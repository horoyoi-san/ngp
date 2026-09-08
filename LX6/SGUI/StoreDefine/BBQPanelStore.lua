-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BBQPanelStore.lua
-- Decompiled from: 01666_BBQPanelStore.lua_4bd3935ed034.luajit

C_BBQPanelStore = DefClass("C_BBQPanelStore", C_BBQPanelStore, C_StoreGroup)
GroupName2Class.BBQPanelStore = C_BBQPanelStore
local M = C_BBQPanelStore
local GameInputManager = LX6.Manager.GameInputManager
local InputActionBind = SGUI.InputActionBind
local GameDevice = SGUI.GameDevice

require("LX6/MiniGame/BBQ/BBQGamepadController")

local BBQConstants = require("LX6/MiniGame/BBQ/BBQConstants")

local FormatCountDownTime = function(seconds)
	local s = math.max(seconds, 0)
	local min = math.floor(s / 60)
	local sec = math.floor(s % 60)

	return gString.Format("%02d:%02d", min, sec)
end

M.ctor = function(self)
	self.totalTime = 0
	self.isStart = false
	self.playerScoreDic = {}
	self.saucePos = {}
	self.isPressing = false
	self.startPressPos = Vector2.zero
	self.hasTriggeredDrag = false
	self.pressPosThreshold = BBQConstants.MousePressDragThreshold
	self.gamepadMode = false
	self.m_GamepadCtrl = nil
end

M.DefineAllVariables = function(self)
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
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

M.GetAvatarWidgetForSeat = function(self, seat)
	local key = BBQConstants.SeatToAvatarKey[seat]

	if not key then
		return nil
	end

	return self.bindData[key .. "Avatar"]
end

M.RefreshSeatAvatarOnline = function(self, seat)
	if not self.isOnline then
		return
	end

	local game = gBBQGameManager and gBBQGameManager.currentGame

	if not game or not game.GetSeatPid then
		return
	end

	local pid = game.GetSeatPid(game, seat)

	local apply = function(widget)
		if not widget then
			return
		end

		local store = gStoreManager:GetStoreGroup("CommonAccountAvatarStore"):GetStoreByWidget(widget)

		if not store or not store.userInfoLight then
			return
		end

		store.userInfoLight.pid = pid or 0
		store.isSelfCtrl = seat ~= self.mySeatIndex and 1 or 0
		store.isEmptyCtrl = pid and 0 or 1
		store.teamColor = self._seatColors[seat]
		store.posNumber = seat + 1
		store.showPlayerNumberCtrl = 0

		widget.luaRenderTooltip = function(btn, tooltip, _)
			if store.userInfoLight and store.userInfoLight.pid == 0 then
				gSocialPalyerTooltipManager:OnRenderToolTips(store.userInfoLight.pid, btn, tooltip, _)
			else
				btn:CloseTooltip()
			end
		end
	end

	apply(self.GetAvatarWidgetForSeat(self, seat))
end

