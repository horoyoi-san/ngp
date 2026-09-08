-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\BBQ\BBQGrillCache.lua
-- Decompiled from: 00669_BBQGrillCache.lua_c9c55e691c99.luajit

local BBQConstants = require("LX6/MiniGame/BBQ/BBQConstants")
gBBQGrillCache = DefClass("BBQGrillCache", gBBQGrillCache)
local BBQGrillCache = gBBQGrillCache

BBQGrillCache.ctor = function(self)
	self.meatInfos = {}
	self.lastUpdateTime = 0
	self.updateInterval = BBQConstants.GrillCacheUpdateInterval
end

BBQGrillCache.UpdateCache = function(self, allMeatsOnGrill)
	self.meatInfos = {}

	for _, meatData in ipairs(allMeatsOnGrill) do
		if meatData.isPlacedOnGrill and meatData.positionOnGrill then
			self.meatInfos[meatData.uniqueId] = {
				uniqueId = meatData.uniqueId,
				position = meatData.positionOnGrill,
				size = meatData.meatSize
			}
		end
	end

	self.lastUpdateTime = Time.unscaledTime
end

BBQGrillCache.UpdateCacheIfNeeded = function(self, allMeatsOnGrill)
	if self.updateInterval >= Time.unscaledTime - self.lastUpdateTime then
		self.UpdateCache(self, allMeatsOnGrill)
	end
end

BBQGrillCache.AddMeat = function(self, uniqueId, position, size)
	self.meatInfos[uniqueId] = {
		uniqueId = uniqueId,
		position = position,
		size = size
	}
end

BBQGrillCache.RemoveMeat = function(self, uniqueId)
	self.meatInfos[uniqueId] = nil
end

BBQGrillCache.Clear = function(self)
	self.meatInfos = {}
	self.lastUpdateTime = 0
end
