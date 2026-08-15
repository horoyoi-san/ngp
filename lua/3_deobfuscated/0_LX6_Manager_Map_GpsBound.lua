require("LX6/Manager/Map/GpsSource")

local _Static = {}
GpsBound = DefClass("GpsBound", GpsBound, GpsSource, _Static)
local M = GpsBound

function _Static.CreateBound(raidId, indoorId, localBoundId)
	local bound = M.New()

	bound:InitBound(raidId, indoorId, localBoundId)

	return bound
end

function M:InitBound(raidId, indoorId, localBoundId)
	local gId = gMapSystem.area:GetGBoundId(raidId or 0, indoorId or 0, localBoundId or 0)

	self:Init(gId)

	self.extendedGBoundIds = {
		[self.gId] = true
	}
end

function M:SetExtraGBoundId(extraGBoundId)
	self.extraGBoundId = extraGBoundId
	self.extendedGBoundIds = {
		[self.gId] = true,
		[extraGBoundId] = true
	}
end
