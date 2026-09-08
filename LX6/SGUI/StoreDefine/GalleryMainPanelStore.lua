-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\GalleryMainPanelStore.lua
-- Decompiled from: 01825_GalleryMainPanelStore.lua_c4b4ab7d8d74.luajit

C_GalleryMainPanelStore = DefClass("C_GalleryMainPanelStore", C_GalleryMainPanelStore, C_StoreGroup)
GroupName2Class.GalleryMainPanelStore = C_GalleryMainPanelStore
local M = C_GalleryMainPanelStore
local HomePageConfig = LTConfig.AssetGalleryHomePageConfig
local AssetGalleryType = LTConfig.AssetGalleryAssetGalleryTypeConfig

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.rootArea = nil
	local TypeType = HomePageConfig.TypeType
	self.typePanelMap = {
		[TypeType.CollectionRoom] = gPanelId.COLLECTION_ROOM_MAIN_ENTRANCE_PANEL,
		[TypeType.Fashion] = gPanelId.GALLERY_CLOTHES_PANEL,
		[TypeType.Vehicle] = gPanelId.GALLERY_CAR_PREVIEW_PANEL,
		[TypeType.Furniture] = gPanelId.GALLERY_FURNITURE_PANEL,
		[TypeType.Weapon] = gPanelId.GALLERY_WEAPON_PREVIEW_PANEL
	}
	self.typeToAssetGalleryType = {
		[TypeType.Fashion] = AssetGalleryType.Fashion,
		[TypeType.Vehicle] = AssetGalleryType.Vehicle,
		[TypeType.Weapon] = AssetGalleryType.Weapon,
		[TypeType.Furniture] = AssetGalleryType.Furniture
	}
end

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
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
	self.cardStoreMap = nil
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	if self.rootGo then
		self.rootArea = self.rootGo:GetComponent("UNavigationArea")
	end

	gGalleryManager:BuildSearchIndex()
	self:InitTopTemplate()
	self:InitHomePage()
end

M.GetTopTemplateStore = function(self)
	local topTemplate = self.bindData.topTemplate

	if not topTemplate then
		return nil
	end

	return gStoreManager:GetStoreGroup(topTemplate.Store)
end

M.InitTopTemplate = function(self)
	local topStore = self.GetTopTemplateStore(self)

	if not topStore then
		return
	end

	topStore.SetData(topStore, {
		switchToRootArea = function ()
			if self.rootArea then
				SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.rootArea
			end
		end
	})
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.InitHomePage = function(self)
	local categoryRoot = self.bindData.categoryRoot and self.bindData.categoryRoot.transform

	if not categoryRoot then
		return
	end

	local configList = {}

	for i = 0, HomePageConfig.count - 1 do
		table.insert(configList, HomePageConfig.LoadAt(i))
	end

	table.sort(configList, function (a, b)
		return b.Weight <= a.Weight
	end)

	self.cardStoreMap = {}

	for cardIndex = 1, #configList do
		local cfg = configList[cardIndex]
		local childTf = categoryRoot.GetChild(categoryRoot, cardIndex - 1)

		if not childTf then
			break
		end

		local widget = childTf.GetComponent(childTf, "UWidget")

		if widget then
			local store = gStoreManager:GetStoreGroup(widget.Store):GetStoreByWidget(widget)

			if cfg.Image and cfg.Image == 0 and cfg.Image == "" then
				store.cardIconId = cfg.Image
			end

			store.title = cfg.Name
			local assetType = self.typeToAssetGalleryType[cfg.Type]

			if assetType then
				local credit = gGalleryManager.GetCreditByType(assetType)
				store.numberText = tostring(credit)
				local totalScore = gGalleryManager.GetCategoryTotalScore(assetType)

				store.progress:SetActive(true)

				store.progress.value = totalScore <= 0 and math.min(1, credit / totalScore) or 0
			else
				store.numberText = ""

				store.progress:SetActive(false)
			end

			self.cardStoreMap[cardIndex] = store
		end

		local button = childTf.GetComponent(childTf, "UButton")

		if button then
			button.luaClick = self.CreateActionWithArgs(self, "OnClickCard", cfg.Type)
		end
	end
end

M.OnClickCard = function(self, homePageType)
	local panelId = self.typePanelMap[homePageType]

	if panelId then
		gPanelManager:CheckShow(panelId)
	end
end

M.RegisterWidget = function(self)
	self.bindData.backBtn.luaClick = self.CreateAction(self, self.OnClickBackBtn)
end

M.OnClickBackBtn = function(self)
	local topStore = self.GetTopTemplateStore(self)

	if topStore and topStore.IsSearchActive(topStore) then
		topStore.ClearSearchText(topStore)

		return
	end

	gPanelManager:Close(self.m_Id)
end
