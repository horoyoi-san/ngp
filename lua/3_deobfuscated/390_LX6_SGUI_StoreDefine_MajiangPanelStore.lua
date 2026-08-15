local GameStateEnum = UX.Game.MjGameStateEnum
local MessageConfig = LTConfig.MessageConfig
local MahjongRoomState = UX.Game.MahjongRoomState
local MjActionType = UX.Game.MjActionType
local TextConfig = LTConfig.TextConfig
local MahjongConfig = LTConfig.MahjongConfig
local MahjongChatType = UX.Game.MahjongChatType
local MahjongPveMahjongNpcTalkConfig = LTConfig.MahjongPveMahjongNpcTalkConfig
local BOOL2CTL = {
	[true] = 0,
	[false] = 1
}
local TIPS_TYPE = {
	auto = 3,
	tips = 2,
	notips = 4,
	matching = 5,
	xuanpai = 0,
	chance = 6,
	fixed = 7,
	huanpaizhong = 1
}
local OP_EFFECT_ACTION = {
	GangShangKaiHua = 4,
	HaiDiLaoYue = 5,
	Hu = 2,
	HuJiaoZhuanYi = 6,
	Gang = 1,
	Peng = 0,
	WeiTingPai = 9,
	He = 12,
	ChaHuaZhu = 7,
	None = 13,
	ZiMo = 3,
	Chi = 10,
	TuiShui = 8,
	Reach = 11
}
C_MajiangPanelStore = DefClass("C_MajiangPanelStore", C_MajiangPanelStore, C_StoreGroup)
GroupName2Class.MajiangPanelStore = C_MajiangPanelStore
local M = C_MajiangPanelStore

function M:ctor()
	self.mgr = gMaJiangManager
end

function M:OnAwake()
	self.avatarStore = {}
	self.feedbackStore = {}
	self.handCard = {}
	self.bindData.handCardList.luaSimpleRenderItem = self:CreateAction(self.OnRenderHandCardItem)
	self.bindData.handCardList.luaSimpleClick = self:CreateAction(self.OnHandCardClick)
	self.bindData.tingList.luaSimpleRenderItem = self:CreateAction(self.OnRenderTingCardItem)
	self.bindData.autoBtn.luaClick = self:CreateAction("OnBeginAutoMode")
	self.bindData.unAutoBtn.luaClick = self:CreateAction("OnBeginAutoMode")
	self.bindData.backBtn.luaClick = self:CreateAction("ExitMaJiangInGame", self.mgr)
	self.bindData.backGround.luaClick = self:CreateAction("OnClickBackGround")
	self.bindData.dragArea.luaClick = self:CreateAction("OnClickBackGround")
	self.bindData.tingpaiBtn.luaClick = self:CreateAction("OnClickTingHelper")
	self.bindData.tingpaiBack.luaClick = self:CreateAction("OnClickTingHelper")
	self.bindData.huanPaiConfirmBtn.luaClick = self:CreateAction("OnHuanPaiConfirm")
	self.bindData.huBtn.luaClick = self:CreateAction("OnHuBtnClick")
	self.bindData.gangBtn.luaClick = self:CreateAction("OnGangBtnClick")
	self.bindData.pengBtn.luaClick = self:CreateAction("OnPengBtnClick")
	self.bindData.guoBtn.luaClick = self:CreateAction("OnGuoBtnClick")
	self.bindData.teachBtn.luaClick = self:CreateAction("OnTeachBtnClick")
	self.bindData.dqTongBtn.luaClick = self:CreateActionWithArgs("OnSelectDingQue", 1)
	self.bindData.dqTiaoBtn.luaClick = self:CreateActionWithArgs("OnSelectDingQue", 2)
	self.bindData.dqWanBtn.luaClick = self:CreateActionWithArgs("OnSelectDingQue", 3)
end

function M:OnShow(panelId, data)
	self:OnInit()

	if self.mgr.isNewGame then
		self:OnNewGame()
	end

	self:RefreshRoomState()
	self:RefreshRoom()
	self:RefreshGame()

	self.bindData.showTingHelper = BOOL2CTL[false]
	self.countDownTimer = Timer.New(self:CreateAction(self.HandleTimeCountDown), 1, -1):Start()
end

local COUNT_DOWN_FORMATTER = "%02d"

function M:HandleTimeCountDown()
	local timeout = self.mgr.timeOut

	if timeout == nil then
		return
	end

	local bindData = self.bindData
	local remain = 999

	if self.showCountDown then
		local now = gCS.TimeManager.ServerUnixTime
		remain = math.ceil(timeout - now)

		if remain < 0 then
			remain = 0
		end

		if not self.enableOpCountDown then
			remain = self.lastCountDownRemain
		end

		local str = gString.Format(COUNT_DOWN_FORMATTER, remain)
		bindData.countDown = str

		self.mgr:RefreshCountDown(str)

		if bindData.tips == TIPS_TYPE.xuanpai then
			bindData.selectCountDown = "(" .. str .. ")"
		end
	end

	self.lastRemain = remain
end

function M:OnClose()
	if self.countDownTimer then
		self.countDownTimer:Stop()

		self.countDownTimer = nil
	end

	self:ClearMessageEvents()
	self.mgr:UnRegisterStore()
end

