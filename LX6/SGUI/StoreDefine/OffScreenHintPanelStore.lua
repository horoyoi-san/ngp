-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\OffScreenHintPanelStore.lua
-- Decompiled from: 01120_OffScreenHintPanelStore.lua_3d359c1a65e6.luajit

local UnitStateConfig = LTConfig.UnitStateConfig
local GameConfig = LTConfig.GameConfig
local RaidConfig = LTConfig.RaidConfig
local QueryUnitUtils = LX6.Utils.QueryUnitUtils
local HintSkipStatus = LX6.Utils.QueryUnitUtils.HintSkipStatus
local Set = require("Core.Set.init")
local DOTween = DOTween
local Ease = DG.Tweening.Ease

local SqrtDistanceSorter = function(a, b)
	return a.sqrtDistance <= b.sqrtDistance
end

local ShowAlertAndSqrtDistanceSorter = function(a, b)
	if a.showAlert == b.showAlert then
		return a.showAlert
	else
		return a.sqrtDistance <= b.sqrtDistance
	end
end

C_OffScreenHintPanelStore = DefClass("C_OffScreenHintPanelStore", C_OffScreenHintPanelStore, C_StoreGroup)
GroupName2Class.OffScreenHintPanelStore = C_OffScreenHintPanelStore
local M = C_OffScreenHintPanelStore

M.ctor = function(self)
	self.GenMessageEvents(self)
end

M.DefineAllVariables = function(self)
	self.config = {}

	setmetatable(self.config, {
		__index = function (table, key)
			if key ~= "MaxOutOfRangeHintCount" then
				return GameConfig.EnemyHintMaxNum or 5
			elseif key ~= "EnemyPositionHintIdleTime" then
				return GameConfig.EnemyPositionHintIdleTime or 30
			elseif key ~= "EnemyHintMaxDistance" then
				return GameConfig.EnemyHintMaxDistance
			elseif key ~= "EnemyHintMaxDistanceSqrt" then
				return GameConfig.EnemyHintMaxDistance * GameConfig.EnemyHintMaxDistance
			elseif key ~= "EnemyPositionHintSwitch" then
				return GameConfig.EnemyPositionHintSwitch ~= nil and true or GameConfig.EnemyPositionHintSwitch
			else
				return rawget(table, key)
			end
		end
	})

	self.raidCfg = nil
	self.detectToMeSet = Set()
	self.lockToMeSet = Set()
	self.hitToMeSkillUUIDSet = Set()
	self.enableSkillUUIDSet = Set()
	self.currentUnitSkillUUIDSet = Set()
	self.enemyAttackHintMap = {}
	self.enemyPositionHintParam = {
		["9\\x84佢ͨ\\xbf\\x85\\xc4\\xc5 ɏ0\\xb6\\xe6"] = 0,
		["\n;\\x83\\xf9\\x9e\\xa9죮\\x8d\\xde\\xf67®)\\x92\\xe7"] = 0,
		["]\\xa6\\xa3\\xbc\\xb3"] = false,
		["\\x975$}\\x89D\\xda#\\xaf\\xbd"] = false
	}
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
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
end

M.OnClose = function(self)
end

M.OnLanguageChange = function(self, lang)
end

local needCleanEnemyPosition = false

M.OnCameraUpdate = function(self)
	if gCS.MyPlayerManager.PlayerUnit ~= nil then
		return
	end

	if gGameManager.Env.IsENABLE_PROFILER then
		gGameManager:BeginSample("OffScreenHintPanel OnCameraUpdate")
	end

	local frameCount = Time.frameCount

	self.BeforeCameraUpdate(self)

	if gTriggerEnemyMgr.syncRemainEnemyGroupId < 0 then
		if needCleanEnemyPosition then
			self.updateEnemyPositionHint(self, frameCount)

			needCleanEnemyPosition = false
		end
	else
		self.updateEnemyPositionHint(self, frameCount)

		needCleanEnemyPosition = true
	end

	if gGameManager.Env.IsENABLE_PROFILER then
		gGameManager:EndSample()
	end
