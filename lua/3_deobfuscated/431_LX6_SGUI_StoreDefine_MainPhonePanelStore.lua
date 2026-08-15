local PanelRedDotConfig = LTConfig.PanelRedDotConfig
C_MainPhonePanelStore = DefClass("C_MainPhonePanelStore", C_MainPhonePanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.MainPhonePanelStore = C_MainPhonePanelStore
local M = C_MainPhonePanelStore

function M:OnAwake()
	self.bindData.mainPhoneList.expectedItemCount = 100
	self.bindData.mainPhoneList.luaSimpleRenderItem = self:CreateAction("OnPhoneRenderItem")
	self.bindData.bottomList.luaSimpleRenderItem = self:CreateAction("OnBottomAppRenderItem")
	self.bindData.exitPreviewSkinButton.luaClick = self:CreateAction("OnExitPreviewSkinModeClick")
	self.bindData.applySkinButton.luaClick = self:CreateAction("OnApplySkinClick")

	gMessageManager:SendMessage(gEventConstants.ASK_MAILS_BRIEF_INFO)
	self:InitDataSetEvents()
	coroutine.start(function ()
		coroutine.step()
		self.bindData.mainPhoneList:RegisterToScrollEvent(self:CreateAction("OnPhoneListOnScroll"))
	end)
end

function M:InitDataSetEvents()
	return
end

function M:GetMessageEvents()
	return {
		[gEventConstants.LANGUAGE_CHANGE] = self:CreateAction("RefreshPanelView"),
		[gEventConstants.SYSTEM_UNLOCK_STATE_CHANGE] = self:CreateAction("RefreshPanelView"),
		[gEventConstants.RED_POINT_PANEL_UPDATE] = self:CreateAction("RefreshPanelView"),
		[gEventConstants.UPDATE_UNREAD_MSG_TIPS] = self:CreateAction("RefreshPanelView"),
		[gEventConstants.REFRESH_MAIN_BUTTON_RED_POT] = self:CreateAction("RefreshPanelView"),
		[gEventConstants.ADJUST_WORLD_LEVEL] = self:CreateAction("RefreshPanelView"),
		[gEventConstants.PALYER_LEVEL_UP] = self:CreateAction("RefreshPanelView"),
		[gEventConstants.SYNC_CURRENT_SPIRIT] = self:CreateAction("RefreshPanelView"),
		[gEventConstants.ON_PLAYER_FAN_CHANGE] = self:CreateAction("RefreshPanelView"),
		[gEventConstants.JOB_CHANGE_EVENT] = self:CreateAction("RefreshPanelView"),
		[gEventConstants.ON_ENTER_PREVIEW_SKIN_MODE] = self:CreateAction("OnEnterPreviewSkinMode"),
		[gEventConstants.ON_MAIN_PHONE_SKIN_RESET] = self:CreateAction("OnResetSkinView"),
		[gEventConstants.ON_SYNC_SPIRIT_SKIN_PART_INFO_CHANGE] = self:CreateAction("OnSpiritSkinPartChange"),
		[gEventConstants.ON_MAIN_PHONE_PAGE_CHANGE] = self:CreateAction("OnMainPhonePageChange"),
		[gEventConstants.ON_LEVEL_REWARD_UPDATE] = self:CreateAction("RefreshPanelView"),
		[gEventConstants.PANEL_ON_CLOSE] = self:CreateAction("OnPanelClose"),
		[gEventConstants.LINK_MODE_CHANGE] = self:CreateAction("RefreshPanelView"),
		[gEventConstants.AGENT_PROFILE_RED_POINT_REFRESH] = self:CreateAction("RefreshPanelView"),
		[gEventConstants.UPDATE_NOTICE_RED_POT] = self:CreateAction("RefreshRedDot"),
		[gEventConstants.ON_PHONE_CALL_STATE_CHANGE] = self:CreateAction("RefreshPanelView"),
		[gEventConstants.ON_EXIT_WALL_PAPER_PREVIEW_MODE] = self:CreateAction("OnExitPreviewSkinMode"),
		[gEventConstants.ON_HACKER_APP_REDPOINT_CHANGE] = self:CreateAction("RefreshPanelView"),
		[gEventConstants.ON_PHONE_APP_HOME_HIDE] = self:CreateAction("OnExit")
	}
end

function M:InitModel(args)
	M.base.InitModel(self, args)

	self.isClickCdIng = nil
	self.panelId = args.panelId
	self.ShowControl = {
		Hide = 1,
		Show = 0
	}
	self.DownloadControl = {
		Before = 1,
		After = 0
	}
	self.skinInfo = gMainPhoneUtils.GetCurrentSpiritSkinInfo()
end

function M:InitView(_)
	M.base.InitView(self, _)
	self.rootWidget:SetActive(true)
	self:RefreshPanelView()
	self.bindData.mainPhoneList:GoToPage(0, true)
	gClientUtils.FinishAnimation(self.bindData.panelAnimation, "S_Vx_MainPhonePanel_BacktoMain")
	SGUI.ExtensionMethod.RefreshPlayingAnimation(self.bindData.panelAnimation)
	gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnimation, "S_Vx_MainPhonePanel_open")
	self.bindData.pageList:SelectItem(0)
