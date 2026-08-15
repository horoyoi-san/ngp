local M = {
	OnStateTreeEnter = function ()
		gMessageManager:SendMessage(gEventConstants.ON_ENTER_CHAR_MOTION_ANIMATION)
	end,
	OnStateTreeExit = function ()
		gMessageManager:SendMessage(gEventConstants.ON_EXIT_CHAR_MOTION_ANIMATION)
	end,
	MotionActionBreak = function (_)
		gMessageManager:SendMessage(gEventConstants.ON_EXIT_CHAR_MOTION_ANIMATION)
	end,
	OnClickPlayerInteract = function (self, npcUnit)
		gMainPhoneFunctionAction.OpenCharMotionPanel({
			isLinkMode = true,
			showType = gClientConst.MOTION_ACTION_SHOW_TYPE.Double,
			npcId = npcUnit.NpcId,
			npcUnit = npcUnit,
			npcPid = npcUnit.Pid
		})
	end
}

function M.InvitePlayerInteractionAction(pid, actionId)
	M.invitePid = pid
	M.actionId = actionId

	gPanelManager:CheckShow(gPanelId.MOTION_INVITE_MSG_PANEL, {
		pid = pid,
		actionId = actionId
	})
end

function M.SyncInviteeStartPlayAction()
	gPanelManager:CheckShow(gPanelId.CHAR_MOTION_STOP_BUTTON_PANEL, {
		invitePid = M.invitePid,
		actionId = M.actionId
	})
end

function M.GetPlayerInteractionActionInfo()
	return gPlayerManager.infoMinor.bindData.playerInteractionActionInfo
end

function M.CheckInviteNotDisturb()
	local playerInteractionActionInfo = M.GetPlayerInteractionActionInfo()

	return playerInteractionActionInfo and playerInteractionActionInfo.InvitedNotDisturb or false
end

function M.SetInviteNotDisturb(callback)
	local isEnableNotDisturb = M.CheckInviteNotDisturb()

	gClientToGameDelegate:AskEnableInvitedNotDisturb(not isEnableNotDisturb).Callback = function (errorId)
		if errorId ~= LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			if callback then
				callback()
			end

			return
		end

		local playerInteractionActionInfo = M.GetPlayerInteractionActionInfo()

		if playerInteractionActionInfo then
			playerInteractionActionInfo.InvitedNotDisturb = not isEnableNotDisturb
		end

		if callback then
			callback()
		end
	end
end

gCharMotionUtils = M
