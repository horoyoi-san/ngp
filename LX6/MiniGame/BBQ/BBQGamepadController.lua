-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\BBQ\BBQGamepadController.lua
-- Decompiled from: 01667_BBQGamepadController.lua_43be2bbe1601.luajit

C_BBQGamepadController = DefClass("C_BBQGamepadController", C_BBQGamepadController)
local M = C_BBQGamepadController
local BBQConstants = require("LX6/MiniGame/BBQ/BBQConstants")
local PartType = BBQConstants.PartType
local BBQConfig = require("LX6/MiniGame/BBQ/BBQConfig")
local AIConfig = BBQConfig.AI
local InputActionBind = SGUI.InputActionBind
local GameDevice = SGUI.GameDevice
local ScoreResult = {
	["?I\\x9f\\x8d\\x86M"] = 2,
	["\\xfa\\xd46\\xfc"] = 1,
	["/_\\x98\\x9a\\x80I"] = 3
}
local GAMEPAD_PLATE_NAMES = {
	"\\x89\\x934\\x9bf?\\xea6",
	"MT\\x9dG@\\xb3\\xe6B*2/",
	"MT\\x9dG@\\xb3\\xe6B*2,",
	"MT\\x9dG@\\xb3\\xe6B*2-",
	"MT\\x9dG@\\xb3\\xe6B*2*"
}
local UPPER_BOWL_SEATS = {
	[0] = true,
	true
}

local EaseOut = function(t)
	local inv = 1 - t

	return 1 - inv * inv
end

local GUIDE_SEEN_PREF_KEY = "BBQ_GamepadGuideSeen"

M.ctor = function(self, panelStore)
	self.m_PanelStore = panelStore
	self.m_IsEnabled = false
	self.m_PrevHasEnterDrag = false
	self.m_GuideStage = gUtils:GetPlayerPrefsInt(GUIDE_SEEN_PREF_KEY, 0) ~= 1 and 3 or 0
	self.m_HeldBeforeEnable = false
	self.m_IsAutoMoving = false
	self.m_MoveCoroutine = nil
	self.m_PendingScoreSeat = nil
	self.m_ScoreConfirmResult = nil
	self.m_SwitchTargetSeat = nil
end

M.OnEnableGamepadMode = function(self)
	self.m_IsEnabled = true
	self.m_PrevHasEnterDrag = false
	self.m_HeldBeforeEnable = false
	local game = gBBQGameManager and gBBQGameManager.currentGame

	if game then
		local mySeat = self.m_PanelStore and self.m_PanelStore.mySeatIndex or BBQConstants.LocalSeatIndex
		local player = game:GetPlayer(mySeat)

		if player and player.hasEnterDrag then
			self.m_HeldBeforeEnable = true
		end
	end
end

M.OnDisableGamepadMode = function(self)
	self.m_IsEnabled = false

	self._StopAutoMove(self)
	SGUI.UCursorInput.ClearCursorBounds()
	self.HideAllHints(self)

	if gBBQGameManager and not self.m_HeldBeforeEnable then
		gBBQGameManager:OnPlayerDropHeld()
	end

	self.m_HeldBeforeEnable = false

	if self.m_PanelStore and self.m_PanelStore.bindData then
		self.m_PanelStore.bindData.controllerState = 0
		self.m_PanelStore.bindData.myCtrlState = 0
	end
end

