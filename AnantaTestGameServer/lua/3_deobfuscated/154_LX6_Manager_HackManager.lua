local GameConfig = LTConfig.GameConfig
local RaidConfig = LTConfig.RaidConfig
local LogicalHiddenCause = LX6.Units.LogicalHiddenCause
local HackingSCIIConfig = LTConfig.HackingSCIIConfig
local EffectConfig = LTConfig.EffectConfig
local DataSet = require("LX6/DataBind/DataSet")
local Formula_cs = require("LuaGen/AutoGen/Formula_cs")
local UnitModelManager = LX6.Units.UnitModelManager
local HackingConfig = LTConfig.HackingConfig
local CollectionSubQuestConfig = LTConfig.CollectionSubQuestConfig
local CollectionQuestConfig = LTConfig.CollectionQuestConfig
local TaskConfig = LTConfig.TaskConfig
local TaskEventConfig = LTConfig.TaskEventConfig
local TaskTitleConfig = LTConfig.TaskTitleConfig
local LayerConstants = LX6.Constants.LayerConstants
local CullingDisableReason = LX6.Units.CullingDisableReason
local M = gHackManager or {}
M.npcToolTipId = {}
M.npcDeepBugId = {}
M.npcDialogId = {}
M.npcQuestionId = {}
M.npcHasAction = {}
M.npcHasActionHasClicked = {}
M.npcHackThinkList = {}
M.controlNpcId = nil
M.enemyToolTipId = {}
M.enemyDeepBugId = {}
M.enemyDialogId = {}
M.enemyQuestionId = {}
M.npcEyeEffectList = {}
M.curDangerDataSet = {}
M.ENTITY_TYPE_ENEMY = 999
M.ENTITY_TYPE_MONITOR = 998
M.ENTITY_TYPE_SCII = 997
M.ENTITY_TYPE_FEISUO = 996
M.ENTITY_TYPE_PAOKU = 995
M.ENTITY_TYPE_ZIPLINE = 994
M.ENTITY_SINGLE_ACTION = 993
M.ENTITY_TYPE_SCENEGAMEOBJECT = 992
M.INTERACTION_DEFAULT = {
	CLOSE = -1,
	NONE = -999
}
M.baseInteraction = {}
M.lastHackEntityInfo = {
	Angle = -1,
	Pid = -1,
	Type = -1,
	Id = -1,
	canInteraction = false
}
M.ToolTipType = {
	Item = 5,
	Unknown = 3,
	Enemy = 1,
	Npc = 0,
	FengduNpc = 6,
	RandomNpc = 2
}
M.AngleToScale = {
	[45.0] = 0.5,
	[60.0] = 0.7,
	[30.0] = 0.32,
	[180.0] = 999,
	[80.0] = 1,
	[90.0] = 1.2
}
M.RandomNpcToolTips = {}
M.npcHackThinkList = {}
M.randomTooltipCfg = {}
M.InterestLayer = {
	ALL = -1,
	Monitor = 4,
	Enemy = 2,
	Npc = 1,
	Paoku = 16,
	SCII = 8,
	None = 0
}
M.CurInterestLayer = -1
M.npcHackThinkList = {}
M.blockCheckEntity = {}
M.hackEffectList = {}
M.canSeeHackEffectNpc = {}
M.HaiRuActionId = {
	STEAL_RANDOM = 118,
	STEAL_VOICE = 115,
	BUY_HOLOGRAM = 110,
	STEAL_MESSAGE = 114,
	REST = 109,
	FOLLOW = 104,
	BUY_YANHUA = 111,
	STEAL_ITEM = 113,
	CONTROL = 105
}
M.HaiRuActionTaskType = {
	TRANSFORM_PLAY_ACTION = 4,
	CHANGE_NAME = 1,
	CHANGE_IDENTITY = 2,
	CHANGE_IDEA = 3
}
M.HairuBtnType = {
	Monitor = 5,
	SingleHairu = 8,
	Close = -1,
	Hairu = 2,
	ZipLine = 6,
	Paoku = 3,
	SCII = 7,
	Feisuo = 1,
	None = 0
}
M.todayStolenNpcList = {}
M.HackingInteractionInfo = DataSet.New({
	btnInteractionEntityId = -1,
	btnText = "",
	btnType = 0,
	btnInteractionId = -1,
	btnCanActive = true,
	btnIcon = 0
})
M.VirtualCmr = {
	ActivePriority = 0,
	Pos = Vector3.zero,
	Dir = Vector3.zero,
	Except = {}
}
M.StartHackingCountDown = {}
M.LONGPRESSTIME = 1
M.DebugId = 0
M.itemDir = Vector3.New(0, 0, 0)
M.HackDis = -1
M.hackEffectUUIDList = {}
M.waitStopEffectList = {}
M.waitStopHackList = {}
M.lockEffectList = {}
M.isCanShowHackBtn = true
M.isHackBtnShow = false
M.MonitorHackSetting = {
	isInTimeline = false,
	except = {
		[M.InterestLayer.Monitor] = -1
	}
}
M.dangerEffectUnitPid1 = 0
M.dangerEffectUnitPid2 = 0
M.dangerEffectLastState = 0
M.RaycastAccurateHitTarget = nil
M.RaycastTargetLayer = LayerConstants.AllWithoutPlayer
M.delayScanTimers = {}
M.HackerSpiritInfo = {}
M.hackEntityInfo = {
	Angle = -1,
	Pid = 0,
	Type = -1,
	Id = 0,
	canInteraction = false,
	interactionType = -1
}
local eventHandler = {
	[gEventConstants.SCII_INFO_REFRESH] = function (eventId, data)
		local typeName = data.typeName
		local key = data.key
		local interactionId = data.interactionId

		if M.hackEntityInfo.Id == typeName and M.hackEntityInfo.Pid == key then
			M.HackingInteractionInfo:RefreshData({
				btnInteractionEntityId = M.hackEntityInfo.Pid,
				btnType = M.HackingInteractionInfo.btnType,
				btnInteractionId = interactionId
			})
		end
	end,
	[gEventConstants.AFTER_SWITCH_SCENE] = function (eventId, switchType)
		if switchType ~= gSwitchSceneType.Reconnect then
			return
		end

		M.isHackBtnShow = false

		M:SetShowHackBtn(true)
	end,
	[gEventConstants.STEALTH_DEBUG] = function (eventId, data)
		if not data or not data[0] or data[1] == nil then
			return
		end

		if type(data[0]) ~= "number" then
			return
		end

		if data[0] > 4 then
			M.DebugId = tonumber(data[0])
		end
	end,
	[gEventConstants.SHOW_ENEMY_DANGER] = function (eventId, data)
		if not data or data[0] == nil then
			return
		end

		if type(data[0]) == "boolean" then
			M.showEnemyDangerNum = data[0]
		end
	end,
	[gEventConstants.HACK_STEAL_RESULT] = function (eventId, data)
		return
	end,
	[gEventConstants.DISABLE_HACK_NPC] = function (eventId, data)
		if M.MonitorHackSetting.except == nil then
			M.MonitorHackSetting.except = {}
		end

		if M.MonitorHackSetting.except[M.InterestLayer.Npc] == nil then
			M.MonitorHackSetting.except[M.InterestLayer.Npc] = {}
		end

		local npcId = tonumber(data)

		if not table.contains(M.MonitorHackSetting.except[M.InterestLayer.Npc], npcId) then
			table.insert(M.MonitorHackSetting.except[M.InterestLayer.Npc], npcId)
		end
	end,
	[gEventConstants.ENABLE_HACK_NPC] = function (eventId, data)
		if M.MonitorHackSetting.except == nil then
			M.MonitorHackSetting.except = {}
		end

		if M.MonitorHackSetting.except[M.InterestLayer.Npc] == nil then
			M.MonitorHackSetting.except[M.InterestLayer.Npc] = {}
		end

		local npcId = tonumber(data)

		table.removeEx(M.MonitorHackSetting.except[M.InterestLayer.Npc], npcId)
	end,
	[gEventConstants.DISABLE_SELF_CLOSE_MONITOR] = function ()
		M.MonitorHackSetting.isInTimeline = true
	end,
	[gEventConstants.ENABLE_SELF_CLOSE_MONITOR] = function ()
		M.MonitorHackSetting.isInTimeline = false
	end,
	[gEventConstants.TIMELINE_END] = function ()
		M.MonitorHackSetting = {
			isInTimeline = false,
			except = {
				[M.InterestLayer.Monitor] = -1
			}
		}
	end
}
local defaultFilter = {
	[M.InterestLayer.Enemy] = function (unit)
		return
	end
}

