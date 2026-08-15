C_PoliceBasePanelStore = DefClass("C_PoliceBasePanelStore", C_PoliceBasePanelStore, C_PhoneAppBaseStackStoreGroup)
GroupName2Class.PoliceBasePanelStore = C_PoliceBasePanelStore
local M = C_PoliceBasePanelStore

function M:ctor()
	self.mgr = gPoliceJobManager.panelMgr
end

function M:OnAwake()
	self.bindData.tabRect.OnRenderTab = self:CreateAction(self.OnRenderTab)
	self.bindData.backGround.luaClick = self:CreateAction(self.OnExitClick)
	self.bindData.backBtn.luaClick = self:CreateAction("CloseCurrentPanel", self.mgr)
	self.currentTabStore = nil
end

function M:GetMessageEvents()
	return {
		[gEventConstants.ON_PHONE_CALL_CONTENT_SHOW] = function (_, args)
			self:ShowContentPanel(args)
		end,
		[gEventConstants.ON_PHONE_CALL_CONTENT_CLOSE] = function (_, args)
			self:CloseContentPanel(args)
		end
	}
end

function M:OnRenderTab(index, widget)
	local showType = index
	local stackInfo = self.stackPanel:Peek()

	if self:GetShowType(stackInfo) == showType then
		local store = gStoreManager:GetStoreGroup(widget.Store)
		stackInfo.panelId = self.panelId

		store:ShowPanel(stackInfo)

		if store.RefreshPage then
			store:RefreshPage()
		end

		self.currentTabStore = store
	end
end

function M:InitModel(args)
	gPoliceJobManager.panelMgr:OnPanelInit()
	M.base.InitModel(self, args)
end

function M:InitView(args)
	M.base.InitView(self, args)
end

function M:OnExitClick()
	self.mgr:CloseCurrentPanel()
end

function M:RefreshPage()
	if not self.STATE_EnableOnce then
		return
	end

	if self.currentTabStore and self.currentTabStore.RefreshPage then
		self.currentTabStore:RefreshPage()
	end
end

function M:OnExecuteExitAction()
	gMessageManager:SendMessage(gEventConstants.ON_PHONE_APP_HOME_CONTENT_CLOSE)
end

function M:GetShowTypeField()
	return gClientConst.PhoneAppShowTypeLevel.SecondLevel
end
