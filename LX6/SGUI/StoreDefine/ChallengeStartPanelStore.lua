-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ChallengeStartPanelStore.lua
-- Decompiled from: 01451_ChallengeStartPanelStore.lua_d2497b97b0d4.luajit

C_ChallengeStartPanelStore = DefClass("C_ChallengeStartPanelStore", C_ChallengeStartPanelStore, C_StoreGroup)
GroupName2Class.ChallengeStartPanelStore = C_ChallengeStartPanelStore
local M = C_ChallengeStartPanelStore

M.OnAwake = function(self)
	self.animeName = "S_Vx_ChallengeStartPanel"
	self.animeTime = 4
	self.needUpdate = false
	self.finishTime = 4
end

M.OnShow = function(self, panelId, data)
	if data then
		self.closeCallback = data and data.callBack or data.CallBack
	else
		self.closeCallback = nil
	end

	self.animeTime = 4
	self.finishTime = gCS.TimeManager.ServerUnixTime + self.animeTime
	self.needUpdate = true

	gCS.LuaUtils.PlayAnimationByName(self.bindData.anime, self.animeName)
end

M.OnUpdate = function(self)
	if self.needUpdate and self.finishTime < gCS.TimeManager.ServerUnixTime then
		self.needUpdate = false

		gPanelManager:Close(gPanelId.S_CHALLENGE_START_PANEL)
		gPanelManager:Close(gPanelId.S_CAR_RACE_START_PANEL)
	end
end

M.OnClose = function(self)
	if self.closeCallback then
		self.InvokeCallBack(self, self.closeCallback, self.needUpdate)
	end

	self.closeCallback = nil
end

M.InvokeCallBack = function(self, cb, param)
	if type(cb) ~= "userdata" then
		cb.DynamicInvoke(cb, param, 0)
	else
		cb(param, 0)
	end
end
