local bit = require("bit")
local M = C_NewMapPanelStore
EControllerPointerHideMask = {
	SwitchMapMode = 4,
	FilterPanel = 2,
	CharacterList = 1,
	RightTopFilterList = 8,
	LegendList = 16,
	None = 0
}

function M:InitInteraction()
	self._curHoverId = nil
	self._manualAttaching = false
	self.bindData.controllerAttachIndicator.luaClick = self:CreateAction("OnControllerAttachIndicator")
	self.controllerPointerHideMask = 0

	self:RegisterConflictComp("Candidate", function ()
		self:HideCandidatePanel()
	end)

	self.bindData.controllerPin.luaClick = self:CreateAction("OnControllerPinBtn")
	self.bindData.rightStickZoom.luaGamePadInputChanged = self:CreateAction("OnRightStickZoom")
	self.bindData.controllerZoomInBtn.luaPress = self:CreateActionWithArgs("OnControllerZoomIn", true)
	self.bindData.controllerZoomInBtn.luaRelease = self:CreateActionWithArgs("OnControllerZoomIn", false)
	self.bindData.controllerZoomOutBtn.luaPress = self:CreateActionWithArgs("OnControllerZoomOut", true)
	self.bindData.controllerZoomOutBtn.luaRelease = self:CreateActionWithArgs("OnControllerZoomOut", false)
	local leftJS = self.bindData.controllerLeftJoyStickRT:GetComponent(typeof(SGUI.UCustomNavRespond))
	leftJS.luaGamePadInputChanged = self:CreateAction("OnLeftJoyStickMove")
end

function M:RefreshCloseBtnState()
	if self._showingCandidate or self._isShowingMobileFilter or self.bindData.MobileShowMainPageCtrl == 1 then
		self.bindData.leftTopCloseBtn:SetActive(false)
	else
		self.bindData.leftTopCloseBtn:SetActive(true)
	end
end

function M:GetCharacterHeadIconIdById(id)
	local cfg = LTConfig.FightSpiritConfig.GetConfig(id)

	if not cfg then
		print_debug("FightSpiritConfig 里不存在 " .. id)

		return nil
	end

	return cfg.SHeadIconID
end

function M:TickHover()
	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.hoverRoot:SetActiveFastest(false)

		return
	end

	local ids = self:GetMatchIds(self.MAGIC_HOVER_RADIUS, true)

	if not self.enableController and not self._showingCandidate and ids and #ids > 0 and gCS.LuaUtils.GetCurrentHoverGo() == self.bindData.mainRayBoxRT.gameObject then
		local id = ids[1]
		self.bindData.curHoverName = self._id2ElementInfo[id].element:GetName()
		local info = self._id2ElementInfo[id]

		if info.store.visualCenter then
			self.bindData.hoverRoot.rectTransform.position = info.store.visualCenter.position
		else
			local texX = info.texPos.x
			local texY = info.texPos.y
			local uiX, uiY = self:TransformTexToUIXY(texX, texY)

			self.bindData.hoverRoot.rectTransform:SetLocalPositionXY(uiX, uiY)
		end

		self.bindData.hoverRoot:SetActiveFastest(true)

		if self._curHoverId ~= id then
			self.bindData.hoverAnim:Stop()
			self.bindData.hoverAnim:Play(self.HOVER_FOCUS)
			self.bindData.hoverAnim:PlayQueued(self.HOVER_LOOP)
			self.bindData.hoverAnim:Sample()
		end

		self:SetHover(id)

		if self._holdingHoverAction and self._curHoverElementFirstAction then
			self._hoverActionTimer = self._hoverActionTimer + UnityEngine.Time.unscaledDeltaTime

			if self._hoverActionTimer > 0.5 then
				local element = self._id2ElementInfo[id].element

				self:OnPerformAction(element, self._curHoverElementFirstAction, true)
				self:SetHover(nil)
			end
		end
	else
		self.bindData.hoverAnim:Stop()
		self.bindData.hoverRoot:SetActiveFastest(false)
		self:SetHover(nil)
	end

	self.bindData.hoverActionFillAmount = self._holdingHoverAction and self._hoverActionTimer / 0.5 or 0
