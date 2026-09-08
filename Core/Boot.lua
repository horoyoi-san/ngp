-- Original chunk: @Lua\LuaFiles\Core\Boot.lua
-- Decompiled from: 00028_Boot.lua_0432ab9ff81c.luajit

gRF = {
	call = ReflectionCallMethod,
	getField = ReflectionGetField,
	setField = ReflectionSetField,
	getProp = ReflectionGetProperty,
	setProp = ReflectionSetProperty,
	typeName = ReflectionTypeName,
	getType = ReflectionTypeByFullName,
	new = ReflectionCreateInstance,
	genericFunc = ReflectionGenGenericMethod
}

require("LX6/CS")
require("LX6/Extend/Extend")
require("LuaGen/AutoGen/LuaEnumCoder")
require("LuaGen/AutoGen/RPCEnum")
require("LuaGen/AutoGen/RPCLengthLimits")
math.randomseed(os.clock())

LTConfig = {}
System.Linq = System.Linq or {
	Enumerable = {}
}
_LTConfigWrap = require("LX6/Base/LTConfigWrap")
local classNameDict = {}
local class = require("Core/class")

DefClass = function(className, m, super, static_props)
	if classNameDict[className] and classNameDict[className] == m then
		print_error("类定义失败: 类名重复 ", className)

		return
	end

	classNameDict[className] = class(super, static_props, m, className)

	return classNameDict[className]
end

GetClass = function(className)
	return classNameDict[className]
end

HotPatchClass = function(className, key, val)
	local classType = GetClass(className)

	if classType then
		classType[key] = val

		classType.DoHotPatch(key)
		print_warn("HotPatchClass Success", className, key)
	else
		print_warn("HotPatchClass Fail, 找不到类 ", className, key)
	end
end

require("LX6/Extend/Log")

Vector3.null = LX6.Extension.Vector3Ext.Null

Vector3.SetNull = function(v)
	v.x = Vector3.null.x
	v.y = Vector3.null.y
	v.z = Vector3.null.z
end

return {}
