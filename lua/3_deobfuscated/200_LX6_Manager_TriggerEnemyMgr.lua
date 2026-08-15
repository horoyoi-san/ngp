local RefreshEnemy = LTConfig.RefreshEnemyConfig
local TaskTipsType = require("LX6/Manager/Task/TaskTipsType")
local M = {
	openSyncRemainGroup = false,
	exitEnemyGroupTime = 0,
	enterEnemyGroupTime = 0,
	EnemyGroupGpsName = "EnemyGroup",
	syncRemainEnemyGroupId = 0,
	RandomEventGpsName = "RandomEvent",
	activeList = {},
	groupEnemyList = {},
	mapList = {},
	battleTipList = {},
	lockEnemyGroupList = {},
	activeRandomList = {},
	lastEnterTipTime = {},
	showEnterTipAble = {},
	GetViewDis = function (self)
		return RefreshEnemy.RefreshTipRange
	end,
	GetEnterTipCD = function (self)
		return RefreshEnemy.TipCD
	end,
	CheckEnterTipAble = function (self, id)
		if self.showEnterTipAble[id] == false then
			return false
		end

		if not self.lastEnterTipTime[id] then
			self.showEnterTipAble[id] = false
			self.lastEnterTipTime[id] = gLogicTime.time

			return true
		end

		if self:GetEnterTipCD() < gLogicTime.time - self.lastEnterTipTime[id] then
			self.showEnterTipAble[id] = false
			self.lastEnterTipTime[id] = gLogicTime.time

			return true
		end

		return false
	end,
	OnBeforeSwitchScene = function (self, switchType)
		self.enterEnemyGroupTime = 0
		self.exitEnemyGroupTime = 0

		self:EnableSyncRemainEnemyCount(self.syncRemainEnemyGroupId, false, false, true)

		self.lockEnemyGroupList = {}

		if switchType == gSwitchSceneType.KickToLogin then
			self.activeList = {}
			self.groupEnemyList = {}
			self.activeRandomList = {}
		end
	end
}
local frameCount = 0

function M:OnUpdate()
	if not gSpoonMgr:GetRaidGraph() or not gCS.MyPlayerManager.PlayerUnitExists then
		return
	end

	frameCount = frameCount + 1

	if frameCount % 10 == 0 then
		frameCount = 0

		self:CheckGroups()
	end
end

function M:CheckGroups()
	for id, v in pairs(self.activeList) do
		if v then
			self:CheckGroup(id)
		end
	end
end

function M:ResetActiveList(list)
	self.activeList = {}
	self.mapList = {}

	for id, data in pairs(list) do
		if gSpoonMgr:GetRaidGraph():GetWildEnemyData(id) then
			self.activeList[id] = data.Time
			self.groupEnemyList[id] = data.EnemyInstanceIds

			self:CheckEnemyGroupId(id, self.groupEnemyList[id], true)
		end
	end
end

function M:AddActiveGroup(id, ids)
	self.activeList[id] = 0
	self.groupEnemyList[id] = ids

	self:CheckEnemyGroupId(id, self.groupEnemyList[id], true)
end

function M:RemoveActiveGroup(id, banned)
	self:CheckEnemyGroupId(id, self.groupEnemyList[id], false)

	self.groupEnemyList[id] = nil

	self:OnFinishGroup(id, banned)
	self:EnableSyncRemainEnemyCount(id, false, false, true)

	self.activeList[id] = nil
end

function M:CheckEnemyGroupId(groupId, ids, active)
	if ids == nil then
		return
	end
end

function M:GetGroupPos(id)
	local group = gSpoonMgr:GetRaidGraph():GetWildEnemyData(id)

	if not group then
		return Vector3.New(2000000, 2000000, 2000000)
	end

	return Vector3.NewT(group.pos:ToLuaTable())
end

function M:GetGroupType(id)
	return gSpoonMgr:GetRaidGraph():GetWildEnemyData(id).type
end

function M:OnEnterGroup(id, info)
	if not self.activeList[id] then
		return
	end

	if self:CheckEnterTipAble(id) then
		self.activeList[id] = self:CurTime()
	end

	self:AddEnemyIcon(id)
end

function M:OnExitGroup(id, info)
	self.showEnterTipAble[id] = true

	if not self.activeList[id] then
		return
	end

	self:RemoveEnemyIcon(id)
end

function M:OnEnterBattleGroup(id, info)
	self.battleTipList[id] = true

	if info.mapScale then
		gMapManager:SetMiniMapScale(info.mapScale, gMapScaleType.BattleEvent)
	end
end

function M:OnExitBattleGroup(id, info)
	if info.mapScale then
		gMapManager:RemoveMiniMapScaleType(gMapScaleType.BattleEvent)
	end

	self.battleTipList[id] = false
end

