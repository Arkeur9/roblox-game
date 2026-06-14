local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CardsConfig = require(ReplicatedStorage.Shared.Configs.CardsConfig)
local RarityConfig = require(ReplicatedStorage.Shared.Configs.RarityConfig)
local FormatNumber = require(ReplicatedStorage.Shared.Utils.FormatNumber)
local Network = require(ReplicatedStorage.Shared.Utils.Network)

local RNGVisuals = {}
local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Screen shaking utility
local function triggerScreenShake(intensity: number)
	task.spawn(function()
		local originalCF = camera.CFrame
		local duration = 1.5
		local startTime = os.clock()
		
		while os.clock() - startTime < duration do
			local elapsed = os.clock() - startTime
			local fade = 1 - (elapsed / duration)
			local offsetX = (math.random() - 0.5) * intensity * 0.1 * fade
			local offsetY = (math.random() - 0.5) * intensity * 0.1 * fade
			local offsetZ = (math.random() - 0.5) * intensity * 0.1 * fade
			
			camera.CFrame = camera.CFrame * CFrame.new(offsetX, offsetY, offsetZ)
			task.wait(0.02)
		end
	end)
end

-- Play epic audio pull
local function playSound(soundId: string)
	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	sound.Volume = 0.8
	sound.PlayOnRemove = true
	sound.Parent = SoundService
	sound:Destroy()
end

-- Trigger rolling visual overlay
function RNGVisuals.PlayRollVisuals(cardName: string, wasCritical: boolean)
	local cardInfo = CardsConfig.Cards[cardName]
	if not cardInfo then return end
	
	local rarityInfo = RarityConfig.Rarities[cardInfo.Rarity]
	local rarityColor = rarityInfo and rarityInfo.Color or Color3.new(1, 1, 1)
	
	local playerGui = localPlayer:WaitForChild("PlayerGui")
	local sg = playerGui:FindFirstChild("AnimeRNGLegendsGUI")
	if not sg then return end
	
	-- Create Roll Reveal Overlay Screen
	local revealFrame = Instance.new("Frame")
	revealFrame.Name = "RevealOverlay"
	revealFrame.Size = UDim2.fromScale(1, 1)
	revealFrame.BackgroundColor3 = Color3.new(0, 0, 0)
	revealFrame.BackgroundTransparency = 0.5
	revealFrame.BorderSizePixel = 0
	revealFrame.Parent = sg
	
	-- Centered Reveal Card Info
	local cardFrame = Instance.new("CanvasGroup")
	cardFrame.Size = UDim2.fromScale(0.3, 0.45)
	cardFrame.Position = UDim2.fromScale(0.5, 0.5)
	cardFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	cardFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
	cardFrame.GroupTransparency = 1
	cardFrame.Parent = revealFrame
	
	local cardCorner = Instance.new("UICorner")
	cardCorner.CornerRadius = UDim.new(0, 16)
	cardCorner.Parent = cardFrame
	
	local stroke = Instance.new("UIStroke")
	stroke.Color = rarityColor
	stroke.Thickness = 4
	stroke.Parent = cardFrame
	
	-- Display text elements
	local title = Instance.new("TextLabel")
	title.Size = UDim2.fromScale(1, 0.25)
	title.Position = UDim2.fromScale(0, 0.1)
	title.BackgroundTransparency = 1
	title.Text = cardInfo.DisplayName
	title.Font = Enum.Font.SourceSans
	title.TextSize = 28
	title.TextColor3 = Color3.new(1, 1, 1)
	title.Parent = cardFrame
	
	local rarity = Instance.new("TextLabel")
	rarity.Size = UDim2.fromScale(1, 0.15)
	rarity.Position = UDim2.fromScale(0, 0.35)
	rarity.BackgroundTransparency = 1
	rarity.Text = cardInfo.Rarity:upper()
	rarity.Font = Enum.Font.SourceSans
	rarity.TextSize = 16
	rarity.TextColor3 = rarityColor
	rarity.Parent = cardFrame
	
	local odds = rarityInfo and rarityInfo.Chance or 1
	local oddsText = string.format("Probabilité: 1/%s", FormatNumber.FormatWithCommas(odds))
	
	local oddsLbl = Instance.new("TextLabel")
	oddsLbl.Size = UDim2.fromScale(1, 0.15)
	oddsLbl.Position = UDim2.fromScale(0, 0.5)
	oddsLbl.BackgroundTransparency = 1
	oddsLbl.Text = oddsText
	oddsLbl.Font = Enum.Font.SourceSans
	oddsLbl.TextSize = 14
	oddsLbl.TextColor3 = Color3.fromRGB(180, 180, 190)
	oddsLbl.Parent = cardFrame
	
	if wasCritical then
		local critLbl = Instance.new("TextLabel")
		critLbl.Size = UDim2.fromScale(1, 0.15)
		critLbl.Position = UDim2.fromScale(0, 0.65)
		critLbl.BackgroundTransparency = 1
		critLbl.Text = "CHANCE CRITIQUE!"
		critLbl.Font = Enum.Font.SourceSans
		critLbl.TextSize = 18
		critLbl.TextColor3 = Color3.fromRGB(255, 100, 100)
		critLbl.Parent = cardFrame
	end
	
	-- Trigger Sound
	if rarityInfo and rarityInfo.SoundId then
		playSound(rarityInfo.SoundId)
	end
	
	-- Screen Shake
	if rarityInfo and rarityInfo.Shake and rarityInfo.ShakeIntensity then
		triggerScreenShake(rarityInfo.ShakeIntensity)
	end
	
	-- Extra full-screen flash for Divine+
	local orderIndex = table.find(RarityConfig.Order, cardInfo.Rarity) or 0
	local divineOrder = table.find(RarityConfig.Order, "Divine") or 8
	
	if orderIndex >= divineOrder then
		local flash = Instance.new("Frame")
		flash.Size = UDim2.fromScale(1, 1)
		flash.BackgroundColor3 = Color3.new(1, 1, 1)
		flash.BorderSizePixel = 0
		flash.Parent = sg
		
		TweenService:Create(flash, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
		task.spawn(function()
			task.wait(0.5)
			flash:Destroy()
		end)
	end
	
	-- Fade In
	TweenService:Create(cardFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.fromScale(0.35, 0.55),
		GroupTransparency = 0
	}):Play()
	
	-- Wait and Fade Out
	task.spawn(function()
		task.wait(2.2)
		local fadeTween = TweenService:Create(cardFrame, TweenInfo.new(0.3), {GroupTransparency = 1})
		fadeTween.Completed:Connect(function()
			revealFrame:Destroy()
		end)
		fadeTween:Play()
	end)
end

function RNGVisuals.Start()
	-- Event connects
	local rollVisualsEvent = Network.GetEvent("PlayRollVisuals")
	rollVisualsEvent.OnClientEvent:Connect(function(cardName, wasCritical)
		RNGVisuals.PlayRollVisuals(cardName, wasCritical)
	end)
end

return RNGVisuals
