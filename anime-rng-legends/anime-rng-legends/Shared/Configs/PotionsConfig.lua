local PotionsConfig = {
	Potions = {
		LuckPotion = {
			DisplayName = "Luck Potion",
			Duration = 300, -- 5 minutes
			BuffType = "Luck",
			Value = 1.5 -- +50% Luck
		},
		SuperLuckPotion = {
			DisplayName = "Super Luck Potion",
			Duration = 300,
			BuffType = "Luck",
			Value = 2.0 -- +100% Luck
		},
		UltraLuckPotion = {
			DisplayName = "Ultra Luck Potion",
			Duration = 300,
			BuffType = "Luck",
			Value = 3.0 -- +200% Luck
		},
		GodLuckPotion = {
			DisplayName = "God Luck Potion",
			Duration = 300,
			BuffType = "Luck",
			Value = 6.0 -- +500% Luck
		},
		RollSpeedPotion = {
			DisplayName = "Speed Potion",
			Duration = 300,
			BuffType = "RollSpeed",
			Value = 0.75 -- Cooldown is multiplied by 0.75 (25% faster)
		},
		GoldPotion = {
			DisplayName = "Gold Potion",
			Duration = 300,
			BuffType = "GoldMultiplier",
			Value = 1.5 -- +50% Gold gained
		},
		BossDamagePotion = {
			DisplayName = "Boss Damage Potion",
			Duration = 300,
			BuffType = "BossDamageMultiplier",
			Value = 1.5 -- +50% Damage dealt to Bosses
		}
	}
}

return PotionsConfig