function M:OnInit()
	self.scoreFlag = 0
	self.endActCount = 0
	self.myDingqueCount = 0
	self.cos = {}
	self.scoreQue = {
		{},
		{},
		{},
		{}
	}
	self.preSelectIndex = -1
	self.showCountDown = false
	self.enableOpCountDown = true
	self.lastCountDownRemain = 0
	self.outCardInfo = {}
	self.lastPlayVoiceEffectTime = 0
	self.bubbleTimers = {}

	self:SetAuto(false)

	for i = 1, 4 do
		local store = gStoreManager:GetStoreGroup("MaJiangAvatarTemplate"):GetStoreByWidget(self.bindData["player" .. i])
		self.avatarStore[i] = store
	end

	for i = 1, 4 do
		local store = self:GetStoreByWidget(self.bindData["feedback" .. i])
		self.feedbackStore[i] = store
	end

	self.mgr:RegisterStore(self)
end

function M:RefreshInitState(state)
	self.bindData.isIniting = BOOL2CTL[state]

	self:UpdateTooltips(self.mgr.gameState)
	self:RefreshShowOp(false)
end

function M:OnRenderHandCardItem(btn, csIndex)
	local data = self.handCard[csIndex + 1]
	local store = gStoreManager:GetStoreGroup("MaJiangHandCardTemplate"):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.iconId = data.icon
	store.isMask = BOOL2CTL[data.mask]
	store.isNew = BOOL2CTL[data.new]
	btn.luaBeginDrag = self:CreateAction("OnHandCardBeginDrag")
	btn.luaEndDrag = self:CreateActionWithArgs("OnHandCardDragEnd", {
		btn = btn,
		data = data
	})
	btn.luaEnterDropWidget = self:CreateAction("OnHandCardEnterDropWidget")
	btn.luaExitDropWidget = self:CreateAction("OnHandCardExitDropWidget")
	btn.autoClickOnHover = self.mgr.gameState ~= GameStateEnum.HuanPai
end

function M:OnHandCardBeginDrag()
	self.handCardCanExit = false
end

function M:OnHandCardDragEnd(args)
	local btn = args.btn
	local data = args.data

	if self.handCardCanExit == true and self:OutCard(data) then
		return
	end

	btn.rectTransform.position = btn.originWidgetPos
end

function M:OnHandCardEnterDropWidget()
	self.handCardCanExit = true
end

function M:OnHandCardExitDropWidget()
	self.handCardCanExit = false
end

function M:OnRemoveLastFold()
	return
end

function M:OutCard(data)
	local paiInfo = data.paiInfo

	if self.waitingGang then
		gClientToAvatarDelegate:Gang(paiInfo).Callback = function (err, needWait)
			if err ~= 0 then
				gDisplayMessageMgr:DisplayServerMessageId(err)

				return
			end

			local hasOp = self.canHu or self.canPeng or self.canReach

			self:RefreshShowOp(hasOp)

			if not needWait then
				self:StopOpCountDown()
			end
		end

		return true
	elseif self.turn == self.mgr.mySeatID then
		gClientToAvatarDelegate:ChuPai(paiInfo, false)
		self:SwitchJobDone(true)
		self:RefreshShowOp(false)

		self.bindData.tips = TIPS_TYPE.notips
		self.bindData.showTingHelper = BOOL2CTL[false]

		if data.id ~= self.mgr.tingsPai then
			self.mgr.tingsPai = -1
			self.mgr.tingsInfo = nil
		end

		return true
	end

	return false
end

function M:OnHandCardClick(btn, csIndex)
	local data = self.handCard[csIndex + 1]

	if self.stopNext then
		self.stopNext = false

		return
	end

	local view = data
	local state = self.mgr.gameState
	btn.enabledDraggingClick = false

	if state == GameStateEnum.HuanPai then
		if self.jobDone then
			return
		end

		local pais = {}

		for i = 1, #self.handCard do
			if self.handCard[i].selected then
				table.insert(pais, self.handCard[i].paiInfo)
			end
		end

		self.huanPais = pais

		self:CheckCanHuanPai()
	elseif state == GameStateEnum.Playing then
		self:OnHandCardClick_Playing(btn, csIndex, view)
	end
end

function M:OnHandCardClick_Playing(btn, csIndex, view)
	self.selectIndex = csIndex

	if self.mgr.hasHu then
		return
	end

	local canGang = self.bindData.canGang or false
	local showOp = self.bindData.showOp == BOOL2CTL[true]
	local canOperateHandCard = not showOp or showOp and canGang

	if not canOperateHandCard then
		return
	end

	local isDoubleClick = self.selectIndex == self.preSelectIndex

	if self.waitingGang then
		btn.enabledDraggingClick = true

		if isDoubleClick then
			self:OutCard(view)
		end
	else
		if self.autoMode then
			return
		end

		if isDoubleClick then
			self.preSelectIndex = -1

			self:OutCard(view)

			return
		end

		btn.enabledDraggingClick = true

		self:ShowTingHelper(view.id)
		self:RefreshSameOutCards(view.id)
	end

	self.preSelectIndex = self.selectIndex
end

function M:OnRenderTingCardItem(btn, csIndex)
	local data = self.tingListData[csIndex + 1]
	local store = self:GetStoreByWidget(btn)

	if not store then
		return
	end

	store.iconId = data.TingIcon
	store.numLabel = data.TingCount
	store.fanLabel = data.TingFan
end

function M:OnBeginAutoMode()
	if self.autoMode == false then
		gClientToAvatarDelegate:TuoGuan().Callback = self:CreateAction("OnBeginAutoModeCallback")
		self.bindData.showTingHelper = BOOL2CTL[false]
	else
		gClientToAvatarDelegate:CancelTuoGuan().Callback = self:CreateAction("OnEndAutoModeCallback")
	end
end

