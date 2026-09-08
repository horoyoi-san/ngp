-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\RopeSwingPanelStore.lua
-- Decompiled from: 00861_RopeSwingPanelStore.lua_bce48a4396e2.luajit

C_RopeSwingPanelStore = DefClass("C_RopeSwingPanelStore", C_RopeSwingPanelStore, C_StoreGroup)
GroupName2Class.RopeSwingPanelStore = C_RopeSwingPanelStore
local M = C_RopeSwingPanelStore
local MyPlayerManager = gCS.MyPlayerManager
local ABPVarManager = MuGenStates.Logic.ABPVarManager
local LogicStateMachineManager = gCS.LogicStateMachineManager
local GuiMgr = LX6.GUI.GuiMgr

M.ctor = function(self)
	self.INWARD_SIGNAL = {
		["\\xadY\\xaed\\xe6\\x8f\\x80"] = 12516,
		[">m\\xb9\\xa7\\xade"] = 12513,
		["\\x81\\x84(\\x9bU\\xcb"] = 12514,
		["\\xff\\xf4&*?\\xd5"] = 12512,
		["h\\x80\\x96\\x8a\\x84"] = 12511
	}
	self.ABPVar = {
		["\\xa1.\\xea\\xb9` \\xc7P\\xea\\xfb7XR\\xf95\\xbd\\xdf"] = 117
	}
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
	self.showCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.showCtrlEnum = nil
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
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	self.isShow = true

	self.InitRopeSwing(self, data)
end

