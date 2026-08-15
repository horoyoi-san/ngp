C_PartySelectPanelStore = DefClass("C_PartySelectPanelStore", C_PartySelectPanelStore, C_PhoneAppBaseStackStoreGroup)
GroupName2Class.PartySelectPanelStore = C_PartySelectPanelStore
local M = C_PartySelectPanelStore

function M:ctor()
	return
end

function M:OnAwake()
	self.bindData.tabRect.OnRenderTab = self:CreateAction("OnRenderTab")
	self.bindData.fullScreenButton.luaClick = self:CreateAction("OnExitClick")
	self.bindData.exitButton.luaClick = self:CreateAction("CloseContentPanel")
end

function M:GetMessageEvents()
	return {
		[gEventConstants.ON_PARTY_CONTENT_SHOW] = function (_, args)
			self:ShowContentPanel(args)
		end,
		[gEventConstants.ON_PARTY_CONTENT_HIDE] = function (_, args)
			self:CloseContentPanel(args)
		end
	}
end

function M:InitModel(args)
	M.base.InitModel(self, args)

	self.panelId = args.panelId
end

function M:InitView(args)
	M.base.InitView(self, args)
end

function M:OnRenderTab(index, widget)
	if self.panelArgs then
		gClientUtils.InitNavAreasInChildren(widget, self.panelId)
	end

	M.base.OnRenderTab(self, index, widget)
end

function M:OnExitClick()
	self:OnExit()
end

function M:OnExecuteExitAction()
	gMessageManager:SendMessage(gEventConstants.ON_PHONE_APP_HOME_CONTENT_CLOSE)
end

function M:GetShowTypeField()
	return gClientConst.PhoneAppShowTypeLevel.SecondLevel
end
