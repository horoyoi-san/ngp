C_CharMotionStopButtonPanelStore = DefClass("C_CharMotionStopButtonPanelStore", C_CharMotionStopButtonPanelStore, C_StoreGroup)
GroupName2Class.CharMotionStopButtonPanelStore = C_CharMotionStopButtonPanelStore
local M = C_CharMotionStopButtonPanelStore

function M:ctor()
	return
end

function M:OnAwake()
	self.bindData.stopButton.luaClick = self:CreateAction("OnStopClick")

	self:InitMessages()
end

function M:InitMessages()
	local eventHandlers = {
		[gEventConstants.ON_SYNC_CANCEL_INVITE_PLAYER_ACTION] = self:CreateAction("OnCancelPlayAction"),
		[gEventConstants.ON_SYNC_CANCEL_INVITEE_PLAYER_ACTION] = self:CreateAction("OnCancelPlayAction")
	}

	self:RegisterMessageEvents(eventHandlers)
end

function M:OnShow(_, args)
	self:InitModel(args)
	self:InitView(args)
end

function M:InitModel(args)
	self.pid = args.invitePid
end

function M:InitView(args)
	local actionId = args.actionId
	local actionItemCfg = LTConfig.ActionItemConfig.GetConfig(actionId)

	if actionItemCfg and actionItemCfg.IsLoopAction then
		self.bindData.stopButton:SetActive(true)
	else
		self.bindData.stopButton:SetActive(false)
	end
end

function M:OnStopClick()
	gClientToGameDelegate:AskCancelInviteePlayerInteractionAction().Callback = function (errorId)
		if errorId ~= LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end
	end

	gPanelManager:Close(self.m_Id)
end

function M:OnCancelPlayAction(_, interactionActionState)
	if interactionActionState ~= UX.Game.InteractionActionState.Cancel then
		gDisplayMessageMgr:ShowMessageContent(LTConfig.ActionItemConfig.InvitePlayerExitInteractTips)
	end

	gPanelManager:Close(self.m_Id)
end

function M:OnDestroy()
	self:ClearMessageEvents()
end
