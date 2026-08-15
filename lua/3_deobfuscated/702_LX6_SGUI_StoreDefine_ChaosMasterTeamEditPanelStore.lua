C_ChaosMasterTeamEditPanelStore = DefClass("C_ChaosMasterTeamEditPanelStore", C_ChaosMasterTeamEditPanelStore, C_StoreGroup)
GroupName2Class.ChaosMasterTeamEditPanelStore = C_ChaosMasterTeamEditPanelStore
local M = C_ChaosMasterTeamEditPanelStore
local EditMode = {
	SingleEdit = 1,
	QuickEdit = 0
}
local GamePadTipId = {
	Finish = 410,
	Join = 412,
	Replace = 413,
	Leave = 411
}

function M:ctor()
	self.mode = EditMode.SingleEdit
	self.callBack = nil
	self.curChaosId = 0
	self.curChaosData = nil
	self.curTeamList = {}
	self.hideOrderNumFlag = 99999
end

function M:DefineAllVariables()
	return
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
	return
end

function M:OnGroupDisable()
	return
end

function M:OnShow(panelId, data)
	self.hideOrderNumFlag = 99999

	self:BuildCurTeamList()

	self.onShowData = data
	self.isAlreadyInTeam = false

	if data then
		self.mode = data.isQuickEdit and EditMode.QuickEdit or EditMode.SingleEdit
		self.enterIndex = data.enterIndex

		if self.mode == EditMode.QuickEdit then
			self.curChaosId = self.chaosList[1] and self.chaosList[1].Id or 0
			self.bindData.exitBtnName = LTConfig.TextScriptTextConfig.GetConfig(89901157).Text
			self.bindData.confirmBtnName = LTConfig.TextScriptTextConfig.GetConfig(89900103).Text
			self.bindData.disableConfirmBtnName = LTConfig.TextScriptTextConfig.GetConfig(89900103).Text

			if gCS.LuaUtils.IsNonMobileAdaptive() then
				self.bindData.gamePadArea:SetButtonInfoTipNameId(GamePadTipId.Finish, 1)
			end
		elseif self.mode == EditMode.SingleEdit then
			self.oldCardId = data.curChaosId
			self.curChaosId = data.curChaosId
			self.isAlreadyInTeam = self.curChaosId ~= 0
			self.bindData.exitBtnName = LTConfig.TextScriptTextConfig.GetConfig(89900262).Text
			self.bindData.confirmBtnName = LTConfig.TextScriptTextConfig.GetConfig(self.isAlreadyInTeam and 89901159 or 89901158).Text
			self.bindData.disableConfirmBtnName = LTConfig.TextScriptTextConfig.GetConfig(self.isAlreadyInTeam and 89901159 or 89901158).Text

			if gCS.LuaUtils.IsNonMobileAdaptive() then
				self.bindData.gamePadArea:SetButtonInfoTipNameId(self.isAlreadyInTeam and GamePadTipId.Leave or GamePadTipId.Join, 1)
			end

			self.bindData.showInfoCtrl = self.curChaosId ~= 0 and 0 or 1
		end

		self.curChaosData = gBattlePetsMgr:GetPetDataById(self.curChaosId)
		self.callBack = data.callBack
	else
		self.mode = EditMode.SingleEdit
		self.curChaosId = 0
		self.callBack = nil
	end

	self:RefreshDDL(gBattlePetsMgr.countDown)
	self:RefreshChaosList(true)
	self:RefreshTeamCost()
	self:RefreshChaosInfo()
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

function M:GenMessageEvents()
	return
end

function M:RegisterWidget()
	self.bindData.exitBtn.luaClick = self:CreateAction("OnClickExitBtn")
	self.bindData.comfirmBtn.luaClick = self:CreateAction("OnClickConfirmBtn")
	self.bindData.comfirmBtn.luaInvalidClick = self:CreateAction("OnClickConfirmBtn")
	self.bindData.cardList.luaRenderItem = self:CreateAction("OnRenderCardListItem")
	self.bindData.cardList.luaClick = self:CreateAction("OnClickCardList")
	self.chaosInfo = gStoreManager:GetStoreGroup("ChaosInfoPanelStore")
