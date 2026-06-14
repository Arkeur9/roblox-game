local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Network = require(ReplicatedStorage.Shared.Utils.Network)
local DataManager = require(script.Parent.DataManager)
local CombatService = require(script.Parent.CombatService)

local LeaderboardService = {}
local cachedLeaderboards = {
	Rolls = {},
	Power = {},
	Playtime = {},
	Gold = {}
}

-- Safe fetch OrderedDataStore
local function getOrderedStore(name: string)
	local store = nil
	local success, err = pcall(function()
		store = DataStoreService:GetOrderedDataStore("Leaderboard_" .. name .. "_v1")
	end)
	if not success then
		warn("Failed to get OrderedDataStore " .. name .. ": " .. tostring(err))
	end
	return store
end

-- Refresh rankings from OrderedDataStore
local function refreshRankings(name: string)
	local store = getOrderedStore(name)
	if not store then return end
	
	local success, pages = pcall(function()
		return store:GetSortedAsync(false, 10) -- top 10, descending
	end)
	
	if success and pages then
		local newRankings = {}
		local currentPage = pages:GetCurrentPage()
		
		for rank, data in ipairs(currentPage) do
			local userId = tonumber(data.key)
			local score = data.value
			
			-- Resolve name
			local username = "Unknown"
			local nameSuccess, resolvedName = pcall(function()
				return Players:GetNameFromUserIdAsync(userId)
			end)
			if nameSuccess then
				username = resolvedName
			end
			
			table.insert(newRankings, {
				Rank = rank,
				Name = username,
				Value = score
			})
		end
		
		cachedLeaderboards[name] = newRankings
		-- Broadcast to all clients
		Network.FireAllClients("UpdateLeaderboardCache", name, newRankings)
	else
		warn("Failed to retrieve rankings for " .. name)
	end
end

-- Push a player's score to the data stores
function LeaderboardService.UpdatePlayerScore(player: Player)
	local profile = DataManager.GetProfile(player)
	if not profile then return end
	
	local rollsStore = getOrderedStore("Rolls")
	local powerStore = getOrderedStore("Power")
	local playtimeStore = getOrderedStore("Playtime")
	local goldStore = getOrderedStore("Gold")
	
	-- Calculate power
	local _, power = CombatService.CalculatePlayerPower(player)
	
	if rollsStore then pcall(function() rollsStore:SetAsync(tostring(player.UserId), profile.Rolls) end) end
	if powerStore then pcall(function() powerStore:SetAsync(tostring(player.UserId), math.floor(power)) end) end
	if playtimeStore then pcall(function() playtimeStore:SetAsync(tostring(player.UserId), profile.Playtime) end) end
	if goldStore then pcall(function() goldStore:SetAsync(tostring(player.UserId), profile.Gold) end) end
end

function LeaderboardService.Start()
	-- Connect remote retrieve func
	local getLeaderboardFunc = Network.GetFunction("GetLeaderboard")
	getLeaderboardFunc.OnServerInvoke = function(player, boardName)
		return cachedLeaderboards[boardName] or {}
	end
	
	-- Periodically update scores and refresh rankings
	task.spawn(function()
		while true do
			task.wait(60) -- Every 60s
			
			-- Update current players
			for _, player in ipairs(Players:GetPlayers()) do
				pcall(LeaderboardService.UpdatePlayerScore, player)
			end
			
			-- Refresh rankings
			refreshRankings("Rolls")
			task.wait(2)
			refreshRankings("Power")
			task.wait(2)
			refreshRankings("Playtime")
			task.wait(2)
			refreshRankings("Gold")
		end
	end)
end

return LeaderboardService
