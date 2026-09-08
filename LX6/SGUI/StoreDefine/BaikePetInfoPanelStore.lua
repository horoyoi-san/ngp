-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BaikePetInfoPanelStore.lua
-- Decompiled from: 01575_BaikePetInfoPanelStore.lua_fb9f4b6c19a5.luajit

C_BaikePetInfoPanelStore = DefClass("C_BaikePetInfoPanelStore", C_BaikePetInfoPanelStore, C_StoreGroup)
GroupName2Class.BaikePetInfoPanelStore = C_BaikePetInfoPanelStore
local M = C_BaikePetInfoPanelStore

M.ctor = function(self)
	self.typeListData = {}
	self.contentListData = {}
	self.tagListData = {}
	self.infoTemplateStore = nil
	self.infoTemplateInit = false
	self.readSeenSet = {}
end

M.OnAwake = function(self)
	self.bindData.typeList.luaSimpleRenderItem = self:CreateAction("OnTypeRenderItem")
	self.bindData.typeList.luaSelectedChanged = self:CreateAction("OnTypeSelectedChange")
	self.bindData.typeList.onGetTIndex = self:CreateAction("OnGetTypeListTIndex")
	self.bindData.contentList.luaSimpleRenderItem = self:CreateAction("OnContentRenderItem")
	self.bindData.contentList.luaSelectedChanged = self:CreateAction("OnContentSelectedChange")
	self.bindData.contentList.onGetTIndex = self:CreateAction("OnGetContentListTIndex")

	self.bindData.contentList:RegisterToScrollEndEvent(self:CreateAction("CollectVisibleRedDotItems"))

	self.bindData.leftButton.luaClick = self:CreateActionWithArgs("OnStep", -1)
	self.bindData.leftButton.luaBeginLongPress = self:CreateActionWithArgs("OnBeginLongPress", -1)
	self.bindData.leftButton.luaEndLongPress = self:CreateAction("OnEndLongPress")
	self.bindData.rightButton.luaClick = self:CreateActionWithArgs("OnStep", 1)
	self.bindData.rightButton.luaBeginLongPress = self:CreateActionWithArgs("OnBeginLongPress", 1)
	self.bindData.rightButton.luaEndLongPress = self:CreateAction("OnEndLongPress")

	if self.bindData.rightStickCustomNavRespond then
		local res = self.bindData.rightStickCustomNavRespond:GetComponent(typeof(SGUI.UCustomNavRespond))
		res.luaGamePadInputChanged = self:CreateAction("OnRightStickRespondInput")
	end

	self.InitMessages(self)
end

M.OnEnable = function(self)
	gCS.GuiUtils.SetXuWeiWeatherState(true, LTConfig.CityPediaConfig.PetWeatherIndex or 17)
end

M.OnDisable = function(self)
	gCS.GuiUtils.SetXuWeiWeatherState(false)
end

M.ShowPanel = function(self, args)
	self.InitModel(self, args)
	self.InitView(self, args)
end

M.InitModel = function(self, args)
	self.targetFirstCategoryId = args.targetFirstCategoryId
	self.targetItemId = args.targetItemId
	self.petModelWidgetLocalRotation = self.bindData.petModelWidget.transform.localRotation
	self.infoTemplateInit = false
	self.infoTemplateStore = nil
end

