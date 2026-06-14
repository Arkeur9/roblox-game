local QuestsConfig = {
	Daily = {
		Roll100 = {
			Description = "Faire 100 rolls",
			Type = "Rolls",
			Target = 100,
			Rewards = {
				Gems = 50,
				Gold = 500,
				Potions = { LuckPotion = 1 }
			}
		},
		Obtain3Legendary = {
			Description = "Obtenir 3 légendaires",
			Type = "ObtainRarity",
			Rarity = "Legendary",
			Target = 3,
			Rewards = {
				Gems = 100,
				Gold = 1000,
				Potions = { SuperLuckPotion = 1 }
			}
		},
		Spend1000Gold = {
			Description = "Dépenser 1000 Gold",
			Type = "SpendGold",
			Target = 1000,
			Rewards = {
				Gems = 20,
				Tokens = 1,
				Potions = { RollSpeedPotion = 1 }
			}
		}
	},
	
	Weekly = {
		Roll5000 = {
			Description = "Faire 5000 rolls",
			Type = "Rolls",
			Target = 5000,
			Rewards = {
				Gems = 1000,
				Gold = 10000,
				Potions = { GodLuckPotion = 1 }
			}
		},
		ObtainMythic = {
			Description = "Obtenir un Mythic",
			Type = "ObtainRarity",
			Rarity = "Mythic",
			Target = 1,
			Rewards = {
				Gems = 1500,
				Tokens = 10,
				Potions = { UltraLuckPotion = 2 }
			}
		},
		BeatBoss = {
			Description = "Battre un Boss 10 fois",
			Type = "DefeatBoss",
			Target = 10,
			Rewards = {
				Gems = 500,
				Gold = 5000,
				Potions = { BossDamagePotion = 3 }
			}
		}
	}
}

return QuestsConfig
