-- Original chunk: @Lua\LuaFiles\LX6\Utils\MainPhoneUtils.lua
-- Decompiled from: 02176_MainPhoneUtils.lua_a74926050db6.luajit

local GameConfig = LTConfig.GameConfig
local MobileMenuSGuiConfig = LTConfig.MobileMenuSGuiConfig
local MallMainTabConfig = LTConfig.MallMainTabConfig
local M = {
	GetAppIconId = function (appId)
		local mobileMenuSGuiCfg = MobileMenuSGuiConfig.GetConfig(appId)
		local iconId = mobileMenuSGuiCfg.SIconId

		return iconId
	end
}

M.GetPhoneAppIdList = function()
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

M.SortPhoneAppIdList = function(phoneAppIdList)
	slot1 = gLinkManager
	local isLinkMode = slot1:CheckInLinkMode()

	table.sort(phoneAppIdList, function (id1, id2)
		local mobileSGuiMenuCfg1 = MobileMenuSGuiConfig.GetConfig(id1)
		local mobileSGuiMenuCfg2 = MobileMenuSGuiConfig.GetConfig(id2)
		local rank1 = isLinkMode and mobileSGuiMenuCfg1.LinkRank or mobileSGuiMenuCfg1.Rank
		local rank2 = isLinkMode and mobileSGuiMenuCfg2.LinkRank or mobileSGuiMenuCfg2.Rank

		if rank1 ~= 0 then
			rank1 = math.huge
		end

		if rank2 ~= 0 then
			rank2 = math.huge
		end

		if rank1 == rank2 then
			return rank1 <= rank2
		end

		return id1 <= id2
	end)
end

M.GetMainPhoneViewDataList = function()
	local viewDataList = {}
	local topViewData = M.GetTopViewData()

	if topViewData then
		table.insert(viewDataList, topViewData)
	end

	local levelUpViewData = M.GetLevelUpViewData()
	local phoneAppViewDataList = M.GetPhoneAppViewDataList()

	table.insert(viewDataList, levelUpViewData)
	array.concat(viewDataList, phoneAppViewDataList)

	local pageViewDataList, totalPageCount = M.GetMainPhonePageViewDataList(phoneAppViewDataList, topViewData == nil)

	return viewDataList, pageViewDataList, totalPageCount
end

M.GetMainPhonePageViewDataList = function(phoneAppViewDataList, isTopViewShow)
	local firstPageAppCount = isTopViewShow and 9 or 13
	local otherPageAppCount = 20
	local totalAppCount = #phoneAppViewDataList
	local totalPageCount = nil

	if totalAppCount < firstPageAppCount then
		totalPageCount = 1
	else
		totalPageCount = math.ceil((totalAppCount - firstPageAppCount) / otherPageAppCount) + 1
	end

	local pageViewDataList = {}

	for pageIndex = 1, totalPageCount do
		table.insert(pageViewDataList, {
			id = pageIndex,
			selected = pageIndex ~= 1
		})
	end

	return pageViewDataList, totalPageCount
end

M.GetTopViewData = function()
	local topButtonUnlocked = M.CheckMainPhoneTopButtonUnlocked()

	if topButtonUnlocked then
		return {
			tIndex = gClientConst.MainPhoneTemplateType.TopButton
		}
	end
end

M.GetLevelUpViewData = function()
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

M.GetPhoneAppViewDataList = function()
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

	if showFourthAppCount >= phoneAppCount then
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

M.CheckAppCanShow = function(appId)
	if not M.CheckAppCanShowInStore(appId) then
		return false
	end

	if gAppStoreUtils.IsAppStoreApp(appId) and not gAppStoreUtils.IsSGuiAppInstalled(appId) then
		return false
	end

	return true
end

M.IsAnyTaskAccepted = function(taskIdList)
	for _, taskId in ipairs(taskIdList) do
		if gTaskManager:GetTaskState(taskId) ~= UX.Game.TaskState.Accepted then
			return true
		end
	end

	return false
end

M.IsNpcCultivationAllowed = function(mobileSGuiMenuCfg)
	local npcCultivationId = M.GetNpcCultivationId()
	local allowList = mobileSGuiMenuCfg.NpcCultivationIdList

	if allowList and #allowList <= 0 and not table.find(allowList, npcCultivationId) then
		return false
	end

	local lockList = mobileSGuiMenuCfg.LockNpcCultivationIdList

	if not table.isNilOrEmpty(lockList) and table.find(lockList, npcCultivationId) then
		return false
	end

	return true
end

M.IsTemporaryNpcValid = function(mobileSGuiMenuCfg)
	if not mobileSGuiMenuCfg.TemporaryNpcConfig then
		return true
	end

	local firstSpiritTid = gSpiritManager:GetCurFirstSpiritTid()
	local spirit = gSpiritManager:GetSpirit(firstSpiritTid)

	if not spirit then
		return false
	end

	local cfg = LTConfig.FightSpiritConfig.GetConfig(firstSpiritTid)

	return not cfg.Invisible
