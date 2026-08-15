local DataCell = require("LX6/DataBind/DataCell")
local mt = {}
local DataSet = {
	INIT_EMPTY_VALUE = false,
	EVENT_VALUE = true
}

function mt.__newindex(table, key, value)
	local iseq = table._data[key] == value

	if not iseq then
		table._data[key] = value

		table:SendBindEvent(key, value)
	else
		table:SendBindEvent(key, value, true)
	end
end

function mt.__index(table, key)
	local v = table._data[key]

	if v == nil then
		v = rawget(mt, key)
	end

	return v
end

function mt.__tostring(table)
	return tostring(table._data)
end

function mt:SendBindEvent(key, value, arbitraryOnly)
	if value == nil then
		value = self._data[key]
	end

	if value == nil then
		return
	end

	if self._delaySendBindEvent then
		self._delaySendBindEvent[key] = value
		self._delaySendBindEventParams[key] = arbitraryOnly

		return
	end

	if not arbitraryOnly then
		local list = self._bindHandlers[key]

		if list ~= nil then
			local count = #list
			local i = 1

			while count >= i do
				list[i]:Call(value)

				i = i + 1
			end
		end
	end

	local list = self._bindArbitraryHandlers[key]

	if list ~= nil then
		local count = #list
		local i = 1

		while count >= i do
			list[i]:Call(value)

			i = i + 1
		end
	end
end

function mt:DelaySendBindEvent(enable)
	if enable then
		if not self._delaySendBindEvent then
			rawset(self, "_delaySendBindEvent", {})
			rawset(self, "_delaySendBindEventParams", {})
		end
	elseif self._delaySendBindEvent then
		local tbl = self._delaySendBindEvent
		local params = self._delaySendBindEventParams

		rawset(self, "_delaySendBindEvent", nil)
		rawset(self, "_delaySendBindEventParams", nil)

		for key, value in pairs(tbl) do
			self:SendBindEvent(key, value, params[key])
		end
	end
end

function mt:BindCell(cell)
	local bindName = cell.key

	if self._data[bindName] == nil and cell.isUI then
		print_error("绑定空变量 bindName=", bindName, "filePath[" .. (self._data.tracePath or "nil") .. "]", SGUITools.GetHierarchy(cell.gameObject))

		if string.contains(bindName, " ") then
			print_error("绑定变量中存在空格 bindName=", bindName, "filePath[" .. (self._data.tracePath or "nil") .. "]", SGUITools.GetHierarchy(cell.gameObject))
		end
	end

	local list = nil

	if cell.ignoreValueCheck then
		list = self._bindArbitraryHandlers[bindName]

		if list == nil then
			list = {}
			self._bindArbitraryHandlers[bindName] = list
		end
	else
		list = self._bindHandlers[bindName]

		if list == nil then
			list = {}
			self._bindHandlers[bindName] = list
		end
	end

	local count = #list + 1
	list[count] = cell
	cell.dataSetIndex = count
end

function mt:UnBindCell(cell)
	local list = nil

	if cell.ignoreValueCheck then
		list = self._bindArbitraryHandlers[cell.key]
	else
		list = self._bindHandlers[cell.key]
	end

	if list ~= nil then
		local count = #list
		local index = cell.dataSetIndex

		if count < index or list[index] ~= cell then
			print_error(index, count)
		end

		cell.dataSetIndex = nil

		if count ~= index then
			list[index] = list[count]
			list[count] = nil
			list[index].dataSetIndex = index
		else
			list[count] = nil
		end
	end
end

function mt:BindHandler(bindName, handler)
	local cell = DataCell.new(self, handler, bindName)

	self:BindCell(cell)

	return cell
end

function mt:BindHandlers(bindHandlers)
	for k, v in pairs(bindHandlers) do
		self:BindHandler(k, v)
	end
end

function mt:RefreshData(data)
	self:DelaySendBindEvent(true)

	for key, value in pairs(data) do
		local oldValue = self[key]

		if getmetatable(value) == mt then
			value = value._data
		end

		if type(oldValue) == "table" and oldValue.RefreshData ~= nil then
			if type(value) == "table" then
				oldValue:RefreshData(value)
			else
				self[key] = value
			end
		else
			self[key] = value
		end
	end

	self:DelaySendBindEvent(false)
end

function mt:Clear()
	rawset(self, "_bindHandlers", {})
	rawset(self, "_bindArbitraryHandlers", {})
	rawset(self, "_data", {})
	rawset(self, "_delaySendBindEvent", nil)
	rawset(self, "_delaySendBindEventParams", nil)
end

function DataSet.New(template)
	local table = {
		_data = {},
		_bindHandlers = {},
		_bindArbitraryHandlers = {}
	}

	if template ~= nil then
		table._data = template
	end

	setmetatable(table, mt)

	return table
end

function DataSet.IsType(tbl)
	return getmetatable(tbl) == mt
end

return DataSet
