-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\BBQ\BBQSauceBowl.lua
-- Decompiled from: 00667_BBQSauceBowl.lua_7b1d3d606092.luajit

gBBQSauceBowl = DefClass("BBQSauceBowl", gBBQSauceBowl)
local BBQSauceBowl = gBBQSauceBowl

BBQSauceBowl.ctor = function(self, playerId, transform)
	self.playerId = playerId
	self.transform = transform
	self.gameObject = transform.gameObject
	self.position = transform.position
end
