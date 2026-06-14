local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BossConfig = require(ReplicatedStorage.Shared.Configs.BossConfig)
local CardsConfig = require(ReplicatedStorage.Shared.Configs.CardsConfig)
local WorldsConfig = require(ReplicatedStorage.Shared.Configs.WorldsConfig)
local FormatNumber = require(ReplicatedStorage.Shared.Utils.FormatNumber)

local Network = require(ReplicatedStorage.Shared.Utils.Network)
local DataManager = require(script.Parent.DataManager)

local CombatService = {}
local activeBosses = {} -- Map of { WorldName = { Name = string, HP = number, MaxHP = number, Level = number } }
local bossContributors = {} -- Map of { WorldName = { [Player] = DamageDealt } }
local lastAttackTime = {} -- Anti-cheat: { [Player] = epochTime }

-- Calculate player's total combat power
function CombatService.CalculatePlayerPower(player: Player)
	local profile = DataManager.GetProfile(player)
	if not profile then return 10 end -- base default power
	
	local totalPower = 0
	local totalDamage = 0
	
	-- Sum stats of all equipped cards
	for _, cardId in ipairs(profile.EquippedCards) do
		local card = nil
		for _, c in ipairs(profile.Inventory) do
			if c.Id == cardId then
				card = c
				break
			end
		end
		if card then
			local cardConf = CardsConfig.Cards[card.Name]
			if cardConf then
				-- Level scaling: +10% stats per card level
				local lvlMultiplier = 1 + (card.Level - 1) * 0.1
				totalPower = totalPower + (cardConf.Power * lvlMultiplier)
				totalDamage = totalDamage + (cardConf.Damage * lvlMultiplier)
			end
		end
	end
	
	-- Apply Potion Damage Buffs
	local activePotions = profile.ActivePotions or {}
	local PotionsConfig = require(ReplicatedStorage.Shared.Configs.PotionsConfig)
	local damageMultiplier = 1.0
	for potName, duration in pairs(activePotions) do
		if duration > 0 then
			local pConf = PotionsConfig.Potions[potName]
			if pConf and pConf.BuffType == "BossDamageMultiplier" then
				damageMultiplier = damageMultiplier * pConf.Value
			end
		end
	end
	
	-- Default stats if no cards equipped
	if totalPower == 0 then totalPower = 10 end
	if totalDamage == 0 then totalDamage = 5 end
	
	return totalDamage * damageMultiplier, totalPower * damageMultiplier
end

-- Spawn a boss in a specific world
local function spawnBoss(worldName: string)
	local wConf = WorldsConfig.Worlds[worldName]
	if not wConf or not wConf.Boss then return end
	
	local bossName = wConf.Boss
	local bossConf = BossConfig.Bosses[bossName]
	if not bossConf then return end
	
	activeBosses[worldName] = {
		Name = bossName,
		DisplayName = bossConf.DisplayName,
		HP = bossConf.MaxHP,
		MaxHP = bossConf.MaxHP,
		Level = bossConf.Level
	}
	
	bossContributors[worldName] = {}
	
	-- Notify clients in this world
	Network.FireAllClients("BossSpawned", worldName, activeBosses[worldName])
	print("Spawned boss " .. bossConf.DisplayName .. " in " .. worldName)
end

