-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\Majiang\MajiangPanelStore_Shared.lua
-- Decompiled from: 01212_MajiangPanelStore_Shared.lua_a7118a1900ec.luajit

local GameStateEnum = UX.Game.MjGameStateEnum
local MessageConfig = LTConfig.MessageConfig
local MahjongRoomState = UX.Game.MahjongRoomState
local MjActionType = UX.Game.MjActionType
local TextConfig = LTConfig.TextConfig
local MahjongConfig = LTConfig.MahjongConfig
local MahjongChatType = UX.Game.MahjongChatType
local MahjongPveMahjongNpcTalkConfig = LTConfig.MahjongPveMahjongNpcTalkConfig
local MahjongTuoGuanType = UX.Game.MahjongTuoGuanType
local C_MajiangCharacter = require("LX6/Gameplay/Majiang/MajiangCharacter")
local MjStateType = gMaJiangConst.MjStateType
local M = C_MajiangPanelStore

M.AddPlayer = function(self, player)
	local index = self.game:MapIndex(player.SeatIndex)

	self:AddPlayerByIndex(index, player)
end

M.AddPlayerByIndex = function(self, i, player)
	local store = self.avatarStore[i]
	local view = {
		["^\\xad\\xad\\xbd\\xb3"] = "",
		["t#p^"] = "",
		["[[ݙ\\x8d\\xbf\\xdc\\xed"] = false,
		["n;m^"] = 0,
		["[\\xa5\\x9b\\x91O"] = false,
		["r'|_"] = 0,
		["KFYB*"] = false
	}

	if player == nil and not player.exit then
		self.game:BuildPlayerView(player, view)

		store.iconId = self.game:GetPlayerHeadIcon(view.SeatRef)
		store.nameLabel = view.name
		store.scoreLabel = view.score
		store.scorecolor = i ~= 1 and 0 or 1
	end
end

M.ClearLastGame = function(self)
	self.scoreFlag = 0
	self.discardCardInfo = {}
	self.handCard = {}
	local ques = self.scoreQue

	for i = 1, #ques do
		ques[i] = {}
	end

	self.actionFlag = false
	self.actionQue = {}
	self.endActCount = 0
	self.game.tingsPai = -1
	self.game.tingsInfo = nil
end

M.ClearSelection = function(self, seatID)
end

M.ConvertMJActionType = function(self, mjActionType)
	if mjActionType ~= MjActionType.Hu then
		return gMaJiangConst.OpEffectAction.Hu
	elseif mjActionType ~= MjActionType.AnGang or mjActionType ~= MjActionType.WangGang or mjActionType ~= MjActionType.DianGang then
		return gMaJiangConst.OpEffectAction.Gang
	elseif mjActionType ~= MjActionType.MaoZhuanYu then
		return gMaJiangConst.OpEffectAction.HuJiaoZhuanYi
	elseif mjActionType ~= MjActionType.TuiShui then
		return gMaJiangConst.OpEffectAction.TuiShui
	elseif mjActionType ~= MjActionType.ChaDaJiao then
		return gMaJiangConst.OpEffectAction.ChaDaJiao
	elseif mjActionType ~= MjActionType.ChaHuaZhu then
		return gMaJiangConst.OpEffectAction.ChaHuaZhu
	end
end

M.HandleTimeCountDown = function(self)
	local timeout = self.game.timeOut

	if timeout ~= nil then
		return
	end

	local bindData = self.bindData
	local remain = 999

	if self.showCountDown then
		local now = gCS.TimeManager.ServerUnixTime
		remain = math.ceil(timeout - now)

		if remain >= 0 then
			remain = 0
		end

		if not self.enableOpCountDown then
			remain = self.lastCountDownRemain
		end

		local str = gString.Format(gMaJiangConst.CountDownFormatter, remain)
		local strs = str .. "s"
		bindData.countDown = str

		self.game:RefreshCountDown(str)

		bindData.selectCountDown = strs

		self:SyncSelectCountDown(strs)
	end

	self.lastRemain = remain
end

