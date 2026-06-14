local CraftingConfig = {
	-- Fusion Definitions
	Fusions = {
		Common = {
			TargetRarity = "Uncommon",
			AmountRequired = 5,
			GoldCost = 100
		},
		Uncommon = {
			TargetRarity = "Rare",
			AmountRequired = 5,
			GoldCost = 250
		},
		Rare = {
			TargetRarity = "Epic",
			AmountRequired = 5,
			GoldCost = 1000
		},
		Epic = {
			TargetRarity = "Legendary",
			AmountRequired = 5,
			GoldCost = 5000
		},
		Legendary = {
			TargetRarity = "Mythic",
			AmountRequired = 5,
			GoldCost = 20000,
			GemsCost = 100
		},
		Mythic = {
			TargetRarity = "Secret",
			AmountRequired = 5,
			GoldCost = 100000,
			GemsCost = 500
		}
	},

	-- Potions Crafting Recipes
	Recipes = {
		LuckPotion = {
			DisplayName = "Luck Potion",
			Result = "LuckPotion",
			Requirements = {
				Gold = 200,
				Gems = 0,
				Cards = {
					{ Rarity = "Common", Amount = 5 }
				}
			}
		},
		SuperLuckPotion = {
			DisplayName = "Super Luck Potion",
			Result = "SuperLuckPotion",
			Requirements = {
				Gold = 500,
				Gems = 0,
				Potions = { LuckPotion = 2 },
				Cards = {
					{ Rarity = "Uncommon", Amount = 3 }
				}
			}
		},
		UltraLuckPotion = {
			DisplayName = "Ultra Luck Potion",
			Result = "UltraLuckPotion",
			Requirements = {
				Gold = 2000,
				Gems = 50,
				Potions = { SuperLuckPotion = 2 },
				Cards = {
					{ Rarity = "Rare", Amount = 3 }
				}
			}
		},
		GodLuckPotion = {
			DisplayName = "God Luck Potion",
			Result = "GodLuckPotion",
			Requirements = {
				Gold = 10000,
				Gems = 250,
				Potions = { UltraLuckPotion = 2 },
				Cards = {
					{ Rarity = "Epic", Amount = 3 }
				}
			}
		},
		RollSpeedPotion = {
			DisplayName = "Roll Speed Potion",
			Result = "RollSpeedPotion",
			Requirements = {
				Gold = 300,
				Gems = 0,
				Cards = {
					{ Rarity = "Common", Amount = 3 },
					{ Rarity = "Uncommon", Amount = 1 }
				}
			}
		},
		GoldPotion = {
			DisplayName = "Gold Potion",
			Result = "GoldPotion",
			Requirements = {
				Gold = 250,
				Gems = 0,
				Cards = {
					{ Rarity = "Common", Amount = 4 }
				}
			}
		},
		BossDamagePotion = {
			DisplayName = "Boss Damage Potion",
			Result = "BossDamagePotion",
			Requirements = {
				Gold = 800,
				Gems = 10,
				Cards = {
					{ Rarity = "Uncommon", Amount = 3 },
					{ Rarity = "Rare", Amount = 1 }
				}
			}
		}
	}
}

return CraftingConfig
