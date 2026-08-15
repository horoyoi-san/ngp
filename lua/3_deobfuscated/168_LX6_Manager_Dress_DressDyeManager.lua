local FashionConfig = LTConfig.FashionConfig
local FashionColorConfig = LTConfig.FashionColorConfig
gDressDyeManager = gDressDyeManager or {}
local M = {
	DYE_STATE = {
		CAN_DYE = 1,
		HAS_DYE = 2,
		CANOT_DYE = 0
	},
	colorGroupList = {},
	colorCfgId2Color = {},
	InitColorList = function (self)
		if table.isNilOrEmpty(self.colorGroupList) then
			self.colorGroupList = {}
			self.colorCfgId2Color = {}

			for i = 0, FashionColorConfig.count - 1 do
				local cfg = FashionColorConfig.LoadAt(i)

				if cfg and cfg.GroupId > 0 then
					if self.colorGroupList[cfg.GroupId] == nil then
						self.colorGroupList[cfg.GroupId] = {}
					end

					local view = {
						Id = cfg.Id,
						groupId = cfg.GroupId,
						color = self:GetColor(cfg.Id)
					}
					self.colorCfgId2Color[cfg.Id] = view.color

					table.insert(self.colorGroupList[cfg.GroupId], view)
				end
			end
		end
	end,
	ConvertToColoringType = function (self, coloringTypeList)
		if table.isNilOrEmpty(coloringTypeList) then
			return FashionConfig.ColoringType.None
		end

		local curColoring = FashionConfig.ColoringType.None

		for _, coloring in ipairs(coloringTypeList) do
			curColoring = bit.bor(curColoring, coloring)
		end

		return curColoring
	end
}

function M:GetColorTabList(fashionId)
	local cfg = FashionConfig.GetConfig(fashionId)

	if cfg then
		local coloringList = cfg.Coloring
		local result = {}

		for _, coloring in pairs(coloringList) do
			local exponent = math.log(coloring) / math.log(2) + 1

			table.insert(result, exponent)
		end

		return result
	end

	return {}
end

function M:GetDyeState(fashionId)
	local cfg = FashionConfig.GetConfig(fashionId)
	local state = self.DYE_STATE.CANOT_DYE

	if cfg and #cfg.Coloring > 0 then
		if self:IsFashionHasDye(fashionId) then
			state = self.DYE_STATE.HAS_DYE
		else
			state = self.DYE_STATE.CAN_DYE
		end
	end

	return state
end

function M:IsFashionHasDye(fashionId)
	local fashionInfoDict = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo.FashionInfoDict
	local fashionInfo = fashionInfoDict[fashionId]

	if fashionInfo then
		return fashionInfo.ApplyColoringSchemeId and fashionInfo.ApplyColoringSchemeId > 0
	end

	return false
end

function M:GetColorPlanList(fashionId)
	local cfg = FashionConfig.GetConfig(fashionId)

	if cfg then
		local fashionInfoDict = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo.FashionInfoDict
		local fashionInfo = fashionInfoDict[fashionId]

		if fashionInfo then
			return table.clone(fashionInfo.ColoringSchemeInfoDict), fashionInfo.ApplyColoringSchemeId
		end
	end
end

function M:SetColor(fashionId, partId, colorCfgId)
	local fashionSlot = gCS.MyPlayerManager.PlayerUnit.FashionSlot

	if fashionSlot == nil then
		return
	end

	fashionSlot:SetColor(fashionId, partId, colorCfgId)
end

function M:SetColorList(fashionId, coloringList)
	if table.isNilOrEmpty(coloringList) then
		return
	end

	local colorMatIdDict = {}

	for coloringType, colorCfgId in pairs(coloringList) do
		local index = self:GetColorMatList(coloringType)

		if index then
			colorMatIdDict[index] = colorCfgId
		end
	end

	local fashionSlot = gCS.MyPlayerManager.PlayerUnit.FashionSlot

	if fashionSlot == nil then
		return
	end

	fashionSlot:ResetListColor(fashionId)
	fashionSlot:SetColorList(fashionId, colorMatIdDict)
end

function M:GetColor(colorCfgId)
	local fashionSlot = gCS.MyPlayerManager.PlayerUnit.FashionSlot

	if fashionSlot == nil then
		return
	end

	local r = 0
	local g = 0
	local b = 0
	local a = 1
	r, g, b, a = fashionSlot.GetColor(colorCfgId, r, g, b, a)

	return Color.New(r, g, b, a)
end

function M:ResetColor(fashionId, partIdList)
	local fashionSlot = gCS.MyPlayerManager.PlayerUnit.FashionSlot

	if fashionSlot == nil then
		return
	end

	fashionSlot:ResetColor(fashionId, partIdList)
end

function M:ResetListColor(fashionId)
	local fashionSlot = gCS.MyPlayerManager.PlayerUnit.FashionSlot

	if fashionSlot == nil then
		return
	end

	fashionSlot:ResetListColor(fashionId)
end

function M:SetFashionPartSlotHighLight(fashionId, partId)
	local fashionSlot = gCS.MyPlayerManager.PlayerUnit.FashionSlot

	if fashionSlot == nil then
		return
	end

	fashionSlot:SetFashionPartSlotHighLight(fashionId, 2, partId)
end

function M:GetColorMatList(color)
	if bit.band(color, 1) > 0 then
		return 1
	end

	if bit.band(color, 2) > 0 then
		return 2
	end

	if bit.band(color, 4) > 0 then
		return 3
	end

	if bit.band(color, 8) > 0 then
		return 4
	end

	if bit.band(color, 16) > 0 then
		return 5
	end

	if bit.band(color, 32) > 0 then
		return 6
	end

	if bit.band(color, 64) > 0 then
		return 7
	end
end

gDressDyeManager = M
