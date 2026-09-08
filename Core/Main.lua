-- Original chunk: @Lua\LuaFiles\Core\Main.lua
-- Decompiled from: 00027_Main.lua_44bf0dd87a4f.luajit

Main = function()
	print("logic start")
end

OnLevelWasLoaded = function(level)
	collectgarbage("collect")

	Time.timeSinceLevelLoad = 0
end

OnApplicationQuit = function()
end
