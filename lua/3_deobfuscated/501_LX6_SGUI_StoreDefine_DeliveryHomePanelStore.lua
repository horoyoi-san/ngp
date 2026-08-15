C_DeliveryHomePanelStore = DefClass("C_DeliveryHomePanelStore", C_DeliveryHomePanelStore, C_PhoneAppBaseStackStoreGroup)
GroupName2Class.DeliveryHomePanelStore = C_DeliveryHomePanelStore
local M = C_DeliveryHomePanelStore

function M:OnAwake()
	self.bindData.tabRect.OnRenderTab = self:CreateAction(self.OnRenderTab)
	self.bindData.fullScreenButton.luaClick = self:CreateAction(self.OnExitClick)
end

function M:GetMessageEvents()
	return {
		[gEventConstants.ON_DELIVERY_APP_CONTENT_SHOW] = function (_, args)
			self:ShowContentPanel(args)
		end,
		[gEventConstants.ON_DELIVERY_APP_CONTENT_CLOSE] = function (_, args)
			self:CloseContentPanel(args)
		end,
		[gEventConstants.JOB_CHANGE_EVENT] = self:CreateAction("OnJobChanged")
	}
end

function M:InitModel(args)
	M.base.InitModel(self, args)
end

function M:InitView(args)
	M.base.InitView(self, args)
end

function M:OnExitClick()
	self:OnExit()
end

function M:OnJobChanged()
	local currentJobClassId = gSpiritJobManager.GetCurSpiritJobClassId()

	if currentJobClassId ~= LTConfig.UrbanJobJobClassConfig.Delivery then
		self:OnExit()
	end
end

function M:OnRenderTab(index, widget)
	if self.panelArgs.panelId then
		gClientUtils.InitNavAreasInChildren(widget, self.panelArgs.panelId)
	end

	M.base.OnRenderTab(self, index, widget)
end

function M:OnExecuteExitAction()
	gMainPhoneUtils.CloseFrontContent()
	gMessageManager:SendMessage(gEventConstants.ON_PHONE_APP_HOME_CONTENT_CLOSE)
end

function M:GetShowTypeField()
	return gClientConst.PhoneAppShowTypeLevel.SecondLevel
end
