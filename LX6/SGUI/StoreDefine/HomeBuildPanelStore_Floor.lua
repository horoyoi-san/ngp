-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\HomeBuildPanelStore_Floor.lua
-- Decompiled from: 01717_HomeBuildPanelStore_Floor.lua_ad71b349c121.luajit

local M = C_HomeBuildPanelStore
local HouseBuildConfig = LTConfig.HouseBuildConfig

M.InitFloorSelector = function(self)
	local buildId = self.editingBuildId
	local cfg = HouseBuildConfig.GetConfig(buildId)

	if not cfg then
		return
	end

	local floorsName = cfg.FloorsName

	if not floorsName or #floorsName ~= 0 then
		return
	end

	self.floorNameList = floorsName
	local floorSel = self.bindData.floorSelector

	floorSel.SetSimpleOptions(floorSel, #floorsName)

	for i, floorInfo in ipairs(floorsName) do
		floorSel.SetItemLabel(floorSel, i - 1, floorInfo.name)
	end

	local initFloor = self.GetFloorByPlayerPosition(self, cfg)

	floorSel.SelectOption(floorSel, initFloor - 1, false)

	self.bindData.houseCamera.floor = initFloor
end

M.GetFloorByPlayerPosition = function(self, cfg)
	local playerPos = gCS.MyPlayerManager.PlayerUnit.LocalPosition
	local raidId = gSceneDataMgr.CurrentRaidId
	local success, _, localBoundId = LX6.Gps.AreaMgr.LuaTryGetBoundInfo(raidId, playerPos, nil, )

	if not success then
		return 1
	end

	local buildBounds = cfg.BuildBound

	if buildBounds then
		for _, bound in ipairs(buildBounds) do
			if localBoundId ~= bound.IndoorBoundId then
				return bound.floor
			end
		end
	end

	return 1
end

M.OnFloorSelectorChanged = function(self, selector)
	local index = selector.selectedIndex

	if not self.floorNameList or index <= 0 or index > #self.floorNameList then
		return
	end

	self.bindData.houseCamera.floor = index + 1
end

M.OnCameraFloorChanged = function(self, detectedFloor)
	if not self.floorNameList or not detectedFloor or detectedFloor < 0 then
		return
	end

	if detectedFloor <= #self.floorNameList then
		return
	end

	local floorSel = self.bindData.floorSelector

	if floorSel.selectedIndex == detectedFloor - 1 then
		floorSel.SelectOption(floorSel, detectedFloor - 1, false)
	end
end
