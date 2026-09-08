-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\MultiversePromoWindowPanelStore.lua
-- Decompiled from: 01055_MultiversePromoWindowPanelStore.lua_45e8ca452402.luajit

local MainPageTabConfig = LTConfig.MultiverseMainPageTabConfig
C_MultiversePromoWindowPanelStore = DefClass("C_MultiversePromoWindowPanelStore", C_MultiversePromoWindowPanelStore, C_StoreGroup)
GroupName2Class.MultiversePromoWindowPanelStore = C_MultiversePromoWindowPanelStore
local M = C_MultiversePromoWindowPanelStore

M.ctor = function(self)
	self.mgr = gMultiverseMgr
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
	self.isCurrentVerseEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.isCurrentVerseEnum = nil
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
	self.id = data and data.id or 0
	self.cfg = MainPageTabConfig.GetConfig(self.id)

	if not self.cfg then
		return
	end

	self.bindData.descLabel = self.cfg.detailedDesc
	self.bindData.titleLabel = self.cfg.Name
	self.bindData.backgroundImage = self.cfg.Image

	self.mgr:RefreshCurrentVerse(self.bindData, self.cfg.VerseId)

	self.bindData.confirmBtn.interactable = self.mgr:CheckVerse(self.cfg.VerseId)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.confirmBtn.luaClick = self.CreateAction(self, self.OnClickConfirmBtn)
	self.bindData.backBtn.luaClick = self.CreateAction(self, self.OnClickBackBtn)
end

M.OnClickConfirmBtn = function(self)
	self.mgr:AskEnterMultiverse(self.cfg.VerseId)
end

M.OnClickBackBtn = function(self)
	gPanelManager:Close(self.m_Id)
end
