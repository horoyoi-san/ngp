-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\AkxFloatWindowInputBarStore.lua
-- Decompiled from: 01602_AkxFloatWindowInputBarStore.lua_988fd1e5ea7d.luajit

C_AkxFloatWindowInputBarStore = DefClass("C_AkxFloatWindowInputBarStore", C_AkxFloatWindowInputBarStore, C_StoreGroup)
GroupName2Class.AkxFloatWindowInputBarStore = C_AkxFloatWindowInputBarStore
local M = C_AkxFloatWindowInputBarStore
M.SendBtnCtrl = {
	["9F\\x90\\x8c\\x8fD"] = 2,
	I6rK = 3,
	["\\xfd\\xd2(\\xf4"] = 0
}

M.ctor = function(self)
	self.sessionid = nil
end

M.OnAwake = function(self)
	self.bindData.btnSend.luaClick = self.CreateAction(self, "OnClickBtnSend")
end

M.OnDestroy = function(self)
end

M.OnEnable = function(self)
	self:InitEvent()

	self.windowStore = gStoreManager:GetStoreGroup("AkxFloatWindowPanel")
end

M.OnDisable = function(self)
	self.ClearMessageEvents(self)
end

M.InitEvent = function(self)
	local msgEvents = {
		[gEventConstants.AKX_SESSION_UPDATED] = self.CreateAction(self, "RefreshSession")
	}

	self.RegisterMessageEvents(self, msgEvents)
end

M.RefreshPanel = function(self, sessionid)
	self.sessionid = sessionid

	self.LoadSessionState(self)
end

M.RefreshSession = function(self, _, data)
	if not data.sessionid then
		return
	end

	self.sessionid = data.sessionid
	local message, _ = gAkxManager:GetMessage(data.sessionid, data.messageid)

	if not message then
		return
	end

	self.LoadSessionState(self)

	if self.windowStore then
		self.windowStore:RefreshPanel(data.sessionid)
	end
end

M.LoadSessionState = function(self)
	if self.sessionid then
		local session = gAkxManager:GetSession(self.sessionid)

		if session and #session.messages <= 0 then
			local lastMessage = session.messages[#session.messages]

			if lastMessage.answered then
				self.bindData.inputCtrl = self.SendBtnCtrl.Enable
			else
				self.bindData.inputCtrl = self.SendBtnCtrl.Stop
			end

			return
		end
	end

	self.bindData.inputCtrl = self.SendBtnCtrl.Enable
end

M.SendMessage = function(self, message)
	gAkxManager:PushMessage(message, self.sessionid)

	self.bindData.inputCtrl = self.SendBtnCtrl.Stop
	self.bindData.playerInput.text = ""
end

M.OnClickBtnSend = function(self)
	if string.is_null_or_empty(self.bindData.playerInput.text) then
		local chatInputEmptyCfg = LTConfig.MessageConfig.GetConfig(LTConfig.MessageConfig.V4ChatInputEmpty)

		gDisplayMessageMgr:ShowMessageContent(chatInputEmptyCfg.Content)

		return
	end

	self.SendMessage(self, self.bindData.playerInput.text)
end

M.OnActiveDeviceChange = function(self, device)
end
