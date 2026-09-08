-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ComputerMainPanelStore.lua
-- Decompiled from: 01518_ComputerMainPanelStore.lua_65bfa2466128.luajit

local ComputerConfig = LTConfig.ComputerConfig
local EMAIL_REDDOT_KEY_PREFIX = "ComputerEmailReddot_"
local EMAIL_REDDOT_MAX_COUNT = 99
local MAX_PANEL = {
	[LTConfig.ComputerAppConfig.hacker1] = true,
	[LTConfig.ComputerAppConfig.hacker2] = true,
	[LTConfig.ComputerAppConfig.hacker3] = true,
	[LTConfig.ComputerAppConfig.hacker4] = true
}
C_ComputerMainPanelStore = DefClass("C_ComputerMainPanelStore", C_ComputerMainPanelStore, C_StoreGroup)
GroupName2Class.ComputerMainPanelStore = C_ComputerMainPanelStore
local M = C_ComputerMainPanelStore

M.OnAwake = function(self)
	self.bindData.enterButton.luaClick = self:CreateAction("OnEnterClick")
	self.bindData.bottomList.luaSimpleRenderItem = self:CreateAction("OnBottomAppRenderItem")
	self.bindData.tabRect.OnRenderTab = self:CreateAction("OnRenderTab")
	self.bindData.previewTabRect.OnRenderTab = self:CreateAction("OnPreviewRenderTab")
	self.bindData.emailList.luaSimpleRenderItem = self:CreateAction("OnMailListRenderItem")
	self.bindData.exitButton.luaClick = self:CreateAction("OnExitClick")
	self.bindData.inputField.luaValueChanged = self:CreateAction("OnInputFieldValueChange")
	self.bindData.inputField.onActivateAction = self:CreateAction("OnInputFieldActivate")
	self.bindData.inputField.onDeActivateAction = self:CreateAction("OnInputFieldDeActivate")
	self.bindData.welcomeButton.luaClick = self:CreateAction("OnWelcomeButtonClick")
	self.bindData.desktopList.onGetTIndex = self:CreateAction("OnDesktopListGetTIndex")
	self.bindData.desktopList.luaSimpleRenderItem = self:CreateAction("OnDesktopListRenderItem")
	self.bindData.leftControllerButton.luaClick = self:CreateActionWithArgs("OnStep", -1)
	self.bindData.rightControllerButton.luaClick = self:CreateActionWithArgs("OnStep", 1)

	self:InitMessages()

	self.redDotAction = self:CreateAction("OnRenderRedDot")
	SGUI.RedDotMgr.onRenderRedDot = SGUI.RedDotMgr.onRenderRedDot and SGUI.RedDotMgr.onRenderRedDot + self.redDotAction or self.redDotAction
end

M.InitMessages = function(self)
	self.RegisterMessageEvents(self, {
		[gEventConstants.ON_COMPUTER_APP_CLOSE] = self.CreateAction(self, "OnComputerAppClose"),
		[gEventConstants.ON_COMPUTER_PREVIEW_SHOW] = self.CreateAction(self, "OnComputerPreviewShow"),
		[gEventConstants.ON_COMPUTER_PREVIEW_CLOSE] = self.CreateAction(self, "OnComputerPreviewClose"),
		[gEventConstants.ON_ENTER_COMPUTER_INTERACT] = self.CreateAction(self, "OnEnterComputerInteract"),
		[gEventConstants.COMPUTER_ALLOW_EXIT] = function (_, enable)
			gMessageManager:SendMessage(gEventConstants.ON_COMPUTER_PANEL_EXIT_BUTTON_STATE_CHANGE, enable)
		end,
		[gEventConstants.ON_COMPUTER_PANEL_EXIT_BUTTON_STATE_CHANGE] = function (_, isActive)
			self.bindData.exitButton:SetActive(isActive)
		end,
		[gEventConstants.ON_COMPUTER_EMAIL_READ] = self.CreateAction(self, "OnComputerEmailRead")
	})
end

M.OnShow = function(self, _, args)
	self.bindData.controllerBtnShowCtrl = 0

	if type(args) ~= "userdata" then
		args = args.ToTable(args)
		local computerId = args[1]
		local uiPivot = args[2]
		local entityId = args[3]
		args = {
			computerId = computerId,
			uiPivot = uiPivot,
			entityId = entityId
		}
	end

	self.InitModel(self, args)
	self.InitView(self, args)
	self.TryOpenTaskNoticePanel(self)
end

