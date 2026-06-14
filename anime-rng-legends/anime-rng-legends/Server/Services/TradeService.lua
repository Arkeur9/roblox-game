local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Network = require(ReplicatedStorage.Shared.Utils.Network)
local DataManager = require(script.Parent.DataManager)

local TradeService = {}
local activeTrades = {} -- Map of session ID to { Player1, Player2, Offer1 = {}, Offer2 = {}, Accepted1 = bool, Accepted2 = bool }
local playerSessions = {} -- Map of Player to active Session ID

-- Helper to find an active trade session for a player
local function getPlayerSession(player: Player)
	local sId = playerSessions[player]
	if sId then
		return activeTrades[sId], sId
	end
	return nil, nil
end

-- Safely remove items from inventory
local function removeItemsFromPlayer(player: Player, cardsList, potionsList, gold, gems)
	local profile = DataManager.GetProfile(player)
	if not profile then return false end
	
	-- Remove gold and gems
	profile.Gold = profile.Gold - gold
	profile.Gems = profile.Gems - gems
	
	-- Remove potions
	profile.InventoryPotions = profile.InventoryPotions or {}
	for potName, count in pairs(potionsList) do
		profile.InventoryPotions[potName] = profile.InventoryPotions[potName] - count
	end
	
	-- Remove cards
	for _, id in ipairs(cardsList) do
		for i, c in ipairs(profile.Inventory) do
			if c.Id == id then
				table.remove(profile.Inventory, i)
				break
			end
		end
		
		-- Remove from equipped if they were somehow equipped
		local eqIdx = table.find(profile.EquippedCards, id)
		if eqIdx then
			table.remove(profile.EquippedCards, eqIdx)
		end
	end
	
	return true
end

-- Safely add items to player
local function addItemsToPlayer(player: Player, cardsList, potionsList, gold, gems)
	local profile = DataManager.GetProfile(player)
	if not profile then return end
	
	profile.Gold = profile.Gold + gold
	profile.Gems = profile.Gems + gems
	
	profile.InventoryPotions = profile.InventoryPotions or {}
	for potName, count in pairs(potionsList) do
		profile.InventoryPotions[potName] = (profile.InventoryPotions[potName] or 0) + count
	end
	
	-- Cards list elements are complete tables of cards, we generate fresh IDs or retain parameters
	for _, cardInfo in ipairs(cardsList) do
		table.insert(profile.Inventory, {
			Id = cardInfo.Id,
			Name = cardInfo.Name,
			Level = cardInfo.Level,
			DateObtained = os.time(),
			Serial = cardInfo.Serial
		})
	end
end

-- Verify that the offer contents are valid and owned by the player
local function validateOffer(player: Player, offer)
	local profile = DataManager.GetProfile(player)
	if not profile then return false end
	
	-- 1. Currencies check
	if (offer.Gold or 0) < 0 or (offer.Gems or 0) < 0 then return false end
	if profile.Gold < (offer.Gold or 0) then return false end
	if profile.Gems < (offer.Gems or 0) then return false end
	
	-- 2. Potions check
	profile.InventoryPotions = profile.InventoryPotions or {}
	for potName, count in pairs(offer.Potions or {}) do
		if count < 0 then return false end
		local pOwned = profile.InventoryPotions[potName] or 0
		if pOwned < count then return false end
	end
	
	-- 3. Cards check
	for _, cardId in ipairs(offer.Cards or {}) do
		local owned = false
		for _, c in ipairs(profile.Inventory) do
			if c.Id == cardId then
				owned = true
				break
			end
		end
		if not owned then return false end
		
		-- Equipped cards cannot be traded!
		if table.find(profile.EquippedCards, cardId) then
			return false
		end
	end
	
	return true
end

