-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\SwitchCharacterStore.lua
-- Decompiled from: 01304_SwitchCharacterStore.lua_198f9b4782bf.luajit

local LingGuiUtils = require("LX6/GUI/Ling/LingGuiUtils")
local MessageConfig = LTConfig.MessageConfig
local ShowcaseConfig = LTConfig.HouseInteractionFashionShowcaseConfig
C_SwitchCharacterStore = DefClass("C_SwitchCharacterStore", C_SwitchCharacterStore, C_StoreGroup)
GroupName2Class.SwitchCharacterStore = C_SwitchCharacterStore
local M = C_SwitchCharacterStore

M.OnAwake = function(self)
	self.bindData.backBtn.luaClick = self.CreateAction(self, "OnBackBtnClick")
	self.bindData.backBtn2.luaClick = self.CreateAction(self, "OnBackBtnClick")
	self.bindData.itemList.luaSimpleRenderItem = self.CreateAction(self, "OnRefreshItemList")
	self.bindData.itemList.luaSimpleClick = self.CreateAction(self, "OnChangeItem")
	self.bindData.itemList.luaSimpleInvalidClick = self.CreateAction(self, "OnChangeItemInvalid")
end

M.OnShow = function(self, panelId, data)
	self.panelId = panelId
	self.itemList = {}
	self.callBack = data and data.callBack
	self.isDressFormMode = data and data.isDressFormMode or false

	if self.isDressFormMode then
		self.InitDressFormMode(self, data)
	else
		self.InitCharacterMode(self, data)
	end
end

M.OnClose = function(self)
	gDressStack:SetDressStack(self.m_Id, false)

	if not self.isDressFormMode then
		self.CloseCharacterMode(self)
	end

	if self.callBack then
		self.callBack(self.hasChange, self.selectedSpiritId)
	end
end

M.OnDestroy = function(self)
	if not self.isDressFormMode then
		self.DestroyCharacterMode(self)
	end
end

