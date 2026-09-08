-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\GpsLText.lua
-- Decompiled from: 00209_GpsLText.lua_ef93227cf87c.luajit

EGpsLTextResolveType = {
	["Fx\\xa8rT\\xb7\\xf6acrH"] = 2,
	["@\\xfd4\\xe7\n6=\\xc4n\\xd0G\\x85G\\xd4\\xff"] = 4,
	["wFbm7"] = 5,
	["+3\\xefP\\x99\\xe53\\xa7\\xef\\xf1\\xeda\\xeb"] = 3,
	["/\\\\x83\\x87\\x8dF"] = 0,
	["k\\xa7\\xa7\\xa3\\xb2"] = 1,
	["\\xfd\\xc2-\\xf2"] = 7,
	["d[ݵ\\x81\\x8c\\xda\\xe3"] = 6
}
GpsLText = GpsLText or {}
local M = GpsLText
M.__index = M

M.CreateString = function(str)
	local obj = setmetatable({
		str = str or "",
		resolveType = EGpsLTextResolveType.String
	}, M)

	return obj
end

M.CreateDynamicText = function(getText)
	local obj = setmetatable({
		textGetter = getText,
		resolveType = EGpsLTextResolveType.Dynamic
	}, M)

	return obj
end

M.CreateCommonText = function(cfg, fieldName, syntaxRef, eventId)
	local obj = setmetatable({
		cfg = cfg,
		fieldName = fieldName,
		eventId = eventId,
		resolveType = EGpsLTextResolveType.Field
	}, M)

	return obj
end

M.CreateIndexedText = function(cfg, fieldName, index, eventId)
	local obj = setmetatable({
		cfg = cfg,
		fieldName = fieldName,
		index = index,
		eventId = eventId,
		resolveType = EGpsLTextResolveType.IndexedField
	}, M)

	return obj
end

M.CreateCargoDeliveryText = function(eventId)
	local obj = setmetatable({}, M)
	obj.resolveType = EGpsLTextResolveType.TaskCargoDelivery
	obj.eventId = eventId

	if eventId ~= nil then
		print_error("CreateCargoDeliveryText eventId is nil")
	end

	return obj
end

M.CreateCargoPickupText = function(eventId, uniqueId)
	local obj = setmetatable({}, M)
	obj.resolveType = EGpsLTextResolveType.TaskCargoPickup
	obj.eventId = eventId
	obj.uniqueId = uniqueId

	if eventId ~= nil or uniqueId ~= nil then
		print_error("CreateCargoPickupText eventId or uniqueId is nil" .. "eventId:" .. tostring(eventId) .. " uniqueId:" .. tostring(uniqueId))
	end

	return obj
end

M.CreateCargoText = function(eventId, uniqueId)
	local obj = setmetatable({}, M)
	obj.resolveType = EGpsLTextResolveType.TaskCargo
	obj.eventId = eventId
	obj.uniqueId = uniqueId

	if eventId ~= nil or uniqueId ~= nil then
		print_error("CreateCargoText eventId or uniqueId is nil" .. "eventId:" .. tostring(eventId) .. " uniqueId:" .. tostring(uniqueId))
	end

	return obj
end

M.CreateWasherTaskText = function()
	local obj = setmetatable({}, M)
	obj.resolveType = EGpsLTextResolveType.WasherTask

	return obj
end

M.GetText = function(self)
	if self.resolveType ~= EGpsLTextResolveType.String then
		return self.str or ""
	elseif self.resolveType ~= EGpsLTextResolveType.Field then
		local text = self.cfg and self.cfg[self.fieldName] or ""

		return M.ResolveRideAndDateText(text, self.eventId)
	elseif self.resolveType ~= EGpsLTextResolveType.IndexedField then
		local text = self.cfg and self.cfg[self.fieldName] and self.cfg[self.fieldName][self.index] or ""

		return M.ResolveRideAndDateText(text, self.eventId)
	elseif self.resolveType ~= EGpsLTextResolveType.TaskCargoPickup then
		return self:GetCargoPickUpText()
	elseif self.resolveType ~= EGpsLTextResolveType.TaskCargoDelivery then
		return self:GetCargoDeliveryText()
	elseif self.resolveType ~= EGpsLTextResolveType.TaskCargo then
		return self:GetCargoText()
	elseif self.resolveType ~= EGpsLTextResolveType.WasherTask then
		return self:GetWasherTaskText()
	elseif self.resolveType ~= EGpsLTextResolveType.Dynamic then
		return self.textGetter and self.textGetter() or ""
	else
		return ""
	end
end

M.GetCargoPickUpText = function(self)
	local info = gDeliveryTaskManager:GetOrderByEventId(self.eventId)

	if not info or not info.cargoInfoList then
		return ""
	end

	for i = 1, #info.cargoInfoList do
		if info.cargoInfoList[i].instanceId ~= self.uniqueId then
			return info.cargoInfoList[i].startPosText or ""
		end
	end

	return ""
end

M.GetCargoDeliveryText = function(self)
	local info = gDeliveryTaskManager:GetOrderByEventId(self.eventId)

	if not info then
		return ""
	end

	return info.finishPosText
end

M.GetCargoText = function(self)
	local info = gDeliveryTaskManager:GetOrderByEventId(self.eventId)

	if not info or not info.cargoInfoList then
		print_error("GetCargoText info or cargoInfoList is nil", "eventId:", self.eventId, "uniqueId:", self.uniqueId)

		return ""
	end

	for i = 1, #info.cargoInfoList do
		if info.cargoInfoList[i].instanceId ~= self.uniqueId then
			local cargoId = info.cargoInfoList[i].cargoId
			local cfg = info and LTConfig.UberSimRandomGoodsConfig.GetConfig(cargoId)

			return cfg and cfg.information or ""
		end
	end

	return ""
end

M.GetWasherTaskText = function(self)
	local washerJobInfo = gWasherManager:GetWasherJobInfo()
	local randomCfgId = washerJobInfo and washerJobInfo.CurRandomCfgId or 0
	local randomCfg = randomCfgId == 0 and LTConfig.WasherRandomTaskConfig.GetConfig(randomCfgId) or nil

	if randomCfg and not string.is_null_or_empty(randomCfg.RandomQuestName) then
		return randomCfg.RandomQuestName
	end

	return ""
end

M.ResolveRideAndDateText = function(text, eventId)
	return gTaskUtils:FormatTaskDesByEventId(text, eventId)
end
