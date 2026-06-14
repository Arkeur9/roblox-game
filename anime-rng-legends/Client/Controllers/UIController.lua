local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FormatNumber = require(ReplicatedStorage.Shared.Utils.FormatNumber)
local RarityConfig = require(ReplicatedStorage.Shared.Configs.RarityConfig)
local CardsConfig = require(ReplicatedStorage.Shared.Configs.CardsConfig)
local UpgradesConfig = require(ReplicatedStorage.Shared.Configs.UpgradesConfig)
local WorldsConfig = require(ReplicatedStorage.Shared.Configs.WorldsConfig)
local QuestsConfig = require(ReplicatedStorage.Shared.Configs.QuestsConfig)
local CraftingConfig = require(ReplicatedStorage.Shared.Configs.CraftingConfig)
local PotionsConfig = require(ReplicatedStorage.Shared.Configs.PotionsConfig)

local Network = require(ReplicatedStorage.Shared.Utils.Network)

local UIController = {}
local localPlayer = Players.LocalPlayer
local localData = nil
local activePanels = {}
local activeTab = nil
local inventorySubTab = "Cards"

-- UI Colors
local BG_COLOR = Color3.fromRGB(20, 20, 25)
local PANEL_COLOR = Color3.fromRGB(30, 30, 38)
local ACCENT_COLOR = Color3.fromRGB(120, 80, 240)
local TEXT_COLOR = Color3.fromRGB(240, 240, 250)
local MUTED_TEXT = Color3.fromRGB(150, 150, 160)

-- Core GUI instances
local screenGui = nil
local hudFrame = nil
local contentContainer = nil

-- Helper: Create UI transitions
local function applyPopTween(element, open)
	element.Visible = true
	if open then
		element.Size = UDim2.fromScale(0.4, 0.4)
		element.GroupTransparency = 1
		TweenService:Create(element, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = UDim2.fromScale(0.6, 0.7),
			GroupTransparency = 0
		}):Play()
	else
		local tween = TweenService:Create(element, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Size = UDim2.fromScale(0.4, 0.4),
			GroupTransparency = 1
		})
		tween.Completed:Connect(function()
			if element.GroupTransparency == 1 then
				element.Visible = false
			end
		end)
		tween:Play()
	end
end

-- Helper: Create a styled rounded button
local function createStyledButton(name, text, size, pos, parent)
	local btn = Instance.new("TextButton")
	btn.Name = name
	btn.Size = size
	btn.Position = pos
	btn.BackgroundColor3 = BG_COLOR
	btn.BorderSizePixel = 0
	btn.Text = text
	btn.Font = Enum.Font.Outfit
	btn.TextSize = 16
	btn.TextColor3 = TEXT_COLOR
	btn.Parent = parent
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = btn
	
	local stroke = Instance.new("UIStroke")
	stroke.Color = ACCENT_COLOR
	stroke.Thickness = 1.5
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = btn
	
	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = ACCENT_COLOR}):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = BG_COLOR}):Play()
	end)
	
	return btn
end

-- Helper: Create a standard panel frame
local function createMenuPanel(name)
	local frame = Instance.new("CanvasGroup")
	frame.Name = name .. "Panel"
	frame.Size = UDim2.fromScale(0.6, 0.7)
	frame.Position = UDim2.fromScale(0.5, 0.45)
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.BackgroundColor3 = PANEL_COLOR
	frame.BorderSizePixel = 0
	frame.Visible = false
	frame.Parent = contentContainer
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = frame
	
	local stroke = Instance.new("UIStroke")
	stroke.Color = ACCENT_COLOR
	stroke.Thickness = 2
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = frame
	
	-- Title Label
	local title = Instance.new("TextLabel")
	title.Size = UDim2.fromScale(1, 0.1)
	title.BackgroundTransparency = 1
	title.Text = name:upper()
	title.Font = Enum.Font.Outfit
	title.TextSize = 24
	title.TextColor3 = TEXT_COLOR
	title.Parent = frame
	
	-- Close Button
	local closeBtn = createStyledButton("CloseButton", "X", UDim2.fromOffset(30, 30), UDim2.new(0.95, -15, 0.05, 0), frame)
	closeBtn.AnchorPoint = Vector2.new(1, 0)
	closeBtn.MouseButton1Click:Connect(function()
		applyPopTween(frame, false)
		if activeTab == name then
			activeTab = nil
		end
	end)
	
	-- Content Scroller
	local scroller = Instance.new("ScrollingFrame")
	scroller.Name = "Scroller"
	scroller.Size = UDim2.fromScale(0.95, 0.8)
	scroller.Position = UDim2.fromScale(0.025, 0.15)
	scroller.BackgroundTransparency = 1
	scroller.ScrollBarThickness = 6
	scroller.ScrollBarImageColor3 = ACCENT_COLOR
	scroller.Parent = frame
	
	local grid = Instance.new("UIGridLayout")
	grid.CellSize = UDim2.fromOffset(110, 140)
	grid.CellPadding = UDim2.fromOffset(10, 10)
	grid.SortOrder = Enum.SortOrder.LayoutOrder
	grid.Parent = scroller
	
	activePanels[name] = frame
	return frame
