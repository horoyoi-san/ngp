-- Original chunk: @Lua\LuaFiles\LX6\Manager\House\HouseContext.lua
-- Decompiled from: 00740_HouseContext.lua_4340ca67ea29.luajit

C_HouseContext = DefClass("C_HouseContext", C_HouseContext)
local M = C_HouseContext

local _NewPendingChanges = function()
	return {
		added = {},
		changed = {},
		removed = {}
	}
end

local _NewPendingWallChanges = function()
	return {
		edges = {},
		nodes = {},
		changedEdgeTex = {},
		changedFloorTex = {},
		changedCeilingTex = {},
		fenestrations = {}
	}
end

M.ctor = function(self)
	self.houseId = 0
	self.indoorId = 0
	self.buildCfg = nil
	self.serverSyncState = {}
	self.showcaseCache = {}
	self.isShowcaseCacheInited = false
	self.pendingChanges = _NewPendingChanges()
	self.pendingWallChanges = _NewPendingWallChanges()
	self.isLoaded = false
	self.loadedHouseDataID = 0
	self.isWallSyncing = false
	self.syncToken = 0
end

M.Init = function(self, houseId, indoorId, buildCfg)
	self.houseId = houseId or 0
	self.indoorId = indoorId or 0
	self.buildCfg = buildCfg
end

M.GetHouseRoot = function(self)
	return gHouseSceneLayout:GetHouseRootGo(self.houseId)
end

M.GetGridSystemProxy = function(self)
	local houseRoot = self.GetHouseRoot(self)

	if not houseRoot or gCS.LuaUtils.IsNull(houseRoot) then
		return nil
	end

	return houseRoot.GetComponent(houseRoot, typeof(LX6.GamePlay.House.LuaGridSystemProxy))
end

M.ClearPendingChanges = function(self)
	self.pendingChanges = _NewPendingChanges()
end

M.ClearPendingWallChanges = function(self)
	self.pendingWallChanges = _NewPendingWallChanges()
end

M.ClearServerMirrors = function(self)
	self.serverSyncState = {}
	self.showcaseCache = {}
	self.isShowcaseCacheInited = false
end

M.Reset = function(self)
	self.ClearPendingChanges(self)
	self.ClearPendingWallChanges(self)
	self.ClearServerMirrors(self)

	self.loadedHouseDataID = 0
	self.isWallSyncing = false
	self.syncToken = self.syncToken + 1
end

M.Destroy = function(self)
	self:Reset()
	gHouseSceneLayout:DestroyHouseNamespace(self.houseId)

	self.isLoaded = false
end
