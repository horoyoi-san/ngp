-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\SettingsKeyPanelPCStore.lua
-- Decompiled from: 00925_SettingsKeyPanelPCStore.lua_ea57039cb5bb.luajit

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

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.LeftSwitchTabAnim = "vx_S_SettingsKeyPanel_to_right"
	self.RightSwitchTabAnim = "vx_S_SettingsKeyPanel_to_left"
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	self:InitButtonLayoutData()
	self:InitRebindActionData()

	self.classifySelected = 1

	self.bindData.layoutList:SetSimpleList(#self.leftLayoutList)
	self.bindData.tabList:SetSimpleList(#self.classifyList)
	self.bindData.tabList:SetItemSelected(0, true)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.REBIND_CHANGE_CONFIG_FINISH] = self.CreateAction(self, "OnRefreshRightRegion")
	}
end

M.RegisterWidget = function(self)
	self.bindData.layoutList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderLayoutListItem")
	self.bindData.layoutList.onGetTIndex = self.CreateAction(self, "OnGetLayoutListTIndex")
	self.bindData.tabList.luaSelectedChanged = self.CreateAction(self, "OnClassifySelectedChanged")
	self.bindData.tabList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderClassifyListItem")
	self.bindData.detailList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderRebindListItem")
	self.bindData.detailList.onGetTIndex = self.CreateAction(self, "OnGetDetailListTIndex")
	self.bindData.leftBtn.luaClick = self.CreateActionWithArgs(self, "OnRefreshTab", -1)
	self.bindData.rightBtn.luaClick = self.CreateActionWithArgs(self, "OnRefreshTab", 1)
end

M.OnGetLayoutListTIndex = function(self, index)
	local data = self.leftLayoutList[index + 1]

	if not data then
		return 0
	else
		return data.tIndex
	end
end

