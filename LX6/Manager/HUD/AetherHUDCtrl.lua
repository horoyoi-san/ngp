-- Original chunk: @Lua\LuaFiles\LX6\Manager\HUD\AetherHUDCtrl.lua
-- Decompiled from: 02292_AetherHUDCtrl.lua_18d68a112f35.luajit

local HUDCtrl = require("LX6/Manager/HUD/HudController")
C_AetherHUDCtrl = DefClass("C_AetherHUDCtrl", C_AetherHUDCtrl, HUDCtrl)
local AetherHUDCtrl = C_AetherHUDCtrl

AetherHUDCtrl.ctor = function(self)
	self.tType = gHudMgr.HUDTargetType.Aether
	self.isDebugCreate = false
end

AetherHUDCtrl.CustomProcedure = function(self)
	self.uiRoot.ExtraOffset = 1.5
end

AetherHUDCtrl.CustomClearProcedure = function(self)
end

return AetherHUDCtrl
