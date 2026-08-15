C_Store = DefClass("C_Store", C_Store)
ET = {
	Property = 10,
	Controller = 5,
	Method = 20,
	Component = 25,
	Field = 15,
	Event = 0
}
local ETField = ET.Field
local ETEvent = ET.Event
local ETProperty = ET.Property
local ETController = ET.Controller
local ETMethod = ET.Method
local StoreBindMethod = gStoreBindMethod
local Store = C_Store

function Store:ctor(name, id)
	self.group = nil
	self.bindWidget = nil
	self.wgtId = 0
	self.bindData = {}
	self.m_Id = id
	self.m_Name = name
	self.m_ImmediatelyCommit = false
	self.m_FieldMap = {}
	self.m_WidgetMap = {}
	self.m_UpdateMap = {}
	self.m_UpdateBackMap = {}
	self.m_IsUpdating = false
	self.__m_UpdateDirty = false
end

function Store:__RegisterToMap(data, field)
	local store = self.m_Store
	local map = store.m_FieldMap[field] or {}

	table.insert(map, data)

	store.m_FieldMap[field] = map
end

function Store:__UnRegisterToMap(data, field)
	local store = self.m_Store
	local map = store.m_FieldMap[field]

	if map ~= nil then
		for i = #map, 1, -1 do
			if map[i] == data then
				table.remove(map, i)

				break
			end
		end

		if #map > 0 then
			store.m_FieldMap[field] = map
		else
			store.m_FieldMap[field] = nil
		end
	end
end

function Store:__RegisterToWidgetMap(field, widget)
	local store = self.m_Store
	store.m_WidgetMap[field] = widget

	rawset(store, field, widget)
end

function Store:__UnRegisterToWidgetMap(field)
	local store = self.m_Store
	store.m_WidgetMap[field] = nil

	rawset(store, field, nil)
end

function Store:Clear()
	local store = self.m_Store
	store.group = nil
	store.bindWidget = nil
	store.wgtId = 0

	table.clear(store.bindData)

	for _, map in pairs(store.m_FieldMap) do
		if map and #map > 0 then
			table.clear(map)
		end
	end

	table.clear(store.m_FieldMap)

	for field, _ in pairs(store.m_WidgetMap) do
		rawset(store, field, nil)
	end

	table.clear(store.m_WidgetMap)
	table.clear(store.m_UpdateMap)
	table.clear(store.m_UpdateBackMap)
end

function Store:ClearData()
	local store = self.m_Store

	table.clear(store.bindData)
end

function Store:EnableImmediatelyCommit(enable)
	local store = self.m_Store
	store.m_ImmediatelyCommit = enable
end

function Store:BindWidget(widget)
	local store = self.m_Store
	store.bindWidget = widget
	store.wgtId = widget.gameObject:GetInstanceID()
end

function Store:__AddToUpdateMap(key)
	if self.m_IsUpdating then
		self.m_UpdateBackMap[key] = true
	else
		self.__m_UpdateDirty = true

		gStoreManager:AddToUpdatedStoreMap(self)

		self.m_UpdateMap[key] = true
	end
end

function Store:IsDirty()
	return self.__m_UpdateDirty
end

function Store:__Update()
	if self.__m_UpdateDirty then
		self.__m_UpdateDirty = false
		self.m_IsUpdating = true

		for key, _ in pairs(self.m_UpdateMap) do
			local map = self.m_FieldMap[key] or STORE_EMPTY_TABLE

			for i, v in ipairs(map) do
				if gGameManager.Env.IsENABLE_PROFILER then
					gCS.LuaUtils.BeginSample(v.field)
				end

				self:__ApplyBindingData(v)

				if gGameManager.Env.IsENABLE_PROFILER then
					gCS.LuaUtils.EndSample()
				end
			end

			self.m_UpdateMap[key] = nil
		end

		self.m_IsUpdating = false

		for key, _ in pairs(self.m_UpdateBackMap) do
			local map = self.m_FieldMap[key] or STORE_EMPTY_TABLE

			for i, v in ipairs(map) do
				if gGameManager.Env.IsENABLE_PROFILER then
					gCS.LuaUtils.BeginSample(v.field)
				end

				self:__ApplyBindingData(v)

				if gGameManager.Env.IsENABLE_PROFILER then
					gCS.LuaUtils.EndSample()
				end
			end

			self.m_UpdateBackMap[key] = nil
		end
	end
