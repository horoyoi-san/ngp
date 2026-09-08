-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\WeaponTransmogStore.lua
-- Decompiled from: 01159_WeaponTransmogStore.lua_cd240d77fd3c.luajit

local WeaponSkinConfig = LTConfig.WeaponSkinConfig
local WeaponSkinDefaultSkinConfig = LTConfig.WeaponSkinDefaultSkinConfig
local SceneitemConfig = LTConfig.SceneitemConfig
local FightSpiritConfig = LTConfig.FightSpiritConfig
local MessageConfig = LTConfig.MessageConfig
local ConsumableQualityTypeConfig = LTConfig.ConsumableQualityTypeConfig
local LingGuiUtils = require("LX6/GUI/Ling/LingGuiUtils")
slot7 = gWeaponSkinManager
local WeaponSkinTextInfos = slot7:GetTextInfos()
C_WeaponTransmogStore = DefClass("C_WeaponTransmogStore", C_WeaponTransmogStore, C_StoreGroup)
GroupName2Class.WeaponTransmogStore = C_WeaponTransmogStore
local M = C_WeaponTransmogStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.spiritContext = nil
	self.hideCb = nil
	self.tab1List = {}
	self.tab2List = {}
	self.currentTab1 = 0
	self.currentTab2 = 0
	self.skinList = {}
	self.currentSkinId = 0
	self.currentPage = 1
	self.characterOption = 1
	self.weaponOption = 1
	self.selectedCharacterIds = {}
	self.weaponCheckList = {}
	self.characterCheckList = {}
	self._allSpiritIdsCache = nil
	self.editContentStore = nil
	self.displayMode = 0
	self.qualityOptions = nil
	self.currentQualityFilter = 0
end

M.GetTextFromInfoName = function(self, textInfo, ...)
	return gWeaponSkinManager:GetText(textInfo, ...)
end

local SetCharacterPreviewVisible = function(unit, visible)
	if not unit then
		return
	end

	LX6.Units.UnitModelManager.SyncShadowModelVisibility(unit, visible)
end