end

-- Refresh UI values based on localData
function UIController.UpdateHUD()
	if not localData or not hudFrame then return end
	
	hudFrame.StatsBar.GoldLabel.Text = "Or: " .. FormatNumber.FormatCompact(localData.Gold)
	hudFrame.StatsBar.GemsLabel.Text = "Gemmes: " .. FormatNumber.FormatCompact(localData.Gems)
	hudFrame.StatsBar.TokensLabel.Text = "Frags: " .. FormatNumber.FormatCompact(localData.Tokens)
	hudFrame.StatsBar.RollsLabel.Text = "Rolls: " .. FormatNumber.FormatWithCommas(localData.Rolls)
	
	-- Luck Multiplier calculation
	local totalLuck = 1.0
	local luckUpgradeLvl = localData.Upgrades.Luck
	totalLuck = totalLuck + (luckUpgradeLvl - 1) * 0.02
	
	-- Potion boost addition
	for potName, duration in pairs(localData.ActivePotions or {}) do
		if duration > 0 then
			local pConf = PotionsConfig.Potions[potName]
			if pConf and pConf.BuffType == "Luck" then
				totalLuck = totalLuck * pConf.Value
			end
		end
	end
	
	-- World boost
	local worldConf = WorldsConfig.Worlds[localData.CurrentWorld]
	if worldConf then
		totalLuck = totalLuck * worldConf.LuckMultiplier
	end
	
	hudFrame.StatsBar.LuckLabel.Text = string.format("Chance: %.1fx", totalLuck)
end

