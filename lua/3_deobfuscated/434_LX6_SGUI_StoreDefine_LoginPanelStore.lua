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
	SingleMode = 1,
	PublicMode = 3,
	PrivateMode = 2,
	QuitGame = 4
}

function M:OnAwake()
	self.mgr = gLoginManager
	self.panelId = gPanelId.USER_LOGIN
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
		[gEventConstants.PANEL_CLOSE] = self:CreateAction(self.OnPanelClose)
	}
	local length = gCS.LuaUtils.IsNonMobileAdaptive() and #LinkConfig.LoginPanelVideo or 1

	for i = 1, length do
		local videoPlayer = self.bindData["videoPlayer" .. i]
		local videoId = LinkConfig.LoginPanelVideo[i]

		videoPlayer:Init()
		videoPlayer:PlayVideo(videoId, true)
		videoPlayer:Pause()
	end

	self.preIndex = 1

	DRPFUtils.SendLoginUILog()

	self.bindData.backgroundBtn.luaClick = self:CreateAction("OnClick_Login")
	self.bindData.ageTipBtn.luaClick = self:CreateAction("OnClick_AgeTip")
	self.bindData.qrCodeBtn.luaClick = self:CreateAction("OnClick_QrCode")
	self.bindData.deleteRoleBtn.luaClick = self:CreateAction("OnClick_DeleteRole", self.mgr)
	self.bindData.serverBtn.luaClick = self:CreateAction("OpenSelectServerPanel", self.mgr)
	self.bindData.settingBtn.luaClick = self:CreateAction("OnClick_Setting")
	self.bindData.testAccountBtn.luaClick = self:CreateAction("OnClick_TestAccount")
	self.bindData.testAccountConfirmBtn.luaClick = self:CreateAction("OnClick_ConfirmTestAccount")
	self.bindData.testAccountCancelBtn.luaClick = self:CreateAction("OnClick_CancelTestAccount")
	self.bindData.btnList.luaSimpleRenderItem = self:CreateAction(self.OnBtnRender)
	self.bindData.btnList.luaSimpleClick = self:CreateAction(self.OnBtnClick)
	self.bindData.accountBtn.luaClick = self:CreateAction("OnClick_SDKUserCenter")
	self.bindData.foldBtn.luaClick = self:CreateActionWithArgs("OnChangeFoldMode", false)
	self.bindData.expandBtn.luaClick = self:CreateActionWithArgs("OnChangeFoldMode", true)
	self.bindData.clientFixBtn.luaClick = self:CreateAction("OnClick_Repair")
	self.bindData.announcementBtn.luaClick = self:CreateAction("OpenNoticePanel", gAnnouncementMgr)
	self.bindData.debugBtn.luaClick = self:CreateAction("OnClickDebug")
	self.bindData.downloadBtn.luaClick = self:CreateAction("OnClick_Download")
	self.bindData.accountBindBtn.luaClick = self:CreateAction("OnClick_AccountBind")
end

function M:OnReShow()
	self.blockAllInput = false
end

