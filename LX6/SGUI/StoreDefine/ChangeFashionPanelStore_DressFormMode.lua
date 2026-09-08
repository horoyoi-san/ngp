-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ChangeFashionPanelStore_DressFormMode.lua
-- Decompiled from: 01455_ChangeFashionPanelStore_DressFormMode.lua_555ded4f0343.luajit

local FashionConfig = LTConfig.FashionConfig
local FashionSuitConfig = LTConfig.FashionSuitConfig
local FightSpiritConfig = LTConfig.FightSpiritConfig
local M = C_ChangeFashionPanelStore

M.DefineDressFormVariables = function(self)
	self.dressFormInitSnapshot = nil
	self.dressFormPlacedId = nil
	self.dressFormModelIndex = nil
	self.dressFormShowcaseId = nil
	self.dressFormInstanceId = nil
end

M.InitDressFormMode = function(self, data)
	local gadgetEntity = data[3]
	local gadgetId = gadgetEntity.entityInstanceId
	local placedId, showcaseData = gHouseGadgetManager:GetShowcaseDataByGadgetId(gadgetId)
	local modelIndex = data.modelIndex or 0
	local modelData = showcaseData and showcaseData.Models and showcaseData.Models[modelIndex]

	if not modelData then
		return
	end

	local showcaseCfg = LTConfig.HouseInteractionFashionShowcaseConfig.GetConfig(modelData.ShowcaseId)
	local fakeSpiritId = showcaseCfg.SpiritId
	local _, showcaseInfoList = gFurnitureShowCaseUtils:_GetShowcaseCompByPlacedId(placedId, false)
	local mannequinUnit = showcaseInfoList and showcaseInfoList[modelIndex] and showcaseInfoList[modelIndex].unit
	local spiritCfg = LTConfig.FightSpiritConfig.GetConfig(fakeSpiritId)
	local agentCfg = spiritCfg and LTConfig.AgentConfig.GetConfig(spiritCfg.AgentId)
	local modelCfg = LTConfig.GeneralModelConfig.GetConfig(showcaseCfg.ModelId)
	local spiritInfo = agentCfg and {
		Sex = agentCfg.SexType,
		CameraBodyType = modelCfg and modelCfg.BodyType or 0,
		ModelId = showcaseCfg.ModelId
	} or {}
	self.spiritContext = {
		spiritId = fakeSpiritId,
		unit = mannequinUnit,
		unitPid = mannequinUnit and mannequinUnit.Pid,
		spiritInfo = spiritInfo
	}
	self.dressFormInstanceId = modelData.FashionInstanceId
	self.dressFormPlacedId = placedId
	self.dressFormModelIndex = modelIndex
	self.dressFormShowcaseId = modelData.ShowcaseId

	gDressManager:InitSteps(self.spiritContext)

	self.dressFormInitSnapshot = gDressManager:GetCurrentFashionListInfoRecord(self.spiritContext)

	self:RefreshFormTypeCtrl()
	self:InitSubStores(data)
end

M.OnRefreshDressFormMode = function(self)
	if self.dressFormInitSnapshot then
		gDressManager:DressNewFashionListAndEdit(self.dressFormInitSnapshot.WearFashionInfoList, self.dressFormInitSnapshot.WearFashionEditInfoList, self.spiritContext)
	end
end

M.DestroyDressFormMode = function(self)
end

M.SaveDressFormFashion = function(self, cb)
	if not self.dressFormInstanceId then
		return
	end

	local placedId = self.dressFormPlacedId
	local modelIndex = self.dressFormModelIndex
	local spiritContext = self.spiritContext

	LX6.Units.Module.UnitFashionInfoModule.AskSetDressFormFashions(self.dressFormInstanceId, spiritContext.spiritId, spiritContext.unit, function (errCode)
		if errCode ~= 0 then
			local fashionRecord = gDressManager:GetCurrentFashionListInfoRecord(spiritContext)

			if fashionRecord and placedId == nil and modelIndex == nil then
				gHouseManager:SyncShowcaseFashionToCache(placedId, modelIndex, fashionRecord)
			end
		end

		if cb then
			cb(errCode)
		end
	end)
end

