local ComputerConfig = LTConfig.ComputerConfig
local MAX_PANEL = {
	[LTConfig.ComputerAppConfig.hacker1] = true,
	[LTConfig.ComputerAppConfig.hacker2] = true,
	[LTConfig.ComputerAppConfig.hacker3] = true
}
C_ComputerMainPanelStore = DefClass("C_ComputerMainPanelStore", C_ComputerMainPanelStore, C_StoreGroup)
GroupName2Class.ComputerMainPanelStore = C_ComputerMainPanelStore
local M = C_ComputerMainPanelStore

function M:OnAwake()
	self.bindData.enterButton.luaClick = self:CreateAction("OnEnterClick")
	self.bindData.bottomList.luaSimpleRenderItem = self:CreateAction("OnBottomAppRenderItem")
	self.bindData.tabRect.OnRenderTab = self:CreateAction("OnRenderTab")
	self.bindData.previewTabRect.OnRenderTab = self:CreateAction("OnPreviewRenderTab")
	self.bindData.exitButton.luaClick = self:CreateAction("OnExitClick")
	self.bindData.inputField.luaValueChanged = self:CreateAction("OnInputFieldValueChange")
	self.bindData.inputField.onActivateAction = self:CreateAction("OnInputFieldActivate")
	self.bindData.inputField.onDeActivateAction = self:CreateAction("OnInputFieldDeActivate")

	self:InitMessages()
end

function M:InitMessages()
	self:RegisterMessageEvents({
		[gEventConstants.ON_COMPUTER_APP_CLOSE] = self:CreateAction(self.OnComputerAppClose),
		[gEventConstants.ON_COMPUTER_PREVIEW_SHOW] = self:CreateAction(self.OnComputerPreviewShow),
		[gEventConstants.ON_COMPUTER_PREVIEW_CLOSE] = self:CreateAction(self.OnComputerPreviewClose),
		[gEventConstants.COMPUTER_ALLOW_EXIT] = function (_, enable)
			gMessageManager:SendMessage(gEventConstants.ON_COMPUTER_PANEL_EXIT_BUTTON_STATE_CHANGE, enable)
		end,
		[gEventConstants.ON_COMPUTER_PANEL_EXIT_BUTTON_STATE_CHANGE] = function (_, isActive)
			self.bindData.exitButton:SetActive(isActive)
		end
	})
end

function M:OnShow(_, args)
	if type(args) == "userdata" then
		args = args:ToTable()
		local computerId = args[1]
		local uiPivot = args[2]
		local entityId = args[3]
		args = {
			computerId = computerId,
			uiPivot = uiPivot,
			entityId = entityId
		}
	end

	self:InitModel(args)
	self:InitView(args)
end

function M:InitModel(args)
	self.computerId = args.computerId
	self.gamePadMode = SGUI.GameDevice.KeyboardMouse < gCS.LuaUtils.GetActiveDevice()
	self.entityId = args.entityId
	self.Computer_Default_Panel_Type = {
		File = 3,
		Hacker2 = 6,
		Hacker1 = 5,
		Desktop = 1,
		Email = 2,
		Webpage = 4,
		Start = 0,
		Hacker3 = 7
	}
	self.Computer_Status_Control = {
		Desktop = 2,
		WallPaper = 3,
		Start = 0,
		StartPassword = 1
	}
	self.App_Template_Type = {
		Spacer = 1,
		App = 0
	}
	self.Password_Control = {
		Incorrect = 1,
		Normal = 0
	}
	self.Preview_Max = {
		Active = 1,
		Normal = 0
	}
	self.Preview_TabRect_Type = {
		WebPage = 1,
		Normal = 0
	}
end

function M:InitView(args)
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

	local rootGo = self.rootGo
	self.intiViewCo = coroutine.start(function ()
		coroutine.step()

		if gClientUtils.NotNil(rootGo) then
			self:RefreshPanelView(args)
		end
	end)
end

