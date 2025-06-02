-- for _, force in pairs(game.forces) do
--   local technologies = force.technologies
--   local recipes = force.recipes

--   if mods["upgraded_gas-generatorUpdated"] then
--     recipes["gas-generator"].enabled     = technologies["gas-power-station-1"].researched
--     recipes["mk1-gas-generator"].enabled = technologies["gas-power-station-2"].researched
--     recipes["mk2-gas-generator"].enabled = technologies["gas-power-station-3"].researched
--     recipes["mk3-gas-generator"].enabled = technologies["gas-power-station-4"].researched

--     if technologies["upgraded-gas-generators"].researched then
--       recipes["gas-power-station-1"].enabled = true
--     end
--     if technologies["upgraded-gas-generators-mk1"].researched then
--       recipes["gas-power-station-2"].enabled = true
--     end
--     if technologies["upgraded-gas-generators-mk2"].researched then
--       recipes["gas-power-station-3"].enabled = true
--     end
--     if technologies["upgraded-gas-generators-mk3"].researched then
--       recipes["gas-power-station-4"].enabled = true
--     end
--   end
-- end

--//TODO use control.lua