-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PoliceBasePanelStore.lua
-- Decompiled from: 02082_PoliceBasePanelStore.lua_64a7c51cf34b.luajit

C_PoliceBasePanelStore = DefClass("C_PoliceBasePanelStore", C_PoliceBasePanelStore, C_PhoneAppBaseStackStoreGroup)
GroupName2Class.PoliceBasePanelStore = C_PoliceBasePanelStore
local M = C_PoliceBasePanelStore

M.ctor = function(self)
	self.mgr = gPoliceJobManager.panelMgr
end

M.OnAwake = function(self)
	self.bindData.tabRect.OnRenderTab = self.CreateAction(self, self.OnRenderTab)
	self.bindData.backGround.luaClick = self.CreateAction(self, self.OnExitClick)
	self.bindData.backBtn.luaClick = self.CreateAction(self, "CloseCurrentPanel", self.mgr)
	self.currentTabStore = nil
end

M.GetMessageEvents = function(self)
	return {
		[gEventConstants.ON_PHONE_CALL_CONTENT_SHOW] = function (_, args)
			self:ShowContentPanel(args)
		end,
		[gEventConstants.ON_PHONE_CALL_CONTENT_CLOSE] = function (_, args)
			self:CloseContentPanel(args)
		end
	}
end

M.OnRenderTab = function(self, index, widget)
	local showType = index
	local stackInfo = self.stackPanel:Peek()

	if self:GetShowType(stackInfo) ~= showType then
		local store = gStoreManager:GetStoreGroup(widget.Store)
		stackInfo.panelId = self.panelId

		store:ShowPanel(stackInfo)

		if store.RefreshPage then
			store.RefreshPage(store)
		end

		self.currentTabStore = store
	end
end

M.InitModel = function(self, args)
	gPoliceJobManager.panelMgr:OnPanelInit()
	M.base.InitModel(self, args)
end

M.InitView = function(self, args)
	M.base.InitView(self, args)
end

M.OnExitClick = function(self)
	self.mgr:CloseCurrentPanel()
end

M.RefreshPage = function(self)
	if not self.STATE_EnableOnce then
		return
	end

	if self.currentTabStore and self.currentTabStore.RefreshPage then
		self.currentTabStore:RefreshPage()
	end
end

M.OnExecuteExitAction = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_PHONE_APP_HOME_CONTENT_CLOSE)
end

M.GetShowTypeField = function(self)
	return gClientConst.PhoneAppShowTypeLevel.SecondLevel
end

M.ClearData = function(self)
	if not self.mgr.successGoToTrial then
		self.mgr:TriggerSpoonEndTrial()
	end
end
