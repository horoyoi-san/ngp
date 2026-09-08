-- Original chunk: @Lua\LuaFiles\LX6\Guide\Resource\CheckBigMapSelect.lua
-- Decompiled from: 00459_CheckBigMapSelect.lua_4f7532561e2b.luajit

C_GuideBT_CheckBigMapSelect = DefClass("C_GuideBT_CheckBigMapSelect", C_GuideBT_CheckBigMapSelect, C_GuideBT_ResourceBase)
local M = C_GuideBT_CheckBigMapSelect

M.OnCreate = function(self)
	self.mapStore = gStoreManager:GetStoreGroup("NewMapPanelStore")
end

M.Eval = function(self)
	if not self.mapStore then
		self.mapStore = gStoreManager:GetStoreGroup("NewMapPanelStore")
	end

	self.isGpsIdMatch.val = self.mapStore and self.mapStore.selectedGpsId and self.mapStore.selectedGpsId ~= self.gpsId:Eval()
end
