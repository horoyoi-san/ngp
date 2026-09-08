-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\OnlineInGameNoticePanelStore.lua
-- Decompiled from: 01112_OnlineInGameNoticePanelStore.lua_cbf341283fc4.luajit

local PopupSyncConfig = LTConfig.SyncValuePopupSyncConfig
C_OnlineInGameNoticePanelStore = DefClass("C_OnlineInGameNoticePanelStore", C_OnlineInGameNoticePanelStore, C_StoreGroup)
GroupName2Class.OnlineInGameNoticePanelStore = C_OnlineInGameNoticePanelStore
local M = C_OnlineInGameNoticePanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
	self.colorEnum = {
		["Z\\x90\\x80\\x84D"] = 1,
		["x.h^"] = 2,
		["J\\xbc\\xa7\\xaa\\xb8"] = 3,
		["\\x9cmb"] = 0
	}
	self.showImgEnum = {
		["POc~G="] = 1,
		["G\\x83\\x83\\x82M"] = 0
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.colorEnum = nil
	self.showImgEnum = nil
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
	self.cfg = PopupSyncConfig.GetConfig(data.id)

	if not self.cfg then
		return
	end

	if self.cfg.IsImportant then
		gNewGamePlayProgressMgr:AskPopupEnter(self.cfg.Id)
	end

	self.bindData.descLabel = self.cfg.Desc
	self.bindData.iconId = self.cfg.ImageId
	local hasIcon = self.cfg.ImageId == 0
	self.bindData.showImg = hasIcon and self.showImgEnum.showimage or self.showImgEnum.normal
	self.bindData.color = self.cfg.NoticeColor

	gLuaTimeMgrUtils.Delay(function ()
		self:OnExit()
	end, self.cfg.Duration, 1, nil, true)
end

M.OnExit = function(self)
	gPanelManager:Close(self.m_Id)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
end