function M:OnInit()
	for k, v in pairs(eventHandler) do
		gMessageManager:AddMessageListener(k, v)
	end
end

function M:GetPosScanDelay(pos, minDis)
	local dis = nil

	if minDis then
		dis = minDis
	else
		dis = Vector3.Distance(gCS.MyPlayerManager.PlayerUnit.LocalPosition, pos)
	end

	return dis / GameConfig.ScanSpeed
end

function M:TryRefreshGadgetScan(entityId, rootGo)
	local idKey = "slot_" .. ulong.tostring(entityId)

	if not self.hackEffectUUIDList[idKey] then
		return
	end

	gCS.EffectMgr:RefreshRenderMaterialEffect(idKey, rootGo)
end

M.collectionGpsDelay = {}
M.collectionEffectDelay = {}
M.collectionEffectUUID = {}
M.exterminateGpsDelay = {}
M.exterminateEffectDelay = {}
M.exterminateEffectUUID = {}
M.randomEventGpsDelay = {}
M.randomEventEffectDelay = {}
M.randomEventEffectUUID = {}

function M:ScanGameAndTask(scanTime)
	if gSceneDataMgr.CurrentRaidId ~= RaidConfig.WorldMap then
		return
	end

	local scanTime = scanTime or self:HackMapTime()
	local subQuestPosDict = gMapSubSystem_Collection:GetAllVisiblePoiISubQuestPos()
	local taskPosDict = gMapSubSystem_Task:GetHackableUnacceptGpsInfos()

	for id, pos in pairs(subQuestPosDict) do
		local cfg = CollectionSubQuestConfig.GetConfig(id)
		local QuestCfg = CollectionQuestConfig.GetConfig(cfg.QuestCategory)

		if self:SubQuestIsScanUseful(cfg, QuestCfg) then
			local pointInfo = {
				id = id,
				pos = pos,
				icon = QuestCfg.SQuestIcon
			}

			self:ScanPoint(id, pointInfo, scanTime)
		end
	end

	for id, pos in pairs(taskPosDict) do
		local cfg = TaskEventConfig.GetConfig(id)

		if cfg then
			if not cfg.StartTask then
				-- Nothing
			else
				local taskCfg = TaskConfig.GetConfig(cfg.StartTask)

				if not taskCfg then
					-- Nothing
				else
					local titleCfg = TaskTitleConfig.GetConfig(taskCfg.Title)

					if self:TaskIsScanUseful(id) then
						local pointInfo = {
							id = id,
							pos = pos,
							icon = titleCfg.SQuestIcon
						}

						self:ScanPoint(id, pointInfo, scanTime)
					end
				end
			end
		end
	end
