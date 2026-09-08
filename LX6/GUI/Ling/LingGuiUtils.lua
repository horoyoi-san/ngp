-- Original chunk: @Lua\LuaFiles\LX6\GUI\Ling\LingGuiUtils.lua
-- Decompiled from: 00535_LingGuiUtils.lua_8eae140784fe.luajit

local GeneralModelConfig = LTConfig.GeneralModelConfig
local M = {
	GetAllLingList = function (self)
		local lingList = {}
		slot2 = gSpiritManager

		slot2:Foreach(function (spirit)
			table.insert(lingList, self:GetCardData(spirit))
		end)

		return lingList
	end
}

M.GetCardData = function(self, spirit)
	if not spirit or not spirit.config then
		return nil
	end

	local agentId = spirit.config.AgentId
	local agentConfig = LTConfig.AgentConfig.GetConfig(agentId)
	local data = {
		["/M\\x9d\\x8b\\x80U"] = false,
		["\\xe8\\xce0\\xe8"] = 0,
		["G\\xf4(\\xfb?.\\xcdf\\xddJ\\x82l\\xd3\\xeb"] = false,
		["R#k^"] = true,
		["\\xd0\\xc810\\xe8"] = false,
		["`Rϳ\\x83+\\xb0\\xc7\\xef"] = false,
		["@c\\xb8{E\\xbc\\xf7devq^"] = 0,
		["1\\xeb^\"\r\\xf3\\xb7O\\xa6x\\xa5\\xbb"] = 0,
		Id = spirit.Id,
		Name = spirit.Name,
		Lv = spirit.Lv,
		LiHui = spirit.Image,
		sIcon = spirit.config and spirit.config.SHeadIconID,
		Domain = spirit.Domain,
		Tid = spirit.Tid,
		QualityColor = spirit.QualityColor,
		FightHp = spirit.FightHp,
		FightAtk = spirit.FightAtk,
		FightPhyDef = spirit.FightPhyDef,
		Star = spirit.Star,
		ElementType = spirit.ElementType,
		Sex = agentConfig and agentConfig.SexType or UX.Game.SexType.Male
	}

	if spirit.config then
		local agentId = spirit.config.AgentId
		local agentConfig = LTConfig.AgentConfig.GetConfig(agentId)
		local modelId = agentConfig and agentConfig.GeneralModelId or 0
		data.ModelId = modelId
		local modelCfg = GeneralModelConfig.GetConfig(modelId)

		if modelCfg then
			data.CameraBodyType = modelCfg.CameraBodyType
		end
	end

	return data
end

return M
