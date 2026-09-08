-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\Progress\ProgressBaseStore.lua
-- Decompiled from: 01835_ProgressBaseStore.lua_d708dcec5ab0.luajit

C_ProgressBaseStore = DefClass("C_ProgressBaseStore", C_ProgressBaseStore, C_StoreGroup)
GroupName2Class.ProgressBaseStore = C_ProgressBaseStore
local M = C_ProgressBaseStore

M.ctor = function(self)
	self.progressId = 0
	self.tempalteId = 0
	self.mgr = gNewGamePlayProgressMgr
end

M.OnInitData = function(self)
	self.visible = true
	self.progressId = 0
	self.uiId = 0
	self.progressInfo = {}
	self.listenProgressIds = {}
end

M.OnAwake = function(self)
	self.OnInitData(self)

	self.msgEvents = {
		[gEventConstants.PROGRESS_TEMPLATE_STATE_CHANGE] = self.CreateAction(self, self.RefreshProgressInfo),
		[gEventConstants.PROGRESS_STATE_CHANGE] = self.CreateAction(self, self.RefreshCurrentProgress)
	}

	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnShow = function(self, panelId, data)
	self.tempalteId = data.templateId
	self.listenProgressIds = self.mgr:GetProgressDictByTemplateIds({
		self.tempalteId
	})
	self.uiId = data.uiId

	self:GetProgressInfo()
end

M.RefreshProgressInfo = function(self, _, data)
	if data.uiId ~= self.uiId then
		self.tempalteId = data.templateId

		self.GetProgressInfo(self)
	end
end

M.RefreshCurrentProgress = function(self, _, progressId)
	if self.listenProgressIds[progressId] then
		self.GetProgressInfo(self)
	end
end

M.GetProgressInfo = function(self)
	self.progressId = self.mgr:RenderSingleProgressTemplate(self.bindData, self.tempalteId)
end

M.OnUpdate = function(self)
	self.mgr:RefreshSingleProgressCounter(self.bindData, self.progressId, self.tempalteId)
end

M.OnClose = function(self)
	self.ClearMessageEvents(self)
end
