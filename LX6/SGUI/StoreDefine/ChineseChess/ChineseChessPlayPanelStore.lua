-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ChineseChess\ChineseChessPlayPanelStore.lua
-- Decompiled from: 01264_ChineseChessPlayPanelStore.lua_08305e990b86.luajit

C_ChineseChessPlayPanelStore = DefClass("C_ChineseChessPlayPanelStore", C_ChineseChessPlayPanelStore, C_StoreGroup)
GroupName2Class.ChineseChessPlayPanelStore = C_ChineseChessPlayPanelStore
local M = C_ChineseChessPlayPanelStore

M.OnAwake = function(self)
	self.instance = {
		targetItems = {},
		pointBtnMap = {}
	}

	self.RegisterWidget(self)
end

M.RegisterWidget = function(self)
	self.bindData.undoBtn.luaClick = self:CreateAction(self.OnUndoBtnClick)
	self.bindData.exitBtn.luaClick = self:CreateAction(self.OnExitBtnClick)
	self.bindData.cancelBtn.luaClick = self:CreateAction(self.OnCancelBtnClick)

	self.bindData.cancelBtn:SetActive(false)

	self.bindData.showOptionBtn.luaClick = self:CreateAction(self.OnShowOptionBtnClick)
	self.bindData.targetList.luaRenderItem = self:CreateAction(self.OnRenderTargetListItem)
	self.bindData.targetList.luaPress = self:CreateAction(self.OnTargetListItemPress)

	self.bindData.targetList.onGetTIndex = function()
		return 0
	end

	self.bindData.optionContainer:SetActive(false)
end

M.OnShow = function(self, panelId, data)
	self.Init(self, gChineseChessMgr._waitPanelReadyToken)

	self.bindData.onlineCtrl = 0
end

M.Cleanup = function(self)
	self.optionVisible = false

	self.bindData.optionContainer:SetActive(false)

	if self.instance.delayUUID then
		gLuaTimeMgrUtils.CancelUnitDelay(self.instance.delayUUID)

		self.instance.delayUUID = nil
	end

	self.instance.pointUIPositions = nil
	self.instance.chessScreenSize = nil
	self.instance.targetItems = {}

	table.clear(self.instance.pointBtnMap)
	self.bindData.targetList:SetList(0)
	self.bindData.cancelBtn:SetActive(false)
	self.SubGroup.ChineseChessPlayerStore_Left:BindPlayer(nil)
	self.SubGroup.ChineseChessPlayerStore_Right:BindPlayer(nil)
end

M.Init = function(self, waitToken)
	self:Cleanup()

	local my, enemy = gChineseChessMgr:GetPlayerInfo2()
	local isFlipChart = gChineseChessMgr.IsFlipChart

	self.SubGroup.ChineseChessPlayerStore_Left:BindPlayer(my)

	local isDoubleAi = gChineseChessMgr.zoneInfo and gChineseChessMgr.zoneInfo.GameType ~= UX.Game.ChineseChessGameType.DoubleAI

	self.SubGroup.ChineseChessPlayerStore_Left:SetMode(isFlipChart, isDoubleAi)
	self.SubGroup.ChineseChessPlayerStore_Right:BindPlayer(enemy)
	self.SubGroup.ChineseChessPlayerStore_Right:SetMode(isFlipChart, isDoubleAi)
	self:RefreshUndoBtn()

	local TargetsFullRefresh = function()
		self:InitPointUIPositions()

		self.instance.chessScreenSize = nil

		self:RefreshTargetList()
	end

	TargetsFullRefresh()

	self.instance.delayUUID = gLuaTimeMgrUtils.Delay(TargetsFullRefresh, 2, 2)

	if waitToken then
		waitToken.SetResult(waitToken)
	end
end

M.OnUpdate = function(self)
	if not gChineseChessMgr.IsPlaying then
		return
	end

	local my, enemy = gChineseChessMgr:GetPlayerInfo2()
	local isRedTurnState = gChineseChessMgr:IsTurnStateRed()
	local isMyAction = my.IsRed and isRedTurnState or not my.IsRed and not isRedTurnState

	self.SubGroup.ChineseChessPlayerStore_Left:UpdatePlayer(my, isMyAction)
	self.SubGroup.ChineseChessPlayerStore_Right:UpdatePlayer(enemy, not isMyAction)
end

M.OnDestroy = function(self)
	self.ClearMessageEvents(self)

	if self.instance and self.instance.delayUUID then
		gLuaTimeMgrUtils.CancelUnitDelay(self.instance.delayUUID)
	end

	self.instance = nil
end

M.OnUndoBtnClick = function(self)
	gChineseChessMgr:Undo()
end