-- Initialize Inventory Page
local function refreshInventoryPanel(scroller)
	local panel = scroller.Parent
	
	-- Check or create SubTab header frame
	local subTabHeader = panel:FindFirstChild("SubTabHeader")
	if not subTabHeader then
		subTabHeader = Instance.new("Frame")
		subTabHeader.Name = "SubTabHeader"
		subTabHeader.Size = UDim2.fromScale(0.9, 0.08)
		subTabHeader.Position = UDim2.fromScale(0.05, 0.12)
		subTabHeader.BackgroundTransparency = 1
		subTabHeader.Parent = panel
		
		-- Adjust scroller position to make room for sub-tabs
		scroller.Position = UDim2.fromScale(0.025, 0.22)
		scroller.Size = UDim2.fromScale(0.95, 0.73)
		
		-- Create buttons
		local cardsBtn = createStyledButton("CardsTabBtn", "Cartes", UDim2.fromScale(0.45, 1), UDim2.fromScale(0, 0), subTabHeader)
		local potionsBtn = createStyledButton("PotionsTabBtn", "Potions", UDim2.fromScale(0.45, 1), UDim2.fromScale(0.55, 0), subTabHeader)
		
		cardsBtn.MouseButton1Click:Connect(function()
			inventorySubTab = "Cards"
			refreshInventoryPanel(scroller)
		end)
		
		potionsBtn.MouseButton1Click:Connect(function()
			inventorySubTab = "Potions"
			refreshInventoryPanel(scroller)
		end)
	end
	
	-- Highlight the active sub-tab button
	local cardsBtn = subTabHeader:FindFirstChild("CardsTabBtn")
	local potionsBtn = subTabHeader:FindFirstChild("PotionsTabBtn")
	if cardsBtn and potionsBtn then
		if inventorySubTab == "Cards" then
			cardsBtn.BackgroundColor3 = ACCENT_COLOR
			potionsBtn.BackgroundColor3 = BG_COLOR
		else
			cardsBtn.BackgroundColor3 = BG_COLOR
			potionsBtn.BackgroundColor3 = ACCENT_COLOR
		end
	end

	-- Clean scroller
	for _, child in ipairs(scroller:GetChildren()) do
		if child:IsA("GuiObject") and not child:IsA("UILayout") then
			child:Destroy()
		end
	end
	
	local layout = scroller:FindFirstChildOfClass("UIGridLayout")
	
	if inventorySubTab == "Cards" then
		if layout then
			layout.CellSize = UDim2.fromOffset(130, 170)
		end
		
		for _, item in ipairs(localData.Inventory) do
			local cConf = CardsConfig.Cards[item.Name]
			if not cConf then continue end
			
			local rarityInfo = RarityConfig.Rarities[cConf.Rarity]
			local cardColor = rarityInfo and rarityInfo.Color or TEXT_COLOR
			
			local itemFrame = Instance.new("Frame")
			itemFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
			itemFrame.BorderSizePixel = 0
			itemFrame.Parent = scroller
			
			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(0, 8)
			corner.Parent = itemFrame
			
			-- Border stroke matching rarity
			local stroke = Instance.new("UIStroke")
			stroke.Color = cardColor
			stroke.Thickness = 2
			stroke.Parent = itemFrame
			
			-- Display Name
			local nameLbl = Instance.new("TextLabel")
			nameLbl.Size = UDim2.fromScale(1, 0.25)
			nameLbl.Position = UDim2.fromScale(0, 0.05)
			nameLbl.BackgroundTransparency = 1
			nameLbl.Text = cConf.DisplayName
			nameLbl.Font = Enum.Font.Outfit
			nameLbl.TextSize = 14
			nameLbl.TextColor3 = TEXT_COLOR
			nameLbl.TextWrapped = true
			nameLbl.Parent = itemFrame
			
			-- Rarity Label
			local rarityLbl = Instance.new("TextLabel")
			rarityLbl.Size = UDim2.fromScale(1, 0.15)
			rarityLbl.Position = UDim2.fromScale(0, 0.3)
			rarityLbl.BackgroundTransparency = 1
			rarityLbl.Text = cConf.Rarity
			rarityLbl.Font = Enum.Font.Outfit
			rarityLbl.TextSize = 10
			rarityLbl.TextColor3 = cardColor
			rarityLbl.Parent = itemFrame
			
			-- Stats label
			local statsLbl = Instance.new("TextLabel")
			statsLbl.Size = UDim2.fromScale(1, 0.25)
			statsLbl.Position = UDim2.fromScale(0, 0.45)
			statsLbl.BackgroundTransparency = 1
			statsLbl.Text = string.format("Pwr: %s\nLvl: %d", FormatNumber.FormatCompact(cConf.Power), item.Level)
			statsLbl.Font = Enum.Font.Outfit
			statsLbl.TextSize = 11
			statsLbl.TextColor3 = MUTED_TEXT
			statsLbl.Parent = itemFrame
			
			-- Equip Button
			local isEquipped = table.find(localData.EquippedCards, item.Id) ~= nil
			local eqBtn = createStyledButton("EquipBtn", isEquipped and "Unequip" or "Equip", UDim2.fromScale(0.8, 0.22), UDim2.fromScale(0.1, 0.72), itemFrame)
			eqBtn.TextSize = 12
			if isEquipped then
				eqBtn.BackgroundColor3 = Color3.fromRGB(240, 60, 60)
				eqBtn.UIStroke.Color = Color3.fromRGB(240, 60, 60)
			end
			
			eqBtn.MouseButton1Click:Connect(function()
				Network.FireServer("ToggleEquipCard", item.Id)
			end)
		end
	else
		-- Potions inventory sub-tab
		if layout then
			layout.CellSize = UDim2.fromOffset(200, 110)
		end
		
		local potInventory = localData.InventoryPotions or {}
		for potName, count in pairs(potInventory) do
			if count <= 0 then continue end
			local pConf = PotionsConfig.Potions[potName]
			if not pConf then continue end
			
			local itemFrame = Instance.new("Frame")
			itemFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
			itemFrame.BorderSizePixel = 0
			itemFrame.Parent = scroller
			
			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(0, 8)
			corner.Parent = itemFrame
			
			local stroke = Instance.new("UIStroke")
			stroke.Color = ACCENT_COLOR
			stroke.Thickness = 1.5
			stroke.Parent = itemFrame
			
			-- Potion Name & Qty
			local nameLbl = Instance.new("TextLabel")
			nameLbl.Size = UDim2.fromScale(0.9, 0.3)
			nameLbl.Position = UDim2.fromScale(0.05, 0.05)
			nameLbl.BackgroundTransparency = 1
			nameLbl.Text = string.format("%s (x%d)", pConf.DisplayName, count)
			nameLbl.Font = Enum.Font.Outfit
			nameLbl.TextSize = 14
			nameLbl.TextColor3 = TEXT_COLOR
			nameLbl.Parent = itemFrame
			
			-- Buff Type & Value
			local descLbl = Instance.new("TextLabel")
			descLbl.Size = UDim2.fromScale(0.9, 0.25)
			descLbl.Position = UDim2.fromScale(0.05, 0.35)
			descLbl.BackgroundTransparency = 1
			
			local multText = pConf.BuffType == "RollSpeed" and string.format("-%.0f%% temps", (1 - pConf.Value) * 100) or string.format("+%.0f%% %s", (pConf.Value - 1) * 100, pConf.BuffType)
			descLbl.Text = string.format("Effet: %s (5m)", multText)
			descLbl.Font = Enum.Font.Outfit
			descLbl.TextSize = 11
			descLbl.TextColor3 = MUTED_TEXT
			descLbl.Parent = itemFrame
			
			-- Use Button
			local useBtn = createStyledButton("UseBtn", "Utiliser", UDim2.fromScale(0.8, 0.3), UDim2.fromScale(0.1, 0.65), itemFrame)
			useBtn.TextSize = 12
			useBtn.MouseButton1Click:Connect(function()
				Network.InvokeServer("RequestUsePotion", potName)
			end)
		end
	end
