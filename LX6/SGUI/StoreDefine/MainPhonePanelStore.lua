-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\MainPhonePanelStore.lua
-- Decompiled from: 01966_MainPhonePanelStore.lua_52018c9ca27a.luajit

local PanelRedDotConfig = LTConfig.PanelRedDotConfig
C_MainPhonePanelStore = DefClass("C_MainPhonePanelStore", C_MainPhonePanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.MainPhonePanelStore = C_MainPhonePanelStore
local M = C_MainPhonePanelStore

dofile("LX6/SGUI/StoreDefine/MainPhonePanelStore_NavigateComp")

M.OnAwake = function(self)
	self.bindData.mainPhoneList.luaSimpleRenderItem = self:CreateAction("OnPhoneRenderItem")
	self.bindData.bottomList.luaSimpleRenderItem = self:CreateAction("OnBottomAppRenderItem")
	self.bindData.exitPreviewSkinButton.luaClick = self:CreateAction("OnExitPreviewSkinModeClick")
	self.bindData.applySkinButton.luaClick = self:CreateAction("OnApplySkinClick")

	gMessageManager:SendMessage(gEventConstants.ASK_MAILS_BRIEF_INFO)
	self:InitDataSetEvents()
end

M.InitDataSetEvents = function(self)
end

M.GetMessageEvents = function(self)
	return {
		[gEventConstants.LANGUAGE_CHANGE] = self.CreateAction(self, "RefreshPanelView"),
		[gEventConstants.SYSTEM_UNLOCK_STATE_CHANGE] = self.CreateAction(self, "OnMainPhoneViewDataChanged"),
		[gEventConstants.UPDATE_UNREAD_MSG_TIPS] = self.CreateAction(self, "RefreshPanelView"),
		[gEventConstants.REFRESH_MAIN_BUTTON_RED_POT] = self.CreateAction(self, "RefreshPanelView"),
		[gEventConstants.ADJUST_WORLD_LEVEL] = self.CreateAction(self, "RefreshPanelView"),
		[gEventConstants.PALYER_LEVEL_UP] = self.CreateAction(self, "RefreshPanelView"),
		[gEventConstants.SYNC_CURRENT_SPIRIT] = self.CreateAction(self, "OnMainPhoneViewDataChanged"),
		[gEventConstants.ON_PLAYER_FAN_CHANGE] = self.CreateAction(self, "RefreshPanelView"),
		[gEventConstants.JOB_CHANGE_EVENT] = self.CreateAction(self, "OnMainPhoneViewDataChanged"),
		[gEventConstants.ON_ENTER_PREVIEW_SKIN_MODE] = self.CreateAction(self, "OnEnterPreviewSkinMode"),
		[gEventConstants.ON_MAIN_PHONE_SKIN_RESET] = self.CreateAction(self, "OnResetSkinView"),
		[gEventConstants.ON_SYNC_SPIRIT_SKIN_PART_INFO_CHANGE] = self.CreateAction(self, "OnSpiritSkinPartChange"),
		[gEventConstants.ON_MAIN_PHONE_PAGE_CHANGE] = self.CreateAction(self, "OnMainPhonePageChange"),
		[gEventConstants.ON_LEVEL_REWARD_UPDATE] = self.CreateAction(self, "RefreshPanelView"),
		[gEventConstants.PANEL_ON_CLOSE] = self.CreateAction(self, "OnPanelClose"),
		[gEventConstants.LINK_MODE_CHANGE] = self.CreateAction(self, "OnMainPhoneViewDataChanged"),
		[gEventConstants.AGENT_PROFILE_RED_POINT_REFRESH] = self.CreateAction(self, "RefreshPanelView"),
		[gEventConstants.ON_PHONE_CALL_STATE_CHANGE] = self.CreateAction(self, "RefreshPanelView"),
		[gEventConstants.ON_EXIT_WALL_PAPER_PREVIEW_MODE] = self.CreateAction(self, "OnExitPreviewSkinMode"),
		[gEventConstants.ON_HACKER_APP_REDPOINT_CHANGE] = self.CreateAction(self, "RefreshPanelView"),
		[gEventConstants.ON_PHONE_APP_HOME_HIDE] = self.CreateAction(self, "OnExit"),
		[gEventConstants.ON_PHONE_APP_INSTALL_STATE_CHANGE] = self.CreateAction(self, "OnMainPhoneViewDataChanged"),
		[gEventConstants.ON_PLAYER_POPULARITY_CHANGE] = self.CreateAction(self, "RefreshPopularityView")
	}
end

M.InitModel = function(self, args)
	M.base.InitModel(self, args)

	self.isClickCdIng = nil
	self.panelId = args.panelId
	self.ShowControl = {
		["R+y^"] = 1,
		["I*rL"] = 0
	}
	self.DownloadControl = {
		[">M\\x97\\x81\\x91D"] = 1,
		["l\\xa8\\xb6\\xaa\\xa4"] = 0
	}
	self.UninstallControl = {
		["/"] = 1,
		["\\xa1n`"] = 0
	}
	self.uninstallMode = false
	self.skinInfo = gMainPhoneUtils.GetCurrentSpiritSkinInfo()
end

M.InitView = function(self, args)
	M.base.InitView(self, args)

	self.uninstallMode = false
	self.bindData.wallPaperNodeActive = false
	self.refreshIndividualizationView = true

	self.rootWidget:SetActive(true)
	self:InitBackgroundButton()

	self.isPreLoad = args and args.preLoad
	self.bindData.mainPhoneList.forceSyncInstantiate = self.isPreLoad ~= true
	self.bindData.bottomList.forceSyncInstantiate = self.isPreLoad ~= true

	gClientUtils.FinishAnimation(self.bindData.panelAnimation, "S_Vx_MainPhonePanel_BacktoMain")
	SGUI.ExtensionMethod.RefreshPlayingAnimation(self.bindData.panelAnimation)
	gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnimation, "S_Vx_MainPhonePanel_open")

	self.onSetToPoolCallback = self:CreateAction("OnSetToPoolCallback")

	self.bindData.mainPhoneList:UnRegisterToSetToPoolEvent(self.onSetToPoolCallback)
	self.bindData.mainPhoneList:RegisterToSetToPoolEvent(self.onSetToPoolCallback)
	self:showAllDownloadDonePopup()
	self:RebuildContentList(0)

	self.onPhoneListOnScroll = self.onPhoneListOnScroll or self:CreateAction("OnPhoneListOnScroll")

	self.bindData.mainPhoneList:UnRegisterToScrollEvent(self.onPhoneListOnScroll)
	self.bindData.mainPhoneList:RegisterToScrollEvent(self.onPhoneListOnScroll)