-- Initialize Trade Request
function TradeService.SendTradeRequest(sender: Player, receiverName: string)
	local receiver = Players:FindFirstChild(receiverName)
	if not receiver or receiver == sender then
		return false, "Joueur introuvable."
	end
	
	-- Check if either is already in a trade
	if playerSessions[sender] or playerSessions[receiver] then
		return false, "Un des joueurs est déjà en train de faire un échange."
	end
	
	-- Send invite trigger to receiver
	Network.FireClient(receiver, "ReceiveTradeInvite", sender.Name)
	return true
end

-- Accept invite, start session
function TradeService.AcceptInvite(player: Player, senderName: string)
	local sender = Players:FindFirstChild(senderName)
	if not sender then return false, "L'expéditeur est parti." end
	
	if playerSessions[player] or playerSessions[sender] then
		return false, "Un des joueurs est occupé."
	end
	
	-- Start session
	local HttpService = game:GetService("HttpService")
	local sId = HttpService:GenerateGUID(false)
	
	activeTrades[sId] = {
		Player1 = sender,
		Player2 = player,
		Offer1 = { Cards = {}, Potions = {}, Gold = 0, Gems = 0 },
		Offer2 = { Cards = {}, Potions = {}, Gold = 0, Gems = 0 },
		Accepted1 = false,
		Accepted2 = false,
		DoubleConfirmed1 = false,
		DoubleConfirmed2 = false
	}
	
	playerSessions[sender] = sId
	playerSessions[player] = sId
	
	-- Notify both clients
	Network.FireClient(sender, "StartTradeSession", sId, player.Name)
	Network.FireClient(player, "StartTradeSession", sId, sender.Name)
	
	return true
end

-- Cancel / Decline active trade session
function TradeService.CancelTrade(player: Player)
	local session, sId = getPlayerSession(player)
	if not session then return end
	
	local p1 = session.Player1
	local p2 = session.Player2
	
	if p1 and p1.Parent then Network.FireClient(p1, "TradeCancelled") playerSessions[p1] = nil end
	if p2 and p2.Parent then Network.FireClient(p2, "TradeCancelled") playerSessions[p2] = nil end
	
	activeTrades[sId] = nil
end

-- Update player trade offer details
function TradeService.UpdateOffer(player: Player, offerDetails)
	local session, sId = getPlayerSession(player)
	if not session then return end
	
	-- Verify ownership
	if not validateOffer(player, offerDetails) then
		return false, "Offre invalide."
	end
	
	-- Reset accept state upon changes to prevent bait-and-switch
	session.Accepted1 = false
	session.Accepted2 = false
	session.DoubleConfirmed1 = false
	session.DoubleConfirmed2 = false
	
	local otherPlayer = nil
	if session.Player1 == player then
		session.Offer1 = offerDetails
		otherPlayer = session.Player2
	else
		session.Offer2 = offerDetails
		otherPlayer = session.Player1
	end
	
	-- Sync update to other player
	if otherPlayer and otherPlayer.Parent then
		Network.FireClient(otherPlayer, "SyncPartnerOffer", offerDetails)
	end
	
	return true
end

-- Accept phase 1
function TradeService.AcceptTrade(player: Player)
	local session, sId = getPlayerSession(player)
	if not session then return end
	
	local isPlayer1 = session.Player1 == player
	if isPlayer1 then
		session.Accepted1 = true
	else
		session.Accepted2 = true
	end
	
	local otherPlayer = isPlayer1 and session.Player2 or session.Player1
	Network.FireClient(otherPlayer, "PartnerAcceptedState", true)
	
	-- If both accepted, start double-confirmation timer
	if session.Accepted1 and session.Accepted2 then
		Network.FireClient(session.Player1, "EnterDoubleConfirm")
		Network.FireClient(session.Player2, "EnterDoubleConfirm")
	end
end

