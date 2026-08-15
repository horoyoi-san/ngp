require("LX6/Manager/Map/BaseMap")

gBaseMapMgr = gBaseMapMgr or {}
local M = gBaseMapMgr

function M:Init()
	self.activeBaseMaps = {}

	gMessageManager:AddMessageListener(gEventConstants.MAP_BLOCK_UPDATE, function ()
		self:OnBlockInfoUpdate()
	end)
end

function M:OnBlockInfoUpdate()
	for _, baseMap in ipairs(self.activeBaseMaps) do
		baseMap:UpdateSegmentedBlockInfo()
	end
end

function M:GetBaseMap(widget)
	local baseMap = C_BaseMap.New()

	baseMap:Bind(widget)
	table.insert(self.activeBaseMaps, baseMap)

	return baseMap
end

function M:Release(baseMap)
	for i, map in ipairs(self.activeBaseMaps) do
		if map == baseMap then
			table.remove(self.activeBaseMaps, i)

			break
		end
	end
end

function M:Tick()
	if L50.L50App.Scene.GamePlayUtils:UnitIsNull(gCS.MyPlayerManager.PlayerUnit) then
		return
	end

	local playerY = gCS.MyPlayerManager.PlayerUnit.LocalPosition.y

	if not self._cacheY or math.abs(playerY - self._cacheY) > 0.1 or gGpsTools.TryTick("BaseMapTickY", 0.3) then
		self._cacheY = playerY

		for _, baseMap in ipairs(self.activeBaseMaps) do
			baseMap:UpdatePlayerY()
		end
	end
end
