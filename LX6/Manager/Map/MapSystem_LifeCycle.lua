-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\MapSystem_LifeCycle.lua
-- Decompiled from: 00216_MapSystem_LifeCycle.lua_640312be192d.luajit

local gGpsTools = gGpsTools
local M = gMapSystem

M.OnSceneInit = function(self)
	for key, _ in pairs(self.subSystems) do
		local subSystem = self.subSystems[key]
		local status, err = xpcall(subSystem.DoSceneInit, tolua.traceback, subSystem)

		if not status then
			print_error("MapSubSystem Scene Init Failed: " .. subSystem._name .. "\n", err)
		end
	end

	self.hasEnterScene = true
end

M.OnSceneDestroy = function(self)
	self.hasEnterScene = false

	for key, _ in pairs(self.subSystems) do
		local subSystem = self.subSystems[key]
		local status, err = xpcall(subSystem.DoSceneDestroy, tolua.traceback, subSystem)

		if not status then
			print_error("MapSubSystem Scene Destroy Failed: " .. subSystem._name .. "\n", err)
		end
	end
end

M.OnLogin = function(self)
	gGpsTools.PCallMethod(self.RealOnLogin, self)
end

M.RealOnLogin = function(self)
	if self._logined then
		print_error("重复登录")

		return
	end

	gBigMapHelper:OnLogin()
	gGpsBindingMgr:OnLogin()

	for i = 1, #self.modules do
		local module = self.modules[i]

		if module.OnLogin then
			gGpsTools.PCallMethod(module.OnLogin, module)
		end
	end

	if self._cachedPlayerInfo then
		local playerInfo = self._cachedPlayerInfo
		self._cachedPlayerInfo = nil

		gGpsTools.PCallMethod(self.OnSyncPlayerInfo, self, playerInfo)
	end

	for _, subSystem in pairs(self.subSystems) do
		local status, err = xpcall(subSystem.OnLogin, tolua.traceback, subSystem)

		if not status then
			print_error("MapSubSystem Login Failed: " .. subSystem._name .. "\n", err)
		end
	end

	for _, subSystem in pairs(self.subSystems) do
		local status, err = xpcall(subSystem.LoadData, tolua.traceback, subSystem)

		if not status then
			print_error("MapSubSystem LoadData Failed: " .. subSystem._name .. "\n", err)
		end
	end

	self.FlushAll(self, "Login")

	self._logined = true
end

M.OnSyncPlayerInfo = function(self, playerInfo)
	if playerInfo then
		self.taskUtils:SyncTaskGuideTitles(playerInfo.InfoMinor.PlayerInfoGuide.TaskTitleGuideUnlockList)
	else
		print_error("MapSystem OnLogin playerInfo is nil")
	end
end

M.OnLogout = function(self)
	if not self._logined then
		return
	end

	self._logined = nil

	for _, subSystem in pairs(self.subSystems) do
		gGpsTools.PCallMethod(subSystem.OnLogout, subSystem)
	end

	for i = #self.modules, 1, -1 do
		local module = self.modules[i]

		if module.OnLogout then
			gGpsTools.PCallMethod(module.OnLogout, module)
		end
	end

	gGpsBindingMgr:OnLogout()
end

M.CSOnRenderTick = function(self)
	self.CallWithProfiler(self, "MapSystem.OnRenderTick", self.OnRenderTick, self)
end

M.OnRenderTick = function(self)
	local lastToken = self._renderTickToken
	self._renderTickToken = nil

	if not lastToken or lastToken == UnityEngine.Time.frameCount then
		return
	end

	gGpsTools.ProfilerMethod("ClearCoordDirty", self.container.ClearCoordDirty, self.container)
	gGpsTools.ProfilerMethod("Sync View", self.container.TickView, self.container)
	gGpsTools.ProfilerMethod("Sync GlobalGps", self.trace.Tick, self.trace)
	gGpsTools.ProfilerMethod("TickWeakGuide", self.trace.TickWeakGuide, self.trace)
	gGpsTools.ProfilerMethod("Container TickViewNotify", self.container.TickViewNotify, self.container)
	gGpsTools.ProfilerMethod("TickVehicleNavInfo", self.navigation.TickVehicleNavInfo, self.navigation)
	gGpsTools.ProfilerMethod("TickWalkNavInfo", self.TickWalkNavInfo, self)
	gGpsTools.ProfilerMethod("TickRaceNavLineInfo", self.navigation.TickRaceNavLineInfo, self.navigation)
	gGpsTools.ProfilerMethod("BaseMap Tick", gBaseMapMgr.Tick, gBaseMapMgr)
	self.ui:Tick()
