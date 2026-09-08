-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\BBQ\BBQPlate.lua
-- Decompiled from: 00666_BBQPlate.lua_02094f46dbfb.luajit

gBBQPlate = DefClass("BBQPlate", gBBQPlate)
local BBQPlate = gBBQPlate

BBQPlate.ctor = function(self, id, transform)
	self.id = id
	self.transform = transform
	self.gameObject = transform.gameObject
	self.position = transform.position
end
