-- Original chunk: @Lua\LuaFiles\Core\class.lua
-- Decompiled from: 00041_class.lua_58a8f20959bc.luajit

local _class = {}
local create = nil

create = function(c, obj, ...)
	if c.super then
		create(c.super, obj, ...)
	end

	if c.ctor then
		c.ctor(obj, ...)
	end
end

local class = function(super, static_props, m, className)
	if super and not _class[super] then
		print_error(" 定义失败: super~=nil, 但super中没有vtbl")

		return
	end

	local class_type = m or {}
	local metatable = rawget(class_type, "metatable")
	local vtbl = _class[class_type]
	local inheritors = rawget(class_type, "inheritors")

	if vtbl then
		if not gGameManager.Env.isEditor or not string.contains(className, "Store") or not gStoreManager.m_EnableAutoPatch then
			print_warn("Class 重新定义, className:", className)
		end

		setmetatable(vtbl, nil)

		for k in pairs(vtbl) do
			vtbl[k] = nil
		end

		setmetatable(class_type, nil)

		if class_type.super then
			class_type.super.RemoveInheritor(class_type)
		end

		for k in pairs(class_type) do
			class_type[k] = nil
		end

		if inheritors then
			for k, v in pairs(inheritors) do
				k.OnClassHotPatch()
			end
		end
	else
		vtbl = {}
	end

	vtbl.funcFromSuper = {}
	class_type.ctor = false
	class_type.super = super
	class_type.base = super and _class[super]

	if super then
		super.AddInheritor(class_type)
	end

	class_type.new = function(...)
		local obj = {}

		if not metatable then
			metatable = {
				__index = _class[class_type],
				__tostring = function (k)
					return _class[class_type].__tostring and _class[class_type].__tostring(k) or ""
				end
			}

			rawset(class_type, "metatable", metatable)
		end

		setmetatable(obj, metatable)
		create(class_type, obj, ...)

		return obj
	end

	class_type.New = class_type.new

	class_type.IsType = function(ins)
		return ins and getmetatable(ins) and getmetatable(ins) ~= rawget(class_type, "metatable")
	end

	class_type.className = className or "NONE"
	_class[class_type] = vtbl

	class_type.GetVtbl = function()
		return _class[class_type]
	end

	class_type.inheritors = inheritors or {}

	class_type.AddInheritor = function(inheritor)
		if not class_type.inheritors[inheritor] then
			class_type.inheritors[inheritor] = true
		end
	end

	class_type.RemoveInheritor = function(inheritor)
		if class_type.inheritors[inheritor] then
			class_type.inheritors[inheritor] = nil
		end
	end

	class_type.OnClassHotPatch = function(key)
		if key then
			if vtbl.funcFromSuper[key] then
				vtbl.funcFromSuper[key] = nil
				vtbl[key] = nil
			end
		else
			for k, v in pairs(vtbl.funcFromSuper) do
				vtbl[k] = nil
				vtbl.funcFromSuper[k] = nil
			end
		end

		if class_type.inheritors then
			for k, v in pairs(class_type.inheritors) do
				k.OnClassHotPatch(key)
			end
		end
	end

	class_type.DoHotPatch = function(key)
		if class_type.inheritors then
			for k, v in pairs(class_type.inheritors) do
				k.OnClassHotPatch(key)
			end
		end
	end

	setmetatable(class_type, {
		__newindex = function (t, k, v)
			vtbl[k] = v
		end,
		__index = function (t, k)
			return static_props and rawget(static_props, k) or super and super[k]
		end
	})

	class_type.GetClassType = function()
		return class_type
	end

	class_type.GetTypeName = function()
		return class_type.className
	end

	class_type.isType = function(typeName)
		return class_type.className ~= typeName
	end

	class_type.CreateAction = function(this, action, target)
		return function (...)
			target = target or this

			if action ~= nil then
				print_error("CreateAction Error, action is nil, className=", this.GetTypeName())

				return
			end

			if type(action) ~= "string" then
				if type(target) == "table" then
					print_error("CreateAction Error, target type is not table, type=", type(target), "action=", action, "className=", this.GetTypeName())

					return
				end

				if target[action] then
					return target[action](target, ...)
				end
			else
				return action(target, ...)
			end
		end
	end

	class_type.CreateActionWithArgs = function(this, action, args, target)
		return function (...)
			target = target or this

			if action ~= nil then
				print_error("CreateActionWithArgs error, action is nil, className=", this.GetTypeName())

				return
			end

			if type(action) ~= "string" then
				if type(target) == "table" then
					print_error("CreateActionWithArgs Error, target type is not table, type=", type(target), "action=", action, "className=", this.GetTypeName())

					return
				end

				if target[action] then
					return target[action](target, args, ...)
				end
			else
				return action(target, args, ...)
			end
		end
	end

	if super then
		setmetatable(vtbl, {
			__index = function (t, k)
				local ret = _class[super][k]
				vtbl[k] = ret

				if ret then
					vtbl.funcFromSuper[k] = true
				end

				return ret
			end
		})
	end

	return class_type
end

return class
