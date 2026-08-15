local CSPauseManager = LX6.Engine.PauseManager
C_UidLayerPanelStore = DefClass("C_UidLayerPanelStore", C_UidLayerPanelStore, C_StoreGroup)
GroupName2Class.UidLayerPanelStore = C_UidLayerPanelStore
local M = C_UidLayerPanelStore
local BOOL2CTL = {
	[true] = 0,
	[false] = 1
}

function M:ctor()
	self.msgEvents = {
		[gEventConstants.BEFORE_SWITCH_SCENE] = self:CreateAction("OnBeforeSwitchScene")
	}
end

function M:OnAwake()
	self:RegisterMessageEvents(self.msgEvents)

	gLuaUIMgr.uidLayerPanelStore = self
end

function M:OnShow(panelId, data)
	self:RefreshUID()
end

function M:OnClose()
	return
end

function M:OnDestroy()
	self:ClearMessageEvents()

	gLuaUIMgr.uidLayerPanelStore = nil
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end

function M:ShowPauseInfo(serveSpeed)
	if not gGameManager.Env.isEditor or not gCS.PauseManager.showPauseTip then
		self.bindData.pauseLabel = ""

		return
	end

	local clientSpeed = CSPauseManager.Instance.PauseSpeed
	local text = ""

	if clientSpeed then
		if clientSpeed == 0 then
			text = text .. "客户端暂停 "
		elseif clientSpeed < 1 then
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

function M:RefreshUID()
	if gPlayerManager.infoLogin.bindData.pid == nil then
		self:RefreshUIDDisplay(false)

		self.bindData.uidLabel = ""

		return
	end

	self:RefreshUIDDisplay(true)

	self.bindData.uidLabel = "UID:" .. ulong.tostring(gPlayerManager.infoLogin.bindData.pid)
end

function M:RefreshUIDDisplay(show)
	self.bindData.showUID = BOOL2CTL[show]
end

function M:OnBeforeSwitchScene(eventId, switchType)
	if switchType == gSwitchSceneType.KickToLogin then
		self:RefreshUIDDisplay(false)
	end
end