M.OnStart = function(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnRefreshItemList = function(self, btn, index)
	local data = self.itemList[index + 1]
	local store = gStoreManager:GetStoreGroup("DressAvatarStore"):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.iconId = data.iconId

	if self.isDressFormMode then
		self.OnDressFormRender(self, btn, data)
	else
		self.OnCharacterRender(self, btn, data)
	end
end

M.OnChangeItem = function(self, btn, index)
	if not btn.isSelected then
		return
	end

	local data = self.itemList[index + 1]

	if self.isDressFormMode then
		self.OnDressFormSelect(self, data)
	else
		self.OnCharacterSelect(self, data)
	end
end

M.OnChangeItemInvalid = function(self)
	gDisplayMessageMgr:ShowMessage(MessageConfig.FashionTaskOccupy)
end

M.OnBackBtnClick = function(self)
	gUIUtils:PlayAniClosePanel(self.bindData.anim, "S_Vx_DressFilterPanel_close", self.panelId)
end

M.InitCharacterMode = function(self, data)
	self.hasChange = false
	self.onlyPreview = false
	self.skipMovementState = false
	self.selectedSpiritId = nil
	self.originalSpiritId = gCS.MyPlayerManager.PlayerUnit.ClientData.cardId
	self.initialSpiritId = nil
	self.showBaikeSpirits = false
	self.filterFunc = nil
	local useStaticBlur = false

	if data then
		self.onSelectCallback = data.onSelectCallback
		self.sex = data.sex
		self.onlyPreview = data.onlyPreview or false
		self.skipMovementState = data.skipMovementState or data.isFromMall or false
		self.isFromShop = data.isFromShop
		self.initialSpiritId = data.spiritId
		self.showBaikeSpirits = data.showBaikeSpirits or false
		self.filterFunc = data.filterFunc
		useStaticBlur = data.useStaticBlur or false
	end

	self.bindData.blurCtrl = useStaticBlur and 1 or 0

	self.OnModelLoadedCallback = function()
		gCS.AnimControllerManager.PlayAction(gCS.MyPlayerManager.PlayerUnit, 1001, 1, 9999, 0, -1, false, nil, LX6.Units.Module.AnimSource.ModelReload)
	end

	gCS.MyPlayerManager.PlayerUnit.ClientData.forceLodLevel = LX6.Units.UnitLOD.UnitLODLevel.UnitLOD0

	self:BuildCharacterList()

	local cameraParams = {}

	if not self.skipMovementState then
		cameraParams.movementState = LX6.Cinemachine.EMovementCamState.TryFashion
	end

	gDressStack:SetDressStack(self.m_Id, true, cameraParams)

	local unit = gCS.MyPlayerManager.PlayerUnit
	unit.OnLoadCompleteHandler = unit.OnLoadCompleteHandler + self.OnModelLoadedCallback
end

M.BuildCharacterList = function(self)
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
	local tryWearList = self.CheckIsTryWearSpiritsList(self)

	for i = 1, #lingList do
		local card = lingList[i]
		local sexMatch = gDressManager:CheckGenderWithBodyTypeBySpirit(card.Id, self.sex)
		local filterMatch = self.filterFunc ~= nil or self.filterFunc(card.Id)

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

M.SortItems = function(self, itemList)
	local compareId = self.selectedSpiritId or self.originalSpiritId

	if self.onlyPreview and self.initialSpiritId then
		compareId = self.initialSpiritId
	end

	table.sort(itemList, function (a, b)
		if a.Id == compareId and b.Id == compareId then
			return table.contains(self.lingList, a.Id) and not table.contains(self.lingList, b.Id)
		end

		return a.Id ~= compareId and b.Id == compareId
	end)
end

M.OnCharacterRender = function(self, btn, data)
	local compareId = self.initialSpiritId or self.selectedSpiritId or self.originalSpiritId
	btn.isSelected = data.Id ~= compareId
	btn.interactable = not data.isTryWear
end

M.OnCharacterSelect = function(self, data)
	if data.Id == (self.selectedSpiritId or self.originalSpiritId) and not self.onlyPreview then
		self.hasChange = true
		self.selectedSpiritId = data.Id

		gBattleSpiritMgr:ResetPlayerCardId(gCS.MyPlayerManager.PlayerUnit.Pid, data.Id)
		gDressManager:PrepareUnitForDress(gCS.MyPlayerManager.PlayerUnit)

		if not self.skipMovementState then
			gDressStack:ResetVerticalOffset()
			gDressStack:VerticalMoveCamera(0)
			gDressCamera:SetFullSlotShotCamera()
		end
	elseif self.onlyPreview then
		self.hasChange = true
		self.selectedSpiritId = data.Id

		if self.onSelectCallback then
			self.onSelectCallback(data.Id)
		end
	end
end

M.CloseCharacterMode = function(self)
	local unit = gCS.MyPlayerManager.PlayerUnit
	unit.OnLoadCompleteHandler = unit.OnLoadCompleteHandler - self.OnModelLoadedCallback
end

M.DestroyCharacterMode = function(self)
	gCS.MyPlayerManager.PlayerUnit.ClientData.forceLodLevel = LX6.Units.UnitLOD.UnitLODLevel.None
end

M.CheckIsTryWearSpiritsList = function(self)
	local list = {}
	local spiritFashionsInfoDict = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo.SpiritFashionsInfoDict

	for spiritId, info in pairs(spiritFashionsInfoDict) do
		if info.SpiritWearFashionsInfo and bit.band(info.SpiritWearFashionsInfo.WearSourceInfo.Source, UX.Game.FashionWearSource.TryWear) == 0 then
			table.insert(list, spiritId)
		end
	end

	return list
end

M.InitDressFormMode = function(self, data)
	self.hasChange = false
	self.placedInstanceId = data.placedInstanceId
	self.modelIndex = data.modelIndex
	self.currentShowcaseId = data.currentShowcaseId
	self.onSwitchDone = data.onSwitchDone
	self.dressFormUnit = data.unit
	self.bindData.blurCtrl = 0

	self:BuildDressFormList()

	local cameraParams = {
		movementState = LX6.Cinemachine.EMovementCamState.TryFashion,
		movementStateParam = self.dressFormUnit,
		unitProvider = function ()
			return self.dressFormUnit
		end
	}

	gDressStack:SetDressStack(self.m_Id, true, cameraParams)
end

M.BuildDressFormList = function(self)
	self.itemList = {}

	for index = 0, ShowcaseConfig.count - 1 do
		local cfg = ShowcaseConfig.LoadAt(index)

		if cfg then
			table.insert(self.itemList, {
				Id = cfg.Id,
				iconId = cfg.BodyImage
			})
		end
	end

	self.bindData.itemList:SetSimpleList(#self.itemList)
end

M.OnDressFormRender = function(self, btn, data)
	btn.isSelected = data.Id ~= self.currentShowcaseId
	btn.interactable = true
end

M.OnDressFormSelect = function(self, data)
	if data.Id ~= self.currentShowcaseId then
		return
	end

	slot2 = gHouseManager

	slot2:AskSwitchHouseShowcaseAgent(self.placedInstanceId, self.modelIndex, data.Id, function (success)
		if success then
			self.hasChange = true
			self.currentShowcaseId = data.Id

			if self.onSwitchDone then
				self.onSwitchDone(data.Id)
			end

			gUIUtils:PlayAniClosePanel(self.bindData.anim, "S_Vx_DressFilterPanel_close", self.panelId)
		end
	end)
end
