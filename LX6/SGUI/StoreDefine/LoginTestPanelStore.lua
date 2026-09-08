-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\LoginTestPanelStore.lua
-- Decompiled from: 01789_LoginTestPanelStore.lua_0d5eed29dc1a.luajit

C_LoginTestPanelStore = DefClass("C_LoginTestPanelStore", C_LoginTestPanelStore, C_StoreGroup)
GroupName2Class.LoginTestPanelStore = C_LoginTestPanelStore
local M = C_LoginTestPanelStore
local BOOL2CTL = {
	[true] = 0,
	[false] = 1
}

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
	self.showTestAccountInputEnum = {
		["#N\\x90\\x82\\x90D"] = 1,
		["r\\xba\\xb0\\xba\\xb3"] = 0
	}
	self.showServerBtnCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.showTestAccountInputEnum = nil
	self.showServerBtnCtrlEnum = nil
end

M.OnAwake = function(self)
	self.mgr = gLoginManager

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
	self:RegisterMessageEvents(self.msgEvents)

	self.bindData.showServerBtnCtrl = gCS.LoginManager.canSelectServer and self.showServerBtnCtrlEnum._true or self.showServerBtnCtrlEnum._false

	if gCS.LoginManager.canSelectServer then
		self.bindData.serverNameText = self.mgr.serverName
	end
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	gMessageManager:SendMessage(gEventConstants.HIDE_WAITING_PANEL, nil)

	if not self.soundNid then
		self.soundNid = gSoundMgr:PlaySoundByTid(LTConfig.GameConfig.LoginInterface)
	end
end

M.OnClose = function(self)
	gSoundMgr:StopSoundByNid(self.soundNid)

	self.soundNid = nil
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.LOGIN_SERVER_CHANGE] = self.CreateAction(self, self.OnChangeServer)
	}
end

M.RegisterWidget = function(self)
	self.bindData.testAccountBtn.luaClick = self.CreateAction(self, self.OnClickTestAccountBtn)
	self.bindData.deleteRoleBtn.luaClick = self.CreateAction(self, self.OnClickDeleteRoleBtn)
	self.bindData.serverBtn.luaClick = self.CreateAction(self, self.OnClickServerBtn)
	self.bindData.accountCancelBtn.luaClick = self.CreateAction(self, self.OnClickAccountCancelBtn)
	self.bindData.accountConfirmBtn.luaClick = self.CreateAction(self, self.OnClickAccountConfirmBtn)
	self.bindData.debugBtn.luaClick = self.CreateAction(self, self.OnClickDebugBtn)
	self.bindData.accountInput.luaValueChanged = self.CreateAction(self, self.OnAccountInputInputValueChanged)
end

M.OnClickTestAccountBtn = function(self)
	self.mgr:DoKickToLogin()

	self.bindData.showTestAccountInput = BOOL2CTL[true]
end

M.OnClickDeleteRoleBtn = function(self)
	self.mgr:OnClick_DeleteRole()
end

M.OnClickServerBtn = function(self)
	self.mgr:OpenSelectServerPanel()
end

M.OnClickAccountCancelBtn = function(self)
	self.mgr:DoLoginUniSDK()

	self.bindData.showTestAccountInput = BOOL2CTL[false]
end

M.OnClickAccountConfirmBtn = function(self)
	if gCS.LuaUtils.IsPublish or not gCS.LoginManager.loginByCheat then
		return
	end

	local inputStr = self.bindData.accountInput.text

	self.mgr:SetEditorAccount(inputStr)
	self.mgr:DoLoginUniSDK()

	self.bindData.showTestAccountInput = BOOL2CTL[false]
end

M.OnClickDebugBtn = function(self)
	gPanelManager:CheckShow(gPanelId.S_TEST_MAIN_PANEL)
end

M.OnAccountInputInputValueChanged = function(self, text)
end

M.OnChangeServer = function(self, _, serverData)
	if serverData then
		self.bindData.serverNameText = serverData.Name
	end
end
