-- Simulation Runner for Anime RNG Legends
-- This script runs outside of Roblox to verify RNG calculations and weights.

-- 1. Mocking Roblox Globals
local function mockTable(name)
	local mock = {}
	setmetatable(mock, {
		__index = function(_, key)
			return function(...)
				-- print("Mock called: " .. name .. "." .. key)
				return mock
			end
		end
	})
	return mock
end

Color3 = {
	fromRGB = function(r, g, b) return {R=r, G=g, B=b} end,
	new = function(r, g, b) return {R=r, G=g, B=b} end
}
UDim = { new = function() return {} end }
UDim2 = {
	fromScale = function() return {} end,
	fromOffset = function() return {} end,
	new = function() return {} end
}
Enum = {
	Font = { Outfit = 1 },
	UserInputType = { MouseButton1 = 1, Touch = 2 },
	EasingStyle = { Back = 1, Quad = 2 },
	EasingDirection = { Out = 1, In = 2 },
	ApplyStrokeMode = { Border = 1 }
}

-- 2. Mock Modules Require Loader
local modules = {}
local function mockRequire(path)
	if path:match("RarityConfig") then
		return dofile("Shared/Configs/RarityConfig.lua")
	elseif path:match("CardsConfig") then
		return dofile("Shared/Configs/CardsConfig.lua")
	elseif path:match("UpgradesConfig") then
		return dofile("Shared/Configs/UpgradesConfig.lua")
	elseif path:match("WorldsConfig") then
		return dofile("Shared/Configs/WorldsConfig.lua")
	elseif path:match("PotionsConfig") then
		return dofile("Shared/Configs/PotionsConfig.lua")
	end
	error("Unknown require path in simulation: " .. tostring(path))
end

-- 3. Load Configurations
local RarityConfig = mockRequire("RarityConfig")
local CardsConfig = mockRequire("CardsConfig")
local UpgradesConfig = mockRequire("UpgradesConfig")

-- Seed random
math.randomseed(os.time())

-- 4. Re-implement RNG Draw logic for testing
local function selectCardFromRNG(luckMultiplier, worldCardsPool, criticalLuckChance)
	local isCritical = math.random() < criticalLuckChance
	local rollLuck = luckMultiplier
	if isCritical then
		-- Apply random crit boost between 5x and 50x
		rollLuck = luckMultiplier * math.random(5, 50)
	end
	
	local chosenCard = nil
	local chosenRarityOrder = -1
	
	-- Filter cards by pool if active
	local allowedCards = CardsConfig.Cards
	local hasPool = worldCardsPool and #worldCardsPool > 0
	
	for cardKey, cInfo in pairs(allowedCards) do
		if cInfo.IsEvolved then goto continue end
		
		-- Pool constraints check
		if hasPool then
			local matched = false
			for _, pCard in ipairs(worldCardsPool) do
				if pCard == cardKey then
					matched = true
					break
				end
			end
			if not matched then goto continue end
		end
		
		local rInfo = RarityConfig.Rarities[cInfo.Rarity]
		if not rInfo then goto continue end
		
		-- Probability weight check
		local finalChance = rInfo.Chance
		local rollOdds = math.random() * rollLuck
		if rollOdds >= (1 / finalChance) * rollLuck then
			-- Identify if it's rarer
			local rarityOrderIdx = 0
			for i, rName in ipairs(RarityConfig.Order) do
				if rName == cInfo.Rarity then
					rarityOrderIdx = i
					break
				end
			end
			
			if rarityOrderIdx > chosenRarityOrder then
				chosenCard = cardKey
				chosenRarityOrder = rarityOrderIdx
			end
		end
		
		::continue::
	end
	
	if not chosenCard then
		chosenCard = "Sakury"
	end
	
	return chosenCard, isCritical
end

-- 5. Run Roll Simulations
local SIMULATION_ROLLS = 100000
local results = {}
local criticalCount = 0

print("--------------------------------------------------")
print("Starting RNG Simulation: " .. SIMULATION_ROLLS .. " rolls...")
print("--------------------------------------------------")

local startClock = os.clock()

for i = 1, SIMULATION_ROLLS do
	-- Simulate player with Level 1 Luck Upgrade (Base = 1.0x luck multiplier)
	local luckMultiplier = 1.0
	
	-- Simulate 5% Critical Luck upgrade chance
	local critChance = 0.05 
	
	local cardName, wasCrit = selectCardFromRNG(luckMultiplier, nil, critChance)
	
	local cardData = CardsConfig.Cards[cardName]
	local rarity = cardData.Rarity
	
	results[rarity] = (results[rarity] or 0) + 1
	if wasCrit then
		criticalCount = criticalCount + 1
	end
end

local endClock = os.clock()

print(string.format("Simulation ended in %.4f seconds.", endClock - startClock))
print(string.format("Critical Rolls triggered: %d (%.2f%%)", criticalCount, (criticalCount / SIMULATION_ROLLS) * 100))
print("\n--- Card Rarity Distribution ---")
for _, rName in ipairs(RarityConfig.Order) do
	local count = results[rName] or 0
	local percentage = (count / SIMULATION_ROLLS) * 100
	local expectedOdds = RarityConfig.Rarities[rName].Chance
	print(string.format("%-15s : %-6d pulls (%.4f%%) - Configured Odds: 1/%s", rName, count, percentage, expectedOdds))
end
print("--------------------------------------------------")
