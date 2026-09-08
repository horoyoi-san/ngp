-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ChaosEditTeamFullscreenStore.lua
-- Decompiled from: 01461_ChaosEditTeamFullscreenStore.lua_cf6253f59a4b.luajit

local ChaosMasterConfig = LTConfig.ChaosMasterConfig
C_ChaosEditTeamFullscreenStore = DefClass("C_ChaosEditTeamFullscreenStore", C_ChaosEditTeamFullscreenStore, C_StoreGroup)
GroupName2Class.ChaosEditTeamFullscreenStore = C_ChaosEditTeamFullscreenStore
local M = C_ChaosEditTeamFullscreenStore
local IsFillCtrl = {
	["\\+qW"] = 0,
	["h\\xa3\\xb2\\xbb\\xaf"] = 1
}
local FillState = {
	["^0|\\"] = 1,
	["=J\\x82\\x81\\x91C"] = 2,
	["2G\\x83\\x83\\x82M"] = 0
}
local EmptyState = {
	["=J\\x82\\x81\\x91C"] = 1,
	["2G\\x83\\x83\\x82M"] = 0
}
local CardState = {
	["^0|\\"] = 1,
	["5F\\xa5\\x8b\\x82L"] = 2,
	["2G\\x83\\x83\\x82M"] = 0
}

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
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
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
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

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.OnUpdate = function(self)
end

M.RefreshChaosList = function(self, needSort)
	local allChaos = needSort and gBattlePetsMgr.petDataDic or self.chaosList
	self.chaosList = {}

	for k, v in pairs(allChaos) do
		local chaos = gBattlePetsMgr:GetPetDataById(v.Id)
		local cfg = gBattlePetsMgr:GetChaosLimboChaConfig(chaos.LimboChaId)

		if cfg then
			local item = {
				["\\xa2\\xa2,\\xa5^;\\xff>"] = false,
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
			return b.cost <= a.cost
		end)
	end

	self.bindData.chaosList:SetSimpleList(#self.chaosList)

	if needSort then
		self.bindData.chaosList:SetNavSelectToTop()
	end
end

M.RefreshChaosTeamList = function(self)
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

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.confirmBtn.luaClick = self.CreateAction(self, self.OnClickConfirmBtn)
	self.bindData.closeChaosInfoBtn.luaClick = self.CreateAction(self, self.OnClickCloseChaosInfoBtn)
	self.bindData.backBtn.luaClick = self.CreateAction(self, self.OnClickBackBtn)
	self.bindData.chaosList.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderChaosListItem)
	self.bindData.frontChaosList.luaSimpleRenderItem = self.CreateActionWithArgs(self, self.OnRenderChaosTeamListItem, -1)
	self.bindData.middleChaosList.luaSimpleRenderItem = self.CreateActionWithArgs(self, self.OnRenderChaosTeamListItem, -2)
	self.bindData.backChaosList.luaSimpleRenderItem = self.CreateActionWithArgs(self, self.OnRenderChaosTeamListItem, -3)
	self.bindData.deleteAreaBtn.luaHover = self.CreateAction(self, self.OnHoverDeleteArea)
	self.bindData.deleteAreaBtn.luaUnhover = self.CreateAction(self, self.OnUnhoverDeleteArea)
end

M.RegisterTooltip = function(self)
	self.chaosInfoStore = gStoreManager:GetStoreGroup(self.bindData.chaosInfoTooltipWidget.Store):GetStoreByWidget(self.bindData.chaosInfoTooltipWidget)
	self.equipInfoStore = gStoreManager:GetStoreGroup(self.bindData.chaosEquipInfoWidget.Store):GetStoreByWidget(self.bindData.chaosEquipInfoWidget)
	self.chaosInfoStore.attributeList.luaSimpleRenderItem = self:CreateAction(self.OnRenderChaosAttributeListItem)
	self.chaosInfoStore.equipList.luaSimpleRenderItem = self:CreateAction(self.OnRenderEquipListItem)
	self.equipInfoStore.attributeList.luaSimpleRenderItem = self:CreateAction(self.OnRenderEquipAttributeListItem)
	self.equipInfoStore.skillList.luaSimpleRenderItem = self:CreateAction(self.OnRenderEquipSkillListItem)
end

M.OnClickConfirmBtn = function(self)
	gPanelManager:Close(gPanelId.CHAOS_EDIT_TEAM_FULLSCREEN)

	if gBattlePetsMgr.maxCost >= self.totalCost then
		return
	end

	self.AskStartGame(self)