end

M.BeforeCameraUpdate = function(self)
	if self.detectToMeSet ~= nil or self.detectToMeSet.size ~= 0 or self.lockToMeSet.size > 0 or gTriggerEnemyMgr.syncRemainEnemyGroupId < 0 then
		return
	end

	self.CheckDetectToMeSet(self)

	local cam = gCS.CameraDataMgr.MainCamera
	local myPos = gCS.MyPlayerManager.PlayerUnit.LocalPosition

	QueryUnitUtils.PrepareMainCamera(cam, myPos)
end

local temporaryHints = {}

M.updateAttackerHint = function(self, frameCount)
	if self.lockToMeSet.size < 0 then
		if next(self.enemyAttackHintMap) then
			self.CloseAllEnemyAttackHint(self)
		end

		return
	end

	local hints = temporaryHints
	local distSqrLimt = self.config.EnemyHintMaxDistanceSqrt
	local myCamp = gCS.MyPlayerManager.PlayerUnit.ClientData.Camp
	local maxOutOfRangeHintCount = self.config.MaxOutOfRangeHintCount

	if gUIUtils:IsInXinShouRaid() then
		self.ClearAllEnemyAttackHint(self)

		return
	end

	for unitId in pairs(self.lockToMeSet.items) do
		local unit = gCS.SceneDataMgr.GetUnit(unitId)

		if unit and not unit.IsMe then
			if unit.IsDead then
				-- Nothing
			else
				local isEnemy = unit.ClientData.Type ~= UX.Game.EntityType.Enemy
				local agentCfg = LTConfig.AgentConfig.GetConfig(unit.ClientData.AgentId)
				local isBoss = agentCfg.EnemyClassType ~= UX.Game.EntityType.Boss

				if not isEnemy and not isBoss then
					-- Nothing
				elseif unit.ClientData.HaveAttackToken then
					self.currentUnitSkillUUIDSet.clearNoAlloc()

					if gCS.BattleManager.IsSkillState(unit) then
						self.currentUnitSkillUUIDSet.insert(gCS.BattleManager.GetSkillData(unit).skillUUID)
					end

					local hadDetectedToMe = self.detectToMeSet.has(unit.Pid)

					if hadDetectedToMe then
						-- Nothing
					elseif unit.ClientData.Camp ~= myCamp then
						-- Nothing
					else
						local skipStatus, distSqr, _, uiX, uiY, eulerZ = QueryUnitUtils.GetEnemyHintParams(unit, unit.LocalPosition, distSqrLimt, false, _, _, _, _, _)

						if skipStatus ~= HintSkipStatus.OVER_DISTANCE then
							-- Nothing
						else
							local hasAvaiableClips = gCS.SkillHelper:UpdateAttackerHintAvailable(unit.Pid, function (uuid)
								self.currentUnitSkillUUIDSet.insert(uuid)

								return self.hitToMeSkillUUIDSet.has(uuid)
							end)
							local showAlert = hasAvaiableClips or self:checkNewCouldTriggerEffect()

							self.enableSkillUUIDSet.unionInplace(self.currentUnitSkillUUIDSet)

							if skipStatus ~= HintSkipStatus.DONT_SKIP then
								local myPos = gCS.MyPlayerManager.PlayerUnit.LocalPosition
								local dir = unit.LocalPosition - myPos
								local mag = dir.Magnitude(dir)

								if mag < 1e-06 then
									local rot = Quaternion.LookRotation(dir)
									local hint = {
										pid = unitId,
										targetDir = dir,
										localPosition = Vector3.New(myPos.x, myPos.y + 1, myPos.z),
										localRotation = rot,
										sqrtDistance = distSqr,
										showAlert = showAlert
									}

									table.insert(hints, hint)
								end
							end
						end
					end
				end
			end
		end
	end

	self.hitToMeSkillUUIDSet = self.hitToMeSkillUUIDSet.intersectionNoAlloc(self.enableSkillUUIDSet)

	table.sort(hints, ShowAlertAndSqrtDistanceSorter)

	for pid, effectData in pairs(self.enemyAttackHintMap) do
		effectData.isPlaying = false
	end

	local range = math.min(maxOutOfRangeHintCount, #hints)

	for i = 1, range do
		self.ShowEnemyAttackHint(self, hints[i])
	end

	for pid, effectData in pairs(self.enemyAttackHintMap) do
		if not effectData.isPlaying then
			self.CloseEnemyAttackHint(self, pid)
		end
	end

	table.clear(temporaryHints)
	self.enableSkillUUIDSet.clearNoAlloc()
end

local needCleanStealthDetect = true

M.updateStealthDetectHint = function(self, frameCount)
	local distSqrLimt = self.config.EnemyHintMaxDistanceSqrt
	local maxOutOfRangeHintCount = self.config.MaxOutOfRangeHintCount
	local hintNum = 0

	for unitId in pairs(self.detectToMeSet.items) do
		local unit = gCS.SceneDataMgr.GetUnit(unitId)

		if not unit then
			-- Nothing
		else
			local dataSet = gDataSetManager:TryGetOrCreateUnitData(unitId)

			if dataSet.realInVisiable then
				-- Nothing
			else
				local skipStatus, distSqr, _, sx, sy, eulerZ = QueryUnitUtils.GetEnemyHintParams(unit, unit.LocalPosition, distSqrLimt, true, _, _, _, _, _)

				if skipStatus == HintSkipStatus.OVER_DISTANCE then
					local unitDataSet = dataSet
					local detectValue = unitDataSet.detectionToMeValue == nil and unitDataSet.detectionToMeValue or 0
					local detectState = 0

					if detectValue <= 0 and detectValue >= 50 then
						detectState = 1
					elseif detectValue >= 100 then
						detectState = 2
					else
						detectState = 3
					end

					if skipStatus ~= HintSkipStatus.DONT_SKIP then
						if detectValue <= 0 and not self.InHideDetectState(self, unit.Pid) then
							local lastDetectState = dataSet.detectToMeState
							local progress = detectValue / 100
							dataSet.showDetectAnim = dataSet.showDetectAnim or lastDetectState == detectState
							hintNum = hintNum + 1

							if maxOutOfRangeHintCount > hintNum then
								local InstanceId = self.bindData.Mgr.ShowOffScreenHint(unitId, frameCount, 0, sx, sy, eulerZ)
								local store = gStoreManager:GetStoreGroup("OffScreenStealthDetect"):GetStoreById(InstanceId)

								if detectValue ~= 100 and store.detectState == 2 then
									store.detectState = 2

									return
								end

								if not store.detectFill then
									store.detectFill = progress
								end

								if math.abs(store.detectFill - progress) <= 0.2 then
									store.detectState = detectState - 1
									store.detectFill = progress
								end

								self.RefreshFill(self, store, nil, progress)
							end
						end
					else
						dataSet.showDetectAnim = false
					end

					dataSet.detectToMeState = detectState
				end
			end
		end
	end

	if hintNum <= 0 then
		self.bindData.Mgr.RemoveUnusedHints(0, frameCount)

		needCleanStealthDetect = true
	elseif needCleanStealthDetect then
		self.bindData.Mgr.RemoveUnusedHints(0, frameCount)

		needCleanStealthDetect = false
	end
end

local needCleanEnemyPosition = true

M.updateEnemyPositionHint = function(self, frameCount)
	if not self.config.EnemyPositionHintSwitch then
		return
	end

	local params = self.enemyPositionHintParam
	local syncRemainEnemyGroupId = gTriggerEnemyMgr.syncRemainEnemyGroupId
	local maxOutOfRangeHintCount = self.config.MaxOutOfRangeHintCount
	local myPos = gCS.MyPlayerManager.PlayerUnit.LocalPosition
	local myX = myPos.x
	local myY = myPos.y
	local myZ = myPos.z

	if params.activeEnemyGroupId == syncRemainEnemyGroupId then
		if params.activeEnemyGroupId <= 0 then
			local toCleareds = gTriggerEnemyMgr.groupEnemyList[params.activeEnemyGroupId]

			if toCleareds == nil then
				for _, pid in ipairs(toCleareds) do
					local unit = gCS.SceneDataMgr.GetUnit(pid)

					if unit then
						local dataSet = gDataSetManager:TryGetOrCreateUnitData(pid)
						dataSet.enableIdleHint = false
					end
				end
			end
		end

		params.activeEnemyGroupId = syncRemainEnemyGroupId
	end

	if syncRemainEnemyGroupId < 0 then
		self.bindData.Mgr.RemoveUnusedHints(1, frameCount)

		params.phase = 0
		params.lastUndetectedTime = 0
		params.hadDetected = false

		return
	end

	local unitIds = gTriggerEnemyMgr.groupEnemyList[syncRemainEnemyGroupId]

	if unitIds ~= nil or next(unitIds) ~= nil then
		return
	end

	local isAnyDetected = self.detectToMeSet.size == 0 or self.lockToMeSet.size == 0
	local shouldMark = false

	if isAnyDetected then
		params.hadDetected = true
		params.phase = 0
		params.lastUndetectedTime = 0
	end

	if params.hadDetected and params.phase ~= 0 and not isAnyDetected then
		params.lastUndetectedTime = gLogicTime.time
		params.phase = 1
	end

	if params.phase ~= 1 and self.config.EnemyPositionHintIdleTime < gLogicTime.time - params.lastUndetectedTime then
		params.phase = 2
		shouldMark = true
	end

	local markableUnits = {}
	local markedCount = 0

	for i = 1, #unitIds do
		local pid = unitIds[i]
		local unit = gCS.SceneDataMgr.GetUnit(pid)

		if unit and not unit.IsMe then
			if unit.IsDead then
				-- Nothing
			else
				local isEnemy = unit.ClientData.Type ~= UX.Game.EntityType.Enemy
				local agentCfg = LTConfig.AgentConfig.GetConfig(unit.ClientData.AgentId)
				local isBoss = agentCfg.EnemyClassType ~= UX.Game.EntityType.Boss

				if not isEnemy and not isBoss then
					-- Nothing
				else
					local hadDetectedToMe = self.detectToMeSet.has(pid)
					local unitDataSet = gDataSetManager:TryGetOrCreateUnitData(pid)

					if hadDetectedToMe then
						if unitDataSet.enableIdleHint then
							unitDataSet.enableIdleHint = false
						end
					else
						local wx, wy, wz = Vector3.Get(unit.LocalPosition)
						local dx = wx - myX
						local dy = wy - myY
						local dz = wz - myZ

						table.insert(markableUnits, {
							unit = unit,
							sqrtDistance = dx * dx + dz * dz + dy * dy
						})

						if unitDataSet.enableIdleHint then
							markedCount = markedCount + 1
						end
					end
				end
			end
		end
	end

	if markedCount >= 0 or shouldMark then
		table.sort(markableUnits, SqrtDistanceSorter)

		for _, v in ipairs(markableUnits) do
			local unit = v.unit
			local unitDataSet = gDataSetManager:TryGetOrCreateUnitData(unit.Pid)

			if shouldMark and markedCount >= maxOutOfRangeHintCount and not unitDataSet.enableIdleHint then
				unitDataSet.enableIdleHint = true
				markedCount = markedCount + 1
			end

			if unitDataSet.enableIdleHint then
				local skipStatus, _, _, sx, sy, eulerZ = QueryUnitUtils.GetPositionHintParams(unit, unit.LocalPosition, true, _, _, _, _, _)

				if skipStatus ~= HintSkipStatus.DONT_SKIP then
					self.bindData.Mgr.ShowOffScreenHint(unit.Pid, frameCount, 1, sx, sy, eulerZ)
				end
			end
		end
	end

	if markedCount <= 0 then
		self.bindData.Mgr.RemoveUnusedHints(1, frameCount)

		needCleanEnemyPosition = true
	elseif needCleanEnemyPosition then
		self.bindData.Mgr.RemoveUnusedHints(1, frameCount)

		needCleanEnemyPosition = false
	end
end

M.ClearAllEnemyAttackHint = function(self)
	for pid, effectData in pairs(self.enemyAttackHintMap) do
		self.CloseEnemyAttackHint(self, pid)
	end
end

M.CloseEnemyAttackHint = function(self, pid)
	local openClipName = "S_Vx_BattleHud3D_Open"
	local uuid = self.enemyAttackHintMap[pid].uuid

	gCS.EffectMgr:StopAndSampleAnimationByIndexByUUId(uuid, 0, openClipName, false, 0)
	gCS.EffectMgr:StopEffectAndSetCacheByUUID(uuid)

	self.enemyAttackHintMap[pid] = nil
end

M.CloseAllEnemyAttackHint = function(self)
	for pid, effectData in pairs(self.enemyAttackHintMap) do
		local openClipName = "S_Vx_BattleHud3D_Open"
		local uuid = self.enemyAttackHintMap[pid].uuid

		gCS.EffectMgr:StopAndSampleAnimationByIndexByUUId(uuid, 0, openClipName, false, 0)
		gCS.EffectMgr:StopEffectAndSetCacheByUUID(uuid)
	end

	table.clear(self.enemyAttackHintMap)
end

M.checkNewCouldTriggerEffect = function(self)
	for skillUUID in pairs(self.currentUnitSkillUUIDSet.items) do
		if not self.hitToMeSkillUUIDSet.has(skillUUID) and gCS.EffectMgr:IsAnyCouldTriggerEffectBySkillUUID(skillUUID) then
			return true
		end
	end

	return false
end

M.ShowEnemyAttackHint = function(self, hint)
	if gGameManager.Env.IsENABLE_PROFILER then
		gGameManager:BeginSample("OffScreenHintPanel ShowEnemyAttackHint")
	end

	local playOpenAni = false
	local pid = hint.pid

	if not self.enemyAttackHintMap[pid] then
		local uuid = gCS.EffectMgr:PlayEffect(53700215, LX6.Effect.EffectPlayTag.UI)
		self.enemyAttackHintMap[pid] = {
			uuid = uuid
		}
		playOpenAni = true
	end

	self.enemyAttackHintMap[pid].isPlaying = true
	local pos = hint.localPosition
	local dir = hint.targetDir
	local rot = hint.localRotation
	local alertClipName = "S_Vx_BattleHud3D_Red"
	local uuid = self.enemyAttackHintMap[pid].uuid

	if not gCS.EffectMgr:IsEffectDestroy(uuid) then
		self:SetEnemyAttackHintPosAndRot(nil, uuid, pos, dir, rot)

		if gCS.EffectMgr:IsEffectHasSlot(uuid) then
			if hint.showAlert then
				if not hint.effectShowAlert then
					gCS.EffectMgr:PlayAnimationByIndexByUUId(uuid, 0, alertClipName, true)

					hint.effectShowAlert = true
				end
			elseif playOpenAni then
				gCS.EffectMgr:PlayAnimationByIndexByUUId(uuid, 0, alertClipName, true)

				hint.effectShowAlert = false
			elseif hint.effectShowAlert then
				gCS.EffectMgr:PlayAnimationByIndexByUUId(uuid, 0, alertClipName, false)

				hint.effectShowAlert = false
			end
		end
	end

	if gGameManager.Env.IsENABLE_PROFILER then
		gGameManager:EndSample()
	end
end

M.SetEnemyAttackHintPosAndRot = function(self, effect, effectUUId, pos, dir, rot)
	if gGameManager.Env.IsENABLE_PROFILER then
		gGameManager:BeginSample("SetEnemyAttackHintPosAndRot")
	end

	if gMainMenuMgr:HasTargetParkourState(LTConfig.ParkourStateConfig.Drive) and gCS.DriveManager.CurrentPlayerBaseVehicle then
		local car = gCS.DriveManager.CurrentPlayerBaseVehicle
		local carRight = car.transform.right
		local length = car.vehicleSize.z
		local width = car.vehicleSize.x + GameConfig.EnemyAttackHintEllipseExtRadius
		local height = car.vehicleSize.y + GameConfig.EnemyAttackHintEllipseExtRadius
		local angle = gCS.BaseUnitUtils.GetAngle(carRight, dir)
		local vec = self:GetEllipsePos(width, length, -angle)
		pos = car.transform:TransformPoint(vec)
		pos.y = pos.y + 0.5 * height
	else
		pos = pos + dir.normalized
	end

	gCS.EffectMgr:SetPositionAndRotationByUUId(effectUUId, pos, rot.eulerAngles)

	if gGameManager.Env.IsENABLE_PROFILER then
		gGameManager:EndSample()
	end
end

M.GetEllipsePos = function(self, a, b, t)
	t = Mathf.Deg2Rad * t
	local x = a * Mathf.Cos(t)
	local z = b * Mathf.Sin(t)
	local vec = Vector3.New(x, 0, z)

	return vec
end

M.CheckDetectToMeSet = function(self)
	self.detectToMeSet.each(function (unitId)
		local unit = gCS.SceneDataMgr.GetUnit(unitId)
		local unitDataSet = gDataSetManager:TryGetOrCreateUnitData(unitId)

		if not unit or unit.IsDead or unitDataSet.detectionToMeValue ~= nil or unitDataSet.detectionToMeValue < 0 then
			self.detectToMeSet.delete(unitId)
		end
	end)
end

M.InHideDetectState = function(self, pid)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	return gCS.UnitStateMgr:HasState(unit, UnitStateConfig.NearDeath) or gCS.UnitStateMgr:HasState(unit, UnitStateConfig.DeadS) or gCS.UnitStateMgr:HasState(unit, 10308)
end

M.RefreshFill = function(self, store, startValue, progress)
	if startValue then
		store.detectFill = startValue
	end

	if not store.detectFill then
		return
	end

	if math.abs(store.detectFill - progress) >= 0.01 then
		return
	end

	if startValue == nil or store.detectFill == progress then
		if store.tweenFill then
			store.tweenFill:Kill()
		end

		local tweenFill = DOTween.To(function ()
			return store.detectFill
		end, function (value)
			store.detectFill = value

			if value <= 0 and value >= 0.5 then
				store.detectState = 0
			elseif value >= 1 then
				store.detectState = 1
			else
				store.detectState = 2
			end
		end, progress, 0.3):SetEase(Ease.Linear):OnKill(function ()
			store:Commit("tweenFill", nil)
		end)

		store:Commit("tweenFill", tweenFill)
	end
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.LOAD_SCENE_COMPLETED] = function ()
			self.raidCfg = RaidConfig.GetConfig(gRaidDataManager.RaidId)
		end,
		[gEventConstants.ADD_OR_REMOVE_DETECT_TO_ME] = function (eventId, data)
		end,
		[gEventConstants.UNIT_LOCK_TARGET] = function (eventId, data)
			local triggerId = data.triggerId
			local targetId = data.targetId
			local trigger = gCS.SceneDataMgr.GetUnit(triggerId)
			local target = gCS.SceneDataMgr.GetUnit(targetId)

			if not trigger or not target or not target.IsMe then
				self.lockToMeSet.delete(triggerId)

				return
			end

			self.lockToMeSet.insert(triggerId)
		end
	}
end