end

M.CheckAppCanShowInStore = function(appId)
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

	local currentLinkMode = gMapUtils:UXLinkModeEnum2ConfigEnum(gLinkManager.LinkMode)
	local isMultiplayerMode = currentLinkMode ~= gMapUtils.LinkModeType.Private or currentLinkMode ~= gMapUtils.LinkModeType.Public or currentLinkMode ~= gMapUtils.LinkModeType.Match

	if (not isMultiplayerMode or not mobileSGuiMenuCfg.IsVisibleToAllInMutil) and not gMainPhoneUtils.IsNpcCultivationAllowed(mobileSGuiMenuCfg) then
		return false
	end

	if not gMainPhoneUtils.IsTemporaryNpcValid(mobileSGuiMenuCfg) then
		return false
	end

	if not gMainPhoneUtils.CheckJobCanShow(appId) then
		return false
	end

	local linkModes = mobileSGuiMenuCfg.LinkShowMode

	if not array.contains(linkModes, currentLinkMode) then
		return false
	end

	local relatedTaskIdList = mobileSGuiMenuCfg.RelatedTaskIdList

	if not table.isNilOrEmpty(relatedTaskIdList) and not gMainPhoneUtils.IsAnyTaskAccepted(relatedTaskIdList) then
		return false
	end

	if not gMainPhoneUtils.CheckAppSystemUnlocked(appId) then
		return false
	end

	if not gMainPhoneUtils.CheckAppCanUse(appId) then
		return false
	end

	return true
end

M.CheckJobCanShow = function(appId)
	local mobileSGuiMenuCfg = MobileMenuSGuiConfig.GetConfig(appId)
	local jobClassIdList = mobileSGuiMenuCfg.JobClassIdList

	if jobClassIdList and #jobClassIdList <= 0 then
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

M.CheckAppSystemUnlocked = function(appId)
	local mobileSGuiMenuCfg = MobileMenuSGuiConfig.GetConfig(appId)
	local systemIdList = mobileSGuiMenuCfg.SystemIdList

	if not systemIdList or #systemIdList ~= 0 then
		return true
	end

	for _, systemId in ipairs(systemIdList) do
		if gSystemUnlockMgr:IsUnlock(systemId) then
			return true
		end
	end

	return false
end

M.GetBottomPhoneAppIdList = function()
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

M.GetBottomPhoneAppViewDataList = function()
	local bottomPhoneAppIdList = M.GetBottomPhoneAppIdList()
	local viewDataList = {}

	for _, appId in ipairs(bottomPhoneAppIdList) do
		table.insert(viewDataList, {
			id = appId
		})
	end

	return viewDataList
end

