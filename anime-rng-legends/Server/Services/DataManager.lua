local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")

local Network = require(game:GetService("ReplicatedStorage").Shared.Utils.Network)

local DataManager = {}
local profiles = {}

local DATA_STORE_KEY = "AnimeRNGLegends_v1"
local PlayerDataStore = nil

-- Safe DataStore fetch
local function getDataStore()
	if PlayerDataStore then return PlayerDataStore end
	
	local success, err = pcall(function()
		PlayerDataStore = DataStoreService:GetDataStore(DATA_STORE_KEY)
	end)
	
	if not success then
		warn("Failed to get DataStore: " .. tostring(err))
	end
	
	return PlayerDataStore
end

local DEFAULT_DATA = {
	Gold = 500,
	Gems = 50,
	Tokens = 0,
	Rolls = 0,
	CurrentWorld = "AnimeVillage",
	Playtime = 0,
	AutoRollUnlocked = false,
	MultiRollLevel = 1,
	
	Upgrades = {
		Luck = 1,
		RollSpeed = 1,
		InventorySize = 1,
		CriticalLuck = 1
	},
	
	Inventory = {}, -- Array of: { Id = string, Name = string, Level = number, DateObtained = number }
	EquippedCards = {}, -- Array of Card Ids
	
	ActivePotions = {}, -- Dictionary of { PotionName = DurationRemaining }
	
	ClaimedCodes = {}, -- Dictionary of { CodeString = true }
	UnlockedAchievements = {}, -- Dictionary of { AchievementName = true }
	
	QuestsProgress = {
		Daily = {}, -- { QuestName = Progress }
		Weekly = {} -- { QuestName = Progress }
	},
	
	LastDailyReset = 0,
	LastWeeklyReset = 0,
	
	WorldsUnlocked = {
		AnimeVillage = true
	}
}

-- Reconcile player data with DEFAULT_DATA to add newly created keys
local function reconcile(data, template)
	data = data or {}
	for k, v in pairs(template) do
		if data[k] == nil then
			if type(v) == "table" then
				data[k] = reconcile({}, v)
			else
				data[k] = v
			end
		elseif type(v) == "table" and type(data[k]) == "table" then
			data[k] = reconcile(data[k], v)
		end
	end
	return data
end

function DataManager.GetProfile(player: Player)
	return profiles[player]
end

function DataManager.Set(player: Player, key: string, value: any)
	local profile = profiles[player]
	if profile then
		profile[key] = value
	end
end

function DataManager.Update(player: Player, key: string, callback: (any) -> any)
	local profile = profiles[player]
	if profile then
		profile[key] = callback(profile[key])
	end
end

-- Save Data
function DataManager.SaveData(player: Player)
	local profile = profiles[player]
	if not profile then return end
	
	local ds = getDataStore()
	if not ds then return end
	
	local success, err = pcall(function()
		ds:SetAsync(tostring(player.UserId), profile)
	end)
	
	if not success then
		warn("Failed to save data for " .. player.Name .. ": " .. tostring(err))
	else
		print("Successfully saved data for " .. player.Name)
	end
end

-- Load Data
local function loadData(player: Player)
	local ds = getDataStore()
	local data = nil
	
	if ds then
		local success, result = pcall(function()
			return ds:GetAsync(tostring(player.UserId))
		end)
		
		if success and result then
			data = reconcile(result, DEFAULT_DATA)
		elseif not success then
			warn("Failed to retrieve data for " .. player.Name .. ": " .. tostring(result))
		end
	end
	
	if not data then
		print("No data found for " .. player.Name .. ". Creating new profile.")
		-- Deep copy default data
		data = reconcile({}, DEFAULT_DATA)
	end
	
	profiles[player] = data
	return data
end

local function onPlayerAdded(player: Player)
	local data = loadData(player)
	
	-- Track Playtime increment
	task.spawn(function()
		while player.Parent do
			task.wait(1)
			if profiles[player] then
				profiles[player].Playtime = profiles[player].Playtime + 1
			end
		end
	end)
	
	-- Sync to client periodically
	task.spawn(function()
		while player.Parent do
			local currentData = profiles[player]
			if currentData then
				Network.FireClient(player, "SyncData", currentData)
			end
			task.wait(2) -- Sync every 2 seconds
		end
	end)
end

local function onPlayerRemoving(player: Player)
	DataManager.SaveData(player)
	profiles[player] = nil