function M:RefreshPanelView(_)
	local needHideExitOnInit = false
	local computerCfg = LTConfig.ComputerConfig.GetConfig(self.computerId)

	if computerCfg.UIRound > 0 then
		local uiRound = computerCfg.UIRound
		self.bindData.roundMask.cornerRadius = Vector4.New(uiRound, uiRound, uiRound, uiRound)
	end

	if computerCfg.DefaultPanel == self.Computer_Default_Panel_Type.Start then
		self:RefreshStartView()
		self:PlayFirstOpenEffect()
	else
		if computerCfg.DefaultPanel == self.Computer_Default_Panel_Type.Email then
			self:SelectedTabRect(0, 0.1)
		elseif computerCfg.DefaultPanel == self.Computer_Default_Panel_Type.File then
			self:SelectedTabRect(1, 0.1)
		elseif computerCfg.DefaultPanel == self.Computer_Default_Panel_Type.Hacker1 then
			self:SelectedTabRect(gClientConst.ComputerAppId2TabIndex[gClientConst.ComputerAppIdMap.Hacker1], 1.5)

			needHideExitOnInit = true
		elseif computerCfg.DefaultPanel == self.Computer_Default_Panel_Type.Hacker2 then
			self:SelectedTabRect(gClientConst.ComputerAppId2TabIndex[gClientConst.ComputerAppIdMap.Hacker2], 1.5)

			needHideExitOnInit = true
		elseif computerCfg.DefaultPanel == self.Computer_Default_Panel_Type.Hacker3 then
			self:SelectedTabRect(gClientConst.ComputerAppId2TabIndex[gClientConst.ComputerAppIdMap.Hacker3], 1.5)

			needHideExitOnInit = true
		end

		if computerCfg.DefaultPanel == self.Computer_Default_Panel_Type.Hacker1 or computerCfg.DefaultPanel == self.Computer_Default_Panel_Type.Hacker2 or computerCfg.DefaultPanel == self.Computer_Default_Panel_Type.Hacker3 then
			self.bindData.isMax = 1
		else
			self.bindData.isMax = 0
		end
	end

	self.bindData.startImageId = computerCfg.StartImage
	self.bindData.desktopImageId = computerCfg.DesktopImage

	self:OpenComputerHudPanel(needHideExitOnInit)
end

function M:SelectedTabRect(index, delay)
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
		self:RefreshDesktopView()

		self.bindData.tabRect.selectedIndex = index
	end
end

function M:PlayFirstOpenEffect()
	local computerCfg = LTConfig.ComputerConfig.GetConfig(self.computerId)

	if computerCfg.IsPlayAnimation and not self:CheckComputerHasOpened() then
		self.bindData.syncControl = 1
		self.playOpenEffectCo = coroutine.start(function ()
			coroutine.wait(3)

			self.bindData.syncControl = 0
		end)

		self:AskComputerOpened()
	end
end

function M:CheckComputerHasOpened()
	local computerInfos = self:GetComputerInfos()

	return computerInfos[self.computerId] ~= nil
end

function M:GetComputerInfos()
	local computerUnlockInfo = gPlayerManager.infoMinor.bindData.computerUnlockInfo

	return computerUnlockInfo.ComputerInfos
end

function M:AskComputerOpened()
	gClientToGameDelegate:AskComputerOpened(self.computerId).Callback = function (errorId)
		if errorId ~= LTConfig.MessageConfig.Ok then
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

function M:OpenComputerHudPanel(needHideExitOnInit)
	gPanelManager:CheckShow(gPanelId.COMPUTER_HUD_PANEL, {
		navigationArea = self.bindData.uNavigationArea,
		exitCallback = function ()
			self:OnExitClick()
		end,
		exitInitShow = needHideExitOnInit
	})
end

function M:CloseComputerHudPanel()
	if gPanelManager:IsPanelShowing(gPanelId.COMPUTER_HUD_PANEL) then
		gPanelManager:Close(gPanelId.COMPUTER_HUD_PANEL)
	end
end

function M:RefreshStartView()
	local computerCfg = LTConfig.ComputerConfig.GetConfig(self.computerId)
	self.bindData.statusControl = string.is_null_or_empty(computerCfg.Password) and self.Computer_Status_Control.Start or self.Computer_Status_Control.StartPassword
	self.bindData.userName = computerCfg.UserName

	if computerCfg.IsPlayerComputer then
		local headIcon, _ = gHunLunManager:GetHeadIconAndName(gPlayerManager.infoLogin.bindData.infoPzHeadInfo.SystemHeadId)
		self.bindData.headIconId = headIcon
	else
		self.bindData.headIconId = computerCfg.UserHeadId
	end

	self.bindData.startImageId = computerCfg.StartImage
end

function M:OnInputFieldValueChange()
	local inputContent = self.bindData.inputField.text
	self.bindData.inputField.text = LX6.Extension.StringEx.ReplacePattern(inputContent, "[^a-zA-Z0-9]", "")
end

function M:OnInputFieldActivate()
	self.bindData.exitButton.gameObject:SetActive(false)
