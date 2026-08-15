local InputManager = LX6.Manager.GameInputManager
local Mgr = gVolleyballGameMgr
local CharacterState = Mgr.CharacterState
C_VolleyballPlayerController = DefClass("C_VolleyballPlayerController", C_VolleyballPlayerController, C_VolleyballControllerBase)
local M = C_VolleyballPlayerController

function M:ctor(character, gameInstance)
	self.gamePanel = nil
	self.cameraTrans = nil
	self.mouse0Action = nil
	self.mouse1Action = nil
	self.moveValue = nil
	self.needContinueInput = false

	function self.moveListener(e)
		local input = e:ReadValueVector2()

		self:Input(input)
	end

	self.preInputCo = nil
	self.preInputAction = nil
end

function M:Init()
	self.cameraTrans = gCS.CameraDataMgr.MainCamera.transform

	InputManager.RegisterInputCallback(gInputActionId.MOVEMENT_MOVE, self.moveListener)
end

function M:Input(input)
	if input ~= self.moveValue then
		self.moveValue = input

		if input ~= Vector2.zero then
			input = self:GetHorDirInCamera(input, self.cameraTrans)
		end

		self.view:SetInputByWorldSpace(input)
	end
end

function M:ClickMouse(isMouse0)
	if isMouse0 and self.mouse0Action then
		self.needContinueInput = not self.mouse0Action(self.view)
		self.preInputAction = self.mouse0Action
	elseif not isMouse0 and self.mouse1Action then
		self.needContinueInput = not self.mouse1Action(self.view)
		self.preInputAction = self.mouse1Action
	end

	if self.needContinueInput then
		if self.preInputCo ~= nil then
			coroutine.stop(self.preInputCo)
		end

		self.preInputCo = coroutine.start(self.PreInputCo, self, self.preInputAction, 0.3, 0.03)
	end
end

function M:PreInputCo(action, duration, interval)
	while duration > 0 do
		coroutine.wait(interval)

		if action then
			action(self.view)
		end

		duration = duration - interval
	end
end

function M:GetHorDirInCamera(inputValue, cameraTrans)
	local cameraRad = math.rad(cameraTrans.eulerAngles.y)
	local inputRad = Mathf.Atan2(inputValue.y, inputValue.x)
	local rad = inputRad - cameraRad
	local result = Vector2.New(math.cos(rad), math.sin(rad))

	return result
end

function M:OnPossessionChange(team)
	self.gamePanel:ChangeButtonInteractable(team == self.view.curTeam)
end

function M:OnTargetChange(target)
	return
end

function M:OnCharacterStateChange(_, to)
	if to == CharacterState.None then
		self.mouse0Action = nil
		self.mouse1Action = nil
	elseif to == CharacterState.Free then
		self.mouse0Action = self.view.TryKickBackBall
		self.mouse1Action = self.view.TryPassBall
	elseif to == CharacterState.PreLaunch then
		self.mouse0Action = self.view.TryLaunch
		self.mouse1Action = nil
	elseif to == CharacterState.LaunchQTE then
		self.mouse0Action = self.view.TryQTEConfirm
		self.mouse1Action = nil
	elseif to == CharacterState.SmashQTE then
		self.mouse0Action = self.view.TryQTEConfirm
		self.mouse1Action = self.view.TryQTEFake
	end

	self:ChangePlayerButtonByState(to)
end

function M:ChangePlayerButtonByState(newState)
	if newState == CharacterState.None or newState == CharacterState.Match then
		return
	end

	local hide = 0
	local imageA = 0
	local imageB = 0

	if newState == CharacterState.Free then
		hide = 1
		imageA = 4
		imageB = 0
	elseif newState == CharacterState.SmashQTE then
		hide = 1
		imageA = 2
		imageB = 1
	elseif newState == CharacterState.LaunchQTE then
		hide = 0
		imageA = 1
	elseif newState == CharacterState.PreLaunch then
		self.gamePanel:ChangeButtonInteractable(true)

		hide = 0
		imageA = 0
	end

	if self.gamePanel then
		self.gamePanel:ChangeButtonState(hide, imageA, imageB)
	else
		Mgr:PrintError("GameUIPanel is null")
	end
end

function M:OnDestroy()
	InputManager.UnregisterInputCallback(gInputActionId.MOVEMENT_MOVE, self.moveListener)
end
