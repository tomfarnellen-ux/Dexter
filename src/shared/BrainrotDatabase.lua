local BrainrotDatabase = {}

BrainrotDatabase.List = {
	{ id = "noodle_nugget",        name = "Noodle Nugget",           rarity = "Common",      income = 2,     size = 3 },
	{ id = "banana_bob",           name = "Banana Bob",              rarity = "Common",      income = 3,     size = 3 },
	{ id = "soggy_sock",           name = "Soggy Sock",              rarity = "Common",      income = 4,     size = 3 },
	{ id = "toaster_tim",          name = "Toaster Tim",             rarity = "Common",      income = 5,     size = 3 },

	{ id = "rubber_ducky",         name = "Rubber Ducky Deluxe",     rarity = "Uncommon",    income = 10,    size = 4 },
	{ id = "spaghetti_sam",        name = "Spaghetti Sam",           rarity = "Uncommon",    income = 14,    size = 4 },
	{ id = "bubble_gumbo",         name = "Bubble Gumbo",            rarity = "Uncommon",    income = 18,    size = 4 },

	{ id = "pizza_panther",        name = "Pizza Panther",           rarity = "Rare",        income = 35,    size = 5 },
	{ id = "waffle_wizard",        name = "Waffle Wizard",           rarity = "Rare",        income = 50,    size = 5 },
	{ id = "gummy_gorilla",        name = "Gummy Gorilla",           rarity = "Rare",        income = 70,    size = 5 },

	{ id = "turbo_taco",           name = "Turbo Taco",              rarity = "Epic",        income = 120,   size = 6 },
	{ id = "mega_muffin",          name = "Mega Muffin",             rarity = "Epic",        income = 180,   size = 6 },
	{ id = "cosmic_cupcake",       name = "Cosmic Cupcake",          rarity = "Epic",        income = 250,   size = 6 },

	{ id = "galaxy_gummybear",     name = "Galaxy Gummybear",        rarity = "Legendary",   income = 450,   size = 7 },
	{ id = "volcano_viper",        name = "Volcano Viper",           rarity = "Legendary",   income = 700,   size = 7 },
	{ id = "thunder_toast",        name = "Thunder Toast",           rarity = "Legendary",   income = 1100,  size = 7 },

	{ id = "rainbow_ramen",        name = "Rainbow Ramen",           rarity = "Mythic",      income = 2200,  size = 8 },
	{ id = "diamond_donut",        name = "Diamond Donut",           rarity = "Mythic",      income = 3500,  size = 8 },
	{ id = "nebula_noodle",        name = "Nebula Noodle",           rarity = "Mythic",      income = 5000,  size = 8 },

	{ id = "infinity_icecream",    name = "Infinity Ice Cream",      rarity = "BrainrotGod", income = 9000,  size = 10 },
	{ id = "cosmic_crocodile",     name = "Cosmic Crocodile",        rarity = "BrainrotGod", income = 14000, size = 10 },
	{ id = "astro_alligator",      name = "Astro Alligator",         rarity = "BrainrotGod", income = 20000, size = 10 },

	{ id = "secret_sparkle",       name = "Sparkle Sentinel ???",    rarity = "Secret",      income = 50000, size = 12 },
}

local byId = {}
for _, entry in ipairs(BrainrotDatabase.List) do
	byId[entry.id] = entry
end

function BrainrotDatabase.GetById(id)
	return byId[id]
end

function BrainrotDatabase.GetByRarity(rarity)
	local result = {}
	for _, entry in ipairs(BrainrotDatabase.List) do
		if entry.rarity == rarity then
			table.insert(result, entry)
		end
	end
	return result
end

return BrainrotDatabase
