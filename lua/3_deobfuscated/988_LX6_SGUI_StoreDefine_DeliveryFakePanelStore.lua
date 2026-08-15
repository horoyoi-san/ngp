C_DeliveryFakePanelStore = DefClass("C_DeliveryFakePanelStore", C_DeliveryFakePanelStore, C_PhoneAppBaseStackStoreGroup)
GroupName2Class.DeliveryFakePanelStore = C_DeliveryFakePanelStore
local M = C_DeliveryFakePanelStore

function M:OnAwake()
	self.bindData.takeOrderTabButton.luaClick = self:CreateAction(self.OnTakeOrderTabClick)
	self.bindData.acceptOrderTabButton.luaClick = self:CreateAction(self.OnAcceptOrderTabClick)
	self.bindData.startButton.luaClick = self:CreateAction(self.OnStartClick)
	self.bindData.exitButton.luaClick = self:CreateAction(self.OnExitClick)
	self.bindData.takeOrderButton.luaClick = self:CreateAction(self.OnTakeOrderClick)
	self.bindData.fullScreenButon.luaClick = self:CreateAction(self.OnExitClick)
end

function M:GetMessageEvents()
	return {
		[gEventConstants.LANGUAGE_CHANGE] = function ()
			self:RefreshAcceptOrderListView()
			self:RefreshTakeOrderListView()
		end,
		[gEventConstants.ON_TRUCK_GUIDE_TAKE_ORDER_SATE_CHANGE] = function ()
			self:RefreshAcceptOrderListView()
			self:RefreshTakeOrderListView()
		end
	}
end

function M:InitModel(args)
	M.base.InitModel(args)

	self.clientTruckOrderView = args.clientTruckOrderView
	self.Order_Show_Type_Control = {
		TakeOrderList = 0,
		AcceptOrderList = 1
	}
end

function M:InitView()
	self.bindData.showTypeControl = self.Order_Show_Type_Control.TakeOrderList

	self:RefreshTakeOrderListView()
end

function M:OnTakeOrderClick()
	gClientToGameDelegate:AskStartTruckOrderGuide().Callback = function (errorId)
		if errorId ~= LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end
	end
end

function M:OnExitClick()
	self:OnExit()
end

function M:OnStartClick()
	self.bindData.typeControl = 1
end

function M:OnTakeOrderTabClick()
	if self.bindData.showTypeControl == self.Order_Show_Type_Control.TakeOrderList then
		return
	end

	self.bindData.showTypeControl = self.Order_Show_Type_Control.TakeOrderList

	self.bindData.selectAnimation:Play("S_Vx_Yanjie_Tab2")
	self:RefreshTakeOrderListView()
end

function M:OnAcceptOrderTabClick()
	if self.bindData.showTypeControl == self.Order_Show_Type_Control.AcceptOrderList then
		return
	end

	self.bindData.showTypeControl = self.Order_Show_Type_Control.AcceptOrderList

	self.bindData.selectAnimation:Play("S_Vx_Yanjie_Tab1")
	self:RefreshAcceptOrderListView()
end

function M:RefreshTakeOrderListView()
	local takeTemplateStore = gStoreManager:GetStoreGroup(self.bindData.takeTemplateWidget.Store):GetStoreByWidget(self.bindData.takeTemplateWidget)
	takeTemplateStore.takeStateControl = self:CheckHasTakeOrder() and 1 or 0
end

function M:CheckHasTakeOrder()
	return gDeliveryTaskManager.guideHasTakeOrder
end

function M:RefreshAcceptOrderListView()
	local hasTakeOrder = self:CheckHasTakeOrder()

	self.bindData.acceptOrderWidget.gameObject:SetActive(hasTakeOrder)

	self.bindData.setTargetButton.interactable = false
end

function M:OnExecuteExitAction()
	gMessageManager:SendMessage(gEventConstants.ON_PHONE_APP_HOME_CONTENT_CLOSE)
end
