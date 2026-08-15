C_BaikePetInfoPanelStore = DefClass("C_BaikePetInfoPanelStore", C_BaikePetInfoPanelStore, C_StoreGroup)
GroupName2Class.BaikePetInfoPanelStore = C_BaikePetInfoPanelStore
local M = C_BaikePetInfoPanelStore

function M:ctor()
	self.typeListData = {}
	self.contentListData = {}
	self.tagListData = {}
	self.textTagListData = {}
end

function M:OnAwake()
	self.bindData.typeList.luaSimpleRenderItem = self:CreateAction("OnTypeRenderItem")
	self.bindData.typeList.luaSelectedChanged = self:CreateAction("OnTypeSelectedChange")
	self.bindData.typeList.onGetTIndex = self:CreateAction("OnGetTypeListTIndex")
	self.bindData.contentList.luaSimpleRenderItem = self:CreateAction("OnContentRenderItem")
	self.bindData.contentList.luaSelectedChanged = self:CreateAction("OnContentSelectedChange")
	self.bindData.contentList.onGetTIndex = self:CreateAction("OnGetContentListTIndex")
	self.bindData.tagList.luaSimpleRenderItem = self:CreateAction("OnTagRenderItem")
	self.bindData.tagList.luaSimpleClick = self:CreateAction("OnTagItemClick")
	self.bindData.tagList.onGetTIndex = self:CreateAction("OnGetTagListTIndex")
	self.bindData.textTagList.luaSimpleRenderItem = self:CreateAction("OnTextTagRenderItem")
	self.bindData.textTagList.onGetTIndex = self:CreateAction("OnGetTextTagListTIndex")
	self.bindData.leftButton.luaClick = self:CreateActionWithArgs("OnStep", -1)
	self.bindData.leftButton.luaBeginLongPress = self:CreateActionWithArgs("OnBeginLongPress", -1)
	self.bindData.leftButton.luaEndLongPress = self:CreateAction("OnEndLongPress")
	self.bindData.rightButton.luaClick = self:CreateActionWithArgs("OnStep", 1)
	self.bindData.rightButton.luaBeginLongPress = self:CreateActionWithArgs("OnBeginLongPress", 1)
	self.bindData.rightButton.luaEndLongPress = self:CreateAction("OnEndLongPress")
end

function M:OnEnable()
	gCS.GuiUtils.SetXuWeiWeatherState(true, LTConfig.CityPediaConfig.PetWeatherIndex or 17)
end

function M:OnDisable()
	gCS.GuiUtils.SetXuWeiWeatherState(false)
end

function M:ShowPanel(args)
	self:InitModel(args)
	self:InitView(args)
end

function M:InitModel(args)
	self.targetFirstCategoryId = args.targetFirstCategoryId
	self.targetItemId = args.targetItemId
	self.petModelWidgetLocalRotation = self.bindData.petModelWidget.transform.localRotation
end

