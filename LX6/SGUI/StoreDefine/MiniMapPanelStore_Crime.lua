-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\MiniMapPanelStore_Crime.lua
-- Decompiled from: 00983_MiniMapPanelStore_Crime.lua_568e738e7d95.luajit

local M = C_MiniMapPanelStore
local MAP_CRIME_MODE = 0
local MAP_NORMAL_MODE = 1
local ARREST_SEARCHING_MODE = 0
local ARREST_WANTED_MODE = 3

M.InitCrime = function(self)
	self.UpdateArrestMode(self)
end

M.UpdateArrestMode = function(self)
	local unit = gMapSystem.curPlayerUnit

	if gGpsTools:UnitIsNull(unit) then
		return
	end

	local stateArrest = gCS.UnitStateMgr:HasState(unit, LTConfig.UnitStateConfig.PoliceArrestStateArrest)
	local stateSearch = gCS.UnitStateMgr:HasState(unit, LTConfig.UnitStateConfig.PoliceArrestStateSearch)
	local inCarArrest = gMapSubSystem_Vehicle:GetMiniMapArrestActivate()

	if stateArrest then
		self.bindData.isArrested = MAP_CRIME_MODE
		self.bindData.arrestMode = ARREST_WANTED_MODE
	elseif inCarArrest then
		self.bindData.isArrested = MAP_CRIME_MODE
		self.bindData.arrestMode = ARREST_WANTED_MODE
	elseif stateSearch then
		self.bindData.isArrested = MAP_CRIME_MODE
		self.bindData.arrestMode = ARREST_SEARCHING_MODE
	else
		self.bindData.isArrested = MAP_NORMAL_MODE
		self.bindData.arrestMode = ARREST_SEARCHING_MODE
	end
end
