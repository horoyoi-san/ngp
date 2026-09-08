-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\LoginPanelStore.lua
-- Decompiled from: 01788_LoginPanelStore.lua_f233d24dfa83.luajit

local PatchPackageMgr = LX6.Engine.Patch.PatchPackageMgr.Instance
local DRPFUtils = LX6.Utils.DRPFUtils
local LinkConfig = LTConfig.LinkConfig
local EInvokeTime = SGUI.EInvokeTime
C_LoginPanelStore = DefClass("C_LoginPanelStore", C_LoginPanelStore, C_StoreGroup)
GroupName2Class.LoginPanelStore = C_LoginPanelStore
local M = C_LoginPanelStore
local BOOL2CTL = {
	[true] = 0,
	[false] = 1
}
local BtnType = {
	["`S\\xc0\\xba\\x88\r\\x95\\xcd\\xed"] = 1,
	["cO̱\\x8d\\x95\\xcd\\xed"] = 3,
	["\\xaf&))y\\x89D\\xf48\\xae\\xbc"] = 2,
	["\\x9a\\xa4\\xbfM?\\xf36"] = 4
}

M.OnAwake = function(self)
	self.mgr = gLoginManager
	self.btnClickTime = 0
	self.btnClickAnimName = "S_Vx_LogInButton_SelectPressed"
	self.isFirst = true
	self.matchLocalServer = false
	self.availableServerList = {}
	self.blockAllInput = false
	self.btnList = {}
	self.LOGIN_PATCH_FILE = "Login.bin"
	self.msgEvents = {
		[gEventConstants.RESHOW_LOGING_PANEL] = self:CreateActionWithArgs("OnReShow"),
		[gEventConstants.LINK_MODE_UNLOCK_CHAGE] = self:CreateAction("OnUpdateBtnList"),
		[gEventConstants.LINK_MODE_CHANGE] = self:CreateAction("OnUpdateBtnList"),
		[gEventConstants.DLC_DOWN_LOAD_PROGRESS_CHANGED] = function (_)
			self:RefreshDLCProgress()
		end,
		[gEventConstants.PANEL_CLOSE] = self:CreateAction(self.OnPanelClose),
		[gEventConstants.LANGUAGE_CHANGE] = self:CreateAction(self.OnLanguageChange),
		[gEventConstants.LOGIN_SERVER_CHANGE] = self:CreateAction(self.OnChangeServer)
	}
	local length = gCS.LuaUtils.IsNonMobileAdaptive() and #LinkConfig.LoginPanelVideo or 1

	for i = 1, length do
		local videoPlayer = self.bindData["videoPlayer" .. i]
		local videoId = LinkConfig.LoginPanelVideo[i]

		videoPlayer.Init(videoPlayer)
		videoPlayer.PlayVideo(videoPlayer, videoId, true)
		videoPlayer.Pause(videoPlayer)
	end

	self.preIndex = 1

	DRPFUtils.SendLoginUILog()

	self.bindData.backgroundBtn.luaClick = self.CreateAction(self, "OnClick_Login")
	self.bindData.ageTipBtn.luaClick = self.CreateAction(self, "OnClick_AgeTip")
	self.bindData.qrCodeBtn.luaClick = self.CreateAction(self, "OnClick_QrCode")
	self.bindData.deleteRoleBtn.luaClick = self.CreateAction(self, "OnClick_DeleteRole", self.mgr)
	self.bindData.serverBtn.luaClick = self.CreateAction(self, "OpenSelectServerPanel", self.mgr)
	self.bindData.settingBtn.luaClick = self.CreateAction(self, "OnClick_Setting")
	self.bindData.testAccountBtn.luaClick = self.CreateAction(self, "OnClick_TestAccount")
	self.bindData.testAccountConfirmBtn.luaClick = self.CreateAction(self, "OnClick_ConfirmTestAccount")
	self.bindData.testAccountCancelBtn.luaClick = self.CreateAction(self, "OnClick_CancelTestAccount")
	self.bindData.btnList.luaSimpleRenderItem = self.CreateAction(self, self.OnBtnRender)
	self.bindData.btnList.luaSimpleClick = self.CreateAction(self, self.OnBtnClick)
	self.bindData.btnList.luaLayoutSet = self.CreateAction(self, self.OnBtnLayoutSet)
	self.bindData.accountBtn.luaClick = self.CreateAction(self, "OnClick_SDKUserCenter")
	self.bindData.foldBtn.luaClick = self.CreateActionWithArgs(self, "OnChangeFoldMode", false)
	self.bindData.expandBtn.luaClick = self.CreateActionWithArgs(self, "OnChangeFoldMode", true)
	self.bindData.clientFixBtn.luaClick = self.CreateAction(self, "OnClick_Repair")
	self.bindData.announcementBtn.luaClick = self.CreateAction(self, "OpenNoticePanel", gAnnouncementMgr)
	self.bindData.debugBtn.luaClick = self.CreateAction(self, "OnClickDebug")
	self.bindData.downloadBtn.luaClick = self.CreateAction(self, "OnClick_Download")
	self.bindData.accountBindBtn.luaClick = self.CreateAction(self, "OnClick_AccountBind")
