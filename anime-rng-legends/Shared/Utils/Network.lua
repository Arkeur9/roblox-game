local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Network = {}
local remotesFolder = nil

-- Find or create the Remotes folder
local function getRemotesFolder()
	if remotesFolder then return remotesFolder end
	
	if RunService:IsServer() then
		remotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
		if not remotesFolder then
			remotesFolder = Instance.new("Folder")
			remotesFolder.Name = "Remotes"
			remotesFolder.Parent = ReplicatedStorage
		end
	else
		remotesFolder = ReplicatedStorage:WaitForChild("Remotes")
	end
	
	return remotesFolder
end

-- Events
function Network.GetEvent(name: string): RemoteEvent
	local folder = getRemotesFolder()
	local event = folder:FindFirstChild(name)
	
	if not event and RunService:IsServer() then
		event = Instance.new("RemoteEvent")
		event.Name = name
		event.Parent = folder
	elseif not event then
		event = folder:WaitForChild(name, 5)
		if not event then
			warn("RemoteEvent not found after 5s: " .. name)
		end
	end
	
	return event
end

function Network.FireServer(name: string, ...)
	local event = Network.GetEvent(name)
	if event then
		event:FireServer(...)
	end
end

function Network.FireClient(player: Player, name: string, ...)
	local event = Network.GetEvent(name)
	if event then
		event:FireClient(player, ...)
	end
end

function Network.FireAllClients(name: string, ...)
	local event = Network.GetEvent(name)
	if event then
		event:FireAllClients(...)
	end
end

-- Functions
function Network.GetFunction(name: string): RemoteFunction
	local folder = getRemotesFolder()
	local func = folder:FindFirstChild(name)
	
	if not func and RunService:IsServer() then
		func = Instance.new("RemoteFunction")
		func.Name = name
		func.Parent = folder
	elseif not func then
		func = folder:WaitForChild(name, 5)
		if not func then
			warn("RemoteFunction not found after 5s: " .. name)
		end
	end
	
	return func
end

function Network.InvokeServer(name: string, ...)
	local func = Network.GetFunction(name)
	if func then
		return func:InvokeServer(...)
	end
end

return Network
