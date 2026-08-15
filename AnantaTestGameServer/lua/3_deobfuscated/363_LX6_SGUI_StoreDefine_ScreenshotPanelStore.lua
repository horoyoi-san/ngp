C_ScreenshotPanelStore = DefClass("C_ScreenshotPanelStore", C_ScreenshotPanelStore, C_StoreGroup)
GroupName2Class.ScreenshotPanelStore = C_ScreenshotPanelStore
local M = C_ScreenshotPanelStore

function M:ctor()
	self:RegisterMessageEvents({
		[gEventConstants.BEFORE_SWITCH_SCENE] = self:CreateAction(self.ClosePanel),
		[gEventConstants.AFTER_SWITCH_SCENE] = self:CreateAction(self.ShowPanel),
		[gEventConstants.FEEDBACK_PANEL_SHOW] = function (_, isShow)
			if isShow then
				self:ClosePanel()
			else
				self:ShowPanel()
			end
		end
	})
end

function M:OnShow(_, _)
	self:DefineAllVariables()
	self:RegisterWidget()
	self.bindData.msgRoot:SetActive(false)
end

function M:DefineAllVariables()
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

function M:RegisterWidget()
	self.bindData.btn.luaClick = self:CreateAction(self.OnBtnClick)
	self.bindData.btn.luaPress = self:CreateActionWithArgs(self.OnBtnPress, self.bindData.btn)
	self.bindData.btn.luaRelease = self:CreateActionWithArgs(self.OnBtnRelease, self.bindData.btn)
	self.bindData.pcKeyHint.luaPress = self:CreateActionWithArgs(self.OnBtnPress, self.bindData.pcKeyHint)
	self.bindData.pcKeyHint.luaRelease = self:CreateActionWithArgs(self.OnBtnRelease, self.bindData.pcKeyHint)
end

function M:OnClose()
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

function M:ShowPanel()
	if self.STATE_EnableOnce then
		self.rootWidget:SetActive(true)
	else
		gPanelManager:CheckShow(gPanelId.SCREENSHOT_PANEL)
	end
end

function M:ClosePanel()
	if self.STATE_EnableOnce then
		self.rootWidget:SetActive(false)
	end
end

function M:OnBtnClick()
	local store = gStoreManager:GetStoreGroup("FeedbackPanelStore")

	if store then
		store:DoBackgroundScreenShot()
	end
end

function M:OnBtnPress(btn)
	local dragInfo = self.dragInfos and self.dragInfos[btn]

	if dragInfo == nil then
		return
	end

	local pointerPos = gCS.LuaUtils.GetPointerPosition()
	local uiPos = gCS.LuaUtils.ScreenPointUI(self.baseTransform, pointerPos)
	dragInfo.posDiff = uiPos - dragInfo.btnTrans.anchoredPosition
	dragInfo.updateHandler = UpdateBeat:CreateListener(self:CreateActionWithArgs(self.OnBtnDragUpdate, btn), self)

	UpdateBeat:AddListener(dragInfo.updateHandler)
end

function M:OnBtnDragUpdate(btn)
	local dragInfo = self.dragInfos and self.dragInfos[btn]

	if dragInfo == nil then
		return
	end

	local pointerPos = gCS.LuaUtils.GetPointerPosition()
	local uiPos = gCS.LuaUtils.ScreenPointUI(self.baseTransform, pointerPos)
	local newPos = uiPos - dragInfo.posDiff

	local function clamp(v, min, max)
		return math.min(math.max(v, min), max)
	end

	newPos.x = clamp(newPos.x, dragInfo.localPosMin.x, dragInfo.localPosMax.x)
	newPos.y = clamp(newPos.y, dragInfo.localPosMin.y, dragInfo.localPosMax.y)
	dragInfo.btnTrans.anchoredPosition = newPos
end

function M:OnBtnRelease(btn)
	local dragInfo = self.dragInfos and self.dragInfos[btn]

	if dragInfo == nil then
		return
	end

	if dragInfo.updateHandler then
		UpdateBeat:RemoveListener(dragInfo.updateHandler)

		dragInfo.updateHandler = nil
	end
end

function M:ShowMessage(mid, ...)
	local config = gDisplayMessageMgr:GetMessageConfig(mid)
	local content = gString.Format(config.Content, ...)
	self.bindData.msgText = content

	self.bindData.msgRoot:SetActive(true)

	if self.timer then
		self.timer:Stop()
	end

	self.timer = Timer.New(function ()
		if self.STATE_EnableOnce then
			self.bindData.msgRoot:SetActive(false)
		end
	end, 3)

	self.timer:Start()
end
