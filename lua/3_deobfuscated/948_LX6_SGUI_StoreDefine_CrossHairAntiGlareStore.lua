C_CrossHairAntiGlareStore = DefClass("C_CrossHairAntiGlareStore", C_CrossHairAntiGlareStore, C_StoreGroup)
GroupName2Class.CrossHairAntiGlareStore = C_CrossHairAntiGlareStore
local M = C_CrossHairAntiGlareStore

function M:OnAwake()
	local msgEvents = {
		[gEventConstants.PANEL_ON_SHOW] = self:CreateAction("OnPanelShow"),
		[gEventConstants.PANEL_ON_CLOSE] = self:CreateAction("OnPanelClose")
	}

	self:RegisterMessageEvents(msgEvents)
end

function M:OnDestroy()
	self:ClearMessageEvents()
end

function M:OnShow(panelId, data)
	self.bindData.isShowCtrl = 1
end

function M:OnPanelShow(eventId, panelId)
	local list = LTConfig.ShezhiPanelConfig.AntidinicModeSpecial

	for i, v in pairs(list) do
		if v == panelId then
			self.panelId = panelId

			gPanelManager:CheckShow(gPanelId.S_CROSS_HAIR_ANTI_GLARE_FULLSCREEN)

			return
		end
	end
end

function M:OnPanelClose(eventId, panelId)
	if self.panelId == panelId then
		self.panelId = nil

		gPanelManager:Close(gPanelId.S_CROSS_HAIR_ANTI_GLARE_FULLSCREEN)
	end
end

function M:OnChangeAntidinicMode(eventId, isShow)
	if isShow then
		self.bindData.isShowCtrl = 1
	else
		self.bindData.isShowCtrl = 0
	end
end
