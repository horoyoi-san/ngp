-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ZhuanpanGamePanel.lua
-- Decompiled from: 01271_ZhuanpanGamePanel.lua_d5d83fd41374.luajit

C_ZhuanpanGamePanel = DefClass("C_ZhuanpanGamePanel", C_ZhuanpanGamePanel, C_StoreGroup)
GroupName2Class.ZhuanpanGamePanel = C_ZhuanpanGamePanel
local M = C_ZhuanpanGamePanel
local MyPlayerManager = gCS.MyPlayerManager
local ABPVarManager = MuGenStates.Logic.ABPVarManager
local LogicStateMachineManager = gCS.LogicStateMachineManager
local GaoQiaoUtils = L18.Gameplay.GaoQiaoUtils

M.ctor = function(self)
	self.INWARD_SIGNAL = {
		["\\xc1R\\xab\\xd2\\x8a\\xc7\\xd9\\xcfZ\\xdc"] = 10705,
		["NOu"] = 10703,
		["\\xefs\\xa9\\xc4\\x8cq\\xe2\\xca}\\xfe\\x88\\x9b`\\x91Ks\\x99\\xe2"] = 10706,
		["`j똠7\\x8b0\\xe6\\xd8"] = 10707,
		["h\\x80\\x96\\x8a\\x84"] = 10701,
		["IRk"] = 10704,
		["_To"] = 10702
	}
	self.ABPVar = {
		["\\x88\\xa4\\x98z;\\xfb7"] = 88
	}
	self.OUTWARD_SIGNAL = {
		["JX\\x8dU`\\x97\\xcdeX[Ui"] = 5406,
		["\\xba\tG\\xa9n\\xeb\\x9f\\x9c"] = 5404,
		["`rኻ8\\x99*\\xec\\xc4"] = 5407,
		["&\\xcal\r(\\xfc9\\x89c\\x93w\\x9b\\x93"] = 5405,
		["JX\\x98R~\\x8d\\xc6hXKKi"] = 5403
	}
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)

	self.fixedUpdateHandler = nil
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
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	self.InitTurnTable(self, data)
end

M.OnClose = function(self)
	self.ReleaseTurnTable(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.COMMON_GAMEPLAY_OUTWARD_SIGNAL] = self.CreateAction(self, "OnGamePlayOutWardSignal")
	}
end

M.OnGamePlayOutWardSignal = function(self, eventId, data)
	local pid = data.GetPid(data)

	if pid ~= MyPlayerManager.PlayerUnit.Pid then
		local signalId = data.GetCfgId(data)

		if signalId ~= self.OUTWARD_SIGNAL.ENTER_TORQUE then
			self.isInTorqueAnim = true
		elseif signalId ~= self.OUTWARD_SIGNAL.EXIT_TORQUE then
			self.isInTorqueAnim = false

			gCS.AnimationManager.SetStateSpeed(MyPlayerManager.PlayerUnit, 0, 1)
		elseif signalId ~= self.OUTWARD_SIGNAL.DISABLE_BRAKE then
			self.canBrake = false
		elseif signalId ~= self.OUTWARD_SIGNAL.ENABLE_BRAKE then
			self.canBrake = true
		elseif signalId ~= self.OUTWARD_SIGNAL.SHOW_PANEL then
			self.enableInput = true
			self.bindData.showPanel = 1
		end
	end
end

M.RegisterWidget = function(self)
	local dragBtn = SGUI.EventSystems.DragEventListener.Get(self.bindData.pressBtn.gameObject)
	dragBtn.onBeginDrag = self.CreateAction(self, self.OnBtnDragBegin)
	dragBtn.onDrag = self.CreateAction(self, self.OnBtnDrag)
	dragBtn.onEndDrag = self.CreateAction(self, self.OnBtnDragEnd)
	self.bindData.brakeBtn.luaPress = self.CreateAction(self, self.OnPressBrakeBtn)
	self.bindData.brakeBtn.luaRelease = self.CreateAction(self, self.OnReleaseBrakeBtn)
	self.bindData.brakeRespond.luaGamePadInputChanged = self.CreateAction(self, self.OnBrakeRespond)
	self.bindData.turnRespond.luaGamePadInputChanged = self.CreateAction(self, self.OnTurnRespond)
	self.bindData.joyStick.luaValueChanged = self.CreateAction(self, self.OnJoyTurnRespond)
	self.bindData.joyStick.luaBeginDrag = self.CreateAction(self, self.OnJoyBeginDrag)
	self.bindData.joyStick.luaEndDrag = self.CreateAction(self, self.OnJoyEndDrag)
