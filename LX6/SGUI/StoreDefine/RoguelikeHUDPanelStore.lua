-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\RoguelikeHUDPanelStore.lua
-- Decompiled from: 00871_RoguelikeHUDPanelStore.lua_4428d5764b94.luajit

C_RoguelikeHUDPanelStore = DefClass("C_RoguelikeHUDPanelStore", C_RoguelikeHUDPanelStore, C_StoreGroup)
GroupName2Class.RoguelikeHUDPanelStore = C_RoguelikeHUDPanelStore
local M = C_RoguelikeHUDPanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.showBtn.luaClick = self.CreateAction(self, self.OnClickShowBtn)
	self.bindData.giveUpBtn.luaClick = self.CreateAction(self, self.OnClickGiveUpBtn)
	self.bindData.giveUpBtn.luaLongPress = self.CreateAction(self, self.OnClickGiveUpBtn)
end

M.OnClickShowBtn = function(self)
	gPanelManager:CheckShow(gPanelId.ROGUELIKE_IN_GAME_PANEL)
end

M.OnClickGiveUpBtn = function(self)
	local content = LTConfig.TextScriptTextConfig.GetConfig(89901578).Text
	slot2 = gDisplayMessageMgr

	slot2:ShowMessageContent(content, gDisplayMessageId.SELECT, nil, function ()
		gRoguelikeManager:LeaveRogueLikeGame()
	end, nil, LTConfig.TextScriptTextConfig.GetConfig(89900149).Text, LTConfig.TextCommonTextConfig.GetConfig(74009093).Text)
end
