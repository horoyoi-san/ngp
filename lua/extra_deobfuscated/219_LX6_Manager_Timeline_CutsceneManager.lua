local M = {
	logEnable = false,
	OnInit = function (self)
		return
	end
}
local C_CutsceneManager = LX6.TimelineScript.CutsceneManager.Instance
local GeneralModelConfig = LTConfig.GeneralModelConfig

function M:GetBlendShapeDefaultData(bodyType)
	return C_CutsceneManager:GetBlendShapeDefaultData(bodyType)
end

function M:SetBlendShapeIkDafaultData(unit, bodyType)
	C_CutsceneManager:SetBlendShapeIkDafaultData(unit, bodyType)
end

function M:StopBlendShapeIk(unit)
	if unit == nil then
		return
	end

	C_CutsceneManager:StopBlendShapeIk(unit)
end

function M:DebugLog(content)
	if self.logEnable then
		print_notice("[CutsceneManager] " .. content)
	end
end

function M:Error(content)
	print_error("[CutsceneManager] " .. content)
end

function M:OpenBlackScreenTransition(blackScreenId, text, isWhite, crossScene, openTime, stayTime, closeTime, openCb, stayCb, closeCb)
	if stayTime < 0 then
		stayTime = 15
	end

	gBlackScreenManager:AutoTransition(blackScreenId, text, isWhite, crossScene, openTime, stayTime, closeTime, openCb, stayCb, closeCb)
end

function M:TempSetPlayerDefaultCardByCS()
	local sexType = gPlayerManager.infoLogin.bindData.sexType
	local defaultId = 0

	if sexType == 1 then
		defaultId = LTConfig.FightSpiritConfig.DefaultMale
	elseif sexType == 2 then
		defaultId = LTConfig.FightSpiritConfig.DefaultFemale
	end

	if defaultId ~= 0 then
		return self:TempSetPlayerCardByCS(defaultId)
	end

	return 0
end

function M:TempSetPlayerCardByCS(cardId)
	if cardId ~= 0 then
		local myPlayerCSUnit = gCS.MyPlayerManager.PlayerUnit
		local originalCarId = myPlayerCSUnit.ClientData.cardId
		local success = gBattleSpiritMgr:ResetPlayerCardId(myPlayerCSUnit.Pid, cardId)

		if success then
			return originalCarId
		end
	end

	return 0
end

function M:GetBodyType(unit)
	local modelId = unit.modelId
	local modelConfig = GeneralModelConfig.GetConfig(modelId)
	local bodyType = modelConfig.CameraBodyType

	if bodyType == 0 then
		bodyType = modelConfig.BodyType
	end

	return bodyType
end

gCutsceneManager = M
