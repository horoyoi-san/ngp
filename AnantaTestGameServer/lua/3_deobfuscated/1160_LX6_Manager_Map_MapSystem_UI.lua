local RaidConfig = LTConfig.RaidConfig
local IndoorConfig = LTConfig.IndoorConfig
local SceneConfig = LTConfig.SceneConfig
local ParkourStateConfig = LTConfig.ParkourStateConfig
local M = {
	Init = function (self)
		self.hudEllipseRT = nil
		self._miniMapViewMask = EMapViewMask.MiniMap
		self._lastParkourScaleType = nil
		self._onRenderTickHandlers = {}
		self._activeUIs = {}
		self._bigMapAccess = false
		self._miniMapCameraInfo = {}
		self.bigMapInterestSource = GpsSource.CreateCommon("BigMapInterest", true)
		self._isProwling = false
	end,
	OnLogin = function (self)
		self._disableHudGps = {}
		self._bigMapInterestByGuideIdSet = {}
	end,
	OnLogout = function (self)
		self._bigMapInterestByGuideIdSet = {}
		self._lastParkourScaleType = nil
		self._miniMapViewMask = EMapViewMask.MiniMap

		gMapManager:RemoveMiniMapScaleType(gMapScaleType.Car)
		gMapManager:RemoveMiniMapScaleType(gMapScaleType.Parkour)
		self:CloseMiniMap()
	end,
	Tick = function (self)
		self.env:CallWithProfiler("UI Render Tick", self.DoUIRenderTick, self)
		self.env:CallWithProfiler("Check MiniMap Visibility", self.TickUIAccessable, self)
	end,
	TryAddUI = function (self, key, ui)
		if self._activeUIs[key] then
			return
		end

		self._activeUIs[key] = ui
	end,
	TryRemoveUI = function (self, key)
		self._activeUIs[key] = nil
	end,
	DoUIPreTick = function (self)
		for key, ui in pairs(self._activeUIs) do
			local tickFunc = ui.OnPreTick

			if ui.tickable and tickFunc then
				self:DoUIFunc(tickFunc, ui, key)
			end
		end
	end,
	DoUIRenderTick = function (self)
		for key, ui in pairs(self._activeUIs) do
			local tickFunc = ui.OnRenderTick

			if ui.tickable and tickFunc then
				self:DoUIFunc(tickFunc, ui, key)
			end
		end
	end,
	DoUIFunc = function (self, func, target, key)
		if gGameManager.Env.IsENABLE_PROFILER then
			gCS.LuaUtils.BeginSample(key)
		end

		local ok, err = xpcall(func, tolua.traceback, target)

		if not ok then
			print_error(err)
		end

		if gGameManager.Env.IsENABLE_PROFILER then
			gCS.LuaUtils.EndSample()
		end
	end,
	ShowMiniMap = function (self)
		if not self._miniMapVisible then
			print_notice("[SGUI Debug]: ShowMiniMap], frame: " .. UnityEngine.Time.frameCount)

			self._miniMapVisible = true
		end
	end,
	CloseMiniMap = function (self)
		if self._miniMapVisible then
			print_notice("[SGUI Debug]: CloseMiniMap], frame: " .. UnityEngine.Time.frameCount)

			self._miniMapVisible = false
		end
	end,
	TickUIAccessable = function (self)
		local miniMapVisible = self._miniMapVisible and gSystemUnlockMgr:IsUnlock(LTConfig.SystemUnlockConfig.MiniMapUnlock)
		miniMapVisible = miniMapVisible and gLuaDataManager.gameStage == gGFConstant.GameStage.GameScene and not gPanelManager:IsPanelShowing(gPanelId.PVP_LOADING_PANEL)
		local isShowing = gPanelManager:IsPanelShowing(gPanelId.S_MINI_MAP_PANEL)

		if miniMapVisible and not isShowing then
			gPanelManager:CheckShow(gPanelId.S_MINI_MAP_PANEL)
		elseif not miniMapVisible and isShowing then
			gPanelManager:Close(gPanelId.S_MINI_MAP_PANEL)
		end

		local bigMapAccess = miniMapVisible and self:IsBigMapAvailable()

		if not self._bigMapAccess ~= not bigMapAccess then
			self._bigMapAccess = bigMapAccess

			gMessageManager:SendMessage(gEventConstants.HUD_OPEN_BIG_MAP_TIP_CHANGE)
		end
	end,
	GetMiniMapViewMask = function (self)
		return self._miniMapViewMask
	end,
	SetMiniMapViewMask = function (self, viewMask)
		if self._miniMapViewMask == viewMask then
			return
		end

		self._miniMapViewMask = viewMask

		gMessageManager:SendMessage(gEventConstants.MINI_MAP_VIEW_MASK_CHANGE)
	end,
	UpdateParkourScaleType = function (self)
		local parkourScaleType = nil
		local clientStates = gMainMenuMgr:GetClientState()
		local key = next(clientStates)
		local firststate = clientStates[key]

		for _, key in pairs(clientStates) do
			if key and key ~= 0 then
				local parkourCfg = ParkourStateConfig.GetConfig(key)

				if ParkourStateConfig.GetConfig(firststate).MiniMapScalePriority < parkourCfg.MiniMapScalePriority then
					firststate = key
				end
			end
		end

		if firststate and firststate ~= 0 then
			local parkourCfg = ParkourStateConfig.GetConfig(firststate)
			parkourScaleType = parkourCfg.MiniMapScale
		else
			parkourScaleType = 5
		end

		if parkourScaleType == 5 or parkourScaleType == self._lastParkourScaleType then
			return
		end

		self._lastParkourScaleType = parkourScaleType

		if parkourScaleType == nil then
			gMapManager:RemoveMiniMapScaleType(gMapScaleType.Car)
			gMapManager:RemoveMiniMapScaleType(gMapScaleType.Parkour)

			return
		end

		local miniMapScale = nil

		for _, entry in ipairs(LTConfig.GameConfig.ParkourStateMiniMapScale) do
			if entry.stateId == parkourScaleType then
				miniMapScale = entry.scale

				break
			end
		end

		if not miniMapScale then
			return
		end

		if parkourScaleType == 4 then
			gMapManager:RemoveMiniMapScaleType(gMapScaleType.Parkour)
			gMapManager:SetMiniMapScale(miniMapScale, gMapScaleType.Car)
		else
			gMapManager:RemoveMiniMapScaleType(gMapScaleType.Car)
			gMapManager:SetMiniMapScale(miniMapScale, gMapScaleType.Parkour)
		end
	end,
	UpdateParkourProwlState = function (self)
		local isProwl = false
		local clientStates = gMainMenuMgr:GetClientState()

		for _, key in pairs(clientStates) do
			if key == ParkourStateConfig.Prowl then
				isProwl = true

				break
			end
		end

		if self._isProwling == isProwl then
			return
		end

		self._isProwling = isProwl

		gMessageManager:SendMessage(gEventConstants.ON_PROWL_STATE_CHANGE, isProwl)
	end,
	OnMyUnitStateChange = function (self)
		local unit = gCS.MyPlayerManager.PlayerUnit

		if L50.L50App.Scene.GamePlayUtils:UnitIsNull(unit) then
			return
		end

		if gCS.UnitStateMgr:HasState(unit, LTConfig.UnitStateConfig.FightS) then
			gMapManager:SetMiniMapScale(LTConfig.GameConfig.BattleMoodMiniMapScale, gMapScaleType.Fight)
		else
			gMapManager:RemoveMiniMapScaleType(gMapScaleType.Fight)
		end
	end,
	SetHudGpsHideReason = function (self, id, hide)
		if not self._disableHudGps then
			print_warn("调用时机错误, MapSubSystem没有初始化")

			return
		end

		if hide then
			self._disableHudGps[id] = true
		else
			self._disableHudGps[id] = nil
		end
	end,
	IsHudGpsEnabled = function (self)
		if not self._disableHudGps then
			print_warn("调用时机错误, MapSubSystem没有初始化")

			return
		end

		return not next(self._disableHudGps)
	end,
	OnBigMapOpen = function (self)
		for _, subSystem in pairs(self.env.subSystems) do
			local status, err = xpcall(subSystem.OnBigMapOpen, tolua.traceback, subSystem)

			if not status then
				print_error("MapSubSystem Login Failed: " .. subSystem._name .. "\n", err)
			end
		end
	end
}

