-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ChallengeEndPanelStore.lua
-- Decompiled from: 01552_ChallengeEndPanelStore.lua_aec8d86a90cb.luajit

local TextCommonTextConfig = LTConfig.TextCommonTextConfig
C_ChallengeEndPanelStore = DefClass("C_ChallengeEndPanelStore", C_ChallengeEndPanelStore, C_StoreGroup)
GroupName2Class.ChallengeEndPanelStore = C_ChallengeEndPanelStore
local M = C_ChallengeEndPanelStore

M.ctor = function(self)
	self.callback = nil
	self.timer = nil
end

M.OnAwake = function(self)
end

M.OnShow = function(self, panelId, data)
	self.callback = data.callback
	self.closeWaitToken = data.closeWaitToken
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

M.OnClose = function(self)
	if self.callback then
		self.InvokeCallBack(self, self.callback)

		self.callback = nil
	end

	if self.closeWaitToken then
		self.closeWaitToken:SetResult(true)

		self.closeWaitToken = nil
	end
end

M.InvokeCallBack = function(self, cb)
	if type(cb) ~= "userdata" then
		cb.DynamicInvoke(cb)
	else
		cb()
	end
end