M.Init = function(self)
	self.bindData.FullBtn:SetActive(true)
	self.bindData.MyMouse:SetActive(true)

	self.bindData.myScore = 0
	self.bindData.p1Score = 0
	self.bindData.p2Score = 0
	self.bindData.p3Score = 0
	self.bindData.countDownTime = FormatCountDownTime(self.totalTime)
	self.bindData.counterFillAmount = 1
	self.isStart = true

	self.bindData.MeFeedback.gameObject:SetActive(false)
	self.bindData.P1Feedback.gameObject:SetActive(false)
	self.bindData.P2Feedback.gameObject:SetActive(false)

	slot1 = self.bindData.P3Feedback.gameObject

	slot1:SetActive(false)

	self.playerScoreDic = {
		[0] = 0,
		0,
		0,
		0
	}
	self.isPressing = false
	self.startPressPos = Vector2.zero
	self.hasTriggeredDrag = false
	self._seatColors = {
		[0] = LTConfig.PoiGameConfig.BBQ_CharNameColor2,
		LTConfig.PoiGameConfig.BBQ_CharNameColor3,
		LTConfig.PoiGameConfig.BBQ_CharNameColor1,
		LTConfig.PoiGameConfig.BBQ_CharNameColor4
	}

	if self.isOnline then
		local game = gBBQGameManager and gBBQGameManager.currentGame

		for seat = 0, 3 do
			self:RefreshSeatAvatarOnline(seat)

			local pid = game and game.GetSeatPid and game:GetSeatPid(seat)

			if pid then
				local slot = game and game.GetMouseSlotForSeat and game:GetMouseSlotForSeat(seat)

				if slot ~= "self" then
					self.bindData.meTeamColor = self._seatColors[seat]
				elseif slot then
					self.bindData[slot .. "TeamColor"] = self._seatColors[seat]
				end
			end
		end
	else
		local meColor = self._seatColors[2]
		local p1Color = self._seatColors[0]
		local p2Color = self._seatColors[1]
		local p3Color = self._seatColors[3]
		local playerColors = {
			[0] = p1Color,
			p2Color,
			meColor,
			p3Color
		}
		local aiNpcIdBySeat = gBBQGameManager and gBBQGameManager:GetSinglePlayerSeatNpcMap() or {}
		self.playerProfile = {}

		for playerId = 0, 3 do
			local profile = {
				color = playerColors[playerId],
				number = tostring(playerId + 1)
			}

			if playerId ~= BBQConstants.LocalSeatIndex then
				profile.name = gClientUtils.GetCurrentSpiritDisplayName()
				local _, headPath = gImageManager:GetHeadIconByHeadIconInfo(gPlayerManager.infoLogin.bindData.infoPzHeadInfo, gPlayerManager.infoLogin.bindData.sexType, true)
				local imgCfg = LTConfig.ImageNewAvatarConfig.GetConfig(headPath) or LTConfig.ImageNewAvatarConfig.GetConfig(LTConfig.ImageNewAvatarConfig.AdultMH)
				local sguiImageId = imgCfg and imgCfg.SguiImageId or 0
				local sguiImgCfg = imgCfg and LTConfig.SguiImageConfig.GetConfig(sguiImageId)
				profile.headIconPath = sguiImgCfg and sguiImgCfg.ImgPath or ""
				profile.headIconId = sguiImageId
			else
				local npcId = aiNpcIdBySeat[playerId]
				local npcCfg = npcId and LTConfig.NpcCultivationConfig.GetConfig(npcId)
				profile.isEmpty = not npcCfg
				profile.name = npcCfg and npcCfg.Name or ""
				local sguiImageId = npcCfg and npcCfg.SChatHeadId or 0
				local sguiImgCfg = LTConfig.SguiImageConfig.GetConfig(sguiImageId)
				profile.headIconPath = sguiImgCfg and sguiImgCfg.ImgPath or ""
				profile.headIconId = sguiImageId
			end

			self.playerProfile[playerId] = profile
		end

		self.bindData.myName = self.playerProfile[2].name
		self.bindData.player1Name = self.playerProfile[0].name
		self.bindData.player2Name = self.playerProfile[1].name
		self.bindData.player3Name = self.playerProfile[3].name

		local initAvatar = function(widget, playerId)
			if not widget then
				return
			end

			local store = gStoreManager:GetStoreGroup("CommonAccountAvatarStore"):GetStoreByWidget(widget)

			if not store then
				return
			end

			local p = self.playerProfile[playerId]
			store.headIconPath = p.headIconPath
			store.posNumber = p.number
			store.teamColor = p.color
			store.showPlayerNumberCtrl = 0
			store.isEmptyCtrl = p.isEmpty and 1 or 0
			store.headBtn.interactable = false
		end

		initAvatar(self.bindData.MeAvatar, 2)
		initAvatar(self.bindData.P1Avatar, 0)
		initAvatar(self.bindData.P2Avatar, 1)
		initAvatar(self.bindData.P3Avatar, 3)

		self.bindData.meTeamColor = meColor
		self.bindData.p1TeamColor = p1Color
		self.bindData.p2TeamColor = p2Color
		self.bindData.p3TeamColor = p3Color
	end

	local game = gBBQGameManager and gBBQGameManager.currentGame

	if game and game.IsSeatOccupied then
		for seat = 0, 3 do
			local slot = game.GetMouseSlotForSeat(game, seat)

			if slot and slot == "self" then
				local mouseWidget = self.bindData[slot .. "Mouse"]

				if mouseWidget then
					mouseWidget.gameObject:SetActive(game:IsSeatOccupied(seat))
				end
			end
		end
	end

	gCS.GuiUtils.SetPanelHideCursor(gPanelId.BBQ_PANEL_STORE, true)
	GameInputManager.AddCursorControl(LX6.Manager.GameInputManager.ControlType.Gameplay, false, UnityEngine.CursorLockMode.None)