function M:IsBigMapAvailable(logError)
	local raidId = self.env.lastRaidId
	local indoorId = self.env.lastIndoorId

	if not gSystemUnlockMgr:IsUnlock(LTConfig.SystemUnlockConfig.BigMapUnlock) then
		return false
	end

	local cfg = RaidConfig.GetConfig(raidId)

	if not cfg then
		if logError then
			print_error("RaidConfig表中找不到raidId=" .. raidId .. "的数据")
		end

		return false
	else
		local canOpen = nil

		if indoorId == 0 and (raidId == RaidConfig.WorldMap or raidId == RaidConfig.Chongxiao) then
			canOpen = true
		else
			local mapCfg = nil

			if indoorId ~= 0 then
				mapCfg = IndoorConfig.GetConfig(indoorId)
			else
				mapCfg = SceneConfig.GetConfig(cfg.SceneId)
			end

			local raidTypeCfg = LTConfig.RaidRaidTypeConfig.GetConfig(cfg.RaidType)
			canOpen = raidTypeCfg and raidTypeCfg.CanOpenMap and mapCfg and mapCfg.SMapName and mapCfg.SMapName > 0
		end

		return canOpen
	end
end

function M:HudHasOpenBigMapTip()
	return self._bigMapAccess and gMapSubSystem_Task:HudHasOpenBigMapTip()
end

local PoiConfig = LTConfig.CollectionPoiAreaConfig
local PopupConfig = LTConfig.PopupConfig

function M:OnPoiAreaChange(poiId)
	if self.lastPoiPopTime and Time.time - self.lastPoiPopTime < PopupConfig.PoiAreaPopUpCd then
		return
	end

	if poiId == 0 then
		return
	end

	local cfg = PoiConfig.GetConfig(poiId)

	if not cfg then
		print_error("MapSystem OnPoiAreaChange cfg for poiId not found: ", poiId)

		return
	end

	gNewPopupManager:PushPopup(LTConfig.PopupConfig.MapPOIMessage, {
		poiName = cfg.PoiName
	})

	self.lastPoiPopTime = Time.time
end

function M:SetBigMapGuideInterest(instanceId)
	self._bigMapInterestByGuideIdSet[instanceId] = true
end

function M:ClearBigMapGuideInterest(instanceId)
	self._bigMapInterestByGuideIdSet[instanceId] = nil
end

function M:ClearAllBigMapGuideInterest()
	self._bigMapInterestByGuideIdSet = {}
end

function M:IsBigMapGuideInterest(instanceId)
	return self._bigMapInterestByGuideIdSet[instanceId] or false
end

function M:GetAllBigMapGuideInterest()
	return self._bigMapInterestByGuideIdSet
end

function M:OnEnterSafeOrDangerArea(isSafe)
	gNewPopupManager:PushPopup(LTConfig.PopupConfig.MapSafeAreaMessage, {
		isSafe = isSafe
	})
end

return M
