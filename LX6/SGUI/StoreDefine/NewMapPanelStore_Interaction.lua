-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\NewMapPanelStore_Interaction.lua
-- Decompiled from: 00992_NewMapPanelStore_Interaction.lua_624fe9ae3413.luajit

local bit = require("bit")
local M = C_NewMapPanelStore
EControllerPointerHideMask = {
	["43\\x97忓綜\\x81\\xd1\\xf67Զ)\\x8c\\xf6"] = 8,
	["\\xb9;#*k\\xa9D\\xc1\\xa5\\xaa"] = 128,
	["!\\xeb^>\\xd3\\xb3S\\x8d_\\xa3\\xa2"] = 1,
	["1\\xf4V8\t\\xd81\\xb7Q\\x8cY\\xb4\\xb3"] = 4,
	["\\xab!޿A-\\xc3U%\\xc4\\xeb.YH\\xd9\r\\xb5\\xd8"] = 64,
	["_ɸ\\x8a\\x94\r\\xda\\xfc"] = 16,
	["\\xb9=,+}\\x8fq\\xd89\\xaf\\xb5"] = 2,
	["I\\x8d\\xa3\\xa8դ\\xc63\\x84>\\x9f\r2"] = 32,
	["T-s^"] = 0
}

M.InitInteraction = function(self)
	self._curHoverId = nil
	self._controllerAttachIconAnimId = nil
	self._manualAttaching = false
	self.bindData.controllerAttachIndicator.luaClick = self:CreateAction("OnControllerAttachIndicator")
	self.controllerPointerHideMask = 0
	self.lastMousePosition = UnityEngine.Input.mousePosition

	self:RegisterConflictComp("Candidate", function ()
		self:HideCandidatePanel()
	end)

	self.bindData.controllerPin.luaClick = self:CreateAction("OnControllerPinBtn")
	self.bindData.rightStickZoom.luaGamePadInputChanged = self:CreateAction("OnRightStickZoom")
	self.bindData.controllerZoomInBtn.luaPress = self:CreateActionWithArgs("OnControllerZoomIn", true)
	self.bindData.controllerZoomInBtn.luaRelease = self:CreateActionWithArgs("OnControllerZoomIn", false)
	self.bindData.controllerZoomOutBtn.luaPress = self:CreateActionWithArgs("OnControllerZoomOut", true)
	self.bindData.controllerZoomOutBtn.luaRelease = self:CreateActionWithArgs("OnControllerZoomOut", false)
	self.bindData.mapPanelMousePositionRespond.luaGamePadInputChanged = self:CreateAction("OnMousePosition")
	local leftJS = self.bindData.controllerLeftJoyStickRT:GetComponent(typeof(SGUI.UCustomNavRespond))
	leftJS.luaGamePadInputChanged = self:CreateAction("OnLeftJoyStickMove")
end

M.OnMousePosition = function(self, context)
	local value = context:ReadValueVector2()
	self.lastMousePosition = value or self.lastMousePosition
end

M.RefreshCloseBtnState = function(self)
	if self._showingCandidate or self._isShowingMobileFilter or self.bindData.MobileShowMainPageCtrl ~= 1 or self.compRefs.HouseView.actived then
		self.bindData.leftTopCloseBtn:SetActive(false)
	else
		self.bindData.leftTopCloseBtn:SetActive(true)
	end
end

M.GetCharacterHeadIconIdById = function(self, id)
	local cfg = LTConfig.FightSpiritConfig.GetConfig(id)

	if not cfg then
		print_debug("FightSpiritConfig 里不存在 " .. id)

		return nil
	end

	return cfg.SHeadIconID
end

M.GetCharacterNameById = function(self, id)
	if id ~= LTConfig.FightSpiritConfig.DefaultMale or id ~= LTConfig.FightSpiritConfig.DefaultFemale then
		return gPlayerManager.infoLogin.bindData.name
	end

	local cfg = LTConfig.FightSpiritConfig.GetConfig(id)

	if not cfg then
		print_debug("FightSpiritConfig 里不存在 " .. id)

		return ""
	end

	return cfg.Name
end

M.TickHover = function(self)
	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.hoverRoot:SetActiveFastest(false)

		return
	end

	if self.enableController then
		self.bindData.hoverAnim:Stop()
		self.bindData.hoverRoot:SetActiveFastest(false)
		self:SetHover(nil)

		self.bindData.hoverActionFillAmount = self._holdingHoverAction and self._hoverActionTimer / 0.5 or 0

		return
	end

	local ids = self.GetMatchIds(self, self.MAGIC_HOVER_RADIUS, true)

	if not self._showingCandidate and ids and #ids <= 0 and gCS.LuaUtils.GetCurrentHoverGo() ~= self.bindData.mainRayBoxRT.gameObject then
		local id = ids[1]

		if not self.compRefs.HouseView.actived then
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

			if self._curHoverId == id then
				self.bindData.hoverAnim:Stop()
				self.bindData.hoverAnim:Play(self.HOVER_FOCUS)
				self.bindData.hoverAnim:Sample()
			end
		end

		self.SetHover(self, id)

		if self._holdingHoverAction and self._curHoverElementFirstAction then
			self._hoverActionTimer = self._hoverActionTimer + UnityEngine.Time.unscaledDeltaTime

			if self._hoverActionTimer <= 0.5 then
				local element = self._id2ElementInfo[id].element

				self.OnPerformAction(self, element, self._curHoverElementFirstAction, true)
				self.SetHover(self, nil)
			end
		end
	else
		self.bindData.hoverAnim:Stop()
		self.bindData.hoverRoot:SetActiveFastest(false)
		self:SetHover(nil)
	end

	self.bindData.hoverActionFillAmount = self._holdingHoverAction and self._hoverActionTimer / 0.5 or 0
