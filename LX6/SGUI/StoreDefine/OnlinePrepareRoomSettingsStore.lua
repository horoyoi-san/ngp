-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\OnlinePrepareRoomSettingsStore.lua
-- Decompiled from: 01095_OnlinePrepareRoomSettingsStore.lua_41c0b9b1973d.luajit

C_OnlinePrepareRoomSettingsStore = DefClass("C_OnlinePrepareRoomSettingsStore", C_OnlinePrepareRoomSettingsStore, C_StoreGroup)
GroupName2Class.OnlinePrepareRoomSettingsStore = C_OnlinePrepareRoomSettingsStore
local M = C_OnlinePrepareRoomSettingsStore

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
	self.bindData.onExitBtn = self.CreateAction(self, self.OnClickExitBtn)
	self.bindData.settingList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderSettingListItem)
	self.bindData.settingList.luaSimpleClick = self.CreateAction(self, self.OnSimpleClickSettingList)
end

M.OnClickExitBtn = function(self)
	if self.onCloseCallback then
		self.onCloseCallback()
	end
end

M.OnSimpleRenderSettingListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local cfg = LTConfig.TextScriptTextConfig.GetConfig(89901501)
	store.itemTitle = cfg and cfg.Text or ""
	store.state = self.allowNonHostInvite and 0 or 1
	store.switchStateBtn.luaClick = self:CreateAction(self.OnSwitchAllowNonHostInvite)
end

M.OnSimpleClickSettingList = function(self, btn, index)
end

M.OnSwitchAllowNonHostInvite = function(self)
	if self.requesting then
		return
	end

	self.requesting = true
	slot1 = gClientToGameDelegate

	slot1:ChangePrepareRoomSetting({
		AllowNonLeaderInvite = not self.allowNonHostInvite
	}).Callback = function (err)
		self.requesting = false

		if err == 0 then
			gDisplayMessageMgr:ShowServerMessage(err)

			return
		end
	end
end

M.InitData = function(self, onCloseCallback)
	self.requesting = false
	self.onCloseCallback = onCloseCallback
end

M.Refresh = function(self, linkGame)
	local setting = linkGame and linkGame.uxData and linkGame.uxData.Setting

	if not setting then
		self.bindData.settingList:SetSimpleList(0)

		return
	end

	self.allowNonHostInvite = setting and setting.AllowNonLeaderInvite

	self.bindData.settingList:SetSimpleList(1)
end
