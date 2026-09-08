-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PoliceOccupationPanelStore.lua
-- Decompiled from: 02081_PoliceOccupationPanelStore.lua_7f97cea84d4f.luajit

C_PoliceOccupationPanelStore = DefClass("C_PoliceOccupationPanelStore", C_PoliceOccupationPanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.PoliceOccupationPanelStore = C_PoliceOccupationPanelStore
local M = C_PoliceOccupationPanelStore

M.ctor = function(self)
	self.mgr = gPoliceJobManager.panelMgr
end

M.OnAwake = function(self)
	self.bindData.exitBtn.luaClick = self.CreateAction(self, "OnExitClick")
	self.bindData.talentTreeBtn.luaClick = self.CreateAction(self, "OpenTalentTree")
	self.bindData.jobList.luaSimpleRenderItem = self.CreateAction(self, "RenderJobPathItem")
end

M.InitView = function(self, data)
	self.mgr:RenderCurrentSpirit(self.bindData.avatar)
end

M.OnExecuteExitAction = function(self)
	self.mgr:CloseCurrentPanel()
end

M.ClearData = function(self)
	self.jobList = nil
end

M.OpenTalentTree = function(self)
	gUIFunctionStateManager:TalentTreeOpenTrigger({
		jobClassId = LTConfig.UrbanJobJobClassConfig.Police
	})
end

M.RefreshPage = function(self)
	local currentJob, jobCfg = gSpiritJobManager:GetAvailableJobByClass(LTConfig.UrbanJobJobClassConfig.Police)
	self.bindData.jobNameLabel = jobCfg.Name
	local spiritTid = gSpiritManager:GetCurFirstSpiritTid()
	local levelCfg = gSpiritJobManager:GetLevelData(jobCfg, spiritTid)
	local level = levelCfg and levelCfg.Level or 1
	self.bindData.levelText = string.format("Lv%d", level or 1)
	self.bindData.jobProgress.maxValue = levelCfg.Exp

	self.bindData.jobProgress:ProgressToValue(currentJob.Exp, 0)

	self.bindData.showTalent = self:CanShowTalentTree() and 1 or 0
	self.jobList = self:GetJobListByClassId(LTConfig.UrbanJobJobClassConfig.Police)

	self.bindData.jobList:SetSimpleList(#self.jobList)
end

M.CanShowTalentTree = function(self)
	local systemUnlockId = LTConfig.SystemUnlockConfig.PoliceTalent

	if systemUnlockId <= 0 then
		return gSystemUnlockMgr:IsUnlock(systemUnlockId) and gMainPhoneUtils.CheckAppCanShow(LTConfig.MobileMenuSGuiConfig.TalentTreeId)
	else
		return gMainPhoneUtils.CheckAppCanShow(LTConfig.MobileMenuSGuiConfig.TalentTreeId)
	end
end

M.GetJobListByClassId = function(self, classId)
	local targetJobId = gSpiritJobManager.GetAvailableJobId(LTConfig.UrbanJobJobClassConfig.Police)
	local jobList = {}

	for i = 0, LTConfig.UrbanJobConfig.count - 1 do
		local cfg = LTConfig.UrbanJobConfig.LoadAt(i)

		if cfg.JobClass ~= classId then
			local ele = {
				id = cfg.Id,
				isNow = cfg.Id > (targetJobId or 0)
			}

			table.insert(jobList, ele)
		end
	end

	return jobList
end

M.RenderJobPathItem = function(self, btn, index)
	local data = self.jobList[index + 1]

	if data then
		gSpiritJobManager:OnRenderJobPathItem(btn, index, data)
	end
end
