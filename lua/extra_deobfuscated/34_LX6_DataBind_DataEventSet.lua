local M = DefClass("C_DataEventSet", C_DataEventSet)

function M:ctor()
	self.dataCells = {}
	self.msgEvents = {}
end

function M:BindHandler(dataSet, bindName, bindFunc, param, callInstants)
	if callInstants == nil then
		callInstants = true
	end

	local cell = dataSet:BindHandler(bindName, bindFunc)
	cell.param = param
	self.dataCells[#self.dataCells + 1] = cell

	if callInstants then
		cell:Call()
	end

	return cell
end

function M:BindHandler2(bindDatas, bindFunc, param, callInstants)
	if callInstants == nil then
		callInstants = true
	end

	for i = 1, #bindDatas, 2 do
		local cell = bindDatas[i]:BindHandler(bindDatas[i + 1], bindFunc)
		cell.param = param
		self.dataCells[#self.dataCells + 1] = cell
	end

	if callInstants then
		self.dataCells[#self.dataCells]:Call()
	end
end

function M:Clear(isDestroy)
	for i = 1, #self.dataCells do
		self.dataCells[i]:Destroy()
	end

	for i, v in pairs(self.msgEvents) do
		gMessageManager:RemoveMessageListener(v.eventid, v.func)
	end

	if isDestroy then
		self.dataCells = nil
		self.msgEvents = nil
	else
		self.dataCells = {}
		self.msgEvents = {}
	end
end

function M:Destroy()
	self:Clear(true)
end

function M:RegisterSingleEvent(enentId, func)
	self.msgEvents[#self.msgEvents + 1] = {
		eventid = enentId,
		func = func
	}

	gMessageManager:AddMessageListener(enentId, func)
end

function M:RegisterEvents(eventHandlers)
	for k, v in pairs(eventHandlers) do
		self:RegisterSingleEvent(k, v)
	end
end

C_DataEventSet = M
