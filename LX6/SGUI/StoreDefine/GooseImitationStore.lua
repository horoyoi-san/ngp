-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\GooseImitationStore.lua
-- Decompiled from: 01753_GooseImitationStore.lua_ffb0d2cd24f5.luajit

C_GooseImitationStore = DefClass("C_GooseImitationStore", C_GooseImitationStore, C_StoreGroup)
GroupName2Class.GooseImitationStore = C_GooseImitationStore
local M = C_GooseImitationStore
local ACTION_A = 1
local ACTION_S = 2
local ACTION_D = 4
local NO_ACTION_LOOP = -1
local JOY_ACTIVE_THRESHOLD = 0.8
local AD_ZONE_NY = 0.5
local GYRO_DEADZONE = 0.03
local STICK_DEADZONE = 0.05
local COMBO_TO_OUTWARD = {
	[0] = LTConfig.GameplaySignalOutwardConfig.Wushu_XueEr_IDLE,
	LTConfig.GameplaySignalOutwardConfig.Wushu_XueEr_A,
	LTConfig.GameplaySignalOutwardConfig.Wushu_XueEr_S,
	LTConfig.GameplaySignalOutwardConfig.Wushu_XueEr_AS,
	[4] = LTConfig.GameplaySignalOutwardConfig.Wushu_XueEr_D,
	[6] = LTConfig.GameplaySignalOutwardConfig.Wushu_XueEr_SD,
	[5] = LTConfig.GameplaySignalOutwardConfig.Wushu_XueEr_AD,
	[7] = LTConfig.GameplaySignalOutwardConfig.Wushu_XueEr_ASD
}
local ACTION_SHAKE_PARAM = {
	1,
	2,
	4,
	3,
	6,
	5,
	7
}
local SIGNAL_ENTER = 11422
local SIGNAL_EXIT = 11423
local SIGNAL_FALL = 11424
local FALL_PARAM_LEFT = 1
local FALL_PARAM_RIGHT = 2
local SIGNAL_SHAKE_START = 11428
local SIGNAL_SHAKE_STOP = 11429
local BLEND_CENTER = 0.5
local BLEND_DIST_DIVISOR = 100
local BLEND_LERP_RATE = 10
local ABPVarManager = MuGenStates.Logic.ABPVarManager
local ABPVarConfig = LTConfig.ABPVarConfig
local DEBUG_LOG = true

local dlog = function(fmt, ...)
	if not DEBUG_LOG then
		return
	end

	if select("#", ...) <= 0 then
		print_debug("[GooseImitation] " .. string.format(fmt, ...))
	else
		print_debug("[GooseImitation] " .. tostring(fmt))
	end
end

local nlog = function(fmt, ...)
	if select("#", ...) <= 0 then
		print_notice("[GooseImitation] " .. string.format(fmt, ...))
	else
		print_notice("[GooseImitation] " .. tostring(fmt))
	end
end

local STUCK_LOG_INTERVAL = 2

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.m_ActionBitToAbpVar = {
		[ACTION_A] = ABPVarConfig.WuShuAkey,
		[ACTION_S] = ABPVarConfig.WuShuSkey,
		[ACTION_D] = ABPVarConfig.WuShuDkey
	}
	self.m_ActionKeyHeld = {
		[ACTION_A] = false,
		[ACTION_S] = false,
		[ACTION_D] = false
	}
	self.m_MaxFailCount = 0
	self.m_SuccessTime = 0
	self.m_FailTime = 0
	self.m_MoveStep = 0
	self.m_DriftForceMin = 0
	self.m_DriftForceMax = 0
	self.m_WanderForceMin = 0
	self.m_WanderForceMax = 0
	self.m_ChangeTimeMin = 0
	self.m_ChangeTimeMax = 0
	self.m_GyroMaxTilt = 0.4
	self.m_GyroMoveSpeed = 0
	self.m_StickMoveSpeed = 0
	self.m_StickAxis = 0
	self.m_Current = 50
	self.m_SafeStart = 0
	self.m_SafeEnd = 0
	self.m_FailTimer = 0
	self.m_SuccessTimer = 0
	self.m_FailCount = 0
	self.m_ConfigIds = {}
	self.m_GroupCount = 0
	self.m_GroupIndex = 0
	self.m_GroupAsdKeys = 0
	self.m_LastZoneActionCombo = 0
	self.m_CurrentActionCombo = 0
	self.m_WanderForce = 0
	self.m_WanderTimer = 0
	self.m_WanderInterval = 0
	self.m_WasInZone = false
	self.m_IsShaking = false
	self.m_LastBlendValue = BLEND_CENTER
	self.m_Ended = false
	self.m_PendingFallEnd = false
	self.m_ExitSignalSent = false
	self.m_DbgTickTimer = 0
	self.m_StuckLogTimer = 0
