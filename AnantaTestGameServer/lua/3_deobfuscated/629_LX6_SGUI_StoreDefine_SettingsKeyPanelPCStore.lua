local ShezhiPanelConfig = LTConfig.ShezhiPanelConfig
local RebindActionConfig = LTConfig.RebindActionConfig
local RebindActionActionMapConfig = LTConfig.RebindActionActionMapConfig
local RebindActionButtonIconConfig = LTConfig.RebindActionButtonIconConfig
local FightSpiritConfig = LTConfig.FightSpiritConfig
local ProfileManager = LX6.Engine.ProfileManager
local gameProfile = ProfileManager.gameProfile
local RebindMode = LX6.Manager.RebindMode
C_SettingsKeyPanelPCStore = DefClass("C_SettingsKeyPanelPCStore", C_SettingsKeyPanelPCStore, C_StoreGroup)
GroupName2Class.SettingsKeyPanelPCStore = C_SettingsKeyPanelPCStore
local M = C_SettingsKeyPanelPCStore

function M:ctor()
	return
end

function M:DefineAllVariables()
	self.LeftSwitchTabAnim = "vx_S_SettingsKeyPanel_to_right"
	self.RightSwitchTabAnim = "vx_S_SettingsKeyPanel_to_left"
end

function M:OnAwake()
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()
end

function M:OnEnable()
	return
end

function M:OnStart()
	return
end

function M:OnDisable()
	return
end

function M:OnDestroy()
	return
end

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	return
end

