local OnsenNpcdailyConfig = LTConfig.OnsenNpcdailyConfig
local MessageConfig = LTConfig.MessageConfig
local GameplayHudDescGroupConfig = LTConfig.GameplayHudDescGroupConfig
local StaticProps = {}
C_HotSpringManager = DefClass("C_HotSpringManager", C_HotSpringManager, nil, StaticProps)
local M = C_HotSpringManager
local OnsenType = {
	MULTIPLE = 2,
	SINGLE = 1
}
local OnsenType2GameplayType = {
	[OnsenType.SINGLE] = GameplayHudDescGroupConfig.SINGLE_ONSEN,
	[OnsenType.MULTIPLE] = GameplayHudDescGroupConfig.SINGLE_ONSEN
}

function M:ctor()
	self:OnInit()
end

function M:OnInit()
	self.info = {}
	self.inGuess = false
	self.npcId = 0
end

function M:OnBeginPlay(type)
	self.inGuess = false
	local gameplayType = OnsenType2GameplayType[type]

	if not gameplayType then
		print_error("[C_HotSpringManager] OnBeginPlay failed, type =", type)

		return
	end

	gPanelManager:CheckShow(gPanelId.GAMEPLAY_HUD_PRO_PANEL, {
		groupId = gameplayType,
		backCallback = self:CreateAction("OnEndStageOfPlay"),
		showCallback = self:CreateAction("OnBeginStageOfPlay")
	})
end

function M:OnInviteNpc(npcUnit)
	local pid = npcUnit.Pid
	local npcId = gSpiritAcquisitionManager:GetTemplateIdByPid(pid)

	if not npcId then
		return
	end

	for i = 0, OnsenNpcdailyConfig.count - 1 do
		local cfg = OnsenNpcdailyConfig.LoadAt(i)

		if cfg.Npcid == npcId then
			self.npcId = cfg.Id
			local favorLevel = gSpiritAcquisitionManager:GetSpiritFavorLevel(npcId)
			local dialogId = cfg.DialogList[favorLevel]

			if dialogId then
				gDialogManager:ShowDialogInteractionActionFinish(dialogId, npcUnit)
			end

			break
		end
	end

	self:AskInviteHotSpringNpc(npcId)
end

function M:OnBeginStageOfPlay()
	return
end

function M:OnEndStageOfPlay()
	gPanelManager:Close(gPanelId.GAMEPLAY_HUD_PRO_PANEL)
end

function M:OnSyncHotSpringInfo(info)
	self.info = info
end

function M:AskUseOnsenTicket()
	gClientToGameDelegate:AskHotSpringUseTicket().Callback = function (err)
		if err ~= MessageConfig.Ok then
			gDisplayMessageMgr:ShowMessage(err)

			return
		end
	end
end

function M:AskHotSpringStart()
	gClientToGameDelegate:AskHotSpringStart().Callback = function (err)
		if err ~= MessageConfig.Ok then
			gDisplayMessageMgr:ShowMessage(err)

			return
		end
	end
end

function M:AskInviteHotSpringNpc(npcid)
	gClientToGameDelegate:AskHotSpringInviteCompanionNpc(npcid).Callback = function (err)
		if err ~= MessageConfig.Ok then
			gDisplayMessageMgr:ShowMessage(err)

			return
		end
	end
end

function M:AskHotSpringSettlement()
	gClientToGameDelegate:AskHotSpringSettlement().Callback = function (err)
		if err ~= MessageConfig.Ok then
			gDisplayMessageMgr:ShowMessage(err)

			return
		end
	end
end

function M:GetInviteAgentId()
	local cfg = OnsenNpcdailyConfig.GetConfig(self.npcId)

	return cfg and cfg.AgentId or 0
end

gHotSpringManager = gHotSpringManager or C_HotSpringManager.new()