M.OnSimpleRenderLayoutListItem = function(self, btn, index)
	local data = self.leftLayoutList[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	if data.tIndex ~= 0 then
		store.title = data.title
	elseif data.tIndex ~= 1 then
		store.title = data.title

		store.dropMenu:SetSimpleOptions(#self.optionList)

		for i = 1, #self.optionList do
			store.dropMenu:SetItemLabel(i - 1, self.optionList[i].label)
		end

		local selectIndex = self:GetKeyConfigIndex()

		store.dropMenu:SelectOption(selectIndex)

		store.dropMenu.luaSimpleOptionClick = self:CreateAction("OnConfigSelectedChanged")

		self:OnRefreshRightRegion()
	elseif data.tIndex ~= 2 then
		store.title = data.title
		store.turnToBtn.luaClick = self.CreateAction(self, "OnTurnToBtnClicked")
	end

	store.interactable = 1
end

M.OnTurnToBtnClicked = function(self)
	gPanelManager:CheckShow(gPanelId.SETTING_BTN_RESET_PANEL, {
		classify = self.classifyList,
		type = self.typeNameList,
		icon = self.buttonIconList,
		rebindAction = self.rebindGroupedData
	})
end

M.GetKeyConfigIndex = function(self)
	return gameProfile.isCustomizeButton and 0 or 1
end

M.OnConfigSelectedChanged = function(self, btn, index)
	gameProfile.isCustomizeButton = index == 1

	ProfileManager.SaveGameProperty()

	if gameProfile.isCustomizeButton then
		gMessageManager:SendMessage(gEventConstants.REBIND_TO_CUSTOM, RebindMode.Keyboard)
	else
		gMessageManager:SendMessage(gEventConstants.REBIND_TO_DEFAULT, RebindMode.Keyboard)
	end

	gMessageManager:SendMessage(gEventConstants.SETTING_KEY_PANEL_CHANGED)
end

M.OnSimpleRenderClassifyListItem = function(self, btn, index)
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

M.OnClassifySelectedChanged = function(self)
	self.classifySelected = self.bindData.tabList.selectedIndex + 1

	self.OnRefreshRightRegion(self)
end

M.OnRefreshRightRegion = function(self)
	self:InitRebindActionData()
	self.bindData.detailList:SetSimpleList(#self.rebindGroupedData[self.classifySelected])
	self.bindData.detailList:GoToIndex(0, true)
end

M.OnGetDetailListTIndex = function(self, index)
	local data = self.rebindGroupedData[self.classifySelected][index + 1]

	if not data then
		return 0
	else
		return data.id ~= -1 and 0 or 1
	end
end

M.OnSimpleRenderRebindListItem = function(self, btn, index)
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
	local rebindButtons = {}

	if data.button then
		for k, buttonName in pairs(data.button) do
			if data.isComposite and k <= 1 then
				table.insert(rebindButtons, {
					["a\\x9f\\x8a\\x86Y"] = 5
				})
			end

			local buttonInfo = gRebindActionManager.buttonNamePCDic[buttonName]

			if buttonInfo then
				if not string.is_null_or_empty(buttonInfo.RebindText) then
					table.insert(rebindButtons, {
						["a\\x9f\\x8a\\x86Y"] = 4,
						buttonText = buttonInfo.RebindText,
						buttonFont = SGUI.SDF.SDFAsyncFontAssetManager.GetFontAssetByName(buttonInfo.KeyFont)
					})
				elseif buttonInfo.ButtonIcon == 0 then
					table.insert(rebindButtons, {
						["a\\x9f\\x8a\\x86Y"] = 2,
						iconId = buttonInfo.RebindIcon
					})
				end
			elseif not string.is_null_or_empty(buttonName) then
				local buttonPath = gCS.RebindMgr:ExtractKeyName(buttonName)

				if buttonPath then
					table.insert(rebindButtons, {
						["a\\x9f\\x8a\\x86Y"] = 4,
						buttonText = buttonPath
					})
				end
			end
		end

		store.templateList.luaSimpleRenderItem = self:CreateActionWithArgs("OnSimpleRenderTemplateListItem", rebindButtons)
		store.templateList.onGetTIndex = self:CreateActionWithArgs("OnGetTemplateListTIndex", rebindButtons)

		store.templateList:SetSimpleList(#rebindButtons)
	end
end

M.OnRenderDetailListItem = function(self, btn, index)
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
			local buttonInfo = gRebindActionManager.buttonNamePCDic[buttonName]

			if buttonInfo then
				if not string.is_null_or_empty(buttonInfo.RebindText) then
					table.insert(rebindButtons, {
						["a\\x9f\\x8a\\x86Y"] = 4,
						buttonText = buttonInfo.RebindText,
						buttonFont = SGUI.SDF.SDFAsyncFontAssetManager.GetFontAssetByName(buttonInfo.KeyFont)
					})
				elseif buttonInfo.ButtonIcon == 0 then
					table.insert(rebindButtons, {
						["a\\x9f\\x8a\\x86Y"] = 2,
						iconId = buttonInfo.RebindIcon
					})
				end
			end
		end

		store.templateList.luaSimpleRenderItem = self:CreateActionWithArgs("OnSimpleRenderTemplateListItem", rebindButtons)
		store.templateList.onGetTIndex = self:CreateActionWithArgs("OnGetTemplateListTIndex", rebindButtons)

		store.templateList:SetSimpleList(#rebindButtons)
	end
end

M.OnSimpleRenderTemplateListItem = function(self, contentList, btn, index)
	local data = contentList[index + 1]

	if not data then
		return
	end

	if data.tIndex ~= 5 then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	if data.tIndex ~= 2 then
		store.icon = data.iconId
	elseif data.tIndex ~= 4 then
		store.text = data.buttonText

		if data.buttonFont then
			store.font = data.buttonFont
		end
	end
end

M.OnGetTemplateListTIndex = function(self, contentList, index)
	local data = contentList[index + 1]

	if not data then
		return 0
	end

	return data.tIndex
end

M.InitButtonLayoutData = function(self)
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

M.InitRebindActionData = function(self)
	self.rebindGroupedData = {}
	local sexType = gPlayerManager.infoLogin.bindData.sexType
	local notShowId = nil

	if sexType ~= 1 then
		notShowId = LTConfig.FightSpiritConfig.DefaultFemale
	elseif sexType ~= 2 then
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
				if config.FightSpiritId[1] ~= notShowId then
					if config.FightSpiritId[2] then
						local fightSpiritCfg = FightSpiritConfig.GetConfig(config.FightSpiritId[2])

						if fightSpiritCfg then
							name = "[" .. fightSpiritCfg.Name .. "]" .. name
						else
							print_error("SettingsKeyPanelPCStore: InitRebindActionData FightSpiritConfig.GetConfig not found, FightSpiritId=" .. tostring(config.FightSpiritId[2]))
						end
					end
				else
					local fightSpiritCfg = FightSpiritConfig.GetConfig(config.FightSpiritId[1])

					if fightSpiritCfg then
						name = "[" .. fightSpiritCfg.Name .. "]" .. name
					else
						print_error("SettingsKeyPanelPCStore: InitRebindActionData FightSpiritConfig.GetConfig not found, FightSpiritId=" .. tostring(config.FightSpiritId[1]))
					end
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

				if not table.contains(typeUsed, actionType) and actionType == 0 then
					table.insert(self.rebindGroupedData[classify], {
						["\t\r"] = -1,
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

	self.rebindGroupedData[RebindActionConfig.CharacterClassfify] = self.SortCharacterList(self, self.rebindGroupedData[RebindActionConfig.CharacterClassfify])
end

M.SortCharacterList = function(self, source_table)
	if not source_table or #source_table ~= 0 then
		return {}
	end

	local result_table = {}
	local current_chunk = {}

	local sort_func = function(a, b)
		return a.id <= b.id
	end

	local process_chunk = function()
		if #current_chunk <= 0 then
			table.sort(current_chunk, sort_func)

			for _, item in ipairs(current_chunk) do
				table.insert(result_table, item)
			end

			current_chunk = {}
		end
	end

	for _, item in ipairs(source_table) do
		if item.id ~= -1 then
			process_chunk()
			table.insert(result_table, item)
		else
			table.insert(current_chunk, item)
		end
	end

	process_chunk()

	return result_table
end

M.OnRefreshTab = function(self, step)
	local nextStep = self.bindData.tabList.selectedIndex + step

	if nextStep >= 0 then
		nextStep = #self.classifyList - 1
	elseif nextStep > #self.classifyList then
		nextStep = 0
	end

	self.bindData.tabList:SetItemSelected(nextStep, true)

	self.bindData.pageCtrl = nextStep
end
