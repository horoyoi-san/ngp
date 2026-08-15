C_MajiangLoadingPanelStore = DefClass("C_MajiangLoadingPanelStore", C_MajiangLoadingPanelStore, C_StoreGroup)
GroupName2Class.MajiangLoadingPanelStore = C_MajiangLoadingPanelStore
local M = C_MajiangLoadingPanelStore

function M:ctor()
	return
end

function M:OnAwake()
	return
end

function M:OnShow(panelId, data)
	if not gMaJiangManager.roomInfo then
		return
	end
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
