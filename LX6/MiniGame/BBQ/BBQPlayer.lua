-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\BBQ\BBQPlayer.lua
-- Decompiled from: 00665_BBQPlayer.lua_85d1a6e20d42.luajit

gBBQPlayer = DefClass("BBQPlayer", gBBQPlayer)
local BBQPlayer = gBBQPlayer

BBQPlayer.ctor = function(self)
	self.playerId = -1
	self.isMe = false
	self.isAI = false
	self.totalScore = 0
	self.singleAddScore = 0
	self.inputPosition = {
		["\\xd5"] = 0,
		["\\xd4"] = 0
	}
	self.canRaycast = true
	self.hasRaycastPart = false
	self.hasEnterDrag = false
	self.draggedPartId = -1
	self.raycastPartId = -1
	self.raycastTargetType = -1
	self.pressTargetType = nil
	self.pressPartId = nil
	self.hasPressTarget = nil
end

BBQPlayer.Initialize = function(self, playerId, isMe, isAI)
	self.playerId = playerId
	self.isMe = isMe
	self.isAI = isAI
	self.totalScore = 0
	self.singleAddScore = 0
	self.inputPosition = {
		["\\xd5"] = 0,
		["\\xd4"] = 0
	}
	self.canRaycast = true
	self.hasRaycastPart = false
	self.hasEnterDrag = false
	self.draggedPartId = -1
	self.raycastPartId = -1
	self.raycastTargetType = -1
	self.pressTargetType = nil
	self.pressPartId = nil
	self.hasPressTarget = nil
end

BBQPlayer.Reset = function(self)
	self.totalScore = 0
	self.singleAddScore = 0
	self.inputPosition = {
		["\\xd5"] = 0,
		["\\xd4"] = 0
	}
	self.canRaycast = true
	self.hasRaycastPart = false
	self.hasEnterDrag = false
	self.draggedPartId = -1
	self.raycastPartId = -1
	self.raycastTargetType = -1
	self.pressTargetType = nil
	self.pressPartId = nil
	self.hasPressTarget = nil
end
