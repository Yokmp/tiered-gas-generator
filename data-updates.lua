require("functions")
if settings.startup["vanilla-fluid-fuel-values"].value then
	apply_vanilla_fluid_fuel_stats()
end

--[[ 
	If you want to add another mod and don't want to use the preset values then 
	please remember that each value is a string like "600KJ" or "0.6MJ"
]]

local fluid_value = data.raw.fluid["light-oil"].fuel_value
local gas_value = data.raw.fluid["petroleum-gas"].fuel_value

if mods["KS_Power"] then
	if not data.raw.fluid["diesel-fuel"].fuel_value then
		data.raw.fluid["diesel-fuel"].fuel_value = fluid_value
	end
end

if mods["space-exploration"] then
	if not data.raw.fluid["se-methane-gas"].fuel_value then
		data.raw.fluid["se-methane-gas"].fuel_value = gas_value
	end
end