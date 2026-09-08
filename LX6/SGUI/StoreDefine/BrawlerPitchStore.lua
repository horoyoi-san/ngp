-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BrawlerPitchStore.lua
-- Decompiled from: 01626_BrawlerPitchStore.lua_5818d163f053.luajit

C_BrawlerPitchStore = DefClass("C_BrawlerPitchStore", C_BrawlerPitchStore, C_StoreGroup)
GroupName2Class.BrawlerPitchStore = C_BrawlerPitchStore
local M = C_BrawlerPitchStore
local Input = UnityEngine.Input
local Screen = UnityEngine.Screen
local GameDevice = SGUI.GameDevice
local UCursorInput = SGUI.UCursorInput
local InputActionBind = SGUI.InputActionBind
local Defaults = {
	["@\\x9e\\x9a\\xa0e"] = 0.5,
	["\\x92;\"6t\\x98r\\xc92\\xaf\\xbd"] = 0.4,
	["POܮ\\x8b\\x8b\r\\xd3\\xed"] = 208,
	["~\\xbd\"\\xe4Q\\xa4h2,8<t\\x92\\xee \\xdc\\xe3"] = 1,
	["2>%\\xd4v\\x8a\\xf11\\xab;\\xd4\\xf3\\xe8s\\xfe"] = 0.2,
	["n\\xb3%\\xe3|\\x8f{3,8<t\\x92\\xee \\xdc\\xe3"] = 0.5,
	["BN˒\\x8f:\\xb9\n\\xce\\xed"] = 0.4,
	["\\xea\\x93\\xff0\\xf0\\xe6\\xdaދ:-"] = 104,
	["\\xea\\x93\\xff0\\xf0\\xe6\\xd9ދ:-"] = 52,
	["/\\x82\\xfe\\xa4\\xb5أ\\xa8\\x8e\\xd8\\xe1&\\xf5\\x99!\\x93\\xe7"] = 0.5,
	["PPmp|="] = 50
}
local shootProgressStartTime = 0
local currentMoveOffsetProgress = 0
local currentMoveDir = Vector3.New(0, 1, 0)

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	for k, v in pairs(Defaults) do
		self[k] = v
	end

	self.handler = nil
	self.lastShotTime = 0
	self.missLevel = 0
	self.tempStopUpdateProgress = false
	self.inCursorVisibleAnim = false
	self.isCursorMove = false
	self.curVelocity = Vector2.New(0, 0)
	self.currentTruePosition = Vector3.New(0, 0, 0)
	self.currentCursorPos = Vector3.New(Screen.width / 2, Screen.height / 2, 0)
	self.targetCenterTransform = nil
end

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
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
	UCursorInput.onCursorPosChange = nil
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	self.handler = data and data.handler
	self.currentInputDevice = InputActionBind.activeGameDevice
	UCursorInput.onCursorPosChange = self:CreateAction("onCursorPosChange")

	UCursorInput.Inst.SetCursorDisplay(false)
	UCursorInput.StopCursorSnap()
	LX6.Manager.GameInputManager.AddCursorControl(LX6.Manager.GameInputManager.ControlType.Gameplay, false, UnityEngine.CursorLockMode.None)
	self:InitSetting()
	self:InitRangeView()
	self:SetCanInput(true)
	self:RefreshDisplay()
end

M.OnClose = function(self)
	self.handler = nil
	UCursorInput.onCursorPosChange = nil

	gCS.GuiUtils.SetPanelHideCursor(gPanelId.S_GAMEPLAY_HUD_PANEL, false)
	UCursorInput.Inst.SetCursorDisplay(true)
	LX6.Manager.GameInputManager.RemoveCursorControl(LX6.Manager.GameInputManager.ControlType.Gameplay)
	gPitchPotGameManager:DestroyGame()
end

M.OnActiveDeviceChange = function(self, device)
	self.currentInputDevice = device
end

M.OnUpdate = function(self)
	if self.handler ~= nil then
		return
	end

	self.UpdateShootProgressFill(self)
	self.RefreshShootBtnInteractable(self)
	self.UpdateCursorInput(self)

	if self.bindData.CanInput and not self.tempStopUpdateProgress then
		self.UpdateRandomMoveCursorOffset(self)
	end
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.ON_ACTIVE_DEVICE_CHANGED] = self.CreateAction(self, "OnActionDeviceChanged")
	}

	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnActionDeviceChanged = function(self)
	self.currentInputDevice = InputActionBind.activeGameDevice
end

M.RegisterWidget = function(self)
	self.bindData.BtnShotFull.luaClick = self.CreateAction(self, self.OnClickBtnShotFull)
	self.bindData.BtnShot.luaClick = self.CreateAction(self, self.OnClickBtnShot)
	self.bindData.joyStick.luaValueChanged = self.CreateAction(self, self.OnJoyStickValueChanged)
end

M.OnClickBtnShotFull = function(self)
	self.OnShoot(self)
end

M.OnClickBtnShot = function(self)
	self.OnShoot(self)
