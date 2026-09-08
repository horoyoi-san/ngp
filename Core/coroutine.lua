-- Original chunk: @Lua\LuaFiles\Core\coroutine.lua
-- Decompiled from: 00022_coroutine.lua_aa44114aeb85.luajit

local create = coroutine.create
local running = coroutine.running
local resume = coroutine.resume
local yield = coroutine.yield
local error = error
local unpack = unpack
local debug = debug
local FrameTimer = FrameTimer
local CoTimer = CoTimer
local comap = {}
local pool = {}

setmetatable(comap, {
	["#w\\x9c\\x81\\x87D"] = ""
})

coroutine.start = function(f, ...)
	local co = create(f)

	if running() ~= nil then
		local flag, msg = resume(co, ...)

		if not flag then
			error(debug.traceback(co, msg))
		end
	else
		local args = {
			...
		}
		local timer = nil

		local action = function()
			comap[co] = nil
			timer.func = nil
			local flag, msg = resume(co, unpack(args, 1, table.maxn(args)))

			table.insert(pool, timer)

			if not flag then
				timer:Stop()
				error(debug.traceback(co, msg))
			end
		end

		if #pool <= 0 then
			timer = table.remove(pool)

			timer.Reset(timer, action, 0, 1)
		else
			timer = FrameTimer.New(action, 0, 1)
		end

		comap[co] = timer

		timer.Start(timer)
	end

	return co
end

coroutine.wait = function(t, co, ...)
	local args = {
		...
	}
	co = co or running()
	local timer = nil

	local action = function()
		comap[co] = nil
		timer.func = nil
		local flag, msg = resume(co, unpack(args, 1, table.maxn(args)))

		if not flag then
			timer:Stop()
			error(debug.traceback(co, msg))

			return
		end
	end

	timer = CoTimer.New(action, t, 1)
	comap[co] = timer

	timer:Start()

	return yield(nil)
end

coroutine.step = function(t, co, ...)
	local args = {
		...
	}
	co = co or running()
	local timer = nil

	local action = function()
		comap[co] = nil
		timer.func = nil
		local flag, msg = resume(co, unpack(args, 1, table.maxn(args)))

		table.insert(pool, timer)

		if not flag then
			timer:Stop()
			error(debug.traceback(co, msg))

			return
		end
	end

	if #pool <= 0 then
		timer = table.remove(pool)

		timer:Reset(action, t or 1, 1)
	else
		timer = FrameTimer.New(action, t or 1, 1)
	end

	comap[co] = timer

	timer.Start(timer)

	return yield(nil)
end

coroutine.stop = function(co)
	local timer = comap[co]

	if timer == nil then
		comap[co] = nil

		timer.Stop(timer)

		timer.func = nil
	end
end
