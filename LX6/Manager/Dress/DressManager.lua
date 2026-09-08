-- Original chunk: @Lua\LuaFiles\LX6\Manager\Dress\DressManager.lua
-- Decompiled from: 00531_DressManager.lua_11dc7e064e09.luajit

require("LX6/Manager/Dress/DressCamera")
require("LX6/Manager/Dress/DressDyeManager")
require("LX6/Manager/Dress/DressStack")

local Formula_cs = require("LuaGen/AutoGen/Formula_cs")
local ShopCommodityCfg = LTConfig.ShopCommodityConfig
local FashionConfig = LTConfig.FashionConfig
local FashionSuitConfig = LTConfig.FashionSuitConfig
local FashionBaseConfig = LTConfig.FashionBaseConfig
local FashionTagConfig = LTConfig.FashionTagConfig
local FashionSpiritConfig = LTConfig.FashionSpiritConfig
local FightSpiritConfig = LTConfig.FightSpiritConfig
local FashionFunctionSuitConfig = LTConfig.FashionFunctionSuitConfig
local LingGuiUtils = require("LX6/GUI/Ling/LingGuiUtils")
local AgentConfig = LTConfig.AgentConfig
local UnitFashionInfoModule = LX6.Units.Module.UnitFashionInfoModule
C_DressManager = DefClass("C_DressManager", C_DressManager)
local M = C_DressManager

M.ctor = function(self)
	self.brandsList = {}
	self.showHiddenPart = false
	self.DRESS_PART = {
		["\\xafDJ"] = 100,
		["\\xfb\\xf4 )1\t\\xc2"] = 2,
		["~\\x9b\\x8b\\x9b\\x85"] = 101,
		["ahHPq-$;"] = 1,
		[";d\\xbe\\xb8\\xa6r"] = 3,
		["~\\x86\\x8d\\x8a\\x85"] = 4,
		["kfE[h,><"] = 7,
		["RTi"] = 10,
		["1i\\xba\\xab\\xb6q"] = 9,
		["\\x83\\x90,\\x99H\\xdd"] = 8,
		["JRk"] = 5,
		["N\rMh"] = 0
	}
	self.DRESS_TYPE = {
		["R'|_"] = 11,
		["\\xacia"] = 7,
		["i\\xbc\\xa7\\xbc\\xa5"] = 4,
		["n\\xa2\\xad\\xbb\\xbe"] = 1,
		["j\\xa2\\xad\\xb9\\xb3"] = 3,
		[":I\\x92\\x87\\x82M"] = 12,
		["/D\\x94\\x8b\\x95D"] = 2,
		["I*r^"] = 6,
		["\\x98\\xb9\\xb9o\\xf7="] = 99,
		[">G\\x85\\x9a\\x8cL"] = 5
	}
	self.DRESS_TYPE_KEYS = {}

	for k, _ in pairs(self.DRESS_TYPE) do
		table.insert(self.DRESS_TYPE_KEYS, k)
	end

	self.DRESS_TYPE_COUNT = #self.DRESS_TYPE_KEYS
	self.CtrlZSteps = {}
	self.currentPointIndex = 0
	self.fashionIdToSuitId = {}
	self.ConflictBaseFashions = {}
	self.BodyType2FunctionSuits = {}
	self.SpiritSpEarCfg = {}
	self.SelectType = {
		tag = {},
		collect = {},
		approach = {},
		brand = {}
	}
	self.fashionVariantDict = {}
	self.gmBanAction = false
end

M.OnInit = function(self)
	gDressStack:Init()
	self:InitFunctionSuitTypes()
	self:CacheFashionVariantDict()
end

M.GetCurrentModule = function(self, unit)
	unit = unit or self:GetDefaultDressUnit()

	if not unit then
		return nil
	end

	return UnitFashionInfoModule.GetModule(unit)
end

M.GetSpiritContext = function(self, cardId, pid, inputUnit)
	local unit = inputUnit

	if not unit and pid and pid == 0 then
		unit = gCS.SceneDataMgr.GetUnit(pid)
	end

	unit = unit or gCS.MyPlayerManager.PlayerUnit

	if not unit then
		return nil
	end

	if cardId ~= nil or cardId ~= 0 then
		cardId = unit.ClientData.cardId
	end

	local spirit = gSpiritManager:GetSpiritById(cardId)
	local context = {
		spiritId = cardId,
		spiritInfo = LingGuiUtils:GetCardData(spirit),
		unitPid = unit.Pid,
		unit = unit
	}

	return context
end

M.PrepareUnitForDress = function(self, unit, ignoreHideWeapon)
	if unit and not ignoreHideWeapon then
		unit:SetForceShowWeapon(true, LX6.Units.BaseUnit.ForceReason.Dress, false)
	end
end

M.RestoreUnitAfterDress = function(self, unit)
	if unit and not L50.L50App.Scene.GamePlayUtils:UnitIsNull(unit) then
		unit:SetForceShowWeapon(false, LX6.Units.BaseUnit.ForceReason.Dress, false)
	end
end

M.SetPlayerFashionsInfo = function(self, unit)
	local module = self:GetCurrentModule(unit)

	if module then
		module:SetPlayerFashionsInfo()
	end
end

M.GetSuitIdByFashionId = function(self, fashionId)
	if table.isNilOrEmpty(self.fashionIdToSuitId) then
		for index = 0, FashionSuitConfig.count - 1 do
			local cfg = FashionSuitConfig.LoadAt(index)

			if cfg then
				for i = 1, #cfg.FashionIdList do
					if table.isNilOrEmpty(self.fashionIdToSuitId[cfg.FashionIdList[i]]) then
						self.fashionIdToSuitId[cfg.FashionIdList[i]] = {}
					end

					table.insert(self.fashionIdToSuitId[cfg.FashionIdList[i]], cfg.Id)
				end
			end
		end
	end

	return self.fashionIdToSuitId[fashionId] or {}
end

M.GetBrandsById = function(self, brandsTypes)
	if table.isNilOrEmpty(self.brandsList) then
		for index = 0, ShopCommodityCfg.count - 1 do
			local cfg = ShopCommodityCfg.LoadAt(index)

			if cfg and cfg.BelongBrand and cfg.BelongBrand == 0 then
				if not self.brandsList[cfg.BelongBrand] then
					self.brandsList[cfg.BelongBrand] = {}
				end

				table.insert(self.brandsList[cfg.BelongBrand], cfg)
			end
		end
	end

	local items = {}

	for i = 1, #brandsTypes do
		if self.brandsList[brandsTypes[i]] then
			array.concat(items, self.brandsList[brandsTypes[i]])
		end
	end

	return items
