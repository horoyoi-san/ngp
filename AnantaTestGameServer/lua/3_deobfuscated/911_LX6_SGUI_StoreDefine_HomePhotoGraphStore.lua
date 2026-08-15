C_HomePhotoGraphStore = DefClass("C_HomePhotoGraphStore", C_HomePhotoGraphStore, C_StoreGroup)
GroupName2Class.HomePhotoGraphStore = C_HomePhotoGraphStore
local M = C_HomePhotoGraphStore

function M:ctor()
	return
end

function M:OnAwake()
	return
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

local MAX_COUNT = 8

function M:OnShow(panelId, data)
	if not data or not data.paths then
		print_error("HomePhotoGraphStore:OnShow data is nil")
		gPanelManager:Close(self.m_Id)

		return
	end

	local maxCount = data.count and math.min(data.count, MAX_COUNT) or MAX_COUNT

	for i = 1, maxCount do
		local path = "imageUrl" .. i
		self.bindData[path] = data.paths[i] and data.paths[i] or ""
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
