local WorldsConfig = {
	Order = {
		"AnimeVillage",
		"NinjaWorld",
		"PirateOcean",
		"SoulSociety",
		"SaiyanPlanet",
		"MagicKingdom",
		"DemonRealm",
		"ShadowUniverse",
		"CelestialHeaven",
		"AnimeMultiverse"
	},
	
	Worlds = {
		AnimeVillage = {
			DisplayName = "Anime Village",
			Cost = 0,
			Currency = "Gold",
			LuckMultiplier = 1.0,
			Boss = nil,
			ExclusiveCards = {"Sakury", "Koby", "Krilyn", "Tanjero"}
		},
		NinjaWorld = {
			DisplayName = "Ninja World",
			Cost = 1000,
			Currency = "Gold",
			LuckMultiplier = 1.2,
			Boss = "Madory",
			ExclusiveCards = {"Sasuky", "Noruto", "SageNoruto", "KuramaNoruto", "HokageNoruto"}
		},
		PirateOcean = {
			DisplayName = "Pirate Ocean",
			Cost = 5000,
			Currency = "Gold",
			LuckMultiplier = 1.5,
			Boss = "LuffiBoss", -- Defined in BossConfig
			ExclusiveCards = {"Sanjy", "Zolo", "Luffi", "Gear2Luffi", "Gear4Luffi", "Gear5Luffi"}
		},
		SoulSociety = {
			DisplayName = "Soul Society",
			Cost = 25000,
			Currency = "Gold",
			LuckMultiplier = 2.0,
			Boss = "Aizn",
			ExclusiveCards = {"Uryu", "Itchigo", "Aizn", "Yhawach"}
		},
		SaiyanPlanet = {
			DisplayName = "Saiyan Planet",
			Cost = 100000,
			Currency = "Gold",
			LuckMultiplier = 3.0,
			Boss = "Freesa",
			ExclusiveCards = {"Goko", "SuperGoko", "BlueGoko", "UIGoko", "GokoUI", "Jiren"}
		},
		MagicKingdom = {
			DisplayName = "Magic Kingdom",
			Cost = 500000,
			Currency = "Gold",
			LuckMultiplier = 4.5,
			Boss = "Yuno",
			ExclusiveCards = {"GoldenRimuru"}
		},
		DemonRealm = {
			DisplayName = "Demon Realm",
			Cost = 2000000,
			Currency = "Gold",
			LuckMultiplier = 6.0,
			Boss = "Mozan",
			ExclusiveCards = {"Zenitso", "Sokuna", "Gojoo", "Mozan"}
		},
		ShadowUniverse = {
			DisplayName = "Shadow Universe",
			Cost = 10000,
			Currency = "Gems",
			LuckMultiplier = 8.0,
			Boss = "ShadowLord",
			ExclusiveCards = {"Saitamo"}
		},
		CelestialHeaven = {
			DisplayName = "Celestial Heaven",
			Cost = 50000,
			Currency = "Gems",
			LuckMultiplier = 12.0,
			Boss = "GodKami",
			ExclusiveCards = {"Jiren"}
		},
		AnimeMultiverse = {
			DisplayName = "Anime Multiverse",
			Cost = 250000,
			Currency = "Gems",
			LuckMultiplier = 20.0,
			Boss = "MultiverseOverlord",
			ExclusiveCards = {} -- Can roll all cards with +50% base luck
		}
	}
}

return WorldsConfig