M.DefineAllEnumsAutoGen = function(self)
	self.displayCtrlEnum = {
		["M\\x90\\x9e\\x8cO"] = 0,
		["@Om{O*"] = 1
	}
	self.hidePageCtrlEnum = {
		["r+y^"] = 0,
		["i*rL"] = 1
	}
	self.pageCtrlEnum = {
		["K\\xa7\\xb0\\xbc\\xa2"] = 0,
		["M\\x92\\x81\\x8dE"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.displayCtrlEnum = nil
	self.hidePageCtrlEnum = nil
	self.pageCtrlEnum = nil
end

M.OnAwake = function(self)
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()
end

M.OnGroupEnable = function(self)
	self:RegisterMessageEvents(self.msgEvents)
	self:RegisterDataSetEvents(self.dataSetEvents)
end

M.OnDisable = function(self)
	self:SwitchDisplayMode(self.displayCtrlEnum.character)

	if self.bindData.switchBtn then
		self.bindData.switchBtn.gameObject:SetActive(true)
	end

	gDressStack:SetDressStack(-gDressSceneManager.TabType.Weapon, false)
end

M.OnGroupDisable = function(self)
	gDressStack:SetDressStack(-gDressSceneManager.TabType.Weapon, false)
	self:ClearMessageEvents()
	self:ClearDataSetEvents()
end

M.OnShow = function(self, data)
	local unit = data and data.unit

	if not unit then
		return
	end

	self.hideCb = data.hideCb
	self.spiritContext = gDressManager:GetSpiritContext(nil, , unit)

	if not self.spiritContext then
		return
	end

	self.displayMode = self.displayCtrlEnum.weapon
	self.bindData.displayCtrl = self.displayCtrlEnum.weapon
	local cameraParams = {
		verticalButton = self.bindData.verticalButton,
		basePanel = self.bindData.basePanel,
		rightStickCustomNavRespond = self.bindData.mouseCustomNavRespond,
		unitProvider = function ()
			return gDressSceneManager.currentModelUnit
		end,
		weaponParentProvider = function ()
			return gDressSceneManager:GetCurrentWeaponParent()
		end
	}

	gDressStack:SetDressStack(-gDressSceneManager.TabType.Weapon, true, cameraParams)

	self.currentPage = self.pageCtrlEnum.first

	self:RefreshTab1List()
	self:RefreshPreview()
	self:RefreshAvatar()

	self.bindData.lightNameText = gDressSceneManager:GetNextSceneName()
	self.bindData.pageCtrl = self.pageCtrlEnum.first

	self:InitEditContentStore()

	if self.SubGroup and self.SubGroup.CommonDressTooltip then
		self.SubGroup.CommonDressTooltip:Init({
			spiritContext = self.spiritContext
		})
	end

	SetCharacterPreviewVisible(unit, false)

	if self.bindData.switchBtn then
		self.bindData.switchBtn.gameObject:SetActive(false)
	end

	self.bindData.hidePageCtrl = self.hidePageCtrlEnum.show
end

M.InitEditContentStore = function(self)
	if self.editContentStore then
		return
	end

	local content = self.bindData.weaponScrollRect.content

	if not content then
		return
	end

	self.editContentStore = gStoreManager:GetStoreGroup("WeaponTransmogEditContentStore"):GetStoreByWidget(content)

	if not self.editContentStore then
		return
	end

	local ec = self.editContentStore
	ec.allWeaponBtn.luaClick = self:CreateAction("OnClickAllWeapon")
	ec.assignedWeaponBtn.luaClick = self:CreateAction("OnClickAssignedWeapon")
	ec.weaponCheckList.luaSimpleRenderItem = self:CreateAction("OnRenderWeaponCheckItem")
	ec.weaponCheckList.luaSimpleClick = self:CreateAction("OnClickWeaponCheckItem")

	self:SetupQualitySorter(ec)
end

M.OnClose = function(self)
	self:SwitchDisplayMode(self.displayCtrlEnum.character)

	self.spiritContext = nil
	self.hideCb = nil
end

M.SetupQualitySorter = function(self, ec)
	local selector = ec.qualitySorter

	if not selector then
		return
	end

	local qualityCfg = ConsumableQualityTypeConfig.GetConfig(1)
	self.qualityOptions = {
		{
			["\\xc8\\xce0\\xe8"] = 0,
			name = self:GetTextFromInfoName(WeaponSkinTextInfos.AllQuality)
		}
	}

	if qualityCfg then
		local qualityFields = {
			qualityCfg.White,
			qualityCfg.Green,
			qualityCfg.Blue,
			qualityCfg.Purple,
			qualityCfg.Gold,
			qualityCfg.Orange
		}

		for i, name in ipairs(qualityFields) do
			local fallbackQualityPrefix = self:GetTextFromInfoName(WeaponSkinTextInfos.Quality)

			table.insert(self.qualityOptions, {
				quality = i,
				name = name or fallbackQualityPrefix .. i
			})
		end
	end

	selector:SetSimpleOptions(0)

	for i = 1, #self.qualityOptions do
		selector:AddSimpleOptionLabel(0, self.qualityOptions[i].name, i ~= 1)
	end

	selector.selectedIndex = 0

	selector:RefreshOptions()

	selector.luaSelectedChanged = self:CreateAction("OnQualitySorterChanged")
	self.currentQualityFilter = 0
end

M.OnQualitySorterChanged = function(self, selector)
	local option = self.qualityOptions[selector.selectedIndex + 1]
	self.currentQualityFilter = option and option.quality or 0

	selector:ClosePopUp()
	self:RebuildWeaponCheckList()
	self:RefreshWeaponCheckListUI()
	self:RefreshConfirmBtnState()
end

M.MatchQualityFilter = function(self, quality)
	if not self.currentQualityFilter or self.currentQualityFilter ~= 0 then
		return true
	end

	return quality ~= self.currentQualityFilter
end

M.RebuildWeaponCheckList = function(self)
	table.clear(self.weaponCheckList)

	local weaponIds = gCS.WeaponSkinManager.Instance:GetType2Weapon(self.currentTab2):ToTable()

	for _, weaponSceneItemId in ipairs(weaponIds) do
		local weaponCfg = SceneitemConfig.GetConfig(weaponSceneItemId)
		local quality = weaponCfg and weaponCfg.Quality or 0

		if self:MatchQualityFilter(quality) then
			table.insert(self.weaponCheckList, {
				["ZI\\xfd\\xb8\\x88\r\\xbb\\xcc\\xec"] = false,
				sceneItemId = weaponSceneItemId,
				quality = quality
			})
		end
	end

	table.sort(self.weaponCheckList, function (a, b)
		if a.quality == b.quality then
			return b.quality <= a.quality
		end

		return b.sceneItemId <= a.sceneItemId
	end)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.SYNC_ADD_WEAPON_SKIN_LIST] = function (eventId, skinIdToAcquireTime)
			self:OnSyncAddWeaponSkinList(skinIdToAcquireTime)
		end
	}
	self.dataSetEvents = {}
end

M.RegisterWidget = function(self)
	self.bindData.lightBtn.luaClick = self:CreateAction("OnClickLightBtn")
	self.bindData.hideBtn.luaClick = self:CreateAction("OnClickHideBtn")
	self.bindData.switchDisplayBtn.luaClick = self:CreateAction("OnClickSwitchDisplay")
	self.bindData.switchBtn.luaClick = self:CreateAction("OnClickAvatar")
	self.bindData.settingBtn.luaClick = self:CreateAction("OnClickSettingBtn")
	self.bindData.skinList.luaSimpleRenderItem = self:CreateAction("OnRenderSkinItem")
	self.bindData.skinList.luaSimpleClick = self:CreateAction("OnClickSkinItem")
	self.bindData.editBtn.luaClick = self:CreateAction("OnClickEditBtn")
	self.bindData.confirmBtn.luaClick = self:CreateAction("OnConfirmClick")
	self.bindData.tab1List.luaSimpleRenderItem = self:CreateAction("OnRenderTab1Item")
	self.bindData.tab1List.luaSelectedChanged = self:CreateAction("OnTab1SelectedChanged")
	self.bindData.tab2List.luaSimpleRenderItem = self:CreateAction("OnRenderTab2Item")
	self.bindData.tab2List.luaSelectedChanged = self:CreateAction("OnTab2SelectedChanged")

	if self.bindData.tab2TopBtn then
		self.bindData.tab2TopBtn.luaClick = self:CreateActionWithArgs("OnTab2Scroll", -1)
	end

	if self.bindData.tab2BottomBtn then
		self.bindData.tab2BottomBtn.luaClick = self:CreateActionWithArgs("OnTab2Scroll", 1)
	end
