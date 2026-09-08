-- Original chunk: @Lua\LuaFiles\LX6\Data\BaseDataManager.lua
-- Decompiled from: 00086_BaseDataManager.lua_824173c4cd6e.luajit

require("LX6/Data/BaseData")

C_BaseDataManager = DefClass("C_BaseDataManager", C_BaseDataManager)
local BaseDataManager = C_BaseDataManager

BaseDataManager.ctor = function(self)
	self.__DataList = {}

	self.DefineData(self)
	self.DefineEvents(self)
end

BaseDataManager.Init = function(self)
	for i = 1, #self.__DataList do
		local data = self.__DataList[i]

		data.Init(data)
	end

	for eventId, handler in pairs(self.EventHandler) do
		self.RegisterEvents(self, eventId, handler)
	end
end

BaseDataManager.Dispose = function(self)
	for eventId, handler in pairs(self.EventHandler) do
		self.UnregisterEvents(self, eventId, handler)
	end

	self.EventHandler = {}

	for i = 1, #self.__DataList do
		local data = self.__DataList[i]

		data.Dispose(data)
	end

	self.__DataList = {}
end

BaseDataManager.DefineData = function(self)
end

BaseDataManager.DefineEvents = function(self)
	self.EventHandler = {}
end

BaseDataManager.AddData = function(self, data)
	table.insert(self.__DataList, data)
end

BaseDataManager.RegisterEvents = function(self, eventId, handler)
	gMessageManager:AddMessageListener(eventId, handler)
end

BaseDataManager.UnregisterEvents = function(self, eventId, handler)
	gMessageManager:RemoveMessageListener(eventId, handler)
end
