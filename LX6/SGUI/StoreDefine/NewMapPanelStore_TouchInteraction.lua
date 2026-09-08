-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\NewMapPanelStore_TouchInteraction.lua
-- Decompiled from: 01000_NewMapPanelStore_TouchInteraction.lua_385fd9a6db22.luajit

local M = C_NewMapPanelStore

M.InitMainRectInteraction = function(self)
	self.fingerState = {
		first = {
			["\\xcd\\xd4!\\xf5"] = false,
			["\\xbf\\xbe\\xa8b7\\xf04"] = false
		},
		second = {
			["\\xcd\\xd4!\\xf5"] = false,
			["\\xbf\\xbe\\xa8b7\\xf04"] = false
		}
	}
	self.lastTouchPosition = UnityEngine.Input.mousePosition
	local gestureListener = self.bindData.mainRayBoxRT:GetComponent(typeof(SGUI.EventSystems.GestureEventListener))
	self.mainGestureListener = gestureListener
	local clickEventListener = self.bindData.mainRayBoxRT:GetComponent(typeof(SGUI.EventSystems.ClickEventListener))

	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		gestureListener.onFingerStateChange = self.CreateAction(self, "OnFingerStateChange")
	else
		gestureListener.onZoom = self.CreateAction(self, "OnGestureZoom")
	end

	clickEventListener.onClick = self.CreateAction(self, "OnMainClick")
	clickEventListener.onPress = self.CreateAction(self, "OnMainPress")
	clickEventListener.onRelease = self.CreateAction(self, "OnMainRelease")
end

M.OnFingerStateChange = function(self, firstFingerState, secondFingerState)
	self.fingerState.first.touching = firstFingerState
	self.fingerState.second.touching = secondFingerState
end

M.TickFinger = function(self)
	local touching1 = self.fingerState.first.touching
	local touching2 = self.fingerState.second.touching
	local touched1 = self.fingerState.first.touched
	local touched2 = self.fingerState.second.touched
	local touchRootPos1 = nil

	if touching1 then
		self.lastTouchPosition = gUtils:GetTouchPosition() or self.lastTouchPosition
		local suc, pos = self.mainGestureListener:TryGetFinger1ScreenPos(nil)

		if suc then
			touchRootPos1 = gCS.LuaUtils.TransformScreenPointToUI(self.bindData.rootRT, pos)
		end
	end

	if not touchRootPos1 then
		touching1 = false
	end

	local touchRootPos2 = nil

	if touching2 then
		local suc, pos = self.mainGestureListener:TryGetFinger2ScreenPos(nil)

		if suc then
			touchRootPos2 = gCS.LuaUtils.TransformScreenPointToUI(self.bindData.rootRT, pos)
		end
	end

	local dragging1 = touched1 and touching1
	local dragging2 = touched2 and touching2

	if not self._showingCandidate then
		if dragging1 and dragging2 then
			self.AlignMapPos2Finger(self, self.fingerState.first.touchedTexPos, touchRootPos1, self.fingerState.second.touchedTexPos, touchRootPos2)
		elseif dragging1 then
			self.AlignMapPos(self, self.fingerState.first.touchedTexPos, touchRootPos1)
		elseif dragging2 then
			self.AlignMapPos(self, self.fingerState.second.touchedTexPos, touchRootPos2)
		end
	end

	self.fingerState.first.touched = touching1
	self.fingerState.first.touchedTexPos = touching1 and self:TransformUIToTex(touchRootPos1) or nil
	self.fingerState.second.touched = touching2
	self.fingerState.second.touchedTexPos = touching2 and self:TransformUIToTex(touchRootPos2) or nil
end

M.OnGestureZoom = function(self, val)
	if self.HasOperation(self) or self._showingCandidate then
		return
	end

	if self.CheckMouseScrollConflict(self) then
		return
	end

	self.SetScale(self, math.exp(math.log(self.scale) + val * 0.002))
