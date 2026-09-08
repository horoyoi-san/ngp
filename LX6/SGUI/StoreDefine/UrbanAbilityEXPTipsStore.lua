-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\UrbanAbilityEXPTipsStore.lua
-- Decompiled from: 01190_UrbanAbilityEXPTipsStore.lua_f50fa83b5546.luajit

C_UrbanAbilityEXPTipsStore = DefClass("C_UrbanAbilityEXPTipsStore", C_UrbanAbilityEXPTipsStore, C_StoreGroup)
GroupName2Class.UrbanAbilityEXPTipsStore = C_UrbanAbilityEXPTipsStore
local M = C_UrbanAbilityEXPTipsStore

M.ctor = function(self)
end

M.OnShow = function(self, panelId, args)
	self.panelId = panelId
	self.areaIndex = args.areaIndex
	self.jobExpInfo = args.JobExpInfo

	self.InitView(self)
	self.SetData(self)
end

M.SetData = function(self)
	local jobClassId = 0
	local exp = 0

	for k, v in pairs(self.jobExpInfo) do
		jobClassId = k
		exp = v
	end

	local curJob, cfg = gSpiritJobManager:GetAvailableJobByClass(jobClassId)

	if not curJob then
		print_error("[UrbanAbilityEXPTips] not curJob jobClassId=", jobClassId)

		return
	end

	self.bindData.titleLabel = cfg.Name
	self.bindData.addexp = "+" .. exp
	local curExp = curJob.Exp
	local maxExp = cfg.Exp
	self.bindData.progress.maxValue = maxExp

	self.bindData.progress:ProgressToValue(curExp)
end

M.InitView = function(self)
	self.autoCloseCo = coroutine.start(function ()
		coroutine.wait(3)
		gPanelManager:Close(self.panelId)
	end)
end

M.OnClose = function(self)
end
