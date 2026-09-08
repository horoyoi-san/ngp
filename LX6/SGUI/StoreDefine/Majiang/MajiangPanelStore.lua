-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\Majiang\MajiangPanelStore.lua
-- Decompiled from: 01211_MajiangPanelStore.lua_67f58592a36f.luajit

C_MajiangPanelStore = DefClass("C_MajiangPanelStore", C_MajiangPanelStore, C_StoreGroup)
GroupName2Class.MajiangPanelStore = C_MajiangPanelStore
local M = C_MajiangPanelStore

dofile("LX6/SGUI/StoreDefine/Majiang/MajiangPanelStore_Shared.lua")
dofile("LX6/SGUI/StoreDefine/Majiang/MajiangPanelStore_XLCH_BattleUI.lua")
dofile("LX6/SGUI/StoreDefine/Majiang/MajiangPanelStore_XLCH_HandArea.lua")
dofile("LX6/SGUI/StoreDefine/Majiang/MajiangPanelStore_Reach.lua")

M.OnAwake = function(self)
	self.instance = {
		tipsTabStores = {},
		isAuto = {}
	}
	self.avatarStore = {
		{},
		{},
		{},
		{}
	}
	self.feedbackStore = {}
	self.handCard = {}
	self.bindData.handCardProxyList.luaRenderItem = self:CreateAction(self.OnRenderHandCardProxyListItem)
	self.bindData.handCardProxyList.luaClick = self:CreateAction(self.OnHandCardClick)

	self.bindData.handCardProxyList.onGetTIndex = function()
		return 0
	end

	self.bindData.tuoGuanContainer:SetActive(false)

	local initTuoGuanTimer = FrameTimer.New(function ()
		if gClientUtils.IsNil(self.bindData.tuoGuanContainer) then
			return
		end

		self.bindData.tuoGuanContainer:SetActive(true)
		self.bindData.tuoGuanContainer:SetUrlWithCallback("Assets/Res/SGUI/Panel/MaJiang/S_MajiangPanel_TuoGuan.prefab", self:CreateAction(self.OnTuoGuanPrefabLoaded))
	end, 1)

	initTuoGuanTimer:Start()

	self.bindData.backBtn.luaClick = self:CreateAction(self.mgr.ShowLeaveCurrentRoundDialog, self.mgr)
	self.bindData.tingpaiBtn.luaPress = self:CreateActionWithArgs(self.OnClickTingHelper, true)
	self.bindData.tingpaiBtn.luaRelease = self:CreateActionWithArgs(self.OnClickTingHelper, false)
	self.bindData.tingpaiBack.luaClick = self:CreateActionWithArgs(self.OnClickTingHelper, false)
	self.bindData.tingList.luaSimpleRenderItem = self:CreateAction(self.OnRenderTingCardItem)
	self.bindData.tipsTabRect.OnGenerateTab = self:CreateAction(self.OnGenerateTipsTab)
	self.bindData.huBtn.luaClick = self:CreateAction(self.OnHuBtnClick)
	self.bindData.gangBtn.luaClick = self:CreateAction(self.OnGangBtnClick)
	self.bindData.pengBtn.luaClick = self:CreateAction(self.OnPengBtnClick)
	self.bindData.guoBtn.luaClick = self:CreateAction(self.OnGuoBtnClick)
	self.bindData.huBtn.luaFocus = self:CreateActionWithArgs(self.OnOpItemFocus, "huBtn")
	self.bindData.gangBtn.luaFocus = self:CreateActionWithArgs(self.OnOpItemFocus, "gangBtn")
	self.bindData.pengBtn.luaFocus = self:CreateActionWithArgs(self.OnOpItemFocus, "pengBtn")
	self.bindData.guoBtn.luaFocus = self:CreateActionWithArgs(self.OnOpItemFocus, "guoBtn")
	self.bindData.richiBtn.luaClick = self:CreateAction(self.OnRichiBtnClick)
	self.bindData.chiBtn.luaClick = self:CreateAction(self.OnChiBtnClick)
	self.bindData.roundDrawBtn.luaClick = self:CreateAction(self.OnRoundDrawBtnClick)
	self.bindData.richiBtn.luaFocus = self:CreateActionWithArgs(self.OnOpItemFocus, "richiBtn")
	self.bindData.chiBtn.luaFocus = self:CreateActionWithArgs(self.OnOpItemFocus, "chiBtn")
	self.bindData.roundDrawBtn.luaFocus = self:CreateActionWithArgs(self.OnOpItemFocus, "roundDrawBtn")

	self.bindData.richiBtn:SetActive(false)
	self.bindData.chiBtn:SetActive(false)
	self.bindData.roundDrawBtn:SetActive(false)

	self.bindData.teachBtn.luaClick = self:CreateAction(self.OnTeachBtnClick)
	self.bindData.lookAtTableBtn.luaPress = self:CreateAction(self.OnLookAtTableBtnPress)
	self.bindData.lookAtTableBtn.luaRelease = self:CreateAction(self.OnLookAtTableBtnRelease)
	self.bindData.resetViewBtn.luaClick = self:CreateAction(self.OnResetViewBtnClick)
	self.bindData.selectLeftBtn.luaPress = self:CreateActionWithArgs(self.OnMoveSelectPress, -1)
	self.bindData.selectLeftBtn.luaRelease = self:CreateAction(self.OnMoveSelectRelease)
	self.bindData.selectRightBtn.luaPress = self:CreateActionWithArgs(self.OnMoveSelectPress, 1)
	self.bindData.selectRightBtn.luaRelease = self:CreateAction(self.OnMoveSelectRelease)
	self.bindData.selectEnterBtn.luaClick = self:CreateAction(self.ConfirmSelect)
	self.bindData.selectToListLastItemNavBtn.luaFocus = self:CreateActionWithArgs(self.OnSelectFirstOrLastFocus, false)
	self.bindData.selectToListFirstItemNavBtn.luaFocus = self:CreateActionWithArgs(self.OnSelectFirstOrLastFocus, true)
	self.bindData.dragArea.luaPress = self:CreateAction(self.OnDragAreaPress)
	self.bindData.dragArea.luaRelease = self:CreateAction(self.OnDragAreaRelease)
	self.bindData.rStickRespond.luaGamePadInputChanged = self:CreateAction(self.OnRStickInput)
