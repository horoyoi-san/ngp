local yield = coroutine.yield
local GameObject = UnityEngine.GameObject
local DetectStealthState = UX.Game.EnemyDetectState
local EffectConfig = LTConfig.EffectConfig
local HackingConfig = LTConfig.HackingConfig
local patrolShowRedResPath = "Assets/Res/Effects/Prefab/CodeRef/skill_ShowPatrolPos.prefab"
local patrolShowBlueResPath = "Assets/Res/Effects/Prefab/CodeRef/skill_ShowPatrolPos_Blue.prefab"
local StealthItemResPath = "Assets/DesignerConfigData/GeneralSpoonPrefab/%s.prefab"
local GeneralModelConfig = LTConfig.GeneralModelConfig
local StealthEnemyConfig = LTConfig.AgentDetectConfig
local ActionManager = LX6.Units.ActionManager
local HackingSCIIConfig = LTConfig.HackingSCIIConfig
local M = {
	guardPidList = {},
	patrolLines = {},
	linePool = {},
	lineLoadOps = {},
	lastFindPlayerPoint = {},
	stealthMonitorRoot = nil,
	stealthMonitorDict = {},
	HackedMonitorDict = {},
	sceneCanInteractionItems = {},
	PropLocks = {},
	areaBoxCountFinishEffects = {},
	effectCache = {},
	canInteractionItemsRoot = nil,
	showEnemyViewNum = false,
	perceivedValueList = {},
	UnlockedTrigger = {},
	HackingMonitor = nil,
	_dynamicIsMindCache = {}
}
local eventHandler = {
	[gEventConstants.LOAD_SCENE_COMPLETED] = function ()
		M:InitScene()
	end,
	[gEventConstants.UNIT_DESTROY] = function (eventId, data)
		local pid = data

		M:HideEnemyPatrolPos(pid)
	end
}

function M:SetToMeStealthValue(guardUnitPid, state, value)
	if value > 0 and gPanelManager:IsPanelShowing(gPanelId.S_OFF_SCREEN_HINT_PANEL) then
		gMessageManager:SendMessage(gEventConstants.ADD_OR_REMOVE_DETECT_TO_ME, {
			isAdd = true,
			unitPid = guardUnitPid
		})
	end

	if value == 0 and gPanelManager:IsPanelShowing(gPanelId.S_OFF_SCREEN_HINT_PANEL) then
		gMessageManager:SendMessage(gEventConstants.ADD_OR_REMOVE_DETECT_TO_ME, {
			isAdd = false,
			unitPid = guardUnitPid
		})
	end
end

function M:SwitchUnitStealthState(guardUnitPid, state, preState, value)
	local guardUnit = gCS.SceneDataMgr.GetUnit(guardUnitPid)
	local dataSet = gDataSetManager:GetUnitData(guardUnitPid)

	self:CheckPerceivedValue(guardUnit, guardUnitPid, value)

	if dataSet.stealthCfgId == nil or dataSet.stealthCfgId == 0 then
		return
	end

	if state == DetectStealthState.Alert and self.guardPidList[guardUnitPid] then
		-- Nothing
	end

	M:SetToMeStealthValue(guardUnitPid, state, value)

	if preState == DetectStealthState.Suspect and state ~= DetectStealthState.Suspect and self.lastFindPlayerPoint[guardUnitPid] and not gCS.LuaUtils.IsNull(self.lastFindPlayerPoint[guardUnitPid]) then
		UnityEngine.GameObject.Destroy(self.lastFindPlayerPoint[guardUnitPid])

		self.lastFindPlayerPoint[guardUnitPid] = nil
		local gdUnit = gCS.SceneDataMgr.GetUnit(guardUnitPid)

		gCS.LookAtIkModule.StopLookAtIkPlugin(gdUnit)
	end

	if preState ~= DetectStealthState.Fight and state == DetectStealthState.Fight then
		gMessageManager:SendMessage(gEventConstants.SYNC_HACKUNIT_ENTER_FIGHT, guardUnitPid)
	end

	local stealthEnemyCfg = StealthEnemyConfig.GetConfig(dataSet.stealthCfgId)

	if stealthEnemyCfg and stealthEnemyCfg.DetectionStateToActionGroup then
		for i, v in pairs(stealthEnemyCfg.DetectionStateToActionGroup) do
			if state == v.State and guardUnit.State.ActionGroupId ~= v.ActionGroup then
				guardUnit.dialogActionGroupType = v.ActionGroup

				ActionManager.CheckActionGroupId(guardUnit)
			end
		end
	end
