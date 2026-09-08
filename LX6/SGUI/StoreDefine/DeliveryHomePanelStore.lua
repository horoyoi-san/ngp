-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\DeliveryHomePanelStore.lua
-- Decompiled from: 02107_DeliveryHomePanelStore.lua_ac3cca6ec1e4.luajit

C_DeliveryHomePanelStore = DefClass("C_DeliveryHomePanelStore", C_DeliveryHomePanelStore, C_PhoneAppBaseStackStoreGroup)
GroupName2Class.DeliveryHomePanelStore = C_DeliveryHomePanelStore
local M = C_DeliveryHomePanelStore

M.OnAwake = function(self)
	self.bindData.tabRect.OnRenderTab = self.CreateAction(self, self.OnRenderTab)
	self.bindData.fullScreenButton.luaClick = self.CreateAction(self, self.OnExitClick)
end

M.GetMessageEvents = function(self)
	return {
		[gEventConstants.ON_DELIVERY_APP_CONTENT_SHOW] = function (_, args)
			self:ShowContentPanel(args)
		end,
		[gEventConstants.ON_DELIVERY_APP_CONTENT_CLOSE] = function (_, args)
			self:CloseContentPanel(args)
		end,
		[gEventConstants.JOB_CHANGE_EVENT] = self.CreateAction(self, "OnJobChanged")
	}
end

M.InitModel = function(self, args)
	M.base.InitModel(self, args)
end

M.InitView = function(self, args)
	M.base.InitView(self, args)
end

M.OnExitClick = function(self)
	self.OnExit(self)
end

M.OnJobChanged = function(self)
	local currentJobClassId = gSpiritJobManager.GetCurSpiritJobClassId()

	if currentJobClassId == LTConfig.UrbanJobJobClassConfig.Delivery then
		self.OnExit(self)
	end
end

M.OnRenderTab = function(self, index, widget)
	if self.panelArgs.panelId then
		gClientUtils.InitNavAreasInChildren(widget, self.panelArgs.panelId)
	end

	M.base.OnRenderTab(self, index, widget)
end

M.OnExecuteExitAction = function(self)
	gMainPhoneUtils.CloseFrontContent()
	gMessageManager:SendMessage(gEventConstants.ON_PHONE_APP_HOME_CONTENT_CLOSE)
end

M.GetShowTypeField = function(self)
	return gClientConst.PhoneAppShowTypeLevel.SecondLevel
end
