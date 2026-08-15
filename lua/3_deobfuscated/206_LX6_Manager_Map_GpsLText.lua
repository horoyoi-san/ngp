EGpsLTextResolveType = {
	IndexedField = 2,
	TaskCargoDelivery = 4,
	TaskCargo = 5,
	TaskCargoPickup = 3,
	String = 0,
	Field = 1
}
GpsLText = GpsLText or {}
local M = GpsLText
M.__index = M

function M.CreateString(str)
	local obj = setmetatable({
		str = str or "",
		resolveType = EGpsLTextResolveType.String
	}, M)

	return obj
end

function M.CreateCommonText(cfg, fieldName, syntaxRef)
	local obj = setmetatable({
		cfg = cfg,
		fieldName = fieldName,
		resolveType = EGpsLTextResolveType.Field
	}, M)

	return obj
end

function M.CreateIndexedText(cfg, fieldName, index)
	local obj = setmetatable({
		cfg = cfg,
		fieldName = fieldName,
		index = index,
		resolveType = EGpsLTextResolveType.IndexedField
	}, M)

	return obj
end

function M.CreateCargoDeliveryText(eventId)
	local obj = setmetatable({}, M)
	obj.resolveType = EGpsLTextResolveType.TaskCargoDelivery
	obj.eventId = eventId

	if eventId == nil then
		print_error("CreateCargoDeliveryText eventId is nil")
	end

	return obj
end

function M.CreateCargoPickupText(eventId, uniqueId)
	local obj = setmetatable({}, M)
	obj.resolveType = EGpsLTextResolveType.TaskCargoPickup
	obj.eventId = eventId
	obj.uniqueId = uniqueId

	if eventId == nil or uniqueId == nil then
		print_error("CreateCargoPickupText eventId or uniqueId is nil" .. "eventId:" .. tostring(eventId) .. " uniqueId:" .. tostring(uniqueId))
	end

	return obj
end

function M.CreateCargoText(eventId, uniqueId)
	local obj = setmetatable({}, M)
	obj.resolveType = EGpsLTextResolveType.TaskCargo
	obj.eventId = eventId
	obj.uniqueId = uniqueId

	if eventId == nil or uniqueId == nil then
		print_error("CreateCargoText eventId or uniqueId is nil" .. "eventId:" .. tostring(eventId) .. " uniqueId:" .. tostring(uniqueId))
	end

	return obj
end

function M:GetText()
	if self.resolveType == EGpsLTextResolveType.String then
		return self.str or ""
	elseif self.resolveType == EGpsLTextResolveType.Field then
		return self.cfg and self.cfg[self.fieldName] or ""
	elseif self.resolveType == EGpsLTextResolveType.IndexedField then
		return self.cfg and self.cfg[self.fieldName] and self.cfg[self.fieldName][self.index] or ""
	elseif self.resolveType == EGpsLTextResolveType.TaskCargoPickup then
		return self:GetCargoPickUpText()
	elseif self.resolveType == EGpsLTextResolveType.TaskCargoDelivery then
		return self:GetCargoDeliveryText()
	elseif self.resolveType == EGpsLTextResolveType.TaskCargo then
		return self:GetCargoText()
	else
		return ""
	end
end

function M:GetCargoPickUpText()
	local info = gDeliveryTaskManager:GetOrderByEventId(self.eventId)

	if not info or not info.cargoInfoList then
		return ""
	end

	for i = 1, #info.cargoInfoList do
		if info.cargoInfoList[i].instanceId == self.uniqueId then
			return info.cargoInfoList[i].startPosText or ""
		end
	end

	return ""
end

function M:GetCargoDeliveryText()
	local info = gDeliveryTaskManager:GetOrderByEventId(self.eventId)

	if not info then
		return ""
	end

	return info.finishPosText
end

function M:GetCargoText()
	local info = gDeliveryTaskManager:GetOrderByEventId(self.eventId)

	if not info or not info.cargoInfoList then
		print_error("GetCargoText info or cargoInfoList is nil", "eventId:", self.eventId, "uniqueId:", self.uniqueId)

		return ""
	end

	for i = 1, #info.cargoInfoList do
		if info.cargoInfoList[i].instanceId == self.uniqueId then
			local cargoId = info.cargoInfoList[i].cargoId
			local cfg = info and LTConfig.UberSimRandomGoodsConfig.GetConfig(cargoId)

			return cfg and cfg.information or ""
		end
	end

	return ""
end
