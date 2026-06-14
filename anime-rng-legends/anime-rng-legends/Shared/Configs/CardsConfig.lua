local CardsConfig = {
	Cards = {
		-- Common
		Sakury = {
			DisplayName = "Sakury",
			Anime = "Ninja Chronicles",
			Rarity = "Common",
			Damage = 10,
			HP = 50,
			Power = 15,
			LuckBonus = 0.0,
			Value = 50,
			Aura = "PinkMist",
			Evolution = nil
		},
		Koby = {
			DisplayName = "Koby",
			Anime = "Pirate Sea",
			Rarity = "Common",
			Damage = 8,
			HP = 40,
			Power = 12,
			LuckBonus = 0.0,
			Value = 40,
			Aura = "GreySmoke",
			Evolution = nil
		},
		Krilyn = {
			DisplayName = "Krilyn",
			Anime = "Z Warriors",
			Rarity = "Common",
			Damage = 12,
			HP = 60,
			Power = 18,
			LuckBonus = 0.0,
			Value = 60,
			Aura = "YellowSparks",
			Evolution = nil
		},

		-- Uncommon
		Zenitso = {
			DisplayName = "Zenitso",
			Anime = "Demon Slayer",
			Rarity = "Uncommon",
			Damage = 25,
			HP = 120,
			Power = 40,
			LuckBonus = 0.01,
			Value = 150,
			Aura = "YellowLightning",
			Evolution = nil
		},
		Uryu = {
			DisplayName = "Uryu",
			Anime = "Soul Reapers",
			Rarity = "Uncommon",
			Damage = 20,
			HP = 100,
			Power = 35,
			LuckBonus = 0.01,
			Value = 120,
			Aura = "BlueEnergy",
			Evolution = nil
		},
		Sanjy = {
			DisplayName = "Sanjy",
			Anime = "Pirate Sea",
			Rarity = "Uncommon",
			Damage = 28,
			HP = 130,
			Power = 45,
			LuckBonus = 0.01,
			Value = 160,
			Aura = "FireFeet",
			Evolution = nil
		},

		-- Rare
		Tanjero = {
			DisplayName = "Tanjero",
			Anime = "Demon Slayer",
			Rarity = "Rare",
			Damage = 60,
			HP = 300,
			Power = 100,
			LuckBonus = 0.03,
			Value = 400,
			Aura = "WaterFlow",
			Evolution = nil
		},
		Zolo = {
			DisplayName = "Zolo",
			Anime = "Pirate Sea",
			Rarity = "Rare",
			Damage = 65,
			HP = 320,
			Power = 110,
			LuckBonus = 0.03,
			Value = 450,
			Aura = "GreenSlash",
			Evolution = nil
		},
		Sasuky = {
			DisplayName = "Sasuky",
			Anime = "Ninja Chronicles",
			Rarity = "Rare",
			Damage = 70,
			HP = 310,
			Power = 115,
			LuckBonus = 0.03,
			Value = 480,
			Aura = "PurpleLightning",
			Evolution = nil
		},

		-- Epic
		Bakogo = {
			DisplayName = "Bakogo",
			Anime = "Hero School",
			Rarity = "Epic",
			Damage = 150,
			HP = 750,
			Power = 300,
			LuckBonus = 0.05,
			Value = 1200,
			Aura = "ExplosionGlow",
			Evolution = nil
		},
		Levy = {
			DisplayName = "Levy",
			Anime = "Titan Wall",
			Rarity = "Epic",
			Damage = 160,
			HP = 700,
			Power = 320,
			LuckBonus = 0.05,
			Value = 1300,
			Aura = "WindSpin",
			Evolution = nil
		},
		Itchigo = {
			DisplayName = "Itchigo",
			Anime = "Soul Reapers",
			Rarity = "Epic",
			Damage = 180,
			HP = 800,
			Power = 350,
			LuckBonus = 0.06,
			Value = 1500,
			Aura = "BlackGetsuga",
			Evolution = nil
		},

		-- Legendary
		Noruto = {
			DisplayName = "Noruto",
			Anime = "Ninja Chronicles",
			Rarity = "Legendary",
			Damage = 350,
			HP = 1800,
			Power = 800,
			LuckBonus = 0.10,
			Value = 4000,
			Aura = "OrangeChakra",
			Evolution = {
				NextStage = "SageNoruto",
				Requirements = {
					Gold = 10000,
					Gems = 200,
					Materials = { Common = 10, Uncommon = 5 }
				}
			}
		},
		Luffi = {
			DisplayName = "Luffi",
			Anime = "Pirate Sea",
			Rarity = "Legendary",
			Damage = 360,
			HP = 1900,
			Power = 820,
			LuckBonus = 0.10,
			Value = 4200,
			Aura = "RedSteam",
			Evolution = {
				NextStage = "Gear2Luffi",
				Requirements = {
					Gold = 10000,
					Gems = 200,
					Materials = { Common = 10, Uncommon = 5 }
				}
			}
		},
		Goko = {
			DisplayName = "Goko",
			Anime = "Z Warriors",
			Rarity = "Legendary",
			Damage = 400,
			HP = 2000,
			Power = 900,
			LuckBonus = 0.12,
			Value = 5000,
			Aura = "YellowAura",
			Evolution = {
				NextStage = "SuperGoko",
				Requirements = {
					Gold = 12000,
					Gems = 250,
					Materials = { Common = 15, Uncommon = 8 }
				}
			}
		},

		-- Mythic
		Sokuna = {
			DisplayName = "Sokuna",
			Anime = "Cursed Magic",
			Rarity = "Mythic",
			Damage = 1000,
			HP = 5000,
			Power = 2500,
			LuckBonus = 0.20,
			Value = 15000,
			Aura = "FireSlash",
			Evolution = nil
		},
		Gojoo = {
			DisplayName = "Gojoo",
			Anime = "Cursed Magic",
			Rarity = "Mythic",
			Damage = 1100,
			HP = 5500,
			Power = 2700,
			LuckBonus = 0.22,
			Value = 17000,
			Aura = "InfinityBluePurple",
			Evolution = nil
		},
		Saitamo = {
			DisplayName = "Saitamo",
			Anime = "One Punch Hero",
			Rarity = "Mythic",
			Damage = 2500,
			HP = 3000,
			Power = 4000,
			LuckBonus = 0.25,
			Value = 20000,
			Aura = "SonicBoom",
			Evolution = nil
		},

		-- Secret
		Madory = {
			DisplayName = "Madory",
			Anime = "Ninja Chronicles",
			Rarity = "Secret",
			Damage = 5000,
			HP = 20000,
			Power = 12000,
			LuckBonus = 0.40,
			Value = 50000,
			Aura = "BlueSusanoo",
			Evolution = nil
		},
		Aizn = {
			DisplayName = "Aizn",
			Anime = "Soul Reapers",
			Rarity = "Secret",
			Damage = 5200,
			HP = 22000,
			Power = 12500,
			LuckBonus = 0.42,
			Value = 55000,
			Aura = "PurpleHado",
			Evolution = nil
		},

		-- Divine
		Freesa = {
			DisplayName = "Freesa",
			Anime = "Z Warriors",
			Rarity = "Divine",
			Damage = 15000,
			HP = 60000,
			Power = 35000,
			LuckBonus = 0.60,
			Value = 150000,
			Aura = "PurpleDeathEnergy",
			Evolution = nil
		},
		Mozan = {
			DisplayName = "Mozan",
			Anime = "Demon Slayer",
			Rarity = "Divine",
			Damage = 14000,
			HP = 65000,
			Power = 34000,
			LuckBonus = 0.58,
			Value = 145000,
			Aura = "BloodMist",
			Evolution = nil
		},

		-- Celestial
		Jiren = {
			DisplayName = "Jiren",
			Anime = "Z Warriors",
			Rarity = "Celestial",
			Damage = 50000,
			HP = 200000,
			Power = 120000,
			LuckBonus = 1.00,
			Value = 500000,
			Aura = "RedGlair",
			Evolution = nil
		},

		-- Transcendent
		Yhawach = {
			DisplayName = "Yhawach",
			Anime = "Soul Reapers",
			Rarity = "Transcendent",
			Damage = 180000,
			HP = 800000,
			Power = 450000,
			LuckBonus = 1.50,
			Value = 1800000,
			Aura = "AlmightyEyes",
			Evolution = nil
		},

		-- Anime God
		GokoUI = {
			DisplayName = "Goko (Ultra Instinct)",
			Anime = "Z Warriors",
			Rarity = "Anime God",
			Damage = 600000,
			HP = 2500000,
			Power = 1500000,
			LuckBonus = 2.50,
			Value = 8000000,
			Aura = "SilverCosmo",
			Evolution = nil
		},

		-- Impossible
		GoldenRimuru = {
			DisplayName = "Golden Rimuru",
			Anime = "Slime Lord",
			Rarity = "Impossible",
			Damage = 5000000,
			HP = 20000000,
			Power = 12000000,
			LuckBonus = 5.00,
			Value = 50000000,
			Aura = "VoidDevourer",
			Evolution = nil
		},

		-- EVOLVED FORMS (Not obtainable via RNG rolls directly, only evolution)
		SageNoruto = {
			DisplayName = "Sage Noruto",
			Anime = "Ninja Chronicles",
			Rarity = "Legendary",
			Damage = 900,
			HP = 4000,
			Power = 2000,
			LuckBonus = 0.18,
			Value = 12000,
			Aura = "SageChakra",
			IsEvolved = true,
			Evolution = {
				NextStage = "KuramaNoruto",
				Requirements = {
					Gold = 35000,
					Gems = 600,
					Materials = { Uncommon = 20, Rare = 5 }
				}
			}
		},
		KuramaNoruto = {
			DisplayName = "Kurama Noruto",
			Anime = "Ninja Chronicles",
			Rarity = "Mythic",
			Damage = 2800,
			HP = 12000,
			Power = 6000,
			LuckBonus = 0.30,
			Value = 35000,
			Aura = "GoldenKurama",
			IsEvolved = true,
			Evolution = {
				NextStage = "HokageNoruto",
				Requirements = {
					Gold = 100000,
					Gems = 2000,
					Materials = { Rare = 25, Epic = 5 }
				}
			}
		},
		HokageNoruto = {
			DisplayName = "Hokage Noruto",
			Anime = "Ninja Chronicles",
			Rarity = "Secret",
			Damage = 9000,
			HP = 45000,
			Power = 25000,
			LuckBonus = 0.50,
			Value = 120000,
			Aura = "HokageCape",
			IsEvolved = true,
			Evolution = nil
		},

		Gear2Luffi = {
			DisplayName = "Gear 2 Luffi",
			Anime = "Pirate Sea",
			Rarity = "Legendary",
			Damage = 950,
			HP = 4200,
			Power = 2100,
			LuckBonus = 0.18,
			Value = 13000,
			Aura = "PinkSteamJet",
			IsEvolved = true,
			Evolution = {
				NextStage = "Gear4Luffi",
				Requirements = {
					Gold = 35000,
					Gems = 600,
					Materials = { Uncommon = 20, Rare = 5 }
				}
			}
		},
		Gear4Luffi = {
			DisplayName = "Gear 4 Luffi",
			Anime = "Pirate Sea",
			Rarity = "Mythic",
			Damage = 3000,
			HP = 13000,
			Power = 6500,
			LuckBonus = 0.32,
			Value = 38000,
			Aura = "HakiGlow",
			IsEvolved = true,
			Evolution = {
				NextStage = "Gear5Luffi",
				Requirements = {
					Gold = 120000,
					Gems = 2500,
					Materials = { Rare = 25, Epic = 5 }
				}
			}
		},
		Gear5Luffi = {
			DisplayName = "Gear 5 Luffi",
			Anime = "Pirate Sea",
			Rarity = "Secret",
			Damage = 10000,
			HP = 50000,
			Power = 28000,
			LuckBonus = 0.55,
			Value = 130000,
			Aura = "WhiteCloudsJoyboy",
			IsEvolved = true,
			Evolution = nil
		},

		SuperGoko = {
			DisplayName = "Super Goko",
			Anime = "Z Warriors",
			Rarity = "Legendary",
			Damage = 1100,
			HP = 4500,
			Power = 2300,
			LuckBonus = 0.20,
			Value = 15000,
			Aura = "SSJAura",
			IsEvolved = true,
			Evolution = {
				NextStage = "BlueGoko",
				Requirements = {
					Gold = 40000,
					Gems = 700,
					Materials = { Uncommon = 25, Rare = 6 }
				}
			}
		},
		BlueGoko = {
			DisplayName = "Blue Goko",
			Anime = "Z Warriors",
			Rarity = "Mythic",
			Damage = 3300,
			HP = 15000,
			Power = 7500,
			LuckBonus = 0.35,
			Value = 45000,
			Aura = "SSBAura",
			IsEvolved = true,
			Evolution = {
				NextStage = "UIGoko",
				Requirements = {
					Gold = 150000,
					Gems = 3000,
					Materials = { Rare = 30, Epic = 6 }
				}
			}
		},
		UIGoko = {
			DisplayName = "UI Goko",
			Anime = "Z Warriors",
			Rarity = "Secret",
			Damage = 12000,
			HP = 55000,
			Power = 32000,
			LuckBonus = 0.60,
			Value = 160000,
			Aura = "UltraInstinctFlow",
			IsEvolved = true,
			Evolution = nil
		}
	}
}

return CardsConfig
