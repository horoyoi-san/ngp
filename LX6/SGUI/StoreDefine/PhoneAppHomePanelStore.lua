-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PhoneAppHomePanelStore.lua
-- Decompiled from: 02088_PhoneAppHomePanelStore.lua_7cf18542d0f7.luajit

C_PhoneAppHomePanelStore = DefClass("C_PhoneAppHomePanelStore", C_PhoneAppHomePanelStore, C_PhoneAppBaseStackStoreGroup)
GroupName2Class.PhoneAppHomePanelStore = C_PhoneAppHomePanelStore
local M = C_PhoneAppHomePanelStore

M.OnAwake = function(self)
	self.bindData.fullScreenButton.luaClick = self.CreateAction(self, self.OnFullScreenClick)
	self.bindData.tabRect.OnRenderTab = self.CreateAction(self, self.OnRenderTab)
	self.bindData.mainTabRect.OnRenderTab = self.CreateAction(self, self.OnMainRenderTab)
	self.bindData.frontTabRect.OnRenderTab = self.CreateAction(self, self.OnFrontRenderTab)
end

M.OnFullScreenClick = function(self)
	if gClientUtils.CheckIsGamePadMode() then
		local mainStore = self.currentMainStore

		if mainStore and mainStore.uninstallMode and mainStore.SetUninstallMode then
			mainStore.SetUninstallMode(mainStore, false)

			return
		end
	end

	self.OnExitClick(self)
end

M.EnterHide = function(self, flag)
	local currentStore = self.bindData.tabRect.selectedIndex > 0 and self.currentTabStore or self.currentMainStore

	if flag then
		currentStore.rootWidget:SetWidgetFaraway(true)
	else
		currentStore.rootWidget:SetWidgetFaraway(false)
	end
end

M.OnShow = function(self, panelId, args, store)
	gClientUtils.currentMainPanelId = panelId
	self.m_Id = panelId
	self.panelId = panelId

	if gClientUtils.IsNil(self.rootGo) then
		return
	end

	self.isPreLoad = nil
	self.bindData.tabRect.selectedIndex = -1

	self.bindData.tabRect:ClearUnusedTabInstances()

	self.hasDestroy = nil
	args = args or {}
	local showTypeField = self:GetShowTypeField()
	args[showTypeField] = args[showTypeField] or -1
	args.store = store
	self.isPreLoad = args.preLoad

	if not self.isPreLoad then
		if gLuaDataManager.isNetworkAvailable then
			self.waitNotifyPopularityPhoneFirstOpened = nil

			gHotCenterManager:TryNotifyPopularityPhoneFirstOpened()
		else
			self.waitNotifyPopularityPhoneFirstOpened = true
		end
	end

	self.ShowPanel(self, args)

	if not self.isPreLoad then
		self.waitFrameCo = coroutine.stop(self.waitFrameCo)

		gSoundMgr:PlaySoundByTid(70600299)

		self.isPlayShowSound = true

		self:SetShowJoystick(true)
		gClientUtils.OnMainPhonePanelOpen()
		gMessageManager:SendMessage(gEventConstants.ON_PHONE_APP_HOME_SHOW)
		gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.BattleUI, "openCommonHalf", true)
		gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.SwitchCharacterWheels, "openCommonHalf", true)
		gMessageManager:SendMessage(gEventConstants.ENABLE_CAMERA_FOLLOW, true)
		LX6.GUI.NavMgrEx.Instance:AddBanArea(self.bindData.panelRootNavArea)
		gMainPhoneUtils.SetSGUIGlobalBarVisible(false)
	else
		self.waitFrameCo = coroutine.start(function ()
			coroutine.step()
			self:OnCloseMainPhonePanel(_, true)
		end)
	end
end

M.SetShowJoystick = function(self, isShow)
	if self.m_Id then
		local panelCfg = LTConfig.PanelConfig.GetConfig(self.m_Id)

		if panelCfg.isFullScreen then
			return
		end

		if isShow then
			local sortingInOrder = gCS.LuaUtils.GetSortingInOrder(self.rootGo)

			SGUI.SguiJoystick.EnableTempSorting(isShow, sortingInOrder + 10)
		else
			SGUI.SguiJoystick.EnableTempSorting(isShow, 0)
		end
	end
end

