-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\DressSettingsPanelStore.lua
-- Decompiled from: 01898_DressSettingsPanelStore.lua_3da37e98fd97.luajit

C_DressSettingsPanelStore = DefClass("C_DressSettingsPanelStore", C_DressSettingsPanelStore, C_StoreGroup)
GroupName2Class.DressSettingsPanelStore = C_DressSettingsPanelStore
local M = C_DressSettingsPanelStore
local FashionConfig = LTConfig.FashionConfig

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.bindData.backBtn.luaClick = self.CreateAction(self, "OnBackBtnClick")
	self.bindData.scroll.luaSimpleRenderItem = self.CreateAction(self, "OnRefreshScrollList")
	self.bindData.scroll.luaSimpleClick = self.CreateAction(self, "OnChangeScrollList")
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnShow = function(self, panelId, data)
	self.skipMovementState = data and data.skipMovementState
	self.spiritContext = data and data.spiritContext or gDressManager:GetSpiritContext()

	self:InitData()

	local cameraParams = {
		verticalButton = self.bindData.verticalButton,
		basePanel = self.bindData.basePanel
	}

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		cameraParams.rightStickCustomNavRespond = self.bindData.mouseCustomNavRespond
		cameraParams.L2CustomNavRespond = self.bindData.L2CustomNavRespond
		cameraParams.R2CustomNavRespond = self.bindData.R2CustomNavRespond
	end

	if not self.skipMovementState then
		cameraParams.movementState = LX6.Cinemachine.EMovementCamState.TryFashion
	end

	cameraParams.unitProvider = function()
		return self.spiritContext.unit
	end

	gDressStack:SetDressStack(self.m_Id, true, cameraParams)
end

M.OnClose = function(self)
	gDressStack:SetDressStack(self.m_Id, false)
end

