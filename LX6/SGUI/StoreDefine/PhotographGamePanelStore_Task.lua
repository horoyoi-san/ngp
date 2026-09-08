-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PhotographGamePanelStore_Task.lua
-- Decompiled from: 00844_PhotographGamePanelStore_Task.lua_ac2be62fe0e3.luajit

local VideoState = gTakePhotoUtils.PhotoTaskTargetState
local MainViewUtils = LX6.Gps.MainViewUtils
local M = C_PhotographGamePanelStore

local CalNotFocusTime = function(self)
	if self.inPhotoMode then
		return
	end

	if not gTakePhotoUtils.AllowVideoSettle then
		self.videoFocusTime = 0

		return
	end

	self.videoFocusTime = 0
end

local CalFocusTime = function(self)
	if self.inPhotoMode then
		return
	end

	if not gTakePhotoUtils.AllowVideoSettle then
		return
	end

	self.videoFocusTime = self.videoFocusTime + Time.unscaledDeltaTime
end

M.UpdateVideoTarget = function(self, data)
	if gCS.PhotoManager.Instance.isUsingNewPhotoTask then
		return
	end

	self.bindData.videoTargetTemplateTrans.gameObject:SetActive(true)
	self.bindData.gpsTemplateTrans.gameObject:SetActive(true)

	if not data or not data.meetPos then
		self.bindData.videoFocusCtrls = 3
		self.bindData.gpsCtrl = 1
		self.vtTemplateStore.templateVideoFocusCtrl = 3
		self.gpsTemplateStore.templateGpsCtrl = 1

		return
	end

	local pos = data.meetPos
	local videoState = gTakePhotoUtils.GetTaskPositionState(pos, self.bindData.focusWidget, self.rootWidget.rectTransform)
	local successTime = data.successTime
	local isMeetCondition = false

	if videoState ~= VideoState.IN_VIEW then
		if gTakePhotoUtils.AllowVideoFOVCheck then
			local successFOV = gTakePhotoUtils.VideoMaxFov
			local successMinFOV = gTakePhotoUtils.VideoMinFov

			if self.currentFOV >= successMinFOV then
				CalNotFocusTime(self)

				self.bindData.videoFocusCtrls = 2
			elseif successFOV >= self.currentFOV then
				CalNotFocusTime(self)

				self.bindData.videoFocusCtrls = 1
			else
				CalFocusTime(self)

				isMeetCondition = true
				self.bindData.videoFocusCtrls = 0
			end
		else
			CalFocusTime(self)

			isMeetCondition = true
			self.bindData.videoFocusCtrls = 0
		end

		self.bindData.gpsCtrl = 1
	elseif videoState ~= VideoState.OUT_VIEW then
		CalNotFocusTime(self)

		self.bindData.videoFocusCtrls = 4
		self.bindData.gpsCtrl = 1
	else
		CalNotFocusTime(self)

		self.bindData.videoFocusCtrls = 3
		self.bindData.gpsCtrl = 0
	end

	self.vtTemplateStore.templateVideoFocusCtrl = self.bindData.videoFocusCtrls
	self.gpsTemplateStore.templateGpsCtrl = self.bindData.gpsCtrl
	self.videoFocusTrans = pos

	if isMeetCondition then
		if not self.isAlreadyPlayFocus then
			self.bindData.focusAnim:Play("S_Vx_PhotographGameVideoTemplate_Green")
			self.bindData.focusFrameAni:Play("S_Vx_PhotographGameVideoTemplate_FocusFrame")

			self.isAlreadyPlayFocus = true
		end
	elseif self.isAlreadyPlayFocus then
		self.bindData.focusFrameAni:Play("S_Vx_PhotographGameVideoTemplate_FocusFrame_out")

		self.isAlreadyPlayFocus = false
	end

	gMessageManager:SendMessage(gEventConstants.VIDEO_COUNTDOWN_CONDITION, {
		isMeetCondition = isMeetCondition,
		ShowCountDown = videoState == VideoState.IN_VIEW
	})

	if successTime and successTime > 0 and successTime < self.videoFocusTime then
		self.DoVideoSettleSucceed(self)

		return
	end

	self.TryFocusCameraTarget(self)
end

