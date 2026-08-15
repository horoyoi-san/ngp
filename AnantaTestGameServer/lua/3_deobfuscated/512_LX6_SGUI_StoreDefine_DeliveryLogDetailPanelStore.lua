C_DeliveryLogDetailPanelStore = DefClass("C_DeliveryLogDetailPanelStore", C_DeliveryLogDetailPanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.DeliveryLogDetailPanelStore = C_DeliveryLogDetailPanelStore
local M = C_DeliveryLogDetailPanelStore

function M:OnAwake()
	self.bindData.exitButton.luaClick = self:CreateAction(self.OnExitClick)
end

function M:InitModel(args)
	M.base.InitModel(self, args)

	self.truckJobOrderWrap = args.truckJobOrderWrap
end

function M:InitView(args)
	M.base.InitView(self, args)
	gDeliveryTaskManager.RefreshDeliveryAvatarView(self.bindData.avatar, self.rootGo)
	self:RefreshDetailView()
end

function M:RefreshDetailView()
	local widget = self.bindData.detailItemWidget

	gDeliveryTaskManager.RefreshOrderDetailView(widget, self.truckJobOrderWrap)
end

function M:OnExecuteExitAction()
	gMessageManager:SendMessage(gEventConstants.ON_DELIVERY_APP_CONTENT_CLOSE)
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end