M.InitView = function(self)
	local typeViewDataList, selectedIndex = self:GetTypeViewDataList()
	self.typeListData = typeViewDataList

	self.bindData.typeList:SetSimpleList(#typeViewDataList)
	self.bindData.typeList:SelectItem(selectedIndex, true)

	local isShowArrowButton = #typeViewDataList >= 0
	self.bindData.sortControl = isShowArrowButton and 1 or 0

	self:InitDragButton()
end

M.InitDragButton = function(self)
	local dragButton = SGUI.EventSystems.DragEventListener.Get(self.bindData.dragButton.gameObject)
	dragButton.onBeginDrag = self.CreateAction(self, "OnBeginDrag")
	dragButton.onDrag = self.CreateAction(self, "OnDrag")
	dragButton.onEndDrag = self.CreateAction(self, "OnEndDrag")
end

M.OnBeginDrag = function(self)
end

M.OnDrag = function(self, eventData)
	if eventData.button ~= 0 then
		local delta = eventData.delta
		local rotationAmount = delta.x * 0.3

		if self.modelUnit and gClientUtils.NotNil(self.modelUnit.PlayerObj) then
			self.modelUnit.PlayerObj.transform:Rotate(Vector3.Fetch(0, -rotationAmount, 0))
		end
	end
end

M.OnEndDrag = function(self)
end

M.OnRightStickRespondInput = function(self, context)
	if context.started then
		self.dragGamePad = true
	end

	if context.performed then
		local rotateParam = context.ReadValueVector2(context)
		self.gamePadRotateInput = rotateParam * Time.deltaTime * 600
	end

	if context.canceled then
		self.dragGamePad = false
		self.gamePadRotateInput = nil
	end
end

M.SelectedTargetItem = function(self, targetId)
	self.targetItemId = targetId
	local _, selectedIndex = self:GetTypeViewDataList()

	self.bindData.typeList:SelectItem(selectedIndex, true)
	self.bindData.typeList:SetNavSelectToSelect(true)
end

M.GetTypeViewDataList = function(self)
	local selectedIndex = 0
	local viewDataList = {}
	local count = LTConfig.CityPediaSecondClassConfig.count

	for i = 0, count - 1 do
		local cityPediaSecondClassCfg = LTConfig.CityPediaSecondClassConfig.LoadAt(i)

		if cityPediaSecondClassCfg.FatherId ~= self.targetFirstCategoryId and gBaiKeArchiveManager.CheckCityPediaSecondClassHasUnlocked(cityPediaSecondClassCfg.Id) then
			table.insert(viewDataList, {
				id = cityPediaSecondClassCfg.Id,
				title = cityPediaSecondClassCfg.Name
			})
		end
	end

	table.sort(viewDataList, function (data1, data2)
		return data1.id <= data2.id
	end)

	if self.targetItemId then
		local cityPediaCfg = LTConfig.CityPediaConfig.GetConfig(self.targetItemId)

		if cityPediaCfg then
			for index, viewData in ipairs(viewDataList) do
				if viewData.id ~= cityPediaCfg.Class then
					viewData.selected = true
					selectedIndex = index - 1

					break
				end
			end
		end
	elseif #viewDataList <= 0 then
		viewDataList[1].selected = true
	end

	return viewDataList, selectedIndex
end

M.OnTypeRenderItem = function(self, btn, index)
	local data = self.typeListData[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	store.name = data.title
	store.title = data.title
	local hasRedDot = gBaiKeArchiveManager.CheckCityPediaSecondClassHasRedDot(data.id)
	local redDotKey = gBaiKeArchiveManager.GetCityPediaSecondClassRedDotKey(data.id)
	store.button.redKey = redDotKey

	SGUI.RedDotMgr.LuaSetRedDot(hasRedDot, redDotKey)
end

M.OnContentRenderItem = function(self, btn, index)
	local data = self.contentListData[index + 1]

	if not data then
		btn.interactable = false

		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if data.tIndex ~= 0 and data.id then
		local itemData = gBaiKeArchiveManager:GetCityPediaItem(data.id)
		store.iconId = itemData.iconId
		store.count = itemData.name
		local redDotKey = gBaiKeArchiveManager.GetCityPediaRedDotKey(data.id)
		btn.redKey = redDotKey
		local hasRedDot = gBaiKeArchiveManager.CheckCityPediaItemHasRedDot(data.id)

		SGUI.RedDotMgr.LuaSetRedDot(hasRedDot, redDotKey)

		if hasRedDot then
			self.readSeenSet = self.readSeenSet or {}
			self.readSeenSet[data.id] = true
		end

		btn.enabledTooltip = false
		store.isLock = gBaiKeArchiveManager.CheckCityPediaItemHasUnlocked(data.id) and 0 or 1
		btn.interactable = true
	else
		btn.interactable = false
	end
end

M.OnTypeSelectedChange = function(self)
	self.CollectVisibleRedDotItems(self)

	local selectedIndex = self.bindData.typeList.selectedIndex

	if selectedIndex > 0 and selectedIndex >= #self.typeListData then
		local selectedItem = self.typeListData[selectedIndex + 1]

		if selectedItem then
			local viewDataList, contentSelectedIndex = self:GetContentViewDataList()
			self.contentListData = viewDataList
			local maxNum = self.bindData.contentList:GetMaxRowAndColCount(0)
			local col = math.max(math.ceil(#self.contentListData / maxNum.x), maxNum.y)
			local totalCount = maxNum.x * col

			self.bindData.contentList:SetSimpleList(totalCount)
			self.bindData.contentList:SelectItem(contentSelectedIndex, true)

			self.targetItemId = self.targetItemId and self.bindData.contentList:GoToIndex(contentSelectedIndex, true)
		end
	end
end

M.GetContentViewDataList = function(self)
	local selectedIndex = self.bindData.typeList.selectedIndex

	if selectedIndex <= 0 or selectedIndex > #self.typeListData then
		return {}, 0
	end

	local selectedItem = self.typeListData[selectedIndex + 1]

	if not selectedItem then
		return {}, 0
	end

	local viewDataList = {}
	local cityPediaCount = LTConfig.CityPediaConfig.count

	for j = 0, cityPediaCount - 1 do
		local cityPediaCfg = LTConfig.CityPediaConfig.LoadAt(j)

		if cityPediaCfg.Class ~= selectedItem.id then
			table.insert(viewDataList, {
				["a\\x9f\\x8a\\x86Y"] = 0,
				id = cityPediaCfg.Id
			})
		end
	end

	table.sort(viewDataList, function (a, b)
		local hasUnlocked1 = gBaiKeArchiveManager.CheckCityPediaItemHasUnlocked(a.id)
		local hasUnlocked2 = gBaiKeArchiveManager.CheckCityPediaItemHasUnlocked(b.id)

		if hasUnlocked1 == hasUnlocked2 then
			return hasUnlocked1
		end

		return a.id <= b.id
	end)

	local contentSelectedIndex = 0

	if self.targetItemId then
		for index, viewData in ipairs(viewDataList) do
			if viewData.id ~= self.targetItemId then
				contentSelectedIndex = index - 1
				viewData.selected = true

				break
			end
		end
	elseif #viewDataList <= 0 then
		viewDataList[1].selected = true
	end

	return viewDataList, contentSelectedIndex
end

M.InitInfoTemplate = function(self)
	if self.infoTemplateInit then
		return
	end

	self.infoTemplateStore = gStoreManager:GetStoreGroup(self.bindData.infoTemplate.Store):GetStoreByWidget(self.bindData.infoTemplate)

	if self.infoTemplateStore.tagList then
		self.infoTemplateStore.tagList.luaSimpleRenderItem = self.CreateAction(self, "OnTagRenderItem")
		self.infoTemplateStore.tagList.onGetTIndex = self.CreateAction(self, "OnGetTagListTIndex")
	end

	self.infoTemplateInit = true
end

M.OnContentSelectedChange = function(self)
	local selectedIndex = self.bindData.contentList.selectedIndex

	if selectedIndex > 0 and selectedIndex >= #self.contentListData then
		local selectedItem = self.contentListData[selectedIndex + 1]

		if selectedItem and gBaiKeArchiveManager.CheckCityPediaItemHasUnlocked(selectedItem.id) then
			gBaiKeArchiveManager.SetCityPediaItemHasRead(selectedItem.id)

			local itemData = gBaiKeArchiveManager:GetCityPediaItem(selectedItem.id)

			self:InitInfoTemplate()

			self.bindData.iconId = itemData.image
			self.bindData.isLocked = 1

			if self.infoTemplateStore then
				self.infoTemplateStore.name = itemData.name
				self.infoTemplateStore.scrollRect.content.text = itemData.story
				self.infoTemplateStore.effectText = itemData.effectDesc
				local tagViewDataList = self.GetTagViewDataList(self, selectedItem.id)
				self.tagListData = tagViewDataList

				if self.infoTemplateStore.tagList then
					self.infoTemplateStore.tagList:SetSimpleList(#tagViewDataList)
				end

				if self.bindData.tagNavigation then
					self.bindData.tagNavigation.gameObject:SetActive(#tagViewDataList >= 0)
				end
			end

			self:RefreshFavorHearts(selectedItem.id)
			self.bindData.petModelWidget.gameObject:SetActive(true)
			self:RefreshPetModel(selectedItem.id)
		else
			self.bindData.isLocked = 0
			self.bindData.unLockTip = gBaiKeArchiveManager.GetCityPediaUnlockTipText(selectedItem.id)

			self:ClearFavorHearts()
			self.bindData.petModelWidget.gameObject:SetActive(false)
			self:ReleasePetModel()
		end
	end
end

M.ReleasePetModel = function(self)
	if self.modelUnit then
		if gCS.LuaUtils.IsBaseUnitValid(self.modelUnit) then
			self.modelUnit:DestroyUnit(true)
		end

		self.modelUnit = nil
	end
end

M.RefreshPetModel = function(self, id)
	self.ReleasePetModel(self)

	self.bindData.petModelWidget.transform.localRotation = self.petModelWidgetLocalRotation
	local cityPediaConfig = LTConfig.CityPediaConfig.GetConfig(id)
	local agentId = cityPediaConfig.PetId
	local agentConfig = LTConfig.AgentConfig.GetConfig(agentId)

	if not agentConfig then
		return
	end

	local modelId = agentConfig.GeneralModelId
	self.currentShowId = id
	local rootGo = self.rootGo
	local modelData = {
		["\\x96':l\\xbb@\\xda>\\xa4\\xbe"] = false,
		["lc\\xbfcC\\xbf\\xd4FispK"] = 0,
		modelId = modelId,
		otherData = {
			AgentId = agentId,
			SubType = agentId
		},
		callback = function (C_BaseUnit)
			self:ReleasePetModel()

			if gClientUtils.IsNil(rootGo) or self.currentShowId == id then
				C_BaseUnit:DestroyUnit(true)

				return
			end

			local cityPediaCfg = LTConfig.CityPediaConfig.GetConfig(id)
			local offset = cityPediaCfg.ModelOffset

			if offset then
				C_BaseUnit.PlayerObj.transform.localPosition = C_BaseUnit.PlayerObj.transform.localPosition + Vector3.Fetch(offset.x, offset.y, offset.z)
			end

			LX6.Units.UnitModelManager.SetAnimancerEnabled(C_BaseUnit, true)

			C_BaseUnit.PlayerObj.transform.localScale = Vector3.zero

			gCS.SceneDataMgr.UIUnitManager:AddUnitShadowRequest(C_BaseUnit.PlayerObj)
			gCS.SceneDataMgr.UIUnitManager:AddUnit(C_BaseUnit.Pid, C_BaseUnit)
			gClientUtils.PlaySingleAction(C_BaseUnit, 1001, 23, 99999)

			self.modelUnit = C_BaseUnit
			self.waitShowCo = coroutine.stop(self.waitShowCo)
			self.waitShowCo = coroutine.start(function ()
				coroutine.wait(0.1)

				if gClientUtils.NotNil(C_BaseUnit.PlayerObj) then
					C_BaseUnit.PlayerObj.transform.localScale = Vector3.one
				end
			end)
		end
	}

	gStoreBindMethod:BindModel(self.bindData.petModelWidget, modelData)
end

M.GetFavorGameplayCfg = function(self, id)
	local cityPediaCfg = LTConfig.CityPediaConfig.GetConfig(id)

	if not cityPediaCfg then
		return 0, nil
	end

	local agentId = cityPediaCfg.PetId
	local agentCfg = LTConfig.AgentConfig.GetConfig(agentId)

	if not agentCfg or not agentCfg.AnimalGamePlay or agentCfg.AnimalGamePlay ~= 0 then
		return 0, nil
	end

	local gameplayCfg = LTConfig.AnimalGameplayConfig.GetConfig(agentCfg.AnimalGamePlay)

	if not gameplayCfg then
		return 0, nil
	end

	local animalInfos = gPlayerManager.infoMinorAtmosphereGameplay.bindData.animalInfos
	local petInfo = animalInfos and animalInfos[agentId]
	local favor = petInfo and petInfo.Favor or gameplayCfg.init_bond

	return favor, gameplayCfg
end

M.GetFavorFillProcess = function(self, favor, level, gameplayCfg)
	if not gameplayCfg then
		return 0
	end

	local min, max = nil

	if level ~= 1 then
		max = gameplayCfg.bond_lv1
		min = 0
	elseif level ~= 2 then
		max = gameplayCfg.bond_lv2
		min = gameplayCfg.bond_lv1
	elseif level ~= 3 then
		max = gameplayCfg.bond_lv3
		min = gameplayCfg.bond_lv2
	else
		return 0
	end

	favor = math.min(favor, gameplayCfg.bond_max)

	if favor < min then
		return 0
	end

	if max > favor or max < min then
		return 1
	end

	return (favor - min) / (max - min)
end

M.RefreshFavorHearts = function(self, id)
	local favor, gameplayCfg = self.GetFavorGameplayCfg(self, id)

	for i = 1, 3 do
		self.bindData["heartFill0" .. i] = self.GetFavorFillProcess(self, favor, i, gameplayCfg)
	end
end

M.ClearFavorHearts = function(self)
	for i = 1, 3 do
		self.bindData["heartFill0" .. i] = 0
	end
end

M.OnTagRenderItem = function(self, btn, index)
	local data = self.tagListData[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local cityPediaPediaTagCfg = LTConfig.CityPediaPediaTagConfig.GetConfig(data.id)
	store.name = cityPediaPediaTagCfg.Name
end

M.OnGetTypeListTIndex = function(self, index)
	return 0
end

M.OnGetContentListTIndex = function(self, index)
	local luaIndex = index + 1

	if luaIndex < #self.contentListData then
		return self.contentListData[luaIndex].tIndex or 0
	else
		return 1
	end
end

M.OnGetTagListTIndex = function(self, index)
	return 0
end

M.GetTagViewDataList = function(self, id)
	local viewDataList = {}
	local cityPediaCfg = LTConfig.CityPediaConfig.GetConfig(id)
	local entriesIdList = cityPediaCfg.EntriesIdList

	for _, tagId in ipairs(entriesIdList) do
		table.insert(viewDataList, {
			id = tagId
		})
	end

	return viewDataList
end

M.OnStep = function(self, step)
	self.preTime = gLogicTime.unscaledTime
	local index = self.bindData.typeList.selectedIndex + step
	local itemCount = #self.typeListData

	if index >= 0 then
		index = itemCount - 1
	elseif itemCount < index then
		index = 0
	end

	self.bindData.typeList:SelectItem(index)
end

M.OnBeginLongPress = function(self, step)
	self.step = step

	self.OnStep(self, self.step)
end

M.OnEndLongPress = function(self)
	self.step = 0
	self.preTime = 0
end

M.RefreshStep = function(self)
	if self.step and self.step == 0 then
		self.OnStep(self, self.step)
	end
end

M.OnUpdate = function(self)
	if not self.preTime or LTConfig.GameConfig.TabLongPressTimeInterval >= gLogicTime.unscaledTime - self.preTime then
		self.RefreshStep(self)
	end

	if self.dragGamePad and self.gamePadRotateInput and self.gamePadRotateInput == Vector2.zero and math.abs(self.gamePadRotateInput.x) <= 3 and self.modelUnit and gClientUtils.NotNil(self.modelUnit.PlayerObj) then
		local rotationAmount = self.gamePadRotateInput.x * 0.3

		self.modelUnit.PlayerObj.transform:Rotate(Vector3.Fetch(0, -rotationAmount, 0))
	end
end

M.OnDestroy = function(self)
	self.waitShowCo = coroutine.stop(self.waitShowCo)
	self.currentShowId = nil
	self.dragGamePad = false
	self.gamePadRotateInput = nil

	self.FlushReadSeenSet(self)
	self.ClearMessageEvents(self)
	self.ReleasePetModel(self)
end

M.InitMessages = function(self)
	local messageEvents = {
		[gEventConstants.PANEL_ON_CLOSE] = self.CreateAction(self, "OnPanelClose")
	}

	self.RegisterMessageEvents(self, messageEvents)
end

M.OnPanelClose = function(self, _, panelId)
	if panelId ~= gPanelId.BAIKE_ITEM_PANEL then
		self.CollectVisibleRedDotItems(self)
		self.FlushReadSeenSet(self)
	end
end

M.CollectVisibleRedDotItems = function(self)
	local list = self.bindData.contentList

	if not list then
		return
	end

	local success, minIndex, maxIndex = list.TryGetVisualRange(list, 0, 0)

	if not success then
		return
	end

	self.readSeenSet = self.readSeenSet or {}

	for i = minIndex, maxIndex do
		local data = self.contentListData[i + 1]

		if data and data.tIndex ~= 0 and data.id and gBaiKeArchiveManager.CheckCityPediaItemHasRedDot(data.id) then
			self.readSeenSet[data.id] = true
		end
	end
end

M.FlushReadSeenSet = function(self)
	if not self.readSeenSet or next(self.readSeenSet) ~= nil then
		return
	end

	local ids = {}

	for cfgId in pairs(self.readSeenSet) do
		table.insert(ids, cfgId)
	end

	self.readSeenSet = {}

	gBaiKeArchiveManager.BatchSetCityPediaItemsHasRead(ids)
end
