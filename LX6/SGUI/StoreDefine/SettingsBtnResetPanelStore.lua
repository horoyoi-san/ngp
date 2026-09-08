-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\SettingsBtnResetPanelStore.lua
-- Decompiled from: 00886_SettingsBtnResetPanelStore.lua_2ec22b56b2bd.luajit

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

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
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

	self.InitKeyPathToImage(self)

	self.curKeyPathBindActions = {}
	self.OpenPanelAnim = "vx_S_SettingBtnResetPanel_open"
	self.LeftSwitchTabAnim = "vx_S_SettingBtnResetPanel_to_right"
	self.RightSwitchTabAnim = "vx_S_SettingBtnResetPanel_to_left"
	self.NoneRebindAnim = "vx_S_SettingTemplate_red"
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

	self.actionNameToInfo = nil
	self.actionMapIdToInfo = nil
	self.keyPathToImage = nil
	self.curKeyPathBindActions = nil
end

M.OnShow = function(self, panelId, data)
	self.classifyList = gRebindActionManager:GetPCClassifyList()
	self.typeNameList = gRebindActionManager:GetPCTypeNameList()

	self:InitRebindActionData()
	self:SetCharacterInfo()

	self.classifySelected = 1
	self.bindData.isInputCtrl = 0

	self.bindData.tabList:SetSimpleList(#self.classifyList)
	self.bindData.tabList:SetItemSelected(0, true)

	if self.classifySelected ~= RebindActionConfig.CharacterClassfify then
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

	gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnim, self.OpenPanelAnim)
end

M.InitRightInfo = function(self)
	if self.hoverButtonInfo and self.classifySelected == self.hoverButtonInfo.curClassify then
		self.hoverButtonInfo = nil
	end

	local showInfo = self.GetShowInfo(self)

	if not showInfo then
		self.bindData.buttonTitle = ""
		self.bindData.buttonInfo = ""

		return
	end

	self.bindData.buttonTitle = showInfo.actionName
	self.bindData.isModifiedCtrl = (showInfo.isEmpty or showInfo.isRebind) and 1 or 0

	if self.bindData.isModifiedCtrl ~= 1 then
		self.SetInitKeyData(self, showInfo.id)
	end

	local bindActionNames = self.GetBindActionNames(self, showInfo)

	if table.isNilOrEmpty(bindActionNames) then
		self.bindData.buttonInfo = ""

		return
	end

	table.clear(self.curKeyPathBindActions)

	for _, name in ipairs(bindActionNames) do
		if name == self.bindData.buttonTitle then
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

M.GetShowInfo = function(self)
	if table.isNilOrEmpty(self.hoverButtonInfo) then
		local data = self.rebindGroupedData[self.classifySelected]

		if table.isNilOrEmpty(data) then
			return nil
		end

		local firstIndex = 1

		if data[firstIndex].id ~= -1 then
			firstIndex = firstIndex + 1
		end

		return data[firstIndex]
	else
		local classify = self.classifySelected
		local index = self.hoverButtonInfo.index

		if classify ~= RebindActionConfig.CharacterClassfify then
			return self.characterPageData[index]
		else
			return self.rebindGroupedData[classify][index]
		end
	end
end

M.GetBindActionNames = function(self, showInfo)
	if table.isNilOrEmpty(showInfo.button) or showInfo.isComposite then
		return {}
	end

	return gCS.RebindMgr:GetActionsByPath(showInfo.button[1]):ToTable()
end