end

M.OnClickCloseChaosInfoBtn = function(self)
	self.HideChaosTooltip(self)
end

M.OnClickBackBtn = function(self)
	gPanelManager:Close(gPanelId.CHAOS_EDIT_TEAM_FULLSCREEN)

	if self.isReplay then
		self.AskFinishGame(self, true)
	end
end

M.OnHoverDeleteArea = function(self)
	if self.isDragging then
		self.isHoverDeleteArea = true
	end
end

M.OnUnhoverDeleteArea = function(self)
	self.isHoverDeleteArea = false
end

M.OnRenderChaosListItem = function(self, btn, index)
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
		btn.luaBeginDrag = self.CreateActionWithArgs(self, self.OnBeginDragChaosListItem, param)
		btn.luaEndDrag = self.CreateActionWithArgs(self, self.OnEndDragChaosListItem, param)
	else
		btn.luaBeginDrag = nil
		btn.luaEndDrag = nil
	end
end

M.OnClickChaosListItem = function(self, param)
	local data = self.chaosList[param.index + 1]

	if not data then
		return
	end

	self.ShowChaosTooltip(self, data.Id)
	self.SetSelectedBtn(self, param.btn)
end

M.OnBeginDragChaosListItem = function(self, param)
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

	self.BeginDrag(self, data.Id, param.btn)
end

M.OnEndDragChaosListItem = function(self, param)
	local data = self.chaosList[param.index + 1]

	if not data then
		return
	end

	if not self.isDragging then
		return
	end

	param.store.stateCtrl = CardState.Normal

	self.EndDrag(self)
end

M.OnRenderChaosTeamListItem = function(self, row, btn, index)
	local store = gStoreManager:GetStoreGroup("ChaosHexagonCardStore"):GetStoreByWidget(btn)

	if not store then
		return
	end

	local chaosId = self.teamDic[row][index]
	local chaos = gBattlePetsMgr:GetPetDataById(chaosId)
	store.isFillCtrl = chaosId and IsFillCtrl.Fill or IsFillCtrl.Empty
	btn.draggable = chaosId == nil
	local param = {
		row = row,
		index = index,
		store = store,
		btn = btn
	}

	if chaosId then
		self.RefreshChaosHexagonCard(self, chaosId, store)

		btn.luaClick = self.CreateActionWithArgs(self, self.OnClickChaosTeamListItem, param)
		btn.luaBeginDrag = self.CreateActionWithArgs(self, self.OnBeginDragChaosTeamListItem, param)
		btn.luaEndDrag = self.CreateActionWithArgs(self, self.OnEndDragChaosTeamListItem, param)
		btn.luaRightClick = self.CreateActionWithArgs(self, self.OnRightClickChaosTeamListItem, param)
	end

	btn.luaHover = self.CreateActionWithArgs(self, self.OnHoverChaosTeamListItem, param)
	btn.luaUnhover = self.CreateActionWithArgs(self, self.OnUnhoverChaosTeamListItem, param)
end

M.OnHoverChaosTeamListItem = function(self, param)
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

M.OnUnhoverChaosTeamListItem = function(self, param)
	if self.hoverRow ~= param.row and self.hoverCol ~= param.index then
		self.hoverRow = nil
		self.hoverCol = nil
	end

	param.store.fillStateCtrl = FillState.Normal
	param.store.emptyStateCtrl = EmptyState.Normal
end

M.OnClickChaosTeamListItem = function(self, param)
	local chaosId = self.teamDic[param.row][param.index]

	if not chaosId then
		return
	end

	self.ShowChaosTooltip(self, chaosId)
	self.SetSelectedBtn(self, param.btn)
end

M.OnRightClickChaosTeamListItem = function(self, param)
	local chaosId = self.teamDic[param.row][param.index]

	if not chaosId then
		return
	end

	self.RemoveFromTeam(self, param.row, param.index)
	self.RefreshCost(self)
	self.RefreshCount(self)
	self.RefreshConfirmBtn(self)
end

M.OnBeginDragChaosTeamListItem = function(self, param)
	local chaosId = self.teamDic[param.row][param.index]

	if not chaosId then
		return
	end

	if self.isDragging then
		return
	end

	param.store.isFillCtrl = IsFillCtrl.Empty

	self.SetShowDeleteArea(self, true)

	self.dragRow = param.row
	self.dragCol = param.index

	self.BeginDrag(self, chaosId, param.btn)
end

