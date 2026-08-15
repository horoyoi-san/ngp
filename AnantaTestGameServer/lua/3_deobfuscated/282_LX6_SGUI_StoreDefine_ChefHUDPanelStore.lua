C_ChefHUDPanelStore = DefClass("C_ChefHUDPanelStore", C_ChefHUDPanelStore, C_StoreGroup)
GroupName2Class.ChefHUDPanelStore = C_ChefHUDPanelStore
local M = C_ChefHUDPanelStore

function M:ctor()
	return
end

function M:DefineAllVariables()
	return
end

function M:OnAwake()
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()
end

function M:OnShow(panelId, data)
	gPanelManager:CheckShow(gPanelId.S_CHEF_BAG_PANEL)
end

function M:OnClose()
	gPanelManager:Close(gPanelId.S_CHEF_BAG_PANEL)
end

function M:GenMessageEvents()
	return
end

function M:RegisterWidget()
	return
end