end

M.OnShow = function(self, panelId, data)
	self.totalTime = data.seconds
	self.isOnline = gLinkManager:CheckInLinkMode()
	local game = gBBQGameManager and gBBQGameManager.currentGame
	self.mySeatIndex = self.isOnline and game and game.mySeatIndex or BBQConstants.LocalSeatIndex
	self.bindData.mypositionCtrl = self.mySeatIndex
	local sp = data.saucePos

	if sp ~= nil then
		self.saucePos = {}
	elseif type(sp) ~= "table" then
		self.saucePos = sp
	elseif sp.ToTable then
		self.saucePos = sp.ToTable(sp)
	else
		self.saucePos = {}
	end

	self.Init(self)

	if gBBQGameManager then
		gBBQGameManager.panelRef = self
	end

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.gamepadMode = GameDevice.KeyboardMouse <= InputActionBind.activeGameDevice

		if self.m_GamepadCtrl ~= nil then
			self.m_GamepadCtrl = C_BBQGamepadController.new(self)
		end

		self.ApplyInputMode(self)
	end
end

M.OnClose = function(self)
	self.isStart = false

	if self.m_GamepadCtrl then
		self.m_GamepadCtrl:Destroy()

		self.m_GamepadCtrl = nil
	end

	self.gamepadMode = false
end

M.OnActiveDeviceChange = function(self, device)
	self.gamepadMode = GameDevice.KeyboardMouse <= device

	if self.isPressing then
		self.isPressing = false
		self.hasTriggeredDrag = false

		if gBBQGameManager then
			gBBQGameManager:ClearPressTarget()
		end
	end

	self.ApplyInputMode(self)
end

M.ApplyInputMode = function(self)
	if self.m_GamepadCtrl then
		if self.gamepadMode then
			self.m_GamepadCtrl:OnEnableGamepadMode()
		else
			self.m_GamepadCtrl:OnDisableGamepadMode()
		end
	end
end

M.OnRestart = function(self)
	self:Init()

	self.gamepadMode = GameDevice.KeyboardMouse <= InputActionBind.activeGameDevice

	self:ApplyInputMode()
end

M.OnGameTimerUp = function(self)
	self.isStart = false

	if self.m_GamepadCtrl then
		SGUI.UCursorInput.ClearCursorBounds()
	end

	self.bindData.myCtrlState = 0
	self.bindData.p1CtrlState = 0
	self.bindData.p2CtrlState = 0
	self.bindData.p3CtrlState = 0

	if self.isOnline then
		gCS.GuiUtils.SetPanelHideCursor(gPanelId.BBQ_PANEL_STORE, false)
		GameInputManager.RemoveCursorControl(LX6.Manager.GameInputManager.ControlType.Gameplay)

		return
	end

	local rankListData = {}
	local scoreArray = {}
	local game = gBBQGameManager and gBBQGameManager.currentGame

	for playerId, score in pairs(self.playerScoreDic) do
		if not game or not game.IsSeatOccupied or game.IsSeatOccupied(game, playerId) then
			table.insert(scoreArray, {
				playerId = playerId,
				score = score
			})
		end
	end

	table.sort(scoreArray, function (a, b)
		if a.score == b.score then
			return b.score <= a.score
		else
			return a.playerId <= b.playerId
		end
	end)

	for rank, info in ipairs(scoreArray) do
		local p = self.playerProfile[info.playerId]

		table.insert(rankListData, {
			playerId = info.playerId,
			score = info.score,
			rank = rank,
			playerName = p.name,
			playerHeadIcon = p.headIconId,
			playerNumber = p.number,
			playerColor = p.color
		})
	end

	gCS.GuiUtils.SetPanelHideCursor(gPanelId.BBQ_PANEL_STORE, false)
	GameInputManager.RemoveCursorControl(LX6.Manager.GameInputManager.ControlType.Gameplay)

	if gBBQGameManager then
		gBBQGameManager:OnGameResultReady(rankListData)
	end
end