end

M.CheckCurrentSpritShowFashion = function(self, fashionId, context)
	local spiritId = context and context.spiritId
	local showFashion = true
	local cfg = FashionConfig.GetConfig(fashionId)

	if cfg then
		if not cfg.IsShow then
			showFashion = false
		end

		if cfg.BelongSpiritId == nil and cfg.BelongSpiritId <= 0 and cfg.BelongSpiritId == spiritId then
			showFashion = false
		end
	end

	return showFashion
end

M.CheckFashionConflict = function(self, tryApplyIds, context)
	local unit = context and context.unit or self:GetDefaultDressUnit()

	if unit ~= nil then
		return {}, {}
	end

	local fashionSlot = unit.FashionSlot

	if fashionSlot ~= nil then
		return {}, {}
	end

	local conflictIds, addedBaseIds = nil
	_, conflictIds, addedBaseIds = UnitFashionInfoModule.CheckConflict(unit, unit.ClientData.cardId, tryApplyIds, nil, conflictIds, addedBaseIds)

	return conflictIds:ToTable() or {}, addedBaseIds:ToTable() or {}
end

M.CheckRemoveFashionConflict = function(self, tryApplyIds, context)
	local unit = context and context.unit or self:GetDefaultDressUnit()
	local fashionSlot = unit.FashionSlot

	if fashionSlot ~= nil then
		return
	end

	local conflictIds, addedBaseIds = nil
	_, conflictIds, addedBaseIds = UnitFashionInfoModule.CheckConflict(unit, unit.ClientData.cardId, nil, tryApplyIds, conflictIds, addedBaseIds)

	return conflictIds:ToTable() or {}, addedBaseIds:ToTable() or {}
end

M.CheckFashionConflictIsTakeEffect = function(self, context)
	local unit = context and context.unit or self:GetDefaultDressUnit()
	local fashionSlot = unit.FashionSlot

	if fashionSlot ~= nil then
		return
	end

	return true
end

M.CheckPropConflict = function(self, tryApplyIds, unit)
	local conflictIds = {}
	unit = unit or self:GetDefaultDressUnit()
	local fashionSlot = unit.FashionSlot
	local allAppliedProps = fashionSlot:GetAllFashionPropId()

	if allAppliedProps ~= nil or allAppliedProps.Length < 0 then
		return conflictIds
	end

	for i = 1, #tryApplyIds do
		local conflictId = self:GetPropConflictFashionId(tryApplyIds[i], allAppliedProps)

		if conflictId then
			table.insert(conflictIds, conflictId)
		end
	end

	return conflictIds
end

M.GetPropConflictFashionId = function(self, fashionId, allAppliedProps)
	local cfg = FashionConfig.GetConfig(fashionId)

	if cfg.Part ~= gDressManager.DRESS_PART.PROP then
		local type = cfg.Types[1]

		for i = 0, allAppliedProps.Length - 1 do
			local appliedCfg = FashionConfig.GetConfig(allAppliedProps[i])

			if type ~= appliedCfg.Types[1] and fashionId == allAppliedProps[i] then
				return allAppliedProps[i]
			end
		end
	end

	return nil
end

M.IsPlayerWearFashionListNoChange = function(self, fashionList, context)
	if table.isNilOrEmpty(fashionList) then
		return true
	end

	local spiritId = context and context.spiritId
	local wearCount = 0
	local spiritFashionsInfoDict = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo.SpiritFashionsInfoDict
	local spiritFashionsInfo = spiritFashionsInfoDict[spiritId]

	if spiritFashionsInfo then
		local wearInfo = spiritFashionsInfo.SpiritWearFashionsInfo.WearFashionInfoList

		if wearInfo.Count == table.count(fashionList) then
			return false
		end

		for t = 1, wearInfo.Count do
			if table.contains(fashionList, wearInfo[t].FashionId) then
				wearCount = wearCount + 1
			end
		end

		if wearCount ~= wearInfo.Count then
			return true
		end
	end

	return false
end

M.IsDressEditNoChange = function(self, edit, context)
	if table.isNilOrEmpty(edit) then
		return true
	end

	local spiritId = context and context.spiritId
	local spiritFashionsInfoDict = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo.SpiritFashionsInfoDict
	local spiritFashionsInfo = spiritFashionsInfoDict[spiritId]

	if spiritFashionsInfo then
		local wearFashionEditInfoList = spiritFashionsInfo.WearFashionEditInfoList

		if not table.isNilOrEmpty(wearFashionEditInfoList) then
			for i = 1, wearFashionEditInfoList.Count do
				if wearFashionEditInfoList[i].SpiritId ~= spiritId then
					local editInfo = wearFashionEditInfoList[i]

					if editInfo.FashionId ~= edit.FashionId and edit.Scale ~= editInfo.Scale and edit.Offset ~= editInfo.Offset and edit.Rotation ~= editInfo.Rotation then
						return true
					end
				end
			end
		end
	end

	return false
end

M.IsSamePart = function(self, fashion1, fashion2)
	local cfg1 = FashionConfig.GetConfig(fashion1)
	local cfg2 = FashionConfig.GetConfig(fashion2)

	if cfg1 and cfg2 and cfg1.Part ~= cfg2.Part then
		return true
	end

	return false
end

M.IsFashionCanEdit = function(self, fashionId)
	local cfg = FashionConfig.GetConfig(fashionId)

	if cfg then
		return cfg.EditId and cfg.EditId >= 0
	end

	return false
end

M.GetTagList = function(self, fashionId)
	local fashionCfg = FashionConfig.GetConfig(fashionId)
	local tagList = {}

	if fashionCfg then
		for i = 1, #fashionCfg.Tags do
			local tagCfg = FashionTagConfig.GetConfig(fashionCfg.Tags[i])

			if tagCfg then
				local view = {
					title = tagCfg.Name,
					color = tagCfg.BackgroundColor
				}

				table.insert(tagList, view)
			end
		end
	end

	return tagList
end

M.GetCurrentSpritSuitSlotCount = function(self, context)
	local spiritId = context and context.spiritId
	local spiritFashionsInfoDict = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo.SpiritFashionsInfoDict
	local spiritFashionsInfo = spiritFashionsInfoDict[spiritId]
	local count = spiritFashionsInfo.UnlockSuitSlotCount

	return count
end

M.ClearSelectTypeData = function(self)
	self.SelectType.collect = {}
	self.SelectType.approach = {}
	self.SelectType.brand = {}
	self.SelectType.tag = {}
end

