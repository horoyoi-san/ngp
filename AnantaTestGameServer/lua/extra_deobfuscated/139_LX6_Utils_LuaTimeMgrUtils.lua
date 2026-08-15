local M = {
	UnitDelayDictionary = {},
	TimerCache = {},
	TimerUUId = 0
}

function M.GetUUId()
	M.TimerUUId = M.TimerUUId + 2

	return M.TimerUUId
end

function M.SetTimerCache(timer)
	if timer then
		timer:Stop()

		timer.func = nil
		timer.data = nil
		timer.uuid = 0
		timer.pid = -1

		table.insert(M.TimerCache, timer)
	end
end

function M.GetTimerCache(callback, delay, data, notAutoR, unscaled, isLogic)
	local timer = nil

	if #M.TimerCache > 0 then
		timer = table.remove(M.TimerCache)
		timer.func = callback

		timer:ResetTime(delay, data)

		timer.isLogic = isLogic
	else
		timer = Timer.New(callback, delay, nil, unscaled, isLogic)
	end

	if notAutoR then
		timer.Recycle = nil
	else
		timer.Recycle = M.CancelUnitDelay
	end

	timer.data = data
	timer.uuid = M.GetUUId()

	return timer
end

function M.NotDestroyDelay(callback, delay, loop, unscaled, isLogic)
	if delay > 0 then
		local timer = M.GetTimerCache(callback, delay, nil, nil, unscaled, isLogic)
		timer.loop = loop or 1

		timer:Start(true)
		table.insert(M.UnitDelayDictionary, timer)

		return timer.uuid
	else
		callback()
	end

	return 0
end

function M.Delay(callback, delay, loop, unscaled, isLogic)
	if delay > 0 then
		local timer = M.GetTimerCache(callback, delay, nil, nil, unscaled, isLogic)
		timer.loop = loop or 1

		timer:Start()
		table.insert(M.UnitDelayDictionary, timer)

		return timer.uuid
	else
		callback()
	end

	return 0
end

function M.UnitDelay(pid, delay, callback, data, notAutoR, unscaled, isLogic, domust)
	if isLogic == nil then
		isLogic = true
	end

	if delay > 0 then
		local timer = M.GetTimerCache(callback, delay, data, notAutoR, unscaled, isLogic)
		timer.pid = pid
		timer.domust = domust
		local unit_cs = gCS.SceneDataMgr.GetUnit(pid)

		if unit_cs and isLogic then
			timer.deltaTimeScale = unit_cs.timeScale
		end

		timer:Start()
		table.insert(M.UnitDelayDictionary, timer)

		return timer.uuid
	else
		callback(data)
	end

	return 0
end

function M.CancelUnitDelay(uuid)
	if uuid == nil or uuid == 0 then
		return
	end

	for i = #M.UnitDelayDictionary, 1, -1 do
		if M.UnitDelayDictionary[i].uuid == uuid then
			local t = table.remove(M.UnitDelayDictionary, i)

			M.SetTimerCache(t)
		end
	end
end

function M.CancelAllUnitDelay(pid)
	for i = #M.UnitDelayDictionary, 1, -1 do
		if M.UnitDelayDictionary[i].pid == pid and not M.UnitDelayDictionary[i].domust then
			local t = table.remove(M.UnitDelayDictionary, i)

			M.SetTimerCache(t)
		end
	end
end

gLuaTimeMgrUtils = M