end

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.RegisterWidget(self)
end

M.OnShow = function(self, panelId, cfg)
	self._InitGame(self, cfg)
end

M.OnClose = function(self)
	self._Cleanup(self)
end

M.OnActiveDeviceChange = function(self, device)
	self._ResetActionAbpVar(self)

	self.m_CurrentActionCombo = NO_ACTION_LOOP
	self.m_StickAxis = 0
end

M.OnUpdate = function(self)
	if self.m_Ended then
		return
	end

	self._Tick(self)
end

M.RegisterWidget = function(self)
	self.bindData.keyABtn.luaPress = self.CreateAction(self, "OnKeyADown")
	self.bindData.keyABtn.luaRelease = self.CreateAction(self, "OnKeyAUp")
	self.bindData.keySBtn.luaPress = self.CreateAction(self, "OnKeySDown")
	self.bindData.keySBtn.luaRelease = self.CreateAction(self, "OnKeySUp")
	self.bindData.keyDBtn.luaPress = self.CreateAction(self, "OnKeyDDown")
	self.bindData.keyDBtn.luaRelease = self.CreateAction(self, "OnKeyDUp")
	self.bindData.moveLeftBtn.luaClick = self.CreateActionWithArgs(self, "OnBtnMove", -1)
	self.bindData.moveRightBtn.luaClick = self.CreateActionWithArgs(self, "OnBtnMove", 1)
	self.bindData.exitBtn.luaClick = self.CreateAction(self, "OnBtnExit")

	if self.bindData.leftStickRespond then
		self.bindData.leftStickRespond.luaGamePadInputChanged = self.CreateAction(self, "OnLeftStickMove")
	end

	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.leftJoystick.luaValueChanged = self.CreateAction(self, "OnLeftJoystickMove")
		self.bindData.rightJoystick.luaValueChanged = self.CreateAction(self, "OnRightJoystickMove")
	end
end