M.RefreshUndoBtn = function(self)
	self.bindData.undoBtn.interactable = gChineseChessMgr.Board.Chart:CanUndo()
	self.bindData.undoRemainCount = gChineseChessMgr.Board.Chart:GetUndoRemainCount()
end

M.OnCancelBtnClick = function(self)
	gChineseChessMgr.Board:DeselectChess()
	self.bindData.cancelBtn:SetActive(false)
	self:RefreshTargetList()
end

M.OnExitBtnClick = function(self)
	if gChineseChessMgr.IsPlaying then
		gChineseChessMgr:QuitMidGame()
	else
		gChineseChessMgr:ExitAfterGameEnd()
	end
end

M.OnShowOptionBtnClick = function(self)
	return

	self.optionVisible = not self.optionVisible

	self.bindData.optionContainer:SetActive(self.optionVisible)

	if self.optionVisible then
		self.bindData.optionContainer:SetUrlWithCallback("Assets/Res/SGUI/Panel/ChineseChess/S_ChineseChess_Options.prefab", self:CreateAction(self.OnOptionContainerPrefabLoaded))
	end
end

M.OnOptionContainerPrefabLoaded = function(self, widget)
	if not widget then
		return
	end

	slot2 = gStoreManager
	slot2 = slot2:GetStoreGroup(widget.Store)
	local store = slot2:GetStoreByWidget(widget)

	store.resignBtn.luaClick = function()
		gChineseChessMgr:GiveUp()
		self:HideOptions()
	end

	store.offerDrawBtn.luaClick = function()
		gChineseChessMgr:Draw()
		self:HideOptions()
	end

	store.continueBtn.luaClick = function()
		self:HideOptions()
	end
end

M.HideOptions = function(self)
	self.optionVisible = false

	self.bindData.optionContainer:SetActive(false)
end

M.OnChangePlayer = function(self)
	local my, enemy = gChineseChessMgr:GetPlayerInfo2()
	local isMyAction = gChineseChessMgr:IsMyAction()

	if self.SubGroup.ChineseChessPlayerStore_Left then
		self.SubGroup.ChineseChessPlayerStore_Left:UpdatePlayer(my, isMyAction)
	end

	if self.SubGroup.ChineseChessPlayerStore_Right then
		self.SubGroup.ChineseChessPlayerStore_Right:UpdatePlayer(enemy, not isMyAction)
	end

	self.RefreshTargetList(self)
end

M.OnCountdownVisibleChanged = function(self, visible)
	self.SubGroup.ChineseChessPlayerStore_Left:SetCountdownVisible(visible)
	self.SubGroup.ChineseChessPlayerStore_Right:SetCountdownVisible(visible)
end

M.OnAgainClient = function(self)
	local my, enemy = gChineseChessMgr:GetPlayerInfo2()

	self.SubGroup.ChineseChessPlayerStore_Left:BindPlayer(my)
	self.SubGroup.ChineseChessPlayerStore_Right:BindPlayer(enemy)
	self:RefreshTargetList()
end

M.InitPointUIPositions = function(self)
	local board = gChineseChessMgr.Board
	local cam = gCS.CameraDataMgr.MainCamera
	local parentRect = self.bindData.targetList.rectTransform
	self.instance.pointUIPositions = {}

	for point, tf in pairs(board.PointTransforms) do
		local x, y, z = gCS.LuaUtils.WorldToScreenPointProjected(tf.position, cam, 0, 0, 0)

		if z > 0 then
			self.instance.pointUIPositions[point] = gCS.LuaUtils.ScreenPointUI(parentRect, Vector2.New(x, y))
		end
	end
end

M.OnGameEnd = function(self)
	self.instance.targetItems = {}

	table.clear(self.instance.pointBtnMap)
	self.bindData.targetList:SetList(0)
	self.bindData.cancelBtn:SetActive(false)
	gChineseChessMgr.Board:DeselectChess()
end

