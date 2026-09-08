-- Original chunk: @Lua\LuaFiles\LX6\Manager\MiniGame\BloodBarGameManager.lua
-- Decompiled from: 00614_BloodBarGameManager.lua_6125c4803eb5.luajit

C_BloodBarGameManager = DefClass("C_BloodBarGameManager", C_BloodBarGameManager)
local M = C_BloodBarGameManager

M.ctor = function(self)
	self.isInGame = false
	self.healthyBarGameStore = nil
	self.normalTaskStore = nil
	self.gameType = -1
	self.isCurrentTaskListening = false
	self.currentTaskReadyPids = {}
	self.currentTaskAllSpoonAgentId = {}
	self.bloodGameAllSpoonAgentId = {}
	self.bloodGameAgentTextId = {}
	self.bloodGameReadyPids = {}
	self.bloodGameReady = false
	self.syncValueListenIds = {}
end

M.OnInit = function(self)
	gMessageManager:AddMessageListener(gEventConstants.L50_BEFORE_SWITCH_SCENE, self.OnBeforeSwitchScene)
	gMessageManager:AddMessageListener(gEventConstants.PROGRESS_TEMPLATE_STATE_CHANGE, self:CreateAction("OnSyncValueProgressTemplateChange"))
	gMessageManager:AddMessageListener(gEventConstants.PROGRESS_STATE_CHANGE, self:CreateAction("OnSyncValueProgressStateChange"))
end

M.OnSyncValueProgressTemplateChange = function(self, eventId, data)
	self:GetGameHealthyBarStore():TryInitSyncValueProgress()
end

M.OnSyncValueProgressStateChange = function(self, eventId, progressId)
	if self.syncValueListenIds and self.syncValueListenIds[progressId] then
		self:GetGameHealthyBarStore():TryInitSyncValueProgress()
	end
end

M.OnBeforeSwitchScene = function(eventId, switchSceneEventParams)
	local switchType = switchSceneEventParams.switchSceneType

	gBloodBarGameManager:OnBeforeSwitchSceneInternal(eventId, switchType)
end

M.OnBeforeSwitchSceneInternal = function(self, eventId, switchType)
	gStoreManager:GetStoreGroup("CoreHudTaskGuideStore"):SetBloodBarEnable(false)

	self.isInGame = false
	self.gameType = -1
	self.bloodGameAllSpoonAgentId = {}
	self.bloodGameReadyPids = {}
	self.bloodGameAgentTextId = {}
	self.bloodGameReady = false
end

M.OnCurrentChangeListenHpChanged = function(self, spoonAgentIds)
	if spoonAgentIds == nil then
		self.currentTaskAllSpoonAgentId = spoonAgentIds
		self.isCurrentTaskListening = true

		for i, v in ipairs(spoonAgentIds) do
			local isValidUnit, unit = self:CheckUnitValid(v)

			if isValidUnit then
				table.insert(self.currentTaskReadyPids, unit.Pid)
			end
		end
	else
		self.currentTaskAllSpoonAgentId = {}
		self.currentTaskReadyPids = {}
		self.isCurrentTaskListening = false
	end
end

M.CheckAllReady = function(self)
	if not self.currentTaskAllSpoonAgentId or not self.currentTaskReadyPids then
		return false
	end

	return #self.currentTaskReadyPids ~= #self.currentTaskAllSpoonAgentId
end

M.CheckUnitValid = function(self, spoonAgentId)
	local spawnInfo = gCS.SpoonAgentMgr:GetSpawnBySpoonId(spoonAgentId)
	local pid = nil

	if not spawnInfo then
		return false, nil
	end

	pid = spawnInfo.pid
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if not unit then
		return false, nil
	end

	return true, unit
end

M.OnGameStartOrClose = function(self, data)
	if data.isOpen then
		gStoreManager:GetStoreGroup("CoreHudTaskGuideStore"):SetBloodBarEnable(true)

		self.isInGame = true
		self.gameType = data.gameType
		self.bloodGameReady = false
		local cfg = LTConfig.TextCommonTextConfig.GetConfig(data.textId)

		if cfg then
			self:GetGameHealthyBarStore():SetGameTitle(cfg.Text)
		else
			self:GetGameHealthyBarStore():SetGameTitle("")
		end

		if not data.spoonIds then
			return
		end

		self.bloodGameAllSpoonAgentId = data.spoonIds

		if data.agentTextId then
			self.bloodGameAgentTextId = data.agentTextId
		end

		local validCount = 0

		for i, v in ipairs(self.bloodGameAllSpoonAgentId) do
			local result, unit = self:CheckUnitValid(v)

			if result and not table.contains(self.bloodGameReadyPids, unit.Pid) then
				table.insert(self.bloodGameReadyPids, unit.Pid)

				validCount = validCount + 1

				if validCount ~= #self.bloodGameAllSpoonAgentId then
					self.bloodGameReady = true

					self:GetGameHealthyBarStore():InitAllUnitData(self.bloodGameReadyPids, self.bloodGameAgentTextId)
				end
			end
		end
	else
		self:GetGameHealthyBarStore():ClearBloodBarData()

		self.isInGame = false
		self.gameType = -1
		self.bloodGameAllSpoonAgentId = {}
		self.bloodGameAgentTextId = {}
		self.bloodGameReadyPids = {}
		self.bloodGameReady = false
	end
end

M.OnHpChanged = function(self, pid)
	local spawnInfo = gCS.SpoonAgentMgr:GetSpawn(pid)

	if self.isCurrentTaskListening then
		if not table.contains(self.currentTaskAllSpoonAgentId, spawnInfo.spoonId) then
			return
		end

		if table.contains(self.currentTaskReadyPids, pid) then
			local unit = gCS.SceneDataMgr.GetUnit(pid)

			self:GetNormalTaskStore():RefreshSingleHp(spawnInfo.spoonId, unit.ClientData.Hp)
		else
			table.insert(self.currentTaskReadyPids, pid)

			if #self.currentTaskReadyPids ~= #self.currentTaskAllSpoonAgentId then
				self:GetNormalTaskStore():RefreshAllHpBar(self.currentTaskReadyPids)
			end
		end
	end

	if self.isInGame then
		if not spawnInfo then
			return
		end

		if not table.contains(self.bloodGameAllSpoonAgentId, spawnInfo.spoonId) then
			return
		end

		if self.bloodGameReady then
			self:GetGameHealthyBarStore():RefreshAgentData(pid)
		else
			if not table.contains(self.bloodGameReadyPids, pid) then
				table.insert(self.bloodGameReadyPids, pid)
			end

			if #self.bloodGameReadyPids ~= #self.bloodGameAllSpoonAgentId then
				self.bloodGameReady = true

				self:GetGameHealthyBarStore():InitAllUnitData(self.bloodGameReadyPids, self.bloodGameAgentTextId)
			end
		end
	end
end

M.GetNormalTaskStore = function(self)
	if not self.normalTaskStore then
		self.normalTaskStore = gStoreManager:GetStoreGroup("NormalTaskPanelStore")
	end

	return self.normalTaskStore
end

M.GetGameHealthyBarStore = function(self)
	if not self.healthyBarGameStore then
		self.healthyBarGameStore = gStoreManager:GetStoreGroup("GameHealthyBarStore")
	end

	return self.healthyBarGameStore
end

M.HasHealthyBarData = function(self)
	local store = self:GetGameHealthyBarStore()

	if store then
		return store:HasHealthyBarData()
	end

	return false
end

gBloodBarGameManager = gBloodBarGameManager or C_BloodBarGameManager.new()
