-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\MotionInviteMsgPanelStore.lua
-- Decompiled from: 01052_MotionInviteMsgPanelStore.lua_283df0eae0de.luajit

C_MotionInviteMsgPanelStore = DefClass("C_MotionInviteMsgPanelStore", C_MotionInviteMsgPanelStore, C_StoreGroup)
GroupName2Class.MotionInviteMsgPanelStore = C_MotionInviteMsgPanelStore
local M = C_MotionInviteMsgPanelStore

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.bindData.cancelButton.luaClick = self.CreateAction(self, "OnCancelClick")
	self.bindData.confirmButton.luaClick = self.CreateAction(self, "OnConfirmClick")

	self.InitMessages(self)
end

M.InitMessages = function(self)
	local eventHandlers = {
		[gEventConstants.ON_SYNC_CANCEL_INVITE_PLAYER_ACTION] = self.CreateAction(self, "OnCancelPlayAction"),
		[gEventConstants.ON_SYNC_CANCEL_INVITEE_PLAYER_ACTION] = self.CreateAction(self, "OnCancelPlayAction"),
		[gEventConstants.TIMELINE_START] = function ()
			gPanelManager:Close(self.panelId)
		end
	}

	self.RegisterMessageEvents(self, eventHandlers)
end

M.OnShow = function(self, panelId, args)
	self.panelId = panelId

	self.InitModel(self, args)
	self.InitView(self, args)
end

M.InitModel = function(self, args)
	self.lastRotatedEnable = gCS.CameraDataMgr.cameraControllerManager.IsRotateEnabled
	self.pid = args.pid
	self.actionId = args.actionId
	self.startSeverTime = gLuaDataManager.serverTime
end

M.InitView = function(self, _)
	gCS.CameraDataMgr.cameraControllerManager.IsRotateEnabled = true
	local name = gBattleNetcodeUtils:GetUserName(self.pid)
	local actionItemCfg = LTConfig.ActionItemConfig.GetConfig(self.actionId)
	local actionItemName = actionItemCfg and actionItemCfg.Name or ""
	self.bindData.description = LTConfig.ActionItemConfig.InviteDescription:format(name, actionItemName)

	self:RefreshCountdownView()
end

M.RefreshCountdownView = function(self)
	if self.bindData.uProgress then
		self.bindData.uProgress.value = (gLuaDataManager.serverTime - self.startSeverTime) / LTConfig.ActionItemConfig.InviteCountdownTime
	end

	local diffTime = math.floor(gLuaDataManager.serverTime - self.startSeverTime)
	self.bindData.rejectText = LTConfig.TextScriptTextConfig.GetConfig(89901220).Text:format(LTConfig.ActionItemConfig.InviteCountdownTime - diffTime)
end

M.OnUpdate = function(self)
	self.RefreshCountdownView(self)

	if LTConfig.ActionItemConfig.InviteCountdownTime < gLuaDataManager.serverTime - self.startSeverTime then
		gPanelManager:Close(self.panelId)

		return
	end
end

M.OnCancelClick = function(self)
	local replyState = UX.Game.InteractionActionInviteReplyState.Reject
	slot2 = gClientToGameDelegate

	slot2:AskReplyInvitePlayerInteractionAction(replyState).Callback = function (errorId)
		if errorId == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end

		gPanelManager:Close(self.panelId)
	end
end

M.OnConfirmClick = function(self)
	gCS.BaseUnitModuleUtils.LeaveTaffyMoto(gCS.MyPlayerManager.PlayerUnit)
	gCS.LuaUtils.ManualCheckAnimLookAtIKOff()

	local replyState = UX.Game.InteractionActionInviteReplyState.Accept
	slot2 = gClientToGameDelegate

	slot2:AskReplyInvitePlayerInteractionAction(replyState).Callback = function (errorId)
		if errorId == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end

		gPanelManager:Close(gPanelId.CHAR_MOTION_LIST_PANEL)
		gPanelManager:Close(self.panelId)
	end
end

M.OnCancelPlayAction = function(self, _, interactionActionState)
	if interactionActionState == UX.Game.InteractionActionState.InvitingTimeout then
		gDisplayMessageMgr:ShowMessageContent(LTConfig.ActionItemConfig.InvitePlayerExitInteractTips)
	end

	gPanelManager:Close(self.panelId)
end

M.OnDestroy = function(self)
	gCS.CameraDataMgr.cameraControllerManager.IsRotateEnabled = self.lastRotatedEnable
	self.countdownCo = coroutine.stop(self.countdownCo)

	self.ClearMessageEvents(self)
end
