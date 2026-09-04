local runner = {}

local function technology_unlocks_recipe(technology_name, recipe_name)
	local technology = data.raw.technology[technology_name]
	for _, effect in ipairs((technology and technology.effects) or {}) do
		if effect.type == "unlock-recipe" and effect.recipe == recipe_name then
			return true
		end
	end
	return false
end

function runner.run(profile)
	profile = profile or {}
	local tier_count = tonumber(settings.startup["generator-tiers"].value)
	local base_power = settings.startup["generator-power"].value
	local usage_priority = settings.startup["generator-usage-priority"].value
	local reference_fuel_value, reference_fuel_name = get_fluid_fuel_reference()
	local report = {
		schema = "tiered-gas-generator-test-report/v1",
		mod = "tiered-gas-generator",
		factorio_version = helpers and helpers.game_version or "unknown",
		profile = profile.name or "default",
		status = "pass",
		summary = {total = 0, passed = 0, failed = 0},
		cases = {},
		context = {
			mods = mods,
			settings = {
				generator_tiers = tier_count,
				generator_power = base_power,
				generator_usage_priority = usage_priority,
				vanilla_fluid_fuel_values = settings.startup["vanilla-fluid-fuel-values"].value,
			},
			fluid_fuel_values = {},
			fluid_fuel_reference = {
				name = reference_fuel_name,
				fuel_value = reference_fuel_value,
			},
		},
	}

	local function add_case(id, name, passed, message, details)
		report.summary.total = report.summary.total + 1
		if passed then
			report.summary.passed = report.summary.passed + 1
		else
			report.summary.failed = report.summary.failed + 1
			report.status = "fail"
		end
		table.insert(report.cases, {
			id = id,
			name = name,
			status = passed and "pass" or "fail",
			message = message or (passed and "ok" or "failed"),
			details = details,
		})
	end

	add_case(
		"settings.test-mode",
		"hidden startup setting enables the test report",
		settings.startup["tiered-gas-generator-test-mode"]
			and settings.startup["tiered-gas-generator-test-mode"].value == true
	)

	for _, fluid_name in ipairs({"petroleum-gas", "light-oil", "heavy-oil", "crude-oil", "water"}) do
		local fluid = data.raw.fluid[fluid_name]
		report.context.fluid_fuel_values[fluid_name] = fluid and fluid.fuel_value or "0J"
	end

	for tier = 1, 6 do
		local name = "gas-power-station-" .. tier
		local entity = data.raw.generator[name]
		local item = data.raw.item[name]
		local recipe = data.raw.recipe[name]
		local technology = data.raw.technology[name]
		local visible = tier <= tier_count
		local expected_power = base_power * tier .. "MW"

		add_case(
			"prototype." .. name,
			name .. " entity, item, recipe, and technology exist",
			entity ~= nil and item ~= nil and recipe ~= nil and technology ~= nil,
			nil,
			{has_entity = entity ~= nil, has_item = item ~= nil, has_recipe = recipe ~= nil, has_technology = technology ~= nil}
		)
		add_case(
			"prototype." .. name .. ".links",
			name .. " prototypes link to each other",
			entity and item and recipe and technology
				and item.place_result == name
				and entity.minable and entity.minable.result == name
				and recipe.results and recipe.results[1] and recipe.results[1].name == name
				and technology_unlocks_recipe(name, name)
		)
		add_case(
			"prototype." .. name .. ".generator",
			name .. " has the expected generator parameters",
			entity
				and entity.burns_fluid == true
				and entity.destroy_non_fuel_fluid == false
				and entity.scale_fluid_usage == true
				and entity.effectivity == tier
				and entity.max_power_output == expected_power
				and entity.energy_source
				and entity.energy_source.usage_priority == usage_priority
				and entity.energy_source.output_flow_limit == expected_power,
			nil,
			entity
		)
		add_case(
			"prototype." .. name .. ".visibility",
			name .. " visibility follows generator-tiers",
			recipe and technology and recipe.hidden == not visible and technology.hidden == not visible,
			nil,
			{expected_visible = visible, recipe_hidden = recipe and recipe.hidden, technology_hidden = technology and technology.hidden}
		)
	end

	if mods["space-age"] then
		for tier = 1, 6 do
			local entity = data.raw.generator["gas-power-station-" .. tier]
			local condition = entity and entity.surface_conditions and entity.surface_conditions[1]
			add_case(
				"space-age.surface-condition." .. tier,
				"tier " .. tier .. " is limited to pressure 800 through 2000",
				condition and condition.property == "pressure" and condition.min == 800 and condition.max == 2000,
				nil,
				{surface_conditions = entity and entity.surface_conditions}
			)
		end
	else
		for tier = 1, 6 do
			local entity = data.raw.generator["gas-power-station-" .. tier]
			add_case(
				"vanilla.surface-condition." .. tier,
				"tier " .. tier .. " has no Space Age surface condition",
				entity and entity.surface_conditions == nil
			)
		end
	end

	local fuels_enabled = settings.startup["vanilla-fluid-fuel-values"].value
	for _, fluid_name in ipairs({"petroleum-gas", "light-oil", "heavy-oil", "crude-oil"}) do
		local fluid = data.raw.fluid[fluid_name]
		local has_fuel = not not (fluid and fluid.fuel_value and fluid.fuel_value ~= "0J")
		add_case(
			"fluid-fuel." .. fluid_name,
			fluid_name .. " fuel value follows vanilla-fluid-fuel-values",
			has_fuel == fuels_enabled,
			nil,
			{expected = fuels_enabled, fuel_value = fluid and fluid.fuel_value}
		)
	end

	add_case(
		"fluid-fuel.reference",
		"solid fuel is preferred as fluid fuel reference",
		reference_fuel_name == "solid-fuel" and reference_fuel_value == data.raw.item["solid-fuel"].fuel_value,
		nil,
		report.context.fluid_fuel_reference
	)

	if mods["angelspetrochem"] then
		local expected_angel_fuels = {
			["angels-gas-methane"] = 2.0,
			["angels-gas-natural-1"] = 2.0,
			["angels-gas-raw-1"] = 3.0,
			["angels-gas-residual"] = 4.0,
			["angels-gas-synthesis"] = 4.0,
			["angels-gas-hydrogen"] = 3.0,
			["angels-gas-carbon-monoxide"] = 6.0,
			["angels-gas-ethane"] = 2.0,
			["angels-gas-butane"] = 1.5,
			["angels-gas-methanol"] = 3.0,
			["angels-gas-ethanol"] = 2.5,
			["angels-liquid-fuel-oil"] = 1.25,
			["angels-liquid-naphtha"] = 1.5,
			["angels-liquid-ngl"] = 1.5,
			["angels-liquid-mineral-oil"] = 2.0,
			["angels-liquid-multi-phase-oil"] = 3.0,
			["angels-liquid-vegetable-oil"] = 2.0,
			["angels-liquid-fish-oil"] = 2.5,
			["angels-liquid-black-liquor"] = 5.0,
		}

		local reference_joules = util.parse_energy(reference_fuel_value)
		for fluid_name, divisor in pairs(expected_angel_fuels) do
			local fluid = data.raw.fluid[fluid_name]
			local actual_joules = fluid and fluid.fuel_value and util.parse_energy(fluid.fuel_value) or 0
			local expected_joules = reference_joules / divisor
			report.context.fluid_fuel_values[fluid_name] = fluid and fluid.fuel_value or "0J"
			add_case(
				"fluid-fuel.angels." .. fluid_name,
				fluid_name .. " receives its configured fuel value",
				math.abs(actual_joules - expected_joules) < 0.001,
				nil,
				{divisor = divisor, expected_joules = expected_joules, actual_fuel_value = fluid and fluid.fuel_value}
			)
		end

		for _, fluid_name in ipairs({
			"angels-gas-oxygen",
			"angels-gas-chlorine",
			"angels-gas-sulfur-dioxide",
			"angels-liquid-nitric-acid",
			"angels-liquid-molten-iron",
			"angels-water-purified",
		}) do
			local fluid = data.raw.fluid[fluid_name]
			add_case(
				"fluid-fuel.angels.excluded." .. fluid_name,
				fluid_name .. " remains non-fuel",
				fluid and not fluid.fuel_value,
				nil,
				{fuel_value = fluid and fluid.fuel_value}
			)
		end

		local methane = data.raw.fluid["angels-gas-methane"]
		local configured_methane_value = methane.fuel_value
		methane.fuel_value = "123kJ"
		apply_mod_fluid_fuel_stats(reference_fuel_value)
		local existing_value_was_preserved = methane.fuel_value == "123kJ"
		methane.fuel_value = configured_methane_value
		add_case(
			"fluid-fuel.existing-value",
			"an existing positive fluid fuel value is not overwritten",
			existing_value_was_preserved
		)
	end

	local solid_fuel = data.raw.item["solid-fuel"]
	local coal = data.raw.item["coal"]
	local solid_fuel_value = solid_fuel.fuel_value
	local coal_value = coal.fuel_value
	solid_fuel.fuel_value = nil
	local _, coal_reference = get_fluid_fuel_reference()
	coal.fuel_value = nil
	local _, wood_reference = get_fluid_fuel_reference()
	solid_fuel.fuel_value = solid_fuel_value
	coal.fuel_value = coal_value
	add_case(
		"fluid-fuel.reference-fallback",
		"fluid fuel reference falls back from solid fuel to coal and then wood",
		coal_reference == "coal" and wood_reference == "wood",
		nil,
		{coal_reference = coal_reference, wood_reference = wood_reference}
	)

	return report
end

return runner

