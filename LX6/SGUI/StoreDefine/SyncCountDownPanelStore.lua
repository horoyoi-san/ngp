-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\SyncCountDownPanelStore.lua
-- Decompiled from: 01405_SyncCountDownPanelStore.lua_b8fbea402e62.luajit

C_SyncCountDownPanelStore = DefClass("C_SyncCountDownPanelStore", C_SyncCountDownPanelStore, C_StoreGroup)
GroupName2Class.SyncCountDownPanelStore = C_SyncCountDownPanelStore
local M = C_SyncCountDownPanelStore
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}

M.ctor = function(self)
	self.mgr = gNewGamePlayProgressMgr
	self.openAnimeName = "S_Vx_TimerPanel_open"
end

M.DefineAllVariables = function(self)
	self.progressId = 0
	self.templateId = 0
	self.uiId = 0
	self.listenProgressIds = {}
end

M.DefineAllEnumsAutoGen = function(self)
	self.visibleEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.visibleEnum = nil
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
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	if data and data.ToTable then
		data = data.ToTable(data)
	end

	self.templateId = data and data.templateId or 0
	self.uiId = data and data.uiId or panelId or 0
	self.listenProgressIds = self.mgr and self.mgr:GetProgressDictByTemplateIds({
		self.templateId
	}) or {}

	self:RenderCurrentCountDown()

	if self.bindData.anime and gCS and gCS.LuaUtils and gCS.LuaUtils.PlayAnimationByName then
		gCS.LuaUtils.PlayAnimationByName(self.bindData.anime, self.openAnimeName)
	end
end

M.OnClose = function(self)
	self.progressId = 0
	self.templateId = 0
	self.uiId = 0
	self.listenProgressIds = {}

	self.HideCountDown(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.PROGRESS_TEMPLATE_STATE_CHANGE] = self.CreateAction(self, self.RefreshProgressInfo),
		[gEventConstants.PROGRESS_STATE_CHANGE] = self.CreateAction(self, self.RefreshCurrentProgress)
	}
end

M.RegisterWidget = function(self)
end

M.RefreshProgressInfo = function(self, _, data)
	if data and data.uiId and data.uiId == self.uiId then
		return
	end

	if data and data.templateId then
		self.templateId = data.templateId
	end

	self.listenProgressIds = self.mgr and self.mgr:GetProgressDictByTemplateIds({
		self.templateId
	}) or {}

	self:RenderCurrentCountDown()
end

M.RefreshCurrentProgress = function(self, _, progressId)
	if progressId and not self.listenProgressIds[progressId] then
		return
	end

	self.RenderCurrentCountDown(self)
end

M.HideCountDown = function(self)
	if not self.bindData then
		return
	end

	self.bindData.visible = BOOL2CTL[false]

	if self.bindData.countDown then
		self.bindData.countDown:Stop()
	end
end

M.RenderCurrentCountDown = function(self)
	if not self.mgr or self.templateId ~= 0 or not self.bindData or not self.bindData.countDown then
		self.HideCountDown(self)

		return 0
	end

	local progressInfoList = self.mgr:GetCurrentProgress(1, self.templateId)

	if table.isNilOrEmpty(progressInfoList) then
		self.HideCountDown(self)

		return 0
	end

	local progressInfo = progressInfoList[1]
	local progressId = progressInfo and progressInfo.progressId or 0
	local progress = self.mgr:GetProgress(progressId)

	if not progress or not progress.totalLength or not progress.speed or progress.speed ~= 0 then
		self.HideCountDown(self)

		return 0
	end

	local absSpeed = math.abs(progress.speed)
	local totalSecond = progress.totalLength / absSpeed

	if totalSecond < 0 then
		self.HideCountDown(self)

		return 0
	end

	local currentCounter = self.mgr:GetCounterValue(progressId) or 0
	currentCounter = math.max(0, math.min(currentCounter, progress.totalLength))
	local positiveTiming = progress.speed >= 0
	self.bindData.visible = BOOL2CTL[true]
	self.bindData.countDown.positiveTiming = positiveTiming
	self.bindData.countDown.formatText = progressInfo.formatStr

	self.bindData.countDown:Play(currentCounter, totalSecond)

	self.progressId = progressId

	return progressId
end
