local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CodesConfig = require(ReplicatedStorage.Shared.Configs.CodesConfig)
local Network = require(ReplicatedStorage.Shared.Utils.Network)
local DataManager = require(script.Parent.DataManager)

local CodeService = {}

function CodeService.RedeemCode(player: Player, codeString: string)
	local profile = DataManager.GetProfile(player)
	if not profile then return false, "No Data loaded" end
	
	codeString = string.upper(codeString)
	
	-- Verify code existence
	local rewardRule = CodesConfig.Codes[codeString]
	if not rewardRule then
		return false, "Code invalide."
	end
	
	-- Check if claimed
	if profile.ClaimedCodes[codeString] then
		return false, "Code déjà utilisé."
	end
	
	-- Claim code
	profile.ClaimedCodes[codeString] = true
	
	-- Deliver rewards
	local rewards = rewardRule.Rewards
	if rewards.Gold then
		profile.Gold = profile.Gold + rewards.Gold
	end
	if rewards.Gems then
		profile.Gems = profile.Gems + rewards.Gems
	end
	if rewards.Tokens then
		profile.Tokens = profile.Tokens + rewards.Tokens
	end
	
	local potionMsgs = {}
	if rewards.Potions then
		profile.InventoryPotions = profile.InventoryPotions or {}
		for potName, count in pairs(rewards.Potions) do
			profile.InventoryPotions[potName] = (profile.InventoryPotions[potName] or 0) + count
			table.insert(potionMsgs, count .. "x " .. potName)
		end
	end
	
	-- Sync success
	local msg = "Code activé!"
	if rewards.Gold then msg = msg .. " +" .. rewards.Gold .. " Or" end
	if rewards.Gems then msg = msg .. " +" .. rewards.Gems .. " Gemmes" end
	if #potionMsgs > 0 then msg = msg .. " et " .. table.concat(potionMsgs, ", ") end
	
	Network.FireClient(player, "NotifySuccess", msg)
	return true
end

function CodeService.Start()
	local redeemFunc = Network.GetFunction("RequestCodeRedeem")
	redeemFunc.OnServerInvoke = function(player, codeString)
		return CodeService.RedeemCode(player, codeString)
	end
end

return CodeService
