local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Network = require(ReplicatedStorage.Shared.Utils.Network)
local FormatNumber = require(ReplicatedStorage.Shared.Utils.FormatNumber)

local TradeController = {}
local localPlayer = Players.LocalPlayer
local activeTradeUI = nil
local activeSessionId = nil

-- Create invite prompt overlay
function TradeController.ShowInvitePrompt(senderName: string)
	local sg = localPlayer:WaitForChild("PlayerGui"):FindFirstChild("AnimeRNGLegendsGUI")
	if not sg then return end
	
	local prompt = Instance.new("Frame")
	prompt.Size = UDim2.fromScale(0.3, 0.15)
	prompt.Position = UDim2.fromScale(0.5, 0.2)
	prompt.AnchorPoint = Vector2.new(0.5, 0.5)
	prompt.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
	prompt.BorderSizePixel = 0
	prompt.Parent = sg
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = prompt
	
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(120, 80, 240)
	stroke.Thickness = 2
	stroke.Parent = prompt
	
	local msg = Instance.new("TextLabel")
	msg.Size = UDim2.fromScale(0.9, 0.4)
	msg.Position = UDim2.fromScale(0.05, 0.1)
	msg.BackgroundTransparency = 1
	msg.Text = senderName .. " souhaite faire un échange!"
	msg.Font = Enum.Font.Outfit
	msg.TextSize = 14
	msg.TextColor3 = Color3.new(1, 1, 1)
	msg.Parent = prompt
	
	local function createBtn(text, color, pos, callback)
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.fromScale(0.4, 0.35)
		btn.Position = pos
		btn.BackgroundColor3 = color
		btn.Text = text
		btn.Font = Enum.Font.Outfit
		btn.TextSize = 12
		btn.TextColor3 = Color3.new(1, 1, 1)
		btn.Parent = prompt
		
		local bCor = Instance.new("UICorner")
		bCor.CornerRadius = UDim.new(0, 6)
		bCor.Parent = btn
		
		btn.MouseButton1Click:Connect(callback)
	end
	
	createBtn("Refuser", Color3.fromRGB(240, 60, 60), UDim2.fromScale(0.08, 0.55), function()
		prompt:Destroy()
	end)
	
	createBtn("Accepter", Color3.fromRGB(60, 180, 60), UDim2.fromScale(0.52, 0.55), function()
		Network.InvokeServer("AcceptTradeInvite", senderName)
		prompt:Destroy()
	end)
end

-- Create actual trade screen
function TradeController.OpenTradeUI(partnerName: string)
	local sg = localPlayer:WaitForChild("PlayerGui"):FindFirstChild("AnimeRNGLegendsGUI")
	if not sg then return end
	
	-- Close other panels
	local UIController = require(script.Parent.UIController)
	if UIController.TogglePanel and UIController.activeTab then
		UIController.TogglePanel(UIController.activeTab)
	end
	
	activeTradeUI = Instance.new("Frame")
	activeTradeUI.Name = "ActiveTradePanel"
	activeTradeUI.Size = UDim2.fromScale(0.65, 0.7)
	activeTradeUI.Position = UDim2.fromScale(0.5, 0.45)
	activeTradeUI.AnchorPoint = Vector2.new(0.5, 0.5)
	activeTradeUI.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
	activeTradeUI.BorderSizePixel = 0
	activeTradeUI.Parent = sg
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = activeTradeUI
	
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(120, 80, 240)
	stroke.Thickness = 2
	stroke.Parent = activeTradeUI
	
	-- Title details
	local title = Instance.new("TextLabel")
	title.Size = UDim2.fromScale(1, 0.1)
	title.BackgroundTransparency = 1
	title.Text = "ECHANGE AVEC: " .. partnerName:upper()
	title.Font = Enum.Font.Outfit
	title.TextSize = 20
	title.TextColor3 = Color3.new(1, 1, 1)
	title.Parent = activeTradeUI
	
	-- Left Side: Your Offer
	local leftFrame = Instance.new("Frame")
	leftFrame.Name = "MyOffer"
	leftFrame.Size = UDim2.fromScale(0.46, 0.75)
	leftFrame.Position = UDim2.fromScale(0.03, 0.12)
	leftFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
	leftFrame.BorderSizePixel = 0
	leftFrame.Parent = activeTradeUI
	
	-- Right Side: Partner's Offer
	local rightFrame = Instance.new("Frame")
	rightFrame.Name = "PartnerOffer"
	rightFrame.Size = UDim2.fromScale(0.46, 0.75)
	rightFrame.Position = UDim2.fromScale(0.51, 0.12)
	rightFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
	rightFrame.BorderSizePixel = 0
	rightFrame.Parent = activeTradeUI
	
	-- Subtitles
	local function createSubTitle(text, parent)
		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.fromScale(1, 0.1)
		lbl.BackgroundTransparency = 1
		lbl.Text = text
		lbl.Font = Enum.Font.Outfit
		lbl.TextSize = 14
		lbl.TextColor3 = Color3.fromRGB(200, 200, 210)
		lbl.Parent = parent
	end
	createSubTitle("Ton Offre", leftFrame)
	createSubTitle(partnerName .. " Offre", rightFrame)
	
	-- Add accept button
	local acceptBtn = Instance.new("TextButton")
	acceptBtn.Name = "AcceptTradeBtn"
	acceptBtn.Size = UDim2.fromScale(0.4, 0.08)
	acceptBtn.Position = UDim2.fromScale(0.3, 0.9)
	acceptBtn.BackgroundColor3 = Color3.fromRGB(120, 80, 240)
	acceptBtn.Text = "ACCEPTER L'ECHANGE"
	acceptBtn.Font = Enum.Font.Outfit
	acceptBtn.TextSize = 14
	acceptBtn.TextColor3 = Color3.new(1, 1, 1)
	acceptBtn.Parent = activeTradeUI
	
	local btnCor = Instance.new("UICorner")
	btnCor.CornerRadius = UDim.new(0, 8)
	btnCor.Parent = acceptBtn
	
	acceptBtn.MouseButton1Click:Connect(function()
		Network.FireServer("AcceptTradeOffer")
		acceptBtn.Text = "EN ATTENTE..."
		acceptBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
	end)
