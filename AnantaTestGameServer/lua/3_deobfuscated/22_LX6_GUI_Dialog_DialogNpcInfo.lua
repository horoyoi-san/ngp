local M = DefClass("C_DialogNpcInfo")

function M:ctor(id, isCultivationNpc, cfg)
	self.templateId = id
	self.isCultivationNpc = isCultivationNpc

	if self.isCultivationNpc then
		self.npcCultivationCfg = cfg
	else
		self.normalNpcCfg = cfg
	end
end

function M:GetIcon()
	if self.isCultivationNpc then
		return LTConfig.NpcCultivationConfig.GetConfig(self.templateId).ChatHeadId.DefaultImage
	else
		return self.normalNpcCfg.NpcHeadicon
	end
end

function M:GetName()
	if self.isCultivationNpc then
		return self.npcCultivationCfg.Name
	else
		return self.normalNpcCfg.NpcName
	end
end

function M:GetSignature()
	if self.isCultivationNpc then
		return self.npcCultivationCfg.ChatSign
	else
		return self.normalNpcCfg.NpcSign
	end
end

return M
