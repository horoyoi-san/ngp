-- Original chunk: @Lua\LuaFiles\LX6\Utils\CurveUtils.lua
-- Decompiled from: 00517_CurveUtils.lua_2d3b474b78d9.luajit

local AnimationUtil = LX6.Utils.AnimationUtil
local M = {
	cacheCurveIdMap = {}
}

M.OnConfigHotfix = function(eventId, data)
	local list = data.ToTable(data)

	if array.contains(list, "AnimationCurveConfig") then
		print_error("[DebugLog] 清空曲线缓存", #M.cacheCurveIdMap)

		M.cacheCurveIdMap = {}
	end
end

M.GetCacheCurve = function(curveId)
	if not curveId then
		print_warn("curveId is nil", curveId)

		return
	end

	if M.cacheCurveIdMap[curveId] ~= nil then
		local curve, duration = AnimationUtil.CreateAnimationCurve(curveId, 0, 1)

		if not curve then
			print_warn("AnimationCurveConfig not found curveId:", curveId)

			return nil, 0
		end

		M.cacheCurveIdMap[curveId] = {
			duration = duration,
			curve = curve
		}
	end

	local data = M.cacheCurveIdMap[curveId]

	return data.curve, data.duration
end

gCurveUtils = M
