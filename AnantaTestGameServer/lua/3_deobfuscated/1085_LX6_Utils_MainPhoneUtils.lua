local GameConfig = LTConfig.GameConfig
local MobileMenuSGuiConfig = LTConfig.MobileMenuSGuiConfig
local M = {}

function M.GetPhoneAppIdList()
	local phoneAppIdList = {}
	local appCount = MobileMenuSGuiConfig.count

	for i = 0, appCount - 1 do
		local mobileSGuiMenuCfg = MobileMenuSGuiConfig.LoadAt(i)

		if not mobileSGuiMenuCfg.IsBottom and M.CheckAppCanShow(mobileSGuiMenuCfg.Id) then
			table.insert(phoneAppIdList, mobileSGuiMenuCfg.Id)
		end
	end

	M.SortPhoneAppIdList(phoneAppIdList)

	return phoneAppIdList
end

function M.SortPhoneAppIdList(phoneAppIdList)
	table.sort(phoneAppIdList, function (id1, id2)
		local mobileSGuiMenuCfg1 = MobileMenuSGuiConfig.GetConfig(id1)
		local mobileSGuiMenuCfg2 = MobileMenuSGuiConfig.GetConfig(id2)
		local rank1 = mobileSGuiMenuCfg1.Rank
		local rank2 = mobileSGuiMenuCfg2.Rank

		if rank1 ~= rank2 then
			return rank1 < rank2
		end

		return id1 < id2
	end)
end

function M.GetMainPhoneViewDataList()
	local viewDataList = {}
	local topViewData = M.GetTopViewData()

	if topViewData then
		table.insert(viewDataList, topViewData)
	end

	local levelUpViewData = M.GetLevelUpViewData()
	local phoneAppViewDataList = M.GetPhoneAppViewDataList()

	table.insert(viewDataList, levelUpViewData)
	array.concat(viewDataList, phoneAppViewDataList)

	local pageViewDataList, totalPageCount = M.GetMainPhonePageViewDataList(phoneAppViewDataList, topViewData ~= nil)

	return viewDataList, pageViewDataList, totalPageCount
end

function M.GetMainPhonePageViewDataList(phoneAppViewDataList, isTopViewShow)
	local firstPageAppCount = isTopViewShow and 9 or 13
	local otherPageAppCount = 16
	local totalAppCount = #phoneAppViewDataList
	local totalPageCount = nil

	if totalAppCount <= firstPageAppCount then
		totalPageCount = 1
	else
		totalPageCount = math.ceil((totalAppCount - firstPageAppCount) / otherPageAppCount) + 1
	end

	local pageViewDataList = {}

	for pageIndex = 1, totalPageCount do
		table.insert(pageViewDataList, {
			id = pageIndex,
			selected = pageIndex == 1
		})
	end

	return pageViewDataList, totalPageCount
end

function M.GetTopViewData()
	local topButtonUnlocked = M.CheckMainPhoneTopButtonUnlocked()

	if topButtonUnlocked then
		return {
			tIndex = gClientConst.MainPhoneTemplateType.TopButton
		}
	end
end

function M.GetLevelUpViewData()
	if gGmUtils.isEnableMainPhoneFansView then
		return {
			tIndex = gClientConst.MainPhoneTemplateType.FansIndex
		}
	else
		return {
			tIndex = gClientConst.MainPhoneTemplateType.IndividualizationFansIndex
		}
	end
end

function M.GetPhoneAppViewDataList()
	local viewDataList = {}
	local phoneAppIdList = M.GetPhoneAppIdList()
	local phoneAppCount = table.count(phoneAppIdList)
	local showFourthAppCount = 4
	local maxIndex = math.min(phoneAppCount, showFourthAppCount)
	local fourthAppViewList = {}

	for index = 1, maxIndex do
		local appId = phoneAppIdList[index]

		table.insert(fourthAppViewList, {
			id = appId
		})
	end

	table.insert(viewDataList, {
		tIndex = gClientConst.MainPhoneTemplateType.FourAppTIndex,
		appList = fourthAppViewList
	})

	if showFourthAppCount < phoneAppCount then
		for index = showFourthAppCount + 1, phoneAppCount do
			local appId = phoneAppIdList[index]

			table.insert(viewDataList, {
				tIndex = gClientConst.MainPhoneTemplateType.SingleAppTIndex,
				id = appId
			})
		end
	end

	return viewDataList
