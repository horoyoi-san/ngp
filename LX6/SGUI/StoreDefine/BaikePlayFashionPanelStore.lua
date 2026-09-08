-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BaikePlayFashionPanelStore.lua
-- Decompiled from: 01576_BaikePlayFashionPanelStore.lua_42b41c5d21b3.luajit

local CityPediaConfig = LTConfig.CityPediaConfig
C_BaikePlayFashionPanelStore = DefClass("C_BaikePlayFashionPanelStore", C_BaikePlayFashionPanelStore, C_StoreGroup)
GroupName2Class.BaikePlayFashionPanelStore = C_BaikePlayFashionPanelStore
local M = C_BaikePlayFashionPanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.fashionTemplateStore = nil
	self.rewardListData = {}
	self.rewardBtnList = {}
	self.currentTypeCtrl = 0
	self.currentCategoryType = nil
	self.tabListData = {}
	self.typePointListData = {}
	self.CATEGORY_TYPE = {
		["\\xff\\xfa'57\\xdf"] = 1,
		["\\xef\\xfe<4=\\xd4"] = 2
	}
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
	self.InitRedDot(self)
	self.InitRedDotRender(self)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
	if self.redDotAction then
		SGUI.RedDotMgr.onRenderRedDot = SGUI.RedDotMgr.onRenderRedDot - self.redDotAction
	end
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	self.InitFashionTemplate(self)
	self.RefreshFashionTemplateData(self)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.InitFashionTemplate = function(self)
	self.fashionTemplateStore = gStoreManager:GetStoreGroup(self.bindData.fashionTemplate.Store):GetStoreByWidget(self.bindData.fashionTemplate)
	local collectionValueTab = CityPediaConfig.CollectionValueTab
	self.fashionTemplateStore.cate1Text = collectionValueTab[1]
	self.fashionTemplateStore.cate2Text = collectionValueTab[2]
	self.fashionTemplateStore.category1Btn.luaClick = self:CreateAction("OnClickCategory1")
	self.fashionTemplateStore.category2Btn.luaClick = self:CreateAction("OnClickCategory2")

	if self.fashionTemplateStore.gamepadCategoryBtn then
		self.fashionTemplateStore.gamepadCategoryBtn.luaClick = self.CreateAction(self, "OnClickGamepadCategory")
	end

	self.fashionTemplateStore.gamepadCategoryBtn1.luaClick = self.CreateAction(self, "OnClickGamepadCategory")
	self.fashionTemplateStore.gamepadCategoryBtn2.luaClick = self.CreateAction(self, "OnClickGamepadCategory")
	self.fashionTemplateStore.rewardList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderRewardItem")
	self.fashionTemplateStore.rewardList.luaSelectedChanged = self.CreateAction(self, "OnRewardItemSelectedChanged")
	self.fashionTemplateStore.rewardList.luaSimpleClick = self.CreateAction(self, "OnClickRewardList")
	self.fashionTemplateStore.rewardList.poolMode = SGUI.EPoolMode.Default

	if self.fashionTemplateStore.tabList then
		self.fashionTemplateStore.tabList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderTabList")
		self.fashionTemplateStore.tabList.luaSimpleClick = self.CreateAction(self, "OnClickTabList")
	end

	if self.fashionTemplateStore.typePointList then
		self.fashionTemplateStore.typePointList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderTypePointList")
	end

	local playerFashionHead = self.fashionTemplateStore.playerFashionHead
	local playerFashionHeadStore = gStoreManager:GetStoreGroup(playerFashionHead.Store):GetStoreByWidget(playerFashionHead)
	local currentCredit = gBaiKeArchiveManager.GetCityPediaCredit()
	local currentLevel = gBaiKeArchiveManager.GetCityPediaCreditLevel()
	local nextLevelCfg = LTConfig.CityPediaCollectionLevelConfig.GetConfig(currentLevel + 1)
	local nextLevelPoint = nextLevelCfg and nextLevelCfg.value or currentCredit
	playerFashionHeadStore.fillPercent = currentCredit / nextLevelPoint
	local _, path = gImageManager:GetHeadIconByHeadIconInfo(gPlayerManager.infoLogin.bindData.infoPzHeadInfo, gPlayerManager.infoLogin.bindData.sexType, true)
	local cfg = LTConfig.ImageNewAvatarConfig.GetConfig(path)
	playerFashionHeadStore.headIcon = (cfg or LTConfig.ImageNewAvatarConfig.GetConfig(LTConfig.ImageNewAvatarConfig.AdultMH)).SguiImageId
	self.currentTypeCtrl = 0
	self.fashionTemplateStore.category1Btn.isSelected = true
	self.fashionTemplateStore.category2Btn.isSelected = false

	self:RefreshTypeCtrl()
