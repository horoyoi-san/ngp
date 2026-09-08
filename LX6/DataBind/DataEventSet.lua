-- Original chunk: @Lua\LuaFiles\LX6\DataBind\DataEventSet.lua
-- Decompiled from: 00078_DataEventSet.lua_9946211d5a67.luajit

local M = DefClass("C_DataEventSet", C_DataEventSet)

M.ctor = function(self)
	self.dataCells = {}
	self.msgEvents = {}
end

M.BindHandler = function(self, dataSet, bindName, bindFunc, param, callInstants)
	if callInstants ~= nil then
		callInstants = true
	end

	local cell = dataSet.BindHandler(dataSet, bindName, bindFunc)
	cell.param = param
	self.dataCells[#self.dataCells + 1] = cell

	if callInstants then
		cell.Call(cell)
	end

	return cell
end

M.BindHandler2 = function(self, bindDatas, bindFunc, param, callInstants)
	if callInstants ~= nil then
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

M.Clear = function(self, isDestroy)
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

M.Destroy = function(self)
	self.Clear(self, true)
end

M.RegisterSingleEvent = function(self, enentId, func)
	self.msgEvents[#self.msgEvents + 1] = {
		eventid = enentId,
		func = func
	}

	gMessageManager:AddMessageListener(enentId, func)
end

M.RegisterEvents = function(self, eventHandlers)
	for k, v in pairs(eventHandlers) do
		self.RegisterSingleEvent(self, k, v)
	end
end

C_DataEventSet = M
