-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ScreenshotPanelStore.lua
-- Decompiled from: 00874_ScreenshotPanelStore.lua_226e415e0178.luajit

C_ScreenshotPanelStore = DefClass("C_ScreenshotPanelStore", C_ScreenshotPanelStore, C_StoreGroup)
GroupName2Class.ScreenshotPanelStore = C_ScreenshotPanelStore
local M = C_ScreenshotPanelStore

M.ctor = function(self)
	local block = false

	if block then
		return
	end

	self.RegisterMessageEvents(self, {
		[gEventConstants.L50_BEFORE_SWITCH_SCENE] = self.CreateAction(self, self.ClosePanel),
		[gEventConstants.L50_AFTER_SWITCH_SCENE] = function (_, switchSceneEventParams)
			local switchType = switchSceneEventParams.switchSceneType

			if switchType == gSwitchSceneType.KickToLogin then
				self:ShowPanel()
			end
		end,
		[gEventConstants.FEEDBACK_PANEL_SHOW] = function (_, isShow)
			if isShow then
				self:ClosePanel()
			else
				self:ShowPanel()
			end
		end
	})
end

M.OnShow = function(self, _, _)
	self.DefineAllVariables(self)
	self.RegisterWidget(self)
end

M.DefineAllVariables = function(self)
	self.baseTransform = self.bindData.btn.rectTransform.parent
	self.dragInfos = {
		[self.bindData.btn] = {
			btnTrans = self.bindData.btn.rectTransform
		},
		[self.bindData.pcKeyHint] = {
			btnTrans = self.bindData.pcKeyHint.rectTransform
		}
	}
	local dragArea = self.bindData.dragArea
	local halfBaseTransformSize = self.baseTransform.rect.size / 2
	local dragPosMin = dragArea.rect.min + dragArea.anchoredPosition - halfBaseTransformSize
	local dragPosMax = dragArea.rect.max + dragArea.anchoredPosition - halfBaseTransformSize

	for _, v in pairs(self.dragInfos) do
		v.localPosMin = dragPosMin
		v.localPosMax = dragPosMax
	end
end

M.RegisterWidget = function(self)
	self.bindData.btn.luaClick = self.CreateAction(self, self.OnBtnClick)
	self.bindData.btn.luaPress = self.CreateActionWithArgs(self, self.OnBtnPress, self.bindData.btn)
	self.bindData.btn.luaRelease = self.CreateActionWithArgs(self, self.OnBtnRelease, self.bindData.btn)
	self.bindData.pcKeyHint.luaPress = self.CreateActionWithArgs(self, self.OnBtnPress, self.bindData.pcKeyHint)
	self.bindData.pcKeyHint.luaRelease = self.CreateActionWithArgs(self, self.OnBtnRelease, self.bindData.pcKeyHint)
end

M.OnClose = function(self)
	if self.dragInfos then
		for _, dragInfo in pairs(self.dragInfos) do
			if dragInfo.updateHandler then
				UpdateBeat:RemoveListener(dragInfo.updateHandler)
			end
		end

		self.dragInfos = nil
	end

	if self.timer then
		self.timer:Stop()

		self.timer = nil
	end
end

M.ShowPanel = function(self)
	if not gSystemUnlockMgr:IsUnlock(LTConfig.SystemUnlockConfig.FeedbackUnlock) or not LTConfig.InformConfig.EnableFeedback then
		self.ClosePanel(self)

		return
	end

	if self.STATE_EnableOnce then
		self.rootWidget:SetActive(true)
	else
		gPanelManager:CheckShow(gPanelId.SCREENSHOT_PANEL)
	end
end

M.ClosePanel = function(self)
	if self.STATE_EnableOnce then
		self.rootWidget:SetActive(false)
	end
end

M.OnBtnClick = function(self)
	local store = gStoreManager:GetStoreGroup("FeedbackPanelStore")

	if store then
		store.DoBackgroundScreenShot(store)
	end
end

M.OnBtnPress = function(self, btn)
	local dragInfo = self.dragInfos and self.dragInfos[btn]

	if dragInfo ~= nil then
		return
	end

	local pointerPos = gCS.LuaUtils.GetPointerPosition()
	local uiPos = gCS.LuaUtils.ScreenPointUI(self.baseTransform, pointerPos)
	dragInfo.posDiff = uiPos - dragInfo.btnTrans.anchoredPosition
	dragInfo.updateHandler = UpdateBeat:CreateListener(self:CreateActionWithArgs(self.OnBtnDragUpdate, btn), self)

	UpdateBeat:AddListener(dragInfo.updateHandler)
end

M.OnBtnDragUpdate = function(self, btn)
	local dragInfo = self.dragInfos and self.dragInfos[btn]

	if dragInfo ~= nil then
		return
	end

	local pointerPos = gCS.LuaUtils.GetPointerPosition()
	local uiPos = gCS.LuaUtils.ScreenPointUI(self.baseTransform, pointerPos)
	local newPos = uiPos - dragInfo.posDiff
	newPos.x = Mathf.Clamp(newPos.x, dragInfo.localPosMin.x, dragInfo.localPosMax.x)
	newPos.y = Mathf.Clamp(newPos.y, dragInfo.localPosMin.y, dragInfo.localPosMax.y)
	dragInfo.btnTrans.anchoredPosition = newPos
end

M.OnBtnRelease = function(self, btn)
	local dragInfo = self.dragInfos and self.dragInfos[btn]

	if dragInfo ~= nil then
		return
	end

	if dragInfo.updateHandler then
		UpdateBeat:RemoveListener(dragInfo.updateHandler)

		dragInfo.updateHandler = nil
	end
end