M.CheckGenderWithBodyTypeAllow = function(self, fashionId, spiritInfo)
	local available = false
	local fashionCfg = FashionConfig.GetConfig(fashionId)

	if fashionCfg.Gender ~= FashionConfig.GenderType.Unknow then
		available = true
	elseif fashionCfg.Gender ~= FashionConfig.GenderType.Male then
		available = spiritInfo.Sex ~= fashionCfg.Gender
	else
		local modelId = spiritInfo and spiritInfo.ModelId or gCS.MyPlayerManager.PlayerUnit.ClientData.ModelId
		local modelCfg = LTConfig.GeneralModelConfig.GetConfig(modelId)
		local bodyType = modelCfg.BodyType
		local isGrown = bodyType ~= 5 or bodyType ~= 6

		if fashionCfg.Gender ~= FashionConfig.GenderType.Female then
			available = spiritInfo.Sex ~= fashionCfg.Gender
		else
			available = spiritInfo.Sex ~= FashionConfig.GenderType.Female and isGrown
		end
	end

	return available
end

M.CheckGenderWithBodyTypeBySpirit = function(self, spiritId, requiredGender)
	local spiritCfg = LTConfig.FightSpiritConfig.GetConfig(spiritId)

	if not spiritCfg then
		return false
	end

	local agentCfg = AgentConfig.GetConfig(spiritCfg.AgentId)

	if not agentCfg then
		return false
	end

	if not requiredGender then
		return true
	end

	if requiredGender ~= FashionConfig.GenderType.Unknow or requiredGender ~= 0 then
		return true
	end

	if requiredGender ~= FashionConfig.GenderType.Male or requiredGender ~= FashionConfig.GenderType.Female then
		return agentCfg.SexType ~= requiredGender
	end

	local modelCfg = LTConfig.GeneralModelConfig.GetConfig(agentCfg.GeneralModelId)
	local bodyType = modelCfg.BodyType
	local isGrown = bodyType ~= 5 or bodyType ~= 6

	return agentCfg.SexType ~= FashionConfig.GenderType.Female and isGrown
end

M.InitSpiritSpEarCfg = function(self)
	if table.isNilOrEmpty(self.SpiritSpEarCfg) then
		for index = 0, FashionSpiritConfig.count - 1 do
			local cfg = FashionSpiritConfig.LoadAt(index)

			if cfg then
				if self.SpiritSpEarCfg[cfg.FightSpiritId] ~= nil then
					self.SpiritSpEarCfg[cfg.FightSpiritId] = {}
				end

				self.SpiritSpEarCfg[cfg.FightSpiritId] = cfg.Ear
			end
		end
	end
end

M.CheckSpiritHasSpEar = function(self, context)
	local spiritId = context and context.spiritId

	self:InitSpiritSpEarCfg()

	return self.SpiritSpEarCfg[spiritId]
end

M.CheckSpriteHasDefaultUnderwear = function(self, context)
	local spiritId = context and context.spiritId
	local module = self:GetCurrentModule(context and context.unit)

	if module then
		return module:CheckSpriteHasDefaultUnderwear(spiritId)
	else
		print_error("FashionInfoModule未初始化!")

		return false
	end
end

M.IsFashionListMatchWore = function(self, fashionList, context)
	local spiritId = context and context.spiritId
	local module = self:GetCurrentModule(context and context.unit)

	if module then
		return module:IsFashionListMatchWore(spiritId, fashionList)
	else
		print_error("FashionInfoModule未初始化!")

		return false
	end
end

M.FindCurrentWornSuitId = function(self, wearFashionInfoList, unit, spiritId)
	local candidateSuits = {}
	local fashionIds = {}

	for _, info in ipairs(wearFashionInfoList) do
		local fashionId = info.FashionId

		if fashionId then
			table.insert(fashionIds, fashionId)

			local suitIds = self:GetSuitIdByFashionId(fashionId)

			for _, suitId in ipairs(suitIds) do
				candidateSuits[suitId] = true
			end
		end
	end

	for suitId, _ in pairs(candidateSuits) do
		local cfg = FashionSuitConfig.GetConfig(suitId)

		if cfg then
			local matchResult = self:IsFashionListMatchWore(cfg.FashionIdList, {
				unit = unit,
				spiritId = spiritId
			})

			if matchResult then
				return suitId
			end
		end
	end

	return nil
end

M.CheckShowSetting = function(self, context)
	local spiritId = context and context.spiritId

	self:InitSpiritSpEarCfg()

	local myFashionList = self:GetCurrentSpritWearFashionInfoList(context)
	local showSetting = false

	for i = 0, myFashionList.Count - 1 do
		local cfg = FashionConfig.GetConfig(myFashionList[i].FashionId)

		if cfg then
			local showPart = gDressManager:GetSelectableHiddenPart(cfg.SelectableHiddenPart)

			if table.contains(showPart, 2) and not self.SpiritSpEarCfg[spiritId] then
				table.removeEx(showPart, 2)
			end

			showSetting = showSetting or not table.isNilOrEmpty(showPart)
		end
	end

	return showSetting
end

M.IsFashionWore = function(self, fashionId, context)
	local spiritId = context and context.spiritId
	local module = self:GetCurrentModule(context and context.unit)

	if module then
		return module:IsFashionWore(spiritId, fashionId)
	else
		print_error("FashionInfoModule未初始化!")

		return false
	end
end

M.IsFashionWoreByServer = function(self, fashionId, context)
	local spiritId = context and context.spiritId
	local module = self:GetCurrentModule(context and context.unit)

	if module then
		local info = module:GetCurrentSpritWearFashionInfo(spiritId)
		local list = info.WearFashionInfoList

		for i = 0, list.Count - 1 do
			if fashionId ~= list[i].FashionId then
				return true
			end
		end

		return false
	else
		print_error("FashionInfoModule未初始化!")

		return false
	end
end

M.CheckIsInTryWear = function(self)
	local module = self:GetCurrentModule()

	if module then
		return module:CheckIsInTaskTryWear()
	else
		return false
	end
end

M.GetCurrentFashionListInfoRecord = function(self, context)
	local spiritId = context and context.spiritId
	local module = self:GetCurrentModule(context and context.unit)

	if module then
		return module:GetCloneBaseWearFashionsInfo(spiritId)
	end
end

M.GetCurrentSpritWearFashionInfoList = function(self, context)
	local spiritId = context and context.spiritId
	local module = self:GetCurrentModule(context and context.unit)

	if module then
		return module:GetCurrentSpritWearFashionInfoList(spiritId)
	end
end

M.GetCurrentSpritWearEditFashionInfoList = function(self, context)
	local spiritId = context and context.spiritId
	local module = self:GetCurrentModule(context and context.unit)

	if module then
		return module:GetCurrentSpritWearFashionEditInfoList(spiritId)
	end
