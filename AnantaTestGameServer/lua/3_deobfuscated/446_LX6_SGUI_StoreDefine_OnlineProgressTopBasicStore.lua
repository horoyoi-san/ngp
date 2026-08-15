C_OnlineProgressTopBasicStore = DefClass("C_OnlineProgressTopBasicStore", C_OnlineProgressTopBasicStore, C_StoreGroup)
GroupName2Class.OnlineProgressTopBasicStore = C_OnlineProgressTopBasicStore
local M = C_OnlineProgressTopBasicStore

function M:ctor()
	self.mgr = gNewGamePlayProgressMgr
end

function M:OnAwake()
	self.tempalteIds = {}
	self.uiId = 0
	self.updateList = {}
	self.listenProgressIds = {}
	self.msgEvents = {
		[gEventConstants.PROGRESS_TEMPLATE_STATE_CHANGE] = self:CreateAction(self.RefreshProgressInfo),
		[gEventConstants.PROGRESS_STATE_CHANGE] = self:CreateAction(self.RefreshCurrentProgress)
	}

	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnShow(panelId, data)
	self.uiId = data.uiId
	self.tempalteIds[1] = data.templateId
	self.listenProgressIds = self.mgr:GetProgressDictByTemplateIds(self.tempalteIds)

	self:GetProgressInfo()
end

function M:RefreshCurrentProgress(_, progressId)
	if self.listenProgressIds[progressId] then
		self:GetProgressInfo()
	end
end

function M:RefreshProgressInfo(_, data)
	if data.uiId == self.uiId then
		table.insert(self.tempalteIds, data.templateId)

		self.listenProgressIds = self.mgr:GetProgressDictByTemplateIds(self.tempalteIds)

		self:GetProgressInfo()
	end
end

function M:GetProgressInfo()
	self.updateList = {}

	for i = 1, #self.tempalteIds do
		local cfg = self.mgr:GetUIConfigByTemplateId(self.tempalteIds[i])

		if cfg and cfg.PanelId == self.m_Id then
			local wid = self.bindData[cfg.Widget]
			local store = gStoreManager:GetStoreGroup(wid.Store):GetStoreByWidget(wid)
			local progressId = self.mgr:RenderSingleProgressTemplate(store, self.tempalteIds[i])

			if progressId ~= 0 then
				local ele = {
					store = store,
					progressId = progressId,
					templateId = self.tempalteIds[i]
				}

				table.insert(self.updateList, ele)
			end
		end
	end
end

function M:OnUpdate()
	for i = 1, #self.updateList do
		self.mgr:RefreshSingleProgressCounter(self.updateList[i].store, self.updateList[i].progressId, self.updateList[i].templateId)
	end
end

function M:OnClose()
	self:ClearMessageEvents()
end