M.OnEndDragChaosTeamListItem = function(self, param)
	if not self.teamDic[param.row][param.index] then
		return
	end

	if not self.isDragging then
		return
	end

	param.store.isFillCtrl = IsFillCtrl.Fill

	self.EndDrag(self)
end

M.OnRenderChaosAttributeListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local data = self.chaosAttributeList[index + 1]

	gBattlePetsMgr:RefreshAttributeListItem(store, data)
end

M.OnRenderEquipListItem = function(self, btn, index)
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

M.OnClickEquipListItem = function(self, param)
	self.ShowEquipTooltip(self, param.index)
end

M.OnRenderEquipAttributeListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local data = self.equipAttributeList[index + 1]

	gBattlePetsMgr:RefreshAttributeListItem(store, data)
end

M.OnRenderEquipSkillListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local data = self.equipSkillList[index + 1]

	gBattlePetsMgr:RefreshSkillListItem(store, data)
end

M.BeginDrag = function(self, chaosId, btn)
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

M.EndDrag = function(self)
	self.isDragging = false

	self.CheckEndDrag(self)
	self.RefreshCost(self)
	self.RefreshCount(self)
	self.RefreshConfirmBtn(self)

	self.dragRow = nil
	self.dragCol = nil
	self.hoverRow = nil
	self.hoverCol = nil
	self.isHoverDeleteArea = false

	self.SetShowDeleteArea(self, false)
end

M.CheckEndDrag = function(self)
	if self.isHoverDeleteArea then
		self.RemoveFromTeam(self, self.dragRow, self.dragCol)

		return
	end

	if not self.hoverRow or not self.hoverCol then
		return
	else
		local hoverId = self.teamDic[self.hoverRow][self.hoverCol]

		if hoverId ~= self.curDragChaosId then
			return
		end

		local isExchange = self.dragRow == nil

		if not isExchange then
			local oldCost = self.GetCostById(self, hoverId)
			local newCost = self.GetCostById(self, self.curDragChaosId)
			local totalCost = self.totalCost + newCost - oldCost

			if gBattlePetsMgr.maxCost >= totalCost then
				local textId = LTConfig.ChaosMasterConfig.MaxCostText
				local message = LTConfig.TextCommonTextConfig.GetConfig(textId).Text
				slot8 = self.npcName

				gDisplayMessageMgr:ShowMessageContent(message)

				return
			end
		end

		if isExchange then
			self.AddToTeam(self, hoverId, self.dragRow, self.dragCol)
		else
			self.RemoveFromTeam(self, self.hoverRow, self.hoverCol)
		end

		self.AddToTeam(self, self.curDragChaosId, self.hoverRow, self.hoverCol)
	end
end

M.AddToTeam = function(self, chaosId, row, col)
	self.teamDic[row][col] = chaosId

	self.listList[row]:RefreshElement(col)

	if not chaosId then
		return
	end

	for i, v in ipairs(self.chaosList) do
		if v.Id ~= chaosId then
			if not v.isInTeam then
				v.isInTeam = true

				self.bindData.chaosList:RefreshElement(i - 1)
			end

			break
		end
	end
end

M.RemoveFromTeam = function(self, row, col)
	local chaosId = self.teamDic[row][col]

	if not chaosId then
		return
	end

	self.teamDic[row][col] = nil

	self.listList[row]:RefreshElement(col)

	for i, v in ipairs(self.chaosList) do
		if v.Id ~= chaosId then
			v.isInTeam = false

			self.bindData.chaosList:RefreshElement(i - 1)

			break
		end
	end
end

M.RefreshCost = function(self)
	self.bindData.maxCostText = gBattlePetsMgr.maxCost
	self.totalCost = self.GetTotalCost(self)
	self.bindData.totalCostText = self.totalCost
end

M.RefreshCount = function(self)
	self.bindData.maxNumberText = gBattlePetsMgr.maxChaosInTeam
	self.totalCount = self.GetTotalCount(self)
	self.bindData.totalNumberText = self.totalCount
end

M.ShowChaosTooltip = function(self, chaosId)
	self.curToolTipChaosId = chaosId
	self.curToolTipChaos = gBattlePetsMgr:GetPetDataById(chaosId)

	self:RefreshChaosTooltip(self.curToolTipChaos)
	self:SetShowChaosTooltip(true)
	self:SetShowEquipTooltip(false)
end

M.HideChaosTooltip = function(self)
	self.CancelSelectedBtn(self)

	self.curToolTipChaosId = nil

	self.SetShowChaosTooltip(self, false)
	self.SetShowEquipTooltip(self, false)
