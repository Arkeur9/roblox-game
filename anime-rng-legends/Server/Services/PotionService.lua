local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PotionsConfig = require(ReplicatedStorage.Shared.Configs.PotionsConfig)
local Network = require(ReplicatedStorage.Shared.Utils.Network)
local DataManager = require(script.Parent.DataManager)

local PotionService = {}

-- Consume and activate potion
function PotionService.UsePotion(player: Player, potionName: string)
	local profile = DataManager.GetProfile(player)
	if not profile then return false, "No Data loaded" end
	
	-- Verify potion definition
	local potConf = PotionsConfig.Potions[potionName]
	if not potConf then
		return false, "Potion inconnue."
	end
	
	-- Verify quantity in inventory
	profile.InventoryPotions = profile.InventoryPotions or {}
	local count = profile.InventoryPotions[potionName] or 0
	if count <= 0 then
		return false, "Vous n'avez pas cette potion."
	end
	
	-- Deduct
	profile.InventoryPotions[potionName] = count - 1
	
	-- Activate Potion (stack duration if already active)
	profile.ActivePotions = profile.ActivePotions or {}
	local currentDur = profile.ActivePotions[potionName] or 0
	profile.ActivePotions[potionName] = currentDur + potConf.Duration
	
	Network.FireClient(player, "NotifySuccess", "Potion activée: " .. potConf.DisplayName)
	return true
end

function PotionService.Start()
	local usePotionFunc = Network.GetFunction("RequestUsePotion")
	usePotionFunc.OnServerInvoke = function(player, potionName)
		return PotionService.UsePotion(player, potionName)
	end
	
	-- Tick down timer loop
	task.spawn(function()
		while true do
			task.wait(1)
			
			for _, player in ipairs(Players:GetPlayers()) do
				local profile = DataManager.GetProfile(player)
				if profile and profile.ActivePotions then
					local activeList = profile.ActivePotions
					local updated = false
					
					for potName, duration in pairs(activeList) do
						if duration > 0 then
							activeList[potName] = math.max(0, duration - 1)
							updated = true
						end
					end
					
					-- Optional: Sync active potions to client if changed
					if updated then
						Network.FireClient(player, "SyncActivePotions", activeList)
					end
				end
			end
		end
	end)
end

return PotionService