end

function M:ScanPoint(id, pointInfo, scanTime)
	if self:IsInScanIconDis(pointInfo.pos) then
		if self.collectionGpsDelay[id] then
			gLuaTimeMgrUtils.CancelUnitDelay(self.collectionGpsDelay[id])

			self.collectionGpsDelay[id] = nil
		else
			self:AddOrRemoveGpsByCollection(true, pointInfo)
		end

		self.collectionGpsDelay[id] = gLuaTimeMgrUtils.Delay(function ()
			self:AddOrRemoveGpsByCollection(false, pointInfo)

			self.collectionGpsDelay[id] = nil
		end, scanTime, nil, nil, true)
	elseif self.collectionGpsDelay[id] then
		gLuaTimeMgrUtils.CancelUnitDelay(self.collectionGpsDelay[id])

		self.collectionGpsDelay[id] = nil

		self:AddOrRemoveGpsByCollection(false, pointInfo)
	end

	if self:IsInScanBeamDis(pointInfo.pos) then
		if self.collectionEffectDelay[id] then
			gLuaTimeMgrUtils.CancelUnitDelay(self.collectionEffectDelay[id])

			self.collectionEffectDelay[id] = nil
		else
			local effectId = gTaskUtils.GetTaskEffectId(pointInfo.id)
			self.collectionEffectUUID[id] = gCS.EffectMgr:PlayEffects(effectId, pointInfo.pos)
		end

		self.collectionEffectDelay[id] = gLuaTimeMgrUtils.Delay(function ()
			gCS.EffectMgr:StopEffectAndSetCacheByUUID(self.collectionEffectUUID[id])

			self.collectionEffectDelay[id] = nil
		end, scanTime, nil, nil, true)
	elseif self.collectionEffectDelay[id] then
		gLuaTimeMgrUtils.CancelUnitDelay(self.collectionEffectDelay[id])

		self.collectionEffectDelay[id] = nil

		gCS.EffectMgr:StopEffectAndSetCacheByUUID(self.collectionEffectUUID[id])
	end
end

function M:TaskIsScanUseful(id)
	if self:TaskIdIsTraced(id) then
		return false
	end

	return true
end

function M:SubQuestIsScanUseful(subQuestCfg, questCfg)
	if self:CollectionIdIsTraced(subQuestCfg.Id) then
		return false
	end

	if questCfg.PoiLevel == 2 or questCfg.PoiLevel == 3 then
		return false
	end

	if #subQuestCfg.Coordinate ~= 3 then
		return false
	end

	if questCfg.Id == 8 or questCfg.Id == 29 or questCfg.Id == 30 then
		return false
	end

	return true
end

function M:UseNewScan()
	return L50.L50App.Scene.ScanMgr.useNewScan
end

function M:ScanExterminateTask(time)
	local scanTime = time or self:HackMapTime()

	for id, v in pairs(gTriggerEnemyMgr.activeList) do
		local dis = gTriggerEnemyMgr:GetDis(id)
		local pos = gTriggerEnemyMgr:GetGroupPos(id)
		local pointInfo = {
			icon = 28001084,
			id = id,
			pos = pos
		}

		if dis <= self:HackMapDis2() then
			if self.exterminateGpsDelay[id] then
				gLuaTimeMgrUtils.CancelUnitDelay(self.exterminateGpsDelay[id])

				self.exterminateGpsDelay[id] = nil
			else
				self:AddOrRemoveGpsByExterminate(true, pointInfo)
			end

			self.exterminateGpsDelay[id] = gLuaTimeMgrUtils.Delay(function ()
				self:AddOrRemoveGpsByExterminate(false, pointInfo)

				self.exterminateGpsDelay[id] = nil
			end, scanTime, nil, nil, true)
		elseif self.exterminateGpsDelay[id] then
			gLuaTimeMgrUtils.CancelUnitDelay(self.exterminateGpsDelay[id])

			self.exterminateGpsDelay[id] = nil

			self:AddOrRemoveGpsByExterminate(false, pointInfo)
		end

		if self:HackMapDis1() <= dis and dis <= self:HackMapDis2() then
			if self.exterminateEffectDelay[id] then
				gLuaTimeMgrUtils.CancelUnitDelay(self.exterminateEffectDelay[id])

				self.exterminateEffectDelay[id] = nil
			else
				self.exterminateEffectUUID[id] = gCS.EffectMgr:PlayEffects(53610387, pos)
			end

			self.exterminateEffectDelay[id] = gLuaTimeMgrUtils.Delay(function ()
				gCS.EffectMgr:StopEffectAndSetCacheByUUID(self.exterminateEffectUUID[id])

				self.exterminateEffectDelay[id] = nil
			end, scanTime, nil, nil, true)
		elseif self.exterminateEffectDelay[id] then
			gLuaTimeMgrUtils.CancelUnitDelay(self.exterminateEffectDelay[id])

			self.exterminateEffectDelay[id] = nil

			gCS.EffectMgr:StopEffectAndSetCacheByUUID(self.exterminateEffectUUID[id])
		end
	end