end

function M:SetHover(id)
	if self._curHoverId == id then
		return
	end

	local oldId = self._curHoverId
	self._curHoverId = id

	if oldId then
		self:ClearShowMask(oldId, EBigMapElementShowMask.Hover)

		local info = self._id2ElementInfo[oldId]

		if info then
			self:RefreshIconLayer(info)
		end
	end

	self._hoverActionTimer = 0

	if id then
		gSoundMgr:PlaySoundByTid(70601120)
		self:SetShowMask(id, EBigMapElementShowMask.Hover)

		local info = self._id2ElementInfo[id]

		if info then
			self:RefreshIconLayer(info)
		end

		local actions, actionsBlockReason = info.element:GetActionInfos()
		local action = actions and #actions > 0 and actions[1] or nil

		self:SetupHoverActionCtx(action, actionsBlockReason)
	else
		self:SetupHoverActionCtx(nil)
	end
end

function M:SetupHoverActionCtx(action, blockReason)
	if blockReason then
		self.bindData.hoverActionName = blockReason
		self.bindData.hasHoverAction1 = 1
		self.bindData.hasHoverActionKey = 0
	elseif action then
		self._curHoverElementFirstAction = action
		self.bindData.hoverActionName = gMapUIUtils.GetElementActionName(action)
		self.bindData.hasHoverAction1 = 1
		self.bindData.hasHoverActionKey = 1
	else
		self._holdingHoverAction = false
		self._curHoverElementFirstAction = nil
		self.bindData.hoverActionName = ""
		self.bindData.hasHoverAction1 = 0
		self.bindData.hasHoverActionKey = 0
	end
end

function M:OnHoverFastActionBtn(ctx)
	if ctx.started then
		self._holdingHoverAction = true
		self._hoverActionTimer = 0
	elseif ctx.canceled then
		self._holdingHoverAction = false
		self._hoverActionTimer = 0
	end
end

function M:PreTickController()
	local fixedDt = UnityEngine.Time.deltaTime
	local signZoom = self.ctrlerInput.zoomInTrigger - self.ctrlerInput.zoomOutTrigger + self.ctrlerInput.zoomDir

	if signZoom ~= 0 then
		self:SetScale(self.scale + signZoom * self.CONTROLLER_ZOOM_SCALE * fixedDt)
	end

	if self.enableController then
		if not self:HasOperation() then
			local pointerUiDelta = nil

			if self.ctrlerInput.leftJS then
				self:HideLeftHoverPanel()
				self:ResetControllerPointerAnim()
				self:ClearControllerDropdownCtx()
				self:SetSelected(nil)

				pointerUiDelta = self.ctrlerInput.leftJS * self.CONTROLLER_POINTER_SENSITIVITY
			elseif self.gamePadTouchOffset then
				pointerUiDelta = self.gamePadTouchOffset * LTConfig.GameConfig.BigMapGamePadTouchMovementSensitivity

				if self.isGamePadTouchRunning and not self.isGamePadTouchTrigger then
					self.isGamePadTouchRunning = false
					self.gamePadTouchOffset = nil
				end

				self.isGamePadTouchTrigger = false
			elseif self.gamePadTouchScale then
				if self.isGamePadTouchTwoFingerRunning and not self.isGamePadTouchTwoFingerTrigger then
					self.isGamePadTouchTwoFingerRunning = false
					self.gamePadTouchScale = nil
				end

				self.isGamePadTouchTwoFingerTrigger = false
			elseif self._showingAreaList then
				self:ResetControllerPointerAnim()
				self:ClearControllerDropdownCtx()
			elseif self.controllerPointerHideMask > 0 then
				self:ClearControllerDropdownCtx()
			elseif not self.selectedGpsId and not self._manualAttaching then
				self:CheckControllerDropdownCtx()

				if not self:HasControllerDropdownCtx() then
					local matchIds = self:GetMatchIds(self.CONTROLLER_ATTACH_RANGE)

					if #matchIds > 0 then
						self:SetControllerAttachCtx(matchIds)
					else
						self:ResetControllerPointerAnim()
					end
				end
			end

			pointerUiDelta = self:TickControllerAttachCtx() or pointerUiDelta

			if pointerUiDelta then
				local uiPos = self:TransformTexToUI(self.controllerTexPos)
				uiPos = uiPos + pointerUiDelta
				self.controllerTexPos = self:TransformUIToTex(uiPos)
			end
		end

		local rootRTTexHalfSize = nil
		local clampTexMin = self.clampTexMin
		local clampTexMax = self.clampTexMax

		if not self:IsBigWorld() then
			local rootSize = self:GetRootSize()
			local rootSizeExceptMainPage = gCS.LuaUtils.GetRectTransformSize(self.bindData.areaExceptMainPage.rectTransform)
			local halfTexRootSize = 0.5 * rootSize / self.scale
			local mapHalfTexSize = self.mapCfg.mapSize * 0.5
			clampTexMin = clampTexMin - (mapHalfTexSize + halfTexRootSize)
			clampTexMax = clampTexMax + mapHalfTexSize + halfTexRootSize - (rootSize - rootSizeExceptMainPage) / self.scale
		end

		self:ClampTexPosWithMainPage(self.controllerTexPos, clampTexMin, clampTexMax)
	else
		self.controllerTexPos = self:TransformUIToTex(Vector2.zero)

		self:ClearControllerDropdownCtx()
	end