end

function M:CheckPerceivedValue(guardUnit, pid, value)
	local lastValue = self.perceivedValueList[pid]

	if not self.perceivedValueList[pid] then
		self.perceivedValueList[pid] = value
		lastValue = 0
	end

	if self.perceivedValueList[pid] < value and value < 100 then
		self:PlayPerceivedEffect(pid)
	end

	if lastValue == 0 and value > 0 then
		gCS.LuaUtils.TriggerStartAlert(guardUnit)
	elseif lastValue <= 50 and value > 50 then
		gCS.LuaUtils.TriggerAlert(guardUnit)
	end

	self.perceivedValueList[pid] = value
end

function M:GetPerceivedValue(pid)
	return self.perceivedValueList[pid] or 0
end

function M:PlayPerceivedEffect(pid)
	if gCS.BattleManager.IsAnyEnemyLockMe() then
		return
	end

	if self.perceivedTimer then
		gLuaTimeMgrUtils.CancelUnitDelay(self.perceivedTimer)

		self.perceivedTimer = nil
	end

	if not self.perceivedEffectUUID then
		self.perceivedEffectUUID = gCS.EffectMgr:PlayEffectsForUnit(gCS.MyPlayerManager.PlayerUnit, EffectConfig.DetectEffect)
	end

	self.perceivedTimer = gLuaTimeMgrUtils.Delay(function ()
		self.perceivedTimer = nil

		if self.perceivedEffectUUID then
			gCS.EffectMgr:StopEffectAndSetCacheByUUID(self.perceivedEffectUUID)

			self.perceivedEffectUUID = nil
		end
	end, 0.6)
end

function M:KillPerceivedEffect(pid)
	if self.perceivedTimer then
		gLuaTimeMgrUtils.CancelUnitDelay(self.perceivedTimer)

		self.perceivedTimer = nil
	end

	if self.perceivedEffectUUID then
		gCS.EffectMgr:StopEffectAndSetCacheByUUID(self.perceivedEffectUUID)

		self.perceivedEffectUUID = nil
	end
end

function M.EnemyLockMe(unit)
	return gCS.MyPlayerManager.PlayerUnit ~= nil and unit.ClientData.Type == UX.Game.EntityType.Enemy and ulong.equals(unit.LockTargetId, gCS.MyPlayerManager.PlayerUnit.Pid)
end

function M:OnInit()
	self:Init()
end

function M:Init()
	for k, v in pairs(eventHandler) do
		gMessageManager:AddMessageListener(k, v)
	end

	self.easyTouchStartListener = gCS.LuaUtils.ListenTouchStart(self.HandleTouchStart)
	self.easyTouchUpListener = gCS.LuaUtils.ListenTouchUp(self.HandleTouchUp)
end

function M:InitScene()
	if self.isInit then
		return
	end

	local IsVisible = true
	self.MonitorVisible = IsVisible

	self:SetAllMonitorDisplay(IsVisible)
	self:InitAllMonitor()

	self.isInit = true
end

function M:OnBeforeSwitchScene(switchType)
	if gSwitchSceneType.Image <= switchType then
		self:ClearSceneData()
	end
end

