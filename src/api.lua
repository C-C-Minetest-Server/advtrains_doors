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
local NS = function(s) return s end

local door_variants = {}

do
    local function add_table(src, scl)
        local rtn = {}
        for i, v in ipairs(scl) do
            rtn[i] = src[i] + v
        end
        return rtn
    end

    local function add_table_array(srcs, scl)
        local rtn = {}
        for i, src in ipairs(srcs) do
            rtn[i] = add_table(src, scl)
        end
        return rtn
    end

    local gate_closed_boxes = {
        { -0.5, -0.5, 7 / 16 - 1 / 64, -0.05, 0.5, 0.5 - 1 / 64 }, -- left
        { 0.05, -0.5, 7 / 16 - 1 / 64, 0.5,   0.5, 0.5 - 1 / 64 }, -- right
    }

    local gate_fixed_boxes = {
        { -0.5, -0.5, 0.4, 0.5, 0.5, 0.5 },
    }

    for variant, data in pairs({
        platform_gate = {
            description = NS("@1 Platform Gate"),
            node_box = gate_closed_boxes,
            counterpart = "platform_gate_opened",
            state = "closed",
        },
        platform_gate_opened = {
            node_box = {
                add_table(gate_closed_boxes[1], { -0.4, 0, 0, -0.4, 0, 0 }),
                add_table(gate_closed_boxes[2], { 0.4, 0, 0, 0.4, 0, 0 }),
            },
            counterpart = "platform_gate",
            state = "opened",
        },
        platform_gate_fixed = {
            description = NS("@1 Platform Gate (Fixed)"),
            node_box = gate_fixed_boxes,
        },
        platform_gate_left_fixed = {
            description = NS("@1 Platform Gate (Left-fixed)"),
            node_box = {
                add_table(gate_fixed_boxes[1], { 0, 0, 0, -0.5, 0, 0 }),
                add_table(gate_closed_boxes[1], { 0.5, 0, 0, 0.5, 0, 0 }),
            },
            counterpart = "platform_gate_left_fixed_opened",
            state = "closed",
        },
        platform_gate_left_fixed_opened = {
            node_box = {
                add_table(gate_fixed_boxes[1], { 0, 0, 0, -0.5, 0, 0 }),
                add_table(gate_closed_boxes[1], { 0.1, 0, 0, 0.1, 0, 0 }),
            },
            counterpart = "platform_gate_left_fixed",
            state = "opened",
        },
        platform_gate_right_fixed = {
            description = NS("@1 Platform Gate (Right-fixed)"),
            node_box = {
                add_table(gate_fixed_boxes[1], { 0.5, 0, 0, 0, 0, 0 }),
                add_table(gate_closed_boxes[2], { -0.5, 0, 0, -0.5, 0, 0 }),
            },
            counterpart = "platform_gate_right_fixed_opened",
            state = "closed",
        },
        platform_gate_right_fixed_opened = {
            node_box = {
                add_table(gate_fixed_boxes[1], { 0.5, 0, 0, 0, 0, 0 }),
                add_table(gate_closed_boxes[2], { -0.1, 0, 0, -0.1, 0, 0 }),
            },
            counterpart = "platform_gate_right_fixed",
            state = "opened",
        },
    }) do
        data.collision_box = add_table_array(data.node_box, { 0, 0, 0, 0, 5 / 16, 0 })
        door_variants[variant] = data
    end

    door_variants.platform_gate_downward = {
        description = NS("@1 Platform Gate (Move downward)"),
        node_box = {
            { -0.5, -0.5, 7 / 16 - 1 / 64, 0.5, 0.5, 0.5 - 1 / 64 },
        },
        collision_box = door_variants.platform_gate.collision_box,
        counterpart = "platform_gate_downward_opened",
        state = "closed",
    }
    door_variants.platform_gate_downward_opened = {
        node_box = add_table_array(door_variants.platform_gate_downward.node_box, { 0, -15 / 16, 0, 0, -15 / 16, 0 }),
        counterpart = "platform_gate_downward",
        state = "opened",
    }
    door_variants.platform_gate_downward_left_fixed = {
        description = NS("@1 Platform Gate (Move downward, Left-fixed)"),
        node_box = {
            add_table(gate_fixed_boxes[1], { 0, 0, 0, -0.5, 0, 0 }),
            { 0, -0.5, 7 / 16 - 1 / 64, 0.5, 0.5, 0.5 - 1 / 64 },
        },
        collision_box = door_variants.platform_gate.collision_box,
        counterpart = "platform_gate_downward_left_fixed_opened",
        state = "closed",
    }
    door_variants.platform_gate_downward_left_fixed_opened = {
        node_box = {
            add_table(gate_fixed_boxes[1], { 0, 0, 0, -0.5, 0, 0 }),
            add_table(door_variants.platform_gate_downward_left_fixed.node_box[2], { 0, -15 / 16, 0, 0, -15 / 16, 0 }),
        },
        counterpart = "platform_gate_downward_left_fixed",
        state = "opened",
    }
    door_variants.platform_gate_downward_right_fixed = {
        description = NS("@1 Platform Gate (Move downward, Right-fixed)"),
        node_box = {
            add_table(gate_fixed_boxes[1], { 0.5, 0, 0, 0, 0, 0 }),
            { -0.5, -0.5, 7 / 16 - 1 / 64, 0, 0.5, 0.5 - 1 / 64 },
        },
        collision_box = door_variants.platform_gate.collision_box,
        counterpart = "platform_gate_downward_right_fixed_opened",
        state = "closed",
    }
    door_variants.platform_gate_downward_right_fixed_opened = {
        node_box = {
            add_table(gate_fixed_boxes[1], { 0.5, 0, 0, 0, 0, 0 }),
            add_table(door_variants.platform_gate_downward_right_fixed.node_box[2], { 0, -15 / 16, 0, 0, -15 / 16, 0 }),
        },
        counterpart = "platform_gate_downward_right_fixed",
        state = "opened",
    }

    door_variants.platform_gate_extended = {
        description = NS("@1 Platform Gate (Extended)"),
        node_box = door_variants.platform_gate.collision_box,
        counterpart = "platform_gate_extended_opened",
        state = "closed",
        extended = true,
    }
    door_variants.platform_gate_extended_opened = {
        node_box = door_variants.platform_gate_opened.collision_box,
        counterpart = "platform_gate_extended",
        state = "opened",
        extended = true,
    }
    door_variants.platform_gate_extended_fixed = {
        description = NS("@1 Platform Gate (Extended, Fixed)"),
        node_box = door_variants.platform_gate_fixed.collision_box,
        extended = true,
    }
    door_variants.platform_gate_extended_left_fixed = {
        description = NS("@1 Platform Gate (Extended. Left-fixed)"),
        node_box = door_variants.platform_gate_left_fixed.collision_box,
        counterpart = "platform_gate_extended_left_fixed_opened",
        state = "closed",
        extended = true,
    }
    door_variants.platform_gate_extended_left_fixed_opened = {
        node_box = door_variants.platform_gate_left_fixed_opened.collision_box,
        counterpart = "platform_gate_extended_left_fixed",
        state = "opened",
        extended = true,
    }
    door_variants.platform_gate_extended_right_fixed = {
        description = NS("@1 Platform Gate (Extended, Right-fixed)"),
        node_box = door_variants.platform_gate_right_fixed.collision_box,
        counterpart = "platform_gate_extended_right_fixed_opened",
        state = "closed",
        extended = true,
    }
    door_variants.platform_gate_extended_right_fixed_opened = {
        node_box = door_variants.platform_gate_right_fixed_opened.collision_box,
        counterpart = "platform_gate_extended_right_fixed",
        state = "opened",
        extended = true,
    }

    door_variants.platform_screen = {
        description = NS("@1 Platform Screen Door"),
        node_box = add_table_array(gate_closed_boxes, { 0, 0, 0, 0, 1, 0 }),
        counterpart = "platform_screen_opened",
        state = "closed",
        screen = true,
    }
    door_variants.platform_screen_opened = {
        node_box = add_table_array(door_variants.platform_gate_fixed.node_box, { 0, 0, 0, 0, 1, 0 }),
        counterpart = "platform_screen",
        state = "opened",
        screen = true,
    }
    door_variants.platform_screen_left_fixed = {
        description = NS("@1 Platform Screen Door (Left-fixed)"),
        node_box = add_table_array(door_variants.platform_gate_left_fixed.node_box, { 0, 0, 0, 0, 1, 0 }),
        counterpart = "platform_screen_left_fixed_opened",
        state = "closed",
        screen = true,
    }
    door_variants.platform_screen_left_fixed_opened = {
        node_box = add_table_array(door_variants.platform_gate_left_fixed_opened.node_box, { 0, 0, 0, 0, 1, 0 }),
        counterpart = "platform_screen_left_fixed",
        state = "opened",
        screen = true,
    }
    door_variants.platform_screen_right_fixed = {
        description = NS("@1 Platform Screen Door (Right-fixed)"),
        node_box = add_table_array(door_variants.platform_gate_right_fixed.node_box, { 0, 0, 0, 0, 1, 0 }),
        counterpart = "platform_screen_right_fixed_opened",
        state = "closed",
        screen = true,
    }
    door_variants.platform_screen_right_fixed_opened = {
        node_box = add_table_array(door_variants.platform_gate_right_fixed_opened.node_box, { 0, 0, 0, 0, 1, 0 }),
        counterpart = "platform_screen_right_fixed",
        state = "opened",
        screen = true,
    }