end

M.OnJoyStickValueChanged = function(self, dx, dy, size)
	self.curVelocity = Vector2.New(dx, dy) * size * 20
end

M.InitSetting = function(self)
	local setting = self.handler and self.handler.GetPitchSetting and self.handler:GetPitchSetting()

	if setting then
		for k, v in pairs(setting) do
			if v == nil then
				self[k] = v
			end
		end
	end

	if self.handler and self.handler.GetTargetCenterTransform then
		self.targetCenterTransform = self.handler:GetTargetCenterTransform()
	end
end

M.InitRangeView = function(self)
	self.bindData.okRangeFillAmount = self.qteOkRange * 0.5
	self.bindData.okRotateZ = -90 + self.qteOkRange * 0.5 / 2 * 360
	self.bindData.perfectRangeFillAmount = self.qtePerfectRange * 0.5
	self.bindData.perfectRotateZ = -90 + self.qtePerfectRange * 0.5 / 2 * 360
end

M.RefreshDisplay = function(self)
	if self.handler ~= nil or self.handler.GetPitchDisplay ~= nil then
		return
	end

	local display = self.handler:GetPitchDisplay()

	if display ~= nil then
		return
	end

	if display.leftTimes == nil then
		self.bindData.leftTimes = display.leftTimes
	end

	if display.scoreText == nil then
		self.bindData.scoreText = display.scoreText
	end

	if display.scoreProgress == nil and self.bindData.scoreProgress then
		self.bindData.scoreProgress:ProgressToValue(display.scoreProgress * 100)
	end
end

M.OnShoot = function(self)
	if self.handler ~= nil or not self.bindData.CanInput then
		return
	end

	if self.inCursorVisibleAnim then
		return
	end

	if gLogicTime.time - self.lastShotTime >= self.shotCD then
		return
	end

	if self.handler.CanShoot and not self.handler:CanShoot() then
		return
	end

	local factor = self.bindData.shootProgressFillAmount or 0

	if factor <= 0.5 - self.qtePerfectRange / 2 and factor >= 0.5 + self.qtePerfectRange / 2 then
		self.missLevel = 0
	elseif factor <= 0.5 - self.qteOkRange / 2 and factor >= 0.5 + self.qteOkRange / 2 then
		self.missLevel = 1
	else
		self.missLevel = 2
	end

	local screenPoint = self.bindData.CursorPosition

	if screenPoint ~= nil then
		self.UpdateRandomMoveCursorOffset(self)

		screenPoint = self.bindData.CursorPosition
	end

	if screenPoint ~= nil then
		screenPoint = Vector3.New(0, 0, 0)
	end

	if self.missLevel <= 0 then
		local missDir = Vector3.Normalize(Vector3.New((0.5 - math.random()) * 2, (0.5 - math.random()) * 2, 0))

		if self.missLevel ~= 1 then
			screenPoint = screenPoint + missDir * math.random() * self.missLevel1Size
		else
			screenPoint = screenPoint + missDir * math.random() * self.missLevel2Size
		end
	end

	local worldPosition, hitGameObject, flyDirection = nil
	local worldPos = self.bindData.RootRect:TransformPoint(screenPoint)
	local sguiScreen = gCS.LuaUtils.WorldToSGUIScreenPoint(worldPos)
	local hitInfo = gCS.LuaUtils.GetUIToCameraHitIncludeTriggers(sguiScreen)

	if hitInfo and hitInfo.collider == nil then
		worldPosition = hitInfo.point
		hitGameObject = hitInfo.collider.gameObject
	else
		local cam = gCS.CameraDataMgr.Instance.MainCamera
		local ray = cam.ScreenPointToRay(cam, Vector3.New(sguiScreen.x, sguiScreen.y, 0))
		flyDirection = Vector3.New(ray.direction.x, ray.direction.y, ray.direction.z)
	end

	self.lastShotTime = gLogicTime.time

	self.SetCanInput(self, false)
	gCS.LuaUtils.PlayAnimationByName(self.bindData.DoShootAnim, "S_vx_DartGamePanel_CrosshairShoot")

	if self.handler.OnPitchShoot then
		self.handler:OnPitchShoot({
			missLevel = self.missLevel,
			worldPosition = worldPosition,
			hitGameObject = hitGameObject,
			flyDirection = flyDirection
		})
	end

	self.RefreshDisplay(self)
end

M.UpdateShootProgressFill = function(self)
	if not self.bindData.CanInput then
		return
	end

	if self.tempStopUpdateProgress then
		return
	end

	local progress = (shootProgressStartTime - gLogicTime.time) * self.scatterBarMoveSpeed % 2
	local amount = nil

	if progress < 1 then
		amount = progress
	else
		amount = 2 - progress
	end

	self.bindData.shootProgressFillAmount = amount
	self.bindData.perfectOverFillAmount = Mathf.Clamp(amount - (1 - self.qtePerfectRange) / 2, 0, self.qtePerfectRange)
	self.bindData.progressHeadHintZ = 90 - amount * 180
