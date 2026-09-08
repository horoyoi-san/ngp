-- Original chunk: @Lua\LuaFiles\LX6\Data\BaseData.lua
-- Decompiled from: 00085_BaseData.lua_75e3a0ba9491.luajit

C_BaseData = DefClass("C_BaseData", C_BaseData)
local BaseData = C_BaseData

BaseData.ctor = function(self, dataMgr)
	self.DataMgr = dataMgr

	self:DefineData()
	self:DefineEvents()
	self.DataMgr:AddData(self)
end

BaseData.Init = function(self)
	for eventId, handler in pairs(self.EventHandler) do
		self.DataMgr:RegisterEvents(eventId, handler)
	end

	self.OnInit(self)
end

BaseData.Dispose = function(self)
	for eventId, handler in pairs(self.EventHandler) do
		self.DataMgr:UnregisterEvents(eventId, handler)
	end

	self.OnDispose(self)
end

BaseData.DefineData = function(self)
end

BaseData.DefineEvents = function(self)
	self.EventHandler = {}
end

BaseData.OnInit = function(self)
end

BaseData.OnDispose = function(self)
end
