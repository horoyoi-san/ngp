require("LX6/Manager/Dress/DressCamera")
require("LX6/Manager/Dress/DressDyeManager")
require("LX6/Manager/Dress/DressRoomChange")

local Formula_cs = require("LuaGen/AutoGen/Formula_cs")
local ShopCommodityCfg = LTConfig.ShopCommodityConfig
local FashionConfig = LTConfig.FashionConfig
local FashionSuitConfig = LTConfig.FashionSuitConfig
local FashionBaseConfig = LTConfig.FashionBaseConfig
local FashionTagConfig = LTConfig.FashionTagConfig
local FashionSpiritConfig = LTConfig.FashionSpiritConfig
local FightSpiritConfig = LTConfig.FightSpiritConfig
local EffectConfig = LTConfig.EffectConfig
local IndoorConfig = LTConfig.IndoorConfig
local FashionFunctionSuitConfig = LTConfig.FashionFunctionSuitConfig
local SoundEventConfig = LTConfig.SoundEventConfig
local SoundConfig = LTConfig.SoundConfig
local LingGuiUtils = require("LX6/GUI/Ling/LingGuiUtils")
local UXVector3 = UX.Game.UXVector3
local AgentConfig = LTConfig.AgentConfig
local M = {
	showHiddenPart = false,
	CurrentSpiritId = 0,
	RecordSpriteId = 0,
	brandsList = {},
	CurrentSpiritInfo = {},
	SpriteFashionInfoDict = {},
	fashionProp = {},
	DRESS_PART = {
		ALL = 100,
		BOTTOMS = 2,
		GLOVES = 3,
		BODY_SUIT = 1,
		SUITS = 101,
		SHOES = 4,
		PROP = 5,
		TOPS = 0
	},
	DRESS_TYPE = {
		Head = 11,
		Bag = 7,
		Dress = 4,
		Cloth = 1,
		Glove = 3,
		Facial = 12,
		Sleeve = 2,
		Shoe = 6,
		ShareMin = 99,
		Bottom = 5
	},
	CtrlZSteps = {},
	FashionId_SuitId = {},
	ConflictBaseFashions = {},
	BodyType2FunctionSuits = {},
	SelectType = {
		tag = {},
		collect = {},
		approach = {},
		brand = {}
	},
	STEP_TYPE = {
		ADD_FASHION = 1,
		REMOVE_FASHION = 2,
		ADD_SUIT = 4,
		EDIT = 3
	},
	OnInit = function (self)
		return
	end,
	GetSuitIdByFashionId = function (self, fashionId)
		if table.isNilOrEmpty(self.FashionId_SuitId) then
			for index = 0, FashionSuitConfig.count - 1 do
				local cfg = FashionSuitConfig.LoadAt(index)

				if cfg then
					for i = 1, #cfg.FashionIdList do
						if table.isNilOrEmpty(self.FashionId_SuitId[cfg.FashionIdList[i]]) then
							self.FashionId_SuitId[cfg.FashionIdList[i]] = {}
						end

						table.insert(self.FashionId_SuitId[cfg.FashionIdList[i]], cfg.Id)
					end
				end
			end
		end

		return self.FashionId_SuitId[fashionId] or {}
	end,
	GetBrandsById = function (self, brandsType)
		if table.isNilOrEmpty(self.brandsList) then
			for index = 0, ShopCommodityCfg.count - 1 do
				local cfg = ShopCommodityCfg.LoadAt(index)

				if cfg and cfg.BelongBrand and cfg.BelongBrand ~= 0 then
					if table.isNilOrEmpty(self.brandsList[cfg.BelongBrand]) then
						self.brandsList[cfg.BelongBrand] = {}
					end

					table.insert(self.brandsList[cfg.BelongBrand], cfg)
				end
			end
		end

		local items = {}

		for i = 1, #brandsType do
			if self.brandsList[brandsType[i]] then
				for t = 1, #self.brandsList[brandsType[i]] do
					table.insert(items, self.brandsList[brandsType[i]][t])
				end
			end
		end

		return items
	end,
	CheckCurrentSpritShowFashion = function (self, fashionId)
		local showFashion = true
		local cfg = FashionConfig.GetConfig(fashionId)

		if cfg then
			if not cfg.IsShow then
				showFashion = false
			end

			if cfg.BelongSpiritId ~= nil and cfg.BelongSpiritId > 0 and cfg.BelongSpiritId ~= self.CurrentSpiritId then
				showFashion = false
			end
		end

		return showFashion
	end,
	CheckFashionConflict = function (self, tryApplyIds)
		local fashionSlot = gCS.MyPlayerManager.PlayerUnit.FashionSlot

		if fashionSlot == nil then
			return {}, {}
		end

		local conflictIds = {}
		local addedBaseIds = {}
		conflictIds, addedBaseIds = fashionSlot:BatchPreHandelFashionApplyConflict(tryApplyIds, true, conflictIds, addedBaseIds)

		return conflictIds:ToTable() or {}, addedBaseIds:ToTable() or {}
	end,
	CheckRemoveFashionConflict = function (self, tryApplyIds)
		local fashionSlot = gCS.MyPlayerManager.PlayerUnit.FashionSlot

		if fashionSlot == nil then
			return
		end

		local conflictIds = {}
		local addedBaseIds = {}
		conflictIds, addedBaseIds = fashionSlot:BatchPreHandleFashionRemoveConflict(tryApplyIds, conflictIds, addedBaseIds)

		return conflictIds:ToTable() or {}, addedBaseIds:ToTable() or {}
	end,
	CheckFashionConflictIsTakeEffect = function (self)
		local fashionSlot = gCS.MyPlayerManager.PlayerUnit.FashionSlot

		if fashionSlot == nil then
			return
		end

		return fashionSlot.DataValid or false
	end,
	CheckPropConflict = function (self, tryApplyIds)
		local conflictIds = {}
		local fashionSlot = gCS.MyPlayerManager.PlayerUnit.FashionSlot
		local allPropApplied = fashionSlot:GetAllFashionPropId()

		if allPropApplied == nil or allPropApplied.Length <= 0 then
			return conflictIds
		end

		for i = 1, #tryApplyIds do
			local cfltId = self:GetPropConflictFashionId(tryApplyIds[i], allPropApplied)

			if cfltId then
				table.insert(conflictIds, cfltId)
			end
		end

		return conflictIds
	end,
	GetPropConflictFashionId = function (self, fashionId, allPropIds)
		local cfg = FashionConfig.GetConfig(fashionId)

		if cfg.Part == gDressManager.DRESS_PART.PROP then
			local type = cfg.Types[1]

			for i = 0, allPropIds.Length - 1 do
				local acfg = FashionConfig.GetConfig(allPropIds[i])

				if type == acfg.Types[1] and fashionId ~= allPropIds[i] then
					return allPropIds[i]
				end
			end
		end

		return false
	end,
	CheckSpriteHasDefaultUnderwear = function (self)
		local spriteFashionInfo = self.SpriteFashionInfoDict[self.CurrentSpiritId]

		if spriteFashionInfo then
			for i, info in pairs(spriteFashionInfo.WearFashionInfoList) do
				local cfg = FashionConfig.GetConfig(info.FashionId)

				if cfg.IsDefaultUnderwear then
					return true
				end
			end
		end

		return false
	end,
	IsTempWearFashionList = function (self, fashionList)
		local wearCount = 0
		local spriteFashionInfo = self.SpriteFashionInfoDict[self.CurrentSpiritId]

		if spriteFashionInfo then
			for i = 1, #spriteFashionInfo.WearFashionInfoList do
				if table.contains(fashionList, spriteFashionInfo.WearFashionInfoList[i].FashionId) then
					wearCount = wearCount + 1
				end
			end
		end

		if wearCount == #fashionList then
			return true
		end

		return false
	end,
	IsPlayerWearFashionList = function (self, fashionList)
		if table.isNilOrEmpty(fashionList) then
			return true
		end

		local wearCount = 0
		local spiritFashionsInfoDict = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo.SpiritFashionsInfoDict
		local spiritFashionsInfo = spiritFashionsInfoDict[self.CurrentSpiritId]

		if spiritFashionsInfo then
			local wearInfo = spiritFashionsInfo.SpiritWearFashionsInfo.WearFashionInfoList

			if wearInfo.Count ~= table.count(fashionList) then
				return false
			end

			for t = 1, wearInfo.Count do
				if table.contains(fashionList, wearInfo[t].FashionId) then
					wearCount = wearCount + 1
				end
			end

			if wearCount == wearInfo.Count then
				return true
			end
		end

		return false
	end,
	IsDressEditNoChange = function (self, edit)
		if table.isNilOrEmpty(edit) then
			return true
		end

		local spiritFashionsInfoDict = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo.SpiritFashionsInfoDict
		local spiritFashionsInfo = spiritFashionsInfoDict[self.CurrentSpiritId]

		if spiritFashionsInfo then
			local wearFashionEditInfoList = spiritFashionsInfo.WearFashionEditInfoList

			if not table.isNilOrEmpty(wearFashionEditInfoList) then
				for i = 1, wearFashionEditInfoList.Count do
					if wearFashionEditInfoList[i].SpiritId == self.CurrentSpiritId then
						local editInfo = wearFashionEditInfoList[i]

						if editInfo.FashionId == edit.FashionId and edit.Scale == editInfo.Scale and edit.Offset == editInfo.Offset and edit.Rotation == editInfo.Rotation then
							return true
						end
					end
				end
			end
		end

		return false
	end,
	IsSamePart = function (self, fashion1, fashion2)
		local cfg1 = FashionConfig.GetConfig(fashion1)
		local cfg2 = FashionConfig.GetConfig(fashion2)

		if cfg1 and cfg2 and cfg1.Part == cfg2.Part then
			return true
		end

		return false
	end,
	IsFashionCanEdit = function (self, fashionId)
		local cfg = FashionConfig.GetConfig(fashionId)

		if cfg then
			return cfg.EditId and cfg.EditId > 0
		end

		return false
	end,
	GetCurrentSpritFashionList = function (self)
		local spriteFashionInfo = self.SpriteFashionInfoDict[self.CurrentSpiritId]

		if spriteFashionInfo == nil then
			return {}
		end

		local myFashionList = {}

		for i = 1, #spriteFashionInfo.WearFashionInfoList do
			table.insert(myFashionList, spriteFashionInfo.WearFashionInfoList[i].FashionId)
		end

		return spriteFashionInfo.WearFashionInfoList
	end,
	GetMyCurrentFashionList = function (self)
		local list = {}
		local spriteFashionInfo = gDressManager.SpriteFashionInfoDict[gDressManager.CurrentSpiritId]

		if spriteFashionInfo then
			local wearInfoList = spriteFashionInfo.WearFashionInfoList

			for i = 1, #wearInfoList do
				table.insert(list, wearInfoList[i].FashionId)
			end
		end

		return list, spriteFashionInfo and spriteFashionInfo.WearFashionEditInfoList or {}
	end,
	GetTagList = function (self, fashionId)
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
}