end

M.SetHover = function(self, id)
	if self._curHoverId ~= id then
		return
	end

	local oldId = self._curHoverId
	self._curHoverId = id

	if oldId then
		self.ClearShowMask(self, oldId, EBigMapElementShowMask.Hover)

		local info = self._id2ElementInfo[oldId]

		if info then
			self.RefreshIconLayer(self, info)
		end
	end

	self._hoverActionTimer = 0

	if id then
		gSoundMgr:PlaySoundByTid(70601120)
		self:SetShowMask(id, EBigMapElementShowMask.Hover)

		local info = self._id2ElementInfo[id]

		if info then
			self.RefreshIconLayer(self, info)
		end

		local actions, actionsBlockReason = info.element:GetActionInfos()
		local action = actions and #actions <= 0 and actions[1] or nil

		self:SetupHoverActionCtx(action, actionsBlockReason)
	else
		self.SetupHoverActionCtx(self, nil)
	end
end

M.SetupHoverActionCtx = function(self, action, blockReason)
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

M.OnHoverFastActionBtn = function(self, ctx)
	if ctx.started then
		self._holdingHoverAction = true
		self._hoverActionTimer = 0
	elseif ctx.canceled then
		self._holdingHoverAction = false
		self._hoverActionTimer = 0
	end
end

M.PreTickController = function(self)
	local fixedDt = UnityEngine.Time.deltaTime
	local signZoom = self.ctrlerInput.zoomInTrigger - self.ctrlerInput.zoomOutTrigger + self.ctrlerInput.zoomDir

	if signZoom == 0 then
		self.SetScale(self, self.scale + signZoom * self.CONTROLLER_ZOOM_SCALE * fixedDt)
	end

	if self.enableController then
		local shouldUpdateAttachIconPreview = false

		if not self.HasOperation(self) then
			local pointerUiDelta = nil

			if self.ctrlerInput.leftJS then
				self.HideLeftHoverPanel(self)
				self.ResetControllerPointerAnim(self)

				if self.HasControllerDropdownCtx(self) or self._manualAttaching then
					self.ClearControllerDropdownCtx(self)
				end

				self.SetSelected(self, nil)

				pointerUiDelta = self.ctrlerInput.leftJS * self.CONTROLLER_POINTER_SENSITIVITY
				shouldUpdateAttachIconPreview = true
			elseif self.gamePadTouchOffset then
				pointerUiDelta = self.gamePadTouchOffset * LTConfig.GameConfig.BigMapGamePadTouchMovementSensitivity
				shouldUpdateAttachIconPreview = self.isGamePadTouchRunning

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
				self.ResetControllerPointerAnim(self)
				self.ClearControllerDropdownCtx(self)
			elseif self.controllerPointerHideMask <= 0 then
				self.ClearControllerDropdownCtx(self)
			elseif not self.selectedGpsId and not self._manualAttaching then
				self.CheckControllerDropdownCtx(self)

				if not self.HasControllerDropdownCtx(self) then
					local matchIds = self.GetMatchIds(self, self.CONTROLLER_ATTACH_RANGE)

					if #matchIds <= 0 then
						self.SetControllerAttachCtx(self, matchIds)
					else
						self.ResetControllerPointerAnim(self)
					end
				end
			end

			pointerUiDelta = self.controllerPointerHideMask ~= 0 and pointerUiDelta or nil
			shouldUpdateAttachIconPreview = shouldUpdateAttachIconPreview and pointerUiDelta == nil
			pointerUiDelta = self:TickControllerAttachCtx() or pointerUiDelta

			if pointerUiDelta then
				local uiPos = self.TransformTexToUI(self, self.controllerTexPos)
				uiPos = uiPos + pointerUiDelta
				self.controllerTexPos = self.TransformUIToTex(self, uiPos)
			end
		end

		local rootRTTexHalfSize = nil
		local clampTexMin = self.clampTexMin
		local clampTexMax = self.clampTexMax

		if not self.IsBigWorld(self) then
			local rootSize = self.GetRootSize(self)
			local rootSizeExceptMainPage = gCS.LuaUtils.GetRectTransformSize(self.bindData.areaExceptMainPage.rectTransform)
			local halfTexRootSize = 0.5 * rootSize / self.scale
			local mapHalfTexSize = self.mapCfg.mapSize * 0.5
			clampTexMin = clampTexMin - (mapHalfTexSize + halfTexRootSize)
			clampTexMax = clampTexMax + mapHalfTexSize + halfTexRootSize - (rootSize - rootSizeExceptMainPage) / self.scale
		end

		self.ClampTexPosWithMainPage(self, self.controllerTexPos, clampTexMin, clampTexMax)

		if shouldUpdateAttachIconPreview and not self.selectedGpsId and not self.HasControllerDropdownCtx(self) then
			self.UpdateControllerAttachIconPreview(self)
		elseif not self.controllerAttachCtx then
			self.SetControllerAttachIconAnimTarget(self, nil)
		end
	else
		self.controllerTexPos = self.TransformUIToTex(self, Vector2.zero)

		self.ClearControllerDropdownCtx(self)
	end
