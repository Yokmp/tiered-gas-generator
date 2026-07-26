--#region debug
local report_name = "tiered-gas-generator-test-report"
local report_path = "tiered-gas-generator/test-report.json"
local evaluation_tick = 300

local function add_case(report, id, name, passed, message, details)
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

local function write_report()
	if not storage.tgg_test or not storage.tgg_test.report then return end
	helpers.write_file(report_path, helpers.table_to_json(storage.tgg_test.report), false)
	log("[tiered-gas-generator-test] Wrote " .. report_path)
end

local function copy_staged_report()
	if not prototypes or not prototypes.mod_data then return nil end
	local staged = prototypes.mod_data[report_name]
	if not (staged and staged.data) then return nil end
	return helpers.json_to_table(helpers.table_to_json(staged.data))
end

local function create_load(surface, position)
	local pole = surface.create_entity({
		name = "substation",
		position = position,
		force = "player",
		create_build_effect_smoke = false,
	})
	local load = surface.create_entity({
		name = "tiered-gas-generator-test-load",
		position = {position.x + 3, position.y},
		force = "player",
		create_build_effect_smoke = false,
	})
	return pole, load
end

local function create_generator_setup(surface, id, name, position, fluid_name, with_load)
	local generator = surface.create_entity({
		name = name,
		position = position,
		force = "player",
		create_build_effect_smoke = false,
	})
	local pole, load
	if generator and with_load then
		pole, load = create_load(surface, {x = position.x + 4, y = position.y})
	end
	if generator and fluid_name then
		generator.fluidbox[1] = {name = fluid_name, amount = 100, temperature = 25}
	end
	table.insert(storage.tgg_test.setups, {
		id = id,
		generator = generator,
		pole = pole,
		load = load,
		fluid = fluid_name,
		with_load = with_load,
	})
end

local function create_surface_condition_cases()
	if not script.active_mods["space-age"] then return end

	for _, condition in ipairs({
		{name = "pressure-0", pressure = 0, expected = false},
		{name = "pressure-800", pressure = 800, expected = true},
		{name = "pressure-1000", pressure = 1000, expected = true},
		{name = "pressure-2000", pressure = 2000, expected = true},
		{name = "pressure-4000", pressure = 4000, expected = false},
	}) do
		local surface_name = "tgg-test-" .. condition.name
		local surface = game.surfaces[surface_name] or game.create_surface(surface_name, {
			autoplace_controls = {},
			default_enable_all_autoplace_controls = false,
			width = 64,
			height = 64,
		})
		surface.set_property("pressure", condition.pressure)
		surface.request_to_generate_chunks({0, 0}, 1)
		surface.force_generate_chunk_requests()
		local can_place = surface.can_place_entity({
			name = "gas-power-station-1",
			position = {0, 0},
			force = "player",
		})
		add_case(
			storage.tgg_test.report,
			"runtime.surface." .. condition.name,
			"placement follows pressure condition at " .. condition.pressure,
			can_place == condition.expected,
			nil,
			{pressure = condition.pressure, expected = condition.expected, actual = can_place}
		)
	end
end

local function create_test_world()
	local report = copy_staged_report()
	if not report then return end

	storage.tgg_test = {report = report, setups = {}, started_tick = game.tick}
	report.runtime_creation = {
		tick = game.tick,
		vanilla_fluid_fuel_values = settings.startup["vanilla-fluid-fuel-values"].value,
		fluid_fuel_values = {
			["petroleum-gas"] = prototypes.fluid["petroleum-gas"].fuel_value,
			["light-oil"] = prototypes.fluid["light-oil"].fuel_value,
			["heavy-oil"] = prototypes.fluid["heavy-oil"].fuel_value,
			["crude-oil"] = prototypes.fluid["crude-oil"].fuel_value,
		},
	}
	local surface = game.surfaces.nauvis
	surface.request_to_generate_chunks({0, 0}, 8)
	surface.force_generate_chunk_requests()

	local tier_count = tonumber(settings.startup["generator-tiers"].value)
	for tier = 1, tier_count do
		create_generator_setup(
			surface,
			"runtime.tier." .. tier,
			"gas-power-station-" .. tier,
			{x = 20 * (tier - 1), y = 0},
			"petroleum-gas",
			true
		)
	end

	for index, fluid_name in ipairs({"petroleum-gas", "light-oil", "heavy-oil", "crude-oil"}) do
		create_generator_setup(
			surface,
			"runtime.fuel." .. fluid_name,
			"gas-power-station-1",
			{x = 20 * (index - 1), y = 20},
			fluid_name,
			true
		)
	end

	create_generator_setup(surface, "runtime.nonfuel.water", "gas-power-station-1", {x = 0, y = 40}, "water", true)
	create_generator_setup(surface, "runtime.no-demand", "gas-power-station-1", {x = 20, y = 40}, "petroleum-gas", false)
	create_generator_setup(surface, "runtime.no-fluid", "gas-power-station-1", {x = 40, y = 40}, nil, true)

	create_surface_condition_cases()
	write_report()
end

local function sample_test_world()
	if not storage.tgg_test or storage.tgg_test.evaluated then return end
	for _, setup in ipairs(storage.tgg_test.setups) do
		local generator = setup.generator
		if generator and generator.valid then
			setup.peak_generated = math.max(setup.peak_generated or 0, generator.energy_generated_last_tick)
		end
	end
end
local function evaluate_test_world()
	if not storage.tgg_test or storage.tgg_test.evaluated then return end
	local report = storage.tgg_test.report

	for _, setup in ipairs(storage.tgg_test.setups) do
		local generator = setup.generator
		local generated_last_tick = generator and generator.valid and generator.energy_generated_last_tick or 0
		local generated = math.max(setup.peak_generated or 0, generated_last_tick)
		local fluid = generator and generator.valid and generator.fluidbox[1] or nil
		local status = generator and generator.valid and generator.status or nil
		local details = {
			generated_last_tick = generated_last_tick,
			peak_generated = generated,
			status = status,
			fluid = fluid,
			connected = generator and generator.valid and generator.is_connected_to_electric_network() or false,
		}

		if setup.id == "runtime.nonfuel.water" then
			add_case(report, setup.id, "water does not generate electricity", generated == 0, nil, details)
		elseif setup.id == "runtime.no-demand" then
			add_case(report, setup.id, "a fueled generator without demand stays idle", generated_last_tick == 0, nil, details)
		elseif setup.id == "runtime.no-fluid" then
			add_case(report, setup.id, "a generator without fluid does not generate", generated == 0, nil, details)
		else
			local fuel_value = setup.fluid and prototypes.fluid[setup.fluid].fuel_value or 0
			local expected_to_work = fuel_value > 0
			add_case(
				report,
				setup.id,
				setup.id .. (expected_to_work and " generates electricity" or " cannot generate without a fluid fuel value"),
				(generated > 0) == expected_to_work,
				nil,
				{fuel_value = fuel_value, observation = details}
			)
		end
	end

	report.runtime = {
		evaluated_tick = game.tick,
		elapsed_ticks = game.tick - storage.tgg_test.started_tick,
		vanilla_fluid_fuel_values = settings.startup["vanilla-fluid-fuel-values"].value,
	}
	storage.tgg_test.evaluated = true
	write_report()
end

script.on_init(create_test_world)
script.on_configuration_changed(create_test_world)
script.on_nth_tick(1, sample_test_world)
script.on_nth_tick(60, function()
	if storage.tgg_test and not storage.tgg_test.evaluated
		and game.tick - storage.tgg_test.started_tick >= evaluation_tick then
		evaluate_test_world()
	end
end)
--#endregion








