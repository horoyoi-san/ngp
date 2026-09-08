-- Original chunk: @Lua\LuaFiles\LX6\Manager\Link\LinkProgressEvent.lua
-- Decompiled from: 02250_LinkProgressEvent.lua_7928181f275b.luajit

local PopupConfig = LTConfig.PopupConfig
local ProgressConfig = LTConfig.LinkProgressConfig
local LineConfig = LTConfig.LinkLineConfig
local M = {
	OnFullConfirmBegin = function (self)
		gPanelManager:CheckShow(gPanelId.S_ONLINE_PLAY_READY_PANEL)
	end,
	OnHalfConfirmBegin = function (self)
		gPanelManager:CheckShow(gPanelId.ONLINE_HALF_PROGRESS, {
			groupId = ProgressConfig.halfConfirm
		})
	end,
	OnInGameVoteBegin = function (self)
		gPanelManager:CheckShow(gPanelId.ONLINE_HALF_PROGRESS, {
			groupId = ProgressConfig.InGameVote
		})
	end,
	AskPartyMiniGameConfirm = function (self, data)
		slot2 = gClientToGameDelegate

		slot2:AskConfirmPartyMiniGameMatch(data.gameConfigId, true).Callback = function (err)
			if err == LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)

				return
			end
		end
	end,
	AskPartyMiniGameCancel = function (self, data)
		slot2 = gClientToGameDelegate

		slot2:AskConfirmPartyMiniGameMatch(data.gameConfigId, false).Callback = function (err)
			if err == LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)

				return
			end

			gPanelManager:Close(gPanelId.S_ONLINE_PLAY_READY_PANEL)
			gPanelManager:Close(gPanelId.ONLINE_HALF_PROGRESS)
		end
	end,
	OnFullScreenReadyConfirm = function (self, data)
		if data and data.partyMiniGameMatch then
			self.AskPartyMiniGameConfirm(self, data)

			return
		end

		gLinkManager:AskConfirm(true, LTConfig.LinkStageConfig.FullScreenConfirm)
	end,
	OnHalfScreenReadyConfirm = function (self, data)
		if data and data.partyMiniGameMatch then
			self.AskPartyMiniGameConfirm(self, data)

			return
		end

		gLinkManager:AskConfirm(true, LTConfig.LinkStageConfig.BubbleConfirm)
	end,
	OnInGameVoteConfirm = function (self, data)
		gLinkManager:ConfirmSurrender()
	end,
	OnMatchReadyCancel = function (self, data)
		gLinkManager:AskConfirm(false)
	end,
	OnFullScreenReadyCancel = function (self, data)
		if data and data.partyMiniGameMatch then
			self.AskPartyMiniGameCancel(self, data)

			return
		end

		gLinkManager:AskConfirm(false, LTConfig.LinkStageConfig.FullScreenConfirm)
	end,
	OnHalfScreenReadyCancel = function (self, data)
		if data and data.partyMiniGameMatch then
			self.AskPartyMiniGameCancel(self, data)

			return
		end

		gLinkManager:AskConfirm(false, LTConfig.LinkStageConfig.BubbleConfirm)
	end,
	OnInGameVoteCancel = function (self, data)
		gLinkManager:RejectSurrender()
	end,
	OnMatchReadyFinish = function (self, groupId, isOutTime)
		if groupId ~= ProgressConfig.halfConfirm then
			gPanelManager:Close(gPanelId.ONLINE_HALF_PROGRESS)

			return
		end

		if isOutTime then
			gLinkManager:OnMemberRejectConfirm()
		end
	end,
	OnInGameVoteFinish = function (self)
		gPanelManager:Close(gPanelId.ONLINE_HALF_PROGRESS)
		gLinkManager:OnInitVote()
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
	end,
	OnInGameVoteRender = function (self, store, progress, data)
		local isNotReady = not gLinkManager:CheckSelfIsSurrender()
		store.bindData.acceptBtn.interactable = isNotReady
		store.bindData.rejectBtn.interactable = isNotReady
	end
}
M.EventMap = {
	[ProgressConfig.fullConfirm] = {
		begin = M.OnFullConfirmBegin,
		confirm = M.OnFullScreenReadyConfirm,
		cancel = M.OnFullScreenReadyCancel,
		finish = M.OnMatchReadyFinish,
		render = M.OnFullConfirmRender
	},
	[ProgressConfig.halfConfirm] = {
		begin = M.OnHalfConfirmBegin,
		confirm = M.OnHalfScreenReadyConfirm,
		cancel = M.OnHalfScreenReadyCancel,
		finish = M.OnMatchReadyFinish,
		render = M.OnHalfConfirmRender
	},
	[ProgressConfig.InGameVote] = {
		begin = M.OnInGameVoteBegin,
		confirm = M.OnInGameVoteConfirm,
		cancel = M.OnInGameVoteCancel,
		finish = M.OnInGameVoteFinish,
		render = M.OnInGameVoteRender
	}
}

return M
