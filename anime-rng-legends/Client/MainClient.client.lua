-- MainClient.client.lua
-- Entry point for client controllers initialization.

print("Initializing Anime RNG Legends Client Framework...")

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ControllersFolder = script.Parent.Controllers

-- Load Controllers
local UIController = require(ControllersFolder.UIController)
local RNGVisuals = require(ControllersFolder.RNGVisuals)
local CombatVisuals = require(ControllersFolder.CombatVisuals)
local TradeController = require(ControllersFolder.TradeController)
local Network = require(ReplicatedStorage.Shared.Utils.Network)

local localPlayer = Players.LocalPlayer

-- ─── Toast Notification System ─────────────────────────────────────────────
local function showToast(message: string, isError: boolean)
	local sg = localPlayer:WaitForChild("PlayerGui"):FindFirstChild("AnimeRNGLegendsGUI")
	if not sg then return end

	local toast = Instance.new("Frame")
	toast.Name = "ToastNotif"
	toast.Size = UDim2.fromOffset(340, 50)
	toast.Position = UDim2.new(0.5, -170, 0, -60)
	toast.BackgroundColor3 = isError and Color3.fromRGB(200, 40, 40) or Color3.fromRGB(30, 180, 90)
	toast.BorderSizePixel = 0
	toast.Parent = sg

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = toast

	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 1.5
	stroke.Color = isError and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(100, 255, 150)
	stroke.Parent = toast

	local icon = Instance.new("TextLabel")
	icon.Size = UDim2.fromOffset(40, 50)
	icon.BackgroundTransparency = 1
	icon.Text = isError and "⚠" or "✓"
	icon.Font = Enum.Font.GothamBold
	icon.TextSize = 20
	icon.TextColor3 = Color3.new(1, 1, 1)
	icon.Parent = toast

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -45, 1, 0)
	lbl.Position = UDim2.fromOffset(40, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = message
	lbl.Font = Enum.Font.Outfit
	lbl.TextSize = 14
	lbl.TextColor3 = Color3.new(1, 1, 1)
	lbl.TextWrapped = true
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = toast

	-- Slide in from top
	TweenService:Create(toast, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.new(0.5, -170, 0, 15)
	}):Play()

	-- Slide out after 2.5s
	task.spawn(function()
		task.wait(2.5)
		local out = TweenService:Create(toast, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Position = UDim2.new(0.5, -170, 0, -60)
		})
		out.Completed:Connect(function() toast:Destroy() end)
		out:Play()
	end)
end

-- Server Announcement Banner (for rare card pulls)
local function showAnnouncement(playerName: string, cardName: string, rarity: string)
	local sg = localPlayer:WaitForChild("PlayerGui"):FindFirstChild("AnimeRNGLegendsGUI")
	if not sg then return end

	local banner = Instance.new("Frame")
	banner.Size = UDim2.new(1, 0, 0, 60)
	banner.Position = UDim2.new(0, 0, 0, -65)
	banner.BackgroundColor3 = Color3.fromRGB(15, 10, 25)
	banner.BorderSizePixel = 0
	banner.Parent = sg

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(255, 200, 50)
	stroke.Thickness = 2
	stroke.Parent = banner

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.fromScale(1, 1)
	lbl.BackgroundTransparency = 1
	lbl.RichText = true
	lbl.Text = string.format('🎉 <b>%s</b> vient d\'obtenir <b>%s</b> [<font color="#FFD700">%s</font>]!', playerName, cardName, rarity)
	lbl.Font = Enum.Font.Outfit
	lbl.TextSize = 16
	lbl.TextColor3 = Color3.new(1, 1, 1)
	lbl.Parent = banner

	TweenService:Create(banner, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.new(0, 0, 0, 0)
	}):Play()

	task.spawn(function()
		task.wait(4)
		local out = TweenService:Create(banner, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Position = UDim2.new(0, 0, 0, -65)
		})
		out.Completed:Connect(function() banner:Destroy() end)
		out:Play()
	end)
end

-- ─── Start Controllers ──────────────────────────────────────────────────────
local function startController(name, module)
	local success, err = pcall(function()
		if module.Start then
			module.Start()
		end
	end)

	if success then
		print("Client Controller Started: " .. name)
	else
		warn("Failed to start client controller: " .. name .. " - Error: " .. tostring(err))
	end
end

startController("UIController", UIController)
startController("RNGVisuals", RNGVisuals)
startController("CombatVisuals", CombatVisuals)
startController("TradeController", TradeController)

-- ─── Global Client Event Listeners ─────────────────────────────────────────
-- (These are server→client events that no specific controller handles)

-- Success / Error toasts
Network.GetEvent("NotifySuccess").OnClientEvent:Connect(function(msg)
	showToast(msg, false)
end)

Network.GetEvent("NotifyError").OnClientEvent:Connect(function(msg)
	showToast(msg, true)
end)

-- Server-wide rare pull announcements
Network.GetEvent("BroadcastAnnouncement").OnClientEvent:Connect(function(pName, cardName, rarity)
	showAnnouncement(pName, cardName, rarity)
end)

-- Boss rewards popup
Network.GetEvent("NotifyBossRewards").OnClientEvent:Connect(function(bossName, gold, gems, extra)
	local msg = string.format("Boss %s vaincu! +%d Or, +%d Gemmes%s", bossName, gold, gems, extra or "")
	showToast(msg, false)
end)

-- Active potions sync (timer display, optional)
Network.GetEvent("SyncActivePotions").OnClientEvent:Connect(function(_activePotions)
	-- Future: display active potion timers on HUD
	-- For now, the SyncData every 2s keeps things up to date
end)

print("Anime RNG Legends Client Framework Fully Loaded.")

