local ReplicatedStorage = game:GetService("ReplicatedStorage")

local QuestsConfig = require(ReplicatedStorage.Shared.Configs.QuestsConfig)
local AchievementsConfig = require(ReplicatedStorage.Shared.Configs.AchievementsConfig)
local RarityConfig = require(ReplicatedStorage.Shared.Configs.RarityConfig)

local Network = require(ReplicatedStorage.Shared.Utils.Network)
local DataManager = require(script.Parent.DataManager)

local QuestService = {}

-- Check and reset player quests if needed
function QuestService.CheckResets(player: Player)
	local profile = DataManager.GetProfile(player)
	if not profile then return end
	
	local now = os.time()
	local dayLength = 86400
	local weekLength = 604800
	
	-- Daily Reset Check
	if now - profile.LastDailyReset >= dayLength then
		profile.LastDailyReset = now
		profile.QuestsProgress.Daily = {}
		-- Initialize Daily Quests
		for questName, _ in pairs(QuestsConfig.Daily) do
			profile.QuestsProgress.Daily[questName] = 0
		end
		print("Reset daily quests for " .. player.Name)
	end
	
	-- Weekly Reset Check
	if now - profile.LastWeeklyReset >= weekLength then
		profile.LastWeeklyReset = now
		profile.QuestsProgress.Weekly = {}
		-- Initialize Weekly Quests
		for questName, _ in pairs(QuestsConfig.Weekly) do
			profile.QuestsProgress.Weekly[questName] = 0
		end
		print("Reset weekly quests for " .. player.Name)
	end
end

-- Give quest or achievement reward
local function deliverReward(player: Player, rewards)
	local profile = DataManager.GetProfile(player)
	if not profile then return end
	
	if rewards.Gold then
		profile.Gold = profile.Gold + rewards.Gold
	end
	if rewards.Gems then
		profile.Gems = profile.Gems + rewards.Gems
	end
	if rewards.Tokens then
		profile.Tokens = profile.Tokens + rewards.Tokens
	end
	
	if rewards.Potions then
		profile.InventoryPotions = profile.InventoryPotions or {}
		for potName, count in pairs(rewards.Potions) do
			profile.InventoryPotions[potName] = (profile.InventoryPotions[potName] or 0) + count
		end
	end
end

-- Update a quest's progress
local function incrementQuestProgress(player: Player, questCategory: string, questName: string, questInfo, value: number)
	local profile = DataManager.GetProfile(player)
	if not profile then return end
	
	local currentProgress = profile.QuestsProgress[questCategory][questName] or 0
	if currentProgress >= questInfo.Target then return end -- Already completed
	
	local newProgress = math.min(questInfo.Target, currentProgress + value)
	profile.QuestsProgress[questCategory][questName] = newProgress
	
	-- Completed now?
	if newProgress >= questInfo.Target then
		deliverReward(player, questInfo.Rewards)
		Network.FireClient(player, "NotifySuccess", "Quête accomplie: " .. questInfo.Description)
	end
end

-- Hook when player rolls a card
function QuestService.OnPlayerRoll(player: Player, cardRarity: string)
	QuestService.CheckResets(player)
	local profile = DataManager.GetProfile(player)
	if not profile then return end
	
	-- Update Quests
	-- 1. Rolls Count (Daily / Weekly)
	for questName, qInfo in pairs(QuestsConfig.Daily) do
		if qInfo.Type == "Rolls" then
			incrementQuestProgress(player, "Daily", questName, qInfo, 1)
		end
	end
	for questName, qInfo in pairs(QuestsConfig.Weekly) do
		if qInfo.Type == "Rolls" then
			incrementQuestProgress(player, "Weekly", questName, qInfo, 1)
		end
	end
	
	-- 2. ObtainRarity Check
	local rolledRarityOrder = table.find(RarityConfig.Order, cardRarity) or 0
	
	for questName, qInfo in pairs(QuestsConfig.Daily) do
		if qInfo.Type == "ObtainRarity" then
			local reqRarityOrder = table.find(RarityConfig.Order, qInfo.Rarity) or 0
			if rolledRarityOrder >= reqRarityOrder then
				incrementQuestProgress(player, "Daily", questName, qInfo, 1)
			end
		end
	end
	
	for questName, qInfo in pairs(QuestsConfig.Weekly) do
		if qInfo.Type == "ObtainRarity" then
			local reqRarityOrder = table.find(RarityConfig.Order, qInfo.Rarity) or 0
			if rolledRarityOrder >= reqRarityOrder then
				incrementQuestProgress(player, "Weekly", questName, qInfo, 1)
			end
		end
	end
	
	-- Update Achievements
	for achName, achInfo in pairs(AchievementsConfig.Achievements) do
		if profile.UnlockedAchievements[achName] then continue end -- Already unlocked
		
		local unlocked = false
		
		if achInfo.Type == "Rolls" and profile.Rolls >= achInfo.Target then
			unlocked = true
		elseif achInfo.Type == "ObtainRarity" then
			local reqRarityOrder = table.find(RarityConfig.Order, achInfo.Rarity) or 0
			if rolledRarityOrder >= reqRarityOrder then
				unlocked = true
			end
		end
		
		if unlocked then
			profile.UnlockedAchievements[achName] = true
			deliverReward(player, achInfo.Rewards)
			Network.FireClient(player, "NotifySuccess", "Succès débloqué: " .. achInfo.DisplayName)
		end
	end
end

-- Hook when player defeats a boss
function QuestService.OnPlayerDefeatBoss(player: Player)
	QuestService.CheckResets(player)
	
	for questName, qInfo in pairs(QuestsConfig.Daily) do
		if qInfo.Type == "DefeatBoss" then
			incrementQuestProgress(player, "Daily", questName, qInfo, 1)
		end
	end
	for questName, qInfo in pairs(QuestsConfig.Weekly) do
		if qInfo.Type == "DefeatBoss" then
			incrementQuestProgress(player, "Weekly", questName, qInfo, 1)
		end
	end
end

-- Hook when player spends gold
function QuestService.OnPlayerSpendGold(player: Player, amount: number)
	QuestService.CheckResets(player)
	
	for questName, qInfo in pairs(QuestsConfig.Daily) do
		if qInfo.Type == "SpendGold" then
			incrementQuestProgress(player, "Daily", questName, qInfo, amount)
		end
	end
	for questName, qInfo in pairs(QuestsConfig.Weekly) do
		if qInfo.Type == "SpendGold" then
			incrementQuestProgress(player, "Weekly", questName, qInfo, amount)
		end
	end
end

function QuestService.Start()
	-- Connect Player Added validation
	game:GetService("Players").PlayerAdded:Connect(function(player)
		-- Wait for profile to load
		task.wait(2)
		QuestService.CheckResets(player)
	end)
end

return QuestService
