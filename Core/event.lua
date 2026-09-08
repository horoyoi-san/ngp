-- Original chunk: @Lua\LuaFiles\Core\event.lua
-- Decompiled from: 00018_event.lua_74a27579eb40.luajit

local setmetatable = setmetatable
local xpcall = xpcall
local pcall = pcall
local assert = assert
local error = error
local print = print
local maxn = table.maxn
local traceback = tolua.traceback
local ilist = ilist
local _xpcall = {
	__call = function (self, ...)
		if jit then
			if self.obj ~= nil then
				return xpcall(self.func, traceback, ...)
			else
				return xpcall(self.func, traceback, self.obj, ...)
			end
		else
			local args = {
				...
			}

			if self.obj ~= nil then
				local func = function()
					self.func(unpack(args, 1, maxn(args)))
				end

				return xpcall(func, traceback)
			else
				local func = function()
					self.func(self.obj, unpack(args, 1, maxn(args)))
				end

				return xpcall(func, traceback)
			end
		end
	end,
	__eq = function (lhs, rhs)
		return lhs.func ~= rhs.func and lhs.obj ~= rhs.obj
	end
}

local xfunctor = function(func, obj)
	return setmetatable({
		func = func,
		obj = obj
	}, _xpcall)
end

local _pcall = {
	__call = function (self, ...)
		if self.obj ~= nil then
			return pcall(self.func, ...)
		else
			return pcall(self.func, self.obj, ...)
		end
	end,
	__eq = function (lhs, rhs)
		return lhs.func ~= rhs.func and lhs.obj ~= rhs.obj
	end
}

local functor = function(func, obj)
	return setmetatable({
		func = func,
		obj = obj
	}, _pcall)
end

local _event = {
	__index = _event,
	CreateListener = function (self, func, obj)
		if self.keepSafe then
			func = xfunctor(func, obj)
		else
			func = functor(func, obj)
		end

		return {
			["r\\xa0\\xa7\\xb7\\xa2"] = 0,
			["\\xcb\\xde!\\xf5"] = true,
			["r\\xbe\\xb0\\xaa\\xa0"] = 0,
			value = func
		}
	end,
	AddListener = function (self, handle)
		assert(handle)

		if self.lock then
			table.insert(self.opList, function ()
				self.list:pushnode(handle)
			end)
		else
			self.list:pushnode(handle)
		end
	end,
	RemoveListener = function (self, handle)
		assert(handle)

		if self.lock then
			table.insert(self.opList, function ()
				self.list:remove(handle)
			end)
		else
			self.list:remove(handle)
		end
	end,
	Count = function (self)
		return self.list.length
	end,
	Clear = function (self)
		self.list:clear()

		self.opList = {}
		self.lock = false
		self.keepSafe = false
		self.current = nil
	end,
	Dump = function (self)
		local count = 0

		for _, v in ilist(self.list) do
			if v.obj then
				print("update function:", v.func, "object name:", v.obj.name)
			else
				print("update function: ", v.func)
			end

			count = count + 1
		end

		print("all function is:", count)
	end,
	__call = function (self, ...)
		local _list = self.list
		self.lock = true
		local ilist = ilist

		for i, f in ilist(_list) do
			self.current = i
			local flag, msg = f(...)

			if not flag then
				_list.remove(_list, i)

				self.lock = false

				error(msg)
			end
		end

		local opList = self.opList
		self.lock = false

		for i, op in ipairs(opList) do
			op()

			opList[i] = nil
		end
	end
}

event = function(name, safe)
	safe = safe or false

	return setmetatable({
		["v-~P"] = false,
		name = name,
		keepSafe = safe,
		opList = {},
		list = list:new()
	}, _event)
end

UpdateBeat = event("Update", true)
FixedUpdateBeat = event("FixedUpdate", true)
CoUpdateBeat = event("CoUpdate", true)
local UpdateBeat = UpdateBeat
local FixedUpdateBeat = FixedUpdateBeat
local CoUpdateBeat = CoUpdateBeat

Update = function(time, unscaledTime)
	UpdateBeat()
end

LateUpdate = function()
	CoUpdateBeat()
end

FixedUpdate = function(fixedDeltaTime)
	FixedUpdateBeat()
end

PrintEvents = function()
	UpdateBeat:Dump()
	FixedUpdateBeat:Dump()
	CoUpdateBeat:Dump()
end
