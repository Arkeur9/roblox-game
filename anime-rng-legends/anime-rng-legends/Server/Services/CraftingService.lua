local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local CraftingConfig = require(ReplicatedStorage.Shared.Configs.CraftingConfig)
local CardsConfig = require(ReplicatedStorage.Shared.Configs.CardsConfig)
local RarityConfig = require(ReplicatedStorage.Shared.Configs.RarityConfig)

local Network = require(ReplicatedStorage.Shared.Utils.Network)
local DataManager = require(script.Parent.DataManager)

local CraftingService = {}

-- Helper to find index of item in inventory array
local function findCardIndex(inventory, id)
	for i, c in ipairs(inventory) do
		if c.Id == id then
			return i
		end
	end
	return nil
end

-- Securely perform card fusion
function CraftingService.FuseCards(player: Player, cardIds: {string})
	local profile = DataManager.GetProfile(player)
	if not profile then return false, "No Data loaded" end
	
	-- Verify input length
	if not cardIds or #cardIds < 5 then
		return false, "Vous devez sélectionner au moins 5 cartes."
	end
	
	-- Resolve card info and verify duplicates/existence
	local cardsToUse = {}
	local targetRarity = nil
	
	for _, id in ipairs(cardIds) do
		local idx = findCardIndex(profile.Inventory, id)
		if not idx then
			return false, "Une ou plusieurs cartes sélectionnées n'existent pas."
		end
		
		-- Check if equipped
		if table.find(profile.EquippedCards, id) then
			return false, "Impossible de fusionner une carte équipée."
		end
		
		local cardData = profile.Inventory[idx]
		local conf = CardsConfig.Cards[cardData.Name]
		if not conf then
			return false, "Configuration de carte introuvable."
		end
		
		if not targetRarity then
			targetRarity = conf.Rarity
		elseif conf.Rarity ~= targetRarity then
			return false, "Toutes les cartes doivent avoir la même rareté."
		end
		
		table.insert(cardsToUse, {Index = idx, Name = cardData.Name})
	end
	
	-- Validate fusion path in config
	local fusionRule = CraftingConfig.Fusions[targetRarity]
	if not fusionRule then
		return false, "Cette rareté ne peut pas être fusionnée."
	end
	
	-- Gold / Gems Cost validation
	local goldCost = fusionRule.GoldCost or 0
	local gemsCost = fusionRule.GemsCost or 0
	
	if profile.Gold < goldCost then
		return false, "Or insuffisant."
	end
	if profile.Gems < gemsCost then
		return false, "Gemmes insuffisantes."
	end
	
	-- Sort indices in descending order to prevent shifts when removing
	table.sort(cardIds, function(a, b)
		local idxA = findCardIndex(profile.Inventory, a)
		local idxB = findCardIndex(profile.Inventory, b)
		return (idxA or 0) > (idxB or 0)
	end)
	
	-- Deduct cost
	profile.Gold = profile.Gold - goldCost
	profile.Gems = profile.Gems - gemsCost
	
	-- Delete fused cards
	for _, id in ipairs(cardIds) do
		local idx = findCardIndex(profile.Inventory, id)
		if idx then
			table.remove(profile.Inventory, idx)
		end
	end
	
	-- Select a random card of target tier
	local candidates = {}
	local nextTier = fusionRule.TargetRarity
	
	for cardKey, cInfo in pairs(CardsConfig.Cards) do
		if cInfo.Rarity == nextTier and not cInfo.IsEvolved then
			table.insert(candidates, cardKey)
		end
	end
	
	local chosenCard = candidates[math.random(1, #candidates)]
	if not chosenCard then
		chosenCard = "Tanjero" -- Fallback
	end
	
	-- Create and save new card
	local uniqueId = HttpService:GenerateGUID(false)
	local newCard = {
		Id = uniqueId,
		Name = chosenCard,
		Level = 1,
		DateObtained = os.time(),
		Serial = profile.Rolls + 1
	}
	table.insert(profile.Inventory, newCard)
	
	-- Trigger client feedback
	Network.FireClient(player, "PlayFusionVisuals", chosenCard)
	
	return true, newCard
end

-- Securely craft a potion
function CraftingService.CraftPotion(player: Player, recipeName: string)
	local profile = DataManager.GetProfile(player)
	if not profile then return false, "No Data loaded" end
	
	local recipe = CraftingConfig.Recipes[recipeName]
	if not recipe then
		return false, "Recette introuvable."
	end
	
	local requirements = recipe.Requirements
	
	-- 1. Currencies check
	local goldCost = requirements.Gold or 0
	local gemsCost = requirements.Gems or 0
	if profile.Gold < goldCost then return false, "Or insuffisant." end
	if profile.Gems < gemsCost then return false, "Gemmes insuffisantes." end
	
	-- 2. Potion sub-components check
	if requirements.Potions then
		for reqPot, amt in pairs(requirements.Potions) do
			local pAmt = profile.InventoryPotions and profile.InventoryPotions[reqPot] or 0
			if pAmt < amt then
				return false, "Potions requises insuffisantes."
			end
		end
	end
	
	-- 3. Cards material check
	local cardsToRemove = {}
	if requirements.Cards then
		for _, reqCard in ipairs(requirements.Cards) do
			local count = 0
			for i, c in ipairs(profile.Inventory) do
				local cConf = CardsConfig.Cards[c.Name]
				if cConf and cConf.Rarity == reqCard.Rarity and not table.find(profile.EquippedCards, c.Id) and not table.find(cardsToRemove, i) then
					table.insert(cardsToRemove, i)
					count = count + 1
					if count >= reqCard.Amount then
						break
					end
				end
			end
			
			if count < reqCard.Amount then
				return false, "Cartes requises insuffisantes."
			end
		end
	end
	
	-- All checks passed! Deduct currencies
	profile.Gold = profile.Gold - goldCost
	profile.Gems = profile.Gems - gemsCost
	
	-- Deduct potions material
	if requirements.Potions then
		profile.InventoryPotions = profile.InventoryPotions or {}
		for reqPot, amt in pairs(requirements.Potions) do
			profile.InventoryPotions[reqPot] = profile.InventoryPotions[reqPot] - amt
		end
	end
	
	-- Deduct cards material (Sort indices descending first!)
	table.sort(cardsToRemove, function(a, b) return a > b end)
	for _, idx in ipairs(cardsToRemove) do
		table.remove(profile.Inventory, idx)
	end
	
	-- Award crafted potion
	profile.InventoryPotions = profile.InventoryPotions or {}
	local targetPotion = recipe.Result
	profile.InventoryPotions[targetPotion] = (profile.InventoryPotions[targetPotion] or 0) + 1
	
	-- Trigger success alert
	Network.FireClient(player, "NotifySuccess", "Vous avez fabriqué 1x " .. recipe.DisplayName)
	
	return true
end

function CraftingService.Start()
	-- RemoteFunctions
	local fuseFunc = Network.GetFunction("RequestFusion")
	fuseFunc.OnServerInvoke = function(player, cardIds)
		return CraftingService.FuseCards(player, cardIds)
	end
	
	local craftFunc = Network.GetFunction("RequestCraft")
	craftFunc.OnServerInvoke = function(player, recipeName)
		return CraftingService.CraftPotion(player, recipeName)
	end
end

return CraftingService
