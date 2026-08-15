local GeneralModelConfig = LTConfig.GeneralModelConfig
local M = {
	GetAllLingList = function (self)
		local lingList = {}

		gSpiritManager:Foreach(function (spirit)
			table.insert(lingList, self:GetCardData(spirit))
		end)

		return lingList
	end,
	GetAllLingListFromConfig = function (self)
		local lingList = {}
		local spiritCount = LTConfig.FightSpiritConfig.count

		for i = 0, spiritCount - 1 do
			local spiritCfg = LTConfig.FightSpiritConfig.LoadAt(i)

			if spiritCfg and spiritCfg.CanJoin then
				local agentCfg = LTConfig.AgentConfig.GetConfig(spiritCfg.AgentId)

				if agentCfg then
					local cardData = {
						Select = false,
						Have = false,
						Id = spiritCfg.Id,
						Name = spiritCfg.Name,
						sIcon = spiritCfg.SHeadIconID,
						Quality = spiritCfg.Quality,
						Sex = agentCfg.SexType
					}

					table.insert(lingList, cardData)
				end
			end
		end

		return lingList
	end
}

function M:GetCardData(spirit)
	if not spirit or not spirit.config then
		return nil
	end

	local agentId = spirit.config.AgentId
	local agentConfig = LTConfig.AgentConfig.GetConfig(agentId)
	local data = {
		Select = false,
		Quality = 0,
		ShowShangChangNum = false,
		Have = true,
		isEmpty = false,
		ShangChang = false,
		OutlineColor = 0,
		ShangChangNum = 0,
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
		local modelCfg = GeneralModelConfig.GetConfig(modelId)

		if modelCfg then
			data.CameraBodyType = modelCfg.CameraBodyType
		end
	end

	return data
end

return M