end

-- Initialize Upgrades Page
local function refreshUpgradesPanel(scroller)
	for _, child in ipairs(scroller:GetChildren()) do
		if child:IsA("GuiObject") and not child:IsA("UILayout") then
			child:Destroy()
		end
	end
	
	local layout = scroller:FindFirstChildOfClass("UIGridLayout")
	if layout then
		layout.CellSize = UDim2.fromOffset(200, 110)
	end
	
	local upgradeTypes = {
		{Key = "Luck", Name = "Base Luck (+2% / lvl)", Config = UpgradesConfig.Luck, Currency = "Gold"},
		{Key = "RollSpeed", Name = "Roll Speed (-cooldown)", Config = UpgradesConfig.RollSpeed, Currency = "Gold"},
		{Key = "InventorySize", Name = "Sac à Dos (+3 slots)", Config = UpgradesConfig.InventorySize, Currency = "Gold"},
		{Key = "CriticalLuck", Name = "Chance Critique RNG", Config = UpgradesConfig.CriticalLuck, Currency = "Gems"}
	}
	
	for _, upgrade in ipairs(upgradeTypes) do
		local currentLvl = localData.Upgrades[upgrade.Key]
		local isMax = currentLvl >= upgrade.Config.MaxLevel
		local cost = not isMax and upgrade.Config.GetCost(currentLvl) or 0
		
		local itemFrame = Instance.new("Frame")
		itemFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
		itemFrame.BorderSizePixel = 0
		itemFrame.Parent = scroller
		
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 8)
		corner.Parent = itemFrame
		
		local nameLbl = Instance.new("TextLabel")
		nameLbl.Size = UDim2.fromScale(0.9, 0.3)
		nameLbl.Position = UDim2.fromScale(0.05, 0.05)
		nameLbl.BackgroundTransparency = 1
		nameLbl.Text = upgrade.Name
		nameLbl.Font = Enum.Font.Outfit
		nameLbl.TextSize = 14
		nameLbl.TextColor3 = TEXT_COLOR
		nameLbl.Parent = itemFrame
		
		local lvlLbl = Instance.new("TextLabel")
		lvlLbl.Size = UDim2.fromScale(0.9, 0.25)
		lvlLbl.Position = UDim2.fromScale(0.05, 0.35)
		lvlLbl.BackgroundTransparency = 1
		lvlLbl.Text = "Niveau: " .. currentLvl .. " / " .. upgrade.Config.MaxLevel
		lvlLbl.Font = Enum.Font.Outfit
		lvlLbl.TextSize = 12
		lvlLbl.TextColor3 = MUTED_TEXT
		lvlLbl.Parent = itemFrame
		
		local costText = isMax and "MAX" or (FormatNumber.FormatCompact(cost) .. " " .. upgrade.Currency)
		local buyBtn = createStyledButton("BuyBtn", costText, UDim2.fromScale(0.8, 0.3), UDim2.fromScale(0.1, 0.65), itemFrame)
		buyBtn.TextSize = 12
		if isMax then
			buyBtn.Active = false
			buyBtn.AutoButtonColor = false
		else
			buyBtn.MouseButton1Click:Connect(function()
				Network.FireServer("RequestUpgrade", upgrade.Key)
			end)
		end
	end
end

