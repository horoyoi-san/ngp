-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CampBattleTalentTreePanelStore.lua
-- Decompiled from: 02023_CampBattleTalentTreePanelStore.lua_c2bfbe1c5e3c.luajit

C_CampBattleTalentTreePanelStore = DefClass("C_CampBattleTalentTreePanelStore", C_CampBattleTalentTreePanelStore, C_CommonTalentTreePanelStore)
GroupName2Class.CampBattleTalentTreePanelStore = C_CampBattleTalentTreePanelStore
local M = C_CampBattleTalentTreePanelStore

M.OnRefreshBackGroudStore = function(self, store)
	if not self.cfg then
		return
	end

	local talentDict = self.mgr:GetCurrentTalentDict(self.cfg.JobClassId)
	local talentCount = table.count(talentDict)
	store.stage = self.stage - 1
	store.stageLockLabel = talentCount .. "/" .. self.nextStageCount
end
