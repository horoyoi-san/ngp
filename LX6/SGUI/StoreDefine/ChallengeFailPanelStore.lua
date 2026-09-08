-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ChallengeFailPanelStore.lua
-- Decompiled from: 01551_ChallengeFailPanelStore.lua_5e3164fdfca7.luajit

C_ChallengeFailPanelStore = DefClass("C_ChallengeFailPanelStore", C_ChallengeFailPanelStore, C_StoreGroup)
GroupName2Class.ChallengeFailPanelStore = C_ChallengeFailPanelStore
local M = C_ChallengeFailPanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	self.isOperated = false
end

M.OnClose = function(self)
	if not self.isOperated then
		self.OnClickBackBtn(self)
	end
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.backBtn.luaClick = self.CreateAction(self, self.OnClickBackBtn)
	self.bindData.againBtn.luaClick = self.CreateAction(self, self.OnClickAgainBtn)
end

M.OnClickBackBtn = function(self)
	self.isOperated = true

	gWushuTournamentManager:LeaveWushuTournament()
end

M.OnClickAgainBtn = function(self)
	self.isOperated = true
	local action = UX.Game.WushuTournamentPostSettlementAction.Retry

	gWushuTournamentManager:RequestPostSettlement(gWushuTournamentManager.curRoundId, action)
end