-- Initialize Crafting/Fusion Page
local function refreshCraftingPanel(scroller)
	for _, child in ipairs(scroller:GetChildren()) do
		if child:IsA("GuiObject") and not child:IsA("UILayout") then
			child:Destroy()
		end
	end
	
	local layout = scroller:FindFirstChildOfClass("UIGridLayout")
	if layout then
		layout.CellSize = UDim2.fromOffset(260, 130)
	end
	
	-- 1. Display Potion Recipes
	for recKey, rInfo in pairs(CraftingConfig.Recipes) do
		local potFrame = Instance.new("Frame")
		potFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
		potFrame.BorderSizePixel = 0
		potFrame.Parent = scroller
		
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 8)
		corner.Parent = potFrame
		
		local title = Instance.new("TextLabel")
		title.Size = UDim2.fromScale(0.9, 0.25)
		title.Position = UDim2.fromScale(0.05, 0.05)
		title.BackgroundTransparency = 1
		title.Text = rInfo.DisplayName
		title.Font = Enum.Font.Outfit
		title.TextSize = 15
		title.TextColor3 = TEXT_COLOR
		title.Parent = potFrame
		
		-- Requirements listing
		local reqList = {}
		if rInfo.Requirements.Gold > 0 then table.insert(reqList, rInfo.Requirements.Gold .. " Or") end
		if rInfo.Requirements.Gems and rInfo.Requirements.Gems > 0 then table.insert(reqList, rInfo.Requirements.Gems .. " Gems") end
		
		if rInfo.Requirements.Cards then
			for _, cardReq in ipairs(rInfo.Requirements.Cards) do
				table.insert(reqList, string.format("%dx %s", cardReq.Amount, cardReq.Rarity))
			end
		end
		if rInfo.Requirements.Potions then
			for potReq, amt in pairs(rInfo.Requirements.Potions) do
				table.insert(reqList, string.format("%dx %s", amt, potReq))
			end
		end
		
		local reqsLbl = Instance.new("TextLabel")
		reqsLbl.Size = UDim2.fromScale(0.9, 0.35)
		reqsLbl.Position = UDim2.fromScale(0.05, 0.3)
		reqsLbl.BackgroundTransparency = 1
		reqsLbl.Text = "Requis: " .. table.concat(reqList, ", ")
		reqsLbl.Font = Enum.Font.Outfit
		reqsLbl.TextSize = 10
		reqsLbl.TextColor3 = MUTED_TEXT
		reqsLbl.TextWrapped = true
		reqsLbl.Parent = potFrame
		
		local craftBtn = createStyledButton("CraftBtn", "Fabriquer", UDim2.fromScale(0.8, 0.25), UDim2.fromScale(0.1, 0.7), potFrame)
		craftBtn.TextSize = 12
		craftBtn.MouseButton1Click:Connect(function()
			local success = Network.InvokeServer("RequestCraft", recKey)
			if not success then
				warn("Echec de fabrication.")
			end
		end)
	end
	
	-- 2. Fusion Options
	for rKey, fRule in pairs(CraftingConfig.Fusions) do
		local fuseFrame = Instance.new("Frame")
		fuseFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
		fuseFrame.BorderSizePixel = 0
		fuseFrame.Parent = scroller
		
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 8)
		corner.Parent = fuseFrame
		
		local title = Instance.new("TextLabel")
		title.Size = UDim2.fromScale(0.9, 0.25)
		title.Position = UDim2.fromScale(0.05, 0.05)
		title.BackgroundTransparency = 1
		title.Text = string.format("Fusion %s ➔ %s", rKey, fRule.TargetRarity)
		title.Font = Enum.Font.Outfit
		title.TextSize = 13
		title.TextColor3 = Color3.fromRGB(150, 200, 255)
		title.Parent = fuseFrame
		
		local costText = string.format("Requis: 5x %s + %d Or", rKey, fRule.GoldCost)
		local reqsLbl = Instance.new("TextLabel")
		reqsLbl.Size = UDim2.fromScale(0.9, 0.35)
		reqsLbl.Position = UDim2.fromScale(0.05, 0.3)
		reqsLbl.BackgroundTransparency = 1
		reqsLbl.Text = costText
		reqsLbl.Font = Enum.Font.Outfit
		reqsLbl.TextSize = 11
		reqsLbl.TextColor3 = MUTED_TEXT
		reqsLbl.Parent = fuseFrame
		
		local fuseBtn = createStyledButton("FuseBtn", "Fusionner", UDim2.fromScale(0.8, 0.25), UDim2.fromScale(0.1, 0.7), fuseFrame)
		fuseBtn.TextSize = 12
		fuseBtn.MouseButton1Click:Connect(function()
			-- Select first 5 non-equipped matching cards
			local matchingIds = {}
			for _, card in ipairs(localData.Inventory) do
				local cConf = CardsConfig.Cards[card.Name]
				if cConf and cConf.Rarity == rKey and not table.find(localData.EquippedCards, card.Id) then
					table.insert(matchingIds, card.Id)
					if #matchingIds >= 5 then
						break
					end
				end
			end
			
			if #matchingIds < 5 then
				warn("Vous n'avez pas 5 cartes non-équipées de cette rareté!")
				return
			end
			
			local success, result = Network.InvokeServer("RequestFusion", matchingIds)
			if not success then
				warn(result)
			end
		end)
	end
end

