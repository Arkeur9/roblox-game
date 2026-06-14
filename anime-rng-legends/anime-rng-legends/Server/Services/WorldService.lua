local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WorldsConfig = require(ReplicatedStorage.Shared.Configs.WorldsConfig)
local Network = require(ReplicatedStorage.Shared.Utils.Network)
local DataManager = require(script.Parent.DataManager)

local WorldService = {}

-- Securely unlock a world
function WorldService.UnlockWorld(player: Player, worldName: string)
	local profile = DataManager.GetProfile(player)
	if not profile then return false, "No Data loaded" end
	
	local wInfo = WorldsConfig.Worlds[worldName]
	if not wInfo then
		return false, "Monde introuvable."
	end
	
	if profile.WorldsUnlocked[worldName] then
		return false, "Ce monde est déjà débloqué."
	end
	
	-- Verify cost
	local cost = wInfo.Cost or 0
	local currency = wInfo.Currency or "Gold"
	
	if currency == "Gold" then
		if profile.Gold < cost then
			return false, "Or insuffisant."
		end
		profile.Gold = profile.Gold - cost
		-- Track quest spend
		local QuestService = require(script.Parent.QuestService)
		QuestService.OnPlayerSpendGold(player, cost)
	elseif currency == "Gems" then
		if profile.Gems < cost then
			return false, "Gemmes insuffisantes."
		end
		profile.Gems = profile.Gems - cost
	else
		return false, "Type de monnaie invalide."
	end
	
	profile.WorldsUnlocked[worldName] = true
	
	-- Notify client
	Network.FireClient(player, "NotifySuccess", "Monde débloqué: " .. wInfo.DisplayName)
	return true
end

-- Teleport player to a world
function WorldService.TeleportToWorld(player: Player, worldName: string)
	local profile = DataManager.GetProfile(player)
	if not profile then return false, "No Data loaded" end
	
	if not profile.WorldsUnlocked[worldName] then
		return false, "Ce monde n'est pas encore débloqué."
	end
	
	profile.CurrentWorld = worldName
	
	-- In an actual game, you would teleport the player's character:
	-- local character = player.Character
	-- if character and character:FindFirstChild("HumanoidRootPart") then
	--     local spawnPoint = workspace:FindFirstChild(worldName .. "Spawn")
	--     if spawnPoint then
	--         character.HumanoidRootPart.CFrame = spawnPoint.CFrame + Vector3.new(0, 3, 0)
	--     end
	-- end
	
	Network.FireClient(player, "NotifySuccess", "Téléporté dans " .. WorldsConfig.Worlds[worldName].DisplayName)
	return true
end

function WorldService.Start()
	-- Connect remote functions
	local unlockFunc = Network.GetFunction("RequestUnlockWorld")
	unlockFunc.OnServerInvoke = function(player, worldName)
		return WorldService.UnlockWorld(player, worldName)
	end
	
	local teleportFunc = Network.GetFunction("RequestTeleportToWorld")
	teleportFunc.OnServerInvoke = function(player, worldName)
		return WorldService.TeleportToWorld(player, worldName)
	end
end

return WorldService