function M:SetPlayerFashionsInfo()
	self.recordAddFashionList = {}
	local spiritFashionsInfoDict = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo.SpiritFashionsInfoDict

	for spiritId, spiritFashionsInfo in pairs(spiritFashionsInfoDict) do
		local spriteFashionInfo = {}
		self.SpriteFashionInfoDict[spiritId] = spriteFashionInfo
		local wearInfoList = {}
		local tempWearList = spiritFashionsInfo.SpiritWearFashionsInfo.WearFashionInfoList

		if tempWearList then
			local count = tempWearList.Count or #tempWearList

			for t = 1, count do
				local cfg = FashionConfig.GetConfig(tempWearList[t].FashionId)

				if cfg then
					local view = {
						ColoringType = tempWearList[t].ColoringType,
						FashionId = tempWearList[t].FashionId
					}

					table.insert(wearInfoList, view)
				end
			end
		end

		spriteFashionInfo.WearFashionInfoList = wearInfoList
		local editInfoList = {}
		local tempEditList = spiritFashionsInfo.SpiritWearFashionsInfo.WearFashionEditInfoList

		if tempEditList then
			for t = 1, tempEditList.Count do
				local cfg = FashionConfig.GetConfig(tempEditList[t].FashionId)

				if cfg then
					local view = {
						FashionId = tempEditList[t].FashionId,
						Scale = tempEditList[t].Scale,
						Offset = tempEditList[t].Offset,
						Rotation = tempEditList[t].Rotation
					}

					table.insert(editInfoList, view)
				end
			end
		end

		spriteFashionInfo.WearFashionEditInfoList = editInfoList
	end
