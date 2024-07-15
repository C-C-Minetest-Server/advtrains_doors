-- advtrains_doors/src/api.lua
-- API for registering gates
--[[
    advtrains_doors: Platform screen doors for Advtrains
    Copyright (C) 2024  1F616EMO

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as
    published by the Free Software Foundation, either version 3 of the
    License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
]]

local _ad = advtrains_doors
local _int = _ad.internal
local logger = _int.logger:sublogger("api")

local S = _int.S

-- These are from door shutters of cottages
local gate_closed_box = {
    type = "fixed",
    fixed = {
        { -0.5, -0.5, 7 / 16 - 1 / 64, -0.05, 0.5, 0.5 - 1 / 64 },
        { 0.05, -0.5, 7 / 16 - 1 / 64, 0.5,   0.5, 0.5 - 1 / 64 },
    },
}
local gate_opened_box = {
    type = "fixed",
    fixed = {
        { -0.90, -0.5, 7 / 16 - 1 / 64, -0.45, 0.5, 0.5 - 1 / 64 },
        { 0.45,  -0.5, 7 / 16 - 1 / 64, 0.9,   0.5, 0.5 - 1 / 64 },
    },
}
local gate_fixed_box = {
    type = "fixed",
    fixed = {
        { -0.5, -0.5, 0.4, 0.5, 0.5, 0.5 },
    },
}

-- Modified from above
local double_gate_closed_box = {
    type = "fixed",
    fixed = {
        { -0.5, -0.5, 7 / 16 - 1 / 64, -0.05, 1.5, 0.5 - 1 / 64 },
        { 0.05, -0.5, 7 / 16 - 1 / 64, 0.5,   1.5, 0.5 - 1 / 64 },
    },
}
local double_gate_opened_box = {
    type = "fixed",
    fixed = {
        { -0.90, -0.5, 7 / 16 - 1 / 64, -0.45, 1.5, 0.5 - 1 / 64 },
        { 0.45,  -0.5, 7 / 16 - 1 / 64, 0.9,   1.5, 0.5 - 1 / 64 },
    },
}

local mese, steel
if minetest.get_modpath("default") then
    mese = "default:mese_crystal_fragment"
    steel = "default:steel_ingot"
elseif minetest.get_modpath("mcl_core") and minetest.get_modpath("mesecons_wires") then
    mese = "mesecons:redstone"
    steel = "mcl_core:iron_ingot"
else
    logger:warning("No compactible game found, no crafting recipies will be registered.")
end

local keep_groups = {
    -- General groups
    "not_in_creative_inventory",

    -- Minetest Game dig groups
    "crumbly", "cracky", "snappy", "choppy", "fleshy", "explody", "oddly_breakable_by_hand", "dig_immediate",

    -- MineClone2 dig groups
    "pickaxey", "axey", "shovely", "swordly", "shearsy", "handy", "creative_breakable",

    -- MineClone2 interaction groups
    "flammable", "fire_encouragement", "fire_flammability",
}
local function prepare_groups(groups)
    if not groups then return {} end

    local rtn = {}
    for _, key in ipairs(keep_groups) do
        rtn[key] = groups[key]
    end
    return rtn
end

minetest.register_node("advtrains_doors:platform_screen_upper", {
    drawtype = "airlike",
    paramtype = "light",
    drop = "",
    walkable = false,
    pointable = false,
    diggable = true,
    sunlight_propagates = true,
    is_ground_content = false,
    groups = {
        not_in_creative_inventory = 1,
        not_blocking_trains = 1
    },
})

local function screen_on_construct(pos)
    pos.y = pos.y + 1
    local node = minetest.get_node(pos)
    if node and node.name == "air" then
        node.name = "advtrains_doors:platform_screen_upper"
        minetest.set_node(pos, node)
    end
end

local function screen_on_destruct(pos)
    pos.y = pos.y + 1
    local node = minetest.get_node(pos)
    if node and node.name == "advtrains_doors:platform_screen_upper" then
        minetest.remove_node(pos)
    end
end

on_rotate = minetest.global_exists("screwdriver") and screwdriver.rotate_simple or nil