function M:ClearSceneData()
	self.guardPidList = {}

	for i, v in pairs(self.lastFindPlayerPoint) do
		if not gCS.LuaUtils.IsNull(v) then
			UnityEngine.GameObject.Destroy(v)
		end
	end

	self.lastFindPlayerPoint = {}

	self:ClearAllPatrol()
	self:ClearAllMonitor()
	self:ClearAllDropItemTriggerArea()
	self:ClearAllEffect()

	self.lastReportEyeAngleCache = {}
	self.guardUnitCheckVisibleCache = {}
	self.UnlockedTrigger = {}
	self.isInit = false
end

function M:CircleIntersectWithSector(self, circleCenter, circleRadius, sectorCenter, minRadius, maxRadius, startAngle, endAngle)
	return gCS.LuaUtils.CircleIntersectWithSector(Vector3.New(circleCenter.X, circleCenter.Y, circleCenter.Z), circleRadius, Vector3.New(sectorCenter.X, sectorCenter.Y, sectorCenter.Z), minRadius, maxRadius, startAngle, endAngle)
end

function M:OnHandleInputShootingMode()
	if self.isTouch and gPlayerManager.main.bindData.isInShootingMode and self.startPos then
		local pos = gUtils:GetTouchPosition(self.finger)
		local myPlayerCSUnit = gCS.MyPlayerManager.PlayerUnit

		self:HandleTouchScreenAsRotateUnit(myPlayerCSUnit, pos.x - self.startPos.x, HackingConfig.ViewingAngleSlidingSpeed)

		self.startPos = pos
	end
end

function M.HandleTouchStart(gesture)
	if not gPlayerManager.main.bindData.isInShootingMode then
		return
	end

	M.isTouch = true
	M.touchMoved = false
	M.finger = gesture.fingerIndex
	M.startPos = gUtils:GetTouchPosition(M.finger)
end

function M.HandleTouchUp(gesture)
	M.isTouch = false
	M.touchMoved = false
	M.finger = nil
	M.startPos = nil
end

function M:ClearAllEffect()
	for i, v in pairs(self.effectCache) do
		if not gCS.LuaUtils.IsNull(v) then
			GameObject.Destroy(v.gameObject)
		end
	end

	self.effectCache = {}
end

function M:ClearAllPatrol()
	for _, v in pairs(self.linePool) do
		local lineTypePool = v

		for j = 1, #lineTypePool do
			local res = lineTypePool[j]

			if res and not gCS.LuaUtils.IsNull(res) then
				GameObject.Destroy(res)
			end
		end
	end

	self.linePool = {}

	for _, v in pairs(self.patrolLines) do
		local res = v.res

		if res and not gCS.LuaUtils.IsNull(res) then
			GameObject.Destroy(res)
		end
	end

	self.patrolLines = {}

	for _, v in pairs(self.lineLoadOps) do
		gResourceManager:UnloadAssetLoadOp(v)
	end

	self.lineLoadOps = {}
end

function M:HideEnemyPatrolPos(pid)
	self:DisUseLine(pid)
end

function M:DisplayEnemyPatrolPos(pid, pointList, colorType)
	if pointList == nil then
		return
	end

	local info = self.patrolLines[pid]

	if info ~= nil then
		self:DisUseLine(pid)
	end

	self:GetOrNewLine(function (obj)
		obj.gameObject:SetActive(true)
		self:TrySetPatrolPos(pid, pointList, obj, colorType)
	end, colorType)
end

function M:GetOrNewLine(cb, colorType)
	local res = nil
	local linePool = self.linePool[colorType]

	if linePool then
		while #linePool > 0 do
			res = linePool[1]

			table.remove(linePool, 1)

			if res ~= nil and not gCS.LuaUtils.IsNull(res) and cb then
				cb(res)

				return
			end
		end
	end

	gCoroutineManager:StartCoroutine(self.CreatePatrolLine, function (obj)
		cb(obj)
	end, colorType)
end