end

function M:CheckHasPropEdit(fashionId)
	local spriteFashionInfo = self.SpriteFashionInfoDict[self.CurrentSpiritId]

	if spriteFashionInfo and spriteFashionInfo.WearFashionEditInfoList then
		for i = 1, #spriteFashionInfo.WearFashionEditInfoList do
			if fashionId == spriteFashionInfo.WearFashionEditInfoList[i].FashionId then
				self:PreSetPropEditInfo(fashionId, spriteFashionInfo.WearFashionEditInfoList[i].Rotation, spriteFashionInfo.WearFashionEditInfoList[i].Offset, spriteFashionInfo.WearFashionEditInfoList[i].Scale)

				return
			end
		end
	end
end

function M:ChangeFashionPart(fashionList, removeFashionIdList)
	local spriteFashionInfo = self.SpriteFashionInfoDict[self.CurrentSpiritId]

	if spriteFashionInfo == nil then
		return
	end

	local list = {}
	local fashionIdList = {}

	for i, fashionInfo in pairs(spriteFashionInfo.WearFashionInfoList) do
		if not table.contains(removeFashionIdList, fashionInfo.FashionId) then
			table.insert(list, fashionInfo)
			table.insert(fashionIdList, fashionInfo.FashionId)
		end
	end

	spriteFashionInfo.WearFashionInfoList = list

	for i = 1, #fashionList do
		local cfg = FashionConfig.GetConfig(fashionList[i])

		if cfg and self:IsFashionHaved(fashionList[i]) and not table.contains(fashionIdList, fashionList[i]) and not self:CheckHasConflictTypes(fashionIdList, fashionList[i]) then
			local view = {
				ColoringType = 0,
				FashionId = fashionList[i]
			}

			table.insert(spriteFashionInfo.WearFashionInfoList, view)
		end
	end
end

function M:CheckHasConflictTypes(list, fashionId)
	local fashionCfg = FashionConfig.GetConfig(fashionId)

	if fashionCfg then
		for i = 1, #list do
			local cfg = FashionConfig.GetConfig(list[i])

			for t, v in pairs(cfg.Types) do
				if v ~= self.DRESS_TYPE.Sleeve and v ~= self.DRESS_TYPE.Dress and v ~= self.DRESS_TYPE.ShareMin and table.contains(fashionCfg.Types, v) then
					return true
				end
			end
		end
	end

	return false