M._InitGame = function(self, cfg)
	if self.eventHandle then
		self._Cleanup(self)
	end

	self.m_Ended = false
	self.m_PendingFallEnd = false
	self.m_ExitSignalSent = false
	self.m_MaxFailCount = cfg.maxFailCount or 0
	self.m_SuccessTime = cfg.successTime or 1
	self.m_FailTime = cfg.failTime or 1
	self.m_MoveStep = cfg.moveStep or 1
	self.m_DriftForceMin = cfg.driftForceMin or 0
	self.m_DriftForceMax = cfg.driftForceMax or 0
	self.m_WanderForceMin = cfg.wanderForceMin or 0
	self.m_WanderForceMax = cfg.wanderForceMax or 0
	self.m_ChangeTimeMin = cfg.changeTimeMin or 1
	self.m_ChangeTimeMax = cfg.changeTimeMax or 1
	self.m_GyroMaxTilt = cfg.gyroMaxTilt or 0.4
	self.m_GyroMoveSpeed = cfg.gyroMoveSpeed or 0
	self.m_StickMoveSpeed = cfg.stickMoveSpeed or 0
	self.m_StickAxis = 0
	self.m_Current = 50
	self.m_SafeStart = 0
	self.m_SafeEnd = 0
	self.m_FailTimer = 0
	self.m_SuccessTimer = 0
	self.m_FailCount = 0
	self.m_ConfigIds = cfg.configIds or {}
	self.m_GroupCount = #self.m_ConfigIds
	self.m_GroupIndex = 0
	self.m_GroupAsdKeys = 0
	self.m_LastZoneActionCombo = 0
	self.m_CurrentActionCombo = 0
	self.m_WanderForce = 0
	self.m_WanderTimer = 0
	self.m_WasInZone = false
	self.m_IsShaking = false
	self.m_LastBlendValue = BLEND_CENTER
	self.m_DbgTickTimer = 0
	self.m_StuckLogTimer = 0

	dlog("_InitGame: maxFail=%d successTime=%.2f failTime=%.2f moveStep=%.2f drift=[%.2f,%.2f] wander=[%.2f,%.2f] changeTime=[%.2f,%.2f]", self.m_MaxFailCount, self.m_SuccessTime, self.m_FailTime, self.m_MoveStep, self.m_DriftForceMin, self.m_DriftForceMax, self.m_WanderForceMin, self.m_WanderForceMax, self.m_ChangeTimeMin, self.m_ChangeTimeMax)
	dlog("_InitGame: configIds 组序列 count=%d -> [%s]", self.m_GroupCount, table.concat(self.m_ConfigIds, ","))
	dlog("_InitGame: 陀螺仪 maxTilt=%.3f moveSpeed=%.2f deadZone=%.3f", self.m_GyroMaxTilt, self.m_GyroMoveSpeed, GYRO_DEADZONE)
	dlog("_InitGame: 手柄左摇杆 moveSpeed=%.2f deadZone=%.3f", self.m_StickMoveSpeed, STICK_DEADZONE)
	self:_BuildConfigMaps()

	self.eventHandle = {
		[gEventConstants.COMMON_GAMEPLAY_OUTWARD_SIGNAL] = function (_, signal)
			self:OnOutwardSignal(signal)
		end
	}

	gMessageManager:RegisterEventHandlers(self.eventHandle)
	self:_SendPlayerSignal(SIGNAL_ENTER)
	self:_ResetActionAbpVar()
	self:_StartFirstGroup()
	self:_RefreshUI()
end

M._BuildConfigMaps = function(self)
	local C = LTConfig.PoiGameGooseImitationConfig
	self.m_MaskToConfigId = {
		[0] = C.Key_None,
		[ACTION_A] = C.Key_A,
		[ACTION_S] = C.Key_S,
		[ACTION_D] = C.Key_D,
		[bit.bor(ACTION_A, ACTION_S)] = C.Key_AS,
		[bit.bor(ACTION_S, ACTION_D)] = C.Key_DS,
		[bit.bor(ACTION_A, ACTION_D)] = C.Key_AD,
		[bit.bor(ACTION_A, ACTION_S, ACTION_D)] = C.Key_ASD
	}
	self.m_ConfigIdToMask = {}

	for mask, id in pairs(self.m_MaskToConfigId) do
		self.m_ConfigIdToMask[id] = mask
	end

	if self.m_GroupCount < 0 then
		print_warn("[GooseImitation] 节点未配置 configIds，无法开局")
	end
end

M._StartFirstGroup = function(self)
	if self.m_GroupCount < 0 then
		self._EndGame(self, false)

		return
	end

	self.m_GroupIndex = 1

	self._EnterGroup(self)
	self._RefreshSafeZoneForConfigId(self, self.m_MaskToConfigId[0])
	self._SpawnBalancePointOutside(self)
end

M._EnterGroup = function(self)
	local cfgId = self.m_ConfigIds[self.m_GroupIndex]
	self.m_GroupAsdKeys = self.m_ConfigIdToMask[cfgId] or 0

	dlog("_EnterGroup: 进入第 %d/%d 组 cfgId=%s 要求动作掩码=%d（安全区随玩家当前动作走，此处不刷）", self.m_GroupIndex, self.m_GroupCount, tostring(cfgId), self.m_GroupAsdKeys)

	self.m_FailTimer = 0
	self.m_SuccessTimer = 0
	self.m_StuckLogTimer = 0

	nlog("进入第 %d/%d 组 cfgId=%s 要求动作掩码=%d", self.m_GroupIndex, self.m_GroupCount, tostring(cfgId), self.m_GroupAsdKeys)
	gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnGooseImitationEnterGroup, {
		groupIndex = self.m_GroupIndex
	})