end

M.OnBtnDragBegin = function(self, eventData)
	if not self.enableInput then
		return
	end

	self.startPosition = eventData.position
	self.dragging = true
end

M.OnBtnDrag = function(self, eventData)
	if not self.enableInput then
		return
	end

	if not self.dragging then
		return
	end

	local current = eventData.position
	local passValue = 100
	local distance = Vector2.Magnitude(current - self.startPosition)

	if passValue >= distance then
		self.dragging = false

		self.AddTorque(self)
	end
end

M.OnBtnDragEnd = function(self, eventData)
	if not self.enableInput then
		return
	end

	self.dragging = false
end

M.OnPressBrakeBtn = function(self)
	if not self.enableInput then
		return
	end

	self.StartBraking(self)
end

M.OnReleaseBrakeBtn = function(self)
	if not self.enableInput then
		return
	end

	self.StopBraking(self)
end

M.OnBrakeRespond = function(self, context)
	if not self.enableInput then
		return
	end

	if context.performed then
		self.StartBraking(self)
	end

	if context.canceled then
		self.StopBraking(self)
	end
end

M.OnTurnRespond = function(self, context)
	if not self.enableInput then
		return
	end

	local value = context.ReadValueVector2(context)

	if context.started then
		self.turnTracking = false
		self.turnAccumAngle = 0
		self.checkAngle = 30
	elseif context.performed then
		self.UpdateStickRotation(self, value)
	elseif context.canceled then
		self.turnTracking = false
		self.turnAccumAngle = 0
		self.checkAngle = 30
	end
end

M.OnJoyBeginDrag = function(self)
	self.turnTracking = false
	self.turnAccumAngle = 0
	self.checkAngle = 30
end

M.OnJoyEndDrag = function(self)
	self.turnTracking = false
	self.turnAccumAngle = 0
	self.checkAngle = 30
end

M.OnJoyTurnRespond = function(self, dirX, dirY, value)
	self.UpdateStickRotation(self, Vector2.New(dirX * value, dirY * value))
end

M.UpdateStickRotation = function(self, value)
	if Vector2.Magnitude(value) >= self.turnStickDeadzone then
		self.turnTracking = false
		self.turnAccumAngle = 0
		self.checkAngle = 30

		return
	end

	local angle = Mathf.Atan2(value.y, value.x) * Mathf.Rad2Deg

	if not self.turnTracking then
		self.turnTracking = true
		self.turnLastAngle = angle
		self.checkAngle = 30

		return
	end

	local delta = Mathf.DeltaAngle(self.turnLastAngle, angle)
	self.turnLastAngle = angle
	local dir = delta * self.turnClockwiseDir

	if dir <= 0 then
		self.turnAccumAngle = self.turnAccumAngle + dir
	elseif dir >= -self.turnReverseTolerance then
		self.turnAccumAngle = 0
	end

	if self.checkAngle < self.turnAccumAngle then
		self.checkAngle = 180

		self.AddTorque(self)

		self.turnAccumAngle = 0
	end
end

M.RegisterUpdate = function(self)
	self.fixedUpdateHandler = FixedUpdateBeat:CreateListener(self.FixedUpdate, self)

	FixedUpdateBeat:AddListener(self.fixedUpdateHandler)
end

M.UnRegisterUpdate = function(self)
	if self.fixedUpdateHandler then
		FixedUpdateBeat:RemoveListener(self.fixedUpdateHandler)

		self.fixedUpdateHandler = nil
	end
end

M.InitTurnTable = function(self, args)
	self.gameObject = args.gameObject
	self.turnTable = self.gameObject:GetComponent(typeof(L18.Gameplay.TurnTable.TurnTable))
	self.startBrake = false
	self.addTorqueCD = GaoQiaoUtils.GetTurnTableAddTorqueCD()
	self.startBrakingCD = GaoQiaoUtils.GetTurnTableStartBrakingWaitTime()
	self.maxBrakingDeltaSpeed = GaoQiaoUtils.GetTurnTableMaxBrakingDeltaSpeed()
	self.canAddTorque = true
	self.curDeltaTime = 0
	self.curBrakeDeltaTime = 0
	self.canBrake = true
	self.lastAngularSpeed = 0
	self.checkAngle = 30
	self.turnStickDeadzone = 0.6
	self.turnTracking = false
	self.turnAccumAngle = 0
	self.turnLastAngle = 0
	self.turnClockwiseDir = -1
	self.turnReverseTolerance = 5

	self:RegisterUpdate()
	self:SendSignal(self.INWARD_SIGNAL.ENTER)

	self.speedCurve = GaoQiaoUtils.GetTurnTableMapToSpeedCurve()
	self.enableInput = false
	self.bindData.showPanel = 0

	if self.turnTable then
		self.turnTable:StartTurnTable()
	else
		print_error("初始化转盘玩法界面失败！需要给机关上需要需要旋转的转盘GameObject上挂TurnTable组件！")
	end