end

function M:SetFashionList(fashionIdList, isFromIndoor)
	local unit = gCS.MyPlayerManager.PlayerUnit
	local pid = unit.Pid

	if unit.FirstLoadModel then
		unit.OnFirstLoadCompleteHandler = unit.OnFirstLoadCompleteHandler + function ()
			if gCS.MyPlayerManager.PlayerUnit.Pid == pid then
				self:SetFashionList(fashionIdList)
			end
		end
	else
		local fashionSlot = gCS.MyPlayerManager.PlayerUnit.FashionSlot

		if fashionSlot == nil then
			return
		end

		fashionSlot:TrySetFashionPartList(fashionIdList)

		if isFromIndoor then
			local effectCfg = EffectConfig.GetConfig(FightSpiritConfig.CommonSwitchEffect)

			if not gPauseManager.isBreak and effectCfg and effectCfg.Time > 0 then
				gCS.EffectMgr:PlayEffectsForUnit(gCS.MyPlayerManager.PlayerUnit, FightSpiritConfig.CommonSwitchEffect)
			end
		end
	end

	local curSpiritCfg = FightSpiritConfig.GetConfig(self.CurrentSpiritId)

	if curSpiritCfg then
		gSoundMgr:PlayCharacterCombineExternalVoice(SoundConfig.Char_COS, curSpiritCfg.AgentId)
	end
end

function M:RemoveFashionPart(fashionIdList, noAddBase)
	local fashionSlot = gCS.MyPlayerManager.PlayerUnit.FashionSlot

	if fashionSlot == nil then
		return
	end

	fashionSlot:TryRemoveFashionPartList(fashionIdList, noAddBase or false)
end

function M:CheckClearFashionPart()
	local fashionSlot = gCS.MyPlayerManager.PlayerUnit.FashionSlot

	if not fashionSlot then
		print_warn("当前角色不能换装")

		return
	end

	fashionSlot:SyncApplyPlayerFashionInfo()
end

function M:IsFashionHaved(fashionId)
	local fashionInfoDict = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo.FashionInfoDict

	if table.isNilOrEmpty(fashionInfoDict) or fashionInfoDict.Count == 0 then
		return false
	end

	local cfg = FashionConfig.GetConfig(fashionId)

	if cfg and cfg.IsDefaultUnderwear then
		return true
	end

	local fashionInfo = fashionInfoDict[fashionId]

	return not table.isNilOrEmpty(fashionInfo)
end

function M:DressSuitFashionList(list, isSaveInfo, isFromIndoor, ignoreRecord)
	local fashionList = table.clone(list)
	local removeFashionIdList = {}
	local spriteFashionInfo = self.SpriteFashionInfoDict[self.CurrentSpiritId]

	if spriteFashionInfo == nil then
		return
	end

	if table.isNilOrEmpty(self.recordAddFashionList) or ignoreRecord then
		for i, fashionInfo in pairs(spriteFashionInfo.WearFashionInfoList) do
			if not table.contains(fashionList, fashionInfo.FashionId) then
				table.insert(removeFashionIdList, fashionInfo.FashionId)
			end
		end
	else
		removeFashionIdList = self.recordAddFashionList
	end

	self:CheckAddFashionDefault(fashionList)

	if table.isNilOrEmpty(self.ConflictBaseFashions) then
		for index = 0, FashionSpiritConfig.count - 1 do
			local cfg = FashionSpiritConfig.LoadAt(index)

			if cfg then
				if self.ConflictBaseFashions[cfg.FightSpiritId] == nil then
					self.ConflictBaseFashions[cfg.FightSpiritId] = {}
				end

				self.ConflictBaseFashions[cfg.FightSpiritId].gloves = cfg.BaseGlove
				self.ConflictBaseFashions[cfg.FightSpiritId].shoes = cfg.BaseShoe
			end
		end
	end

	if isSaveInfo then
		local recordRemoveList = {}

		for i, fashionInfo in pairs(spriteFashionInfo.WearFashionInfoList) do
			if not table.contains(fashionList, fashionInfo.FashionId) then
				table.insert(recordRemoveList, fashionInfo.FashionId)
			end
		end

		self:ChangeFashionPart(fashionList, recordRemoveList)
	end

	self:RemoveFashionPart(removeFashionIdList, true)

	self.recordAddFashionList = fashionList

	self:SetFashionList(fashionList, isFromIndoor)
end