end

M.StopMoveSelectTimer = function(self)
	if self.moveSelectTimer then
		self.moveSelectTimer:Stop()

		self.moveSelectTimer = nil
	end
end

M.OnMoveSelectPress = function(self, step)
	self.StopMoveSelectTimer(self)

	if not self.CanMoveSelection(self) then
		return
	end

	self:MoveSelect(step)

	self.moveSelectTimer = Timer.New(function ()
		if self:CanMoveSelection() then
			self:MoveSelect(step)
		end
	end, gMaJiangConst.MoveSelectRepeatInterval, -1)

	self.moveSelectTimer:Start()
end

M.OnMoveSelectRelease = function(self)
	self.StopMoveSelectTimer(self)
end

M.OnSelectFirstOrLastFocus = function(self, isFirst)
	local target = isFirst and 1 or #self.handCard

	self:SelectHandCardByIndex(target)
end

M.OnClose = function(self)
	self.StopMoveSelectTimer(self)

	if self.countDownTimer then
		self.countDownTimer:Stop()

		self.countDownTimer = nil
	end

	self:ClearMessageEvents()
	self.mgr:GetGameNullableCall():UnRegisterStore()
	self.mgr:DestroyGame("PanelClose")
end

M.OnDestroy = function(self)
	if self.aniCo then
		self.aniCo = coroutine.stop(self.aniCo)
	end

	if self.instance then
		if self.instance.resetViewTween then
			self.instance.resetViewTween:Kill()

			self.instance.resetViewTween = nil
		end

		if self.instance.richiAutoDiscardTimer then
			self.instance.richiAutoDiscardTimer:Stop()

			self.instance.richiAutoDiscardTimer = nil
		end

		self.instance.richiAutoDiscardPending = false
		self.instance = nil
	end

	self.StopMoveSelectTimer(self)

	self.rotationDiff = nil
end

M.OnInit = function(self)
	slot1 = self.mgr
	self.game = slot1:GetGame()
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
	self.selectedHandCardIndex = nil
	self.showCountDown = false
	self.enableOpCountDown = true
	self.lastCountDownRemain = 0
	self.discardCardInfo = {}
	self.lastPlayVoiceEffectTime = 0
	self.bubbleTimers = {}

	for i = 1, 4 do
		local store = self.GetStoreByWidget(self, self.bindData["feedback" .. i])
		self.feedbackStore[i] = store
	end

	self.game:RegisterStore(self)
end

M.OnShow = function(self, panelId, data)
	gPanelManager:Close(gPanelId.S_EMPTY_FULL_SCREEN_PANEL)
	self:OnInit()

	if self.game.isNewGame then
		self.OnNewGame(self)
	end

	self:RefreshRoom()
	self:RefreshGame()
	self:DisableTuoGuan()
	self:RefreshConfirmSelectBtn()

	self.countDownTimer = Timer.New(self:CreateAction(self.HandleTimeCountDown), 1, -1):Start()
	slot3 = ipairs
	slot5 = self.game.queuedActions or {}

	for _, v in slot3(slot5) do
		self.game:RunAction(unpack(v))
	end
end

M.OnUpdate = function(self)
	self.RefreshHandCardProxyRects(self)

	local mouseMoveVal = gCS.LuaUtils.GetCameraRotateInput()

	if mouseMoveVal.x == 0 or mouseMoveVal.y == 0 then
		local rotateSpeed = LTConfig.MahjongConfig.CameraFreelookRotateSpeed

		self.UpdateCameraLookAt(self, mouseMoveVal, rotateSpeed)
	end
end

M.RefreshInitState = function(self, state)
	self.bindData.isIniting = gMaJiangConst.BOOL2CTL[state]

	self.UpdateTooltips(self, self.game.gameState)
	self.RefreshShowOp(self, false)
end

M.ctor = function(self)
	self.mgr = gMaJiangManager
	self.game = nil
end