M.OnClose = function(self)
	self.isShow = false

	self.Release(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.forwardBtn.luaPress = self.CreateAction(self, self.OnPressForwardBtn)
	self.bindData.forwardBtn.luaRelease = self.CreateAction(self, self.OnReleaseForwardBtn)
	self.bindData.behindBtn.luaPress = self.CreateAction(self, self.OnPressBehindBtn)
	self.bindData.behindBtn.luaRelease = self.CreateAction(self, self.OnReleaseBehindBtn)
	self.bindData.jumpBtn.luaClick = self.CreateAction(self, self.OnClickJumpBtn)
end

M.OnPressForwardBtn = function(self)
	if not self.enableInput then
		return
	end

	self.forwardPress = true

	self.ChangeInputDirection(self)
end

M.OnReleaseForwardBtn = function(self)
	if not self.enableInput then
		return
	end

	self.forwardPress = false

	self.ChangeInputDirection(self)
end

M.OnPressBehindBtn = function(self)
	if not self.enableInput then
		return
	end

	self.behindPress = true

	self.ChangeInputDirection(self)
end

M.OnReleaseBehindBtn = function(self)
	if not self.enableInput then
		return
	end

	self.behindPress = false

	self.ChangeInputDirection(self)
end

M.OnClickJumpBtn = function(self)
	local hasTarget = self:IsRopeSwingValid() and self.ropeSwing:TryJumpToBestTarget()

	self:SendSignal(self.INWARD_SIGNAL.JUMP_OUT, hasTarget and 1 or 2)

	if self:IsRopeSwingValid() then
		self.ropeSwing:EndInteractSmooth()
	end

	self.StartJumpOutFallbackTimer(self)
end

M.StartJumpOutFallbackTimer = function(self)
	self.StopJumpOutFallbackTimer(self)

	local delay = L18.Gameplay.RopeSwing.RopeSwingController.GetJumpOutFallbackCloseTime()

	if not delay or delay < 0 then
		return
	end

	self.jumpOutFallbackTimer = Timer.New(function ()
		self.jumpOutFallbackTimer = nil

		if self.isShow then
			print_warn("[RopeSwing] 跳出保底定时器触发，节点未关界面，保底关闭")
			self:StopGameplay()
		end
	end, delay):Start()
end

M.StopJumpOutFallbackTimer = function(self)
	if self.jumpOutFallbackTimer then
		self.jumpOutFallbackTimer:Stop()

		self.jumpOutFallbackTimer = nil
	end
end

M.StopGameplay = function(self)
	local gameplayControlStore = gStoreManager:GetStoreGroup("CoreHudGameplayControlStore")

	if gameplayControlStore then
		gameplayControlStore.StopGameplayByType(gameplayControlStore, gHUDGameplayType.ROPE_SWING)
	end
end

M.InitRopeSwing = function(self, args)
	self.gameObject = args.gameObject
	self.ropeSwing = self.gameObject:GetComponent(typeof(L18.Gameplay.RopeSwing.RopeSwingController))
	self.forwardPress = false
	self.behindPress = false
	self.lastInputParams = 0
	self.enableInput = true

	self:StopJumpOutFallbackTimer()

	if self.ropeSwing then
		self.ropeSwing:StartInteract()
	else
		print_error("初始化绳索摆荡玩法界面失败！需要给摆荡节点 GameObject 上挂 RopeSwingController 组件！")
	end

	self:SendSignal(self.INWARD_SIGNAL.ENTER)
	ABPVarManager.SetInt(MyPlayerManager.PlayerUnit, self.ABPVar.CageShakeButtonState, 0)
	self:SetPlayerJoystickBanned(true)
	self.bindData.jumpBtn.gameObject:SetActive(not self.ropeSwing or not self.ropeSwing:IsJumpButtonDisabled())

	self.bindData.showCtrl = 1
end

M.SetPlayerJoystickBanned = function(self, banned)
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		return
	end

	if banned then
		GuiMgr.Instance:AddHUDJoystickControl(false, gBanId.ROPE_SWING)
	else
		GuiMgr.Instance:RemoveHUDJoystickControl(gBanId.ROPE_SWING)
	end

	GuiMgr.Instance:SetDisableJoystick(banned, gBanId.ROPE_SWING)
end

M.Release = function(self)
	self.gameObject = nil
	self.ropeSwing = nil
	self.enableInput = false

	self.StopJumpOutFallbackTimer(self)
	self.SetPlayerJoystickBanned(self, false)

	if MyPlayerManager.PlayerUnit then
		ABPVarManager.SetInt(MyPlayerManager.PlayerUnit, self.ABPVar.CageShakeButtonState, 0)
	end
end

M.IsRopeSwingValid = function(self)
	return self.ropeSwing and not gCS.LuaUtils.IsNull(self.ropeSwing)
end

M.ChangeInputDirection = function(self)
	local direction = 0
	local params = 0

	if self.forwardPress then
		direction = direction + 1
		params = 1
	end

	if self.behindPress then
		direction = direction - 1
		params = 2
	end

	if self.IsRopeSwingValid(self) then
		self.ropeSwing:SetForceDirection(direction)
	end

	ABPVarManager.SetInt(MyPlayerManager.PlayerUnit, self.ABPVar.CageShakeButtonState, direction)

	if params == self.lastInputParams then
		if params ~= 1 then
			self.SendSignal(self, self.INWARD_SIGNAL.FORWARD)
		elseif params ~= 2 then
			self.SendSignal(self, self.INWARD_SIGNAL.BEHIND)
		else
			print_debug("[RopeSwing] SendSignal:", self.INWARD_SIGNAL.RELEASE_KEY, "param:", self.lastInputParams)
			LogicStateMachineManager.SendGameplayInwardSignal(MyPlayerManager.PlayerUnit, self.INWARD_SIGNAL.RELEASE_KEY, self.lastInputParams)
		end
	end

	self.lastInputParams = params
end

M.DisableForce = function(self, disable)
	if self.IsRopeSwingValid(self) then
		self.ropeSwing:DisableForce(disable)
	end
end

M.AddImpulseVelocity = function(self, forward)
	if not self.IsRopeSwingValid(self) then
		return
	end

	if forward then
		self.ropeSwing:AddForwardImpulseVelocity()
	else
		self.ropeSwing:AddBackwardImpulseVelocity()
	end
end

M.AddJumpInImpulseVelocity = function(self)
	if not self.IsRopeSwingValid(self) then
		return
	end

	self.ropeSwing:AddJumpInImpulseVelocity()
end

M.SendSignal = function(self, signal, param)
	print_debug("[RopeSwing] SendSignal:", signal, "param:", param)

	if param == nil then
		LogicStateMachineManager.SendGameplayInwardSignal(MyPlayerManager.PlayerUnit, signal, param)
	else
		LogicStateMachineManager.SendGameplayInwardSignal(MyPlayerManager.PlayerUnit, signal)
	end
end