M.SetInitKeyData = function(self, actionId)
	if not actionId then
		return
	end

	local config = RebindActionConfig.GetConfig(actionId)
	local rawInitData = gCS.RebindMgr:GetInitBindingsByName(actionId, RebindMode.Keyboard):ToTable()

	if config.IsComposite then
		self.initData = {}

		for k, path in ipairs(rawInitData) do
			if k <= 1 and not string.is_null_or_empty(path) and #self.initData <= 0 then
				table.insert(self.initData, "+")
			end

			if not string.is_null_or_empty(path) then
				table.insert(self.initData, path)
			end
		end
	else
		self.initData = rawInitData
	end

	self.bindData.initList:SetSimpleList(#self.initData)
end

M.SetCharacterInfo = function(self)
	local characterList = {}

	if not RebindActionConfig.CharacterClassfify or not self.rebindGroupedData[RebindActionConfig.CharacterClassfify] then
		return
	end

	local notShowId = self.GetNotShowCharacter(self)
	local data = self.rebindGroupedData[RebindActionConfig.CharacterClassfify]

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

M.OnClose = function(self)
	self.classifyList = nil
	self.typeNameList = nil
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.REBIND_COMPLETE] = self.CreateAction(self, "OnCompleteRebindAction"),
		[gEventConstants.REBIND_CONFLICT] = self.CreateAction(self, "OnConflictRebindAction"),
		[gEventConstants.REBIND_OVERWRITE] = self.CreateAction(self, "OnConflictOverwriteAction"),
		[gEventConstants.REBIND_GIVE_UP] = self.CreateAction(self, "OnGiveUpRebind")
	}
end

M.RegisterWidget = function(self)
	self.bindData.exitBindBtn.luaClick = self.CreateAction(self, "OnClickExitBindBtn")
	self.bindData.closeBtn.luaClick = self.CreateAction(self, "OnClickCloseBtn")
	self.bindData.switchCharacterBtn.luaRenderTooltip = self.CreateAction(self, "OnRenderCharacterTooltip")
	self.bindData.switchCharacterBtn.luaTooltipPopup = self.CreateAction(self, "OnCharacterTooltipPopup")
	self.bindData.resetBtn.luaClick = self.CreateAction(self, "OnClickResetBtn")
	self.bindData.tabList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderTabListItem")
	self.bindData.tabList.luaSelectedChanged = self.CreateAction(self, "OnSimpleClickTabList")
	self.bindData.buttonList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderButtonListItem")
	self.bindData.buttonList.onGetTIndex = self.CreateAction(self, "OnGetButtonListTIndex")
	self.bindData.initList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderInitListItem")
	self.bindData.initList.onGetTIndex = self.CreateAction(self, "OnGetInitListTIndex")
end