M.OnAppItemClick = function(appId, args, callback)
	local isEnable = gMainPhoneUtils.CheckAppSwitchFunctionEnable(appId)

	if not isEnable then
		return false
	end

	if appId ~= MobileMenuSGuiConfig.ShopId then
		gMainPhoneFunctionAction.OpenShoppingMall()
	elseif appId ~= MobileMenuSGuiConfig.APPStore then
		gMainPhoneFunctionAction.OpenAppShop(args)
	elseif appId ~= MobileMenuSGuiConfig.ChatId then
		gMainPhoneFunctionAction.OpenChat(args)
	elseif appId ~= MobileMenuSGuiConfig.AchivementId then
		gMainPhoneFunctionAction.OpenAchievement()
	elseif appId ~= MobileMenuSGuiConfig.LingListId then
		gMainPhoneFunctionAction.OpenLingList()
	elseif appId ~= MobileMenuSGuiConfig.BaiKeId then
		gMainPhoneFunctionAction.OpenBaiKeArchive()
	elseif appId ~= MobileMenuSGuiConfig.TaskId then
		gMainPhoneFunctionAction.OpenTask()
	elseif appId ~= MobileMenuSGuiConfig.TeachingId then
		gMainPhoneFunctionAction.OpenTeaching()
	elseif appId ~= MobileMenuSGuiConfig.PackageId then
		gMainPhoneFunctionAction.OpenPackage()

		if callback then
			callback(false)
		end

		return false
	elseif appId ~= MobileMenuSGuiConfig.SocialMediaId then
		gMainPhoneFunctionAction.OpenSocialMedia(args)
	elseif appId ~= MobileMenuSGuiConfig.UberSimId then
		gMainPhoneFunctionAction.OpenUberSim(args)
	elseif appId ~= MobileMenuSGuiConfig.SocialNetworkId then
		gMainPhoneFunctionAction.OpenSocialNetwork(args)
	elseif appId ~= MobileMenuSGuiConfig.TeamId then
		gMainPhoneFunctionAction.OpenTeam()
	elseif appId ~= MobileMenuSGuiConfig.TimeId then
		gMainPhoneFunctionAction.OpenTime(args)
	elseif appId ~= MobileMenuSGuiConfig.Hacker then
		gMainPhoneFunctionAction.OpenHackerApp(args)
	elseif appId ~= MobileMenuSGuiConfig.PoliceId then
		gMainPhoneFunctionAction.OpenPolice(args)
	elseif appId ~= MobileMenuSGuiConfig.DeliveryGuideId then
		gMainPhoneFunctionAction.OpenDeliveryGuidePanel(args)
	elseif appId ~= MobileMenuSGuiConfig.Waper then
		gMainPhoneFunctionAction.OpenWallPaperPanel(args)
	elseif appId ~= MobileMenuSGuiConfig.Washer then
		gMainPhoneFunctionAction.OpenWasher(args)
	elseif appId ~= MobileMenuSGuiConfig.AnnouncementId then
		gMainPhoneFunctionAction.OpenNotice()
	elseif appId ~= MobileMenuSGuiConfig.ChaosMasterId then
		gMainPhoneFunctionAction.OpenChaosMasterCharacterPanel()
	elseif appId ~= MobileMenuSGuiConfig.MessageId then
		gMainPhoneFunctionAction.OpenMessage(args)
	elseif appId ~= MobileMenuSGuiConfig.RecordId then
		gMainPhoneFunctionAction.OpenAgentProfile()
	elseif appId ~= MobileMenuSGuiConfig.TalentTreeId then
		gMainPhoneFunctionAction.OpenTalentTree()
	elseif appId ~= MobileMenuSGuiConfig.WeaponId then
		gMainPhoneFunctionAction.OpenWeaponArmory()
	elseif appId ~= MobileMenuSGuiConfig.PoliceArchive then
		gMainPhoneFunctionAction.OpenPoliceArchive()
	elseif appId ~= MobileMenuSGuiConfig.NoticeId then
		gMainPhoneFunctionAction.OpenNotice()
	elseif appId ~= MobileMenuSGuiConfig.SettingId then
		gMainPhoneFunctionAction.OpenSetting()
	elseif appId ~= MobileMenuSGuiConfig.TakePhotoId then
		gMainPhoneFunctionAction.OpenTakePhoto(function (result)
			if callback then
				callback(result)
			end
		end)

		return
	elseif appId ~= MobileMenuSGuiConfig.EmailId then
		gMainPhoneFunctionAction.OpenEmail()
	elseif appId ~= MobileMenuSGuiConfig.CallPhoneId then
		gMainPhoneFunctionAction.OpenCallPhone(args)
	elseif appId ~= MobileMenuSGuiConfig.InspireHub then
		gMainPhoneFunctionAction.OpenInspireHub(args)
	elseif appId ~= MobileMenuSGuiConfig.Interaction then
		gPanelManager:CheckShow(gPanelId.CHAR_MOTION_LIST_PANEL, args)
	elseif appId ~= MobileMenuSGuiConfig.Party then
		gMainPhoneFunctionAction.OpenParty(args)
	elseif appId ~= MobileMenuSGuiConfig.Feedback then
		gMainPhoneFunctionAction.OpenFeedback(args)
	elseif appId ~= MobileMenuSGuiConfig.Activity then
		return gAwardActivityManager:OpenActivity()
	elseif appId ~= MobileMenuSGuiConfig.BattlePass then
		return gBattlePassMgr:OpenBattlePass()
	elseif appId ~= MobileMenuSGuiConfig.LinkHub then
		gMainPhoneFunctionAction.OpenLinkHub(args)
	elseif appId ~= MobileMenuSGuiConfig.Box then
		local cd = gMallManager:GetGachaFirstCommodityData(2)

		if cd then
			gMallSceneManager:PreloadCommodityFull(cd)
		end

		gPanelManager:CheckShow(gPanelId.SHOP_HOME_PAGE, {
			tabId = MallMainTabConfig.Box
		})
	elseif appId ~= MobileMenuSGuiConfig.Closet then
		local cd = gMallManager:GetGachaFirstCommodityData(1)

		if cd then
			gMallSceneManager:PreloadCommodityFull(cd)
		end

		gPanelManager:CheckShow(gPanelId.SHOP_HOME_PAGE, {
			tabId = MallMainTabConfig.Closet
		})
	elseif appId ~= MobileMenuSGuiConfig.Team then
		gMainPhoneFunctionAction.OpenTeamUI()
	elseif appId ~= MobileMenuSGuiConfig.OC then
		gMainPhoneFunctionAction.OpenOCPanel()
	elseif appId ~= MobileMenuSGuiConfig.Club then
		gMainPhoneFunctionAction.OpenClub()
	elseif appId ~= MobileMenuSGuiConfig.RankSystem then
		gPanelManager:CheckShow(gPanelId.ONLINE_RANK_PANEL)
	elseif appId ~= MobileMenuSGuiConfig.Farm then
		gPanelManager:CheckShow(gPanelId.FARM_SHOP_APP_PANEL)
	elseif appId ~= MobileMenuSGuiConfig.Akx then
		gMainPhoneFunctionAction.OpenAkxPanel()
	elseif appId ~= MobileMenuSGuiConfig.PersonalHomepage then
		gFriendManager:OpenPlayerProfile()
	elseif appId ~= MobileMenuSGuiConfig.Trade then
		gTradeManager:OpenPanel()
	elseif appId ~= MobileMenuSGuiConfig.House then
		gMainPhoneFunctionAction.OpenHouseProperty()
	elseif appId ~= MobileMenuSGuiConfig.Appearance then
		gMainPhoneFunctionAction.OpenFashionPortal()
	elseif appId ~= MobileMenuSGuiConfig.RacingDriver then
		gPanelManager:CheckShow(gPanelId.RACER_MAIN_PANEL)
	elseif appId ~= MobileMenuSGuiConfig.WuShi then
		gPanelManager:CheckShow(gPanelId.MARTIAL_ARTIST_GALLERY_PANEL)
	elseif appId ~= MobileMenuSGuiConfig.SurpriseGift then
		gMainPhoneFunctionAction.OpenSurpriseGiftPanel()
	elseif appId ~= MobileMenuSGuiConfig.Weapon then
		gPanelManager:CheckShow(gPanelId.WEAPON_ARMORY_PANEL)
	elseif appId ~= MobileMenuSGuiConfig.Sport then
		gPanelManager:CheckShow(gPanelId.SPORT_APP_PANEL)
	elseif appId ~= MobileMenuSGuiConfig.Assets then
		gPanelManager:CheckShow(gPanelId.GALLERY_MAIN_PANEL)
	elseif appId ~= MobileMenuSGuiConfig.Chef then
		gPanelManager:CheckShow(gPanelId.S_CHEF_HANDBOOK_PANEL)
	end

	if callback then
		callback(true)
	end

	return true