M.InitModel = function(self, args)
	self.ignoreBottomNavigation = nil
	self.computerId = args.computerId
	self.gamePadMode = SGUI.GameDevice.KeyboardMouse <= gCS.LuaUtils.GetActiveDevice()
	self.entityId = args.entityId
	self.Computer_Default_Panel_Type = {
		["h\\xa3\\xa3\\xa6\\xba"] = 2,
		["\\xf1\\xda6\\xa3"] = 6,
		["\\+q^"] = 3,
		["\\xf1\\xda6\\xa0"] = 5,
		["\\xf1\\xda6\\xa5"] = 8,
		["~\\xba\\xa3\\xbd\\xa2"] = 0,
		["\\xf1\\xda6\\xa2"] = 7,
		["\\xfd\\xde\n+\\xe1"] = 1,
		["\\xee\\xde\r#\\xf4"] = 4
	}
	self.Computer_Status_Control = {
		["\\xfd\\xde\n+\\xe1"] = 2,
		["tF`e~*"] = 3,
		["~\\xba\\xa3\\xbd\\xa2"] = 0,
		["1\\xf7^>\\xe0\\xa5R\\xb6Y\\xa2\\xb2"] = 1
	}
	self.App_Template_Type = {
		["/X\\x90\\x8d\\x86S"] = 1,
		["\\xafxv"] = 0
	}
	self.Password_Control = {
		["jIof\\,"] = 1,
		["2G\\x83\\x83\\x82M"] = 0
	}
	self.Preview_Max = {
		["=K\\x85\\x87\\x95D"] = 1,
		["2G\\x83\\x83\\x82M"] = 0
	}
	self.Preview_TabRect_Type = {
		["\\xee\\xde-#\\xf4"] = 1,
		["2G\\x83\\x83\\x82M"] = 0
	}
end

M.InitView = function(self, args)
	local uiPivot = args.uiPivot
	self.rootGo.transform.position = uiPivot.position
	self.rootGo.transform.rotation = uiPivot.rotation
	self.rootGo.transform.localScale = uiPivot.localScale

	if not args.computerId or not LTConfig.ComputerConfig.GetConfig(args.computerId) then
		self.waitCloseCo = coroutine.start(function ()
			coroutine.wait(1)
			gPanelManager:Close(self.m_Id)
		end)

		print_error("@linminghe computerId is nil", inspect(args))

		return
	end

	print_debug("computerId", args.computerId)

	local rootGo = self.rootGo
	self.intiViewCo = coroutine.start(function ()
		coroutine.step()

		if gClientUtils.NotNil(rootGo) then
			self:RefreshPanelView(args)
		end
	end)
end

M.RefreshPanelView = function(self, _)
	local showComputerMax = false
	local computerCfg = LTConfig.ComputerConfig.GetConfig(self.computerId)

	if computerCfg.UIRound <= 0 then
		local uiRound = computerCfg.UIRound

		if self.bindData.roundMask then
			self.bindData.roundMask.cornerRadius = Vector4.New(uiRound, uiRound, uiRound, uiRound)
		end
	end

	if computerCfg.DefaultPanel ~= self.Computer_Default_Panel_Type.Start then
		self.RefreshStartView(self)

		if not self.CheckComputerHasOpened(self) then
			if self.IsNeedBlackscreenAnimationComputer(self) then
				self.PlayOpeningEffect(self)
			else
				self.PlayFirstOpenEffect(self)
			end
		end
	else
		if computerCfg.DefaultPanel ~= self.Computer_Default_Panel_Type.Email then
			self.SelectedTabRect(self, 0, 0.1)
		elseif computerCfg.DefaultPanel ~= self.Computer_Default_Panel_Type.File then
			self.SelectedTabRect(self, 1, 0.1)
		elseif computerCfg.DefaultPanel ~= self.Computer_Default_Panel_Type.Hacker1 then
			showComputerMax = true

			self.SelectedTabRect(self, gClientConst.ComputerAppId2TabIndex[gClientConst.ComputerAppIdMap.Hacker1], 1.5)
		elseif computerCfg.DefaultPanel ~= self.Computer_Default_Panel_Type.Hacker2 then
			showComputerMax = true

			self.SelectedTabRect(self, gClientConst.ComputerAppId2TabIndex[gClientConst.ComputerAppIdMap.Hacker2], 1.5)
		elseif computerCfg.DefaultPanel ~= self.Computer_Default_Panel_Type.Hacker3 then
			showComputerMax = true

			self.SelectedTabRect(self, gClientConst.ComputerAppId2TabIndex[gClientConst.ComputerAppIdMap.Hacker3], 1.5)
		elseif computerCfg.DefaultPanel ~= self.Computer_Default_Panel_Type.Hacker4 then
			showComputerMax = true

			self.SelectedTabRect(self, gClientConst.ComputerAppId2TabIndex[gClientConst.ComputerAppIdMap.Hacker4], 1.5)
		end

		if showComputerMax then
			self.bindData.isMax = 1
		else
			self.bindData.isMax = 0
		end
	end

	self.bindData.startImageId = computerCfg.StartImage
	self.bindData.desktopImageId = computerCfg.DesktopImage

	self.OpenComputerHudPanel(self)
end

