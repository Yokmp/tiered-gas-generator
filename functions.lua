-- Freeware modding by Adamo
require("util")

local max_tiers = settings.startup["generator-tiers"].value
local fuel_config = require("fuel-config")


---divide energy by given argument, return energy string
---@param energy string
---@param div number
---@return string|nil
function energy_div(energy, div)
	if type(energy) ~= "string" or type(div) ~= "number" or div <= 0 then return nil end
	local num = energy:match "[0-9%.]+"
	local alpha = energy:match "%a+"
	if not num or not alpha then return nil end
	num = num/div
	return (num..alpha)
end


local function has_positive_fuel_value(prototype)
	local fuel_value = prototype and prototype.fuel_value
	if type(fuel_value) ~= "string" then return false end
	local ok, parsed = pcall(util.parse_energy, fuel_value)
	return ok and parsed and parsed > 0
end


---returns the fuel value of the first reference_item it finds
---@return string|nil
---@return string|nil
function get_fluid_fuel_reference()
	for _, item_name in ipairs(fuel_config.reference_items) do
		local item = check_item(data.raw.item[item_name])
		if item and has_positive_fuel_value(item) then
			return get_fuel_value(item), item_name
		end
	end
	return nil, nil
end


function get_fluid_fuel_config()
	return fuel_config
end


local function source_is_enabled(source_name, source)
	if source_name ~= "base" and not mods[source_name] then return false end
	if source.startup_setting then
		local setting = settings.startup[source.startup_setting]
		return setting and setting.value == true
	end
	return true
end


local function apply_fluid_fuel_source(source_name, reference_value)
	local source = fuel_config.sources[source_name]
	if not source or not source_is_enabled(source_name, source) then return {} end

	local applied = {}
	for canonical_name, fluid_name in pairs(source.fluids) do
		local divisor = fuel_config.fuelfactors[canonical_name]
		local prototype_name = source.prefix .. fluid_name
		local fluid = check_fluid(data.raw.fluid[prototype_name])
		if fluid and divisor and not has_positive_fuel_value(fluid) then
			local fuel_value = energy_div(reference_value, divisor)
			if fuel_value then
				apply_fluid_fuel_stat(fluid, fuel_value)
				applied[prototype_name] = fuel_value
			end
		end
	end
	return applied
end


---Applies configured fuel values to vanilla petroleum fluids when the
---vanilla-fluid-fuel-values startup setting is enabled. The optional reference
---value overrides the automatic solid-fuel, coal, then wood lookup.
---@param reference_value? string Energy value such as "12MJ"
---@return table<string, string>|false applied Prototype names mapped to their assigned fuel values, or false when no reference fuel exists
function apply_vanilla_fluid_fuel_stats(reference_value)
	reference_value = reference_value or get_fluid_fuel_reference()
	if not reference_value then return false end
	return apply_fluid_fuel_source("base", reference_value)
end


---Applies configured fuel values to fluids provided by active compatible mods.
---Prototype names are resolved through the prefixes and aliases in fuel-config;
---fluids that already have a positive fuel value are left unchanged. The
---optional reference value overrides the automatic solid-fuel, coal, then wood
---lookup.
---@param reference_value? string Energy value such as "12MJ"
---@return table<string, string>|false applied Prototype names mapped to their assigned fuel values, or false when no reference fuel exists
function apply_mod_fluid_fuel_stats(reference_value)
	reference_value = reference_value or get_fluid_fuel_reference()
	if not reference_value then return false end

	local applied = {}
	for source_name in pairs(fuel_config.sources) do
		if source_name ~= "base" then
			for prototype_name, fuel_value in pairs(apply_fluid_fuel_source(source_name, reference_value)) do
				applied[prototype_name] = fuel_value
			end
		end
	end
	return applied
end


function apply_fluid_fuel_stat(fluid, fuel_value, fuel_type)
	fluid 		 = check_fluid(fluid)
	fuel_value = check_string(fuel_value)
	if not fluid or not fuel_value then return nil end
	fuel_type  = check_string(fuel_type)
	fluid.fuel_category = fuel_type
	fluid.fuel_value 		= fuel_value
	return fluid
end


---returns the fuel value or 0 if the fluid has none
---@param prototype table|string|nil
---@return string
function get_fuel_value(prototype)
	prototype = check_table(prototype) or {}
	local fuel_value = "0J"
	if not prototype then return fuel_value end
	if prototype.type == "fluid" or prototype.type == "item" then
		fuel_value = prototype.fuel_value
	end
	if type(fuel_value) ~= "string" then return "0J" end
	return fuel_value
end


---Returns the value if value matches given type
---@param value any
---@param vtype string
---@return string|nil
function get_ifType(value, vtype)
	if type(value) == vtype then
		return value
	end
	return nil
end
function check_table(prototype)
	return get_ifType(prototype, "table")
end
function check_string(string)
	return get_ifType(string, "string")
end

---returns the argument if the argument is a fluid
---@param prototype table|string
---@return any
function check_fluid(prototype)
	if type(prototype) == "table"	and prototype.type == "fluid" then
		return prototype
	end
	if type(prototype) == "string" then
		prototype = check_fluid(data.raw.fluid[prototype])
		return prototype
	end
	return prototype
end

---returns the argument if the argument is an item
---@param prototype table|string
---@return any
function check_item(prototype)
	if type(prototype) == "table" and prototype.type == "item" then
		return prototype
	end
	if type(prototype) == "string" then
		prototype = check_item(data.raw.item[prototype])
		return prototype
	end
	return prototype
end

---returns an icons table
---@param tint table
---@return table
function add_tier_icons(tier, tint)
local icons = {}
	if settings.startup["use-tier-icons"].value then
		-- local tiers = settings.startup["generator-tiers"].value
		local icon_filename = "__tiered-gas-generator__/graphics/icons/tier.png"
		icons = {}
		local x,y =  12,18
		for i = 1, tier, 1 do
			if i == 4 then
				x = x - 6
				y = y + 30
			end
			icons[i] = {
				icon = icon_filename,
				icon_size = 12,
				scale = 0.5,
				shift = {x , y - i*10 },
				-- tint = tint[i]
			}
		end
	end
	return icons
end