end

function Store:RefreshAllBindingData()
	for field, map in pairs(self.m_FieldMap) do
		self:__AddToUpdateMap(field)
	end
end

function IsNilObject(obj)
	return gCS.LuaUtils.IsNull(obj) or obj == nil or obj == EMPTY_STORE_OBJECT
end

function Store_InvokeMethod(widget, funcName, value)
	if IsNilObject(widget) then
		return
	end

	return StoreBindMethod[funcName](StoreBindMethod, widget, value)
end

function _ApplyToWidgetEnum(child, param, paramType, curValue)
	if child == nil then
		return
	end

	if paramType == ETField or paramType == ETProperty or paramType == ETEvent then
		child[param] = curValue
	elseif paramType == ETController then
		child:TryChangePage(param, curValue)
	elseif paramType == ETMethod then
		Store_InvokeMethod(child, param, curValue)
	end
end

function Store:__ApplyBindingData(data)
	local curValue = self.bindData[data.field]

	if curValue == nil then
		return
	end

	local widget = data.widget
	local param = data.param
	local paramType = data.paramType
	local status, err = xpcall(_ApplyToWidgetEnum, tolua.traceback, widget, param, paramType, curValue)

	if not status then
		print_error("ApplyBindingData Failed, Group:", self.group ~= nil and self.group.m_Name or "nil", "widget:", widget, "param:", param, "paramType:", paramType, "field:", data.field, "curValue:", curValue, "Path:", SGUITools.GetHierarchy(widget.gameObject), "\n", err)
	end
end

local readonly = {
	__newindex = function (t, k, v)
		print_error("Attempt to modify a readonly table.")
	end
}
STORE_EMPTY_TABLE = {}
COMMIT_IMMEDIATELY = {}
COMMIT_FORCE = {}
COMMIT_IMMEDIATELY_WITH_CHECK = {}

setmetatable(STORE_EMPTY_TABLE, readonly)
setmetatable(COMMIT_IMMEDIATELY, readonly)
setmetatable(COMMIT_FORCE, readonly)
setmetatable(COMMIT_IMMEDIATELY_WITH_CHECK, readonly)

EMPTY_STORE_OBJECT = {}

setmetatable(EMPTY_STORE_OBJECT, {
	__index = function (t, k)
		return EMPTY_STORE_OBJECT
	end,
	__newindex = function (t, k, v)
		return
	end,
	__call = function ()
		return EMPTY_STORE_OBJECT
	end
})

function _ForceCommit(store, field, value)
	store.bindData[field] = value

	store:__AddToUpdateMap(field)
end

function _ImmediatelyCommit(store, field, value)
	store.bindData[field] = value
	local map = store.m_FieldMap[field] or STORE_EMPTY_TABLE

	if #map > 0 then
		for i, v in ipairs(map) do
			store:__ApplyBindingData(v)
		end
	end
end

function _ImmediatelyCommitWithCheck(store, field, value)
	local lastValue = store.bindData[field]

	if value ~= lastValue then
		store.bindData[field] = value
		local map = store.m_FieldMap[field] or STORE_EMPTY_TABLE

		if #map > 0 then
			for i, v in ipairs(map) do
				store:__ApplyBindingData(v)
			end
		end
	end
end

function Store:Commit(field, value, options)
	local store = self.m_Store

	if options == nil then
		self[field] = value

		return
	end

	if options == COMMIT_FORCE then
		_ForceCommit(store, field, value)

		return
	end

	if options == COMMIT_IMMEDIATELY then
		_ImmediatelyCommit(store, field, value)

		return
	end

	if options == COMMIT_IMMEDIATELY_WITH_CHECK then
		_ImmediatelyCommitWithCheck(store, field, value)

		return
	end
end