end

function DataManager.Start()
	-- Connect Players
	Players.PlayerAdded:Connect(onPlayerAdded)
	Players.PlayerRemoving:Connect(onPlayerRemoving)
	
	for _, player in ipairs(Players:GetPlayers()) do
		task.spawn(onPlayerAdded, player)
	end
	
	-- Bind To Close (Shutdown)
	game:BindToClose(function()
		print("Server shutting down. Saving all player data...")
		local threads = {}
		for _, player in ipairs(Players:GetPlayers()) do
			local t = task.spawn(function()
				DataManager.SaveData(player)
			end)
			table.insert(threads, t)
		end
		
		-- Wait for all saves to complete (or time out after 5s)
		local startTime = os.clock()
		while os.clock() - startTime < 4 do
			local running = false
			for _, t in ipairs(threads) do
				if coroutine.status(t) ~= "dead" then
					running = true
					break
				end
			end
			if not running then break end
			task.wait(0.1)
		end
		print("All profiles saved.")
	end)
	
	-- Auto Save loop
	task.spawn(function()
		while true do
			task.wait(60) -- Auto-save every minute
			for _, player in ipairs(Players:GetPlayers()) do
				task.spawn(DataManager.SaveData, player)
			end
		end
	end)
	
	-- Client Requests Sync
	local getProfileFunc = Network.GetFunction("GetProfile")
	getProfileFunc.OnServerInvoke = function(player)
		local profile = profiles[player]
		while not profile and player.Parent do
			task.wait(0.1)
			profile = profiles[player]
		end
		return profile
	end

	-- Equip / Unequip Card
	local equipEvent = Network.GetEvent("ToggleEquipCard")
	equipEvent.OnServerEvent:Connect(function(player, cardId)
		local profile = profiles[player]
		if not profile then return end
		if not cardId or type(cardId) ~= "string" then return end

		-- Verify card exists in inventory
		local found = false
		for _, c in ipairs(profile.Inventory) do
			if c.Id == cardId then found = true break end
		end
		if not found then return end

		local idx = table.find(profile.EquippedCards, cardId)
		if idx then
			-- Unequip
			table.remove(profile.EquippedCards, idx)
			Network.FireClient(player, "NotifySuccess", "Carte déséquipée.")
		else
			-- Max 3 equipped cards at once
			if #profile.EquippedCards >= 3 then
				Network.FireClient(player, "NotifyError", "Limite de 3 cartes équipées atteinte!")
				return
			end
			table.insert(profile.EquippedCards, cardId)
			Network.FireClient(player, "NotifySuccess", "Carte équipée!")
		end
	end)

	-- Buy Upgrade
	local upgradeEvent = Network.GetEvent("RequestUpgrade")
	upgradeEvent.OnServerEvent:Connect(function(player, upgradeKey)
		local profile = profiles[player]
		if not profile then return end

		local UpgradesConfig = require(game:GetService("ReplicatedStorage").Shared.Configs.UpgradesConfig)
		local upgradeConf = UpgradesConfig[upgradeKey]
		if not upgradeConf then
			Network.FireClient(player, "NotifyError", "Amélioration inconnue.")
			return
		end

		local currentLvl = profile.Upgrades[upgradeKey] or 1
		if currentLvl >= upgradeConf.MaxLevel then
			Network.FireClient(player, "NotifyError", "Niveau maximum atteint!")
			return
		end

		local cost = upgradeConf.GetCost(currentLvl)
		local currency = (upgradeKey == "CriticalLuck") and "Gems" or "Gold"

		if currency == "Gems" then
			if profile.Gems < cost then
				Network.FireClient(player, "NotifyError", "Gemmes insuffisantes!")
				return
			end
			profile.Gems = profile.Gems - cost
		else
			if profile.Gold < cost then
				Network.FireClient(player, "NotifyError", "Or insuffisant!")
				return
			end
			profile.Gold = profile.Gold - cost
		end

		profile.Upgrades[upgradeKey] = currentLvl + 1

		-- Track SpendGold quest
		if currency == "Gold" then
			local QuestService = require(script.Parent.QuestService)
			if QuestService.OnPlayerSpendGold then
				QuestService.OnPlayerSpendGold(player, cost)
			end
		end

		Network.FireClient(player, "NotifySuccess", "Amélioration achetée! Niveau " .. (currentLvl + 1))
	end)
end

return DataManager
