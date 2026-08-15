local ChaosMasterConfig = LTConfig.ChaosMasterConfig
C_ChaosEditTeamFullscreenStore = DefClass("C_ChaosEditTeamFullscreenStore", C_ChaosEditTeamFullscreenStore, C_StoreGroup)
GroupName2Class.ChaosEditTeamFullscreenStore = C_ChaosEditTeamFullscreenStore
local M = C_ChaosEditTeamFullscreenStore
local IsFillCtrl = {
	Fill = 0,
	Empty = 1
}
local FillState = {
	Drag = 1,
	Absorb = 2,
	Normal = 0
}
local EmptyState = {
	Absorb = 1,
	Normal = 0
}
local CardState = {
	Drag = 1,
	InTeam = 2,
	Normal = 0
}

function M:ctor()
	return
end

function M:DefineAllVariables()
	self.teamDic = {}
	self.gridSizeM = 7
	self.halfM = 3
	self.isDragging = false
	self.isAskFinish = false
	self.chaosList = {}
	self.listList = {}
	self.dragCardStore = nil
	self.curDragChaosId = nil
	self.dragRow = nil
	self.dragCol = nil
	self.hoverRow = nil
	self.hoverCol = nil
	self.isHoverDeleteArea = false
	self.curToolTipChaosId = nil
	self.curToolTipChaos = nil
	self.totalCost = 0
	self.totalCount = 0
	self.chaosInfoStore = nil
	self.equipInfoStore = nil
	self.curSelectedBtn = nil
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
	self.isReplay = data and data.isReplay or false
	self.isEnemy = data and data.isEnemy or false

	self:RegisterTooltip()
	self:RefreshChaosList(true)
	self:RefreshChaosTeamList()
	self:RefreshCost()
	self:RefreshCount()
	self:HideChaosTooltip()
	self:SetShowDeleteArea(false)
	self:RefreshConfirmBtn()
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

function M:OnUpdate()
	return
end

