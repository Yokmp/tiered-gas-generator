---@diagnostic disable-next-line: assign-type-mismatch
local recycle = settings.startup["recycle-previous-tiers"].value ---@type boolean

function _recipe(prefix, tier, hidden)
  local recipe = {
    type = "recipe",
    name = prefix..tier,
		hidden = hidden,
    localised_description = {"", {"entity-description.gas-power-station"}},
    energy_required = 5,
    -- category = "crafting-with-fluid",
    enabled = false,
    ingredients = {
      {type = "item", name = "steel-plate", amount = 10},
      {type = "item", name = "engine-unit", amount =  2},
      {type = "item", name = "electronic-circuit", amount =  4},
      {type = "item", name = "pipe", amount =  4},
    },
    results = {
      {type = "item", name = prefix..tier, amount=1}
    }
  }
  if recycle then
    recipe.ingredients[5] = tier-1 > 0 and {type = "item", name = prefix..tostring(tier-1), amount=1} or nil
  end
  return recipe
end
