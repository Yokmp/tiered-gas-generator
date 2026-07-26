

local hit_effects = require("__base__/prototypes/entity/hit-effects")       ---@diagnostic disable-line:different-requires
local sounds = require("__base__.prototypes.entity.sounds")
local power = settings.startup["generator-power"].value

local function animation(tint)
  return {
    layers = {
      {
        filename = "__tiered-gas-generator__/graphics/entity/hr-gas-power-station.png",
        width = 380,
        height = 380,
        scale = 0.5,
        frame_count = 32,
        line_length = 8,
        animation_speed = 1.2,
        shift = { 0, 0 },
      },
      {
        filename = "__tiered-gas-generator__/graphics/entity/hr-gas-power-station-mask.png",
        width = 380,
        height = 380,
        scale = 0.5,
        repeat_count = 32,
        tint = tint,
      },
      {
        filename = "__tiered-gas-generator__/graphics/entity/pipe-patch/hr-pipe-patch.png",
        width = 55,
        height = 50,
        frame_count = 1,
        repeat_count = 32,
        scale = 0.5,
        shift = { 0, 2.5 },
      },
      {
        filename = "__tiered-gas-generator__/graphics/entity/hr-gas-power-station-sh.png",
        width = 380,
        height = 380,
        scale = 0.5,
        frame_count = 1,
        repeat_count = 32,
        animation_speed = 1.2,
        draw_as_shadow = true,
        shift = { 0, 0 },
      },
    },
  }
end

local empty_sprite = {
  filename = "__core__/graphics/empty.png",
  priority = "extra-high",
  width = 1,
  height = 1,
}

local pipe_path = {
  north = empty_sprite,
  east = empty_sprite,
  south = {
    filename = "__tiered-gas-generator__/graphics/entity/pipe-patch/hr-pipe-patch.png",
    priority = "high",
    width = 55,
    height = 50,
    scale = 0.5,
    shift = { 0.01, -0.58 },
  },
  west = empty_sprite,
}


local smoke = {
  type = "trivial-smoke",
  name = "gas-power-station-smoke",
  duration = 300,
  fade_in_duration = 0,
  fade_away_duration = 180,
  spread_duration = 400,
  start_scale = 0.17,
  end_scale = 1.15,
  color = { r = 0.25, g = 0.25, b = 0.25, a = 0.75 },
  cyclic = true,
  affected_by_wind = true,
  animation = {
    width = 152,
    height = 120,
    line_length = 5,
    frame_count = 60,
    shift = { -0.53125, -0.4375 },
    priority = "high",
    animation_speed = 0.25,
    filename = "__tiered-gas-generator__/graphics/entity/smoke.png",
    flags = { "smoke" },
  },
}

data:extend({smoke})


function _entity(prefix, tint, tier, tiers, usage_priority)
  local name = prefix..tier
  local entity = {
    type = "generator",
    name = name,
    localised_name = {"", {"entity-name.gas-power-station"}, " ", tostring(tier)},
    localised_description = {"", {"entity-description.gas-power-station"}},
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
    flags = { "placeable-neutral", "player-creation" },
    fast_replaceable_group = "gas-power-station",
    next_upgrade = tier+1 <= tiers and prefix..(tier+1) or nil,
    minable = { mining_time = 0.5, result = prefix..tier},
    max_health = 750,
    corpse = "big-remnants",
    dying_explosion = "medium-explosion",
    is_military_target = true,
    fluid_usage_per_tick = 1 / 10,
    maximum_temperature = 25,
    burns_fluid = true,
    scale_fluid_usage = true,
    destroy_non_fuel_fluid = false,
    effectivity = tier,
    resistances = {
      { type = "physical", percent = 25 },
      { type = "fire", percent = 75 },
      { type = "impact", percent = 50 },
    },
    collision_box = { { -2.3, -2.3 }, { 2.3, 2.3 } },
    selection_box = { { -2.5, -2.5 }, { 2.5, 2.5 } },
    damaged_trigger_effect = hit_effects.entity(),

    fluid_box =
    {
      volume = 100,
      pipe_covers = pipecoverspictures(),
      pipe_picture = pipe_path,
      pipe_connections =
      {
        { direction = defines.direction.north, position = {0, -2} },
        { direction = defines.direction.east, position = {2, 0} },
        { direction = defines.direction.south, position = {0, 2} },
        { direction = defines.direction.west, position = {-2, 0} }
      },
      hide_connection_info = false
    },

    energy_source = {
      type = "electric",
      usage_priority = usage_priority,
      emissions_per_minute = { pollution = 30 },
      render_no_network_icon = true,
      output_flow_limit = power*tier.."MW",
      -- buffer_capacity = "5MJ",
    },
    horizontal_animation = animation(tint),
    vertical_animation = animation(tint),
    smoke = {
      {
        name = "gas-power-station-smoke",
        north_position = util.by_pixel(47, -88),
        south_position = util.by_pixel(47, -88),
        east_position = util.by_pixel(47, -88),
        west_position = util.by_pixel(47, -88),
        frequency = 0.350,
        starting_vertical_speed = 0.05,
        slow_down_factor = 1,
        starting_frame_deviation = 60,
      },
    },
    vehicle_impact_sound = sounds.generic_impact,
    working_sound = {
      sound = {
        variations = {
          {
            filename = "__tiered-gas-generator__/sounds/gas-power-station-1.ogg",
            volume = 0.8,
          },
          {
            filename = "__tiered-gas-generator__/sounds/gas-power-station-2.ogg",
            volume = 0.75,
          },
        },
        aggregation = {
          max_count = 3,
          remove = false,
          count_already_playing = true,
        },
      },
      match_speed_to_activity = true,
      max_sounds_per_type = 3,
      fade_in_ticks = 10,
      fade_out_ticks = 30,
    },

    water_reflection = {
      pictures = {
        filename = "__tiered-gas-generator__/graphics/entity/gas-power-station-reflection.png",
        priority = "extra-high",
        width = 42,
        height = 38,
        shift = util.by_pixel(0, 40),
        variation_count = 1,
        scale = 5,
      },
      rotate = false,
      orientation_to_variation = false,
    },

    audible_distance_modifier = 5,
    -- min_perceived_performance = 0.25,
    performance_to_sound_speedup = 0.5,
    max_power_output = power*tier.."MW",
  }

  return entity
end