function M:DisUseLine(pid)
	local info = self.patrolLines[pid]

	if info == nil then
		return
	end

	local unUseRes = info.res

	if unUseRes ~= nil and not gCS.LuaUtils.IsNull(unUseRes.gameObject) then
		unUseRes.gameObject:SetActive(false)
	else
		return
	end

	if self.linePool[info.colorType] == nil then
		self.linePool[info.colorType] = {}
	end

	table.insert(self.linePool[info.colorType], unUseRes)

	self.patrolLines[pid] = nil
end

function M:TrySetPatrolPos(pid, pointList, obj, colorType)
	local positionList = {}
	local count = pointList.Count

	if type(pointList) == "table" then
		count = #pointList
	end

	for i = 1, count do
		local v = nil

		if pointList[i].position then
			v = pointList[i].position
		else
			v = Vector3.New(pointList[i].X, pointList[i].Y, pointList[i].Z)
		end

		table.insert(positionList, v)
	end

	gCS.LuaUtils.SetLine(positionList, obj)

	self.patrolLines[pid] = {
		res = obj,
		colorType = colorType
	}
end

function M.CreatePatrolLine(cb, colorType)
	local loadOp = M.lineLoadOps[colorType]

	if loadOp == nil then
		local path = patrolShowRedResPath

		if colorType == 1 then
			path = patrolShowRedResPath
		else
			path = patrolShowBlueResPath
		end

		loadOp = gResourceManager:LoadAssetAsync(path, typeof(GameObject))
		M.lineLoadOps[colorType] = loadOp
	end

	yield(loadOp)

	local currentLine = loadOp.asset
	local obj = GameObject.Instantiate(currentLine)

	obj.gameObject:SetActive(true)

	if cb then
		cb(obj)
	end
end

function M:GetStealthItemByPid(id)
	return nil
end

function M:ClearAllDropItemTriggerArea()
	for index, areaBoxCountFinishEffectUUid in pairs(self.areaBoxCountFinishEffects) do
		gCS.EffectMgr:StopEffectAndSetCacheByUUID(areaBoxCountFinishEffectUUid)
	end

	self.areaBoxCountFinishEffects = {}
end

function M:InitAllDropItemTriggerArea()
	if gSpoonMgr:GetRaidGraph() then
		local areaBoxCountFinishList = gSpoonMgr:GetRaidGraph().AreaBoxCountFinish

		if areaBoxCountFinishList then
			for index, areaBoxCountFinish in pairs(areaBoxCountFinishList) do
				if self.areaBoxCountFinishEffects[index] then
					print_error(index, " areaBox AllReady Have")

					return
				end

				local pos = areaBoxCountFinish.spoonTransform.position
				local effectUUID = gCS.EffectMgr:PlayEffects(EffectConfig.BoxAreaEffect, pos)
				self.areaBoxCountFinishEffects[index] = effectUUID

				gCS.EffectMgr:SetLocalEulerAnglesByUUId(effectUUID, Vector3.New(0, areaBoxCountFinish.spoonTransform.facing, 0))
				gCS.EffectMgr:SetLocalScaleByUUId(effectUUID, Vector3.New(areaBoxCountFinish.specialInfo.radius * 2, 1, areaBoxCountFinish.specialInfo.radius * 2))
			end
		end
	end
end

function M:SetAllMonitorDisplay(isVisible)
	for i, v in pairs(self.stealthMonitorDict) do
		v:SetVisible(isVisible)
	end
end

function M:UpdateHackedMonitor(hackedMonitor)
	local name = hackedMonitor.MonitorName
	local pid = hackedMonitor.PlayerId

	if self.stealthMonitorDict[name] and pid ~= nil and ulong.equals(pid, gPlayerManager.infoLogin.bindData.pid) then
		if self.HackingMonitor then
			self:SetHackedMonitor(self.HackingMonitor, nil)
			self.stealthMonitorDict[self.HackingMonitor]:OnCloseMonitorVision()
		end

		if self.stealthMonitorDict[name] then
			self.HackingMonitor = name

			self.stealthMonitorDict[name]:OpenMonitorVision()
		end
	end

	self:SetHackedMonitor(name, pid)
