-- Original chunk: @Lua\LuaFiles\LX6\Manager\AgentWeaponManager.lua
-- Decompiled from: 00315_AgentWeaponManager.lua_e2af50ba371a.luajit

local SummonSkillInfoConfig = LTConfig.SummonSkillInfoConfig
C_AgentWeaponManager = DefClass("C_AgentWeaponManager", C_AgentWeaponManager, nil)
local M = C_AgentWeaponManager

M.ctor = function(self)
	self.agentWeaponSlotDict = {}
	self.agentCurrentWeaponDict = {}
	self.weaponId2InfoId = {}
	self.DEFAULT_NAME = 719
end

M.OnInit = function(self)
	for i = 0, SummonSkillInfoConfig.count - 1 do
		local cfg = SummonSkillInfoConfig.LoadAt(i)

		if cfg then
			self.weaponId2InfoId[cfg.WeaponId] = cfg.Id
		end
	end
end

M.SyncAgentWeaponWheel = function(self, agentId, currentWeaponId, weaponSlots)
	self.agentWeaponSlotDict[agentId] = table.clone(weaponSlots)
	self.agentCurrentWeaponDict[agentId] = currentWeaponId

	gMessageManager:SendMessageMultiParamLuaOnly(gEventConstants.AGENT_CURRENT_WEAPON_CHANGE, agentId, currentWeaponId)
end

M.SyncAgentChangeWeapon = function(self, agentId, weaponId)
	self.agentCurrentWeaponDict[agentId] = weaponId

	gMessageManager:SendMessageMultiParamLuaOnly(gEventConstants.AGENT_CURRENT_WEAPON_CHANGE, agentId, weaponId)
end

M.SyncRemoveAgent = function(self, agentId)
	self.agentWeaponSlotDict[agentId] = nil
	self.agentCurrentWeaponDict[agentId] = nil

	gMessageManager:SendMessageMultiParamLuaOnly(gEventConstants.AGENT_CURRENT_WEAPON_CHANGE, agentId, nil)
end

M.GetAgentWeaponWheel = function(self, agentId)
	return self.agentWeaponSlotDict[agentId]
end

M.GetAgentCurrentWeapon = function(self, agentId)
	return self.agentCurrentWeaponDict[agentId]
end

M.GetAgentWeaponInfoCfg = function(self, weaponId)
	if weaponId and self.weaponId2InfoId[weaponId] then
		local cfg = SummonSkillInfoConfig.GetConfig(self.weaponId2InfoId[weaponId])

		if not cfg then
			print_error("SummonSkillInfoConfig 找不到武器的文本提示信息, weaponId=", weaponId, " 请找策划配置 @shichenyang@corp.netease.com")
		end

		return cfg
	end

	return nil
end

gAgentWeaponManager = gAgentWeaponManager or C_AgentWeaponManager.new()