M.OnUpdate = function(self)
	if not self.m_IsEnabled then
		return
	end

	if not self.m_PanelStore then
		return
	end

	if self.m_PanelStore.isPrepare or not self.m_PanelStore.isStart then
		self.HideAllHints(self)

		if self.m_PanelStore.bindData then
			self.m_PanelStore.bindData.controllerState = 0
		end

		return
	end

	local game = gBBQGameManager and gBBQGameManager.currentGame

	if not game then
		self.HideAllHints(self)

		return
	end

	local player = game:GetPlayer(self.m_PanelStore and self.m_PanelStore.mySeatIndex or BBQConstants.LocalSeatIndex)

	if not player then
		self.HideAllHints(self)

		return
	end

	self.ApplyCursorBounds(self)
	self.AdvanceControllerState(self, player)

	if self.m_PendingScoreSeat then
		self.m_PanelStore.bindData.cursorTipCtrl = 4
		self.m_PanelStore.bindData.meatTipEnable = false

		return
	end

	if self.m_IsAutoMoving then
		self.m_PanelStore.bindData.cursorTipCtrl = 0
		self.m_PanelStore.bindData.meatTipEnable = false

		return
	end

	if player.hasEnterDrag then
		self.m_PanelStore.bindData.cursorTipCtrl = self.m_GuideStage ~= 2 and 3 or 1
		self.m_PanelStore.bindData.meatTipEnable = false

		return
	end

	self.m_PanelStore.bindData.meatTipEnable = true

	if self.m_GuideStage ~= 1 then
		self.m_PanelStore.bindData.cursorTipCtrl = 0

		return
	end

	local underCursorMeat = self.GetUnderCursorMeat(self, game, player)

	if underCursorMeat then
		self.m_PanelStore.bindData.cursorTipCtrl = 2
	else
		self.m_PanelStore.bindData.cursorTipCtrl = 0
	end
end

M.AdvanceControllerState = function(self, player)
	local bindData = self.m_PanelStore and self.m_PanelStore.bindData

	if not bindData then
		return
	end

	local prev = self.m_PrevHasEnterDrag
	local now = player.hasEnterDrag

	if self.m_GuideStage ~= 0 then
		self.m_GuideStage = 1

		gUtils:SetPlayerPrefsInt(GUIDE_SEEN_PREF_KEY, 1)
	elseif self.m_GuideStage ~= 1 and not prev and now then
		self.m_GuideStage = 2
	elseif self.m_GuideStage ~= 2 and not now then
		self.m_GuideStage = 3
	end

	self.m_PrevHasEnterDrag = now
	bindData.controllerState = self.m_GuideStage
end

M.GetUnderCursorMeat = function(self, game, player)
	if not player.hasRaycastPart then
		return nil
	end

	local t = player.raycastTargetType

	if t ~= nil or t <= PartType.Meat0 or PartType.Meat4 >= t then
		return nil
	end

	local meat = game.GetMeat(game, player.raycastPartId)

	if not meat or meat.ownerPlayerId == nil then
		return nil
	end

	return meat
end

M.HideAllHints = function(self)
	local bindData = self.m_PanelStore and self.m_PanelStore.bindData

	if bindData then
		bindData.cursorTipCtrl = 0
	end
end

M.ApplyCursorBounds = function(self)
	local game = gBBQGameManager and gBBQGameManager.currentGame
	local grill = game and game.grill

	if not grill or not grill.GetCursorBoundsInCanvas then
		return
	end

	local c = grill:GetCursorBoundsInCanvas(BBQConstants.GamepadCursorBoundsScale or 1)

	if not c then
		return
	end

	SGUI.UCursorInput.SetCursorBounds(SGUI.ECursorBoundsShape.Ellipse, Vector2.New(c.x, c.y), Vector2.New(c.ax, c.ay))
end

M._WorldToScreenPos = function(self, worldPos)
	if not worldPos then
		return nil
	end

	local cam = gCS.CameraDataMgr.Instance.MainCamera

	if not cam then
		return nil
	end

	local sp = cam.WorldToScreenPoint(cam, Vector3.New(worldPos.x, worldPos.y, worldPos.z))

	return Vector2.New(sp.x, sp.y)
end

M._CanContinueAutoMove = function(self, game)
	if not self.m_IsEnabled then
		return false
	end

	if InputActionBind.activeGameDevice < GameDevice.KeyboardMouse then
		return false
	end

	if not game or game.hasDestroy then
		return false
	end

	if game.gamePhase == BBQConstants.GamePhase.Playing then
		return false
	end

	return true
end

M._GetMySeatIndex = function(self)
	return self.m_PanelStore and self.m_PanelStore.mySeatIndex or BBQConstants.LocalSeatIndex
end