end

M.GetCurrentSpritWearFashionInfo = function(self, context)
	local spiritId = context and context.spiritId
	local module = self:GetCurrentModule(context and context.unit)

	if module then
		return module:GetCurrentSpritWearFashionInfo(spiritId)
	end
end

M.GetCurrentSpritTryWearFashionInfo = function(self, context)
	local spiritId = context and context.spiritId
	local module = self:GetCurrentModule(context and context.unit)

	if module then
		return module:GetCurrentSpritTryWearFashionInfo(spiritId)
	end
end

M.GetFashionIsNew = function(self, fashionId)
	fashionId = self:GetBelongMainFashionId(fashionId)
	local fashionInfoDict = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo.FashionInfoDict

	if table.isNilOrEmpty(fashionInfoDict) or fashionInfoDict.Count ~= 0 then
		return false
	end

	local fashionInfo = fashionInfoDict[fashionId]

	if table.isNilOrEmpty(fashionInfo) then
		return false
	end

	return fashionInfo.Status ~= 1
end

M.DressSuitFashionList = function(self, list, isFromIndoor, context)
	local fromDoor = isFromIndoor and true or false
	local spiritId = context and context.spiritId
	local module = self:GetCurrentModule(context and context.unit)

	if module then
		module:TryAddFashionSuit(spiritId, list, fromDoor)
	end
end

M.SetFashionList = function(self, fashionIdList, isFromIndoor, context)
	local fromIndoor = isFromIndoor and true or false
	local spiritId = context and context.spiritId
	local module = self:GetCurrentModule(context and context.unit)

	if module then
		module:TryAddFashionIds(spiritId, fashionIdList, fromIndoor)
	end
end

M.RemoveFashionPart = function(self, fashionIdList, context)
	local spiritId = context and context.spiritId
	local module = self:GetCurrentModule(context and context.unit)

	if module then
		module:TryRemoveFashionIds(spiritId, fashionIdList)
	end
end

M.CheckClearFashionPart = function(self, context)
	local module = self:GetCurrentModule(context and context.unit)

	if module then
		module:ClearTryFashionParts()
	end
end

M.IsFashionHad = function(self, fashionId)
	fashionId = self:GetBelongMainFashionId(fashionId)
	local fashionInfoDict = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo.FashionInfoDict

	if table.isNilOrEmpty(fashionInfoDict) or fashionInfoDict.Count ~= 0 then
		return false
	end

	local cfg = FashionConfig.GetConfig(fashionId)

	if cfg and cfg.IsDefaultUnderwear then
		return true
	end

	local fashionInfo = fashionInfoDict[fashionId]

	return not table.isNilOrEmpty(fashionInfo)
end

M.DressNewFashionListAndEdit = function(self, wearFashionInfoList, wearFashionEditInfoList, context)
	local spiritId = context and context.spiritId
	local module = self:GetCurrentModule(context and context.unit)

	if module then
		module:SetFashionsByWearInfo(spiritId, wearFashionInfoList, wearFashionEditInfoList)
	end
end

M.CheckAddFashionDefault = function(self, fashionList, context)
	local spiritId = context and context.spiritId
	local hasShoes = false
	local hasGloves = false

	for i = 1, #fashionList do
		local cfg = FashionConfig.GetConfig(fashionList[i])

		if table.contains(cfg.Types, self.DRESS_TYPE.Shoe) then
			hasShoes = true
		end

		if table.contains(cfg.Types, self.DRESS_TYPE.Glove) then
			hasGloves = true
		end
	end

	local addList = {}
	local baseFashion = self.ConflictBaseFashions[spiritId]

	if baseFashion then
		if not hasShoes then
			table.insert(fashionList, baseFashion.shoes)
			table.insert(addList, baseFashion.shoes)
		end

		if not hasGloves then
			table.insert(fashionList, baseFashion.gloves)
			table.insert(addList, baseFashion.gloves)
		end
	end

	return addList
end

M.SaveFashionListEdit = function(self, FashionId, scale, offset, rotation, context)
	local spiritId = context and context.spiritId
	local module = self:GetCurrentModule(context and context.unit)

	if module then
		module:SaveFashionListEdit(spiritId, FashionId, scale, offset, rotation)
	end
end

local tempVec = Vector3.zero

M.DoChange = function(self, fashionId, euler, offset, scale, context)
	if fashionId ~= nil or fashionId ~= 0 then
		print_error("fashionId is nil or 0")

		return
	end

	local unit = context and context.unit or self:GetDefaultDressUnit()
	local eu = euler or tempVec
	local of = offset or tempVec
	local sc = scale or 1

	gCS.UnitFashionPropController.DoChange(unit, fashionId, eu, of, sc)
end

M.SetHiddenParts = function(self, hiddenParts, editedHiddenParts, unit)
	unit = unit or self:GetDefaultDressUnit()
	local fashionSlot = unit.FashionSlot

	if fashionSlot ~= nil then
		return
	end

	fashionSlot:SetHiddenParts(hiddenParts, editedHiddenParts)
	fashionSlot:ForceRefreshHiddenPart()
end

M.RefreshPlayerHiddenPartsData = function(self, hiddenParts, editedHiddenParts, context)
	local spiritId = context and context.spiritId
	local unit = context and context.unit or self:GetDefaultDressUnit()
	local fashionSlot = unit.FashionSlot

	if fashionSlot ~= nil or spiritId ~= 0 then
		return
	end

	fashionSlot:RefreshPlayerHiddenPartsData(spiritId, hiddenParts, editedHiddenParts)
end

M.CheckSetPropEditInfo = function(self, fashionId, context)
	local spiritId = context and context.spiritId
	local module = self:GetCurrentModule(context and context.unit)

	if module then
		return module:CheckSetPropEditInfo(spiritId, fashionId)
	else
		print_error("FashionInfoModule未初始化!")

		return false
	end
end

M.PreSetPropEditInfo = function(self, fashionId, euler, offset, scale, context)
	local spiritId = context and context.spiritId
	local module = self:GetCurrentModule(context and context.unit)

	if module then
		return module:PreSetPropEditInfo(spiritId, fashionId, scale, offset, euler)
	end
end

M.GetDefaultDressUnit = function(self)
	return gCS.MyPlayerManager.PlayerUnit
end

M.TransformPlayer = function(self, y, unit)
	unit = unit or self:GetDefaultDressUnit()

	if unit then
		local facing = unit.FacingDirection

		unit:SetFacing(facing + y)
	end
end

