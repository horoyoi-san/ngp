local FormulaAuto = require("LuaGen/AutoGen/ConfigFormulaAuto")
ConfigExtensionFormulaAuto = ConfigExtensionFormulaAuto or {}
local resetter = FormulaAuto.LoadAll()

resetter()

return resetter
