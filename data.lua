-- disable the reskins warning:
---@diagnostic disable: undefined-global

local max_tiers,tier,prefix,name,hidden,tint = 6,1,"gas-power-station-",nil,true,nil
local entity,item,recipe,technology,icon_style

local tiers = tonumber(settings.startup["generator-tiers"].value)
local scheme = tostring(settings.startup["color-scheme"].value)

local tints = {
	midnightxrush = {
		{r=      0, g=      0, b=      0, a=0}, -- orange
		-- util.color("ff6419"),
		{r= 86/255, g=145/255, b= 41/255, a=1}, -- green
		{r= 40/255, g= 88/255, b=195/255, a=1}, -- blue
		{r=235/255, g=189/255, b= 65/255, a=1}, -- yellow
		{r= 88/255, g= 40/255, b=103/255, a=1},	-- purple
		-- {r= 45/255, g=229/255, b=189/255, a=1},	-- cyan/green
		{r=1,g=1,b=1,a=1}
		-- white / no tint  reskins.lib.adjust_alpha() will bug here
	},
	Vanilla = {
		-- {90, 98, 83}, --T1 assembler
		-- {40, 65, 96}, --T2 assembler
		-- {118, 140, 52}, --T3 assembler
		-- {72, 71, 58}, --burner inserter
		-- {255, 197, 72}, --inserter
		-- {75, 172, 231}, --fast inserter
		-- {117, 180, 58}, --stack inserter
		-- {70, 118, 33}, --stack inserter
		-- {142, 107, 47}, --T1 splitter
		-- {147, 42, 40}, --T2 splitter
		-- {89, 164, 197}--T3 splitter
		{r=235/255, g=189/255, b= 65/255, a=1}, -- yellow
		{r=242/255, g= 35/255, b= 24/255, a=1}, -- red
		{r= 40/255, g= 88/255, b=195/255, a=1}, -- blue
		-- {r= 86/255, g=145/255, b= 41/255, a=1}, -- green
		{r= 190/255, g=210/255, b= 98/255, a=1}, -- green
		{r= 88/255, g= 40/255, b=103/255, a=1} 	-- purple
	},
	Artisanal_Reskin = mods["reskins-library"] and reskins.lib.tint_index or {
		util.color("808080"), -- 1.1.7: 4d4d4d
		util.color("ffb726"), -- 1.1.7: de9400
		util.color("f22318"), -- 1.1.7: c20600
		util.color("33b4ff"), -- 1.1.7: 0099ff, 1.1.0: 1b87c2
		util.color("b459ff"), -- 1.1.7: a600bf
		util.color("2ee55c"), -- 1.1.7: 16c746, 1.1.6: 23de55
		util.color("ff8533"), -- 1.1.7: ff7700
	},
}

tint = tints[scheme] ---@type table


require("functions")
require("prototype.entity")
require("prototype.item")
require("prototype.recipe")
require("prototype.technology")

if mods["reskins-library"] then -- https://github.com/kirazy/reskins-library/issues/5  shift by 1
	icon_style = settings.startup["reskins-lib-icon-tier-labeling-style"].value
	if scheme == "Artisanal_Reskin" then
		table.insert(tint, 0, false)
	end
end


function add_labels(icon_table, _tier) --tier icons
	local label = {
		icon = reskins.lib.directory.."/graphics/icons/tiers/"..icon_style.."/".._tier..".png",
		icon_size = 64,
		icon_mipmaps = 4,
	}
	local label_tint = {
		icon = reskins.lib.directory.."/graphics/icons/tiers/"..icon_style.."/".._tier..".png",
		icon_size = 64,
		icon_mipmaps = 4,
		-- tint = tint[_tier] and reskins.lib.adjust_alpha(tint[_tier], 0.75) or {0.66,0.66,0.66,0.75}
		tint = {0.66,0.66,0.66,0.75}
	}
	table.insert(icon_table, label)
	table.insert(icon_table, label_tint)
end


for i = 1, max_tiers do
	if i<=tiers then hidden = false else hidden = true end
  tier			 = i
	name 			 = prefix..tostring(tier)
	entity 		 = _entity(prefix, tint[tier], tier, tiers)
	item 			 = _item(name, tint[tier])
	recipe 		 = _recipe(prefix, tier, hidden)
	technology = _technology(prefix, tint[tier], tier, tiers, entity.max_power_output, hidden)

	if mods["space-age"] then
    entity.surface_conditions = { { property = "pressure", min = 800, max = 2000 } }
	end

	if mods["reskins-library"] and settings.startup["reskins-lib-icon-tier-labeling"].value then
		add_labels(item.icons, tier)
		add_labels(entity.icons, tier)
	elseif settings.startup["use-tier-icons"].value then
		local tier_icons = add_tier_icons(i, tint)
		-- log(serpent.block(tier_icons))
		for j = 1, tiers, 1 do
			item.icons[j+2] = tier_icons[j]
		end
	end
  data:extend({entity,item,recipe,technology})
end
