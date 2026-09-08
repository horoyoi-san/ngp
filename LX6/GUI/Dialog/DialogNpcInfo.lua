-- Original chunk: @Lua\LuaFiles\LX6\GUI\Dialog\DialogNpcInfo.lua
-- Decompiled from: 00313_DialogNpcInfo.lua_80965391ee06.luajit

local M = DefClass("C_DialogNpcInfo")

M.ctor = function(self, id, isCultivationNpc, cfg)
	self.templateId = id
	self.isCultivationNpc = isCultivationNpc

	if self.isCultivationNpc then
		self.npcCultivationCfg = cfg
	else
		self.normalNpcCfg = cfg
	end
end

M.GetIcon = function(self)
	if self.isCultivationNpc then
		return LTConfig.NpcCultivationConfig.GetConfig(self.templateId).ChatHeadId.DefaultImage
	else
		return self.normalNpcCfg.NpcHeadicon
	end
end

M.GetName = function(self)
	if self.isCultivationNpc then
		return self.npcCultivationCfg.Name
	else
		return self.normalNpcCfg.NpcName
	end
end

M.GetSignature = function(self)
	if self.isCultivationNpc then
		return self.npcCultivationCfg.ChatSign
	else
		return self.normalNpcCfg.NpcSign
	end
end

return M