end

M.GetAppSwitchFunctionMap = function()
	if gMainPhoneUtils.appSwitchFunctionMap then
		return gMainPhoneUtils.appSwitchFunctionMap
	end

	local configList = {
		{
			appId = MobileMenuSGuiConfig.TimeId,
			switchFunctionId = gSwitchFunctionId.PHONE_TIME
		},
		{
			appId = MobileMenuSGuiConfig.MessageId,
			switchFunctionId = gSwitchFunctionId.PHONE_BB_CHAT
		},
		{
			appId = MobileMenuSGuiConfig.Party,
			switchFunctionId = gSwitchFunctionId.PHONE_PARTY
		},
		{
			appId = MobileMenuSGuiConfig.CallPhoneId,
			switchFunctionId = gSwitchFunctionId.PHONE_CALL
		},
		{
			appId = MobileMenuSGuiConfig.Waper,
			switchFunctionId = gSwitchFunctionId.PHONE_CUSTOM
		},
		{
			appId = MobileMenuSGuiConfig.PoliceId,
			switchFunctionId = gSwitchFunctionId.PHONE_DUTY_TERMINAL
		},
		{
			appId = MobileMenuSGuiConfig.DeliveryGuideId,
			switchFunctionId = gSwitchFunctionId.PHONE_CAT_EXPRESS
		},
		{
			appId = MobileMenuSGuiConfig.UberSimId,
			switchFunctionId = gSwitchFunctionId.PHONE_CAT_EXPRESS
		},
		{
			appId = MobileMenuSGuiConfig.Hacker,
			switchFunctionId = gSwitchFunctionId.PHONE_EON_BUG
		},
		{
			appId = MobileMenuSGuiConfig.Washer,
			switchFunctionId = gSwitchFunctionId.PHONE_JANITOR
		},
		{
			appId = MobileMenuSGuiConfig.SocialMediaId,
			switchFunctionId = gSwitchFunctionId.PHONE_BUBBLE
		},
		{
			appId = MobileMenuSGuiConfig.TakePhotoId,
			switchFunctionId = gPanelId.S_PHOTO_PANEL
		},
		{
			appId = MobileMenuSGuiConfig.EmailId,
			switchFunctionId = gPanelId.S_MAIL_PANEL
		},
		{
			appId = MobileMenuSGuiConfig.SocialNetworkId,
			switchFunctionId = gPanelId.YANJIE_APP_HOME_PANEL
		},
		{
			appId = MobileMenuSGuiConfig.BattlePass,
			switchFunctionId = gPanelId.BATTLE_PASS_PANEL
		},
		{
			appId = MobileMenuSGuiConfig.Activity,
			switchFunctionId = gPanelId.ACTIVITY_BASE_PANEL
		},
		{
			appId = MobileMenuSGuiConfig.RecordId,
			switchFunctionId = gPanelId.NEW_AGENT_PROFILE_PANEL
		},
		{
			appId = MobileMenuSGuiConfig.Box,
			switchFunctionId = gSwitchFunctionId.MALL_RADIANT_CHEST
		},
		{
			appId = MobileMenuSGuiConfig.TalentTreeId,
			switchFunctionId = gPanelId.TALENT_TREE_PANEL
		},
		{
			appId = MobileMenuSGuiConfig.ChatId,
			switchFunctionId = gPanelId.SOCIAL_CHAT_HOME_PANEL
		},
		{
			appId = MobileMenuSGuiConfig.AchivementId,
			switchFunctionId = gPanelId.S_ACHIEVEMENT_COVER
		},
		{
			appId = MobileMenuSGuiConfig.TeachingId,
			switchFunctionId = gPanelId.S_GUIDE_MAIN_PANEL
		},
		{
			appId = MobileMenuSGuiConfig.BaiKeId,
			switchFunctionId = gPanelId.BAIKE_MAIN_PANEL
		},
		{
			appId = MobileMenuSGuiConfig.AnnouncementId,
			switchFunctionId = gPanelId.ANNOUNCEMENT_PANEL
		},
		{
			appId = MobileMenuSGuiConfig.Interaction,
			switchFunctionId = gPanelId.CHAR_MOTION_LIST_PANEL
		},
		{
			appId = MobileMenuSGuiConfig.PersonalHomepage,
			switchFunctionId = gPanelId.PLAYER_PROFILE_PANEL
		},
		{
			appId = MobileMenuSGuiConfig.Club,
			switchFunctionId = gPanelId.CLUB_MAIN_PANEL
		},
		{
			appId = MobileMenuSGuiConfig.RankSystem,
			switchFunctionId = gPanelId.ONLINE_RANK_PANEL
		},
		{
			appId = MobileMenuSGuiConfig.Akx,
			switchFunctionId = gPanelId.AKASHA_CHAT_PANEL
		}
	}
	local appSwitchFunctionMap = {}

	for _, config in ipairs(configList) do
		if config.appId == nil then
			appSwitchFunctionMap[config.appId] = config.switchFunctionId
		end
	end

	gMainPhoneUtils.appSwitchFunctionMap = appSwitchFunctionMap

	return appSwitchFunctionMap