end

M.RefreshFashionTemplateData = function(self)
	local currentCredit = gBaiKeArchiveManager.GetCityPediaCredit()
	local currentLevel = gBaiKeArchiveManager.GetCityPediaCreditLevel()
	local nextLevelCfg = LTConfig.CityPediaCollectionLevelConfig.GetConfig(currentLevel + 1)
	local nextLevelPoint = nextLevelCfg and nextLevelCfg.value or currentCredit
	self.fashionTemplateStore.minePoint = tostring(currentCredit)
	self.fashionTemplateStore.totalPoint = tostring(nextLevelPoint)
	self.fashionTemplateStore.playerName = gPlayerManager.infoLogin.bindData.name or ""
	self.fashionTemplateStore.levelText = "V" .. currentLevel

	self:RefreshRewardList()
end

M.RefreshRewardList = function(self)
	self.rewardListData = {}
	local currentCredit = gBaiKeArchiveManager.GetCityPediaCredit()
	local count = LTConfig.CityPediaCollectionLevelConfig.count

	for i = 0, count - 1 do
		local levelCfg = LTConfig.CityPediaCollectionLevelConfig.LoadAt(i)

		if levelCfg then
			local rewardItems = gCommonItemManager:ConvertDropToFakeItem(levelCfg.DropId, 1)
			local isClaimed = gBaiKeArchiveManager.CheckRewardClaimed(levelCfg.Id)
			local canClaim = levelCfg.value < currentCredit and not isClaimed

			table.insert(self.rewardListData, {
				level = levelCfg.Id,
				credit = levelCfg.value,
				dropId = levelCfg.DropId,
				rewards = rewardItems,
				isClaimed = isClaimed,
				canClaim = canClaim
			})
		end
	end

	self.lastReachedRewardIndex = -1

	for i = #self.rewardListData, 1, -1 do
		local data = self.rewardListData[i]

		if data.isClaimed or data.canClaim then
			self.lastReachedRewardIndex = i

			break
		end
	end

	self.fashionTemplateStore.rewardList:SetSimpleList(#self.rewardListData)
	self.fashionTemplateStore.rewardList:SelectItem(0, true)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.ON_BAIKE_CREDIT_INFO_CHANGE] = self.CreateAction(self, "OnCreditInfoChange")
	}
end

M.OnCreditInfoChange = function(self)
	self.RefreshFashionTemplateData(self)
	self.RefreshRedDot(self)
end

M.RegisterWidget = function(self)
	self.bindData.baseButton.luaClick = self.CreateAction(self, "OnClickBaseButton")
end

M.OnClickBaseButton = function(self)
	gUIUtils:PlayAniClosePanel(self.bindData.anim, "S_Vx_PlayFashionPanel_close", gPanelId.PLAY_FASHION_PANEL)
end

M.OnClickCategory1 = function(self)
	self.currentTypeCtrl = 0

	self.RefreshTypeCtrl(self)

	self.fashionTemplateStore.category1Btn.isSelected = true
	self.fashionTemplateStore.category2Btn.isSelected = false
end

M.OnClickCategory2 = function(self)
	self.currentTypeCtrl = 1

	self.RefreshTypeCtrl(self)

	self.fashionTemplateStore.category1Btn.isSelected = false
	self.fashionTemplateStore.category2Btn.isSelected = true
end