end

function TradeController.Start()
	-- Connect Network RemoteEvents
	local inviteEvent = Network.GetEvent("ReceiveTradeInvite")
	inviteEvent.OnClientEvent:Connect(function(senderName)
		TradeController.ShowInvitePrompt(senderName)
	end)
	
	local startEvent = Network.GetEvent("StartTradeSession")
	startEvent.OnClientEvent:Connect(function(sId, partnerName)
		activeSessionId = sId
		TradeController.OpenTradeUI(partnerName)
	end)
	
	local syncPartnerEvent = Network.GetEvent("SyncPartnerOffer")
	syncPartnerEvent.OnClientEvent:Connect(function(partnerOffer)
		if not activeTradeUI then return end
		-- Update Right Side (partnerOffer details)
		local pLabel = activeTradeUI.PartnerOffer:FindFirstChild("ContentSummary")
		if not pLabel then
			pLabel = Instance.new("TextLabel")
			pLabel.Name = "ContentSummary"
			pLabel.Size = UDim2.fromScale(0.9, 0.8)
			pLabel.Position = UDim2.fromScale(0.05, 0.15)
			pLabel.BackgroundTransparency = 1
			pLabel.Font = Enum.Font.Outfit
			pLabel.TextSize = 13
			pLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
			pLabel.TextWrapped = true
			pLabel.Parent = activeTradeUI.PartnerOffer
		end
		
		local summaryText = string.format("Or: %d\nGemmes: %d\nCartes: %d", partnerOffer.Gold, partnerOffer.Gems, #partnerOffer.Cards)
		pLabel.Text = summaryText
	end)
	
	local doubleConfirmEvent = Network.GetEvent("EnterDoubleConfirm")
	doubleConfirmEvent.OnClientEvent:Connect(function()
		if not activeTradeUI then return end
		local btn = activeTradeUI:FindFirstChild("AcceptTradeBtn")
		if btn then
			btn.Text = "CONFIRMATION FINAL (3s)"
			btn.BackgroundColor3 = Color3.fromRGB(240, 120, 40)
			
			task.spawn(function()
				task.wait(3)
				btn.Text = "CLIQUEZ POUR VALIDER"
				btn.BackgroundColor3 = Color3.fromRGB(60, 180, 60)
				btn.MouseButton1Click:Connect(function()
					Network.FireServer("ConfirmTradeFinal")
					btn.Text = "ACCEPTE !"
					btn.Active = false
				end)
			end)
		end
	end)
	
	local cancelEvent = Network.GetEvent("TradeCancelled")
	cancelEvent.OnClientEvent:Connect(function()
		if activeTradeUI then
			activeTradeUI:Destroy()
			activeTradeUI = nil
		end
		activeSessionId = nil
	end)
	
	local completedEvent = Network.GetEvent("TradeCompleted")
	completedEvent.OnClientEvent:Connect(function()
		if activeTradeUI then
			activeTradeUI:Destroy()
			activeTradeUI = nil
		end
		activeSessionId = nil
		-- Show completion success dialog
		warn("L'échange s'est terminé avec succès!")
	end)
end

return TradeController