end

M.OnUpdate = function(self)
	if not self.inited or not self.hasEnterScene then
		return
	end

	gGpsTools.ProfilerMethod("TickRecycle", self.container.TickRecycle, self.container)

	if not self._logined then
		return
	end

	local isGameScene = gLuaDataManager.gameStage ~= LX6.Scene.SwitchSceneManager.GameStage.GameScene

	if gCS.LuaUtils.IsOnEditor and not gLuaDataManager.isNetworkAvailable then
		isGameScene = false
	end

	gGpsTools.ProfilerMethod("UpdateCurPlayerUnit", self.UpdateCurPlayerUnit, self)
	gGpsTools.ProfilerMethod("MapUIOnUpdate", self.ui.DoUIPreTick, self.ui)

	if not isGameScene then
		return
	end

	gGpsTools.ProfilerMethod("MapSubSystem Tick", self.TickSubSystem, self)
	gGpsTools.ProfilerMethod("FlushData", self.FlushSubSystems, self)
	gGpsTools.ProfilerMethod("gGpsBindingMgr Tick", gGpsBindingMgr.Tick, gGpsBindingMgr)

	self._renderTickToken = UnityEngine.Time.frameCount
end

M.OnBeforeSwitchScene = function(self, switchType)
	if switchType == gSwitchSceneType.KickToLogin then
		if switchType == gSwitchSceneType.Reconnect then
			self.lastIndoorId = 0
		end

		for _, subSystem in pairs(self.subSystems) do
			subSystem.OnBeforeSwitchScene(subSystem, switchType)
		end
	end
end

M.InitSubSystem = function(self)
	self.tickEntries = {}
	self.subSystems = {}

	for enumName, subSystemType in pairs(EMapSubSystemType) do
		if not gMapSubSystemInfo[subSystemType] then
			print_warn("EMapSubSystemType." .. enumName .. " 未找到对应的路径")
		else
			local shortName = gMapSubSystemInfo[subSystemType]
			local subSystemName = "MapSubSystem_" .. shortName
			local path = "LX6/Manager/Map/MapSubSystem/" .. subSystemName
			local ok, res = xpcall(require, tolua.traceback, path)

			if not ok then
				print_error_without_stack("MapSubSystem Require Failed: " .. subSystemName .. "\n", res)
			elseif not res or not res.New then
				print_error("MapSubSystem New Method Not Found: " .. subSystemName)
			else
				local subSystem = res.New()
				subSystem.env = self
				subSystem.systemType = subSystemType
				subSystem._name = subSystemName
				subSystem._flushProfilerKey = subSystemName .. " FlushData"
				subSystem._tickProfilerKey = subSystemName .. " Tick"
				self.subSystems[subSystemType] = subSystem
				_G["gMapSubSystem_" .. shortName] = subSystem
				_G["gGps_" .. shortName] = subSystem

				if subSystem.Tick then
					array.push(self.tickEntries, {
						["WNobz*"] = 0,
						systemType = subSystemType,
						interval = gMapSubSystemTickInterval[subSystemType] or 0,
						profilerKey = subSystemName .. " Tick"
					})
				end
			end
		end
	end

	gMapSubSystem_TaskGps = self.subSystems[EMapSubSystemType.TaskGps]
	gMapSubSystem_Debug = self.subSystems[EMapSubSystemType.Debug]
	gMapSubSystem_RangeEvent = self.subSystems[EMapSubSystemType.RangeEvent]
	gMapSubSystem_Pin = self.subSystems[EMapSubSystemType.Pin]
	gMapSubSystem_Boss = self.subSystems[EMapSubSystemType.Boss]
	gMapSubSystem_Entrance = self.subSystems[EMapSubSystemType.Entrance]
	gMapSubSystem_Task = self.subSystems[EMapSubSystemType.Task]
	gMapSubSystem_TaxiDest = self.subSystems[EMapSubSystemType.TaxiDest]
	gMapSubSystem_Vehicle = self.subSystems[EMapSubSystemType.Vehicle]
	gMapSubSystem_NearByMisc = self.subSystems[EMapSubSystemType.NearByMisc]
	gMapSubSystem_Misc = self.subSystems[EMapSubSystemType.Misc]
	gMapSubSystem_CommonUnit = self.subSystems[EMapSubSystemType.CommonUnit]
	gMapSubSystem_CommonGps = self.subSystems[EMapSubSystemType.CommonGps]
	gMapSubSystem_Collection = self.subSystems[EMapSubSystemType.Collection]
	gMapSubSystem_LegacyGps = self.subSystems[EMapSubSystemType.LegacyGps]
	gMapSubSystem_SpiritAcquisition = self.subSystems[EMapSubSystemType.SpiritAcquisition]
	gMapSubSystem_FunctionPoint = self.subSystems[EMapSubSystemType.FunctionPoint]
	gMapSubSystem_Faction = self.subSystems[EMapSubSystemType.Faction]
	gMapSubSystem_Gangster = self.subSystems[EMapSubSystemType.Gangster]
	gMapSubSystem_Legend = self.subSystems[EMapSubSystemType.Legend]
	gMapSubSystem_Camp = self.subSystems[EMapSubSystemType.Camp]
	gMapSubSystem_Player = self.subSystems[EMapSubSystemType.Player]
	gMapSubSystem_Crime = self.subSystems[EMapSubSystemType.Crime]
	gMapSubSystem_EvacuationPlace = self.subSystems[EMapSubSystemType.EvacuationPlace]
	gMapSubSystem_HideAndSeek = self.subSystems[EMapSubSystemType.HideAndSeek]
	gMapSubSystem_ChatMark = self.subSystems[EMapSubSystemType.ChatMark]
	gMapSubSystem_PublicEvent = self.subSystems[EMapSubSystemType.PublicEvent]
	gMapSubSystem_OnlineTrace = self.subSystems[EMapSubSystemType.OnlineTrace]
	gMapSubSystem_FightSkillFromNpc = self.subSystems[EMapSubSystemType.FightSkillFromNpc]
	gMapSubSystem_LinkGameplay = self.subSystems[EMapSubSystemType.LinkGameplay]
	gMapSubSystem_CarRace = self.subSystems[EMapSubSystemType.CarRace]
	gMapSubSystem_Rowboat = self.subSystems[EMapSubSystemType.Rowboat]

	for _, subSystem in pairs(self.subSystems) do
		local ok, err = xpcall(subSystem.Init, tolua.traceback, subSystem)

		if not ok then
			print_error("MapSubSystem Init Failed: " .. subSystem._name .. "\n", err)
		end
	end
