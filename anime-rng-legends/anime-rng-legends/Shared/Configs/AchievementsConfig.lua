local AchievementsConfig = {
	Achievements = {
		Roll100 = {
			DisplayName = "Novice Roller",
			Description = "Faire 100 Rolls",
			Type = "Rolls",
			Target = 100,
			Rewards = {
				Gold = 500,
				Gems = 20
			}
		},
		Roll1000 = {
			DisplayName = "Dedicated Roller",
			Description = "Faire 1,000 Rolls",
			Type = "Rolls",
			Target = 1000,
			Rewards = {
				Gold = 2500,
				Gems = 100,
				Potions = { LuckPotion = 2 }
			}
		},
		Roll10000 = {
			DisplayName = "RNG Master",
			Description = "Faire 10,000 Rolls",
			Type = "Rolls",
			Target = 10000,
			Rewards = {
				Gold = 15000,
				Gems = 500,
				Potions = { SuperLuckPotion = 3 }
			}
		},
		FirstMythic = {
			DisplayName = "Mythic Fate",
			Description = "Obtenir ton premier personnage Mythic",
			Type = "ObtainRarity",
			Rarity = "Mythic",
			Target = 1,
			Rewards = {
				Gems = 250,
				Potions = { UltraLuckPotion = 1 }
			}
		},
		FirstSecret = {
			DisplayName = "Secret Legacy",
			Description = "Obtenir ton premier personnage Secret",
			Type = "ObtainRarity",
			Rarity = "Secret",
			Target = 1,
			Rewards = {
				Gems = 1000,
				Tokens = 5,
				Potions = { GodLuckPotion = 1 }
			}
		},
		FirstDivine = {
			DisplayName = "Divine Intervention",
			Description = "Obtenir ton premier personnage Divine",
			Type = "ObtainRarity",
			Rarity = "Divine",
			Target = 1,
			Rewards = {
				Gems = 5000,
				Tokens = 20,
				Potions = { GodLuckPotion = 3 }
			}
		},
		FirstAnimeGod = {
			DisplayName = "Godlike Entity",
			Description = "Obtenir ton premier personnage Anime God",
			Type = "ObtainRarity",
			Rarity = "Anime God",
			Target = 1,
			Rewards = {
				Gems = 25000,
				Tokens = 100,
				Potions = { GodLuckPotion = 10 }
			}
		}
	}
}

return AchievementsConfig