end

function M:RefreshPanelView()
	if gClientUtils.IsNil(self.rootGo) then
		return
	end

	local hasUnlocked = gMainPhoneUtils.CheckMainPhoneTopButtonUnlocked()

	self.bindData.topFakeNavButton:SetActive(hasUnlocked)

	local mainPhoneViewDataList, pageViewDataList, totalPageCount = gMainPhoneUtils.GetMainPhoneViewDataList()
	self.mainPhoneViewDataList = mainPhoneViewDataList

	function self.bindData.mainPhoneList.onGetTIndex(csIndex)
		local luaIndex = csIndex + 1
		local data = self.mainPhoneViewDataList[luaIndex]

		return data.tIndex
	end

	self.bindData.mainPhoneList:SetSimpleList(#mainPhoneViewDataList)
	self.bindData.pageList:SetSimpleList(#pageViewDataList)

	self.bottomAppDataList = gMainPhoneUtils.GetBottomPhoneAppViewDataList()

	self.bindData.bottomList:SetSimpleList(#self.bottomAppDataList)

	totalPageCount = totalPageCount or 1
	self.bindData.fansCount = gPlayerManager.infoMinor.bindData.fan123
	self.bindData.showDotCtrl = totalPageCount > 1 and self.ShowControl.Show or self.ShowControl.Hide

	self:RefreshIndividualizationView()
	self:RefreshRedDot()
end

function M:RefreshRedDot()
	gMainPhoneUtils.CheckMainPhoneHasRedDot(function (hasRed)
		SGUI.RedDotMgr.LuaSetRedDot(hasRed, "CoreHudSystemControlStore.Phone")
	end)
end

function M:RefreshIndividualizationView()
	local wallPaperId = self.skinInfo and self.skinInfo.wallPaperId
	local skinPartCfg = LTConfig.MobileMenuSkinPartConfig.GetConfig(wallPaperId)
	local colorControlValue = skinPartCfg and skinPartCfg.WallpaperColorIndex or 0
	local backgroundImageId = 0

	if wallPaperId ~= LTConfig.MobileMenuSkinPartConfig.DefaultWallPaper and skinPartCfg then
		backgroundImageId = skinPartCfg.IconId2 > 0 and skinPartCfg.IconId2 or skinPartCfg.IconId
	end

	self.bindData.colorControl = colorControlValue
	self.bindData.blurActive = false
	self.bindData.backgroundImageId = backgroundImageId
	self.bindData.blurBackgroundImageId = 0

	self:RefreshPendantView()
end

function M:RefreshPendantView()
	local rootStoreGroupName = self.panelArgs and self.panelArgs.store
	local phoneAppHomePanelStore = gStoreManager:GetStoreGroup(rootStoreGroupName)

	if phoneAppHomePanelStore and gClientUtils.NotNil(phoneAppHomePanelStore.rootGo) then
		local pendantId = self.skinInfo and self.skinInfo.pendantId
		local skinPartCfg = LTConfig.MobileMenuSkinPartConfig.GetConfig(pendantId)
		local skinPendantIndex = 0

		if pendantId ~= LTConfig.MobileMenuSkinPartConfig.DefaultPendant and skinPartCfg then
			skinPendantIndex = skinPartCfg.PendantTabRectIndex
		end

		phoneAppHomePanelStore.bindData.skinPendantTabRect:ResetAllTabInstances()
		phoneAppHomePanelStore.bindData.skinPendantTabRect:SelectIndexWithClose(skinPendantIndex)
	end
end

function M:OnPhoneRenderItem(btn, csIndex)
	self.mainPhoneListBtn = self.mainPhoneListBtn or {}
	local luaIndex = csIndex + 1
	local data = self.mainPhoneViewDataList[luaIndex]
	local storeName = btn.Store
	local store = gStoreManager:GetStoreGroup(storeName):GetStoreByWidget(btn)

	if data.tIndex == gClientConst.MainPhoneTemplateType.FourAppTIndex then
		function store.appList.luaSimpleRenderItem(childBtn, childCsIndex)
			local childLuaIndex = childCsIndex + 1
			local childData = data.appList[childLuaIndex]

			self:OnSinglePhoneAppRenderItem(childBtn, childCsIndex, childData)
			self:SetMainPhoneBtnList(luaIndex, childBtn, childLuaIndex)
		end

		store.appList:SetSimpleList(#data.appList)
	elseif data.tIndex == gClientConst.MainPhoneTemplateType.SingleAppTIndex then
		self:OnSinglePhoneAppRenderItem(btn, csIndex, data)
		self:SetMainPhoneBtnList(luaIndex, btn)

		local hasUnlockedTopButton = gMainPhoneUtils.CheckMainPhoneTopButtonUnlocked()

		if hasUnlockedTopButton then
			if csIndex <= 10 then
				btn.gameObject.name = ("S_PhoneIconTemplate_%d"):format(csIndex)
			else
				btn.gameObject.name = ("ListPhoneIconTemplate_%d"):format(csIndex)
			end
		elseif csIndex <= 13 then
			btn.gameObject.name = ("S_PhoneIconTemplate_%d"):format(csIndex + 1)
		else
			btn.gameObject.name = ("ListPhoneIconTemplate_%d"):format(csIndex)
		end
	elseif data.tIndex == gClientConst.MainPhoneTemplateType.FansIndex then
		self:RefreshBubbleFansView(store)
		self:SetMainPhoneBtnList(luaIndex, btn)
	elseif data.tIndex == gClientConst.MainPhoneTemplateType.IndividualizationFansIndex then
		self:RefreshIndividualizationFansView(store)
		self:SetMainPhoneBtnList(luaIndex, self.individualizationWidget)
	elseif data.tIndex == gClientConst.MainPhoneTemplateType.TopButton then
		local popularityStore = self:RefreshTopView(store)

		self:SetMainPhoneBtnList(luaIndex, popularityStore.button)
	end

	if #self.mainPhoneViewDataList == luaIndex then
		self:OnLayoutSet()
	end
end

function M:SetMainPhoneBtnList(index, btn, subIndex)
	self.mainPhoneListBtnIndexDict = self.mainPhoneListBtnIndexDict or {}
	self.mainPhoneListBtnIndexDict[btn] = 0
	self.mainPhoneListBtn = self.mainPhoneListBtn or {}
	local buttonList = self.mainPhoneListBtn[index] or {}
	buttonList[subIndex or 1] = btn
	self.mainPhoneListBtn[index] = buttonList
end

function M:OnLayoutSet()
	local navigationButtonList = {}

	for _, buttonList in ipairs(self.mainPhoneListBtn) do
		for _, button in ipairs(buttonList) do
			table.insert(navigationButtonList, button)

			self.mainPhoneListBtnIndexDict[button] = #navigationButtonList
		end
	end

	self.bindData.navigateComponent:Refresh(navigationButtonList)
end

function M:RefreshTopView(store)
	local popularityStore = gStoreManager:GetStoreGroup(store.popularityWidget.Store):GetStoreByWidget(store.popularityWidget)
	popularityStore.guideComp.targetScrollableWidget = self.bindData.mainPhoneList
	popularityStore.guideComp.targetMaskWidget = self.bindData.mainPhoneList
	popularityStore.fansCount = gClientUtils.FormatWithThousandsSeparator(gPlayerManager.infoMinor.bindData.fan123)
	popularityStore.popularityValue = gSocialNetworkUtils.GetCurrentPopularityValue()
	popularityStore.button.luaClick = self:CreateAction(self.OnInspireHubClick)
	self.InspirePopularityUI = self.InspirePopularityUI or C_InspirePopularityUI.new()

	self.InspirePopularityUI:RenderInspirePopularityChart(popularityStore.popularityWidget, true)

	store.expandControl = 1

	return popularityStore
end

function M:OnBottomAppRenderItem(btn, csIndex)
	local luaIndex = csIndex + 1
	local data = self.bottomAppDataList[luaIndex]

	self:OnSinglePhoneAppRenderItem(btn, csIndex, data)
end

function M:RefreshIndividualizationFansView(store)
	local decorationId = self.skinInfo and self.skinInfo.decorationId
	local skinPartCfg = LTConfig.MobileMenuSkinPartConfig.GetConfig(decorationId)
	local decorationIndex = skinPartCfg and skinPartCfg.DecorationTabIndex or 0
	local tabUrlList = store.tabRect.TabUrlList

	if skinPartCfg and skinPartCfg.HasWeatherSkin then
		local tabUrl = tabUrlList[decorationIndex]
		local isNightTime = gMainPhoneUtils.CheckIsNightTime()
		local dir = tabUrl:match("(.*/)") or ""
		local prefabName = tabUrl:match("([^/]+)$")

		if isNightTime then
			if not prefabName:find("_night%.prefab$") then
				prefabName = prefabName:gsub("%.prefab$", "_night.prefab")
			end
		else
			prefabName = prefabName:gsub("_night%.prefab$", ".prefab")
		end

		local newPrefabPath = dir .. prefabName
		tabUrlList[decorationIndex] = System.String(newPrefabPath)
	end

	store.tabRect.OnRenderTab = self:CreateAction(self.OnIndividualizationRenderItem)

	if self.bindData.wallPaperNodeActive then
		store.tabRect:ResetAllTabInstances()
	end

	store.tabRect.selectedIndex = decorationIndex
end

function M:OnIndividualizationRenderItem(csIndex, widget)
	local storeName = widget.Store
	local store = gStoreManager:GetStoreGroup(storeName):GetStoreByWidget(widget)
	self.individualizationWidget = widget
	self.individualizationStore = store
	local ownMoney = gUIUtils:GetMoneyByType(UX.Game.MoneyType.Money) or 0
	store.coinCount = ownMoney
	store.button.luaClick = self:CreateAction(self.OnIndividualizationClick)

	self:RefreshIndividualizationFansCount()

	if csIndex == 9 then
		local imageList = {
			"S_vx_PhoneFans_SaimoA",
			"S_vx_PhoneFans_SaimoB",
			"S_vx_PhoneFans_SaimoC",
			"S_vx_PhoneFans_SaimoD",
			"S_vx_PhoneFans_SaimoE",
			"S_vx_PhoneFans_SaimoF"
		}
		local imageIndex = math.random(1, #imageList)
		local targetImage = imageList[imageIndex]
		local textureUrl = ("Assets/Res/SGUI/Texture/MainPhoneIcon/%s.png"):format(targetImage)

		store.image:SetPropertyTexture(textureUrl, "_MainTex")
	end
end

function M:RefreshIndividualizationFansCount()
	self.individualizationStore.fansCount = gPlayerManager.infoMinor.bindData.fan123
end

function M:OnIndividualizationClick()
	if not self:CheckCanClick() then
		return
	end

	gHunLunManager:OpenPersonalInfoPanel()
end

function M:RefreshBubbleFansView(store)
	store.fansCount = 0

	gHunLunManager:InitPersonalInfo(nil, function ()
		if self.hasDestroy or not gHunLunManager.roleInfo then
			return
		end

		store.fansCount = gHunLunManager.roleInfo.fanCount
	end)

	store.archiveButton.luaClick = self:CreateAction(self.OnArchiveClick)
end

function M:OnPopularityClick()
	if not self:CheckCanClick() then
		return
	end

	gMainPhoneFunctionAction.OpenSocialNetwork()
end

function M:OnInspireHubClick()
	if not self:CheckCanClick() then
		return
	end

	gMainPhoneFunctionAction.OpenInspireHub()
end

function M:OnArchiveClick()
	gHunLunManager:OpenPersonalInfoPanel()
end

function M:OnPhoneListOnScroll(_)
	local targetPage = self.bindData.mainPhoneList:GetNearestPageIndex()

	self.bindData.pageList:SelectItem(targetPage)
end

function M:OnExitPreviewSkinModeClick(_)
	if not self:CheckCanClick() then
		return
	end

	self:OnExitPreviewSkinMode()
end

function M:OnExitPreviewSkinMode()
	gMessageManager:SendMessage(gEventConstants.ON_EXIT_PREVIEW_SKIN_MODE)

	self.previewSkinPartId = nil
	self.bindData.wallPaperNodeActive = false
	self.skinInfo = gMainPhoneUtils.GetCurrentSpiritSkinInfo()

	self:RefreshPanelView()

	if self.lastPreviewPageIndex then
		self.bindData.mainPhoneList:GoToPage(self.lastPreviewPageIndex, true)

		self.lastPreviewPageIndex = nil
	end
end

function M:OnEnterPreviewSkinMode(_, args)
	gClientUtils.FinishAnimation(self.bindData.panelAnimation, "S_Vx_MainPhonePanel_open")
	gClientUtils.FinishAnimation(self.bindData.panelAnimation, "S_Vx_MainPhonePanel_BacktoMain")

	self.bindData.previewSkinControl = 1
	self.bindData.wallPaperNodeActive = true
	self.lastPreviewPageIndex = self.bindData.pageList.selectedIndex

	self.bindData.mainPhoneList:GoToPage(0, true)

	local isAvailable = gMainPhoneUtils.CheckSkinPartAvailable(args.skinPartId)
	local isApply = gMainPhoneUtils.CheckIsApplySkinPart(args.skinPartId)
	self.bindData.applySkinButton.interactable = isAvailable and not isApply
	self.previewSkinPartId = args.skinPartId
	local targetWallPaperId, targetDecorationId, targetPendantId = gMainPhoneUtils.GetTargetSkinIds(self.previewSkinPartId)
	self.skinInfo.wallPaperId = targetWallPaperId or self.skinInfo.wallPaperId
	self.skinInfo.decorationId = targetDecorationId or self.skinInfo.decorationId
	self.skinInfo.pendantId = targetPendantId or self.skinInfo.pendantId

	self:RefreshPanelView()
end

function M:OnResetSkinView()
	self.skinInfo = gMainPhoneUtils.GetCurrentSpiritSkinInfo()

	self:RefreshPanelView()
end

function M:OnSpiritSkinPartChange()
	self.skinInfo = gMainPhoneUtils.GetCurrentSpiritSkinInfo()

	self:RefreshPanelView()
end

function M:OnMainPhonePageChange(_, targetIndex)
	targetIndex = targetIndex or 0

	self.bindData.mainPhoneList:GoToPage(targetIndex, true)
end

function M:OnApplySkinClick()
	local rootGo = self.rootGo
	local targetWallPaperId, targetDecorationId, targetPendantId = gMainPhoneUtils.GetTargetSkinIds(self.previewSkinPartId)

	gMainPhoneUtils.AskSetMobileSkinPart({
		wallPaperId = targetWallPaperId,
		decorationId = targetDecorationId,
		pendantId = targetPendantId,
		callback = function ()
			if gClientUtils.NotNil(rootGo) then
				self.bindData.wallPaperNodeActive = false
				self.skinInfo = gMainPhoneUtils.GetCurrentSpiritSkinInfo()

				self:RefreshPanelView()
				gMessageManager:SendMessage(gEventConstants.ON_EXIT_PREVIEW_SKIN_MODE)
				gMainPhoneUtils.ApplySkinPartSuccess({
					ignoreBackToMainAnimation = true
				})
			end
		end
	})
end

function M:OnSinglePhoneAppRenderItem(btn, csIndex, data)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	btn.gameObject.name = ("S_PhoneIconTemplate_%d"):format(csIndex)
	btn.interactable = gMainPhoneUtils.CheckAppCanInteractable(data.id)
	local appId = data.id
	local mobileMenuSGuiCfg = LTConfig.MobileMenuSGuiConfig.GetConfig(appId)
	store.name = mobileMenuSGuiCfg.Name
	store.iconId = self:GetAppIconId(appId)
	store.guideComp.guideID = mobileMenuSGuiCfg.GuideId
	store.guideComp.targetScrollableWidget = self.bindData.mainPhoneList
	store.guideComp.targetMaskWidget = self.bindData.mainPhoneList
	store.downloadControl = self:GetAppDownloadState(appId)
	local redCfg = PanelRedDotConfig.GetConfig(mobileMenuSGuiCfg.RedDotId)
	local redDotKey = ""

	if redCfg then
		store.button.redId = mobileMenuSGuiCfg.RedDotId
	else
		redDotKey = ("PhoneAppItemRedDot:%d"):format(appId)
		store.button.redKey = redDotKey

		gMainPhoneUtils.RefreshAppItemRedDot(appId, redDotKey)
	end

	if store.playDownloadAnimationId and store.playDownloadAnimationId ~= appId then
		store.playDownloadAnimCo = coroutine.stop(store.playDownloadAnimCo)
		store.playDownloadAnimationId = nil
	end

	function store.button.luaClick()
		self:OnPhoneAppClick(store, appId, {
			isFromMainPhone = true,
			fromPosition = btn.transform.position,
			mainPhonePageIndex = self.bindData.pageList.selectedIndex
		})
	end
end

function M:OnPhoneAppClick(store, appId, args)
	if not self:CheckCanClick() then
		return
	end

	if store.downloadAnimation then
		if store.downloadAnimation.isPlaying then
			return
		end

		if store.downloadControl == self.DownloadControl.Before then
			local rootGo = self.rootGo

			gClientToGameDelegate:AskPhoneAppDownload(appId).Callback = function (err)
				if err ~= LTConfig.MessageConfig.Ok then
					gDisplayMessageMgr:DisplayServerMessageId(err)

					return
				end

				table.insert(gPlayerManager.infoMinor.bindData.downLoadAppIds, appId)

				if gClientUtils.IsNil(rootGo) then
					return
				end

				store.downloadControl = self.DownloadControl.After
				local time = gCS.LuaUtils.PlayAnimationByName(store.downloadAnimation, "S_Vx_PhoneIconTemplate_downloading")
				store.playDownloadAnimCo = coroutine.stop(store.playDownloadAnimCo)
				store.playDownloadAnimationId = appId
				store.playDownloadAnimCo = coroutine.start(function ()
					coroutine.wait(time)

					store.playDownloadAnimationId = nil
					store.playDownloadAnimCo = nil
				end)
			end

			return
		end
	end

	local animationName = "S_Vx_MainPhonePanel_OpenAPP"
	local result = gMainPhoneUtils.OnAppItemClick(appId, args)

	if result then
		gClientUtils.ResetAnimation(self.bindData.panelAnimation, animationName)
		gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnimation, animationName)
	end
end

function M:GetAppIconId(appId)
	local mobileMenuSGuiCfg = LTConfig.MobileMenuSGuiConfig.GetConfig(appId)
	local iconId = mobileMenuSGuiCfg.SIconId

	if appId == LTConfig.MobileMenuSGuiConfig.TeamId then
		if gLinkManager.LinkMode == UX.Game.LinkMode.Private then
			iconId = 28002468
		elseif gLinkManager.LinkMode == UX.Game.LinkMode.Public or gLinkManager.LinkMode == UX.Game.LinkMode.Match then
			iconId = 28002467
		end
	end

	return iconId
end

function M:CheckCanClick()
	if self.isClickCdIng then
		return false
	end

	self:StartIsClickCdIng()

	return true
end

function M:StartIsClickCdIng()
	self.isClickCdIng = true

	LX6.Manager.GameInputManager.SetDisableInput(self.panelId, true, true, false)

	self.clickCdCo = coroutine.stop(self.clickCdCo)
	self.clickCdCo = coroutine.start(function ()
		coroutine.wait(0.4)

		self.isClickCdIng = false

		LX6.Manager.GameInputManager.SetEnableInput(self.panelId, true, true, true)
	end)
end

function M:GetAppDownloadState(appId)
	local mobileMenuSGuiCfg = LTConfig.MobileMenuSGuiConfig.GetConfig(appId)

	if mobileMenuSGuiCfg.IsLoading then
		local downLoadAppIds = gPlayerManager.infoMinor.bindData.downLoadAppIds or {}

		for _, downloadAppId in ipairs(downLoadAppIds) do
			if downloadAppId == appId then
				return self.DownloadControl.After
			end
		end

		return self.DownloadControl.Before
	end

	return self.DownloadControl.After
end

function M:PlayBackToMainAnimation()
	local animationName = "S_Vx_MainPhonePanel_BacktoMain"

	gClientUtils.ResetAnimation(self.bindData.panelAnimation, animationName)
	gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnimation, animationName)
end

function M:OnPanelClose(_, panelId)
	local panelCfg = LTConfig.PanelConfig.GetConfig(panelId)

	if panelCfg and panelCfg.isFullScreen then
		gClientUtils.FinishAnimation(self.bindData.panelAnimation, "S_Vx_MainPhonePanel_BacktoMain")
	end
end

function M:ClearData()
	gClientUtils.FinishAnimation(self.bindData.panelAnimation, "S_Vx_MainPhonePanel_BacktoMain")
	LX6.Manager.GameInputManager.SetEnableInput(self.panelId, true, true, true)

	self.mainPhoneListBtnIndexDict = nil
	self.mainPhoneListBtn = nil
	self.refreshPopularityCo = coroutine.stop(self.refreshPopularityCo)
	self.clickCdCo = coroutine.stop(self.clickCdCo)

	self:ClearDataSetEvents()

	if self.InspirePopularityUI then
		self.InspirePopularityUI = self.InspirePopularityUI:Destroy()
	end
end