M.RefreshDressFormAfterSwitch = function(self, newShowcaseId)
	self.dressFormShowcaseId = newShowcaseId
	local showcaseCfg = LTConfig.HouseInteractionFashionShowcaseConfig.GetConfig(newShowcaseId)

	if not showcaseCfg then
		return
	end

	local fakeSpiritId = showcaseCfg.SpiritId
	local _, showcaseInfoList = gFurnitureShowCaseUtils:_GetShowcaseCompByPlacedId(self.dressFormPlacedId, false)
	local mannequinUnit = showcaseInfoList and showcaseInfoList[self.dressFormModelIndex] and showcaseInfoList[self.dressFormModelIndex].unit
	local spiritCfg = LTConfig.FightSpiritConfig.GetConfig(fakeSpiritId)
	local agentCfg = spiritCfg and LTConfig.AgentConfig.GetConfig(spiritCfg.AgentId)
	local modelCfg = LTConfig.GeneralModelConfig.GetConfig(showcaseCfg.ModelId)
	local spiritInfo = agentCfg and {
		Sex = agentCfg.SexType,
		CameraBodyType = modelCfg and modelCfg.BodyType or 0,
		ModelId = showcaseCfg.ModelId
	} or {}
	self.spiritContext = {
		spiritId = fakeSpiritId,
		unit = mannequinUnit,
		unitPid = mannequinUnit and mannequinUnit.Pid,
		spiritInfo = spiritInfo
	}
	local modelData = gHouseManager:GetShowcaseModelData(self.dressFormPlacedId, self.dressFormModelIndex)
	self.dressFormInstanceId = modelData and modelData.FashionInstanceId

	gDressManager:InitSteps(self.spiritContext)

	self.dressFormInitSnapshot = gDressManager:GetCurrentFashionListInfoRecord(self.spiritContext)

	self:RefreshFormTypeCtrl()
	self.SubGroup.CommonDressTooltip:ClearData()

	self.bindData.isShowInfoCtrl = self.isShowInfoCtrlEnum._false
	self.selectFashionId = 0
	self.suitId = 0
	local itemList = self:BuildFashionItemList()

	self.SubGroup.CommonDressList:Init({
		itemList = itemList,
		spiritContext = self.spiritContext,
		tabRefreshCb = function (tabData)
			self:OnTabRefresh(tabData)
		end,
		renderSuitSelectedCb = function (suitData)
			self:OnRenderSuitSelected(suitData)
		end,
		suitListClickCb = function (isSelected, suitData)
			self:OnSuitListClick(isSelected, suitData)
		end,
		renderItemSelectedCb = function (itemData)
			self:OnRenderItemSelected(itemData)
		end,
		itemListClickCb = function (isSelected, itemData)
			self:OnItemListClick(isSelected, itemData)
		end,
		checkFashionSuitCanShowFn = function (suitId)
			return self:CheckFashionSuitCanShow(suitId)
		end
	})
	self.SubGroup.CommonDressTooltip:Init({
		collectClickCb = function ()
			self:OnCollectClick()
		end,
		dyeClickCb = function ()
			self:OnDyeClick()
		end,
		adjustClickCb = function ()
			self:OnAdjustClick()
		end,
		suitFashionClickCb = function (fashionId, part, propPart)
			self:OnSuitFashionClick(fashionId, part, propPart)
		end,
		spiritContext = self.spiritContext
	})
	self:RefreshStepBtnState()
end

M.CheckDressFormFashionCanShow = function(self, fashionId)
	if self.fashionChangeType == gClientConst.FashionChangeType.DressForm then
		return false
	end

	local fashionCfg = FashionConfig.GetConfig(fashionId)

	if not fashionCfg then
		return false
	end

	if fashionCfg.IsDefault then
		return false
	end

	local currentModelId = self.spiritContext and self.spiritContext.spiritInfo and self.spiritContext.spiritInfo.ModelId

	if not currentModelId then
		return false
	end

	local currentModelCfg = LTConfig.GeneralModelConfig.GetConfig(currentModelId)

	if not currentModelCfg then
		return false
	end

	local isMale = currentModelCfg.BodyType > 3
	local gender = fashionCfg.Gender

	if gender ~= FashionConfig.GenderType.Unknow then
		return true
	elseif gender ~= FashionConfig.GenderType.Male then
		return isMale
	else
		return not isMale
	end
end

M.RefreshFormTypeCtrl = function(self)
	local currentModelId = self.spiritContext and self.spiritContext.spiritInfo and self.spiritContext.spiritInfo.ModelId

	if not currentModelId then
		return
	end

	local currentModelCfg = LTConfig.GeneralModelConfig.GetConfig(currentModelId)

	if not currentModelCfg then
		return
	end

	local isMale = currentModelCfg.BodyType > 3
	self.bindData.formTypeCtrl = isMale and self.formTypeCtrlEnum.man or self.formTypeCtrlEnum.woman