end

M.OnClickHideBtn = function(self)
	if self.bindData.hidePageCtrl ~= self.hidePageCtrlEnum.hide then
		self.bindData.hidePageCtrl = self.hidePageCtrlEnum.show
	else
		self.bindData.hidePageCtrl = self.hidePageCtrlEnum.hide
	end

	if self.hideCb then
		self.hideCb(self.bindData.hidePageCtrl)
	end
end

M.OnClickLightBtn = function(self)
	gDressSceneManager:CycleDressScene()

	self.bindData.lightNameText = gDressSceneManager:GetNextSceneName()

	if self.displayMode ~= self.displayCtrlEnum.weapon then
		self:RefreshPreview()
	end
end

M.OnClickSwitchDisplay = function(self)
	if self.displayMode ~= self.displayCtrlEnum.character then
		self:SwitchDisplayMode(self.displayCtrlEnum.weapon)
	else
		self:SwitchDisplayMode(self.displayCtrlEnum.character)
	end
end

M.OnClickAvatar = function(self)
	gPanelManager:CheckShow(gPanelId.S_SWITCH_CHARACTER, {
		["g\\xf7.\\xfc89\\xc6l%\\xdb_\\xbfC\\xd2\\xe3"] = true,
		["\\x90:,&H\\x8fD\\xcf>\\xaf\\xae"] = true,
		spiritId = self.spiritContext.spiritId,
		onSelectCallback = function (selectedSpiritId)
			gDressSceneManager:SwitchCharacterModel(selectedSpiritId, function (unit)
				self:OnSpiritChanged(selectedSpiritId, unit)
			end)
		end
	})
end

M.OnSpiritChanged = function(self, spiritId, unit)
	self.spiritContext = gDressManager:GetSpiritContext(spiritId, nil, unit)

	self:RefreshAvatar()
	self:RefreshSkinList()
	self:RefreshPreview()
end

M.OnClickSettingBtn = function(self)
	gPanelManager:CheckShow(gPanelId.DRESS_SETTINGS_PANEL, {
		["g\\xf7.\\xfc89\\xc6l%\\xdb_\\xbfC\\xd2\\xe3"] = true,
		spiritContext = self.spiritContext
	})
end

M.RefreshAvatar = function(self)
	local spiritId = self.spiritContext.spiritId
	local info = FightSpiritConfig.GetConfig(spiritId)

	if info then
		self.bindData.switchIconId = info.SHeadIconID
	end
end

M.RefreshTab1List = function(self)
	table.clear(self.tab1List)

	local tab1Set = {}

	for i = 0, WeaponSkinDefaultSkinConfig.count - 1 do
		local cfg = WeaponSkinDefaultSkinConfig.LoadAt(i)

		if cfg and not tab1Set[cfg.Tab1] then
			tab1Set[cfg.Tab1] = true

			table.insert(self.tab1List, {
				tab1 = cfg.Tab1
			})
		end
	end

	if #self.tab1List <= 0 then
		local foundIdx = -1

		if self.currentTab1 and self.currentTab1 == 0 then
			for i, data in ipairs(self.tab1List) do
				if data.tab1 ~= self.currentTab1 then
					foundIdx = i - 1

					break
				end
			end
		end

		if foundIdx >= 0 then
			self.currentTab1 = self.tab1List[1].tab1
			foundIdx = 0
		end
	end

	self:RefreshTab1UI()
	self:RefreshTab2List()
end

M.RefreshTab2List = function(self)
	table.clear(self.tab2List)

	local tab2Set = {}

	for i = 0, WeaponSkinDefaultSkinConfig.count - 1 do
		local cfg = WeaponSkinDefaultSkinConfig.LoadAt(i)

		if cfg and cfg.Tab1 ~= self.currentTab1 and not tab2Set[cfg.Tab2] then
			tab2Set[cfg.Tab2] = true

			table.insert(self.tab2List, {
				tab2 = cfg.Tab2,
				tabicon = cfg.tabicon
			})
		end
	end

	if #self.tab2List <= 0 then
		local foundIdx = -1

		if self.currentTab2 and self.currentTab2 == 0 then
			for i, data in ipairs(self.tab2List) do
				if data.tab2 ~= self.currentTab2 then
					foundIdx = i - 1

					break
				end
			end
		end

		if foundIdx >= 0 then
			self.currentTab2 = self.tab2List[1].tab2
			foundIdx = 0
		end
	end

	self:RefreshTab2UI()
	self:RefreshSkinList()
end

