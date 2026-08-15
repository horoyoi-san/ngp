local PopupConfig = LTConfig.PopupConfig
local ProgressConfig = LTConfig.LinkProgressConfig
local M = {
	OnLinkRoomBegin = function (self)
		gNewPopupManager:PushPopup(PopupConfig.S_OnlinePlayInvitingTip, {
			groupId = ProgressConfig.Invite
		})
	end,
	OnFullConfirmBegin = function (self)
		gPanelManager:CheckShow(gPanelId.S_ONLINE_PLAY_READY_PANEL)
	end,
	OnHalfConfirmBegin = function (self)
		gMessageManager:SendMessage(gEventConstants.LINK_PROGRESS_VISIBILITY_CHANGE, {
			visible = true,
			groupId = ProgressConfig.halfConfirm
		})
	end,
	OnLinkRoomConfirm = function (self, data)
		gLinkManager:AskReplyToFriendRoomInvite(data.roomId, data.pid, true)
	end,
	OnMatchReadyConfirm = function (self, data)
		gLinkManager:AskConfirm(true)
	end,
	OnLinkRoomCancel = function (self, data)
		gLinkManager:AskReplyToFriendRoomInvite(data.roomId, data.pid, false)
	end,
	OnMatchReadyCancel = function (self, data)
		gLinkManager:AskConfirm(false)
	end,
	OnLinkRoomEnd = function (self, groupId, data, isOutTime)
		gPanelManager:Close(gPanelId.S_ONLINE_ROOM_INVITE_MESG)
	end,
	OnMatchReadyFinish = function (self, groupId, data, isOutTime)
		if groupId == ProgressConfig.halfConfirm then
			gMessageManager:SendMessage(gEventConstants.LINK_PROGRESS_VISIBILITY_CHANGE, {
				visible = false,
				groupId = ProgressConfig.halfConfirm
			})
		end

		if isOutTime then
			gLinkManager:OnMemberRejectConfirm()
		end
	end,
	OnLinkRoomRender = function (self, store, progress, data)
		store.bindData.pid = data.pid
		store.bindData.titleLabel = gLinkManager:GetPlayModeName(data.gameId)
	end,
	OnFullConfirmRender = function (self, store, progress, data)
		local modeId = gLinkManager.targetPlayId
		store.bindData.titleLabel = gLinkManager:GetPlayModeName(modeId)
		local isNotReady = not gLinkManager:CheckPlayerIsReady()
		store.bindData.acceptBtn.interactable = isNotReady
		store.bindData.rejectBtn.interactable = isNotReady
	end,
	OnHalfConfirmRender = function (self, store, progress, data)
		local isNotReady = not gLinkManager:CheckPlayerIsReady()
		store.bindData.acceptBtn.interactable = isNotReady
		store.bindData.rejectBtn.interactable = isNotReady
	end
}

return M