end

function M:AddOrRemoveGpsByExterminateCSharp(isAdd, id, pos, icon)
	self:AddOrRemoveGpsByExterminate(isAdd, {
		id = id,
		pos = pos,
		icon = icon
	})
end

function M:AddOrRemoveGpsByExterminate(isAdd, info)
	if not isAdd then
		gGpsManager:RemoveGPSById("ScanExterminate" .. info.id, gTaskGpsType.WeakGuide)

		return
	end

	local gpsData = {
		NotLimitOutViewPos = true,
		IsCurrentTarget = false,
		HideInMap = true,
		InstanceId = "ScanExterminate" .. info.id,
		GpsType = gTaskGpsType.WeakGuide,
		TargetPos = info.pos,
		RaidId = RaidConfig.WorldMap,
		SIconId = info.icon
	}

	gGpsManager:AddGPS(gpsData)
end

function M:ScanRandomEvent(time)
	local scanTime = time or self:HackMapTime()

	for id, info in pairs(gMapSubSystem_RangeEvent.rangeEvents) do
		if info and info.centerPos then
			local dis = Vector3.Distance(gCS.MyPlayerManager.PlayerUnit.LocalPosition, info.centerPos)

			if dis <= self:HackMapDis2() then
				if self.randomEventGpsDelay[id] then
					gLuaTimeMgrUtils.CancelUnitDelay(self.randomEventGpsDelay[id])

					self.randomEventGpsDelay[id] = nil
				else
					self:AddOrRemoveGpsByRandomEvent(true, info)
				end

				self.randomEventGpsDelay[id] = gLuaTimeMgrUtils.Delay(function ()
					self:AddOrRemoveGpsByRandomEvent(false, info)

					self.randomEventGpsDelay[id] = nil
				end, scanTime, nil, nil, true)
			elseif self.randomEventGpsDelay[id] then
				gLuaTimeMgrUtils.CancelUnitDelay(self.randomEventGpsDelay[id])

				self.randomEventGpsDelay[id] = nil

				self:AddOrRemoveGpsByRandomEvent(false, info)
			end

			if info.Radius <= dis and dis <= self:HackMapDis2() then
				if self.randomEventEffectDelay[id] then
					gLuaTimeMgrUtils.CancelUnitDelay(self.randomEventEffectDelay[id])

					self.randomEventEffectDelay[id] = nil
				else
					self.randomEventEffectUUID[id] = gCS.EffectMgr:PlayEffects(53610387, info.centerPos)
				end

				self.randomEventEffectDelay[id] = gLuaTimeMgrUtils.Delay(function ()
					gCS.EffectMgr:StopEffectAndSetCacheByUUID(self.randomEventEffectUUID[id])

					self.randomEventEffectDelay[id] = nil
				end, scanTime, nil, nil, true)
			elseif self.randomEventEffectDelay[id] then
				gLuaTimeMgrUtils.CancelUnitDelay(self.randomEventEffectDelay[id])

				self.randomEventEffectDelay[id] = nil

				gCS.EffectMgr:StopEffectAndSetCacheByUUID(self.randomEventEffectUUID[id])
			end
		end
	end
end

function M:AddOrRemoveGpsByRandomEventCSharp(isAdd, eventId, pos)
	self:AddOrRemoveGpsByRandomEvent(isAdd, {
		eventId = eventId,
		centerPos = pos
	})
end

function M:AddOrRemoveGpsByRandomEvent(isAdd, info)
	if not isAdd then
		gGpsManager:RemoveGPSById("ScanRandomEvent" .. info.eventId, gTaskGpsType.WeakGuide)

		return
	end

	local eventCfg = LTConfig.ScheduleScheduleEventListConfig.GetConfig(info.eventId)
	local icon = 0

	if eventCfg then
		local cfg = LTConfig.ScheduleScheduleCampConfig.GetConfig(eventCfg.Scheduleid)

		if cfg then
			icon = cfg.SMapIcon
		end
	end

	local gpsData = {
		NotLimitOutViewPos = true,
		IsCurrentTarget = false,
		HideInMap = true,
		InstanceId = "ScanRandomEvent" .. info.eventId,
		GpsType = gTaskGpsType.WeakGuide,
		TargetPos = info.centerPos,
		RaidId = RaidConfig.WorldMap,
		SIconId = icon
	}

	gGpsManager:AddGPS(gpsData)
end

function M:TaskIdIsTraced(id)
	self.__taskIdToFind = id

	if not self.findTracingTaskPrediction then
		function self.findTracingTaskPrediction(element)
			return element.userdata and element.userdata.taskLineId == self.__taskIdToFind
		end
	end

	return gMapSystem.trace:FindTracingElement(self.findTracingTaskPrediction) ~= nil
end

function M:CollectionIdIsTraced(id)
	self.__collectionIdToFind = id

	if not self.findTracingCollectionPrediction then
		function self.findTracingCollectionPrediction(element)
			return element.id == self.__collectionIdToFind
		end
	end

	return gMapSystem.trace:FindTracingElement(self.findTracingCollectionPrediction) ~= nil
end

function M:IsInScanBeamDis(pos)
	local dis = self:GetHoriDis(pos, gCS.MyPlayerManager.PlayerUnit.LocalPosition)

	return self:HackMapDis1() <= dis and dis <= self:HackMapDis2()
