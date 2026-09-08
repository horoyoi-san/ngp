-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\SettingsBtnGamepadResetPanelStore.lua
-- Decompiled from: 00885_SettingsBtnGamepadResetPanelStore.lua_afd83fd96593.luajit

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

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
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
	self.optionListMap = {}
	self.gameDeviceIndex = gCS.LuaUtils.GetActiveDevice() ~= SGUI.GameDevice.PlayStation and "ps" or "xbox"

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

	if self.classifySelected ~= RebindActionConfig.ControllerCharacterClassfify then
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

M.SetRebindGroupedData = function(self)
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

	local classifyTypeData = {}
	local classifyTypeOrder = {}

	for i = 0, RebindActionActionMapConfig.count - 1 do
		local config = RebindActionActionMapConfig.LoadAt(i)

		if config then
			local mapId = config.Id
			local classify = config.Classify
			local actionType = config.Type
			local mapDetails = tempMapData[mapId]

			if mapDetails then
				if not classifyTypeData[classify] then
					classifyTypeData[classify] = {}
					classifyTypeOrder[classify] = {}
				end

				if not classifyTypeData[classify][actionType] then
					classifyTypeData[classify][actionType] = {}
				end

				if not table.contains(classifyTypeOrder[classify], actionType) then
					table.insert(classifyTypeOrder[classify], actionType)
				end

				for _, detail in ipairs(mapDetails) do
					table.insert(classifyTypeData[classify][actionType], detail)
				end
			end
		end
	end

	for classify, typeData in pairs(classifyTypeData) do
		self.rebindGroupedData[classify] = {}
		local order = classifyTypeOrder[classify]

		if order then
			for _, actionType in ipairs(order) do
				if actionType == 0 then
					table.insert(self.rebindGroupedData[classify], {
						["\t\r"] = -1,
						actionName = self.typeNameList[actionType]
					})
				end

				local details = typeData[actionType]

				for _, detail in ipairs(details) do
					table.insert(self.rebindGroupedData[classify], detail)
				end
			end
		end
	end
end

M.SetCharacterInfo = function(self)
	local characterList = {}

	if not RebindActionConfig.ControllerCharacterClassfify or not self.rebindGroupedData[RebindActionConfig.ControllerCharacterClassfify] then
		return
	end

	local sexType = gPlayerManager.infoLogin.bindData.sexType
	local notShowId = nil

	if sexType ~= 1 then
		notShowId = LTConfig.FightSpiritConfig.DefaultFemale
	elseif sexType ~= 2 then
		notShowId = LTConfig.FightSpiritConfig.DefaultMale
	end

	local data = self.rebindGroupedData[RebindActionConfig.ControllerCharacterClassfify]

	for k, actionInfo in pairs(data) do
		if actionInfo.id == -1 then
			local characterInfo = actionInfo.character

			for id = 1, #characterInfo do
				if characterInfo[id] == notShowId then
					characterList[characterInfo[id]] = characterList[characterInfo[id]] or {}

					table.insert(characterList[characterInfo[id]], actionInfo)
				end
			end
		end
	end

	self.characterTabList = {}

	for characterId, _ in pairs(characterList) do
		if characterId == notShowId then
			table.insert(self.characterTabList, characterId)
		end
	end

	table.sort(self.characterTabList)

	self.characterList = characterList
end

M.GetCurSpiritId = function(self)
	local characterSelected = gSpiritManager:GetCurFirstSpiritTid()

	if not table.contains(self.characterTabList, characterSelected) then
		local sexType = gPlayerManager.infoLogin.bindData.sexType
		characterSelected = sexType ~= 1 and LTConfig.FightSpiritConfig.DefaultMale or LTConfig.FightSpiritConfig.DefaultFemale
	end

	return characterSelected
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
	self.OnRefreshButtons(self)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.REBIND_COMPLETE] = self.CreateAction(self, "OnCompleteRebindAction"),
		[gEventConstants.REBIND_CONFLICT] = self.CreateAction(self, "OnConflictRebindAction"),
		[gEventConstants.REBIND_OVERWRITE] = self.CreateAction(self, "OnConflictOverwriteAction")
	}
end