end

function M:ClampTexPosWithMainPage(texPos, minTexPos, maxTexPos)
	if not texPos then
		return
	end

	if maxTexPos.x < texPos.x then
		texPos.x = maxTexPos.x
	elseif texPos.x < minTexPos.x then
		texPos.x = minTexPos.x
	end

	if texPos.y < minTexPos.y then
		texPos.y = minTexPos.y
	else
		local rootSize = gCS.LuaUtils.GetRectTransformSize(self.bindData.rootRT)
		local rootSizeExceptMainPage = gCS.LuaUtils.GetRectTransformSize(self.bindData.areaExceptMainPage.rectTransform)
		local dHeight = rootSize.y - rootSizeExceptMainPage.y
		local maxY = maxTexPos.y - dHeight / self.scale

		if maxY < texPos.y then
			texPos.y = maxY
		end
	end
end

function M:OnControllerAttachIndicator()
	local ids = {
		-1
	}

	for id, _ in pairs(self._indicatorData) do
		table.insert(ids, id)
	end

	self._manualAttaching = true

	self:SetControllerAttachCtx(ids, 10)
end

function M:SetControllerAttachCtx(ids, speedMultiplier)
	if ids == nil or #ids == 0 then
		self:ClearControllerDropdownCtx()

		return
	end

	speedMultiplier = speedMultiplier or 1

	self.bindData.controllerAttachPanel.gameObject:SetActive(true)

	if self.controllerAttachCtx then
		local oldIds = self.controllerAttachCtx.ids
		self.controllerAttachCtx = nil

		for _, id in pairs(oldIds) do
			if id ~= -1 then
				self:RefreshIconLayer(self._id2ElementInfo[id])
				self:ClearShowMask(id, EBigMapElementShowMask.ControllerMatch)
			end
		end
	end

	self.controllerAttachCtx = {
		curIdx = 1,
		ids = ids,
		speedMultiplier = speedMultiplier
	}

	self:PlayQueueControllerPointerAnim()

	local renderData = {}

	for i, id in ipairs(ids) do
		if id == -1 then
			local curSpiritTid = gSpiritManager:GetCurFirstSpiritTid()
			local iconId = self:GetCharacterHeadIconIdById(curSpiritTid)

			if iconId == nil then
				print_error("@xiajingbo01 没有获取到人物头像 curSpiritTid:" .. curSpiritTid)

				iconId = 28003372
			end

			table.insert(renderData, {
				gpsId = -1,
				name = gPlayerManager.infoLogin.bindData.name,
				iconId = iconId,
				index = i
			})
		else
			self:SetShowMask(id, EBigMapElementShowMask.ControllerMatch)

			local info = self._id2ElementInfo[id]

			self:RefreshIconLayer(info)
			table.insert(renderData, {
				gpsId = id,
				name = info.element:GetName(),
				iconId = self:GetIconId(info.element),
				index = i
			})
		end
	end

	self.controllerAttachListRenderData = renderData

	self.bindData.controllerAttachList:SetSimpleList(#renderData)
end

function M:TickControllerAttachCtx()
	if not self.controllerAttachCtx then
		return nil
	end

	local id = self.controllerAttachCtx.ids[self.controllerAttachCtx.curIdx]
	local action, targetUiPos = nil

	if id ~= -1 then
		local info = self._id2ElementInfo[id]
		local element = info.element
		local actions, blockReason = element:GetActionInfos()

		if blockReason then
			action = nil
		else
			action = actions[1]
		end

		if info.store.visualCenter then
			targetUiPos = self.bindData.controllerAttachPanel.rectTransform.parent:InverseTransformPoint(info.store.visualCenter.position)
		else
			targetUiPos = self:TransformTexToUI(info.texPos)
		end

		self.bindData.controllerAttachSelectBtn:SetActive(true)
	else
		local texPos = self.bindData.playerRT.localPosition
		targetUiPos = self:TransformTexToUI(texPos)
		action = nil

		self.bindData.controllerAttachSelectBtn:SetActive(false)
	end

	if not action then
		self.bindData.controllerAttachActionBtn1:SetActive(false)
	else
		self.bindData.controllerAttachActionBtn1:SetActive(true)

		self.bindData.controllerAttachActionName1 = gMapUIUtils.GetElementActionName(action)
	end

	local ptrUiPos = self:TransformTexToUI(self.controllerTexPos)
	local delta = targetUiPos - ptrUiPos
	local dir = Vector2.Normalize(delta)
	local distance = Vector2.Magnitude(delta)
	local step = self.CONTROLLER_POINTER_ATTACH_SPEED * UnityEngine.Time.deltaTime * self.controllerAttachCtx.speedMultiplier
	local delta = dir * (distance > step and step or distance)

	if distance < step then
		self:ShowControllerAttachCtxMenu()
	end

	self.bindData.controllerAttachPanel.localPosition = targetUiPos

	return delta
end

function M:ShowControllerAttachCtxMenu()
	if self._showingControllerAttachMenu then
		return
	end

	self._showingControllerAttachMenu = true

	self.bindData.controllerAttachPanel:SetActive(true)
	self.bindData.controllerAttachList:SelectItem(0)
	gSoundMgr:PlaySoundByExternalSource("ExHandle_click_03", LX6.Audio.ExternalSourceType.Motion_2D)
end

function M:HasControllerDropdownCtx()
	return self.controllerAttachCtx ~= nil or self.controllerIndicatorCtx ~= nil
end

function M:CheckControllerDropdownCtx()
	if self.controllerAttachCtx then
		for i, id in ipairs(self.controllerAttachCtx.ids) do
			local info = self._id2ElementInfo[id]

			if not info or info.showMask < info.hideMask or info.showMask == 0 then
				self:ClearControllerDropdownCtx()

				return
			end
		end
	end
end

function M:ClearControllerDropdownCtx()
	self._manualAttaching = false

	if self.controllerAttachCtx then
		for _, id in ipairs(self.controllerAttachCtx.ids) do
			if id ~= -1 and self._id2ElementInfo[id] then
				self:RefreshIconLayer(self._id2ElementInfo[id])
				self:ClearShowMask(id, EBigMapElementShowMask.ControllerMatch)
				self:ClearShowMask(id, EBigMapElementShowMask.ControllerAttach)
			end
		end

		self.controllerAttachCtx = nil
	end

	self.controllerIndicatorCtx = nil
	self._showingControllerAttachMenu = false

	self.bindData.controllerAttachPanel:SetActive(false)
	self.bindData.controllerAttachList:SetSimpleList(0)
end

function M:PlayQueueControllerPointerAnim()
	self.controllerPointerAnim:Stop()
	self.controllerPointerAnim:Play(self.CONTROLLER_POINTER_OPEN)
	self.controllerPointerAnim:PlayQueued(self.CONTROLLER_POINTER_LOOP)
end

function M:ResetControllerPointerAnim()
	self.controllerPointerAnim:Stop()
	self.controllerPointerAnim:Play(self.CONTROLLER_POINTER_OPEN)
	self.controllerPointerAnim:Sample()
	self.controllerPointerAnim:Stop()
end

function M:OnClickControllerAttachSelect()
	local id = self.controllerAttachCtx.ids[self.controllerAttachCtx.curIdx]
	local info = self._id2ElementInfo[id]

	if not info then
		return
	end

	local element = self._id2ElementInfo[id].element

	if element then
		self:ScheduleOperation(self.OperationType.Select, {
			gpsId = element.gpsId,
			source = EBigMapSelectSource.ClickElement
		})
	end
end

function M:OnClickControllerAttachAction1()
	local id = self.controllerAttachCtx.ids[self.controllerAttachCtx.curIdx]
	local element = self._id2ElementInfo[id].element
	local action1 = element:GetRawActions()[1]

	if action1 then
		self:OnPerformAction(element, action1, true)
	end
end

function M:SetControllerMouseHideMask(mask, enable)
	if enable then
		self.controllerPointerHideMask = bit.bor(self.controllerPointerHideMask, mask)
	else
		self.controllerPointerHideMask = bit.band(self.controllerPointerHideMask, bit.bnot(mask))
	end

	if self.enableController then
		if self.controllerPointerHideMask ~= 0 then
			self.bindData.controllerPointer:SetActive(false)
		else
			self.bindData.controllerPointer:SetActive(true)
		end
	end
end

function M:RegisterConflictComp(type, hideFunc)
	self.conflictCompHideFuncs = self.conflictCompHideFuncs or {}
	self.conflictCompHideFuncs[type] = hideFunc
end

function M:UnRegisterConflictComp(type)
	if self.conflictCompHideFuncs then
		self.conflictCompHideFuncs[type] = nil
	end
end

function M:HideConflictComps(curType)
	for type, hide in pairs(self.conflictCompHideFuncs or {}) do
		if type ~= curType then
			hide()
		end
	end
end

function M:HideCandidatePanel()
	self._showingCandidate = false

	if self._candidateIds then
		for _, id in ipairs(self._candidateIds) do
			self:ClearShowMask(id, EBigMapElementShowMask.Match)
		end
	end

	self.bindData.matchScrollRect:SetActive(false)
	self:RefreshCloseBtnState()
end

function M:ShowCandidatePanel(ids)
	self._showingCandidate = true

	if self._candidateIds then
		for _, id in ipairs(self._candidateIds) do
			self:ClearShowMask(id, EBigMapElementShowMask.Match)
		end
	end

	self._candidateIds = ids
	local pivot = nil
	local pointerUIPos = self:GetPointerUIPos()

	if pointerUIPos.x > 0 and pointerUIPos.y > 0 then
		pivot = Vector2.New(1, 1)
	elseif pointerUIPos.x > 0 and pointerUIPos.y < 0 then
		pivot = Vector2.New(1, 0)
	elseif pointerUIPos.x < 0 and pointerUIPos.y > 0 then
		pivot = Vector2.New(0, 1)
	else
		pivot = Vector2.New(0, 0)
	end

	self.bindData.matchScrollRect.rectTransform.pivot = pivot

	self.bindData.matchScrollRect.rectTransform:SetLocalPositionXY(0, 0)
	self.bindData.matchScrollRect:GoToPos(Vector2.zero, true)

	self.bindData.matchRT.localPosition = self:GetPointerUIPos()

	self.bindData.matchScrollRect:SetActive(true)

	local infos = {}

	for _, id in ipairs(ids) do
		self:SetShowMask(id, EBigMapElementShowMask.Match)

		local info = self._id2ElementInfo[id]

		table.insert(infos, {
			gpsId = info.element.gpsId,
			name = info.element:GetName(),
			iconId = self:GetIconId(info.element)
		})
	end

	self.matchList:SetList(infos)
	self:RefreshCloseBtnState()
	self:HideConflictComps("Candidate")
end

function M:InitOperation()
	self.OperationType = {
		WaitFocus = 6,
		FocusTexPos = 3,
		Select = 5,
		WaitSelect = 4
	}
	self.OperationProcessor = {
		[self.OperationType.FocusTexPos] = "Operation_FocusTexPos",
		[self.OperationType.Select] = "Operation_Select",
		[self.OperationType.WaitSelect] = "Operation_WaitSelect",
		[self.OperationType.WaitFocus] = "Operation_WaitFocus"
	}
	self.OperationState = {
		Done = 1,
		Running = 0,
		Squash = 2
	}
	self.focusTexSpeed = 13000
	self._opQueue = {}
	self._curOp = nil
end

function M:TickOperation()
	self:TryFetchNextOperation()

	if self._curOp then
		local execName = self.OperationProcessor[self._curOp.type]

		if not execName then
			print_error("@sunwei08: Map ScheduleProcessor type not found", self._curOp)

			self._curOp = nil

			return
		end

		local execFunc = execName and self[execName]

		if not execFunc then
			print_error("@sunwei08: Map ScheduleProcessor type not implement", self._curOp)

			self._curOp = nil

			return
		end

		local state = execFunc(self, self._curOp.data, self._curOp.ctx)

		if state == self.OperationState.Done then
			self._curOp = nil
		end
	end
end

function M:HasOperation()
	return self._curOp or #self._opQueue > 0
end

function M:TryFetchNextOperation()
	if not self._curOp and #self._opQueue > 0 then
		self._curOp = table.remove(self._opQueue, 1)
	end
end

function M:HasOperationOfType(type)
	if self._curOp and self._curOp.type == type then
		return true
	end

	for i = #self._opQueue, 1, -1 do
		if self._opQueue[i].type == type then
			return true
		end
	end

	return false
end

function M:ScheduleOperation(type, data, pushFront)
	if pushFront then
		table.insert(self._opQueue, 1, {
			type = type,
			data = data,
			ctx = {}
		})
	else
		table.insert(self._opQueue, {
			type = type,
			data = data,
			ctx = {}
		})
	end
end

function M:ClearScheduleOperation(type)
	for i = #self._opQueue, 1, -1 do
		if not type or self._opQueue[i].type == type then
			table.remove(self._opQueue, i)
		end
	end
end

local _tmpVec2 = Vector2.zero

function M:Operation_FocusTexPos(data, ctx)
	if not data or not data.texPos then
		return self.OperationState.Done
	end

	local targetTexPos = data.texPos
	local x, y = self:TransformUIToTexXY(0, 0)
	_tmpVec2.x = x
	_tmpVec2.y = y
	local dp = targetTexPos - _tmpVec2
	local dist = Vector2.Magnitude(dp)
	local step = self.focusTexSpeed * UnityEngine.Time.deltaTime

	if data.speedMultiplier then
		step = step * data.speedMultiplier
	end

	local nextTexPos = _tmpVec2 + step * Vector2.Normalize(dp)
	self.controllerTexPos = nextTexPos

	if dist <= step or not self:AlignMapPos(nextTexPos) then
		self:AlignMapPos(targetTexPos)

		self.controllerTexPos = targetTexPos

		return self.OperationState.Done
	end

	return self.OperationState.Running
end

function M:Operation_Select(data, ctx)
	local gpsId = data.gpsId

	self:RealSetSelected(gpsId, data.source)

	return self.OperationState.Done
end

function M:Operation_WaitFocus(data, ctx)
	local gpsId = data.gpsId
	local maxWaitTime = data.maxWaitTime
	ctx.waitTime = ctx.waitTime or 0

	if maxWaitTime and maxWaitTime < ctx.waitTime then
		print_debug("[BigMapStore] Operation_WaitSelect timeout gpsId =", gpsId)

		local timeOutMsg = data.timeOutMessage

		if timeOutMsg then
			gDisplayMessageMgr:ShowMessage(timeOutMsg)
		end

		return self.OperationState.Done
	end

	local id = gMapSystem:GetInstanceIdByGpsId(gpsId)
	local info = self._id2ElementInfo[id]

	if not info then
		ctx.waitTime = ctx.waitTime + Time.deltaTime

		return self.OperationState.Running
	end

	self:ScheduleOperation(self.OperationType.FocusTexPos, {
		texPos = info.texPos
	}, true)

	return self.OperationState.Done
end

function M:Operation_WaitSelect(data, ctx)
	local gpsId = data.gpsId
	local maxWaitTime = data.maxWaitTime
	ctx.waitTime = ctx.waitTime or 0

	if maxWaitTime and maxWaitTime < ctx.waitTime then
		print_debug("[BigMapStore] Operation_WaitSelect timeout gpsId =", gpsId)

		local timeOutMsg = data.timeOutMessage

		if timeOutMsg then
			gDisplayMessageMgr:ShowMessage(timeOutMsg)
		end

		return self.OperationState.Done
	end

	local id = gMapSystem:GetInstanceIdByGpsId(gpsId)
	local info = self._id2ElementInfo[id]

	if not info then
		local sameTargetInstanceIds = gGpsBindingMgr:GetAllInstanceIdsWithSameBinding(id)

		for _, instanceId in ipairs(sameTargetInstanceIds) do
			local sameInfo = self._id2ElementInfo[instanceId]

			if sameInfo then
				info = sameInfo
				gpsId = sameInfo.element.gpsId

				break
			end
		end
	end

	if not info then
		ctx.waitTime = ctx.waitTime + Time.deltaTime

		return self.OperationState.Running
	end

	self:ScheduleOperation(self.OperationType.Select, {
		gpsId = gpsId,
		source = data.source
	}, true)
	self:ScheduleOperation(self.OperationType.FocusTexPos, {
		texPos = info.texPos
	}, true)

	return self.OperationState.Done
end

EBigMapControllerKey = {
	SwitchSpirit = 1,
	SwitchMap = 2
}
EBigMapNavArea = {
	SwitchMapMode = 3,
	RightTopFilterList = 5,
	Main = 0,
	SwitchSpirit = 4,
	FilterMenu = 1,
	InScreenElementsList = 2
}
local controllerKeyConflictCfg = {
	[EBigMapControllerKey.SwitchSpirit] = {
		[EBigMapNavArea.FilterMenu] = true,
		[EBigMapNavArea.InScreenElementsList] = true,
		[EBigMapNavArea.SwitchMapMode] = true,
		[EBigMapNavArea.RightTopFilterList] = true
	},
	[EBigMapControllerKey.SwitchMap] = {
		[EBigMapNavArea.FilterMenu] = true,
		[EBigMapNavArea.InScreenElementsList] = true,
		[EBigMapNavArea.SwitchSpirit] = true,
		[EBigMapNavArea.RightTopFilterList] = true
	}
}

function M:InitControllerKeyConflict()
	self._controllerType2KeyWidget = {}
	self._navArea2Type = {}
	self._cachedControllerKeyActiveState = {}
	self._lastNavArea = nil

	self:RegisterNavArea(EBigMapNavArea.Main, self.bindData.mainNavArea)
	self:RegisterNavArea(EBigMapNavArea.Main, self.bindData.mainOnlyNavArea)
end

function M:RegisterControllerKey(keyType, keyWidget)
	self._controllerType2KeyWidget[keyType] = keyWidget
end

function M:UnRegisterControllerKey(keyType)
	self._controllerType2KeyWidget[keyType] = nil
end

function M:RegisterNavArea(areaType, area)
	self._navArea2Type[area] = areaType
end

function M:UnRegisterNavArea(areaType, area)
	self._navArea2Type[area] = nil
end

local NavMgr = SGUI.UNavigationMgr

function M:TickNavAreaChange()
	if self._lastNavArea == NavMgr.Inst.CurrentActiveArea then
		return
	end

	local oldArea = self._lastNavArea
	local newArea = NavMgr.Inst.CurrentActiveArea
	self._lastNavArea = newArea

	self:OnNavAreaChange(oldArea, newArea)
end

function M:OnNavAreaChange(oldArea, newArea)
	if not newArea then
		return
	end

	self:NotifyCompsOnNavAreaChange(oldArea, newArea)

	local newAreaType = self._navArea2Type[newArea]

	for keyType, widget in pairs(self._controllerType2KeyWidget) do
		local conflictCfg = controllerKeyConflictCfg[keyType]

		if conflictCfg then
			if newAreaType and conflictCfg[newAreaType] then
				if self._cachedControllerKeyActiveState[keyType] == nil then
					self._cachedControllerKeyActiveState[keyType] = widget.gameObjectActive
				end

				widget:SetActive(false)
			elseif self._cachedControllerKeyActiveState[keyType] ~= nil then
				widget:SetActive(self._cachedControllerKeyActiveState[keyType])

				self._cachedControllerKeyActiveState[keyType] = nil
			end
		end
	end
end

function M:OnRightStickZoom(ctx)
	if ctx.canceled then
		self.ctrlerInput.zoomDir = 0
	elseif ctx.performed then
		local val = ctx:ReadValueVector2()
		self.ctrlerInput.zoomDir = val.y
	end
end

function M:OnControllerPinBtn()
	if self.selectedGpsId then
		return
	end

	if self:CanPin() then
		self:PinAndSelect(self.controllerTexPos)
	end
end

function M:OnLeftJoyStickMove(ctx)
	if ctx.canceled then
		self.ctrlerInput.leftJS = nil
	elseif ctx.performed then
		self.ctrlerInput.leftJS = ctx:ReadValueVector2()
	end
end

function M:OnControllerZoomIn(holding)
	self.ctrlerInput.zoomInTrigger = holding and 1 or 0
end

function M:OnControllerZoomOut(holding)
	self.ctrlerInput.zoomOutTrigger = holding and 1 or 0
end

function M:OnScroll(ctx)
	if ctx.performed and not self._showingCandidate and not self:HasOperation() then
		-- Nothing
	end
end

function M:OnMapRectClick(uiPos)
	self:HideLeftHoverPanel()

	if self._showingCandidate then
		self:HideCandidatePanel()

		return
	end

	local matchIds = self:GetMatchIds(self.MAGIC_HOVER_RADIUS)

	for _, gpsId in ipairs(gMapSubSystem_Pin:GetAllTempPinGpsIds()) do
		array.remove(matchIds, gpsId)
	end

	local previousSelecting = self.selectedGpsId ~= nil

	self:SetSelected(nil)

	if #matchIds == 1 then
		local info = self._id2ElementInfo[matchIds[1]]

		self:SetSelected(info.element.gpsId, EBigMapSelectSource.ClickElement)
		gMapSubSystem_Pin:ClearTempPin()
	elseif #matchIds > 1 then
		self:ShowCandidatePanel(matchIds)
		gMapSubSystem_Pin:ClearTempPin()
	elseif not previousSelecting and self:CanPin() then
		self:PinAndSelect(self:TransformUIToTex(uiPos))
	end
end

function M:PinAndSelect(texPos)
	if not self:IsBigWorld() then
		return
	end

	local areaId, worldPos = self:Tmp_PinTransform(texPos)
	local gpsId = gMapSubSystem_Pin:TempPin(worldPos, areaId)

	self:SetSelected(gpsId, EBigMapSelectSource.ClickElement)
end

function M:OnMapAreaListEntryClick()
	self:HideCandidatePanel()
	self:SetSelected(nil)
	self:ShowMapAreaList()
end

function M:OnElementListBtnClick()
	self:ShowElementList()
end