end

function M:SetHackedMonitor(monitorName, pid)
	if pid and self.stealthMonitorDict[monitorName] then
		self.stealthMonitorDict[monitorName].HackingMonitorVision(pid)
	end

	local pid = pid
	self.HackedMonitorDict[monitorName] = pid
end

function M:RemoveHackedMonitor(name)
	if self.stealthMonitorDict[name] then
		self.stealthMonitorDict[name].StopHacking()
	end

	local preHacker = self.HackedMonitorDict[name]
	self.HackedMonitorDict[name] = nil

	if self.HackingMonitor == name and ulong.equals(preHacker, gPlayerManager.infoLogin.bindData.pid) then
		self.HackingMonitor = nil

		self.stealthMonitorDict[name]:OnCloseMonitorVision()
	end
end

function M:AskHackingMonitor(name, timeLine)
	if self.HackedMonitorDict[name] then
		return
	end

	if self.HackingMonitor then
		local preHackingMonitor = self.HackingMonitor

		self:SetHackedMonitor(preHackingMonitor, nil)
		self.stealthMonitorDict[preHackingMonitor]:OnCloseMonitorVision()

		if self.stealthMonitorDict[name] then
			self.HackingMonitor = name

			self.stealthMonitorDict[name]:OpenMonitorVision(timeLine)
		end

		self:SetHackedMonitor(name, gPlayerManager.infoLogin.bindData.pid)
	else
		if self.stealthMonitorDict[name] then
			self.HackingMonitor = name

			self.stealthMonitorDict[name]:OpenMonitorVision(timeLine)
		end

		self:SetHackedMonitor(name, gPlayerManager.infoLogin.bindData.pid)
	end
end

function M:EndHackingMonitor(name, cb)
	if self.HackingMonitor ~= name then
		return
	end

	if self.stealthMonitorDict[name] then
		if self.HackingMonitor == name then
			self.HackingMonitor = nil
		end

		self:SetHackedMonitor(name, nil)
		self.stealthMonitorDict[name]:OnCloseMonitorVision()
	end

	M:RemoveHackedMonitor(name)
end

function M:GetMonitor(name)
	return self.stealthMonitorDict[name]
end

function M:TrackClearAimGame(groupId)
	for i, v in pairs(self.stealthMonitorDict) do
		if v.taskGroup == groupId then
			local isLockPos = v:IsLockToPos()

			if not isLockPos then
				return false
			end
		end
	end

	if groupId == self.runningAimGame then
		self.runningAimGame = nil
	end
end

