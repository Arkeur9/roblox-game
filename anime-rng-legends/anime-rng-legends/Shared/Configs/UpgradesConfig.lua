local UpgradesConfig = {
	-- Luck Upgrade (1 to 500)
	Luck = {
		MaxLevel = 500,
		BaseCost = 100, -- Gold
		CostMultiplier = 1.05, -- cost = BaseCost * (CostMultiplier ^ level)
		GetCost = function(level)
			return math.floor(100 * (1.06 ^ (level - 1)))
		end,
		GetMultiplier = function(level)
			return 1 + (level - 1) * 0.02 -- +2% luck per level
		end
	},

	-- Roll Speed Upgrade (1 to 200)
	RollSpeed = {
		MaxLevel = 200,
		BaseCost = 250, -- Gold
		GetCost = function(level)
			return math.floor(250 * (1.08 ^ (level - 1)))
		end,
		-- Time in seconds between rolls
		GetCooldown = function(level)
			-- Starts at 3.0s, approaches 0.3s at max level
			local minCooldown = 0.3
			local maxCooldown = 3.0
			local scale = (level - 1) / 199
			return math.max(minCooldown, maxCooldown - (maxCooldown - minCooldown) * scale)
		end
	},

	-- Inventory Size Upgrade
	InventorySize = {
		MaxLevel = 100,
		BaseCost = 500, -- Gold
		GetCost = function(level)
			return math.floor(500 * (1.10 ^ (level - 1)))
		end,
		GetCapacity = function(level)
			return 20 + (level - 1) * 3 -- Starts at 20 slots, +3 per level
		end
	},

	-- Critical Luck Upgrade (Increases chance of triggering a Critical Roll which multiplies Luck by 5x to 100x temporarily for that roll)
	CriticalLuck = {
		MaxLevel = 100,
		BaseCost = 1000, -- Gems
		GetCost = function(level)
			return math.floor(1000 * (1.12 ^ (level - 1)))
		end,
		GetChance = function(level)
			return 0.01 + (level - 1) * 0.002 -- Starts at 1%, +0.2% per level (max 20.8%)
		end,
		GetMultiplier = function()
			-- Returns a random multiplier between 5 and 50
			return math.random(5, 50)
		end
	},

	-- Multi Roll options (Unlocked via Gems or progress)
	MultiRoll = {
		Tiers = {
			[1] = { Amount = 1, Cost = 0, Currency = "Gold" },
			[2] = { Amount = 5, Cost = 5000, Currency = "Gold" },
			[3] = { Amount = 10, Cost = 25000, Currency = "Gold" },
			[4] = { Amount = 50, Cost = 1000, Currency = "Gems" },
			[5] = { Amount = 100, Cost = 5000, Currency = "Gems" }
		}
	},

	-- Auto Roll
	AutoRoll = {
		Cost = 1000, -- Gold to unlock permanently
		Currency = "Gold"
	}
}

return UpgradesConfig