end

function M:IsInScanIconDis(pos)
	local dis = self:GetHoriDis(pos, gCS.MyPlayerManager.PlayerUnit.LocalPosition)

	return dis <= self:HackMapDis2()
end

local deltPos = nil

function M:GetHoriDis(pos1, pos2)
	deltPos = pos2 - pos1

	return Mathf.Sqrt(deltPos.x * deltPos.x + deltPos.z * deltPos.z)
end

function M:AddOrRemoveGpsByCollection(isAdd, info)
	if not isAdd then
		gGpsManager:RemoveGPSById("ScanCollection" .. info.id, gTaskGpsType.WeakGuide)

		return
	end

	local gpsData = {
		NotLimitOutViewPos = true,
		IsCurrentTarget = false,
		HideInMap = true,
		InstanceId = "ScanCollection" .. info.id,
		GpsType = gTaskGpsType.WeakGuide,
		TargetPos = info.pos,
		RaidId = RaidConfig.WorldMap,
		SIconId = info.icon
	}

	gGpsManager:AddGPS(gpsData)
end

function M:AddSimpleGPS(id, pos, raidId, sIconId)
	local gpsData = {
		InstanceId = "SimpleGPS" .. tostring(id),
		TargetPos = pos,
		GpsType = gTaskGpsType.SimpleGPS,
		RaidId = raidId,
		SIconId = sIconId
	}

	gGpsManager:AddGPS(gpsData)
end

function M:RemoveSimpleGPS(id)
	local InstanceId = "SimpleGPS" .. tostring(id)

	gGpsManager:RemoveGPSById(InstanceId, gTaskGpsType.SimpleGPS)
end

function M:AddHackItemName(type, name)
	self.hackItemName = self.hackItemName .. "\n" .. type .. "：" .. name
	self.hackItemNum = self.hackItemNum + 1
end

function M:GetScanDis(pid)
	local unit = gCS.SceneDataMgr.GetUnit(pid)
	local isNpc = unit.ClientData.Type == UX.Game.EntityType.Npc

	if not unit or not isNpc then
		return HackingConfig.ScanEnemyRadius
	end

	local info = self:GetTaskNpcInfoByPid(unit.Pid)

	if info and info.scanParam then
		return info.scanDis or HackingConfig.ScanEnemyRadius
	end

	return HackingConfig.ScanEnemyRadius
end

function M:GetTaskNpcInfoByPid(pid)
	if table.isNilOrEmpty(gTaskNodeManager.NowDoingTask) then
		return nil
	end

	return gCS.SpoonTaskMgr.Instance:GetTaskNpcInfoByPid(pid)
end

function M:GetUnitScanTime(pid)
	local unit = gCS.SceneDataMgr.GetUnit(pid)
	local isNpc = unit.ClientData.Type == UX.Game.EntityType.Npc

	if not unit or not isNpc then
		return HackingConfig.ScanEnemyTime
	end

	local info = self:GetTaskNpcInfoByPid(unit.Pid)

	if info and info.scanParam then
		return info.scanTime or HackingConfig.ScanEnemyTime
	end

	return HackingConfig.ScanEnemyTime
end

function M:GetGadgetScanTime(temp)
	if temp.useLocalScanTime then
		return temp.scanTime
	end

	return HackingConfig.ScanEnemyTime
end

function M:GetGadgetEffect(temp)
	if type(temp) == "table" and temp.ignoreOutLine then
		return nil
	end

	if temp.isHunE then
		return HackingConfig.ScanEffect[1]
	else
		return HackingConfig.ScanEffect[2]
	end
end

function M:HackMapDis1()
	return HackingConfig.ScanMapRadius1
end

function M:HackMapDis2()
	return HackingConfig.ScanMapRadius2
end

function M:HackMapTime()
	return HackingConfig.ScanMapTime
end

function M:OnNpcDead(pid)
	local key = "unit_" .. ulong.tostring(pid)

	if self.hackEffectUUIDList[key] then
		self.hackEffectUUIDList[key] = nil
	end

	if self.waitStopEffectList[key] then
		gLuaTimeMgrUtils.CancelUnitDelay(self.waitStopEffectList[key])

		self.waitStopEffectList[key] = nil
	end

	if self.delayScanTimers[pid] then
		gLuaTimeMgrUtils.CancelUnitDelay(self.delayScanTimers[pid])

		self.delayScanTimers[pid] = nil
	end
end

function M:RecordUnitScanState(unit)
	local key = "unit_" .. ulong.tostring(unit.pid)

	if self.waitStopHackList[key] ~= nil then
		gLuaTimeMgrUtils.CancelUnitDelay(self.waitStopHackList[key])
	end

	self.waitStopHackList[key] = gLuaTimeMgrUtils.Delay(function ()
		self.waitStopHackList[key] = nil
	end, self:GetUnitScanTime(unit.pid), nil, nil, true)
end

function M:AddLockEffectForUnit(enemy, unit, anotherUnit, dangerValue)
	self:DoAddLockEffectForUnit(enemy, unit, dangerValue)
	self:DoAddLockEffectForUnit(enemy, anotherUnit, dangerValue)
end

