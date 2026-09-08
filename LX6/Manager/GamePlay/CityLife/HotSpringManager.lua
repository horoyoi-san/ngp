-- Original chunk: @Lua\LuaFiles\LX6\Manager\GamePlay\CityLife\HotSpringManager.lua
-- Decompiled from: 00728_HotSpringManager.lua_e2c163d6c371.luajit

local OnsenNpcdailyConfig = LTConfig.OnsenNpcdailyConfig
local MessageConfig = LTConfig.MessageConfig
local GameplayHudDescGroupConfig = LTConfig.GameplayHudDescGroupConfig
local StaticProps = {}
C_HotSpringManager = DefClass("C_HotSpringManager", C_HotSpringManager, nil, StaticProps)
local M = C_HotSpringManager
local OnsenType = {
	["\\x86\\x84)\\x9fC\\xd2"] = 2,
	["/a\\xbf\\xa9\\xafd"] = 1
}
local OnsenType2GameplayType = {
	[OnsenType.SINGLE] = GameplayHudDescGroupConfig.SINGLE_ONSEN,
	[OnsenType.MULTIPLE] = GameplayHudDescGroupConfig.SINGLE_ONSEN
}

M.ctor = function(self)
	self:OnInit()
end

M.OnInit = function(self)
	self.info = {}
	self.inGuess = false
	self.npcId = 0
end

M.OnBeginPlay = function(self, type)
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

M.OnInviteNpc = function(self, npcUnit)
	local pid = npcUnit.Pid
	local npcId = gSpiritAcquisitionManager:GetTemplateIdByPid(pid)

	if not npcId then
		return
	end

	for i = 0, OnsenNpcdailyConfig.count - 1 do
		local cfg = OnsenNpcdailyConfig.LoadAt(i)

		if cfg.Npcid ~= npcId then
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

M.OnBeginStageOfPlay = function(self)
end

M.OnEndStageOfPlay = function(self)
	gPanelManager:Close(gPanelId.GAMEPLAY_HUD_PRO_PANEL)
end

M.OnSyncHotSpringInfo = function(self, info)
	self.info = info
end

M.AskUseOnsenTicket = function(self)
	gClientToGameDelegate:AskHotSpringUseTicket().Callback = function (err)
		if err == MessageConfig.Ok then
			gDisplayMessageMgr:ShowMessage(err)

			return
		end
	end
end

M.AskHotSpringStart = function(self)
	gClientToGameDelegate:AskHotSpringStart().Callback = function (err)
		if err == MessageConfig.Ok then
			gDisplayMessageMgr:ShowMessage(err)

			return
		end
	end
end

M.AskInviteHotSpringNpc = function(self, npcid)
	gClientToGameDelegate:AskHotSpringInviteCompanionNpc(npcid).Callback = function (err)
		if err == MessageConfig.Ok then
			gDisplayMessageMgr:ShowMessage(err)

			return
		end
	end
end

M.AskHotSpringSettlement = function(self)
	gClientToGameDelegate:AskHotSpringSettlement().Callback = function (err)
		if err == MessageConfig.Ok then
			gDisplayMessageMgr:ShowMessage(err)

			return
		end
	end
end

M.GetInviteAgentId = function(self)
	local cfg = OnsenNpcdailyConfig.GetConfig(self.npcId)

	return cfg and cfg.AgentId or 0
end

gHotSpringManager = gHotSpringManager or C_HotSpringManager.new()
