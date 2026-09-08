-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\ElementFilterId.lua
-- Decompiled from: 00210_ElementFilterId.lua_3125527091d7.luajit

ElementFilterId = ElementFilterId or {}
local M = ElementFilterId
M.__index = M

M.CreateFilterIdByCfg = function(cfg, fieldName, baseId)
	local obj = setmetatable({
		cfg = cfg,
		fieldName = fieldName,
		baseId = baseId
	}, M)

	return obj
end

M.GetFilterId = function(self)
	return self.cfg and self.cfg[self.fieldName] + self.baseId or nil
end