-- Distribute boss loot
local function distributeBossRewards(worldName: string, bossData)
	local contributors = bossContributors[worldName]
	if not contributors then return end
	
	local bossConf = BossConfig.Bosses[bossData.Name]
	if not bossConf then return end
	
	-- Calculate total damage dealt to verify
	local totalDamageDealt = 0
	for _, dmg in pairs(contributors) do
		totalDamageDealt = totalDamageDealt + dmg
	end
	if totalDamageDealt == 0 then totalDamageDealt = 1 end
	
	-- Distribute rewards based on damage share
	for player, dmg in pairs(contributors) do
		if player.Parent then
			local profile = DataManager.GetProfile(player)
			if profile then
				local contributionPct = dmg / totalDamageDealt
				
				-- Base calculations
				local goldDropped = math.random(bossConf.Drops.GoldRange.Min, bossConf.Drops.GoldRange.Max) * contributionPct
				local gemsDropped = math.random(bossConf.Drops.GemsRange.Min, bossConf.Drops.GemsRange.Max) * contributionPct
				
				-- Multipliers from Potions
				local activePotions = profile.ActivePotions or {}
				local PotionsConfig = require(ReplicatedStorage.Shared.Configs.PotionsConfig)
				local goldMult = 1.0
				for potName, duration in pairs(activePotions) do
					if duration > 0 then
						local pConf = PotionsConfig.Potions[potName]
						if pConf and pConf.BuffType == "GoldMultiplier" then
							goldMult = goldMult * pConf.Value
						end
					end
				end
				
				-- Gamepass multipliers
				if profile.VIPActive then goldMult = goldMult * 1.5 end
				if profile.DoubleGemsActive then gemsDropped = gemsDropped * 2.0 end
				
				goldDropped = math.floor(goldDropped * goldMult)
				gemsDropped = math.floor(gemsDropped)
				
				-- Give currencies
				profile.Gold = profile.Gold + goldDropped
				profile.Gems = profile.Gems + gemsDropped
				
				-- Fragments drop
				local fragMsg = ""
				if math.random() < bossConf.Drops.Fragments.Chance then
					local frags = math.random(bossConf.Drops.Fragments.Min, bossConf.Drops.Fragments.Max)
					profile.Tokens = profile.Tokens + frags
					fragMsg = string.format(" et +%d Fragments!", frags)
				end
				
				-- Card drops
				local cardMsg = ""
				local HttpService = game:GetService("HttpService")
				for _, dropCard in ipairs(bossConf.Drops.ExclusiveCards) do
					if math.random() < (dropCard.Chance * contributionPct) then
						-- Give card to player
						local uniqueId = HttpService:GenerateGUID(false)
						local newCard = {
							Id = uniqueId,
							Name = dropCard.CardName,
							Level = 1,
							DateObtained = os.time(),
							Serial = profile.Rolls + 1 -- count rolls as Serial
						}
						
						-- Check Inventory capacity
						local maxInvSize = require(ReplicatedStorage.Shared.Configs.UpgradesConfig).InventorySize.GetCapacity(profile.Upgrades.InventorySize)
						if #profile.Inventory < maxInvSize then
							table.insert(profile.Inventory, newCard)
							cardMsg = string.format(" et CARTES EXCLUSIVE: %s!", dropCard.CardName)
						end
						break
					end
				end
				
				-- Update achievements/quests
				local QuestService = require(script.Parent.QuestService)
				if QuestService.OnPlayerDefeatBoss then
					QuestService.OnPlayerDefeatBoss(player)
				end
				
				-- Notify player of rewards
				Network.FireClient(player, "NotifyBossRewards", bossData.DisplayName, goldDropped, gemsDropped, fragMsg .. cardMsg)
			end
		end
	end
	
	-- Clear references and wait respawn
	activeBosses[worldName] = nil
	bossContributors[worldName] = nil
	
	local respawnDelay = bossConf.RespawnTime or 30
	task.spawn(function()
		task.wait(respawnDelay)
		spawnBoss(worldName)
	end)
end

-- Process attacks from players
function CombatService.ProcessAttack(player: Player, targetWorld: string)
	local profile = DataManager.GetProfile(player)
	if not profile then return end
	
	-- Player must be in the world they are attacking
	if profile.CurrentWorld ~= targetWorld then return end
	
	local boss = activeBosses[targetWorld]
	if not boss then return end
	
	-- Rate limit check: max 10 attacks/sec
	local now = os.clock()
	local lastTime = lastAttackTime[player] or 0
	if now - lastTime < 0.09 then -- 90ms min interval
		return
	end
	lastAttackTime[player] = now
	
	-- Calculate damage
	local damage, power = CombatService.CalculatePlayerPower(player)
	
	boss.HP = math.max(0, boss.HP - damage)
	
	-- Track contribution
	local contributors = bossContributors[targetWorld]
	if contributors then
		contributors[player] = (contributors[player] or 0) + damage
	end
	
	-- Sync health update with clients
	Network.FireAllClients("BossHPUpdated", targetWorld, boss.HP, boss.MaxHP)
	
	-- Visual effect trigger
	Network.FireAllClients("SpawnDamageNumber", player.Name, targetWorld, damage)
	
	-- Defeated?
	if boss.HP <= 0 then
		distributeBossRewards(targetWorld, boss)
	end
end

function CombatService.Start()
	-- Initial spawn loop for each world with bosses
	for worldName, wInfo in pairs(WorldsConfig.Worlds) do
		if wInfo.Boss then
			spawnBoss(worldName)
		end
	end
	
	-- Listen to attack signals
	local attackEvent = Network.GetEvent("RequestAttack")
	attackEvent.OnServerEvent:Connect(function(player, targetWorld)
		CombatService.ProcessAttack(player, targetWorld)
	end)
	
	-- RemoteFunction to get active bosses
	local getBossesFunc = Network.GetFunction("GetActiveBosses")
	getBossesFunc.OnServerInvoke = function()
		return activeBosses
	end
end

return CombatService
