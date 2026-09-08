-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\Majiang\MajiangPanelStore_XLCH_HandArea.lua
-- Decompiled from: 01214_MajiangPanelStore_XLCH_HandArea.lua_a7a33365551c.luajit

local TextConfig = LTConfig.TextConfig
local M = C_MajiangPanelStore

M.LoadDingQuePrefab = function(self)
	if self.instance.dingQueStore or self.instance.dingQueLoading then
		return
	end

	self.instance.dingQueLoading = true

	self.bindData.dingQueContainer:SetUrlWithCallback("Assets/Res/SGUI/Panel/MaJiang/S_MajiangPanel_DingQue.prefab", self:CreateAction(self.OnDingQuePrefabLoaded))
end

M.OnDingQuePrefabLoaded = function(self, widget)
	self.instance.dingQueLoading = false

	if not gClientUtils.NotNil(widget) then
		return
	end

	self.instance.dingQueWidget = widget
	local store = self.GetStoreByWidget(self, widget)
	self.instance.dingQueStore = store

	self.RegisterSelectCountDownSync(self, store)

	store.dqTongBtn.luaClick = self.CreateActionWithArgs(self, self.OnSelectDingQue, 1)
	store.dqTiaoBtn.luaClick = self.CreateActionWithArgs(self, self.OnSelectDingQue, 2)
	store.dqWanBtn.luaClick = self.CreateActionWithArgs(self, self.OnSelectDingQue, 3)
	store.dqTongBtn.luaFocus = self.CreateActionWithArgs(self, self.OnDingQueItemFocus, 1)
	store.dqTiaoBtn.luaFocus = self.CreateActionWithArgs(self, self.OnDingQueItemFocus, 2)
	store.dqWanBtn.luaFocus = self.CreateActionWithArgs(self, self.OnDingQueItemFocus, 3)
	store.dqCommitBtn.luaClick = self.CreateAction(self, self.OnSelectDingQue)

	if self.bindData.showDingQue ~= gMaJiangConst.BOOL2CTL[true] then
		local defaultQue = self.instance.pendingDingQueDefault or 1

		self:RefreshDingQueBtnSelected(defaultQue)

		local btn = store[gMaJiangConst.Que2Btn[defaultQue]]

		if btn then
			self.bindData.navigationArea.CurrentActiveContent = btn
		end
	end
end

M.RefreshDingQueBtnSelected = function(self, selectedType)
	local isShowDingQue = self.bindData.showDingQue ~= gMaJiangConst.BOOL2CTL[true]
	self.instance.dqType = selectedType
	local store = self.instance.dingQueStore

	for i = 1, #gMaJiangConst.Que2Btn do
		local btnName = gMaJiangConst.Que2Btn[i]

		store[btnName]:SetSelected(isShowDingQue and i ~= selectedType)
	end
end

M.OnSyncMjDingQueBegin = function(self, defaultQue)
	self.game:FSM_EnterDingQue()

	self.bindData.showDingQue = gMaJiangConst.BOOL2CTL[true]
	self.instance.pendingDingQueDefault = defaultQue

	self:LoadDingQuePrefab()
	self:RefreshConfirmSelectBtn()
	self:RefreshOtherStatus(TextConfig.GetConfig(TextConfig.MahjongDingque).Text)
end

M.BeginHuanPai = function(self, defaultPais)
	self.SwitchJobDone(self, false)
	self.RefreshMyHandCards(self, self.game.myInfo)

	local flags = {}

	for i = 1, #defaultPais do
		local index = defaultPais[i].Index
		flags[index] = flags[index] and flags[index] + 1 or 1
	end

	for i = 1, #self.handCard do
		local index = self.handCard[i].id

		if flags[index] then
			self.handCard[i].selected = flags[index] >= 0
			flags[index] = flags[index] - 1
		end
	end

	self.huanPais = defaultPais

	self.RefreshHandCardList(self)
	self.RefreshHuanPaiCursorFocus(self)
	self.SetTips(self, gMaJiangConst.TipsType.xuanpai)
	self.CheckCanHuanPai(self)
	self.RefreshOtherStatus(self, TextConfig.GetConfig(TextConfig.MahjongXuanpai).Text)