M.InitData = function(self)
	local spiritFashionsInfoDict = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo.SpiritFashionsInfoDict
	local spiritFashionsInfo = spiritFashionsInfoDict[self.spiritContext.spiritId]

	if spiritFashionsInfo then
		self.HiddenParts = spiritFashionsInfo.SpiritWearFashionsInfo.HiddenParts
		self.EditedHiddenParts = spiritFashionsInfo.SpiritWearFashionsInfo.EditedHiddenParts
	else
		self.HiddenParts = 0
		self.EditedHiddenParts = 0
	end

	self.fashionInfo = gDressManager:GetCurrentSpritWearFashionInfoList(self.spiritContext)
	self.part2PartInfo = {}
	local result = gDressManager:GetSelectableHiddenPart(self.HiddenParts)
	self.editResult = gDressManager:GetSelectableHiddenPart(self.EditedHiddenParts)

	for i = 0, self.fashionInfo.Count - 1 do
		local info = self.fashionInfo[i]
		local cfg = FashionConfig.GetConfig(info.FashionId)

		if cfg and cfg.SelectableHiddenPart <= 0 then
			local hiddenPartId = cfg.SelectableHiddenPart

			if hiddenPartId == 2 or gDressManager:CheckSpiritHasSpEar(self.spiritContext) then
				if table.isNilOrEmpty(self.part2PartInfo[hiddenPartId]) then
					self.part2PartInfo[hiddenPartId] = {
						fashionIds = {}
					}

					if table.contains(self.editResult, hiddenPartId) then
						self.part2PartInfo[hiddenPartId].hide = table.contains(result, hiddenPartId)
					else
						self.part2PartInfo[hiddenPartId].hide = bit.band(cfg.DefaultHidePart, hiddenPartId) == 0
					end
				end

				table.insert(self.part2PartInfo[hiddenPartId].fashionIds, info.FashionId)
			end
		end
	end

	self.showHiddenPartList = {}
	local index = 1
	local HiddenPartTypeInfo = FashionConfig.HiddenPartTypeInfo

	for hiddenPartId, partInfo in pairs(self.part2PartInfo) do
		for i = 1, #HiddenPartTypeInfo do
			local hiddenPartType = HiddenPartTypeInfo[i]

			if hiddenPartType.type ~= hiddenPartId then
				local view = {
					hiddenPartType = hiddenPartType.hiddenPartType,
					itemTitle = hiddenPartType.name,
					fashionType = hiddenPartType.type,
					IconId = hiddenPartType.IconId,
					isHide = partInfo.hide
				}

				if table.isNilOrEmpty(self.showHiddenPartList[index]) then
					self.showHiddenPartList[index] = {
						hiddenPartType = hiddenPartType.hiddenPartType,
						type = hiddenPartType.type,
						fashionItems = {}
					}
				end

				table.insert(self.showHiddenPartList[index].fashionItems, view)

				index = index + 1
			end
		end
	end

	for i = 1, #FashionConfig.HiddenTitleTypeInfo do
		local info = FashionConfig.HiddenTitleTypeInfo[i]

		for t = 1, #self.showHiddenPartList do
			if self.showHiddenPartList[t].hiddenPartType ~= info.hiddenPartType then
				self.showHiddenPartList[t].typeTitle = info.name
			end
		end
	end

	self.bindData.scroll:SetSimpleList(#self.showHiddenPartList)
end

M.OnRefreshScrollList = function(self, btn, index)
	local data = self.showHiddenPartList[index + 1]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if store then
		store.typeTitle = data.typeTitle
		store.list.luaSimpleRenderItem = self:CreateActionWithArgs("OnRefreshItemScrollList", index)

		store.list:SetSimpleList(#data.fashionItems)
	end
end

M.OnRefreshItemScrollList = function(self, typeIndex, btn, index)
	local data = self.showHiddenPartList[typeIndex + 1].fashionItems[index + 1]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if store then
		store.itemTitle = data.itemTitle

		store.switchStateBtn:SetSelected(data.isHide)

		local view = {
			typeIndex = typeIndex,
			itemIndex = index
		}
		store.switchStateBtn.luaClick = self:CreateActionWithArgs("OnSwitchStateBtnClick", view)
	end
end

M.OnSwitchStateBtnClick = function(self, data)
	local hideState = self.showHiddenPartList[data.typeIndex + 1].fashionItems[data.itemIndex + 1].isHide
	self.showHiddenPartList[data.typeIndex + 1].fashionItems[data.itemIndex + 1].isHide = not hideState
	self.part2PartInfo[self.showHiddenPartList[data.typeIndex + 1].type].hide = not hideState

	self.bindData.scroll:RefreshList()

	if not table.contains(self.editResult, self.showHiddenPartList[data.typeIndex + 1].type) then
		table.insert(self.editResult, self.showHiddenPartList[data.typeIndex + 1].type)
	end

	local hiddenParts = gDressManager:SetSelectableHiddenPart(self.part2PartInfo)
	local editHiddenParts = self:GetEditResult(self.editResult)

	gDressManager:SetHiddenParts(hiddenParts, editHiddenParts, self.spiritContext and self.spiritContext.unit)
	self:SyncToPlayerUnitIfNeeded(hiddenParts, editHiddenParts)
end

M.OnChangeScrollList = function(self, btn, index)
end

M.OnBackBtnClick = function(self)
	local hiddenParts = gDressManager:SetSelectableHiddenPart(self.part2PartInfo)
	local editHiddenParts = self:GetEditResult(self.editResult)

	local callBack = function()
		gDressManager:RefreshPlayerHiddenPartsData(hiddenParts, editHiddenParts, self.spiritContext)
		gPanelManager:Close(gPanelId.DRESS_SETTINGS_PANEL)
	end

	gDressData:AskSetSpiritWearFashionHiddenParts(self.spiritContext.spiritId, hiddenParts, editHiddenParts, callBack)
end

M.GetEditResult = function(self, editResult)
	local result = 0

	for i = 1, #editResult do
		result = result + editResult[i]
	end

	return result
end

M.SyncToPlayerUnitIfNeeded = function(self, hiddenParts, editHiddenParts)
	local playerUnit = gCS.MyPlayerManager.PlayerUnit

	if not playerUnit then
		return
	end

	local unit = self.spiritContext and self.spiritContext.unit

	if unit and unit == playerUnit and self.spiritContext.spiritId ~= playerUnit.ClientData.cardId then
		gDressManager:SetHiddenParts(hiddenParts, editHiddenParts, playerUnit)
	end
end
