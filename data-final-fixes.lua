-- Power Priority Updated creates alternate generator prototypes by appending a
-- priority suffix, but its deep copies retain the original next_upgrade target.
-- Keep upgrades inside the same priority family so prototype masks and the
-- selected power priority remain consistent across tiers.
if mods["PowerPriorityUpdated"] then
	local generators = data.raw.generator or {}
	local priority_suffixes = {
		"-POWER-PRIORITY-PRIMARY",
		"-POWER-PRIORITY-SECONDARY",
	}

	for tier = 1, 6 do
		local original_name = "gas-power-station-" .. tier
		local original = generators[original_name]

		for _, suffix in ipairs(priority_suffixes) do
			local alternate = generators[original_name .. suffix]
			if alternate then
				-- Priority variants are runtime replacements for the original entity and
				-- must therefore obey the same placement and collision restrictions.
				alternate.collision_mask = original.collision_mask
					and table.deepcopy(original.collision_mask)
					or nil

				local alternate_upgrade = original.next_upgrade
					and generators[original.next_upgrade .. suffix]
					and (original.next_upgrade .. suffix)
					or nil
				alternate.next_upgrade = alternate_upgrade
			end
		end
	end
end

--#region debug
local test_mode = settings.startup["tiered-gas-generator-test-mode"]

if test_mode and test_mode.value then
	local profile = {}
	local ok, loaded_profile = pcall(require, "tools.test.profile")
	if ok and type(loaded_profile) == "table" then
		profile = loaded_profile
	end

	local test_load = table.deepcopy(data.raw["electric-energy-interface"]["electric-energy-interface"])
	test_load.name = "tiered-gas-generator-test-load"
	test_load.localised_name = "Tiered Gas Generator test load"
	test_load.hidden = true
	test_load.minable = nil
	test_load.collision_box = {{-0.4, -0.4}, {0.4, 0.4}}
	test_load.selection_box = {{-0.5, -0.5}, {0.5, 0.5}}
	test_load.energy_source = {
		type = "electric",
		buffer_capacity = "1MJ",
		usage_priority = "secondary-input",
		input_flow_limit = "1GW",
		output_flow_limit = "0W",
	}
	test_load.energy_production = "0W"
	test_load.energy_usage = "1GW"
	test_load.gui_mode = "none"
	test_load.picture = {
		filename = "__core__/graphics/empty.png",
		width = 1,
		height = 1,
	}

	local runner = require("tools.test.runner")
	data:extend({
		test_load,
		{
			type = "mod-data",
			name = "tiered-gas-generator-test-report",
			data_type = "tiered-gas-generator-test-report/v1",
			data = runner.run(profile),
		},
	})
end
--#endregion