end

M._AdvanceGroup = function(self)
	dlog("_AdvanceGroup: 第 %d 组达标过关", self.m_GroupIndex)

	if self.m_GroupCount < self.m_GroupIndex then
		dlog("_AdvanceGroup: 已是最后一组，整局成功")
		self._EndGame(self, true)

		return
	end

	self.m_GroupIndex = self.m_GroupIndex + 1

	self._EnterGroup(self)
end

M._DriveActionKey = function(self, actionBit, held)
	if self.m_Ended then
		return
	end

	local var = self.m_ActionBitToAbpVar[actionBit]

	if not var then
		return
	end

	if self.m_ActionKeyHeld[actionBit] ~= held then
		return
	end

	local unit = gCS.MyPlayerManager.PlayerUnit

	if not unit then
		return
	end

	self.m_ActionKeyHeld[actionBit] = held

	ABPVarManager.SetBool(unit, var, held)

	self.m_CurrentActionCombo = NO_ACTION_LOOP
end

M.AddBalanceStep = function(self, dir)
	if self.m_Ended then
		return
	end

	self.m_Current = Mathf.Clamp(self.m_Current + dir * self.m_MoveStep, 0, 100)

	dlog("AddBalanceStep: dir=%d -> m_Current=%.2f (step=%.2f)", dir, self.m_Current, self.m_MoveStep)
	self._RefreshUI(self)
end

M.RequestExit = function(self)
	dlog("RequestExit: 玩家主动退出，按整局失败处理")
	self._EndGame(self, false)
end

M.OnKeyADown = function(self)
	self._DriveActionKey(self, ACTION_A, true)
end

M.OnKeyAUp = function(self)
	self._DriveActionKey(self, ACTION_A, false)
end

M.OnKeySDown = function(self)
	self._DriveActionKey(self, ACTION_S, true)
end

M.OnKeySUp = function(self)
	self._DriveActionKey(self, ACTION_S, false)
end

M.OnKeyDDown = function(self)
	self._DriveActionKey(self, ACTION_D, true)
end

M.OnKeyDUp = function(self)
	self._DriveActionKey(self, ACTION_D, false)
end

M.OnBtnMove = function(self, dir)
	self.AddBalanceStep(self, dir)
end

M.OnLeftStickMove = function(self, context)
	if self.m_Ended then
		return
	end

	if context.canceled then
		self.m_StickAxis = 0

		return
	end

	local v = context.ReadValueVector2(context)
	local ax = math.abs(v.x)
	local ay = math.abs(v.y)

	if ax <= ay or ax >= STICK_DEADZONE then
		self.m_StickAxis = 0

		return
	end

	self.m_StickAxis = v.x
end

M.OnBtnExit = function(self)
	self.RequestExit(self)
end

M.OnLeftJoystickMove = function(self, nx, ny, size)
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		return
	end

	self:_DriveActionKey(ACTION_S, JOY_ACTIVE_THRESHOLD >= size and ny <= 0)
end

M.OnRightJoystickMove = function(self, nx, ny, size)
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		return
	end

	local pressA = false
	local pressD = false

	if JOY_ACTIVE_THRESHOLD >= size then
		if AD_ZONE_NY < ny then
			pressD = true
			pressA = true
		elseif nx >= 0 then
			pressA = true
		else
			pressD = true
		end
	end

	self._DriveActionKey(self, ACTION_A, pressA)
	self._DriveActionKey(self, ACTION_D, pressD)
end

