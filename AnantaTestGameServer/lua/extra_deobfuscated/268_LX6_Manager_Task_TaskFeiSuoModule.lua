C_TaskFeiSuoModule = DefClass("C_TaskFeiSuoModule", C_TaskFeiSuoModule)
local TaskFeiSuoModule = C_TaskFeiSuoModule
local HackingConfig = LTConfig.HackingConfig
local TaskState = UX.Game.TaskState

function TaskFeiSuoModule:ctor()
	self.m_Timer = gLogicTime.time
	self.m_UpdaterName = "TaskManager_TaskFeiSuo"
	self.m_FeiSuoCache = {}
	self.m_GpsDataTemplate = {
		ForceHide = true,
		UseFeiSuoPoint = true,
		InstanceId = "UniqueTaskFeiSuo",
		TaskFeiSuoId = 0,
		GpsType = gTaskGpsType.Responsive,
		AutoShowDistance = HackingConfig.TaskFeiSuoDis
	}
end

function TaskFeiSuoModule:OnInit()
	gMessageManager:AddMessageListener(gEventConstants.LOADING_FINISHED, function (eventId, switchType)
		self:OnLoadingFinish(eventId, switchType)
	end)
end

function TaskFeiSuoModule:OnLoadingFinish(eventId, switchType)
	local tasks = gTaskManager.tasks

	for _, taskInfo in pairs(tasks) do
		if taskInfo.State == TaskState.Accepted then
			local taskId = taskInfo.TaskId

			self:AddTaskStaticFeiSuoInfo(taskId)
		end
	end
end

function TaskFeiSuoModule:RefreshDynamicUpdate()
	if self:CheckNotHasTaskFeiSuo() then
		gLuaClient:UnregisterDynamicUpdate(self.m_UpdaterName)
	else
		gLuaClient:RegisterDynamicUpdate(self.m_UpdaterName, self)
	end
end

function TaskFeiSuoModule:NewGpsDataInstance()
	return self.m_GpsDataTemplate
end

function TaskFeiSuoModule:NewFeiSuoDataInstanceFromStaticSpoonInfo(index, feiSuoSpoonStaticInfo)
	local v = feiSuoSpoonStaticInfo
	local data = {
		Enable = true,
		Id = v.Id or index,
		pos = v.Pos,
		FeiSuoDistance = v.FeiSuoDistance or -1,
		NpcId = v.NpcId and v.NpcId ~= 0 and v.NpcId or nil,
		VehicleId = v.VehicleId and v.VehicleId ~= 0 and v.VehicleId or nil,
		GadgetUniqueId = v.GadgetUniqueId and v.GadgetUniqueId ~= 0 and v.GadgetUniqueId or nil,
		SlotBindName = v.SlotBindName,
		MoverBindId = v.MoverBindId,
		IsPoint = v.IsPoint,
		ResponsiveCallBack = function ()
			if v.Id and v.Id ~= 0 then
				gClientToGameSceneDelegate:AskFeiSuoSuccess(v.Id)
			end

			if not table.isNilOrEmpty(HackingConfig.TaskFeiSuoCallBack) then
				for i = 1, #HackingConfig.TaskFeiSuoCallBack do
					gDialogAction:RunFunc(HackingConfig.TaskFeiSuoCallBack[i], nil, nil, nil, nil, {
						pos = v.Pos,
						id = v.NpcId,
						vehicleId = v.VehicleId,
						GadgetUniqueId = v.GadgetUniqueId,
						slotBindName = v.SlotBindName,
						moverBindId = v.MoverBindId,
						banMove = v.BanMove,
						isPoint = v.IsPoint or false
					})
				end
			end
		end
	}

	return data
end

function TaskFeiSuoModule:HandleCurrentTaskFeiSuo()
	if self.m_GpsDataTemplate.ResponsiveCallBack and gMapSubSystem_NearByMisc.canUseTaskFeiSuo then
		self.m_GpsDataTemplate.ResponsiveCallBack()
	end