M.SelectedTabRect = function(self, index, delay)
	if delay then
		local computerCfg = LTConfig.ComputerConfig.GetConfig(self.computerId)

		if computerCfg.WallpaperOnly then
			self.bindData.statusControl = self.Computer_Status_Control.WallPaper
			self.bindData.wallpaperOnly = 1
		end

		self.delayShowDesktopCo = coroutine.start(function ()
			coroutine.wait(delay)
			self:RefreshDesktopView()

			self.bindData.tabRect.selectedIndex = index
		end)
	else
		self.RefreshDesktopView(self)

		self.bindData.tabRect.selectedIndex = index
	end
end

M.PlayFirstOpenEffect = function(self)
	local computerCfg = ComputerConfig.GetConfig(self.computerId)

	if computerCfg.IsPlayAnimation then
		self.bindData.syncControl = 1
		self.playOpenEffectCo = coroutine.start(function ()
			coroutine.wait(3)

			self.bindData.syncControl = 0
		end)

		self.AskComputerOpened(self)
	end
end

M.PlayOpeningEffect = function(self)
	self.bindData.openingCtrl = 1

	self.bindData.openingAnimation:Play("S_Vx_ComputerMainPanel_CW_Opening")

	self.playOpeningEffectCo = coroutine.start(function ()
		coroutine.wait(3.166667)
		self.bindData.openingAnimation:Stop("S_Vx_ComputerMainPanel_CW_Opening")

		self.bindData.openingCtrl = 0
	end)

	self:AskComputerOpened()
end

M.CheckComputerHasOpened = function(self)
	local computerInfos = self:GetComputerInfos()

	return computerInfos[self.computerId] == nil
end

M.GetComputerInfos = function(self)
	local computerUnlockInfo = gPlayerManager.infoMinor.bindData.computerUnlockInfo

	return computerUnlockInfo.ComputerInfos
end

M.IsNeedBlackscreenAnimationComputer = function(self)
	local blackscreenAnimationComputerId = ComputerConfig.BlackscreenAnimationComputerId

	return array.contains(blackscreenAnimationComputerId, self.computerId)
end

M.IsNeedWelcomeComputer = function(self)
	local welcomeComputerId = ComputerConfig.WelcomeAnimationComputerId

	return array.contains(welcomeComputerId, self.computerId)
end

M.AskComputerOpened = function(self)
	slot1 = gClientToGameDelegate

	slot1:AskComputerOpened(self.computerId).Callback = function (errorId)
		if errorId == LTConfig.MessageConfig.Ok then
			return
		end

		local computerInfos = self:GetComputerInfos()
		local computerInfo = computerInfos[self.computerId]

		if not computerInfo then
			computerInfos[self.computerId] = {
				CfgId = self.computerId,
				FirstOpenTime = gLuaDataManager.serverTime,
				DeleteFiles = {},
				DeleteEmails = {}
			}
		end
	end
end