end

M.GetShowcaseIdByBodyType = function(self, targetBodyType)
	local ShowcaseConfig = LTConfig.HouseInteractionFashionShowcaseConfig

	for i = 0, ShowcaseConfig.count - 1 do
		local cfg = ShowcaseConfig.LoadAt(i)

		if cfg then
			local modelCfg = LTConfig.GeneralModelConfig.GetConfig(cfg.ModelId)

			if modelCfg and modelCfg.BodyType ~= targetBodyType then
				return cfg.Id
			end
		end
	end

	return nil
end

M.GetDefaultMaleShowcaseId = function(self)
	return self.GetShowcaseIdByBodyType(self, 2)
end

M.GetDefaultFemaleShowcaseId = function(self)
	return self.GetShowcaseIdByBodyType(self, 5)
end

M.GetFashionBodyType = function(self, fashionId)
	local fashionCfg = FashionConfig.GetConfig(fashionId)

	if not fashionCfg then
		return nil
	end

	if fashionCfg.Gender ~= FashionConfig.GenderType.GrownFemale then
		return 5
	end

	local belongSpiritId = fashionCfg.BelongSpiritId

	if not belongSpiritId or belongSpiritId ~= 0 then
		return nil
	end

	local spiritCfg = FightSpiritConfig.GetConfig(belongSpiritId)

	if not spiritCfg then
		return nil
	end

	local agentCfg = LTConfig.AgentConfig.GetConfig(spiritCfg.AgentId)

	if not agentCfg then
		return nil
	end

	local modelCfg = LTConfig.GeneralModelConfig.GetConfig(agentCfg.GeneralModelId)

	return modelCfg and modelCfg.BodyType
end

M.CheckNeedSwitchBodyForFashion = function(self, fashionId)
	local fashionCfg = FashionConfig.GetConfig(fashionId)

	if not fashionCfg then
		return false, nil
	end

	local currentModelId = self.spiritContext and self.spiritContext.spiritInfo and self.spiritContext.spiritInfo.ModelId

	if not currentModelId then
		return false, nil
	end

	local currentModelCfg = LTConfig.GeneralModelConfig.GetConfig(currentModelId)

	if not currentModelCfg then
		return false, nil
	end

	local currentBodyType = currentModelCfg.BodyType

	if fashionCfg.Gender ~= FashionConfig.GenderType.GrownFemale then
		if currentBodyType ~= 5 or currentBodyType ~= 6 then
			return false, nil
		end

		local targetShowcaseId = self:GetShowcaseIdByBodyType(5)

		return targetShowcaseId == nil, targetShowcaseId
	end

	local targetBodyType = self.GetFashionBodyType(self, fashionId)

	if not targetBodyType then
		local isMale = currentBodyType > 3
		targetBodyType = isMale and 2 or 5
	end

	if currentBodyType ~= targetBodyType then
		return false, nil
	end

	local targetShowcaseId = self:GetShowcaseIdByBodyType(targetBodyType)

	return targetShowcaseId == nil, targetShowcaseId
end

M.SwitchDressFormShowcase = function(self, targetShowcaseId, onDone)
	if targetShowcaseId ~= self.dressFormShowcaseId then
		if onDone then
			onDone()
		end

		return
	end

	slot3 = gHouseManager

	slot3:AskSwitchHouseShowcaseAgent(self.dressFormPlacedId, self.dressFormModelIndex, targetShowcaseId, function (success)
		if success then
			self:RefreshDressFormAfterSwitch(targetShowcaseId)
		end

		if onDone then
			onDone()
		end
	end)
end

M.DressFormWearAfterSwitch = function(self, fashionId)
	if not gDressManager:IsFashionHad(fashionId) then
		return
	end

	gDressManager:CheckSetPropEditInfo(fashionId, self.spiritContext)

	local conflictItems, addItems = gDressManager:CheckFashionConflict({
		fashionId
	}, self.spiritContext)

	table.insert(addItems, fashionId)
	gDressManager:SetFashionList(addItems, nil, self.spiritContext)
	self:PushSnapshot(fashionId, nil)

	self.selectFashionId = fashionId

	self.SubGroup.CommonDressList:RefreshAllList()
end