M.OnGameEndOnline = function(self, endInfo)
	self.isStart = false

	if self.m_GamepadCtrl then
		SGUI.UCursorInput.ClearCursorBounds()
	end

	gCS.GuiUtils.SetPanelHideCursor(gPanelId.BBQ_PANEL_STORE, false)
	GameInputManager.RemoveCursorControl(LX6.Manager.GameInputManager.ControlType.Gameplay)

	local game = gBBQGameManager and gBBQGameManager.currentGame
	local rankArray = {}

	for seat = 0, 3 do
		local pid = game and game.GetSeatPid and game:GetSeatPid(seat) or nil
		local score = endInfo and endInfo.FinalScores and endInfo.FinalScores[seat] or 0

		if pid then
			table.insert(rankArray, {
				pid = pid,
				score = score
			})
		end
	end

	table.sort(rankArray, function (a, b)
		if a.score == b.score then
			return b.score <= a.score
		end

		return a.pid <= b.pid
	end)

	local showList = {}

	for _, item in ipairs(rankArray) do
		table.insert(showList, {
			id = item.pid,
			customFields = {
				score = tostring(item.score)
			}
		})
	end

	if gBBQGameManager then
		gBBQGameManager:OnGameResultReadyOnline(showList)
	end
end

M.RefreshAllScoresOnline = function(self)
	if not self.isOnline then
		return
	end

	local game = gBBQGameManager and gBBQGameManager.currentGame

	if not game then
		return
	end

	for seat = 0, 3 do
		local p = game.GetPlayer and game:GetPlayer(seat)
		local score = p and p.totalScore or 0
		self.playerScoreDic[seat] = score
	end

	self.bindData.myScore = self.playerScoreDic[2] or 0
	self.bindData.p1Score = self.playerScoreDic[0] or 0
	self.bindData.p2Score = self.playerScoreDic[1] or 0
	self.bindData.p3Score = self.playerScoreDic[3] or 0
end

M.OnPlayerScore = function(self, playerId, score, cookedLevel, authoritativeTotal)
	if self.playerScoreDic[playerId] ~= nil then
		self.playerScoreDic[playerId] = 0
	end

	self.ShowFeedback(self, playerId, score, cookedLevel)

	if authoritativeTotal == nil then
		self.playerScoreDic[playerId] = authoritativeTotal
	else
		self.playerScoreDic[playerId] = self.playerScoreDic[playerId] + score
	end

	self.bindData.myScore = self.playerScoreDic[2] or 0
	self.bindData.p1Score = self.playerScoreDic[0] or 0
	self.bindData.p2Score = self.playerScoreDic[1] or 0
	self.bindData.p3Score = self.playerScoreDic[3] or 0
end

M.ShowFeedback = function(self, playerId, score, cookedLevel)
	self._ShowFeedbackOnWidget(self, self.GetFeedbackWidget(self, playerId), score, cookedLevel)
end

M._ShowFeedbackOnWidget = function(self, widget, score, cookedLevel)
	if not widget then
		return
	end

	widget.gameObject:SetActive(true)

	local store = self:GetStoreByWidget(widget)

	if store then
		store.score = score

		store.Commit(store, "feedback", (cookedLevel + 1) % 5, COMMIT_FORCE)
	end
end

M.GetFeedbackWidget = function(self, playerId)
	if playerId ~= 2 then
		return self.bindData.MeFeedback
	elseif playerId ~= 0 then
		return self.bindData.P1Feedback
	elseif playerId ~= 1 then
		return self.bindData.P2Feedback
	else
		return self.bindData.P3Feedback
	end

	return null
end

M.OnUpdate = function(self)
	if not self.isStart then
		return
	end

	local game = gBBQGameManager and gBBQGameManager.currentGame

	if not game then
		return
	end

	if self.isPressing and not self.hasTriggeredDrag and not self.gamepadMode then
		local mousePos = UnityEngine.Input.mousePosition
		local dx = mousePos.x - self.startPressPos.x
		local dy = mousePos.y - self.startPressPos.y
		local threshold = self.pressPosThreshold

		if dx * dx + dy * dy <= threshold * threshold then
			self.hasTriggeredDrag = true

			gBBQGameManager:OnPlayerBeginDrag()
		end
	end

	local t = math.max(game.gameTimer, 0)
	self.bindData.countDownTime = FormatCountDownTime(t)
	self.bindData.counterFillAmount = self.totalTime <= 0 and t / self.totalTime or 0

	self:UpdateMousePositions()

	if self.m_GamepadCtrl then
		self.m_GamepadCtrl:OnUpdate()
	end
