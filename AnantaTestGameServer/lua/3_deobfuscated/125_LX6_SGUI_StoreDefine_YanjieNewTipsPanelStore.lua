C_YanjieNewTipsPanelStore = DefClass("C_YanjieNewTipsPanelStore", C_YanjieNewTipsPanelStore, C_StoreGroup)
GroupName2Class.YanjieNewTipsPanelStore = C_YanjieNewTipsPanelStore
local M = C_YanjieNewTipsPanelStore

function M:ctor()
	return
end

function M:OnAwake()
	self.bindData.hitBtn.luaClick = self:CreateAction(self.OnItemClick)
end

function M:OnDestroy()
	self.autoCloseCo = coroutine.stop(self.autoCloseCo)
end

function M:OnShow(panelId, args)
	self.panelId = panelId

	self:InitModel(args)
	self:InitView()
end

function M:InitModel(args)
	self.areaIndex = args and args.areaIndex
end

function M:InitView()
	self.autoCloseCo = coroutine.start(function ()
		coroutine.wait(3)
		self:ClosePanel()
	end)
end

function M:ClosePanel()
	gPanelManager:Close(self.panelId)
end

function M:OnItemClick()
	gMainPhoneFunctionAction.OpenSocialNetwork()
	self:ClosePanel()
end