-- Accept phase 2 (Final Double Confirm)
function TradeService.ConfirmTradeFinal(player: Player)
	local session, sId = getPlayerSession(player)
	if not session then return end
	if not (session.Accepted1 and session.Accepted2) then return end
	
	local isPlayer1 = session.Player1 == player
	if isPlayer1 then
		session.DoubleConfirmed1 = true
	else
		session.DoubleConfirmed2 = true
	end
	
	-- Process completion if both double-confirmed
	if session.DoubleConfirmed1 and session.DoubleConfirmed2 then
		local p1 = session.Player1
		local p2 = session.Player2
		
		-- Final validation checks
		local p1Valid = validateOffer(p1, session.Offer1)
		local p2Valid = validateOffer(p2, session.Offer2)
		
		if not p1Valid or not p2Valid then
			TradeService.CancelTrade(p1)
			return
		end
		
		-- Fetch detailed card structures from profiles to add to inventory
		local profile1 = DataManager.GetProfile(p1)
		local profile2 = DataManager.GetProfile(p2)
		
		local p1CardsToTransfer = {}
		for _, cardId in ipairs(session.Offer1.Cards) do
			for _, c in ipairs(profile1.Inventory) do
				if c.Id == cardId then
					table.insert(p1CardsToTransfer, c)
					break
				end
			end
		end
		
		local p2CardsToTransfer = {}
		for _, cardId in ipairs(session.Offer2.Cards) do
			for _, c in ipairs(profile2.Inventory) do
				if c.Id == cardId then
					table.insert(p2CardsToTransfer, c)
					break
				end
			end
		end
		
		-- Perform transfer transactions safely
		removeItemsFromPlayer(p1, session.Offer1.Cards, session.Offer1.Potions, session.Offer1.Gold, session.Offer1.Gems)
		removeItemsFromPlayer(p2, session.Offer2.Cards, session.Offer2.Potions, session.Offer2.Gold, session.Offer2.Gems)
		
		addItemsToPlayer(p1, p2CardsToTransfer, session.Offer2.Potions, session.Offer2.Gold, session.Offer2.Gems)
		addItemsToPlayer(p2, p1CardsToTransfer, session.Offer1.Potions, session.Offer1.Gold, session.Offer1.Gems)
		
		-- Clear sessions
		playerSessions[p1] = nil
		playerSessions[p2] = nil
		activeTrades[sId] = nil
		
		-- Notify success
		Network.FireClient(p1, "TradeCompleted")
		Network.FireClient(p2, "TradeCompleted")
	end
end

function TradeService.Start()
	-- Connect remote triggers
	local sendRequestFunc = Network.GetFunction("SendTradeRequest")
	sendRequestFunc.OnServerInvoke = function(player, receiverName)
		return TradeService.SendTradeRequest(player, receiverName)
	end
	
	local acceptInviteFunc = Network.GetFunction("AcceptTradeInvite")
	acceptInviteFunc.OnServerInvoke = function(player, senderName)
		return TradeService.AcceptInvite(player, senderName)
	end
	
	local updateOfferEvent = Network.GetEvent("UpdateTradeOffer")
	updateOfferEvent.OnServerEvent:Connect(function(player, offerDetails)
		TradeService.UpdateOffer(player, offerDetails)
	end)
	
	local acceptTradeEvent = Network.GetEvent("AcceptTradeOffer")
	acceptTradeEvent.OnServerEvent:Connect(function(player)
		TradeService.AcceptTrade(player)
	end)
	
	local confirmFinalEvent = Network.GetEvent("ConfirmTradeFinal")
	confirmFinalEvent.OnServerEvent:Connect(function(player)
		TradeService.ConfirmTradeFinal(player)
	end)
	
	local cancelTradeEvent = Network.GetEvent("CancelTrade")
	cancelTradeEvent.OnServerEvent:Connect(function(player)
		TradeService.CancelTrade(player)
	end)
	
	-- Remove session if player leaves
	Players.PlayerRemoving:Connect(function(player)
		if playerSessions[player] then
			TradeService.CancelTrade(player)
		end
	end)
end

return TradeService
