
function _item(name, tint)
	local item = {
		type = "item",
		name = name,
		icons = {
			{
				icon = "__tiered-gas-generator__/graphics/icons/gas-power-station-1.png",
				icon_size = 64,
			},
			{
				icon = "__tiered-gas-generator__/graphics/icons/gas-power-station-mask.png",
				icon_size = 64,
				tint = tint
			}
		},
		flags = {},
		subgroup = "energy",
		order = "b[steam-power]-d["..name.."]",
		place_result = ""..name,
		stack_size = 10,
		weight = 100*kg,
	}
	return item
end
