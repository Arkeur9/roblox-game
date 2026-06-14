local RarityConfig = {
	Order = {
		"Common",
		"Uncommon",
		"Rare",
		"Epic",
		"Legendary",
		"Mythic",
		"Secret",
		"Divine",
		"Celestial",
		"Transcendent",
		"Anime God",
		"Impossible"
	},
	
	Rarities = {
		Common = {
			DisplayName = "Common",
			Chance = 2, -- 1/2
			Color = Color3.fromRGB(180, 180, 180),
			Glow = false,
			Particles = false,
			Shake = false,
			Announce = false,
			SoundId = "rbxassetid://9114223153"
		},
		Uncommon = {
			DisplayName = "Uncommon",
			Chance = 5, -- 1/5
			Color = Color3.fromRGB(120, 220, 120),
			Glow = false,
			Particles = false,
			Shake = false,
			Announce = false,
			SoundId = "rbxassetid://9114223153"
		},
		Rare = {
			DisplayName = "Rare",
			Chance = 20, -- 1/20
			Color = Color3.fromRGB(70, 160, 240),
			Glow = true,
			Particles = false,
			Shake = false,
			Announce = false,
			SoundId = "rbxassetid://9114223408"
		},
		Epic = {
			DisplayName = "Epic",
			Chance = 100, -- 1/100
			Color = Color3.fromRGB(180, 80, 220),
			Glow = true,
			Particles = true,
			Shake = false,
			Announce = false,
			SoundId = "rbxassetid://9114223408"
		},
		Legendary = {
			DisplayName = "Legendary",
			Chance = 500, -- 1/500
			Color = Color3.fromRGB(250, 180, 40),
			Glow = true,
			Particles = true,
			Shake = true,
			ShakeIntensity = 2,
			Announce = false,
			SoundId = "rbxassetid://9119707253"
		},
		Mythic = {
			DisplayName = "Mythic",
			Chance = 2000, -- 1/2,000
			Color = Color3.fromRGB(240, 60, 60),
			Glow = true,
			Particles = true,
			Shake = true,
			ShakeIntensity = 5,
			Announce = true,
			SoundId = "rbxassetid://9119707253"
		},
		Secret = {
			DisplayName = "Secret",
			Chance = 10000, -- 1/10,000
			Color = Color3.fromRGB(240, 50, 180),
			Glow = true,
			Particles = true,
			Shake = true,
			ShakeIntensity = 8,
			Announce = true,
			SoundId = "rbxassetid://9119707253"
		},
		Divine = {
			DisplayName = "Divine",
			Chance = 100000, -- 1/100,000
			Color = Color3.fromRGB(255, 230, 100),
			Glow = true,
			Particles = true,
			Shake = true,
			ShakeIntensity = 15,
			Announce = true,
			SoundId = "rbxassetid://16024840801"
		},
		Celestial = {
			DisplayName = "Celestial",
			Chance = 1000000, -- 1/1,000,000
			Color = Color3.fromRGB(100, 240, 255),
			Glow = true,
			Particles = true,
			Shake = true,
			ShakeIntensity = 25,
			Announce = true,
			SoundId = "rbxassetid://16024840801"
		},
		Transcendent = {
			DisplayName = "Transcendent",
			Chance = 10000000, -- 1/10,000,000
			Color = Color3.fromRGB(255, 100, 255),
			Glow = true,
			Particles = true,
			Shake = true,
			ShakeIntensity = 40,
			Announce = true,
			SoundId = "rbxassetid://16024840801"
		},
		["Anime God"] = {
			DisplayName = "Anime God",
			Chance = 100000000, -- 1/100,000,000
			Color = Color3.fromRGB(255, 60, 100),
			Glow = true,
			Particles = true,
			Shake = true,
			ShakeIntensity = 60,
			Announce = true,
			SoundId = "rbxassetid://16024840801"
		},
		Impossible = {
			DisplayName = "Impossible",
			Chance = 1000000000, -- 1/1,000,000,000
			Color = Color3.fromRGB(0, 0, 0),
			Glow = true,
			Particles = true,
			Shake = true,
			ShakeIntensity = 100,
			Announce = true,
			SoundId = "rbxassetid://16024840801"
		}
	}
}

return RarityConfig