end

M.ReleaseTurnTable = function(self)
	self.gameObject = nil

	if self.turnTable then
		self.turnTable:FinishTurnTable()
	end

	self.turnTable = nil

	self.UnRegisterUpdate(self)
	gCS.GuiUtils.SetPanelHideCursor(gPanelId.S_GAMEPLAY_HUD_PANEL, true)
	self.SendSignal(self, self.INWARD_SIGNAL.EXIT)
end

M.FixedUpdate = function(self)
	if not self.enableInput then
		return
	end

	if self.turnTable then
		local curSpeed = Mathf.Rad2Deg * self.turnTable:GetAngularVelocityLength()

		ABPVarManager.SetFloat(MyPlayerManager.PlayerUnit, self.ABPVar.CurSpeed, curSpeed)

		if self.lastAngularSpeed <= 0.1 and curSpeed >= 0.1 then
			self.SendSignal(self, self.INWARD_SIGNAL.SPEED_STOP)
		end

		self.lastAngularSpeed = curSpeed
	end
end

M.OnUpdate = function(self)
	if not self.enableInput then
		return
	end

	if not self.canAddTorque then
		self.curDeltaTime = self.curDeltaTime - Time.deltaTime

		if self.curDeltaTime >= 0 then
			self.canAddTorque = true
		end
	end

	if self.isInTorqueAnim then
		local speed = 1

		if self.speedCurve then
			local curAngularSpeed = Mathf.Rad2Deg * self.turnTable:GetAngularVelocityLength()
			speed = self.speedCurve:Evaluate(curAngularSpeed)
		end

		gCS.AnimationManager.SetStateSpeed(MyPlayerManager.PlayerUnit, 0, speed)
	end

	if self.startBrake then
		if self.curBrakeDeltaTime <= 0 then
			self.curBrakeDeltaTime = self.curBrakeDeltaTime - Time.deltaTime

			if self.curBrakeDeltaTime >= 0 then
				self.StartBrakingInternal(self)
			end
		end

		local deltaSpeed = Mathf.Rad2Deg * math.abs(self.turnTable:GetAngularVelocityLength() - self.startBrakingVelocity)

		if self.maxBrakingDeltaSpeed >= deltaSpeed then
			self.StopBraking(self)
		end
	end
end

M.AddTorque = function(self)
	if not self.enableInput then
		return
	end

	if self.canAddTorque then
		self.turnTable:AddTorque()
		self:SendSignal(self.INWARD_SIGNAL.TURN)

		self.canAddTorque = false
		self.curDeltaTime = self.addTorqueCD
	end
end

M.StartBraking = function(self)
	if self.canBrake then
		self.startBrake = true
		self.curBrakeDeltaTime = self.startBrakingCD
		self.startBrakingVelocity = self.turnTable:GetAngularVelocityLength()

		self:SendSignal(self.INWARD_SIGNAL.STOP)
	end
end

M.StartBrakingInternal = function(self)
	if self.startBrake then
		self.turnTable:StartBraking()

		self.startBrakingVelocity = self.turnTable:GetAngularVelocityLength()
	end
end

M.StopBraking = function(self)
	if self.startBrake then
		self.startBrake = false

		self.turnTable:EndBraking()

		local deltaSpeed = Mathf.Rad2Deg * math.abs(self.turnTable:GetAngularVelocityLength() - self.startBrakingVelocity)

		if self.maxBrakingDeltaSpeed >= deltaSpeed then
			self.SendSignal(self, self.INWARD_SIGNAL.RELEASE_BRAKING)
		else
			self.SendSignal(self, self.INWARD_SIGNAL.RELEASE_BRAKING_BY_HAND)
		end
	end
end

M.SendSignal = function(self, signal)
	LogicStateMachineManager.SendGameplayInwardSignal(MyPlayerManager.PlayerUnit, signal)
end
