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
local gate_closed_extended_box = {
    type = "fixed",
    fixed = {
        { -0.5, -0.5, 7 / 16 - 1 / 64, -0.05, 13 / 16, 0.5 - 1 / 64 },
        { 0.05, -0.5, 7 / 16 - 1 / 64, 0.5,   13 / 16, 0.5 - 1 / 64 },
    },
}
local gate_opened_extended_box = {
    type = "fixed",
    fixed = {
        { -0.90, -0.5, 7 / 16 - 1 / 64, -0.45, 13 / 16, 0.5 - 1 / 64 },
        { 0.45,  -0.5, 7 / 16 - 1 / 64, 0.9,   13 / 16, 0.5 - 1 / 64 },
    },
}
local gate_fixed_extended_box = {
    type = "fixed",
    fixed = {
        { -0.5, -0.5, 0.4, 0.5, 13 / 16, 0.5 },
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
if core.get_modpath("default") then
    mese = "default:mese_crystal_fragment"
    steel = "default:steel_ingot"
elseif core.get_modpath("mcl_core") and core.get_modpath("mesecons_wires") then
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

core.register_node("advtrains_doors:platform_screen_upper", {
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
local advtrains_allow_build_to_owner = core.settings:get_bool("advtrains_allow_build_to_owner")
local function is_protected_advt(pos, name)
    local privs = core.get_player_privs(name)
    if privs.protection_bypass then return true end
    if advtrains_allow_build_to_owner and core.is_protected(pos) and not core.is_protected(pos, name) then
        return true
    end
    if privs.track_builder then return true end
    return false
end

local force_open_time = tonumber(core.settings:get("advtrains_doors.force_open_time")) or 4
local function door_on_rightclick(pos, node, player, itemstack, pointed_thing)
    if not player:is_player() then return itemstack end
    if not pointed_thing or pointed_thing.type ~= "node" then return itemstack end
    local facedir = core.facedir_to_dir(node.param2)

    if not vector.equals(pointed_thing.above, vector.subtract(pos, facedir)) then
        local pname = player:get_player_name()
        if core.is_protected(pos, pname) then
            core.chat_send_player(pname, S("You're not allowed to forcefully open platform dooors!"))
            return itemstack
        end
    end

    advtrains_doors.force_open_door(pos, force_open_time)
    return itemstack
end

local function screen_on_construct(pos)
    pos.y = pos.y + 1
    local node = core.get_node(pos)
    if node and node.name == "air" then
        node.name = "advtrains_doors:platform_screen_upper"
        core.set_node(pos, node)
    end
end

local function screen_on_destruct(pos)
    pos.y = pos.y + 1
    local node = core.get_node(pos)
    if node and node.name == "advtrains_doors:platform_screen_upper" then
        core.remove_node(pos)
    end
end

local on_rotate = core.global_exists("screwdriver") and screwdriver.rotate_simple or nil

local function create_extended_texture(tiles)
    local new_tiles = {}
    for i, tile in ipairs(tiles) do
        new_tiles[i] = string.format(
            "%s^%s",
            tile,
            "advtrains_door_extended_gate_bkg.png"
        )
    end
    return new_tiles
end

function _ad.register_platform_gate(node_name)
    local node_def = logger:assert(core.registered_nodes[node_name],
        "Node " .. node_name .. " not found!")

    local description = node_def.short_description or node_def.description or node_name

    local groups = prepare_groups(node_def.groups)
    groups.not_blocking_trains = 1
    local groups_for_gate_closed = table.copy(groups)
    groups_for_gate_closed.advtrains_doors = 1
    groups_for_gate_closed.advtrains_doors_closed = 1
    local groups_for_gate_opened = table.copy(groups)
    groups_for_gate_opened.advtrains_doors = 1
    groups_for_gate_opened.advtrains_doors_opened = 1

    local tiles = node_def.tiles
    if node_def.drawtype == "glasslike_framed_optional" then
        tiles = { tiles[1] }
    end

    -- Closed gate
    core.register_node(":" .. node_name .. "_platform_gate", {
        description = S("@1 Platform Gate", description),

        drawtype = "nodebox",
        tiles = tiles,
        use_texture_alpha = node_def.use_texture_alpha,
        paramtype = "light",
        paramtype2 = "facedir",
        node_box = gate_closed_box,
        selection_box = gate_closed_box,
        collision_box = gate_closed_extended_box,
        on_rotate = on_rotate,
        on_rightclick = door_on_rightclick,

        groups = groups_for_gate_closed,
        sounds = node_def.sounds,
        sunlight_propagates = true,
        is_ground_content = false,

        _advtrains_doors_state = "closed",
        _advtrains_doors_counterpart = node_name .. "_platform_gate_opened",
    })

    -- Opened gate - not obtainable
    core.register_node(":" .. node_name .. "_platform_gate_opened", {
        drawtype = "nodebox",
        tiles = tiles,
        use_texture_alpha = node_def.use_texture_alpha,
        paramtype = "light",
        paramtype2 = "facedir",
        node_box = gate_opened_box,
        selection_box = gate_opened_box,
        collision_box = gate_opened_extended_box,
        on_rotate = on_rotate,
        on_rightclick = door_on_rightclick,

        groups = groups_for_gate_opened,
        sounds = node_def.sounds,
        sunlight_propagates = true,
        is_ground_content = false,
        drop = node_name .. "_platform_gate",

        _advtrains_doors_state = "opened",
        _advtrains_doors_counterpart = node_name .. "_platform_gate",
    })

    -- Fixed gate - won't open
    core.register_node(":" .. node_name .. "_platform_gate_fixed", {
        description = S("@1 Platform Gate (Fixed)", description),

        drawtype = "nodebox",
        tiles = tiles,
        use_texture_alpha = node_def.use_texture_alpha,
        paramtype = "light",
        paramtype2 = "facedir",
        node_box = gate_fixed_box,
        selection_box = gate_fixed_box,
        collision_box = gate_fixed_extended_box,
        on_rotate = on_rotate,

        groups = groups, -- NO advtrains_doors
        sounds = node_def.sounds,
        sunlight_propagates = true,
        is_ground_content = false,
    })

    local extended_tiles = create_extended_texture(tiles)

    -- Closed extended gate
    core.register_node(":" .. node_name .. "_platform_gate_extended", {
        description = S("@1 Platform Gate (Extended)", description),

        drawtype = "nodebox",
        tiles = extended_tiles,
        use_texture_alpha = node_def.use_texture_alpha,
        paramtype = "light",
        paramtype2 = "facedir",
        node_box = gate_closed_extended_box,
        selection_box = gate_closed_extended_box,
        on_rotate = on_rotate,
        on_rightclick = door_on_rightclick,

        groups = groups_for_gate_closed,
        sounds = node_def.sounds,
        sunlight_propagates = true,
        is_ground_content = false,

        _advtrains_doors_state = "closed",
        _advtrains_doors_counterpart = node_name .. "_platform_gate_extended_opened",
    })

    -- Opened gate - not obtainable
    core.register_node(":" .. node_name .. "_platform_gate_extended_opened", {
        drawtype = "nodebox",
        tiles = extended_tiles,
        use_texture_alpha = node_def.use_texture_alpha,
        paramtype = "light",
        paramtype2 = "facedir",
        node_box = gate_opened_extended_box,
        selection_box = gate_opened_extended_box,
        on_rotate = on_rotate,
        on_rightclick = door_on_rightclick,

        groups = groups_for_gate_opened,
        sounds = node_def.sounds,
        sunlight_propagates = true,
        is_ground_content = false,
        drop = node_name .. "_platform_gate_extended",

        _advtrains_doors_state = "opened",
        _advtrains_doors_counterpart = node_name .. "_platform_gate_extended",
    })

    -- Fixed gate - won't open
    core.register_node(":" .. node_name .. "_platform_gate_extended_fixed", {
        description = S("@1 Platform Gate (Extended, Fixed)", description),

        drawtype = "nodebox",
        tiles = extended_tiles,
        use_texture_alpha = node_def.use_texture_alpha,
        paramtype = "light",
        paramtype2 = "facedir",
        node_box = gate_fixed_extended_box,
        selection_box = gate_fixed_extended_box,
        on_rotate = on_rotate,

        groups = groups, -- NO advtrains_doors
        sounds = node_def.sounds,
        sunlight_propagates = true,
        is_ground_content = false,
    })

    -- Closed screen
    core.register_node(":" .. node_name .. "_platform_screen", {
        description = S("@1 Platform Screen Door", description),

        drawtype = "nodebox",
        tiles = tiles,
        use_texture_alpha = node_def.use_texture_alpha,
        paramtype = "light",
        paramtype2 = "facedir",
        node_box = double_gate_closed_box,
        selection_box = double_gate_closed_box,
        on_rotate = on_rotate,
        on_rightclick = door_on_rightclick,

        groups = groups_for_gate_closed,
        sounds = node_def.sounds,
        sunlight_propagates = true,
        is_ground_content = false,

        _advtrains_doors_state = "closed",
        _advtrains_doors_counterpart = node_name .. "_platform_screen_opened",

        on_construct = screen_on_construct,
        on_destruct = screen_on_destruct,
    })

    -- Opened screen
    core.register_node(":" .. node_name .. "_platform_screen_opened", {
        drawtype = "nodebox",
        tiles = tiles,
        use_texture_alpha = node_def.use_texture_alpha,
        paramtype = "light",
        paramtype2 = "facedir",
        node_box = double_gate_opened_box,
        selection_box = double_gate_opened_box,
        on_rotate = on_rotate,
        on_rightclick = door_on_rightclick,

        groups = groups_for_gate_opened,
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
        core.register_craft({
            output = node_name .. "_platform_gate 4",
            recipe = {
                { node_name, mese, node_name }
            }
        })

        -- Crafting recipe for fixed
        core.register_craft({
            output = node_name .. "_platform_gate_fixed 6",
            recipe = {
                { node_name, steel, node_name }
            }
        })

        -- Crafting recipie for gate extended
        core.register_craft({
            output = node_name .. "_platform_gate_extended 6",
            recipe = {
                { "",        node_name, "" },
                { node_name, mese,      node_name }
            }
        })

        -- Crafting recipe for fixed
        core.register_craft({
            output = node_name .. "_platform_gate_extended_fixed 6",
            recipe = {
                { "",        node_name, "" },
                { node_name, steel,     node_name }
            }
        })
    end

    -- Crafting recipe for screen
    core.register_craft({
        type = "shapeless",
        output = node_name .. "_platform_screen",
        recipe = { node_name .. "_platform_gate", node_name .. "_platform_gate" }
    })

    -- screen back to recipe
    core.register_craft({
        type = "shapeless",
        output = node_name .. "_platform_gate 2",
        recipe = { node_name .. "_platform_screen" }
    })
end
