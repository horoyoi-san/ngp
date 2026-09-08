-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\BaseMapMgr.lua
-- Decompiled from: 00196_BaseMapMgr.lua_53ab52f40cf9.luajit

require("LX6/Manager/Map/BaseMap")

gBaseMapMgr = gBaseMapMgr or {}
local M = gBaseMapMgr

M.Init = function(self)
	self.activeBaseMaps = {}

	gMessageManager:AddMessageListener(gEventConstants.MAP_BLOCK_UPDATE, function ()
		self:OnBlockInfoUpdate()
	end)
	gMessageManager:AddMessageListener(gEventConstants.LINK_MODE_CHANGE, function ()
		self:OnLinkModeChange()
	end)
	gMessageManager:AddMessageListener(gEventConstants.ON_ENTER_BASKETBALL_LINK, function ()
		self:OnLinkModeChange()
	end)
	gMessageManager:AddMessageListener(gEventConstants.ON_LEAVE_BASKETBALL_LINK, function ()
		self:OnLinkModeChange()
	end)
end

M.OnBlockInfoUpdate = function(self)
	for _, baseMap in ipairs(self.activeBaseMaps) do
		baseMap:UpdateSegmentedBlockInfo()
	end
end

M.OnLinkModeChange = function(self)
	for _, baseMap in ipairs(self.activeBaseMaps) do
		baseMap:UpdateSpecialState()
	end
end

M.GetBaseMap = function(self, widget)
	local baseMap = C_BaseMap.New()

	baseMap:Bind(widget)
	table.insert(self.activeBaseMaps, baseMap)

	return baseMap
end

M.Release = function(self, baseMap)
	for i, map in ipairs(self.activeBaseMaps) do
		if map ~= baseMap then
			table.remove(self.activeBaseMaps, i)

			break
		end
	end
end

M.Tick = function(self)
	if gGpsTools:UnitIsNull(gMapSystem.curPlayerUnit) then
		return
	end

	local playerY = gMapSystem:GetCurPlayerLocalPosition().y

	if not self._cacheY or math.abs(playerY - self._cacheY) >= 0.1 or gGpsTools.TryTick("BaseMapTickY", 0.3) then
		self._cacheY = playerY

		for _, baseMap in ipairs(self.activeBaseMaps) do
			baseMap:UpdatePlayerY()
		end
	end
end