function M:DoAddLockEffectForUnit(unit1, unit2, dangerValue)
	if not unit1 or not unit2 then
		return
	end

	local lockeffect = dangerValue >= 100 and 53700206 or 53700207

	if not self:CheckHasEffect(unit1.Pid, unit2.Pid) then
		local lockEffectInfo = {
			needRemove = false,
			UUID = gCS.EffectMgr:PlayLinkedEffect(unit1.Pid, lockeffect, unit2.Pid, self:GetUnitScanTime(), nil, nil),
			unit1 = unit1,
			unit2 = unit2
		}

		table.insert(self.lockEffectList, lockEffectInfo)
		self:AddDelayDestroyAction(unit1, lockEffectInfo.UUID)
		self:AddDelayDestroyAction(unit2, lockEffectInfo.UUID)
	end
end

function M:CheckHasEffect(pid1, pid2)
	for i = #self.lockEffectList, 1, -1 do
		local v = self.lockEffectList[i]

		if v.needRemove and v.unit1.Pid == pid1 and v.unit2.Pid == pid2 then
			v.needRemove = false

			return true
		end
	end
end

function M:AddDelayDestroyAction(unit, uuid)
	if not unit then
		return
	end

	gLuaTimeMgrUtils.UnitDelay(unit.Pid, self:GetUnitScanTime(), function ()
		self:TryRemoveLockEffectByUUID(uuid)
	end, self:GetUnitScanTime(), nil, nil, nil, true)
end

function M:SetNeedRemove()
	for i = #self.lockEffectList, 1, -1 do
		local v = self.lockEffectList[i]
		v.needRemove = true
	end
end

function M:TryRemoveLockEffectByUUID(uuid)
	for i = #self.lockEffectList, 1, -1 do
		local v = self.lockEffectList[i]

		if v.UUID == uuid then
			gCS.EffectMgr:StopEffectAndSetCacheByUUID(v.UUID)
			table.remove(self.lockEffectList, i)

			return
		end
	end
end

function M:TryRemoveLockEffectByPid(pid)
	for i = #self.lockEffectList, 1, -1 do
		local v = self.lockEffectList[i]

		if v.unit1.Pid == pid or v.unit2.Pid == pid then
			gCS.EffectMgr:StopEffectAndSetCacheByUUID(v.UUID)
			table.remove(self.lockEffectList, i)
		end
	end
end

function M:TryRemoveLockEffectByFlag()
	for i = #self.lockEffectList, 1, -1 do
		local v = self.lockEffectList[i]

		if v.needRemove then
			gCS.EffectMgr:StopEffectAndSetCacheByUUID(v.UUID)
			table.remove(self.lockEffectList, i)
		end
	end
end

function M:TryRemoveLockEffect(destroyNow)
	for i = #self.lockEffectList, 1, -1 do
		local v = self.lockEffectList[i]

		if destroyNow then
			gCS.EffectMgr:StopEffectAndSetCacheByUUIDNow(v.UUID)
		else
			gCS.EffectMgr:StopEffectAndSetCacheByUUID(v.UUID)
		end

		table.remove(self.lockEffectList, i)
	end
end

function M:TryRemoveHackEffectForUnit(cs_unit, type)
	local key = "unit_" .. ulong.tostring(cs_unit.Pid)

	if self.waitStopEffectList[key] then
		gLuaTimeMgrUtils.CancelUnitDelay(self.waitStopEffectList[key])

		self.waitStopEffectList[key] = nil

		if self.hackEffectUUIDList[key] then
			gCS.EffectMgr:StopEffectAndSetCacheByUUID(self.hackEffectUUIDList[key])

			self.hackEffectUUIDList[key] = nil
		end
	end
end

function M:CancelHackUnitDelayTimer(unit)
	local key = "unit_" .. ulong.tostring(unit.pid)

	if self.waitStopEffectList[key] then
		gLuaTimeMgrUtils.CancelUnitDelay(self.waitStopEffectList[key])

		self.waitStopEffectList[key] = nil
	end
end

function M:IsScanAbleNpc(pid, spoonId)
	local unit = gCS.SceneDataMgr.GetUnit(pid)
	local isNpc = unit.ClientData.Type == UX.Game.EntityType.Npc

	if not isNpc then
		return false
	end

	local info = self:GetTaskNpcInfoByPid(pid)

	if info and info.scanParam then
		return true
	end

	local cfg = LTConfig.AgentConfig.GetConfig(unit.TemplateId)
	local interactCfg = gInteractionManager:GetAgentInteractConfig(cfg)

	if not cfg or not interactCfg then
		return false
	end

	local labels = interactCfg.InteractionTexts

	if labels and #labels ~= 0 then
		return true
	end

	return false
end

function M:GetUnitScanEffect(pid)
	local unit = gCS.SceneDataMgr.GetUnit(pid)
	local isEnemy = unit.ClientData.Type == UX.Game.EntityType.Enemy

	if isEnemy then
		return HackingConfig.ScanEffect[1]
	end

	local info = self:GetTaskNpcInfoByPid(unit.Pid)

	if info and info.isHunE then
		return HackingConfig.ScanEffect[1]
	else
		return HackingConfig.ScanEffect[2]
	end
end

function M:GetScanSignal(pid)
	local info = self:GetTaskNpcInfoByPid(pid)

	if info and info.scanParam then
		return info.scanSignal
	end

	return nil
end

function M:AddHackingHintEffectToNpc(pid)
	self.canSeeHackEffectNpc[pid] = Time.time
end

function M:GetEnemyDangerValue(pid, anotherPid)
	if pid ~= nil and anotherPid ~= nil then
		return self:ForeachDangerEnemy(pid, anotherPid)
	else
		return self:ForeachDangerEnemy(pid)
	end
