-- advtrains_doors/src/register.lua
-- Register for MTG
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
local logger = _int.logger:sublogger("register")

_ad.register_platform_gate("default:steelblock")
_ad.register_platform_gate("default:copperblock")
_ad.register_platform_gate("default:glass")
_ad.register_platform_gate("default:obsidian_glass")