M.RefreshTargetList = function(self)
	if not self.instance.pointUIPositions then
		return
	end

	local items = {}
	local board = gChineseChessMgr.Board
	local chart = board.Chart
	local isFlip = gChineseChessMgr.IsFlipChart

	if isFlip then
		for chessId, point in pairs(chart.ChessPointMap) do
			if point and point == -1 then
				if chart.IsFaceDown(chart, chessId) then
					items[#items + 1] = {
						point = point,
						chessId = chessId
					}
				elseif gChineseChessTools.IsRedChess(chessId) ~= gChineseChessMgr.IsRed then
					items[#items + 1] = {
						point = point,
						chessId = chessId
					}
				end
			end
		end

		if board.SelectedChessId and gChineseChessMgr:IsMyAction() then
			local targets = chart.GetMovePoints(chart, board.SelectedChessId)

			for _, targetPoint in ipairs(targets) do
				items[#items + 1] = {
					point = targetPoint
				}
			end
		end
	else
		for chessId, point in pairs(chart.ChessPointMap) do
			if point and point == -1 and gChineseChessTools.IsRedChess(chessId) ~= gChineseChessMgr.IsRed then
				items[#items + 1] = {
					point = point,
					chessId = chessId
				}
			end
		end

		if board.SelectedChessId and gChineseChessMgr:IsMyAction() then
			local targets = chart.GetMovePoints(chart, board.SelectedChessId)

			for _, targetPoint in ipairs(targets) do
				items[#items + 1] = {
					point = targetPoint
				}
			end
		end
	end

	self.instance.targetItems = items

	table.clear(self.instance.pointBtnMap)
	self.bindData.targetList:SetList(#items)

	local lastSelectId = self.instance.lastSelectId
	local btnMap = self.instance.pointBtnMap

	if btnMap[lastSelectId] then
		self.bindData.navArea.CurrentActiveContent = btnMap[lastSelectId]
	elseif #items <= 0 then
		local k, v = next(btnMap)
		self.bindData.navArea.CurrentActiveContent = v
	else
		self.bindData.navArea:SetActiveContentNull()
	end

	self.bindData.cancelBtn:SetActive(board.SelectedChessId == nil)
end

M.OnRenderTargetListItem = function(self, btn, csIndex)
	local index = csIndex + 1
	local item = self.instance.targetItems[index]
	local hoverAction = self.CreateActionWithArgs(self, self.OnTargetItemFocusHover, item)
	local unhoverAction = self.CreateActionWithArgs(self, self.OnTargetItemFocusUnhover, item)
	btn.luaHover = hoverAction
	btn.luaUnhover = unhoverAction
	btn.luaFocus = hoverAction
	btn.luaBlur = unhoverAction
	btn.gameObject.transform.localPosition = self.instance.pointUIPositions[item.point]

	if not self.instance.chessScreenSize then
		self.instance.chessScreenSize = self:CalculateChessScreenSize(gChineseChessMgr.Board:GetPointTransform(item.point).position)
	end

	btn.rectTransform.sizeDelta = self.instance.chessScreenSize
	self.instance.pointBtnMap[item.point] = btn
end

M.OnTargetListItemPress = function(self, btn, csIndex)
	local frameCount = Time.frameCount

	if self.instance.lastClickFrameCount ~= frameCount then
		return
	end

	self.instance.lastClickFrameCount = frameCount
	local index = csIndex + 1
	local item = self.instance.targetItems[index]

	if gChineseChessMgr.IsPlaying then
		gChineseChessMgr.Board:ClickPoint(item.point)

		self.instance.lastSelectId = item.point

		self:RefreshTargetList()
	end
end

M.OnTargetItemFocusHover = function(self, item)
	local board = gChineseChessMgr.Board
	local tf = board:GetPointTransform(item.point)

	gChineseChessMgr.EffectMgr:ShowHoverIndicator(tf.position)

	if item.chessId and board.ChessGoMap[item.chessId] then
		gChineseChessMgr.EffectMgr:ShowChessHoverHighlight(board.ChessGoMap[item.chessId])
	end
end

M.OnTargetItemFocusUnhover = function(self, item)
	gChineseChessMgr.EffectMgr:HideHoverIndicator()
	gChineseChessMgr.EffectMgr:HideChessHoverHighlight()
end

M.CalculateChessScreenSize = function(self, referenceWorldPos)
	local cam = gCS.CameraDataMgr.MainCamera
	local parentRect = self.bindData.targetList.rectTransform
	local worldPos2 = referenceWorldPos + Vector3.New(0.036, 0, 0)
	local x1, y1 = gCS.LuaUtils.WorldToScreenPointProjected(referenceWorldPos, cam, 0, 0, 0)
	local x2, y2 = gCS.LuaUtils.WorldToScreenPointProjected(worldPos2, cam, 0, 0, 0)
	local uiPos1 = gCS.LuaUtils.ScreenPointUI(parentRect, Vector2.New(x1, y1))
	local uiPos2 = gCS.LuaUtils.ScreenPointUI(parentRect, Vector2.New(x2, y2))
	local dx = uiPos2.x - uiPos1.x
	local dy = uiPos2.y - uiPos1.y
	local diameter = math.sqrt(dx * dx + dy * dy)

	return Vector2.Fetch(diameter, diameter)
end

M.ShowCheckmateBanner = function(self)
	self.bindData.checkmateBanner:SetActive(false)
	self.bindData.checkmateBanner:SetActive(true)
end

M.ShowWinBanner = function(self)
	self.bindData.winBanner:SetActive(false)
	self.bindData.winBanner:SetActive(true)
end