M.RegisterWidget = function(self)
	self.bindData.closeBtn.luaClick = self.CreateAction(self, "OnClickCloseBtn")
	self.bindData.switchCharacterBtn.luaRenderTooltip = self.CreateAction(self, "OnRenderCharacterTooltip")
	self.bindData.resetBtn.luaClick = self.CreateAction(self, "OnClickResetBtn")
	self.bindData.leftBtn.luaClick = self.CreateActionWithArgs(self, "OnRefreshTab", -1)
	self.bindData.rightBtn.luaClick = self.CreateActionWithArgs(self, "OnRefreshTab", 1)
	self.bindData.tabList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderTabListItem")
	self.bindData.tabList.luaSelectedChanged = self.CreateAction(self, "OnTabListSelectedChange")
	self.bindData.buttonList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderButtonListItem")
	self.bindData.buttonList.onGetTIndex = self.CreateAction(self, "OnGetButtonListTIndex")
	self.bindData.buttonList.luaSelectedChanged = self.CreateAction(self, "OnButtonSelectedChange")
end

M.OnRefreshButtons = function(self, optId)
	if optId then
		local config = RebindActionControllerConfig.GetConfig(optId)
		local targetMapId = config.ActionMapId
		local targetClassify = self.actionMapIdToInfo[targetMapId].classify

		for i = 1, #self.rebindGroupedData[targetClassify] do
			if self.rebindGroupedData[targetClassify][i].id ~= optId then
				self.rebindGroupedData[targetClassify][i].button = gCS.RebindMgr:GetButtonNamesByActionId(optId, RebindMode.Gamepad, config.IsComposite):ToTable()
				self.rebindGroupedData[targetClassify][i].isRebind = gCS.RebindMgr:IsActionRebound(optId, RebindMode.Gamepad)
				self.rebindGroupedData[targetClassify][i].isEmpty = gCS.RebindMgr:IsActionEmpty(optId, RebindMode.Gamepad)

				break
			end
		end
	end

	if self.classifySelected ~= RebindActionConfig.ControllerCharacterClassfify then
		self.characterPageData = self:SetCharacterData()

		self.bindData.buttonList:SetSimpleList(#self.characterPageData)
	else
		self.characterPageData = nil

		self.bindData.buttonList:SetSimpleList(#self.rebindGroupedData[self.classifySelected])
	end

	self.InitRightInfo(self)
end

M.InitRightInfo = function(self, showData)
	local device = gCS.LuaUtils.GetActiveDevice()
	self.bindData.imgCtrl = device ~= SGUI.GameDevice.PlayStation and 0 or 1
	local gameDeviceIndex = device ~= SGUI.GameDevice.PlayStation and "ps" or "xbox"

	if table.isNilOrEmpty(showData) then
		local firstIndex = 1

		if self.rebindGroupedData[self.classifySelected][firstIndex].id ~= -1 then
			firstIndex = firstIndex + 1
		end

		if table.isNilOrEmpty(self.rebindGroupedData[self.classifySelected]) or table.isNilOrEmpty(self.rebindGroupedData[self.classifySelected].button) then
			self.bindData.isModifiedCtrl = 0

			return
		end

		local firstRebindData = self.rebindGroupedData[self.classifySelected][firstIndex]
		self.bindData.isModifiedCtrl = (firstRebindData.isRebind or firstRebindData.isEmpty) and 1 or 0

		if self.bindData.isModifiedCtrl ~= 1 then
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

		if self.bindData.isModifiedCtrl ~= 1 then
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

M.SetCharacterData = function(self)
	local pageData = {}
	local data = self.rebindGroupedData[self.classifySelected]
	local chrData = self.characterList[self.characterSelected]

	if chrData then
		for t = 1, #chrData do
			table.insert(pageData, chrData[t])
		end
	end

	for t = 1, #data do
		if table.isNilOrEmpty(data[t].character) then
			if data[t].actionName ~= self.typeNameList[13] then
				table.insert(pageData, 1, data[t])
			else
				table.insert(pageData, data[t])
			end
		end
	end

	return pageData
end

M.OnClickCloseBtn = function(self)
	local firstEmptyAction = gCS.RebindMgr:HasEmptyAction(RebindMode.Gamepad)

	if string.is_null_or_empty(firstEmptyAction) then
		gMessageManager:SendMessage(gEventConstants.REBIND_CLOSE_PANEL, RebindMode.Gamepad)
		gPanelManager:Close(gPanelId.SETTING_BTN_RESET_PANEL_CONTROLLER)
	else
		local centerCallback = function()
			local mapId = self.actionNameToInfo[firstEmptyAction].mapId
			self.classifySelected = self.actionMapIdToInfo[mapId].classify

			self.bindData.tabList:SetItemSelected(self.classifySelected - 1, true)
			self:OnRefreshButtons()

			for t = 1, #self.rebindGroupedData[self.classifySelected] do
				if self.rebindGroupedData[self.classifySelected][t].id ~= self.actionNameToInfo[firstEmptyAction].id then
					self.bindData.buttonList:GoToIndex(t - 1, true)

					break
				end
			end
		end

		local leftCallback = function()
			gMessageManager:SendMessage(gEventConstants.REBIND_CLOSE_PANEL)
			gPanelManager:Close(gPanelId.SETTING_BTN_RESET_PANEL_CONTROLLER)
		end

		gDisplayMessageMgr:ShowMessageTriple(MessageConfig.PCkeyResetEmpty, leftCallback, centerCallback, nil, self.actionNameToInfo[firstEmptyAction].name)
	end
end

M.OnClickResetBtn = function(self)
	slot1 = gDisplayMessageMgr

	slot1:ShowMessage(MessageConfig.ShezhiReset, function ()
		gCS.RebindMgr:RemoveAllOverrides(RebindMode.Gamepad)

		gameProfile.isCustomizeController = false

		ProfileManager.SaveGameProperty()
		self:SetRebindGroupedData()
		self:OnRefreshButtons()
	end, nil, LTConfig.TextScriptTextConfig.GetConfig(89901303).Text)
end

M.OnRenderCharacterTooltip = function(self, btn, widget)
	local store = gStoreManager:GetStoreGroup("SettingBtnResetCharacterList"):GetStoreByWidget(widget)

	if not store then
		return
	end

	local characterListGo = store.characterList

	characterListGo.SetSimpleList(characterListGo, #self.characterTabList)

	characterListGo.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderCharacterListItem")
end

M.OnSimpleRenderTabListItem = function(self, btn, index)
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

M.OnTabListSelectedChange = function(self)
	local index = self.bindData.tabList.selectedIndex
	self.classifySelected = index + 1

	if self.classifySelected ~= RebindActionConfig.ControllerCharacterClassfify then
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

M.OnGetButtonListTIndex = function(self, index)
	local data = self.rebindGroupedData[self.classifySelected][index + 1]

	if self.classifySelected ~= RebindActionConfig.ControllerCharacterClassfify then
		if not self.characterPageData then
			self.characterPageData = self.SetCharacterData(self)
		end

		data = self.characterPageData[index + 1]
	end

	if not data then
		return 0
	else
		return data.id ~= -1 and 0 or 1
	end
end

M.OnSimpleRenderButtonListItem = function(self, btn, index)
	local data = self.rebindGroupedData[self.classifySelected][index + 1]

	if self.classifySelected ~= RebindActionConfig.ControllerCharacterClassfify then
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
	self.bindData.imgCtrl = device ~= SGUI.GameDevice.PlayStation and 0 or 1
	local gameDeviceIndex = gCS.LuaUtils.GetActiveDevice() ~= SGUI.GameDevice.PlayStation and "ps" or "xbox"

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

		store.rebindButton.luaFocus = self.CreateActionWithArgs(self, "OnButtonSelectedChange", data)
	end

	if not table.isNilOrEmpty(data.exchangeList) then
		self.optionListMap[data.id] = {}

		for t = 1, #data.exchangeList do
			local curButtonPath = RebindActionIconConfig.GetConfig(data.exchangeList[t]).ButtonName
			local tView = {
				buttonPath = curButtonPath,
				iconId = self.buttonPathToIcon[curButtonPath][gameDeviceIndex],
				index = t,
				isSelect = false
			}

			table.insert(self.optionListMap[data.id], tView)
		end

		store.dropMenu:SetSimpleOptions(#self.optionListMap[data.id])

		store.dropMenu.luaRenderPopup = self:CreateActionWithArgs("OnDropMenuRenderPopup", data.id)
	end
end

M.OnDropMenuRenderPopup = function(self, actionId, popup, list)
	list.luaSimpleRenderItem = self.CreateAction(self, "OnRenderPopupListItem")
	self.curDropMenuActionId = actionId

	list.SetSimpleList(list, #self.optionListMap[actionId])

	list.luaSimpleClick = self.CreateActionWithArgs(self, "OnDropMenuOptionClicked", actionId)
end

M.OnRenderPopupListItem = function(self, btn, index)
	local data = self.optionListMap[self.curDropMenuActionId][index + 1]
	local store = gStoreManager:GetStoreGroup("DropMenuBtn"):GetStoreByWidget(btn)

	if store and data then
		local actionText = ""
		local useActions = gCS.RebindMgr:GetActionsByPath(data.buttonPath):ToTable()

		if not table.isNilOrEmpty(useActions) then
			for t = 1, #useActions do
				actionText = actionText .. useActions[t]

				if t == #useActions then
					actionText = actionText .. "/"
				end
			end
		end

		store.title = actionText
		store.iconId = data.iconId
	end
end

M.OnDropMenuOptionClicked = function(self, actionId, btn, index)
	local data = self.optionListMap[actionId][index + 1]

	if not data then
		return
	end

	local rebindRequest = RebindRequest.New(actionId, data.buttonPath, RebindStrategyType.Gamepad)

	gCS.RebindMgr:StartRebindNew(rebindRequest)
end

M.OnButtonSelectedChange = function(self, data)
	if not data then
		return
	end

	self.InitRightInfo(self, data)

	if not table.isNilOrEmpty(data.button) then
		local device = gCS.LuaUtils.GetActiveDevice()
		self.bindData.imgCtrl = device ~= SGUI.GameDevice.PlayStation and 0 or 1

		if data.isComposite then
			if data.button[1] ~= "<Gamepad>/buttonNorth" and data.button[2] ~= "<Gamepad>/buttonEast" then
				self.bindData.imgKeyCtrl = 16
			end
		elseif table.isNilOrEmpty(data.button) or not data.button[1] or not self.buttonPathToIcon[data.button[1]] then
			print_error("OnButtonSelectedChange", data.actionName)
		else
			self.bindData.imgKeyCtrl = self.buttonPathToIcon[data.button[1]].iconCtrl
		end
	end
end

M.OnSimpleRenderTemplateListItem = function(self, contentList, btn, index)
	local data = contentList[index + 1]

	if not data then
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
	end
end

M.OnGetTemplateListTIndex = function(self, contentList, index)
	local data = contentList[index + 1]

	if not data then
		return 0
	end

	return data.tIndex
end

M.OnCompleteRebindAction = function(self, eventId, data)
	self.OnRefreshButtons(self, self.actionNameToInfo[data].id)
end

M.OnConflictRebindAction = function(self, eventId, data)
	local rightCallBack = function()
		gMessageManager:SendMessage(gEventConstants.REBIND_CONFLICT_CONFIRM)
	end

	local mid = MessageConfig.PCkeyResetConflict
	local conflictText = ""
	local conflictActionNames = data[1]:ToTable()

	for t = 1, #conflictActionNames do
		conflictText = conflictText .. self.actionNameToInfo[conflictActionNames[t]].name

		if t == #conflictActionNames then
			conflictText = conflictText .. "/"
		end
	end

	gDisplayMessageMgr:ShowMessage(mid, rightCallBack, nil, conflictText, conflictText)
end

M.OnConflictOverwriteAction = function(self, eventId, data)
	self:OnRefreshButtons(self.actionNameToInfo[data[0]].id)

	local conflictActionNames = data[1]:ToTable()

	for t = 1, #conflictActionNames do
		self.OnRefreshButtons(self, self.actionNameToInfo[conflictActionNames[t]].id)
	end
end

M.OnSimpleRenderCharacterListItem = function(self, btn, index)
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
	store.imageBtn.luaClick = self.CreateActionWithArgs(self, "OnSimpleClickCharacterList", index)
end

M.OnSimpleClickCharacterList = function(self, index)
	self.characterSelected = self.characterTabList[index + 1]
	local fightSpirit = FightSpiritConfig.GetConfig(self.characterSelected)
	self.bindData.characterImage = fightSpirit.SHeadIconID
	self.bindData.characterName = fightSpirit.Name
	self.characterPageData = self:SetCharacterData()

	self.bindData.buttonList:SetSimpleList(#self.characterPageData)
	self.bindData.switchCharacterBtn:CloseTooltip()
end

M.OnRefreshTab = function(self, step)
	local nextStep = self.bindData.tabList.selectedIndex + step

	if nextStep >= 0 then
		nextStep = #self.tabList - 1
	elseif nextStep > #self.classifyList then
		nextStep = 0
	end

	self.bindData.tabList:SetItemSelected(nextStep, true)
end