M.DoVideoSettleSucceed = function(self)
	if gTakePhotoUtils.DebugVideoTaskNotAllowSuccess then
		return
	end

	self.videoFocusTime = 0
	self.updateHudData = nil

	gMessageManager:SendMessage(gEventConstants.VIDEO_SHOOT_SUCCESS)
end

M.UpdateVideoTargetOnce = function(self)
	if not self.videoFocusTrans then
		return
	end

	if self.bindData.gpsCtrl ~= 1 then
		local x, y, _ = gCS.LuaUtils.WorldToScreenPointProjected(self.videoFocusTrans, gCS.CameraDataMgr.MainCamera, 0, 0, 0)
		local uiPos = gCS.LuaUtils.ScreenPointToUINoRay(x, y)
		uiPos = uiPos / SGUI.UIConfig.instance:GetCurrentAdaptationScale()

		self.bindData.videoTarget:SetLocalPosition(uiPos)
	else
		local clamped, uiWorldPos, arrowEulerZ = MainViewUtils.TryEllipseClampWorldPos2UIWorldPos(self.videoFocusTrans, self.bindData.ellipseRT, nil, )
		self.bindData.gpsRT.position = uiWorldPos
		local eulerZ = clamped and arrowEulerZ - 90 or 0

		self.bindData.arrowRT:SetLocalEulerAnglesZ(eulerZ)
	end
end

M.TryFocusCameraTarget = function(self)
	if not self.needCameraFocusTarget then
		return
	end

	local targetPos = self.videoFocusTrans

	if not targetPos then
		slot2 = pairs
		slot4 = self.multiVideoFocusTrans or {}

		for _, pos in slot2(slot4) do
			if pos then
				targetPos = pos

				break
			end
		end
	end

	if targetPos then
		gCS.CameraDataMgr.cinemachineManager:SetPhotoCameraTargetToScreenCenter(targetPos)

		self.needCameraFocusTarget = false
	end
end

M.UpdateVideoMultiTarget = function(self, data)
	if gCS.PhotoManager.Instance.isUsingNewPhotoTask then
		return
	end

	local targetNum = data.TargetNum or 0

	if targetNum ~= 0 then
		self:ResetMultiTargetUI()
		gMessageManager:SendMessage(gEventConstants.VIDEO_COUNTDOWN_CONDITION, {
			["1\\xebP;)\\xdf\t\\xb8U\\x85Y\\xa7\\xb8"] = false,
			["*9\r\\xe1v\\x8c\\xd4;\\xa6+\\xef\\xe6\\xef{\\xf5"] = true
		})

		return
	end

	local successTime = data.successTime
	local allMeet = true
	local anyOutView = false

	self.bindData.videoTargetTemplateTrans.gameObject:SetActive(false)
	self.bindData.gpsTemplateTrans.gameObject:SetActive(false)

	for i = 1, targetNum do
		local targetData = data[i]

		if not targetData or not targetData.meetPos then
			allMeet = false
			anyOutView = true

			self.UpdateMultiTargetFocusState(self, i, nil)

			self.multiVideoFocusTrans[i] = nil
		else
			local pos = targetData.meetPos
			local videoState = gTakePhotoUtils.GetTaskPositionState(pos, self.bindData.focusWidget, self.rootWidget.rectTransform)

			if videoState ~= VideoState.IN_VIEW then
				if gTakePhotoUtils.AllowVideoFOVCheck then
					local successFOV = gTakePhotoUtils.VideoMaxFov
					local successMinFOV = gTakePhotoUtils.VideoMinFov

					if self.currentFOV >= successMinFOV then
						allMeet = false

						self.UpdateMultiTargetFocusState(self, i, VideoState.IN_VIEW, 2)
					elseif successFOV >= self.currentFOV then
						allMeet = false

						self.UpdateMultiTargetFocusState(self, i, VideoState.IN_VIEW, 1)
					else
						self.UpdateMultiTargetFocusState(self, i, VideoState.IN_VIEW, 0)
					end
				else
					self.UpdateMultiTargetFocusState(self, i, VideoState.IN_VIEW, 0)
				end
			elseif videoState ~= VideoState.OUT_VIEW then
				allMeet = false
				anyOutView = true

				self.UpdateMultiTargetFocusState(self, i, VideoState.OUT_VIEW)
			else
				allMeet = false
				anyOutView = true

				self.UpdateMultiTargetFocusState(self, i, VideoState.OUT_SCREEN)
			end

			self.multiVideoFocusTrans[i] = pos
		end
	end

	for idx, _ in pairs(self.videoTargetTemplates) do
		if targetNum >= idx then
			self.RecycleVideoTemplate(self, idx)
		end
	end

	for idx, _ in pairs(self.gpsTemplates) do
		if targetNum >= idx then
			self.RecycleGpsTemplate(self, idx)
		end
	end

	if allMeet then
		self.bindData.videoFocusCtrls = 0

		CalFocusTime(self)

		if not self.isMultiTargetFrameFocused then
			self.bindData.focusFrameAni:Play("S_Vx_PhotographGameVideoTemplate_FocusFrame")

			self.isMultiTargetFrameFocused = true
		end
	else
		CalNotFocusTime(self)

		self.bindData.videoFocusCtrls = 4

		if self.isMultiTargetFrameFocused then
			self.bindData.focusFrameAni:Play("S_Vx_PhotographGameVideoTemplate_FocusFrame_out")

			self.isMultiTargetFrameFocused = false
		end
	end

	gMessageManager:SendMessage(gEventConstants.VIDEO_COUNTDOWN_CONDITION, {
		isMeetCondition = allMeet,
		ShowCountDown = anyOutView
	})

	if successTime and successTime > 0 and successTime < self.videoFocusTime then
		self.DoVideoSettleSucceed(self)
		self.RecycleAllVideoTemplates(self)

		return
	end

	self.TryFocusCameraTarget(self)