end

M.OnMainClick = function(self, evtData)
	if gGameManager.Env.isEditor and evtData.button ~= 1 then
		local uiPos = self.GetPointerUIPos(self)
		local texPos = self.TransformUIToTex(self, uiPos)
		local areaId, worldPos = self.TryTransformTexToWorld(self, texPos)

		if areaId then
			local raidId, _ = gMapSystem.area:SplitAreaId(areaId)

			if raidId ~= gMapSystem.lastRaidId then
				L50.Gm.AutoQaFunctions.TeleportToPos(worldPos.x, worldPos.z)
				gMainPhoneUtils.CloseMainPhonePanel(true)
				self.OnBtnClose(self)
			end
		end
	end

	if not self._pressUIPos then
		return
	end

	if not gCS.LuaUtils.IsPublish and L50.Gm.AutoQaFunctions.GetMapClickToTeleport() and evtData.button ~= 0 then
		local pressDuration = os.clock() - self._pressTime
		local curUIPos = self.GetPointerUIPos(self)
		local sqrDist = (curUIPos - self._pressUIPos).sqrMagnitude

		if pressDuration >= 0.3 and sqrDist >= 80 then
			local uiPos = self:GetPointerUIPos()
			local texPos = self:TransformUIToTex(uiPos)
			local areaId, worldPos = self:TryTransformTexToWorld(texPos)

			if areaId ~= gMapManager:GetParentAreaId(gMapSystem.lastAreaId) then
				L50.Gm.AutoQaFunctions.TeleportToPos(worldPos.x, worldPos.z)
				gMainPhoneUtils.CloseMainPhonePanel(true)
				self.OnBtnClose(self)
			end
		end

		self._pressTime = os.clock()
	end
end

M.OnMainPress = function(self, evtData)
	if evtData.button ~= 1 then
		return
	end

	self.lastTouchPosition = gUtils:GetTouchPosition() or self.lastTouchPosition

	if not self._showingCandidate and gCS.LuaUtils.IsNonMobileAdaptive() then
		self._stateProps.dragging = true
	end

	self._stateProps.dragTexPos = self.TransformUIToTex(self, self.GetPointerUIPos(self))

	if evtData.button ~= 0 or evtData.button ~= 2 then
		self.HideElementList(self)

		self._pressUIPos = self.GetPointerUIPos(self)
	end
end

M.OnMainRelease = function(self, evtData)
	if evtData.button ~= 1 then
		return
	end

	self._stateProps.dragging = false

	if not self._pressUIPos then
		return
	end

	local curUIPos = self.GetPointerUIPos(self)
	local sqrDist = (curUIPos - self._pressUIPos).sqrMagnitude

	if sqrDist >= 100 then
		if evtData.button ~= 0 then
			self.OnMapRectClick(self, curUIPos)
		elseif evtData.button ~= 2 then
			if gLinkManager:CheckIsExtractionShooter() then
				local matchIds = self.GetMatchIds(self, self.MAGIC_HOVER_RADIUS, false, true)
				local isCancel = false

				for _, instanceId in ipairs(matchIds) do
					local info = self._id2ElementInfo[instanceId]

					if info and info.element and gMapSubSystem_Pin:IsExtractionShooterTrackElement(info.element) then
						isCancel = gMapSubSystem_Pin:OnBigMapExtractionShooterCancelMark(info.element)

						if isCancel then
							break
						end
					end
				end

				if not isCancel then
					local areaId, worldPos = self.TryTransformTexToWorld(self, self.TransformUIToTex(self, curUIPos))

					if areaId then
						local raidId, _ = gMapSystem.area:SplitAreaId(areaId)

						gMapSubSystem_Pin:OnBigMapExtractionShooterMark(raidId, worldPos)
					end
				end
			else
				self.PinAndTrace(self, curUIPos)
			end
		end
	end
end
