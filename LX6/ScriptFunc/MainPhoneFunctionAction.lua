-- Original chunk: @Lua\LuaFiles\LX6\ScriptFunc\MainPhoneFunctionAction.lua
-- Decompiled from: 02269_MainPhoneFunctionAction.lua_8259be6d3dcc.luajit

local M = {
	OpenShoppingMall = function ()
	end,
	OpenChat = function (args)
		gSocialChatManager:OpenChatUI()
	end,
	OpenAchievement = function ()
		gPanelManager:CheckShow(gPanelId.S_ACHIEVEMENT_COVER)
	end,
	OpenLingList = function ()
		if gUIUtils:CheckCanOpenCardPanel() then
			gSpiritManager:ShowLingMainPanel()
		end
	end,
	OpenBaiKeArchive = function ()
		gPanelManager:CheckShow(gPanelId.BAIKE_MAIN_PANEL)
	end,
	OpenTask = function ()
		gPanelManager:CheckShow(gPanelId.S_TASK_LIST)
	end,
	OpenMap = function ()
		gClientUtils.OpenMap()
	end,
	OpenTeaching = function ()
		gPanelManager:CheckShow(gPanelId.S_GUIDE_MAIN_PANEL)
	end,
	OpenPackage = function ()
		if not gUIFunctionStateManager:InventoryCheckCanShow() then
			return
		end

		gCommonItemManager:OpenInventoryPanel()
	end,
	OpenSocialMedia = function (args)
		args = args or {}

		gNewBubbleMgr:SwitchCurrentPanel(args)
	end,
	OpenChaosMasterCharacterPanel = function ()
		gPanelManager:CheckShow(gPanelId.CHAOS_CULTIVATION_MAIN_PANEL)
	end
}

M.OpenUberSim = function(args)
	args = args or {}
	local teachEventId = LTConfig.UberSimConfig.TeachEventId
	local eventState = gTaskManager:GetTaskEventState(teachEventId)
	args.eventSubmited = eventState ~= UX.Game.TaskEventState.Submited
	args.eventDoing = false

	if not args.eventSubmited then
		local nowDoingTask = gTaskNodeManager:GetNowDoingTask()

		if nowDoingTask and nowDoingTask <= 0 then
			args.eventDoing = gTaskNodeManager:GetEventIdByTask(nowDoingTask) ~= teachEventId
		end
	end

	if (args.eventSubmited or args.eventDoing) and gSpiritJobManager.GetCurSpiritJobClassId() ~= LTConfig.UrbanJobJobClassConfig.Delivery then
		slot3 = gClientToGameDelegate

		slot3:AskGetTruckJobOrders().Callback = function (errorId, clientTruckOrderView)
			if errorId == LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(errorId)

				return
			end

			args.showType = gClientConst.MAIN_PHONE_ROOT_SHOW_TYPE.DeliveryApp
			args.secondShowType = gClientConst.DELIVERY_APP_SHOW_TYPE.ORDER
			args.clientTruckOrderView = clientTruckOrderView

			gNewGuideMgr:NotifySignal(EGuideSignal.DeliveryPanelOpen)
			gMainPhoneUtils.ShowPhoneAppContent(args)
		end
	else
		args.showType = gClientConst.MAIN_PHONE_ROOT_SHOW_TYPE.DeliveryApp

		gMainPhoneUtils.ShowPhoneAppContent(args)
	end
end

M.OpenPolice = function(args)
	gPoliceJobManager.panelMgr:OpenMainPanel(args)
end

M.OpenSocialNetwork = function(args)
	args = args or {}

	if args.isFromMainPhone ~= nil then
		args.isFromMainPhone = true
	end

	args.showType = args.showType or gClientConst.MAIN_PHONE_ROOT_SHOW_TYPE.YanJie

	gPanelManager:CheckShow(gPanelId.YANJIE_APP_HOME_PANEL, args)
end

M.OpenTeam = function()
	gLinkManager:ShowLinkPanel()
end

M.OpenCallPhone = function(args)
	args = args or {}
	args.showType = gClientConst.MAIN_PHONE_ROOT_SHOW_TYPE.CallPhone
	args.secondShowType = args.secondShowType or gClientConst.CallPhoneShowType.Contact

	if args.isFromMainPhone ~= nil then
		args.isFromMainPhone = true
	end

	gMainPhoneUtils.ShowPhoneAppContent(args)
end

M.OpenTime = function(args)
	args = args or {}
	args.showType = gClientConst.MAIN_PHONE_ROOT_SHOW_TYPE.Time

	gMainPhoneUtils.ShowPhoneAppContent(args)
end

M.OpenAppShop = function(args)
	args = args or {}
	args.showType = gClientConst.MAIN_PHONE_ROOT_SHOW_TYPE.AppShop

	gMainPhoneUtils.ShowPhoneAppContent(args)
end

M.OpenTakePhoto = function(callback)
	return gTakePhotoUtils.TryTakePhoto(nil, , callback)
end

M.OpenSetting = function()
	gPanelManager:CheckShow(gPanelId.S_SETTINGS_PANEL)
end

M.OpenNotice = function()
	gAnnouncementMgr:OpenNoticePanel()
end

M.OpenEmail = function()
	gUIFunctionStateManager:MailOpenTrigger()
end

M.OpenMessage = function(args)
	args = args or {}
	args.OpenMessage = true

	gNpcChatUtils.OpenChatPanel(args)