end

function M.CheckAppCanShow(appId)
	local mobileSGuiMenuCfg = MobileMenuSGuiConfig.GetConfig(appId)

	if not mobileSGuiMenuCfg then
		return false
	end

	if not mobileSGuiMenuCfg.IsShow then
		return false
	end

	local panelId = gPanelId[mobileSGuiMenuCfg.PanelId]
	local hideAppPanelIdList = GameConfig.HideMainCubeApps or {}

	if table.contains(hideAppPanelIdList, panelId) then
		return false
	end

	local npcCultivationIdList = mobileSGuiMenuCfg.NpcCultivationIdList
	local lockedNpcCultivationIdList = mobileSGuiMenuCfg.LockNpcCultivationIdList
	local npcCultivationId = M.GetNpcCultivationId()

	if npcCultivationIdList and #npcCultivationIdList > 0 and not table.find(npcCultivationIdList, npcCultivationId) then
		return false
	end

	if not table.isNilOrEmpty(lockedNpcCultivationIdList) and table.find(lockedNpcCultivationIdList, npcCultivationId) then
		return false
	end

	if mobileSGuiMenuCfg.TemporaryNpcConfig then
		local firstSpiritTid = gSpiritManager:GetCurFirstSpiritTid()

		if not gSpiritManager:GetSpirit(firstSpiritTid) then
			return false
		end

		local cfg = LTConfig.FightSpiritConfig.GetConfig(firstSpiritTid)

		if cfg.Invisible then
			return false
		end
	end

	if not M.CheckJobCanShow(appId) then
		return false
	end

	local hasAppSystemUnlocked = M.CheckAppSystemUnlocked(appId)
	local canUse = M.CheckAppCanUse(appId)

	return hasAppSystemUnlocked and canUse
end

function M.CheckJobCanShow(appId)
	local mobileSGuiMenuCfg = MobileMenuSGuiConfig.GetConfig(appId)
	local jobClassIdList = mobileSGuiMenuCfg.JobClassIdList

	if jobClassIdList and #jobClassIdList > 0 then
		local availableJobIdList = gSpiritJobManager.GetCurSpiritAvailableJobIdList()

		for _, jobId in ipairs(availableJobIdList) do
			local urbanJobCfg = LTConfig.UrbanJobConfig.GetConfig(jobId)
			local jobClassId = urbanJobCfg and urbanJobCfg.JobClass or 0

			if table.contains(jobClassIdList, jobClassId) then
				return true
			end
		end

		return false
	end

	return true
end

function M.CheckAppSystemUnlocked(appId)
	local mobileSGuiMenuCfg = MobileMenuSGuiConfig.GetConfig(appId)
	local systemIdList = mobileSGuiMenuCfg.SystemIdList

	if not systemIdList or #systemIdList == 0 then
		return true
	end

	for _, systemId in ipairs(systemIdList) do
		if gSystemUnlockMgr:IsUnlock(systemId) then
			return true
		end
	end

	return false
end

function M.GetBottomPhoneAppIdList()
	local bottomPhoneAppIdList = {}
	local appCount = MobileMenuSGuiConfig.count

	for i = 0, appCount - 1 do
		local mobileSGuiMenuCfg = MobileMenuSGuiConfig.LoadAt(i)

		if mobileSGuiMenuCfg.IsBottom and M.CheckAppCanShow(mobileSGuiMenuCfg.Id) then
			table.insert(bottomPhoneAppIdList, mobileSGuiMenuCfg.Id)
		end
	end

	M.SortPhoneAppIdList(bottomPhoneAppIdList)

	return bottomPhoneAppIdList
end

function M.GetBottomPhoneAppViewDataList()
	local bottomPhoneAppIdList = M.GetBottomPhoneAppIdList()
	local viewDataList = {}

	for _, appId in ipairs(bottomPhoneAppIdList) do
		table.insert(viewDataList, {
			id = appId
		})
	end

	return viewDataList
end

