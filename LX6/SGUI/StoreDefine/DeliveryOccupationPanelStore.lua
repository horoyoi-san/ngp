-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\DeliveryOccupationPanelStore.lua
-- Decompiled from: 01955_DeliveryOccupationPanelStore.lua_c46a9bb309ae.luajit

C_DeliveryOccupationPanelStore = DefClass("C_DeliveryOccupationPanelStore", C_DeliveryOccupationPanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.DeliveryOccupationPanelStore = C_DeliveryOccupationPanelStore
local M = C_DeliveryOccupationPanelStore

M.OnAwake = function(self)
	self.bindData.exitButton.luaClick = self.CreateAction(self, "OnExitClick")
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, "OnRenderItem")
	self.bindData.talentTreeButton.luaClick = self.CreateAction(self, "OnTalentTreeClick")
end

M.InitModel = function(self, args)
	M.base.InitModel(args)

	self.targetJobId = gSpiritJobManager.GetAvailableJobId(LTConfig.UrbanJobJobClassConfig.Delivery)
end

M.InitView = function(self, args)
	M.base.InitView(args)
	gDeliveryTaskManager.RefreshDeliveryAvatarView(self.bindData.avatarWidget, self.rootGo)

	local urbanJobCfg = LTConfig.UrbanJobConfig.GetConfig(self.targetJobId)
	self.bindData.jobName = urbanJobCfg.Name

	self.RefreshJobExpView(self)
	self.RefreshJobListView(self)
end

M.RefreshJobExpView = function(self)
	local urbanJobCfg = LTConfig.UrbanJobConfig.GetConfig(self.targetJobId)
	local jobInfo = gSpiritJobManager.GetCurSpiritJob(self.targetJobId)
	local levelCfg = gSpiritJobManager:GetLevelData(urbanJobCfg, gSpiritManager:GetCurFirstSpiritTid())
	local progress = jobInfo.Exp / levelCfg.Exp

	self.bindData.progressBar:ProgressToValue(progress)

	self.bindData.progressText = ("%d/%d"):format(jobInfo.Exp, levelCfg.Exp)
end

M.RefreshJobListView = function(self)
	local jobIdList = gSpiritJobManager:GetJobData(self.targetJobId)
	self.viewDataList = {}

	for _, jobId in pairs(jobIdList) do
		table.insert(self.viewDataList, {
			id = jobId,
			isNow = jobId > self.targetJobId
		})
	end

	self.bindData.list:SetSimpleList(#self.viewDataList)
end

M.OnRenderItem = function(self, btn, csIndex)
	local data = self.viewDataList[csIndex + 1]

	gSpiritJobManager:OnRenderJobPathItem(btn, csIndex, data)
end

M.OnTalentTreeClick = function(self)
	gDeliveryTaskManager:OpenTalentTree()
end

M.OnExecuteExitAction = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_DELIVERY_APP_CONTENT_CLOSE)
end

M.ClearData = function(self)
	self.viewDataList = nil
end
