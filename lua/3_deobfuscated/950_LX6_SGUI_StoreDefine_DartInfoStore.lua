C_DartInfoStore = DefClass("C_DartInfoStore", C_DartInfoStore, C_StoreGroup)
GroupName2Class.DartInfoStore = C_DartInfoStore
local M = C_DartInfoStore

function M:ctor()
	return
end

function M:OnAwake()
	self.bindData.BtnExit.luaClick = self:CreateAction("OnExitBtn")
end

function M:OnExitBtn()
	gPanelManager:Close(gPanelId.S_DART_INFO)
end

function M:OnEnable()
	return
end

function M:OnStart()
	return
end

function M:OnDisable()
	return
end

function M:OnDestroy()
	return
end

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	return
end

function M:OnShow(panelId, data)
	return
end

function M:OnClose()
	return
end
