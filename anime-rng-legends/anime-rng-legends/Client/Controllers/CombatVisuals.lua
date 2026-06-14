local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Network = require(ReplicatedStorage.Shared.Utils.Network)
local FormatNumber = require(ReplicatedStorage.Shared.Utils.FormatNumber)

local CombatVisuals = {}
local localPlayer = Players.LocalPlayer
local bossHUDFrame = nil

-- Update boss health bar UI
local function updateBossUI(bossData, currentHP, maxHP)
	local sg = localPlayer:WaitForChild("PlayerGui"):FindFirstChild("AnimeRNGLegendsGUI")
	if not sg then return end
	
	if not bossHUDFrame then
		bossHUDFrame = Instance.new("Frame")
		bossHUDFrame.Name = "BossHPFrame"
		bossHUDFrame.Size = UDim2.fromScale(0.35, 0.08)
		bossHUDFrame.Position = UDim2.fromScale(0.5, 0.1)
		bossHUDFrame.AnchorPoint = Vector2.new(0.5, 0)
		bossHUDFrame.BackgroundColor3 = Color3.fromRGB(30, 20, 20)
		bossHUDFrame.BorderSizePixel = 0
		bossHUDFrame.Parent = sg
		
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 8)
		corner.Parent = bossHUDFrame
		
		local stroke = Instance.new("UIStroke")
		stroke.Color = Color3.fromRGB(240, 80, 80)
		stroke.Thickness = 2
		stroke.Parent = bossHUDFrame
		
		-- Title Label
		local title = Instance.new("TextLabel")
		title.Name = "Title"
		title.Size = UDim2.fromScale(1, 0.45)
		title.Position = UDim2.fromScale(0, 0.05)
		title.BackgroundTransparency = 1
		title.Text = "Boss Name"
		title.Font = Enum.Font.Outfit
		title.TextSize = 14
		title.TextColor3 = Color3.new(1, 1, 1)
		title.Parent = bossHUDFrame
		
		-- Health Bar BG
		local hbBG = Instance.new("Frame")
		hbBG.Name = "BarBG"
		hbBG.Size = UDim2.fromScale(0.9, 0.25)
		hbBG.Position = UDim2.fromScale(0.05, 0.55)
		hbBG.BackgroundColor3 = Color3.fromRGB(15, 10, 10)
		hbBG.BorderSizePixel = 0
		hbBG.Parent = bossHUDFrame
		
		local bCor = Instance.new("UICorner")
		bCor.CornerRadius = UDim.new(0, 4)
		bCor.Parent = hbBG
		
		-- Health Bar Fill
		local hbFill = Instance.new("Frame")
		hbFill.Name = "BarFill"
		hbFill.Size = UDim2.fromScale(1, 1)
		hbFill.BackgroundColor3 = Color3.fromRGB(240, 60, 60)
		hbFill.BorderSizePixel = 0
		hbFill.Parent = hbBG
		
		local fCor = Instance.new("UICorner")
		fCor.CornerRadius = UDim.new(0, 4)
		fCor.Parent = hbFill
	end
	
	bossHUDFrame.Title.Text = string.format("BOSS: %s (Lvl %d)", bossData.DisplayName, bossData.Level)
	
	local fillFrame = bossHUDFrame.BarBG.BarFill
	local ratio = math.clamp(currentHP / maxHP, 0, 1)
	
	TweenService:Create(fillFrame, TweenInfo.new(0.2), {Size = UDim2.fromScale(ratio, 1)}):Play()
	
	if currentHP <= 0 then
		bossHUDFrame.Visible = false
	else
		bossHUDFrame.Visible = true
	end
end

-- Floating damage indicators
function CombatVisuals.SpawnDamageIndicator(playerName: string, dmg: number)
	local sg = localPlayer:WaitForChild("PlayerGui"):FindFirstChild("AnimeRNGLegendsGUI")
	if not sg then return end
	
	local dmgLbl = Instance.new("TextLabel")
	dmgLbl.Size = UDim2.fromOffset(80, 30)
	
	-- Pick a random position near the middle of the screen
	local rx = 0.4 + (math.random() * 0.2)
	local ry = 0.3 + (math.random() * 0.2)
	dmgLbl.Position = UDim2.fromScale(rx, ry)
	dmgLbl.BackgroundTransparency = 1
	dmgLbl.Text = "-" .. FormatNumber.FormatCompact(dmg)
	dmgLbl.Font = Enum.Font.Outfit
	dmgLbl.TextSize = 22
	dmgLbl.TextColor3 = playerName == localPlayer.Name and Color3.fromRGB(255, 230, 80) or Color3.fromRGB(240, 240, 240)
	dmgLbl.Parent = sg
	
	-- Animate floating upwards and fade out
	local targetPos = UDim2.fromScale(rx, ry - 0.12)
	TweenService:Create(dmgLbl, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = targetPos,
		TextTransparency = 1
	}):Play()
	
	task.spawn(function()
		task.wait(0.8)
		dmgLbl:Destroy()
	end)
end

function CombatVisuals.Start()
	-- Connect Boss HP synchronization
	local hpEvent = Network.GetEvent("BossHPUpdated")
	hpEvent.OnClientEvent:Connect(function(worldName, currentHP, maxHP)
		local profile = localPlayer:FindFirstChild("PlayerGui") and Network.InvokeServer("GetProfile")
		if profile and profile.CurrentWorld == worldName then
			-- Query full boss details
			local getBosses = Network.GetFunction("GetActiveBosses")
			local activeList = getBosses:InvokeServer()
			local boss = activeList[worldName]
			if boss then
				updateBossUI(boss, currentHP, maxHP)
			end
		elseif bossHUDFrame then
			bossHUDFrame.Visible = false
		end
	end)
	
	local spawnEvent = Network.GetEvent("BossSpawned")
	spawnEvent.OnClientEvent:Connect(function(worldName, bossData)
		local profile = Network.InvokeServer("GetProfile")
		if profile and profile.CurrentWorld == worldName then
			updateBossUI(bossData, bossData.HP, bossData.MaxHP)
		end
	end)
	
	-- Damage indicator event
	local dmgEvent = Network.GetEvent("SpawnDamageNumber")
	dmgEvent.OnClientEvent:Connect(function(playerName, targetWorld, dmgValue)
		local profile = Network.InvokeServer("GetProfile")
		if profile and profile.CurrentWorld == targetWorld then
			CombatVisuals.SpawnDamageIndicator(playerName, dmgValue)
		end
	end)
	
	-- Combat Attack Input Loop (Simulates clicking the screen to attack the boss)
	-- To make combat feel dynamic, player clicking anywhere on screen triggers attack request.
	local UserInputService = game:GetService("UserInputService")
	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			local profile = Network.InvokeServer("GetProfile")
			if profile and profile.CurrentWorld then
				Network.FireServer("RequestAttack", profile.CurrentWorld)
			end
		end
	end)
end

return CombatVisuals