M.OnWelcomeButtonClick = function(self)
	self.bindData.welcomeControl = 0
	self.bindData.emailControl = 1
	local emailId = LTConfig.ComputerConfig.ACDOfferEmail
	self.emailIdList = {
		emailId
	}

	self.bindData.emailList:SetSimpleList(#self.emailIdList)
end

M.OnEmailCloseClick = function(self)
	self.bindData.emailControl = 0

	self.EnterDesktop(self)
end

M.OpenComputerHudPanel = function(self)
	gPanelManager:CheckShow(gPanelId.COMPUTER_HUD_PANEL, {
		navigationArea = self.bindData.uNavigationArea,
		exitCallback = function ()
			self:OnExitClick()
		end
	})
end

M.CloseComputerHudPanel = function(self)
	if gPanelManager:IsPanelShowing(gPanelId.COMPUTER_HUD_PANEL) then
		gPanelManager:Close(gPanelId.COMPUTER_HUD_PANEL)
	end
end

M.RefreshStartView = function(self)
	local computerCfg = LTConfig.ComputerConfig.GetConfig(self.computerId)
	self.bindData.statusControl = string.is_null_or_empty(computerCfg.Password) and self.Computer_Status_Control.Start or self.Computer_Status_Control.StartPassword
	self.bindData.userName = computerCfg.UserName

	if computerCfg.UserName ~= "<player>" then
		local headIcon, _ = gHunLunManager:GetHeadIconAndName(gPlayerManager.infoLogin.bindData.infoPzHeadInfo.SystemHeadId)
		self.bindData.headIconId = headIcon
	else
		self.bindData.headIconId = computerCfg.UserHeadId
	end

	self.bindData.startImageId = computerCfg.StartImage
end

M.OnInputFieldValueChange = function(self)
	local inputContent = self.bindData.inputField.text
	self.bindData.inputField.text = LX6.Extension.StringEx.ReplacePattern(inputContent, "[^a-zA-Z0-9]", "")
end

M.OnInputFieldActivate = function(self)
	self.inputDeactivateCo = coroutine.stop(self.inputDeactivateCo)
	self.inputActive = true
end

M.OnInputFieldDeActivate = function(self)
	self.inputDeactivateCo = coroutine.stop(self.inputDeactivateCo)
	self.inputDeactivateCo = coroutine.start(function ()
		coroutine.step()

		self.inputActive = false
	end)
end

M.OnExitClick = function(self)
	if self.inputActive then
		self.bindData.inputField:DeactivateInputField()
	end

	self.CloseTaskNoticePanel(self)
	self.CloseComputerHudPanel(self)

	local computerCfg = LTConfig.ComputerConfig.GetConfig(self.computerId)

	if computerCfg.DontCloseOnExit then
		self.isInBackground = true

		gSpoonClientMgr:TryCallInnerSignal(self.entityId, L50.Spoon.SpoonRunTime.ClientGraphType.GADGET, "ComputerMainPanelClose")
		gPanelManager:SetActiveById(self.m_Id, false)
		self.rootGo.transform:ChangeLayersRecursively(Layer.Default)
	else
		gPanelManager:Close(self.m_Id)
	end
end

M.OnActiveDeviceChange = function(self, device)
	self.gamePadMode = SGUI.GameDevice.KeyboardMouse <= device
end

M.OnEnterComputerInteract = function(self)
	gPanelManager:SetActiveById(self.m_Id, true)

	self.isInBackground = nil
	self.bindData.uNavigationArea.enabled = true

	self.rootGo.transform:ChangeLayersRecursively(Layer.WorldUI_HitMaterial)
	self:OpenComputerHudPanel()
	self:TryOpenTaskNoticePanel()
end

M.OnEnterClick = function(self)
	if not self.CheckComputerHasOpened(self) and self.IsNeedWelcomeComputer(self) then
		self.ShowWelcome(self)

		return
	end

	self.EnterDesktop(self)
end

M.ShowWelcome = function(self)
	self.bindData.welcomeContent = ComputerConfig.WelcomeAnimationComputerContext
	self.bindData.welcomeControl = 1

	self.AskComputerOpened(self)
end

M.EnterDesktop = function(self)
	local computerCfg = LTConfig.ComputerConfig.GetConfig(self.computerId)
	local password = computerCfg.Password or ""

	if gClientUtils.CheckIsGamePadMode() and not string.is_null_or_empty(password) and not self.inputActive then
		self.bindData.inputField:ActivateInputField()

		return
	end

	local signalKey = nil

	if password == self.bindData.inputField.text then
		self:ShowPasswordErrorTips()

		signalKey = "ComputerPasswordError"

		gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnReceiveSignal, {
			signalKey = signalKey
		})

		return
	end

	signalKey = "ComputerPasswordCorrect"

	gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnReceiveSignal, {
		signalKey = signalKey
	})

	self.passwordErrorTipsCo = coroutine.stop(self.passwordErrorTipsCo)
	self.bindData.passwordControl = self.Password_Control.Normal
	self.waitCo = coroutine.stop(self.waitCo)
	self.waitCo = coroutine.start(function ()
		coroutine.step()
		self:RefreshDesktopView()
		self:TryOpenTaskNoticePanel()
	end)

	self:RefreshDesktopFileList()
end

M.TryOpenTaskNoticePanel = function(self)
	local taskId = gTaskNodeManager:GetNowDoingTask()

	if not taskId then
		return
	end

	local ids = LTConfig.ComputerConfig.TaskNoticeTaskIds

	if not ids then
		return
	end

	for _, id in ipairs(ids) do
		if id ~= taskId then
			gPanelManager:CheckShow(gPanelId.S_NORMAL_TASK_NOTICE)

			return
		end
	end
end

M.CloseTaskNoticePanel = function(self)
	if gPanelManager:IsPanelShowing(gPanelId.S_NORMAL_TASK_NOTICE) then
		gPanelManager:Destroy(gPanelId.S_NORMAL_TASK_NOTICE)
	end
end

M.ShowPasswordErrorTips = function(self)
	self.passwordErrorTipsCo = coroutine.stop(self.passwordErrorTipsCo)
	self.bindData.passwordControl = self.Password_Control.Incorrect
	self.passwordErrorTipsCo = coroutine.start(function ()
		coroutine.wait(2)

		self.bindData.passwordControl = self.Password_Control.Normal
	end)
end

M.OnBottomAppRenderItem = function(self, btn, csIndex)
	local navigation = btn.navigation

	if self.ignoreBottomNavigation then
		navigation.mode = 0
	else
		navigation.mode = 3
	end

	btn.navigation = navigation
	btn.gameObject.name = ("AppItem:%d"):format(csIndex)
	local luaIndex = csIndex + 1
	local data = self.bottomViewDataList[luaIndex]

	if data.tIndex ~= self.App_Template_Type.App then
		local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

		store.button.luaClick = function()
			self:OnBottomAppClick(data.appId)
		end

		store.button.isSelected = data.appId ~= self.currentAppId
		local appCfg = LTConfig.ComputerAppConfig.GetConfig(data.appId)
		store.iconId = appCfg.SIconId
		store.guideId = appCfg.GuideId

		if data.appId ~= LTConfig.ComputerAppConfig.Email and self.computerId then
			local computerCfg = LTConfig.ComputerConfig.GetConfig(self.computerId)

			if computerCfg and computerCfg.IsShowEmailReddot then
				if store.button.templateKey == "Number" then
					store.button.templateKey = "Number"
				end

				local desiredRedKey = self.GetEmailReddotParentKey(self)

				if store.button.redKey == desiredRedKey then
					store.button.redKey = desiredRedKey
				end
			end
		end
	end
