local RebindStrategyType = LX6.Manager.RebindStrategyType
local RebindRequest = LX6.Manager.RebindRequest
local MessageConfig = LTConfig.MessageConfig
local RebindActionConfig = LTConfig.RebindActionConfig
local RebindActionActionMapConfig = LTConfig.RebindActionActionMapConfig
local FightSpiritConfig = LTConfig.FightSpiritConfig
local ProfileManager = LX6.Engine.ProfileManager
local gameProfile = ProfileManager.gameProfile
local RebindMode = LX6.Manager.RebindMode
local InputKeyboardConfig = LTConfig.InputKeyboardConfig
C_SettingsBtnResetPanelStore = DefClass("C_SettingsBtnResetPanelStore", C_SettingsBtnResetPanelStore, C_StoreGroup)
GroupName2Class.SettingsBtnResetPanelStore = C_SettingsBtnResetPanelStore
local M = C_SettingsBtnResetPanelStore

function M:ctor()
	return
end

function M:DefineAllVariables()
	self.actionNameToInfo = {}
	self.actionMapIdToInfo = {}

	for i = 0, RebindActionConfig.count - 1 do
		local config = RebindActionConfig.LoadAt(i)

		if config then
			local realName = nil

			if string.is_null_or_empty(config.PartName) then
				realName = config.ActionName
			else
				realName = config.ActionName .. "_" .. config.PartName
			end

			self.actionNameToInfo[realName] = {
				id = config.Id,
				mapId = config.ActionMapId,
				name = config.Name,
				composite = config.IsComposite,
				canRebind = config.CanRebind
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

	self.keyPathToImage = {}

	self:InitKeyPathToImage()

	self.curKeyPathBindActions = {}
	self.OpenPanelAnim = "vx_S_SettingBtnResetPanel_open"
	self.LeftSwitchTabAnim = "vx_S_SettingBtnResetPanel_to_right"
	self.RightSwitchTabAnim = "vx_S_SettingBtnResetPanel_to_left"
	self.NoneRebindAnim = "vx_S_SettingTemplate_red"
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
	if data then
		self.classifyList = data.classify
		self.typeNameList = data.type
		self.buttonIconList = data.icon

		self:InitRebindActionData()
		self:SetCharacterInfo()

		self.classifySelected = 1
		self.bindData.isInputCtrl = 0

		self.bindData.tabList:SetSimpleList(#self.classifyList)
		self.bindData.tabList:SetItemSelected(0, true)

		if self.classifySelected == RebindActionConfig.CharacterClassfify then
			self.bindData.showCharacterCtrl = 1
			self.characterSelected = self:GetCurSpiritId()

			self:SetCurCharacterImage()

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

	gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnim, self.OpenPanelAnim)
end

function M:InitRightInfo()
	if self.hoverButtonInfo and self.classifySelected ~= self.hoverButtonInfo.curClassify then
		self.hoverButtonInfo = nil
	end

	local showInfo = self:GetShowInfo()

	if not showInfo then
		self.bindData.buttonTitle = ""
		self.bindData.buttonInfo = ""

		return
	end

	self.bindData.buttonTitle = showInfo.actionName
	self.bindData.isModifiedCtrl = (showInfo.isEmpty or showInfo.isRebind) and 1 or 0

	if self.bindData.isModifiedCtrl == 1 then
		self:SetInitKeyData(showInfo.id)
	end

	local bindActionNames = self:GetBindActionNames(showInfo)

	if table.isNilOrEmpty(bindActionNames) then
		self.bindData.buttonInfo = ""

		return
	end

	table.clear(self.curKeyPathBindActions)

	for _, name in ipairs(bindActionNames) do
		if name ~= self.bindData.buttonTitle then
			table.insert(self.curKeyPathBindActions, name)
		end
	end

	if table.isNilOrEmpty(self.curKeyPathBindActions) then
		self.bindData.buttonInfo = ""

		return
	end

	local buttonInfoText = table.concat(self.curKeyPathBindActions, "/")
	self.bindData.buttonInfo = gString.Format(LTConfig.TextScriptTextConfig.GetConfig(89901283).Text, buttonInfoText)
end

function M:GetShowInfo()
	if table.isNilOrEmpty(self.hoverButtonInfo) then
		local data = self.rebindGroupedData[self.classifySelected]

		if table.isNilOrEmpty(data) then
			return nil
		end

		local firstIndex = 1

		if data[firstIndex].id == -1 then
			firstIndex = firstIndex + 1
		end

		return data[firstIndex]
	else
		local classify = self.classifySelected
		local index = self.hoverButtonInfo.index

		if classify == RebindActionConfig.CharacterClassfify then
			return self.characterPageData[index]
		else
			return self.rebindGroupedData[classify][index]
		end
	end
end

function M:GetBindActionNames(showInfo)
	if table.isNilOrEmpty(showInfo.button) or showInfo.isComposite then
		return {}
	end

	return gCS.RebindMgr:GetActionsByPath(showInfo.button[1]):ToTable()
end

function M:SetInitKeyData(actionId)
	if not actionId then
		return
	end

	local actionName = RebindActionConfig.GetConfig(actionId).ActionName
	self.initData = gCS.RebindMgr:GetInitBindingsByName(actionId, RebindMode.Keyboard):ToTable()

	self.bindData.initList:SetSimpleList(#self.initData)
end

function M:SetCharacterInfo()
	local characterList = {}

	if not RebindActionConfig.CharacterClassfify or not self.rebindGroupedData[RebindActionConfig.CharacterClassfify] then
		return
	end

	local notShowId = self:GetNotShowCharacter()
	local data = self.rebindGroupedData[RebindActionConfig.CharacterClassfify]

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
		[gEventConstants.REBIND_OVERWRITE] = self:CreateAction("OnConflictOverwriteAction"),
		[gEventConstants.REBIND_GIVE_UP] = self:CreateAction("OnGiveUpRebind")
	}
end

function M:RegisterWidget()
	self.bindData.exitBindBtn.luaClick = self:CreateAction("OnClickExitBindBtn")
	self.bindData.closeBtn.luaClick = self:CreateAction("OnClickCloseBtn")
	self.bindData.switchCharacterBtn.luaRenderTooltip = self:CreateAction("OnRenderCharacterTooltip")
	self.bindData.switchCharacterBtn.luaTooltipPopup = self:CreateAction("OnCharacterTooltipPopup")
	self.bindData.resetBtn.luaClick = self:CreateAction("OnClickResetBtn")
	self.bindData.tabList.luaSimpleRenderItem = self:CreateAction("OnSimpleRenderTabListItem")
	self.bindData.tabList.luaSelectedChanged = self:CreateAction("OnSimpleClickTabList")
	self.bindData.buttonList.luaSimpleRenderItem = self:CreateAction("OnSimpleRenderButtonListItem")
	self.bindData.buttonList.onGetTIndex = self:CreateAction("OnGetButtonListTIndex")
	self.bindData.initList.luaSimpleRenderItem = self:CreateAction("OnSimpleRenderInitListItem")
	self.bindData.initList.onGetTIndex = self:CreateAction("OnGetInitListTIndex")
end

function M:OnRefreshButtons(optId)
	if optId then
		local config = RebindActionConfig.GetConfig(optId)
		local targetMapId = config.ActionMapId
		local targetClassify = self.actionMapIdToInfo[targetMapId].classify

		for i = 1, #self.rebindGroupedData[targetClassify] do
			if self.rebindGroupedData[targetClassify][i].id == optId then
				self.rebindGroupedData[targetClassify][i].button = gCS.RebindMgr:GetButtonNamesByActionId(optId, RebindMode.Keyboard, config.IsComposite):ToTable()
				self.rebindGroupedData[targetClassify][i].isRebind = gCS.RebindMgr:IsActionRebound(optId, RebindMode.Keyboard)
				self.rebindGroupedData[targetClassify][i].isEmpty = gCS.RebindMgr:IsActionEmpty(optId, RebindMode.Keyboard)

				break
			end
		end
	end

	self:SetCharacterInfo()

	if self.classifySelected == RebindActionConfig.CharacterClassfify then
		self.characterPageData = self:SetCharacterData()

		self.bindData.buttonList:SetSimpleList(#self.characterPageData)
	else
		self.characterPageData = nil

		self.bindData.buttonList:SetSimpleList(#self.rebindGroupedData[self.classifySelected])
	end

	if self.hoverButtonInfo and self.hoverButtonInfo.curClassify ~= self.classifySelected then
		self.hoverButtonInfo = nil
	end

	self.bindData.isInputCtrl = 0

	if self.hoverButtonInfo then
		self.bindData.cleanCtrl = 1
	end

	self.bindData.exitCtrl = 0

	self.bindData.buttonList:SetScrollDisabled(false)
	self:InitRightInfo()
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
			if data[t].actionName == self.typeNameList[21] then
				table.insert(pageData, 1, data[t])
			else
				table.insert(pageData, data[t])
			end
		end
	end

	return pageData
end

function M:OnClickCleanBtn(hoverButtonInfo)
	gCS.RebindMgr:RemoveOverrideAction(hoverButtonInfo.id, RebindMode.Keyboard)
	self:OnRefreshButtons(hoverButtonInfo.id)
end

function M:OnClickCloseBtn()
	self.firstEmptyAction = gCS.RebindMgr:HasEmptyAction(RebindMode.Keyboard)

	if string.is_null_or_empty(self.firstEmptyAction) then
		gMessageManager:SendMessage(gEventConstants.REBIND_CLOSE_PANEL, RebindMode.Keyboard)
		gPanelManager:Close(gPanelId.SETTING_BTN_RESET_PANEL)
	else
		local function centerCallback()
			local mapId = self.actionNameToInfo[self.firstEmptyAction].mapId
			self.classifySelected = self.actionMapIdToInfo[mapId].classify

			self.bindData.tabList:SetItemSelected(self.classifySelected - 1, true)
			self:SwitchToActionCharacter(self.firstEmptyAction)
			self:OnRefreshButtons()

			local targetPageData = self.rebindGroupedData[self.classifySelected]

			if self.classifySelected == RebindActionConfig.CharacterClassfify then
				targetPageData = self.characterPageData
			end

			for t = 1, #targetPageData do
				if targetPageData[t].id == self.actionNameToInfo[self.firstEmptyAction].id then
					self.bindData.buttonList:GoToIndex(t - 1, true)

					break
				end
			end

			self.firstEmptyAction = nil
		end

		gDisplayMessageMgr:ShowMessage(MessageConfig.PCkeyResetEmpty, centerCallback, nil, self.actionNameToInfo[self.firstEmptyAction].name)
	end
end

function M:OnClickResetBtn()
	gDisplayMessageMgr:ShowMessage(MessageConfig.ShezhiReset, function ()
		gCS.RebindMgr:RemoveAllOverrides(RebindMode.Keyboard)

		gameProfile.isCustomizeButton = false

		ProfileManager.SaveGameProperty()
		self:InitRebindActionData()
		self:OnRefreshButtons()
	end, nil, LTConfig.TextScriptTextConfig.GetConfig(89901303).Text)
end

function M:OnRenderCharacterTooltip(btn, widget)
	local store = gStoreManager:GetStoreGroup("SettingBtnResetCharacterList"):GetStoreByWidget(widget)

	if not store then
		return
	end

	self.bindData.hideCharacterCtrl = 1
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

function M:OnSimpleClickTabList(btn)
	if self.classifySelected < btn.selectedIndex + 1 then
		gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnim, self.RightSwitchTabAnim)
	else
		gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnim, self.LeftSwitchTabAnim)
	end

	self.classifySelected = btn.selectedIndex + 1

	if self.classifySelected == RebindActionConfig.CharacterClassfify then
		self.bindData.showCharacterCtrl = 1
		self.characterSelected = self:GetCurSpiritId()

		self:SetCurCharacterImage()

		self.characterPageData = self:SetCharacterData()

		self.bindData.buttonList:SetSimpleList(#self.characterPageData)
	else
		self.characterPageData = nil
		self.bindData.showCharacterCtrl = 0

		self.bindData.buttonList:SetSimpleList(#self.rebindGroupedData[self.classifySelected])
	end
end

function M:OnGetButtonListTIndex(index)
	local data = self.rebindGroupedData[self.classifySelected][index + 1]

	if self.classifySelected == RebindActionConfig.CharacterClassfify then
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

	if self.classifySelected == RebindActionConfig.CharacterClassfify then
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
	store.emptyCtrl = data.isEmpty and 1 or 0
	store.rebindCtrl = data.isRebind and not data.isEmpty and 1 or 0

	if not string.is_null_or_empty(self.firstEmptyAction) and self.actionNameToInfo[self.firstEmptyAction].id == data.id and store.noneAnim then
		gCS.LuaUtils.PlayAnimationByName(store.noneAnim, self.NoneRebindAnim)
	end

	local rebindButtons = {}

	if data.button then
		self:InitRightInfo()

		for k, buttonName in pairs(data.button) do
			if not string.is_null_or_empty(buttonName) and not table.isNilOrEmpty(self.keyPathToImage[buttonName]) then
				local buttonInfo = self.keyPathToImage[buttonName]

				if not string.is_null_or_empty(buttonInfo.text) then
					table.insert(rebindButtons, {
						tIndex = 4,
						buttonText = buttonInfo.text,
						buttonFont = SGUI.SDF.SDFAsyncFontAssetManager.GetFontAssetByName(buttonInfo.font)
					})
				elseif buttonInfo.icon ~= 0 then
					table.insert(rebindButtons, {
						tIndex = 2,
						iconId = buttonInfo.icon
					})
				end
			elseif not string.is_null_or_empty(buttonName) then
				local buttonPath = gCS.RebindMgr:ExtractKeyName(buttonName)

				if buttonPath then
					table.insert(rebindButtons, {
						tIndex = 4,
						buttonText = buttonPath
					})
				end
			end
		end

		store.templateList.luaSimpleRenderItem = self:CreateActionWithArgs("OnSimpleRenderTemplateListItem", rebindButtons)
		store.templateList.onGetTIndex = self:CreateActionWithArgs("OnGetTemplateListTIndex", rebindButtons)

		store.templateList:SetSimpleList(#rebindButtons)

		local curButtonHoverInfo = {
			id = data.id,
			name = data.actionName,
			buttonPath = data.button,
			btnGo = store.rebindBtn,
			btnList = store.templateList,
			isComposite = data.isComposite,
			showInitInfo = data.isRebind or data.isEmpty,
			templateButtonList = rebindButtons,
			curClassify = self.classifySelected,
			index = index + 1
		}
		store.rebindBtn.luaHover = self:CreateActionWithArgs("OnHoverRebindButton", curButtonHoverInfo)
		store.rebindBtn.luaUnhover = self:CreateAction("OnUnHoverRebindButton")
		store.rebindBtn.luaClick = self:CreateActionWithArgs("OnClickRebindButton", curButtonHoverInfo)
		store.rebindBtn.luaRightClick = self:CreateActionWithArgs("OnClickCleanBtn", curButtonHoverInfo)
		store.rebindBtn.interactable = data.canRebind
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

		if data.buttonFont then
			store.font = data.buttonFont
		end
	end
end

function M:OnGetTemplateListTIndex(contentList, index)
	local data = contentList[index + 1]

	if not data then
		return 0
	end

	return data.tIndex
end

function M:OnHoverRebindButton(buttonHoverInfo)
	self.hoverButtonInfo = buttonHoverInfo
	self.bindData.buttonTitle = buttonHoverInfo.name
	self.bindData.isModifiedCtrl = buttonHoverInfo.showInitInfo and 1 or 0

	if buttonHoverInfo.showInitInfo then
		self:SetInitKeyData(buttonHoverInfo.id)
	end

	self.bindData.cleanCtrl = self.curRebindBtn and 0 or 1

	if table.isNilOrEmpty(buttonHoverInfo.buttonPath) then
		self.bindData.buttonInfo = ""

		return
	end

	local bindActionNames = gCS.RebindMgr:GetActionsByPath(buttonHoverInfo.buttonPath[1]):ToTable()

	if table.isNilOrEmpty(bindActionNames) or buttonHoverInfo.isComposite then
		self.bindData.buttonInfo = ""

		return
	end

	table.clear(self.curKeyPathBindActions)

	for _, name in ipairs(bindActionNames) do
		if name ~= self.bindData.buttonTitle then
			table.insert(self.curKeyPathBindActions, name)
		end
	end

	if table.isNilOrEmpty(self.curKeyPathBindActions) then
		self.bindData.buttonInfo = ""

		return
	end

	local buttonInfoText = table.concat(self.curKeyPathBindActions, "/")
	self.bindData.buttonInfo = gString.Format(LTConfig.TextScriptTextConfig.GetConfig(89901283).Text, buttonInfoText)
end

function M:OnUnHoverRebindButton()
	self.hoverButtonInfo = nil
	self.bindData.cleanCtrl = 0
end

function M:OnClickRebindButton(info)
	info.btnGo:SetSelected(true)
	self.bindData.buttonList:SetScrollDisabled(true)
	info.btnList:SetSimpleList(0)

	self.curRebindBtn = info
	local rebindRequest = RebindRequest.New(info.id, 0, RebindStrategyType.Single)
	self.bindData.cleanCtrl = 0
	self.bindData.isInputCtrl = 1
	self.bindData.exitCtrl = 1

	gCS.RebindMgr:StartRebindNew(rebindRequest)
end

function M:OnCompleteRebindAction(eventId, data)
	self.curRebindBtn.btnGo:SetSelected(false)

	self.curRebindBtn = nil

	self:OnRefreshButtons(self.actionNameToInfo[data].id)
end

function M:OnConflictRebindAction(eventId, data)
	local conflictActionNames = data[1]:ToTable()
	local conflictText = ""

	for t = 1, #conflictActionNames do
		if not self.actionNameToInfo[conflictActionNames[t]] then
			print_error("@xuchenfei [SettingsBtnResetPanelStore][OnConflictRebindAction]Action Need Delete", conflictActionNames[t])
		else
			if not self.actionNameToInfo[conflictActionNames[t]].canRebind then
				gDisplayMessageMgr:ShowMessageContent(LTConfig.TextScriptTextConfig.GetConfig(89901300).Text)
				self.curRebindBtn.btnGo:SetSelected(false)

				self.curRebindBtn = nil

				self:OnRefreshButtons()

				return
			end

			conflictText = conflictText .. self.actionNameToInfo[conflictActionNames[t]].name

			if t ~= #conflictActionNames then
				conflictText = conflictText .. "/"
			end
		end
	end

	local function rightCallBack()
		gMessageManager:SendMessage(gEventConstants.REBIND_CONFLICT_CONFIRM)
	end

	local function leftCallBack()
		self.curRebindBtn.btnGo:SetSelected(false)

		self.curRebindBtn = nil

		self:OnRefreshButtons()
	end

	local mid = MessageConfig.PCkeyResetConflict

	gDisplayMessageMgr:ShowMessage(mid, rightCallBack, leftCallBack, conflictText, conflictText)
end

function M:OnConflictOverwriteAction(eventId, data)
	self.curRebindBtn.btnGo:SetSelected(false)

	self.curRebindBtn = nil

	self:OnRefreshButtons(self.actionNameToInfo[data[0]].id)

	local conflictActionNames = data[1]:ToTable()

	for t = 1, #conflictActionNames do
		self:OnRefreshButtons(self.actionNameToInfo[conflictActionNames[t]].id)
	end
end

function M:OnGiveUpRebind(eventId, data)
	self.curRebindBtn.btnGo:SetSelected(false)
	self.curRebindBtn.btnList:SetSimpleList(#self.curRebindBtn.templateButtonList)

	self.curRebindBtn = nil
	self.bindData.exitCtrl = 0
	self.bindData.cleanCtrl = self.hoverButtonInfo and 1 or 0
	self.bindData.isInputCtrl = 0

	self.bindData.buttonList:SetScrollDisabled(false)
end

function M:OnCharacterTooltipPopup(btn, popup, index)
	if not popup then
		self.bindData.hideCharacterCtrl = 0
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

	self:SetCurCharacterImage()

	self.characterPageData = self:SetCharacterData()

	self.bindData.buttonList:SetSimpleList(#self.characterPageData)
	self.bindData.switchCharacterBtn:CloseTooltip()

	self.bindData.hideCharacterCtrl = 0
end

function M:OnSimpleRenderInitListItem(btn, index)
	local data = self.initData[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local showInfo = gCS.RebindMgr:ExtractKeyName(data)

	if self.buttonIconList[showInfo] then
		store.icon = self.buttonIconList[showInfo]
	else
		store.text = showInfo
	end
end

function M:OnGetInitListTIndex(index)
	local data = self.initData[index + 1]

	if not data then
		return 0
	end

	local buttonPath = gCS.RebindMgr:ExtractKeyName(data)

	if not string.is_null_or_empty(buttonPath) then
		if self.buttonIconList[buttonPath] then
			return 2
		else
			return 4
		end
	else
		return 0
	end
end

function M:InitRebindActionData()
	self.rebindGroupedData = {}
	local tempMapData = {}

	for i = 0, RebindActionConfig.count - 1 do
		local config = RebindActionConfig.LoadAt(i)

		if config then
			local actionMapId = config.ActionMapId

			if not tempMapData[actionMapId] then
				tempMapData[actionMapId] = {}
			end

			table.insert(tempMapData[actionMapId], {
				id = config.Id,
				actionName = config.Name,
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
end

function M:InitKeyPathToImage()
	for i = 0, InputKeyboardConfig.count - 1 do
		local config = InputKeyboardConfig.LoadAt(i)

		if config then
			local keyPath = config.ButtonName
			self.keyPathToImage[keyPath] = {
				icon = config.RebindIcon,
				text = config.RebindText,
				font = config.KeyFont
			}
		end
	end
end

function M:GetCurSpiritId()
	local characterSelected = gSpiritManager:GetCurFirstSpiritTid()

	if not table.contains(self.characterTabList, characterSelected) then
		local sexType = gPlayerManager.infoLogin.bindData.sexType
		characterSelected = sexType == 1 and LTConfig.FightSpiritConfig.DefaultMale or LTConfig.FightSpiritConfig.DefaultFemale
	end

	return characterSelected
end

function M:SwitchToActionCharacter(actionName)
	local actionId = self.actionNameToInfo[actionName].id
	local spiritIds = RebindActionConfig.GetConfig(actionId).FightSpiritId

	if table.isNilOrEmpty(spiritIds) then
		return
	end

	local notShowSpiritId = self:GetNotShowCharacter()

	for i = 1, #spiritIds do
		if spiritIds[i] ~= notShowSpiritId then
			self.characterSelected = spiritIds[i]

			self:SetCurCharacterImage()

			return
		end
	end
end

function M:GetNotShowCharacter()
	local sexType = gPlayerManager.infoLogin.bindData.sexType

	if sexType == 1 then
		return LTConfig.FightSpiritConfig.DefaultFemale
	elseif sexType == 2 then
		return LTConfig.FightSpiritConfig.DefaultMale
	end
end

function M:SetCurCharacterImage()
	local fightSpirit = FightSpiritConfig.GetConfig(self.characterSelected)

	if not fightSpirit then
		print_error("[[SettingsBtnResetPanelStore] CurFightSpirit Is Null, Check!", self.characterSelected)
	end

	self.bindData.characterImage = fightSpirit.SHeadIconID
	self.bindData.characterName = fightSpirit.Name
end