function M:EnableSyncRemainEnemyCount(groupId, enable, noSync, force)
	if enable then
		if self.syncRemainEnemyGroupId == 0 then
			self.syncRemainEnemyGroupId = groupId
			self.enterEnemyGroupTime = gLogicTime.time
			self.exitEnemyGroupTime = 0

			gMessageManager:SendMessage(gEventConstants.CAMP_REMAIN_ENEMY_GROUPID_CHANGE, self.syncRemainEnemyGroupId)

			if self.openSyncRemainGroup then
				gClientToGameSceneDelegate:AskTrackWildEnemyGroupInfo(groupId).Callback = function (err)
					return
				end
			end
		end
	elseif self.syncRemainEnemyGroupId > 0 and (force or self.syncRemainEnemyGroupId == groupId) then
		if self.exitEnemyGroupTime == 0 then
			self.exitEnemyGroupTime = gLogicTime.time
		end

		if force or not self.lockEnemyGroupList[groupId] then
			self.syncRemainEnemyGroupId = 0
			self.enterEnemyGroupTime = 0

			gMessageManager:SendMessage(gEventConstants.CAMP_REMAIN_ENEMY_GROUPID_CHANGE, self.syncRemainEnemyGroupId)

			if self.openSyncRemainGroup and not noSync then
				gClientToGameSceneDelegate:AskCancelTrackWildEnemyGroupInfo(groupId).Callback = function (err)
					return
				end
			end
		end
	end
end

function M:EnemyGroupSwitchLockState(groupId, lockTarget)
	if lockTarget then
		self.lockEnemyGroupList[groupId] = true
	elseif self.lockEnemyGroupList[groupId] then
		self.lockEnemyGroupList[groupId] = nil
		local dis = self:GetDis(groupId)
		local info = gSpoonMgr:GetRaidGraph():GetWildEnemyData(groupId)

		if info then
			local uiRadius = info.uiRadius and info.uiRadius > 0 and info.uiRadius or self.GetViewDis()

			if uiRadius < dis and self.syncRemainEnemyGroupId == groupId then
				self:EnableSyncRemainEnemyCount(groupId, false, false, false)
			end
		end
	end
end

function M:OnFinishGroup(id, banned)
	if not self.activeList[id] then
		return
	end

	if not banned then
		gNewPopupManager:PushPopup(LTConfig.PopupConfig.S_HUDTipsPanel, {
			Param = {
				IsOpenCamp = false,
				TipType = TaskTipsType.Camp,
				name = LTConfig.TextScriptTextConfig.GetConfig(89900054).Text
			}
		})
	end

	self:RemoveEnemyIcon(id)
end

function M:AddEnemyIcon(id)
	if not id or id == 0 then
		return
	end

	self.mapList[id] = true
end

function M:RemoveEnemyIcon(id)
	if not id or id == 0 then
		return
	end

	self.mapList[id] = nil
end

function M:AskFirstTrigger(id)
	gClientToGameSceneDelegate:AskCheckWildEnemyGroup(id)
end

function M:GetMapEnemyNearest()
	if not gSpoonMgr:GetRaidGraph() or not gSpoonMgr:GetRaidGraph().WildEnemyGroup then
		return nil
	end

	local minDis = math.huge
	local minId = nil
	local WildEnemyGroup = gSpoonMgr:GetRaidGraph().WildEnemyGroup:ToTable()

	for id, _ in pairs(WildEnemyGroup) do
		local dis = self:GetDis(id)

		if dis < minDis then
			minDis = dis
			minId = id
		end
	end

	return minId
end

local dis = nil

function M:CheckGroup(id)
	local info = gSpoonMgr:GetRaidGraph():GetWildEnemyData(id)

	if info then
		return
	end

	dis = self:GetDis(id)

	if dis <= self.GetViewDis() and not self.mapList[id] then
		self:OnEnterGroup(id, info)
	elseif self.GetViewDis() < dis and self.mapList[id] then
		self:OnExitGroup(id, info)
	end

	if dis <= info.battleRadius and not self.battleTipList[id] then
		self:OnEnterBattleGroup(id, info)
	elseif info.battleRadius < dis and self.battleTipList[id] then
		self:OnExitBattleGroup(id, info)
	end
end

function M:GetDis(id)
	return Vector3.Distance(gCS.MyPlayerManager.PlayerUnit.LocalPosition, self:GetGroupPos(id))
end

function M:CurTime()
	return gLuaDataManager.serverTime
end

function M:EnemyShowDangerAble(pid)
	local groupId = nil

	for id, list in pairs(self.groupEnemyList) do
		for i, v in pairs(list) do
			if v == pid then
				groupId = id

				break
			end
		end

		if groupId then
			break
		end
	end

	if not groupId then
		return true
	end

	local data = gSpoonMgr:GetRaidGraph():GetWildEnemyData(groupId)

	if not data then
		return true
	end

	if data.goHomeRadius == 0 then
		return true
	end

	local inDis = gUtils:GetDistanceWithXYZ(data.pos.x, data.pos.y, data.pos.z, gCS.MyPlayerManager.PlayerUnit.LocalPosition) < data.goHomeRadius

	return inDis
end

function M:OnEnterWildEnemyRoom(groupId)
	self:EnableSyncRemainEnemyCount(groupId, true, false, false)
end

function M:OnExitWildEnemyRoom(groupId)
	self.groupExtraTargetMap = nil
	self.groupMainTarget = nil

	self:EnableSyncRemainEnemyCount(groupId, false, false, false)
end

gTriggerEnemyMgr = M