function _ad.register_platform_gate(node_name)
    local node_def = logger:assert(minetest.registered_nodes[node_name],
        "Node " .. node_name .. " not found!")

    local description = node_def.short_description or node_def.description or node_name

    local groups = prepare_groups(node_def.groups)
    groups.not_blocking_trains = 1
    local groups_for_gate = table.copy(groups)
    groups_for_gate.advtrains_doors = 1

    local tiles = node_def.tiles
    if node_def.drawtype == "glasslike_framed_optional" then
        tiles = { tiles[1] }
    end

    -- Closed gate
    minetest.register_node(":" .. node_name .. "_platform_gate", {
        description = S("@1 Platform Gate", description),

        drawtype = "nodebox",
        tiles = tiles,
        use_texture_alpha = node_def.use_texture_alpha,
        paramtype = "light",
        paramtype2 = "facedir",
        node_box = gate_closed_box,
        selection_box = gate_closed_box,
        on_rotate = on_rotate,

        groups = groups_for_gate,
        sounds = node_def.sounds,
        sunlight_propagates = true,
        is_ground_content = false,

        _advtrains_doors_state = "closed",
        _advtrains_doors_counterpart = node_name .. "_platform_gate_opened",
    })

    -- Opened gate - not obtainable
    minetest.register_node(":" .. node_name .. "_platform_gate_opened", {
        drawtype = "nodebox",
        tiles = tiles,
        use_texture_alpha = node_def.use_texture_alpha,
        paramtype = "light",
        paramtype2 = "facedir",
        node_box = gate_opened_box,
        selection_box = gate_opened_box,
        on_rotate = on_rotate,

        groups = groups_for_gate,
        sounds = node_def.sounds,
        sunlight_propagates = true,
        is_ground_content = false,
        drop = node_name .. "_platform_gate",

        _advtrains_doors_state = "opened",
        _advtrains_doors_counterpart = node_name .. "_platform_gate",
    })

    -- Fixed gate - won't open
    minetest.register_node(":" .. node_name .. "_platform_gate_fixed", {
        description = S("@1 Platform Gate (Fixed)", description),

        drawtype = "nodebox",
        tiles = tiles,
        use_texture_alpha = node_def.use_texture_alpha,
        paramtype = "light",
        paramtype2 = "facedir",
        node_box = gate_fixed_box,
        selection_box = gate_fixed_box,
        on_rotate = on_rotate,

        groups = groups, -- NO advtrains_doors
        sounds = node_def.sounds,
        sunlight_propagates = true,
        is_ground_content = false,
    })

    -- Closed screen
    minetest.register_node(":" .. node_name .. "_platform_screen", {
        description = S("@1 Platform Screen Door", description),

        drawtype = "nodebox",
        tiles = tiles,
        use_texture_alpha = node_def.use_texture_alpha,
        paramtype = "light",
        paramtype2 = "facedir",
        node_box = double_gate_closed_box,
        selection_box = double_gate_closed_box,
        on_rotate = on_rotate,

        groups = groups_for_gate,
        sounds = node_def.sounds,
        sunlight_propagates = true,
        is_ground_content = false,

        _advtrains_doors_state = "closed",
        _advtrains_doors_counterpart = node_name .. "_platform_screen_opened",

        on_construct = screen_on_construct,
        on_destruct = screen_on_destruct,
    })

    -- Opened screen
    minetest.register_node(":" .. node_name .. "_platform_screen_opened", {
        drawtype = "nodebox",
        tiles = tiles,
        use_texture_alpha = node_def.use_texture_alpha,
        paramtype = "light",
        paramtype2 = "facedir",
        node_box = double_gate_opened_box,
        selection_box = double_gate_opened_box,
        on_rotate = on_rotate,

        groups = groups_for_gate,
        sounds = node_def.sounds,
        sunlight_propagates = true,
        is_ground_content = false,
        drop = node_name .. "_platform_screen",

        _advtrains_doors_state = "opened",
        _advtrains_doors_counterpart = node_name .. "_platform_screen",

        on_construct = screen_on_construct,
        on_destruct = screen_on_destruct,
    })

    -- fixed screen (just use two fixed gates!)

    if mese and steel then
        -- Crafting recipie for gate
        minetest.register_craft({
            output = node_name .. "_platform_gate 4",
            recipe = {
                { node_name, mese, node_name }
            }
        })

        -- Crafting recipe for fixed
        minetest.register_craft({
            output = node_name .. "_platform_gate_fixed 4",
            recipe = {
                { node_name, steel, node_name }
            }
        })
    end

    -- Crafting recipe for screen
    minetest.register_craft({
        type = "shapeless",
        output = node_name .. "_platform_screen",
        recipe = { node_name .. "_platform_gate", node_name .. "_platform_gate" }
    })

    -- screen back to recipe
    minetest.register_craft({
        type = "shapeless",
        output = node_name .. "_platform_gate 2",
        recipe = { node_name .. "_platform_screen" }
    })
end