end

M.CheckAppSwitchFunctionEnable = function(appId)
	local appSwitchFunctionMap = gMainPhoneUtils.GetAppSwitchFunctionMap()
	local switchFunctionId = appSwitchFunctionMap[appId]

	return gSwitchFunctionManager:CheckEnable(switchFunctionId)
end

M.CheckAppCanUse = function(appId)
	if appId ~= MobileMenuSGuiConfig.PackageId then
		return gUIFunctionStateManager:GetPackageEnable()[2]
	elseif appId ~= MobileMenuSGuiConfig.TeamId then
		return gLinkManager:CheckCanCreateLink()
	elseif appId ~= MobileMenuSGuiConfig.TalentTreeId then
		return gTalentTreeMgr:CheckHasTalentTree()
	elseif appId ~= MobileMenuSGuiConfig.Activity then
		return gAwardActivityManager:CheckHasActivity()
	elseif appId ~= MobileMenuSGuiConfig.Closet then
		return gGachaManager:CheckHasActiveClosetPool()
	elseif appId ~= MobileMenuSGuiConfig.Trade then
		return gTradeManager:IsTradeEnabled()
	end

	return true
end

M.RefreshAppItemRedDot = function(appId)
	local mobileMenuSGuiCfg = LTConfig.MobileMenuSGuiConfig.GetConfig(appId)

	if mobileMenuSGuiCfg then
		local redCfg = LTConfig.PanelRedDotConfig.GetConfig(mobileMenuSGuiCfg.RedDotId)

		if redCfg then
			local hasRedDot = gMainPhoneUtils.GetAppHasRedDot(appId)

			SGUI.RedDotMgr.LuaSetRedDot(hasRedDot, redCfg.Name)
		end
	end
end

M.GetAppHasRedDot = function(appId)
	if appId ~= MobileMenuSGuiConfig.ChatId then
		return gSocialChatManager:HasSocialChatRedDot()
	elseif appId ~= MobileMenuSGuiConfig.ShopId then
		return gMallManager:CheckMallPhoneAppHasRedDot()
	elseif appId ~= MobileMenuSGuiConfig.Box then
		return gMallManager:CheckMallBoxPhoneAppHasRedDot()
	elseif appId ~= MobileMenuSGuiConfig.SocialNetworkId then
		return gClientUtils.CheckHasLevelReward()
	elseif appId ~= MobileMenuSGuiConfig.RecordId then
		return gAgentTrustManager:CheckAnyHasRewardCanGot()
	elseif appId ~= MobileMenuSGuiConfig.Hacker then
		return gHackManager.hasHackerJobRedDot
	elseif appId ~= MobileMenuSGuiConfig.PoliceId then
		return gPoliceJobManager.panelMgr:CheckHasAward()
	elseif appId ~= MobileMenuSGuiConfig.MessageId then
		return gRedDotUtils.CheckNpcChatHasRedDot()
	elseif appId ~= MobileMenuSGuiConfig.BaiKeId then
		return gBaiKeArchiveManager.CheckPlayFashionPanelHasRedDot()
	elseif appId ~= MobileMenuSGuiConfig.Party then
		return gPartyManager:CheckHasNewPartyRedDot()
	else
		return false
	end