end

M.ClampTexPosWithMainPage = function(self, texPos, minTexPos, maxTexPos)
	if not texPos then
		return
	end

	if maxTexPos.x >= texPos.x then
		texPos.x = maxTexPos.x
	elseif texPos.x >= minTexPos.x then
		texPos.x = minTexPos.x
	end

	if texPos.y >= minTexPos.y then
		texPos.y = minTexPos.y
	else
		local rootSize = gCS.LuaUtils.GetRectTransformSize(self.bindData.rootRT)
		local rootSizeExceptMainPage = gCS.LuaUtils.GetRectTransformSize(self.bindData.areaExceptMainPage.rectTransform)
		local dHeight = rootSize.y - rootSizeExceptMainPage.y
		local maxY = maxTexPos.y - dHeight / self.scale

		if maxY >= texPos.y then
			texPos.y = maxY
		end
	end
end

M.OnControllerAttachIndicator = function(self)
	local ids = {
		-1
	}

	for id, _ in pairs(self._indicatorData) do
		table.insert(ids, id)
	end

	self._manualAttaching = true

	self.SetControllerAttachCtx(self, ids, 10, true)
end

M.PlayControllerAttachIconAnim = function(self, id, animName)
	if not id or id ~= -1 then
		return false
	end

	local info = self._id2ElementInfo[id]
	local anim = info and info.store and info.store.selectAnim

	if not anim or not anim.GetClip(anim, animName) then
		return false
	end

	anim.Stop(anim)
	anim.Play(anim, animName)

	return true
end

M.SetControllerAttachIconAnimTarget = function(self, id)
	if self._controllerAttachIconAnimId ~= id then
		return
	end

	local oldId = self._controllerAttachIconAnimId
	self._controllerAttachIconAnimId = nil

	if oldId then
		self.PlayControllerAttachIconAnim(self, oldId, self.CONTROLLER_ATTACH_ICON_CLOSE)
	end

	if self.PlayControllerAttachIconAnim(self, id, self.CONTROLLER_ATTACH_ICON_OPEN) then
		self._controllerAttachIconAnimId = id
	end
end

M.UpdateControllerAttachIconPreview = function(self)
	local matchIds = self.GetMatchIds(self, self.CONTROLLER_ATTACH_RANGE, false, false)

	self.SetControllerAttachIconAnimTarget(self, matchIds[1])
end

