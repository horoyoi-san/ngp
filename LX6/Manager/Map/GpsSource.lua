-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\GpsSource.lua
-- Decompiled from: 00192_GpsSource.lua_6f7a4acc6386.luajit

local bit = require("bit")
local _Static = {}
GpsSource = DefClass("GpsSource", GpsSource, nil, _Static)
local M = GpsSource

_Static.CreateCommon = function(name, interest, gateInterest)
	local source = M.New()

	source.Init(source, name, interest, gateInterest)

	return source
end

M.Init = function(self, gId, interest, gateInterest)
	self.gId = gId
	self.interest = interest
	self.elems = {}
	self.visibleElems = {}
	self.listeners = {}
	self.gateInterest = gateInterest
end

M.AddElement = function(self, instanceId)
	if self.elems[instanceId] then
		gGpsTools.Assert(gGpsModule.SafeAssert, "Element exist", instanceId, self.gId)

		return
	end

	local element = gMapSystem.container:Get(instanceId)

	if not element then
		gGpsTools.Assert(gGpsModule.SafeAssert, "Can't get Element from container", instanceId, self.gId)

		return
	end

	if element.fData.interestOnly and not self.interest then
		gGpsTools.Assert(gGpsModule.SafeAssert, "Element is interest only, can't add to non-interest source", instanceId, self.gId)

		return
	end

	element._belongSources[self.gId] = self
	self.elems[instanceId] = element
	local visible = element.IsVisible(element)

	if visible then
		self.visibleElems[instanceId] = element

		self.NotifyAdd(self, element)
	end
end

M.RemoveElement = function(self, instanceId)
	local element = self.elems[instanceId]

	if not element then
		gGpsTools.Assert(gGpsModule.SafeAssert, "Element not exist", gGpsTools.GetGpsDebugDesc(instanceId), self.gId)

		return
	end

	self.elems[instanceId] = nil

	if self.visibleElems[instanceId] then
		self.visibleElems[instanceId] = nil

		self.NotifyRemove(self, element)
	end

	element._belongSources[self.gId] = nil
end

M.ClearAllElement = function(self)
	for instanceid, _ in pairs(self.elems) do
		self.RemoveElement(self, instanceid)
	end
end

M.AddListener = function(self, listener)
	if not array.contains(self.listeners, listener) then
		table.insert(self.listeners, listener)
	end

	local viewMask = listener.cfg.viewMask

	for _, elem in pairs(self.visibleElems) do
		if elem.CheckViewMask(elem, viewMask) then
			listener.AddBySource(listener, elem.instanceId, self.gId)
		end
	end
end

M.RemoveListener = function(self, listener)
	local index = array.index_of(self.listeners, listener)

	if index <= 0 then
		table.remove(self.listeners, index)
	end

	local viewMask = listener.cfg.viewMask

	for _, elem in pairs(self.visibleElems) do
		if elem.CheckViewMask(elem, viewMask) then
			listener.RemoveBySource(listener, elem.instanceId, self.gId)
		end
	end
end

M.NotifyAdd = function(self, element, viewMask)
	if self.listeners then
		for _, listener in ipairs(self.listeners) do
			if element.CheckViewMask(element, listener.cfg.viewMask) then
				listener.AddBySource(listener, element.instanceId, self.gId)
			end
		end
	end
end

M.NotifyRemove = function(self, element)
	if self.listeners then
		for _, listener in ipairs(self.listeners) do
			if element.CheckViewMask(element, listener.cfg.viewMask) then
				listener.RemoveBySource(listener, element.instanceId, self.gId)
			end
		end
	end
end

M.GetAllElements = function(self, viewMask, output)
	local ret = output or {}

	for _, elem in pairs(self.elems) do
		if elem.VisibleOn(elem, viewMask) then
			ret[elem.instanceId] = elem
		end
	end

	return ret
end

M.ElementVisibleChanged = function(self, element)
	local instanceId = element.instanceId

	if not self.elems[instanceId] then
		gGpsTools.Assert(gGpsModule.SafeAssert, "Element not exist", element.instanceId, self.gId)

		return
	end

	if element.IsVisible(element) then
		if not self.visibleElems[instanceId] then
			self.visibleElems[instanceId] = element

			self.NotifyAdd(self, element)
		end
	elseif self.visibleElems[instanceId] then
		self.visibleElems[instanceId] = nil

		self.NotifyRemove(self, element)
	end
end

M.ElementViewMaskChanged = function(self, element, oldViewMask, newViewMask)
	local instanceId = element.instanceId

	if not self.elems[instanceId] then
		gGpsTools.Assert(gGpsModule.SafeAssert, "Element not exist", element.instanceId, self.gId)

		return
	end

	if not element.IsVisible(element) then
		return
	end

	for _, listener in ipairs(self.listeners) do
		local viewMask = listener.cfg.viewMask
		local matched = bit.band(viewMask, oldViewMask) == 0
		local newMatched = bit.band(viewMask, newViewMask) == 0

		if matched and not newMatched then
			listener.RemoveBySource(listener, instanceId, self.gId)
		elseif not matched and newMatched then
			listener.AddBySource(listener, instanceId, self.gId)
		end
	end
end
