-- MainServer.server.lua
-- Entry point for server services initialization.

print("Initializing Anime RNG Legends Server Framework...")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServicesFolder = script.Parent.Services

-- Load Services
local DataManager = require(ServicesFolder.DataManager)
local QuestService = require(ServicesFolder.QuestService)
local CombatService = require(ServicesFolder.CombatService)
local RNGService = require(ServicesFolder.RNGService)
local CraftingService = require(ServicesFolder.CraftingService)
local WorldService = require(ServicesFolder.WorldService)
local TradeService = require(ServicesFolder.TradeService)
local CodeService = require(ServicesFolder.CodeService)
local PotionService = require(ServicesFolder.PotionService)
local LeaderboardService = require(ServicesFolder.LeaderboardService)

-- Start Services in order
local function startService(name, module)
	local success, err = pcall(function()
		if module.Start then
			module.Start()
		end
	end)
	
	if success then
		print("Server Service Started: " .. name)
	else
		warn("Failed to start server service: " .. name .. " - Error: " .. tostring(err))
	end
end

-- DataManager needs to start first to intercept early PlayerAdded events
startService("DataManager", DataManager)

-- Start remaining services
startService("QuestService", QuestService)
startService("CombatService", CombatService)
startService("RNGService", RNGService)
startService("CraftingService", CraftingService)
startService("WorldService", WorldService)
startService("TradeService", TradeService)
startService("CodeService", CodeService)
startService("PotionService", PotionService)
startService("LeaderboardService", LeaderboardService)

print("Anime RNG Legends Server Services Fully Loaded.")
