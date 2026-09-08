-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\WatchingGameInteractionStore.lua
-- Decompiled from: 01150_WatchingGameInteractionStore.lua_7cc497db5d1b.luajit

local LinkInteractionConfig = LTConfig.LinkInteractionConfig
local LinkConfig = LTConfig.LinkConfig
C_WatchingGameInteractionStore = DefClass("C_WatchingGameInteractionStore", C_WatchingGameInteractionStore, C_StoreGroup)
GroupName2Class.WatchingGameInteractionStore = C_WatchingGameInteractionStore
local M = C_WatchingGameInteractionStore

M.OnAwake = function(self)
	self.TYPE = {
		["\"/\\xf3Z\\x96\\xe31\\xba.\\xe5\\xe6\\xef{\\xf5"] = 1,
		["\\x99\\xb4\\xbbe0\\xed6"] = 2,
		["\\xf1\\xd2<0\\xff"] = 3,
		["T-s^"] = 0
	}
	self.bindData.respond = self.CreateAction(self, "OnRespondBtnClick")
	self.bindData.shield = self.CreateAction(self, "OnShieldBtnClick")
	self.maskList = {}
end

M.SetData = function(self, data)
	if data.isResponse and data.isSource then
		self.bindData.showInteraction = 0

		return
	end

	if self.maskList[data.pid] then
		return
	end

	self.data = data

	self.HideInteraction(self)

	local cfg = LinkInteractionConfig.GetConfig(data.type)

	if data.isResponse then
		self.bindData.showInteraction = self.TYPE.Response
		self.bindData.respondIcon = cfg.Icon
	else
		if data.isSource then
			self.bindData.showInteraction = self.TYPE.HideBtn
			self.bindData.playerName = gPlayerManager.infoLogin.bindData.name
		else
			self.bindData.showInteraction = self.TYPE.ShowInteraction
			self.bindData.playerName = data.name
		end

		if data.context ~= "" then
			self.bindData.msg = LTConfig.TextCommonTextConfig.GetConfig(tonumber(cfg.Text)).Text
		else
			self.bindData.msg = data.context
		end

		self.bindData.icon = cfg.Icon
	end
end

M.HideInteraction = function(self)
	if self.waitTimer then
		self.waitTimer:Stop()

		self.waitTimer = nil
	end

	self.waitTimer = Timer.New(function ()
		self.bindData.showInteraction = 0
		self.waitTimer = nil
	end, LinkConfig.LinkInteractionPopupShowTime):Start()
end

M.OnRespondBtnClick = function(self)
	if self.data.isSource or self.data.isResponse then
		return
	end

	slot1 = gClientToGameDelegate

	slot1:AskSendInteractionInfo(self.data.pid, self.data.type, true).Callback = function (err, data)
		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
		end
	end
end

M.OnShieldBtnClick = function(self)
	self.maskList[self.data.pid] = true
end