end

M.InitBackgroundButton = function(self)
	self.waitInitBackgroundCo = coroutine.stop(self.waitInitBackgroundCo)
	self.waitInitBackgroundCo = coroutine.start(function ()
		coroutine.step()

		local backGroundInstance = self.bindData.mainPhoneList.backgroundInstance

		if backGroundInstance then
			local button = backGroundInstance.GetComponent(backGroundInstance, "UButton")

			if button then
				button.luaClick = self:CreateAction("OnBackGroundClick")
			end
		end
	end)
end

M.OnBackGroundClick = function(self)
	if not self.uninstallMode then
		return
	end

	self.SetUninstallMode(self, false)
end

M.OnSetToPoolCallback = function(self, tIndex, widget)
	self:GetNavigateComp():OnSetToPoolCallback(tIndex, widget)

	widget.gameObject.name = "AppItem"
end

M.OnMainPhoneViewDataChanged = function(self)
	self.RebuildContentList(self)
end

M.RebuildContentList = function(self, targetPage)
	local mainPhoneViewDataList, pageViewDataList, totalPageCount = gMainPhoneUtils.GetMainPhoneViewDataList()
	targetPage = targetPage or self.bindData.mainPhoneList:GetNearestPageIndex()
	targetPage = Mathf.Clamp(targetPage, 0, totalPageCount - 1)
	self.mainPhoneViewDataList = mainPhoneViewDataList

	self.bindData.mainPhoneList.onGetTIndex = function(csIndex)
		local luaIndex = csIndex + 1
		local data = self.mainPhoneViewDataList[luaIndex]

		return data.tIndex
	end

	local navigateComp = self:GetNavigateComp()

	navigateComp:SetDisable(false)
	navigateComp:BeforeSetSimpleList(mainPhoneViewDataList)
	self.bindData.mainPhoneList:SetSimpleList(#mainPhoneViewDataList)
	self.bindData.pageList:SetSimpleList(#pageViewDataList)
	self.bindData.mainPhoneList:GoToPage(targetPage, true)
	self.bindData.pageList:SelectItem(targetPage)

	self.bottomAppDataList = gMainPhoneUtils.GetBottomPhoneAppViewDataList()

	self.bindData.bottomList:SetSimpleList(#self.bottomAppDataList)

	self.bindData.fansCount = gPlayerManager.infoMinor.bindData.fan123
	self.bindData.showDotCtrl = totalPageCount <= 1 and self.ShowControl.Show or self.ShowControl.Hide

	self:RefreshIndividualizationView()
	self:ApplyPendingFocusAfterUninstall()
end

M.PrepareReturnFromApp = function(self, appId)
	self.rootWidget:SetActive(true)

	local mainPhoneList = self.bindData.mainPhoneList
	local forceSyncInstantiate = mainPhoneList.forceSyncInstantiate
	mainPhoneList.forceSyncInstantiate = true

	self:RebuildContentList()

	mainPhoneList.forceSyncInstantiate = forceSyncInstantiate

	return self:GetNavigateComp():FocusApp(appId)
end

M.showAllDownloadDonePopup = function(self)
	if self.downloadDonePopupMap then
		for appId, downloadDonePopupCo in pairs(self.downloadDonePopupMap) do
			coroutine.stop(downloadDonePopupCo)

			local downloadPopupId, downloadPopupData = self:GetDownloadDonePopUpData(appId)

			gNewPopupManager:PushPopup(downloadPopupId, downloadPopupData)
		end

		self.downloadDonePopupMap = nil
	end
end

M.RefreshPanelView = function(self)
	if gClientUtils.IsNil(self.rootGo) then
		return
	end

	local hasUnlocked = gMainPhoneUtils.CheckMainPhoneTopButtonUnlocked()

	self.bindData.topFakeNavButton:SetActive(hasUnlocked)
	self.bindData.mainPhoneList:SetSimpleList(#self.mainPhoneViewDataList)
	self.bindData.bottomList:RefreshList()
	self:RefreshIndividualizationView()
end

M.RefreshPopularityView = function(self)
	if gClientUtils.IsNil(self.rootGo) or not self.mainPhoneViewDataList then
		return
	end

	self.bindData.mainPhoneList:SetSimpleList(#self.mainPhoneViewDataList)
end

M.RefreshIndividualizationView = function(self)
	local wallPaperId = self.skinInfo and self.skinInfo.wallPaperId
	local skinPartCfg = LTConfig.MobileMenuSkinPartConfig.GetConfig(wallPaperId)
	local colorControlValue = skinPartCfg and skinPartCfg.WallpaperColorIndex or 0
	local backgroundImageId = 0

	if wallPaperId == LTConfig.MobileMenuSkinPartConfig.DefaultWallPaper and skinPartCfg then
		backgroundImageId = skinPartCfg.IconId2 <= 0 and skinPartCfg.IconId2 or skinPartCfg.IconId
	end

	self.bindData.colorControl = colorControlValue
	self.bindData.blurActive = false
	self.bindData.backgroundImageId = backgroundImageId
	self.bindData.blurBackgroundImageId = 0

	self:RefreshPendantView()
end

M.RefreshPendantView = function(self)
	local rootStoreGroupName = self.panelArgs and self.panelArgs.store
	local phoneAppHomePanelStore = gStoreManager:GetStoreGroup(rootStoreGroupName)

	if phoneAppHomePanelStore and gClientUtils.NotNil(phoneAppHomePanelStore.rootGo) then
		local pendantId = self.skinInfo and self.skinInfo.pendantId
		local skinPartCfg = LTConfig.MobileMenuSkinPartConfig.GetConfig(pendantId)
		local skinPendantIndex = 0

		if pendantId == LTConfig.MobileMenuSkinPartConfig.DefaultPendant and skinPartCfg then
			skinPendantIndex = skinPartCfg.PendantTabRectIndex
		end

		phoneAppHomePanelStore.bindData.skinPendantTabRect:ResetAllTabInstances()
		phoneAppHomePanelStore.bindData.skinPendantTabRect:SelectIndexWithClose(skinPendantIndex)
	end
end

M.ResetAppItem = function(self, btn)
	local root = btn.transform:Find("Root")

	if root then
		if btn.Store ~= "PhoneFansRootStore" then
			root.transform.localPosition = Vector3.Fetch(8.4, 2.5, 0)
			root.transform.localScale = Vector3.one
		else
			root.transform.localPosition = Vector3.zero
			root.transform.localScale = Vector3.one
		end
	end
end

M.OnPhoneRenderItem = function(self, btn, csIndex)
	self:ResetAppItem(btn)

	local luaIndex = csIndex + 1
	local data = self.mainPhoneViewDataList[luaIndex]
	local storeName = btn.Store
	local store = gStoreManager:GetStoreGroup(storeName):GetStoreByWidget(btn)

	if data.tIndex ~= gClientConst.MainPhoneTemplateType.FourAppTIndex then
		if store.appList ~= nil then
			print_error("MainPhonePanelStore OnPhoneRenderItem: store.appList is nil, storeName=", storeName, "csIndex=", csIndex, "btn=", gUtils.GetFindPath(btn, self.rootWidget))

			return
		end

		btn.gameObject.name = "S_4IconTemplate(Clone)"

		store.appList.luaSimpleRenderItem = function(childBtn, childCsIndex)
			self:ResetAppItem(childBtn)

			local childLuaIndex = childCsIndex + 1
			local childData = data.appList[childLuaIndex]

			self:SetMainPhoneBtnList(luaIndex, childBtn, childLuaIndex)
			self:GetNavigateComp():OnRenderItem(childBtn, -childCsIndex, childData)
			self:OnSinglePhoneAppRenderItem(childBtn, childCsIndex, childData)
		end

		store.appList:SetSimpleList(#data.appList)
	elseif data.tIndex ~= gClientConst.MainPhoneTemplateType.SingleAppTIndex then
		self:SetMainPhoneBtnList(luaIndex, btn)
		self:GetNavigateComp():OnRenderItem(btn, csIndex, data)
		self:OnSinglePhoneAppRenderItem(btn, csIndex, data)

		local hasUnlockedTopButton = gMainPhoneUtils.CheckMainPhoneTopButtonUnlocked()

		if hasUnlockedTopButton then
			if csIndex < 10 then
				btn.gameObject.name = ("S_PhoneIconTemplate_%d"):format(csIndex)
			else
				btn.gameObject.name = ("ListPhoneIconTemplate_%d"):format(csIndex)
			end
		elseif csIndex < 13 then
			btn.gameObject.name = ("S_PhoneIconTemplate_%d"):format(csIndex + 1)
		else
			btn.gameObject.name = ("ListPhoneIconTemplate_%d"):format(csIndex)
		end
	elseif data.tIndex ~= gClientConst.MainPhoneTemplateType.FansIndex then
		self.RefreshBubbleFansView(self, store)
		self.SetMainPhoneBtnList(self, luaIndex, btn)
	elseif data.tIndex ~= gClientConst.MainPhoneTemplateType.IndividualizationFansIndex then
		self.RefreshIndividualizationFansView(self, store)
		self.SetMainPhoneBtnList(self, luaIndex, self.individualizationWidget)
	elseif data.tIndex ~= gClientConst.MainPhoneTemplateType.TopButton then
		local popularityStore = self.RefreshTopView(self, btn)

		if popularityStore then
			self.SetMainPhoneBtnList(self, luaIndex, popularityStore.button)
		end
	end

	if data.tIndex == gClientConst.MainPhoneTemplateType.SingleAppTIndex then
		self:GetNavigateComp():OnRenderItem(btn, csIndex, data)
	end
end

M.SetMainPhoneBtnList = function(self, index, btn, subIndex)
	local navigateComp = self.GetNavigateComp(self)
	btn.luaFocus = self.CreateActionWithArgs(self, navigateComp.OnButtonFocus, btn, navigateComp)
end

M.RefreshTopView = function(self, btn)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store.popularityWidget then
		print_error("@linminghe RefreshTopView error, store.popularityWidget is nil", btn.gameObject.name, btn.Store)

		return
	end

	local popularityStore = gStoreManager:GetStoreGroup(store.popularityWidget.Store):GetStoreByWidget(store.popularityWidget)
	popularityStore.guideComp.targetScrollableWidget = self.bindData.mainPhoneList
	popularityStore.guideComp.targetMaskWidget = self.bindData.mainPhoneList
	popularityStore.fansCount = gClientUtils.FormatWithThousandsSeparator(gPlayerManager.infoMinor.bindData.fan123)
	popularityStore.popularityValue = gSocialNetworkUtils.GetCurrentPopularityValue()
	popularityStore.upCtrl = gHotCenterManager:GetPopularityGainSpeedCtrl()
	popularityStore.button.luaClick = self:CreateAction(self.OnInspireHubClick)
	popularityStore.button.redKey = ""
	self.InspirePopularityUI = self.InspirePopularityUI or C_InspirePopularityUI.new()

	self.InspirePopularityUI:RenderInspirePopularityChart(popularityStore.popularityWidget, true)
	gHotCenterManager:RenderMainPhoneSevenDaysPopularityData(btn)
	gHotCenterManager.RenderFansData(store.fansWidget)

	store.expandControl = 1
	store.modeCtrl = gClientUtils.CheckIsLinkMode() and 2 or 0
	store.oldPopularity = tostring(gHotCenterManager:GetYesterdayPopularityEarnings())
	local canPlaySettlementAnim = not self.isPreLoad and not self.hasDestroy

	gHotCenterManager:RenderPhonePopularitySettlementAnim(store, canPlaySettlementAnim, popularityStore)

	return popularityStore
end

M.OnBottomAppRenderItem = function(self, btn, csIndex)
	local luaIndex = csIndex + 1
	local data = self.bottomAppDataList[luaIndex]

	self.OnSinglePhoneAppRenderItem(self, btn, csIndex, data)
end

M.RefreshIndividualizationFansView = function(self, store)
	self.individualizationStore = store

	if gClientUtils.IsNil(store.tabRect) then
		return
	end

	local decorationId = self.skinInfo and self.skinInfo.decorationId
	local skinPartCfg = LTConfig.MobileMenuSkinPartConfig.GetConfig(decorationId)
	local useShopDecoration = decorationId ~= LTConfig.MobileMenuSkinPartConfig.DefaultDecoration and gMainPhoneUtils.CheckUseShopDecoration()
	local decorationIndex = nil

	if useShopDecoration then
		decorationIndex = LTConfig.MobileMenuConfig.ShopDecorationIndex
	elseif skinPartCfg then
		decorationIndex = skinPartCfg.DecorationTabIndex
	else
		decorationIndex = 0
	end

	local tabUrlList = store.tabRect.TabUrlList
	local isSamePrefabUrl = true

	if skinPartCfg and skinPartCfg.HasWeatherSkin and not useShopDecoration then
		local tabUrl = tabUrlList[decorationIndex]
		local isNightTime = gMainPhoneUtils.CheckIsNightTime()
		local dir = tabUrl:match("(.*/)") or ""
		local prefabName = tabUrl:match("([^/]+)$")

		if isNightTime then
			if not prefabName.find(prefabName, "_night%.prefab$") then
				prefabName = prefabName.gsub(prefabName, "%.prefab$", "_night.prefab")
			end
		else
			prefabName = prefabName.gsub(prefabName, "_night%.prefab$", ".prefab")
		end

		local newPrefabPath = dir .. prefabName
		isSamePrefabUrl = newPrefabPath ~= tabUrl
		tabUrlList[decorationIndex] = System.String(newPrefabPath)
	end

	store.tabRect.OnRenderTab = self.CreateAction(self, self.OnIndividualizationRenderItem)

	if store.tabRect.selectedIndex ~= decorationIndex then
		if isSamePrefabUrl then
			if self.refreshIndividualizationView then
				local exist, widget = store.tabRect:TryGetTabInstance(decorationIndex, nil)

				if exist then
					local animation = widget.GetComponent(widget, "Animation")

					if animation then
						if decorationIndex ~= 9 then
							self.SetSaimoRandomImage(self, widget)
						end

						gCS.LuaUtils.PlayAnimationByName(animation, animation.clip.name)
					end

					if useShopDecoration then
						local appId = LTConfig.MobileMenuSGuiConfig.ShopId
						local mobileMenuSGuiCfg = LTConfig.MobileMenuSGuiConfig.GetConfig(appId)

						if mobileMenuSGuiCfg then
							local redCfg = PanelRedDotConfig.GetConfig(mobileMenuSGuiCfg.RedDotId)

							if redCfg then
								widget.redId = mobileMenuSGuiCfg.RedDotId

								gMainPhoneUtils.RefreshAppItemRedDot(appId)
							end
						end
					end
				end
			end
		else
			store.tabRect.selectedIndex = -1

			store.tabRect:ClearUnusedTabInstances()

			store.tabRect.selectedIndex = decorationIndex
		end
	else
		store.tabRect.selectedIndex = decorationIndex
	end

	self.refreshIndividualizationView = nil
end

M.OnIndividualizationRenderItem = function(self, csIndex, widget)
	local storeName = widget.Store
	local store = gStoreManager:GetStoreGroup(storeName):GetStoreByWidget(widget)
	self.individualizationWidget = widget
	self.individualizationStore = store
	local ownMoney = gUIUtils:GetMoneyByType(UX.Game.MoneyType.Money) or 0
	store.coinCount = ownMoney

	if widget.guide then
		widget.guide.targetScrollableWidget = self.bindData.mainPhoneList
		widget.guide.targetMaskWidget = self.bindData.mainPhoneList
	end

	store.button.luaClick = self.CreateAction(self, self.OnIndividualizationClick)

	self.RefreshIndividualizationFansCount(self)

	if csIndex ~= 9 then
		self.SetSaimoRandomImage(self, widget)
	end

	local animation = widget.GetComponent(widget, "Animation")

	if animation then
		gCS.LuaUtils.PlayAnimationByName(animation, animation.clip.name)
	end
end

M.SetSaimoRandomImage = function(self, widget)
	local store = gStoreManager:GetStoreGroup(widget.Store):GetStoreByWidget(widget)
	local imageList = {
		"<\t\\xa2\\xf8 !|:\\xb05'ޣ\\xa62\\x90\\x9aƯ",
		"<\t\\xa2\\xf8 !|:\\xb05'ޣ\\xa62\\x90\\x9aƬ",
		"<\t\\xa2\\xf8 !|:\\xb05'ޣ\\xa62\\x90\\x9aƭ",
		"<\t\\xa2\\xf8 !|:\\xb05'ޣ\\xa62\\x90\\x9aƪ",
		"<\t\\xa2\\xf8 !|:\\xb05'ޣ\\xa62\\x90\\x9aƫ",
		"<\t\\xa2\\xf8 !|:\\xb05'ޣ\\xa62\\x90\\x9aƨ"
	}
	local textureUrl = ("Assets/Res/SGUI/Vfx/Texture/%s.png"):format(imageList[math.random(1, #imageList)])

	store.image:SetPropertyTexture(textureUrl, "_MainTex")
end

M.RefreshIndividualizationFansCount = function(self)
	self.individualizationStore.fansCount = gPlayerManager.infoMinor.bindData.fan123
end

M.OnIndividualizationClick = function(self)
	if not self.CheckCanClick(self) then
		return
	end

	if not gSystemUnlockMgr:IsUnlock(LTConfig.SystemUnlockConfig.MallPanel) then
		return
	end

	gMallSceneManager:WarmupSceneById(gMallManager:GetRecommendFirstSceneId())
	gPanelManager:CheckShow(gPanelId.SHOP_HOME_PAGE)
end

M.RefreshBubbleFansView = function(self, store)
	store.fansCount = 0

	gHunLunManager:InitPersonalInfo(nil, function ()
		if self.hasDestroy or not gHunLunManager.roleInfo then
			return
		end

		store.fansCount = gHunLunManager.roleInfo.fanCount
	end)

	store.archiveButton.luaClick = self:CreateAction(self.OnArchiveClick)
end

M.OnPopularityClick = function(self)
	if not self.CheckCanClick(self) then
		return
	end

	gMainPhoneFunctionAction.OpenSocialNetwork()
end

M.OnInspireHubClick = function(self)
	if not self.CheckCanClick(self) then
		return
	end

	gMainPhoneFunctionAction.OpenInspireHub()
end

M.OnArchiveClick = function(self)
	gHunLunManager:OpenPersonalInfoPanel()
end

M.OnPhoneListOnScroll = function(self, _)
	local targetPage = self.bindData.mainPhoneList:GetNearestPageIndex()

	self.bindData.pageList:SelectItem(targetPage)
end

M.OnExitPreviewSkinModeClick = function(self, _)
	if self.isClickCdIng then
		return
	end

	self.OnExitPreviewSkinMode(self)
end

M.OnExitPreviewSkinMode = function(self)
	self.isEnterPreviewSkinMode = false
	self.previewSkinPartId = nil
	self.bindData.wallPaperNodeActive = false
	self.skinInfo = gMainPhoneUtils.GetCurrentSpiritSkinInfo()

	self:RefreshPanelView()
	self:GetNavigateComp():OnExitPreviewSkinMode()
	gMessageManager:SendMessage(gEventConstants.ON_EXIT_PREVIEW_SKIN_MODE)
end

M.OnEnterPreviewSkinMode = function(self, _, args)
	self.isEnterPreviewSkinMode = true

	gClientUtils.FinishAnimation(self.bindData.panelAnimation, "S_Vx_MainPhonePanel_open")
	gClientUtils.FinishAnimation(self.bindData.panelAnimation, "S_Vx_MainPhonePanel_BacktoMain")

	self.bindData.previewSkinControl = 1
	self.bindData.wallPaperNodeActive = true

	self:GetNavigateComp():OnEnterPreviewSkinMode()
	self.bindData.mainPhoneList:GoToPage(0, true)

	local isAvailable = gMainPhoneUtils.CheckSkinPartAvailable(args.skinPartId)
	local isApply = gMainPhoneUtils.CheckIsApplySkinPart(args.skinPartId)
	self.bindData.applySkinButton.interactable = isAvailable and not isApply
	self.previewSkinPartId = args.skinPartId
	local skinPartCfg = LTConfig.MobileMenuSkinPartConfig.GetConfig(args.skinPartId)

	if skinPartCfg.Type ~= LTConfig.MobileMenuSkinPartConfig.TypeType.Decoration or skinPartCfg.Type ~= LTConfig.MobileMenuSkinPartConfig.TypeType.Suit then
		self.refreshIndividualizationView = true
	end

	local targetWallPaperId, targetDecorationId, targetPendantId = gMainPhoneUtils.GetTargetSkinIds(self.previewSkinPartId)
	self.skinInfo.wallPaperId = targetWallPaperId or self.skinInfo.wallPaperId
	self.skinInfo.decorationId = targetDecorationId or self.skinInfo.decorationId
	self.skinInfo.pendantId = targetPendantId or self.skinInfo.pendantId

	self:RefreshPanelView()
end

M.OnResetSkinView = function(self)
	self.skinInfo = gMainPhoneUtils.GetCurrentSpiritSkinInfo()

	self.RefreshPanelView(self)
end

M.OnSpiritSkinPartChange = function(self)
	self.skinInfo = gMainPhoneUtils.GetCurrentSpiritSkinInfo()

	self.RefreshPanelView(self)
end

M.OnMainPhonePageChange = function(self, _, targetIndex)
	targetIndex = targetIndex or 0

	self.bindData.mainPhoneList:GoToPage(targetIndex, true)
end

M.OnApplySkinClick = function(self)
	local rootGo = self.rootGo

	if self.previewSkinPartId then
		local targetWallPaperId, targetDecorationId, targetPendantId = gMainPhoneUtils.GetTargetSkinIds(self.previewSkinPartId)

		gMainPhoneUtils.AskSetMobileSkinPart({
			wallPaperId = targetWallPaperId,
			decorationId = targetDecorationId,
			pendantId = targetPendantId,
			callback = function ()
				if gClientUtils.NotNil(rootGo) then
					self:OnExitPreviewSkinMode()
					gMainPhoneUtils.ApplySkinPartSuccess({
						["Ef\\xf9J\\xd6\\xfc\\xd0n?\\xff\\J\\xd6\\xf1q\\xf3E|\\xdf\\xdd\\xfeɕ\\xfdj"] = true
					})
				end
			end
		})
	end
end

M.OnSinglePhoneAppRenderItem = function(self, btn, csIndex, data)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	btn.gameObject.name = ("S_PhoneIconTemplate_%d"):format(csIndex)
	btn.interactable = gMainPhoneUtils.CheckAppCanInteractable(data.id)
	local appId = data.id
	local mobileMenuSGuiCfg = LTConfig.MobileMenuSGuiConfig.GetConfig(appId)
	store.name = mobileMenuSGuiCfg.Name
	store.iconId = gMainPhoneUtils.GetAppIconId(appId)
	store.guideComp.guideID = self.isEnterPreviewSkinMode and 0 or mobileMenuSGuiCfg.GuideId
	store.guideComp.targetScrollableWidget = self.bindData.mainPhoneList
	store.guideComp.targetMaskWidget = self.bindData.mainPhoneList
	store.downloadControl = self:GetAppDownloadState(appId)
	local redCfg = PanelRedDotConfig.GetConfig(mobileMenuSGuiCfg.RedDotId)

	if redCfg then
		btn.redId = mobileMenuSGuiCfg.RedDotId

		gMainPhoneUtils.RefreshAppItemRedDot(appId)
	end

	if store.playDownloadAnimationId and store.playDownloadAnimationId == appId then
		store.playDownloadAnimCo = coroutine.stop(store.playDownloadAnimCo)
		store.playDownloadAnimationId = nil
	end

	store.button.luaClick = function()
		self:OnPhoneAppClick(store, appId, {
			["*9\\xf6|\\x95\\xda5\\xa1!\\xd6\\xfa\\xe9z\\xfe"] = true,
			fromPosition = btn.transform.position,
			mainPhonePageIndex = self.bindData.pageList.selectedIndex
		})
	end

	if store.uninstallBtn then
		store.button.luaLongPress = self.CreateActionWithArgs(self, "OnPhoneAppLongPress", appId)
		store.uninstallBtn.luaClick = self.CreateActionWithArgs(self, "OnClickIconUninstallBtn", appId)

		self.RefreshIconUninstallCtrl(self, store, appId)
	end
end

M.RefreshIconUninstallCtrl = function(self, store, appId)
	local showUninstall = self.uninstallMode and gAppStoreUtils.IsAppRemovable(appId)
	store.isUninstallCtrl = showUninstall and self.UninstallControl.On or self.UninstallControl.Off

	if not store.uninstallAnimation then
		return
	end

	if self.uninstallMode then
		store.uninstallAnimation:Stop("S_Vx_PhoneIconTemplate_loop")
		store.uninstallAnimation:Play("S_Vx_PhoneIconTemplate_loop")
	else
		gClientUtils.ResetAnimation(store.uninstallAnimation, "S_Vx_PhoneIconTemplate_loop")
	end
end

M.OnPhoneAppLongPress = function(self, appId)
	self.SetUninstallMode(self, true)
end

M.SetUninstallMode = function(self, on)
	if self.uninstallMode ~= on then
		return
	end

	self.uninstallMode = on

	self.bindData.mainPhoneList:SetSimpleList(#self.mainPhoneViewDataList)
end

M.OnClickIconUninstallBtn = function(self, appId)
	local navComp = self.GetNavigateComp(self)
	local appIndex = navComp.appId2Index[appId]
	local nextAppId, previousAppId = nil

	if gClientUtils.IsControllerMode() and appIndex then
		for candidateAppId, candidateIndex in pairs(navComp.appId2Index) do
			if candidateAppId <= 0 then
				if candidateIndex ~= appIndex + 1 then
					nextAppId = candidateAppId
				elseif candidateIndex ~= appIndex - 1 then
					previousAppId = candidateAppId
				end
			end
		end
	end

	local focusAppId = nextAppId or previousAppId

	if focusAppId then
		self.pendingFocusAfterUninstall = {
			removedAppId = appId,
			focusAppId = focusAppId
		}
	end

	gAppStoreUtils.AskUninstallApp(appId)
end

M.ApplyPendingFocusAfterUninstall = function(self)
	local pending = self.pendingFocusAfterUninstall
	self.pendingFocusAfterUninstall = nil

	if not pending or not gClientUtils.IsControllerMode() then
		return
	end

	local navComp = self.GetNavigateComp(self)

	if navComp.appId2Index[pending.removedAppId] == nil then
		return
	end

	if navComp.appId2Index[pending.focusAppId] ~= nil then
		return
	end

	navComp.FocusApp(navComp, pending.focusAppId)
end

M.PlayDesktopDownloadAnim = function(self, store, appId)
	if not store.downloadAnimation or store.downloadAnimation.isPlaying then
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

	self.ShowDownloadDonePopup(self, appId, time)
end

M.TryPlayAppDesktopDownload = function(self, store, appId)
	if not store.downloadAnimation then
		return false
	end

	if store.downloadAnimation.isPlaying then
		return true
	end

	if store.downloadControl == self.DownloadControl.Before then
		return false
	end

	local rootGo = self.rootGo
	slot4 = gClientToGameDelegate

	slot4:AskPhoneAppDownload(appId).Callback = function (err)
		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		table.insert(gPlayerManager.infoMinor.bindData.downLoadAppIds, appId)

		if gClientUtils.IsNil(rootGo) then
			return
		end

		self:PlayDesktopDownloadAnim(store, appId)
	end

	return true
end

M.ForcePlayAppDesktopDownload = function(self, store, appId)
	if store.downloadControl ~= self.DownloadControl.Before then
		self.TryPlayAppDesktopDownload(self, store, appId)
	else
		self.PlayDesktopDownloadAnim(self, store, appId)
	end
end

M.LocateAndDownloadApp = function(self, appId, delay)
	local locateAndPlay = function()
		local btn = self:GetNavigateComp():FocusApp(appId)

		if gClientUtils.IsNil(btn) then
			return
		end

		local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

		if store then
			self:ForcePlayAppDesktopDownload(store, appId)
		end
	end

	delay = delay or 0

	if delay < 0 then
		locateAndPlay()

		return
	end

	self.locateDownloadCo = coroutine.stop(self.locateDownloadCo)
	self.locateDownloadCo = coroutine.start(function ()
		coroutine.wait(delay)

		self.locateDownloadCo = nil

		locateAndPlay()
	end)
end

M.OnPhoneAppClick = function(self, store, appId, args)
	if self.uninstallMode then
		return
	end

	if not self.CheckCanClick(self) then
		return
	end

	if self.TryPlayAppDesktopDownload(self, store, appId) then
		return
	end

	local animationName = "S_Vx_MainPhonePanel_OpenAPP"

	gMainPhoneUtils.OnAppItemClick(appId, args, function (result)
		if result then
			gClientUtils.ResetAnimation(self.bindData.panelAnimation, animationName)
			gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnimation, animationName)
		end
	end)
end

M.ShowDownloadDonePopup = function(self, appId, time)
	local mobileMenuSGuiCfg = LTConfig.MobileMenuSGuiConfig.GetConfig(appId)

	if mobileMenuSGuiCfg.DownloadDonePopupId and mobileMenuSGuiCfg.DownloadDonePopupId <= 0 then
		self.downloadDonePopupMap = self.downloadDonePopupMap or {}
		self.downloadDonePopupMap[appId] = coroutine.start(function ()
			coroutine.wait(time)

			self.downloadDonePopupMap[appId] = nil
			local downloadPopupId, downloadPopupData = self:GetDownloadDonePopUpData(appId)

			gNewPopupManager:PushPopup(downloadPopupId, downloadPopupData)
		end)
	end
end

M.GetDownloadDonePopUpData = function(self, appId)
	local mobileMenuSGuiCfg = LTConfig.MobileMenuSGuiConfig.GetConfig(appId)
	local iconId = gMainPhoneUtils.GetAppIconId(appId)
	local downloadPopupData = {
		PopupPic = iconId,
		PopupName = mobileMenuSGuiCfg.Name
	}

	return mobileMenuSGuiCfg.DownloadDonePopupId, downloadPopupData
end

M.CheckCanClick = function(self)
	if self.isClickCdIng then
		return false
	end

	self.StartIsClickCdIng(self)

	return true
end

M.StartIsClickCdIng = function(self)
	self.isClickCdIng = true

	LX6.Manager.GameInputManager.SetDisableInput(self.panelId, true, true, false)

	self.clickCdCo = coroutine.stop(self.clickCdCo)
	self.clickCdCo = coroutine.start(function ()
		coroutine.wait(0.4)

		self.isClickCdIng = false

		LX6.Manager.GameInputManager.SetEnableInput(self.panelId, true, true, true)
	end)
end

M.GetAppDownloadState = function(self, appId)
	local mobileMenuSGuiCfg = LTConfig.MobileMenuSGuiConfig.GetConfig(appId)

	if mobileMenuSGuiCfg.IsLoading then
		local downLoadAppIds = gPlayerManager.infoMinor.bindData.downLoadAppIds or {}

		for _, downloadAppId in ipairs(downLoadAppIds) do
			if downloadAppId ~= appId then
				return self.DownloadControl.After
			end
		end

		return self.DownloadControl.Before
	end

	return self.DownloadControl.After
end

M.PlayBackToMainAnimation = function(self)
	self.uninstallMode = false

	self.bindData.mainPhoneList:RefreshLogicList()

	local animationName = "S_Vx_MainPhonePanel_BacktoMain"

	gClientUtils.ResetAnimation(self.bindData.panelAnimation, animationName)
	gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnimation, animationName)
end

M.GetNavigateComp = function(self)
	if self.navigateComp ~= nil then
		self.navigateComp = C_MainPhonePanelStore_NavigateComp.new(self)
	end

	return self.navigateComp
end

M.OnPanelClose = function(self, _, panelId)
	local panelCfg = LTConfig.PanelConfig.GetConfig(panelId)

	if panelCfg and panelCfg.isFullScreen then
		gClientUtils.FinishAnimation(self.bindData.panelAnimation, "S_Vx_MainPhonePanel_BacktoMain")
	end
end

M.OnDestroy = function(self)
	self.locateDownloadCo = coroutine.stop(self.locateDownloadCo)
	self.navigateComp = self.navigateComp and self.navigateComp:Destroy()

	M.base.OnDestroy(self)
end

M.ClearData = function(self)
	self.waitInitBackgroundCo = coroutine.stop(self.waitInitBackgroundCo)
	self.refreshIndividualizationView = nil
	self.isPreLoad = nil
	self.isEnterPreviewSkinMode = false
	self.pendingFocusAfterUninstall = nil

	gClientUtils.FinishAnimation(self.bindData.panelAnimation, "S_Vx_MainPhonePanel_BacktoMain")
	LX6.Manager.GameInputManager.SetEnableInput(self.panelId, true, true, true)

	self.clickCdCo = coroutine.stop(self.clickCdCo)

	self:ClearMessageEvents()
	self:GetNavigateComp():SetDisable(true)

	if self.InspirePopularityUI then
		self.InspirePopularityUI = self.InspirePopularityUI:Destroy()
	end
end

M.OnLanguageChange = function(self, lang)
end
