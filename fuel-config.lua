local fuel_config = {}

-- The first available item with a positive fuel value is used as reference.
fuel_config.reference_items = {"solid-fuel", "coal", "wood"}

-- Values are divisors: fluid fuel value = reference item fuel value / divisor.
-- Canonical fuel names occur exactly once, independently of mod prefixes.
fuel_config.fuelfactors = {
	["petroleum-gas"] = 1.0,
	["light-oil"] = 1.5,
	["heavy-oil"] = 2.0,
	["crude-oil"] = 3.0,
	["methane"] = 2.0,
	["natural-gas"] = 2.0,
	["raw-gas"] = 3.0,
	["residual-gas"] = 4.0,
	["synthesis-gas"] = 4.0,
	["hydrogen"] = 3.0,
	["carbon-monoxide"] = 6.0,
	["ethane"] = 2.0,
	["butane"] = 1.5,
	["methanol"] = 3.0,
	["ethanol"] = 2.5,
	["fuel-oil"] = 1.25,
	["naphtha"] = 1.5,
	["natural-gas-liquids"] = 1.5,
	["mineral-oil"] = 2.0,
	["multi-phase-oil"] = 3.0,
	["vegetable-oil"] = 2.0,
	["fish-oil"] = 2.5,
	["black-liquor"] = 5.0,
	["diesel"] = 1.25,
}

-- A source stores only its prefix and the mod-specific part of each prototype
-- name. This keeps balancing in fuelfactors while allowing different naming
-- conventions such as angels-gas-methane and se-methane-gas.
fuel_config.sources = {
	base = {
		prefix = "",
		startup_setting = "vanilla-fluid-fuel-values",
		fluids = {
			["petroleum-gas"] = "petroleum-gas",
			["light-oil"] = "light-oil",
			["heavy-oil"] = "heavy-oil",
			["crude-oil"] = "crude-oil",
		},
	},
	angelspetrochem = {
		prefix = "angels-",
		fluids = {
			["methane"] = "gas-methane",
			["natural-gas"] = "gas-natural-1",
			["raw-gas"] = "gas-raw-1",
			["residual-gas"] = "gas-residual",
			["synthesis-gas"] = "gas-synthesis",
			["hydrogen"] = "gas-hydrogen",
			["carbon-monoxide"] = "gas-carbon-monoxide",
			["ethane"] = "gas-ethane",
			["butane"] = "gas-butane",
			["methanol"] = "gas-methanol",
			["ethanol"] = "gas-ethanol",
			["fuel-oil"] = "liquid-fuel-oil",
			["naphtha"] = "liquid-naphtha",
			["natural-gas-liquids"] = "liquid-ngl",
			["mineral-oil"] = "liquid-mineral-oil",
			["multi-phase-oil"] = "liquid-multi-phase-oil",
			["vegetable-oil"] = "liquid-vegetable-oil",
			["fish-oil"] = "liquid-fish-oil",
			["black-liquor"] = "liquid-black-liquor",
		},
	},
	["space-exploration"] = {
		prefix = "se-",
		fluids = {
			["methane"] = "methane-gas",
		},
	},
	KS_Power = {
		prefix = "",
		fluids = {
			["diesel"] = "diesel-fuel",
		},
	},
}

return fuel_config