M.SelectSuitableSpiritForFashion = function(self, fashionCfg, currentSpiritId)
	if not fashionCfg then
		return currentSpiritId
	end

	local requiredGender = fashionCfg.Gender or 0
	local belongSpiritId = fashionCfg.BelongSpiritId

	if belongSpiritId and belongSpiritId <= 0 then
		return belongSpiritId
	end

	if self:CheckGenderWithBodyTypeBySpirit(currentSpiritId, requiredGender) then
		return currentSpiritId
	end

	local spiritIdList = LTConfig.CityPediaConfig.FashionShowcaseSpiritList

	for i = 1, #spiritIdList do
		local spiritCfg = LTConfig.FightSpiritConfig.GetConfig(spiritIdList[i])

		if spiritCfg and gSpiritManager:GetSpirit(spiritCfg.Id) and self:CheckGenderWithBodyTypeBySpirit(spiritCfg.Id, requiredGender) then
			return spiritCfg.Id
		end
	end

	for i = 1, #spiritIdList do
		local spiritCfg = LTConfig.FightSpiritConfig.GetConfig(spiritIdList[i])

		if spiritCfg and self:CheckGenderWithBodyTypeBySpirit(spiritCfg.Id, requiredGender) then
			return spiritCfg.Id
		end
	end

	return currentSpiritId
end

M.CleanupDressState = function(self, context, isResetDress, recordSpriteId)
	if not context then
		return
	end

	self:RestoreUnitAfterDress(context.unit)
	self:ResetDressAction()

	if recordSpriteId and recordSpriteId == 0 and context.unit and context.unit.ClientData.cardId == recordSpriteId then
		gBattleSpiritMgr:ResetPlayerCardId(context.unit.Pid, recordSpriteId)
	elseif isResetDress then
		self:CheckClearFashionPart(context)
	end
end

M.GetFashionShowAction = function(self, unit, spiritId, fashionInfo)
	local wearFashionInfoList = fashionInfo and fashionInfo.WearFashionInfoList

	if not wearFashionInfoList then
		return
	end

	if type(wearFashionInfoList) ~= "userdata" then
		wearFashionInfoList = wearFashionInfoList:ToTable()
	end

	local count = wearFashionInfoList.Count or #wearFashionInfoList

	if count ~= 0 then
		return
	end

	for _, wearInfo in ipairs(wearFashionInfoList) do
		local fashionId = wearInfo and wearInfo.FashionId
		local fashionCfg = fashionId and FashionConfig.GetConfig(fashionId)

		if fashionCfg and not table.isNilOrEmpty(fashionCfg.StartAction) and not table.isNilOrEmpty(fashionCfg.LoopAction) then
			return fashionCfg.StartAction, fashionCfg.LoopAction
		end
	end

	local matchedSuitId = self:FindCurrentWornSuitId(wearFashionInfoList, unit, spiritId)

	if matchedSuitId then
		local suitCfg = FashionSuitConfig.GetConfig(matchedSuitId)

		if suitCfg and not table.isNilOrEmpty(suitCfg.StartAction) and not table.isNilOrEmpty(suitCfg.LoopAction) then
			return suitCfg.StartAction, suitCfg.LoopAction
		end
	end
end

M.PlayFashionShowAction = function(self, unit, spiritId, fashionInfo, loopOnly)
	local startAction, loopAction = self:GetFashionShowAction(unit, spiritId, fashionInfo)

	if not startAction then
		return false
	end

	if loopOnly then
		gCS.AnimControllerManager.PlayAction(unit, loopAction[1], startAction[2], 999999, 0, -1, false, nil, 0)

		return true
	end

	gClientUtils:PlayQueuedActions(unit, {
		startAction[1],
		loopAction[1]
	}, startAction[2], {
		-1,
		999999
	})

	return true
end

M.PlayDressDefaultAction = function(self)
	self.playActionTime = nil
	local defaultActionInfo = FashionConfig.FashionDefaultAction

	if table.isNilOrEmpty(defaultActionInfo) then
		print_notice("没有找到默认动作  FashionConfig.FashionDefaultAction")

		return
	end

	self:PlayDressBaseAction(defaultActionInfo.actionid, defaultActionInfo.groupid, defaultActionInfo.expressionid, true)
end

M.PlayDressSuitAction = function(self, suitId, context)
	local unit = context and context.unit or self:GetDefaultDressUnit()

	if self:PlayDressEnterAction(nil, suitId, context) then
		return
	end

	local suitActionInfo = unit ~= gCS.MyPlayerManager.PlayerUnit and FashionConfig.FashionActionSuit or FashionConfig.FashionShopActionSuit

	if table.isNilOrEmpty(suitActionInfo) then
		print_notice("没有找到默认动作  FashionConfig.FashionShopActionSuit")

		return
	end

	self:PlayDressBaseAction(suitActionInfo.actionid, suitActionInfo.groupid, suitActionInfo.expressionid, false, unit)
end

M.PlayDressAction = function(self, Types, fashionId, suitId, context)
	local unit = context and context.unit or self:GetDefaultDressUnit()

	if self:PlayDressEnterAction(fashionId, suitId, context) then
		return
	end

	local spiritInfo = context and context.spiritInfo
	local actionName = self:GetFashionShopActionTypeByFashionType(Types, unit)

	if not actionName then
		print_notice("没有找到对应的动作名, types = " .. (Types or "nil") .. ", fashionId = " .. fashionId)

		return
	end

	local bodyType = spiritInfo.CameraBodyType
	local cfg = FashionBaseConfig.GetConfig(bodyType)
	local info = cfg[actionName]

	if info then
		self:PlayDressBaseAction(info.actionid, info.groupid, info.expressionid, false, unit)
	else
		print_notice("没有找到对应的动作, types = " .. (Types or "nil") .. ", fashionId = " .. fashionId)
	end
end

M.PlayRandomDressAction = function(self, suitId, context)
	if suitId and self:PlayDressEnterAction(nil, suitId, context) then
		return
	end

	local randomIndex = math.random(1, self.DRESS_TYPE_COUNT)
	local randomKey = self.DRESS_TYPE_KEYS[randomIndex]
	local types = self.DRESS_TYPE[randomKey]

	self:PlayDressAction(types, nil, , context)
end