end

M.RefreshShootBtnInteractable = function(self)
	local canShoot = not self.inCursorVisibleAnim and self.bindData.CanInput and self.shotCD > gLogicTime.time - self.lastShotTime
	self.bindData.BtnShot.interactable = canShoot
	self.bindData.BtnShotFull.interactable = canShoot
	self.bindData.leftStickBtn.interactable = canShoot
end

M.UpdateCursorInput = function(self)
	local pos = nil

	if self.currentInputDevice ~= GameDevice.KeyboardMouse and gCS.LuaUtils.IsPCPlatformOrEditorAdaptive() then
		pos = Input.mousePosition
	elseif self.currentInputDevice ~= GameDevice.PlayStation or self.currentInputDevice ~= GameDevice.Xbox then
		pos = self.currentCursorPos
	else
		self.currentCursorPos = self.currentCursorPos + self.curVelocity * self.mobileSpeed
		pos = self.currentCursorPos
	end

	if pos ~= nil then
		return
	end

	pos.x = Mathf.Clamp(pos.x, 0, Screen.width)
	pos.y = Mathf.Clamp(pos.y, 0, Screen.height)
	local delta = pos - self.currentTruePosition

	if math.abs(delta.x) >= 0.01 or math.abs(delta.y) <= 0.01 then
		if self.bindData.CanInput then
			self.currentTruePosition = pos
		end

		self.isCursorMove = true
	else
		self.isCursorMove = false
	end
end

M.UpdateRandomMoveCursorOffset = function(self)
	currentMoveOffsetProgress = currentMoveOffsetProgress + Time.deltaTime * self.crossHairsMoveSpeed

	if currentMoveOffsetProgress > 2 then
		currentMoveDir = Vector3.Normalize(Vector3.New((0.5 - math.random()) * 2, (0.5 - math.random()) * 2, 0))
		currentMoveOffsetProgress = currentMoveOffsetProgress % 2
	end

	local currentScreenRealPoint = gCS.LuaUtils.ScreenPointUI(self.bindData.RootRect, self.currentTruePosition)
	local currentPosition = nil

	if currentMoveOffsetProgress < 1 then
		currentPosition = currentScreenRealPoint + currentMoveDir * currentMoveOffsetProgress * self.swayRange
	else
		currentPosition = currentScreenRealPoint + currentMoveDir * (2 - currentMoveOffsetProgress) * self.swayRange
	end

	self.bindData.CursorPosition = currentPosition
end

M.ResetRandomPosition = function(self)
	if self.currentInputDevice ~= GameDevice.KeyboardMouse and gCS.LuaUtils.IsPCPlatformOrEditorAdaptive() then
		LX6.Manager.GameInputManager.SetCursorPositionInPC(Screen.width / 2, Screen.height / 2)
	elseif self.currentInputDevice ~= GameDevice.PlayStation or self.currentInputDevice ~= GameDevice.Xbox then
		self.currentCursorPos = Vector3.New(Screen.width / 2, Screen.height / 2, 0)

		UCursorInput.ResetCursorPos()
	end

	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		self.currentCursorPos = Vector3.New(Screen.width / 2, Screen.height / 2, 0)
	end
end

M.onCursorPosChange = function(self, position)
	local rect = UCursorInput.Inst.gameObject:GetComponent(typeof(UnityEngine.RectTransform))
	local width = rect.rect.width
	local height = rect.rect.height
	local worldPos = rect.parent:TransformPoint(Vector3.New(position.x - width / 2, position.y - height / 2, 0))
	local pos = gCS.LuaUtils.WorldToSGUIScreenPoint(worldPos)
	self.currentCursorPos = Vector3.New(pos.x, pos.y, 0)
end

M.SetReadyForShoot = function(self)
	self.SetCanInput(self, true)
	self.RefreshDisplay(self)
end

M.SetCanInput = function(self, isCanInput)
	if isCanInput and self.bindData.CanInput == isCanInput then
		self.ResetRandomPosition(self)

		self.tempStopUpdateProgress = false

		gCS.LuaUtils.PlayAnimationByName(self.bindData.DoShootAnim, "S_vx_DartGamePanel_CrosshairOpen")

		local delay = gCS.LuaUtils.GetAnimationTime(self.bindData.DoShootAnim, "S_vx_DartGamePanel_CrosshairOpen")
		self.inCursorVisibleAnim = false

		if delay <= 0 then
			self.inCursorVisibleAnim = true

			Timer.New(function ()
				self.inCursorVisibleAnim = false
			end, delay):Start()
		end
	end

	self.bindData.CanInput = isCanInput

	if self.bindData.BtnShotFull then
		self.bindData.BtnShotFull.interactable = isCanInput
	end

	if self.bindData.BtnShot then
		self.bindData.BtnShot.interactable = isCanInput
	end

	if self.bindData.leftStickBtn then
		self.bindData.leftStickBtn.interactable = isCanInput
	end
end
