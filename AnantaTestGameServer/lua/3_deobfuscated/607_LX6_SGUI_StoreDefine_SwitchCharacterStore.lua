local LingGuiUtils = require("LX6/GUI/Ling/LingGuiUtils")
local MessageConfig = LTConfig.MessageConfig
C_SwitchCharacterStore = DefClass("C_SwitchCharacterStore", C_SwitchCharacterStore, C_StoreGroup)
GroupName2Class.SwitchCharacterStore = C_SwitchCharacterStore
local M = C_SwitchCharacterStore

function M:OnAwake()
	self.bindData.backBtn.luaClick = self:CreateAction("OnBackBtnClick")
	self.bindData.backBtn2.luaClick = self:CreateAction("OnBackBtnClick")
	self.bindData.itemList.luaSimpleRenderItem = self:CreateAction("OnRefreshItemList")
	self.bindData.itemList.luaSimpleClick = self:CreateAction("OnChangeItem")
	self.bindData.itemList.luaSimpleInvalidClick = self:CreateAction("OnChangeItemInvalid")

	function self.OnModelLoadedCallback()
		gCS.AnimControllerManager.PlayAction(gCS.MyPlayerManager.PlayerUnit, 1001, 1, 9999, 0, -1, false, nil, 0)
	end
end

function M:OnDestroy()
	gCS.MyPlayerManager.PlayerUnit.ClientData.forceLodLevel = LX6.Units.UnitLOD.UnitLODLevel.None
end

function M:OnStart()
	return
end

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	return
end

function M:OnShow(panelId, data)
	self.panelId = panelId
	self.itemList = {}
	self.hasChange = false
	self.onlyPreview = false
	self.selectedSpiritId = nil
	self.originalSpiritId = gDressManager.CurrentSpiritId
	self.initialSpiritId = nil
	self.showBaikeSpirits = false
	self.filterFunc = nil
	local useStaticBlur = false

	if data then
		self.callBack = data.callBack
		self.onSelectCallback = data.onSelectCallback
		self.sex = data.sex
		self.onlyPreview = data.onlyPreview or false
		self.isFromShop = data.isFromShop
		self.initialSpiritId = data.spiritId
		self.showBaikeSpirits = data.showBaikeSpirits or false
		self.filterFunc = data.filterFunc
		useStaticBlur = data.useStaticBlur or false
	end

	if useStaticBlur then
		self.bindData.blurCtrl = 1
	else
		self.bindData.blurCtrl = 0
	end

	gCS.MyPlayerManager.PlayerUnit.ClientData.forceLodLevel = LX6.Units.UnitLOD.UnitLODLevel.UnitLOD0

	self:InitCharacter()

	local cameraParams = {}

	gDressSetPanelCamera:SetDressPanelCamera(self.m_Id, true, cameraParams)

	local unit = gCS.MyPlayerManager.PlayerUnit
	unit.OnLoadCompleteHandler = unit.OnLoadCompleteHandler + self.OnModelLoadedCallback
end

function M:OnClose()
	gDressSetPanelCamera:SetDressPanelCamera(self.m_Id, false)

	local unit = gCS.MyPlayerManager.PlayerUnit
	unit.OnLoadCompleteHandler = unit.OnLoadCompleteHandler - self.OnModelLoadedCallback

	if self.callBack then
		if self.onlyPreview then
			self.callBack(self.hasChange, self.selectedSpiritId)
		else
			self.callBack(self.hasChange)
		end
	end
end

function M:InitCharacter()
	self.lingList = {}

	for i = 1, #gBattleSpiritMgr.battleSpiritList do
		table.insert(self.lingList, gBattleSpiritMgr.battleSpiritList[i].templateId)
	end

	local lingList = {}

	if self.showBaikeSpirits then
		lingList = gBaiKeArchiveManager:GetFashionShowCaseSpiritList()
	else
		lingList = LingGuiUtils:GetAllLingList()
	end

	self.itemList = {}
	local tryWearList = self:CheckIsTryWearSpiritsList()

	for i = 1, #lingList do
		local card = lingList[i]
		local sexMatch = self.sex == nil or self.sex == card.Sex
		local filterMatch = self.filterFunc == nil or self.filterFunc(card.Id)

		if sexMatch and filterMatch then
			local view = {
				Id = card.Id,
				iconId = card.sIcon,
				Quality = card.Quality,
				isTryWear = table.contains(tryWearList, card.Id) or false,
				isOwned = table.contains(self.lingList, card.Id)
			}

			table.insert(self.itemList, view)
		end
	end

	self:SortItems(self.itemList)
	self.bindData.itemList:SetSimpleList(#self.itemList)
end

function M:SortItems(itemList)
	local compareId = gDressManager.CurrentSpiritId

	if self.onlyPreview and self.initialSpiritId then
		compareId = self.initialSpiritId
	end

	table.sort(itemList, function (a, b)
		if a.Id ~= compareId and b.Id ~= compareId then
			return table.contains(self.lingList, a.Id) and not table.contains(self.lingList, b.Id)
		end

		return a.Id == compareId and b.Id ~= compareId
	end)
end

function M:OnBackBtnClick()
	gPanelManager:Close(self.panelId)
end

function M:OnRefreshItemList(btn, index)
	local data = self.itemList[index + 1]
	local store = gStoreManager:GetStoreGroup("DressAvatarStore"):GetStoreByWidget(btn)

	if store then
		store.iconId = data.iconId
		local compareId = self.initialSpiritId or gDressManager.CurrentSpiritId
		btn.isSelected = data.Id == compareId
		btn.interactable = not data.isTryWear
	end
end

function M:OnChangeItem(btn, index)
	local data = self.itemList[index + 1]

	if btn.isSelected and data.Id ~= gDressManager.CurrentSpiritId then
		self.hasChange = true
		self.selectedSpiritId = data.Id

		if not self.onlyPreview then
			gDressManager:SetCurrentPlayerSpirit(data.Id)

			if self.isFromShop then
				gDressCamera:SetFullSlotShotCamera()
			end
		elseif self.onSelectCallback then
			self.onSelectCallback(data.Id)
		end
	end
end

function M:OnChangeItemInvalid()
	gDisplayMessageMgr:ShowMessage(MessageConfig.FashionTaskOccupy)
end

function M:CheckIsTryWearSpiritsList()
	local list = {}
	local spiritFashionsInfoDict = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo.SpiritFashionsInfoDict

	for spiritId, info in pairs(spiritFashionsInfoDict) do
		if info.IsTryWear then
			table.insert(list, spiritId)
		end
	end

	return list
end