function M:DressNewFashionListAndEdit(fashionList, fashionEditList, recordFashionList)
	local removeList = {}
	local changeList = {}

	if recordFashionList == nil then
		recordFashionList = self:GetMyCurrentFashionList()
	end

	for i = 1, #recordFashionList do
		if table.contains(fashionList, recordFashionList[i]) then
			table.insert(changeList, recordFashionList[i])
		else
			table.insert(removeList, recordFashionList[i])
		end
	end

	if table.isNilOrEmpty() then
		gDressManager:RemoveFashionPart(removeList)
	end

	local hasEditList = {}

	if not table.isNilOrEmpty(fashionEditList) then
		for i = 1, #fashionEditList do
			table.insert(hasEditList, fashionEditList[i].FashionId)

			local info = fashionEditList[i]
			local rotation = UXVector3.New(info.Rotation.X, info.Rotation.Y, info.Rotation.Z)
			local offset = UXVector3.New(info.Offset.X, info.Offset.Y, info.Offset.Z)

			gDressManager:PreSetPropEditInfo(info.FashionId, rotation, offset, info.Scale)
		end
	end

	for i = 1, #changeList do
		if not table.contains(hasEditList, changeList[i]) and gDressManager:IsFashionCanEdit(changeList[i]) then
			gDressManager:PreSetPropEditInfo(changeList[i], UXVector3.New(0, 0, 0), UXVector3.New(0, 0, 0), 1)
		end
	end

	gDressManager:DressSuitFashionList(fashionList, true, false, true)
end

function M:CheckAddFashionDefault(fashionList)
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

	if table.isNilOrEmpty(self.ConflictBaseFashions) then
		for index = 0, FashionSpiritConfig.count - 1 do
			local cfg = FashionSpiritConfig.LoadAt(index)

			if cfg then
				if self.ConflictBaseFashions[cfg.FightSpiritId] == nil then
					self.ConflictBaseFashions[cfg.FightSpiritId] = {}
				end

				self.ConflictBaseFashions[cfg.FightSpiritId].gloves = cfg.BaseGlove
				self.ConflictBaseFashions[cfg.FightSpiritId].shoes = cfg.BaseShoe
			end
		end
	end

	local addList = {}
	local baseFashion = self.ConflictBaseFashions[self.CurrentSpiritId]

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

function M:GetUnitProp(fashionId, isNotEdit)
	if self.fashionProp[fashionId] == nil or isNotEdit then
		self.fashionProp[fashionId] = gCS.UnitFashionPropController.GetUnitProp(gCS.MyPlayerManager.PlayerUnit, fashionId)
	end

	return self.fashionProp[fashionId]
end

local tempVec = Vector3.zero

function M:DoChange(fashionId, euler, offset, scale, isNotEdit)
	if fashionId == nil or fashionId == 0 then
		print_error("fashionId is nil or 0")

		return
	end

	local propRecord = self:GetUnitProp(fashionId, isNotEdit)

	if propRecord then
		euler = euler or tempVec
		offset = offset or tempVec
		scale = scale or 1

		gCS.UnitFashionPropController.DoChange(propRecord, euler, offset, scale)
	else
		print_error("找不到对应的UnitProp ，fashionId = " .. fashionId)
	end
end

function M:PreSetPropEditInfo(fashionId, euler, offset, scale)
	if fashionId == nil or fashionId == 0 then
		print_error("fashionId is nil or 0")

		return
	end

	local eu = Vector3.New(euler.X, euler.Y, euler.Z)
	local of = Vector3.New(offset.X, offset.Y, offset.Z)

	if self:IsTempWearFashionList({
		fashionId
	}) then
		self:DoChange(fashionId, eu, of, scale, true)
	else
		local fashionSlot = gCS.MyPlayerManager.PlayerUnit.FashionSlot

		if fashionSlot == nil then
			return
		end

		gCS.UnitFashionPropController.PreSetPropEditInfo(gCS.MyPlayerManager.PlayerUnit.FashionSlot, fashionId, eu, of, scale)
		fashionSlot:TrySetFashionPartList({
			fashionId
		})
	end
end

function M:SaveFashionListEdit(FashionId, Scale, Offset, Rotation)
	local editInfoList = {
		FashionId = FashionId,
		Scale = Scale,
		Offset = Offset,
		Rotation = Rotation
	}
	local spriteFashionInfo = gDressManager.SpriteFashionInfoDict[gDressManager.CurrentSpiritId]

	if spriteFashionInfo then
		local hasEditInfo = false

		for i = 1, #spriteFashionInfo.WearFashionEditInfoList do
			if spriteFashionInfo.WearFashionEditInfoList[i].FashionId == FashionId then
				spriteFashionInfo.WearFashionEditInfoList[i] = editInfoList
				hasEditInfo = true

				break
			end
		end

		if not hasEditInfo then
			table.insert(spriteFashionInfo.WearFashionEditInfoList, editInfoList)
		end
	end
end

function M:SetHiddenParts(hiddenParts, editedHiddenParts)
	local fashionSlot = gCS.MyPlayerManager.PlayerUnit.FashionSlot

	if fashionSlot == nil then
		return
	end

	fashionSlot:SetHiddenParts(hiddenParts, editedHiddenParts)
	fashionSlot:ForceRefreshHiddenPart()
end

