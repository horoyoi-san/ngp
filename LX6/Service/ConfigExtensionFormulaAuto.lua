-- Original chunk: @Lua\LuaFiles\LX6\Service\ConfigExtensionFormulaAuto.lua
-- Decompiled from: 00046_ConfigExtensionFormulaAuto.lua_25e4206e1b3e.luajit

local FormulaAuto = require("LuaGen/AutoGen/ConfigFormulaAuto")
ConfigExtensionFormulaAuto = ConfigExtensionFormulaAuto or {}
local resetter = FormulaAuto.LoadAll()

resetter()

return resetter
