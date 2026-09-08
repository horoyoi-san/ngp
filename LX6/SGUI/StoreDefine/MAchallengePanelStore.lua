-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\MAchallengePanelStore.lua
-- Decompiled from: 01792_MAchallengePanelStore.lua_bd32f193891f.luajit

C_MAchallengePanelStore = DefClass("C_MAchallengePanelStore", C_MAchallengePanelStore, C_StoreGroup)
GroupName2Class.MAchallengePanelStore = C_MAchallengePanelStore
local M = C_MAchallengePanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
	self.levelCtrlEnum = {
		["I\\x9f\\x89\\x86S"] = 1,
		["G\\x83\\x83\\x82M"] = 0
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.levelCtrlEnum = nil
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
	if data and type(data) ~= "number" then
		self.InitChallenge(self, data)
	else
		print_error("@liuyibing：Check show wu xue challenge panel failed!ChallengeId is invalid! challengeId: " .. tostring(data))
	end
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.startBtn.luaClick = self.CreateAction(self, self.OnClickStartBtn)
	self.bindData.closeBtn.luaClick = self.CreateAction(self, self.OnClickCloseBtn)
end

M.OnClickStartBtn = function(self)
	local challengeCfg = LTConfig.ChallengeConfig.GetConfig(self.challengeId)
	local taskId = challengeCfg.RelatedTask and challengeCfg.RelatedTask[1]

	if taskId and taskId <= 0 then
		slot3 = gTaskManager

		slot3:SetCurrentTask(taskId, function ()
			gPanelManager:Close(gPanelId.ACHALLENGE_PANEL)
		end)
	else
		print_error("@liuyibing：Start challenge task failed!Task id is invalid! challengeId: " .. tostring(self.challengeId))
		self.OnClickCloseBtn(self)
	end
end

M.OnClickCloseBtn = function(self)
	gPanelManager:Close(gPanelId.ACHALLENGE_PANEL)
end

M.InitChallenge = function(self, challengeId)
	local challengeCfg = LTConfig.ChallengeConfig.GetConfig(challengeId)
	self.challengeId = challengeId

	if challengeCfg then
		self.bindData.name = challengeCfg.Name
		self.bindData.icon = challengeCfg.Image
		self.bindData.level = string.format("Lv.%d", challengeCfg.UrbanJobLevel or 1)

		self:InitFightSkillInfo(challengeCfg.FightSkill, self.bindData.maWidget)

		local level = 1
		local currentJob, jobCfg = gSpiritJobManager:GetAvailableJobByClass(LTConfig.UrbanJobJobClassConfig.Wuxue)

		if currentJob and jobCfg then
			local tid = gSpiritManager:GetCurFirstSpiritTid()
			local levelCfg = gSpiritJobManager:GetLevelData(jobCfg, tid)
			level = levelCfg and levelCfg.Level or 1
		end

		self.bindData.levelCtrl = level >= challengeCfg.UrbanJobLevel and self.levelCtrlEnum.danger or self.levelCtrlEnum.normal
		self.bindData.complete = 0

		gClientToGameDelegate:AskNewChallengeRecord(challengeId).Callback = function (err, data)
			if err ~= LTConfig.MessageConfig.Ok then
				if gClientUtils.IsNil(self.rootGo) then
					return
				end

				self.bindData.complete = data.HighestLevel <= 0 and 1 or 0
			end
		end
	else
		print_error("@liuyibing：Initialize wu xue challenge panel failed!ChallengeId is invalid! challengeId: " .. tostring(challengeId))
	end
end

M.InitFightSkillInfo = function(self, id, widget)
	if id and id <= 0 then
		local store = gStoreManager:GetStoreGroup(widget.Store):GetStoreByWidget(widget)

		if store then
			local fightSkillCfg = LTConfig.FightSkillConfig.GetConfig(id)

			if fightSkillCfg then
				store.maIcon = fightSkillCfg.IconId
				store.maName = fightSkillCfg.Name
				store.QualityCtrl = fightSkillCfg.Quality or 0
			end
		end
	end
end