end

M.UpdateMousePositions = function(self)
	local game = gBBQGameManager and gBBQGameManager.currentGame

	if not game then
		return
	end

	if not self.bindData.RootRect or gCS.LuaUtils.IsNull(self.bindData.RootRect) then
		return
	end

	local positions = game.playerInputPositions

	local toVec2 = function(pos)
		return Vector2.New(pos and pos.x or 0, pos and pos.y or 0)
	end

	for seat = 0, 3 do
		if not game.IsSeatOccupied or game.IsSeatOccupied(game, seat) then
			local slot = game.GetMouseSlotForSeat(game, seat)
			local screenPos = gCS.LuaUtils.ScreenPointUI(self.bindData.RootRect, toVec2(positions[seat]))

			if slot ~= "self" then
				self.bindData.selfMousePos:SetLocalPositionXY(screenPos.x, screenPos.y)
			elseif slot ~= "p1" then
				self.bindData.p1Mouse:SetLocalPositionXY(screenPos.x, screenPos.y)

				self.bindData.p1CtrlState = game:IsSeatHoldingMeat(seat) and 1 or 0
			elseif slot ~= "p2" then
				self.bindData.p2Mouse:SetLocalPositionXY(screenPos.x, screenPos.y)

				self.bindData.p2CtrlState = game:IsSeatHoldingMeat(seat) and 1 or 0
			elseif slot ~= "p3" then
				self.bindData.p3Mouse:SetLocalPositionXY(screenPos.x, screenPos.y)

				self.bindData.p3CtrlState = game:IsSeatHoldingMeat(seat) and 1 or 0
			end
		end
	end
end

M.RegisterWidget = function(self)
	self.bindData.FullBtn.luaPress = self.CreateAction(self, "OnPressFullBtn")
	self.bindData.FullBtn.luaRelease = self.CreateAction(self, "OnReleaseFullBtn")

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.meat1Btn.luaClick = self.CreateAction(self, "OnGamepadPickFromPlate1")
		self.bindData.meat2Btn.luaClick = self.CreateAction(self, "OnGamepadPickFromPlate2")
		self.bindData.meat3Btn.luaClick = self.CreateAction(self, "OnGamepadPickFromPlate3")
		self.bindData.meat4Btn.luaClick = self.CreateAction(self, "OnGamepadPickFromPlate4")
		self.bindData.meat5Btn.luaClick = self.CreateAction(self, "OnGamepadPickFromPlate5")
		self.bindData.pickUpBtn.luaClick = self.CreateAction(self, "OnGamepadPickOrPlace")
		self.bindData.putDownBtn.luaClick = self.CreateAction(self, "OnGamepadPickOrPlace")
		self.bindData.confBtn.luaClick = self.CreateAction(self, "OnGamepadScoreConfirm")
		self.bindData.cancBtn.luaClick = self.CreateAction(self, "OnGamepadScoreCancel")
		self.bindData.turnOverBtn.luaClick = self.CreateAction(self, "OnGamepadFlip")
		self.bindData.turnOverBtn.luaPress = self.CreateAction(self, "OnGamepadFlipPress")
		self.bindData.turnOverBtn.luaRelease = self.CreateAction(self, "OnGamepadFlipRelease")
		self.bindData.meBtn.luaClick = self.CreateAction(self, "OnGamepadScoreToP2")
		self.bindData.p1Btn.luaClick = self.CreateAction(self, "OnGamepadScoreToP0")
		self.bindData.p2Btn.luaClick = self.CreateAction(self, "OnGamepadScoreToP1")
		self.bindData.p3Btn.luaClick = self.CreateAction(self, "OnGamepadScoreToP3")
	end
end

M.OnPressFullBtn = function(self)
	if self.gamepadMode then
		return
	end

	if self.isPrepare or not self.isStart then
		return
	end

	self.isPressing = true
	self.hasTriggeredDrag = false
	self.bindData.myCtrlState = 1
	local mousePos = UnityEngine.Input.mousePosition
	self.startPressPos = Vector2.New(mousePos.x, mousePos.y)

	if gBBQGameManager then
		gBBQGameManager:CapturePressTarget(mousePos.x, mousePos.y)
	end
end