M.PlayDressBaseAction = function(self, actionId, actionGroupId, expressionId, isDefault, unit)
	if self.gmBanAction then
		return
	end

	if self.playActionTime == nil and gLogicTime.time - self.playActionTime < FashionConfig.FashionShopActionCD then
		print_notice("当前已经有在播的动作，还在播动作的CD内，不能再播新动作")

		return
	end

	if not isDefault then
		self.playActionTime = gLogicTime.time
	end

	unit = unit or self:GetDefaultDressUnit()
	local isRealPlayer = unit ~= gCS.MyPlayerManager.PlayerUnit

	if isRealPlayer then
		gCS.LogicStateMachineManager.SendGameplayInwardSignal(unit, actionGroupId, actionId)
	else
		gCS.AnimControllerManager.PlayAction(unit, actionId, actionGroupId, -1, 0, -1, false, nil, 0)
	end

	if unit.ModelSlot and unit.ModelSlot.ExpressionController then
		unit.ModelSlot.ExpressionController:Init(unit, 2)
		unit.ModelSlot.ExpressionController:PlaySpecialExpression(expressionId, 0, true, 0)
	end
end

M.PlayDressEnterAction = function(self, fashionId, suitId, context)
	local unit = context and context.unit or self:GetDefaultDressUnit()

	if not unit then
		return false
	end

	local isRealPlayer = unit ~= gCS.MyPlayerManager.PlayerUnit

	if isRealPlayer then
		return false
	end

	local startAction, loopAction = nil

	if suitId and suitId <= 0 then
		local suitCfg = FashionSuitConfig.GetConfig(suitId)

		if suitCfg then
			startAction = suitCfg.StartAction
			loopAction = suitCfg.LoopAction
		end
	end

	if (not startAction or #startAction ~= 0) and fashionId and fashionId <= 0 then
		local fashionCfg = FashionConfig.GetConfig(fashionId)

		if fashionCfg then
			startAction = fashionCfg.StartAction
			loopAction = fashionCfg.LoopAction
		end
	end

	if not startAction or #startAction ~= 0 or not loopAction or #loopAction ~= 0 then
		return false
	end

	local startActionId = startAction[1]
	local startGroupId = startAction[2]
	local startExpressionId = startAction[3]
	local loopActionId = loopAction[1]
	local actions = {
		startActionId,
		loopActionId
	}
	local times = {
		-1,
		999999
	}

	gClientUtils:PlayQueuedActions(unit, actions, startGroupId, times)

	if startExpressionId and startExpressionId <= 0 and unit.ModelSlot and unit.ModelSlot.ExpressionController then
		unit.ModelSlot.ExpressionController:Init(unit, 2)
		unit.ModelSlot.ExpressionController:PlaySpecialExpression(startExpressionId, 0, true, 0)
	end

	self.playActionTime = nil

	return true
end

M.GetFashionShopActionTypeByFashionType = function(self, type, unit)
	local FashionShopActionType = FashionConfig.FashionShopActionType
	local isRealPlayer = unit ~= gCS.MyPlayerManager.PlayerUnit

	for i = 1, #FashionShopActionType do
		if FashionShopActionType[i].type ~= type then
			if isRealPlayer then
				return FashionShopActionType[i].action
			else
				return FashionShopActionType[i].action .. "2"
			end
		end
	end
end

M.ResetDressAction = function(self, unit)
	unit = unit or self:GetDefaultDressUnit()

	if unit then
		unit:ResetActionGroupId()
	end
end

M.InitSteps = function(self, context)
	self.CtrlZSteps = {}
	self.currentPointIndex = 0

	self:PushSnapshot(context)
end

M.PushSnapshot = function(self, context, selectFashionId, selectSuitId)
	if self.currentPointIndex >= #self.CtrlZSteps then
		for i = #self.CtrlZSteps, self.currentPointIndex + 1, -1 do
			table.remove(self.CtrlZSteps, i)
		end
	end

	local snapshot = self:TakeSnapshot(context, selectFashionId, selectSuitId)

	table.insert(self.CtrlZSteps, snapshot)

	if #self.CtrlZSteps <= 11 then
		table.remove(self.CtrlZSteps, 1)
	end

	self.currentPointIndex = #self.CtrlZSteps
end

M.TakeSnapshot = function(self, context, selectFashionId, selectSuitId)
	local info = self:GetCurrentFashionListInfoRecord(context)

	return {
		wearFashionInfoList = info.WearFashionInfoList,
		wearFashionEditInfoList = info.WearFashionEditInfoList,
		selectFashionId = selectFashionId,
		selectSuitId = selectSuitId
	}
end

M.HasLastStep = function(self)
	return self.currentPointIndex and self.currentPointIndex >= 1
end

M.HasNextStep = function(self)
	return self.currentPointIndex and self.currentPointIndex <= #self.CtrlZSteps
end

M.Undo = function(self, context)
	if not self:HasLastStep() then
		return nil
	end

	self.currentPointIndex = self.currentPointIndex - 1

	self:ApplySnapshot(self.CtrlZSteps[self.currentPointIndex], context)

	return self.CtrlZSteps[self.currentPointIndex]
end

M.Redo = function(self, context)
	if not self:HasNextStep() then
		return nil
	end

	self.currentPointIndex = self.currentPointIndex + 1

	self:ApplySnapshot(self.CtrlZSteps[self.currentPointIndex], context)

	return self.CtrlZSteps[self.currentPointIndex]
end

M.ApplySnapshot = function(self, snapshot, context)
	if not snapshot then
		return
	end

	self:DressNewFashionListAndEdit(snapshot.wearFashionInfoList, snapshot.wearFashionEditInfoList, context)
end

M.ClearSteps = function(self)
	self.currentPointIndex = 0
	self.CtrlZSteps = {}
end

M.IsFashionCollected = function(self, fashionId)
	if fashionId ~= nil or fashionId ~= 0 then
		return false
	end

	fashionId = self:GetBelongMainFashionId(fashionId)
	local info = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo.FavoriteFashionIdList

	if table.isNilOrEmpty(info) then
		return false
	end

	for i = 1, info.Count do
		if info[i] ~= fashionId then
			return true
		end
	end

	return false
end

M.IsFashinSuitCollected = function(self, suitId)
	if suitId ~= nil or suitId ~= 0 then
		return false
	end

	local info = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo.FavoriteFashionSuitIdList

	if table.isNilOrEmpty(info) then
		return false
	end

	for i = 1, info.Count do
		if info[i] ~= suitId then
			return true
		end
	end

	return false
end

M.IsFashionListHasRedDotNew = function(self, list)
	local fashionInfoDict = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo.FashionInfoDict
	local fashionInfo = nil

	for _, fashionId in ipairs(list) do
		fashionInfo = fashionInfoDict[fashionId]

		if fashionInfo and fashionInfo.Status ~= 1 then
			return true
		end
	end

	return false
end

M.InitFunctionSuitTypes = function(self)
	if table.isNilOrEmpty(self.BodyType2FunctionSuits) then
		for i = 0, FashionFunctionSuitConfig.count - 1 do
			local cfg = FashionFunctionSuitConfig.LoadAt(i)

			if cfg then
				for t = 1, #cfg.BodyTypeList do
					if table.isNilOrEmpty(self.BodyType2FunctionSuits[cfg.BodyTypeList[t]]) then
						self.BodyType2FunctionSuits[cfg.BodyTypeList[t]] = {}
					end

					local cfgInfo = {
						FashionIdList = UnitFashionInfoModule.GetWearFashionInfoListByLuaTable(cfg.FashionIdList),
						FashionEditList = UnitFashionInfoModule.GetEmptyWearFashionEditInfoList(),
						cfgId = cfg.Id,
						TagId = cfg.TagId,
						Icon = cfg.Icon,
						Icon = cfg.Icon,
						IconChoose = cfg.IconChoose
					}
					self.BodyType2FunctionSuits[cfg.BodyTypeList[t]][cfg.Id] = cfgInfo
				end
			end
		end
	end

	if table.isNilOrEmpty(self.ConflictBaseFashions) then
		for index = 0, FashionSpiritConfig.count - 1 do
			local cfg = FashionSpiritConfig.LoadAt(index)

			if cfg then
				if self.ConflictBaseFashions[cfg.FightSpiritId] ~= nil then
					self.ConflictBaseFashions[cfg.FightSpiritId] = {}
				end

				self.ConflictBaseFashions[cfg.FightSpiritId].gloves = cfg.BaseGlove
				self.ConflictBaseFashions[cfg.FightSpiritId].shoes = cfg.BaseShoe
			end
		end
	end
end

M.GetBodyType2FunctionSuits = function(self, bodyType, context)
	if bodyType ~= nil and context and context.spiritInfo then
		bodyType = context.spiritInfo.CameraBodyType
	end

	if bodyType ~= nil then
		print_error("GetBodyType2FunctionSuits: bodyType is nil")

		return {}
	end

	if table.isNilOrEmpty(self.BodyType2FunctionSuits[bodyType]) then
		self.BodyType2FunctionSuits[bodyType] = {}
	end

	local spiritId = context and context.spiritId

	if spiritId ~= nil then
		return self.BodyType2FunctionSuits[bodyType] or {}
	end

	local result = {}

	for k, v in pairs(self.BodyType2FunctionSuits[bodyType]) do
		result[k] = v
	end

	local module = self:GetCurrentModule(context and context.unit)

	if not module then
		print_error("FashionInfoModule未初始化!")

		return result
	end

	local spiritFashionsInfo = module:GetCurrentSpritFashionInfo(spiritId)

	if spiritFashionsInfo and spiritFashionsInfo.FashionFunctionSuitSchemeInfoDict then
		local dict = spiritFashionsInfo.FashionFunctionSuitSchemeInfoDict:ToTable()
		local originDict = spiritFashionsInfo.FashionFunctionSuitSchemeInfoDict

		for functionSuitId, info in pairs(dict) do
			local cfg = FashionFunctionSuitConfig.GetConfig(functionSuitId)

			if cfg then
				local cfgInfo = {}
				local _, suitSchemeInfo = originDict:TryGetValue(functionSuitId, nil)
				cfgInfo.FashionIdList = suitSchemeInfo.WearFashionInfoList
				cfgInfo.FashionEditList = suitSchemeInfo.WearFashionEditInfoList
				cfgInfo.TagId = cfg.TagId
				cfgInfo.Icon = cfg.Icon
				cfgInfo.Icon = cfg.Icon
				cfgInfo.IconChoose = cfg.IconChoose
				cfgInfo.cfgId = functionSuitId

				if table.contains(cfg.BodyTypeList, bodyType) then
					result[functionSuitId] = cfgInfo
				end
			end
		end
	end

	return result
end

M.GetSuitSchemeInfo = function(self, context)
	local spiritId = context and context.spiritId

	if spiritId ~= nil then
		return nil
	end

	local module = self:GetCurrentModule(context and context.unit)

	if module then
		local spiritFashionsInfo = module:GetCurrentSpritFashionInfo(spiritId)

		if spiritFashionsInfo then
			return spiritFashionsInfo.FashionCustomSuitSchemeInfos
		end
	else
		return nil
	end
end

M.SetCustomSuitSchemeName = function(self, context, schemeIndex, schemeName)
	local spiritId = context and context.spiritId
	local spiritFashionsInfoDict = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo.SpiritFashionsInfoDict
	local spiritFashionsInfo = spiritFashionsInfoDict[spiritId]

	if spiritFashionsInfo then
		if not spiritFashionsInfo.FashionCustomSuitSchemeInfos[schemeIndex] then
			spiritFashionsInfo.FashionCustomSuitSchemeInfos[schemeIndex] = {}
		end

		spiritFashionsInfo.FashionCustomSuitSchemeInfos[schemeIndex].SchemeName = schemeName
	end
end

M.CacheFashionVariantDict = function(self)
	for index = 0, FashionConfig.count - 1 do
		local cfg = FashionConfig.LoadAt(index)

		if cfg and cfg.BelongMainFashionId == 0 then
			if not self.fashionVariantDict[cfg.BelongMainFashionId] then
				self.fashionVariantDict[cfg.BelongMainFashionId] = {}
			end

			table.insert(self.fashionVariantDict[cfg.BelongMainFashionId], cfg.Id)
		end
	end
end

M.GetBelongMainFashionId = function(self, fashionId)
	if self:CheckFashionIsVariant(fashionId) then
		return FashionConfig.GetConfig(fashionId).BelongMainFashionId
	end

	return fashionId
end

M.CheckFashionIsVariant = function(self, fashionId)
	local cfg = FashionConfig.GetConfig(fashionId)

	if not cfg then
		print_error("@moshu01 fashionId服务端下发，但是配表读不到，检查是否存在投放或配置问题！fashionId:" .. fashionId)

		return false
	end

	return cfg.BelongMainFashionId == 0
end

M.CheckIfFashionHasVariant = function(self, fashionId)
	return self.fashionVariantDict[fashionId] and #self.fashionVariantDict[fashionId] >= 0
end

M.CheckFashionVariantUnlock = function(self, fashionVariantId)
	local cfg = FashionConfig.GetConfig(fashionVariantId)
	local result = gEventConditionUtils.CheckHasUnlocked(cfg, UX.Game.EventConditionImplModule.VariantFashion)

	return result
end

M.GetFashionVariantList = function(self, fashionId)
	return self.fashionVariantDict[fashionId]
end

M.GetFashionVariantPrefer = function(self, fashionId, context)
	local spiritId = context and context.spiritId
	local spiritFashionsInfoDict = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo.SpiritFashionsInfoDict
	local info = spiritFashionsInfoDict[spiritId]

	if not info then
		return fashionId
	end

	local dict = info.MainFashionId2VariantFashionIdDict

	if dict and dict[fashionId] then
		return dict[fashionId]
	end

	return fashionId
end

M.SetSpiritFashionVariant = function(self, spiritId, fashionId, variantFashionId, ignoreHideWeapon)
	local context = self:GetSpiritContext(spiritId)

	if not context then
		return
	end

	self:PrepareUnitForDress(context.unit, ignoreHideWeapon)

	local cb = function()
		local conflictItems, addItems = self:CheckFashionConflict({
			variantFashionId
		})

		table.insert(addItems, variantFashionId)
		self:CheckSetPropEditInfo(variantFashionId, context)
		self:SetFashionList(addItems, nil, context)
		gDressData:AskSetSpiritFashions(nil, spiritId, context.unit)
	end

	gDressData:AskSetSpiritFashionVariantPreference(spiritId, fashionId, variantFashionId, cb)
end

M.GetSelectableHiddenPart = function(self, hiddenParts)
	local result = {}

	if bit.band(hiddenParts, 1) <= 0 then
		table.insert(result, 1)
	end

	if bit.band(hiddenParts, 2) <= 0 then
		table.insert(result, 2)
	end

	if bit.band(hiddenParts, 4) <= 0 then
		table.insert(result, 3)
	end

	if bit.band(hiddenParts, 8) <= 0 then
		table.insert(result, 4)
	end

	if bit.band(hiddenParts, 16) <= 0 then
		table.insert(result, 5)
	end

	if bit.band(hiddenParts, 32) <= 0 then
		table.insert(result, 6)
	end

	if bit.band(hiddenParts, 64) <= 0 then
		table.insert(result, 7)
	end

	return result
end

M.SetSelectableHiddenPart = function(self, hiddenPartsInfo)
	local result = 0

	for hiddenPartId, info in pairs(hiddenPartsInfo) do
		if info.hide then
			result = result + hiddenPartId
		end
	end

	return result
end

M.EnterDressScene = function(self, spiritId, sceneId, cb)
	gDressSceneManager:EnterDressScene(spiritId, sceneId, function (unit, weatherCb)
		if cb then
			cb(unit, weatherCb)
		end
	end)
end

M.ExitDressScene = function(self)
	gDressSceneManager:ExitDressScene()
end

M.EnterFashionPortal = function(self, enterSceneCb)
	local spiritId = gCS.MyPlayerManager.PlayerUnit.ClientData.cardId

	self:EnterDressScene(spiritId, 1, function (unit, weatherCb)
		if enterSceneCb then
			enterSceneCb()
		end

		gPanelManager:CheckShow(gPanelId.S_FASHION_PORTAL_PANEL, {
			unit = unit,
			spiritId = spiritId,
			weatherCb = weatherCb
		})
	end)
end

M.EnterChangeFashion = function(self, params)
	local spiritId = gCS.MyPlayerManager.PlayerUnit.ClientData.cardId

	self:EnterDressScene(spiritId, 1, function (unit, weatherCb)
		local data = params or {}
		data.spiritContext = self:GetSpiritContext(spiritId, nil, unit)
		data.skipMovementState = true
		data.shouldExitScene = true
		data.isDummyMode = true
		data.weatherCb = weatherCb

		gPanelManager:CheckShow(gPanelId.S_FASHION_DETAIL_PANEL, data)
	end)
end

M.KeepBoneCloth = function(self, unit, keep, frameCount)
	UnitFashionInfoModule.KeepBoneCloth(unit, keep, frameCount)
end

M.IsInPartyTryWear = function(self, context)
	local spiritId = context and context.spiritId

	if not spiritId then
		return false
	end

	local playerFashionsInfo = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo

	if table.isNilOrEmpty(playerFashionsInfo) then
		return false
	end

	local spiritFashionsInfoDict = playerFashionsInfo.SpiritFashionsInfoDict

	if table.isNilOrEmpty(spiritFashionsInfoDict) then
		return false
	end

	local info = spiritFashionsInfoDict[spiritId]

	if not info then
		return false
	end

	local src = info.ActiveClientTryWearSource

	return bit.band(src, UX.Game.FashionWearSource.Rent) == 0 or bit.band(src, UX.Game.FashionWearSource.Host) == 0
end

M.IsInHostCloset = function(self, fashionId)
	local playerFashionsInfo = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo

	if table.isNilOrEmpty(playerFashionsInfo) then
		return false
	end

	local hostList = playerFashionsInfo.HostClosetFashionIds

	if table.isNilOrEmpty(hostList) or hostList.Count ~= 0 then
		return false
	end

	for i = 1, hostList.Count do
		if hostList[i] ~= fashionId then
			return true
		end
	end

	return false
end

M.GetHostClosetFashionList = function(self)
	local playerFashionsInfo = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo

	if table.isNilOrEmpty(playerFashionsInfo) then
		return nil
	end

	return playerFashionsInfo.HostClosetFashionIds
end

M.CanWearFashionInParty = function(self, fashionId, context)
	if self:IsFashionHad(fashionId) then
		return true
	end

	if self:IsInHostCloset(fashionId) then
		return true
	end

	return false
end

M.CalculateAgentSuitId = function(self, agentId, fashionTag)
	local agentCfg = AgentConfig.GetConfig(agentId)

	if not agentCfg then
		return 0
	end

	return Formula_cs:GetNpcFashionSuit(agentCfg.SexType, fashionTag)
end

M.GetOverrideHairByMyPlayer = function(self, spiritId)
	local fashionInfoDict = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo.FashionInfoDict

	if table.isNilOrEmpty(fashionInfoDict) or fashionInfoDict.Count ~= 0 then
		return nil, 
	end

	local hair01, hair02 = nil
	local foundHair01 = false
	local foundHair02 = false

	for _, fashionInfo in pairs(fashionInfoDict) do
		local fashionId = fashionInfo.FashionId
		local cfg = FashionConfig.GetConfig(fashionId)

		if cfg and cfg.IsOneTime and cfg.BelongSpiritId ~= spiritId then
			if not foundHair01 and table.contains(cfg.Types, FashionConfig.TypesType.Hair01) then
				hair01 = fashionId
				foundHair01 = true
			end

			if not foundHair02 and table.contains(cfg.Types, FashionConfig.TypesType.Hair02) then
				hair02 = fashionId
				foundHair02 = true
			end

			if foundHair01 and foundHair02 then
				break
			end
		end
	end

	return hair01, hair02
end

gDressManager = gDressManager or C_DressManager.new()