function M:OnUpdateBtnList()
	self.loginList = {
		{
			tIndex = 0,
			id = BtnType.SingleMode,
			buttonText = LTConfig.TextScriptTextConfig.GetConfig(89901111).Text
		}
	}

	if gLinkManager:CheckCanCreateLink(true) then
		table.insert(self.loginList, {
			tIndex = 0,
			id = BtnType.PublicMode,
			buttonText = LTConfig.TextScriptTextConfig.GetConfig(89901112).Text
		})
	end

	if gLinkManager:CheckCanEnterPrivateLink() then
		table.insert(self.loginList, {
			tIndex = 0,
			id = BtnType.PrivateMode,
			buttonText = LTConfig.TextScriptTextConfig.GetConfig(89901113).Text
		})
	end

	if gCS.LuaUtils.IsPCPlatformOrEditorAdaptive() then
		table.insert(self.loginList, {
			tIndex = 0,
			id = BtnType.QuitGame,
			buttonText = LTConfig.TextScriptTextConfig.GetConfig(89901069).Text
		})
	end

	self.bindData.btnList:SetSimpleList(#self.loginList)
end

function M:OnGroupEnable()
	self:OnUpdateBtnList()
	self:SetBaseParams(true)
	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnShow(panelId, data)
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
		self.mgr:Connect()
	end

	self.bindData.modeType = -1

	self:OnBtnHover(BtnType.SingleMode)
	LX6.Manager.GameQualitySettings.Instance:ApplySettings()

	gCS.LoginManager.isFirstLogin = false

	if not self.soundNid then
		self.soundNid = gSoundMgr:PlaySoundByTid(LTConfig.GameConfig.LoginInterface)
	end
end

function M:OnGroupDisable()
	self:ClearMessageEvents()
end

function M:OnClose()
	self.mgr:StopReconCo()
	gSoundMgr:StopSoundByNid(self.soundNid)

	self.soundNid = nil
end

function M:OnDestroy()
	self.mgr:StopReconCo()
end

function M:OnChangeFoldMode(flag)
	self.bindData.showBtnLayout = BOOL2CTL[flag]
end

function M:SetBaseParams(flag)
	if flag then
		self.bindData.showDeleteBtn = BOOL2CTL[not gCS.LuaUtils.IsPublish]
		self.bindData.showServerBtn = BOOL2CTL[gCS.LoginManager.canSelectServer]
		self.bindData.showQrCodeBtn = BOOL2CTL[not gCS.LuaUtils.IsOnEditor and not gCS.LuaUtils.IsStandalone and not gCS.LuaUtils.IsOnPS5]
		self.bindData.showAgeTipBtn = BOOL2CTL[true]
		self.bindData.showUserCenter = BOOL2CTL[gCS.LoginManager.loginBySDK]
		self.bindData.showTestAccountBtn = BOOL2CTL[not gCS.LoginManager.loginBySDK and not gCS.LoginManager.loginByOpenId]
		self.bindData.showTestAccountInput = BOOL2CTL[false]
		self.bindData.showBtnList = BOOL2CTL[true]
		self.bindData.showDLCTest = BOOL2CTL[gDlcDownLoadMgr.hasDLC]
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

function M:SetFullUI(flag)
	if not self.STATE_EnableOnce then
		return
	end

	if flag then
		self.bindData.bindWidget:InvokeCallback(EInvokeTime.User1)
	end

	self.bindData.showControlRoot = BOOL2CTL[flag]
end

function M:OnBtnRender(btn, index)
	local data = self.loginList[index + 1]
	local store = self:GetStoreByWidget(btn)

	if not store then
		return
	end

	store.btnText = data.buttonText
	store.modeType = self.bindData.modeType
	self.btnList[index + 1] = store
	btn.luaHover = self:CreateActionWithArgs("OnBtnHover", data.id)
	btn.luaFocus = self:CreateActionWithArgs("OnBtnHover", data.id)
end

function M:OnBtnClick(btn, index)
	local data = self.loginList[index + 1]
	local btnTitle = data and data.id or BtnType.SingleMode

	if btnTitle == BtnType.SingleMode then
		gLinkManager:OnChangeLinkMode(UX.Game.LinkMode.None)
		self.mgr:OnLogin()
	elseif btnTitle == BtnType.PublicMode then
		gLinkManager:OnChangeLinkMode(UX.Game.LinkMode.Public)
		self.mgr:OnLogin()
	elseif btnTitle == BtnType.PrivateMode then
		gLinkManager:OnChangeLinkMode(UX.Game.LinkMode.Private)
		self.mgr:OnLogin()
	elseif btnTitle == BtnType.QuitGame then
		self.mgr:OnClick_PCQuit()
	end
end

function M:OnBtnHover(btnTitle)
	if self.bindData.modeType == btnTitle - 1 then
		return
	end

	self:SeekToTime(btnTitle)

	self.bindData.modeType = btnTitle - 1

	for i = 1, #self.btnList do
		self.btnList[i].modeType = btnTitle - 1
	end
end

function M:SeekToTime(index)
	local videoPlayer = self.bindData["videoPlayer" .. self.preIndex]

	if videoPlayer then
		videoPlayer:Pause()
	end

	videoPlayer = self.bindData["videoPlayer" .. index]

	if videoPlayer then
		videoPlayer:Resume()
	end

	self.preIndex = index
end

function M:OnChangeServer(serverData)
	self.bindData.serverNameText = serverData.Name
	self.bindData.status = serverData.Status
end

function M:OnClick_TestAccount()
	if self:IsBtnInCd() then
		return
	end

	self.mgr:DoKickToLogin()

	self.bindData.showTestAccountInput = BOOL2CTL[true]

	self:SetFullUI(false)
end

function M:OnClick_ConfirmTestAccount()
	if gCS.LuaUtils.IsPublish or not gCS.LoginManager.loginByCheat then
		return
	end

	local inputStr = self.bindData.testAccountInput.text

	self.mgr:SetEditorAccount(inputStr)
	self.mgr:DoLoginUniSDK()

	self.bindData.showTestAccountInput = BOOL2CTL[false]
end

function M:OnClick_CancelTestAccount()
	self.mgr:DoLoginUniSDK()

	self.bindData.showTestAccountInput = BOOL2CTL[false]
end

function M:OnClick_QrCode()
	if self:IsBtnInCd() then
		return
	end

	UniSDKManager.ScanQRCode()
end

function M:OnClick_AgeTip()
	if self:IsBtnInCd() then
		return
	end

	gDisplayMessageMgr:ShowMessExplain(LTConfig.MessageExplainConfig.ShiLingTiXing)
end

function M:OnClick_SDKUserCenter()
	if self:IsBtnInCd() then
		return
	end

	self:SetAgeTipPos()
	gCS.LoginManager:OpenUserCenter()
end

function M:SetAgeTipPos()
	local camera = SGUI.UWidget.uiCamera

	if camera then
		local ageTipTrans = self.bindData.ageTipBtn.rectTransform
		local screenPos = camera:WorldToScreenPoint(ageTipTrans.position)
		local uiPos = gUtils:ScreenToUIPosition(screenPos)
		local rect = self.bindData.ageTipImage.rectTransform.rect

		gUIUtils:AdjustAgeTip(uiPos, rect.width, rect.height)
	else
		print_error("LoginPanelStore SetAgeTipPos camera is nil")
	end
end

function M:OnClick_Setting()
	gPanelManager:CheckShow(gPanelId.S_SETTINGS_PANEL, {
		isLoginShow = false
	})
end

function M:OnClick_Repair()
	if self:IsBtnInCd() then
		return
	end

	local beforeClick2 = self:GetControlFlag(self.bindData.showControlRoot)

	local function cancelCB()
		self:SetFullUI(beforeClick2)
	end

	self:SetFullUI(false)
	gUIUtils:ClickRepairClient(cancelCB)
end

function M:InitNgPush()
	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		Timer.New(function ()
			LX6.SDK.PushService.InitPushService()
		end, 2):Start()
	end
end

function M:GetControlFlag(val)
	if val == 0 then
		return true
	else
		return false
	end
end

function M:IsBtnInCd()
	if self.blockAllInput then
		return true
	end

	local time = Time.time

	if time < self.btnClickTime then
		return true
	end

	self.btnClickTime = time + 1

	return false
end

function M:OnClickDebug()
	gPanelManager:CheckShow(gPanelId.S_TEST_MAIN_PANEL)
end

function M:OnClick_Download()
	gPanelManager:CheckShow(gPanelId.DLC_DOWNLOAD_PANEL)
end

function M:OnClick_AccountBind()
	self.mgr:ShowAccountBind()
end

function M:OnPanelClose(_, msg)
	if msg.panelId == gPanelId.ANNOUNCEMENT_PANEL then
		self:SetFullUI(true)
	end
end
