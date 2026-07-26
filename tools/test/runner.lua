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

	return report
end

return runner