end

M.InitEventHandler = function(self)
	self._mapAreaUpdateEvent = {}
	self._mapElementUpdate = {}
	self.eventHandlers = {
		[gEventConstants.PAOKU_STATE_CHANGE] = function ()
			if gGameManager.Env.IsENABLE_PROFILER then
				gGameManager:BeginSample("UpdateParkourScaleType")
			end

			self.ui:UpdateParkourScaleType()
			self.ui:UpdateParkourProwlState()

			if gGameManager.Env.IsENABLE_PROFILER then
				gGameManager:EndSample()
			end
		end,
		[gEventConstants.CURRENT_TASK_CHANGE] = function ()
			for _, taskId in pairs(gTaskNodeManager.NowDoingTask) do
				local taskCfg = LTConfig.TaskConfig.GetConfig(taskId)

				if taskCfg and table.contains(taskCfg.Tags, LTConfig.TaskConfig.TagsType.MiniMapFocusMode) then
					self.ui:SetMiniMapViewMask(EMapViewMask.FocusMode)

					return
				end
			end

			self.ui:SetMiniMapViewMask(EMapViewMask.MiniMap)
		end,
		[gEventConstants.MY_UNIT_STATE_CHANGE] = function (eventId, params)
			self.ui:OnMyUnitStateChange()
		end,
		[gEventConstants.LINK_MODE_CHANGE] = function (eventId, params)
			self.container:OnLinkModeChange()
		end,
		[gEventConstants.ON_POI_AREA_CHANGE] = function (eventId, params)
			self.poi:OnPoiAreaChange(params)
		end,
		[gEventConstants.ON_ENTER_SAFE_OR_DANGER_AREA] = function (eventId, params)
			self.ui:OnEnterSafeOrDangerArea(params)
		end
	}

	gMessageManager:RegisterEventHandlers(self.eventHandlers)
end