end

function M:OnInputFieldDeActivate()
	self.bindData.exitButton.gameObject:SetActive(true)
end

function M:OnExitClick()
	local selectedIndex = self.bindData.tabRect.selectedIndex

	if selectedIndex > 1 then
		local exist, widget = self.bindData.tabRect:TryGetTabInstance(selectedIndex, nil)

		if exist then
			local store = gStoreManager:GetStoreGroup(widget.Store)

			if store.TryClose and type(store.TryClose) == "function" then
				store:TryClose()
			end
		end

		self:OnComputerAppClose()

		return
	end

	self:CloseComputerHudPanel()
	gPanelManager:Close(self.m_Id)
end

function M:OnActiveDeviceChange(device)
	self.gamePadMode = SGUI.GameDevice.KeyboardMouse < device
end

function M:OnEnterClick()
	local computerCfg = LTConfig.ComputerConfig.GetConfig(self.computerId)
	local password = computerCfg.Password or ""
	local signalKey = nil

	if password ~= self.bindData.inputField.text then
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
	end)
end

function M:ShowPasswordErrorTips()
	self.passwordErrorTipsCo = coroutine.stop(self.passwordErrorTipsCo)
	self.bindData.passwordControl = self.Password_Control.Incorrect
	self.passwordErrorTipsCo = coroutine.start(function ()
		coroutine.wait(2)

		self.bindData.passwordControl = self.Password_Control.Normal
	end)
end

function M:OnBottomAppRenderItem(btn, csIndex)
	local luaIndex = csIndex + 1
	local data = self.bottomViewDataList[luaIndex]

	if data.tIndex == self.App_Template_Type.App then
		local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
		store.button.luaClick = self:CreateActionWithArgs(self.OnBottomAppClick, data.appId)
		local appCfg = LTConfig.ComputerAppConfig.GetConfig(data.appId)
		store.iconId = appCfg.SIconId
		store.guideId = appCfg.GuideId
	end
end

function M:OnRenderTab(_, widget)
	local store = gStoreManager:GetStoreGroup(widget.Store)
	store.m_Id = self.m_Id

	if SGUI.GameDevice.KeyboardMouse < gCS.LuaUtils.GetActiveDevice() then
		SGUI.UCursorInput.ResetCursorPos()
	end

	store:ShowPanel(self.computerId, self.entityId)
end

function M:OnPreviewRenderTab(_, widget)
	local store = gStoreManager:GetStoreGroup(widget.Store)
	store.m_Id = self.m_Id

	SGUI.UCursorInput.ResetCursorPos()
	store:ShowPanel(self.computerPreviewFileId)
end

function M:OnBottomAppClick(appId)
	if appId == LTConfig.ComputerAppConfig.Email then
		self.bindData.tabRect.selectedIndex = gClientConst.ComputerAppId2TabIndex[gClientConst.ComputerAppIdMap.Email]
	elseif appId == LTConfig.ComputerAppConfig.File then
		self.bindData.tabRect.selectedIndex = gClientConst.ComputerAppId2TabIndex[gClientConst.ComputerAppIdMap.File]
	elseif appId == LTConfig.ComputerAppConfig.hacker1 then
		self.bindData.tabRect.selectedIndex = gClientConst.ComputerAppId2TabIndex[gClientConst.ComputerAppIdMap.Hacker1]
	elseif appId == LTConfig.ComputerAppConfig.hacker2 then
		self.bindData.tabRect.selectedIndex = gClientConst.ComputerAppId2TabIndex[gClientConst.ComputerAppIdMap.Hacker2]
	elseif appId == LTConfig.ComputerAppConfig.hacker3 then
		self.bindData.tabRect.selectedIndex = gClientConst.ComputerAppId2TabIndex[gClientConst.ComputerAppIdMap.Hacker3]
	elseif appId == LTConfig.ComputerAppConfig.WebPage then
		self.bindData.tabRect.selectedIndex = gClientConst.ComputerAppId2TabIndex[gClientConst.ComputerAppIdMap.Webpage]
	end

	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.isMax = 1
	elseif MAX_PANEL[appId] then
		self.bindData.isMax = 1
	else
		self.bindData.isMax = 0
	end
end

function M:RefreshDesktopView()
	self.bindData.statusControl = self.Computer_Status_Control.Desktop

	self:StartCountDownCo()
	self:RefreshBottomAppListView()
end