function M.OnAppItemClick(appId, args)
	if appId == MobileMenuSGuiConfig.ShopId then
		gMainPhoneFunctionAction.OpenShoppingMall()
	elseif appId == MobileMenuSGuiConfig.ChatId then
		gMainPhoneFunctionAction.OpenChat(args)
	elseif appId == MobileMenuSGuiConfig.AchivementId then
		gMainPhoneFunctionAction.OpenAchievement()
	elseif appId == MobileMenuSGuiConfig.LingListId then
		gMainPhoneFunctionAction.OpenLingList()
	elseif appId == MobileMenuSGuiConfig.BaiKeId then
		gMainPhoneFunctionAction.OpenBaiKeArchive()
	elseif appId == MobileMenuSGuiConfig.TaskId then
		gMainPhoneFunctionAction.OpenTask()
	elseif appId == MobileMenuSGuiConfig.TeachingId then
		gMainPhoneFunctionAction.OpenTeaching()
	elseif appId == MobileMenuSGuiConfig.PackageId then
		gMainPhoneFunctionAction.OpenPackage()
	elseif appId == MobileMenuSGuiConfig.SocialMediaId then
		gMainPhoneFunctionAction.OpenSocialMedia(args)
	elseif appId == MobileMenuSGuiConfig.UberSimId then
		gMainPhoneFunctionAction.OpenUberSim(args)
	elseif appId == MobileMenuSGuiConfig.SocialNetworkId then
		gMainPhoneFunctionAction.OpenSocialNetwork(args)
	elseif appId == MobileMenuSGuiConfig.TeamId then
		gMainPhoneFunctionAction.OpenTeam()
	elseif appId == MobileMenuSGuiConfig.TimeId then
		gMainPhoneFunctionAction.OpenTime(args)
	elseif appId == MobileMenuSGuiConfig.Hacker then
		gMainPhoneFunctionAction.OpenHackerApp(args)
	elseif appId == MobileMenuSGuiConfig.PoliceId then
		gMainPhoneFunctionAction.OpenPolice(args)
	elseif appId == MobileMenuSGuiConfig.DeliveryGuideId then
		gMainPhoneFunctionAction.OpenDeliveryGuidePanel(args)
	elseif appId == MobileMenuSGuiConfig.Waper then
		gMainPhoneFunctionAction.OpenWallPaperPanel(args)
	elseif appId == MobileMenuSGuiConfig.Washer then
		gMainPhoneFunctionAction.OpenWasher(args)
	elseif appId == MobileMenuSGuiConfig.AnnouncementId then
		gMainPhoneFunctionAction.OpenNotice()
	elseif appId == MobileMenuSGuiConfig.ChaosMasterId then
		gMainPhoneFunctionAction.OpenChaosMasterCharacterPanel()
	elseif appId == MobileMenuSGuiConfig.MessageId then
		gMainPhoneFunctionAction.OpenMessage(args)
	elseif appId == MobileMenuSGuiConfig.RecordId then
		gMainPhoneFunctionAction.OpenAgentProfile()
	elseif appId == MobileMenuSGuiConfig.TalentTreeId then
		gMainPhoneFunctionAction.OpenTalentTree()
	elseif appId == MobileMenuSGuiConfig.WeaponId then
		gMainPhoneFunctionAction.OpenWeaponArmory()
	elseif appId == MobileMenuSGuiConfig.PoliceArchive then
		gMainPhoneFunctionAction.OpenPoliceArchive()
	elseif appId == MobileMenuSGuiConfig.NoticeId then
		gMainPhoneFunctionAction.OpenNotice()
	elseif appId == MobileMenuSGuiConfig.SettingId then
		gMainPhoneFunctionAction.OpenSetting()
	elseif appId == MobileMenuSGuiConfig.TakePhotoId then
		return gMainPhoneFunctionAction.OpenTakePhoto()
	elseif appId == MobileMenuSGuiConfig.EmailId then
		gMainPhoneFunctionAction.OpenEmail()
	elseif appId == MobileMenuSGuiConfig.CallPhoneId then
		gMainPhoneFunctionAction.OpenCallPhone(args)
	elseif appId == MobileMenuSGuiConfig.InspireHub then
		gMainPhoneFunctionAction.OpenInspireHub(args)
	elseif appId == MobileMenuSGuiConfig.Interaction then
		gPanelManager:CheckShow(gPanelId.CHAR_MOTION_LIST_PANEL)
	elseif appId == MobileMenuSGuiConfig.Party then
		gMainPhoneFunctionAction.OpenParty(args)
	elseif appId == MobileMenuSGuiConfig.Feedback then
		gMainPhoneFunctionAction.OpenFeedback(args)
	elseif appId == MobileMenuSGuiConfig.Activity then
		return gAwardActivityManager:OpenActivity()
	end

	return true