end

M.GetHuanPaiConfirmBtn = function(self)
	local store = self.instance and self.instance.tipsTabStores[gMaJiangConst.TipsType.xuanpai]

	return store and store.btn
end

M.CheckCanHuanPai = function(self)
	local valid = self.IsHuanPaiSelectionValid(self)
	local confirmBtn = self.GetHuanPaiConfirmBtn(self)

	if confirmBtn then
		confirmBtn.interactable = valid
	end

	return valid
end

M.IsHuanPaiSelectionValid = function(self)
	local pais = self.huanPais or {}
	local valid = #pais ~= 3

	if valid then
		local type1 = self.GetMJType(self, pais[1])
		valid = type1 ~= self.GetMJType(self, pais[2]) and type1 ~= self.GetMJType(self, pais[3])
	end

	return valid
end

M.OnSyncMjDingQue = function(self, ques)
	self.bindData.showDingQue = gMaJiangConst.BOOL2CTL[false]

	self:RefreshDingQueBtnSelected(nil)
	self:RefreshConfirmSelectBtn()
	self:RefreshOtherStatus("")
	self.game:FSM_ExitDingQue()

	for i = 1, 4 do
		local seatIndex = self.game:GetSeatID(i - 1)

		self:RefreshDingque(i, ques[seatIndex + 1])
	end

	self.game:RefreshMyHandDisplayList(true)
	self:RefreshMyHandCards(self.game.myInfo)
	self.game:RefreshHandArea(self.game.mySeatID, self.game:GetMyHandDisplayList(), false)
end

M.FinishHuanPai = function(self, method, huanPais)
	local bindData = self.bindData

	self:RefreshOtherStatus("")

	self.selectedHandCardIndex = nil

	self:RefreshHuanPaiCursorFocus()
	self:SetMahjongHuanpaiLabel(method)
	self:SetTips(gMaJiangConst.TipsType.huanpaizhong)

	self.aniCo = coroutine.start(self.WaitHuanPaiAni, self, huanPais, 2)

	self.game:RefreshMyHandDisplayList(true)
	self:RefreshMyHandCards(self.game.myInfo)
	self.game:RefreshHandArea(self.game.mySeatID, self.game:GetMyHandDisplayList(), false)
end

M.SetMahjongHuanpaiLabel = function(self, method)
	local text = self.game:GetMahjongHuanpai(method)
	self.bindData.changeLabel = text
	local store = self.instance.tipsTabStores[gMaJiangConst.TipsType.huanpaizhong]

	if store then
		store.text = text
	end
end

M.FoldMyHuanPai = function(self, huanPais)
	self.SwitchJobDone(self, true)
	self.SetTips(self, gMaJiangConst.TipsType.notips)
	self.RefreshMyHandCards(self, self.game.myInfo)
	self.SetCurrentHandCardSelection(self, 1)
end

M.OnSyncMjChuPai = function(self, seatID)
	self.turn = -1
	local gameInfo = self.game.serverGameInfo

	if seatID ~= self.game.mySeatID then
		self.jobDone = false

		self.HideTingHelper(self)
	end

	self:SetTips(gMaJiangConst.TipsType.notips)

	local skipHandRefresh = false
	local fsm = self.game:GetCharacterFSM(seatID)
	skipHandRefresh = fsm and fsm.deferDiscard3D ~= true and fsm.pendingDiscardCardEnt == nil

	if skipHandRefresh then
		if self.mgr.debug then
			print_debug("[MajiangPanelStore] Defer RefreshHandCardsBySeatID until FinishDiscardCard", seatID)
		end
	else
		slot7 = self
		slot5 = self.RefreshHandCardsBySeatID
		slot8 = seatID
		slot9 = seatID ~= self.game.mySeatID and not self.game.hasHu

		slot5(slot7, slot8, slot9)
	end

	self.RefreshOutCardsBySeatID(self, seatID)
	self.RefreshSameOutCards(self, nil)