function M:RefreshChaosList(needSort)
	local allChaos = needSort and gBattlePetsMgr.petDataDic or self.chaosList
	self.chaosList = {}

	for k, v in pairs(allChaos) do
		local chaos = gBattlePetsMgr:GetPetDataById(v.Id)
		local cfg = gBattlePetsMgr:GetChaosLimboChaConfig(chaos.LimboChaId)

		if cfg then
			local item = {
				isInTeam = false,
				cost = gBattlePetsMgr:GetChaosCost(chaos),
				lihuiId = cfg.CardIcon,
				Id = chaos.Id,
				cfg = cfg,
				chaosData = chaos
			}

			table.insert(self.chaosList, item)
		end
	end

	if needSort then
		table.sort(self.chaosList, function (a, b)
			return b.cost < a.cost
		end)
	end

	self.bindData.chaosList:SetSimpleList(#self.chaosList)

	if needSort then
		self.bindData.chaosList:SetNavSelectToTop()
	end
end

function M:RefreshChaosTeamList()
	self.teamDic = {
		[-1] = {},
		[-2] = {},
		[-3] = {}
	}
	self.listList = {
		[-1] = self.bindData.frontChaosList,
		[-2] = self.bindData.middleChaosList,
		[-3] = self.bindData.backChaosList
	}
	local colMax = 6

	self.bindData.frontChaosList:SetSimpleList(colMax)
	self.bindData.middleChaosList:SetSimpleList(colMax)
	self.bindData.backChaosList:SetSimpleList(colMax)
end

function M:GenMessageEvents()
	return
end

function M:RegisterWidget()
	self.bindData.confirmBtn.luaClick = self:CreateAction(self.OnClickConfirmBtn)
	self.bindData.closeChaosInfoBtn.luaClick = self:CreateAction(self.OnClickCloseChaosInfoBtn)
	self.bindData.backBtn.luaClick = self:CreateAction(self.OnClickBackBtn)
	self.bindData.chaosList.luaSimpleRenderItem = self:CreateAction(self.OnRenderChaosListItem)
	self.bindData.frontChaosList.luaSimpleRenderItem = self:CreateActionWithArgs(self.OnRenderChaosTeamListItem, -1)
	self.bindData.middleChaosList.luaSimpleRenderItem = self:CreateActionWithArgs(self.OnRenderChaosTeamListItem, -2)
	self.bindData.backChaosList.luaSimpleRenderItem = self:CreateActionWithArgs(self.OnRenderChaosTeamListItem, -3)
	self.bindData.deleteAreaBtn.luaHover = self:CreateAction(self.OnHoverDeleteArea)
	self.bindData.deleteAreaBtn.luaUnhover = self:CreateAction(self.OnUnhoverDeleteArea)
end

function M:RegisterTooltip()
	self.chaosInfoStore = gStoreManager:GetStoreGroup(self.bindData.chaosInfoTooltipWidget.Store):GetStoreByWidget(self.bindData.chaosInfoTooltipWidget)
	self.equipInfoStore = gStoreManager:GetStoreGroup(self.bindData.chaosEquipInfoWidget.Store):GetStoreByWidget(self.bindData.chaosEquipInfoWidget)
	self.chaosInfoStore.attributeList.luaSimpleRenderItem = self:CreateAction(self.OnRenderChaosAttributeListItem)
	self.chaosInfoStore.equipList.luaSimpleRenderItem = self:CreateAction(self.OnRenderEquipListItem)
	self.equipInfoStore.attributeList.luaSimpleRenderItem = self:CreateAction(self.OnRenderEquipAttributeListItem)
	self.equipInfoStore.skillList.luaSimpleRenderItem = self:CreateAction(self.OnRenderEquipSkillListItem)
end

function M:OnClickConfirmBtn()
	gPanelManager:Close(gPanelId.CHAOS_EDIT_TEAM_FULLSCREEN)

	if gBattlePetsMgr.maxCost < self.totalCost then
		return
	end

	self:AskStartGame()
end

function M:OnClickCloseChaosInfoBtn()
	self:HideChaosTooltip()
end

function M:OnClickBackBtn()
	gPanelManager:Close(gPanelId.CHAOS_EDIT_TEAM_FULLSCREEN)

	if self.isReplay then
		self:AskFinishGame(true)
	end
end

function M:OnHoverDeleteArea()
	if self.isDragging then
		self.isHoverDeleteArea = true
	end
end

function M:OnUnhoverDeleteArea()
	self.isHoverDeleteArea = false
end

function M:OnRenderChaosListItem(btn, index)
	local store = gStoreManager:GetStoreGroup("ChaosCardTemplate"):GetStoreByWidget(btn)

	if not store then
		return
	end

	local data = self.chaosList[index + 1]
	store.lihuiId = data.lihuiId
	store.hideCost = data.hideCost
	store.stateCtrl = data.isInTeam and CardState.InTeam or CardState.Normal
	store.cost = data.cost
	btn.draggable = not data.isInTeam
	local param = {
		index = index,
		store = store,
		btn = btn
	}
	btn.luaClick = self:CreateActionWithArgs(self.OnClickChaosListItem, param)

	if not data.isInTeam then
		btn.luaBeginDrag = self:CreateActionWithArgs(self.OnBeginDragChaosListItem, param)
		btn.luaEndDrag = self:CreateActionWithArgs(self.OnEndDragChaosListItem, param)
	else
		btn.luaBeginDrag = nil
		btn.luaEndDrag = nil
	end
end

function M:OnClickChaosListItem(param)
	local data = self.chaosList[param.index + 1]

	if not data then
		return
	end

	self:ShowChaosTooltip(data.Id)
	self:SetSelectedBtn(param.btn)
end

function M:OnBeginDragChaosListItem(param)
	local data = self.chaosList[param.index + 1]

	if not data then
		return
	end

	if self.isDragging then
		return
	end

	param.store.stateCtrl = CardState.Drag
	self.dragRow = nil
	self.dragCol = param.index

	self:BeginDrag(data.Id, param.btn)
end

function M:OnEndDragChaosListItem(param)
	local data = self.chaosList[param.index + 1]

	if not data then
		return
	end

	if not self.isDragging then
		return
	end

	param.store.stateCtrl = CardState.Normal

	self:EndDrag()
end

function M:OnRenderChaosTeamListItem(row, btn, index)
	local store = gStoreManager:GetStoreGroup("ChaosHexagonCardStore"):GetStoreByWidget(btn)

	if not store then
		return
	end

	local chaosId = self.teamDic[row][index]
	local chaos = gBattlePetsMgr:GetPetDataById(chaosId)
	store.isFillCtrl = chaosId and IsFillCtrl.Fill or IsFillCtrl.Empty
	btn.draggable = chaosId ~= nil
	local param = {
		row = row,
		index = index,
		store = store,
		btn = btn
	}

	if chaosId then
		self:RefreshChaosHexagonCard(chaosId, store)

		btn.luaClick = self:CreateActionWithArgs(self.OnClickChaosTeamListItem, param)
		btn.luaBeginDrag = self:CreateActionWithArgs(self.OnBeginDragChaosTeamListItem, param)
		btn.luaEndDrag = self:CreateActionWithArgs(self.OnEndDragChaosTeamListItem, param)
		btn.luaRightClick = self:CreateActionWithArgs(self.OnRightClickChaosTeamListItem, param)
	end

	btn.luaHover = self:CreateActionWithArgs(self.OnHoverChaosTeamListItem, param)
	btn.luaUnhover = self:CreateActionWithArgs(self.OnUnhoverChaosTeamListItem, param)
end

function M:OnHoverChaosTeamListItem(param)
	self.hoverRow = param.row
	self.hoverCol = param.index

	if self.teamDic[param.row][param.index] then
		param.store.fillStateCtrl = FillState.Absorb
		param.store.emptyStateCtrl = EmptyState.Normal
	else
		param.store.emptyStateCtrl = EmptyState.Absorb
		param.store.fillStateCtrl = FillState.Normal
	end
end

function M:OnUnhoverChaosTeamListItem(param)
	if self.hoverRow == param.row and self.hoverCol == param.index then
		self.hoverRow = nil
		self.hoverCol = nil
	end

	param.store.fillStateCtrl = FillState.Normal
	param.store.emptyStateCtrl = EmptyState.Normal
end

function M:OnClickChaosTeamListItem(param)
	local chaosId = self.teamDic[param.row][param.index]

	if not chaosId then
		return
	end

	self:ShowChaosTooltip(chaosId)
	self:SetSelectedBtn(param.btn)
end

function M:OnRightClickChaosTeamListItem(param)
	local chaosId = self.teamDic[param.row][param.index]

	if not chaosId then
		return
	end

	self:RemoveFromTeam(param.row, param.index)
	self:RefreshCost()
	self:RefreshCount()
	self:RefreshConfirmBtn()
end

function M:OnBeginDragChaosTeamListItem(param)
	local chaosId = self.teamDic[param.row][param.index]

	if not chaosId then
		return
	end

	if self.isDragging then
		return
	end

	param.store.isFillCtrl = IsFillCtrl.Empty

	self:SetShowDeleteArea(true)

	self.dragRow = param.row
	self.dragCol = param.index

	self:BeginDrag(chaosId, param.btn)
end

function M:OnEndDragChaosTeamListItem(param)
	if not self.teamDic[param.row][param.index] then
		return
	end

	if not self.isDragging then
		return
	end

	param.store.isFillCtrl = IsFillCtrl.Fill

	self:EndDrag()
end

function M:OnRenderChaosAttributeListItem(btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local data = self.chaosAttributeList[index + 1]

	gBattlePetsMgr:RefreshAttributeListItem(store, data)
end

function M:OnRenderEquipListItem(btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local data = self.equipList[index + 1]

	gBattlePetsMgr:RefreshEquipListItem(store, data)

	btn.luaClick = self:CreateActionWithArgs(self.OnClickEquipListItem, {
		index = index
	})
end

function M:OnClickEquipListItem(param)
	self:ShowEquipTooltip(param.index)
end

function M:OnRenderEquipAttributeListItem(btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local data = self.equipAttributeList[index + 1]

	gBattlePetsMgr:RefreshAttributeListItem(store, data)
end

function M:OnRenderEquipSkillListItem(btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local data = self.equipSkillList[index + 1]

	gBattlePetsMgr:RefreshSkillListItem(store, data)
end

function M:BeginDrag(chaosId, btn)
	if not chaosId then
		return
	end

	self.curDragChaosId = chaosId
	self.isDragging = true
	local dragHexagon = btn.replicaWidget
	dragHexagon.visibility = SGUI.EVisibility.HitTestInvisible
	dragHexagon.rectTransform.localScale = self.bindData.rightAreaWidget.rectTransform.localScale
	self.dragCardStore = gStoreManager:GetStoreGroup(dragHexagon.Store):GetStoreByWidget(dragHexagon)
	self.dragCardStore.fillStateCtrl = FillState.Drag

	self:RefreshChaosHexagonCard(chaosId, self.dragCardStore)
end

function M:EndDrag()
	self.isDragging = false

	self:CheckEndDrag()
	self:RefreshCost()
	self:RefreshCount()
	self:RefreshConfirmBtn()

	self.dragRow = nil
	self.dragCol = nil
	self.hoverRow = nil
	self.hoverCol = nil
	self.isHoverDeleteArea = false

	self:SetShowDeleteArea(false)
end

function M:CheckEndDrag()
	if self.isHoverDeleteArea then
		self:RemoveFromTeam(self.dragRow, self.dragCol)

		return
	end

	if not self.hoverRow or not self.hoverCol then
		return
	else
		local hoverId = self.teamDic[self.hoverRow][self.hoverCol]

		if hoverId == self.curDragChaosId then
			return
		end

		local isExchange = self.dragRow ~= nil

		if not isExchange then
			local oldCost = self:GetCostById(hoverId)
			local newCost = self:GetCostById(self.curDragChaosId)
			local totalCost = self.totalCost + newCost - oldCost

			if gBattlePetsMgr.maxCost < totalCost then
				local textId = LTConfig.ChaosMasterConfig.MaxCostText
				local message = LTConfig.TextCommonTextConfig.GetConfig(textId).Text
				slot8 = self.npcName

				gDisplayMessageMgr:ShowMessageContent(message)

				return
			end
		end

		if isExchange then
			self:AddToTeam(hoverId, self.dragRow, self.dragCol)
		else
			self:RemoveFromTeam(self.hoverRow, self.hoverCol)
		end

		self:AddToTeam(self.curDragChaosId, self.hoverRow, self.hoverCol)
	end
end

function M:AddToTeam(chaosId, row, col)
	self.teamDic[row][col] = chaosId

	self.listList[row]:RefreshElement(col)

	if not chaosId then
		return
	end

	for i, v in ipairs(self.chaosList) do
		if v.Id == chaosId then
			if not v.isInTeam then
				v.isInTeam = true

				self.bindData.chaosList:RefreshElement(i - 1)
			end

			break
		end
	end
end

function M:RemoveFromTeam(row, col)
	local chaosId = self.teamDic[row][col]

	if not chaosId then
		return
	end

	self.teamDic[row][col] = nil

	self.listList[row]:RefreshElement(col)

	for i, v in ipairs(self.chaosList) do
		if v.Id == chaosId then
			v.isInTeam = false

			self.bindData.chaosList:RefreshElement(i - 1)

			break
		end
	end
end

function M:RefreshCost()
	self.bindData.maxCostText = gBattlePetsMgr.maxCost
	self.totalCost = self:GetTotalCost()
	self.bindData.totalCostText = self.totalCost
end

function M:RefreshCount()
	self.bindData.maxNumberText = gBattlePetsMgr.maxChaosInTeam
	self.totalNumber = self:GetTotalCount()
	self.bindData.totalNumberText = self.totalNumber
end

function M:ShowChaosTooltip(chaosId)
	self.curToolTipChaosId = chaosId
	self.curToolTipChaos = gBattlePetsMgr:GetPetDataById(chaosId)

	self:RefreshChaosTooltip(self.curToolTipChaos)
	self:SetShowChaosTooltip(true)
	self:SetShowEquipTooltip(false)
end

function M:HideChaosTooltip()
	self:CancelSelectedBtn()

	self.curToolTipChaosId = nil

	self:SetShowChaosTooltip(false)
	self:SetShowEquipTooltip(false)
end

function M:ShowEquipTooltip(index)
	local dic = {
		[0] = LTConfig.ChaosMasterBodyConfig.GetConfig(self.curToolTipChaos.Body),
		LTConfig.ChaosMasterCampConfig.GetConfig(self.curToolTipChaos.Camp),
		LTConfig.ChaosMasterWeaponConfig.GetConfig(self.curToolTipChaos.Weapon)
	}
	local cfg = dic[index]

	self:RefreshEquipTooltip(cfg, index == 2)
	self:SetShowEquipTooltip(true)
end

function M:RefreshChaosTooltip(chaos)
	local limboChaConfig = gBattlePetsMgr:GetChaosLimboChaConfig(chaos.LimboChaId)
	self.chaosInfoStore.nameText = limboChaConfig.Name
	self.chaosInfoStore.costText = gBattlePetsMgr:GetChaosCost(chaos)
	self.chaosInfoStore.roleText = gBattlePetsMgr:GetChaosRoleName(limboChaConfig)
	self.chaosInfoStore.avatarIconId = limboChaConfig.HeadIconID
	local attrs = gBattlePetsMgr:GetChaosAttributes(chaos)
	self.chaosAttributeList = gBattlePetsMgr:GetChaosAttributeList(attrs)

	self.chaosInfoStore.attributeList:SetSimpleList(#self.chaosAttributeList)

	local bodyEquip = gBattlePetsMgr:GetChaosEquipItemDataByBody(chaos.Body)
	local campEquip = gBattlePetsMgr:GetChaosEquipItemDataByCamp(chaos.Camp)
	local weaponEquip = gBattlePetsMgr:GetChaosEquipItemDataByWeapon(chaos.Weapon)
	self.equipList = {
		bodyEquip,
		campEquip,
		weaponEquip
	}

	self.chaosInfoStore.equipList:SetSimpleList(#self.equipList)

	local skillWidget = self.chaosInfoStore.skillWidget
	local skillStore = gStoreManager:GetStoreGroup(skillWidget.Store):GetStoreByWidget(skillWidget)

	if not limboChaConfig or not limboChaConfig.TalentBuff or #limboChaConfig.TalentBuff == 0 then
		return
	end

	local skillCfg = LTConfig.ChaosMasterPassiveSkillConfig.GetConfig(limboChaConfig.TalentBuff[1])

	if skillCfg then
		local data = {
			name = skillCfg.Name,
			type = LTConfig.TextScriptTextConfig.GetConfig(89901196).Text,
			description = skillCfg.Effect
		}

		gBattlePetsMgr:RefreshSkillListItem(skillStore, data)
	end
end

function M:RefreshEquipTooltip(cfg, isWeapon)
	self.equipInfoStore.nameText = cfg.BodyName or cfg.CampName or cfg.WeaponName
	local equipAttrs = gBattlePetsMgr:GetEquipAttributes(cfg)
	self.equipAttributeList = gBattlePetsMgr:GetEquipAttributeList(equipAttrs)

	self.equipInfoStore.attributeList:SetSimpleList(#self.equipAttributeList)

	local skillList = {}

	if not isWeapon then
		skillList = gBattlePetsMgr:GetBodyCampSkillList(cfg)
	else
		local limboChaCfg = LTConfig.ChaosMasterLimboChaConfig.GetConfig(self.curToolTipChaos.LimboChaId)
		skillList = gBattlePetsMgr:GetWeaponSkillList(limboChaCfg)
	end

	self.equipSkillList = skillList

	self.equipInfoStore.skillList:SetSimpleList(#skillList)
end

function M:SetShowChaosTooltip(isShow)
	self.bindData.showChaosTooltipCtrl = isShow and 0 or 1
end

function M:SetShowDeleteArea(isShow)
	self.bindData.showDeleteAreaCtrl = isShow and 0 or 1
end

function M:SetShowEquipTooltip(isShow)
	self.bindData.showEquipInfoCtrl = isShow and 0 or 1
end

function M:GetTotalCost()
	local totalCost = 0

	for row, colDic in pairs(self.teamDic) do
		for col, chaosId in pairs(colDic) do
			local chaos = gBattlePetsMgr:GetPetDataById(chaosId)
			totalCost = totalCost + gBattlePetsMgr:GetChaosCost(chaos)
		end
	end

	return totalCost
end

function M:GetTotalCount()
	local count = 0

	for row, colDic in pairs(self.teamDic) do
		for col, chaosId in pairs(colDic) do
			count = count + 1
		end
	end

	return count
end

function M:PrintTeamInfo(datas)
	local infos = {}

	for i, v in pairs(datas) do
		table.insert(infos, string.format("q:%d r:%d s:%d id:%d", v.q, v.r, v.s, ulong.tostring(v.pokemonId)))
	end

	print("当前编队信息：", table.concat(infos, " | "))
end

function M:RefreshChaosHexagonCard(chaosId, store)
	local chaos = gBattlePetsMgr:GetPetDataById(chaosId)
	local cfg = LTConfig.ChaosMasterLimboChaConfig.GetConfig(chaos.LimboChaId)
	store.iconId = cfg.CardIcon
	store.costText = gBattlePetsMgr:GetChaosCost(chaos)
end

function M:GetPokemonTeamDataList()
	local dataList = {}

	for row, colDic in pairs(self.teamDic) do
		for col, chaosId in pairs(colDic) do
			local cube = self:GetCubeCoordByRowCol(row, col)
			local data = {
				q = cube.q,
				r = cube.r,
				s = cube.s,
				pokemonId = chaosId
			}

			table.insert(dataList, data)
		end
	end

	return dataList
end

function M:GetPokemonTeamTestDataList()
	local dataList = {}

	for row, colDic in pairs(self.teamDic) do
		for col, chaosId in pairs(colDic) do
			local cube = self:GetCubeCoordByRowCol(row, col)
			local chaos = gBattlePetsMgr:GetPetDataById(chaosId)
			local chaosTemplateId = chaos.LimboChaId
			local data = {
				q = -cube.q,
				r = -cube.r,
				s = -cube.s,
				TemplateId = chaosTemplateId
			}

			table.insert(dataList, data)
		end
	end

	return dataList
end

function M:GetRowColByCubeCoord(cube)
	local row = cube.r
	local startQ = math.floor((cube.r + 1) / 2) - 2
	local col = cube.q - startQ

	return row, col
end

function M:GetCubeCoordByRowCol(row, col)
	local cube = {}
	local startQ = -math.floor((5 + row) / 2)
	cube.q = col + startQ
	cube.r = row
	cube.s = -cube.q - cube.r

	return cube
end

function M:GetMousePos()
	return gCS.LuaUtils.TransformScreenPointToUI(self.rootWidget.rectTransform, UnityEngine.Input.mousePosition)
end

function M:SetSelectedBtn(btn)
	self:CancelSelectedBtn()

	if btn then
		btn.isSelected = true
		self.curSelectedBtn = btn
	end
end

function M:CancelSelectedBtn()
	if self.curSelectedBtn then
		self.curSelectedBtn.isSelected = false
		self.curSelectedBtn = nil
	end
end

function M:RefreshConfirmBtn()
	if self.totalCount <= 0 then
		self.bindData.confirmBtn.interactable = false
	end

	self.bindData.confirmBtn.interactable = true
end

function M:GetCostById(chaosId)
	local chaos = gBattlePetsMgr:GetPetDataById(chaosId)

	return gBattlePetsMgr:GetChaosCost(chaos)
end

function M:AskStartGame()
	if not self.isReplay then
		gBattlePetsMgr.lastPlayerPos = gCS.MyPlayerManager.PlayerUnit.Position
	end

	if not self.isEnemy then
		local teamInfo = self:GetPokemonTeamDataList()

		gBattlePetsMgr:RestoreTeamInfo(teamInfo)
	else
		local teamInfo = self:GetPokemonTeamTestDataList()

		gBattlePetsMgr:RestoreTeamTestInfo(teamInfo)
	end

	gBattlePetsMgr:AskStartGame(self.isReplay, self.isEnemy)
end

function M:AskFinishGame(needTeleport)
	if not self.isAskFinish then
		self.isAskFinish = true

		gClientToGameSceneDelegate:AskPlayerOnBVBFinish(not needTeleport).Callback = function (err)
			if err ~= LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)
			end
		end
	end
end