end

function M.CheckAppCanUse(appId)
	if appId == MobileMenuSGuiConfig.PackageId then
		return gUIFunctionStateManager:GetPackageEnable()[2]
	elseif appId == MobileMenuSGuiConfig.LingListId then
		return gUIFunctionStateManager:GetXuWeiEnable()[2]
	elseif appId == MobileMenuSGuiConfig.TeamId then
		return gLinkManager:CheckCanCreateLink()
	elseif appId == MobileMenuSGuiConfig.TalentTreeId then
		return gTalentTreeMgr:CheckHasTalentTree()
	elseif appId == MobileMenuSGuiConfig.Activity then
		return gAwardActivityManager:CheckHasActivity()
	end

	return true
end

function M.RefreshAppItemRedDot(appId, redDotKey)
	M.GetAppHasRedDot(appId, function (hasRedDot)
		SGUI.RedDotMgr.LuaSetRedDot(hasRedDot, redDotKey)
	end)
end

function M.GetAppHasRedDot(appId, callback)
	if appId == MobileMenuSGuiConfig.ChatId then
		gRedDotUtils.CheckChatHasRedDot(callback)
	elseif appId == MobileMenuSGuiConfig.SocialNetworkId then
		callback(gClientUtils.CheckHasLevelReward())
	elseif appId == MobileMenuSGuiConfig.RecordId then
		callback(gAgentTrustManager:CheckAnyHasRewardCanGot())
	elseif appId == MobileMenuSGuiConfig.Hacker then
		callback(gHackManager.hasHackerJobRedDot)
	elseif appId == MobileMenuSGuiConfig.PoliceId then
		callback(gPoliceJobManager.panelMgr:CheckHasAward())
	elseif appId == MobileMenuSGuiConfig.MessageId then
		gRedDotUtils.CheckNpcChatHasRedDot(callback)
	elseif appId == MobileMenuSGuiConfig.BaiKeId then
		callback(gBaiKeArchiveManager.CheckPlayFashionPanelHasRedDot())
	else
		local mobileSGuiMenuCfg = MobileMenuSGuiConfig.GetConfig(appId)

		if mobileSGuiMenuCfg and mobileSGuiMenuCfg.PanelId then
			local panelId = gPanelId[mobileSGuiMenuCfg.PanelId]
			local hasRedDot = gRedPointMgr:IsPanelHasRedPoint(panelId)

			callback(hasRedDot)
		else
			callback(false)
		end
	end
end

function M.CheckMainPhoneHasRedDot(callback)
	local appIdList = M.GetPhoneAppIdList()
	local bottomAppIdList = M.GetBottomPhoneAppIdList()
	local totalAppIdList = array.concat(appIdList, bottomAppIdList)
	local totalAppCount = #totalAppIdList
	local checkedAppCount = 0
	local foundRedDot = false

	for _, appId in ipairs(totalAppIdList) do
		M.GetAppHasRedDot(appId, function (hasRedDot)
			checkedAppCount = checkedAppCount + 1

			if hasRedDot then
				foundRedDot = true

				callback(true)

				return
			end

			if checkedAppCount == totalAppCount and not foundRedDot then
				callback(false)
			end
		end)

		if foundRedDot then
			break
		end
	end
end

function M.ShowPhoneAppContent(args)
	local panelId = gClientUtils.GetMainPhonePanelId()

	if gPanelManager:IsPanelShowing(panelId) then
		gMessageManager:SendMessage(gEventConstants.ON_PHONE_APP_HOME_CONTENT_SHOW, args)
	else
		gPanelManager:CheckShow(panelId, args)
	end