function M:OnEndAutoModeCallback(errID)
	if errID > 0 then
		print_error("CancelTuoGuan failed, error =", gCS.Error.GetNameById(errID))

		return
	end

	self:SetAuto(false)
end

function M:OnBeginAutoModeCallback(errID)
	if errID > 0 then
		if errID == MessageConfig.MJ_CanNotTuoGuan then
			gDisplayMessageMgr:ShowMessage(MessageConfig.MJ_CanNotTuoGuan)
		end

		return
	end

	self:SetAuto(true)
end

function M:OnClickBackGround()
	self.bindData.showTingHelper = BOOL2CTL[false]

	if self.mgr.gameState ~= GameStateEnum.Playing or self.bindData.showOp == BOOL2CTL[true] then
		return
	end

	self:ClearSelection(self.mgr.mySeatID)
end

function M:OnClickTingHelper()
	if self.bindData.showTingHelper == BOOL2CTL[true] then
		self.bindData.showTingHelper = BOOL2CTL[false]
	else
		local tings = self.mgr.tingsInfo or {}

		if next(tings) == nil then
			gDisplayMessageMgr:ShowMessage(MessageConfig.MahjongTingpai)

			return
		end

		self.bindData.showTingHelper = BOOL2CTL[true]
		self.tingListData = tings

		self.bindData.tingList:SetSimpleList(#tings)
	end
end

function M:OnHuanPaiConfirm()
	gClientToAvatarDelegate:HuanPai(self.huanPais)
end

function M:OnHuBtnClick()
	gClientToAvatarDelegate:Hu()
	self:RefreshShowOp(false)
	self:StopOpCountDown()
end

function M:OnGangBtnClick()
	if self.gangActionInfo.Count <= 0 then
		return
	end

	if self.gangActionInfo.Count == 1 then
		gClientToAvatarDelegate:Gang(self.gangActionInfo[1].Pai).Callback = function (err, needWait)
			if err ~= 0 then
				gDisplayMessageMgr:DisplayServerMessageId(err)

				return
			end

			local hasOp = self.canHu or self.canPeng or self.canReach

			self:RefreshShowOp(hasOp)

			if not needWait then
				self:StopOpCountDown()
			end
		end
	else
		self.waitingGang = true

		for i = 1, #self.handCard do
			local view = self.handCard[i]
			local id = view.id
			local isGang = false

			for j = 1, #self.gangActionInfo.Count do
				local gangPai = self.gangActionInfo[j].Pai

				if id == gangPai.Index then
					isGang = true

					break
				end
			end

			view.mask = not isGang
			view.selected = isGang
		end

		self:RefreshHandCardList()
	end
end

function M:OnPengBtnClick()
	local pengPai = self.mgr.lastPai
	local pengPaiList = {}

	for i = 1, #self.handCard do
		local view = self.handCard[i]

		if view.id == pengPai.Index then
			pengPaiList[#pengPaiList + 1] = view.paiInfo

			if #pengPaiList == 2 then
				break
			end
		end
	end

	gClientToAvatarDelegate:Peng(pengPaiList)
	self:RefreshShowOp(false)
end

function M:OnGuoBtnClick()
	gClientToAvatarDelegate:Guo()
	self:RefreshShowOp(false)
end

function M:OnTeachBtnClick()
	self.stopNext = true

	gPanelManager:CheckShow(gPanelId.S_MA_JIANG_TEACH_PANEL, {
		callback = function ()
			FrameTimer.New(function ()
				if self.showOp then
					self:RefreshNav(self.showOp)
				end
			end, 1):Start()
		end
	})
end

function M:OnSelectDingQue(data)
	local type = data

	gClientToAvatarDelegate:DingQue(type).Callback = function (errID)
		if errID > 0 then
			print_error("DingQue failed, error =", gCS.Error.GetNameById(errID), "type =", type)

			return
		end

		self.bindData:Commit("showDingque", BOOL2CTL[false], COMMIT_IMMEDIATELY)

		local _, firstBtn = self.bindData.handCardList:TryGetChildAt(0, nil)
		self.bindData.navigationArea.CurrentActiveContent = firstBtn
	end
end

function M:ClearLastGame()
	self.scoreFlag = 0
	self.outCardInfo = {}
	self.handCard = {}
	local ques = self.scoreQue

	for i = 1, #ques do
		ques[i] = {}
	end

	self.actionFlag = false
	self.actionQue = {}
	self.endActCount = 0
	self.mgr.tingsPai = -1
	self.mgr.tingsInfo = nil
end

function M:OnNewGame()
	local bindData = self.bindData

	self.mgr:RefreshIsShow(BOOL2CTL[false])

	bindData.matchEND = BOOL2CTL[false]

	self.mgr:ClearMachine()

	self.handCard = {}

	self:RefreshHandCardList()
	self:RefreshPlayers(self.mgr.roomInfo)

	self.showCountDown = false

	self:ClearLastGame()

	self.mgr.gameState = GameStateEnum.Begin
	self.hasNew = false
	self.mgr.isNewGame = false
end

function M:CheckCanHuanPai()
	local pais = self.huanPais
	local valid = #pais == 3

	if valid then
		local type1 = self:GetMJType(pais[1])
		valid = type1 == self:GetMJType(pais[2]) and type1 == self:GetMJType(pais[3])
	end

	self.bindData.huanPaiConfirmBtn.interactable = valid
end

function M:SwitchJobDone(flag)
	self.jobDone = flag
	self.bindData.handCardList.groupType = flag == false and 2 or 1
end

function M:BeginHuanPai(defaultPais)
	self:SwitchJobDone(false)
	self:RefreshMyHandCards(self.mgr.myInfo)

	local flags = {}

	for i = 1, #defaultPais do
		local index = defaultPais[i].Index
		flags[index] = flags[index] and flags[index] + 1 or 1
	end

	for i = 1, #self.handCard do
		local index = self.handCard[i].id

		if flags[index] then
			self.handCard[i].selected = flags[index] > 0
			flags[index] = flags[index] - 1
		end
	end

	self:RefreshHandCardList()

	self.huanPais = defaultPais
	self.bindData.tips = TIPS_TYPE.xuanpai

	self:CheckCanHuanPai()
	self:RefreshOtherStatus(TextConfig.GetConfig(TextConfig.MahjongXuanpai).Text)
end

function M:FoldMyHuanPai(huanPais)
	self:SwitchJobDone(true)

	self.bindData.tips = TIPS_TYPE.notips

	self:RefreshMyHandCards(self.mgr.myInfo)
end

function M:SetHandCardsVisible(count, visible)
	for seatID = 0, 3 do
		local info = self.mgr.gameInfo.SeatInfos[seatID + 1]
		local delta = self.mgr:GetSeatIndexBySeatID(seatID)

		if seatID ~= self.mgr.mySeatID then
			local addition = visible == true and count or -1 * count
			local holdsCount = info.HoldsCount + addition
			local views = {}

			for i = 1, holdsCount do
				views[i] = {
					Pai = 0,
					MType = 1
				}
			end

			self.mgr:RefreshHandArea(delta, views)
		end
	end
end

function M:WaitHuanPaiAni(huanPais, duration)
	self:SetHandCardsVisible(3, false)
	coroutine.wait(duration)
	self:RefreshMyHandCards(self.mgr.myInfo)

	local bindData = self.bindData

	self:SetHandCardsVisible(0, true)

	bindData.tips = TIPS_TYPE.notips
	local flags = {}

	for i = 1, #huanPais do
		local index = huanPais[i]
		flags[index] = flags[index] and flags[index] + 1 or 1
	end

	for i = 1, #self.handCard do
		local index = self.handCard[i].id

		if flags[index] then
			self.handCard[i].selected = flags[index] > 0
			flags[index] = flags[index] - 1
		end
	end

	self:RefreshHandCardList()

	self.aniCo = nil
end

function M:FinishHuanPai(method, huanPais)
	local bindData = self.bindData

	self:RefreshOtherStatus("")

	bindData.changeLabel = self.mgr:GetMahjongHuanpai(method)
	bindData.tips = TIPS_TYPE.huanpaizhong
	self.aniCo = coroutine.start(self.WaitHuanPaiAni, self, huanPais, 2)
end

local que2Btn = {
	"dqTongBtn",
	"dqTiaoBtn",
	"dqWanBtn"
}

function M:BeginDingque(defaultQue)
	for i = 1, #que2Btn do
		local btnName = que2Btn[i]
		local btn = self.bindData[btnName]
		btn.isSelected = i == defaultQue

		if i == defaultQue then
			FrameTimer.New(function ()
				btn:InvokeCallback(SGUI.EInvokeTime.User1)
			end, 1):Start()

			self.bindData.navigationArea.CurrentActiveContent = btn
		end
	end

	self.bindData.showDingQue = BOOL2CTL[true]

	self:RefreshOtherStatus(TextConfig.GetConfig(TextConfig.MahjongDingque).Text)
end

function M:FinishDingque(ques)
	self.bindData.showDingQue = BOOL2CTL[false]

	self:RefreshOtherStatus("")

	local myIndex = self.mgr.mySeatID
	self.myQue = ques[myIndex + 1]

	for i = 1, 4 do
		local seatIndex = self.mgr:GetSeatIndex(i)

		self:RefreshDingque(i, ques[seatIndex + 1])
	end

	self:RefreshMyHandCards(self.mgr.myInfo)
end

function M:RefreshShowOp(hasOp)
	self.bindData.showOp = BOOL2CTL[hasOp]
	self.showOp = hasOp

	self:RefreshNav(hasOp)
end

function M:RefreshNav(hasOp)
	SGUI.UNavigationMgr.Inst.CurrentActiveArea = hasOp and self.bindData.opNavigationArea or self.bindData.navigationArea

	if hasOp then
		if self.canHu then
			self.bindData.opNavigationArea.CurrentActiveContent = self.bindData.huBtn
		elseif self.canGang then
			self.bindData.opNavigationArea.CurrentActiveContent = self.bindData.gangBtn
		else
			self.bindData.opNavigationArea.CurrentActiveContent = self.bindData.pengBtn
		end
	end
end

function M:OnMoPai(seatID, pai)
	local gameInfo = self.mgr.gameInfo

	if gameInfo == nil then
		return
	end

	local isMe = seatID == self.mgr.mySeatID

	if isMe then
		self.newCard = pai
		self.hasNew = true
	end

	local bindData = self.bindData
	bindData.cardNum = gameInfo.Remainders

	self:RefreshHandCardsBySeatID(seatID)
	self:ResumeOpCountDown()

	if isMe and self.mgr.tingsInfo == nil then
		self.mgr:GetTingsInfo(pai.Index)
	end
end

function M:RefreshSameOutCards(paiId)
	for i = 0, 3 do
		local list = self.outCardInfo[i]

		if list then
			for j = 1, #list do
				list[j].isSelected = list[j].Index == paiId
			end

			self.mgr:RefreshStackArea(i, list, true)
		end
	end
end

function M:OnChuPai(seatID)
	self.turn = -1
	local gameInfo = self.mgr.gameInfo

	if gameInfo == nil then
		return
	end

	if seatID == self.mgr.mySeatID then
		self.hasNew = false
		local lastView = self.handCard[self.selectIndex]

		if lastView ~= nil and lastView.new or self.mgr.hasHu or self.autoMode == true then
			self.newCard = nil
		end

		self.selectIndex = nil
		self.jobDone = false
		self.bindData.showTingHelper = BOOL2CTL[false]
	end

	self.bindData.tips = TIPS_TYPE.notips

	self:RefreshHandCardsBySeatID(seatID, seatID == self.mgr.mySeatID and not self.mgr.hasHu)
	self:RefreshOutCardsBySeatID(seatID)
	self:RefreshSameOutCards(nil)
end

local counter = 0

function M:DelayRefreshScoreChange(seatId, score, change, coID, duration)
	coroutine.wait(duration)

	local index = self.mgr:MapIndex(seatId)
	self.avatarStore[index].scoreLabel = score
	local changeStr = nil
	local op = 0

	if change > 0 then
		op = 1
		changeStr = gString.Format("+%d", change)
	else
		op = 2
		changeStr = tostring(change)
	end

	self.feedbackStore[index]:Commit("scoreVis", op, COMMIT_FORCE)

	self.feedbackStore[index].scoreLabel = changeStr
	self.cos[coID] = nil
	local que = self.scoreQue[seatId + 1]

	if #que == 0 then
		local mask = bit.lshift(1, 4) - 1 - bit.lshift(1, seatId)
		self.scoreFlag = bit.band(self.scoreFlag, mask)
	else
		local data = que[1]
		counter = counter + 1
		self.cos[counter] = coroutine.start(self.DelayRefreshScoreChange, self, seatId, data[1], data[2], counter, data[3])

		table.remove(que, 1)
	end
end

function M:OnScoreChange(seatId, score, change)
	local mask = bit.lshift(1, seatId)
	local busy = bit.band(self.scoreFlag, mask) ~= 0
	local duration = 3

	if not busy then
		counter = counter + 1
		self.cos[counter] = coroutine.start(self.DelayRefreshScoreChange, self, seatId, score, change, counter, duration)
		self.scoreFlag = bit.bor(self.scoreFlag, mask)
	else
		local que = self.scoreQue[seatId + 1]
		que[#que + 1] = {
			score,
			change,
			duration * 2
		}
	end
end

function M:PlayFangPaoAni(seatIDs, lastSeatID, isQiangGang)
	if lastSeatID >= 0 then
		if not isQiangGang then
			self:RefreshOutCardsBySeatID(lastSeatID)
		else
			self:RefreshPengGangsBySeatID(lastSeatID)
		end
	end

	for i = 1, #seatIDs do
		self:RefreshHusBySeatID(seatIDs[i])
	end
end

function M:PlayZiMoAni(seatID)
	if seatID == self.mgr.mySeatID then
		self.hasNew = false
	end

	self:RefreshHandCardsBySeatID(seatID)
	self:RefreshHusBySeatID(seatID)
end

function M:PlayActionBySeats(seatIDs, action, wait)
	if action == nil then
		return
	end

	for i = 1, #seatIDs do
		local localIndex = self.mgr:MapIndex(seatIDs[i])

		self.feedbackStore[localIndex]:Commit("feedback", action, COMMIT_FORCE)
		self:PlayVoiceByAction(localIndex, action)
	end
end

function M:OnHu(seatIDs, isSelf, lastSeatID, isQiangGang, isGangShangKaiHua)
	local action = OP_EFFECT_ACTION.Hu

	if isSelf then
		action = OP_EFFECT_ACTION.ZiMo

		if isGangShangKaiHua then
			action = OP_EFFECT_ACTION.GangShangKaiHua
		end

		if self.mgr.gameInfo.Remainders == 0 then
			action = OP_EFFECT_ACTION.HaiDiLaoYue
		end
	end

	self:PlayActionBySeats(seatIDs, action, false)

	if isSelf then
		self:PlayZiMoAni(seatIDs[1])
	else
		self:PlayFangPaoAni(seatIDs, lastSeatID, isQiangGang)
	end

	for i = 1, #seatIDs do
		self:ClearSelection(seatIDs[i])
	end

	if self.bindData.canGang == BOOL2CTL[true] or self.bindData.canPeng == BOOL2CTL[true] then
		self:RefreshShowOp(false)
	end
end

function M:OnMyFirstHu()
	for i = 1, #self.handCard do
		self.handCard[i].mask = true
	end

	self:RefreshHandCardList()
end

function M:RefreshHandCardList()
	self.bindData.handCardList:SetSimpleList(#self.handCard)

	self.preSelectIndex = -1
end

function M:RefreshOperation(action)
	local bindData = self.bindData
	self.canHu = not self.mgr.hasHu and action.CanHu
	self.canPeng = action.CanPeng.Count > 0
	self.canGang = action.CanGang.Count > 0
	self.canReach = false
	bindData.canHu = BOOL2CTL[self.canHu]
	bindData.canPeng = BOOL2CTL[self.canPeng]
	bindData.canGang = BOOL2CTL[self.canGang]
	bindData.canReach = BOOL2CTL[self.canReach]
	local hasOp = self.canHu or self.canPeng or self.canGang or self.canReach

	self:RefreshShowOp(hasOp)

	if hasOp then
		self.gangActionInfo = action.CanGang
	end
end

function M:OnPeng(seatID)
	self:RefreshPengGangsBySeatID(seatID)
	self:PlayActionBySeats({
		seatID
	}, OP_EFFECT_ACTION.Peng, false)
	self:ClearSelection(seatID)

	if self.bindData.canHu == BOOL2CTL[true] then
		self:RefreshShowOp(false)
	end
end

function M:OnGang(seatID, pai, type)
	self.waitingGang = false
	self.preSelectIndex = -1

	self:RefreshPengGangsBySeatID(seatID)
	self:PlayActionBySeats({
		seatID
	}, OP_EFFECT_ACTION.Gang, false)
	self:ClearSelection(seatID)

	if self.bindData.canHu == BOOL2CTL[true] then
		self:RefreshShowOp(false)
	end
end

function M:OnGuo()
	self:RefreshShowOp(false)

	if self.waitingGang then
		self.waitingGang = false
		self.preSelectIndex = -1

		self:RefreshMyHandCards(self.mgr.myInfo)
	end
end

function M:OnMaoZhuanYu(seatID)
	self:PlayActionBySeats({
		seatID
	}, OP_EFFECT_ACTION.HuJiaoZhuanYi, true)
end

function M:OnEndCheck(seatList, action)
	self.endActCount = self.endActCount + 1

	self:PlayActionBySeats(seatList, self:ConvertMJActionType(action), true)
end

function M:ConvertMJActionType(mjActionType)
	if mjActionType == MjActionType.Hu then
		return OP_EFFECT_ACTION.Hu
	elseif mjActionType == MjActionType.AnGang or mjActionType == MjActionType.WangGang or mjActionType == MjActionType.DianGang then
		return OP_EFFECT_ACTION.Gang
	elseif mjActionType == MjActionType.MaoZhuanYu then
		return OP_EFFECT_ACTION.HuJiaoZhuanYi
	elseif mjActionType == MjActionType.TuiShui then
		return OP_EFFECT_ACTION.TuiShui
	elseif mjActionType == MjActionType.ChaDaJiao then
		return OP_EFFECT_ACTION.ChaDaJiao
	elseif mjActionType == MjActionType.ChaHuaZhu then
		return OP_EFFECT_ACTION.ChaHuaZhu
	end
end

function M:DelayShowEnd(result)
	local delay = 0

	if self.endActCount > 0 then
		delay = 1
	end

	self.mgr.inExit = true

	coroutine.wait(MahjongConfig.MahjongEndTime + delay)

	self.mgr.inExit = false

	self.mgr:OpenFinal({
		result,
		self.pveCompleteNum
	})

	self.aniCo = nil
end

function M:RefreshPveGameNumInfo(completeNum)
	self.pveCompleteNum = completeNum
end

function M:OnGameOver(result)
	local bindData = self.bindData

	self:SetAuto(false)

	self.showCountDown = false
	bindData.canStartGame = false
	bindData.matchEND = BOOL2CTL[true]

	bindData.handCardList:SetList({})

	for seatID = 0, 3 do
		local info = result.MjPlayerResultList[seatID + 1]
		local delta = self.mgr:GetSeatIndexBySeatID(seatID)

		self:RefreshUnfolds(info.Holds, delta)
	end

	self.aniCo = coroutine.start(self.DelayShowEnd, self, result)
end

function M:SortUnfolds(a, b)
	return a.id < b.id
end

function M:RefreshUnfolds(holds, index)
	local views = {}

	for i = 1, #holds do
		local id = holds[i].Index
		views[i] = {
			isSelected = false,
			id = id,
			Pai = holds[i].Pai,
			MType = holds[i].MType
		}
	end

	table.sort(views, self:CreateAction("SortUnfolds"))
	self.mgr:RefreshHandArea(index, views, true)
end

function M:SetAuto(flag)
	if flag == nil then
		flag = true
	end

	self.bindData.isAuto = BOOL2CTL[flag]
	self.autoMode = flag
end

function M:CheckBankerHint()
	local gameInfo = self.mgr.gameInfo

	if gameInfo == nil or gameInfo.Banker ~= self.mgr.mySeatID then
		return
	end

	self.bindData.ChupaiTipTxt = TextConfig.GetConfig(TextConfig.MahjongChupaiTishi).Text
	self.bindData.tips = TIPS_TYPE.tips
end

function M:RefreshRoom()
	local roomInfo = self.mgr.roomInfo

	if roomInfo == nil then
		return
	end

	self:RefreshRoomState()
	self:RefreshPlayers(roomInfo)
end

function M:RefreshRoomState()
	local state = self.mgr.roomState

	self:RefreshMatchPrepare(state)
	self:RefreshInitState(state == MahjongRoomState.Idle)

	self.bindData.isShowExitBtn = BOOL2CTL[state ~= MahjongRoomState.Display and state ~= MahjongRoomState.Idle]
end

function M:RefreshMatchPrepare(state)
	local bindData = self.bindData

	if state == MahjongRoomState.Idle and self.mgr.gameState ~= GameStateEnum.Over then
		self.SortCardIndex = 0
		bindData.tips = TIPS_TYPE.matching
		bindData.changeLabel = self.mgr:GetMahjongHuanpai(0)
	else
		bindData.tips = TIPS_TYPE.notips
	end
end

function M:RefreshPlayers(roomInfo)
	local players = roomInfo.PlayerInfos

	for i = 1, 4 do
		local index = self.mgr:GetSeatIndex(i)
		local player = players[index + 1]

		self:AddPlayerByIndex(i, player)
	end
end

function M:RefreshGame()
	local gameInfo = self.mgr.gameInfo

	if gameInfo == nil then
		return
	end

	local bindData = self.bindData
	local names = MahjongConfig.SeatNames
	local banker = gameInfo.Banker
	local mySeatID = self.mgr.mySeatID
	local nameList = {}

	for i = 1, 4 do
		local nameIndex = (4 + mySeatID + i - 1 - banker) % 4 + 1
		nameList[i] = names[nameIndex]
	end

	self.mgr:RefreshSeatName(nameList)
	self.mgr:RefreshIsShow(BOOL2CTL[true])

	self.showCountDown = true
	bindData.cardNum = gameInfo.Remainders
	local turn = gameInfo.Turn

	self:RefreshTurn(turn)

	local gameState = self.mgr.gameState
	local isOver = gameState == GameStateEnum.Over
	bindData.matchEND = BOOL2CTL[isOver]
	self.hasNew = not isOver and turn == mySeatID and gameInfo.LastTurn ~= turn and gameInfo.LastMoPaiSeatIndex == mySeatID
	local seatInfos = gameInfo.SeatInfos

	for i = 0, 3 do
		self:RefreshCards(seatInfos, i)
	end

	self:RefreshShowOp(false)
	self:UpdateTooltips(gameState)

	for i = 1, 4 do
		local seatIdx = (self.mgr.mySeatID + i - 1) % 4 + 1
		local info = gameInfo.SeatInfos[seatIdx]
		self.avatarStore[i].scoreLabel = info.Score
	end
end

function M:RefreshTurn(seatID)
	self.turn = seatID

	self.mgr:RefreshSeat(seatID)

	if self.mgr.mySeatID == seatID then
		self:CheckDingqueHint()
	end
end

function M:CheckDingqueHint()
	if self.mgr.myGameCount <= MahjongConfig.MahjongXinshouTishi and self.myDingqueCount > 0 then
		self.bindData.tips = TIPS_TYPE.tips
		self.bindData.ChupaiTipTxt = TextConfig.GetConfig(TextConfig.MahjongQueyimenTishi).Text
	end
end

function M:RefreshCards(seatInfos, addition)
	local seatID = (self.mgr.mySeatID + addition) % 4
	local info = seatInfos[seatID + 1]
	local index = self.mgr:GetSeatIndexBySeatID(seatID)

	if info == nil then
		return
	end

	local que = info.Que
	self.myQue = que

	self:RefreshDingque(index + 1, que)
	self:RefreshOutCards(info, index)
	self:RefreshHus(info, index)

	if addition == 0 then
		self:RefreshMyHandCards(info)
	else
		self:RefreshHandCards(info, index)
	end

	self:RefreshPengGangs(info, index)
end

function M:RefreshDingque(index, que)
	local view = self.avatarStore[index]
	view.queType = que
end

function M:RefreshOutCards(info, index)
	if not info or table.isNilOrEmpty(info.Folds) then
		return
	end

	local views = {}

	for i = 1, #info.Folds do
		local card = info.Folds[i]
		local ele = {
			isSelected = false,
			Index = card.Index,
			Pai = card.Pai,
			MType = card.MType
		}

		table.insert(views, ele)
	end

	self.outCardInfo[index] = views

	self.mgr:RefreshStackArea(index, views)
end

function M:RefreshOutCardsBySeatID(seatID)
	local info = self.mgr.gameInfo.SeatInfos[seatID + 1]
	local delta = self.mgr:GetSeatIndexBySeatID(seatID)

	self:RefreshOutCards(info, delta)
	self.mgr:RefreshLastCard(delta)
end

function M:RefreshHus(info, index)
	self.mgr:RefreshHuArea(index, info.HuPais)
end

function M:RefreshHusBySeatID(seatID)
	local info = self.mgr.gameInfo.SeatInfos[seatID + 1]
	local delta = self.mgr:GetSeatIndexBySeatID(seatID)

	self:RefreshHus(info, delta)
end

function M:RefreshPengGangs(info, index)
	self.mgr:RefreshPengGangArea(index, info.Sequence)
end

function M:RefreshPengGangsBySeatID(seatID)
	local info = self.mgr.gameInfo.SeatInfos[seatID + 1]
	local delta = self.mgr:GetSeatIndexBySeatID(seatID)

	self:RefreshPengGangs(info, delta)
end

function M:RefreshHandCards(info, index)
	local holdsCount = info.HoldsCount
	local views = {}

	for i = 1, holdsCount do
		views[i] = {
			Pai = 0,
			MType = 1
		}
	end

	self.mgr:RefreshHandArea(index, views)
end

function M:RefreshMyHandCards(info, playEffect)
	local holds = info.Holds
	local paiIcons = MahjongConfig.MahjongSPai
	self.handCard = {}
	local dingqueCount = 0

	for i = 1, #holds do
		local info = holds[i]
		local mask = self.mgr.hasHu

		if not mask then
			mask = self:IsDingque(info)
			local dingque = mask and 1 or 0
			dingqueCount = dingqueCount + dingque
		end

		self.handCard[i] = {
			selected = false,
			new = false,
			id = info.Index,
			icon = paiIcons[info.Index + 1],
			mask = mask,
			paiInfo = info
		}
	end

	self.myDingqueCount = dingqueCount

	if self.hasNew then
		self.handCard[#self.handCard].new = true
	end

	table.sort(self.handCard, self.SortHandCards)

	local select = self.selectIndex

	if select ~= nil and self.handCard[select + 1] ~= nil then
		self.handCard[select + 1].selected = true
	end

	self:RefreshHandCardList()
end

function M:RefreshOtherStatus(text)
	for i = 1, 3 do
		self.bindData["status" .. i] = text
	end
end

function M:RefreshHandCardsBySeatID(seatID, playEffect, resetNew)
	local info = self.mgr.gameInfo.SeatInfos[seatID + 1]
	local delta = self.mgr:GetSeatIndexBySeatID(seatID)

	if seatID == self.mgr.mySeatID then
		if resetNew then
			self.hasNew = false
		end

		self:RefreshMyHandCards(info, playEffect)
	else
		self:RefreshHandCards(info, delta)
	end
end

function M:RefreshFriendPrepare(state)
	return
end

function M:UpdateTooltips(gameState)
	if gameState == GameStateEnum.HuanPai then
		self.bindData.showDingQue = BOOL2CTL[false]

		self:RefreshOtherStatus(TextConfig.GetConfig(TextConfig.MahjongXuanpai).Text)
	elseif gameState == GameStateEnum.DingQue then
		self.bindData.tips = TIPS_TYPE.notips

		self:RefreshOtherStatus(TextConfig.GetConfig(TextConfig.MahjongDingque).Text)
	else
		self:RefreshOtherStatus("")

		self.bindData.tips = TIPS_TYPE.notips
		self.bindData.showDingQue = BOOL2CTL[false]
	end
end

function M.SortHandCards(a, b)
	if a.new ~= b.new then
		return not a.new
	end

	local mask = a.mask

	if mask ~= b.mask then
		return not mask
	end

	return a.id < b.id
end

function M:GetMJType(paiInfo)
	return paiInfo.MType or 0
end

function M:IsDingque(id)
	return self:GetMJType(id) == self.myQue
end

function M:ClearSelection(seatID)
	if seatID ~= self.mgr.mySeatID or self.selectIndex == nil then
		return
	end

	self.bindData.handCardList:DeselectAll()

	self.selectIndex = nil
	self.preSelectIndex = -1
end

function M:StopOpCountDown()
	self.lastCountDownRemain = self.lastRemain
	self.enableOpCountDown = false
end

function M:ResumeOpCountDown()
	self.enableOpCountDown = true
end

function M:ShowTingHelper(paiId)
	if self.mgr:GetTingsInfo(paiId) == true then
		self.bindData.showTingHelper = BOOL2CTL[true]
		self.tingListData = self.mgr.tingsInfo or {}

		self.bindData.tingList:SetSimpleList(#self.tingListData)
	end
end

function M:AddPlayerByIndex(i, player)
	local store = self.avatarStore[i]

	if store then
		local view = {
			score = "",
			name = "",
			hasDingque = false,
			type = 0,
			isTurn = false,
			head = 0,
			hasPlayer = false
		}

		if player ~= nil and not player.exit then
			self.mgr:BuildPlayerView(player, view)

			store.iconId = self.mgr:GetPlayerHeadIcon(view)
			store.nameLabel = view.name
			store.scoreLabel = view.score
			store.scorecolor = i == 1 and 0 or 1
		end
	end
end

function M:AddPlayer(player)
	local index = self.mgr:MapIndex(player.SeatIndex)

	self:AddPlayerByIndex(index, player)
end

function M:RemovePlayer(seatIndex)
	local index = self.mgr:MapIndex(seatIndex)
	local store = self.avatarStore[index]

	if store then
		store.nameLabel = ""
		store.scoreLabel = ""
		store.iconId = 0
	end
end

function M:OnReceiveQuickChat(chatType, seatIndex, msgId)
	if chatType == MahjongChatType.SystemText then
		self:ShowQuickTextMsg(seatIndex, msgId)
	end
end

function M:ShowQuickTextMsg(seatID, msgID)
	local cfg = TextConfig.GetConfig(msgID)

	if cfg == nil then
		print_error("TextConfig not found, ID =", msgID)

		return
	end

	self:ShowTextMsg(seatID, cfg.Text)
end

function M:ShowTextMsg(seatID, msgTxt)
	local index = self.mgr:MapIndex(seatID)
	local view = self.feedbackStore[index]

	if view == nil then
		return
	end

	view.showBubble = BOOL2CTL[true]
	view.bubbleLabel = msgTxt
	local t = self.bubbleTimers[index]

	if t ~= nil then
		t:ResetTime(MahjongConfig.MaJiangChatBubbleDisppear)
		t:Start()
	else
		t = Timer.New(function ()
			view.showBubble = BOOL2CTL[false]
		end, MahjongConfig.MaJiangChatBubbleDisppear):Start()
	end
end

function M:OnReceiveNpcChat(seatIndex, npcChatType, dialogId)
	if self.mgr.roomInfo == nil then
		return
	end

	self.mgr:PlayDialogVoice(seatIndex, dialogId)
end

function M:PlayVoiceByAction(index, action)
	if not self.mgr.roomInfo.PlayerInfos then
		return
	end

	local player = self.mgr.roomInfo.PlayerInfos[index]
	local pveNpcTalkId = player.NpcMahjongId or 0

	if pveNpcTalkId ~= 0 then
		local cfg = MahjongPveMahjongNpcTalkConfig.GetConfig(pveNpcTalkId)
		local soundId = 0

		if not cfg then
			print_error("@wangpeizhi MahjongPveMahjongNpcTalkConfig not found, ID =", pveNpcTalkId)

			return
		end

		if action == OP_EFFECT_ACTION.Hu then
			soundId = cfg.HuVoice
		elseif action == OP_EFFECT_ACTION.Gang then
			soundId = cfg.GangVoice
		elseif action == OP_EFFECT_ACTION.Reach then
			soundId = cfg.ReachVoice
		end

		if soundId ~= 0 then
			gSoundMgr:PlaySoundByTid(soundId)
		end
	end
end

function M:OnPlayerReady()
	return
end