end

M.OnRenderTab = function(self, _, widget)
	local store = gStoreManager:GetStoreGroup(widget.Store)
	store.m_Id = self.m_Id

	if self.desktopWebpageIndex then
		store.ShowPanel(store, self.computerId, self.entityId, self.desktopWebpageIndex)

		self.desktopWebpageIndex = nil
	elseif self.desktopFolderId then
		store.ShowPanel(store, self.computerId, self.desktopFolderId)

		self.desktopFolderId = nil
	else
		store.ShowPanel(store, self.computerId, self.entityId)
	end

	self.bindData.controllerBtnShowCtrl = #self.bottomViewDataList <= 1 and 1 or 0
end

M.OnPreviewRenderTab = function(self, _, widget)
	local store = gStoreManager:GetStoreGroup(widget.Store)
	store.m_Id = self.m_Id

	store:ShowPanel(self.computerPreviewFileId)
end

M.OnMailListRenderItem = function(self, btn, csIndex)
	local emailId = self.emailIdList[csIndex + 1]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local emailCfg = LTConfig.ComputerEmailConfig.GetConfig(emailId)
	store.logoId = emailCfg.TemplateLogo
	store.title = emailCfg.TemplateTitle
	store.contentTitle = emailCfg.ContentTitle
	store.content = emailCfg.EmailTextCode
	store.sign = emailCfg.TemplateSign
	store.closeBtnControl = 1
	store.closeButton.luaClick = self:CreateAction("OnEmailCloseClick")
	self.bindData.emailListCloseButton.luaClick = self:CreateAction("OnEmailCloseClick")

	self.bindData.emailListCloseButton.transform:SetAsLastSibling()
end

M.OnDesktopListGetTIndex = function(self)
	return gCS.LuaUtils.IsNonMobileAdaptive() and 0 or 1
end