function M:RefreshPlayerHiddenPartsData(hiddenParts, editedHiddenParts)
	local fashionSlot = gCS.MyPlayerManager.PlayerUnit.FashionSlot

	if fashionSlot == nil or self.CurrentSpiritId == 0 then
		return
	end

	fashionSlot:RefreshPlayerHiddenPartsData(self.CurrentSpiritId, hiddenParts, editedHiddenParts)
end

function M:SetCurrentPlayerSpirit(cardId)
	if gCS.MyPlayerManager.PlayerUnit then
		gCS.MyPlayerManager.PlayerUnit:SetForceShowWeapon(true, LX6.Units.BaseUnit.ForceReason.Dress, false)

		if cardId == nil or cardId == 0 then
			cardId = gCS.MyPlayerManager.PlayerUnit.ClientData.cardId
		end

		gDressManager.CurrentSpiritId = cardId
		local lingList = LingGuiUtils:GetAllLingList()

		for i = 1, #lingList do
			if lingList[i].Id == self.CurrentSpiritId then
				gDressManager.CurrentSpiritInfo = lingList[i]

				break
			end
		end

		if gCS.MyPlayerManager.PlayerUnit.ClientData.cardId ~= cardId then
			gBattleSpiritMgr:ResetPlayerCardId(gCS.MyPlayerManager.PlayerUnit.Pid, cardId)
		end

		if self.RecordSpriteId == 0 then
			self.RecordSpriteId = cardId
		end

		self.recordAddFashionList = {}
	end
end

function M:TransformPlayer(y)
	local csUnit = gCS.MyPlayerManager.PlayerUnit

	if csUnit then
		local facing = gCS.MyPlayerManager.PlayerUnit.FacingDirection

		gCS.MyPlayerManager.PlayerUnit:SetFacing(facing + y)
	end
end

function M:SelectSuitableSpiritForFashion(fashionCfg, currentSpiritId)
	if not fashionCfg then
		return currentSpiritId
	end

	local requiredGender = fashionCfg.Gender or 0
	local belongSpiritId = fashionCfg.BelongSpiritId

	if belongSpiritId and belongSpiritId > 0 then
		return belongSpiritId
	end

	local function CheckGender(spiritId)
		local spiritCfg = LTConfig.FightSpiritConfig.GetConfig(spiritId)

		if not spiritCfg then
			return false
		end

		local agentCfg = AgentConfig.GetConfig(spiritCfg.AgentId)

		return agentCfg and (requiredGender == 0 or agentCfg.SexType == requiredGender)
	end

	if CheckGender(currentSpiritId) then
		return currentSpiritId
	end

	local spiritIdList = LTConfig.CityPediaConfig.FashionShowcaseSpiritList

	for i = 1, #spiritIdList do
		local spiritCfg = LTConfig.FightSpiritConfig.GetConfig(spiritIdList[i])

		if spiritCfg then
			local agentCfg = AgentConfig.GetConfig(spiritCfg.AgentId)

			if agentCfg and (requiredGender == 0 or agentCfg.SexType == requiredGender) then
				return spiritCfg.Id
			end
		end
	end

	return currentSpiritId
end

function M:ClearCurrentPlayerSpirit(isResetDress, keepInfo, keepSpriteId)
	if gCS.MyPlayerManager.PlayerUnit then
		gCS.MyPlayerManager.PlayerUnit:SetForceShowWeapon(false, LX6.Units.BaseUnit.ForceReason.Dress, false)
	end

	if gMapManager.IndoorId > 0 and gTaskManager:IsTaskSubmitted(FashionConfig.IndoorDressUnlockTask) then
		local cfg = IndoorConfig.GetConfig(gMapManager.IndoorId)

		if cfg and cfg.FashionFunctionSuitApplyId > 0 then
			return
		end
	end

	self:ResetDressAction()

	if gCS.MyPlayerManager.PlayerUnit and gCS.MyPlayerManager.PlayerUnit.ClientData.cardId ~= self.RecordSpriteId and self.RecordSpriteId ~= 0 and not keepSpriteId then
		gBattleSpiritMgr:ResetPlayerCardId(gCS.MyPlayerManager.PlayerUnit.Pid, self.RecordSpriteId)
	elseif isResetDress then
		gDressManager:CheckClearFashionPart()
	end

	if not keepInfo then
		self.CurrentSpiritId = 0
		self.RecordSpriteId = 0
		self.recordAddFashionList = {}
	end
end

function M:PlayDressDefaultAction()
	self.playActionTime = nil
	local defaultActionInfo = FashionConfig.FashionDefaultAction

	if table.isNilOrEmpty(defaultActionInfo) then
		print_error("没有找到默认动作  FashionConfig.FashionDefaultAction")

		return
	end

	self:PlayDressBaseAction(defaultActionInfo.actionid, defaultActionInfo.groupid, defaultActionInfo.expressionid, true)
end

function M:PlayDressSuitAction()
	local suitActionInfo = FashionConfig.FashionShopActionSuit

	if table.isNilOrEmpty(suitActionInfo) then
		print_error("没有找到默认动作  FashionConfig.FashionShopActionSuit")

		return
	end

	self:PlayDressBaseAction(suitActionInfo.actionid, suitActionInfo.groupid, suitActionInfo.expressionid)
