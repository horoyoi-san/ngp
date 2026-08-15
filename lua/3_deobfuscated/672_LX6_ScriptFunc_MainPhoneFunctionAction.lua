local M = {
	OpenShoppingMall = function ()
		return
	end,
	OpenChat = function (args)
		gChatUtils.OpenChatPanel(args)
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
		gMainMenuMgr:ClickTaskOnTaskAndTeamState()
	end,
	OpenMap = function ()
		gClientUtils.OpenMap()
	end,
	OpenTeaching = function ()
		gPanelManager:CheckShow(gPanelId.S_GUIDE_MAIN_PANEL)
	end,
	OpenPackage = function ()
		gPanelManager:CheckShow(gPanelId.S_INVENTORY_PANEL)
	end,
	OpenSocialMedia = function (args)
		args = args or {}

		gNewBubbleMgr:SwitchCurrentPanel(args)
	end,
	OpenChaosMasterCharacterPanel = function ()
		gPanelManager:CheckShow(gPanelId.CHAOS_CULTIVATION_MAIN_PANEL)
	end
}

function M.OpenUberSim(args)
	args = args or {}
	local teachEventId = LTConfig.UberSimConfig.TeachEventId
	local eventState = gTaskManager:GetTaskEventState(teachEventId)
	args.eventSubmited = eventState == UX.Game.TaskEventState.Submited
	args.eventDoing = false

	if not args.eventSubmited then
		local nowDoingTask = gTaskNodeManager:GetNowDoingTask()

		if nowDoingTask and nowDoingTask > 0 then
			args.eventDoing = gTaskNodeManager:GetEventIdByTask(nowDoingTask) == teachEventId
		end
	end

	if (args.eventSubmited or args.eventDoing) and gSpiritJobManager.GetCurSpiritJobClassId() == LTConfig.UrbanJobJobClassConfig.Delivery then
		gClientToGameDelegate:AskGetTruckJobOrders().Callback = function (errorId, clientTruckOrderView)
			if errorId ~= LTConfig.MessageConfig.Ok then
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

function M.OpenPolice(args)
	gPoliceJobManager.panelMgr:OpenMainPanel(args)
end

function M.OpenSocialNetwork(args)
	args = args or {
		isFromMainPhone = true,
		showType = gClientConst.MAIN_PHONE_ROOT_SHOW_TYPE.YanJie
	}

	gPanelManager:CheckShow(gPanelId.YANJIE_APP_HOME_PANEL, args)
end

function M.OpenTeam()
	gLinkManager:ShowLinkPanel()
end

function M.OpenCallPhone(args)
	args = args or {}
	args.showType = gClientConst.MAIN_PHONE_ROOT_SHOW_TYPE.CallPhone
	args.secondShowType = args.secondShowType or gClientConst.CallPhoneShowType.Contact
	args.isFromMainPhone = true

	gMainPhoneUtils.ShowPhoneAppContent(args)
end

function M.OpenTime(args)
	args = args or {}
	args.showType = gClientConst.MAIN_PHONE_ROOT_SHOW_TYPE.Time

	gMainPhoneUtils.ShowPhoneAppContent(args)
end

function M.OpenTakePhoto()
	return gTakePhotoUtils.TryTakePhoto()
end

function M.OpenSetting()
	gPanelManager:CheckShow(gPanelId.S_SETTINGS_PANEL)
end

function M.OpenNotice()
	gAnnouncementMgr:OpenNoticePanel()
end

function M.OpenEmail()
	gMainPageManager:MailOpenTrigger()
end

function M.OpenMessage(args)
	args = args or {}
	args.OpenMessage = true

	gNpcChatUtils.OpenChatPanel(args)
end

function M.OpenHackerApp(args)
	args = args or {}
	args.showType = gClientConst.MAIN_PHONE_ROOT_SHOW_TYPE.Hacker

	gMainPhoneUtils.ShowPhoneAppContent(args)
end

function M.OpenDeliveryGuidePanel(args)
	args = args or {}

	gClientToGameDelegate:AskGetTruckJobOrders().Callback = function (errorId, clientTruckOrderView)
		if errorId ~= LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end

		args.showType = gClientConst.MAIN_PHONE_ROOT_SHOW_TYPE.DeliveryGuide
		args.clientTruckOrderView = clientTruckOrderView

		gMainPhoneUtils.ShowPhoneAppContent(args)
	end
end

function M.OpenWallPaperPanel(args)
	args = args or {}
	args.showType = gClientConst.MAIN_PHONE_ROOT_SHOW_TYPE.WallPaper

	gMainPhoneUtils.ShowPhoneAppContent(args)
end

function M.OpenCharMotionPanel(args)
	gPanelManager:CheckShow(gPanelId.CHAR_MOTION_LIST_PANEL, args)
end

function M.OpenAgentProfile()
	gPanelManager:CheckShow(gPanelId.NEW_AGENT_PROFILE_PANEL)
end

function M.OpenTalentTree()
	gMainPageManager:TalentTreeOpenTrigger()
end

function M.OpenWasher(args)
	args = args or {}
	args.showType = gClientConst.MAIN_PHONE_ROOT_SHOW_TYPE.Washer
	args.secondShowType = args.secondShowType or gClientConst.WASHER_APP_SHOW_TYPE.ORDER

	gClientToGameDelegate:AskGetWasherMissionInfo(false).Callback = function (errorId, washerJobInfo)
		if errorId ~= LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)
			gWasherManager:ResetWasherJobInfo()

			return
		end

		args.washerJobInfo = washerJobInfo

		gWasherManager:SetWasherJobInfo(washerJobInfo)
		gMainPhoneUtils.ShowPhoneAppContent(args)
	end
end

function M.OpenWeaponArmory()
	gPanelManager:CheckShow(gPanelId.S_WEAPON_ARMORY_MAIN_PANEL, {
		mode = 1
	})
end

function M.OpenPoliceArchive()
	gMainPageManager:PoliceArchiveOpenTrigger()
end

function M.OpenInspireHub()
	gPanelManager:CheckShow(gPanelId.INSPIRE_HUB_PANEL)
end

function M.OpenParty(args)
	args = args or {}
	args.showType = gClientConst.MAIN_PHONE_ROOT_SHOW_TYPE.Party
	args.secondShowType = args.secondShowType or gClientConst.PartyShowType.PartySelect

	gMainPhoneUtils.ShowPhoneAppContent(args)
end

function M.OpenFeedback()
	gMainPhoneUtils.CloseMainPhonePanel(true)
	LX6.Utils.Feedback.FeedbackUtils.GetScreenShot(function (tex)
		gPanelManager:CheckShow(gPanelId.FEEDBACK_PANEL, {
			imageList = {
				{
					name = "screenshot",
					tex = tex
				}
			}
		})
	end)
end

gMainPhoneFunctionAction = M