end

function TaskFeiSuoModule:EnableTaskStaticFeiSuo(taskId, feisuoId, enable)
	local l = self.m_FeiSuoCache[taskId]

	if not l then
		return
	end

	for _, v in ipairs(l) do
		if v.Id == feisuoId then
			v.Enable = enable

			return
		end
	end
end

function TaskFeiSuoModule:AddTaskStaticFeiSuoInfo(taskId)
	self:ClearTaskFeiSuo(taskId)

	local feiSuoList = {}
	feiSuoList = gCS.LuaUtils.GetSpoonTaskMgrFeisuoInfo(taskId)

	if not feiSuoList then
		return
	end

	if #feiSuoList <= 0 then
		return
	end

	local l = {}
	self.m_FeiSuoCache[taskId] = l

	for i, v in ipairs(feiSuoList) do
		if v then
			local data = self:NewFeiSuoDataInstanceFromStaticSpoonInfo(i, v)
			l[#l + 1] = data
		end
	end

	self:RefreshDynamicUpdate()
end

function TaskFeiSuoModule:AddDynamicTaskFeiSuo(taskId, data)
	local l = self.m_FeiSuoCache[taskId]

	if not self.m_FeiSuoCache[taskId] then
		l = {}
		self.m_FeiSuoCache[taskId] = l
	end

	l[#l + 1] = data
end

function TaskFeiSuoModule:RemoveDynamicTaskFeiSuo(taskId, instanceId)
	local instances = self.m_FeiSuoCache[taskId]

	if instances then
		return
	end

	if not instances[instanceId] then
		return
	end

	instances[instanceId] = nil

	if self:CheckNotHasTaskFeiSuo() then
		gTaskManager.taskFeiSuo.hasTaskFeiSuo = false

		gCS.FeiSuoCrouchManager.SetHideUI(gCS.FeiSuoCrouchManager.HideUIReason.TaskFeisuo, false)
		gGpsManager:RemoveGPSById(self.m_GpsDataTemplate.InstanceId, self.m_GpsDataTemplate.GpsType)
	end
end

function TaskFeiSuoModule:ClearTaskFeiSuo(taskId)
	gGpsManager:RemoveGPSById(self.m_GpsDataTemplate.InstanceId, self.m_GpsDataTemplate.GpsType)
	gMapSubSystem_NearByMisc:RemoveTaskFeiSuo()

	local instances = self.m_FeiSuoCache[taskId]

	if not instances then
		return
	end

	self.m_FeiSuoCache[taskId] = nil

	if self:CheckNotHasTaskFeiSuo() then
		gTaskManager.taskFeiSuo.hasTaskFeiSuo = false

		gCS.FeiSuoCrouchManager.SetHideUI(gCS.FeiSuoCrouchManager.HideUIReason.TaskFeisuo, false)
	end

	self:RefreshDynamicUpdate()
end

function TaskFeiSuoModule:GetTaskFeiSuoSum()
	local sum = 0

	if self.m_FeiSuoCache then
		for _, v in pairs(self.m_FeiSuoCache) do
			sum = sum + (v and #v or 0)
		end
	end

	return sum
end

function TaskFeiSuoModule:CheckNotHasTaskFeiSuo()
	return self:GetTaskFeiSuoSum() <= 0
end

function TaskFeiSuoModule:IsTaskFeiSuoShow(taskId, targetPos, npcId, VehicleId, GadgetUniqueId, slotBindName, feiSuoDistance)
	if not gCS.MyPlayerManager.PlayerUnit then
		return false
	end

	if targetPos == nil and (npcId == nil or npcId == 0) and (VehicleId == nil or VehicleId == 0) and (GadgetUniqueId == nil or ulong.equals(GadgetUniqueId, 0)) then
		return false
	end

	local pid = nil

	if npcId then
		local unit = gCS.NpcMgr:GetNpcByTemplateId(npcId)

		if unit and unit.CanUseRes then
			if not unit.ModelSlot and not unit.ModelSlot.feisuoPoint then
				print_error("策划配置有误，飞索点没有配ModelSlot或者feisuoPoint！ TaskId:", taskId, " Pid:", unit.Pid, " npcId", npcId)
			end

			if unit.ModelSlot and unit.ModelSlot.feisuoPoint then
				targetPos = unit.ModelSlot.feisuoPoint.position
			else
				targetPos = unit.LocalPosition
			end

			pid = unit.Pid
		end
	end

	local vehicleUid = nil

	if VehicleId then
		local vehicleUnit = gDriveVehiclesManager:GetBaseVehicle(VehicleId)

		if vehicleUnit then
			local feiSuoPoint = vehicleUnit:GetFeiSuoPoint()

			if feiSuoPoint then
				targetPos = feiSuoPoint.position
			elseif vehicleUnit.gameObject then
				targetPos = vehicleUnit.gameObject.transform.position
			end

			vehicleUid = vehicleUnit.uid
		end
	end

	local luaSlot = nil

	if GadgetUniqueId and not ulong.equals(GadgetUniqueId, 0) then
		local entity = gGadgetManager:GetEntitySearchByInstanceId(GadgetUniqueId)

		if entity then
			local slotName = slotBindName
			local gameObjectMap = entity:GetGameObjectMap():ToTable()
			local go = nil

			for _, v in pairs(gameObjectMap) do
				if not gCS.LuaUtils.IsNull(v) and not v:IsDestroyed() and v.name == slotName then
					go = v

					break
				end
			end

			if not gCS.LuaUtils.IsNull(go) then
				targetPos = go.transform.position
				luaSlot = entity.entityInstanceId
			else
				targetPos = entity.gameObject.transform.position
				luaSlot = entity.entityInstanceId

				print_error("策划配置有误，luaSlot的飞索点未找到！ TaskId:", taskId, " GadgetUniqueId:", GadgetUniqueId, " BindName:", slotBindName)
			end
		end
	end

	if targetPos == nil then
		return false
	end

	local vec1 = Vector2.zero
	local vec2 = Vector2.zero
	local vec3 = Vector3.zero
	local configShowDistance = HackingConfig.TaskFeiSuoDis

	if feiSuoDistance and feiSuoDistance > 0 then
		configShowDistance = feiSuoDistance
	end

	local vertAngle = HackingConfig.TaskFeiSuoUpDownAngle
	local horzAngle = HackingConfig.TaskFeiSuoLeftRightAngle
	local configHideDistance = HackingConfig.TaskFeiSuoHideDis
	local pos = gCS.MyPlayerManager.PlayerUnit.LocalPosition

	vec3:Set(pos.x - targetPos.x, pos.y - targetPos.y, pos.z - targetPos.z)

	local dis = vec3.magnitude

	if configShowDistance < dis or dis < configHideDistance then
		return false
	end

	if vertAngle or horzAngle then
		local camTrans = gCS.CameraDataMgr.MainCamera.transform
		local p = camTrans:InverseTransformPoint(targetPos)

		if vertAngle then
			vec1:Set(p.y, p.z)
			vec2:Set(0, 1)

			local a = Vector2.Angle(vec1, vec2)

			if vertAngle < a then
				return false
			end
		end

		if horzAngle then
			vec1:Set(p.x, p.z)
			vec2:Set(0, 1)

			local a = Vector2.Angle(vec1, vec2)

			if horzAngle < a then
				return false
			end
		end
	end

	return true, dis, pid, vehicleUid, luaSlot, targetPos
end

function TaskFeiSuoModule:UpdateTaskFeiSuoTarget()
	local feiSuoDict = self.m_FeiSuoCache

	if not feiSuoDict or self:CheckNotHasTaskFeiSuo() then
		return
	end

	if not gSystemUnlockMgr:IsUnlock(LTConfig.SystemUnlockConfig.FeiSuoUnlock) then
		self:UpdateTaskFeiSuoGps(nil, 0, 0, 0, nil, 0, false, nil, 0)

		return
	end

	if gTaskManager.ForceHideFeiSuo then
		self:UpdateTaskFeiSuoGps(nil, 0, 0, 0, nil, 0, false, nil, 0)

		return
	end

	local minDis = -1
	local npcPid, vehicleId, slotId, slotBindName, tarPos, currentTaskGpsInfo = nil

	for taskId, taskFeiSuoInfos in pairs(feiSuoDict) do
		if taskFeiSuoInfos then
			for _, v in pairs(taskFeiSuoInfos) do
				currentTaskGpsInfo = currentTaskGpsInfo or v

				if v.Enable then
					local isShow, dis, pid, vehicleUid, luaEntityId, pos = self:IsTaskFeiSuoShow(taskId or v.Id, v.pos, v.NpcId, v.VehicleId, v.GadgetUniqueId, v.SlotBindName, v.FeiSuoDistance)

					if isShow and (minDis < 0 or dis < minDis) then
						currentTaskGpsInfo = v
						minDis = dis
						tarPos = pos

						if pid then
							npcPid = pid
						end

						if vehicleUid then
							vehicleId = vehicleUid
						end

						if luaEntityId then
							slotId = luaEntityId
							slotBindName = v.SlotBindName
						end
					end
				end
			end
		end
	end

	local isShow = minDis ~= -1

	if isShow and tarPos then
		isShow = gCS.LuaUtils.RayCastFeiSuoPosition(tarPos)
	end

	local taskFeiSuoId = isShow and currentTaskGpsInfo.Id or 0

	self:UpdateTaskFeiSuoGps(currentTaskGpsInfo.pos, npcPid, vehicleId, slotId, slotBindName, currentTaskGpsInfo.FeiSuoDistance, isShow, currentTaskGpsInfo.ResponsiveCallBack, taskFeiSuoId)
end

function TaskFeiSuoModule:UpdateTaskFeiSuoGps(pos, pid, vehicleId, slotId, slotBindName, feiSuoDistance, isShow, responsiveCallBack, taskFeiSuoId)
	if gTaskManager.taskFeiSuo.hasTaskFeiSuo ~= isShow then
		gTaskManager.taskFeiSuo.hasTaskFeiSuo = isShow

		gCS.FeiSuoCrouchManager.SetHideUI(gCS.FeiSuoCrouchManager.HideUIReason.TaskFeisuo, gTaskManager.taskFeiSuo.hasTaskFeiSuo)
	end

	self.m_GpsDataTemplate.AutoShowDistance = feiSuoDistance > 0 and feiSuoDistance or HackingConfig.TaskFeiSuoDis
	self.m_GpsDataTemplate.TargetPos = pos
	self.m_GpsDataTemplate.UnitPid = pid
	self.m_GpsDataTemplate.VehicleUid = vehicleId
	self.m_GpsDataTemplate.SlotPid = slotId
	self.m_GpsDataTemplate.SlotRefName = slotBindName
	self.m_GpsDataTemplate.ResponsiveCallBack = responsiveCallBack
	self.m_GpsDataTemplate.ForceHide = not isShow
	self.m_GpsDataTemplate.TaskFeiSuoId = taskFeiSuoId or 0

	gMapSubSystem_NearByMisc:AddTaskFeiSuo(self.m_GpsDataTemplate)
	gGpsManager:AddGPS(self.m_GpsDataTemplate, nil, true)
end

function TaskFeiSuoModule:OnUpdate()
	if gLogicTime.time - self.m_Timer > 0.5 then
		self.m_Timer = gLogicTime.time

		self:UpdateTaskFeiSuoTarget()
	end
end

return TaskFeiSuoModule
