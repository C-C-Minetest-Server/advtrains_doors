-- advtrains_doors/src/register.lua
-- Register for MTG
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
-- local _int = _ad.internal
-- local logger = _int.logger:sublogger("register")

local queue = {}

-- Minetest Game
queue[#queue + 1] = "default:steelblock"
queue[#queue + 1] = "default:copperblock"
queue[#queue + 1] = "default:glass"
queue[#queue + 1] = "default:obsidian_glass"

-- Moreblocks
queue[#queue + 1] = "moreblocks:iron_glass"
queue[#queue + 1] = "moreblocks:coal_glass"
queue[#queue + 1] = "moreblocks:clean_glass"

-- Basic Materials
queue[#queue + 1] = "basic_materials:concrete_block"

-- VoxelLibre
queue[#queue + 1] = "mcl_core:ironblock"
queue[#queue + 1] = "mcl_core:glass"
for _, color in ipairs({
    "red", "green", "blue", "light_blue", "black", "white", "yellow", "brown", "orange", "pink",
    "gray", "lime", "silver", "magenta", "purple", "cyan",
}) do
    queue[#queue + 1] = "mcl_core:glass_" .. color
end

-- Void
queue[#queue + 1] = "void_essential:stone"
queue[#queue + 1] = "void_essential:water_source"
queue[#queue + 1] = "void_essential:river_water_source"


-- TODO: Implement copper block after dealing with oxidation
--       (or simply only allow waxed?)

for _, name in ipairs(queue) do
    if core.registered_nodes[name] then
        _ad.register_platform_gate(name)
    end
end