M.OnRefreshButtons = function(self, optId)
	if optId then
		local config = RebindActionConfig.GetConfig(optId)
		local targetMapId = config.ActionMapId
		local targetClassify = self.actionMapIdToInfo[targetMapId].classify

		for i = 1, #self.rebindGroupedData[targetClassify] do
			if self.rebindGroupedData[targetClassify][i].id ~= optId then
				self.rebindGroupedData[targetClassify][i].button = gCS.RebindMgr:GetButtonNamesByActionId(optId, RebindMode.Keyboard, config.IsComposite):ToTable()
				self.rebindGroupedData[targetClassify][i].isRebind = gCS.RebindMgr:IsActionRebound(optId, RebindMode.Keyboard)
				self.rebindGroupedData[targetClassify][i].isEmpty = gCS.RebindMgr:IsActionEmpty(optId, RebindMode.Keyboard)

				break
			end
		end
	end

	self.SetCharacterInfo(self)

	if self.classifySelected ~= RebindActionConfig.CharacterClassfify then
		self.characterPageData = self:SetCharacterData()

		self.bindData.buttonList:SetSimpleList(#self.characterPageData)
	else
		self.characterPageData = nil

		self.bindData.buttonList:SetSimpleList(#self.rebindGroupedData[self.classifySelected])
	end

	if self.hoverButtonInfo and self.hoverButtonInfo.curClassify == self.classifySelected then
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

M.SetCharacterData = function(self)
	local pageData = {}
	local data = self.rebindGroupedData[self.classifySelected]
	local chrData = self.characterList[self.characterSelected]

	for t = 1, #chrData do
		table.insert(pageData, chrData[t])
	end

	for t = 1, #data do
		if table.isNilOrEmpty(data[t].character) then
			if data[t].actionName ~= self.typeNameList[21] then
				table.insert(pageData, 1, data[t])
			else
				table.insert(pageData, data[t])
			end
		end
	end

	return pageData
end

M.OnClickCleanBtn = function(self, hoverButtonInfo)
	gCS.RebindMgr:RemoveOverrideAction(hoverButtonInfo.id, RebindMode.Keyboard)
	self:OnRefreshButtons(hoverButtonInfo.id)
end

M.OnClickCloseBtn = function(self)
	self.firstEmptyAction = gCS.RebindMgr:HasEmptyAction(RebindMode.Keyboard)

	if string.is_null_or_empty(self.firstEmptyAction) then
		gMessageManager:SendMessage(gEventConstants.REBIND_CLOSE_PANEL, RebindMode.Keyboard)
		gPanelManager:Close(gPanelId.SETTING_BTN_RESET_PANEL)
	else
		local centerCallback = function()
			local mapId = self.actionNameToInfo[self.firstEmptyAction].mapId
			self.classifySelected = self.actionMapIdToInfo[mapId].classify

			self.bindData.tabList:SetItemSelected(self.classifySelected - 1, true)
			self:SwitchToActionCharacter(self.firstEmptyAction)
			self:OnRefreshButtons()

			local targetPageData = self.rebindGroupedData[self.classifySelected]

			if self.classifySelected ~= RebindActionConfig.CharacterClassfify then
				targetPageData = self.characterPageData
			end

			for t = 1, #targetPageData do
				if targetPageData[t].id ~= self.actionNameToInfo[self.firstEmptyAction].id then
					self.bindData.buttonList:GoToIndex(t - 1, true)

					break
				end
			end

			self.firstEmptyAction = nil
		end

		gDisplayMessageMgr:ShowMessage(MessageConfig.PCkeyResetEmpty, centerCallback, nil, self.actionNameToInfo[self.firstEmptyAction].name)
	end
end

M.OnClickResetBtn = function(self)
	slot1 = gDisplayMessageMgr

	slot1:ShowMessage(MessageConfig.ShezhiReset, function ()
		gCS.RebindMgr:RemoveAllOverrides(RebindMode.Keyboard)

		gameProfile.isCustomizeButton = false

		ProfileManager.SaveGameProperty()
		self:InitRebindActionData()
		self:OnRefreshButtons()
	end, nil, LTConfig.TextScriptTextConfig.GetConfig(89901303).Text)
end

M.OnRenderCharacterTooltip = function(self, btn, widget)
	local store = gStoreManager:GetStoreGroup("SettingBtnResetCharacterList"):GetStoreByWidget(widget)

	if not store then
		return
	end

	self.bindData.hideCharacterCtrl = 1
	local characterListGo = store.characterList
	characterListGo.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderCharacterListItem")

	characterListGo.SetSimpleList(characterListGo, #self.characterTabList)
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

M.OnSimpleClickTabList = function(self, btn)
	if self.classifySelected >= btn.selectedIndex + 1 then
		gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnim, self.RightSwitchTabAnim)
	else
		gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnim, self.LeftSwitchTabAnim)
	end

	self.classifySelected = btn.selectedIndex + 1

	if self.classifySelected ~= RebindActionConfig.CharacterClassfify then
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

	self.bindData.buttonList:GoToIndex(0, true)
end

M.OnGetButtonListTIndex = function(self, index)
	local data = self.rebindGroupedData[self.classifySelected][index + 1]

	if self.classifySelected ~= RebindActionConfig.CharacterClassfify then
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

	if self.classifySelected ~= RebindActionConfig.CharacterClassfify then
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

	if not string.is_null_or_empty(self.firstEmptyAction) and self.actionNameToInfo[self.firstEmptyAction].id ~= data.id and store.noneAnim then
		gCS.LuaUtils.PlayAnimationByName(store.noneAnim, self.NoneRebindAnim)
	end

	local rebindButtons = {}

	if data.button then
		self.InitRightInfo(self)

		for k, buttonName in pairs(data.button) do
			if data.isComposite and k <= 1 and not string.is_null_or_empty(buttonName) and #rebindButtons <= 0 then
				table.insert(rebindButtons, {
					["a\\x9f\\x8a\\x86Y"] = 5
				})
			end

			if not string.is_null_or_empty(buttonName) and not table.isNilOrEmpty(self.keyPathToImage[buttonName]) then
				local buttonInfo = self.keyPathToImage[buttonName]

				if not string.is_null_or_empty(buttonInfo.text) then
					table.insert(rebindButtons, {
						["a\\x9f\\x8a\\x86Y"] = 4,
						buttonText = buttonInfo.text,
						buttonFont = SGUI.SDF.SDFAsyncFontAssetManager.GetFontAssetByName(buttonInfo.font)
					})
				elseif buttonInfo.icon == 0 then
					table.insert(rebindButtons, {
						["a\\x9f\\x8a\\x86Y"] = 2,
						iconId = buttonInfo.icon
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

M.OnSimpleRenderTemplateListItem = function(self, contentList, btn, index)
	local data = contentList[index + 1]

	if not data then
		return
	end

	if data.tIndex ~= 5 then
		return
	end

	if not btn.Store then
		return
	end

	local storeGroup = gStoreManager:GetStoreGroup(btn.Store)

	if not storeGroup then
		return
	end

	local store = storeGroup.GetStoreByWidget(storeGroup, btn)

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

M.OnHoverRebindButton = function(self, buttonHoverInfo)
	self.hoverButtonInfo = buttonHoverInfo
	self.bindData.buttonTitle = buttonHoverInfo.name
	self.bindData.isModifiedCtrl = buttonHoverInfo.showInitInfo and 1 or 0

	if buttonHoverInfo.showInitInfo then
		self.SetInitKeyData(self, buttonHoverInfo.id)
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
		if name == self.bindData.buttonTitle then
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

M.OnUnHoverRebindButton = function(self)
	self.hoverButtonInfo = nil
	self.bindData.cleanCtrl = 0
end

M.OnClickRebindButton = function(self, info)
	info.btnGo:SetSelected(true)
	self.bindData.buttonList:SetScrollDisabled(true)
	info.btnList:SetSimpleList(0)

	self.curRebindBtn = info
	local strategyType = info.isComposite and RebindStrategyType.Composite or RebindStrategyType.Single
	local rebindRequest = RebindRequest.New(info.id, 0, strategyType)
	self.bindData.cleanCtrl = 0
	self.bindData.isInputCtrl = 1
	self.bindData.exitCtrl = 1

	gCS.RebindMgr:StartRebindNew(rebindRequest)
end

M.OnCompleteRebindAction = function(self, eventId, data)
	self.curRebindBtn.btnGo:SetSelected(false)

	self.curRebindBtn = nil

	self:OnRefreshButtons(self.actionNameToInfo[data].id)
end

M.OnConflictRebindAction = function(self, eventId, data)
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

			if t == #conflictActionNames then
				conflictText = conflictText .. "/"
			end
		end
	end

	local rightCallBack = function()
		gMessageManager:SendMessage(gEventConstants.REBIND_CONFLICT_CONFIRM)
	end

	local leftCallBack = function()
		self.curRebindBtn.btnGo:SetSelected(false)

		self.curRebindBtn = nil

		self:OnRefreshButtons()
	end

	local mid = MessageConfig.PCkeyResetConflict

	gDisplayMessageMgr:ShowMessage(mid, rightCallBack, leftCallBack, conflictText, conflictText)
end

M.OnConflictOverwriteAction = function(self, eventId, data)
	self.curRebindBtn.btnGo:SetSelected(false)

	self.curRebindBtn = nil

	self:OnRefreshButtons(self.actionNameToInfo[data[0]].id)

	local conflictActionNames = data[1]:ToTable()

	for t = 1, #conflictActionNames do
		self.OnRefreshButtons(self, self.actionNameToInfo[conflictActionNames[t]].id)
	end
end

M.OnGiveUpRebind = function(self, eventId, data, isForbid)
	if isForbid then
		gDisplayMessageMgr:ShowMessageContent(LTConfig.TextScriptTextConfig.GetConfig(89901300).Text)
	end

	self.curRebindBtn.btnGo:SetSelected(false)
	self.curRebindBtn.btnList:SetSimpleList(#self.curRebindBtn.templateButtonList)

	self.curRebindBtn = nil
	self.bindData.exitCtrl = 0
	self.bindData.cleanCtrl = self.hoverButtonInfo and 1 or 0
	self.bindData.isInputCtrl = 0

	self.bindData.buttonList:SetScrollDisabled(false)
end

M.OnCharacterTooltipPopup = function(self, btn, popup, index)
	if not popup then
		self.bindData.hideCharacterCtrl = 0
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

	self:SetCurCharacterImage()

	self.characterPageData = self:SetCharacterData()

	self.bindData.buttonList:SetSimpleList(#self.characterPageData)
	self.bindData.switchCharacterBtn:CloseTooltip()

	self.bindData.hideCharacterCtrl = 0
end

M.OnSimpleRenderInitListItem = function(self, btn, index)
	local data = self.initData[index + 1]

	if not data then
		return
	end

	if data ~= "+" then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	if self.keyPathToImage[data] and self.keyPathToImage[data].icon == 0 then
		store.icon = self.keyPathToImage[data].icon
	else
		store.text = self.keyPathToImage[data].text
	end
end

M.OnGetInitListTIndex = function(self, index)
	local data = self.initData[index + 1]

	if not data then
		return 0
	end

	if data ~= "+" then
		return 5
	end

	if self.keyPathToImage[data] then
		if self.keyPathToImage[data].icon == 0 then
			return 2
		else
			return 4
		end
	else
		return 0
	end
end

M.InitRebindActionData = function(self)
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
end

M.InitKeyPathToImage = function(self)
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

M.GetCurSpiritId = function(self)
	local characterSelected = gSpiritManager:GetCurFirstSpiritTid()

	if not table.contains(self.characterTabList, characterSelected) then
		local sexType = gPlayerManager.infoLogin.bindData.sexType
		characterSelected = sexType ~= 1 and LTConfig.FightSpiritConfig.DefaultMale or LTConfig.FightSpiritConfig.DefaultFemale
	end

	return characterSelected
end

M.SwitchToActionCharacter = function(self, actionName)
	local actionId = self.actionNameToInfo[actionName].id
	local spiritIds = RebindActionConfig.GetConfig(actionId).FightSpiritId

	if table.isNilOrEmpty(spiritIds) then
		return
	end

	local notShowSpiritId = self.GetNotShowCharacter(self)

	for i = 1, #spiritIds do
		if spiritIds[i] == notShowSpiritId then
			self.characterSelected = spiritIds[i]

			self.SetCurCharacterImage(self)

			return
		end
	end
end

M.GetNotShowCharacter = function(self)
	local sexType = gPlayerManager.infoLogin.bindData.sexType

	if sexType ~= 1 then
		return LTConfig.FightSpiritConfig.DefaultFemale
	elseif sexType ~= 2 then
		return LTConfig.FightSpiritConfig.DefaultMale
	end
end

M.SetCurCharacterImage = function(self)
	local fightSpirit = FightSpiritConfig.GetConfig(self.characterSelected)

	if not fightSpirit then
		print_error("[[SettingsBtnResetPanelStore] CurFightSpirit Is Null, Check!", self.characterSelected)
	end

	self.bindData.characterImage = fightSpirit.SHeadIconID
	self.bindData.characterName = fightSpirit.Name
end