M.SetControllerAttachCtx = function(self, ids, speedMultiplier, isL3Attach)
	self.isL3Attach = isL3Attach

	if ids ~= nil or #ids ~= 0 then
		self.ClearControllerDropdownCtx(self)

		return
	end

	self:SetControllerAttachIconAnimTarget(ids[1])

	speedMultiplier = speedMultiplier or 1

	if isL3Attach then
		self.bindData.controllerL3Panel.gameObject:SetActive(true)
	else
		self.bindData.controllerAttachPanel.gameObject:SetActive(true)
	end

	if self.controllerAttachCtx then
		local oldIds = self.controllerAttachCtx.ids
		self.controllerAttachCtx = nil

		for _, id in pairs(oldIds) do
			if id == -1 then
				self.RefreshIconLayer(self, self._id2ElementInfo[id])
				self.ClearShowMask(self, id, EBigMapElementShowMask.ControllerMatch)
			end
		end
	end

	self.controllerAttachCtx = {
		["]\\x83\\xa7\\x87Y"] = 1,
		ids = ids,
		speedMultiplier = speedMultiplier
	}

	self.PlayQueueControllerPointerAnim(self)

	local renderData = {}

	for i, id in ipairs(ids) do
		if id ~= -1 then
			local curSpiritTid = gSpiritManager:GetCurFirstSpiritTid()
			local iconId = self:GetCharacterHeadIconIdById(curSpiritTid)

			if iconId ~= nil then
				print_error("@xiajingbo01 没有获取到人物头像 curSpiritTid:" .. curSpiritTid)

				iconId = 28003372
			end

			local name = self.GetCharacterNameById(self, curSpiritTid)

			table.insert(renderData, {
				["J\\xbe\\xb1\\x86\\xb2"] = -1,
				name = name,
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

	if isL3Attach then
		self.bindData.controllerL3List:SetSimpleList(#renderData)
	else
		self.bindData.controllerAttachList:SetSimpleList(#renderData)
	end

	self._showingControllerAttachMenu = false

	self.ShowControllerAttachCtxMenu(self)
end

M.OnControllerAttachListSelectedChanged = function(self, list)
	if not self.controllerAttachCtx then
		return
	end

	local oldId = self.controllerAttachCtx.ids[self.controllerAttachCtx.curIdx]
	self.controllerAttachCtx.curIdx = list.selectedIndex + 1
	local newId = self.controllerAttachCtx.ids[self.controllerAttachCtx.curIdx]

	self.ClearShowMask(self, oldId, EBigMapElementShowMask.ControllerAttach)
	self.SetShowMask(self, newId, EBigMapElementShowMask.ControllerAttach)
	self.SetControllerAttachIconAnimTarget(self, newId)
	self.PlayQueueControllerPointerAnim(self)
end

M.TickControllerAttachCtx = function(self)
	if not self.controllerAttachCtx then
		return nil
	end

	local id = self.controllerAttachCtx.ids[self.controllerAttachCtx.curIdx]
	local action, targetUiPos = nil

	if id and id == -1 then
		local info = self._id2ElementInfo[id]
		local element = info.element
		local actions, blockReason = element.GetActionInfos(element)

		if blockReason then
			action = nil
		else
			action = actions[1]
		end

		if info.store.visualCenter then
			targetUiPos = self.bindData.controllerAttachPanel.rectTransform.parent:InverseTransformPoint(info.store.visualCenter.position)
		else
			targetUiPos = self.TransformTexToUI(self, info.texPos)
		end

		if self.isL3Attach then
			self.bindData.controllerL3AttachSelectBtn:SetActive(true)
			self.bindData.controllerAttachSelectBtn:SetActive(false)
		else
			self.bindData.controllerL3AttachSelectBtn:SetActive(false)
			self.bindData.controllerAttachSelectBtn:SetActive(true)
		end
	else
		local texPos = self.bindData.playerRT.localPosition
		targetUiPos = self:TransformTexToUI(texPos)
		action = nil

		self.bindData.controllerL3AttachSelectBtn:SetActive(false)
		self.bindData.controllerAttachSelectBtn:SetActive(false)
	end

	if self.isL3Attach then
		if not action then
			self.bindData.controllerL3AttachActionBtn1:SetActive(false)
		else
			self.bindData.controllerL3AttachActionBtn1:SetActive(true)

			self.bindData.controllerL3AttachActionName1 = gMapUIUtils.GetElementActionName(action)
		end
	elseif not action then
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
	local delta = dir * (distance <= step and step or distance)

	if distance >= step then
		self.SetControllerAttachIconAnimTarget(self, nil)
		self.ShowControllerAttachCtxMenu(self)
	end

	self.bindData.controllerAttachPanel.localPosition = targetUiPos
	self.bindData.controllerL3Panel.localPosition = targetUiPos

	return delta
end

M.ShowControllerAttachCtxMenu = function(self)
	if self._showingControllerAttachMenu then
		return
	end

	self._showingControllerAttachMenu = true

	if self.isL3Attach then
		self.bindData.controllerAttachPanel:SetActive(false)
		self.bindData.controllerL3Panel:SetActive(true)
		self.bindData.controllerL3List:SelectItem(self.controllerAttachCtx.curIdx - 1)
	else
		self.bindData.controllerAttachPanel:SetActive(true)
		self.bindData.controllerAttachList:SelectItem(self.controllerAttachCtx.curIdx - 1)
		self.bindData.controllerL3Panel:SetActive(false)
	end

	if self.controllerAttachCtx and #self.controllerAttachCtx.ids <= 1 then
		self._candidateFSMActive = true

		self.SendFSMSignal(self, EBigMapFSMSignal.Interaction_ShowCandidate)
	end

	gSoundMgr:PlaySoundByExternalSource("ExHandle_click_03", LX6.Audio.ExternalSourceType.Motion_2D)
end

M.HasControllerDropdownCtx = function(self)
	return self.controllerAttachCtx == nil or self.controllerIndicatorCtx == nil
end

M.CheckControllerDropdownCtx = function(self)
	if self.controllerAttachCtx then
		for i, id in ipairs(self.controllerAttachCtx.ids) do
			local info = self._id2ElementInfo[id]

			if not info or info.showMask <= info.hideMask or info.showMask ~= 0 then
				self.ClearControllerDropdownCtx(self)

				return
			end
		end
	end
end

M.ClearControllerDropdownCtx = function(self)
	self.SetControllerAttachIconAnimTarget(self, nil)

	self._manualAttaching = false

	if self.controllerAttachCtx then
		local controllerAttachCtxIds = self.controllerAttachCtx.ids
		self.controllerAttachCtx = nil

		for _, id in ipairs(controllerAttachCtxIds) do
			if id == -1 and self._id2ElementInfo[id] then
				self.RefreshIconLayer(self, self._id2ElementInfo[id])
				self.ClearShowMask(self, id, EBigMapElementShowMask.ControllerMatch)
				self.ClearShowMask(self, id, EBigMapElementShowMask.ControllerAttach)
			end
		end
	end

	self.controllerIndicatorCtx = nil
	local wasCandidateFSMActive = self._candidateFSMActive
	self._candidateFSMActive = false
	self._showingControllerAttachMenu = false

	self.bindData.controllerAttachPanel:SetActive(false)
	self.bindData.controllerAttachList:SetSimpleList(0)
	self.bindData.controllerL3Panel:SetActive(false)
	self.bindData.controllerL3List:SetSimpleList(0)

	if wasCandidateFSMActive and not self._showingCandidate then
		self.SendFSMSignal(self, EBigMapFSMSignal.Interaction_ShowCandidate, false)
	end
end

M.PlayQueueControllerPointerAnim = function(self)
	self.controllerPointerAnim:Stop()
	self.controllerPointerAnim:Play(self.CONTROLLER_POINTER_OPEN)
	self.controllerPointerAnim:PlayQueued(self.CONTROLLER_POINTER_LOOP)
end

M.ResetControllerPointerAnim = function(self)
	self.controllerPointerAnim:Stop()
	self.controllerPointerAnim:Play(self.CONTROLLER_POINTER_OPEN)
	self.controllerPointerAnim:Sample()
	self.controllerPointerAnim:Stop()
end

M.OnClickControllerAttachSelect = function(self)
	local id = 0

	if self.isL3Attach then
		id = self.controllerAttachCtx.ids[self.bindData.controllerL3List.selectedIndex + 1]
	else
		id = self.controllerAttachCtx.ids[self.bindData.controllerAttachList.selectedIndex + 1]
	end

	local info = self._id2ElementInfo[id]

	if not info then
		return
	end

	local element = self._id2ElementInfo[id].element

	if element then
		self.ScheduleOperation(self, self.OperationType.Select, {
			gpsId = element.gpsId,
			source = EBigMapSelectSource.ClickElement
		})
	end
end

M.OnClickControllerAttachAction1 = function(self)
	local id = 0

	if self.isL3Attach then
		id = self.controllerAttachCtx.ids[self.bindData.controllerL3List.selectedIndex + 1]
	else
		id = self.controllerAttachCtx.ids[self.bindData.controllerAttachList.selectedIndex + 1]
	end

	local element = self._id2ElementInfo[id].element
	local action1 = element.GetRawActions(element)[1]

	if action1 then
		self.OnPerformAction(self, element, action1, true)
	end
end

M.SetControllerMouseHideMask = function(self, mask, enable)
	if enable then
		self.controllerPointerHideMask = bit.bor(self.controllerPointerHideMask, mask)
	else
		self.controllerPointerHideMask = bit.band(self.controllerPointerHideMask, bit.bnot(mask))
	end

	if self.enableController then
		if self.controllerPointerHideMask == 0 then
			self.bindData.controllerPointer:SetActive(false)
		else
			self.bindData.controllerPointer:SetActive(true)
		end
	end
end

M.RegisterConflictComp = function(self, type, hideFunc)
	self.conflictCompHideFuncs = self.conflictCompHideFuncs or {}
	self.conflictCompHideFuncs[type] = hideFunc
end

M.UnRegisterConflictComp = function(self, type)
	if self.conflictCompHideFuncs then
		self.conflictCompHideFuncs[type] = nil
	end
end

M.HideConflictComps = function(self, curType)
	slot2 = pairs
	slot4 = self.conflictCompHideFuncs or {}

	for type, hide in slot2(slot4) do
		if type == curType then
			hide()
		end
	end
end

M.HideCandidatePanel = function(self)
	self._showingCandidate = false

	if self._candidateIds then
		for _, id in ipairs(self._candidateIds) do
			self.ClearShowMask(self, id, EBigMapElementShowMask.Match)
		end
	end

	self.bindData.matchScrollRect:SetActive(false)
	self:RefreshCloseBtnState()

	if self._activeStates[EBigMapFSMState.Interaction_CandidateShown] then
		self.SendFSMSignal(self, EBigMapFSMSignal.Interaction_ShowCandidate, false)
	end
end

M.ShowCandidatePanel = function(self, ids)
	self._showingCandidate = true

	if self._candidateIds then
		for _, id in ipairs(self._candidateIds) do
			self.ClearShowMask(self, id, EBigMapElementShowMask.Match)
		end
	end

	self._candidateIds = ids
	local pivot = nil
	local pointerUIPos = self.GetPointerUIPos(self)

	if pointerUIPos.x <= 0 and pointerUIPos.y <= 0 then
		pivot = Vector2.New(1, 1)
	elseif pointerUIPos.x <= 0 and pointerUIPos.y >= 0 then
		pivot = Vector2.New(1, 0)
	elseif pointerUIPos.x >= 0 and pointerUIPos.y <= 0 then
		pivot = Vector2.New(0, 1)
	else
		pivot = Vector2.New(0, 0)
	end

	self.bindData.matchScrollRect.rectTransform.pivot = pivot

	self.bindData.matchScrollRect.rectTransform:SetLocalPositionXY(0, 0)
	self.bindData.matchScrollRect:GoToPos(Vector2.zero, true)

	self.bindData.matchRT.localPosition = self:GetPointerUIPos()

	self.bindData.matchScrollRect:SetActive(true)

	self.candidateInfos = {}

	for _, id in ipairs(ids) do
		self:SetShowMask(id, EBigMapElementShowMask.Match)

		local info = self._id2ElementInfo[id]

		table.insert(self.candidateInfos, {
			gpsId = info.element.gpsId,
			name = info.element:GetName(),
			iconId = self:GetIconId(info.element)
		})
	end

	self.matchList:SetSimpleList(#self.candidateInfos)
	self:RefreshCloseBtnState()
	self:HideConflictComps("Candidate")

	if not self._activeStates[EBigMapFSMState.Interaction_CandidateShown] then
		self.SendFSMSignal(self, EBigMapFSMSignal.Interaction_ShowCandidate)
	end
end

M.InitOperation = function(self)
	self.OperationType = {
		["tFe}h+"] = 6,
		["\\xb9;#*k\\xa9D\\xc1\\xa5\\xaa"] = 3,
		["/M\\x9d\\x8b\\x80U"] = 5,
		["d[ǩ\\xb7\r\\xb4\\xca\\xfc"] = 4
	}
	self.OperationProcessor = {
		[self.OperationType.FocusTexPos] = "Operation_FocusTexPos",
		[self.OperationType.Select] = "Operation_Select",
		[self.OperationType.WaitSelect] = "Operation_WaitSelect",
		[self.OperationType.WaitFocus] = "Operation_WaitFocus"
	}
	self.OperationState = {
		["^-s^"] = 1,
		["\\xeb\\xce*\\xf6"] = 0,
		["/Y\\x84\\x8f\\x90I"] = 2
	}
	self.focusTexSpeed = 13000
	self._opQueue = {}
	self._curOp = nil
end

M.TickOperation = function(self)
	self.TryFetchNextOperation(self)

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

		if state ~= self.OperationState.Done then
			self._curOp = nil
		end
	end

	if self._curOp and self._curOp.type ~= self.OperationType.FocusTexPos then
		if bit.band(self.controllerPointerHideMask, EControllerPointerHideMask.FocusTexPos) ~= 0 then
			self.SetControllerMouseHideMask(self, EControllerPointerHideMask.FocusTexPos, true)
		end
	elseif bit.band(self.controllerPointerHideMask, EControllerPointerHideMask.FocusTexPos) == 0 then
		self.SetControllerMouseHideMask(self, EControllerPointerHideMask.FocusTexPos, false)
	end
end

M.HasOperation = function(self)
	return self._curOp or #self._opQueue >= 0
end

M.TryFetchNextOperation = function(self)
	if not self._curOp and #self._opQueue <= 0 then
		self._curOp = table.remove(self._opQueue, 1)
	end
end

M.HasOperationOfType = function(self, type)
	if self._curOp and self._curOp.type ~= type then
		return true
	end

	for i = #self._opQueue, 1, -1 do
		if self._opQueue[i].type ~= type then
			return true
		end
	end

	return false
end

M.ScheduleOperation = function(self, type, data, pushFront)
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

M.ClearScheduleOperation = function(self, type)
	for i = #self._opQueue, 1, -1 do
		if not type or self._opQueue[i].type ~= type then
			table.remove(self._opQueue, i)
		end
	end
end

local _tmpVec2 = Vector2.zero

M.Operation_FocusTexPos = function(self, data, ctx)
	if not data or not data.texPos then
		return self.OperationState.Done
	end

	local targetTexPos = data.texPos
	local x, y = self.TransformUIToTexXY(self, 0, 0)
	_tmpVec2.x = x
	_tmpVec2.y = y
	local dp = targetTexPos - _tmpVec2
	local dist = Vector2.Magnitude(dp)

	if not ctx.effSpeed then
		local baseSpeed = self.focusTexSpeed

		if data.speedMultiplier then
			baseSpeed = baseSpeed * data.speedMultiplier
		end

		local speed = baseSpeed
		local maxTime = LTConfig.GpsConfig.MapMoveMaxTime

		if maxTime and maxTime <= 0 and dist <= 0 then
			local naturalDuration = dist / baseSpeed

			if maxTime >= naturalDuration then
				speed = dist / maxTime
			end
		end

		ctx.effSpeed = speed
	end

	local step = ctx.effSpeed * UnityEngine.Time.deltaTime
	local nextTexPos = _tmpVec2 + step * Vector2.Normalize(dp)
	self.controllerTexPos = nextTexPos

	if dist > step or not self.AlignMapPos(self, nextTexPos) then
		self.AlignMapPos(self, targetTexPos)

		self.controllerTexPos = targetTexPos

		return self.OperationState.Done
	end

	return self.OperationState.Running
end

M.Operation_Select = function(self, data, ctx)
	local gpsId = data.gpsId

	self.RealSetSelected(self, gpsId, data.source)

	return self.OperationState.Done
end

M.Operation_WaitFocus = function(self, data, ctx)
	local gpsId = data.gpsId
	local maxWaitTime = data.maxWaitTime
	ctx.waitTime = ctx.waitTime or 0

	if maxWaitTime and maxWaitTime >= ctx.waitTime then
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

	self.ScheduleOperation(self, self.OperationType.FocusTexPos, {
		texPos = info.texPos
	}, true)

	return self.OperationState.Done
end

M.Operation_WaitSelect = function(self, data, ctx)
	local gpsId = data.gpsId
	local maxWaitTime = data.maxWaitTime
	ctx.waitTime = ctx.waitTime or 0

	if maxWaitTime and maxWaitTime >= ctx.waitTime then
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

	self.ScheduleOperation(self, self.OperationType.Select, {
		gpsId = gpsId,
		source = data.source
	}, true)
	self.ScheduleOperation(self, self.OperationType.FocusTexPos, {
		texPos = info.texPos
	}, true)

	return self.OperationState.Done
end

EBigMapControllerKey = {
	["\\a\\xa5cO\\xba\\xc1WchwX"] = 1,
	["As\\xbbD[\\xbb\\xe6DbW\\"] = 3,
	["pPe}M<("] = 2
}
EBigMapNavArea = {
	["43\\x97忓綜\\x81\\xd1\\xf67Զ)\\x8c\\xf6"] = 5,
	["\\xaf\\xa1\\xaa\\xa4"] = 8,
	["I\\x8d\\xa3\\xa8դ\\xc63\\x84>\\x9f\r2"] = 7,
	["1\\xf4V8\t\\xd81\\xb7Q\\x8cY\\xb4\\xb3"] = 3,
	["kHyzK2,"] = 6,
	["W#tU"] = 0,
	["\\a\\xa5cO\\xba\\xc1WchwX"] = 4,
	["uS©\\x81\\x95\\xc7\\xfd"] = 1,
	["\\xab!޿A-\\xc3U%\\xc4\\xeb.YH\\xd9\r\\xb5\\xd8"] = 2
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
	},
	[EBigMapControllerKey.NewSwitchMap] = {
		[EBigMapNavArea.FilterMenu] = true,
		[EBigMapNavArea.InScreenElementsList] = true,
		[EBigMapNavArea.SwitchSpirit] = true,
		[EBigMapNavArea.RightTopFilterList] = true
	}
}

M.InitControllerKeyConflict = function(self)
	self._controllerType2KeyWidget = {}
	self._navArea2Type = {}
	self._cachedControllerKeyActiveState = {}
	self._lastNavArea = nil

	self.RegisterNavArea(self, EBigMapNavArea.Main, self.bindData.mainNavArea)
	self.RegisterNavArea(self, EBigMapNavArea.Main, self.bindData.mainOnlyNavArea)
end

M.RegisterControllerKey = function(self, keyType, keyWidget)
	self._controllerType2KeyWidget[keyType] = keyWidget
end

M.UnRegisterControllerKey = function(self, keyType)
	self._controllerType2KeyWidget[keyType] = nil
end

M.RegisterNavArea = function(self, areaType, area)
	self._navArea2Type[area] = areaType
end

M.UnRegisterNavArea = function(self, areaType, area)
	if area then
		self._navArea2Type[area] = nil
	end
end

local NavMgr = SGUI.UNavigationMgr

M.TickNavAreaChange = function(self)
	if self._lastNavArea ~= NavMgr.Inst.CurrentActiveArea then
		return
	end

	local oldArea = self._lastNavArea
	local newArea = NavMgr.Inst.CurrentActiveArea
	self._lastNavArea = newArea

	self.OnNavAreaChange(self, oldArea, newArea)
end

M.OnNavAreaChange = function(self, oldArea, newArea)
	if not newArea then
		return
	end

	self.NotifyCompsOnNavAreaChange(self, oldArea, newArea)

	local newAreaType = self._navArea2Type[newArea]

	for keyType, widget in pairs(self._controllerType2KeyWidget) do
		local conflictCfg = controllerKeyConflictCfg[keyType]

		if conflictCfg then
			if newAreaType and conflictCfg[newAreaType] then
				if self._cachedControllerKeyActiveState[keyType] ~= nil then
					self._cachedControllerKeyActiveState[keyType] = widget.gameObjectActive
				end

				widget.SetActive(widget, false)
			elseif self._cachedControllerKeyActiveState[keyType] == nil then
				widget.SetActive(widget, self._cachedControllerKeyActiveState[keyType])

				self._cachedControllerKeyActiveState[keyType] = nil
			end
		end
	end
end

M.OnRightStickZoom = function(self, ctx)
	if ctx.canceled then
		self.ctrlerInput.zoomDir = 0
	elseif ctx.performed then
		local val = ctx.ReadValueVector2(ctx)
		self.ctrlerInput.zoomDir = val.y
	end
end

M.OnControllerPinBtn = function(self)
	if self.selectedGpsId then
		return
	end

	if self.CanPin(self) then
		self.PinAndSelect(self, self.controllerTexPos)
	end
end

M.OnLeftJoyStickMove = function(self, ctx)
	if ctx.canceled then
		self.ctrlerInput.leftJS = nil
	elseif ctx.performed then
		local value = ctx:ReadValueVector2()
		self.ctrlerInput.leftJS = self.CONTROLLER_POINTER_DEAD_ZONE >= value.magnitude and value or nil
	end
end

M.OnControllerZoomIn = function(self, holding)
	self.ctrlerInput.zoomInTrigger = holding and 1 or 0
end

M.OnControllerZoomOut = function(self, holding)
	self.ctrlerInput.zoomOutTrigger = holding and 1 or 0
end

M.OnScroll = function(self, ctx)
	if ctx.performed and not self._showingCandidate and not self.HasOperation(self) then
		-- Nothing
	end
end

M.OnMapRectClick = function(self, uiPos)
	self.HideLeftHoverPanel(self)

	if self._showingCandidate then
		self.HideCandidatePanel(self)

		return
	end

	local matchIds = self:GetMatchIds(self.MAGIC_HOVER_RADIUS)

	for _, gpsId in ipairs(gMapSubSystem_Pin:GetAllTempPinGpsIds()) do
		array.remove(matchIds, gpsId)
	end

	if self.compRefs.HouseView.actived then
		local previousSelecting = self.selectedGpsId == nil

		self:SetSelected(nil)

		if #matchIds <= 0 then
			local info = self._id2ElementInfo[matchIds[1]]

			self:SetSelected(info.element.gpsId, EBigMapSelectSource.ClickElement)
			gMapSubSystem_Pin:ClearTempPin()
		end
	else
		local previousSelecting = self.selectedGpsId == nil

		self:SetSelected(nil)

		if #matchIds ~= 1 then
			local info = self._id2ElementInfo[matchIds[1]]

			self:SetSelected(info.element.gpsId, EBigMapSelectSource.ClickElement)
			gMapSubSystem_Pin:ClearTempPin()
		elseif #matchIds <= 1 then
			self:ShowCandidatePanel(matchIds)
			gMapSubSystem_Pin:ClearTempPin()
		elseif not previousSelecting and self.CanPin(self) then
			self.PinAndSelect(self, self.TransformUIToTex(self, uiPos))
		elseif not gCS.LuaUtils.IsNonMobileAdaptive() and not previousSelecting and gLinkManager:CheckIsExtractionShooter() then
			local areaId, worldPos = self.TryTransformTexToWorld(self, self.TransformUIToTex(self, uiPos))

			if areaId then
				local raidId, _ = gMapSystem.area:SplitAreaId(areaId)

				gMapSubSystem_Pin:OnBigMapExtractionShooterMark(raidId, worldPos)
			end
		end
	end
end

M.PinAndSelect = function(self, texPos)
	if not self.IsBigWorld(self) then
		return
	end

	local areaId, worldPos = self:Tmp_PinTransform(texPos)
	local gpsId = gMapSubSystem_Pin:TempPin(worldPos, areaId)

	self:SetSelected(gpsId, EBigMapSelectSource.ClickElement)
end

M.PinAndTrace = function(self, uiPos)
	local matchIds = self:GetMatchIds(self.MAGIC_HOVER_RADIUS)

	for _, gpsId in ipairs(gMapSubSystem_Pin:GetAllTempPinGpsIds()) do
		array.remove(matchIds, gpsId)
	end

	self.SetSelected(self, nil)

	if #matchIds ~= 1 then
		local info = self._id2ElementInfo[matchIds[1]]
		local actions, blockReason = info.element:GetActionInfos()

		if actions and actions[1] then
			if actions[1] ~= gMapSystemElementAction.Trace or actions[1] ~= gMapSystemElementAction.TraceTask then
				self.OnPerformAction(self, info.element, actions[1], true)
			elseif actions[1] ~= gMapSystemElementAction.Untrace or actions[1] ~= gMapSystemElementAction.UntraceTask then
				self.OnPerformAction(self, info.element, actions[1], true)
			end
		end

		self._curHoverId = nil

		gMapSubSystem_Pin:ClearTempPin()
	elseif #matchIds <= 1 then
		self:ShowCandidatePanel(matchIds)
		gMapSubSystem_Pin:ClearTempPin()
	elseif self.CanPin(self) then
		local texPos = self:TransformUIToTex(uiPos)
		local areaId, worldPos = self:Tmp_PinTransform(texPos)
		local raidId = gMapSystem.area:SplitAreaId(areaId)
		local blockId = LX6.Gps.MapBlockMgr.GetBlockIdXZ(raidId, worldPos.x, worldPos.z)

		if blockId <= 0 then
			gMapSubSystem_Pin:TempPinAndTrace(worldPos, areaId)
		end
	end
end

M.OnMapAreaListEntryClick = function(self)
	self.HideCandidatePanel(self)
	self.SetSelected(self, nil)
	self.ShowMapAreaList(self)
end

M.OnElementListBtnClick = function(self)
	self.ShowElementList(self)
end