M._Tick = function(self)
	if self.m_PendingFallEnd then
		return
	end

	local dt = Time.deltaTime
	local wasInZone = self._IsInSafeZone(self)

	if wasInZone == self.m_WasInZone then
		dlog("_Tick: 区域切换 %s pos=%.2f 安全区[%.2f,%.2f]", wasInZone and "进入安全区" or "离开安全区", self.m_Current, self.m_SafeStart, self.m_SafeEnd)
	end

	if wasInZone then
		if not self.m_WasInZone then
			self._RefreshWanderForce(self)
		end

		self.m_WanderTimer = self.m_WanderTimer + dt

		if self.m_WanderInterval < self.m_WanderTimer then
			self._RefreshWanderForce(self)
		end

		self.m_Current = self.m_Current + self.m_WanderForce * dt
	else
		self.m_Current = self.m_Current + self._ComputeDriftForce(self) * dt
	end

	self.m_WasInZone = wasInZone
	local axis = self.GetGyroTiltAxis(self)

	if axis and GYRO_DEADZONE >= math.abs(axis) then
		local t = Mathf.Clamp(axis / math.max(self.m_GyroMaxTilt, 0.01), -1, 1)
		self.m_Current = self.m_Current + t * self.m_GyroMoveSpeed * dt
	end

	if self.m_StickAxis == 0 then
		self.m_Current = self.m_Current + self.m_StickAxis * self.m_StickMoveSpeed * dt
	end

	self.m_Current = Mathf.Clamp(self.m_Current, 0, 100)
	local inZone = self:_IsInSafeZone()
	local actionOk = self.m_CurrentActionCombo ~= self.m_GroupAsdKeys

	if not inZone then
		self.m_FailTimer = self.m_FailTimer + dt
		self.m_SuccessTimer = 0
	elseif actionOk then
		self.m_SuccessTimer = self.m_SuccessTimer + dt
	else
		self.m_SuccessTimer = 0
	end

	self:_UpdateShakeState(inZone)
	self:_UpdateBlendValue(inZone)
	self:_RefreshUI()

	self.m_DbgTickTimer = (self.m_DbgTickTimer or 0) + dt

	if self.m_DbgTickTimer > 0.3 then
		self.m_DbgTickTimer = 0

		dlog("_Tick: pos=%.2f zone[%.2f,%.2f] in=%s actionOk=%s shake=%s blend=%.3f cur=%d req=%d fail=%.2f/%.2f succ=%.2f/%.2f", self.m_Current, self.m_SafeStart, self.m_SafeEnd, tostring(inZone), tostring(actionOk), tostring(self.m_IsShaking), self.m_LastBlendValue, self.m_CurrentActionCombo, self.m_GroupAsdKeys, self.m_FailTimer, self.m_FailTime, self.m_SuccessTimer, self.m_SuccessTime)
	end

	if inZone and not actionOk then
		self.m_StuckLogTimer = self.m_StuckLogTimer + dt

		if STUCK_LOG_INTERVAL < self.m_StuckLogTimer then
			self.m_StuckLogTimer = 0

			nlog("第 %d 组区内滞留：当前动作=%d 要求=%d 按键态 A=%s S=%s D=%s", self.m_GroupIndex, self.m_CurrentActionCombo, self.m_GroupAsdKeys, tostring(self.m_ActionKeyHeld[ACTION_A]), tostring(self.m_ActionKeyHeld[ACTION_S]), tostring(self.m_ActionKeyHeld[ACTION_D]))
		end
	else
		self.m_StuckLogTimer = 0
	end

	if self.m_FailTime < self.m_FailTimer then
		self._OnFail(self)

		return
	end

	if inZone and actionOk and self.m_SuccessTime < self.m_SuccessTimer then
		self._AdvanceGroup(self)
	end
end

