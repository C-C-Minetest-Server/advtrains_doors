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
        if node.param2 % 4 ~= node.param2 then
            node.param2 = node.param2 % 4
            minetest.swap_node(pos, node)
        end
        local def = minetest.registered_nodes[node.name]
        local dir = vector.multiply(minetest.facedir_to_dir(node.param2), -1) -- trains are in front of the gate
        for _, entity in ipairs(minetest.get_objects_inside_radius(vector.add(pos, dir), 2)) do
            local luaentity = entity:get_luaentity()
            if luaentity and luaentity.is_wagon then
                local train = luaentity:train()
                if train.velocity == 0 and train.door_open ~= 0 then
                    -- the door is opened, open this gate
                    if def._advtrains_doors_state == "closed" then
                        node.name = def._advtrains_doors_counterpart
                        minetest.swap_node(pos, node)
                    end
                    return
                end
            end
        end
        -- no wagon with opened door found, close this gate
        if def._advtrains_doors_state == "opened" then
            node.name = def._advtrains_doors_counterpart
            minetest.swap_node(pos, node)
        end
    end,
})