M.OnReleaseFullBtn = function(self)
	if self.gamepadMode then
		return
	end

	if self.isPrepare or not self.isStart then
		return
	end

	if not self.isPressing then
		return
	end

	self.isPressing = false
	self.bindData.myCtrlState = 0

	if self.hasTriggeredDrag then
		self.hasTriggeredDrag = false

		if gBBQGameManager then
			gBBQGameManager:OnPlayerEndDrag()
		end
	elseif gBBQGameManager then
		gBBQGameManager:OnPlayerClick()
	end

	if gBBQGameManager then
		gBBQGameManager:ClearPressTarget()
	end
end

M._GamepadGuard = function(self)
	if self.m_GamepadCtrl and self.m_GamepadCtrl:IsAutoMoving() then
		return false
	end

	return self.gamepadMode and not self.isPrepare and self.isStart
end

M._IsGuideStagePickMeat = function(self)
	return self.bindData.controllerState ~= 1
end

M._GamepadPickFromPlate = function(self, plateIndex)
	if not self._GamepadGuard(self) then
		return
	end

	if self.m_GamepadCtrl then
		self.m_GamepadCtrl:StartPickFromPlateMove(plateIndex)
	end
end

M.OnGamepadPickFromPlate1 = function(self)
	self._GamepadPickFromPlate(self, 1)
end

M.OnGamepadPickFromPlate2 = function(self)
	self._GamepadPickFromPlate(self, 2)
end

M.OnGamepadPickFromPlate3 = function(self)
	self._GamepadPickFromPlate(self, 3)
end

M.OnGamepadPickFromPlate4 = function(self)
	self._GamepadPickFromPlate(self, 4)
end

M.OnGamepadPickFromPlate5 = function(self)
	self._GamepadPickFromPlate(self, 5)
end

M.OnGamepadPickOrPlace = function(self)
	if not self._GamepadGuard(self) then
		return
	end

	if self._IsGuideStagePickMeat(self) then
		return
	end

	gBBQGameManager:OnGamepadPickOrPlace()

	local game = gBBQGameManager and gBBQGameManager.currentGame
	local player = game and game:GetPlayer(self.mySeatIndex or BBQConstants.LocalSeatIndex)
	local inFlight = game and game.IsPickupInFlight and game:IsPickupInFlight()
	self.bindData.myCtrlState = (player and player.hasEnterDrag or inFlight) and 1 or 0
end

M.OnGamepadFlip = function(self)
	if not self._GamepadGuard(self) then
		return
	end

	if self._IsGuideStagePickMeat(self) then
		return
	end

	gBBQGameManager:OnGamepadFlip()
end

M.OnGamepadFlipPress = function(self)
	if self._GamepadGuard(self) and not self._IsGuideStagePickMeat(self) then
		self.bindData.myCtrlState = 1
	end
end

M.OnGamepadFlipRelease = function(self)
	if not self.gamepadMode then
		return
	end

	local game = gBBQGameManager and gBBQGameManager.currentGame
	local player = game and game:GetPlayer(self.mySeatIndex or BBQConstants.LocalSeatIndex)
	local inFlight = game and game.IsPickupInFlight and game:IsPickupInFlight()
	self.bindData.myCtrlState = (player and player.hasEnterDrag or inFlight) and 1 or 0
end

M._GamepadScoreToPlayer = function(self, seatIndex)
	if self.m_GamepadCtrl and self.m_GamepadCtrl:IsPendingScore() then
		self.m_GamepadCtrl:SwitchScoreTarget(seatIndex)

		return
	end

	if not self._GamepadGuard(self) then
		return
	end

	if self.m_GamepadCtrl then
		self.m_GamepadCtrl:StartScoreToBowlMove(seatIndex)
	end
end

M.OnGamepadScoreToP0 = function(self)
	self._GamepadScoreToPlayer(self, 0)
end

M.OnGamepadScoreToP1 = function(self)
	self._GamepadScoreToPlayer(self, 1)
end

M.OnGamepadScoreToP2 = function(self)
	self._GamepadScoreToPlayer(self, 2)
end

M.OnGamepadScoreToP3 = function(self)
	self._GamepadScoreToPlayer(self, 3)
end

M.OnGamepadScoreConfirm = function(self)
	if self.m_GamepadCtrl then
		self.m_GamepadCtrl:ConfirmScore()
	end
end

M.OnGamepadScoreCancel = function(self)
	if self.m_GamepadCtrl then
		self.m_GamepadCtrl:CancelScore()
	end
end