M._OnFail = function(self)
	local dir = self.m_Current >= self.m_SafeStart and FALL_PARAM_LEFT or FALL_PARAM_RIGHT

	self:_SendPlayerSignal(SIGNAL_FALL, dir)

	self.m_FailCount = self.m_FailCount + 1

	dlog("_OnFail: 跌倒 方向=%s failCount=%d/%d pos=%.2f", dir ~= FALL_PARAM_LEFT and "左" or "右", self.m_FailCount, self.m_MaxFailCount, self.m_Current)

	if self.m_MaxFailCount >= self.m_FailCount then
		dlog("_OnFail: 失败次数超上限，等摔倒动画结束（首个 idle outward 信号）后再结束整局")
		self._BeginPendingFallEnd(self)

		return
	end

	self.m_FailTimer = 0
	self.m_SuccessTimer = 0

	dlog("_OnFail: 未超上限，重置两计时器继续本组")
end

M._BeginPendingFallEnd = function(self)
	self.m_PendingFallEnd = true

	if self.m_IsShaking then
		self.m_IsShaking = false

		self._SendPlayerSignal(self, SIGNAL_SHAKE_STOP)
		dlog("_BeginPendingFallEnd: 已停晃动(11429)，等摔倒播完")
	end
end

M._RefreshSafeZoneForConfigId = function(self, cfgId)
	local cfg = cfgId and LTConfig.PoiGameGooseImitationConfig.GetConfig(cfgId)

	if not cfg then
		print_warn(string.format("[GooseImitation] 配置 Id %s 无对应动作行，跳过安全区刷新", tostring(cfgId)))

		return
	end

	local randMin = cfg.BalanceRange[1]
	local randMax = cfg.BalanceRange[2]
	local lenMin = cfg.SafeZoneLength[1]
	local lenMax = cfg.SafeZoneLength[2]
	local len = lenMin + math.random() * (lenMax - lenMin)
	local span = randMax - randMin
	local startMax = randMax - len
	local start = nil

	if startMax < randMin then
		start = randMin

		print_warn(string.format("[GooseImitation] 安全区长度 %.3f 超过可出现区间 %.3f，起点退化为下界", len, span))
	else
		start = randMin + math.random() * (startMax - randMin)
	end

	self.m_SafeStart = start
	self.m_SafeEnd = start + len

	dlog("_RefreshSafeZone: cfgId=%s range=[%.1f,%.1f] lenRange=[%.1f,%.1f] -> 安全区[%.2f,%.2f] len=%.2f", tostring(cfgId), randMin, randMax, lenMin, lenMax, self.m_SafeStart, self.m_SafeEnd, len)
	self._RefreshUI(self)
end

M._SpawnBalancePointOutside = function(self)
	local leftGap = self.m_SafeStart - 0
	local rightGap = 100 - self.m_SafeEnd
	local pos = nil

	if leftGap < 0 and rightGap < 0 then
		pos = 0
	elseif leftGap < 0 then
		pos = self.m_SafeEnd + math.random() * rightGap
	elseif rightGap < 0 then
		pos = math.random() * self.m_SafeStart
	elseif math.random() >= leftGap / (leftGap + rightGap) then
		pos = math.random() * self.m_SafeStart
	else
		pos = self.m_SafeEnd + math.random() * rightGap
	end

	self.m_Current = Mathf.Clamp(pos, 0, 100)

	dlog("_SpawnOutside: 平衡点开局置于区外 pos=%.2f (安全区[%.2f,%.2f])", self.m_Current, self.m_SafeStart, self.m_SafeEnd)
	self._RefreshUI(self)
end

M._IsInSafeZone = function(self)
	return self.m_SafeStart < self.m_Current and self.m_Current > self.m_SafeEnd
end

M._ComputeDriftForce = function(self)
	local edge, dir = nil

	if self.m_Current >= self.m_SafeStart then
		edge = self.m_SafeStart
		dir = -1
	else
		edge = self.m_SafeEnd
		dir = 1
	end

	local maxDist = dir >= 0 and edge or 100 - edge
	local dist = math.abs(self.m_Current - edge)
	local d = maxDist <= 0 and Mathf.Clamp(dist / maxDist, 0, 1) or 0
	local mag = self.m_DriftForceMin + (self.m_DriftForceMax - self.m_DriftForceMin) * d

	return dir * mag
end