end

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
    local extended_tiles = create_extended_texture(tiles)

    for variant, data in pairs(door_variants) do
        local node_box = {
            type = "fixed",
            fixed = data.node_box,
        }
        local collision_box = data.collision_box and {
            type = "fixed",
            fixed = data.collision_box,
        } or node_box
        local counterpart = data.counterpart

        local drop = nil
        local groups_used = groups
        if data.state == "closed" then
            groups_used = groups_for_gate_closed
        elseif data.state == "opened" then
            groups_used = groups_for_gate_opened
            drop = node_name .. "_" .. counterpart
        end

        core.register_node(":" .. node_name .. "_" .. variant, {
            description = data.description and S(data.description, description) or nil,

            drawtype = "nodebox",
            tiles = data.extended and extended_tiles or tiles,
            use_texture_alpha = node_def.use_texture_alpha,
            paramtype = "light",
            paramtype2 = "facedir",
            node_box = node_box,
            selection_box = node_box,
            collision_box = collision_box,
            on_rotate = on_rotate,
            on_rightclick = door_on_rightclick,

            groups = groups_used,
            sounds = node_def.sounds,
            sunlight_propagates = true,
            is_ground_content = false,
            drop = drop,

            on_construct = data.screen and screen_on_construct or nil,
            on_destruct = data.screen and screen_on_destruct or nil,


            _advtrains_doors_state = data.state,
            _advtrains_doors_counterpart = counterpart and (node_name .. "_" .. counterpart) or nil,
        })
    end

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
    for _, suffix in ipairs({
        "",
        "_left_fixed",
        "_right_fixed",
    }) do
        core.register_craft({
            type = "shapeless",
            output = node_name .. "_platform_screen" .. suffix,
            recipe = { node_name .. "_platform_gate" .. suffix, node_name .. "_platform_gate" .. suffix }
        })

        core.register_craft({
            type = "shapeless",
            output = node_name .. "_platform_gate" .. suffix .. " 2",
            recipe = { node_name .. "_platform_screen" .. suffix }
        })
    end

    -- Crafting recipe for left or right fixed

    for _, door_group in ipairs({
        "platform_gate",
        "platform_gate_extended",
        "platform_screen",
    }) do
        core.register_craft({
            output = node_name .. "_" .. door_group .. "_left_fixed",
            recipe = { { node_name .. "_" .. door_group .. "_fixed", node_name .. "_" .. door_group } }
        })

        core.register_craft({
            output = node_name .. "_" .. door_group .. "_right_fixed",
            recipe = { { node_name .. "_" .. door_group, node_name .. "_" .. door_group .. "_fixed" } }
        })
    end
end