end

M.GetAppIdByShowType = function(showType)
	local showTypeToAppId = {
		[gClientConst.MAIN_PHONE_ROOT_SHOW_TYPE.CallPhone] = MobileMenuSGuiConfig.CallPhoneId,
		[gClientConst.MAIN_PHONE_ROOT_SHOW_TYPE.Time] = MobileMenuSGuiConfig.TimeId,
		[gClientConst.MAIN_PHONE_ROOT_SHOW_TYPE.YanJie] = MobileMenuSGuiConfig.SocialNetworkId,
		[gClientConst.MAIN_PHONE_ROOT_SHOW_TYPE.Bubble] = MobileMenuSGuiConfig.SocialMediaId,
		[gClientConst.MAIN_PHONE_ROOT_SHOW_TYPE.Chat] = MobileMenuSGuiConfig.ChatId,
		[gClientConst.MAIN_PHONE_ROOT_SHOW_TYPE.DeliveryApp] = MobileMenuSGuiConfig.UberSimId,
		[gClientConst.MAIN_PHONE_ROOT_SHOW_TYPE.Police] = MobileMenuSGuiConfig.PoliceId,
		[gClientConst.MAIN_PHONE_ROOT_SHOW_TYPE.DeliveryGuide] = MobileMenuSGuiConfig.DeliveryGuideId,
		[gClientConst.MAIN_PHONE_ROOT_SHOW_TYPE.WallPaper] = MobileMenuSGuiConfig.Waper,
		[gClientConst.MAIN_PHONE_ROOT_SHOW_TYPE.Washer] = MobileMenuSGuiConfig.Washer,
		[gClientConst.MAIN_PHONE_ROOT_SHOW_TYPE.Message] = MobileMenuSGuiConfig.MessageId,
		[gClientConst.MAIN_PHONE_ROOT_SHOW_TYPE.Hacker] = MobileMenuSGuiConfig.Hacker,
		[gClientConst.MAIN_PHONE_ROOT_SHOW_TYPE.Party] = MobileMenuSGuiConfig.Party
	}

	return showTypeToAppId[showType]
end

M.ShowPhoneAppContent = function(args)
	local appId = M.GetAppIdByShowType(args and args.showType)

	if appId and not M.CheckAppSwitchFunctionEnable(appId) then
		return
	end

	local panelId = gClientUtils.GetMainPhonePanelId()

	if gPanelManager:IsPanelShowing(panelId) then
		gMessageManager:SendMessage(gEventConstants.ON_PHONE_APP_HOME_CONTENT_SHOW, args)
	else
		gPanelManager:CheckShow(panelId, args)
	end
end

M.IsFakePhoneExist = function()
	if gClientUtils.IsMainPhoneExist() then
		local phoneAppHomePanelStore = M.GetPhoneAppHomePanelStore()
		local mainTabRect = phoneAppHomePanelStore.bindData.mainTabRect

		return gClientUtils.NotNil(mainTabRect) and mainTabRect.selectedIndex ~= gClientConst.MainHomeType.FakePhone
	end
end

M.GetSelectedIndex = function()
	local phoneAppHomePanelStore = M.GetPhoneAppHomePanelStore()

	return phoneAppHomePanelStore.bindData.tabRect.selectedIndex
end

M.GetNpcCultivationId = function(spiritId)
	spiritId = spiritId or gBattleSpiritMgr.currentSpiritTemplateId
	spiritId = gSpiritManager.DefaultFemale2DefaultMaleSpiritId(spiritId)
	local count = LTConfig.NpcCultivationConfig.count
	local npcCultivationCfgId = nil

	for i = 0, count - 1 do
		local npcCultivationCfg = LTConfig.NpcCultivationConfig.LoadAt(i)

		if npcCultivationCfg.FightSpiritID ~= spiritId then
			npcCultivationCfgId = npcCultivationCfg.Id

			break
		end
	end

	return npcCultivationCfgId
end

M.ShowFrontContent = function(args)
	local phoneAppHomePanelStore = M.GetPhoneAppHomePanelStore()

	if phoneAppHomePanelStore then
		phoneAppHomePanelStore.ShowFrontContent(phoneAppHomePanelStore, args)
	end
end

