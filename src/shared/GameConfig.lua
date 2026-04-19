local GameConfig = {}

GameConfig.STARTING_COINS = 100
GameConfig.PLOT_COUNT = 6
GameConfig.PLOT_SIZE = Vector3.new(60, 1, 40)
GameConfig.PLOT_SPACING = 30
GameConfig.PEDESTALS_PER_PLOT = 6
GameConfig.PEDESTAL_SPACING = 8
GameConfig.INCOME_TICK = 1

GameConfig.STEAL_HOLD_TIME = 5
GameConfig.STEAL_COOLDOWN = 15
GameConfig.LOCK_DURATION = 60
GameConfig.LOCK_COST = 250

GameConfig.ROLL_COST = 150
GameConfig.ROLL_COOLDOWN = 1.5

GameConfig.MAX_NAME_LENGTH = 24

GameConfig.RARITY_WEIGHTS = {
	Common = 5000,
	Uncommon = 2500,
	Rare = 1500,
	Epic = 700,
	Legendary = 250,
	Mythic = 40,
	BrainrotGod = 9,
	Secret = 1,
}

GameConfig.RARITY_COLORS = {
	Common = Color3.fromRGB(189, 189, 189),
	Uncommon = Color3.fromRGB(102, 204, 102),
	Rare = Color3.fromRGB(80, 160, 255),
	Epic = Color3.fromRGB(170, 80, 255),
	Legendary = Color3.fromRGB(255, 170, 40),
	Mythic = Color3.fromRGB(255, 80, 120),
	BrainrotGod = Color3.fromRGB(255, 240, 60),
	Secret = Color3.fromRGB(255, 40, 255),
}

return GameConfig
