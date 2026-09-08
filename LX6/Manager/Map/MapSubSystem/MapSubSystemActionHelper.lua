-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\MapSubSystem\MapSubSystemActionHelper.lua
-- Decompiled from: 00213_MapSubSystemActionHelper.lua_704ddff2ce28.luajit

gMapSubSystemActionHelper = {}
local M = gMapSubSystemActionHelper

M.TryExecuteTraceAction = function(element, action)
	if action ~= gMapSystemElementAction.Trace then
		M.Trace(element)

		return true
	elseif action ~= gMapSystemElementAction.Untrace then
		M.Untrace(element)

		return true
	else
		return false
	end
end

M.Trace = function(element)
	element.SetMainTrace(element)
end

M.Untrace = function(element)
	element.ClearMainTrace(element)
end

return M
