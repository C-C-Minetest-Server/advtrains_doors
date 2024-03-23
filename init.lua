-- advtrains_doors/init.lua
-- Platform screen doors for Advtrains
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

advtrains_doors = {}
advtrains_doors.internal = {}

advtrains_doors.internal.logger = logging.logger("advtrains_doors")
advtrains_doors.internal.S = minetest.get_translator("advtrains_doors")

local MP = minetest.get_modpath("advtrains_doors")

dofile(MP .. "/src/api.lua")
dofile(MP .. "/src/callbacks.lua")
dofile(MP .. "/src/register.lua")

advtrains_doors.internal = nil
