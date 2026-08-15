C_BaseData = DefClass("C_BaseData", C_BaseData)
local BaseData = C_BaseData

function BaseData:ctor(dataMgr)
	self.DataMgr = dataMgr

	self:DefineData()
	self:DefineEvents()
	self.DataMgr:AddData(self)
end

function BaseData:Init()
	for eventId, handler in pairs(self.EventHandler) do
		self.DataMgr:RegisterEvents(eventId, handler)
	end

	self:OnInit()
end

function BaseData:Dispose()
	for eventId, handler in pairs(self.EventHandler) do
		self.DataMgr:UnregisterEvents(eventId, handler)
	end

	self:OnDispose()
end

function BaseData:DefineData()
	return
end

function BaseData:DefineEvents()
	self.EventHandler = {}
end

function BaseData:OnInit()
	return
end

function BaseData:OnDispose()
	return
end
