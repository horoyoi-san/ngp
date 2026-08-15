local M = C_NewMapPanelStore

function M:InitMainRectInteraction()
	self.fingerState = {
		first = {
			touched = false,
			touching = false
		},
		second = {
			touched = false,
			touching = false
		}
	}
	local gestureListener = self.bindData.mainRayBoxRT:GetComponent(typeof(SGUI.EventSystems.GestureEventListener))
	self.mainGestureListener = gestureListener
	local clickEventListener = self.bindData.mainRayBoxRT:GetComponent(typeof(SGUI.EventSystems.ClickEventListener))

	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		gestureListener.onFingerStateChange = self:CreateAction("OnFingerStateChange")
	else
		gestureListener.onZoom = self:CreateAction("OnGestureZoom")
	end

	clickEventListener.onClick = self:CreateAction("OnMainClick")
	clickEventListener.onPress = self:CreateAction("OnMainPress")
	clickEventListener.onRelease = self:CreateAction("OnMainRelease")
end

function M:OnFingerStateChange(firstFingerState, secondFingerState)
	self.fingerState.first.touching = firstFingerState
	self.fingerState.second.touching = secondFingerState
end

function M:TickFinger()
	local touching1 = self.fingerState.first.touching
	local touching2 = self.fingerState.second.touching
	local touched1 = self.fingerState.first.touched
	local touched2 = self.fingerState.second.touched
	local touchRootPos1 = nil

	if touching1 then
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

	if dragging1 and dragging2 then
		self:AlignMapPos2Finger(self.fingerState.first.touchedTexPos, touchRootPos1, self.fingerState.second.touchedTexPos, touchRootPos2)
	elseif dragging1 then
		self:AlignMapPos(self.fingerState.first.touchedTexPos, touchRootPos1)
	elseif dragging2 then
		self:AlignMapPos(self.fingerState.second.touchedTexPos, touchRootPos2)
	end

	self.fingerState.first.touched = touching1
	self.fingerState.first.touchedTexPos = touching1 and self:TransformUIToTex(touchRootPos1) or nil
	self.fingerState.second.touched = touching2
	self.fingerState.second.touchedTexPos = touching2 and self:TransformUIToTex(touchRootPos2) or nil
end

function M:OnGestureZoom(val)
	if self:HasOperation() or self._showingCandidate then
		return
	end

	if self:CheckMouseScrollConflict() then
		return
	end

	self:SetScale(math.exp(math.log(self.scale) + val * 0.002))
end

function M:OnMainClick(evtData)
	if gGameManager.Env.isEditor and evtData.button == 1 then
		local uiPos = self:GetPointerUIPos()
		local texPos = self:TransformUIToTex(uiPos)
		local areaId, worldPos = self:TryTransformTexToWorld(texPos)

		if areaId then
			local raidId, _ = gMapSystem.area:SplitAreaId(areaId)

			if raidId == gMapSystem.lastRaidId then
				L50.Gm.AutoQaFunctions.TeleportToPos(worldPos.x, worldPos.z)
				gMainPhoneUtils.CloseMainPhonePanel(true)
				self:OnBtnClose()
			end
		end
	end

	if not self._pressUIPos then
		return
	end

	if not gCS.LuaUtils.IsNotUseGM and L50.Gm.AutoQaFunctions.GetMapClickToTeleport() and evtData.button == 0 then
		local pressDuration = os.clock() - self._pressTime
		local curUIPos = self:GetPointerUIPos()
		local sqrDist = (curUIPos - self._pressUIPos).sqrMagnitude

		if pressDuration < 0.3 and sqrDist < 80 then
			local uiPos = self:GetPointerUIPos()
			local texPos = self:TransformUIToTex(uiPos)
			local areaId, worldPos = self:TryTransformTexToWorld(texPos)

			if areaId == gMapSystem.lastAreaId then
				L50.Gm.AutoQaFunctions.TeleportToPos(worldPos.x, worldPos.z)
				gMainPhoneUtils.CloseMainPhonePanel(true)
				self:OnBtnClose()
			end
		end

		self._pressTime = os.clock()
	end
end

function M:OnMainPress(evtData)
	if evtData.button == 1 then
		return
	end

	if not self._showingCandidate and gCS.LuaUtils.IsNonMobileAdaptive() then
		self._stateProps.dragging = true
	end

	self._stateProps.dragTexPos = self:TransformUIToTex(self:GetPointerUIPos())

	if evtData.button == 0 or evtData.button == 2 then
		self:HideElementList()

		self._pressUIPos = self:GetPointerUIPos()
	end
end

function M:OnMainRelease(evtData)
	if evtData.button == 1 then
		return
	end

	self._stateProps.dragging = false

	if not self._pressUIPos then
		return
	end

	local curUIPos = self:GetPointerUIPos()
	local sqrDist = (curUIPos - self._pressUIPos).sqrMagnitude

	if sqrDist < 100 then
		if evtData.button == 0 then
			self:OnMapRectClick(curUIPos)
		elseif evtData.button == 2 and gMapSystem:CheckDebugSwitch(EMapSystemDebugKey.EnableSubSystemDebug) then
			local areaId, worldPos = self:TryTransformTexToWorld(self:TransformUIToTex(curUIPos))

			if areaId then
				local raidId, _ = gMapSystem.area:SplitAreaId(areaId)

				gMapSubSystem_Debug:AddElement("BigMap_ClickDebug", raidId, worldPos)
			end
		end
	end
end
