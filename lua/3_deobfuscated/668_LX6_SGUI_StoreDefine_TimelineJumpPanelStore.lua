C_TimelineJumpPanelStore = DefClass("C_TimelineJumpPanelStore", C_TimelineJumpPanelStore, C_StoreGroup)
GroupName2Class.TimelineJumpPanelStore = C_TimelineJumpPanelStore
local M = C_TimelineJumpPanelStore

function M:ctor()
	return
end

function M:OnAwake()
	self.timelineName = ""
	self.spoonNodeId = 0
	self.jumpToEnd = false
	self.customJumpText = ""
	self.EventHandler = {
		[gEventConstants.DIALOG_SHOW_START] = function (eventId, data)
			self:RefreshBtn()
		end,
		[gEventConstants.DIALOG_SHOW_END] = function (eventId, data)
			self:RefreshBtn()
		end,
		[gEventConstants.TIMELINE_SET_CLICK_JUMP] = function (eventId, data)
			self:ParseData(data)
		end,
		[gEventConstants.DIALOG_TYPEWRITER_FINISHED] = function (eventId, data)
			self:RefreshBtn()
		end
	}

	for i, v in pairs(self.EventHandler) do
		gMessageManager:AddMessageListener(i, v)
	end

	self.closePanelWhenClick = false
	self.bindData.btnSkip.luaClick = self:CreateAction("OnJumpBtnClick")
	self.bindData.btnReview.luaClick = self:CreateAction("OnReviewBtnClick")
	self.bindData.btnAuto.luaClick = self:CreateAction("OnAutoBtnClick")
	self.bindData.btnAutoCancel.luaClick = self:CreateAction("OnAutoBtnCancelClick")
end

function M:OnShow(panelId, data)
	local targetData = data == nil and {} or data

	self:ParseData(targetData)

	self.jumpToEnd = targetData.showJumpBtn

	gDialogManager:SwitchAutoPlay(self.showAutoBtn)
	self:RefreshBtn()
end

function M:OnClose()
	for i, v in pairs(self.EventHandler) do
		gMessageManager:RemoveMessageListener(i, v)
	end
end

function M:ParseData(data)
	if data.timelineName ~= nil then
		self.timelineName = data.timelineName
	end

	if data.spoonNodeId ~= nil then
		self.spoonNodeId = data.spoonNodeId
	end

	if data.showJumpBtn ~= nil then
		self.showJumpBtn = data.showJumpBtn
	end

	if data.customJumpText ~= nil then
		self.customJumpText = data.customJumpText
	end

	if data.showAutoPlayBtn ~= nil then
		self.showAutoBtn = data.showAutoPlayBtn
	end

	if data.banSkip ~= nil then
		self.banSkip = data.banSkip
	end
end

function M:OnAutoBtnClick()
	self:SetButtonsForAuto(true)
	gDialogManager:SwitchAutoPlay(true)
end

function M:OnAutoBtnCancelClick()
	self:SetButtonsForAuto(false)
	gDialogManager:SwitchAutoPlay(false)
end

function M:OnReviewBtnClick()
	gDialogManager:ShowHistory()
end

function M:SetButtonsForAuto(auto)
	self.bindData.btnAuto:SetActive(not auto and gDialogManager.isPlayingDialog and self.showAutoBtn)
	self.bindData.btnReview:SetActive(not auto and gDialogManager.isPlayingDialog)
	self.bindData.btnSkip:SetActive(not auto and self.jumpToEnd and self.showJumpBtn and not gDialogManager.isShowBranch)
	self.bindData.btnAutoCancel:SetActive(auto)
end

function M:RefreshBtn()
	self:SetButtonsForAuto(gDialogManager.autoPlay)
end

function M:JumpFunc()
	gTimelineManager:Timeline_SetTimelineScale(self.timelineName, "JumpPanel", 1)
	gDialogManager:ResumeCurrentVoice()
	gPanelManager:Close(gPanelId.TIMELINE_JUMP_BTN)
	gDialogManager:CloseDialog()
	gTimelineManager:Timeline_Stop(self.timelineName)
end

function M:OnJumpBtnClick()
	if self.jumpToEnd then
		self.isShowBoombox = true

		gTimelineManager:Timeline_SetTimelineScale(self.timelineName, "JumpPanel", 0)
		gDialogManager:PauseCurrentVoice()

		if gCS.LuaUtils.IsOnAndroid then
			gPanelManager:CheckShow(gPanelId.S_SKIP_DIALOG_PANEL, {
				text = self.customJumpText,
				jumpFunc = self.JumpFunc,
				cancelFunc = function ()
					gTimelineManager:Timeline_SetTimelineScale(self.timelineName, "JumpPanel", 1)
					gDialogManager:ResumeCurrentVoice()
				end
			})
		else
			self:JumpFunc()
		end
	end
end
