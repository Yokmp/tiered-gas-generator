-- Freeware modding by Adamo
require("util")

local max_tiers = settings.startup["generator-tiers"].value


local fuelfactors = { -- they are actually divisors
	-- topower 						=   0.0166666667,
	-- ["coal"] 					=   3.0,
	["petroleum-gas"] 		=  1.0,
	["light-oil"] 				=  1.5,
	["heavy-oil"] 				=  2.0,
	["crude-oil"] 				=  3.0,
	["methane"] 					=  0.5,
	["syngas"] 						=  0.33, --methane*2
--	["diesel-fuel"]				= 100.0,
--	["se-methane-gas"]		= 100.0,
}


---divide energy by given argument, return energy string
---@param energy string
---@param div number
---@return string
function energy_div(energy, div)
	local num = energy:match "[0-9%.]+"
	local alpha = energy:match "%a+"
	num = num/div
	return (num..alpha)
end


function apply_vanilla_fluid_fuel_stats()
	local solid_fuel = check_item(data.raw.item["solid-fuel"])
	if not solid_fuel then return false end

	local solid_fuel_value = get_fuel_value(solid_fuel)

	for k,v in pairs(fuelfactors) do
		apply_fluid_fuel_stat(k, energy_div(solid_fuel_value, v))
	end

	-- apply_fluid_fuel_stat("light-oil", 		 energy_div(solid_fuel_value, fuelfactors["light-oil"]))
	-- apply_fluid_fuel_stat("heavy-oil", 		 energy_div(solid_fuel_value, fuelfactors["heavy-oil"]))
	-- apply_fluid_fuel_stat("petroleum-gas", energy_div(solid_fuel_value, fuelfactors["petroleum-gas"]))
	-- apply_fluid_fuel_stat("crude-oil",		 energy_div(solid_fuel_value, fuelfactors["crude-oil"]))
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