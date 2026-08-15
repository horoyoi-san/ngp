local AnimationUtil = LX6.Utils.AnimationUtil
local M = {
	cacheCurveIdMap = {}
}

function M.OnConfigHotfix(eventId, data)
	local list = data:ToTable()

	if array.contains(list, "AnimationCurveConfig") then
		print_error("[DebugLog] 清空曲线缓存", #M.cacheCurveIdMap)

		M.cacheCurveIdMap = {}
	end
end

function M.GetCacheCurve(curveId)
	if not curveId then
		print_warn("curveId is nil", curveId)

		return
	end

	if M.cacheCurveIdMap[curveId] == nil then
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
