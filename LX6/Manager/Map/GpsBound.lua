-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\GpsBound.lua
-- Decompiled from: 00191_GpsBound.lua_77ad9ee3f4e2.luajit

require("LX6/Manager/Map/GpsSource")

local _Static = {}
GpsBound = DefClass("GpsBound", GpsBound, GpsSource, _Static)
local M = GpsBound

_Static.CreateBound = function(raidId, indoorId, localBoundId)
	local bound = M.New()

	bound.InitBound(bound, raidId, indoorId, localBoundId)

	return bound
end

M.InitBound = function(self, raidId, indoorId, localBoundId)
	local gId = gMapSystem.area:GetGBoundId(raidId or 0, indoorId or 0, localBoundId or 0)

	self:Init(gId)

	self.extendedGBoundIds = {
		[self.gId] = true
	}
end

M.SetExtraGBoundId = function(self, extraGBoundId)
	self.extraGBoundId = extraGBoundId
	self.extendedGBoundIds = {
		[self.gId] = true,
		[extraGBoundId] = true
	}
end