end

function M:PlayDressAction(Types)
	local actionName = self:GetFashionShopActionTypeByFashionType(Types)
	local bodyType = self.CurrentSpiritInfo.CameraBodyType
	local cfg = FashionBaseConfig.GetConfig(bodyType)
	local info = cfg[actionName]

	if info then
		self:PlayDressBaseAction(info.actionid, info.groupid, info.expressionid)
	else
		print_error("没有找到对应的动作, types = " .. Types)
	end
end

function M:PlayRandomDressAction()
	local keys = {}

	for k, _ in pairs(self.DRESS_TYPE) do
		table.insert(keys, k)
	end

	local randomKey = keys[math.random(1, #keys)]

	print("时装动作随机到 " .. randomKey)

	local types = self.DRESS_TYPE[randomKey]

	self:PlayDressAction(types)
end

function M:PlayDressBaseAction(actionId, actionGroupId, expressionId, isDefault)
	if self.playActionTime ~= nil and gLogicTime.time - self.playActionTime <= FashionConfig.FashionShopActionCD then
		print("当前已经有在播的动作，还在播动作的CD内，不能再播新动作")

		return
	end

	if not isDefault then
		self.playActionTime = gLogicTime.time
	end

	local unit = gCS.MyPlayerManager.PlayerUnit

	gCS.LogicStateMachineManager.SendGameplayInwardSignal(unit, actionGroupId, actionId)

	if gCS.MyPlayerManager.PlayerUnit.ModelSlot and gCS.MyPlayerManager.PlayerUnit.ModelSlot.ExpressionController then
		gCS.MyPlayerManager.PlayerUnit.ModelSlot.ExpressionController:Init(gCS.MyPlayerManager.PlayerUnit, 2)
		gCS.MyPlayerManager.PlayerUnit.ModelSlot.ExpressionController:PlaySpecialExpression(expressionId, 0, true, 0)
	end
end

function M:GetFashionShopActionTypeByFashionType(type)
	local FashionShopActionType = FashionConfig.FashionShopActionType

	for i = 1, #FashionShopActionType do
		if FashionShopActionType[i].type == type then
			return FashionShopActionType[i].action
		end
	end
end

function M:ResetDressAction()
	if gCS.MyPlayerManager.PlayerUnit then
		gCS.MyPlayerManager.PlayerUnit:ResetActionGroupId()
	end
end

function M:AddStep(data)
	table.insert(self.CtrlZSteps, data)

	if table.count(self.CtrlZSteps) > 10 then
		table.remove(self.CtrlZSteps, 1)
	end

	self.currentPointIndex = #self.CtrlZSteps
end

function M:HasLastStep(index)
	if not self.currentPointIndex then
		return false
	end

	if self.CtrlZSteps[self.currentPointIndex - 1] then
		return true
	end

	return false
end

function M:HasNextStep()
	if not self.currentPointIndex then
		return false
	end

	if self.CtrlZSteps[self.currentPointIndex + 1] then
		return true
	end

	return false
end

function M:ClearSteps()
	self.currentPointIndex = 0
	self.CtrlZSteps = {}
end

function M:IsFashinCollected(fashionId)
	if fashionId == nil or fashionId == 0 then
		return false
	end

	local info = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo.FavoriteFashionIdList

	if table.isNilOrEmpty(info) then
		return false
	end

	for i = 1, info.Count do
		if info[i] == fashionId then
			return true
		end
	end

	return false
end

function M:IsFashinSuitCollected(suitId)
	if suitId == nil or suitId == 0 then
		return false
	end

	local info = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo.FavoriteFashionSuitIdList

	if table.isNilOrEmpty(info) then
		return false
	end

	for i = 1, info.Count do
		if info[i] == suitId then
			return true
		end
	end

	return false
end

function M:IsFashionListHasRedDotNew(list)
	local fashionInfoDict = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo.FashionInfoDict
	local fashionInfo = nil

	for _, fashionId in ipairs(list) do
		fashionInfo = fashionInfoDict[fashionId]

		if fashionInfo and fashionInfo.Status == 1 then
			return true
		end
	end

	return false
end

function M:InitFunctionSuitTypes()
	if table.isNilOrEmpty(self.BodyType2FunctionSuits) then
		self.BodyType2FunctionSuits = {}

		for i = 0, FashionFunctionSuitConfig.count - 1 do
			local cfg = FashionFunctionSuitConfig.LoadAt(i)

			if cfg then
				for t = 1, #cfg.BodyTypeList do
					if self.BodyType2FunctionSuits[cfg.BodyTypeList[t]] == nil then
						self.BodyType2FunctionSuits[cfg.BodyTypeList[t]] = {}
					end

					if table.isNilOrEmpty(self.BodyType2FunctionSuits[cfg.BodyTypeList[t]]) then
						self.BodyType2FunctionSuits[cfg.BodyTypeList[t]] = {}
					end

					self.BodyType2FunctionSuits[cfg.BodyTypeList[t]][cfg.Id] = cfg
				end
			end
		end
	end
end

function M:GetBodyType2FunctionSuits(bodyType)
	if bodyType == nil then
		if table.isNilOrEmpty(self.CurrentSpiritInfo) then
			self:SetCurrentPlayerSpirit()
		end

		bodyType = self.CurrentSpiritInfo.CameraBodyType
	end

	if table.isNilOrEmpty(self.BodyType2FunctionSuits[bodyType]) then
		self.BodyType2FunctionSuits[bodyType] = {}
	end

	local spiritFashionsInfoDict = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo.SpiritFashionsInfoDict
	local spiritFashionsInfo = spiritFashionsInfoDict[self.CurrentSpiritId]

	if spiritFashionsInfo and not table.isNilOrEmpty(spiritFashionsInfo.FashionFunctionSuitSchemeInfoDict) then
		for functionSuitId, info in pairs(spiritFashionsInfo.FashionFunctionSuitSchemeInfoDict) do
			local cfg = FashionFunctionSuitConfig.GetConfig(functionSuitId)

			if cfg then
				local fashionIdList = {}
				local count = info.WearFashionInfoList.Count

				if count == nil then
					count = #info.WearFashionInfoList
				end

				for i = 1, count do
					table.insert(fashionIdList, info.WearFashionInfoList[i].FashionId)
				end

				local cfgInfo = {
					FashionIdList = fashionIdList,
					FashionEditList = info.WearFashionEditInfoList.Count == nil and info.WearFashionEditInfoList or {},
					Title = cfg.Title,
					TagId = cfg.TagId,
					Icon = cfg.Icon,
					Icon = cfg.Icon,
					IconChoose = cfg.IconChoose
				}

				if table.contains(cfg.BodyTypeList, bodyType) then
					if table.isNilOrEmpty(self.BodyType2FunctionSuits[bodyType][functionSuitId]) then
						self.BodyType2FunctionSuits[bodyType][functionSuitId] = {}
					end

					self.BodyType2FunctionSuits[bodyType][functionSuitId] = cfgInfo
				end
			end
		end
	end

	return self.BodyType2FunctionSuits[bodyType] or {}
end

function M:GetSuitSchemeName(spiritId)
	if spiritId == nil then
		spiritId = self.CurrentSpiritId
	end

	local spiritFashionsInfoDict = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo.SpiritFashionsInfoDict
	local spiritFashionsInfo = spiritFashionsInfoDict[spiritId]

	if spiritFashionsInfo then
		return spiritFashionsInfo.FashionCustomSuitSchemeInfos or {}
	end

	return {}
end

function M:SetCustomSuitSchemeName(spiritId, schemeIndex, schemeName)
	if spiritId == nil then
		spiritId = self.CurrentSpiritId
	end

	local spiritFashionsInfoDict = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo.SpiritFashionsInfoDict
	local spiritFashionsInfo = spiritFashionsInfoDict[spiritId]

	if spiritFashionsInfo and spiritFashionsInfo.FashionCustomSuitSchemeInfos[schemeIndex] then
		spiritFashionsInfo.FashionCustomSuitSchemeInfos[schemeIndex].SchemeName = schemeName
	end
end

function M:GetSelectableHiddenPart(hiddenParts)
	local result = {}

	if bit.band(hiddenParts, 1) > 0 then
		table.insert(result, 1)
	end

	if bit.band(hiddenParts, 2) > 0 then
		table.insert(result, 2)
	end

	if bit.band(hiddenParts, 4) > 0 then
		table.insert(result, 3)
	end

	if bit.band(hiddenParts, 8) > 0 then
		table.insert(result, 4)
	end

	return result
end

function M:SetSelectableHiddenPart(hiddenPartsInfo)
	local result = 0

	for hiddenPartId, info in pairs(hiddenPartsInfo) do
		if info.hide then
			result = result + hiddenPartId
		end
	end

	return result
end

function M:CheckMyOotdHiddenPart(fashionId)
	local cfg = FashionConfig.GetConfig(fashionId)

	if cfg then
		local showPart = gDressManager:GetSelectableHiddenPart(cfg.SelectableHiddenPart)
		self.showHiddenPart = not table.isNilOrEmpty(showPart) or false
	end
end

function M:CheckMyPresentHiddenPart()
	self.showHiddenPart = false
	local myFashionList = self:GetCurrentSpritFashionList()

	for i = 1, #myFashionList do
		local cfg = FashionConfig.GetConfig(myFashionList[i])

		if cfg then
			local showPart = gDressManager:GetSelectableHiddenPart(cfg.SelectableHiddenPart)

			if not table.isNilOrEmpty(showPart) then
				self.showHiddenPart = true
			end
		end
	end
end

function M:CalculateAgentSuitId(agentId, fashionTag)
	local agentCfg = AgentConfig.GetConfig(agentId)

	if not agentCfg then
		return 0
	end

	return Formula_cs:GetNpcFashionSuit(agentCfg.SexType, fashionTag)
end

gDressManager = M