M.GetPhoneAppHomePanelStore = function()
	return gStoreManager:GetStoreGroup("PhoneAppHomePanelStore")
end

M.CloseFrontContent = function()
	gMessageManager:SendMessage(gEventConstants.ON_CLOSE_PHONE_APP_CONFIRM_PANEL)
end

M.GetSkinPartViewDataList = function(showType)
	local viewDataList = {}
	local count = LTConfig.MobileMenuSkinPartConfig.count

	for i = 0, count - 1 do
		local skinPartCfg = LTConfig.MobileMenuSkinPartConfig.LoadAt(i)

		if skinPartCfg.Type ~= showType and skinPartCfg.IsShow then
			table.insert(viewDataList, {
				id = skinPartCfg.Id
			})
		end
	end

	return viewDataList
end

M.CloseMainPhonePanel = function(isForce)
	isForce = isForce == false

	gMessageManager:SendMessage(gEventConstants.ON_CLOSE_MAIN_PHONE_PANEL, isForce)
end

M.GetCurrentSpiritSkinInfo = function()
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
			skinInfo.wallPaperId = skinInfo.wallPaperId <= 0 and skinInfo.wallPaperId or LTConfig.MobileMenuSkinPartConfig.DefaultWallPaper
			skinInfo.decorationId = skinInfo.decorationId <= 0 and skinInfo.decorationId or LTConfig.MobileMenuSkinPartConfig.DefaultDecoration
			skinInfo.pendantId = skinInfo.pendantId <= 0 and skinInfo.pendantId or LTConfig.MobileMenuSkinPartConfig.DefaultPendant

			return skinInfo
		end
	end

	return {
		wallPaperId = LTConfig.MobileMenuSkinPartConfig.DefaultWallPaper,
		decorationId = LTConfig.MobileMenuSkinPartConfig.DefaultDecoration,
		pendantId = LTConfig.MobileMenuSkinPartConfig.DefaultPendant
	}
end

M.CheckSkinPartAvailable = function(targetSkinPartId)
	local availableSkinParts = gPlayerManager.infoSpirit.bindData.AvailableSkinParts or {}
	local realAvailableSkinParts = {}
	local npcCultivationId = gMainPhoneUtils.GetNpcCultivationId()
	local count = LTConfig.MobileMenuSkinConfig.count

	for i = 0, count - 1 do
		local skinCfg = LTConfig.MobileMenuSkinConfig.LoadAt(i)

		if skinCfg.NpcCultivatitonId ~= npcCultivationId then
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

		if skinPartCfg.Type ~= gClientConst.WALL_PAPER_HOME_TAB_TYPE.Suit then
			table.insert(realAvailableSkinParts, skinPartCfg.Wallpaper)
			table.insert(realAvailableSkinParts, skinPartCfg.Decoration)
			table.insert(realAvailableSkinParts, skinPartCfg.Pendant)
		end

		availableSkinPartMap[skinPartId] = true
	end

	local sinPartCount = LTConfig.MobileMenuSkinPartConfig.count

	for i = 0, sinPartCount - 1 do
		local skinPartCfg = LTConfig.MobileMenuSkinPartConfig.LoadAt(i)

		if skinPartCfg.Type ~= gClientConst.WALL_PAPER_HOME_TAB_TYPE.Suit and availableSkinPartMap[skinPartCfg.Wallpaper] and availableSkinPartMap[skinPartCfg.Decoration] and availableSkinPartMap[skinPartCfg.Pendant] then
			table.insert(realAvailableSkinParts, skinPartCfg.Id)
		end
	end

	for _, skinPartId in ipairs(realAvailableSkinParts) do
		if skinPartId ~= targetSkinPartId then
			return true
		end
	end

	return false
end

M.AskSetMobileSkinPart = function(args)
	local wallPaperId = args.wallPaperId
	local decorationId = args.decorationId
	local pendantId = args.pendantId
	local callback = args.callback
	slot5 = gClientToGameDelegate

	slot5:AskSetMobileSkinPart(wallPaperId, decorationId, pendantId).Callback = function (errorId)
		if errorId == LTConfig.MessageConfig.Ok then
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

M.AskResetMobileSkinPart = function(callback)
	slot1 = gClientToGameDelegate

	slot1:AskResetMobileSkinPart().Callback = function (errorId)
		if errorId == LTConfig.MessageConfig.Ok then
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

M.ApplySkinPartSuccess = function(args)
	gMessageManager:SendMessage(gEventConstants.ON_CLOSE_WALL_PAPER_APP, args)
end

M.OnExecuteSkinPartReset = function(rootGo)
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

