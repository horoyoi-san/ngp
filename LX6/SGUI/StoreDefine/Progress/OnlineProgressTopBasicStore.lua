-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\Progress\OnlineProgressTopBasicStore.lua
-- Decompiled from: 00943_OnlineProgressTopBasicStore.lua_9868c0aa4d1f.luajit

C_OnlineProgressTopBasicStore = DefClass("C_OnlineProgressTopBasicStore", C_OnlineProgressTopBasicStore, C_StoreGroup)
GroupName2Class.OnlineProgressTopBasicStore = C_OnlineProgressTopBasicStore
local M = C_OnlineProgressTopBasicStore

M.ctor = function(self)
	self.mgr = gNewGamePlayProgressMgr
end

M.OnAwake = function(self)
	self.tempalteIds = {}
	self.uiId = 0
	self.updateList = {}
	self.listenProgressIds = {}
	self.msgEvents = {
		[gEventConstants.PROGRESS_TEMPLATE_STATE_CHANGE] = self.CreateAction(self, self.RefreshProgressInfo),
		[gEventConstants.PROGRESS_STATE_CHANGE] = self.CreateAction(self, self.RefreshCurrentProgress)
	}

	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnShow = function(self, panelId, data)
	self.uiId = data.uiId
	self.tempalteIds = self.mgr:GetAllTemplateIdsByUiId(self.uiId)
	self.listenProgressIds = self.mgr:GetProgressDictByTemplateIds(self.tempalteIds)

	self:GetProgressInfo()
end

M.RefreshCurrentProgress = function(self, _, progressId)
	if self.listenProgressIds[progressId] then
		self.GetProgressInfo(self)
	end
end

M.RefreshProgressInfo = function(self, _, data)
	if data.uiId ~= self.uiId then
		table.insert(self.tempalteIds, data.templateId)

		self.listenProgressIds = self.mgr:GetProgressDictByTemplateIds(self.tempalteIds)

		self:GetProgressInfo()
	end
end

M.GetProgressInfo = function(self)
	self.updateList = {}

	for i = 1, #self.tempalteIds do
		local cfg = self.mgr:GetUIConfigByTemplateId(self.tempalteIds[i])

		if cfg and cfg.PanelId ~= self.m_Id then
			local wid = self.bindData[cfg.Widget]
			local store = gStoreManager:GetStoreGroup(wid.Store):GetStoreByWidget(wid)
			local progressId = self.mgr:RenderSingleProgressTemplate(store, self.tempalteIds[i])

			if progressId == 0 then
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

M.OnUpdate = function(self)
	for i = 1, #self.updateList do
		self.mgr:RefreshSingleProgressCounter(self.updateList[i].store, self.updateList[i].progressId, self.updateList[i].templateId)
	end
end

M.OnClose = function(self)
	self.ClearMessageEvents(self)
end