function M:OnShow(panelId, data)
	self:InitButtonLayoutData()
	self:InitRebindActionData()

	self.classifySelected = 1

	self.bindData.layoutList:SetSimpleList(#self.leftLayoutList)
	self.bindData.tabList:SetSimpleList(#self.classifyList)
	self.bindData.tabList:SetItemSelected(0, true)
end

function M:OnClose()
	return
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end

function M:GenMessageEvents()
	return
end

function M:RegisterWidget()
	self.bindData.layoutList.luaSimpleRenderItem = self:CreateAction("OnSimpleRenderLayoutListItem")
	self.bindData.layoutList.onGetTIndex = self:CreateAction("OnGetLayoutListTIndex")
	self.bindData.tabList.luaSelectedChanged = self:CreateAction("OnClassifySelectedChanged")
	self.bindData.tabList.luaSimpleRenderItem = self:CreateAction("OnSimpleRenderClassifyListItem")
	self.bindData.detailList.luaSimpleRenderItem = self:CreateAction("OnSimpleRenderRebindListItem")
	self.bindData.detailList.onGetTIndex = self:CreateAction("OnGetDetailListTIndex")
	self.bindData.leftBtn.luaClick = self:CreateActionWithArgs("OnRefreshTab", -1)
	self.bindData.rightBtn.luaClick = self:CreateActionWithArgs("OnRefreshTab", 1)
end

function M:OnGetLayoutListTIndex(index)
	local data = self.leftLayoutList[index + 1]

	if not data then
		return 0
	else
		return data.tIndex
	end
end

function M:OnSimpleRenderLayoutListItem(btn, index)
	local data = self.leftLayoutList[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	if data.tIndex == 0 then
		store.title = data.title
	elseif data.tIndex == 1 then
		store.title = data.title

		store.dropMenu:SetOptions(self.optionList)
		store.dropMenu:SelectOption(0)

		self.bindData.isDefaultCtrl = 1
	elseif data.tIndex == 2 then
		store.title = data.title
		store.turnToBtn.luaClick = self:CreateAction("OnTurnToBtnClicked")
	end

	store.interactable = 1
end

function M:OnTurnToBtnClicked()
	gPanelManager:CheckShow(gPanelId.SETTING_BTN_RESET_PANEL, {
		classify = self.classifyList,
		type = self.typeNameList,
		icon = self.buttonIconList,
		rebindAction = self.rebindGroupedData
	})
end

function M:GetKeyConfigIndex()
	return gameProfile.isCustomizeButton and 0 or 1
end

function M:OnConfigSelectedChanged(btn, item)
	self.bindData.isDefaultCtrl = item.index - 1
	gameProfile.isCustomizeButton = self.bindData.isDefaultCtrl ~= 1

	ProfileManager.SaveGameProperty()

	if gameProfile.isCustomizeButton then
		gMessageManager:SendMessage(gEventConstants.REBIND_TO_CUSTOM, RebindMode.Keyboard)
	else
		gMessageManager:SendMessage(gEventConstants.REBIND_TO_DEFAULT, RebindMode.Keyboard)
	end

	self:OnRefreshRightRegion()
end

function M:OnSimpleRenderClassifyListItem(btn, index)
	local data = self.classifyList[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.title = data

	if btn.isSelected then
		self.classifySelected = index + 1
	end
end

function M:OnClassifySelectedChanged()
	if self.bindData.isDefaultCtrl == 1 then
		if self.classifySelected < self.bindData.tabList.selectedIndex + 1 then
			gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnim, self.RightSwitchTabAnim)
		else
			gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnim, self.LeftSwitchTabAnim)
		end
	end

	self.classifySelected = self.bindData.tabList.selectedIndex + 1

	self:OnRefreshRightRegion()
end

function M:OnRefreshRightRegion()
	if self.bindData.isDefaultCtrl == 1 then
		self.bindData.keyMapImage = RebindActionConfig.ClassifyIcon[self.classifySelected]
	else
		self:InitRebindActionData()
		self.bindData.detailList:SetSimpleList(#self.rebindGroupedData[self.classifySelected])
	end
end

function M:OnGetDetailListTIndex(index)
	local data = self.rebindGroupedData[self.classifySelected][index + 1]

	if not data then
		return 0
	else
		return data.id == -1 and 0 or 1
	end
end

function M:OnSimpleRenderRebindListItem(btn, index)
	local data = self.rebindGroupedData[self.classifySelected][index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.title = data.actionName
	store.emptyCtrl = data.isEmpty and 1 or 0
	store.rebindCtrl = data.isRebind and not data.isEmpty and 1 or 0
	store.interactable = data.canRebind
	local rebindButtons = {}

	if data.button then
		for k, buttonName in pairs(data.button) do
			local buttonPath = gCS.RebindMgr:ExtractKeyName(buttonName)

			if self.buttonIconList[buttonPath] then
				table.insert(rebindButtons, {
					tIndex = 2,
					iconId = self.buttonIconList[buttonPath]
				})
			else
				table.insert(rebindButtons, {
					tIndex = 4,
					buttonText = buttonPath
				})
			end
		end

		store.templateList.luaSimpleRenderItem = self:CreateActionWithArgs("OnSimpleRenderTemplateListItem", rebindButtons)
		store.templateList.onGetTIndex = self:CreateActionWithArgs("OnGetTemplateListTIndex", rebindButtons)

		store.templateList:SetSimpleList(#rebindButtons)
	end
end

function M:OnRenderDetailListItem(btn, index)
	local data = self.rebindGroupedData[self.classifySelected][index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.title = data.actionName
	store.emptyCtrl = data.isEmpty and 1 or 0
	store.rebindCtrl = data.isRebind and 1 or 0
	store.interactable = data.canRebind
	local rebindButtons = {}

	if data.button then
		for k, buttonName in pairs(data.button) do
			local buttonPath = gCS.RebindMgr:ExtractKeyName(buttonName)

			if self.buttonIconList[buttonPath] then
				table.insert(rebindButtons, {
					tIndex = 2,
					iconId = self.buttonIconList[buttonPath]
				})
			else
				table.insert(rebindButtons, {
					tIndex = 4,
					buttonText = buttonPath
				})
			end
		end

		store.templateList.luaSimpleRenderItem = self:CreateActionWithArgs("OnSimpleRenderTemplateListItem", rebindButtons)
		store.templateList.onGetTIndex = self:CreateActionWithArgs("OnGetTemplateListTIndex", rebindButtons)

		store.templateList:SetSimpleList(#rebindButtons)
	end
end

function M:OnSimpleRenderTemplateListItem(contentList, btn, index)
	local data = contentList[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	if data.tIndex == 2 then
		store.icon = data.iconId
	elseif data.tIndex == 4 then
		store.text = data.buttonText
	end
end

function M:OnGetTemplateListTIndex(contentList, index)
	local data = contentList[index + 1]

	if not data then
		return 0
	end

	return data.tIndex
end

function M:InitButtonLayoutData()
	self.leftLayoutList = {}
	local titleList = ShezhiPanelConfig.KeyPanelLayoutTitle

	for i = 1, #titleList do
		self.leftLayoutList[i] = {
			index = titleList[i].type,
			tIndex = titleList[i].tIndex,
			title = titleList[i].name
		}
	end

	if not table.isNilOrEmpty(ShezhiPanelConfig.KeyPanelConfigTitle) then
		self.optionList = {}

		for t = 1, #ShezhiPanelConfig.KeyPanelConfigTitle do
			local tView = {
				label = ShezhiPanelConfig.KeyPanelConfigTitle[t],
				iconId = 0,
				index = t,
				isSelect = false
			}

			table.insert(self.optionList, tView)
		end
	end

	if not table.isNilOrEmpty(RebindActionConfig.ClassifyText) then
		self.classifyList = RebindActionConfig.ClassifyText
	end

	self.typeNameList = {}

	for t = 1, #RebindActionConfig.TypeId do
		self.typeNameList[RebindActionConfig.TypeId[t]] = RebindActionConfig.TypeText[t]
	end

	self.buttonIconList = {}

	for i = 0, RebindActionButtonIconConfig.count - 1 do
		local config = RebindActionButtonIconConfig.LoadAt(i)

		if config then
			self.buttonIconList[config.ButtonName] = config.ButtonIcon
		end
	end
end

function M:InitRebindActionData()
	self.rebindGroupedData = {}
	local sexType = gPlayerManager.infoLogin.bindData.sexType
	local notShowId = nil

	if sexType == 1 then
		notShowId = LTConfig.FightSpiritConfig.DefaultFemale
	elseif sexType == 2 then
		notShowId = LTConfig.FightSpiritConfig.DefaultMale
	end

	local tempMapData = {}

	for i = 0, RebindActionConfig.count - 1 do
		local config = RebindActionConfig.LoadAt(i)

		if config then
			local actionMapId = config.ActionMapId

			if not tempMapData[actionMapId] then
				tempMapData[actionMapId] = {}
			end

			local name = config.Name

			if not table.isNilOrEmpty(config.FightSpiritId) then
				if config.FightSpiritId[1] == notShowId then
					if config.FightSpiritId[2] then
						name = "[" .. FightSpiritConfig.GetConfig(config.FightSpiritId[2]).Name .. "]" .. name
					end
				else
					name = "[" .. FightSpiritConfig.GetConfig(config.FightSpiritId[1]).Name .. "]" .. name
				end
			end

			table.insert(tempMapData[actionMapId], {
				id = config.Id,
				actionName = name,
				button = gCS.RebindMgr:GetButtonNamesByActionId(config.Id, RebindMode.Keyboard, config.IsComposite):ToTable(),
				isRebind = gCS.RebindMgr:IsActionRebound(config.Id, RebindMode.Keyboard),
				isEmpty = gCS.RebindMgr:IsActionEmpty(config.Id, RebindMode.Keyboard),
				canRebind = config.CanRebind,
				isComposite = config.IsComposite,
				character = config.FightSpiritId
			})
		end
	end

	local typeUsed = {}

	for i = 0, RebindActionActionMapConfig.count - 1 do
		local config = RebindActionActionMapConfig.LoadAt(i)

		if config then
			local mapId = config.Id
			local classify = config.Classify
			local actionType = config.Type
			local mapDetails = tempMapData[mapId]

			if mapDetails then
				if not self.rebindGroupedData[classify] then
					self.rebindGroupedData[classify] = {}
				end

				if not table.contains(typeUsed, actionType) and actionType ~= 0 then
					table.insert(self.rebindGroupedData[classify], {
						id = -1,
						actionName = self.typeNameList[actionType]
					})
					table.insert(typeUsed, actionType)
				end

				for _, detail in ipairs(mapDetails) do
					table.insert(self.rebindGroupedData[classify], detail)
				end
			end
		end
	end

	self.rebindGroupedData[RebindActionConfig.CharacterClassfify] = self:SortCharacterList(self.rebindGroupedData[RebindActionConfig.CharacterClassfify])
end

function M:SortCharacterList(source_table)
	if not source_table or #source_table == 0 then
		return {}
	end

	local result_table = {}
	local current_chunk = {}

	local function sort_func(a, b)
		return a.id < b.id
	end

	local function process_chunk()
		if #current_chunk > 0 then
			table.sort(current_chunk, sort_func)

			for _, item in ipairs(current_chunk) do
				table.insert(result_table, item)
			end

			current_chunk = {}
		end
	end

	for _, item in ipairs(source_table) do
		if item.id == -1 then
			process_chunk()
			table.insert(result_table, item)
		else
			table.insert(current_chunk, item)
		end
	end

	process_chunk()

	return result_table
end

function M:OnRefreshTab(step)
	local nextStep = self.bindData.tabList.selectedIndex + step

	if nextStep < 0 then
		nextStep = #self.classifyList - 1
	elseif nextStep >= #self.classifyList then
		nextStep = 0
	end

	self.bindData.tabList:SetItemSelected(nextStep, true)

	self.bindData.pageCtrl = nextStep
end