function M:InitView()
	local typeViewDataList, selectedIndex = self:GetTypeViewDataList()
	self.typeListData = typeViewDataList

	self.bindData.typeList:SetSimpleList(#typeViewDataList)
	self.bindData.typeList:SelectItem(selectedIndex, true)

	local isShowArrowButton = #typeViewDataList > 0
	self.bindData.sortControl = isShowArrowButton and 1 or 0
	local current, total = gBaiKeArchiveManager.GetCityPediaFisrtClassPorgress(self.targetFirstCategoryId)
	self.bindData.current = current
	self.bindData.total = total

	self:InitDragButton()
end

function M:InitDragButton()
	local dragButton = SGUI.EventSystems.DragEventListener.Get(self.bindData.dragButton.gameObject)
	dragButton.onBeginDrag = self:CreateAction("OnBeginDrag")
	dragButton.onDrag = self:CreateAction("OnDrag")
	dragButton.onEndDrag = self:CreateAction("OnEndDrag")
end

function M:OnBeginDrag()
	return
end

function M:OnDrag(eventData)
	if eventData.button == 0 then
		local delta = eventData.delta
		local rotationAmount = delta.x * 0.3

		self.bindData.petModelWidget.transform:Rotate(Vector3.Fetch(0, -rotationAmount, 0))
	end
end

function M:OnEndDrag()
	return
end

function M:SelectedTargetItem(targetId)
	self.targetItemId = targetId
	local _, selectedIndex = self:GetTypeViewDataList()

	self.bindData.typeList:SelectItem(selectedIndex, true)
end

function M:GetTypeViewDataList()
	local selectedIndex = 0
	local viewDataList = {}
	local count = LTConfig.CityPediaSecondClassConfig.count
	local countryMap = {}

	for i = 0, count - 1 do
		local cityPediaSecondClassCfg = LTConfig.CityPediaSecondClassConfig.LoadAt(i)

		if cityPediaSecondClassCfg.FatherId == self.targetFirstCategoryId and gBaiKeArchiveManager.CheckCityPediaSecondClassHasUnlocked(cityPediaSecondClassCfg.Id) then
			countryMap[cityPediaSecondClassCfg.Country] = cityPediaSecondClassCfg.Id
		end
	end

	for countryId, cityPediaSecondClassId in pairs(countryMap) do
		table.insert(viewDataList, {
			countryId = countryId,
			cityPediaSecondClassId = cityPediaSecondClassId
		})
	end

	table.sort(viewDataList, function (data1, data2)
		return data1.countryId < data2.countryId
	end)

	if self.targetItemId then
		local cityPediaCfg = LTConfig.CityPediaConfig.GetConfig(self.targetItemId)
		local cityPediaSecondClassCfg = LTConfig.CityPediaSecondClassConfig.GetConfig(cityPediaCfg.Class)

		for index, viewData in ipairs(viewDataList) do
			if viewData.countryId == cityPediaSecondClassCfg.Country then
				viewData.selected = true
				selectedIndex = index - 1

				break
			end
		end
	elseif #viewDataList > 0 then
		viewDataList[1].selected = true
	end

	return viewDataList, selectedIndex
end

function M:OnTypeRenderItem(btn, index)
	local data = self.typeListData[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local collectionCountryCfg = LTConfig.CollectionCountryConfig.GetConfig(data.countryId)
	store.name = collectionCountryCfg.Name
	local hasRedDot = gBaiKeArchiveManager.CheckCityPediaSecondClassHasRedDot(data.cityPediaSecondClassId)
	local redDotKey = gBaiKeArchiveManager.GetCityPediaSecondClassRedDotKey(data.cityPediaSecondClassId)
	store.button.redKey = redDotKey

	SGUI.RedDotMgr.LuaSetRedDot(hasRedDot, redDotKey)
end

function M:OnContentRenderItem(btn, index)
	local data = self.contentListData[index + 1]

	if not data then
		btn.interactable = false

		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if data.tIndex == 0 then
		local cityPediaSecondClassCfg = LTConfig.CityPediaSecondClassConfig.GetConfig(data.id)
		store.title = cityPediaSecondClassCfg.Name
		btn.interactable = true
	elseif data.tIndex == 1 and data.id then
		local cityPeiaCfg = LTConfig.CityPediaConfig.GetConfig(data.id)
		store.iconId = cityPeiaCfg.Image
		store.count = cityPeiaCfg.Name
		local redDotKey = gBaiKeArchiveManager.GetCityPediaRedDotKey(data.id)
		store.button.redKey = redDotKey
		local hasRedDot = gBaiKeArchiveManager.CheckCityPediaItemHasRedDot(data.id)

		SGUI.RedDotMgr.LuaSetRedDot(hasRedDot, redDotKey)

		store.button.enabledTooltip = false
		store.isLock = gBaiKeArchiveManager.CheckCityPediaItemHasUnlocked(data.id) and 0 or 1
		btn.interactable = true
	else
		btn.interactable = false
	end
end

function M:OnTypeSelectedChange()
	local selectedIndex = self.bindData.typeList.selectedIndex

	if selectedIndex >= 0 and selectedIndex < #self.typeListData then
		local selectedItem = self.typeListData[selectedIndex + 1]

		if selectedItem then
			local viewDataList, contentSelectedIndex = self:GetContentViewDataList()
			self.contentListData = viewDataList
			local maxNum = self.bindData.contentList:GetMaxRowAndColCount(1)
			local col = math.max(math.ceil(#self.contentListData / maxNum.x), maxNum.y)
			local totalCount = maxNum.x * col + 1

			self.bindData.contentList:SetSimpleList(totalCount)
			self.bindData.contentList:SelectItem(contentSelectedIndex, true)

			self.targetItemId = self.targetItemId and self.bindData.contentList:GoToIndex(contentSelectedIndex, true)
		end
	end
end

function M:GetContentViewDataList()
	local selectedIndex = self.bindData.typeList.selectedIndex

	if selectedIndex < 0 or selectedIndex >= #self.typeListData then
		return {}, 0
	end

	local selectedItem = self.typeListData[selectedIndex + 1]

	if not selectedItem then
		return {}, 0
	end

	local viewDataList = {}
	local count = LTConfig.CityPediaSecondClassConfig.count

	for i = 0, count - 1 do
		local cityPediaSecondClassConfig = LTConfig.CityPediaSecondClassConfig.LoadAt(i)

		if cityPediaSecondClassConfig.FatherId == self.targetFirstCategoryId and cityPediaSecondClassConfig.Country == selectedItem.countryId then
			table.insert(viewDataList, {
				tIndex = 0,
				id = cityPediaSecondClassConfig.Id
			})

			local cityPediaCount = LTConfig.CityPediaConfig.count
			local childViewDataList = {}

			for j = 0, cityPediaCount - 1 do
				local cityPediaCfg = LTConfig.CityPediaConfig.LoadAt(j)

				if cityPediaCfg.Class == cityPediaSecondClassConfig.Id then
					table.insert(childViewDataList, {
						tIndex = 1,
						id = cityPediaCfg.Id
					})
				end
			end

			table.sort(childViewDataList, function (a, b)
				local hasUnlocked1 = gBaiKeArchiveManager.CheckCityPediaItemHasUnlocked(a.id)
				local hasUnlocked2 = gBaiKeArchiveManager.CheckCityPediaItemHasUnlocked(b.id)

				if hasUnlocked1 ~= hasUnlocked2 then
					return hasUnlocked1
				end

				return a.id < b.id
			end)

			for _, childViewData in ipairs(childViewDataList) do
				table.insert(viewDataList, childViewData)
			end
		end
	end

	local selectedIndex = 0

	if self.targetItemId then
		for index, viewData in ipairs(viewDataList) do
			if viewData.id == self.targetItemId then
				selectedIndex = index - 1
				viewData.selected = true

				break
			end
		end
	else
		for index, viewData in ipairs(viewDataList) do
			if viewData.tIndex == 1 then
				selectedIndex = index - 1
				viewData.selected = true

				break
			end
		end
	end

	return viewDataList, selectedIndex
end

function M:OnContentSelectedChange()
	local selectedIndex = self.bindData.contentList.selectedIndex

	if selectedIndex >= 0 and selectedIndex < #self.contentListData then
		local selectedItem = self.contentListData[selectedIndex + 1]

		if selectedItem and gBaiKeArchiveManager.CheckCityPediaItemHasUnlocked(selectedItem.id) then
			gBaiKeArchiveManager.SetCityPediaItemHasRead(selectedItem.id)

			local cityPediaCfg = LTConfig.CityPediaConfig.GetConfig(selectedItem.id)
			self.bindData.name = cityPediaCfg.Name
			self.bindData.iconId = cityPediaCfg.Image
			self.bindData.description = cityPediaCfg.Story
			self.bindData.effectDescription = cityPediaCfg.Des
			self.bindData.isLocked = 1
			local tagViewDataList = self:GetTagViewDataList(selectedItem.id)
			self.tagListData = tagViewDataList

			self.bindData.tagList:SetSimpleList(#tagViewDataList)

			local textTagViewDataList = self:GetTextTagViewDataList(selectedItem.id)
			self.textTagListData = textTagViewDataList

			self.bindData.textTagList:SetSimpleList(#textTagViewDataList)

			if self.bindData.tagNavigation then
				self.bindData.tagNavigation.gameObject:SetActive(#tagViewDataList > 0)
			end

			local favorLevel = self:GetFavorLevel(selectedItem.id)
			self.bindData.favorLevel = favorLevel

			self.bindData.petModelWidget.gameObject:SetActive(true)
			self:RefreshPetModel(selectedItem.id)
		else
			self.bindData.isLocked = 0

			self.bindData.petModelWidget.gameObject:SetActive(false)
			self:ReleasePetModel()
		end
	end
end

function M:ReleasePetModel()
	if self.modelUnit then
		self.modelUnit:DestroyUnit(true)

		self.modelUnit = nil
	end
end

function M:RefreshPetModel(id)
	self:ReleasePetModel()

	self.bindData.petModelWidget.transform.localRotation = self.petModelWidgetLocalRotation
	local cityPediaConfig = LTConfig.CityPediaConfig.GetConfig(id)
	local petAnimalCfg = LTConfig.PetAnimalConfig.GetConfig(cityPediaConfig.PetId)
	local agentId = petAnimalCfg.AgentId
	local agentConfig = LTConfig.AgentConfig.GetConfig(agentId)
	local modelId = agentConfig.GeneralModelId
	self.currentShowId = id
	local rootGo = self.rootGo
	local modelData = {
		isSetFacing = false,
		customFacing = 0,
		modelId = modelId,
		otherData = {
			AgentId = agentId,
			SubType = agentId
		},
		callback = function (C_BaseUnit)
			self:ReleasePetModel()

			if gClientUtils.IsNil(rootGo) or self.currentShowId ~= id then
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

function M:GetFavorLevel(id)
	local cityPediaCfg = LTConfig.CityPediaConfig.GetConfig(id)
	local petId = cityPediaCfg.PetId
	local petInfo = gPlayerManager.infoMinorAtmosphereGameplay.bindData.animalInfos[petId]

	if petInfo then
		local currentFavor = petInfo.Favor
		local petAnimalCfg = LTConfig.PetAnimalConfig.GetConfig(petId)

		if currentFavor == 0 then
			return 0
		end

		if currentFavor < petAnimalCfg.Lv1 then
			return 1
		end

		if currentFavor == petAnimalCfg.Lv1 then
			return 2
		end

		if currentFavor < petAnimalCfg.Lv2 then
			return 3
		end

		if currentFavor == petAnimalCfg.Lv2 then
			return 4
		end

		if currentFavor < petAnimalCfg.Lv3 then
			return 5
		end

		if petAnimalCfg.Lv3 <= currentFavor then
			return 6
		end
	else
		return 0
	end
end

function M:OnTagRenderItem(btn, index)
	local data = self.tagListData[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local cityPediaPediaTagCfg = LTConfig.CityPediaPediaTagConfig.GetConfig(data.id)
	store.name = cityPediaPediaTagCfg.Name
end

function M:OnTagItemClick(btn, index)
	local data = self.tagListData[index + 1]

	if not data then
		return
	end

	local cityPediaPediaTagCfg = LTConfig.CityPediaPediaTagConfig.GetConfig(data.id)

	gMessageManager:SendMessage(gEventConstants.ON_BAIKE_TAG_SELECTED, cityPediaPediaTagCfg.CityPediaId)
end

function M:OnTextTagRenderItem(btn, index)
	local data = self.textTagListData[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local cityPediaPediaTagCfg = LTConfig.CityPediaPediaTagConfig.GetConfig(data.id)
	store.name = cityPediaPediaTagCfg.Name
end

function M:OnGetTypeListTIndex(index)
	return 0
end

function M:OnGetContentListTIndex(index)
	local luaIndex = index + 1

	if luaIndex <= #self.contentListData then
		return self.contentListData[luaIndex].tIndex or 0
	else
		return 2
	end
end

function M:OnGetTagListTIndex(index)
	return 0
end

function M:OnGetTextTagListTIndex(index)
	return 0
end

function M:GetTagViewDataList(id)
	local viewDataList = {}
	local cityPediaCfg = LTConfig.CityPediaConfig.GetConfig(id)
	local entriesIdList = cityPediaCfg.EntriesIdList

	for _, tagId in ipairs(entriesIdList) do
		local cityPediaPediaTagCfg = LTConfig.CityPediaPediaTagConfig.GetConfig(tagId)

		if cityPediaPediaTagCfg.CityPediaId > 0 then
			table.insert(viewDataList, {
				id = tagId
			})
		end
	end

	return viewDataList
end

function M:GetTextTagViewDataList(id)
	local viewDataList = {}
	local cityPediaCfg = LTConfig.CityPediaConfig.GetConfig(id)
	local entriesIdList = cityPediaCfg.EntriesIdList

	for _, tagId in ipairs(entriesIdList) do
		local cityPediaPediaTagCfg = LTConfig.CityPediaPediaTagConfig.GetConfig(tagId)

		if cityPediaPediaTagCfg.CityPediaId == 0 then
			table.insert(viewDataList, {
				id = tagId
			})
		end
	end

	return viewDataList
end

function M:OnStep(step)
	self.preTime = gLogicTime.unscaledTime
	local index = self.bindData.typeList.selectedIndex + step
	local itemCount = #self.typeListData

	if index < 0 then
		index = itemCount - 1
	elseif itemCount <= index then
		index = 0
	end

	self.bindData.typeList:SelectItem(index)
end

function M:OnBeginLongPress(step)
	self.step = step

	self:OnStep(self.step)
end

function M:OnEndLongPress()
	self.step = 0
	self.preTime = 0
end

function M:RefreshStep()
	if self.step and self.step ~= 0 then
		self:OnStep(self.step)
	end
end

function M:OnUpdate()
	if not self.preTime or LTConfig.GameConfig.TabLongPressTimeInterval < gLogicTime.unscaledTime - self.preTime then
		self:RefreshStep()
	end
end

function M:OnDestroy()
	self.waitShowCo = coroutine.stop(self.waitShowCo)
	self.currentShowId = nil

	self:ClearMessageEvents()
	self:ReleasePetModel()
end
