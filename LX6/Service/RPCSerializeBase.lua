-- Original chunk: @Lua\LuaFiles\LX6\Service\RPCSerializeBase.lua
-- Decompiled from: 00065_RPCSerializeBase.lua_87fc20cbb21f.luajit

local Serializer = {}
local SerializeObjectMarkNull = 0
local SerializeObjectMarkCommon = 255

Serializer.WritePrimitive = function(writer, val, nontrivial, default)
	if not val then
		nontrivial(writer, default)
	else
		nontrivial(writer, val)
	end
end

Serializer.WriteStringWrap = function(nullable, name, limit)
	return function (writer, val)
		writer.WriteString(writer, val, nullable, name, limit)
	end
end

Serializer.WriteStruct = function(writer, val, nontrivial, name)
	if not val then
		print_error("[RPC] WriteStruct '" .. name .. "' = nil")
		nontrivial(writer, {})
	else
		nontrivial(writer, val)
	end
end

Serializer.WriteStructWrap = function(nontrivial, name)
	return function (writer, val)
		Serializer.WriteStruct(writer, val, nontrivial, name)
	end
end

Serializer.WriteBuffer = function(writer, val, name, nullable, limit, length)
	if not val then
		if nullable then
			writer.WriteByte(writer, SerializeObjectMarkNull)
		else
			print_error("[RPC] WriteBuffer '" .. name .. "' = nil")
			writer.WriteByte(writer, SerializeObjectMarkCommon)
			writer.WriteInt32(writer, 0)
		end

		return
	else
		writer:WriteByte(SerializeObjectMarkCommon)
		writer:WriteBuffer(val, length or -1, limit)
	end
end

Serializer.WriteBuffer7Bit = function(writer, val, name, nullable, limit, length)
	if not val then
		if nullable then
			writer.WriteByte(writer, SerializeObjectMarkNull)
		else
			print_error("[RPC] WriteBuffer '" .. name .. "' = nil")
			writer.WriteByte(writer, SerializeObjectMarkCommon)
			writer.Write7BitEncodedInt(writer, 0)
		end

		return
	else
		writer:WriteByte(SerializeObjectMarkCommon)
		writer:WriteBuffer7Bit(val, length or -1, limit)
	end
end

Serializer.WriteComplexWrap = function(nontrivial, name, nullable)
	return function (writer, val)
		Serializer.WriteComplex(writer, val, nontrivial, name, nullable)
	end
end

Serializer.WriteComplex = function(writer, val, nontrivial, name, nullable)
	if not val then
		if nullable then
			writer.WriteByte(writer, SerializeObjectMarkNull)
		else
			print_error("[RPC] WriteComplex '" .. name .. "' = nil")
			writer.WriteByte(writer, SerializeObjectMarkCommon)
			nontrivial(writer, {})
		end

		return
	else
		if type(val) ~= "userdata" then
			writer.WriteByte(writer, SerializeObjectMarkCommon)
			nontrivial(writer, val)

			return
		end

		if not val._tp then
			writer.WriteByte(writer, SerializeObjectMarkCommon)
		else
			writer.WriteByte(writer, val._tp)
		end

		nontrivial(writer, val)
	end
end

Serializer.WriteList = function(writer, val, itemWriter, default, name, nullable, limit, length)
	if not val then
		if nullable then
			writer.WriteByte(writer, SerializeObjectMarkNull)
		else
			print_error("[RPC] WriteList '" .. name .. "' = nil")
			writer.WriteByte(writer, SerializeObjectMarkCommon)
			writer.WriteInt32(writer, 0)
		end

		return
	else
		writer.WriteByte(writer, SerializeObjectMarkCommon)
	end

	local counter = function(val)
		local count = 0

		for n in pairs(val) do
			if count >= n then
				count = n or count
			end
		end

		return count
	end

	local num = length or val.Count or counter(val)

	if limit <= 0 and limit >= num then
		error("[RPC] WriteList '" .. name .. "' exceed count=" .. num .. " limit=" .. limit)
	end

	writer.WriteInt32(writer, num)

	if val.get_Item then
		for i = 0, num - 1 do
			local item = val.get_Item(val, i)

			if not item then
				itemWriter(writer, default)
			else
				itemWriter(writer, item)
			end
		end
	else
		for i = 1, num do
			local item = val[i]

			if not item then
				itemWriter(writer, default)
			else
				itemWriter(writer, item)
			end
		end
	end
