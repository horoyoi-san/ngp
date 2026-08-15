local FactionConfig = LTConfig.FactionConfig
C_GangExpandedHUDStore = DefClass("C_GangExpandedHUDStore", C_GangExpandedHUDStore, C_StoreGroup)
GroupName2Class.GangExpandedHUDStore = C_GangExpandedHUDStore
local M = C_GangExpandedHUDStore

function M:ctor()
	return
end

function M:OnAwake()
	return
end

function M:OnExit()
	gPanelManager:Close(gPanelId.GANG_EXPANDED)
end

function M:OnShow(panelId, data)
	local factionId = data and data.factionId or 0
	local cfg = FactionConfig.GetConfig(factionId)

	if not cfg then
		print_error("[GangExpandedHUDStore] factionId不存在，factionId为：", factionId)
	end

	self.bindData.iconId = cfg.imageId
	self.bindData.nameLabel = cfg.name
	self.timer = Timer.New(function ()
		self:OnExit()
	end, FactionConfig.FactionPopupProgressDuration):Start()
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