end

function M:ForeachDangerEnemy(pid, anotherPid, needAddLockEffect)
	local enemy = gCS.SceneDataMgr.GetUnit(pid)
	local anotherEnmey = gCS.SceneDataMgr.GetUnit(anotherPid)
	local maxValue = 0
	local curValue = 0

	if enemy == nil then
		return 0
	end

	local units = gCS.SceneDataMgr.UnitsManager.GetUnits():ToTable()

	for _, unit in ipairs(units) do
		if anotherPid and ulong.equals(anotherPid, unit.Pid) or ulong.equals(pid, unit.Pid) then
			return
		end

		if not unit.canUseRes or unit.isDead then
			return
		end

		curValue = 0
		local curValue2 = 0
		local config = LTConfig.AgentConfig.GetConfig(unit.TemplateId)
		local isEnemy = unit.ClientData.Type == UX.Game.EntityType.Enemy

		if isEnemy and unit.ClientData.Camp ~= 1 and unit.LogicalVisible and config and config.DetectId and config.DetectId > 0 then
			local detectId = config.DetectId
			local enemyPosition = unit.LocalPosition
			local direction = unit.FacingDirection
			local eventPosition = enemy.Position
			local addValue = Formula_cs:CalcVisualDetectEventAddValue(detectId, enemyPosition, direction, eventPosition)
			addValue = addValue > 0 and addValue or -99999999
			curValue = addValue + (gStealthManager.perceivedValueList[unit.Pid] or 0)

			if anotherEnmey then
				local anotherEventPosition = anotherEnmey.LocalPosition
				addValue = Formula_cs:CalcVisualDetectEventAddValue(detectId, enemyPosition, direction, anotherEventPosition)
				addValue = addValue > 0 and addValue or -99999999
				curValue2 = addValue + (gStealthManager.perceivedValueList[unit.Pid] or 0)
				curValue = (curValue >= 100 or curValue2 >= 100) and 100 or (curValue + curValue2) / 2
			end

			curValue = Mathf.Clamp(curValue, 0, 100)

			if maxValue < curValue then
				maxValue = curValue
			end

			if curValue > 50 and needAddLockEffect then
				self:AddLockEffectForUnit(unit, enemy, anotherEnmey, curValue)
			end
		end
	end

	return maxValue
end

function M:TryForeachDangerEnemy(unit, canAss)
	local pid = unit.pid

	if gCS.BattleManager.PreCheckCanAss(unit.cs_unit) then
		local dis = gUtils:GetDistance(gCS.MyPlayerManager.PlayerUnit.LocalPosition, unit.position)
		local count, enemyId = nil

		if dis <= GameConfig.FeiSuoCheckDistance then
			count, enemyId = gCS.BattleManager.CheckEnemyCountByDis(unit.cs_unit, 3, enemyId)

			if count == 1 then
				self:AddFocusDangerEffect(self.dangerEffectUnitPid1, self.dangerEffectUnitPid2)
			else
				self:AddFocusDangerEffect(self.dangerEffectUnitPid1, self.dangerEffectUnitPid2)
			end
		end

		if pid == gFeisuoAssassMgr.InteractionInfo.LockEnemyId and canAss then
			if count == 1 then
				if M:EnemyShowDangerAble(pid) and M:EnemyShowDangerAble(enemyId) then
					M:ForeachDangerEnemy(pid, enemyId, true)
				end
			elseif M:EnemyShowDangerAble(pid) then
				M:ForeachDangerEnemy(pid, nil, true)
			end
		end
	end
end

function M:AddFocusDangerEffect(pid, anotherPid)
	L50.L50App.Scene.ScanMgr:AddFocusDangerEffect(pid or 0, anotherPid or 0)
end

function M:AddDangerEffect(unit, anotherUnit, effectId, force)
	local flag1 = unit and (not self.dangerEffectUnitPid1 or unit.pid ~= self.dangerEffectUnitPid1) or not unit and self.dangerEffectUnitPid1 ~= 0
	local flag2 = anotherUnit and (not self.dangerEffectUnitPid2 or anotherUnit.pid ~= self.dangerEffectUnitPid2) or not anotherUnit and self.dangerEffectUnitPid2 ~= 0

	if force or flag1 or flag2 then
		self:RemoveAllDangerEffect()

		if unit then
			self:TryRemoveHackEffectForUnit(unit.cs_unit)

			unit.dangerMaterialEffectUUID = gCS.EffectMgr:PlayEffectsForUnit(unit.cs_unit, effectId)
			self.dangerEffectUnitPid1 = unit.pid
		end

		if anotherUnit then
			self:TryRemoveHackEffectForUnit(anotherUnit.cs_unit)

			anotherUnit.dangerMaterialEffectUUID = gCS.EffectMgr:PlayEffectsForUnit(anotherUnit.cs_unit, effectId)
			self.dangerEffectUnitPid2 = anotherUnit.pid
		end
	end
end

function M:RemoveAllDangerEffect()
	return
end

function M:EnemyShowDangerAble(pid)
	local dataSet = gDataSetManager:GetUnitData(pid)

	if not dataSet then
		return false
	end

	local unit = gCS.MyPlayerManager.GetUnit(pid)

	if self.delayScanTimers[pid] or self:UnitIsScaning(unit) then
		return true
	end

	if L50.L50App.Scene.ScanMgr:CheckUnitIsScaning(pid) then
		return true
	end

	return false