end

function M:OnClickExitBtn()
	gBattlePetsMgr:SetChaosMasterPrepareTab(gBattlePetsMgr.PreparePanelTab.Team, nil, false)

	if self.callBack then
		self.callBack()
	end
end

function M:OnClickConfirmBtn()
	if self.bindData.maxCost < self.bindData.totalCost then
		gDisplayMessageMgr:ShowMessageContent(LTConfig.TextScriptTextConfig.GetConfig(89901155).Text)

		return
	end

	if self.mode == EditMode.QuickEdit then
		gBattlePetsMgr.currentTeamList = table.clone(self.curTeamList)
	else
		if self.isAlreadyInTeam then
			if self.oldCardId == self.curChaosId then
				self:RemoveTeamMember(self.curTeamList, self.curChaosData)
			else
				self:SwapTeamMember(self.curTeamList)
			end
		else
			self.curTeamList[self.enterIndex] = self.curChaosData
		end

		gBattlePetsMgr:RebuildCurrentTeamList(self.curTeamList)
	end

	if self.callBack then
		self.callBack()
	end

	gBattlePetsMgr:SetChaosMasterPrepareTab(gBattlePetsMgr.PreparePanelTab.Team, nil, false)
end

function M:OnRenderCardListItem(btn, index, data)
	local store = gStoreManager:GetStoreGroup("ChaosCardSmallTemplate"):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.name = data.name
	store.cost = data.cost
	store.lihuiId = data.lihuiId
	store.orderCtrl = data.orderCtrl
	store.orderNum = data.orderNum
	store.currentUseCtrl = data.currentUseCtrl
	store.button.luaFocus = self:CreateActionWithArgs("OnChaosCardFocus", data)
	store.genreList.luaRenderItem = self:CreateAction("OnGenreRender")
	local list = {}

	for i = 1, #data.cfg.ChaosTag do
		table.insert(list, data.cfg.ChaosTag[i])
	end

	gBattlePetsMgr:RefreshGenreList(store.genreList, list)
end

function M:OnChaosCardFocus(data)
	self.curChaosId = data.chaosData.Id
	self.curChaosData = gBattlePetsMgr:GetPetDataById(self.curChaosId)
	self.bindData.showInfoCtrl = self.curChaosId ~= 0 and 0 or 1

	self:RefreshChaosInfo()
end

function M:OnGenreRender(item, index, data)
	local store = gStoreManager:GetStoreGroup("BuffGenreTemplate"):GetStoreByWidget(item)

	if not store then
		return
	end

	store.iconId = data.iconId ~= 0 and data.iconId or nil
end

