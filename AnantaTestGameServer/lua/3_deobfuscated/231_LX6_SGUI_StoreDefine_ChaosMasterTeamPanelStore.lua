local MessageConfig = LTConfig.MessageConfig
C_ChaosMasterTeamPanelStore = DefClass("C_ChaosMasterTeamPanelStore", C_ChaosMasterTeamPanelStore, C_StoreGroup)
GroupName2Class.ChaosMasterTeamPanelStore = C_ChaosMasterTeamPanelStore
local M = C_ChaosMasterTeamPanelStore

function M:ctor()
	return
end

function M:OnAwake()
	self.bindData.exitBtn.luaClick = self:CreateAction("OnExitBtnClick")
	self.bindData.quickEditBtn.luaClick = self:CreateAction("QuickEditBtnClick")
	self.bindData.fightBtn.luaClick = self:CreateAction("OnFightBtnClick")
	self.bindData.fightBtn.luaInvalidClick = self:CreateAction("OnFightBtnClick")
	self.bindData.genreDetailBtn.luaClick = self:CreateAction("OnGenreDetailBtnDown")
	self.bindData.envGenreList.luaRenderItem = self:CreateAction("OnEnvGenreRender")
	self.bindData.cardList.luaRenderItem = self:CreateAction("OnChaosRender")
	self.bindData.cardList.luaClick = self:CreateAction("OnClickCardList")
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
	self.alreadyConfirm = false

	gBattlePetsMgr:BuildCurrentTeamByQuickSummonList()

	self.bindData.showGenreCtrl = gBattlePetsMgr:CheckIsBVBGameDoJoChallenge() and 1 or 0

	self:RefreshDDL(gBattlePetsMgr.countDown)
	self:RefreshEnvGenreList()
	self:RefreshChaosList()
	self:RefreshCost()
	self:CheckForbidExitBtn()
	self:PlayPanelOpenOrCloseAni(true)
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
	gPanelManager:Close(gPanelId.CHAOS_MASTER_PREPARE_PANEL)
end

function M:QuickEditBtnClick()
	gBattlePetsMgr:SetChaosMasterPrepareTab(gBattlePetsMgr.PreparePanelTab.EditTeam, {
		isQuickEdit = true,
		callBack = function ()
			self:RefreshChaosList()
		end
	})
end

function M:OnFightBtnClick()
	if not self.bindData.fightBtn.interactable then
		if self.alreadyConfirm then
			gDisplayMessageMgr:ShowMessageContent(LTConfig.TextScriptTextConfig.GetConfig(89901185).Text)
		else
			gDisplayMessageMgr:ShowMessageContent(LTConfig.TextScriptTextConfig.GetConfig(89901156).Text)
		end

		return
	end

	local list = {}

	for i = 1, gBattlePetsMgr.maxListCnt do
		list[i] = gBattlePetsMgr.currentTeamList[i] and gBattlePetsMgr.currentTeamList[i].Id or 0
	end

	if gBattlePetsMgr.bvbOnlineType == gBattlePetsMgr.BVBOnlineType.Single then
		gClientToGameSceneDelegate:AskStartBVBGame(gBattlePetsMgr.currentLevelNpcId, gBattlePetsMgr.gameMode).Callback = function (err)
			if err == MessageConfig.Ok then
				gPanelManager:Close(gPanelId.CHAOS_MASTER_PREPARE_PANEL)
			end
		end
	else
		gClientToGameSceneDelegate:AskBVBLinkGameSelectTeam(list).Callback = function (err)
			if err == LTConfig.MessageConfig.Ok then
				self.alreadyConfirm = true

				self:RefreshFightBtn()
			end
		end
	end
end

function M:OnGenreDetailBtnDown()
	gBattlePetsMgr:SetChaosMasterPrepareTab(gBattlePetsMgr.PreparePanelTab.Team)
end

function M:OnGenreClick()
	local curTab = gBattlePetsMgr.curPrepareTab

	gBattlePetsMgr:SetChaosMasterPrepareTab(gBattlePetsMgr.PreparePanelTab.GenreDetail, {
		closeAction = function ()
			gBattlePetsMgr:SetChaosMasterPrepareTab(curTab, nil, false)
			self:PlayPanelOpenOrCloseAni(false)
		end
	})
end

function M:OnClickCardList(btn, data)
	gBattlePetsMgr:SetChaosMasterPrepareTab(gBattlePetsMgr.PreparePanelTab.EditTeam, {
		isQuickEdit = false,
		callBack = function ()
			self:RefreshChaosList()
			self:PlayPanelOpenOrCloseAni(false)
		end,
		enterIndex = data.index,
		curChaosId = data.chaosData and data.chaosData.Id or 0
	})
end

function M:OnEnvGenreRender(item, index, data)
	local store = gStoreManager:GetStoreGroup("BuffGenreTemplate"):GetStoreByWidget(item)

	if not store then
		return
	end

	store.iconId = data.iconId
	store.showBanIconCtrl = data.showBanIconCtrl
	store.button.luaClick = self:CreateAction("OnGenreClick")
end

