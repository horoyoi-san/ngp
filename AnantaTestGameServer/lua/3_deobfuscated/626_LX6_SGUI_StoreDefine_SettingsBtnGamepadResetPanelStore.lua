local RebindStrategyType = LX6.Manager.RebindStrategyType
local RebindRequest = LX6.Manager.RebindRequest
local MessageConfig = LTConfig.MessageConfig
local RebindMode = LX6.Manager.RebindMode
local RebindActionConfig = LTConfig.RebindActionConfig
local RebindActionActionMapConfig = LTConfig.RebindActionActionMapConfig
local FightSpiritConfig = LTConfig.FightSpiritConfig
local RebindActionControllerConfig = LTConfig.RebindActionRebindActionControllerConfig
local RebindActionIconConfig = LTConfig.RebindActionControllerIconConfig
local ProfileManager = LX6.Engine.ProfileManager
local gameProfile = ProfileManager.gameProfile
local RebindMode = LX6.Manager.RebindMode
C_SettingsBtnGamepadResetPanelStore = DefClass("C_SettingsBtnGamepadResetPanelStore", C_SettingsBtnGamepadResetPanelStore, C_StoreGroup)
GroupName2Class.SettingsBtnGamepadResetPanelStore = C_SettingsBtnGamepadResetPanelStore
local M = C_SettingsBtnGamepadResetPanelStore

function M:ctor()
	return
end

function M:DefineAllVariables()
	self.actionNameToInfo = {}
	self.actionMapIdToInfo = {}

	for i = 0, RebindActionControllerConfig.count - 1 do
		local config = RebindActionControllerConfig.LoadAt(i)

		if config then
			self.actionNameToInfo[config.ActionName] = {
				id = config.Id,
				mapId = config.ActionMapId,
				name = config.Name,
				composite = config.IsComposite
			}
		end
	end

	for i = 0, RebindActionActionMapConfig.count - 1 do
		local config = RebindActionActionMapConfig.LoadAt(i)

		if config then
			self.actionMapIdToInfo[config.Id] = {
				classify = config.Classify
			}
		end
	end

	self.buttonPathToIcon = {}

	for i = 0, RebindActionIconConfig.count - 1 do
		local config = RebindActionIconConfig.LoadAt(i)

		if config then
			self.buttonPathToIcon[config.ButtonName] = {
				ps = config.PSIcon,
				xbox = config.XboxIcon,
				iconCtrl = config.IconCtrl
			}
		end
	end
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
	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnGroupDisable()
	self:ClearMessageEvents()
end