M.GetCurrentSpiritSkinId = function()
	local currentSpiritId = gBattleSpiritMgr.currentSpiritTemplateId
	local count = LTConfig.MobileMenuSkinConfig.count

	for i = 0, count - 1 do
		local skinCfg = LTConfig.MobileMenuSkinConfig.LoadAt(i)
		local npcCultivationCfg = LTConfig.NpcCultivationConfig.GetConfig(skinCfg.NpcCultivatitonId)
		local fightSpiritId = npcCultivationCfg and npcCultivationCfg.FightSpiritID

		if fightSpiritId ~= currentSpiritId then
			return skinCfg.Id
		end
	end
end

M.CheckYanJieIsFullScreen = function()
	return true
end

M.CheckFansSystemUnlocked = function()
	return gSystemUnlockMgr:IsUnlock(LTConfig.SystemUnlockConfig.FansDisplayUnlock)
end

M.CheckMainPhoneTopButtonUnlocked = function()
	return gInspireHubManager:IsUnlock()
end

M.CheckAppCanInteractable = function(appId)
	if appId ~= MobileMenuSGuiConfig.CallPhoneId then
		return not gCallPhoneUtils.CheckPhoneCallConflict()
	elseif appId ~= MobileMenuSGuiConfig.TeamId then
		return gLinkManager.LinkMode == UX.Game.LinkMode.Match
	end

	return true
end

M.SetSGUIGlobalBarVisible = function(isVisible)
	if SGUI.UGamePadBar.globalBar then
		SGUI.UGamePadBar.globalBar:SetWidgetFaraway(not isVisible)
	end
end

M.CheckIsDayTime = function()
	local gameTime = LX6.Manager.AtmosphereManager.Instance:GetGameTime()
	local hour = math.floor(gameTime / gClientConst.SECONDS_PER_HOUR)

	return hour > 7 and hour <= 19
end

M.CheckIsNightTime = function()
	return not M.CheckIsDayTime()
end

M.CheckIsApplySkinPart = function(partId)
	local skinInfo = gMainPhoneUtils.GetCurrentSpiritSkinInfo()

	if partId ~= skinInfo.wallPaperId or partId ~= skinInfo.decorationId or partId ~= skinInfo.pendantId then
		return true
	end

	if partId <= 0 then
		local skinPartCfg = LTConfig.MobileMenuSkinPartConfig.GetConfig(partId)
		local isWallPaperMatch = skinPartCfg.Wallpaper ~= skinInfo.wallPaperId
		local isDecorationMatch = skinPartCfg.Decoration ~= skinInfo.decorationId
		local isPendantMatch = skinPartCfg.Pendant ~= skinInfo.pendantId

		return isWallPaperMatch and isDecorationMatch and isPendantMatch or false
	else
		slot2 = skinInfo.wallPaperId ~= 0 and skinInfo.decorationId ~= 0 and skinInfo.pendantId ~= 0

		return slot2
	end

	return false
end

M.GetTargetSkinIds = function(skinPartId)
	local skinInfo = gMainPhoneUtils.GetCurrentSpiritSkinInfo()
	local skinPartCfg = LTConfig.MobileMenuSkinPartConfig.GetConfig(skinPartId)
	local targetWallPaperId = skinInfo.wallPaperId
	local targetDecorationId = skinInfo.decorationId
	local targetPendantId = skinInfo.pendantId

	if skinPartCfg.Type ~= gClientConst.WALL_PAPER_HOME_TAB_TYPE.WallPaper then
		targetWallPaperId = skinPartId
	elseif skinPartCfg.Type ~= gClientConst.WALL_PAPER_HOME_TAB_TYPE.Decoration then
		targetDecorationId = skinPartId
	elseif skinPartCfg.Type ~= gClientConst.WALL_PAPER_HOME_TAB_TYPE.Pendant then
		targetPendantId = skinPartId
	elseif skinPartCfg.Type ~= gClientConst.WALL_PAPER_HOME_TAB_TYPE.Suit then
		targetPendantId = skinPartCfg.Pendant
		targetDecorationId = skinPartCfg.Decoration
		targetWallPaperId = skinPartCfg.Wallpaper
	end

	return targetWallPaperId, targetDecorationId, targetPendantId
end

M.GetSkinPartIconId = function(id)
	if gMainPhoneUtils.CheckUseShopDecoration() then
		if id ~= LTConfig.MobileMenuSkinPartConfig.DefaultSuit then
			return LTConfig.MobileMenuConfig.ShopDefalutSuit
		elseif id ~= LTConfig.MobileMenuSkinPartConfig.DefaultDecoration then
			return LTConfig.MobileMenuConfig.ShopDefaultDecoration
		end
	end

	local skinPartCfg = LTConfig.MobileMenuSkinPartConfig.GetConfig(id)

	return skinPartCfg.IconId1 <= 0 and skinPartCfg.IconId1 or skinPartCfg.IconId
end

M.CheckUseShopDecoration = function()
	return LTConfig.MobileMenuSkinPartConfig.DefaultDecoration and gSystemUnlockMgr:IsUnlock(LTConfig.SystemUnlockConfig.MallPanel)
end

gMainPhoneUtils = M