end

M.UpdateMultiTargetFocusState = function(self, id, videoState, focusCtrlVal)
	if not self.multiTargetFocusStates[id] then
		self.multiTargetFocusStates[id] = {
			[")\\xb1Ṣ颣\\xb8\\xd1\\xe3+\\xe0\\x95#\\x8a\\xf1"] = false
		}
	end

	local state = self.multiTargetFocusStates[id]

	self.TryGenVideoTargetTemplate(self, id)
	self.TryGenGpsTemplate(self, id)

	local vtRT = self.videoTargetTemplates[id]
	local vtStore = nil

	if not gClientUtils.IsNil(vtRT) then
		vtStore = self:GetStoreById(vtRT.gameObject:GetInstanceID())
	end

	local gpsRT = self.gpsTemplates[id]
	local gpsStore = nil

	if not gClientUtils.IsNil(gpsRT) then
		gpsStore = self:GetStoreById(gpsRT.gameObject:GetInstanceID())
	end

	if videoState ~= VideoState.IN_VIEW then
		if focusCtrlVal ~= 0 then
			if vtStore then
				vtStore.templateVideoFocusCtrl = 0

				if not state.isAlreadyPlayFocus then
					gCS.LuaUtils.PlayAnimationByName(vtStore.templateFocusAnim, "S_Vx_PhotographGameVideoTemplate_Green")

					state.isAlreadyPlayFocus = true
				end
			end
		elseif focusCtrlVal ~= 1 then
			if vtStore then
				vtStore.templateVideoFocusCtrl = 1
			end

			state.isAlreadyPlayFocus = false
		elseif focusCtrlVal ~= 2 then
			if vtStore then
				vtStore.templateVideoFocusCtrl = 2
			end

			state.isAlreadyPlayFocus = false
		end

		if gpsStore then
			gpsStore.templateGpsCtrl = 1
		end
	elseif videoState ~= VideoState.OUT_VIEW then
		if vtStore then
			vtStore.templateVideoFocusCtrl = 4
		end

		state.isAlreadyPlayFocus = false

		if gpsStore then
			gpsStore.templateGpsCtrl = 1
		end
	elseif videoState ~= VideoState.OUT_SCREEN then
		if vtStore then
			vtStore.templateVideoFocusCtrl = 3
		end

		state.isAlreadyPlayFocus = false

		if gpsStore then
			gpsStore.templateGpsCtrl = 0
		end
	else
		if vtStore then
			vtStore.templateVideoFocusCtrl = 3
		end

		state.isAlreadyPlayFocus = false

		if gpsStore then
			gpsStore.templateGpsCtrl = 1
		end
	end