function M:StartMonitorAimGame(groupId, isStart, entityPid)
	if isStart then
		if gSpoonMgr:GetRaidGraph() then
			local monitors = gSpoonMgr:GetRaidGraph().Monitors:ToTable()
			local aimGameT = {}

			for monitorId, monitor in pairs(monitors) do
				if monitor.taskGroup == groupId then
					if self.stealthMonitorDict[monitorId] then
						print_error(monitorId, " Monitor AllReady Have")

						return
					end

					if monitor then
						table.insert(aimGameT, {
							id = monitorId,
							nextPoint = monitor.nextPoint
						})

						local quaternion = Quaternion.Euler(monitor.rotation.x, monitor.rotation.y, monitor.rotation.z)
						local pos = Vector3.NewT(monitor.pos:ToLuaTable())
						local forward = quaternion * Vector3.New(0, 0, 1)
						local up = quaternion * Vector3.New(0, 1, 0)
						local right = quaternion * Vector3.New(1, 0, 0)
						local monitorEntity = self:AddMonitor(monitorId, forward, pos, up, right, "DailyAim", true)
						monitorEntity.taskGroup = groupId
						monitorEntity.isPointToPosGame = true
						monitorEntity.pastTimes = 0
						monitorEntity.isStartPoint = monitor.isStartPoint

						if monitor.nextPoint and monitor.nextPoint ~= 0 then
							local nextMonitor = monitors[monitor.nextPoint]
							local nextPosition = Vector3.NewT(nextMonitor.Pos)
							monitorEntity.gameClearDir = nextPosition - pos
							monitorEntity.gameLength = monitorEntity.gameClearDir:Magnitude()
							monitorEntity.nextPoint = monitor.nextPoint
						else
							monitorEntity.gameClearDir = true
						end

						if monitor.sendSignalToSpoonSignalKey and monitor.sendSignalToSpoonSignalKey ~= "" then
							monitorEntity.sendSignalToSpoonSignalKey = monitor.sendSignalToSpoonSignalKey
						end

						if monitor.addTaskCountTaskId and monitor.addTaskCountTaskId ~= 0 then
							monitorEntity.addTaskCountTaskId = monitor.addTaskCountTaskId
							monitorEntity.addTaskCountCounterId = monitor.addTaskCountCounterId
							monitorEntity.addTaskCountValue = monitor.addTaskCountValue
						end

						monitorEntity.isCanInteraction = false
						monitorEntity.luaSlotEntityId = entityPid
						self.stealthMonitorDict[monitorId] = monitorEntity
						self.runningAimGame = groupId

						if self.runningAimGameStartPoint == nil then
							self.runningAimGameStartPoint = monitorId
						end

						if monitor.isStartPoint == true then
							self.runningAimGameStartPoint = monitorId
						end
					end
				end
			end

			if self.runningAimGameStartPoint then
				local entity = self.stealthMonitorDict[self.runningAimGameStartPoint]

				if entity then
					entity.isCanInteraction = true
				end
			end
		end
	else
		for i, v in pairs(self.stealthMonitorDict) do
			if v.taskGroup == groupId then
				self.stealthMonitorDict[i].isDestroy = true

				v:Destroy()

				self.stealthMonitorDict[i] = nil
			end
		end

		if self.runningAimGame == groupId then
			self.runningAimGame = nil
			self.runningAimGameStartPoint = nil
		end
	end
end

function M:InitAllMonitor()
	if not table.isNilOrEmpty(self.stealthMonitorDict) then
		self:ClearAllMonitor()
	end

	if gSpoonMgr:GetRaidGraph() and gSpoonMgr:GetRaidGraph().Monitors then
		local monitors = gSpoonMgr:GetRaidGraph().Monitors:ToTable()

		self:InitMonitors(monitors)
	end
end

function M:InitMonitors(monitors)
	if monitors.ToTable then
		monitors = monitors:ToTable()
	end

	for monitorName, monitor in pairs(monitors) do
		if monitor.taskGroup == nil then
			if self.stealthMonitorDict[monitorName] then
				print_error(monitorName, " Monitor AllReady Have")

				return
			end

			if monitor then
				local quaternion = Quaternion.Euler(monitor.rotation.x, monitor.rotation.y, monitor.rotation.z)
				local pos = Vector3.NewT(monitor.pos:ToLuaTable())
				local forward = quaternion * Vector3.New(0, 0, 1)
				local up = quaternion * Vector3.New(0, 1, 0)
				local right = quaternion * Vector3.New(1, 0, 0)
				local monitorEntity = self:AddMonitor(monitorName, forward, pos, up, right)
				monitorEntity.isCanInteraction = monitor.isCanNotInteraction ~= true
				self.stealthMonitorDict[monitorName] = monitorEntity
			end
		end
	end
end

function M:CheckMonitorIsInHack(monitorName)
	if self.HackedMonitorDict[monitorName] then
		self:UpdateHackedMonitor({
			MonitorName = monitorName,
			PlayerId = self.HackedMonitorDict[monitorName]
		})
	end
end