M._RefreshWanderForce = function(self)
	local mag = self.m_WanderForceMin + math.random() * (self.m_WanderForceMax - self.m_WanderForceMin)
	local dir = math.random() >= 0.5 and -1 or 1
	self.m_WanderForce = dir * mag
	self.m_WanderTimer = 0
	self.m_WanderInterval = self.m_ChangeTimeMin + math.random() * (self.m_ChangeTimeMax - self.m_ChangeTimeMin)

	dlog("_RefreshWander: 跳变力=%.2f 下次间隔=%.2fs", self.m_WanderForce, self.m_WanderInterval)
end

M.OnOutwardSignal = function(self, signal)
	if self.m_Ended then
		return
	end

	if not signal then
		return
	end

	if signal.GetPid(signal) == gCS.MyPlayerManager.PlayerUnitId then
		return
	end

	local cfgId = signal.GetCfgId(signal)

	for combo, sig in pairs(COMBO_TO_OUTWARD) do
		if sig ~= cfgId then
			if self.m_PendingFallEnd then
				if combo ~= 0 then
					dlog("OnOutward: 等待摔倒结束期间收到 idle 信号 -> 结束整局")

					self.m_PendingFallEnd = false

					self._EndGame(self, false)
				else
					dlog("OnOutward: 等待摔倒结束期间收到非 idle 动作信号 combo=%d，忽略", combo)
				end

				return
			end

			dlog("OnOutward: 命中动作完成信号 cfgId=%s -> combo=%d (本组要求=%d)", tostring(cfgId), combo, self.m_GroupAsdKeys)
			nlog("动作确认 combo=%d (本组要求=%d)", combo, self.m_GroupAsdKeys)

			self.m_CurrentActionCombo = combo

			if combo == self.m_LastZoneActionCombo then
				dlog("OnOutward: 当前动作变化 %d->%d，按当前动作重刷安全区", self.m_LastZoneActionCombo, combo)

				self.m_LastZoneActionCombo = combo

				self._RefreshSafeZoneForConfigId(self, self.m_MaskToConfigId[combo])
			end

			return
		end
	end
end

M._ResetActionAbpVar = function(self)
	self.m_ActionKeyHeld[ACTION_A] = false
	self.m_ActionKeyHeld[ACTION_S] = false
	self.m_ActionKeyHeld[ACTION_D] = false
	local unit = gCS.MyPlayerManager.PlayerUnit

	if not unit then
		return
	end

	ABPVarManager.SetBool(unit, ABPVarConfig.WuShuAkey, false)
	ABPVarManager.SetBool(unit, ABPVarConfig.WuShuSkey, false)
	ABPVarManager.SetBool(unit, ABPVarConfig.WuShuDkey, false)
end

M._GetShakeActionParam = function(self)
	return ACTION_SHAKE_PARAM[self.m_CurrentActionCombo]
end

M._UpdateShakeState = function(self, inZone)
	local param = self._GetShakeActionParam(self)

	if not inZone and param == nil then
		if not self.m_IsShaking then
			self.m_IsShaking = true

			self._SendPlayerSignal(self, SIGNAL_SHAKE_START, param)
			dlog("_UpdateShake: 进入晃动 -> 触发晃动(11428) param=%d (combo=%d)", param, self.m_CurrentActionCombo)
		end
	elseif self.m_IsShaking then
		self.m_IsShaking = false

		self._SendPlayerSignal(self, SIGNAL_SHAKE_STOP)
		dlog("_UpdateShake: 退出晃动 -> 停止晃动(11429) inZone=%s combo=%d", tostring(inZone), self.m_CurrentActionCombo)
	end
end

