local HUDCtrl = require("LX6/Manager/HUD/HudController")
C_AetherHUDCtrl = DefClass("C_AetherHUDCtrl", C_AetherHUDCtrl, HUDCtrl)
local AetherHUDCtrl = C_AetherHUDCtrl

function AetherHUDCtrl:ctor()
	self.tType = gHudMgr.HUDTargetType.Aether
	self.isDebugCreate = false
end

function AetherHUDCtrl:CustomProcedure()
	self.uiRoot.ExtraOffset = 1.5
end

function AetherHUDCtrl:CustomClearProcedure()
	return
end

return AetherHUDCtrl