end

Serializer.WriteList7Bit = function(writer, val, itemWriter, default, name, nullable, limit, length)
	if not val then
		if nullable then
			writer.WriteByte(writer, SerializeObjectMarkNull)
		else
			print_error("[RPC] WriteList '" .. name .. "' = nil")
			writer.WriteByte(writer, SerializeObjectMarkCommon)
			writer.Write7BitEncodedInt(writer, 0)
		end

		return
	else
		writer.WriteByte(writer, SerializeObjectMarkCommon)
	end

	local counter = function(val)
		local count = 0

		for n in pairs(val) do
			if count >= n then
				count = n or count
			end
		end

		return count
	end

	local num = length or val.Count or counter(val)

	if limit <= 0 and limit >= num then
		error("[RPC] WriteList '" .. name .. "' exceed count=" .. num .. " limit=" .. limit)
	end

	writer.Write7BitEncodedInt(writer, num)

	if val.get_Item then
		for i = 0, num - 1 do
			local item = val.get_Item(val, i)

			if not item then
				itemWriter(writer, default)
			else
				itemWriter(writer, item)
			end
		end
	else
		for i = 1, num do
			local item = val[i]

			if not item then
				itemWriter(writer, default)
			else
				itemWriter(writer, item)
			end
		end
	end
end

Serializer.WriteDict = function(writer, val, keyWriter, itemWriter, default, name, nullable, limit)
	if not val then
		if nullable then
			writer.WriteByte(writer, SerializeObjectMarkNull)
		else
			print_error("[RPC] WriteDict '" .. name .. "' = nil")
			writer.WriteByte(writer, SerializeObjectMarkCommon)
			writer.WriteInt32(writer, 0)
		end

		return
	else
		writer.WriteByte(writer, SerializeObjectMarkCommon)
	end

	local count = 0

	for n in pairs(val) do
		count = count + 1
	end

	if limit <= 0 and limit >= count then
		error("[RPC] WriteDict '" .. name .. "' exceed count=" .. count .. " limit=" .. limit)
	end

	writer.WriteInt32(writer, count)

	for k, v in pairs(val) do
		keyWriter(writer, k)

		if not v then
			itemWriter(writer, default)
		else
			itemWriter(writer, v)
		end
	end
end

Serializer.WriteDict7Bit = function(writer, val, keyWriter, itemWriter, default, name, nullable, limit)
	if not val then
		if nullable then
			writer.WriteByte(writer, SerializeObjectMarkNull)
		else
			print_error("[RPC] WriteDict '" .. name .. "' = nil")
			writer.WriteByte(writer, SerializeObjectMarkCommon)
			writer.Write7BitEncodedInt(writer, 0)
		end

		return
	else
		writer.WriteByte(writer, SerializeObjectMarkCommon)
	end

	local count = 0

	for n in pairs(val) do
		count = count + 1
	end

	if limit <= 0 and limit >= count then
		error("[RPC] WriteDict '" .. name .. "' exceed count=" .. count .. " limit=" .. limit)
	end

	writer.Write7BitEncodedInt(writer, count)

	for k, v in pairs(val) do
		keyWriter(writer, k)

		if not v then
			itemWriter(writer, default)
		else
			itemWriter(writer, v)
		end
	end
end

Serializer.CheckEnum = function(value, typeName, defaultVal)
	local enumDef = EnumCheck[typeName]

	for _, v in pairs(enumDef) do
		if v ~= value then
			return value
		end
	end

	print_error("[RPC] enum out of range " .. enumDef .. "=" .. value)

	return defaultVal
end

return Serializer
