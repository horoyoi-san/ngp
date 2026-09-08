-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\NewMapPanelStore_Path.lua
-- Decompiled from: 00996_NewMapPanelStore_Path.lua_86545cc5c684.luajit

local MapNavigationMgr = LX6.Gps.MapNavigationMgr
local M = C_NewMapPanelStore

M.ClearPathInfo = function(self)
	self.navInfo = nil
end

M.TickPathObjects = function(self)
	local path = nil

	if gMapSystem.navigation:CanShowVehicleNavRoute() then
		local hideInAutoDrive = LTConfig.VehicleConfig.EnableAutopilotHideNavigationLine == false and gDriveVehiclesManager.isAutoDriving
		local curVehicle = gMapSystem.curVehicle

		if curVehicle and (curVehicle.IsHelicopter or curVehicle.IsPlane or curVehicle.IsBoat) then
			hideInAutoDrive = true
		end

		if not hideInAutoDrive then
			path = MapNavigationMgr.GetUIRenderPath()
		end
	end

	self.DrawVehiclePath(self, self.bindData.taskLineRenderer, path)
end

M.TickExtractionPathObjects = function(self)
	local path = nil

	if gMapSubSystem_Pin and gMapSubSystem_Pin:CanDrawMyExtractionShooterMarkPath() then
		path = gMapSubSystem_Pin:GetMyExtractionShooterMarkPath()
	end

	self.DrawVehiclePath(self, self.bindData.extractionLineRenderer, path)
end

M.DrawVehiclePath = function(self, line, path)
	if path == nil then
		line.ClearPoint(line)

		for i = 0, path.Length - 1 do
			local pos = self.TransformWorldToTex(self, path[i], self.areaId)

			line.AddPoint(line, pos.x, pos.y, 20, true, 0, 10)
		end

		line.RefreshSpline(line)
	else
		line.ClearPoint(line)
		line.RefreshSpline(line)
	end
end

M.SetRaceNavRenderInfo = function(self, paths)
	if not self.bindData or not self.bindData.racePool then
		return
	end

	if self.racePathRenders then
		for _, pathRender in pairs(self.racePathRenders) do
			self.bindData.racePool:DeleteItem(pathRender)
		end
	end

	self.racePathRenders = {}
	slot2 = pairs
	slot4 = paths or {}

	for _, path in slot2(slot4) do
		if table.isNilOrEmpty(path) then
			return
		end

		local pathRender = self.bindData.racePool:CreateItem(0)
		local storeGroup = gStoreManager:GetStoreGroup("MiniMapRacePathStore")

		if not storeGroup then
			return
		end

		local pathStore = storeGroup:GetStoreByWidget(pathRender)

		table.insert(self.racePathRenders, pathRender)
		pathStore.spline:RefreshSpline()

		self.drawLineTimer = FrameTimer.New(function ()
			self:DrawRaceNavPath(pathStore.spline, path, false)

			self.drawLineTimer = nil
		end, 1)

		self.drawLineTimer:Start()
	end
end

M.DrawRaceNavPath = function(self, line, path, inLogicThread)
	if path ~= self._tmp_CacheRacePath then
		return
	end

	self._tmp_CacheRacePath = path

	if not table.isNilOrEmpty(path) then
		line.ClearPoint(line)

		for i = 1, #path do
			local pos = self.TransformWorldToTex(self, path[i], self.areaId)

			line.AddPoint(line, pos.x, pos.y, 20, true, 0, 10)
		end
	else
		line.ClearPoint(line)
	end

	line.RefreshSpline(line)
end
