
-- advtrains_doors/src/api.lua
-- API for registering gates
--[[
    advtrains_doors: Platform screen doors for Advtrains
    Copyright (C) 2024  1F616EMO

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library; if not, write to the Free Software
    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
]]

local _ad = advtrains_doors
local _int = _ad.internal
local logger = _int.logger:sublogger("api")

local S = _int.S

-- These are from door shutters of cottages
local gate_closed_box = {
    type = "fixed",
    fixed = {
        { -0.5, -0.5, 7/16 - 1/64, -0.05, 0.5, 0.5 - 1/64 },
        { 0.05, -0.5, 7/16 - 1/64, 0.5,   0.5, 0.5 - 1/64},
    },
}
local gate_opened_box = {
    type = "fixed",
    fixed = {
        { -0.90, -0.5, 7/16 - 1/64, -0.45, 0.5, 0.5 - 1/64 },
        { 0.45,  -0.5, 7/16 - 1/64, 0.9,   0.5, 0.5 - 1/64 },
    },
}
local gate_fixed_box = {
    type = "fixed",
    fixed = {
        { -0.5, -0.5, 0.4, 0.5, 0.5, 0.5 },
    },
}

local keep_groups = {
    -- General groups
    "not_in_creative_inventory",

    -- Minetest Game dig groups
    "crumby", "cracky", "snappy", "choppy", "fleshy", "explody", "oddly_breakable_by_hand", "dig_immediate",
}
local function prepare_groups(groups)
    if not groups then return {} end

    local rtn = {}
    for _, key in ipairs(keep_groups) do
        rtn[key] = groups[key]
    end
    return rtn
end

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
        paramtype2 = "4dir",
        node_box = gate_closed_box,
        selection_box = gate_closed_box,

        groups = groups_for_gate,

        _advtrains_doors_state = "closed",
        _advtrains_doors_counterpart = node_name .. "_platform_gate_opened",
    })

    -- Opened gate - not obtainable
    minetest.register_node(":" .. node_name .. "_platform_gate_opened", {
        drawtype = "nodebox",
        tiles = tiles,
        use_texture_alpha = node_def.use_texture_alpha,
        paramtype = "light",
        paramtype2 = "4dir",
        node_box = gate_opened_box,
        selection_box = gate_opened_box,

        groups = groups_for_gate,
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
        paramtype2 = "4dir",
        node_box = gate_fixed_box,
        selection_box = gate_fixed_box,

        groups = groups, -- NO advtrains_doors
    })

    -- Crafting recipie for gate
    minetest.register_craft({
        output = node_name .. "_platform_gate 4",
        recipe = {
            { node_name, "default:mese_crystal_fragment", node_name }
        }
    })

    -- Crafting recipe for fixed
    minetest.register_craft({
        output = node_name .. "_platform_gate_fixed 4",
        recipe = {
            { node_name, "default:steel_ingot", node_name }
        }
    })
end
