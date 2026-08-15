C_HackerLoadingPanelStore = DefClass("C_HackerLoadingPanelStore", C_HackerLoadingPanelStore, C_StoreGroup)
GroupName2Class.HackerLoadingPanelStore = C_HackerLoadingPanelStore
local M = C_HackerLoadingPanelStore

function M:ctor()
	self.progressId = 0
	self.tempalteId = 0
	self.mgr = gNewGamePlayProgressMgr
end

function M:OnAwake()
	self.visible = true
	self.progressId = 0
	self.uiId = 0
	self.progressInfo = {}
	self.listenProgressIds = {}
	self.msgEvents = {
		[gEventConstants.PROGRESS_TEMPLATE_STATE_CHANGE] = self:CreateAction(self.RefreshProgressInfo),
		[gEventConstants.PROGRESS_STATE_CHANGE] = self:CreateAction(self.RefreshCurrentProgress)
	}

	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnShow(panelId, data)
	self.tempalteId = data.templateId
	self.listenProgressIds = self.mgr:GetProgressDictByTemplateIds({
		self.tempalteId
	})
	self.uiId = data.uiId

	self:GetProgressInfo()
end

function M:RefreshProgressInfo(_, data)
	if data.uiId == self.uiId then
		self.tempalteId = data.templateId

		self:GetProgressInfo()
	end
end

function M:RefreshCurrentProgress(_, progressId)
	if self.listenProgressIds[progressId] then
		self:GetProgressInfo()
	end
end

function M:GetProgressInfo()
	self.progressId = self.mgr:RenderSingleProgressTemplate(self.bindData, self.tempalteId)
end

function M:OnUpdate()
	self.mgr:RefreshSingleProgressCounter(self.bindData, self.progressId, self.tempalteId)
end

function M:OnClose()
	self:ClearMessageEvents()
end