end

function M:ClearDangerEffectData()
	L50.L50App.Scene.ScanMgr:ClearDangerEffectData()
end

function M:SetShowHackBtn(isCanShow)
	self.isCanShowHackBtn = isCanShow

	if isCanShow then
		self.HandleInteractionBtn()
	end
end

function M.HandleInteractionBtn()
	local viewInfo = M.hackEntityInfo
	local btnType = M.HackingInteractionInfo.btnType
	local btnIcon, btnText = nil
	local alpha = 1
	local interactionHide = 0
	local goTrans = nil

	if btnType == M.HairuBtnType.Close then
		local hackingCfg = HackingConfig.GetConfig(HackingConfig.Close)
		btnText = hackingCfg and hackingCfg.InteractionLabel or ""
		btnIcon = hackingCfg and hackingCfg.InteractionSprite or GameConfig.DefaultHackBtn
		alpha = 1
	elseif btnType == M.HairuBtnType.Hairu then
		if viewInfo then
			local hackingCfg = HackingConfig.GetConfig(viewInfo.interactionType)
			btnText = hackingCfg and hackingCfg.InteractionLabel or ""
			btnIcon = hackingCfg and hackingCfg.InteractionSprite or GameConfig.DefaultHackBtn
			alpha = viewInfo.canInteraction and 1 or 0.5
		end
	elseif btnType == M.HairuBtnType.Monitor then
		local hackingCfg = HackingConfig.GetConfig(HackingConfig.Monitor)
		local TextCfg = LTConfig.TextCommonTextConfig.GetConfig(74000731)
		local entity = gStealthManager:GetMonitor(viewInfo.Pid)

		if entity ~= nil and entity:IsPointToPosGame() then
			hackingCfg = HackingConfig.GetConfig(HackingConfig.JiGuang)
			btnText = TextCfg and TextCfg.Text or ""
			btnIcon = hackingCfg and hackingCfg.InteractionSprite or GameConfig.DefaultHackBtn
		else
			btnText = TextCfg and TextCfg.Text or ""
			btnIcon = hackingCfg and hackingCfg.InteractionSprite or GameConfig.DefaultHackBtn
		end

		goTrans = entity.go.transform
	elseif btnType == M.HairuBtnType.SCII then
		local hackingCfg = HackingConfig.GetConfig(HackingConfig.SCII)
		local key = viewInfo.Pid
		local groupName = viewInfo.Id
		local item = gStealthManager:GetItemByGroupAndKey(groupName, key)
		goTrans = item.go.transform
		local interactionId = 0

		if item then
			interactionId = item:GetInteractionId()
		end

		if interactionId and interactionId ~= 0 then
			hackingCfg = HackingSCIIConfig.GetConfig(interactionId)
			interactionHide = hackingCfg and hackingCfg.InteractionHide or 0
		end

		btnText = hackingCfg and hackingCfg.InteractionLabel or ""
		btnIcon = hackingCfg and hackingCfg.InteractionSprite or GameConfig.DefaultHackBtn
	elseif btnType == M.HairuBtnType.None then
		btnText = ""
		btnIcon = 0
		alpha = 0
	end

	if btnType ~= M.HairuBtnType.None and btnType ~= M.HairuBtnType.Close then
		if M.isHackBtnShow == false then
			gInteractionManager:OnFarDistanceInteractionEnter("hackFarDis_" .. tostring(viewInfo.Id) .. "_" .. ulong.tostring(viewInfo.Pid), {
				BtnTargetTrans = goTrans,
				UIIconId = btnIcon,
				Description = btnText,
				Alpha = alpha,
				InteractionHide = interactionHide
			})

			M.isHackBtnShow = true
		end
	else
		M.isHackBtnShow = false
	end
end

function M:SyncSpiritHackerJobInfo(spiritId, hackerJobInfo)
	print("SyncSpiritHackerJobInfo", spiritId, hackerJobInfo)

	if table.isNilOrEmpty(self.HackerSpiritInfo) then
		self.HackerSpiritInfo = {}
	end

	self.HackerSpiritInfo[spiritId] = hackerJobInfo
	self.hasHackerJobRedDot = false
	self.hasHackerJobRedDotCount = 0

	if hackerJobInfo and hackerJobInfo.PostInfos then
		for i, info in pairs(hackerJobInfo.PostInfos) do
			if not info.HaveRead then
				self.hasHackerJobRedDotCount = self.hasHackerJobRedDotCount + 1
				self.hasHackerJobRedDot = true
			end
		end
	end

	gMessageManager:SendMessage(gEventConstants.ON_HACKER_APP_REDPOINT_CHANGE)
end

function M:ReadHackerJobRedDot(id)
	local cardId = gCS.MyPlayerManager.PlayerUnit.ClientData.cardId
	local SpiritInfo = self.HackerSpiritInfo[cardId]

	if SpiritInfo then
		for i, info in pairs(SpiritInfo.PostInfos) do
			if info.Id == id then
				info.HaveRead = true
				self.hasHackerJobRedDotCount = self.hasHackerJobRedDotCount - 1

				break
			end
		end
	end

	if self.hasHackerJobRedDotCount <= 0 then
		self.hasHackerJobRedDot = false

		gMessageManager:SendMessage(gEventConstants.ON_HACKER_APP_REDPOINT_CHANGE)
	end
end

gHackManager = M
