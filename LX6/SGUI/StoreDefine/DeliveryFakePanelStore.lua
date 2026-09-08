-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\DeliveryFakePanelStore.lua
-- Decompiled from: 02110_DeliveryFakePanelStore.lua_941b26bd02cb.luajit

C_DeliveryFakePanelStore = DefClass("C_DeliveryFakePanelStore", C_DeliveryFakePanelStore, C_PhoneAppBaseStackStoreGroup)
GroupName2Class.DeliveryFakePanelStore = C_DeliveryFakePanelStore
local M = C_DeliveryFakePanelStore

M.OnAwake = function(self)
	self.bindData.takeOrderTabButton.luaClick = self.CreateAction(self, self.OnTakeOrderTabClick)
	self.bindData.acceptOrderTabButton.luaClick = self.CreateAction(self, self.OnAcceptOrderTabClick)
	self.bindData.startButton.luaClick = self.CreateAction(self, self.OnStartClick)
	self.bindData.exitButton.luaClick = self.CreateAction(self, self.OnExitClick)
	self.bindData.takeOrderButton.luaClick = self.CreateAction(self, self.OnTakeOrderClick)
	self.bindData.fullScreenButon.luaClick = self.CreateAction(self, self.OnExitClick)
end

M.GetMessageEvents = function(self)
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

M.InitModel = function(self, args)
	M.base.InitModel(args)

	self.clientTruckOrderView = args.clientTruckOrderView
	self.Order_Show_Type_Control = {
		["6\\xe2T)%\\xc2\\xb3S\\x8d_\\xa3\\xa2"] = 0,
		[")#\\xe1c\\x8c\\xd8&\\xac*\\xf4\\xde\\xefg\\xef"] = 1
	}
end

M.InitView = function(self)
	self.bindData.showTypeControl = self.Order_Show_Type_Control.TakeOrderList

	self.RefreshTakeOrderListView(self)
end

M.OnTakeOrderClick = function(self)
	slot1 = gClientToGameDelegate

	slot1:AskStartTruckOrderGuide().Callback = function (errorId)
		if errorId == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end
	end
end

M.OnExitClick = function(self)
	self.OnExit(self)
end

M.OnStartClick = function(self)
	self.bindData.typeControl = 1
end

M.OnTakeOrderTabClick = function(self)
	if self.bindData.showTypeControl ~= self.Order_Show_Type_Control.TakeOrderList then
		return
	end

	self.bindData.showTypeControl = self.Order_Show_Type_Control.TakeOrderList

	self.bindData.selectAnimation:Play("S_Vx_Yanjie_Tab2")
	self:RefreshTakeOrderListView()
end

M.OnAcceptOrderTabClick = function(self)
	if self.bindData.showTypeControl ~= self.Order_Show_Type_Control.AcceptOrderList then
		return
	end

	self.bindData.showTypeControl = self.Order_Show_Type_Control.AcceptOrderList

	self.bindData.selectAnimation:Play("S_Vx_Yanjie_Tab1")
	self:RefreshAcceptOrderListView()
end

M.RefreshTakeOrderListView = function(self)
	local takeTemplateStore = gStoreManager:GetStoreGroup(self.bindData.takeTemplateWidget.Store):GetStoreByWidget(self.bindData.takeTemplateWidget)
	takeTemplateStore.takeStateControl = self:CheckHasTakeOrder() and 1 or 0
end

M.CheckHasTakeOrder = function(self)
	return gDeliveryTaskManager.guideHasTakeOrder
end

M.RefreshAcceptOrderListView = function(self)
	local hasTakeOrder = self:CheckHasTakeOrder()

	self.bindData.acceptOrderWidget.gameObject:SetActive(hasTakeOrder)

	self.bindData.setTargetButton.interactable = false
end

M.OnExecuteExitAction = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_PHONE_APP_HOME_CONTENT_CLOSE)
end
