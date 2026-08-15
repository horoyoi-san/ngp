gGpsTools = gGpsTools or {}
local M = gGpsTools
M._tableCache = M._tableCache or {}
M._tickTable = M._tickTable or {}
M._devUserName = nil

function M.CreateInst(meta)
	local obj = setmetatable({}, meta)

	return obj
end

function M.GetTable()
	local count = #M._tableCache

	if count > 0 then
		local t = M._tableCache[count]
		M._tableCache[count] = nil

		return t
	else
		return {}
	end
end

function M.ReleaseTable(t)
	if not t then
		return
	end

	for k in pairs(t) do
		t[k] = nil
	end

	table.insert(M._tableCache, t)
end

function M.ReleaseArray(t)
	if not t then
		return
	end

	for i = #t, 1, -1 do
		t[i] = nil
	end

	table.insert(M._tableCache, t)
end

function M.GetCopiedArray(arr)
	if not arr then
		return nil
	end

	local newArr = M.GetTable()

	for i = 1, #arr do
		newArr[i] = arr[i]
	end

	return newArr
end

function M.TrySetDict(target, src)
	local changed = false

	for k, v in pairs(target) do
		if src[k] ~= v then
			target[k] = src[k]
			changed = true
		end
	end

	for k, v in pairs(src) do
		if target[k] ~= v then
			target[k] = v
			changed = true
		end
	end

	return changed
end

function M.TrySetHashDict(target, src)
	local changed = false

	for k in pairs(target) do
		if not src[k] then
			target[k] = nil
			changed = true
		end
	end

	for k in pairs(src) do
		if not target[k] then
			target[k] = true
			changed = true
		end
	end

	return changed
end

function M.TrySetValueArrays(target, src)
	local changed = false
	local lenTarget = #target
	local lenSrc = #src

	if lenTarget == lenSrc then
		for i = 1, lenSrc do
			if not changed and target[i] ~= src[i] then
				changed = true
			end

			target[i] = src[i]
		end
	elseif lenSrc < lenTarget then
		changed = true

		for i = lenSrc + 1, lenTarget do
			target[i] = nil
		end
	else
		changed = true

		for i = lenTarget + 1, lenSrc do
			target[i] = src[i]
		end
	end

	return changed
end

function M.TryTick(key, minInterval)
	local now = Time.realtimeSinceStartup
	local last = M._tickTable[key] or 0

	if minInterval <= now - last then
		M._tickTable[key] = now

		return true
	end

	return false
end

function M.SetDevUserName(devUserName)
	M._devUserName = devUserName
end

function M.Assert(module, msg, ...)
	if module and module.devs[M._devUserName] and gMapSystem:CheckDebugSwitch(EMapSystemDebugKey.EnableAssert) then
		msg = msg or ""

		if module.disableIssue then
			msg = "#NoCreateIssue: " .. msg
		end

		print_error(msg, ...)
	end
end

gGpsModule = {
	SafeAssert = {
		disableIssue = true,
		devs = {
			sunwei08 = true,
			xiajingbo01 = true
		}
	},
	SWTempAssert = {
		disableIssue = true,
		devs = {
			sunwei08 = true
		}
	}
}

function M.GetGpsDebugDesc(instanceId)
	local element = gMapSystem.container:Get(instanceId)

	if not element then
		return "{ Not Found }"
	end

	return string.format("{ %s, %s, %s }", element.instanceId, element:GetName() or "NoName", element.gpsId or "NoGpsId")
end

function M.GetMapId(iconType, partId)
	return M.GetGpsId(iconType, partId)
end

function M.GetGpsId(iconType, partId)
	if not iconType then
		return tostring(partId or "")
	end

	local desc = gMapElementTypeDesc[iconType]
	local transformer = desc and desc.idTransformer

	if not transformer then
		return tostring(partId or "")
	end

	if type(transformer) == "string" then
		return string.format(transformer, partId)
	elseif type(transformer) == "function" then
		return transformer(partId)
	else
		return tostring(partId or "")
	end
end

function M.GetEffectType(iconType)
	local desc = gMapElementTypeDesc[iconType]

	return desc and desc.effectType or EGpsTraceEffectType.Normal
end

function M.UXVec3toVec3(uxVec3, vec3)
	if vec3 == nil then
		vec3 = Vector3.New()
	end

	vec3.x = uxVec3.X
	vec3.y = uxVec3.Y
	vec3.z = uxVec3.Z

	return vec3
end

function M.PCallMethod(func, target, ...)
	if not func then
		print_error("GpsTools.PCallMethod: func is nil.")

		return
	end

	local ok, res = xpcall(func, tolua.traceback, target, ...)

	if not ok then
		print_error_without_stack(res)
	else
		return res
	end
end

function M.ProfilerMethod(profilerName, func, target, ...)
	if not func then
		print_error("GpsTools.PProfilerMethod: func is nil.")

		return
	end

	if gGameManager.Env.IsENABLE_PROFILER then
		gCS.LuaUtils.BeginSample(profilerName)
	end

	func(target or self, ...)

	if gGameManager.Env.IsENABLE_PROFILER then
		gCS.LuaUtils.EndSample()
	end
end

function M.PCallProfilerMethod(profilerName, func, target, ...)
	if not func then
		print_error("GpsTools.PCallProfilerMethod: func is nil.")

		return
	end

	if gGameManager.Env.IsENABLE_PROFILER then
		gCS.LuaUtils.BeginSample(profilerName)
	end

	local ok, res = xpcall(func, tolua.traceback, target, ...)

	if not ok then
		print_error_without_stack(res)
	end

	if gGameManager.Env.IsENABLE_PROFILER then
		gCS.LuaUtils.EndSample()
	end
end