-- Initialize Worlds Panel
local function refreshWorldsPanel(scroller)
	for _, child in ipairs(scroller:GetChildren()) do
		if child:IsA("GuiObject") and not child:IsA("UILayout") then
			child:Destroy()
		end
	end
	
	local layout = scroller:FindFirstChildOfClass("UIGridLayout")
	if layout then
		layout.CellSize = UDim2.fromOffset(200, 120)
	end
	
	for _, wKey in ipairs(WorldsConfig.Order) do
		local wInfo = WorldsConfig.Worlds[wKey]
		local isUnlocked = localData.WorldsUnlocked[wKey] ~= nil
		
		local itemFrame = Instance.new("Frame")
		itemFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
		itemFrame.BorderSizePixel = 0
		itemFrame.Parent = scroller
		
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 8)
		corner.Parent = itemFrame
		
		local nameLbl = Instance.new("TextLabel")
		nameLbl.Size = UDim2.fromScale(0.9, 0.25)
		nameLbl.Position = UDim2.fromScale(0.05, 0.05)
		nameLbl.BackgroundTransparency = 1
		nameLbl.Text = wInfo.DisplayName
		nameLbl.Font = Enum.Font.Outfit
		nameLbl.TextSize = 15
		nameLbl.TextColor3 = TEXT_COLOR
		nameLbl.Parent = itemFrame
		
		local multLbl = Instance.new("TextLabel")
		multLbl.Size = UDim2.fromScale(0.9, 0.2)
		multLbl.Position = UDim2.fromScale(0.05, 0.3)
		multLbl.BackgroundTransparency = 1
		multLbl.Text = string.format("Bonus Chance: %.1fx", wInfo.LuckMultiplier)
		multLbl.Font = Enum.Font.Outfit
		multLbl.TextSize = 12
		multLbl.TextColor3 = Color3.fromRGB(240, 200, 80)
		multLbl.Parent = itemFrame
		
		if isUnlocked then
			local isCurrent = localData.CurrentWorld == wKey
			local btnText = isCurrent and "MORTEL" or "Téléporter"
			local teleBtn = createStyledButton("TeleBtn", btnText, UDim2.fromScale(0.8, 0.3), UDim2.fromScale(0.1, 0.6), itemFrame)
			teleBtn.TextSize = 12
			if isCurrent then
				teleBtn.BackgroundColor3 = ACCENT_COLOR
				teleBtn.Active = false
			else
				teleBtn.MouseButton1Click:Connect(function()
					Network.InvokeServer("RequestTeleportToWorld", wKey)
				end)
			end
		else
			local costText = "Acheter: " .. FormatNumber.FormatCompact(wInfo.Cost) .. " " .. wInfo.Currency
			local buyBtn = createStyledButton("BuyBtn", costText, UDim2.fromScale(0.8, 0.3), UDim2.fromScale(0.1, 0.6), itemFrame)
			buyBtn.TextSize = 10
			buyBtn.MouseButton1Click:Connect(function()
				Network.InvokeServer("RequestUnlockWorld", wKey)
			end)
		end
	end
end

-- Initialize Quests Panel
local function refreshQuestsPanel(scroller)
	for _, child in ipairs(scroller:GetChildren()) do
		if child:IsA("GuiObject") and not child:IsA("UILayout") then
			child:Destroy()
		end
	end
	
	local layout = scroller:FindFirstChildOfClass("UIGridLayout")
	if layout then
		layout.CellSize = UDim2.fromOffset(260, 90)
	end
	
	local renderQuest = function(category, key, info)
		local currentProgress = localData.QuestsProgress[category] and localData.QuestsProgress[category][key] or 0
		
		local itemFrame = Instance.new("Frame")
		itemFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
		itemFrame.BorderSizePixel = 0
		itemFrame.Parent = scroller
		
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 8)
		corner.Parent = itemFrame
		
		local nameLbl = Instance.new("TextLabel")
		nameLbl.Size = UDim2.fromScale(0.9, 0.3)
		nameLbl.Position = UDim2.fromScale(0.05, 0.05)
		nameLbl.BackgroundTransparency = 1
		nameLbl.Text = string.format("[%s] %s", category:upper(), info.Description)
		nameLbl.Font = Enum.Font.Outfit
		nameLbl.TextSize = 12
		nameLbl.TextColor3 = TEXT_COLOR
		nameLbl.Parent = itemFrame
		
		-- Progress indicator bar
		local progBarBG = Instance.new("Frame")
		progBarBG.Size = UDim2.fromScale(0.9, 0.2)
		progBarBG.Position = UDim2.fromScale(0.05, 0.45)
		progBarBG.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
		progBarBG.BorderSizePixel = 0
		progBarBG.Parent = itemFrame
		
		local barCorner = Instance.new("UICorner")
		barCorner.CornerRadius = UDim.new(0, 4)
		barCorner.Parent = progBarBG
		
		local progressRatio = math.clamp(currentProgress / info.Target, 0, 1)
		
		local progBarFill = Instance.new("Frame")
		progBarFill.Size = UDim2.fromScale(progressRatio, 1)
		progBarFill.BackgroundColor3 = ACCENT_COLOR
		progBarFill.BorderSizePixel = 0
		progBarFill.Parent = progBarBG
		
		local fillCorner = Instance.new("UICorner")
		fillCorner.CornerRadius = UDim.new(0, 4)
		fillCorner.Parent = progBarFill
		
		local progLbl = Instance.new("TextLabel")
		progLbl.Size = UDim2.fromScale(0.9, 0.2)
		progLbl.Position = UDim2.fromScale(0.05, 0.7)
		progLbl.BackgroundTransparency = 1
		progLbl.Text = string.format("%s / %s", FormatNumber.FormatCompact(currentProgress), FormatNumber.FormatCompact(info.Target))
		progLbl.Font = Enum.Font.Outfit
		progLbl.TextSize = 10
		progLbl.TextColor3 = MUTED_TEXT
		progLbl.Parent = itemFrame
	end
	
	for key, info in pairs(QuestsConfig.Daily) do
		renderQuest("Daily", key, info)
	end
	for key, info in pairs(QuestsConfig.Weekly) do
		renderQuest("Weekly", key, info)
	end
