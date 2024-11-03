-- advtrains_doors/src/callbacks.lua
-- ABM callbacks
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

local minetest, advtrains, math = core, advtrains, math
local abs, floor, round = math.abs, math.floor, math.round

-- local _ad = advtrains_doors
-- local _int = _ad.internal
-- local logger = _int.logger:sublogger("callbacks")

local doors_opened_pos = {}

local default_door_entry = { -1, 0, 1 }

local function path_get_adjacent(train, index)
    local i_floor = floor(index)
    local p_floor = advtrains.path_get(train, i_floor)
    if abs(i_floor - index) < 0.3 then
        return { p_floor }
    end
    local i_ceil = i_floor + 1
    local p_ceil = advtrains.path_get(train, i_ceil)
    return { p_floor, p_ceil }
end

local total_steps = 0
minetest.register_globalstep(function()
    -- Don't run for the first main loop
    if advtrains.mainloop_runcnt <= 0 then
        return
    end

    -- Run every 5 steps
    total_steps = total_steps + 1
    if total_steps < 5 then
        return
    end
    total_steps = 0

    -- Clear hash table
    for k in pairs(doors_opened_pos) do
        doors_opened_pos[k] = nil
    end

    for _, train in pairs(advtrains.trains) do
        if train.path and train.velocity == 0 and train.door_open and train.door_open ~= 0 then
            for _, wagon_id in ipairs(train.trainparts) do
                local wagon_data = advtrains.wagons[wagon_id]
                if wagon_data then
                    local _, prototype = advtrains.get_wagon_prototype(wagon_data)
                    local door_entry = prototype.door_entry or default_door_entry
                    for _, ino in ipairs(door_entry) do
                        -- Open doors at where door_entry are
                        -- see: wagon:on_step
                        local index = advtrains.path_get_index_by_offset(train, train.index, -wagon_data.pos_in_train)
                        if advtrains.is_node_loaded(advtrains.path_get(train, floor(index))) then
                            local fct = wagon_data.wagon_flipped and -1 or 1
                            local aci = advtrains.path_get_index_by_offset(train, index, ino * fct)
                            local ix1, ix2 = advtrains.path_get_adjacent(train, aci)
                            local add = {
                                x = (ix2.z - ix1.z) * train.door_open,
                                y = 1,
                                z = (ix1.x - ix2.x) * train.door_open
                            }
                            for _, pos in ipairs(path_get_adjacent(train, aci)) do
                                local platform_pos = {
                                    x = round(pos.x + add.x),
                                    y = round(pos.y + add.y),
                                    z = round(pos.z + add.z),
                                }
                                if advtrains.is_node_loaded(platform_pos) then
                                    local hash = minetest.hash_node_position(platform_pos)
                                    local node = minetest.get_node(platform_pos)
                                    local def = minetest.registered_nodes[node.name]
                                    if not doors_opened_pos[hash]
                                        and def.groups
                                        and def.groups.advtrains_doors == 1 then
                                        if def.groups.advtrains_doors_closed == 1 then
                                            node.name = def._advtrains_doors_counterpart
                                            minetest.swap_node(platform_pos, node)
                                        end
                                        doors_opened_pos[hash] = true
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

minetest.register_abm({
    label = "Close advtrains doors",
    nodenames = { "group:advtrains_doors_opened" },
    interval = 0.5,
    chance = 1,
    catch_up = false,
    action = function(pos, node)
        local def = minetest.registered_nodes[node.name]
        if not doors_opened_pos[minetest.hash_node_position(pos)] then
            node.name = def._advtrains_doors_counterpart
            minetest.swap_node(pos, node)
        end
    end,
})
