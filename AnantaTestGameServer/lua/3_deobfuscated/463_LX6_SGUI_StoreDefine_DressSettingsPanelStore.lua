C_DressSettingsPanelStore = DefClass("C_DressSettingsPanelStore", C_DressSettingsPanelStore, C_StoreGroup)
GroupName2Class.DressSettingsPanelStore = C_DressSettingsPanelStore
local M = C_DressSettingsPanelStore
local FashionConfig = LTConfig.FashionConfig

function M:ctor()
	return
end

function M:OnAwake()
	self.bindData.backBtn.luaClick = self:CreateAction("OnBackBtnClick")
	self.bindData.scroll.luaSimpleRenderItem = self:CreateAction("OnRefreshScrollList")
	self.bindData.scroll.luaSimpleClick = self:CreateAction("OnChangeScrollList")
end

function M:OnDisable()
	return
end

function M:OnDestroy()
	return
end

function M:OnShow(panelId, data)
	self:InitData()
	gDressSetPanelCamera:SetDressPanelCamera(self.m_Id, true, {})
end

function M:OnClose()
	gDressSetPanelCamera:SetDressPanelCamera(self.m_Id, false)
end

function M:InitData()
	local spiritFashionsInfoDict = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo.SpiritFashionsInfoDict
	local spiritFashionsInfo = spiritFashionsInfoDict[gDressManager.CurrentSpiritId]

	if spiritFashionsInfo then
		self.HiddenParts = spiritFashionsInfo.SpiritWearFashionsInfo.HiddenParts
		self.EditedHiddenParts = spiritFashionsInfo.SpiritWearFashionsInfo.EditedHiddenParts
	else
		self.HiddenParts = 0
		self.EditedHiddenParts = 0
	end

	self.fashionInfo = gDressManager.SpriteFashionInfoDict[gDressManager.CurrentSpiritId].WearFashionInfoList
	self.part2PartInfo = {}
	local resulit = gDressManager:GetSelectableHiddenPart(self.HiddenParts)
	local editResulit = gDressManager:GetSelectableHiddenPart(self.EditedHiddenParts)
	self.editResulit = editResulit

	for i = 1, #self.fashionInfo do
		local info = self.fashionInfo[i]
		local cfg = FashionConfig.GetConfig(info.FashionId)

		if cfg and cfg.SelectableHiddenPart > 0 then
			local hiddenPartId = cfg.SelectableHiddenPart

			if table.isNilOrEmpty(self.part2PartInfo[hiddenPartId]) then
				self.part2PartInfo[hiddenPartId] = {
					fashionIds = {}
				}

				if table.contains(editResulit, hiddenPartId) then
					self.part2PartInfo[hiddenPartId].hide = table.contains(resulit, hiddenPartId)
				else
					self.part2PartInfo[hiddenPartId].hide = bit.band(cfg.DefaultHidePart, hiddenPartId) ~= 0
				end
			end

			table.insert(self.part2PartInfo[hiddenPartId].fashionIds, info.FashionId)
		end
	end

	self.showHiddenPartList = {}
	local index = 1
	local HiddenPartTypeInfo = FashionConfig.HiddenPartTypeInfo

	for hiddenPartId, partInfo in pairs(self.part2PartInfo) do
		for i = 1, #HiddenPartTypeInfo do
			local hiddenPartType = HiddenPartTypeInfo[i]

			if hiddenPartType.type == hiddenPartId then
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
			if self.showHiddenPartList[t].hiddenPartType == info.hiddenPartType then
				self.showHiddenPartList[t].typeTitle = info.name
			end
		end
	end

	self.bindData.scroll:SetSimpleList(#self.showHiddenPartList)
end

function M:OnRefreshScrollList(btn, index)
	local data = self.showHiddenPartList[index + 1]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if store then
		store.typeTitle = data.typeTitle
		store.list.luaSimpleRenderItem = self:CreateActionWithArgs("OnRefreshItemScrollList", index)

		store.list:SetSimpleList(#data.fashionItems)
	end
end

function M:OnRefreshItemScrollList(typeIndex, btn, index)
	local data = self.showHiddenPartList[typeIndex + 1].fashionItems[index + 1]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if store then
		store.itemTitle = data.itemTitle
		store.state = data.isHide and 1 or 0
		local view = {
			typeIndex = typeIndex,
			itemIndex = index
		}
		store.switchStateBtn.luaClick = self:CreateActionWithArgs("OnSwitchStateBtnClick", view)
	end
end

function M:OnSwitchStateBtnClick(data)
	local hideState = self.showHiddenPartList[data.typeIndex + 1].fashionItems[data.itemIndex + 1].isHide
	self.showHiddenPartList[data.typeIndex + 1].fashionItems[data.itemIndex + 1].isHide = not hideState
	self.part2PartInfo[self.showHiddenPartList[data.typeIndex + 1].type].hide = not hideState

	self.bindData.scroll:RefreshList()

	if not table.contains(self.editResulit, self.showHiddenPartList[data.typeIndex + 1].type) then
		table.insert(self.editResulit, self.showHiddenPartList[data.typeIndex + 1].type)
	end

	local hiddenParts = gDressManager:SetSelectableHiddenPart(self.part2PartInfo)
	local editHiddenParts = self:GetEditResulit(self.editResulit)

	gDressManager:SetHiddenParts(hiddenParts, editHiddenParts)
end

function M:OnChangeScrollList(btn, index)
	return
end

function M:OnBackBtnClick()
	local hiddenParts = gDressManager:SetSelectableHiddenPart(self.part2PartInfo)
	local editHiddenParts = self:GetEditResulit(self.editResulit)

	local function callBack()
		gDressManager:RefreshPlayerHiddenPartsData(hiddenParts, editHiddenParts)
		gPanelManager:Close(gPanelId.DRESS_SETTINGS_PANEL)
	end

	gDressData:AskSetSpiritWearFashionHiddenParts(gDressManager.CurrentSpiritId, hiddenParts, editHiddenParts, callBack)
end

function M:GetEditResulit(editResulit)
	local result = 0

	for i = 1, #editResulit do
		result = result + editResulit[i]
	end

	return result
end