end

function M.IsFakePhoneExist()
	if gClientUtils.IsMainPhoneExist() then
		local phoneAppHomePanelStore = M.GetPhoneAppHomePanelStore()
		local mainTabRect = phoneAppHomePanelStore.bindData.mainTabRect

		return gClientUtils.NotNil(mainTabRect) and mainTabRect.selectedIndex == gClientConst.MainHomeType.FakePhone
	end
end

function M.GetSelectedIndex()
	local phoneAppHomePanelStore = M.GetPhoneAppHomePanelStore()

	return phoneAppHomePanelStore.bindData.tabRect.selectedIndex
end

function M.GetNpcCultivationId(spiritId)
	spiritId = spiritId or gBattleSpiritMgr.currentSpiritTemplateId
	local count = LTConfig.NpcCultivationConfig.count
	local npcCultivationCfgId = nil

	for i = 0, count - 1 do
		local npcCultivationCfg = LTConfig.NpcCultivationConfig.LoadAt(i)

		if npcCultivationCfg.FightSpiritID == spiritId then
			npcCultivationCfgId = npcCultivationCfg.Id

			break
		end
	end

	return npcCultivationCfgId
end

function M.ShowFrontContent(args)
	local phoneAppHomePanelStore = M.GetPhoneAppHomePanelStore()

	if phoneAppHomePanelStore then
		phoneAppHomePanelStore:ShowFrontContent(args)
	end
end

function M.GetPhoneAppHomePanelStore()
	return gStoreManager:GetStoreGroup("PhoneAppHomePanelStore")
end

function M.CloseFrontContent()
	gMessageManager:SendMessage(gEventConstants.ON_CLOSE_PHONE_APP_CONFIRM_PANEL)
end

function M.GetSkinPartViewDataList(showType)
	local viewDataList = {}
	local count = LTConfig.MobileMenuSkinPartConfig.count

	for i = 0, count - 1 do
		local skinPartCfg = LTConfig.MobileMenuSkinPartConfig.LoadAt(i)

		if skinPartCfg.Type == showType then
			table.insert(viewDataList, {
				id = skinPartCfg.Id
			})
		end
	end

	return viewDataList
end

function M.CloseMainPhonePanel(isForce)
	isForce = isForce ~= false

	gMessageManager:SendMessage(gEventConstants.ON_CLOSE_MAIN_PHONE_PANEL, isForce)
end

function M.GetCurrentSpiritSkinInfo()
	local spiritId = gBattleSpiritMgr.currentSpiritTemplateId
	local spiritViewInfo = gSpiritManager:GetSpirit(spiritId)

	if spiritViewInfo and spiritViewInfo.SpiritInfo then
		local spiritInfo = spiritViewInfo.SpiritInfo

		if spiritInfo.MobileSkinInfo then
			local skinInfo = {
				wallPaperId = spiritInfo.MobileSkinInfo.Wallpaper,
				decorationId = spiritInfo.MobileSkinInfo.Decoration,
				pendantId = spiritInfo.MobileSkinInfo.Pendant
			}
			skinInfo.wallPaperId = skinInfo.wallPaperId > 0 and skinInfo.wallPaperId or LTConfig.MobileMenuSkinPartConfig.DefaultWallPaper
			skinInfo.decorationId = skinInfo.decorationId > 0 and skinInfo.decorationId or LTConfig.MobileMenuSkinPartConfig.DefaultDecoration
			skinInfo.pendantId = skinInfo.pendantId > 0 and skinInfo.pendantId or LTConfig.MobileMenuSkinPartConfig.DefaultPendant

			return skinInfo
		end
	end

	return {
		wallPaperId = LTConfig.MobileMenuSkinPartConfig.DefaultWallPaper,
		decorationId = LTConfig.MobileMenuSkinPartConfig.DefaultDecoration,
		pendantId = LTConfig.MobileMenuSkinPartConfig.DefaultPendant
	}
end