function M:RefreshBottomAppListView()
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

		if appCfg1.Rank ~= appCfg2.Rank then
			return appCfg1.Rank < appCfg2.Rank
		end

		return data1.appId < data2.appId
	end)

	self.bottomViewDataList = {}

	for index, viewData in ipairs(viewDataList) do
		table.insert(self.bottomViewDataList, viewData)

		if index ~= #viewDataList then
			table.insert(self.bottomViewDataList, {
				tIndex = self.App_Template_Type.Spacer
			})
		end
	end

	function self.bindData.bottomList.onGetTIndex(csIndex)
		local luaIndex = csIndex + 1

		return self.bottomViewDataList[luaIndex].tIndex
	end

	self.bindData.bottomList:SetSimpleList(#self.bottomViewDataList)

	self.bindData.bottomBar.transform.localScale = #viewDataList > 0 and Vector3.one or Vector3.zero
end

function M:StartCountDownCo()
	self.countDownCo = coroutine.stop(self.countDownCo)
	self.countDownCo = coroutine.start(function ()
		self:RefreshTimeView()

		while true do
			coroutine.wait(1)
			self:RefreshTimeView()
		end
	end)
end

function M:RefreshTimeView()
	local gameTime = LX6.Manager.AtmosphereManager.Instance:GetGameTime()
	local min = math.floor(gameTime / 60 % 60)
	local hour = math.floor(gameTime / gClientConst.SECONDS_PER_HOUR)
	local time = ("%02d:%02d"):format(hour, min)
	self.bindData.time = time
end

function M:OnComputerAppClose(_, params)
	SGUI.UCursorInput.ResetCursorPos()

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

	self.bindData.isMax = 0

	if closeSelf then
		self:OnExitClick()
	end

	if closeWithAppOpen and closeWithAppOpen ~= ComputerConfig.HackOpenAppType.none then
		if closeWithAppOpen == ComputerConfig.HackOpenAppType.email then
			self:OnBottomAppClick(gClientConst.ComputerAppIdMap.Email)
		elseif closeWithAppOpen == ComputerConfig.HackOpenAppType.file then
			self:OnBottomAppClick(gClientConst.ComputerAppIdMap.File)
		elseif closeWithAppOpen == ComputerConfig.HackOpenAppType.webpage then
			self:OnBottomAppClick(gClientConst.ComputerAppIdMap.Webpage)
		elseif closeWithAppOpen == ComputerConfig.HackOpenAppType.desktop then
			-- Nothing
		else
			local computerCfg = LTConfig.ComputerConfig.GetConfig(self.computerId)

			if computerCfg.WallpaperOnly then
				self.bindData.statusControl = self.Computer_Status_Control.WallPaper
			end
		end
	end
end

function M:CheckIsHackerApp()
	local hackerAppTabRectIndexList = {
		2,
		3,
		4
	}

	for _, tabRectIndex in ipairs(hackerAppTabRectIndexList) do
		return self.bindData.tabRect.selectedIndex == tabRectIndex
	end
end

function M:OnComputerPreviewShow(_, computerFileId)
	self.computerPreviewFileId = computerFileId
	local computerFileCfg = LTConfig.ComputerFileConfig.GetConfig(computerFileId)

	if computerFileCfg.FileType == gClientConst.Computer_File_Type.PDF then
		self.bindData.isPreviewMax = self.Preview_Max.Active
		self.bindData.previewTabRect.selectedIndex = self.Preview_TabRect_Type.WebPage
	else
		self.bindData.isPreviewMax = self.Preview_Max.Normal
		self.bindData.previewTabRect.selectedIndex = self.Preview_TabRect_Type.Normal
	end
end

function M:OnComputerPreviewClose()
	self.bindData.previewTabRect:SelectIndexWithClose(-1)
end

function M:OnDestroy()
	self.waitCloseCo = coroutine.stop(self.waitCloseCo)
	self.intiViewCo = coroutine.stop(self.intiViewCo)
	self.delayShowDesktopCo = coroutine.stop(self.delayShowDesktopCo)

	self:CloseComputerHudPanel()

	self.countDownCo = coroutine.stop(self.countDownCo)
	self.playOpenEffectCo = coroutine.stop(self.playOpenEffectCo)
	self.passwordErrorTipsCo = coroutine.stop(self.passwordErrorTipsCo)

	self:ClearMessageEvents()
	gSpoonClientMgr:TryCallInnerSignal(self.entityId, "ComputerMainPanelClose")

	self.waitCo = coroutine.stop(self.waitCo)
end
