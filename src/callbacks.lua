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

local _ad = advtrains_doors
local _int = _ad.internal
local logger = _int.logger:sublogger("callbacks")

local occ_reverse_lookup_sel = advtrains.occ.reverse_lookup_sel

--[[
    local def = minetest.registered_nodes[node.name]
    if def._advtrains_doors_state == "closed" then
        node.name = def._advtrains_doors_counterpart
        minetest.swap_node(pos, node)
    end

    if def._advtrains_doors_state == "opened" then
        node.name = def._advtrains_doors_counterpart
        minetest.swap_node(pos, node)
    end
]]

function _ad.set_door_state(pos, node, state)
    local def = minetest.registered_nodes[node.name]
    if (state == true and def._advtrains_doors_state == "closed")
        or (state == false and def._advtrains_doors_state == "opened") then
        node.name = def._advtrains_doors_counterpart
        minetest.swap_node(pos, node)
    end
end

-- {[hash] = {state, last_updated}, ...}
local check_cache = {}

minetest.register_abm({
    label = "Open/Close advtrains doors",
    nodenames = { "group:advtrains_doors" },
    interval = 0.1,
    chance = 1,
    catch_up = false,
    action = function(pos, node, active_object_count, active_object_count_wider)
        local hash = minetest.hash_node_position(pos)
        if check_cache[hash] then
            if os.clock() - check_cache[hash][2] <= 0.1 then
                _ad.set_door_state(pos, node, check_cache[hash][1])
                return
            end
            check_cache[hash] = nil
        end

        local dir = minetest.fourdir_to_dir(node.param2)
        local cpos = pos + (dir * -1) + vector.new(0, -1, 0)
        local trains, _ = occ_reverse_lookup_sel(cpos, "in_train")
        for train_id, _ in pairs(trains) do
            local train = advtrains.trains[train_id]

            local doorstate = false
            if train.velocity == 0 and train.door_open ~= 0 then
                doorstate = true
            end
            local now = os.clock()

            for i, w_id in ipairs(train.trainparts) do
                local data = advtrains.wagons[w_id]
                local _, wagon = advtrains.get_wagon_prototype(data)

                -- Get the train direction
                -- we use the old position logic cuz that should be enough
                -- see advtrains/advtrains/wagons.lua:424-452
                local index = advtrains.path_get_index_by_offset(train, train.index, -data.pos_in_train)
                local tpos, yaw, npos, npos2 = advtrains.path_get_interpolated(train, index)
                local vdir = vector.normalize(vector.subtract(npos2, npos))

                -- Get the two endpoints of the train
                local minp = vector.round(tpos + (vdir * -wagon.wagon_span))
                local maxp = vector.round(tpos + (vdir * wagon.wagon_span))
                minp, maxp = vector.sort(minp, maxp)

                for x = minp.x, maxp.x do
                    for y = minp.y, maxp.y do
                        for z = minp.z, maxp.z do
                            local check_pos = vector.new(x, y + 1, z) + dir
                            local check_hash = minetest.hash_node_position(check_pos)
                            if doorstate then
                                check_cache[check_hash] = { true, now }
                            else
                                if not (check_cache[check_hash] and check_cache[check_hash][1] == true) then
                                    -- Do not override open doors
                                    check_cache[check_hash] = { false, now }
                                end
                            end
                            if check_hash == hash then
                                _ad.set_door_state(pos, node, check_cache[check_hash][1])
                            end
                        end
                    end
                end
            end
        end
    end,
})