function M.CheckSkinPartAvailable(targetSkinPartId)
	local availableSkinParts = gPlayerManager.infoSpirit.bindData.AvailableSkinParts or {}
	local realAvailableSkinParts = {}
	local npcCultivationId = gMainPhoneUtils.GetNpcCultivationId()
	local count = LTConfig.MobileMenuSkinConfig.count

	for i = 0, count - 1 do
		local skinCfg = LTConfig.MobileMenuSkinConfig.LoadAt(i)

		if skinCfg.NpcCultivatitonId == npcCultivationId then
			local skinPartCfg = LTConfig.MobileMenuSkinPartConfig.GetConfig(skinCfg.SuitId)

			table.insert(realAvailableSkinParts, skinCfg.SuitId)
			table.insert(realAvailableSkinParts, skinPartCfg.Wallpaper)
			table.insert(realAvailableSkinParts, skinPartCfg.Decoration)
			table.insert(realAvailableSkinParts, skinPartCfg.Pendant)

			break
		end
	end

	local availableSkinPartMap = {}

	for _, skinPartId in ipairs(availableSkinParts) do
		table.insert(realAvailableSkinParts, skinPartId)

		local skinPartCfg = LTConfig.MobileMenuSkinPartConfig.GetConfig(skinPartId)

		if skinPartCfg.Type == gClientConst.WALL_PAPER_HOME_TAB_TYPE.Suit then
			table.insert(realAvailableSkinParts, skinPartCfg.Wallpaper)
			table.insert(realAvailableSkinParts, skinPartCfg.Decoration)
			table.insert(realAvailableSkinParts, skinPartCfg.Pendant)
		end

		availableSkinPartMap[skinPartId] = true
	end

	local sinPartCount = LTConfig.MobileMenuSkinPartConfig.count

	for i = 0, sinPartCount - 1 do
		local skinPartCfg = LTConfig.MobileMenuSkinPartConfig.LoadAt(i)

		if skinPartCfg.Type == gClientConst.WALL_PAPER_HOME_TAB_TYPE.Suit and availableSkinPartMap[skinPartCfg.Wallpaper] and availableSkinPartMap[skinPartCfg.Decoration] and availableSkinPartMap[skinPartCfg.Pendant] then
			table.insert(realAvailableSkinParts, skinPartCfg.Id)
		end
	end

	for _, skinPartId in ipairs(realAvailableSkinParts) do
		if skinPartId == targetSkinPartId then
			return true
		end
	end

	return false
end

function M.AskSetMobileSkinPart(args)
	local wallPaperId = args.wallPaperId
	local decorationId = args.decorationId
	local pendantId = args.pendantId
	local callback = args.callback

	gClientToGameDelegate:AskSetMobileSkinPart(wallPaperId, decorationId, pendantId).Callback = function (errorId)
		if errorId ~= LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end

		local tips = LTConfig.TextScriptTextConfig.GetConfig(89901166).Text

		gDisplayMessageMgr:ShowMessageContent(tips)

		if callback then
			callback()
		end
	end
end

function M.AskResetMobileSkinPart(callback)
	gClientToGameDelegate:AskResetMobileSkinPart().Callback = function (errorId)
		if errorId ~= LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end

		local tips = LTConfig.TextScriptTextConfig.GetConfig(89901167).Text

		gDisplayMessageMgr:ShowMessageContent(tips)

		if callback then
			callback()
		end
	end
end

function M.ApplySkinPartSuccess(args)
	gMessageManager:SendMessage(gEventConstants.ON_CLOSE_WALL_PAPER_APP, args)
end

function M.OnExecuteSkinPartReset(rootGo)
	gMainPhoneUtils.ShowFrontContent({
		showType = gClientConst.MAIN_PHONE_FRONT_SHOW_TYPE.ConfirmMessageBox,
		description = LTConfig.TextScriptTextConfig.GetConfig(89901165).Text,
		onConfirmCallback = function ()
			gMainPhoneUtils.AskResetMobileSkinPart(function ()
				if gClientUtils.NotNil(rootGo) then
					gMainPhoneUtils.ApplySkinPartSuccess()
				end
			end)
		end
	})
end