end

M.OnReShow = function(self)
	self.blockAllInput = false
end

M.OnUpdateBtnList = function(self)
	self.loginList = {
		{
			["fx\\xb8r^\\xb3\\xf1SkxrI"] = false,
			["a\\x9f\\x8a\\x86Y"] = 0,
			id = BtnType.SingleMode,
			buttonText = LTConfig.TextScriptTextConfig.GetConfig(89901111).Text
		}
	}

	table.insert(self.loginList, {
		["fx\\xb8r^\\xb3\\xf1SkxrI"] = true,
		["a\\x9f\\x8a\\x86Y"] = 0,
		id = BtnType.PublicMode,
		buttonText = LTConfig.TextScriptTextConfig.GetConfig(89901072).Text
	})

	if gCS.LuaUtils.IsPCPlatformOrEditorAdaptive() then
		table.insert(self.loginList, {
			["fx\\xb8r^\\xb3\\xf1SkxrI"] = true,
			["a\\x9f\\x8a\\x86Y"] = 0,
			id = BtnType.QuitGame,
			buttonText = LTConfig.TextScriptTextConfig.GetConfig(89901069).Text
		})
	end

	self.bindData.btnList:SetSimpleList(#self.loginList)
end

M.OnGroupEnable = function(self)
	self.OnUpdateBtnList(self)
	self.SetBaseParams(self, true)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnShow = function(self, panelId, data)
	self:SetAgeTipPos()

	self.bindData.versionText = PatchPackageMgr:FetchVersionStr()
	self.isFirst = true

	if data then
		self.isFirst = data.isFirst
		self.isInloginQueue = data.isInloginQueue
	end

	gMessageManager:SendMessage(gEventConstants.HIDE_WAITING_PANEL, nil)
	self:SetFullUI(not self.isFirst)

	if self.isFirst then
		self.mgr:PreConnect()
	end

	self.bindData.modeType = -1

	self:OnBtnHover(BtnType.SingleMode)
	LX6.Manager.GameQualitySettings.Instance:ApplySettings()

	gCS.LoginManager.isFirstLogin = false

	if not self.soundNid then
		self.soundNid = gSoundMgr:PlaySoundByTid(LTConfig.GameConfig.LoginInterface)
	end
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnClose = function(self)
	gSoundMgr:StopSoundByNid(self.soundNid)

	self.soundNid = nil
end

M.OnDestroy = function(self)
end

M.OnChangeFoldMode = function(self, flag)
	self.bindData.showBtnLayout = BOOL2CTL[flag]
end

M.SetBaseParams = function(self, flag)
	if flag then
		self.bindData.showDeleteBtn = BOOL2CTL[not gCS.LuaUtils.IsPublish]
		self.bindData.showServerBtn = BOOL2CTL[gCS.LoginManager.canSelectServer]
		self.bindData.showQrCodeBtn = BOOL2CTL[not gCS.LuaUtils.IsOnEditor and not gCS.LuaUtils.IsStandalone and not gCS.LuaUtils.IsOnPS5]
		self.bindData.showAgeTipBtn = BOOL2CTL[true]
		self.bindData.showUserCenter = BOOL2CTL[gCS.LoginManager.loginBySDK]
		self.bindData.showTestAccountBtn = BOOL2CTL[not gCS.LoginManager.loginBySDK and not gCS.LoginManager.loginByOpenId]
		self.bindData.showTestAccountInput = BOOL2CTL[false]
		self.bindData.showBtnList = BOOL2CTL[true]

		self:RefreshDLCProgress()
	else
		self.bindData.showDeleteBtn = BOOL2CTL[false]
		self.bindData.showServerBtn = BOOL2CTL[false]
		self.bindData.showQrCodeBtn = BOOL2CTL[false]
		self.bindData.showAgeTipBtn = BOOL2CTL[false]
		self.bindData.showUserCenter = BOOL2CTL[false]
		self.bindData.showTestAccountBtn = BOOL2CTL[false]
		self.bindData.showTestAccountInput = BOOL2CTL[false]
		self.bindData.showBtnList = BOOL2CTL[false]
		self.bindData.showDLCTest = BOOL2CTL[false]
	end
end

M.SetFullUI = function(self, flag)
	if not self.STATE_EnableOnce then
		return
	end

	if flag then
		self.bindData.bindWidget:InvokeCallback(EInvokeTime.User1)
	end

	self.bindData.showControlRoot = BOOL2CTL[flag]
end

M.OnBtnRender = function(self, btn, index)
	local data = self.loginList[index + 1]
	local store = self.GetStoreByWidget(self, btn)

	if not store then
		return
	end

	store.btnText = data.buttonText
	store.modeType = self.bindData.modeType
	btn.interactable = data.interactable
	self.btnList[index + 1] = store
	btn.luaHover = self.CreateActionWithArgs(self, "OnBtnHover", data.id)
	btn.luaFocus = self.CreateActionWithArgs(self, "OnBtnHover", data.id)
end

M.OnBtnLayoutSet = function(self)
	self.bindData.btnList:SetNavSelectToTop(false)
end

M.OnBtnClick = function(self, btn, index)
	local data = self.loginList[index + 1]
	local btnTitle = data and data.id or BtnType.SingleMode

	if btnTitle ~= BtnType.SingleMode then
		if gDlcDownLoadMgr:IsAllMandatoryDownloaded() then
			gLinkManager:OnChangeLinkMode(UX.Game.LinkMode.None)
			self:TryLogin()
		else
			gDlcDownLoadMgr:EnterDownloadPanelByNetwork(0, true)
		end
	elseif btnTitle ~= BtnType.PublicMode then
		if gDlcDownLoadMgr:IsAllMandatoryDownloaded() then
			gMultiverseMgr:OpenGameView()
		else
			gDlcDownLoadMgr:EnterDownloadPanelByNetwork(0, true)
		end
	elseif btnTitle ~= BtnType.PrivateMode then
		if gDlcDownLoadMgr:IsAllMandatoryDownloaded() then
			gLinkManager:OnChangeLinkMode(UX.Game.LinkMode.Private)
			self:TryLogin()

			return
		end
	elseif btnTitle ~= BtnType.QuitGame then
		self.mgr:OnClick_PCQuit()
	end
end

M.TryLogin = function(self)
	self.mgr:OnLogin()
end

M.OnBtnHover = function(self, btnTitle)
	if self.bindData.modeType ~= btnTitle - 1 then
		return
	end

	self.SeekToTime(self, btnTitle)

	self.bindData.modeType = btnTitle - 1

	for i = 1, #self.btnList do
		self.btnList[i].modeType = btnTitle - 1
	end
end

M.SeekToTime = function(self, index)
	local videoPlayer = self.bindData["videoPlayer" .. self.preIndex]

	if videoPlayer then
		videoPlayer.Pause(videoPlayer)
	end

	videoPlayer = self.bindData["videoPlayer" .. index]

	if videoPlayer then
		videoPlayer.Resume(videoPlayer)
	end

	self.preIndex = index
end

M.OnChangeServer = function(self, _, serverData)
	self.bindData.serverNameText = serverData.Name
	self.bindData.status = serverData.Status
end

M.OnClick_TestAccount = function(self)
	if self.IsBtnInCd(self) then
		return
	end

	self.mgr:DoKickToLogin()

	self.bindData.showTestAccountInput = BOOL2CTL[true]

	self:SetFullUI(false)
end

M.OnClick_ConfirmTestAccount = function(self)
	if gCS.LuaUtils.IsPublish or not gCS.LoginManager.loginByCheat then
		return
	end

	local inputStr = self.bindData.testAccountInput.text

	self.mgr:SetEditorAccount(inputStr)
	self.mgr:DoLoginUniSDK()

	self.bindData.showTestAccountInput = BOOL2CTL[false]
end

M.OnClick_CancelTestAccount = function(self)
	self.mgr:DoLoginUniSDK()

	self.bindData.showTestAccountInput = BOOL2CTL[false]
end

M.OnClick_QrCode = function(self)
	if self.IsBtnInCd(self) then
		return
	end

	UniSDKManager.ScanQRCode()
end

M.RefreshDLCProgress = function(self)
	local isShow = gDlcDownLoadMgr:IsShowProgressBtn(true)
	self.bindData.showDLCTest = BOOL2CTL[isShow]

	if isShow then
		gDlcDownLoadMgr:RefreshDLCProgressStore(self.bindData.downloadBtn)
	end
end

M.OnClick_AgeTip = function(self)
	if self.IsBtnInCd(self) then
		return
	end

	gDisplayMessageMgr:ShowMessExplain(LTConfig.MessageExplainConfig.ShiLingTiXing)
end

M.OnClick_SDKUserCenter = function(self)
	if self.IsBtnInCd(self) then
		return
	end

	self:SetAgeTipPos()
	gCS.LoginManager:OpenUserCenter()
end

M.SetAgeTipPos = function(self)
	local camera = SGUI.UWidget.uiCamera

	if camera then
		local ageTipTrans = self.bindData.ageTipBtn.rectTransform
		local screenPos = camera:WorldToScreenPoint(ageTipTrans.position)
		local uiPos = gUtils:ScreenToUIPosition(screenPos)
		local rect = self.bindData.ageTipImage.rectTransform.rect

		gUIUtils:AdjustAgeTip(uiPos, rect.width, rect.height)
	else
		print_notice("LoginPanelStore SetAgeTipPos camera is nil")
	end
end

M.OnClick_Setting = function(self)
	gPanelManager:CheckShow(gPanelId.S_SETTINGS_PANEL, {
		["\\x96'0\\x94O\\xea?\\xa5\\xae"] = false
	})
end

M.OnClick_Repair = function(self)
	if self.IsBtnInCd(self) then
		return
	end

	local beforeClick2 = self:GetControlFlag(self.bindData.showControlRoot)

	local cancelCB = function()
		self:SetFullUI(beforeClick2)
	end

	self:SetFullUI(false)
	gUIUtils:ClickRepairClient(cancelCB)
end

M.InitNgPush = function(self)
	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		Timer.New(function ()
			LX6.SDK.PushService.InitPushService()
		end, 2):Start()
	end
end

M.GetControlFlag = function(self, val)
	if val ~= 0 then
		return true
	else
		return false
	end
end

M.IsBtnInCd = function(self)
	if self.blockAllInput then
		return true
	end

	local time = Time.time

	if time >= self.btnClickTime then
		return true
	end

	self.btnClickTime = time + 1

	return false
end

M.OnClickDebug = function(self)
	gPanelManager:CheckShow(gPanelId.S_TEST_MAIN_PANEL)
end

M.OnClick_Download = function(self)
	gPanelManager:CheckShow(gPanelId.DLC_DOWNLOAD_PANEL, {
		["w-y^"] = 0
	})
end

M.OnClick_AccountBind = function(self)
	self.mgr:ShowAccountBind()
end

M.OnPanelClose = function(self, _, msg)
	if msg.panelId ~= gPanelId.ANNOUNCEMENT_PANEL then
		self.SetFullUI(self, true)
	end
end

M.OnLanguageChange = function(self, lang)
	self.OnUpdateBtnList(self)
end
