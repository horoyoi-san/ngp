-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\DeliveryLogDetailPanelStore.lua
-- Decompiled from: 01946_DeliveryLogDetailPanelStore.lua_b21945c98f98.luajit

C_DeliveryLogDetailPanelStore = DefClass("C_DeliveryLogDetailPanelStore", C_DeliveryLogDetailPanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.DeliveryLogDetailPanelStore = C_DeliveryLogDetailPanelStore
local M = C_DeliveryLogDetailPanelStore

M.OnAwake = function(self)
	self.bindData.exitButton.luaClick = self.CreateAction(self, self.OnExitClick)
end

M.InitModel = function(self, args)
	M.base.InitModel(self, args)

	self.truckJobOrderWrap = args.truckJobOrderWrap
end

M.InitView = function(self, args)
	M.base.InitView(self, args)
	gDeliveryTaskManager.RefreshDeliveryAvatarView(self.bindData.avatar, self.rootGo)
	self.RefreshDetailView(self)
end

M.RefreshDetailView = function(self)
	local widget = self.bindData.detailItemWidget

	gDeliveryTaskManager.RefreshOrderDetailView(widget, self.truckJobOrderWrap)
end

M.OnExecuteExitAction = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_DELIVERY_APP_CONTENT_CLOSE)
end

M.OnActiveDeviceChange = function(self, device)
end