function M:OnChaosRender(item, index, data)
	local store = gStoreManager:GetStoreGroup("ChaosCardTemplate"):GetStoreByWidget(item)

	if not store then
		return
	end

	item.autoClickOnHover = false
	store.isEmptyCtrl = data.isEmptyCtrl

	if store.isEmptyCtrl == 0 then
		store.lihuiId = data.lihuiId
		store.name = data.name
		store.cost = data.cost
		store.button.luaClick = self:CreateAction("OnChaosClick")
		store.genreList.luaRenderItem = self:CreateAction("OnGenreRender")
		local list = {}

		for i = 1, #data.cfg.ChaosTag do
			table.insert(list, data.cfg.ChaosTag[i])
		end

		gBattlePetsMgr:RefreshGenreList(store.genreList, list)
	end
end

function M:OnGenreRender(item, index, data)
	local store = gStoreManager:GetStoreGroup("BuffGenreTemplate"):GetStoreByWidget(item)

	if not store then
		return
	end

	store.iconId = data.iconId ~= 0 and data.iconId or nil
	store.button.luaClick = self:CreateActionWithArgs("OnGenreClick")
end

function M:RefreshEnvGenreList()
	local allGenList = gBattlePetsMgr.allGenreList
	local list = {}

	for i = 1, #allGenList do
		local cfg = allGenList[i]
		local item = {
			iconId = cfg.SImageId,
			showBanIconCtrl = gBattlePetsMgr:GetCurrentGenreType(cfg.Id) == gBattlePetsMgr.GenreTagType.LevelGenre and 0 or 1,
			cfg = cfg
		}

		table.insert(list, item)
	end

	table.sort(list, function (a, b)
		if a.showBanIconCtrl == b.showBanIconCtrl then
			return a.cfg.Id < b.cfg.Id
		end

		return a.showBanIconCtrl < b.showBanIconCtrl
	end)
	self.bindData.envGenreList:SetList(list)
end

function M:RefreshChaosList()
	local list = {}

	for i = 1, 3 do
		local item = {
			isEmptyCtrl = 1,
			index = i
		}

		if gBattlePetsMgr.currentTeamList[i] then
			local chaos = gBattlePetsMgr:GetPetDataById(gBattlePetsMgr.currentTeamList[i].Id)

			if chaos then
				local cfg = gBattlePetsMgr:GetChaosLimboChaConfig(chaos.LimboChaId)
				item.isEmptyCtrl = 0
				item.lihuiId = cfg.CardIcon
				item.name = cfg.Name
				item.cost = gBattlePetsMgr:GetChaosCost(chaos)
				item.cfg = cfg
				item.chaosData = chaos
			end
		end

		table.insert(list, item)
	end

	self.bindData.cardList:SetList(list)
	self:RefreshCost()
	self:RefreshFightBtn()
end

function M:RefreshCost()
	local curCost = 0

	for i = 1, gBattlePetsMgr.maxListCnt do
		if gBattlePetsMgr.currentTeamList[i] then
			curCost = curCost + gBattlePetsMgr:GetChaosCost(gBattlePetsMgr:GetPetDataById(gBattlePetsMgr.currentTeamList[i].Id))
		end
	end

	self.bindData.totalCost = curCost
	self.bindData.maxCost = gBattlePetsMgr.maxCost
end

function M:RefreshFightBtn()
	self.bindData.fightBtn.interactable = gBattlePetsMgr.currentTeamList[1] ~= nil and not self.alreadyConfirm
end

function M:RefreshDDL(ddl)
	self.enableDLLUpdate = false

	if not self.enableDLLUpdate then
		gBattlePetsMgr.countDown = 0
		self.bindData.countDown = ""

		return
	end

	gBattlePetsMgr.countDown = self.enableDLLUpdate and ddl + gLogicTime.time or 0
	self.bindData.countDown = self.enableDLLUpdate and ddl or ""

	self:RegisterCountDownCallBack(function ()
		self:OnFightBtnClick()
	end)
end

function M:EndDDL()
	gBattlePetsMgr.countDown = 0
	self.bindData.countDown = 0
	self.enableDLLUpdate = false

	if self.ddlCallBack then
		self.ddlCallBack()
	end
end

function M:UpdateDDL()
	if not self.bindData.countDown or self.bindData.countDown <= 0 then
		self:EndDDL()

		return
	end

	self.bindData.countDown = math.ceil(math.max(0, gBattlePetsMgr.countDown - gLogicTime.time))
end

function M:RegisterCountDownCallBack(cb)
	self.ddlCallBack = cb
end

function M:CheckForbidExitBtn()
	if gBattlePetsMgr.bvbOnlineType ~= gBattlePetsMgr.BVBOnlineType.Single then
		self.bindData.exitBtn:SetActive(false)
	end
end

function M:PlayPanelOpenOrCloseAni(open)
	local ani = self.bindData.panelOpenAni

	if open then
		gBattleMgr:CommonPlayAniTool(ani, "S_ChaosMasterTeamPanel_open", 0, 1, true, function ()
			return
		end)
	else
		gBattleMgr:CommonPlayAniTool(ani, "S_ChaosMasterTeamPanel_Back", 0, 1, true, function ()
			return
		end)
	end
end

function M:ResetCardListStaticBlur()
	local flag, child = nil

	for i = 0, 2 do
		flag, child = self.bindData.cardList:TryGetChildAt(i, child)

		if flag then
			local store = gStoreManager:GetStoreGroup("ChaosCardTemplate"):GetStoreByWidget(child)

			if store and store.isEmptyCtrl == 1 then
				store.staticBlur:ResetStaticBlur()
			end
		end
	end
end
