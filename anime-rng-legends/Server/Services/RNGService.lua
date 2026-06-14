local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CardsConfig = require(ReplicatedStorage.Shared.Configs.CardsConfig)
local RarityConfig = require(ReplicatedStorage.Shared.Configs.RarityConfig)
local UpgradesConfig = require(ReplicatedStorage.Shared.Configs.UpgradesConfig)
local WorldsConfig = require(ReplicatedStorage.Shared.Configs.WorldsConfig)

local Network = require(ReplicatedStorage.Shared.Utils.Network)
local DataManager = require(script.Parent.DataManager)

local RNGService = {}
local lastRollTime = {} -- Tracks player cooldowns to prevent speed exploits

-- Roll formulas
function RNGService.CalculatePlayerLuck(player: Player, profile)
	-- 1. Base Upgrade Luck
	local luckUpgradeLvl = profile.Upgrades.Luck
	local luckMultiplier = UpgradesConfig.Luck.GetMultiplier(luckUpgradeLvl)
	
	-- 2. Potion Buffs
	local activePotions = profile.ActivePotions or {}
	local PotionsConfig = require(ReplicatedStorage.Shared.Configs.PotionsConfig)
	for potName, duration in pairs(activePotions) do
		if duration > 0 then
			local pConf = PotionsConfig.Potions[potName]
			if pConf and pConf.BuffType == "Luck" then
				luckMultiplier = luckMultiplier * pConf.Value
			end
		end
	end
	
	-- 3. World Multipliers
	local currentWorld = profile.CurrentWorld or "AnimeVillage"
	local wConf = WorldsConfig.Worlds[currentWorld]
	if wConf then
		luckMultiplier = luckMultiplier * wConf.LuckMultiplier
	end
	
	-- 4. Equipped Cards Luck Bonuses
	for _, cardId in ipairs(profile.EquippedCards) do
		local equippedCard = nil
		for _, c in ipairs(profile.Inventory) do
			if c.Id == cardId then
				equippedCard = c
				break
			end
		end
		if equippedCard then
			local cardConf = CardsConfig.Cards[equippedCard.Name]
			if cardConf and cardConf.LuckBonus then
				luckMultiplier = luckMultiplier + cardConf.LuckBonus
			end
		end
	end
	
	-- 5. Gamepasses/VIP (Simulated via check or flag in data)
	if profile.VIPActive then
		luckMultiplier = luckMultiplier * 1.5 -- VIP gamepass +50%
	end
	if profile.DoubleLuckActive then
		luckMultiplier = luckMultiplier * 2.0 -- 2x Luck gamepass
	end
	
	return luckMultiplier
end

-- Select Card based on Luck
local function selectCardFromRNG(luckMultiplier, worldCardsPool, criticalLuckChance)
	-- Roll Critical Luck
	local isCritical = math.random() < criticalLuckChance
	local rollLuck = luckMultiplier
	if isCritical then
		rollLuck = luckMultiplier * UpgradesConfig.CriticalLuck.GetMultiplier()
	end
	
	-- Gather candidates and sort by Rarity weight
	local rollValue = math.random() * rollLuck
	local chosenCard = nil
	local chosenRarityOrder = -1
	
	-- Filter cards by world restriction. If world pool is empty, all cards are available.
	local allowedCards = CardsConfig.Cards
	local hasPool = worldCardsPool and #worldCardsPool > 0
	
	for cardKey, cInfo in pairs(allowedCards) do
		-- Do not roll evolved forms directly
		if cInfo.IsEvolved then continue end
		
		-- World verification
		if hasPool then
			local matched = false
			for _, pCard in ipairs(worldCardsPool) do
				if pCard == cardKey then
					matched = true
					break
				end
			end
			if not matched then continue end
		end
		
		local rInfo = RarityConfig.Rarities[cInfo.Rarity]
		if not rInfo then continue end
		
		-- Standard RNG check: Weight check
		-- Chance defines a 1/Chance probability. 
		-- We check if rollLuck * Random >= Chance.
		local finalChance = rInfo.Chance
		local rollOdds = math.random() * rollLuck
		if rollOdds >= (1 / finalChance) * rollLuck then
			-- Compare order. Higher rarity order = more rare
			local rarityOrderIdx = table.find(RarityConfig.Order, cInfo.Rarity) or 0
			if rarityOrderIdx > chosenRarityOrder then
				chosenCard = cardKey
				chosenRarityOrder = rarityOrderIdx
			end
		end
	end
	
	-- Fallback if nothing rolled (fallback to first common)
	if not chosenCard then
		chosenCard = "Sakury"
	end
	
	return chosenCard, isCritical