function M.GetCurrentSpiritSkinId()
	local currentSpiritId = gBattleSpiritMgr.currentSpiritTemplateId
	local count = LTConfig.MobileMenuSkinConfig.count

	for i = 0, count - 1 do
		local skinCfg = LTConfig.MobileMenuSkinConfig.LoadAt(i)
		local npcCultivationCfg = LTConfig.NpcCultivationConfig.GetConfig(skinCfg.NpcCultivatitonId)
		local fightSpiritId = npcCultivationCfg and npcCultivationCfg.FightSpiritID

		if fightSpiritId == currentSpiritId then
			return skinCfg.Id
		end
	end
end

function M.CheckYanJieIsFullScreen()
	return true
end

function M.CheckFansSystemUnlocked()
	return gSystemUnlockMgr:IsUnlock(LTConfig.SystemUnlockConfig.FansDisplayUnlock)
end

function M.CheckMainPhoneTopButtonUnlocked()
	return gInspireHubManager:IsUnlock()
end

function M.CheckAppCanInteractable(appId)
	if appId == MobileMenuSGuiConfig.CallPhoneId then
		return not gCallPhoneUtils.CheckPhoneCallConflict()
	elseif appId == MobileMenuSGuiConfig.TeamId then
		return gLinkManager.LinkMode ~= UX.Game.LinkMode.Match
	end

	return true
end

function M.SetSGUIGlobalBarVisible(isVisible)
	local globalBar = GameObject.Find("SGUIRoot/Canvas/GlobalBar")

	if globalBar then
		globalBar.transform.localScale = isVisible and Vector3.one or Vector3.zero
	end
end

function M.CheckIsDayTime()
	local gameTime = LX6.Manager.AtmosphereManager.Instance:GetGameTime()
	local hour = math.floor(gameTime / gClientConst.SECONDS_PER_HOUR)

	return hour >= 7 and hour < 19
end

function M.CheckIsNightTime()
	return not M.CheckIsDayTime()
end

function M.CheckIsApplySkinPart(partId)
	local skinInfo = gMainPhoneUtils.GetCurrentSpiritSkinInfo()

	if partId == skinInfo.wallPaperId or partId == skinInfo.decorationId or partId == skinInfo.pendantId then
		return true
	end

	if partId > 0 then
		local skinPartCfg = LTConfig.MobileMenuSkinPartConfig.GetConfig(partId)
		local isWallPaperMatch = skinPartCfg.Wallpaper == skinInfo.wallPaperId
		local isDecorationMatch = skinPartCfg.Decoration == skinInfo.decorationId
		local isPendantMatch = skinPartCfg.Pendant == skinInfo.pendantId

		return isWallPaperMatch and isDecorationMatch and isPendantMatch or false
	else
		return skinInfo.wallPaperId == 0 and skinInfo.decorationId == 0 and skinInfo.pendantId == 0
	end

	return false
end

function M.GetTargetSkinIds(skinPartId)
	local skinInfo = gMainPhoneUtils.GetCurrentSpiritSkinInfo()
	local skinPartCfg = LTConfig.MobileMenuSkinPartConfig.GetConfig(skinPartId)
	local targetWallPaperId = skinInfo.wallPaperId
	local targetDecorationId = skinInfo.decorationId
	local targetPendantId = skinInfo.pendantId

	if skinPartCfg.Type == gClientConst.WALL_PAPER_HOME_TAB_TYPE.WallPaper then
		targetWallPaperId = skinPartId
	elseif skinPartCfg.Type == gClientConst.WALL_PAPER_HOME_TAB_TYPE.Decoration then
		targetDecorationId = skinPartId
	elseif skinPartCfg.Type == gClientConst.WALL_PAPER_HOME_TAB_TYPE.Pendant then
		targetPendantId = skinPartId
	elseif skinPartCfg.Type == gClientConst.WALL_PAPER_HOME_TAB_TYPE.Suit then
		targetPendantId = skinPartCfg.Pendant
		targetDecorationId = skinPartCfg.Decoration
		targetWallPaperId = skinPartCfg.Wallpaper
	end

	return targetWallPaperId, targetDecorationId, targetPendantId
end

function M:GetItemButtonIndex(btn)
	local store = gStoreManager:GetStoreGroup("MainPhonePanelStore")
	local dict = store.mainPhoneListBtnIndexDict

	return dict and dict[btn] or 0
end

gMainPhoneUtils = M
