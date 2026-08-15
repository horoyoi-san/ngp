C_MotionInviteMsgPanelStore = DefClass("C_MotionInviteMsgPanelStore", C_MotionInviteMsgPanelStore, C_StoreGroup)
GroupName2Class.MotionInviteMsgPanelStore = C_MotionInviteMsgPanelStore
local M = C_MotionInviteMsgPanelStore

function M:ctor()
	return
end

function M:OnAwake()
	self.bindData.cancelButton.luaClick = self:CreateAction("OnCancelClick")
	self.bindData.confirmButton.luaClick = self:CreateAction("OnConfirmClick")

	self:InitMessages()
end

function M:InitMessages()
	local eventHandlers = {
		[gEventConstants.ON_SYNC_CANCEL_INVITE_PLAYER_ACTION] = self:CreateAction("OnCancelPlayAction"),
		[gEventConstants.ON_SYNC_CANCEL_INVITEE_PLAYER_ACTION] = self:CreateAction("OnCancelPlayAction"),
		[gEventConstants.TIMELINE_START] = function ()
			gPanelManager:Close(self.panelId)
		end
	}

	self:RegisterMessageEvents(eventHandlers)
end

function M:OnShow(panelId, args)
	self.panelId = panelId

	self:InitModel(args)
	self:InitView(args)
end

function M:InitModel(args)
	self.pid = args.pid
	self.actionId = args.actionId
	self.startSeverTime = gLuaDataManager.serverTime
end

function M:InitView(_)
	local name = gBattleNetcodeUtils:GetUserName(self.pid)
	local actionItemCfg = LTConfig.ActionItemConfig.GetConfig(self.actionId)
	local actionItemName = actionItemCfg and actionItemCfg.Name or ""
	self.bindData.description = LTConfig.ActionItemConfig.InviteDescription:format(name, actionItemName)

	self:RefreshCountdownView()
end

function M:RefreshCountdownView()
	if self.bindData.uProgress then
		self.bindData.uProgress.value = (gLuaDataManager.serverTime - self.startSeverTime) / LTConfig.ActionItemConfig.InviteCountdownTime
	end

	local diffTime = math.floor(gLuaDataManager.serverTime - self.startSeverTime)
	self.bindData.rejectText = LTConfig.TextScriptTextConfig.GetConfig(89901220).Text:format(LTConfig.ActionItemConfig.InviteCountdownTime - diffTime)
end

function M:OnUpdate()
	self:RefreshCountdownView()

	if LTConfig.ActionItemConfig.InviteCountdownTime <= gLuaDataManager.serverTime - self.startSeverTime then
		gPanelManager:Close(self.panelId)

		return
	end
end

function M:OnCancelClick()
	gClientToGameDelegate:AskReplyInvitePlayerInteractionAction(false).Callback = function (errorId)
		if errorId ~= LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end

		gPanelManager:Close(self.panelId)
	end
end

function M:OnConfirmClick()
	gClientToGameDelegate:AskReplyInvitePlayerInteractionAction(true).Callback = function (errorId)
		if errorId ~= LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end

		gPanelManager:Close(gPanelId.CHAR_MOTION_LIST_PANEL)
		gPanelManager:Close(self.panelId)
	end
end

function M:OnCancelPlayAction(_, interactionActionState)
	if interactionActionState ~= UX.Game.InteractionActionState.InvitingTimeout then
		gDisplayMessageMgr:ShowMessageContent(LTConfig.ActionItemConfig.InvitePlayerExitInteractTips)
	end

	gPanelManager:Close(self.panelId)
end

function M:OnDestroy()
	self.countdownCo = coroutine.stop(self.countdownCo)

	self:ClearMessageEvents()
end