end

-- Initialize Codes Panel
local function refreshCodesPanel(scroller)
	for _, child in ipairs(scroller:GetChildren()) do
		if child:IsA("GuiObject") and not child:IsA("UILayout") then
			child:Destroy()
		end
	end
	
	local layout = scroller:FindFirstChildOfClass("UIGridLayout")
	if layout then
		layout.CellSize = UDim2.fromOffset(260, 120)
	end
	
	local container = Instance.new("Frame")
	container.Size = UDim2.fromScale(1, 1)
	container.BackgroundTransparency = 1
	container.Parent = scroller
	
	local textbox = Instance.new("TextBox")
	textbox.Size = UDim2.fromScale(0.8, 0.3)
	textbox.Position = UDim2.fromScale(0.1, 0.1)
	textbox.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
	textbox.BorderSizePixel = 0
	textbox.PlaceholderText = "Saisir Code (ex: RELEASE)"
	textbox.Text = ""
	textbox.Font = Enum.Font.Outfit
	textbox.TextSize = 16
	textbox.TextColor3 = TEXT_COLOR
	textbox.Parent = container
	
	local boxCorner = Instance.new("UICorner")
	boxCorner.CornerRadius = UDim.new(0, 8)
	boxCorner.Parent = textbox
	
	local submitBtn = createStyledButton("SubmitCodeBtn", "Valider", UDim2.fromScale(0.8, 0.3), UDim2.fromScale(0.1, 0.5), container)
	submitBtn.MouseButton1Click:Connect(function()
		local enteredText = textbox.Text
		if #enteredText > 0 then
			local success, msg = Network.InvokeServer("RequestCodeRedeem", enteredText)
			textbox.Text = ""
		end
	end)
end

-- Toggle active menu view
function UIController.TogglePanel(panelName)
	local p = activePanels[panelName]
	if not p then return end
	
	-- Close active
	if activeTab and activeTab ~= panelName then
		applyPopTween(activePanels[activeTab], false)
	end
	
	if activeTab == panelName then
		applyPopTween(p, false)
		activeTab = nil
	else
		activeTab = panelName
		-- Reload Panel Contents
		local scroller = p:FindFirstChild("Scroller")
		if scroller then
			if panelName == "Inventory" then
				refreshInventoryPanel(scroller)
			elseif panelName == "Upgrades" then
				refreshUpgradesPanel(scroller)
			elseif panelName == "Craft" then
				refreshCraftingPanel(scroller)
			elseif panelName == "Worlds" then
				refreshWorldsPanel(scroller)
			elseif panelName == "Quests" then
				refreshQuestsPanel(scroller)
			elseif panelName == "Codes" then
				refreshCodesPanel(scroller)
			end
		end
		applyPopTween(p, true)
	end
end