M.RefreshTab1UI = function(self, selectedIdx)
	self.bindData.tab1List:SetSimpleList(#self.tab1List)

	if #self.tab1List <= 0 then
		if selectedIdx ~= nil then
			selectedIdx = 0

			if self.currentTab1 and self.currentTab1 == 0 then
				for i, data in ipairs(self.tab1List) do
					if data.tab1 ~= self.currentTab1 then
						selectedIdx = i - 1

						break
					end
				end
			end
		end

		self.bindData.tab1List:SetItemSelected(selectedIdx, true)
	end
end

M.RefreshTab2UI = function(self, selectedIdx)
	self.bindData.tab2List:SetSimpleList(#self.tab2List)

	if #self.tab2List <= 0 then
		if selectedIdx ~= nil then
			selectedIdx = 0

			if self.currentTab2 and self.currentTab2 == 0 then
				for i, data in ipairs(self.tab2List) do
					if data.tab2 ~= self.currentTab2 then
						selectedIdx = i - 1

						break
					end
				end
			end
		end

		self.bindData.tab2List:SetItemSelected(selectedIdx, true)
	end
end

M.OnRenderTab1Item = function(self, btn, index)
	local data = self.tab1List[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if store then
		local tab1TextName = data.tab1 ~= 0 and "Melee" or "Gun"
		store.title = self:GetTextFromInfoName(WeaponSkinTextInfos[tab1TextName])
	end
end

M.OnRenderTab2Item = function(self, btn, index)
	local data = self.tab2List[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if store then
		store.name = self:GetTab2Name(data.tab2)

		if data.tabicon and data.tabicon <= 0 then
			store.icon = data.tabicon
		end
	end
end

M.GetTab2Name = function(self, tab2)
	for i = 0, WeaponSkinDefaultSkinConfig.count - 1 do
		local cfg = WeaponSkinDefaultSkinConfig.LoadAt(i)

		if cfg and cfg.Tab2 ~= tab2 then
			return cfg.TabName or ""
		end
	end

	return ""
end

M.OnTab1SelectedChanged = function(self)
	local index = self.bindData.tab1List.selectedIndex
	local tabData = self.tab1List[index + 1]

	if tabData then
		self.currentTab1 = tabData.tab1
		self.currentSkinId = 0

		self:RefreshTab2List()
	end
end

M.OnTab2SelectedChanged = function(self)
	local index = self.bindData.tab2List.selectedIndex
	local tabData = self.tab2List[index + 1]

	if tabData then
		self.currentTab2 = tabData.tab2
		self.currentSkinId = 0

		self:RefreshSkinList()
	end
end

M.OnTab2Scroll = function(self, dir)
	local current = self.bindData.tab2List.selectedIndex
	local newIndex = current + dir

	if newIndex >= 0 then
		newIndex = 0
	end

	if newIndex > #self.tab2List then
		newIndex = #self.tab2List - 1
	end

	if newIndex == current then
		self.bindData.tab2List:SetItemSelected(newIndex, true)
	end
end

M.RefreshSkinList = function(self)
	table.clear(self.skinList)

	local WeaponSkinMgr = gCS.WeaponSkinManager.Instance
	local skinConfigIds = WeaponSkinMgr:GetType2WeaponSkinIds(self.currentTab2):ToTable()
	local spiritIds = self:GetAllSpiritIds()
	local skinStateDict = WeaponSkinMgr:GetTypeAllSkinState(self.currentTab2, spiritIds):ToTable()
	local defaultSkinSceneItemId = WeaponSkinMgr:GetType2DefaultSkinSceneitemId(self.currentTab2)
	local defaultSkin = nil

	if defaultSkinSceneItemId and defaultSkinSceneItemId <= 0 then
		defaultSkin = {
			["\\xbb13<j\\x94Q\\xcd>\\xa5\\xb7"] = "",
			["jTHlH,"] = true,
			["\\xe8\\xce0\\xe8"] = 7,
			Id = defaultSkinSceneItemId,
			Name = self:GetTextFromInfoName(WeaponSkinTextInfos.DefaultAppearance),
			SceneItemId = defaultSkinSceneItemId
		}
	end

	local ownedSkins = {}

	for _, skinId in ipairs(skinConfigIds) do
		local cfg = WeaponSkinConfig.GetConfig(skinId)

		if cfg and gCS.WeaponSkinManager.Instance:HasWeaponSkin(cfg.Id) then
			table.insert(ownedSkins, cfg)
		end
	end

	local ownedSkinAcquireTimes = gPlayerManager.infoMinor.bindData.PlayerWeaponSkinInfo and gPlayerManager.infoMinor.bindData.PlayerWeaponSkinInfo.OwnedSkinIds or {}

	table.sort(ownedSkins, function (a, b)
		if a.Quality == b.Quality then
			return b.Quality <= a.Quality
		end

		local timeA = ownedSkinAcquireTimes[a.Id] or 0
		local timeB = ownedSkinAcquireTimes[b.Id] or 0

		if timeA == timeB then
			return timeB <= timeA
		end

		return b.Id <= a.Id
	end)

	if defaultSkin then
		table.insert(self.skinList, {
			cfg = defaultSkin,
			state = skinStateDict[defaultSkin.SceneItemId] or 0
		})
	end

	for _, cfg in ipairs(ownedSkins) do
		table.insert(self.skinList, {
			cfg = cfg,
			state = skinStateDict[cfg.SceneItemId] or 0
		})
	end

	self:RefreshSkinListUI()

	if #self.skinList <= 0 then
		local foundIdx = -1

		if self.currentSkinId and self.currentSkinId == 0 then
			for i, item in ipairs(self.skinList) do
				if item.cfg.Id ~= self.currentSkinId then
					foundIdx = i - 1

					break
				end
			end
		end

		if foundIdx >= 0 then
			local firstAppliedIdx = -1

			for i, item in ipairs(self.skinList) do
				if item.state <= 0 then
					firstAppliedIdx = i - 1

					break
				end
			end

			if firstAppliedIdx > 0 then
				foundIdx = firstAppliedIdx
				self.currentSkinId = self.skinList[firstAppliedIdx + 1].cfg.Id
			else
				self.currentSkinId = self.skinList[1].cfg.Id
				foundIdx = 0
			end
		end

		self.bindData.skinList:SetItemSelected(foundIdx, true)
	else
		self.currentSkinId = 0
	end

	self:RefreshEditBtnInteractable()
	self:RefreshPreview()
	self:RefreshTooltip()
end

M.RefreshSkinListUI = function(self)
	self.bindData.skinList:SetSimpleList(#self.skinList)
end

M.OnRenderSkinItem = function(self, btn, index)
	local item = self.skinList[index + 1]

	if not item then
		return
	end

	local cfg = item.cfg
	local store = gStoreManager:GetStoreGroup("WeaponTransmogItemStore"):GetStoreByWidget(btn)

	if store then
		store.nameText = cfg.Name

		if cfg.IsDefault then
			local iconId = self:GetDefaultSkinIconId(self.currentTab2)

			if iconId and iconId == 0 then
				store.iconId = iconId
			end
		else
			local sceneitemCfg = SceneitemConfig.GetConfig(cfg.SceneItemId)

			if sceneitemCfg and sceneitemCfg.SWeaponWheelsIconId and sceneitemCfg.SWeaponWheelsIconId <= 0 then
				store.iconId = sceneitemCfg.SWeaponWheelsIconId
			end
		end

		store.qualityCtrl = cfg.Quality or 0
		store.stateCtrl = item.state
	end
end

M.OnClickSkinItem = function(self, btn, index)
	local item = self.skinList[index + 1]

	if not item then
		return
	end

	local cfg = item.cfg
	self.currentSkinId = cfg.Id

	self:RefreshEditBtnInteractable()
	self:RefreshPreview()
	self:RefreshTooltip()
end

M.RefreshEditBtnInteractable = function(self)
	local hasSelection = self.currentSkinId == 0
	self.bindData.editBtn.interactable = hasSelection
end

M.RefreshTooltip = function(self)
	if not self.SubGroup or not self.SubGroup.CommonDressTooltip then
		return
	end

	local tooltip = self.SubGroup.CommonDressTooltip
	local cfg = self:GetCurrentSkinConfig()

	if not cfg then
		return
	end

	local tab2Name = self:GetTab2Name(self.currentTab2)
	tooltip.bindData.typeText = string.format("%s·%s", self:GetTextFromInfoName(WeaponSkinTextInfos.OutwardAppearance), tab2Name)

	if cfg.IsDefault then
		tooltip.bindData.fashionNameText = self:GetTextFromInfoName(WeaponSkinTextInfos.DefaultAppearance)
		tooltip.bindData.fashionDesText = string.format(self:GetTextFromInfoName(WeaponSkinTextInfos.DefaultAppearanceDesc), tab2Name)
	else
		tooltip.bindData.fashionNameText = cfg.Name or ""
		tooltip.bindData.fashionDesText = cfg.Description or ""
	end

	tooltip.bindData.typeCtrl = tooltip.typeCtrlEnum.NotSuit
	tooltip.bindData.showDesCtrl = tooltip.showDesCtrlEnum.show
	tooltip.bindData.showCollectCtrl = tooltip.showCollectCtrlEnum.hide
	tooltip.bindData.showFashionQualityCtrl = tooltip.showFashionQualityCtrlEnum.Hide
	tooltip.bindData.showDyeCtrl = tooltip.showDyeCtrlEnum._false
	tooltip.bindData.showSwitchCtrl = tooltip.showSwitchCtrlEnum._false
	tooltip.bindData.isShowEditCtrl = tooltip.isShowEditCtrlEnum.hide
end

M.GetDefaultSkinIconId = function(self, tab2)
	for i = 0, WeaponSkinDefaultSkinConfig.count - 1 do
		local cfg = WeaponSkinDefaultSkinConfig.LoadAt(i)

		if cfg and cfg.Tab2 ~= tab2 then
			return cfg.Icon
		end
	end

	return nil
end

M.SwitchDisplayMode = function(self, mode)
	self.displayMode = mode
	self.bindData.displayCtrl = mode
	local unit = gDressSceneManager.currentModelUnit or self.spiritContext and self.spiritContext.unit

	if mode ~= self.displayCtrlEnum.weapon then
		SetCharacterPreviewVisible(unit, false)
		self:RefreshPreview()
	else
		gDressSceneManager:ClearWeaponModel()
		SetCharacterPreviewVisible(unit, true)

		if self.spiritContext and self.spiritContext.spiritId then
			gDressSceneManager:SwitchCharacterModel(self.spiritContext.spiritId, nil)
		end
	end
end

M.RefreshPreview = function(self)
	local cfg = self:GetCurrentSkinConfig()

	if not cfg then
		return
	end

	if self.displayMode ~= self.displayCtrlEnum.weapon then
		local skinSceneItemId = cfg.SceneItemId or 0

		if skinSceneItemId <= 0 then
			gDressSceneManager:LoadWeaponModel(skinSceneItemId, nil, self.currentTab2)
		else
			gDressSceneManager:ClearWeaponModel()
		end
	else
		local unit = gDressSceneManager.currentModelUnit or self.spiritContext and self.spiritContext.unit

		if unit then
			local WeaponSkinManager = gCS.WeaponSkinManager.Instance

			if cfg.IsDefault then
				WeaponSkinManager:ClearWeaponSkinPreview(unit)
			else
				local sceneItemId = cfg.SceneItemId or 0

				if sceneItemId <= 0 then
					WeaponSkinManager:SetWeaponSkinPreview(unit, sceneItemId)
				end
			end
		end
	end
end

M.GetCurrentSkinConfig = function(self)
	for _, item in ipairs(self.skinList) do
		if item.cfg.Id ~= self.currentSkinId then
			return item.cfg
		end
	end

	return nil
end

M.OnClickEditBtn = function(self)
	self.bindData.pageCtrl = self.pageCtrlEnum.second

	self:InitSecondPage()
end

M.InitSecondPage = function(self)
	if not self.editContentStore then
		return
	end

	self.characterOption = 2
	self.weaponOption = 1

	table.clear(self.selectedCharacterIds)
	table.clear(self.weaponCheckList)
	table.clear(self.characterCheckList)
	self:RebuildWeaponCheckList()

	local affectedSpirits = self:GetCurrentSkinAffectedSpirits()

	for _, spiritId in ipairs(affectedSpirits) do
		table.insert(self.characterCheckList, {
			["ZI\\xfd\\xb8\\x88\r\\xbb\\xcc\\xec"] = false,
			spiritId = spiritId
		})
	end

	local ec = self.editContentStore
	local spiritId = self.spiritContext.spiritId
	local spiritCfg = FightSpiritConfig.GetConfig(spiritId)
	local spiritName = spiritCfg and spiritCfg.Name or ""
	ec.currentCharacterText = self:GetTextFromInfoName(WeaponSkinTextInfos.CurrentCharacter, spiritName)
	ec.allCharacterText = self:GetTextFromInfoName(WeaponSkinTextInfos.AllCharacter)
	local tab2Name = self:GetTab2Name(self.currentTab2)
	ec.allWeaponText = self:GetTextFromInfoName(WeaponSkinTextInfos.AllWeaponType, tab2Name)
	ec.assignedWeaponText = self:GetTextFromInfoName(WeaponSkinTextInfos.AssignedWeapon, 0, #self.weaponCheckList)
	ec.assignedCharacterText = self:GetTextFromInfoName(WeaponSkinTextInfos.AssignedCharacter, 0, #self.characterCheckList)
	local applyTipNames = {}

	if self:IsCurrentSkinExclusive() then
		for _, sid in ipairs(affectedSpirits) do
			local scfg = FightSpiritConfig.GetConfig(sid)

			table.insert(applyTipNames, scfg and scfg.Name or tostring(sid))
		end
	else
		applyTipNames = {
			self:GetTextFromInfoName(WeaponSkinTextInfos.AllCharacter)
		}
	end

	ec.applyCharacterTipText = self:GetTextFromInfoName(WeaponSkinTextInfos.ApplyCharacterTip, table.concat(applyTipNames, "、"))
	ec.showCharacterListCtrl = 1
	ec.showWeaponListCtrl = 1

	ec.currentCharacterBtn:SetSelected(true)
	ec.allCharacterBtn:SetSelected(false)
	ec.assignedCharacterBtn:SetSelected(false)
	ec.allWeaponBtn:SetSelected(true)
	ec.assignedWeaponBtn:SetSelected(false)
	self:RefreshWeaponCheckListUI()
	self:RefreshCharacterCheckListUI()
	self:RefreshConfirmBtnState()
end

M.RefreshWeaponCheckListUI = function(self)
	if not self.editContentStore then
		return
	end

	self.editContentStore.weaponCheckList:SetSimpleList(#self.weaponCheckList)
end

M.RefreshCharacterCheckListUI = function(self)
	if not self.editContentStore then
		return
	end

	self.editContentStore.characterCheckList:SetSimpleList(#self.characterCheckList)
end

M.OnRenderWeaponCheckItem = function(self, btn, index)
	local data = self.weaponCheckList[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup("WeaponChooseItemStore"):GetStoreByWidget(btn)

	if store then
		local weaponCfg = SceneitemConfig.GetConfig(data.sceneItemId)

		if weaponCfg then
			store.iconId = weaponCfg.WeaponConsumableIcon
			store.qualityCtrl = weaponCfg.Quality or 0
		else
			store.iconId = 0
			store.qualityCtrl = 0
		end

		store.isSelectedCtrl = data.isSelected and 1 or 0
		store.tickCtrl = data.isSelected and 0 or 1
	end

	btn:SetSelected(data.isSelected)

	btn.luaRenderTooltip = self:CreateActionWithArgs("OnRenderWeaponCheckTooltip", data)
end

M.OnRenderWeaponCheckTooltip = function(self, data, btn, popup, popupIndex)
	if not data or not data.sceneItemId then
		return
	end

	local tipStore = gStoreManager:GetStoreGroup(popup.Store)

	if tipStore then
		tipStore:SetSelectedItem({
			TemplateId = data.sceneItemId
		})
	end
end

M.OnClickWeaponCheckItem = function(self, btn, index)
	local data = self.weaponCheckList[index + 1]

	if not data then
		return
	end

	data.isSelected = not data.isSelected

	btn:SetSelected(data.isSelected)

	local store = gStoreManager:GetStoreGroup("WeaponChooseItemStore"):GetStoreByWidget(btn)

	if store then
		store.tickCtrl = data.isSelected and 0 or 1
	end

	self:RefreshConfirmBtnState()

	if self.editContentStore then
		self.editContentStore.assignedWeaponText = self:GetTextFromInfoName(WeaponSkinTextInfos.AssignedWeapon, self:CountSelectedWeapons(), #self.weaponCheckList)
	end
end

M.OnClickCurrentCharacter = function(self)
	self.characterOption = 1

	if self.editContentStore then
		local ec = self.editContentStore

		ec.currentCharacterBtn:SetSelected(true)
		ec.allCharacterBtn:SetSelected(false)
		ec.assignedCharacterBtn:SetSelected(false)

		ec.showCharacterListCtrl = 1
	end

	self:RefreshConfirmBtnState()
end

M.OnClickAllCharacter = function(self)
	self.characterOption = 2

	if self.editContentStore then
		local ec = self.editContentStore

		ec.currentCharacterBtn:SetSelected(false)
		ec.allCharacterBtn:SetSelected(true)
		ec.assignedCharacterBtn:SetSelected(false)

		ec.showCharacterListCtrl = 1
	end

	self:RefreshConfirmBtnState()
end

M.OnClickAssignedCharacter = function(self)
	self.characterOption = 3

	if self.editContentStore then
		local ec = self.editContentStore

		ec.currentCharacterBtn:SetSelected(false)
		ec.allCharacterBtn:SetSelected(false)
		ec.assignedCharacterBtn:SetSelected(true)

		ec.showCharacterListCtrl = 0
	end

	self:RefreshConfirmBtnState()
end

M.OnRenderCharacterCheckItem = function(self, btn, index)
	local data = self.characterCheckList[index + 1]

	if not data then
		return
	end

	local spiritId = data.spiritId
	local store = gStoreManager:GetStoreGroup("FashionCharacterOrderTemplate"):GetStoreByWidget(btn)

	if store then
		local cfg = FightSpiritConfig.GetConfig(spiritId)

		if cfg then
			store.characterIconId = cfg.SHeadIconID
		end

		btn:SetSelected(data.isSelected)
	end
end

M.OnClickCharacterCheckItem = function(self, btn, index)
	local data = self.characterCheckList[index + 1]

	if not data then
		return
	end

	data.isSelected = not data.isSelected

	btn:SetSelected(data.isSelected)

	if data.isSelected then
		if not self:IsCharacterSelected(data.spiritId) then
			table.insert(self.selectedCharacterIds, data.spiritId)
		end
	else
		for i, id in ipairs(self.selectedCharacterIds) do
			if id ~= data.spiritId then
				table.remove(self.selectedCharacterIds, i)

				break
			end
		end
	end

	self:RefreshConfirmBtnState()

	if self.editContentStore then
		local selectedCnt = 0

		for _, d in ipairs(self.characterCheckList) do
			if d.isSelected then
				selectedCnt = selectedCnt + 1
			end
		end

		self.editContentStore.assignedCharacterText = self:GetTextFromInfoName(WeaponSkinTextInfos.AssignedCharacter, selectedCnt, #self.characterCheckList)
	end
end

M.OnClickAllWeapon = function(self)
	self.weaponOption = 1

	if self.editContentStore then
		local ec = self.editContentStore

		ec.allWeaponBtn:SetSelected(true)
		ec.assignedWeaponBtn:SetSelected(false)

		ec.showWeaponListCtrl = 1
	end

	self:RefreshConfirmBtnState()
end

M.OnClickAssignedWeapon = function(self)
	self.weaponOption = 2

	if self.editContentStore then
		local ec = self.editContentStore

		ec.allWeaponBtn:SetSelected(false)
		ec.assignedWeaponBtn:SetSelected(true)

		ec.showWeaponListCtrl = 0
	end

	self:RefreshConfirmBtnState()
end

M.IsCharacterSelected = function(self, spiritId)
	for _, id in ipairs(self.selectedCharacterIds) do
		if id ~= spiritId then
			return true
		end
	end

	return false
end

M.CountSelectedWeapons = function(self)
	local count = 0

	for _, data in ipairs(self.weaponCheckList) do
		if data.isSelected then
			count = count + 1
		end
	end

	return count
end

M.GetCurrentSkinEquipableSpirits = function(self)
	local cfg = self:GetCurrentSkinConfig()

	if not cfg then
		return nil
	end

	local eq = cfg.EquipableSpirits

	if type(eq) ~= "table" and #eq <= 0 then
		return eq
	end

	return nil
end

M.IsCurrentSkinExclusive = function(self)
	return self:GetCurrentSkinEquipableSpirits() == nil
end

M.GetCurrentSkinAffectedSpirits = function(self)
	local eq = self:GetCurrentSkinEquipableSpirits()

	if eq then
		local result = {}

		for _, sid in ipairs(eq) do
			table.insert(result, sid)
		end

		return result
	end

	return self:GetAllSpiritIds()
end

M.GetSelectedCharacterList = function(self)
	if self:IsCurrentSkinExclusive() then
		return self:GetCurrentSkinAffectedSpirits()
	end

	if self.characterOption ~= 1 then
		return {
			self.spiritContext.spiritId
		}
	elseif self.characterOption ~= 2 then
		return self:GetAllSpiritIds()
	elseif self.characterOption ~= 3 then
		return self.selectedCharacterIds
	end

	return {}
end

M.GetSelectedWeaponList = function(self)
	if self.weaponOption ~= 1 then
		return gCS.WeaponSkinManager.Instance:GetType2Weapon(self.currentTab2):ToTable()
	elseif self.weaponOption ~= 2 then
		local result = {}

		for _, data in ipairs(self.weaponCheckList) do
			if data.isSelected then
				table.insert(result, data.sceneItemId)
			end
		end

		return result
	end

	return {}
end

M.GetAllSpiritIds = function(self)
	if self._allSpiritIdsCache then
		return self._allSpiritIdsCache
	end

	local lingList = LingGuiUtils:GetAllLingList()
	local ids = {}

	for i = 1, #lingList do
		table.insert(ids, lingList[i].Id)
	end

	self._allSpiritIdsCache = ids

	return self._allSpiritIdsCache
end

M.OnConfirmClick = function(self)
	local cfg = self:GetCurrentSkinConfig()

	if not cfg then
		return
	end

	local selectedCharacterList = self:GetSelectedCharacterList()
	local selectedWeaponList = self:GetSelectedWeaponList()

	if #selectedCharacterList ~= 0 or #selectedWeaponList ~= 0 then
		self.bindData.pageCtrl = self.pageCtrlEnum.first

		self:RefreshSkinList()

		return
	end

	local confirmText = nil

	if self.weaponOption ~= 1 then
		confirmText = self:GetTextFromInfoName(WeaponSkinTextInfos.SkinApplyAllWeaponsConfirm)
	end

	if confirmText then
		slot5 = gDisplayMessageMgr

		slot5:ShowMessageContent(confirmText, gDisplayMessageId.SELECT, nil, function ()
			self:DoApplyWeaponSkin(cfg, selectedCharacterList, selectedWeaponList)
		end, nil)

		return
	end

	self:DoApplyWeaponSkin(cfg, selectedCharacterList, selectedWeaponList)
end

M.DoApplyWeaponSkin = function(self, cfg, selectedCharacterList, selectedWeaponList)
	local skinId = cfg.IsDefault and 0 or cfg.Id

	if skinId == 0 and not gCS.WeaponSkinManager.Instance:HasWeaponSkin(skinId) then
		self.bindData.pageCtrl = self.pageCtrlEnum.first

		self:RefreshSkinList()

		return
	end

	local skinSceneItemId = cfg.IsDefault and 0 or cfg.SceneItemId or 0
	local WeaponSkinManager = gCS.WeaponSkinManager.Instance
	local hasChanges = false

	for _, spiritId in ipairs(selectedCharacterList) do
		for _, weaponSceneItemId in ipairs(selectedWeaponList) do
			if WeaponSkinManager:GetWeaponSkinSceneItemId(spiritId, weaponSceneItemId) == skinSceneItemId then
				hasChanges = true

				break
			end
		end

		if hasChanges then
			break
		end
	end

	if not hasChanges then
		self:ShowApplyToast(cfg)

		self.bindData.pageCtrl = self.pageCtrlEnum.first

		self:RefreshSkinList()

		return
	end

	slot8 = gWeaponSkinManager

	slot8:AskSetWeaponSkins(selectedCharacterList, selectedWeaponList, skinId, function (err)
		self:OnApplyResult(err, selectedCharacterList, selectedWeaponList, cfg)
	end)
end

M.ShowApplyToast = function(self, cfg)
	if cfg and cfg.IsDefault then
		gDisplayMessageMgr:ShowMessageContent(self:GetTextFromInfoName(WeaponSkinTextInfos.SkinCancelApplied))
	else
		gDisplayMessageMgr:ShowMessageContent(self:GetTextFromInfoName(WeaponSkinTextInfos.WeaponSkinApplied))
	end
end

M.OnApplyResult = function(self, err, selectedCharacterList, selectedWeaponList, cfg)
	if err == MessageConfig.Ok then
		gDisplayMessageMgr:DisplayServerMessageId(err)

		self.bindData.pageCtrl = self.pageCtrlEnum.first

		self:RefreshSkinList()

		return
	end

	if selectedCharacterList and selectedWeaponList and cfg then
		local WeaponSkinManager = gCS.WeaponSkinManager.Instance
		local skinSceneItemId = cfg.IsDefault and 0 or cfg.SceneItemId or 0

		for _, spiritId in ipairs(selectedCharacterList) do
			for _, weaponSceneItemId in ipairs(selectedWeaponList) do
				WeaponSkinManager:SetWeaponSkin(spiritId, weaponSceneItemId, skinSceneItemId)
			end
		end
	end

	gMessageManager:SendMessage(gEventConstants.UPDATE_WEAPON_SKIN_CONFIG)
	self:ShowApplyToast(cfg)

	self.bindData.pageCtrl = self.pageCtrlEnum.first

	self:RefreshSkinList()
end

M.RefreshConfirmBtnState = function(self)
	local characterValid = self.characterOption ~= 1 or self.characterOption ~= 2 or self.characterOption ~= 3 and #self.selectedCharacterIds >= 0
	local weaponValid = self.weaponOption ~= 1 or self.weaponOption ~= 2 and self:HasSelectedWeapon()
	self.bindData.confirmBtn.interactable = characterValid and weaponValid
end

M.HasSelectedWeapon = function(self)
	for _, data in ipairs(self.weaponCheckList) do
		if data.isSelected then
			return true
		end
	end

	return false
end

M.OnSyncAddWeaponSkinList = function(self, skinIdToAcquireTime)
	if self.bindData.pageCtrl ~= self.pageCtrlEnum.first then
		self:RefreshSkinList()
	end
end
