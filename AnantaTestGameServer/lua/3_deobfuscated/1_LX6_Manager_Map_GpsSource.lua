local bit = require("bit")
local _Static = {}
GpsSource = DefClass("GpsSource", GpsSource, nil, _Static)
local M = GpsSource

function _Static.CreateCommon(name, interest)
	local source = M.New()

	source:Init(name, interest)

	return source
end

function M:Init(gId, interest)
	self.gId = gId
	self.interest = interest
	self.elems = {}
	self.visibleElems = {}
	self.listeners = {}
end

function M:AddElement(instanceId)
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
	local visible = element:IsVisible()

	if visible then
		self.visibleElems[instanceId] = element

		self:NotifyAdd(element)
	end
end

function M:RemoveElement(instanceId)
	local element = self.elems[instanceId]

	if not element then
		gGpsTools.Assert(gGpsModule.SafeAssert, "Element not exist", gGpsTools.GetGpsDebugDesc(instanceId), self.gId)

		return
	end

	self.elems[instanceId] = nil

	if self.visibleElems[instanceId] then
		self.visibleElems[instanceId] = nil

		self:NotifyRemove(element)
	end

	element._belongSources[self.gId] = nil
end

function M:ClearAllElement()
	for instanceid, _ in pairs(self.elems) do
		self:RemoveElement(instanceid)
	end
end

function M:AddListener(listener)
	if not array.contains(self.listeners, listener) then
		table.insert(self.listeners, listener)
	end

	local viewMask = listener.cfg.viewMask

	for _, elem in pairs(self.visibleElems) do
		if elem:CheckViewMask(viewMask) then
			listener:AddBySource(elem.instanceId, self.gId)
		end
	end
end

function M:RemoveListener(listener)
	local index = array.index_of(self.listeners, listener)

	if index > 0 then
		table.remove(self.listeners, index)
	end

	local viewMask = listener.cfg.viewMask

	for _, elem in pairs(self.visibleElems) do
		if elem:CheckViewMask(viewMask) then
			listener:RemoveBySource(elem.instanceId, self.gId)
		end
	end
end

function M:NotifyAdd(element, viewMask)
	if self.listeners then
		for _, listener in ipairs(self.listeners) do
			if element:CheckViewMask(listener.cfg.viewMask) then
				listener:AddBySource(element.instanceId, self.gId)
			end
		end
	end
end

function M:NotifyRemove(element)
	if self.listeners then
		for _, listener in ipairs(self.listeners) do
			if element:CheckViewMask(listener.cfg.viewMask) then
				listener:RemoveBySource(element.instanceId, self.gId)
			end
		end
	end
end

function M:GetAllElements(viewMask, output)
	local ret = output or {}

	for _, elem in pairs(self.elems) do
		if elem:VisibleOn(viewMask) then
			ret[elem.instanceId] = elem
		end
	end

	return ret
end

function M:ElementVisibleChanged(element)
	local instanceId = element.instanceId

	if not self.elems[instanceId] then
		gGpsTools.Assert(gGpsModule.SafeAssert, "Element not exist", element.instanceId, self.gId)

		return
	end

	if element:IsVisible() then
		if not self.visibleElems[instanceId] then
			self.visibleElems[instanceId] = element

			self:NotifyAdd(element)
		end
	elseif self.visibleElems[instanceId] then
		self.visibleElems[instanceId] = nil

		self:NotifyRemove(element)
	end
end

function M:ElementViewMaskChanged(element, oldViewMask, newViewMask)
	local instanceId = element.instanceId

	if not self.elems[instanceId] then
		gGpsTools.Assert(gGpsModule.SafeAssert, "Element not exist", element.instanceId, self.gId)

		return
	end

	if not element:IsVisible() then
		return
	end

	for _, listener in ipairs(self.listeners) do
		local viewMask = listener.cfg.viewMask
		local matched = bit.band(viewMask, oldViewMask) ~= 0
		local newMatched = bit.band(viewMask, newViewMask) ~= 0

		if matched and not newMatched then
			listener:RemoveBySource(instanceId, self.gId)
		elseif not matched and newMatched then
			listener:AddBySource(instanceId, self.gId)
		end
	end
end
