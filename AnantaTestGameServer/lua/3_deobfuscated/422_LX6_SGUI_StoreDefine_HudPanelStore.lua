C_HudPanelStore = DefClass("C_HudPanelStore", C_HudPanelStore, C_StoreGroup)
GroupName2Class.HudPanelStore = C_HudPanelStore
local M = C_HudPanelStore

function M:ctor()
	require("LX6/Manager/HUD/HudMgr")
	require("LX6/Manager/HUD/HudConst")
	gHudMgr:OnInit()
end

function M:OnShow()
	gHudMgr:CreateMySpiritHUD()
end

function M:OnUpdate()
	if gHudMgr.needUpdateCount > 0 then
		gHudMgr:Update()
	end
end

function M:OnDestroy()
	gHudMgr:ReleasePool()
end