end

M.OpenHackerApp = function(args)
	args = args or {}
	args.showType = gClientConst.MAIN_PHONE_ROOT_SHOW_TYPE.Hacker

	gMainPhoneUtils.ShowPhoneAppContent(args)
end

M.OpenDeliveryGuidePanel = function(args)
	args = args or {}

	gClientToGameDelegate:AskGetTruckJobOrders().Callback = function (errorId, clientTruckOrderView)
		if errorId == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end

		args.showType = gClientConst.MAIN_PHONE_ROOT_SHOW_TYPE.DeliveryGuide
		args.clientTruckOrderView = clientTruckOrderView

		gMainPhoneUtils.ShowPhoneAppContent(args)
	end
end

M.OpenWallPaperPanel = function(args)
	args = args or {}
	args.showType = gClientConst.MAIN_PHONE_ROOT_SHOW_TYPE.WallPaper

	gMainPhoneUtils.ShowPhoneAppContent(args)
end

M.OpenCharMotionPanel = function(args)
	gPanelManager:CheckShow(gPanelId.CHAR_MOTION_LIST_PANEL, args)
end

M.OpenAgentProfile = function()
	gPanelManager:CheckShow(gPanelId.NEW_AGENT_PROFILE_PANEL)
end

M.OpenTalentTree = function()
	gUIFunctionStateManager:TalentTreeOpenTrigger()
end

M.OpenWasher = function(args)
	args = args or {}
	args.showType = gClientConst.MAIN_PHONE_ROOT_SHOW_TYPE.Washer
	args.secondShowType = args.secondShowType or gClientConst.WASHER_APP_SHOW_TYPE.ORDER

	gClientToGameDelegate:AskGetWasherMissionInfo(false).Callback = function (errorId, washerJobInfo)
		if errorId == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)
			gWasherManager:ResetWasherJobInfo()

			return
		end

		args.washerJobInfo = washerJobInfo

		gWasherManager:SetWasherJobInfo(washerJobInfo)
		gMainPhoneUtils.ShowPhoneAppContent(args)
	end
end

M.OpenWeaponArmory = function()
	gPanelManager:CheckShow(gPanelId.S_WEAPON_ARMORY_MAIN_PANEL, {
		["w-y^"] = 1
	})
end

M.OpenPoliceArchive = function()
	gPanelManager:CheckShow(gPanelId.POLICE_ARCHIVE_PANEL)
end

M.OpenInspireHub = function()
	gPanelManager:CheckShow(gPanelId.HOT_CENTER_HOME)
end

M.OpenParty = function(args)
	gPanelManager:CheckShow(gPanelId.PARTY_START_PANEL)
end

M.OpenFeedback = function()
	gMainPhoneUtils.CloseMainPhonePanel(true)
	LX6.Utils.Feedback.FeedbackUtils.GetScreenShot(function (tex)
		gPanelManager:CheckShow(gPanelId.FEEDBACK_PANEL, {
			imageList = {
				{
					["t#p^"] = "@Yܸ\\x81\\xab\\xc6\\xfc",
					tex = tex
				}
			}
		})
	end)
end

M.OpenLinkHub = function()
	gPanelManager:CheckShow(gPanelId.ONLINE_ARCADE_CENTER_MAIN_PNEL)
end

M.OpenTeamUI = function()
	gPanelManager:CheckShow(gPanelId.TEAM_MAIN_PANEL)
end

M.OpenOCPanel = function()
	gOCMgr:OpenCreatePanel()
end

M.OpenMeikaMainPanel = function()
	gOCMgr:OpenMeikaMainPanel(nil, "chat")
end

M.OpenClub = function()
	if gClubManager:HasClub() then
		gPanelManager:CheckShow(gPanelId.CLUB_MAIN_PANEL)
	else
		gPanelManager:CheckShow(gPanelId.CLUB_APPLY_PANEL)
	end
end

M.OpenAkxPanel = function()
	gAkxManager:OpenAkxPanel()
end

M.OpenHouseProperty = function()
	gMapSystem.notShowMainPageTabPanel = true
	local raidId = gMapManager:GetParentRaidId(gMapSystem.lastRaidId)
	local indoorId = gMapSystem.lastIndoorId

	if indoorId <= 0 then
		local indoorCfg = LTConfig.IndoorConfig.GetConfig(indoorId)

		if indoorCfg then
			raidId = indoorCfg.ParentRaid or LTConfig.RaidConfig.WorldMap
		else
			raidId = LTConfig.RaidConfig.WorldMap
		end
	end

	gPanelManager:CheckShow(gPanelId.S_NEW_MAP_PANEL, {
		["KHyzK3="] = true,
		["\\xa2\\xbf\\xa4e,\\xd77"] = 0,
		raidId = raidId
	})
end

M.FashionLockMainPage = function()
	gMainPageManager:LockMainPage(gPanelId.S_FASHION_PORTAL_PANEL)
end

M.OpenFashionPortal = function()
	gDressManager:EnterFashionPortal(M.FashionLockMainPage)
end

M.OpenSurpriseGiftPanel = function(args)
	args = args or {}
	args.showType = gClientConst.MAIN_PHONE_ROOT_SHOW_TYPE.HackerSurpriseGift

	gMainPhoneUtils.ShowPhoneAppContent(args)
end

gMainPhoneFunctionAction = M
