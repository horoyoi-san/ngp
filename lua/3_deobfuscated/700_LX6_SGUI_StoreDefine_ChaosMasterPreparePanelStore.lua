C_ChaosMasterPreparePanelStore = DefClass("C_ChaosMasterPreparePanelStore", C_ChaosMasterPreparePanelStore, C_StoreGroup)
GroupName2Class.ChaosMasterPreparePanelStore = C_ChaosMasterPreparePanelStore
local M = C_ChaosMasterPreparePanelStore

function M:ctor()
	self.areaName = {
		[0] = "S_ChaosMasterTeamPanel",
		"S_ChaosMasterTeamEditPanel",
		"S_ChaosGenreDetailPanel"
	}
end

function M:DefineAllVariables()
	return
end

function M:OnAwake()
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()
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
	gBattlePetsMgr:SetChaosMasterPrepareTab(gBattlePetsMgr.PreparePanelTab.Team)
end

function M:OnClose()
	return
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end

function M:GenMessageEvents()
	return
end

function M:RegisterWidget()
	self.bindData.tab.OnRenderTab = self:CreateAction("OnTabRender")
end

function M:OnTabRender(index, widget)
	self.curPanel = gStoreManager:GetStoreGroup(widget.Store)

	gCS.LuaUtils.SetCachedAreaPanelId(self.areaName[index], gPanelId.CHAOS_MASTER_PREPARE_PANEL)

	if self.curPanel and self.needOnShow then
		self.curPanel:OnShow(nil, self.panelData)
	end
end

function M:SetChaosMasterPrepareTab(index, data, needOnShow)
	if needOnShow == nil then
		needOnShow = true
	end

	self.needOnShow = needOnShow
	self.panelData = data
	self.bindData.tab.selectedIndex = index
end
