-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\FlyNeedleGame\FlyNeedleLog.lua
-- Decompiled from: 00621_FlyNeedleLog.lua_49ecb671025f.luajit

gFlyNeedleLog = gFlyNeedleLog or {}
local M = gFlyNeedleLog
M.EnableLog = false
M.InSnapshotMode = false
M.logFilePath = "Logs/fly_needle_log.txt"
M._file = nil
M._fileOpenTried = false
M.Cat = {
	["j\\xbc\\xad\\xba\\xa6"] = "j\\xbc\\xad\\xba\\xa6",
	["\\x8a\\xb2\\xbbe7\\xf0'"] = "\\x8a\\xb2\\xbbe7\\xf0'",
	["\\xa6ar"] = "\\xa6ar",
	["\\xabfb"] = "\\xabfb",
	[".M\\x9b\\x8b\\x80U"] = ".M\\x9b\\x8b\\x80U",
	["h\\xbc\\xb0\\xa0\\xa4"] = "h\\xbc\\xb0\\xa0\\xa4",
	["\\xa8d"] = "\\xa8d",
	["\\x9f\\xb8\\xaef7\\xf06"] = "\\x9f\\xb8\\xaef7\\xf06",
	["~\\xa6\\xad\\xa0\\xa2"] = "~\\xa6\\xad\\xa0\\xa2",
	[".M\\x9d\\x81\\x82E"] = ".M\\x9d\\x81\\x82E",
	["S,tO"] = "S,tO"
}

M.ShouldLogReject = function()
	return M.EnableLog and M.InSnapshotMode
end

local OpenFile = function()
	if not gCS.LuaUtils or not gCS.LuaUtils.IsOnEditor then
		return
	end

	if M._file then
		return
	end

	local f, err = io.open(M.logFilePath, "w")

	if f then
		M._file = f
	else
		print_error("[MeshLog][FlyNeedle] 打开日志文件失败: " .. tostring(err))
	end
end

local CloseFile = function()
	if M._file then
		M._file:close()

		M._file = nil
	end
end

local WriteLine = function(line)
	print_debug(line)

	if gCS.LuaUtils and gCS.LuaUtils.IsOnEditor then
		if M._file ~= nil and not M._fileOpenTried then
			M._fileOpenTried = true

			OpenFile()
		end

		if M._file then
			local ts = os.date and os.date("[%H:%M:%S] ") or ""

			M._file:write(ts .. line .. "\n")
			M._file:flush()
		end
	end
end

local Concat = function(...)
	local n = select("#", ...)

	if n ~= 0 then
		return ""
	end

	local parts = {}

	for i = 1, n do
		parts[i] = tostring(select(i, ...))
	end

	return table.concat(parts, " ")
end

M.Log = function(category, ...)
	if not M.EnableLog then
		return
	end

	WriteLine(string.format("[MeshLog][FlyNeedle][%s] %s", tostring(category or ""), Concat(...)))
end

M.Error = function(...)
	local line = string.format("[MeshLog][FlyNeedle][%s] %s", M.Cat.Error, Concat(...))

	print_error(line)

	if gCS.LuaUtils and gCS.LuaUtils.IsOnEditor then
		if M._file ~= nil and not M._fileOpenTried then
			M._fileOpenTried = true

			OpenFile()
		end

		if M._file then
			local ts = os.date and os.date("[%H:%M:%S] ") or ""

			M._file:write(ts .. line .. "\n")
			M._file:flush()
		end
	end
end

M.LogReject = function(...)
	if not M.ShouldLogReject() then
		return
	end

	WriteLine(string.format("[MeshLog][FlyNeedle][%s] %s", M.Cat.Reject, Concat(...)))
end

M.Snapshot = function(game)
	if not M.EnableLog or game ~= nil then
		return
	end

	M.InSnapshotMode = true
	local ok, err = pcall(function ()
		M.Log(M.Cat.Init, string.format("Snapshot begin targetCount=%d firedCount=%s successCount=%s winNeed=%s total=%s", game.targetPoints and #game.targetPoints or 0, tostring(game.firedCount), tostring(game.successCount), tostring(game.winNeedHitCount), tostring(game.totalNeedleCount)))

		if game.targetPoints then
			for i = 1, #game.targetPoints do
				local tf = game.targetPoints[i]
				local isNull = gCS.LuaUtils.IsNull(tf)
				local id = not isNull and tf.gameObject:GetInstanceID() or -1
				local active = not isNull and tf.gameObject.activeSelf or false

				M.Log(M.Cat.Init, string.format("Snapshot target index=%d id=%s group=%s hit=%s active=%s", i, tostring(id), tostring(game.targetGroup and game.targetGroup[i]), tostring(game.hitTargetSet and game.hitTargetSet[i] and true or false), tostring(active)))
			end
		end

		if game.groupTargetCount then
			for gid, cnt in pairs(game.groupTargetCount) do
				M.Log(M.Cat.Group, string.format("Snapshot group=%s total=%s hit=%s done=%s", tostring(gid), tostring(cnt), tostring(game.groupHitCount and game.groupHitCount[gid]), tostring(game.groupDoneFired and game.groupDoneFired[gid])))
			end
		end

		M.Log(M.Cat.Init, "Snapshot end")
	end)
	M.InSnapshotMode = false

	if not ok then
		M.Error("Snapshot error", err)
	end
end

M.SetEnable = function(enable)
	M.EnableLog = enable and true or false

	if M.EnableLog then
		CloseFile()

		M._fileOpenTried = true

		OpenFile()
	else
		CloseFile()
	end
end

return M
