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

minetest.register_abm({
    label = "Open/Close advtrains doors",
    nodenames = {"group:advtrains_doors"},
    interval = 0.1,
    chance = 1,
    catch_up = false,
    action = function(pos, node, active_object_count, active_object_count_wider)
        local def = minetest.registered_nodes[node.name]
        local dir = vector.multiply(minetest.fourdir_to_dir(node.param2), -1) -- trains are in front of the gate
        local cpos = pos + dir + vector.new(0, -1, 0)

        local trains, _ = advtrains.occ.reverse_lookup_sel(cpos, "in_train")
        for train_id, _ in pairs(trains) do
            local train = advtrains.trains[train_id]
            if train.velocity == 0 and train.door_open ~= 0 then
                -- the door is opened, open this gate
                if def._advtrains_doors_state == "closed" then
                    node.name = def._advtrains_doors_counterpart
                    minetest.swap_node(pos, node)
                end
                return
            end
        end
        -- no wagon with opened door found, close this gate
        if def._advtrains_doors_state == "opened" then
            node.name = def._advtrains_doors_counterpart
            minetest.swap_node(pos, node)
        end
    end,
})
