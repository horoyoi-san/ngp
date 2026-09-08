-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\DriveImmersivePanelStore.lua
-- Decompiled from: 01845_DriveImmersivePanelStore.lua_b12c82890e6c.luajit

C_DriveImmersivePanelStore = DefClass("C_DriveImmersivePanelStore", C_DriveImmersivePanelStore, C_StoreGroup)
GroupName2Class.DriveImmersivePanelStore = C_DriveImmersivePanelStore
local M = C_DriveImmersivePanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.isPc = false
	self.ANIME_NAME = {
		["UXu"] = "\\xdc\\x95\\xfa!ù\\xe0塚\\xee\\x850\\xf7\\x83>\\x8a\\xd1m\\x97\\xb6\\x85",
		["n\\x82\\x8d\\x9c\\x93"] = "^\\xc1]\\xfb\\xdd\\xe0f*\\xf1AH\\xf6\\xf5j\\xeemd\\xd3\\xef\\xfcѓ\\xe1a"
	}
	self.needUpdateClose = false
	self.closeTime = 0
end

M.DefineAllEnumsAutoGen = function(self)
	self.btnHideCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.wordsCtrlEnum = {
		["k\\xaf\\xae\\xbc\\xb3"] = 0,
		["N0h^"] = 1
	}
	self.qteVxCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.btnHideCtrlEnum = nil
	self.wordsCtrlEnum = nil
	self.qteVxCtrlEnum = nil
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
	self.currVehicleData = data

	gCS.LuaUtils.PlayAnimationByName(self.bindData.pcAnime, self.ANIME_NAME.OPEN)
end

M.OnClose = function(self)
	self.currVehicleData = nil
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
end