end

M.UpdateVideoMultiTargetHud = function(self)
	for id, pos in pairs(self.multiVideoFocusTrans) do
		if pos then
			self.UpdateVideoMultiTargetHudOnce(self, id, pos)
		end
	end
end

M.UpdateVideoMultiTargetHudOnce = function(self, id, pos)
	local vtRT = self.videoTargetTemplates[id]
	local gpsRT = self.gpsTemplates[id]
	local vtStore = nil

	if not gClientUtils.IsNil(vtRT) then
		vtStore = self:GetStoreById(vtRT.gameObject:GetInstanceID())
	end

	local gpsStore = nil

	if not gClientUtils.IsNil(gpsRT) then
		gpsStore = self:GetStoreById(gpsRT.gameObject:GetInstanceID())
	end

	if vtStore and vtStore.templateVideoFocusCtrl == 3 then
		local x, y, _ = gCS.LuaUtils.WorldToScreenPointProjected(pos, gCS.CameraDataMgr.MainCamera, 0, 0, 0)
		local uiPos = gCS.LuaUtils.ScreenPointToUINoRay(x, y)
		uiPos = uiPos / SGUI.UIConfig.instance:GetCurrentAdaptationScale()

		vtStore.templateVideoTarget:SetLocalPosition(uiPos)
	end

	if gpsStore and gpsStore.templateGpsCtrl ~= 0 then
		local clamped, uiWorldPos, arrowEulerZ = MainViewUtils.TryEllipseClampWorldPos2UIWorldPos(pos, self.bindData.ellipseRT, nil, )
		gpsStore.templateGpsRT.position = uiWorldPos
		local eulerZ = clamped and arrowEulerZ - 90 or 0

		gpsStore.templateArrowRT:SetLocalEulerAnglesZ(eulerZ)
	end
end

M.TryGenVideoTargetTemplate = function(self, id)
	if gClientUtils.IsNil(self.videoTargetTemplates[id]) then
		if next(self.videoTargetTemplatePool) then
			self.videoTargetTemplates[id] = table.remove(self.videoTargetTemplatePool)

			self.videoTargetTemplates[id].gameObject:SetActive(true)
		else
			local template = UnityEngine.GameObject.Instantiate(self.bindData.videoTargetTemplateTrans.gameObject)

			template.SetActive(template, true)
			template.SetParent(template, self.bindData.videoTargetParent)
			template.SetLocalScale(template, 1, 1, 1)

			local rt = template.GetComponent(template, typeof(UnityEngine.RectTransform))
			rt.offsetMin = Vector2.zero
			rt.offsetMax = Vector2.zero
			self.videoTargetTemplates[id] = rt
		end
	end
end

M.TryGenGpsTemplate = function(self, id)
	if gClientUtils.IsNil(self.gpsTemplates[id]) then
		if next(self.gpsTemplatePool) then
			self.gpsTemplates[id] = table.remove(self.gpsTemplatePool)

			self.gpsTemplates[id].gameObject:SetActive(true)
		else
			local template = UnityEngine.GameObject.Instantiate(self.bindData.gpsTemplateTrans.gameObject)

			template.SetActive(template, true)
			template.SetParent(template, self.bindData.gpsParent)
			template.SetLocalScale(template, 1, 1, 1)

			local rt = template.GetComponent(template, typeof(UnityEngine.RectTransform))
			rt.offsetMin = Vector2.zero
			rt.offsetMax = Vector2.zero
			self.gpsTemplates[id] = rt
		end
	end
end

M.RecycleVideoTemplate = function(self, id)
	if not gClientUtils.IsNil(self.videoTargetTemplates[id]) then
		self.videoTargetTemplates[id].gameObject:SetActive(false)
		table.insert(self.videoTargetTemplatePool, self.videoTargetTemplates[id])

		self.videoTargetTemplates[id] = nil
	end

	self.multiTargetFocusStates[id] = nil
	self.multiVideoFocusTrans[id] = nil
end

