local TextCommonTextConfig = LTConfig.TextCommonTextConfig
C_ChallengeEndPanelStore = DefClass("C_ChallengeEndPanelStore", C_ChallengeEndPanelStore, C_StoreGroup)
GroupName2Class.ChallengeEndPanelStore = C_ChallengeEndPanelStore
local M = C_ChallengeEndPanelStore

function M:ctor()
	self.callback = nil
	self.timer = nil
end

function M:OnAwake()
	return
end

function M:OnShow(panelId, data)
	self.callback = data.callback
	self.bindData.isShowSuccess = data.isSuccess and 1 or 0
	self.bindData.failText = data.failText or TextCommonTextConfig.GetConfig(TextCommonTextConfig.ChallengeFail).Text
	self.bindData.successText = data.successText or TextCommonTextConfig.GetConfig(TextCommonTextConfig.ChallengeSuccess).Text
	local animTime = nil

	if data.isSuccess then
		animTime = self.bindData.successAnim:GetClip("S_Vx_ChallengeEndPanel_Success").length
	else
		animTime = self.bindData.failAnim:GetClip("S_Vx_ChallengeEndPanel_Fail").length
	end

	self.timer = Timer.New(function ()
		self.timer = nil

		gPanelManager:Close(gPanelId.S_CHALLENGE_END_PANEL)
	end, animTime or 2):Start()
end

function M:OnClose()
	if self.callback then
		self.callback()

		self.callback = nil
	end
end
