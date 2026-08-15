C_ChaosGenreDetailPanelStore = DefClass("C_ChaosGenreDetailPanelStore", C_ChaosGenreDetailPanelStore, C_StoreGroup)
GroupName2Class.ChaosGenreDetailPanelStore = C_ChaosGenreDetailPanelStore
local M = C_ChaosGenreDetailPanelStore

function M:ctor()
	return
end

function M:OnAwake()
	self.bindData.exitBtn.luaClick = self:CreateAction("OnExitBtnClick")
	self.bindData.genreDetailList.luaRenderItem = self:CreateAction("OnGenreRender")
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
	self.curGenre = data and data.curGenre or nil
	self.closeAction = data and data.closeAction or nil
	self.isFromInfoTooltip = data and data.isFromInfoTooltip or false

	self:RefreshDDL(gBattlePetsMgr.countDown)
	self:RefreshGenreList()
end

function M:OnClose()
	return
end

function M:OnUpdate()
	if self.enableDLLUpdate then
		self:UpdateDDL()
	end
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end

function M:OnExitBtnClick()
	if self.closeAction then
		self.closeAction()
	end
end

function M:OnGenreRender(item, index, data)
	local store = gStoreManager:GetStoreGroup("GenreDetailTemplate"):GetStoreByWidget(item)

	if not store then
		return
	end

	store.genreIconId = data.genreIconId
	store.genreName = data.genreName
	store.genreDes = data.genreDes
	store.tagCtrl = data.tagCtrl
	store.buffList.luaRenderItem = self:CreateAction("OnBuffRender")

	self:RefreshGenreBuffList(store, data.cfg.Id)
end

function M:OnBuffRender(item, index, data)
	local store = gStoreManager:GetStoreGroup("ChaosMasterBuffTemplate"):GetStoreByWidget(item)

	if not store then
		return
	end

	store.qualityCtrl = data.qualityCtrl
	store.iconId = data.iconId
	store.cfg = data.cfg
	store.button.luaRenderTooltip = self:CreateAction("OnBuffToolTipRender")
	store.button.luaTooltipPopup = self:CreateAction("OnBuffToolTipPopUp")
end

function M:OnBuffToolTipRender(btn, popup, index)
	local store = gStoreManager:GetStoreGroup("ChaosMasterBuffTemplate"):GetStoreByWidget(btn)
	local popupStore = gStoreManager:GetStoreGroup("ChaosBuffTooltip"):GetStoreByWidget(popup)

	if not popupStore or not popupStore then
		return
	end

	popupStore.name = store.cfg.Name
	popupStore.des = gBattlePetsMgr:BuildDescriptionStrByValueList(store.cfg.Description, store.cfg.BuffParameter, store.cfg.StarUpParametersType, 0, false)
	popupStore.qualityCtrl = store.qualityCtrl
end

function M:OnBuffToolTipPopUp(btn, popup, index)
	local store = gStoreManager:GetStoreGroup("ChaosMasterBuffTemplate"):GetStoreByWidget(btn)

	if not store then
		return
	end

	if not popup then
		store.selected = popup

		self:RefreshGenreList()
	end
end

function M:RefreshGenreList()
	local allGenList = gBattlePetsMgr.allGenreList
	local list = {}

	for i = 1, #allGenList do
		local cfg = allGenList[i]
		local tagCtrl = gBattlePetsMgr:GetCurrentGenreType(cfg.Id)

		if self.curGenre then
			tagCtrl = self:CheckContainsGenre(cfg.Id) and gBattlePetsMgr.GenreTagType.ChaosGenre or gBattlePetsMgr.GenreTagType.Hide
		end

		local item = {
			genreIconId = cfg.SImageId,
			genreName = cfg.Name,
			genreDes = gBattlePetsMgr:BuildDescriptionStrByValueList(cfg.Effect, cfg.BuffParameter, cfg.StarUpParametersType, 0, true),
			tagCtrl = tagCtrl,
			cfg = cfg
		}

		table.insert(list, item)
	end

	table.sort(list, function (a, b)
		return a.tagCtrl < b.tagCtrl
	end)
	self.bindData.genreDetailList:SetList(list)
end

function M:RefreshGenreBuffList(store, genreId)
	local allGenreBuffList = gBattlePetsMgr.buffDict[genreId]

	if not allGenreBuffList then
		return
	end

	local list = {}

	for i = 1, #allGenreBuffList do
		local cfg = allGenreBuffList[i]
		local item = {
			qualityCtrl = cfg.Quality - 1,
			iconId = cfg.SImageId,
			cfg = cfg
		}

		table.insert(list, item)
	end

	gBattlePetsMgr:SortByQuality(list)
	store.buffList:SetList(list)
end

function M:CheckContainsGenre(id)
	for i = 1, #self.curGenre do
		if self.curGenre[i].id == id then
			return true
		end
	end

	return false
end

function M:RefreshDDL(ddl)
	self.enableDLLUpdate = false

	if not self.enableDLLUpdate then
		gBattlePetsMgr.countDown = 0
		self.bindData.countDown = ""

		return
	end

	gBattlePetsMgr.countDown = ddl
	self.bindData.countDown = ddl

	self:RegisterCountDownCallBack(function ()
		gBattlePetsMgr:SetChaosMasterPrepareTab(gBattlePetsMgr.PreparePanelTab.Team, nil, false)
	end)
end

function M:EndDDL()
	self.bindData.countDown = 0
	self.enableDLLUpdate = false

	if self.ddlCallBack then
		self.ddlCallBack()
	end
end

function M:UpdateDDL()
	if not self.bindData.countDown or self.bindData.countDown <= 0 or gBattlePetsMgr.countDown == "" then
		self:EndDDL()

		return
	end

	self.bindData.countDown = math.ceil(math.max(0, gBattlePetsMgr.countDown - gLogicTime.time))
end

function M:RegisterCountDownCallBack(cb)
	self.ddlCallBack = cb
end