M.RefreshDesktopFileList = function(self)
	local computerCfg = LTConfig.ComputerConfig.GetConfig(self.computerId)
	self.desktopFileList = {}

	for _, fileId in ipairs(computerCfg.DesktopFile) do
		local computerFileCfg = LTConfig.ComputerFileConfig.GetConfig(fileId)

		if computerFileCfg then
			if gComputerUtils:CheckFileCanShow(self.computerId, fileId) then
				table.insert(self.desktopFileList, fileId)
			end
		else
			local webPageCfg = LTConfig.WebpageConfig.GetConfig(fileId)

			if webPageCfg then
				table.insert(self.desktopFileList, fileId)
			end
		end
	end

	self.bindData.desktopList:SetSimpleList(#self.desktopFileList)
end

M.OnDesktopListRenderItem = function(self, btn, csIndex)
	local fileId = self.desktopFileList[csIndex + 1]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local computerFileCfg = LTConfig.ComputerFileConfig.GetConfig(fileId)
	local computerCfg = LTConfig.ComputerConfig.GetConfig(self.computerId)

	if computerFileCfg then
		store.iconId = gComputerUtils:GetFileIconId(computerFileCfg.FileType)
		store.name = computerFileCfg.FileTitle
		store.nameColor = Color.New(computerCfg.DesktopFileColor[1], computerCfg.DesktopFileColor[2], computerCfg.DesktopFileColor[3], computerCfg.DesktopFileColor[4])
		store.button.luaClick = self:CreateActionWithArgs("OnDesktopFileClick", {
			fileId = fileId,
			fileType = computerFileCfg.FileType
		})
	else
		local webPageCfg = LTConfig.WebpageConfig.GetConfig(fileId)

		if webPageCfg then
			store.iconId = webPageCfg.Logo
			store.name = webPageCfg.Name
			store.nameColor = Color.New(computerCfg.DesktopFileColor[1], computerCfg.DesktopFileColor[2], computerCfg.DesktopFileColor[3], computerCfg.DesktopFileColor[4])
			store.button.luaClick = self.CreateActionWithArgs(self, "OnDesktopWebpageClick", fileId)
		end
	end
end

M.OnDesktopFileClick = function(self, args)
	local fileId = args.fileId
	local fileType = args.fileType

	if fileType == gClientConst.Computer_File_Type.Folder then
		gMessageManager:SendMessage(gEventConstants.ON_COMPUTER_PREVIEW_SHOW, fileId)
	else
		self.desktopFolderId = fileId

		self.OnBottomAppClick(self, LTConfig.ComputerAppConfig.File)
	end
end

M.OnDesktopWebpageClick = function(self, WebpageIndex)
	self.desktopWebpageIndex = WebpageIndex

	self.OnBottomAppClick(self, LTConfig.ComputerAppConfig.WebPage)
end

M.OnBottomAppClick = function(self, appId)
	self.currentAppId = appId

	if appId ~= LTConfig.ComputerAppConfig.Email then
		self.bindData.tabRect.selectedIndex = gClientConst.ComputerAppId2TabIndex[gClientConst.ComputerAppIdMap.Email]

		self.CloseEmailNotification(self)
	elseif appId ~= LTConfig.ComputerAppConfig.File then
		self.bindData.tabRect.selectedIndex = gClientConst.ComputerAppId2TabIndex[gClientConst.ComputerAppIdMap.File]
	elseif appId ~= LTConfig.ComputerAppConfig.hacker1 then
		self.bindData.tabRect.selectedIndex = gClientConst.ComputerAppId2TabIndex[gClientConst.ComputerAppIdMap.Hacker1]
	elseif appId ~= LTConfig.ComputerAppConfig.hacker2 then
		self.bindData.tabRect.selectedIndex = gClientConst.ComputerAppId2TabIndex[gClientConst.ComputerAppIdMap.Hacker2]
	elseif appId ~= LTConfig.ComputerAppConfig.hacker3 then
		self.bindData.tabRect.selectedIndex = gClientConst.ComputerAppId2TabIndex[gClientConst.ComputerAppIdMap.Hacker3]
	elseif appId ~= LTConfig.ComputerAppConfig.hacker4 then
		self.bindData.tabRect.selectedIndex = gClientConst.ComputerAppId2TabIndex[gClientConst.ComputerAppIdMap.Hacker4]
	elseif appId ~= LTConfig.ComputerAppConfig.WebPage then
		self.bindData.tabRect.selectedIndex = gClientConst.ComputerAppId2TabIndex[gClientConst.ComputerAppIdMap.Webpage]
	end

	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.isMax = 1
	elseif MAX_PANEL[appId] then
		self.bindData.isMax = 1
	else
		self.bindData.isMax = 0
	end

	if self.bindData.tabRect.selectedIndex > 0 then
		self.ignoreBottomNavigation = true
	end

	self.bindData.bottomList:RefreshList()
end

M.RefreshDesktopView = function(self)
	self.bindData.controllerBtnShowCtrl = 0
	self.bindData.statusControl = self.Computer_Status_Control.Desktop

	self.StartCountDownCo(self)
	self.RefreshBottomAppListView(self)
end

M.RefreshBottomAppListView = function(self)
	local viewDataList = {}
	local computerCfg = LTConfig.ComputerConfig.GetConfig(self.computerId)
	local appList = computerCfg.AppList or {}

	for _, appId in ipairs(appList) do
		table.insert(viewDataList, {
			tIndex = self.App_Template_Type.App,
			appId = appId
		})
	end

	table.sort(viewDataList, function (data1, data2)
		local appCfg1 = LTConfig.ComputerAppConfig.GetConfig(data1.appId)
		local appCfg2 = LTConfig.ComputerAppConfig.GetConfig(data2.appId)

		if appCfg1.Rank == appCfg2.Rank then
			return appCfg1.Rank <= appCfg2.Rank
		end

		return data1.appId <= data2.appId
	end)

	self.bottomViewDataList = {}

	for index, viewData in ipairs(viewDataList) do
		table.insert(self.bottomViewDataList, viewData)
	end

	self.bindData.bottomList.onGetTIndex = function(csIndex)
		local luaIndex = csIndex + 1

		return self.bottomViewDataList[luaIndex].tIndex
	end

	self.bindData.bottomList:SetSimpleList(#self.bottomViewDataList)

	self.bindData.bottomBar.transform.localScale = #viewDataList <= 0 and Vector3.one or Vector3.zero

	self:RefreshEmailReddot()
	self:RefreshEmailNotification()
end

M.GetEmailReddotParentKey = function(self)
	return EMAIL_REDDOT_KEY_PREFIX .. self.computerId
end

M.GetEmailReddotChildKey = function(self, emailId)
	return self.GetEmailReddotParentKey(self) .. "/" .. emailId
end

M.RefreshEmailReddot = function(self)
	if not self.computerId then
		return
	end

	local parentKey = self.GetEmailReddotParentKey(self)

	SGUI.RedDotMgr.ClearRedDotByKey(parentKey)

	local computerCfg = LTConfig.ComputerConfig.GetConfig(self.computerId)

	if not computerCfg or not computerCfg.IsShowEmailReddot then
		return
	end

	local emailList = computerCfg.EmailList

	if table.isNilOrEmpty(emailList) then
		return
	end

	for _, emailId in ipairs(emailList) do
		if gComputerUtils:CheckEmailCanShow(self.computerId, emailId) and not gComputerUtils:CheckEmailHasRead(emailId) then
			local emailCfg = LTConfig.ComputerEmailConfig.GetConfig(emailId)

			if emailCfg and emailCfg.EmailType ~= LTConfig.ComputerEmailConfig.EmailTypeType.Recipient then
				SGUI.RedDotMgr.LuaSetRedDot(true, self.GetEmailReddotChildKey(self, emailId))
			end
		end
	end
end

M.OnComputerEmailRead = function(self, _, emailId)
	if not self.computerId or not emailId then
		return
	end

	local computerCfg = LTConfig.ComputerConfig.GetConfig(self.computerId)

	if not computerCfg or not computerCfg.IsShowEmailReddot then
		return
	end

	SGUI.RedDotMgr.LuaSetRedDot(false, self.GetEmailReddotChildKey(self, emailId))
end

M.OnRenderRedDot = function(self, redKey, templateKey, widget)
	if templateKey == "Number" then
		return
	end

	if not self.computerId or redKey == self.GetEmailReddotParentKey(self) then
		return
	end

	local store = gStoreManager:GetStoreGroup("RedDotNumber"):GetStoreByWidget(widget)

	if not store then
		return
	end

	local _, count = SGUI.RedDotMgr.GetRedDotIsShown(redKey, 0)

	if count and EMAIL_REDDOT_MAX_COUNT >= count then
		store.num = "99+"
	else
		store.num = tostring(count or 0)
	end
end

local NOTIFICATION_HIDE = 0
local NOTIFICATION_SHOW = 1

M.GetUnreadEmailCount = function(self)
	if not self.computerId then
		return 0
	end

	local _, count = SGUI.RedDotMgr.GetRedDotIsShown(self:GetEmailReddotParentKey(), 0)

	return count or 0
end

M.CloseEmailNotification = function(self)
	self.bindData.showNotification = NOTIFICATION_HIDE
end

M.OnNotificationClick = function(self)
	self.CloseEmailNotification(self)
	self.OnBottomAppClick(self, LTConfig.ComputerAppConfig.Email)
end

M.RefreshEmailNotification = function(self)
	if not self.computerId then
		return
	end

	local computerCfg = LTConfig.ComputerConfig.GetConfig(self.computerId)

	if not computerCfg or not computerCfg.IsShowPopup then
		self.CloseEmailNotification(self)

		return
	end

	local count = self.GetUnreadEmailCount(self)

	if count < 0 then
		self.CloseEmailNotification(self)

		return
	end

	local countText = EMAIL_REDDOT_MAX_COUNT >= count and "99+" or tostring(count)
	self.bindData.notificationText.text = gString.Format(LTConfig.ComputerConfig.MailNoticeText, countText)
	self.bindData.notificationClickBtn.luaClick = self:CreateAction("OnNotificationClick")
	self.bindData.showNotification = NOTIFICATION_SHOW
end

M.StartCountDownCo = function(self)
	self.countDownCo = coroutine.stop(self.countDownCo)
	self.countDownCo = coroutine.start(function ()
		self:RefreshTimeView()

		while true do
			coroutine.wait(1)
			self:RefreshTimeView()
		end
	end)
end

M.RefreshTimeView = function(self)
	local gameTime = LX6.Manager.AtmosphereManager.Instance:GetGameTime()
	local min = math.floor(gameTime / 60 % 60)
	local hour = math.floor(gameTime / gClientConst.SECONDS_PER_HOUR)
	local time = ("%02d:%02d"):format(hour, min)
	self.bindData.time = time
end

M.OnComputerAppClose = function(self, _, params)
	self.currentAppId = nil
	self.ignoreBottomNavigation = nil

	self.bindData.bottomList:RefreshList()

	if self:CheckIsHackerApp() then
		gMessageManager:SendMessage(gEventConstants.ON_COMPUTER_PANEL_EXIT_BUTTON_STATE_CHANGE, true)
		gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnReceiveSignal, {
			signalKey = ("OnHackerAppClose:%d"):format(self.computerId)
		})
	end

	params = params or {}
	local closeSelf = params.closeSelf
	local closeWithAppOpen = params.closeWithAppOpen

	self.bindData.tabRect:SelectIndexWithClose(-1)

	self.bindData.controllerBtnShowCtrl = 0
	self.bindData.isMax = 0

	if closeSelf then
		self.OnExitClick(self)
	end

	if closeWithAppOpen and closeWithAppOpen == ComputerConfig.HackOpenAppType.none then
		if closeWithAppOpen ~= ComputerConfig.HackOpenAppType.email then
			self.OnBottomAppClick(self, gClientConst.ComputerAppIdMap.Email)
		elseif closeWithAppOpen ~= ComputerConfig.HackOpenAppType.file then
			self.OnBottomAppClick(self, gClientConst.ComputerAppIdMap.File)
		elseif closeWithAppOpen ~= ComputerConfig.HackOpenAppType.webpage then
			self.OnBottomAppClick(self, gClientConst.ComputerAppIdMap.Webpage)
		elseif closeWithAppOpen ~= ComputerConfig.HackOpenAppType.desktop then
			-- Nothing
		else
			local computerCfg = LTConfig.ComputerConfig.GetConfig(self.computerId)

			if computerCfg.WallpaperOnly then
				self.bindData.statusControl = self.Computer_Status_Control.WallPaper
			end
		end
	end

	if not closeSelf and (not closeWithAppOpen or closeWithAppOpen ~= ComputerConfig.HackOpenAppType.none or closeWithAppOpen ~= ComputerConfig.HackOpenAppType.desktop) then
		self.bindData.bottomList:SetNavSelectToTop()
	end
end

M.CheckIsHackerApp = function(self)
	local hackerAppTabRectIndexList = {
		gClientConst.ComputerAppId2TabIndex[gClientConst.ComputerAppIdMap.Hacker1],
		gClientConst.ComputerAppId2TabIndex[gClientConst.ComputerAppIdMap.Hacker2],
		gClientConst.ComputerAppId2TabIndex[gClientConst.ComputerAppIdMap.Hacker3],
		gClientConst.ComputerAppId2TabIndex[gClientConst.ComputerAppIdMap.Hacker4]
	}

	for _, tabRectIndex in ipairs(hackerAppTabRectIndexList) do
		return self.bindData.tabRect.selectedIndex ~= tabRectIndex
	end
end

M.OnComputerPreviewShow = function(self, _, computerFileId)
	if not self.CheckFileHaveContent(self, computerFileId) then
		gComputerUtils:AskComputerFileRead(computerFileId, true)

		return
	end

	self.computerPreviewFileId = computerFileId
	local computerFileCfg = LTConfig.ComputerFileConfig.GetConfig(computerFileId)

	if computerFileCfg.FileType ~= gClientConst.Computer_File_Type.PDF then
		self.bindData.isPreviewMax = self.Preview_Max.Active
		self.bindData.previewTabRect.selectedIndex = self.Preview_TabRect_Type.WebPage
	else
		self.bindData.isPreviewMax = self.Preview_Max.Normal
		self.bindData.previewTabRect.selectedIndex = self.Preview_TabRect_Type.Normal
	end
end

M.CheckFileHaveContent = function(self, fileId)
	local computerFileCfg = LTConfig.ComputerFileConfig.GetConfig(fileId)

	return computerFileCfg.PictureId or computerFileCfg.VideoId or computerFileCfg.TextCode or not table.isNilOrEmpty(computerFileCfg.SubFileList)
end

M.OnComputerPreviewClose = function(self)
	self.bindData.previewTabRect:SelectIndexWithClose(-1)
end

M.OnStep = function(self, step)
	local bottomDataList = self.bottomViewDataList

	if not bottomDataList then
		return
	end

	local appIdList = {}

	for _, data in ipairs(bottomDataList) do
		if data.tIndex ~= self.App_Template_Type.App then
			table.insert(appIdList, data.appId)
		end
	end

	local count = #appIdList

	if count < 1 then
		return
	end

	local _, currentIndex = table.find(appIdList, self.currentAppId)

	if not currentIndex then
		return
	end

	local newIndex = currentIndex + step

	if newIndex >= 1 then
		newIndex = count
	elseif count >= newIndex then
		newIndex = 1
	end

	self.OnBottomAppClick(self, appIdList[newIndex])
end

M.OnDestroy = function(self)
	self.currentAppId = nil
	self.isInBackground = nil
	self.waitCloseCo = coroutine.stop(self.waitCloseCo)
	self.intiViewCo = coroutine.stop(self.intiViewCo)
	self.delayShowDesktopCo = coroutine.stop(self.delayShowDesktopCo)

	self.CloseComputerHudPanel(self)

	self.countDownCo = coroutine.stop(self.countDownCo)
	self.playOpenEffectCo = coroutine.stop(self.playOpenEffectCo)
	self.playOpeningEffectCo = coroutine.stop(self.playOpeningEffectCo)
	self.passwordErrorTipsCo = coroutine.stop(self.passwordErrorTipsCo)
	self.inputDeactivateCo = coroutine.stop(self.inputDeactivateCo)

	self.CloseTaskNoticePanel(self)
	self.ClearMessageEvents(self)

	if self.redDotAction then
		SGUI.RedDotMgr.onRenderRedDot = SGUI.RedDotMgr.onRenderRedDot - self.redDotAction
		self.redDotAction = nil
	end

	gSpoonClientMgr:TryCallInnerSignal(self.entityId, L50.Spoon.SpoonRunTime.ClientGraphType.GADGET, "ComputerMainPanelClose")

	self.waitCo = coroutine.stop(self.waitCo)
end
