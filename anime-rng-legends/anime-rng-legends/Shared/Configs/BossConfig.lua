local BossConfig = {
	Bosses = {
		Madory = {
			DisplayName = "Madory",
			Level = 25,
			MaxHP = 15000,
			RespawnTime = 30,
			Drops = {
				GoldRange = {Min = 200, Max = 500},
				GemsRange = {Min = 10, Max = 30},
				Fragments = {Chance = 0.5, Min = 1, Max = 3},
				ExclusiveCards = {
					{CardName = "Sasuky", Chance = 0.05},
					{CardName = "Madory", Chance = 0.005}
				}
			}
		},
		LuffiBoss = {
			DisplayName = "Giant Luffi",
			Level = 40,
			MaxHP = 45000,
			RespawnTime = 40,
			Drops = {
				GoldRange = {Min = 500, Max = 1200},
				GemsRange = {Min = 20, Max = 50},
				Fragments = {Chance = 0.6, Min = 2, Max = 5},
				ExclusiveCards = {
					{CardName = "Zolo", Chance = 0.08},
					{CardName = "Luffi", Chance = 0.01}
				}
			}
		},
		Aizn = {
			DisplayName = "Aizn",
			Level = 60,
			MaxHP = 120000,
			RespawnTime = 60,
			Drops = {
				GoldRange = {Min = 1500, Max = 3500},
				GemsRange = {Min = 50, Max = 120},
				Fragments = {Chance = 0.7, Min = 3, Max = 8},
				ExclusiveCards = {
					{CardName = "Itchigo", Chance = 0.05},
					{CardName = "Aizn", Chance = 0.002}
				}
			}
		},
		Freesa = {
			DisplayName = "Freesa",
			Level = 80,
			MaxHP = 500000,
			RespawnTime = 90,
			Drops = {
				GoldRange = {Min = 5000, Max = 12000},
				GemsRange = {Min = 150, Max = 400},
				Fragments = {Chance = 0.8, Min = 5, Max = 12},
				ExclusiveCards = {
					{CardName = "Goko", Chance = 0.04},
					{CardName = "Freesa", Chance = 0.001}
				}
			}
		},
		Mozan = {
			DisplayName = "Mozan",
			Level = 100,
			MaxHP = 2000000,
			RespawnTime = 120,
			Drops = {
				GoldRange = {Min = 20000, Max = 50000},
				GemsRange = {Min = 500, Max = 1500},
				Fragments = {Chance = 0.9, Min = 10, Max = 25},
				ExclusiveCards = {
					{CardName = "Tanjero", Chance = 0.10},
					{CardName = "Mozan", Chance = 0.0005}
				}
			}
		},
		ShadowLord = {
			DisplayName = "Shadow Lord",
			Level = 150,
			MaxHP = 10000000,
			RespawnTime = 180,
			Drops = {
				GoldRange = {Min = 100000, Max = 250000},
				GemsRange = {Min = 2000, Max = 5000},
				Fragments = {Chance = 1.0, Min = 20, Max = 50},
				ExclusiveCards = {
					{CardName = "Saitamo", Chance = 0.0001}
				}
			}
		},
		Yuno = {
			DisplayName = "Yuno",
			Level = 70,
			MaxHP = 300000,
			RespawnTime = 60,
			Drops = {
				GoldRange = {Min = 3000, Max = 8000},
				GemsRange = {Min = 100, Max = 250},
				Fragments = {Chance = 0.75, Min = 4, Max = 10},
				ExclusiveCards = {
					{CardName = "GoldenRimuru", Chance = 0.0005}
				}
			}
		},
		GodKami = {
			DisplayName = "Kami-sama",
			Level = 120,
			MaxHP = 5000000,
			RespawnTime = 150,
			Drops = {
				GoldRange = {Min = 50000, Max = 150000},
				GemsRange = {Min = 1000, Max = 3000},
				Fragments = {Chance = 0.95, Min = 15, Max = 35},
				ExclusiveCards = {
					{CardName = "Jiren", Chance = 0.01}
				}
			}
		},
		MultiverseOverlord = {
			DisplayName = "Multiverse Overlord",
			Level = 200,
			MaxHP = 50000000,
			RespawnTime = 300,
			Drops = {
				GoldRange = {Min = 500000, Max = 1500000},
				GemsRange = {Min = 10000, Max = 30000},
				Fragments = {Chance = 1.0, Min = 50, Max = 150},
				ExclusiveCards = {
					{CardName = "GoldenRimuru", Chance = 0.005}
				}
			}
		}
	}
}

return BossConfig