end

-- Perform a Single Roll
function RNGService.PerformRoll(player: Player)
	local profile = DataManager.GetProfile(player)
	if not profile then return false, "No Data loaded" end
	
	-- Cooldown protection
	local now = os.clock()
	local speedLvl = profile.Upgrades.RollSpeed
	local baseCooldown = UpgradesConfig.RollSpeed.GetCooldown(speedLvl)
	
	-- Check Speed Potion buff
	local activePotions = profile.ActivePotions or {}
	local PotionsConfig = require(ReplicatedStorage.Shared.Configs.PotionsConfig)
	for potName, duration in pairs(activePotions) do
		if duration > 0 then
			local pConf = PotionsConfig.Potions[potName]
			if pConf and pConf.BuffType == "RollSpeed" then
				baseCooldown = baseCooldown * pConf.Value
			end
		end
	end
	
	local lastTime = lastRollTime[player] or 0
	if now - lastTime < (baseCooldown - 0.05) then -- 0.05s ping tolerance
		return false, "Roll is on cooldown"
	end
	lastRollTime[player] = now
	
	-- Check inventory limit
	local maxInvSize = UpgradesConfig.InventorySize.GetCapacity(profile.Upgrades.InventorySize)
	if #profile.Inventory >= maxInvSize then
		return false, "Inventory is full"
	end
	
	-- Calculate total luck
	local luckMultiplier = RNGService.CalculatePlayerLuck(player, profile)
	
	-- Critical Luck Chance
	local critChanceLvl = profile.Upgrades.CriticalLuck or 1
	local critChance = UpgradesConfig.CriticalLuck.GetChance(critChanceLvl)
	
	-- Get world card restrictions
	local currentWorld = profile.CurrentWorld or "AnimeVillage"
	local wConf = WorldsConfig.Worlds[currentWorld]
	local worldPool = wConf and wConf.ExclusiveCards
	
	local rolledCardName, wasCritical = selectCardFromRNG(luckMultiplier, worldPool, critChance)
	local cardData = CardsConfig.Cards[rolledCardName]
	
	-- Create card structure
	local uniqueId = HttpService:GenerateGUID(false)
	local newCard = {
		Id = uniqueId,
		Name = rolledCardName,
		Level = 1,
		DateObtained = os.time(),
		Serial = profile.Rolls + 1
	}
	
	-- Insert to Inventory
	table.insert(profile.Inventory, newCard)
	
	-- Increment Rolls
	profile.Rolls = profile.Rolls + 1
	
	-- Achievements check
	local AchievementsService = require(script.Parent.QuestService) -- Quests & Achievements managed together
	if AchievementsService.OnPlayerRoll then
		AchievementsService.OnPlayerRoll(player, cardData.Rarity)
	end
	
	-- Fire visuals and sound events on client
	Network.FireClient(player, "PlayRollVisuals", rolledCardName, wasCritical)
	
	-- Server announcement for high tier
	local rarityInfo = RarityConfig.Rarities[cardData.Rarity]
	if rarityInfo and rarityInfo.Announce then
		Network.FireAllClients("BroadcastAnnouncement", player.Name, rolledCardName, cardData.Rarity)
	end
	
	return true, newCard
end

function RNGService.Start()
	-- Connect Network RemoteEvents
	local rollEvent = Network.GetEvent("RequestRoll")
	rollEvent.OnServerEvent:Connect(function(player)
		local success, result = RNGService.PerformRoll(player)
		if not success then
			-- Send error to client
			Network.FireClient(player, "NotifyError", result)
		end
	end)
end

return RNGService