function M:OnClickCardList(btn, data)
	self.curChaosId = data.chaosData.Id
	self.curChaosData = gBattlePetsMgr:GetPetDataById(self.curChaosId)
	self.bindData.showInfoCtrl = self.curChaosId ~= 0 and 0 or 1

	if self.mode == EditMode.SingleEdit then
		if self.isInSetList then
			self:RefreshChaosCard(btn, data)
		else
			self:RefreshChaosList()
		end

		self.isAlreadyInTeam = self:CheckAlreadySelect(data.chaosData.Id, true)

		if self.oldCardId ~= 0 then
			local isOldCard = data.chaosData.Id == self.oldCardId
			self.bindData.confirmBtnName = LTConfig.TextScriptTextConfig.GetConfig(isOldCard and 89901159 or 89901164).Text
			self.bindData.disableConfirmBtnName = LTConfig.TextScriptTextConfig.GetConfig(isOldCard and 89901159 or 89901164).Text

			if gCS.LuaUtils.IsNonMobileAdaptive() then
				self.bindData.gamePadArea:SetButtonInfoTipNameId(isOldCard and GamePadTipId.Leave or GamePadTipId.Replace, 1)
			end
		else
			self.bindData.confirmBtnName = LTConfig.TextScriptTextConfig.GetConfig(self.isAlreadyInTeam and 89901164 or 89901158).Text
			self.bindData.disableConfirmBtnName = LTConfig.TextScriptTextConfig.GetConfig(self.isAlreadyInTeam and 89901164 or 89901158).Text

			if gCS.LuaUtils.IsNonMobileAdaptive() then
				self.bindData.gamePadArea:SetButtonInfoTipNameId(self.isAlreadyInTeam and GamePadTipId.Replace or GamePadTipId.Join, 1)
			end
		end

		self:RefreshTeamCost()
	elseif self.mode == EditMode.QuickEdit then
		if data.orderNum < self.hideOrderNumFlag then
			self:RemoveTeamMember(self.curTeamList, data.chaosData)
		elseif #self.curTeamList < gBattlePetsMgr.maxListCnt then
			self.curTeamList[#self.curTeamList + 1] = data.chaosData
		end

		if self.isInSetList then
			self:RefreshChaosCard(btn, data)
		else
			self:RefreshChaosList()
		end
	end

	self:RefreshChaosInfo()
	self:RefreshConfirmBtn()
end

function M:RefreshChaosInfo()
	if self.bindData.showInfoCtrl == 1 then
		return
	end

	self.chaosInfo:OnShow(nil, {
		showGenreDetail = false,
		curChaosData = self.curChaosData
	})
end

function M:RefreshChaosList(needSort)
	local allChaos = needSort and gBattlePetsMgr.petDataDic or self.chaosList
	local index = 0
	self.chaosList = {}

	for k, v in pairs(allChaos) do
		local chaos = gBattlePetsMgr:GetPetDataById(v.Id)
		local cfg = gBattlePetsMgr:GetChaosLimboChaConfig(chaos.LimboChaId)
		local orderNum = self:GetOrderNum(chaos.Id)
		local showOrderNum = self.mode == EditMode.QuickEdit and orderNum < self.hideOrderNumFlag

		if cfg then
			local item = {
				name = cfg.Name,
				cost = gBattlePetsMgr:GetChaosCost(chaos),
				lihuiId = cfg.CardIcon,
				orderCtrl = showOrderNum and 0 or 1,
				orderNum = orderNum,
				currentUseCtrl = self:CurrentUseCtrl(chaos.Id),
				selected = chaos.Id == self.curChaosId,
				Id = chaos.Id,
				cfg = cfg,
				chaosData = chaos,
				index = index
			}
			index = index + 1

			table.insert(self.chaosList, item)
		end
	end

	if needSort then
		table.sort(self.chaosList, function (a, b)
			if a.orderNum == b.orderNum then
				return b.cost < a.cost
			end

			return a.orderNum < b.orderNum
		end)
	end

	self:RefreshCost(self.curTeamList)

	self.isInSetList = true

	self.bindData.cardList:SetList(self.chaosList)

	self.isInSetList = false

	if needSort then
		self.bindData.cardList:SetNavSelectToTop()
	end
end

function M:RefreshTeamCost()
	if self.mode ~= EditMode.SingleEdit then
		return
	end

	local tempList = table.clone(self.curTeamList)
	local isAlreadyInTeam = self:CheckAlreadySelect(self.curChaosId, true)

	if isAlreadyInTeam then
		if self.oldCardId == self.curChaosId then
			self:RemoveTeamMember(tempList, self.curChaosData)
		else
			self:SwapTeamMember(tempList)
		end
	else
		tempList[self.enterIndex] = self.curChaosData
	end

	self:RefreshCost(tempList)
end

function M:RefreshChaosCard(btn, data)
	local store = gStoreManager:GetStoreGroup("ChaosCardSmallTemplate"):GetStoreByWidget(btn)
	local chaos = gBattlePetsMgr:GetPetDataById(data.Id)
	local cfg = gBattlePetsMgr:GetChaosLimboChaConfig(chaos.LimboChaId)
	local orderNum = self:GetOrderNum(chaos.Id)
	local showOrderNum = self.mode == EditMode.QuickEdit and orderNum < self.hideOrderNumFlag

	if cfg and store then
		data.orderCtrl = showOrderNum and 0 or 1
		data.orderNum = orderNum
		data.currentUseCtrl = self:CurrentUseCtrl(chaos.Id)
		data.selected = chaos.Id == self.curChaosId
		store.orderCtrl = showOrderNum and 0 or 1
		store.orderNum = orderNum
		store.currentUseCtrl = self:CurrentUseCtrl(chaos.Id)
		store.selected = chaos.Id == self.curChaosId

		for i = 1, #self.chaosList do
			if self.chaosList[i].Id == data.Id then
				self.chaosList[i] = data
			end
		end
	end
end

function M:RefreshCost(list)
	local curCost = 0

	for i = 1, gBattlePetsMgr.maxListCnt do
		local chaos = list[i]
		curCost = curCost + self:CalcChaosCost(chaos)
	end

	self.bindData.totalCost = curCost
	self.bindData.maxCost = gBattlePetsMgr.maxCost
end

function M:RefreshConfirmBtn()
	local interactable = true

	if self.bindData.maxCost < self.bindData.totalCost then
		interactable = false
	end

	if self.curChaosId == 0 then
		interactable = false
	end

	self.bindData.comfirmBtn.interactable = interactable
end

function M:CalcChaosCost(chaos)
	if chaos then
		return gBattlePetsMgr:GetChaosCost(chaos)
	end

	return 0
end

function M:GetOrderNum(id)
	for i = 1, gBattlePetsMgr.maxListCnt do
		if self.curTeamList[i] and self.curTeamList[i].Id == id then
			return i
		end
	end

	return self.hideOrderNumFlag
end

function M:CurrentUseCtrl(id)
	if self.mode == EditMode.QuickEdit then
		return 1
	end

	return self:CheckAlreadySelect(id, true) and 0 or 1
end

function M:CheckAlreadySelect(id, ignoreEnterPos)
	for i = 1, gBattlePetsMgr.maxListCnt do
		if self.curTeamList[i] and self.curTeamList[i].Id == id then
			if ignoreEnterPos then
				return true
			end

			return i ~= self.enterIndex
		end
	end

	return false
end

function M:CheckCurTeamMemberCount(chaosId)
	local cnt = 0

	for i = 1, gBattlePetsMgr.maxListCnt do
		if self.curTeamList[i] and self.curTeamList[i].Id ~= chaosId then
			cnt = cnt + 1
		end
	end

	return cnt
end

function M:SwapTeamMember(list)
	local newCardIndex = 1
	local oldCardIndex = self.enterIndex

	for i = 1, #list do
		if list[i].Id == self.oldCardId then
			oldCardIndex = i
		elseif list[i].Id == self.curChaosId then
			newCardIndex = i
		end
	end

	list[newCardIndex] = gBattlePetsMgr:GetPetDataById(self.oldCardId)
	list[oldCardIndex] = self.curChaosData
end

function M:RemoveTeamMember(team, member)
	for i = gBattlePetsMgr.maxListCnt, 1, -1 do
		if team[i] and team[i].Id == member.Id then
			table.remove(team, i)
		end
	end
end

function M:BuildCurTeamList()
	self.curTeamList[1] = gBattlePetsMgr.currentTeamList[1] or nil
	self.curTeamList[2] = gBattlePetsMgr.currentTeamList[2] or nil
	self.curTeamList[3] = gBattlePetsMgr.currentTeamList[3] or nil

	self:RefreshChaosList(true)
end

function M:RefreshDDL(ddl)
	self.enableDLLUpdate = false

	if not self.enableDLLUpdate then
		gBattlePetsMgr.countDown = 0
		self.bindData.countDown = ""

		return
	end

	gBattlePetsMgr.countDown = ddl + gLogicTime.time
	self.bindData.countDown = ddl

	self:RegisterCountDownCallBack(function ()
		gBattlePetsMgr:SetChaosMasterPrepareTab(gBattlePetsMgr.PreparePanelTab.Team, nil, false)
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
	if not self.bindData.countDown or self.bindData.countDown <= 0 or gBattlePetsMgr.countDown == "" then
		self:EndDDL()

		return
	end

	self.bindData.countDown = math.ceil(math.max(0, gBattlePetsMgr.countDown - gLogicTime.time))
end

function M:RegisterCountDownCallBack(cb)
	self.ddlCallBack = cb
end
