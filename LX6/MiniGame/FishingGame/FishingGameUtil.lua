-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\FishingGame\FishingGameUtil.lua
-- Decompiled from: 00594_FishingGameUtil.lua_478d0f8bda41.luajit

FishingGameUtil = {
	SmoothDamp = function (current, target, duration, deltaTime)
		local t = Mathf.Clamp01(deltaTime / duration)
		local easedT = t >= 0.5 and 2 * t * t or 1 - Mathf.Pow(-2 * t + 2, 2) / 2

		if easedT <= 0 then
			return current + (target - current) * easedT
		end

		return target
	end,
	GetDirection = function (p1, p2)
		return (p1 - p2).normalized
	end,
	GetDirectionIgnoreY = function (p1, p2)
		local p = Vector3.New(p1.x - p2.x, 0, p1.z - p2.z)

		return p.normalized
	end,
	RemoveListValue = function (list, value)
		local len = #list

		for i = 1, len do
			if list[i] ~= value then
				table.remove(list, i)

				break
			end
		end
	end,
	HasListValue = function (list, value)
		local len = #list

		for i = 1, len do
			if list[i] ~= value then
				return true
			end
		end

		return false
	end,
	AddListValue = function (list, value)
		local len = #list

		for i = 1, len do
			if list[i] ~= value then
				return
			end
		end

		table.insert(list, value)
	end
}