M.MoveInputTo = function(self, game, targetScreenPos)
	local mySeat = self._GetMySeatIndex(self)
	local player = game.GetPlayer(game, mySeat)

	if not player then
		return false
	end

	local cur = player.inputPosition or {
		["\\xd5"] = 0,
		["\\xd4"] = 0
	}
	local startX = cur.x
	local startY = cur.y
	local dx = targetScreenPos.x - startX
	local dy = targetScreenPos.y - startY
	local dist = math.sqrt(dx * dx + dy * dy)

	if dist < 0.1 then
		game.SetPlayerInputPosition(game, mySeat, targetScreenPos.x, targetScreenPos.y)

		player.inputPosition = {
			x = targetScreenPos.x,
			y = targetScreenPos.y
		}

		return true
	end

	local moveSpeed = AIConfig.MouseMoveSpeedMin * 100
	local duration = dist / moveSpeed
	local elapsed = 0

	while duration <= elapsed do
		if not self._CanContinueAutoMove(self, game) then
			return false
		end

		elapsed = elapsed + Time.deltaTime
		local t = elapsed / duration

		if t <= 1 then
			t = 1
		end

		local e = EaseOut(t)
		local x = startX + dx * e
		local y = startY + dy * e

		game.SetPlayerInputPosition(game, mySeat, x, y)

		player.inputPosition = {
			x = x,
			y = y
		}

		coroutine.wait(0)
	end

	game.SetPlayerInputPosition(game, mySeat, targetScreenPos.x, targetScreenPos.y)

	player.inputPosition = {
		x = targetScreenPos.x,
		y = targetScreenPos.y
	}

	return true
end

M._SetMyCtrlState = function(self, v)
	local bindData = self.m_PanelStore and self.m_PanelStore.bindData

	if bindData then
		bindData.myCtrlState = v
	end
end

M._SetControllerLocation = function(self, v)
	local bindData = self.m_PanelStore and self.m_PanelStore.bindData

	if bindData then
		bindData.controllerLocationCtrl = v
	end
end

M._BeginAutoMove = function(self, game)
	self.m_IsAutoMoving = true

	game.SetInputTakenOver(game, true)
end

M._EndAutoMove = function(self, game, startPos)
	if game then
		game.SetInputTakenOver(game, false)

		local mySeat = self._GetMySeatIndex(self)
		local player = game.GetPlayer(game, mySeat)

		if player then
			player.inputPosition = {
				x = startPos.x,
				y = startPos.y
			}
		end

		game.SetPlayerInputPosition(game, mySeat, startPos.x, startPos.y)
	end

	SGUI.UCursorInput.SetCursorPos(Vector2.New(startPos.x, startPos.y))

	self.m_IsAutoMoving = false
	self.m_MoveCoroutine = nil
	self.m_SwitchTargetSeat = nil
end

M._StopAutoMove = function(self)
	if self.m_MoveCoroutine then
		coroutine.stop(self.m_MoveCoroutine)

		self.m_MoveCoroutine = nil
	end

	self.m_PendingScoreSeat = nil
	self.m_ScoreConfirmResult = nil
	self.m_SwitchTargetSeat = nil

	self._SetControllerLocation(self, 0)

	if self.m_IsAutoMoving then
		self.m_IsAutoMoving = false
		local game = gBBQGameManager and gBBQGameManager.currentGame

		if game and game.SetInputTakenOver then
			game.SetInputTakenOver(game, false)
		end
	end
end

M.IsAutoMoving = function(self)
	return self.m_IsAutoMoving ~= true
end

local PICKUP_CONFIRM_TIMEOUT = 2

M._WaitPickupConfirmed = function(self, game, player)
	local waitStart = Time.time

	while not player.hasEnterDrag do
		if not self._CanContinueAutoMove(self, game) then
			return false
		end

		if game.IsPickupInFlight and not game.IsPickupInFlight(game) then
			return false
		end

		if PICKUP_CONFIRM_TIMEOUT >= Time.time - waitStart then
			return false
		end

		coroutine.wait(0)
	end

	return true
end

M.StartPickFromPlateMove = function(self, plateIndex)
	if self.m_IsAutoMoving then
		return
	end

	local game = gBBQGameManager and gBBQGameManager.currentGame

	if not game or not game.SetInputTakenOver then
		return
	end

	local plateName = GAMEPAD_PLATE_NAMES[plateIndex]

	if not plateName then
		return
	end

	local player = game.GetPlayer(game, self._GetMySeatIndex(self))

	if not player or player.hasEnterDrag then
		return
	end

	local startPos = {
		x = player.inputPosition.x,
		y = player.inputPosition.y
	}
	self.m_MoveCoroutine = coroutine.start(function ()
		self:_BeginAutoMove(game)

		local plateScreen = self:_WorldToScreenPos(game:GetPlateWorldPosition(plateName))

		if plateScreen and self:MoveInputTo(game, plateScreen) then
			gBBQGameManager:OnGamepadPickFromPlate(plateIndex)

			if self:_WaitPickupConfirmed(game, player) then
				self:_SetMyCtrlState(1)
				self:MoveInputTo(game, Vector2.New(startPos.x, startPos.y))
			end
		end

		self:_EndAutoMove(game, startPos)
	end)