M.ShowPanel = function(self, args)
	M.base.ShowPanel(self, args)

	if args.mainHomeType and args.mainHomeType <= 0 then
		if self.bindData.mainTabRect.selectedIndex == 0 then
			self.bindData.mainTabRect:SelectIndexWithClose(0)
		end

		self.bindData.mainTabRect.selectedIndex = args.mainHomeType

		return
	end

	local showTypeField = self:GetShowTypeField()
	local showType = args[showTypeField] or -1
	local showIndex = showType ~= -1 and gClientConst.MainHomeType.MainPhone or -1

	if showIndex > 0 then
		local exist, widget = self.bindData.mainTabRect:TryGetTabInstance(showIndex, nil)

		if exist and gClientUtils.NotNil(widget) then
			widget:SetActive(true)

			local uNavigationArea = widget.gameObject:GetComponent("UNavigationArea")

			if uNavigationArea then
				uNavigationArea.enabled = false
				uNavigationArea.enabled = true
			end

			self.OnMainRenderTab(self, nil, widget)
		else
			self.bindData.mainTabRect.selectedIndex = showIndex
		end
	else
		local exist, widget = self.bindData.mainTabRect:TryGetTabInstance(0, nil)

		if exist and gClientUtils.NotNil(widget) then
			widget.SetActive(widget, false)
		end
	end
end

M.CheckMainHomeWidgetValid = function(self)
	return not self.hasDestroy and self.currentMainStore and gClientUtils.NotNil(self.currentMainStore.rootWidget)
end

M.GetMessageEvents = function(self)
	return {
		[gEventConstants.ON_PHONE_APP_HOME_CONTENT_SHOW] = function (_, args)
			self:ShowContentPanel(args)
		end,
		[gEventConstants.ON_PHONE_APP_HOME_CONTENT_CLOSE] = function (_, args)
			self:CloseContentPanel(args)
		end,
		[gEventConstants.ON_PHONE_INPUT_FIELD_ACTIVE] = self.CreateAction(self, "OnInputFieldActive"),
		[gEventConstants.ON_PHONE_INPUT_FIELD_DE_ACTIVE] = self.CreateAction(self, "OnInputFieldDeActive"),
		[gEventConstants.ON_ENTER_PREVIEW_SKIN_MODE] = self.CreateAction(self, "OnEnterPreviewSkinMode"),
		[gEventConstants.ON_EXIT_PREVIEW_SKIN_MODE] = self.CreateAction(self, "OnExitPreviewSkinMode"),
		[gEventConstants.ON_CLOSE_MAIN_PHONE_PANEL] = self.CreateAction(self, "OnCloseMainPhonePanel"),
		[gEventConstants.ON_CLOSE_PHONE_APP_CONFIRM_PANEL] = self.CreateAction(self, "OnCloseConfirmPanel"),
		[gEventConstants.SYNC_CURRENT_SPIRIT] = self.CreateAction(self, "OnCurrentSpiritChange"),
		[gEventConstants.PANEL_ON_CLOSE] = self.CreateAction(self, "OnPanelClose"),
		[gEventConstants.ON_SHOW_PHONE_MESSAGE_TIPS] = self.CreateAction(self, "ShowMessageTips"),
		[gEventConstants.LOADING_FINISHED] = self.CreateAction(self, "OnLoadingFinished"),
		[gEventConstants.PAOKU_STATE_CHANGE] = function ()
			if not gPanelManager:HasFullscreen() then
				gClientUtils.PlayPhoneAction()
			end
		end,
		[gEventConstants.MY_UNIT_STATE_CHANGE] = function ()
			if not gPanelManager:HasFullscreen() then
				gClientUtils.PlayPhoneAction()
			end
		end,
		[gEventConstants.PHONE_SET_SCREEN_BTN_ACTIVE] = function (_, active)
			self.bindData.fullScreenButton:SetActive(active)
		end
	}
end

M.OnLoadingFinished = function(self)
	if not self.waitNotifyPopularityPhoneFirstOpened or not gLuaDataManager.isNetworkAvailable then
		return
	end

	self.waitNotifyPopularityPhoneFirstOpened = nil

	gHotCenterManager:TryNotifyPopularityPhoneFirstOpened()
end

M.InitModel = function(self, args)
	M.base.InitModel(self, args)

	self.isLogout = nil
end

M.InitView = function(self, args)
	if gClientUtils.IsNil(self.rootGo) or gClientUtils.IsNil(self.bindData.panelAnimation) then
		return
	end

	self.bindData.messageWidget:SetActive(false)
	M.base.InitView(self, args)
	self:OnCloseConfirmPanel()
	gClientUtils.InitNavAreasInChildren(self.rootWidget, self.panelId)
	self.bindData.fullScreenButton:SetActive(true)
	gCS.GuiUtils.SetPanelHideCursor(self.panelId, false)
	SGUI.ExtensionMethod.RefreshPlayingAnimation(self.bindData.panelAnimation)

	self.bindData.panelAnimation = self.rootGo:GetComponent("Animation")

	gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnimation, "S_Vx_PhoneAppHomePanel_open")
end

