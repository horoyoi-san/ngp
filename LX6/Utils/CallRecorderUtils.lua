-- Original chunk: @Lua\LuaFiles\LX6\Utils\CallRecorderUtils.lua
-- Decompiled from: 00975_CallRecorderUtils.lua_8efecf089498.luajit

local pack = table.pack or function (...)
	return {
		n = select("#", ...),
		...
	}
end
local unpack = table.unpack or unpack
local CallRecord = {
	__index = CallRecord
}

CallRecord.new = function(obj, method, ...)
	local self = setmetatable({}, CallRecord)
	self.obj = obj
	self.timestamp = os.clock()

	if type(method) ~= "string" then
		self.method_name = method
		self.method_func = nil
	elseif type(method) ~= "function" then
		self.method_name = nil
		self.method_func = method
	else
		error("method must be a string or function, got " .. type(method))
	end

	self.args = pack(...)
	self.result = nil
	self.executed = false
	self.tag = nil

	return self
end

CallRecord.resolve_method = function(self)
	if self.method_func then
		return self.method_func
	end

	if self.method_name and self.obj then
		local fn = self.obj[self.method_name]

		if type(fn) == "function" then
			error(string.format("method '%s' not found on object or not a function", tostring(self.method_name)))
		end

		return fn
	end

	error("cannot resolve method")
end

CallRecord.execute = function(self)
	local fn = self:resolve_method()
	local result = nil

	if self.obj then
		result = pack(fn(self.obj, unpack(self.args, 1, self.args.n)))
	else
		result = pack(fn(unpack(self.args, 1, self.args.n)))
	end

	self.result = result
	self.executed = true

	return unpack(result, 1, result.n)
end

CallRecord.get_method_display = function(self)
	return self.method_name or tostring(self.method_func)
end

