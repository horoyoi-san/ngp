local FashionConfig = LTConfig.FashionConfig
local FashionFunctionSuitConfig = LTConfig.FashionFunctionSuitConfig
local IndoorConfig = LTConfig.IndoorConfig
local GeneralModelConfig = LTConfig.GeneralModelConfig
local FightSpiritConfig = LTConfig.FightSpiritConfig
local EffectConfig = LTConfig.EffectConfig
local ActionTransitionRuleTypesConfig = LTConfig.ActionTransitionRuleTypesConfig
local M = {
	indoorCountDownTime = 0,
	isLoadFinish = false,
	applyId2BodyType2Id = {},
	OnInit = function (self)
		return
	end,
	OnUpdate = function (self)
		if self.indoorCountDownTime and self.indoorCountDownTime > 0 then
			self.indoorCountDownTime = self.indoorCountDownTime - Time.deltaTime

			if self.indoorCountDownTime < 0 then
				self.indoorCountDownTime = 0

				gDressRoomChange:CheckIndoorFashion()
			end
		end
	end,
	CheckHasFashionByIndoor = function (self)
		if gCS.PaoKuManager.ParkourStateLua == ActionTransitionRuleTypesConfig.ParkourStateType.Skill then
			self.needWaitSkillEnd = true

			return
		end

		if self.needWaitSkillEnd then
			self.needWaitSkillEnd = false
		end

		if gTaskManager:IsTaskSubmitted(FashionConfig.IndoorDressUnlockTask) then
			if gMapManager.IndoorId == 0 then
				gDressManager.recordAddFashionList = {}
				gDressManager.CurrentSpiritId = 0
				self.indoorCountDownTime = FashionConfig.IndoorCountDownTime or 3
			else
				self:CheckIndoorFashion()
			end
		end
	end
}

function M:GetFashionFunctionSuitId(applyid, bodyType)
	if table.isNilOrEmpty(self.applyId2BodyType2Id) then
		self.applyId2BodyType2Id = {}

		for index = 0, FashionFunctionSuitConfig.count - 1 do
			local fashionFunctionSuitCfg = FashionFunctionSuitConfig.LoadAt(index)

			if fashionFunctionSuitCfg.IsClient then
				local bodyType2FunctionSuitIdDict = self.applyId2BodyType2Id[fashionFunctionSuitCfg.ApplyId]

				if not bodyType2FunctionSuitIdDict then
					bodyType2FunctionSuitIdDict = {}
					self.applyId2BodyType2Id[fashionFunctionSuitCfg.ApplyId] = bodyType2FunctionSuitIdDict
				end

				for _, cfgBodyType in ipairs(fashionFunctionSuitCfg.BodyTypeList) do
					bodyType2FunctionSuitIdDict[cfgBodyType] = fashionFunctionSuitCfg.Id
				end
			end
		end
	end

	local bodyType2FunctionSuitIdDict = self.applyId2BodyType2Id[applyid]

	if not bodyType2FunctionSuitIdDict then
		return 0
	end

	return bodyType2FunctionSuitIdDict[bodyType] or 0
end

function M:CheckIndoorFashion()
	if not self.isLoadFinish then
		return
	end

	local indoorId = gMapManager.IndoorId

	if indoorId == 0 then
		if self.isIndoorFashionChange then
			self.isIndoorFashionChange = false

			self:ClearIndoorSpiritFashion()
		end
	else
		local cfg = IndoorConfig.GetConfig(indoorId)

		if cfg and cfg.FashionFunctionSuitApplyId > 0 then
			local bodyType = nil
			local modleId = gCS.MyPlayerManager.PlayerUnitt.CurrentModelId
			local gmcfg = GeneralModelConfig.GetConfig(modleId)

			if gmcfg then
				bodyType = gmcfg.CameraBodyType
			end

			local functionSuitId = self:GetFashionFunctionSuitId(cfg.FashionFunctionSuitApplyId, bodyType)
			local funCfg = FashionFunctionSuitConfig.GetConfig(functionSuitId)

			if funCfg then
				self.isIndoorFashionChange = true

				if table.isNilOrEmpty(gDressManager.SpriteFashionInfoDict) then
					gDressManager:SetPlayerFashionsInfo()
				end

				gDressManager.CurrentSpiritId = gCS.MyPlayerManager.PlayerUnit.ClientData.cardId

				if funCfg.IsSuit then
					gDressManager:DressSuitFashionList(funCfg.FashionIdList, false, true)
				else
					local propConflictItems = gDressManager:CheckPropConflict(funCfg.FashionIdList)

					gDressManager:ChangeFashionPart(funCfg.FashionIdList, propConflictItems)
				end
			else
				print_error("没有找到室内配置的对应的时装")
			end
		elseif self.isIndoorFashionChange then
			self.isIndoorFashionChange = false

			self:ClearIndoorSpiritFashion()
		end
	end
end

function M:ClearIndoorSpiritFashion()
	local fightSpirits = gBattleSpiritMgr:GetBattleSpiritList()

	for i = 1, #fightSpirits do
		local pid = fightSpirits[i].pid
		local unit = gCS.SceneDataMgr.GetUnit(pid)

		if unit and unit.FashionSlot then
			unit.FashionSlot:SyncApplyPlayerFashionInfo()

			local effectCfg = EffectConfig.GetConfig(FightSpiritConfig.CommonSwitchEffect)

			if not gPauseManager.isBreak and effectCfg and effectCfg.Time > 0 then
				gCS.EffectMgr:PlayEffectsForUnit(gCS.MyPlayerManager.PlayerUnit, FightSpiritConfig.CommonSwitchEffect)
			end
		end

		gDressManager.recordAddFashionList = {}
	end
end

function M:LoadingFinish()
	self.isLoadFinish = true

	if gMapManager.IndoorId > 0 then
		local cfg = IndoorConfig.GetConfig(gMapManager.IndoorId)

		if cfg and cfg.FashionFunctionSuitApplyId > 0 then
			self:CheckHasFashionByIndoor()
		end
	end
end

function M:SkillLoadingFinish()
	if gMapManager.IndoorId > 0 and self.needWaitSkillEnd then
		self:CheckHasFashionByIndoor()
	end
end

gDressRoomChange = M