M.OnRenderTab = function(self, index, widget)
	gClientUtils.InitNavAreasInChildren(widget, self.panelId, self.bindData.gamepadBar)
	M.base.OnRenderTab(self, index, widget)

	self.hideMainViewCo = coroutine.stop(self.hideMainViewCo)
	self.hideMainViewCo = coroutine.start(function ()
		coroutine.wait(0.5)

		if self:CheckMainHomeWidgetValid() then
			self.currentMainStore.rootWidget:SetActive(false)
		end
	end)
end

M.OnMainRenderTab = function(self, _, widget)
	if self.panelArgs then
		local store = gStoreManager:GetStoreGroup(widget.Store)
		self.currentMainStore = store
		self.panelArgs.panelId = self.m_Id

		store:ShowPanel(self.panelArgs)

		self.homeScreenNavArea = widget:GetComponent(typeof(SGUI.UNavigationArea))

		gClientUtils.InitNavAreasInChildren(widget, self.panelId, self.bindData.gamepadBar)
	end
end

M.ShowFrontContent = function(self, args)
	if gClientUtils.NotNil(self.rootGo) and args then
		self.frontContentArgs = args
		self.bindData.frontTabRect.selectedIndex = args.showType
	end
end

M.OnFrontRenderTab = function(self, _, widget)
	gClientUtils.InitNavAreasInChildren(widget, self.panelId, self.bindData.gamepadBar)

	local store = gStoreManager:GetStoreGroup(widget.Store)

	store:ShowPanel(self.frontContentArgs)

	self.frontContentArgs = nil
end

M.OnExecuteExitAction = function(self)
	if self.hasDestroy then
		return
	end

	local closeAnimationName = "S_Vx_PhoneAppHomePanel_close"
	local clipTime = gClientUtils.GetAnimationClipLength(self.bindData.panelAnimation, closeAnimationName)

	gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnimation, closeAnimationName)

	self.playCloseAnimationCo = coroutine.stop(self.playCloseAnimationCo)
	self.playCloseAnimationCo = coroutine.start(function ()
		coroutine.wait(clipTime)
		gPanelManager:Close(self.panelId)
	end)
end

M.OnExitClick = function(self)
	if self.bindData.tabRect.selectedIndex ~= gClientConst.MAIN_PHONE_ROOT_SHOW_TYPE.WallPaper then
		gMessageManager:SendMessage(gEventConstants.ON_EXIT_WALL_PAPER_PREVIEW_MODE)
		self:CloseContentPanel()

		return
	end

	if gNpcChatManager.openingChatPanelLock then
		return
	end

	if gNpcChatUtils.IsChatPanelShowing() then
		local npcChatBasePanel = gNpcChatUtils.GetBasePanelStore()

		if npcChatBasePanel.closeType ~= gNpcChatConst.CloseButtonType.Hide then
			return
		end
	end

	self.OnExit(self)
end

M.CloseContentPanel = function(self, args)
	M.base.CloseContentPanel(self)

	self.hideMainViewCo = coroutine.stop(self.hideMainViewCo)

	if self.bindData.tabRect.selectedIndex >= 0 and self.CheckMainHomeWidgetValid(self) then
		gClientUtils.FinishAnimation(self.currentMainStore.bindData.panelAnimation, "S_Vx_MainPhonePanel_open")
		self.currentMainStore.rootWidget:SetActive(true)

		if (not args or not args.ignoreBackToMainAnimation) and self.currentMainStore.PlayBackToMainAnimation then
			self.currentMainStore:PlayBackToMainAnimation()
		end

		if self.currentMainStore.StartIsClickCdIng then
			self.currentMainStore:StartIsClickCdIng()
		end
	end
end

M.OnEnterPreviewSkinMode = function(self)
	self.hasEnterPreviewSkinMode = true
	self.hideMainViewCo = coroutine.stop(self.hideMainViewCo)

	self.currentMainStore.rootWidget:SetActive(true)

	self.bindData.childNodeActive = false
end

M.OnExitPreviewSkinMode = function(self)
	self.hasEnterPreviewSkinMode = false

	self.currentMainStore.rootWidget:SetActive(false)

	self.bindData.childNodeActive = true
end

M.OnCloseMainPhonePanel = function(self, _, force)
	if force then
		gPanelManager:Close(self.m_Id)
	else
		self.OnExitClick(self)
	end
end

M.OnCloseConfirmPanel = function(self)
	self.bindData.frontTabRect.selectedIndex = -1

	self.bindData.frontTabRect:ClearUnusedTabInstances()
end

M.OnCurrentSpiritChange = function(self)
	self.OnExitClick(self)
end