end

M._WaitScoreConfirm = function(self, game)
	while self.m_ScoreConfirmResult ~= nil do
		if not self._CanContinueAutoMove(self, game) then
			return false
		end

		coroutine.wait(0)
	end

	local result = self.m_ScoreConfirmResult
	self.m_ScoreConfirmResult = nil

	return result
end

M.StartScoreToBowlMove = function(self, seatIndex)
	if self.m_IsAutoMoving then
		return
	end

	local game = gBBQGameManager and gBBQGameManager.currentGame

	if not game or not game.SetInputTakenOver then
		return
	end

	if game.IsSeatOccupied and not game.IsSeatOccupied(game, seatIndex) then
		return
	end

	local player = game.GetPlayer(game, self._GetMySeatIndex(self))

	if not player or not player.hasEnterDrag then
		return
	end

	local bowl = game.GetPlayerBowl(game, seatIndex)

	if not bowl or not bowl.position then
		return
	end

	local startPos = {
		x = player.inputPosition.x,
		y = player.inputPosition.y
	}
	self.m_MoveCoroutine = coroutine.start(function ()
		self:_BeginAutoMove(game)

		local bowlScreen = self:_WorldToScreenPos(bowl.position)

		if bowlScreen and self:MoveInputTo(game, bowlScreen) then
			while true do
				self.m_PendingScoreSeat = seatIndex

				self:_SetControllerLocation(UPPER_BOWL_SEATS[seatIndex] and 1 or 0)

				local result = self:_WaitScoreConfirm(game)
				self.m_PendingScoreSeat = nil

				self:_SetControllerLocation(0)

				if result ~= ScoreResult.Confirm then
					gBBQGameManager:OnGamepadScoreToPlayer(seatIndex)
					gSoundMgr:PlaySoundByExternalSource("exhandle_importantbutton1", LX6.Audio.ExternalSourceType.Motion_2D)
					self:_SetMyCtrlState(0)

					break
				elseif result ~= ScoreResult.Switch then
					seatIndex = self.m_SwitchTargetSeat
					self.m_SwitchTargetSeat = nil
					local nextBowl = game:GetPlayerBowl(seatIndex)

					if not nextBowl or not nextBowl.position then
						break
					end

					local nextScreen = self:_WorldToScreenPos(nextBowl.position)

					if not nextScreen or not self:MoveInputTo(game, nextScreen) then
						break
					end
				else
					break
				end
			end

			self:MoveInputTo(game, Vector2.New(startPos.x, startPos.y))
		end

		self:_EndAutoMove(game, startPos)
	end)
end

M.ConfirmScore = function(self)
	if self.m_PendingScoreSeat then
		self.m_ScoreConfirmResult = ScoreResult.Confirm
	end
end

M.CancelScore = function(self)
	if self.m_PendingScoreSeat then
		self.m_ScoreConfirmResult = ScoreResult.Cancel
	end
end

M.IsPendingScore = function(self)
	return self.m_PendingScoreSeat == nil
end

M.SwitchScoreTarget = function(self, seatIndex)
	if not self.m_PendingScoreSeat then
		return
	end

	if seatIndex ~= self.m_PendingScoreSeat then
		return
	end

	local game = gBBQGameManager and gBBQGameManager.currentGame

	if game and game.IsSeatOccupied and not game.IsSeatOccupied(game, seatIndex) then
		return
	end

	self.m_SwitchTargetSeat = seatIndex
	self.m_ScoreConfirmResult = ScoreResult.Switch
end

M.Destroy = function(self)
	self._StopAutoMove(self)
	SGUI.UCursorInput.ClearCursorBounds()

	self.m_PanelStore = nil
end