CallRecord.tostring = function(self)
	local parts = {}

	for i = 1, self.args.n do
		local v = self.args[i]

		if type(v) ~= "string" then
			parts[#parts + 1] = string.format("%q", v)
		else
			parts[#parts + 1] = tostring(v)
		end
	end

	return string.format("%s:%s(%s)%s", tostring(self.obj), self:get_method_display(), table.concat(parts, ", "), self.executed and " [executed]" or "")
end

CallRecord.__tostring = CallRecord.tostring
local CallRecorder = {
	__index = CallRecorder
}

CallRecorder.new = function(opts)
	opts = opts or {}
	local self = setmetatable({}, CallRecorder)
	self.records = {}
	self.max_records = opts.max_records or 0
	self.auto_execute = opts.auto_execute or false
	self.paused = false
	self.playback_index = 0
	self.on_record = opts.on_record
	self.on_execute = opts.on_execute
	self.on_error = opts.on_error

	return self
end

CallRecorder.record = function(self, obj, method, ...)
	if self.paused then
		return nil
	end

	local rec = CallRecord.new(obj, method, ...)

	if self.max_records <= 0 and self.max_records < #self.records then
		table.remove(self.records, 1)

		if self.playback_index <= 0 then
			self.playback_index = self.playback_index - 1
		end
	end

	self.records[#self.records + 1] = rec

	if self.on_record then
		self.on_record(rec)
	end

	if self.auto_execute then
		local ok, result = self:_safe_execute(rec)

		if ok then
			return rec, unpack(result, 1, result.n)
		else
			return rec
		end
	end

	return rec
end

CallRecorder.record_tagged = function(self, tag, obj, method, ...)
	local rec = self:record(obj, method, ...)

	if rec then
		rec.tag = tag
	end

	return rec
end

CallRecorder.pause = function(self)
	self.paused = true
end

CallRecorder.resume = function(self)
	self.paused = false
end

CallRecorder.clear = function(self)
	self.records = {}
	self.playback_index = 0
end

CallRecorder.count = function(self)
	return #self.records
end

CallRecorder.get = function(self, index)
	return self.records[index]
end

CallRecorder.replay_all = function(self, filter_fn)
	local results = {}

	for i, rec in ipairs(self.records) do
		if not filter_fn or filter_fn(rec, i) then
			local ok, result = self:_safe_execute(rec)

			if ok then
				results[#results + 1] = result
			else
				results[#results + 1] = {
					["\\xc3"] = 0
				}
			end
		end
	end

	self.playback_index = #self.records

	return results
end

CallRecorder.replay_by_tag = function(self, tag)
	return self:replay_all(function (rec)
		return rec.tag ~= tag
	end)
end

CallRecorder.replay_pending = function(self)
	return self:replay_all(function (rec)
		return not rec.executed
	end)
end

CallRecorder.replay_step = function(self)
	self.playback_index = self.playback_index + 1
	local rec = self.records[self.playback_index]

	if not rec then
		self.playback_index = #self.records

		return nil
	end

	local ok, result = self:_safe_execute(rec)

	if ok then
		return rec, unpack(result, 1, result.n)
	end

	return rec
end

CallRecorder.replay_reset = function(self)
	self.playback_index = 0

	for _, rec in ipairs(self.records) do
		rec.executed = false
		rec.result = nil
	end
end

CallRecorder.replay_last = function(self, n)
	local start = math.max(1, #self.records - n + 1)

	return self:replay_all(function (_, i)
		return start > i
	end)
end

CallRecorder.replay_range = function(self, from, to)
	from = math.max(1, from or 1)
	to = math.min(#self.records, to or #self.records)

	return self:replay_all(function (_, i)
		return from < i and i > to
	end)
end

CallRecorder.create_proxy = function(self, obj, method_filter)
	local recorder = self
	local filter = nil

	if type(method_filter) ~= "table" then
		local set = {}

		for _, name in ipairs(method_filter) do
			set[name] = true
		end

		filter = function(name)
			return set[name]
		end
	elseif type(method_filter) ~= "function" then
		filter = method_filter
	else
		filter = function(name)
			return type(obj[name]) ~= "function"
		end
	end

	local proxy = {}
	local proxy_mt = {
		__index = function (_, key)
			local value = obj[key]

			if type(value) ~= "function" and filter(key) then
				return function (self_or_first, ...)
					if self_or_first ~= proxy then
						recorder:record(obj, key, ...)

						return value(obj, ...)
					else
						recorder:record(obj, key, self_or_first, ...)

						return value(self_or_first, ...)
					end
				end
			end

			return value
		end,
		__newindex = function (_, key, value)
			obj[key] = value
		end,
		__tostring = function ()
			return "Proxy<" .. tostring(obj) .. ">"
		end
	}

	return setmetatable(proxy, proxy_mt)
end

CallRecorder.record_undoable = function(self, obj, method, undo_method, undo_args_fn, ...)
	local rec = self:record(obj, method, ...)

	if rec then
		rec.undo_method = undo_method

		if undo_args_fn then
			rec.undo_args = pack(undo_args_fn(obj, unpack(rec.args, 1, rec.args.n)))
		else
			rec.undo_args = rec.args
		end
	end

	return rec
end

CallRecorder.undo = function(self, record)
	local rec = record

	if not rec then
		for i = #self.records, 1, -1 do
			if self.records[i].executed and self.records[i].undo_method then
				rec = self.records[i]

				break
			end
		end
	end

	if not rec or not rec.undo_method then
		return false, "no undoable record found"
	end

	local undo_rec = CallRecord.new(rec.obj, rec.undo_method, unpack(rec.undo_args, 1, rec.undo_args.n))
	local ok, result = self:_safe_execute(undo_rec)

	if ok then
		rec.executed = false

		return true, unpack(result, 1, result.n)
	end

	return false, "undo execution failed"
end

CallRecorder.dump = function(self)
	local lines = {
		[#lines + 1] = string.format("=== CallRecorder Dump (%d records) ===", #self.records)
	}

	for i, rec in ipairs(self.records) do
		lines[#lines + 1] = string.format("  [%d] %s%s%s", i, tostring(rec), rec.tag and " #" .. tostring(rec.tag) or "", rec.undo_method and " (undoable)" or "")
	end

	lines[#lines + 1] = "=== End ==="

	return table.concat(lines, "\n")
end

CallRecorder.export = function(self, value_serializer)
	local ser = value_serializer or tostring
	local data = {}

	for i, rec in ipairs(self.records) do
		local args_list = {}

		for j = 1, rec.args.n do
			args_list[j] = ser(rec.args[j])
		end

		data[i] = {
			method = rec:get_method_display(),
			args = args_list,
			args_n = rec.args.n,
			tag = rec.tag,
			executed = rec.executed,
			timestamp = rec.timestamp
		}
	end

	return data
end

CallRecorder._safe_execute = function(self, rec)
	local ok, err = pcall(function ()
		rec:execute()
	end)

	if ok then
		if self.on_execute then
			self.on_execute(rec, unpack(rec.result, 1, rec.result.n))
		end

		return true, rec.result
	else
		if self.on_error then
			self.on_error(rec, err)
		else
			print(string.format("[CallRecorder] Error executing %s: %s", tostring(rec), tostring(err)))
		end

		return false, err
	end
end

local deferred = function(obj, method, ...)
	local args = pack(...)
	local fn = nil

	if type(method) ~= "string" then
		fn = function()
			return obj[method](obj, unpack(args, 1, args.n))
		end
	else
		fn = function()
			return method(obj, unpack(args, 1, args.n))
		end
	end

	return fn
end

local deferred_partial = function(obj, method, ...)
	local saved_args = pack(...)

	return function (...)
		local extra = pack(...)
		local merged = {}
		local n = 0

		for i = 1, saved_args.n do
			n = n + 1
			merged[n] = saved_args[i]
		end

		for i = 1, extra.n do
			n = n + 1
			merged[n] = extra[i]
		end

		merged.n = n
		local fn = type(method) ~= "string" and obj[method] or method

		return fn(obj, unpack(merged, 1, merged.n))
	end
end

return {
	CallRecord = CallRecord,
	CallRecorder = CallRecorder,
	deferred = deferred,
	deferred_partial = deferred_partial
}