-- Generate screen layers
function UIController.CreateGUI()
	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "AnimeRNGLegendsGUI"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = localPlayer:WaitForChild("PlayerGui")
	
	-- Bottom HUD Layout
	hudFrame = Instance.new("Frame")
	hudFrame.Name = "HUD"
	hudFrame.Size = UDim2.new(1, 0, 0.2, 0)
	hudFrame.Position = UDim2.new(0, 0, 0.8, 0)
	hudFrame.BackgroundTransparency = 1
	hudFrame.Parent = screenGui
	
	-- Top stats bar
	local statsBar = Instance.new("Frame")
	statsBar.Name = "StatsBar"
	statsBar.Size = UDim2.new(1, 0, 0.25, 0)
	statsBar.Position = UDim2.new(0, 0, -3.8, 0)
	statsBar.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
	statsBar.BackgroundTransparency = 0.2
	statsBar.BorderSizePixel = 0
	statsBar.Parent = hudFrame
	
	-- Create Top Stats Labels
	local function createStatLabel(name, text, xPos)
		local lbl = Instance.new("TextLabel")
		lbl.Name = name
		lbl.Size = UDim2.new(0.18, 0, 0.8, 0)
		lbl.Position = UDim2.new(xPos, 0, 0.1, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text = text
		lbl.Font = Enum.Font.Outfit
		lbl.TextSize = 16
		lbl.TextColor3 = TEXT_COLOR
		lbl.Parent = statsBar
		return lbl
	end
	
	createStatLabel("GoldLabel", "Or: --", 0.02)
	createStatLabel("GemsLabel", "Gemmes: --", 0.22)
	createStatLabel("TokensLabel", "Frags: --", 0.42)
	createStatLabel("RollsLabel", "Rolls: --", 0.62)
	createStatLabel("LuckLabel", "Chance: --", 0.82)
	
	-- Central contents container
	contentContainer = Instance.new("Frame")
	contentContainer.Name = "Content"
	contentContainer.Size = UDim2.fromScale(1, 0.8)
	contentContainer.Position = UDim2.fromScale(0, 0)
	contentContainer.BackgroundTransparency = 1
	contentContainer.Parent = screenGui
	
	-- Create menu structures
	createMenuPanel("Inventory")
	createMenuPanel("Upgrades")
	createMenuPanel("Craft")
	createMenuPanel("Worlds")
	createMenuPanel("Quests")
	createMenuPanel("Codes")
	
	-- Roll Button Frame
	local rollCenter = Instance.new("Frame")
	rollCenter.Size = UDim2.fromScale(0.25, 0.35)
	rollCenter.Position = UDim2.fromScale(0.375, 0.2)
	rollCenter.BackgroundTransparency = 1
	rollCenter.Parent = hudFrame
	
	local rollBtn = createStyledButton("RollBtn", "ROLL", UDim2.fromScale(1, 1), UDim2.fromScale(0, 0), rollCenter)
	rollBtn.TextSize = 22
	rollBtn.BackgroundColor3 = Color3.fromRGB(240, 80, 80)
	rollBtn.UIStroke.Color = Color3.fromRGB(255, 120, 120)
	rollBtn.MouseButton1Click:Connect(function()
		Network.FireServer("RequestRoll")
	end)
	
	-- Tabs buttons container
	local tabsContainer = Instance.new("Frame")
	tabsContainer.Size = UDim2.fromScale(0.9, 0.25)
	tabsContainer.Position = UDim2.fromScale(0.05, 0.65)
	tabsContainer.BackgroundTransparency = 1
	tabsContainer.Parent = hudFrame
	
	local listLayout = Instance.new("UIListLayout")
	listLayout.FillDirection = Enum.FillDirection.Horizontal
	listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	listLayout.Padding = UDim.new(0, 10)
	listLayout.Parent = tabsContainer
	
	-- Generate Tab Triggers
	local tabs = {"Inventory", "Upgrades", "Craft", "Worlds", "Quests", "Codes"}
	for _, tab in ipairs(tabs) do
		local tabBtn = createStyledButton(tab .. "Tab", tab, UDim2.new(0.14, 0, 0.9, 0), UDim2.fromScale(0, 0), tabsContainer)
		tabBtn.MouseButton1Click:Connect(function()
			UIController.TogglePanel(tab)
		end)
	end
end

function UIController.Start()
	UIController.CreateGUI()
	
	-- Fetch initial data sync
	local getProfileFunc = Network.GetFunction("GetProfile")
	local success, data = pcall(function()
		return getProfileFunc:InvokeServer()
	end)
	if success and data then
		localData = data
		UIController.UpdateHUD()
	end
	
	-- Receive live syncs from server
	local syncEvent = Network.GetEvent("SyncData")
	syncEvent.OnClientEvent:Connect(function(newData)
		localData = newData
		UIController.UpdateHUD()
		
		-- Redraw panel if visible
		if activeTab then
			local p = activePanels[activeTab]
			local scroller = p and p:FindFirstChild("Scroller")
			if scroller then
				if activeTab == "Inventory" then
					refreshInventoryPanel(scroller)
				elseif activeTab == "Upgrades" then
					refreshUpgradesPanel(scroller)
				elseif activeTab == "Craft" then
					refreshCraftingPanel(scroller)
				elseif activeTab == "Worlds" then
					refreshWorldsPanel(scroller)
				elseif activeTab == "Quests" then
					refreshQuestsPanel(scroller)
				end
			end
		end
	end)
end

return UIController
