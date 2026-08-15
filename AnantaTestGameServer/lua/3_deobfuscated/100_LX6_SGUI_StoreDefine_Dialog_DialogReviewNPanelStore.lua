C_DialogReviewNPanelStore = DefClass("C_DialogReviewNPanelStore", C_DialogReviewNPanelStore, C_StoreGroup)
GroupName2Class.DialogReviewNPanelStore = C_DialogReviewNPanelStore
local M = C_DialogReviewNPanelStore
local ExternalSourceType = LX6.Audio.ExternalSourceType
local DialogConfig = LTConfig.DialogConfig
local AudioState = {
	Stop = 1,
	Play = 2,
	None = 0
}

function M:ctor()
	return
end

function M:OnAwake()
	self.bindData.ReviewList.luaSimpleRenderItem = self:CreateAction("OnReviewListItem")
	self.bindData.ReviewList.onGetTIndex = self:CreateAction("OnGetTIndex")
	self.bindData.ReviewList.luaSimpleDynamicRenderItem = self:CreateAction("OnReviewListItem")
	self.bindData.ReviewList.luaClick = self:CreateAction("OnReviewListClick")
	self.bindData.btnClose.luaClick = self:CreateAction("OnCloseReviewClick")
	self.currentVoiceNid = 0
	self.dialogDataTempForEndCb = nil
end

function M:ProcessOverview(dialogInfos)
	local recordCount = #dialogInfos

	if recordCount > 0 then
		local firstId = dialogInfos[1].dialogId
		local firstCfg = DialogConfig.GetConfig(firstId)

		if firstCfg and firstCfg.Recap and firstCfg.Recap ~= "" then
			self.bindData.isOverview = 1
			self.bindData.OverviewText.text = firstCfg.Recap
		else
			self.bindData.isOverview = 0
		end
	else
		self.bindData.isOverview = 0
	end
end

function M:OnShow(panelId, data)
	self.isPlayVoiceDialogId = nil
	local dialogInfos = data:ToTable()
	local recordCount = #dialogInfos

	self:ProcessOverview(dialogInfos)

	self.recordings = {}

	for i = 1, recordCount do
		local dialogReviewData = dialogInfos[i]
		local record = {
			sayer = dialogReviewData.sayer,
			label = dialogReviewData.message,
			ScrollToMe = dialogReviewData.scrollToMe,
			externalVoiceId = dialogReviewData.externalVoiceId,
			dialogId = dialogReviewData.dialogId
		}

		table.insert(self.recordings, record)
	end

	self:RefreshReviewList()
	self.bindData.ReviewList:GoToIndex(recordCount - 1, true)
	gMessageManager:SendMessage(gEventConstants.DIALOG_REVIEW_PANEL_STATE, 1)
end

function M:OnClose()
	self:StopVoice()
	gMessageManager:SendMessage(gEventConstants.DIALOG_REVIEW_PANEL_STATE, 2)
end

function M:PlayVoice(dialogData)
	self.dialogDataTempForEndCb = nil
	local dialogId = dialogData.dialogId
	local externalVoiceId = dialogData.externalVoiceId

	if externalVoiceId and externalVoiceId ~= 0 then
		self.currentVoiceNid = gSoundMgr:PlaySoundByExternalSourceId(externalVoiceId, ExternalSourceType.Voice, nil, function (uuid, soundData)
			if uuid <= 0 then
				self:PlayVoiceCb(nil)
			else
				self:PlayVoiceCb(dialogId)
			end
		end, nil, function (uuid, soundData)
			self:EndVoiceCb()
		end)
	end
end

function M:StopVoice()
	self.isPlayVoiceDialogId = nil

	if self.currentVoiceNid and self.currentVoiceNid ~= 0 then
		gSoundMgr:StopSoundByNid(self.currentVoiceNid)
	end
end

function M:OnReviewListItem(btn, index)
	local data = self.recordings[index + 1]
	local store = self:GetStoreByWidget(btn)

	if store then
		store.name = data.sayer .. "："
		store.text = data.label

		if data.sayer == "<player>" or data.dialogId == 0 then
			store.Speaker = 0
		else
			store.Speaker = 1
		end

		if data.externalVoiceId > 0 then
			if self.isPlayVoiceDialogId == data.dialogId then
				store.AudioState = AudioState.Play
			else
				store.AudioState = AudioState.Stop
			end
		else
			store.AudioState = AudioState.None
		end

		if data.ScrollToMe then
			self.bindData.Navigation.CurrentActiveContent = btn
			data.ScrollToMe = false
		end
	end
end

function M:OnReviewListClick(btn, data)
	local dialogId = data.dialogId

	if dialogId == -1 then
		return
	end

	if self.isPlayVoiceDialogId == dialogId then
		self:StopVoice()

		return
	end

	if self.isPlayVoiceDialogId then
		self.dialogDataTempForEndCb = data

		self:StopVoice()
	else
		self:PlayVoice(data)
	end
end

function M:EndVoiceCb()
	self.isPlayVoiceDialogId = nil

	if self.dialogDataTempForEndCb then
		self:PlayVoice(self.dialogDataTempForEndCb)

		self.dialogDataTempForEndCb = nil
	else
		self:RefreshReviewList()
	end
end

function M:PlayVoiceCb(dialogId)
	self.isPlayVoiceDialogId = dialogId

	self:RefreshReviewList()
end

function M:RefreshReviewList()
	if self.bindData and self.bindData.ReviewList then
		self.bindData.ReviewList:SetSimpleList(#self.recordings)
	end
end

function M:OnGetTIndex(index)
	return 0
end

function M:OnCloseReviewClick()
	gPanelManager:Close(gPanelId.S_DIALOG_REVIEW_N_PANEL)
end
