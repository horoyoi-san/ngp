-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\HomePhotoGraphStore.lua
-- Decompiled from: 01720_HomePhotoGraphStore.lua_05bc4914cbe9.luajit

C_HomePhotoGraphStore = DefClass("C_HomePhotoGraphStore", C_HomePhotoGraphStore, C_StoreGroup)
GroupName2Class.HomePhotoGraphStore = C_HomePhotoGraphStore
local M = C_HomePhotoGraphStore

M.ctor = function(self)
end

M.OnAwake = function(self)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

local MAX_COUNT = 8

M.OnShow = function(self, panelId, data)
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

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end