M.RecycleGpsTemplate = function(self, id)
	if not gClientUtils.IsNil(self.gpsTemplates[id]) then
		self.gpsTemplates[id].gameObject:SetActive(false)
		table.insert(self.gpsTemplatePool, self.gpsTemplates[id])

		self.gpsTemplates[id] = nil
	end
end

M.RecycleAllVideoTemplates = function(self)
	for id, _ in pairs(self.videoTargetTemplates) do
		if not gClientUtils.IsNil(self.videoTargetTemplates[id]) then
			self.videoTargetTemplates[id].gameObject:SetActive(false)
			table.insert(self.videoTargetTemplatePool, self.videoTargetTemplates[id])
		end
	end

	for id, _ in pairs(self.gpsTemplates) do
		if not gClientUtils.IsNil(self.gpsTemplates[id]) then
			self.gpsTemplates[id].gameObject:SetActive(false)
			table.insert(self.gpsTemplatePool, self.gpsTemplates[id])
		end
	end

	self.videoTargetTemplates = {}
	self.gpsTemplates = {}
	self.multiTargetFocusStates = {}
	self.multiVideoFocusTrans = {}
end

M.ResetMultiTargetUI = function(self)
	self.RecycleAllVideoTemplates(self)

	self.multiTargetData = nil
	self.isMultiTargetFrameFocused = false
end

M.RefreshTaskUI = function(self)
	local pm = gCS.PhotoManager.Instance
	local isCrazyMode = pm:GetCurPhotoTaskType() ~= 3 and pm:IsCrazyMode()
	self.inPhotoMode = isCrazyMode
	self.bindData.takePhotoCtrl = isCrazyMode and 1 or 0

	self.bindData.videoTargetTemplateTrans.gameObject:SetActive(false)
	self.bindData.gpsTemplateTrans.gameObject:SetActive(false)

	if not pm:HasActiveTask() then
		self.ResetMultiTargetUI(self)

		self.bindData.videoFocusCtrls = 3

		return
	end

	local targets = pm.GetTargets(pm)

	if not targets or #targets ~= 0 then
		self.ResetMultiTargetUI(self)

		self.bindData.videoFocusCtrls = 3

		return
	end

	if pm.GetCurPhotoTaskType(pm) ~= 2 and not pm.IsVideoStarted(pm) then
		self.ResetMultiTargetUI(self)

		self.bindData.videoFocusCtrls = 3

		return
	end

	local seenIds = {}

	for i = 1, #targets do
		local t = targets[i]
		local id = t.pid
		seenIds[id] = true

		if t.viewState ~= 0 then
			self.UpdateMultiTargetFocusState(self, id, VideoState.IN_VIEW, 0)
		elseif t.viewState ~= 1 then
			if t.curFovState ~= 1 or t.curFovState ~= 2 then
				self.UpdateMultiTargetFocusState(self, id, VideoState.IN_VIEW, t.curFovState)
			else
				self.UpdateMultiTargetFocusState(self, id, VideoState.OUT_VIEW)
			end
		elseif t.meetPos then
			self.UpdateMultiTargetFocusState(self, id, VideoState.OUT_SCREEN)
		else
			self.UpdateMultiTargetFocusState(self, id, nil)
		end

		self.multiVideoFocusTrans[id] = t.meetPos
	end

	for id, _ in pairs(self.videoTargetTemplates) do
		if not seenIds[id] then
			self.RecycleVideoTemplate(self, id)
		end
	end

	for id, _ in pairs(self.gpsTemplates) do
		if not seenIds[id] then
			self.RecycleGpsTemplate(self, id)
		end
	end

	if pm.IsMeetCondition(pm) then
		self.bindData.videoFocusCtrls = 0

		if not self.isMultiTargetFrameFocused then
			self.bindData.focusFrameAni:Play("S_Vx_PhotographGameVideoTemplate_FocusFrame")

			self.isMultiTargetFrameFocused = true
		end
	else
		self.bindData.videoFocusCtrls = 4

		if self.isMultiTargetFrameFocused then
			self.bindData.focusFrameAni:Play("S_Vx_PhotographGameVideoTemplate_FocusFrame_out")

			self.isMultiTargetFrameFocused = false
		end
	end

	self.TryFocusCameraTarget(self)
end