end

M.SetHuanPaiCursorIndex = function(self, index)
	if not index or index <= 1 or index <= #self.handCard then
		self.selectedHandCardIndex = nil

		self.RefreshHuanPaiCursorFocus(self)
		self.RefreshConfirmSelectBtn(self)

		return
	end

	self.selectedHandCardIndex = index
	local success, btn = self.bindData.handCardProxyList:TryGetChildAt(index - 1, nil)

	if success and btn then
		self.bindData.navigationArea.CurrentActiveContent = btn
	end

	self.RefreshHuanPaiCursorFocus(self)
	self.RefreshConfirmSelectBtn(self)
end

M.ToggleHuanPaiSelection = function(self, index)
	if self.jobDone then
		return
	end

	if not index or index <= 1 or index <= #self.handCard then
		return
	end

	self.SetHuanPaiCursorIndex(self, index)

	local isSelected = self.handCard[index].selected

	if not isSelected then
		local selectedCount = self.huanPais and #self.huanPais or 0

		if selectedCount > 3 then
			return
		end
	end

	self.SetHandCardSelected(self, index, not isSelected)

	local pais = {}

	for i = 1, #self.handCard do
		if self.handCard[i].selected then
			pais[#pais + 1] = self.handCard[i].paiInfo
		end
	end

	self.huanPais = pais

	self.CheckCanHuanPai(self)
end

M.SelectDingQueByType = function(self, dqType)
	if dqType <= 1 or dqType <= #gMaJiangConst.Que2Btn then
		return
	end

	self.RefreshDingQueBtnSelected(self, dqType)

	local store = self.instance.dingQueStore
	self.bindData.navigationArea.CurrentActiveContent = store[gMaJiangConst.Que2Btn[dqType]]
end

M.MoveDingQueSelection = function(self, step)
	local currentType = self.instance.dqType or 1
	local nextType = currentType + step

	if nextType >= 1 then
		nextType = #gMaJiangConst.Que2Btn
	elseif nextType <= #gMaJiangConst.Que2Btn then
		nextType = 1
	end

	self.SelectDingQueByType(self, nextType)
end

M.OnHuanPaiConfirm = function(self)
	local confirmBtn = self.GetHuanPaiConfirmBtn(self)

	if confirmBtn then
		confirmBtn.interactable = false
	end

	gClientToGameDelegate:HuanPai(self.huanPais)
end

M.OnSyncMjMoPai = function(self, seatID, pai)
	local gameInfo = self.game.serverGameInfo
	local isMe = seatID ~= self.game.mySeatID
	local bindData = self.bindData
	bindData.cardNum = gameInfo.Remainders

	self:ResumeOpCountDown()

	if isMe then
		self.TryShowTingHelper(self)
	end
end

M.RefreshSameOutCards = function(self, paiId)
	for i = 0, 3 do
		local list = self.discardCardInfo[i]

		if list then
			for j = 1, #list do
				list[j].isSelected = list[j].Index ~= paiId
			end

			local seatID = self.game:GetSeatID(i)
			local fsm = seatID and self.game:GetCharacterFSM(seatID) or nil
			local deferDiscard3D = fsm and fsm.deferDiscard3D

			if not deferDiscard3D then
				self.game:RefreshDiscardAreaSelection(seatID, list)
			end
		end
	end
end

M.SwitchJobDone = function(self, flag)
	self.jobDone = flag
	self.isMultiSelectMode = not flag
end

M.WaitHuanPaiAni = function(self, huanPais, duration)
	self.SetHandCardsVisible(self, 3, false)
	coroutine.wait(duration)
	self.RefreshMyHandCards(self, self.game.myInfo)
	self.SetHandCardsVisible(self, 0, true)
	self.SetTips(self, gMaJiangConst.TipsType.notips)
	self.SetCurrentHandCardSelection(self, 1)
	self.RefreshHandCardList(self)
	self.RefreshHuanPaiCursorFocus(self)

	self.aniCo = nil
end