M.OnPanelClose = function(self, _, panelId)
	local panelCfg = LTConfig.PanelConfig.GetConfig(panelId)

	if panelCfg and panelCfg.isFullScreen and not self.isPreLoad then
		self.bindData.fullScreenButton:SetActive(true)

		if self.bindData.tabRect.selectedIndex > 0 then
			return
		end

		self.checkPanelCo = coroutine.stop(self.checkPanelCo)
		local rootGo = self.rootGo
		local localPosition = self.bindData.rootWidget.transform.localPosition
		self.bindData.rootWidget.transform.localPosition = Vector3.Fetch(localPosition.x, localPosition.y, -100000)
		self.hideMainViewCo = coroutine.stop(self.hideMainViewCo)
		self.checkPanelCo = coroutine.start(function ()
			coroutine.step()

			if gClientUtils.IsNil(rootGo) then
				return
			end

			self.bindData.rootWidget:SetActive(false)
			self.bindData.rootWidget:SetActive(true)

			self.bindData.rootWidget.transform.localPosition = Vector3.Fetch(localPosition.x, localPosition.y, 0)

			if self:CheckMainHomeWidgetValid() then
				self.currentMainStore:PlayBackToMainAnimation()
			end
		end)
	end
end

M.OnInputFieldActive = function(self)
	self.isInputMode = true

	LX6.Manager.GameInputManager.SetDisableInput(self.panelId, false, false, true)
end

M.OnInputFieldDeActive = function(self)
	self.isInputMode = nil

	LX6.Manager.GameInputManager.SetEnableInput(self.panelId, true, true, true)
end

M.GetShowTypeField = function(self)
	return gClientConst.PhoneAppShowTypeLevel.FirstLevel
end

M.ShowMessageTips = function(self, _, args)
	self.bindData.messageTips = args.text
	slot3 = self.bindData.messageWidget

	slot3:SetActive(true)

	self.showMessageCo = coroutine.stop(self.showMessageCo)
	self.showMessageCo = coroutine.start(function ()
		coroutine.wait(2.5)
		self.bindData.messageWidget:SetActive(false)
	end)
end

M.ClearData = function(self)
	gClientUtils.currentMainPanelId = nil
	self.waitFrameCo = coroutine.stop(self.waitFrameCo)
	self.hasEnterPreviewSkinMode = nil
	self.frontContentArgs = nil
	self.isInputMode = nil
	self.homeScreenNavArea = nil

	gNpcChatManager:_UnlockClosePhoneForOpeningChat()

	if self.panelId then
		gCS.GuiUtils.SetPanelHideCursor(self.panelId, false)
		LX6.Manager.GameInputManager.SetEnableInput(self.panelId, true, true, true)
		gCS.GuiUtils.SetPanelHideCursor(self.panelId, false)
	end

	local _ = not self.isLogout and gSocialNetworkUtils.AskTwitterPageClose(UX.Game.CloseTwitterPanelType.PhonePanel)

	gClientUtils.OnMainPhonePanelClose()

	self.dialogMoveStatus = nil

	gMessageManager:SendMessage(gEventConstants.ON_PHONE_APP_HOME_HIDE)
	gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.BattleUI, "openCommonHalf", false)
	gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.SwitchCharacterWheels, "openCommonHalf", false)
	gMessageManager:SendMessage(gEventConstants.ENABLE_CAMERA_FOLLOW, false)
	gNewGuideMgr:NotifySignal(EGuideSignal.MainPhonePanelClose)

	self.checkPanelCo = coroutine.stop(self.checkPanelCo)
	self.hideMainViewCo = coroutine.stop(self.hideMainViewCo)
	self.showMessageCo = coroutine.stop(self.showMessageCo)
	self.popUpQueue = nil

	if self.isPlayShowSound then
		gSoundMgr:PlaySoundByTid(70600334)
	end

	self.isPlayShowSound = false

	self:SetShowJoystick(false)
	LX6.GUI.NavMgrEx.Instance:RemoveBanArea(self.bindData.panelRootNavArea)
	gMainPhoneUtils.SetSGUIGlobalBarVisible(true)

	self.isPreLoad = nil
end

M.OnClose = function(self)
	self.ClearStoreGroupData(self)

	if gClientUtils.NotNil(self.bindData.tabRect) then
		self.bindData.tabRect.selectedIndex = -1

		self.bindData.tabRect:ClearUnusedTabInstances()
	end

	if gClientUtils.NotNil(self.bindData.mainTabRect) then
		local exist, widget = self.bindData.mainTabRect:TryGetTabInstance(0, nil)

		if exist and gClientUtils.NotNil(widget) then
			self.bindData.mainTabRect:SelectIndexWithClose(0)
		end
	end
end

M.OnLanguageChange = function(self, lang)
end

M.OnLogOut = function(self)
	self.isLogout = true

	if self.panelId then
		gPanelManager:Close(self.panelId)
	end
end
