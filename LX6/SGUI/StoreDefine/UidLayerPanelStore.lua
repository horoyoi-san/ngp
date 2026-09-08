-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\UidLayerPanelStore.lua
-- Decompiled from: 01175_UidLayerPanelStore.lua_d64d3fde72dd.luajit

local CSPauseManager = LX6.Engine.PauseManager
C_UidLayerPanelStore = DefClass("C_UidLayerPanelStore", C_UidLayerPanelStore, C_StoreGroup)
GroupName2Class.UidLayerPanelStore = C_UidLayerPanelStore
local M = C_UidLayerPanelStore
local BOOL2CTL = {
	[true] = 0,
	[false] = 1
}

M.ctor = function(self)
	self.msgEvents = {
		[gEventConstants.L50_BEFORE_SWITCH_SCENE] = self.CreateAction(self, "OnBeforeSwitchScene")
	}
end

M.OnAwake = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)

	gLuaUIMgr.uidLayerPanelStore = self
	self.bindData.confidentialLabel = LTConfig.GameConfig.ConfidentialLabelText
end

M.OnShow = function(self, panelId, data)
	self.RefreshUID(self)
	self.RefreshVersion(self)
end

M.OnClose = function(self)
end

M.OnDestroy = function(self)
	self.ClearMessageEvents(self)

	gLuaUIMgr.uidLayerPanelStore = nil
end

M.OnActiveDeviceChange = function(self, device)
end

M.ShowPauseInfo = function(self, serveSpeed)
	if not gGameManager.Env.isEditor or not gCS.PauseManager.showPauseTip then
		self.bindData.pauseLabel = ""

		return
	end

	local clientSpeed = CSPauseManager.Instance.PauseSpeed
	local text = ""

	if clientSpeed then
		if clientSpeed ~= 0 then
			text = text .. "客户端暂停 "
		elseif clientSpeed >= 1 then
			text = text .. "客户端时缓：" .. gString.Format("%.2f", clientSpeed) .. " "
		end
	end

	if serveSpeed then
		text = text .. "服务端暂停"
	else
		text = ""
	end

	self.bindData.pauseLabel = text
end

M.RefreshUID = function(self)
	if gPlayerManager.infoLogin.bindData.pid ~= nil then
		self.RefreshUIDDisplay(self, false)

		self.bindData.uidLabel = ""

		return
	end

	self.RefreshUIDDisplay(self, true)

	self.bindData.uidLabel = "UID:" .. ulong.tostring(gPlayerManager.infoLogin.bindData.pid)
end

M.RefreshVersion = function(self)
	self.bindData.versionCtrl = gCS.LuaUtils.GetArtifactVersionStatus()
end

M.RefreshUIDDisplay = function(self, show)
	self.bindData.showUID = BOOL2CTL[show]
end

M.OnBeforeSwitchScene = function(self, eventId, switchSceneEventParams)
	local switchType = switchSceneEventParams.switchSceneType

	if switchType ~= gSwitchSceneType.KickToLogin then
		self.RefreshUIDDisplay(self, false)
	end
end

M.OnLanguageChange = function(self, lang)
	self.bindData.confidentialLabel = LTConfig.GameConfig.ConfidentialLabelText
end