end

M.ShowEquipTooltip = function(self, index)
	local dic = {
		[0] = LTConfig.ChaosMasterBodyConfig.GetConfig(self.curToolTipChaos.Body),
		LTConfig.ChaosMasterCampConfig.GetConfig(self.curToolTipChaos.Camp),
		LTConfig.ChaosMasterWeaponConfig.GetConfig(self.curToolTipChaos.Weapon)
	}
	local cfg = dic[index]

	self:RefreshEquipTooltip(cfg, index ~= 2)
	self:SetShowEquipTooltip(true)
end

M.RefreshChaosTooltip = function(self, chaos)
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

	if not limboChaConfig or not limboChaConfig.TalentBuff or #limboChaConfig.TalentBuff ~= 0 then
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

M.RefreshEquipTooltip = function(self, cfg, isWeapon)
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

M.SetShowChaosTooltip = function(self, isShow)
	self.bindData.showChaosTooltipCtrl = isShow and 0 or 1
end

M.SetShowDeleteArea = function(self, isShow)
	self.bindData.showDeleteAreaCtrl = isShow and 0 or 1
end

M.SetShowEquipTooltip = function(self, isShow)
	self.bindData.showEquipInfoCtrl = isShow and 0 or 1
end

M.GetTotalCost = function(self)
	local totalCost = 0

	for row, colDic in pairs(self.teamDic) do
		for col, chaosId in pairs(colDic) do
			local chaos = gBattlePetsMgr:GetPetDataById(chaosId)
			totalCost = totalCost + gBattlePetsMgr:GetChaosCost(chaos)
		end
	end

	return totalCost
end

M.GetTotalCount = function(self)
	local count = 0

	for row, colDic in pairs(self.teamDic) do
		for col, chaosId in pairs(colDic) do
			count = count + 1
		end
	end

	return count
end

M.PrintTeamInfo = function(self, datas)
	local infos = {}

	for i, v in pairs(datas) do
		table.insert(infos, string.format("q:%d r:%d s:%d id:%s", v.q, v.r, v.s, ulong.tostring(v.pokemonId)))
	end

	print("当前编队信息：", table.concat(infos, " | "))
end

M.RefreshChaosHexagonCard = function(self, chaosId, store)
	local chaos = gBattlePetsMgr:GetPetDataById(chaosId)
	local cfg = LTConfig.ChaosMasterLimboChaConfig.GetConfig(chaos.LimboChaId)
	store.iconId = cfg.CardIcon
	store.costText = gBattlePetsMgr:GetChaosCost(chaos)
end

M.GetPokemonTeamDataList = function(self)
	local dataList = {}

	for row, colDic in pairs(self.teamDic) do
		for col, chaosId in pairs(colDic) do
			local cube = self.GetCubeCoordByRowCol(self, row, col)
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

M.GetPokemonTeamTestDataList = function(self)
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

M.GetCubeCoordByRowCol = function(self, row, col)
	local cube = {}
	local startQ = -math.floor((5 + row) / 2)
	cube.q = col + startQ
	cube.r = row
	cube.s = -cube.q - cube.r

	return cube
end

M.GetMousePos = function(self)
	return gCS.LuaUtils.TransformScreenPointToUI(self.rootWidget.rectTransform, UnityEngine.Input.mousePosition)
end

M.SetSelectedBtn = function(self, btn)
	self.CancelSelectedBtn(self)

	if btn then
		btn.isSelected = true
		self.curSelectedBtn = btn
	end
end

M.CancelSelectedBtn = function(self)
	if self.curSelectedBtn then
		self.curSelectedBtn.isSelected = false
		self.curSelectedBtn = nil
	end
end

M.RefreshConfirmBtn = function(self)
	if self.totalCount < 0 then
		self.bindData.confirmBtn.interactable = false

		return
	end

	self.bindData.confirmBtn.interactable = true
end

M.GetCostById = function(self, chaosId)
	local chaos = gBattlePetsMgr:GetPetDataById(chaosId)

	return gBattlePetsMgr:GetChaosCost(chaos)
end

M.AskStartGame = function(self)
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

M.AskFinishGame = function(self, needTeleport)
	if not self.isAskFinish then
		self.isAskFinish = true
		slot2 = gReliableRpcManager

		slot2:RegisterRPC(gClientToGameSceneDelegate.AskPlayerOnBVBFinish, not needTeleport, function (err)
			if err == LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)
			end
		end)
	end
end