function M:ClearMonitors(monitors)
	if monitors.ToTable then
		monitors = monitors:ToTable()
	end

	for monitorName, monitor in pairs(monitors) do
		if self.stealthMonitorDict[monitorName] then
			self.stealthMonitorDict[monitorName]:Destroy()

			self.stealthMonitorDict[monitorName] = nil
		end
	end
end

function M:ClearAllMonitor()
	for i, v in pairs(self.stealthMonitorDict) do
		v:Destroy()
	end

	self.stealthMonitorDict = {}

	if self.stealthMonitorRoot then
		GameObject.Destroy(self.stealthMonitorRoot)
	end

	self.stealthMonitorRoot = nil
end

function M.LoadGameObject(cb, prefabName, resPath)
	if resPath == nil then
		resPath = StealthItemResPath
	end

	if not string.starts_with(resPath, "Assets/") then
		resPath = "Assets/" .. resPath
	end

	local path = gString.Format(resPath, prefabName)
	local loadOp = gResourceManager:LoadAssetAsync(path, typeof(GameObject))

	yield(loadOp)

	local res = loadOp.asset

	if res == nil or gCS.LuaUtils.IsNull(res) then
		print_error(resPath, prefabName, "不存在")

		return
	end

	local obj = GameObject.Instantiate(res)

	obj.gameObject:SetActive(true)

	if cb then
		cb(obj, loadOp)
	end
end

function M:AddMonitor(key, forward, pos, up, right, prefabName, isPointToPosGame)
	if self.stealthMonitorRoot == nil then
		self.stealthMonitorRoot = GameObject.New("MonitorRoot")
	end

	local monitorEntity = StealthMonitor.New()
	monitorEntity.isPointToPosGame = isPointToPosGame
	self.stealthMonitorDict[key] = monitorEntity

	monitorEntity:Init(key, forward, pos, up, right)

	local cfg = GeneralModelConfig.GetConfig(GeneralModelConfig.Monitor)

	if prefabName == nil or prefabName == "" then
		prefabName = cfg.Model
	end

	monitorEntity:SetVisible(self.MonitorVisible)

	local entityKey = key

	gCoroutineManager:StartCoroutine(self.LoadGameObject, function (monitorGo)
		if self.stealthMonitorRoot == nil then
			UnityEngine.GameObject.Destroy(monitorGo)

			return
		end

		monitorGo.transform:SetParent(self.stealthMonitorRoot.transform)
		monitorEntity:BindView(monitorGo)
		self:CheckMonitorIsInHack(entityKey)
	end, prefabName)

	return monitorEntity
end

local mainCameraTransform = nil

function M:UpdateMeFollowCamera()
	if gPlayerManager.main.bindData.isInShootingMode then
		if mainCameraTransform == nil then
			mainCameraTransform = gCS.CameraDataMgr.MainCamera.transform
		end

		local myPlayerCSUnit = gCS.MyPlayerManager.PlayerUnit

		if myPlayerCSUnit then
			local forward = Vector3.ProjectOnPlane(mainCameraTransform.forward, myPlayerCSUnit.Up)

			myPlayerCSUnit:SetFacing(forward)
		end
	end
end

function M:HandleTouchScreenAsRotateUnit(cs_unit, inputAxisX, rotateSpeed, rotateByCharacterY)
	local currentFacing = cs_unit.FacingDirection

	if rotateSpeed == nil then
		rotateSpeed = 1
	end

	if rotateByCharacterY then
		cs_unit:RotateFacingByCharacterUp(inputAxisX * rotateSpeed)
	else
		cs_unit:SetFacing(currentFacing + inputAxisX * rotateSpeed)
	end
end

function M:GetFunctionAndArgs(fStr)
	local argsStr = string.match(fStr, "%((.*)%)")
	local funcStr = string.match(fStr, "(.*)%(")

	string.gsub(argsStr, " ", "")

	local args = string.split(argsStr, ",")

	return funcStr, args
end

gStealthManager = M