function M:OnShow(panelId, data)
	if not table.isNilOrEmpty(RebindActionConfig.ControllerClassifyText) then
		self.classifyList = RebindActionConfig.ControllerClassifyText
	end

	self.typeNameList = {}

	for t = 1, #RebindActionConfig.ControllerTypeId do
		self.typeNameList[RebindActionConfig.ControllerTypeId[t]] = RebindActionConfig.ControllerTypeText[t]
	end

	self:SetRebindGroupedData()
	self:SetCharacterInfo()

	self.classifySelected = 1

	self.bindData.tabList:SetSimpleList(#self.classifyList)
	self.bindData.tabList:SetItemSelected(0, true)

	if self.classifySelected == RebindActionConfig.ControllerCharacterClassfify then
		self.bindData.showCharacterCtrl = 1
		self.characterSelected = self:GetCurSpiritId()
		local fightSpirit = FightSpiritConfig.GetConfig(self.characterSelected)
		self.bindData.characterImage = fightSpirit.SHeadIconID
		self.bindData.characterName = fightSpirit.Name
		self.characterPageData = self:SetCharacterData()

		self.bindData.buttonList:SetSimpleList(#self.characterPageData)
	else
		self.characterPageData = nil
		self.bindData.showCharacterCtrl = 0

		if table.isNilOrEmpty(self.rebindGroupedData[self.classifySelected]) then
			self.bindData.buttonList:SetSimpleList(0)
		else
			self.bindData.buttonList:SetSimpleList(#self.rebindGroupedData[self.classifySelected])
		end
	end
end

function M:SetRebindGroupedData()
	self.rebindGroupedData = {}
	local tempMapData = {}

	for i = 0, RebindActionControllerConfig.count - 1 do
		local config = RebindActionControllerConfig.LoadAt(i)

		if config then
			local actionMapId = config.ActionMapId

			if not tempMapData[actionMapId] then
				tempMapData[actionMapId] = {}
			end

			table.insert(tempMapData[actionMapId], {
				id = config.Id,
				actionName = config.Name,
				button = gCS.RebindMgr:GetButtonNamesByActionId(config.Id, RebindMode.Gamepad, config.IsComposite):ToTable(),
				isRebind = gCS.RebindMgr:IsActionRebound(config.Id, RebindMode.Gamepad),
				isEmpty = gCS.RebindMgr:IsActionEmpty(config.Id, RebindMode.Gamepad),
				canRebind = config.CanRebind,
				isComposite = config.IsComposite,
				character = config.FightSpiritId,
				exchangeList = config.ExchangePadList
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
end

function M:SetCharacterInfo()
	local characterList = {}

	if not RebindActionConfig.ControllerCharacterClassfify or not self.rebindGroupedData[RebindActionConfig.ControllerCharacterClassfify] then
		return
	end

	local sexType = gPlayerManager.infoLogin.bindData.sexType
	local notShowId = nil

	if sexType == 1 then
		notShowId = LTConfig.FightSpiritConfig.DefaultFemale
	elseif sexType == 2 then
		notShowId = LTConfig.FightSpiritConfig.DefaultMale
	end

	local data = self.rebindGroupedData[RebindActionConfig.ControllerCharacterClassfify]

	for k, actionInfo in pairs(data) do
		if actionInfo.id ~= -1 then
			local characterInfo = actionInfo.character

			for id = 1, #characterInfo do
				if characterInfo[id] ~= notShowId then
					characterList[characterInfo[id]] = characterList[characterInfo[id]] or {}

					table.insert(characterList[characterInfo[id]], actionInfo)
				end
			end
		end
	end

	self.characterTabList = {}

	for characterId, _ in pairs(characterList) do
		if characterId ~= notShowId then
			table.insert(self.characterTabList, characterId)
		end
	end

	table.sort(self.characterTabList)

	self.characterList = characterList
end

function M:GetCurSpiritId()
	local characterSelected = gSpiritManager:GetCurFirstSpiritTid()

	if not table.contains(self.characterTabList, characterSelected) then
		local sexType = gPlayerManager.infoLogin.bindData.sexType
		characterSelected = sexType == 1 and LTConfig.FightSpiritConfig.DefaultMale or LTConfig.FightSpiritConfig.DefaultFemale
	end

	return characterSelected
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
	self.msgEvents = {
		[gEventConstants.REBIND_COMPLETE] = self:CreateAction("OnCompleteRebindAction"),
		[gEventConstants.REBIND_CONFLICT] = self:CreateAction("OnConflictRebindAction"),
		[gEventConstants.REBIND_OVERWRITE] = self:CreateAction("OnConflictOverwriteAction")
	}
end

function M:RegisterWidget()
	self.bindData.closeBtn.luaClick = self:CreateAction("OnClickCloseBtn")
	self.bindData.switchCharacterBtn.luaRenderTooltip = self:CreateAction("OnRenderCharacterTooltip")
	self.bindData.resetBtn.luaClick = self:CreateAction("OnClickResetBtn")
	self.bindData.leftBtn.luaClick = self:CreateActionWithArgs("OnRefreshTab", -1)
	self.bindData.rightBtn.luaClick = self:CreateActionWithArgs("OnRefreshTab", 1)
	self.bindData.tabList.luaSimpleRenderItem = self:CreateAction("OnSimpleRenderTabListItem")
	self.bindData.tabList.luaSelectedChanged = self:CreateAction("OnTabListSelectedChange")
	self.bindData.buttonList.luaSimpleRenderItem = self:CreateAction("OnSimpleRenderButtonListItem")
	self.bindData.buttonList.onGetTIndex = self:CreateAction("OnGetButtonListTIndex")
	self.bindData.buttonList.luaSelectedChanged = self:CreateAction("OnButtonSelectedChange")
end

function M:OnRefreshButtons(optId)
	if optId then
		local config = RebindActionControllerConfig.GetConfig(optId)
		local targetMapId = config.ActionMapId
		local targetClassify = self.actionMapIdToInfo[targetMapId].classify

		for i = 1, #self.rebindGroupedData[targetClassify] do
			if self.rebindGroupedData[targetClassify][i].id == optId then
				self.rebindGroupedData[targetClassify][i].button = gCS.RebindMgr:GetButtonNamesByActionId(optId, RebindMode.Gamepad, config.IsComposite):ToTable()
				self.rebindGroupedData[targetClassify][i].isRebind = gCS.RebindMgr:IsActionRebound(optId, RebindMode.Gamepad)
				self.rebindGroupedData[targetClassify][i].isEmpty = gCS.RebindMgr:IsActionEmpty(optId, RebindMode.Gamepad)

				break
			end
		end
	end

	if self.classifySelected == RebindActionConfig.ControllerCharacterClassfify then
		self.characterPageData = self:SetCharacterData()

		self.bindData.buttonList:SetSimpleList(#self.characterPageData)
	else
		self.characterPageData = nil

		self.bindData.buttonList:SetSimpleList(#self.rebindGroupedData[self.classifySelected])
	end

	self:InitRightInfo()
end

function M:InitRightInfo(showData)
	local device = gCS.LuaUtils.GetActiveDevice()
	self.bindData.imgCtrl = device == SGUI.GameDevice.PlayStation and 0 or 1
	local gameDeviceIndex = device == SGUI.GameDevice.PlayStation and "ps" or "xbox"

	if table.isNilOrEmpty(showData) then
		local firstIndex = 1

		if self.rebindGroupedData[self.classifySelected][firstIndex].id == -1 then
			firstIndex = firstIndex + 1
		end

		if table.isNilOrEmpty(self.rebindGroupedData[self.classifySelected]) or table.isNilOrEmpty(self.rebindGroupedData[self.classifySelected].button) then
			self.bindData.isModifiedCtrl = 0

			return
		end

		local firstRebindData = self.rebindGroupedData[self.classifySelected][firstIndex]
		self.bindData.isModifiedCtrl = (firstRebindData.isRebind or firstRebindData.isEmpty) and 1 or 0

		if self.bindData.isModifiedCtrl == 1 then
			self.bindData.buttonTitle = firstRebindData.actionName

			if firstRebindData.isComposite then
				self.bindData.initKeyCtrl = 0

				if firstRebindData.button[1] and firstRebindData.button[2] then
					self.bindData.initFirstKey = self.buttonPathToIcon[firstRebindData.button[1]][gameDeviceIndex]
					self.bindData.initSecondKey = self.buttonPathToIcon[firstRebindData.button[2]][gameDeviceIndex]
				end
			else
				self.bindData.initKeyCtrl = 1

				if not self.buttonPathToIcon[firstRebindData.button[1]] then
					self.bindData.initFirstKey = ""
				else
					self.bindData.initFirstKey = self.buttonPathToIcon[firstRebindData.button[1]][gameDeviceIndex]
				end
			end
		end
	else
		self.bindData.buttonTitle = showData.actionName
		self.bindData.isModifiedCtrl = (showData.isEmpty or showData.isRebind) and 1 or 0

		if self.bindData.isModifiedCtrl == 1 then
			local initButtons = gCS.RebindMgr:GetInitBindingsByName(showData.id, RebindMode.Gamepad):ToTable()

			if showData.isComposite then
				self.bindData.initKeyCtrl = 0

				if initButtons[1] and initButtons[2] then
					self.bindData.initFirstKey = self.buttonPathToIcon[initButtons[1]][gameDeviceIndex]
					self.bindData.initSecondKey = self.buttonPathToIcon[initButtons[2]][gameDeviceIndex]
				end
			else
				self.bindData.initKeyCtrl = 1

				if not self.buttonPathToIcon[initButtons[1]] then
					self.bindData.initSingleKey = ""
				else
					self.bindData.initSingleKey = self.buttonPathToIcon[initButtons[1]][gameDeviceIndex]
				end
			end
		end
	end
end

function M:SetCharacterData()
	local pageData = {}
	local data = self.rebindGroupedData[self.classifySelected]
	local chrData = self.characterList[self.characterSelected]

	for t = 1, #chrData do
		table.insert(pageData, chrData[t])
	end

	for t = 1, #data do
		if table.isNilOrEmpty(data[t].character) then
			if data[t].actionName == self.typeNameList[13] then
				table.insert(pageData, 1, data[t])
			else
				table.insert(pageData, data[t])
			end
		end
	end

	return pageData
end

function M:OnClickCloseBtn()
	local firstEmptyAction = gCS.RebindMgr:HasEmptyAction(RebindMode.Gamepad)

	if string.is_null_or_empty(firstEmptyAction) then
		gMessageManager:SendMessage(gEventConstants.REBIND_CLOSE_PANEL, RebindMode.Gamepad)
		gPanelManager:Close(gPanelId.SETTING_BTN_RESET_PANEL_CONTROLLER)
	else
		local function centerCallback()
			local mapId = self.actionNameToInfo[firstEmptyAction].mapId
			self.classifySelected = self.actionMapIdToInfo[mapId].classify

			self.bindData.tabList:SetItemSelected(self.classifySelected - 1, true)
			self:OnRefreshButtons()

			for t = 1, #self.rebindGroupedData[self.classifySelected] do
				if self.rebindGroupedData[self.classifySelected][t].id == self.actionNameToInfo[firstEmptyAction].id then
					self.bindData.buttonList:GoToIndex(t - 1, true)

					break
				end
			end
		end

		local function leftCallback()
			gMessageManager:SendMessage(gEventConstants.REBIND_CLOSE_PANEL)
			gPanelManager:Close(gPanelId.SETTING_BTN_RESET_PANEL_CONTROLLER)
		end

		gDisplayMessageMgr:ShowMessageTriple(MessageConfig.PCkeyResetEmpty, nil, centerCallback, leftCallback, self.actionNameToInfo[firstEmptyAction].name)
	end
end

function M:OnClickResetBtn()
	gDisplayMessageMgr:ShowMessage(MessageConfig.ShezhiReset, function ()
		gCS.RebindMgr:RemoveAllOverrides(RebindMode.Gamepad)

		gameProfile.isCustomizeController = false

		ProfileManager.SaveGameProperty()
		self:SetRebindGroupedData()
		self:OnRefreshButtons()
	end, nil, LTConfig.TextScriptTextConfig.GetConfig(89901303).Text)
end

function M:OnRenderCharacterTooltip(btn, widget)
	local store = gStoreManager:GetStoreGroup("SettingBtnResetCharacterList"):GetStoreByWidget(widget)

	if not store then
		return
	end

	local characterListGo = store.characterList

	characterListGo:SetSimpleList(#self.characterTabList)

	characterListGo.luaSimpleRenderItem = self:CreateAction("OnSimpleRenderCharacterListItem")
end

function M:OnSimpleRenderTabListItem(btn, index)
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

function M:OnTabListSelectedChange()
	local index = self.bindData.tabList.selectedIndex
	self.classifySelected = index + 1

	if self.classifySelected == RebindActionConfig.ControllerCharacterClassfify then
		self.bindData.showCharacterCtrl = 1
		self.characterSelected = self:GetCurSpiritId()
		local fightSpirit = FightSpiritConfig.GetConfig(self.characterSelected)
		self.bindData.characterImage = fightSpirit.SHeadIconID
		self.bindData.characterName = fightSpirit.Name
		self.characterPageData = self:SetCharacterData()

		self.bindData.buttonList:SetSimpleList(#self.characterPageData)
		self.bindData.buttonList:SetItemSelected(0, true)
	else
		self.characterPageData = nil
		self.bindData.showCharacterCtrl = 0

		if table.isNilOrEmpty(self.rebindGroupedData[self.classifySelected]) then
			self.bindData.buttonList:SetSimpleList(0)
		else
			self.bindData.buttonList:SetSimpleList(#self.rebindGroupedData[self.classifySelected])
			self.bindData.buttonList:SetItemSelected(0, true)
		end
	end
end

function M:OnGetButtonListTIndex(index)
	local data = self.rebindGroupedData[self.classifySelected][index + 1]

	if self.classifySelected == RebindActionConfig.ControllerCharacterClassfify then
		if not self.characterPageData then
			self.characterPageData = self:SetCharacterData()
		end

		data = self.characterPageData[index + 1]
	end

	if not data then
		return 0
	else
		return data.id == -1 and 0 or 1
	end
end

function M:OnSimpleRenderButtonListItem(btn, index)
	local data = self.rebindGroupedData[self.classifySelected][index + 1]

	if self.classifySelected == RebindActionConfig.ControllerCharacterClassfify then
		data = self.characterPageData[index + 1]
	end

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.title = data.actionName
	store.rebindCtrl = data.isRebind and 1 or 0
	store.interactable = data.canRebind and 1 or 0
	store.isCompositeCtrl = data.isComposite and 0 or 1
	local device = gCS.LuaUtils.GetActiveDevice()
	self.bindData.imgCtrl = device == SGUI.GameDevice.PlayStation and 0 or 1
	local gameDeviceIndex = gCS.LuaUtils.GetActiveDevice() == SGUI.GameDevice.PlayStation and "ps" or "xbox"

	if data.button then
		if data.isComposite then
			if data.button[1] and data.button[2] then
				store.compositeFirstKey = self.buttonPathToIcon[data.button[1]][gameDeviceIndex]
				store.compositeSecondKey = self.buttonPathToIcon[data.button[2]][gameDeviceIndex]
			end
		elseif not self.buttonPathToIcon[data.button[1]] then
			store.singleKey = ""
		else
			store.singleKey = self.buttonPathToIcon[data.button[1]][gameDeviceIndex]
		end

		store.rebindButton.luaFocus = self:CreateActionWithArgs("OnButtonSelectedChange", data)
	end

	if not table.isNilOrEmpty(data.exchangeList) then
		self.optionList = {}

		for t = 1, #data.exchangeList do
			local curButtonPath = RebindActionIconConfig.GetConfig(data.exchangeList[t]).ButtonName
			local tView = {
				buttonPath = curButtonPath,
				iconId = self.buttonPathToIcon[curButtonPath][gameDeviceIndex],
				index = t,
				isSelect = false
			}

			table.insert(self.optionList, tView)
		end

		store.dropMenu:SetOptions(self.optionList)

		store.dropMenu.luaRenderPopup = self:CreateActionWithArgs("OnDropMenuRenderPopup", data.id)
	end
end

function M:OnDropMenuRenderPopup(actionId, popup, list)
	list.luaSimpleRenderItem = self:CreateAction("OnRenderPopupListItem")

	list:SetSimpleList(#self.optionList)

	list.luaSimpleClick = self:CreateActionWithArgs("OnDropMenuOptionClicked", actionId)
end

function M:OnRenderPopupListItem(btn, index)
	local data = self.optionList[index + 1]
	local store = gStoreManager:GetStoreGroup("DropMenuBtn"):GetStoreByWidget(btn)

	if store and data then
		local actionText = ""
		local useActions = gCS.RebindMgr:GetActionsByPath(data.buttonPath):ToTable()

		if not table.isNilOrEmpty(useActions) then
			for t = 1, #useActions do
				actionText = actionText .. useActions[t]

				if t ~= #useActions then
					actionText = actionText .. "/"
				end
			end
		end

		store.title = actionText
		store.iconId = data.iconId
	end
end

function M:OnDropMenuOptionClicked(actionId, btn, index)
	local data = self.optionList[index + 1]

	if not data then
		return
	end

	local rebindRequest = RebindRequest.New(actionId, data.buttonPath, RebindStrategyType.Gamepad)

	gCS.RebindMgr:StartRebindNew(rebindRequest)
end

function M:OnButtonSelectedChange(data)
	if not data then
		return
	end

	self:InitRightInfo(data)

	if not table.isNilOrEmpty(data.button) then
		local device = gCS.LuaUtils.GetActiveDevice()
		self.bindData.imgCtrl = device == SGUI.GameDevice.PlayStation and 0 or 1

		if data.isComposite then
			if data.button[1] == "<Gamepad>/buttonNorth" and data.button[2] == "<Gamepad>/buttonEast" then
				self.bindData.imgKeyCtrl = 16
			end
		elseif table.isNilOrEmpty(data.button) or not data.button[1] or not self.buttonPathToIcon[data.button[1]] then
			print_error("OnButtonSelectedChange", data.actionName)
		else
			self.bindData.imgKeyCtrl = self.buttonPathToIcon[data.button[1]].iconCtrl
		end
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

function M:OnCompleteRebindAction(eventId, data)
	self:OnRefreshButtons(self.actionNameToInfo[data].id)
end

function M:OnConflictRebindAction(eventId, data)
	local function rightCallBack()
		gMessageManager:SendMessage(gEventConstants.REBIND_CONFLICT_CONFIRM)
	end

	local mid = MessageConfig.PCkeyResetConflict
	local conflictText = ""
	local conflictActionNames = data[1]:ToTable()

	for t = 1, #conflictActionNames do
		conflictText = conflictText .. self.actionNameToInfo[conflictActionNames[t]].name

		if t ~= #conflictActionNames then
			conflictText = conflictText .. "/"
		end
	end

	gDisplayMessageMgr:ShowMessage(mid, rightCallBack, nil, conflictText, conflictText)
end

function M:OnConflictOverwriteAction(eventId, data)
	self:OnRefreshButtons(self.actionNameToInfo[data[0]].id)

	local conflictActionNames = data[1]:ToTable()

	for t = 1, #conflictActionNames do
		self:OnRefreshButtons(self.actionNameToInfo[conflictActionNames[t]].id)
	end
end

function M:OnSimpleRenderCharacterListItem(btn, index)
	local data = self.characterTabList[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local fightSpirit = FightSpiritConfig.GetConfig(data)
	store.image = fightSpirit.SHeadIconID
	store.imageBtn.luaClick = self:CreateActionWithArgs("OnSimpleClickCharacterList", index)
end

function M:OnSimpleClickCharacterList(index)
	self.characterSelected = self.characterTabList[index + 1]
	local fightSpirit = FightSpiritConfig.GetConfig(self.characterSelected)
	self.bindData.characterImage = fightSpirit.SHeadIconID
	self.bindData.characterName = fightSpirit.Name
	self.characterPageData = self:SetCharacterData()

	self.bindData.buttonList:SetSimpleList(#self.characterPageData)
	self.bindData.switchCharacterBtn:CloseTooltip()
end

function M:OnRefreshTab(step)
	local nextStep = self.bindData.tabList.selectedIndex + step

	if nextStep < 0 then
		nextStep = #self.tabList - 1
	elseif nextStep >= #self.classifyList then
		nextStep = 0
	end

	self.bindData.tabList:SetItemSelected(nextStep, true)
end
