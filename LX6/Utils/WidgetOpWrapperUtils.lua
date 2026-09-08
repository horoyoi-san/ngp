-- Original chunk: @Lua\LuaFiles\LX6\Utils\WidgetOpWrapperUtils.lua
-- Decompiled from: 00976_WidgetOpWrapperUtils.lua_81d87431deee.luajit

local M = {}

M.SetEnabled = function(widget, enabled)
	widget.enabled = enabled
end

M.SetLineRendererOverrideWidth = function(lineRenderer, width)
	lineRenderer.overrideWidth = width
end

M.SetLineUVRepeatMultiplier = function(line, width)
	line.uvRepeatMultiplier = width
end

M.SetLocalPosition = function(widget, position)
	widget.localPosition = position
end

M.SetWidgetAnchoredPosition = function(widget, position)
	widget.anchoredPosition = position
end

return M