M.RegisterSelectCountDownSync = function(self, store)
	if not store then
		return
	end

	store:EnableImmediatelyCommit(true)

	store.selectCountDown = self.bindData.selectCountDown
	self.instance.selectCountDownTargets = self.instance.selectCountDownTargets or {}
	self.instance.selectCountDownTargets[#self.instance.selectCountDownTargets + 1] = store
end

M.SyncSelectCountDown = function(self, value)
	local targets = self.instance.selectCountDownTargets

	if not targets then
		return
	end

	for i = #targets, 1, -1 do
		local store = targets[i]

		if store then
			store.selectCountDown = value
		else
			table.remove(targets, i)
		end
	end
end

M.GetTuoGuanMask = function(self)
	local mask = 0
	local isAuto = self.instance.isAuto

	for i = 1, 3 do
		if isAuto[i] then
			local t = gMaJiangConst.TuoGuanTypeMap[i]
			mask = bit.bor(mask, t)
		end
	end

	return mask
end

M.SetTuoGuanMask = function(self, mask)
	local isAuto = self.instance.isAuto

	for i = 1, 3 do
		local t = gMaJiangConst.TuoGuanTypeMap[i]
		isAuto[i] = bit.band(mask, t) == 0
	end

	self.instance.isAuto = isAuto

	self.ApplyCurrentTuoGuanStateToStore(self)
end

M.OnClickAutoBtn = function(self, index)
	local lastMask = self.GetTuoGuanMask(self)
	local selected = not self.instance.isAuto[index]
	self.instance.isAuto[index] = selected
	local store = self.instance.tuoGuanStore

	if store then
		store["autoBtn" .. index]:SetSelected(selected)
	end

	local mask = self.GetTuoGuanMask(self)

	if mask == 0 then
		gClientToGameDelegate:TuoGuan(mask).Callback = function (errID)
			if errID <= 0 then
				if errID ~= MessageConfig.MJ_CanNotTuoGuan then
					gDisplayMessageMgr:ShowMessage(MessageConfig.MJ_CanNotTuoGuan)
				end

				self:SetTuoGuanMask(lastMask)
			else
				self:SetTuoGuanMask(mask)
			end
		end

		self:HideTingHelper()
	else
		slot6 = gClientToGameDelegate

		slot6:CancelTuoGuan(MahjongTuoGuanType.All).Callback = function (errID)
			if errID <= 0 then
				print_error("CancelTuoGuan failed, error =", gCS.Error.GetNameById(errID))
				self:SetTuoGuanMask(lastMask)
			else
				self:SetTuoGuanMask(mask)
			end
		end
	end
end

M.OnDragAreaPress = function(self)
	if self.instance.resetViewTween then
		self.instance.resetViewTween:Kill()

		self.instance.resetViewTween = nil
	end

	self.lastDragPos = gCS.LuaUtils.GetPointerPosition()
	self.updateHandler = UpdateBeat:CreateListener(self.OnDragAreaUpdate, self)

	UpdateBeat:AddListener(self.updateHandler)

	self.instance.lookAtNorm = self.instance.lookAtNorm or Vector2.zero
end

M.OnDragAreaRelease = function(self)
	self.lastDragPos = nil

	UpdateBeat:RemoveListener(self.updateHandler)

	self.update = nil
end

M.UpdateCameraLookAt = function(self, delta, rotateSpeed)
	if self.mgr.machine.CurrentVCamType == 1 then
		self.instance.lookAtNorm = Vector2.zero

		self.mgr.machine:SetMainCameraLookAtNormalized(0, 0)

		return false
	end

	self.instance.lookAtNorm = self.instance.lookAtNorm or Vector2.zero
	local lookAtNorm = self.instance.lookAtNorm
	lookAtNorm.x = Mathf.Clamp(lookAtNorm.x + delta.x * rotateSpeed, -1, 1)
	lookAtNorm.y = Mathf.Clamp(lookAtNorm.y + delta.y * rotateSpeed, -1, 1)

	self.mgr.machine:SetMainCameraLookAtNormalized(lookAtNorm.x, lookAtNorm.y)

	return true
end

M.OnDragAreaUpdate = function(self)
	local rotateSpeed = LTConfig.MahjongConfig.CameraRotateSpeed
	local currentPos = gCS.LuaUtils.GetPointerPosition()
	local delta = currentPos - self.lastDragPos

	self.UpdateCameraLookAt(self, delta, rotateSpeed)

	self.lastDragPos = currentPos
end

M.OnRStickInput = function(self, ctx)
	if ctx.canceled then
		if self.instance.rStickUpdateHandler then
			UpdateBeat:RemoveListener(self.instance.rStickUpdateHandler)

			self.instance.rStickUpdateHandler = nil
		end

		self.instance.rStickValue = nil

		return
	end

	self.instance.rStickValue = ctx.ReadValueVector2(ctx)

	if self.instance.rStickUpdateHandler ~= nil then
		self.instance.rStickUpdateHandler = UpdateBeat:CreateListener(self.OnRStickUpdate, self)

		UpdateBeat:AddListener(self.instance.rStickUpdateHandler)
	end
end

M.OnRStickUpdate = function(self)
	local rotateSpeed = LTConfig.MahjongConfig.GamepadCameraRotateSpeed
	local value = self.instance.rStickValue or Vector2.zero

	self:UpdateCameraLookAt(value, rotateSpeed)
end

M.OnGangBtnClick = function(self)
	if self.IsReach(self) then
		self.OnGangBtnClickReach(self)

		return
	end

	if self.gangActionInfo.Count < 0 then
		return
	end

	if self.gangActionInfo.Count ~= 1 then
		slot1 = gClientToGameDelegate

		slot1:Gang(self.gangActionInfo[1].Pai).Callback = function (err, needWait)
			if err == 0 then
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

				if id ~= gangPai.Index then
					isGang = true

					break
				end
			end

			view.mask = not isGang
			view.selected = isGang
		end

		self.RefreshHandCardList(self)
	end
end

M.OnGuoBtnClick = function(self)
	if self.IsReach(self) then
		self.OnGuoBtnClickReach(self)

		return
	end

	if self.canHu and self.game.useLocalInput then
		self.game:FSM_CancelHu()
	end

	gClientToGameDelegate:Guo()
	self:RefreshShowOp(false)
end

M.OnHuBtnClick = function(self)
	if self.IsReach(self) then
		self.OnHuBtnClickReach(self)

		return
	end

	if self.game.useLocalInput then
		self.game:FSM_ConfirmHu()
	end

	gClientToGameDelegate:Hu()
	self:RefreshShowOp(false)
	self:StopOpCountDown()
end

M.OnPengBtnClick = function(self)
	if self.IsReach(self) then
		self.OnPengBtnClickReach(self)

		return
	end

	local pengPai = self.game:FindPaiInfoByInstanceId(self.game.lastDiscardInstanceId)
	local pengPaiList = {}

	for i = 1, #self.handCard do
		local view = self.handCard[i]

		if view.id ~= pengPai.Index then
			pengPaiList[#pengPaiList + 1] = view.paiInfo

			if #pengPaiList ~= 2 then
				break
			end
		end
	end

	gClientToGameDelegate:Peng(pengPaiList)
	self:RefreshShowOp(false)
end

M.OnRenderAutoStateListItem = function(self, btn, csIndex)
	btn.SetSelected(btn, self.instance.isAuto[csIndex + 1])
end

M.OnLookAtTableBtnPress = function(self)
	self.mgr.machine:SetCamActive(true, 2)
end

M.OnLookAtTableBtnRelease = function(self)
	self.mgr.machine:SetCamActive(false, 2)
end

M.OnResetViewBtnClick = function(self)
	self.mgr.machine:SetCamActive(true, 1)
	self:PlayResetViewTween()
end

M.PlayResetViewTween = function(self)
	if self.instance.resetViewTween then
		self.instance.resetViewTween:Kill()

		self.instance.resetViewTween = nil
	end

	if self.mgr.machine.CurrentVCamType == 1 then
		self.instance.lookAtNorm = Vector2.zero

		self.mgr.machine:SetMainCameraLookAtNormalized(0, 0)

		return
	end

	self.instance.lookAtNorm = self.instance.lookAtNorm or Vector2.zero
	local startX = self.instance.lookAtNorm.x
	local startY = self.instance.lookAtNorm.y

	if startX ~= 0 and startY ~= 0 then
		self.mgr.machine:SetMainCameraLookAtNormalized(0, 0)

		return
	end

	local duration = MahjongConfig.CameraResetDuration or 0.3
	self.instance.resetViewTween = DOTween.To(function ()
		return 0
	end, function (value)
		if not self.instance.lookAtNorm then
			self.instance.lookAtNorm = Vector2.zero
		end

		self.instance.lookAtNorm.x = Mathf.Lerp(startX, 0, value)
		self.instance.lookAtNorm.y = Mathf.Lerp(startY, 0, value)

		self.mgr.machine:SetMainCameraLookAtNormalized(self.instance.lookAtNorm.x, self.instance.lookAtNorm.y)
	end, 1, duration)

	self.instance.resetViewTween:SetEase(MahjongConfig.CameraResetEase or DG.Tweening.Ease.OutCubic)
	self.instance.resetViewTween:OnKill(function ()
		self.instance.resetViewTween = nil
	end)
end

M.OnMotionCameraActive = function(self)
	self.PlayResetViewTween(self)
end

M.RefreshOpBtnSelected = function(self, selectedBtnName)
	local isShowOp = self.bindData.showOp ~= gMaJiangConst.BOOL2CTL[true]
	local btnNames = self:GetEnabledOpBtnNames()

	for i = 1, #btnNames do
		local btnName = btnNames[i]

		self.bindData[btnName]:SetSelected(isShowOp and btnName ~= selectedBtnName)
	end

	self.instance.selectedOpBtnName = isShowOp and selectedBtnName or nil
end

M.OnOpItemFocus = function(self, btnName)
	self.RefreshOpBtnSelected(self, btnName)
end

M.GetEnabledOpBtnNames = function(self)
	local btnNames = {}

	if self.canHu then
		btnNames[#btnNames + 1] = "huBtn"
	end

	if self.canReach then
		btnNames[#btnNames + 1] = "richiBtn"
	end

	if self.canRoundDraw then
		btnNames[#btnNames + 1] = "roundDrawBtn"
	end

	if self.canChow then
		btnNames[#btnNames + 1] = "chiBtn"
	end

	if self.canGang then
		btnNames[#btnNames + 1] = "gangBtn"
	end

	if self.canPeng then
		btnNames[#btnNames + 1] = "pengBtn"
	end

	btnNames[#btnNames + 1] = "guoBtn"

	return btnNames
end

M.SelectOpBtn = function(self, btnName)
	if not btnName then
		return
	end

	self.bindData.opNavigationArea.CurrentActiveContent = self.bindData[btnName]

	self.RefreshOpBtnSelected(self, btnName)
end

M.OnTeachBtnClick = function(self)
	self.stopNext = true

	gPanelManager:CheckShow(gPanelId.S_MA_JIANG_TEACH_PANEL, {
		callback = function ()
			local frameTimer = FrameTimer.New(function ()
				if self.STATE_EnableOnce and self.showOp then
					self:RefreshNav(self.showOp)
				end
			end, 1)

			frameTimer:Start()
		end
	})
end

M.PlayActionBySeats = function(self, seatIDs, action, wait)
	if action ~= nil then
		return
	end

	for i = 1, #seatIDs do
		local localIndex = self.game:MapIndex(seatIDs[i])

		self.feedbackStore[localIndex]:Commit("feedback", action, COMMIT_FORCE)
		self:PlayVoiceByAction(localIndex, action)
	end
end

M.PlayVoiceByAction = function(self, index, action)
	if not self.game.serverRoomInfo.PlayerInfos then
		return
	end

	local player = self.game.serverRoomInfo.PlayerInfos[index]
	local pveNpcTalkId = player.NpcMahjongId or 0

	if pveNpcTalkId == 0 then
		local cfg = MahjongPveMahjongNpcTalkConfig.GetConfig(pveNpcTalkId)
		local soundId = 0

		if not cfg then
			print_error("@wangpeizhi MahjongPveMahjongNpcTalkConfig not found, ID =", pveNpcTalkId)

			return
		end

		if action ~= gMaJiangConst.OpEffectAction.Hu then
			soundId = cfg.HuVoice
		elseif action ~= gMaJiangConst.OpEffectAction.Gang then
			soundId = cfg.GangVoice
		elseif action ~= gMaJiangConst.OpEffectAction.Reach then
			soundId = cfg.ReachVoice
		end

		if soundId == 0 then
			gSoundMgr:PlaySoundByTid(soundId)
		end
	end
end

M.RefreshGame = function(self)
	if self.IsReach(self) then
		self.RefreshReachGame(self)

		return
	end

	local gameInfo = self.game.serverGameInfo
	local bindData = self.bindData
	local names = MahjongConfig.SeatNames
	local banker = gameInfo.Banker
	local mySeatID = self.game.mySeatID
	local nameList = {}

	for i = 1, 4 do
		local nameIndex = (4 + mySeatID + i - 1 - banker) % 4 + 1
		nameList[i] = names[nameIndex]
	end

	self.game:RefreshSeatName(nameList)
	self.game:RefreshIsShow(gMaJiangConst.BOOL2CTL[true])

	self.showCountDown = true
	bindData.cardNum = gameInfo.Remainders
	local turn = gameInfo.Turn

	self:OnSyncMjTurn(turn)

	local gameState = self.game.gameState
	local isOver = gameState ~= GameStateEnum.Over
	bindData.matchEND = gMaJiangConst.BOOL2CTL[isOver]
	local seatInfos = gameInfo.SeatInfos

	for i = 0, 3 do
		self.RefreshCards(self, seatInfos, i)
	end

	self.RefreshShowOp(self, false)
	self.UpdateTooltips(self, gameState)

	for i = 1, 4 do
		local seatIdx = (self.game.mySeatID + i - 1) % 4 + 1
		local info = gameInfo.SeatInfos[seatIdx]
		self.avatarStore[i].scoreLabel = info.Score
	end

	local scores = {}

	for seatID = 0, 3 do
		local info = gameInfo.SeatInfos[seatID + 1]
		scores[seatID + 1] = info and info.Score or 0
	end

	self.game:RefreshSeatScore(scores)
end

M.RefreshHandCardList = function(self)
	self.bindData.handCardProxyList:SetList(#self.handCard)
end

M.IsMyDiscardTurn = function(self)
	local result = self.game.gameState ~= GameStateEnum.Playing and self.turn ~= self.game.mySeatID and not self.showOp and self.bindData.showDingQue == gMaJiangConst.BOOL2CTL[true] and not self.waitingGang and not self.game.pendingGangMoPai

	return result
end

M.RefreshMyHandCardSelectionEffect = function(self)
	local rule = self.game:GetRule()
	local ctx = {
		selectedIndex = self.selectedHandCardIndex,
		isMyDiscardTurn = self:IsMyDiscardTurn()
	}

	for i = 1, #self.handCard do
		local mahjongCard = self.game:GetMyHandCard3D(i)

		if gClientUtils.NotNil(mahjongCard) then
			local state = rule.GetMyHandCardSelectionState(rule, self.handCard[i], i, ctx)
			mahjongCard.isSelected = state.isSelected

			if state.isFocus == nil then
				mahjongCard.isFocus = state.isFocus
			end

			mahjongCard.isGray = state.isGray
		end
	end
end

M.RefreshMatchPrepare = function(self, state)
	local bindData = self.bindData

	if state ~= MahjongRoomState.Idle and self.game.gameState == GameStateEnum.Over then
		self.SortCardIndex = 0

		self.SetTips(self, gMaJiangConst.TipsType.matching)
		self.SetMahjongHuanpaiLabel(self, 0)
	else
		self.SetTips(self, gMaJiangConst.TipsType.notips)
	end
end

M.RefreshMyHandCards = function(self, info, playEffect)
	self.handCard = self.game:GetMyHandDisplayList()
	local dingqueCount = 0

	for i = 1, #self.handCard do
		if self.handCard[i].mask then
			dingqueCount = dingqueCount + 1
		end
	end

	self.myDingqueCount = dingqueCount
	local selectedIndex = self.selectedHandCardIndex

	if selectedIndex and selectedIndex <= #self.handCard then
		selectedIndex = #self.handCard
	end

	local gameState = self.game.gameState

	if not selectedIndex and #self.handCard <= 0 and (gameState ~= GameStateEnum.Playing or gameState ~= GameStateEnum.HuanPai) then
		selectedIndex = self.GetDefaultHandCardIndex(self)
	end

	self.selectedHandCardIndex = selectedIndex

	if selectedIndex and gameState ~= GameStateEnum.Playing then
		self.handCard[selectedIndex].selected = true
	end

	self:RefreshTingAndSetHelperActive(self.bindData.showTingHelper ~= gMaJiangConst.BOOL2CTL[true])
	self:RefreshHandCardList()

	if selectedIndex then
		local success, btn = self.bindData.handCardProxyList:TryGetChildAt(selectedIndex - 1, nil)

		if success and btn then
			self.bindData.navigationArea.CurrentActiveContent = btn
		end
	end

	self.RefreshHuanPaiCursorFocus(self)
	self.RefreshConfirmSelectBtn(self)
end

M.RefreshNav = function(self, hasOp)
	SGUI.UNavigationMgr.Inst.CurrentActiveArea = hasOp and self.bindData.opNavigationArea or self.bindData.navigationArea
	local selectedBtnName = nil

	if hasOp then
		if self.canHu then
			self.bindData.opNavigationArea.CurrentActiveContent = self.bindData.huBtn
			selectedBtnName = "huBtn"
		elseif self.canReach then
			self.bindData.opNavigationArea.CurrentActiveContent = self.bindData.richiBtn
			selectedBtnName = "richiBtn"
		elseif self.canRoundDraw then
			self.bindData.opNavigationArea.CurrentActiveContent = self.bindData.roundDrawBtn
			selectedBtnName = "roundDrawBtn"
		elseif self.canChow then
			self.bindData.opNavigationArea.CurrentActiveContent = self.bindData.chiBtn
			selectedBtnName = "chiBtn"
		elseif self.canGang then
			self.bindData.opNavigationArea.CurrentActiveContent = self.bindData.gangBtn
			selectedBtnName = "gangBtn"
		elseif self.canPeng then
			self.bindData.opNavigationArea.CurrentActiveContent = self.bindData.pengBtn
			selectedBtnName = "pengBtn"
		else
			self.bindData.opNavigationArea.CurrentActiveContent = self.bindData.guoBtn
			selectedBtnName = "guoBtn"
		end
	end

	self.RefreshOpBtnSelected(self, selectedBtnName)
end

M.RefreshOtherStatus = function(self, text)
	for i = 1, 3 do
		self.bindData["status" .. i] = text
	end
end

M.RefreshPlayers = function(self, roomInfo)
	local players = roomInfo.PlayerInfos

	for i = 1, 4 do
		local index = self.game:GetSeatID(i - 1)
		local player = players[index + 1]

		self:AddPlayerByIndex(i, player)
	end
end

M.RefreshRoom = function(self)
	local roomInfo = self.game.serverRoomInfo

	self.RefreshRoomState(self)
	self.RefreshPlayers(self, roomInfo)
end

M.RefreshRoomState = function(self)
	local state = self.game.serverRoomInfo.State

	self:RefreshMatchPrepare(state)
	self:RefreshInitState(state ~= MahjongRoomState.Idle)

	self.bindData.isShowExitBtn = gMaJiangConst.BOOL2CTL[state == MahjongRoomState.Display and state == MahjongRoomState.Idle]
end

M.RefreshShowOp = function(self, hasOp)
	if hasOp then
		local lastOp = self.instance.lastOp

		self:SetTips(gMaJiangConst.TipsType.notips)

		self.instance.lastOp = lastOp

		self.game:ClearTingPreview()
		self:HideTingHelper()
	else
		local tipsType = self.game.pendingGangMoPai and gMaJiangConst.TipsType.notips or self.instance.lastOp

		self:SetTips(tipsType)
	end

	self.bindData.showOp = gMaJiangConst.BOOL2CTL[hasOp]
	self.showOp = hasOp

	self.RefreshNav(self, hasOp)
	self.RefreshConfirmSelectBtn(self)
end

M.TryShowTurnTips = function(self)
	if self.game.hasHu then
		return
	end

	if self.game.pendingGangMoPai then
		return
	end

	if self.showOp then
		self.instance.lastOp = gMaJiangConst.TipsType.turn

		return
	end

	self.SetTipsForce(self, gMaJiangConst.TipsType.turn)
end

M.SetTips = function(self, tipsType)
	tipsType = tipsType or -1

	if self.mgr.debug then
		print_debug("SetTips:", tipsType)
	end

	self.instance.lastOp = tipsType
	self.bindData.tipsTabRect.selectedIndex = tipsType
end

M.SetTipsForce = function(self, tipsType)
	if self.mgr.debug then
		print_debug("SetTipsForce:", tipsType)
	end

	self.instance.lastOp = tipsType
	self.bindData.tipsTabRect.selectedIndex = tipsType
end

M.RemovePlayer = function(self, seatIndex)
	local index = self.game:MapIndex(seatIndex)
	local store = self.avatarStore[index]

	if store then
		store.nameLabel = ""
		store.scoreLabel = ""
		store.iconId = 0
	end
end

M.ResumeOpCountDown = function(self)
	self.enableOpCountDown = true
end

M.DisableTuoGuan = function(self)
	self.SetTuoGuanMask(self, MahjongTuoGuanType.None)
end

M.OnSyncMjAutoEnterTuoGuan = function(self)
	self.SetTuoGuanMask(self, MahjongTuoGuanType.All)
end

M.OnTuoGuanPrefabLoaded = function(self, widget)
	if not gClientUtils.NotNil(widget) then
		return
	end

	self.instance.tuoGuanWidget = widget
	local store = self.GetStoreByWidget(self, widget)
	self.instance.tuoGuanStore = store
	local toggleShowAutoDetail = self.CreateAction(self, self.ToggleShowAutoDetail)
	self.bindData.showAutoDetailBtn.luaClick = toggleShowAutoDetail
	self.bindData.hideAutoDetailBtn.luaClick = toggleShowAutoDetail
	store.showAutoDetailBtn2.luaClick = toggleShowAutoDetail
	store.hideAutoDetailBtn2.luaClick = toggleShowAutoDetail
	store.navigateToTuoGuanBtn.luaClick = self.CreateAction(self, self.NavigateToTuoGuan)
	store.autoBtn1.luaClick = self.CreateActionWithArgs(self, self.OnClickAutoBtn, 1)
	store.autoBtn2.luaClick = self.CreateActionWithArgs(self, self.OnClickAutoBtn, 2)
	store.autoBtn3.luaClick = self.CreateActionWithArgs(self, self.OnClickAutoBtn, 3)
	store.autoStateList.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderAutoStateListItem)

	self.ApplyCurrentTuoGuanStateToStore(self)
end

M.ApplyCurrentTuoGuanStateToStore = function(self)
	local store = self.instance.tuoGuanStore

	if not store then
		return
	end

	local isAuto = self.instance.isAuto

	for i = 1, 3 do
		store["autoBtn" .. i]:SetSelected(isAuto[i] ~= true)
	end

	store.autoStateList:SetSimpleList(3)
end

M.ShowQuickTextMsg = function(self, seatID, msgID)
	local cfg = TextConfig.GetConfig(msgID)

	if cfg ~= nil then
		print_error("TextConfig not found, ID =", msgID)

		return
	end

	self.ShowTextMsg(self, seatID, cfg.Text)
end

M.ShowTextMsg = function(self, seatID, msgTxt)
	local index = self.game:MapIndex(seatID)
	local view = self.feedbackStore[index]

	if view ~= nil then
		return
	end

	view.showBubble = gMaJiangConst.BOOL2CTL[true]
	view.bubbleLabel = msgTxt
	local t = self.bubbleTimers[index]

	if t == nil then
		t.ResetTime(t, MahjongConfig.MaJiangChatBubbleDisppear)
		t.Start(t)
	else
		t = Timer.New(function ()
			view.showBubble = gMaJiangConst.BOOL2CTL[false]
		end, MahjongConfig.MaJiangChatBubbleDisppear)

		t.Start(t)
	end
end

M.SetShowTingHelperCtrl = function(self, isShow)
	if gClientUtils.NotNil(self.rootWidget) then
		local tingHelper = self.rootWidget.transform:Find("tingHelper")

		if tingHelper then
			local anchoredPos = tingHelper.anchoredPosition

			if isShow then
				anchoredPos.z = 0
			else
				anchoredPos.z = -100000
			end

			tingHelper.anchoredPosition = anchoredPos
		end
	end

	self.bindData.showTingHelper = gMaJiangConst.BOOL2CTL[isShow]
end

M.HideTingHelper = function(self)
	self:SetShowTingHelperCtrl(false)
	self.bindData.tingpaiBack:SetActive(false)

	self.tingListData = {}

	self.bindData.tingList:SetSimpleList(0)
end

M.RefreshTingButtonState = function(self)
	if not self.CanPreviewTing(self) then
		self.game:ClearTingPreview()
		self.bindData.tingpaiBtn:SetActive(false)

		self.bindData.tingpaiBtn.interactable = false

		self:HideTingHelper()

		return false
	end

	if self.IsMyDiscardTurn(self) then
		local index = self:GetSelectedHandCardIndex()
		local view = index and self.handCard[index] or nil

		if view then
			self.game:GetTingsInfo(view.id)
		else
			self.game:ClearTingPreview()
		end
	else
		self.game:GetMyCurrentTings()
	end

	local tings = self.game.tingsInfo or {}
	local hasTings = next(tings) == nil

	self.bindData.tingpaiBtn:SetActive(hasTings)

	self.bindData.tingpaiBtn.interactable = hasTings

	if not hasTings then
		self.HideTingHelper(self)
	end

	return hasTings
end

M.RefreshTingAndSetHelperActive = function(self, showHelper)
	if not self.CanPreviewTing(self) then
		self.RefreshTingButtonState(self)

		return
	end

	local hasTings = false

	if self.IsMyDiscardTurn(self) then
		local index = self:GetSelectedHandCardIndex()
		local view = index and self.handCard[index] or nil
		local paiId = view and view.id

		if paiId then
			hasTings = self.game:GetTingsInfo(paiId) ~= true
		else
			self.game:ClearTingPreview()
			self:HideTingHelper()
		end
	else
		hasTings = self.game:GetMyCurrentTings() ~= true
	end

	if not self.RefreshTingButtonState(self) then
		self.HideTingHelper(self)

		return
	end

	if showHelper and hasTings and not table.isNilOrEmpty(self.game.tingsInfo) then
		self.tingListData = self.game.tingsInfo or {}

		self.bindData.tingList:SetSimpleList(#self.tingListData)
		self.bindData.tingpaiBack:SetActive(true)
		self:SetShowTingHelperCtrl(true)
	else
		self.HideTingHelper(self)
	end
end

M.TryShowTingHelper = function(self)
	self.RefreshTingAndSetHelperActive(self, true)
end

M.StopOpCountDown = function(self)
	self.lastCountDownRemain = self.lastRemain
	self.enableOpCountDown = false
end

M.ToggleShowAutoDetail = function(self)
	local isShowAutoDetail = not self.instance.isShowAutoDetail
	self.instance.isShowAutoDetail = isShowAutoDetail

	if isShowAutoDetail then
		self.bindData:Commit("autoCtrl", 1, COMMIT_IMMEDIATELY)

		if gClientUtils.NotNil(self.instance.tuoGuanStore and self.instance.tuoGuanStore.navArea) then
			local tuoGuanNavArea = self.instance.tuoGuanStore.navArea
			SGUI.UNavigationMgr.Inst.CurrentActiveArea = tuoGuanNavArea
		end
	else
		self.bindData.autoCtrl = 0
	end
end

M.NavigateToTuoGuan = function(self)
	if gClientUtils.NotNil(self.instance.tuoGuanStore and self.instance.tuoGuanStore.navArea) and self.instance.isShowAutoDetail then
		local tuoGuanNavArea = self.instance.tuoGuanStore.navArea
		SGUI.UNavigationMgr.Inst.CurrentActiveArea = tuoGuanNavArea
	end
end

M.UpdateTooltips = function(self, gameState)
	local rule = self.game:GetRule()
	local viewData = rule and rule:BuildTooltipsViewData(gameState) or nil

	if viewData then
		self:RefreshOtherStatus(viewData.otherStatusText or "")

		if viewData.tipsType == nil then
			self.SetTips(self, viewData.tipsType)
		end

		if viewData.showDingQue == nil then
			self.bindData.showDingQue = gMaJiangConst.BOOL2CTL[viewData.showDingQue ~= true]
		end
	end

	self.RefreshConfirmSelectBtn(self)
end

M.OnGenerateTipsTab = function(self, index, widget)
	local store = self.GetStoreByWidget(self, widget)
	self.instance.tipsTabStores[index] = store

	if store ~= nil then
		return
	end

	store.EnableImmediatelyCommit(store, true)

	if index ~= gMaJiangConst.TipsType.xuanpai then
		self.RegisterSelectCountDownSync(self, store)

		if gClientUtils.NotNil(store.btn) then
			store.btn.luaClick = self.CreateAction(self, self.OnHuanPaiConfirm)
		end
	elseif index ~= gMaJiangConst.TipsType.turn then
		self.RegisterSelectCountDownSync(self, store)
	elseif index ~= gMaJiangConst.TipsType.huanpaizhong then
		store.text = self.bindData.changeLabel
	end
end

M.OnClickTingHelper = function(self, isShow)
	if isShow then
		self:TryShowTingHelper()

		local tings = self.game.tingsInfo or {}

		if next(tings) ~= nil then
			gDisplayMessageMgr:ShowMessage(MessageConfig.MahjongTingpai)

			return
		end
	else
		self.HideTingHelper(self)
	end
end

M.OnHandCardBeginDrag = function(self)
	self.handCardCanExit = false
end

M.OnHandCardClick = function(self, btn, csIndex)
	local index = csIndex + 1
	local data = self.handCard[csIndex + 1]

	if self.stopNext then
		self.stopNext = false

		return
	end

	local view = data
	local state = self.game.gameState
	btn.enabledDraggingClick = false

	if state ~= GameStateEnum.HuanPai then
		self.ToggleHuanPaiSelection(self, index)
	elseif state ~= GameStateEnum.Playing then
		self.OnHandCardClick_Playing(self, btn, csIndex, view)
	end
end

M.OnHandCardClick_Playing = function(self, btn, csIndex, view)
	if self.game.hasHu then
		return
	end

	if not self.game:GetRule():CanClickHandCard(view) then
		return
	end

	local canGang = self.bindData.canGang or false
	local showOp = self.bindData.showOp ~= gMaJiangConst.BOOL2CTL[true]
	local canOperateHandCard = self.game:GetRule():CanOperateHandCardDuringAction(showOp, canGang)

	if not canOperateHandCard then
		return
	end

	local index = csIndex + 1
	local isDoubleClick = self.selectedHandCardIndex ~= index

	if self.waitingGang then
		btn.enabledDraggingClick = true

		if isDoubleClick then
			self.OutCard(self, index, view)
		else
			self.SetCurrentHandCardSelection(self, index, false)
		end
	else
		if self.autoMode then
			return
		end

		if isDoubleClick then
			self.OutCard(self, index, view)

			return
		end

		btn.enabledDraggingClick = true

		self.SetCurrentHandCardSelection(self, index)
	end
end

M.OutCard = function(self, index, data)
	local isReach = self.IsReach(self)

	if isReach then
		self.OutCardReach(self, index, data)

		return
	end

	local paiInfo = data.paiInfo

	if self.waitingGang then
		self:SetHandCardSelected(index, false)

		slot5 = gClientToGameDelegate

		slot5:Gang(paiInfo).Callback = function (err, needWait)
			if err == 0 then
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
	elseif self.turn ~= self.game.mySeatID then
		if self.game.pendingGangMoPai then
			return false
		end

		if Time.time - self.game.tempBlockDiscardTime >= 1.5 then
			return false
		end

		self.SetHandCardSelected(self, index, false)

		if self.game.myFSM and self.game.myFSM:GetState() == MjStateType.Idle then
			print_error("#NoCreateIssue [MajiangPanelStore] OutCard FSM 当前状态=", self.game.myFSM:GetState(), ", 不是 Idle, 可能会影响动作播放")
		end

		self:SelectNextHandCardAfterOut(index)
		gClientToGameDelegate:ChuPai(paiInfo, false)
		self:SwitchJobDone(true)
		self:RefreshShowOp(false)
		self:SetTips(gMaJiangConst.TipsType.notips)
		self.game:ClearTingPreview()
		self:RefreshTingButtonState()

		return true
	end

	return false
end

M.OnRenderHandCardProxyListItem = function(self, btn, csIndex)
	local index = csIndex + 1
	local data = self.handCard[index]

	self:SetHandCardSelected(index, data.selected)

	btn.luaHover = self:CreateActionWithArgs(self.OnHandCardFocusChange, {
		["\\xd0\\xc821\\xe2"] = true,
		index = index
	})
	btn.luaUnhover = self:CreateActionWithArgs(self.OnHandCardFocusChange, {
		["\\xd0\\xc821\\xe2"] = false,
		index = index
	})
	btn.luaFocus = self:CreateActionWithArgs(self.OnHandCardFocusChange, {
		["\\xd0\\xc821\\xe2"] = true,
		index = index
	})
	btn.luaBlur = self:CreateActionWithArgs(self.OnHandCardFocusChange, {
		["\\xd0\\xc821\\xe2"] = false,
		index = index
	})

	self:UpdateHandCardProxyWidget(index, btn)

	btn.autoClickOnHover = self.game.gameState == GameStateEnum.HuanPai
end

M.OnRenderTingCardItem = function(self, btn, csIndex)
	local data = self.tingListData[csIndex + 1]
	local store = gStoreManager:GetStoreGroup("MajiangTingItemStore"):GetStoreByWidget(btn)
	store.iconId = data.TingIcon
	store.numLabel = data.TingCount
	store.fanLabel = data.TingFan
	store.noYakuCtrl = gMaJiangConst.BOOL2CTL[data.noYaku]
	store.zhentingCtrl = gMaJiangConst.BOOL2CTL[data.zhenTing]
end

M.RefreshHandCardProxyRects = function(self)
	if not self.STATE_EnableOnce or gClientUtils.IsNil(self.bindData.handCardProxyList) then
		return
	end

	local handCard = self.handCard

	if not handCard or #handCard ~= 0 then
		return
	end

	for i = 1, #handCard do
		local success, btn = self.bindData.handCardProxyList:TryGetChildAt(i - 1, nil)

		if success and btn then
			self.UpdateHandCardProxyWidget(self, i, btn)
		end
	end
end

M.UpdateHandCardProxyWidget = function(self, index, btn)
	local mahjongCard = self.game:GetMyHandCard3D(index)
	local rectTransform = btn and btn.rectTransform

	if gClientUtils.IsNil(mahjongCard) or gClientUtils.IsNil(rectTransform) then
		return
	end

	local min, size = mahjongCard.GetFaceScreenPos(mahjongCard, nil, )
	local parentRect = rectTransform.parent

	if gClientUtils.IsNil(parentRect) then
		return
	end

	local max = min + size
	local localMin = gCS.LuaUtils.TransformScreenPointToUI(parentRect, min)
	local localMax = gCS.LuaUtils.TransformScreenPointToUI(parentRect, max)
	local localSize = localMax - localMin
	rectTransform.localPosition = localMin
	rectTransform.sizeDelta = localSize
end

M.SetHandCardSelected = function(self, index, isSelect)
	self.handCard[index].selected = isSelect
	local mahjongCard = self.game:GetMyHandCard3D(index)

	if gClientUtils.NotNil(mahjongCard) then
		local ctx = {
			selectedIndex = self.selectedHandCardIndex,
			isMyDiscardTurn = self:IsMyDiscardTurn(),
			forceSelect = isSelect
		}
		local state = self.game:GetRule():GetMyHandCardSelectionState(self.handCard[index], index, ctx)
		mahjongCard.isSelected = state.isSelected

		if state.isFocus == nil then
			mahjongCard.isFocus = state.isFocus
		end

		mahjongCard.isGray = state.isGray
	end

	local success, btn = self.bindData.handCardProxyList:TryGetChildAt(index - 1, nil)

	if success and btn then
		btn.SetSelected(btn, isSelect)
	end
end

M.SelectSingleHandCard = function(self, csIndex)
	local index = csIndex + 1

	for i = 1, #self.handCard do
		local isSelect = i ~= index

		if self.handCard[i].selected == isSelect then
			self.SetHandCardSelected(self, i, isSelect)
		end
	end
end

M.SetCurrentHandCardSelection = function(self, index, tryShowTing)
	if not index or index <= 1 or index <= #self.handCard then
		self.selectedHandCardIndex = nil

		self:DeselectAllHandCards()
		self.game:ClearTingPreview()
		self:RefreshTingButtonState()
		self:RefreshConfirmSelectBtn()

		return
	end

	local view = self.handCard[index]
	self.selectedHandCardIndex = index

	self:SelectSingleHandCard(index - 1)

	local success, btn = self.bindData.handCardProxyList:TryGetChildAt(index - 1, nil)

	if success and btn then
		self.bindData.navigationArea.CurrentActiveContent = btn
	end

	if tryShowTing == false and self.IsMyDiscardTurn(self) then
		self.TryShowTingHelper(self, view.id)
	else
		self:RefreshTingAndSetHelperActive(self.bindData.showTingHelper ~= gMaJiangConst.BOOL2CTL[true])
	end

	self.RefreshConfirmSelectBtn(self)
end

M.DeselectAllHandCards = function(self)
	for i = 1, #self.handCard do
		if self.handCard[i].selected then
			self.SetHandCardSelected(self, i, false)
		end
	end
end

M.SelectHandCardByIndex = function(self, index)
	if not self.handCard[index] then
		return
	end

	if not self.CanMoveSelection(self) then
		return
	end

	if self.game.gameState ~= GameStateEnum.HuanPai then
		self.SetHuanPaiCursorIndex(self, index)

		return
	end

	if self.waitingGang then
		self.SetCurrentHandCardSelection(self, index, false)

		return
	end

	self.SetCurrentHandCardSelection(self, index)
end

M.SelectNextHandCardAfterOut = function(self, index)
	local count = #self.handCard

	if count < 1 then
		self.selectedHandCardIndex = nil

		self.DeselectAllHandCards(self)
		self.RefreshConfirmSelectBtn(self)

		return
	end

	local displayIndex = index >= count and index + 1 or 1
	self.selectedHandCardIndex = index >= count and index or 1

	self:SelectSingleHandCard(displayIndex - 1)

	local success, btn = self.bindData.handCardProxyList:TryGetChildAt(displayIndex - 1, nil)

	if success and btn then
		self.bindData.navigationArea.CurrentActiveContent = btn
	end

	self.RefreshConfirmSelectBtn(self)
end

M.OnHandCardFocusChange = function(self, args)
	local index = args.index
	local mahjongCard = self.game:GetMyHandCard3D(index)

	if gClientUtils.NotNil(mahjongCard) then
		mahjongCard.isFocus = args.isFocus
	end
end

M.GetSelectedHandCardIndex = function(self)
	local handCard = self.handCard or {}
	local index = self.selectedHandCardIndex

	if index and index > 1 and index < #handCard then
		return index
	end

	return nil
end

M.GetDefaultHandCardIndex = function(self)
	local handCard = self.handCard or {}

	if #handCard <= 0 then
		return 1
	end

	return nil
end

M.CanMoveSelection = function(self)
	if self.bindData.showDingQue ~= gMaJiangConst.BOOL2CTL[true] or self.showOp or self.bindData.showChiSelectorCtrl ~= gMaJiangConst.BOOL2CTL[true] then
		return true
	end

	if self.game.gameState ~= GameStateEnum.HuanPai then
		return self.autoMode == true and not self.jobDone and #self.handCard >= 0
	end

	if self.game.gameState == GameStateEnum.Playing then
		return false
	end

	if self.autoMode ~= true then
		return false
	end

	if self.game.hasHu then
		return false
	end

	local canGang = self.bindData.canGang or false
	local showOp = self.bindData.showOp ~= gMaJiangConst.BOOL2CTL[true]
	local canOperateHandCard = not showOp or showOp and canGang

	return canOperateHandCard
end

M.CanConfirmSelect = function(self)
	local handCard = self.handCard or {}

	if not self:CanMoveSelection() then
		return false
	end

	if self.game.gameState ~= GameStateEnum.HuanPai then
		local index = self:GetSelectedHandCardIndex()
		index = index or self:GetDefaultHandCardIndex()

		return index == nil and handCard[index] == nil
	end

	if self.bindData.showDingQue ~= gMaJiangConst.BOOL2CTL[true] then
		return true
	end

	if self.bindData.showChiSelectorCtrl ~= gMaJiangConst.BOOL2CTL[true] then
		return true
	end

	if self.showOp then
		return true
	end

	if self.turn == self.game.mySeatID then
		return false
	end

	local index = self:GetSelectedHandCardIndex()
	index = index or self:GetDefaultHandCardIndex()

	return index == nil and handCard[index] == nil
end

M.CanPreviewTing = function(self)
	if self.game.gameState == GameStateEnum.Playing then
		return false
	end

	if self.autoMode ~= true then
		return false
	end

	if self.game.hasHu or self.waitingGang then
		return false
	end

	if self.bindData.showDingQue ~= gMaJiangConst.BOOL2CTL[true] or self.showOp then
		return false
	end

	return #self.handCard >= 0
end

M.RefreshConfirmSelectBtn = function(self)
	self.bindData.selectEnterBtn:SetActive(self:CanConfirmSelect())

	if self:IsMyDiscardTurn() then
		self.bindData.navigationArea:RelpaceButtonNameByButtonName(18, 261)
		self.bindData.selectEnterBtn:SetPCKeyInfoTipNameId(261)
	else
		self.bindData.navigationArea:RelpaceButtonNameByButtonName(261, 18)
		self.bindData.selectEnterBtn:SetPCKeyInfoTipNameId(18)
	end
end

M.MoveSelect = function(self, step)
	if self.bindData.showChiSelectorCtrl ~= gMaJiangConst.BOOL2CTL[true] then
		gMaJiangUtils:GetChiSelectorStore():MoveSelection(step)

		return
	end

	if self.bindData.showDingQue ~= gMaJiangConst.BOOL2CTL[true] then
		self.MoveDingQueSelection(self, step)

		return
	end

	if self.showOp then
		self.MoveOpSelection(self, step)

		return
	end

	local count = #self.handCard

	if count < 0 then
		return
	end

	local index = self:GetSelectedHandCardIndex()
	index = index or self:GetDefaultHandCardIndex()

	if not index then
		return
	end

	local targetIndex = index + step

	if targetIndex >= 1 then
		targetIndex = count
	elseif count >= targetIndex then
		targetIndex = 1
	end

	self.SelectHandCardByIndex(self, targetIndex)
end

M.ConfirmSelect = function(self)
	if not self.CanConfirmSelect(self) then
		return
	end

	if self.bindData.showChiSelectorCtrl ~= gMaJiangConst.BOOL2CTL[true] then
		gMaJiangUtils:GetChiSelectorStore():ConfirmSelection()

		return
	end

	if self.game.gameState ~= GameStateEnum.HuanPai then
		local index = self:GetSelectedHandCardIndex()
		index = index or self:GetDefaultHandCardIndex()

		self:ToggleHuanPaiSelection(index)

		return
	end

	if self.bindData.showDingQue ~= gMaJiangConst.BOOL2CTL[true] then
		self.OnSelectDingQue(self)

		return
	end

	if self.showOp then
		self.ConfirmOpSelection(self)

		return
	end

	local index = self.GetSelectedHandCardIndex(self)

	if not index then
		index = self.GetDefaultHandCardIndex(self)

		if not index then
			return
		end

		self.SelectHandCardByIndex(self, index)
	end

	local view = self.handCard[index]

	if not view then
		return
	end

	self.OutCard(self, index, view)
end

M.MoveOpSelection = function(self, step)
	local btnNames = self.GetEnabledOpBtnNames(self)
	local count = #btnNames

	if count < 0 then
		return
	end

	local currentBtnName = self.instance.selectedOpBtnName or btnNames[1]
	local currentIndex = 1

	for i = 1, count do
		if btnNames[i] ~= currentBtnName then
			currentIndex = i

			break
		end
	end

	local nextIndex = currentIndex + step

	if nextIndex >= 1 then
		nextIndex = count
	elseif count >= nextIndex then
		nextIndex = 1
	end

	self.SelectOpBtn(self, btnNames[nextIndex])
end

M.ConfirmOpSelection = function(self)
	local btnName = self.instance.selectedOpBtnName

	if not btnName then
		local btnNames = self.GetEnabledOpBtnNames(self)
		btnName = btnNames[1]

		self.SelectOpBtn(self, btnName)
	end

	if btnName ~= "huBtn" then
		self.OnHuBtnClick(self)
	elseif btnName ~= "gangBtn" then
		self.OnGangBtnClick(self)
	elseif btnName ~= "pengBtn" then
		self.OnPengBtnClick(self)
	elseif btnName ~= "guoBtn" then
		self.OnGuoBtnClick(self)
	elseif btnName ~= "richiBtn" then
		self.OnRichiBtnClick(self)
	elseif btnName ~= "chiBtn" then
		self.OnChiBtnClick(self)
	elseif btnName ~= "roundDrawBtn" then
		self.OnRoundDrawBtnClick(self)
	end
end

M.SetHandCardsVisible = function(self, count, visible)
	for seatID = 0, 3 do
		local info = self.game.serverGameInfo.SeatInfos[seatID + 1]

		if seatID == self.game.mySeatID then
			local addition = visible ~= true and count or -1 * count
			local holdsCount = info.HoldsCount + addition
			local renderHolds = self.game:GetSeatHoldsForRender(seatID, holdsCount, "SetHandCardsVisible")

			if renderHolds == nil then
				self.game:RefreshHandArea(seatID, renderHolds)
			end
		end
	end
end

M.OnHandCardDragEnd = function(self, args)
end

M.OnHandCardEnterDropWidget = function(self)
	self.handCardCanExit = true
end

M.OnHandCardExitDropWidget = function(self)
	self.handCardCanExit = false
end

M.RefreshHuanPaiCursorFocus = function(self)
	local isHuanPai = self.game.gameState ~= GameStateEnum.HuanPai

	if not isHuanPai then
		return
	end

	local selectedIndex = self.selectedHandCardIndex

	for i = 1, #self.handCard do
		local mahjongCard = self.game:GetMyHandCard3D(i)

		if gClientUtils.NotNil(mahjongCard) then
			mahjongCard.isFocus = selectedIndex == nil and i ~= selectedIndex
		end
	end
end
