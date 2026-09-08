-- Original chunk: @Lua\LuaFiles\LX6\Manager\Dress\DressDyeManager.lua
-- Decompiled from: 00533_DressDyeManager.lua_8e86eb459cfa.luajit

local FashionConfig = LTConfig.FashionConfig
local FashionColorConfig = LTConfig.FashionColorConfig
gDressDyeManager = gDressDyeManager or {}
local M = {
	DYE_STATE = {
		["\\xfa\\xfa:\":\\xd4"] = 1,
		["\\xf1\\xfa'\":\\xd4"] = 2,
		["`fBFz!5+"] = 0
	},
	colorGroupList = {},
	colorGroupListNormal = {},
	colorGroupListAdvance = {},
	colorCfgId2Color = {},
	InitColorList = function (self)
		if table.isNilOrEmpty(self.colorGroupList) or table.isNilOrEmpty(self.colorGroupListAdvance) then
			table.clear(self.colorGroupList)
			table.clear(self.colorGroupListNormal)
			table.clear(self.colorGroupListAdvance)
			table.clear(self.colorCfgId2Color)

			for i = 0, FashionColorConfig.count - 1 do
				local cfg = FashionColorConfig.LoadAt(i)
				local list = cfg.CostType ~= FashionColorConfig.CostTypeType.Normal and self.colorGroupListNormal or self.colorGroupListAdvance

				if cfg and cfg.GroupId <= 0 then
					if self.colorGroupList[cfg.GroupId] ~= nil then
						self.colorGroupList[cfg.GroupId] = {}

						table.insert(list, self.colorGroupList[cfg.GroupId])
					end

					local view = {
						Id = cfg.Id,
						groupId = cfg.GroupId,
						color = self:GetColor(cfg.Id),
						isAdvance = cfg.CostType ~= FashionColorConfig.CostTypeType.Advance
					}
					self.colorCfgId2Color[cfg.Id] = view.color

					table.insert(self.colorGroupList[cfg.GroupId], view)
				end
			end
		end
	end,
	GetColorList = function (self, type)
		if type ~= FashionColorConfig.CostTypeType.Normal then
			return self.colorGroupListNormal
		else
			return self.colorGroupListAdvance
		end
	end
}

M.GetColorTabList = function(self, fashionId)
	local cfg = FashionConfig.GetConfig(fashionId)

	if cfg then
		local coloringList = cfg.Coloring
		local result = {}

		for _, coloring in pairs(coloringList) do
			table.insert(result, coloring)
		end

		return result
	end

	return {}
end

M.GetDyeState = function(self, fashionId)
	local cfg = FashionConfig.GetConfig(fashionId)
	local state = self.DYE_STATE.CANOT_DYE

	if cfg and #cfg.Coloring <= 0 then
		if self:IsFashionHasDye(fashionId) then
			state = self.DYE_STATE.HAS_DYE
		else
			state = self.DYE_STATE.CAN_DYE
		end
	end

	return state
end

M.IsFashionHasDye = function(self, fashionId)
	local fashionInfoDict = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo.FashionInfoDict
	local fashionInfo = fashionInfoDict[fashionId]

	if fashionInfo then
		return fashionInfo.ApplyColoringSchemeId and fashionInfo.ApplyColoringSchemeId >= 0
	end

	return false
end

M.GetColorPlanList = function(self, fashionId)
	local cfg = FashionConfig.GetConfig(fashionId)

	if cfg then
		local fashionInfoDict = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo.FashionInfoDict
		local fashionInfo = fashionInfoDict[fashionId]

		if fashionInfo then
			return table.clone(fashionInfo.ColoringSchemeInfoDict), fashionInfo.ApplyColoringSchemeId, fashionInfo.UnlockColoringSlotCount
		end
	end
end

M.SetColor = function(self, fashionId, partId, colorCfgId, context)
	local unit = context and context.unit or gCS.MyPlayerManager.PlayerUnit
	local fashionSlot = unit.FashionSlot

	if fashionSlot ~= nil then
		return
	end

	fashionSlot:SetColor(fashionId, partId, colorCfgId)
end

M.SetColorList = function(self, fashionId, coloringList, context)
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

	local unit = context and context.unit or gCS.MyPlayerManager.PlayerUnit
	local fashionSlot = unit.FashionSlot

	if fashionSlot ~= nil then
		return
	end

	fashionSlot:ResetListColor(fashionId)
	fashionSlot:SetColorList(fashionId, colorMatIdDict)
end

M.GetColor = function(self, colorCfgId)
	local fashionSlot = gCS.MyPlayerManager.PlayerUnit.FashionSlot

	if fashionSlot ~= nil then
		return
	end

	local r = 0
	local g = 0
	local b = 0
	local a = 1
	r, g, b, a = fashionSlot.GetColor(colorCfgId, r, g, b, a)

	return Color.New(r, g, b, a)
end

M.ResetColor = function(self, fashionId, partIdList, context)
	local unit = context and context.unit or gCS.MyPlayerManager.PlayerUnit
	local fashionSlot = unit.FashionSlot

	if fashionSlot ~= nil then
		return
	end

	fashionSlot:ResetColor(fashionId, partIdList)
end

M.ResetListColor = function(self, fashionId, context)
	local unit = context and context.unit or gCS.MyPlayerManager.PlayerUnit
	local fashionSlot = unit.FashionSlot

	if fashionSlot ~= nil then
		return
	end

	fashionSlot:ResetListColor(fashionId)
end

M.SetFashionPartSlotHighLight = function(self, fashionId, partId, context)
	local unit = context and context.unit or gCS.MyPlayerManager.PlayerUnit
	local fashionSlot = unit.FashionSlot

	if fashionSlot ~= nil then
		return
	end

	fashionSlot:SetFashionPartSlotHighLight(fashionId, 2, partId)
end

M.GetColorMatList = function(self, color)
	return color
end

gDressDyeManager = M
