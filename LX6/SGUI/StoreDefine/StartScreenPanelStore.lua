-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\StartScreenPanelStore.lua
-- Decompiled from: 01297_StartScreenPanelStore.lua_15275efe967d.luajit

local PatchPackageMgr = LX6.Engine.Patch.PatchPackageMgr.Instance
local MultiverseConfig = LTConfig.MultiverseConfig
C_StartScreenPanelStore = DefClass("C_StartScreenPanelStore", C_StartScreenPanelStore, C_StoreGroup)
GroupName2Class.StartScreenPanelStore = C_StartScreenPanelStore
local M = C_StartScreenPanelStore
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
	self.showDLCTestEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.showDebugEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.showDLCTestEnum = nil
	self.showDebugEnum = nil
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

	self.bindData.showDebug = gCS.LuaUtils.IsPublish and self.showDebugEnum._false or self.showDebugEnum._true
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)

	self.bindData.showDebug = self.showDebugEnum._false
end

M.OnShow = function(self, panelId, data)
	self:SetAgeTipPos()
	self.SubGroup.LoginTestPanelStore:OnShow(panelId, data)

	self.bindData.versionText = PatchPackageMgr:FetchVersionStr()

	gMessageManager:SendMessage(gEventConstants.HIDE_WAITING_PANEL, nil)

	if not self.soundNid then
		self.soundNid = gSoundMgr:PlaySoundByTid(LTConfig.GameConfig.LoginInterface)
	end

	self.isFirst = true

	if data then
		self.isFirst = data.isFirst
		self.isInloginQueue = data.isInloginQueue
	end

	if self.isFirst then
		self.mgr:PreConnect()
	end

	LX6.Manager.GameQualitySettings.Instance:ApplySettings()

	gCS.LoginManager.isFirstLogin = false

	self.bindData.videoPlayer:Init()
	self.bindData.videoPlayer:PlayVideo(MultiverseConfig.LoginPanelVideo, true)
	self:RefreshDLCProgress()
end

M.OnClose = function(self)
	gSoundMgr:StopSoundByNid(self.soundNid)

	self.soundNid = nil
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.LANGUAGE_CHANGE] = self.CreateAction(self, self.OnLanguageChange),
		[gEventConstants.DLC_DOWN_LOAD_PROGRESS_CHANGED] = function (_)
			self:RefreshDLCProgress()
		end
	}
end

M.RegisterWidget = function(self)
	self.bindData.enterGameBtn.luaClick = self.CreateAction(self, self.OnClickEnterGameBtn)
	self.bindData.ageTipBtn.luaClick = self.CreateAction(self, self.OnClickAgeTipBtn)
	self.bindData.exitBtn.luaClick = self.CreateAction(self, self.OnClickExitBtn)
	self.bindData.announcementBtn.luaClick = self.CreateAction(self, "OpenNoticePanel", gAnnouncementMgr)
	self.bindData.settingBtn.luaClick = self.CreateAction(self, self.OnClickSettingBtn)
	self.bindData.fixClientBtn.luaClick = self.CreateAction(self, self.OnClickFixClientBtn)
	self.bindData.qrcodeBtn.luaClick = self.CreateAction(self, self.OnClickQrcodeBtn)
	self.bindData.accountBindBtn.luaClick = self.CreateAction(self, self.OnClickAccountBindBtn)
	self.bindData.accountBtn.luaClick = self.CreateAction(self, self.OnClickAccountBtn)
	self.bindData.dlcDownloadBtn.luaClick = self.CreateAction(self, self.OnClickDlcDownloadBtn)
end

M.OnClickEnterGameBtn = function(self)
	if not gDlcDownLoadMgr:IsAllMandatoryDownloaded() then
		gDlcDownLoadMgr:EnterDownloadPanelByNetwork(0, true)

		return
	end

	local overlayVideoId = MultiverseConfig.OverlayVideo

	if overlayVideoId ~= 0 then
		self.mgr:OnLogin()

		return
	end

	self.bindData.enterGameBtn.interactable = false
	local entered = false

	local doLogin = function()
		if entered then
			return
		end

		entered = true

		self.mgr:OnLogin()
	end

	self.bindData.overlayPlayer:Init()
	self.bindData.overlayPlayer:PlayVideo(overlayVideoId, false, function ()
		if self.enterGameGuardTimer then
			self.enterGameGuardTimer:Stop()

			self.enterGameGuardTimer = nil
		end

		doLogin()
	end)

	self.enterGameGuardTimer = Timer.New(function ()
		self.enterGameGuardTimer = nil

		doLogin()
	end, 10):Start()
end

M.OnClickAgeTipBtn = function(self)
	gDisplayMessageMgr:ShowMessExplain(LTConfig.MessageExplainConfig.ShiLingTiXing)
end

M.OnClickExitBtn = function(self)
	self.mgr:OnClick_PCQuit()
end

M.OnClickSettingBtn = function(self)
	gPanelManager:CheckShow(gPanelId.S_SETTINGS_PANEL, {
		["\\x96'0\\x94O\\xea?\\xa5\\xae"] = false
	})
end

M.OnClickFixClientBtn = function(self)
	gUIUtils:ClickRepairClient()
end

M.OnClickQrcodeBtn = function(self)
	UniSDKManager.ScanQRCode()
end

M.OnClickAccountBindBtn = function(self)
	self.mgr:ShowAccountBind()
end

M.OnClickAccountBtn = function(self)
	self:SetAgeTipPos()
	gCS.LoginManager:OpenUserCenter()
end

M.OnClickDlcDownloadBtn = function(self)
	gPanelManager:CheckShow(gPanelId.DLC_DOWNLOAD_PANEL, {
		["w-y^"] = 0
	})
end

M.RefreshDLCProgress = function(self)
	local isShow = gDlcDownLoadMgr:IsShowProgressBtn(true)
	self.bindData.showDLCTest = BOOL2CTL[isShow]

	if isShow then
		gDlcDownLoadMgr:RefreshDLCProgressStore(self.bindData.dlcDownloadBtn)
	end
end

M.SetAgeTipPos = function(self)
	local camera = SGUI.UWidget.uiCamera

	if camera then
		local ageTipTrans = self.bindData.ageTipBtn.rectTransform
		local screenPos = camera:WorldToScreenPoint(ageTipTrans.position)
		local uiPos = gUtils:ScreenToUIPosition(screenPos)
		local rect = self.bindData.ageTipBtn.rectTransform.rect

		gUIUtils:AdjustAgeTip(uiPos, rect.width, rect.height)
	else
		print_notice("StartScreenPanelStore SetAgeTipPos camera is nil")
	end
end
