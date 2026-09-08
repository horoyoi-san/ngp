-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CleanerOccupationPanelStore.lua
-- Decompiled from: 02004_CleanerOccupationPanelStore.lua_41bc7fd83163.luajit

C_CleanerOccupationPanelStore = DefClass("C_CleanerOccupationPanelStore", C_CleanerOccupationPanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.CleanerOccupationPanelStore = C_CleanerOccupationPanelStore
local M = C_CleanerOccupationPanelStore

M.OnAwake = function(self)
	self.bindData.exitButton.luaClick = self.CreateAction(self, self.OnExitClick)
	self.bindData.talentTreeButton.luaClick = self.CreateAction(self, self.OnTalentTreeClick)
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderItem)
end

M.InitModel = function(self, args)
	M.base.InitModel(args)

	self.targetJobId = gSpiritJobManager.GetAvailableJobId(LTConfig.UrbanJobJobClassConfig.Washer)
end

M.InitView = function(self, args)
	M.base.InitView(args)
	gWasherManager.RefreshWasherAvatarView(self.bindData.avatarWidget, true)

	local urbanJobCfg = LTConfig.UrbanJobConfig.GetConfig(self.targetJobId)
	self.bindData.jobName = urbanJobCfg.Name

	self.RefreshJobExpView(self)
	self.RefreshJobListView(self)
end

M.RefreshJobExpView = function(self)
	local urbanJobCfg = LTConfig.UrbanJobConfig.GetConfig(self.targetJobId)
	local jobInfo = gSpiritJobManager.GetCurSpiritJob(self.targetJobId)
	local levelCfg = gSpiritJobManager:GetLevelConfig(urbanJobCfg)
	local progress = jobInfo.Exp / levelCfg.Exp

	self.bindData.progressBar:ProgressToValue(progress)

	self.bindData.progressText = ("%d/%d"):format(jobInfo.Exp, levelCfg.Exp)
end

M.RefreshJobListView = function(self)
	local jobIdList = gSpiritJobManager:GetJobData(self.targetJobId)
	self.jobViewDataList = {}

	for _, jobId in pairs(jobIdList) do
		table.insert(self.jobViewDataList, {
			id = jobId
		})
	end

	self.bindData.list:SetSimpleList(#self.jobViewDataList)
end

M.OnTalentTreeClick = function(self)
	gUIFunctionStateManager:TalentTreeOpenTrigger({
		jobClassId = LTConfig.UrbanJobJobClassConfig.Washer
	})
end

M.OnRenderItem = function(self, btn, csIndex)
	local data = self.jobViewDataList[csIndex + 1]

	gSpiritJobManager:OnRenderJobPathItem(btn, csIndex, data)
end

M.OnExecuteExitAction = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_WASHER_APP_CONTENT_CLOSE)
end