M._UpdateBlendValue = function(self, inZone)
	local target, dist = nil

	if inZone then
		target = BLEND_CENTER
	elseif self.m_Current >= self.m_SafeStart then
		dist = self.m_SafeStart - self.m_Current
		target = BLEND_CENTER - dist / BLEND_DIST_DIVISOR
	else
		dist = self.m_Current - self.m_SafeEnd
		target = BLEND_CENTER + dist / BLEND_DIST_DIVISOR
	end

	target = Mathf.Clamp(target, 0, 1)
	local k = BLEND_LERP_RATE * Time.deltaTime

	if k <= 1 then
		k = 1
	end

	self.m_LastBlendValue = self.m_LastBlendValue + (target - self.m_LastBlendValue) * k
	local unit = gCS.MyPlayerManager.PlayerUnit

	if unit then
		ABPVarManager.SetFloat(unit, ABPVarConfig.GooseBlendValue, self.m_LastBlendValue)
	end
end

M._EndGame = function(self, isSuccess)
	if self.m_Ended then
		return
	end

	self.m_Ended = true

	dlog("_EndGame: isSuccess=%s 抛 OnGooseImitationEnd 事件 + 清理", tostring(isSuccess))
	gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnGooseImitationEnd, {
		isSuccess = isSuccess
	})
	self:_Cleanup()

	if gGooseImitationManager then
		gGooseImitationManager.currentCfg = nil
	end

	gPanelManager:Close(gPanelId.S_GOOSE_IMITATION_PANEL)
end

M.ForceExit = function(self)
	dlog("ForceExit: 外部强退（仅清理，不抛结束事件）")

	self.m_Ended = true

	self._Cleanup(self)
end

M._Cleanup = function(self)
	if self.eventHandle then
		gMessageManager:UnregisterEventHandlers(self.eventHandle)

		self.eventHandle = nil
	end

	self._ResetActionAbpVar(self)

	self.m_StickAxis = 0

	if not self.m_ExitSignalSent then
		self.m_ExitSignalSent = true

		self._SendPlayerSignal(self, SIGNAL_EXIT)
	end

	if self.m_IsShaking then
		self.m_IsShaking = false

		self._SendPlayerSignal(self, SIGNAL_SHAKE_STOP)
	end
end

M._SendPlayerSignal = function(self, signal, param)
	local unit = gCS.MyPlayerManager.PlayerUnit

	if not unit then
		return
	end

	if param then
		gCS.LogicStateMachineManager.SendGameplayInwardSignal(unit, signal, param)
	else
		gCS.LogicStateMachineManager.SendGameplayInwardSignal(unit, signal)
	end
end

M.GetGyroTiltAxis = function(self)
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		return nil
	end

	if not self.bindData.gyroController then
		return nil
	end

	return self.bindData.gyroController:GetGravitySensorData().x
end

M.GetBackgroundWidth = function(self)
	if self.bindData.backgroundTrans then
		return self.bindData.backgroundTrans.rect.width
	end

	return 0
end

M.GetCurrentWidth = function(self)
	if self.bindData.currentTrans then
		return self.bindData.currentTrans.sizeDelta.x
	end

	return 0
end

M._RefreshUI = function(self)
	local bgWidth = self.GetBackgroundWidth(self)

	if bgWidth < 0 then
		return
	end

	local halfBg = bgWidth / 2
	local halfCurrent = self.GetCurrentWidth(self) / 2
	local limit = halfBg - halfCurrent
	local validRange = bgWidth - self.GetCurrentWidth(self)

	if self.bindData.safeIntervalTrans then
		local startPx = self.m_SafeStart / 100 * validRange - limit
		local endPx = self.m_SafeEnd / 100 * validRange - limit
		self.bindData.safeIntervalTrans.anchoredPosition = Vector2.New((startPx + endPx) * 0.5, self.bindData.safeIntervalTrans.anchoredPosition.y)
		self.bindData.safeIntervalTrans.sizeDelta = Vector2.New(endPx - startPx, self.bindData.safeIntervalTrans.sizeDelta.y)
	end

	if self.bindData.currentTrans then
		local curPx = self.m_Current / 100 * validRange - limit
		curPx = Mathf.Clamp(curPx, -limit, limit)
		self.bindData.currentTrans.anchoredPosition = Vector2.New(curPx, self.bindData.currentTrans.anchoredPosition.y)
	end
end