M.OnClickGamepadCategory = function(self)
	if self.currentTypeCtrl ~= 0 then
		self.currentTypeCtrl = 1
		self.fashionTemplateStore.category1Btn.isSelected = false
		self.fashionTemplateStore.category2Btn.isSelected = true
	else
		self.currentTypeCtrl = 0
		self.fashionTemplateStore.category1Btn.isSelected = true
		self.fashionTemplateStore.category2Btn.isSelected = false
	end

	self.RefreshTypeCtrl(self)
end

M.RefreshTypeCtrl = function(self)
	if not self.fashionTemplateStore then
		return
	end

	self.fashionTemplateStore.typeCtrl = self.currentTypeCtrl

	if self.currentTypeCtrl ~= 0 then
		self.RefreshRewardList(self)
	else
		self.InitTabList(self)

		if self.fashionTemplateStore.tabList then
			self.fashionTemplateStore.tabList:SetSimpleList(#self.tabListData)

			if #self.tabListData <= 0 then
				local firstCategory = self.tabListData[1].categoryType

				if not self.currentCategoryType then
					self.currentCategoryType = firstCategory
				end

				self.fashionTemplateStore.tabList:SelectItem(0, true)
				self:SwitchToCategoryType(self.currentCategoryType or firstCategory)
			end
		end
	end
end

M.InitTabList = function(self)
	local valueSourceTab = CityPediaConfig.ValueSourceTab
	self.tabListData = {
		{
			categoryType = self.CATEGORY_TYPE.FASHION,
			iconId = valueSourceTab[1].iconId,
			name = valueSourceTab[1].name
		},
		{
			categoryType = self.CATEGORY_TYPE.VEHICLE,
			iconId = valueSourceTab[2].iconId,
			name = valueSourceTab[2].name
		}
	}
end

M.SwitchToCategoryType = function(self, categoryType)
	self.currentCategoryType = categoryType

	if not self.fashionTemplateStore then
		return
	end

	local categoryName = ""

	for _, tabData in ipairs(self.tabListData) do
		if tabData.categoryType ~= categoryType then
			categoryName = tabData.name

			break
		end
	end

	if categoryType ~= self.CATEGORY_TYPE.FASHION then
		self.fashionTemplateStore.typeText = categoryName
		local totalScore, categoryData = self.CalculateFashionCategoryData(self)
		self.fashionTemplateStore.typePointText = tostring(totalScore)
		self.typePointListData = categoryData
	elseif categoryType ~= self.CATEGORY_TYPE.VEHICLE then
		self.fashionTemplateStore.typeText = categoryName
		local totalScore, categoryData = self.CalculateVehicleCategoryData(self)
		self.fashionTemplateStore.typePointText = tostring(totalScore)
		self.typePointListData = categoryData
	end

	if self.fashionTemplateStore.typePointList then
		self.fashionTemplateStore.typePointList:SetSimpleList(#self.typePointListData)
	end
end

M.CalculateFashionCategoryData = function(self)
	local partToScore = {}
	local totalScore = 0
	local fashionCount = LTConfig.FashionConfig.count

	for i = 0, fashionCount - 1 do
		local fashionCfg = LTConfig.FashionConfig.LoadAt(i)

		if fashionCfg and fashionCfg.ShowInPedia and fashionCfg.BelongBrand and fashionCfg.BelongBrand <= 0 and fashionCfg.Part then
			local isOwned = gDressManager:IsFashionHad(fashionCfg.Id)

			if isOwned then
				local score = gBaiKeArchiveManager.CalculateFashionScore(fashionCfg.Id) or 0
				local partType = fashionCfg.Part

				if not partToScore[partType] then
					partToScore[partType] = 0
				end

				partToScore[partType] = partToScore[partType] + score
				totalScore = totalScore + score
			end
		end
	end

	local FashionChangeTabIcon = LTConfig.FashionConfig.FashionChangeTabIcon
	local partToIconId = {}

	for i = 1, #FashionChangeTabIcon do
		local iconData = FashionChangeTabIcon[i]

		if iconData then
			partToIconId[iconData.part] = iconData.IconId
		end
	end

	local FashionChangeTabName = LTConfig.FashionConfig.FashionChangeTabName
	local partToName = {}

	for i = 1, #FashionChangeTabName do
		local nameData = FashionChangeTabName[i]

		if nameData then
			partToName[nameData.type] = nameData.Name
		end
	end

	local categoryData = {}

	for partType, score in pairs(partToScore) do
		table.insert(categoryData, {
			partType = partType,
			score = score,
			iconId = partToIconId[partType] or 0,
			name = partToName[partType]
		})
	end

	table.sort(categoryData, function (a, b)
		return a.partType <= b.partType
	end)

	return totalScore, categoryData
end

M.CalculateVehicleCategoryData = function(self)
	local vehicleTypeToScore = {}
	local vehicleTypeSet = {}
	local totalScore = 0
	local vehicleCount = LTConfig.VehicleConfig.count

	for i = 0, vehicleCount - 1 do
		local vehicleCfg = LTConfig.VehicleConfig.LoadAt(i)

		if vehicleCfg and vehicleCfg.ShowInPedia and vehicleCfg.Brand and vehicleCfg.Brand <= 0 and vehicleCfg.VehicleType and vehicleCfg.VehicleType == "" then
			local vehicleType = vehicleCfg.VehicleType
			local vehicleTypeCfg = LTConfig.VehicleTypeConfig.GetConfig(vehicleType)

			if vehicleTypeCfg then
				if not vehicleTypeSet[vehicleType] then
					vehicleTypeSet[vehicleType] = true
					vehicleTypeToScore[vehicleType] = 0
				end

				local isOwned = gApplyCarManager:CheckPlayerAlreadyHasVehicle(vehicleCfg.Id)

				if isOwned then
					local score = gBaiKeArchiveManager.CalculateVehicleScore(vehicleCfg.Id) or 0
					vehicleTypeToScore[vehicleType] = vehicleTypeToScore[vehicleType] + score
					totalScore = totalScore + score
				end
			end
		end
	end

	local categoryData = {}

	for vehicleType, score in pairs(vehicleTypeToScore) do
		local vehicleTypeCfg = LTConfig.VehicleTypeConfig.GetConfig(vehicleType)

		table.insert(categoryData, {
			vehicleType = vehicleType,
			score = score,
			iconId = vehicleTypeCfg.Icon,
			name = vehicleTypeCfg and vehicleTypeCfg.DisplayName
		})
	end

	table.sort(categoryData, function (a, b)
		return a.vehicleType <= b.vehicleType
	end)

	return totalScore, categoryData
end

M.OnRenderTabList = function(self, btn, index)
	local data = self.tabListData[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if store then
		store.icon = data.iconId
	end

	if not self.currentCategoryType and index ~= 0 then
		btn.isSelected = true
	else
		btn.isSelected = self.currentCategoryType ~= data.categoryType
	end
end

M.OnClickTabList = function(self, btn, index)
	local data = self.tabListData[index + 1]

	if not data then
		return
	end

	self.SwitchToCategoryType(self, data.categoryType)
end

M.OnRenderTypePointList = function(self, btn, index)
	local data = self.typePointListData[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if store then
		store.iconId = data.iconId
		store.numText = tostring(data.score)
		store.nameText = data.name or ""
	end
end

M.OnRenderRewardItem = function(self, btn, index)
	local data = self.rewardListData[index + 1]

	if not data then
		return
	end

	self.rewardBtnList[index + 1] = btn
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if store then
		local levelCfg = LTConfig.CityPediaCollectionLevelConfig.GetConfig(data.level)
		store.levelText = levelCfg.levelName or ""
		store.pointText = levelCfg.value
		store.iconId = levelCfg.icon
		local transform = btn.transform.localPosition
		btn.transform.localPosition = UnityEngine.Vector3(transform.x, transform.y, 0)

		if data.isClaimed then
			store.rewardCtrl = 0
		elseif data.canClaim then
			store.rewardCtrl = 1
		else
			store.rewardCtrl = 2
		end

		local isReached = data.isClaimed or data.canClaim

		if not isReached then
			store.progressCtrl = 0
		elseif index + 1 ~= self.lastReachedRewardIndex then
			store.progressCtrl = 1
		else
			store.progressCtrl = 2
		end

		if store.rewardBtn then
			if data.canClaim then
				slot8 = store.rewardBtn

				slot8:SetActive(true)

				store.rewardBtn.luaClick = function()
					self:OnClickRewardButton(data)
				end
			else
				store.rewardBtn:SetActive(false)
			end
		end

		local redDotKey = ("BaikeRewardLevel:%d"):format(data.level)
		btn.redKey = redDotKey

		SGUI.RedDotMgr.LuaSetRedDot(data.canClaim, redDotKey)

		store.rewardBtns = {}

		if data.rewards and #data.rewards <= 0 then
			store.rewardList.luaSimpleRenderItem = function(itemBtn, itemIndex)
				store.rewardBtns[itemIndex + 1] = itemBtn
				local itemData = data.rewards[itemIndex + 1]

				if itemData then
					local renderData = gCommonItemManager:GetItemRenderData({
						itemId = itemData.Id,
						itemNum = itemData.Count
					})

					gCommonItemManager:OnCommonItemRender(itemBtn, itemIndex, renderData)
				end
			end

			store.rewardList.luaSelectedChanged = function(list)
				local selectedIndex = list.selectedIndex

				for i, itemBtn in ipairs(store.rewardBtns) do
					if i - 1 == selectedIndex then
						SGUI.UButton.CloseTooltip(itemBtn, false)
					end
				end
			end

			store.rewardList:SetSimpleList(#data.rewards)
		else
			store.rewardList:SetSimpleList(0)
		end
	end
end

M.OnClickRewardList = function(self, list, index)
end

M.OnRewardItemSelectedChanged = function(self, list)
	local index = self.fashionTemplateStore.rewardList.selectedIndex
	local btn = self.rewardBtnList[index + 1]

	if not btn then
		return
	end
end

M.OnClickRewardButton = function(self, data)
	if not data then
		return
	end

	if data.canClaim then
		gBaiKeArchiveManager.ClaimCityPediaLevelReward(data.level, function (success, errId)
			if success then
				self:RefreshRewardList()

				local fakeItems = gCommonItemManager:ConvertDropToFakeItem(data.dropId, 1)
				local previewMaterials = {}

				for _, item in ipairs(fakeItems) do
					table.insert(previewMaterials, {
						ItemId = item.Id,
						Count = item.Count
					})
				end

				gDropManager:ShowRewardWindow({
					["B\\x8e\\x82\\xbe\\xee\\xb5\\xd2:\\xbb;=\\xb37"] = 2,
					Param = previewMaterials
				})
			end
		end)
	end
end

M.InitRedDot = function(self)
	local redDotKey = gBaiKeArchiveManager.GetPlayFashionPanelRedDotKey()
	self.bindData.baseButton.redKey = redDotKey

	self.RefreshRedDot(self)
end

M.RefreshRedDot = function(self)
	local hasRedDot = gBaiKeArchiveManager.CheckPlayFashionPanelHasRedDot()
	local redDotKey = gBaiKeArchiveManager.GetPlayFashionPanelRedDotKey()

	SGUI.RedDotMgr.LuaSetRedDot(hasRedDot, redDotKey, true)
end

M.InitRedDotRender = function(self)
	self.redDotAction = self:CreateAction("OnRenderRedDot")
	SGUI.RedDotMgr.onRenderRedDot = SGUI.RedDotMgr.onRenderRedDot and SGUI.RedDotMgr.onRenderRedDot + self.redDotAction or self.redDotAction
end

M.OnRenderRedDot = function(self, redKey, _, widget)
	if redKey ~= "BaikePlayFashionPanelRedDot" then
		local store = gStoreManager:GetStoreGroup("RedDotNumber"):GetStoreByWidget(widget)

		if store then
			store.num = gBaiKeArchiveManager.GetPlayFashionPanelRedDotCount()
		end
	end
end
