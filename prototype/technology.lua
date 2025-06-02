function _technology(prefix, tint, tier, tiers, power, hidden)
  local prerequisites = { --TODO: 
    {"oil-gathering"},
    {"gas-power-station-1", "electric-engine"},
    {"gas-power-station-2", "chemical-science-pack"},
    {"gas-power-station-3", "advanced-oil-processing"},
  }

  local ingredients = {
    {
      {"automation-science-pack", 1},{"logistic-science-pack", 1}
    },
    {
      {"automation-science-pack", 1},{"logistic-science-pack", 1},{"chemical-science-pack", 1}
    },
    {
      {"automation-science-pack", 1},{"logistic-science-pack", 1},{"chemical-science-pack", 1},{"production-science-pack", 1}
    },
    {
      {"automation-science-pack", 1},{"logistic-science-pack", 1},{"chemical-science-pack", 1},{"production-science-pack", 1},{"utility-science-pack", 1}
    },
  }

  local unit = {
    ingredients = tier <= tiers and ingredients[tier] or ingredients[4],
    count = 100*tier,
    time = 10+10*tier,
  }


  local technology = {
    type = "technology",
    name = prefix..tier,
    localised_name = {"", {"entity-name.gas-power-station", " ", tostring(tier)}},
    localised_description = {"", {"technology-description.gas-power-station", tostring(power)}},
    icons = {
      {
        icon = "__tiered-gas-generator__/graphics/tech/gas-power-station-1.png",
        icon_size = 128,
      },
      {
        icon = "__tiered-gas-generator__/graphics/tech/gas-power-station-mask.png",
        icon_size = 128,
        tint = tint
      }
    },
    enabled = true,
		hidden = hidden,
    effects = {
      {
          type = "unlock-recipe",
          recipe = prefix..tier
      }
    },
    prerequisites = tier <= tiers and prerequisites[tier] or {prefix..(tier-1)},
    unit = unit
  }

  return technology
end

