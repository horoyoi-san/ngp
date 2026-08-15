C_CommonInfoPanelsBaseStore = DefClass("C_CommonInfoPanelsBaseStore", C_CommonInfoPanelsBaseStore, C_StoreGroup)
local M = C_CommonInfoPanelsBaseStore

function M:OnShow(panelId, data)
	self.panelId = panelId
	self.data = data

	if data.onShowCallback then
		data.onShowCallback()
	end

	self:InitOnShow(data, data.panelTypeCfg)
end

function M:InitOnShow(data, panelTypeCfg)
	return
end

function M:OnClose()
	self:ClearOnClose()

	if self.data.onCloseCallback then
		self.data.onCloseCallback()
	end
end

function M:ClearOnClose()
	return
end

function M:ClosePanel()
	gPanelManager:Close(self.panelId)
end
