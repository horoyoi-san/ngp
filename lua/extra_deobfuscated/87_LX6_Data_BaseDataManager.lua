require("LX6/Data/BaseData")

C_BaseDataManager = DefClass("C_BaseDataManager", C_BaseDataManager)
local BaseDataManager = C_BaseDataManager

function BaseDataManager:ctor()
	self.__DataList = {}

	self:DefineData()
	self:DefineEvents()
end

function BaseDataManager:Init()
	for i = 1, #self.__DataList do
		local data = self.__DataList[i]

		data:Init()
	end

	for eventId, handler in pairs(self.EventHandler) do
		self:RegisterEvents(eventId, handler)
	end
end

function BaseDataManager:Dispose()
	for eventId, handler in pairs(self.EventHandler) do
		self:UnregisterEvents(eventId, handler)
	end

	self.EventHandler = {}

	for i = 1, #self.__DataList do
		local data = self.__DataList[i]

		data:Dispose()
	end

	self.__DataList = {}
end

function BaseDataManager:DefineData()
	return
end

function BaseDataManager:DefineEvents()
	self.EventHandler = {}
end

function BaseDataManager:AddData(data)
	table.insert(self.__DataList, data)
end

function BaseDataManager:RegisterEvents(eventId, handler)
	gMessageManager:AddMessageListener(eventId, handler)
end

function BaseDataManager:UnregisterEvents(eventId, handler)
	gMessageManager:RemoveMessageListener(eventId, handler)
end
