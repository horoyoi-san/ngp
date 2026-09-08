-- Original chunk: @Lua\LuaFiles\LX6\Manager\HUD\CoreHudQteVisualMgr.lua
-- Decompiled from: 02240_CoreHudQteVisualMgr.lua_77e596667714.luajit

C_CoreHudQteVisualMgr = DefClass("C_CoreHudQteVisualMgr", C_CoreHudQteVisualMgr)
local M = C_CoreHudQteVisualMgr

M.ctor = function(self)
	self.Tier = {
		["i\\xa1\\xa6\\xa8\\xb3"] = 3,
		["nNbm~*"] = 1,
		["\\xf2\\xd21\"\\xf7"] = 4,
		["o\\xa2\\xad\\xac\\xbd"] = 2
	}
	self.wants = {}
	self.activeTier = nil

	gMessageManager:AddMessageListener(gEventConstants.L50_BEFORE_SWITCH_SCENE, function (eventId, switchSceneEventParams)
		self:OnBeforeSwitchScene(eventId, switchSceneEventParams)
	end)
end

M.RequestQteVisual = function(self, tier, want)
	want = want and true or false

	if self.wants[tier] ~= want then
		return
	end

	self.wants[tier] = want

	self:_Arbitrate()
end

M._Arbitrate = function(self)
	local newActiveTier = self.wants[self.Tier.KickOff] and self.Tier.KickOff or self.wants[self.Tier.Dodge] and self.Tier.Dodge or self.wants[self.Tier.Block] and self.Tier.Block or self.wants[self.Tier.MindPower] and self.Tier.MindPower or nil

	if newActiveTier ~= self.activeTier then
		return
	end

	local oldActiveTier = self.activeTier
	self.activeTier = newActiveTier

	gMessageManager:SendMessageMultiParamLuaOnly(gEventConstants.QTE_VISUAL_TIER_CHANGE, newActiveTier, oldActiveTier)
end

M.OnBeforeSwitchScene = function(self, eventId, switchSceneEventParams)
	local switchType = switchSceneEventParams and switchSceneEventParams.switchSceneType

	if not switchType or switchType < gSwitchSceneType.Reconnect then
		return
	end

	table.clear(self.wants)

	self.activeTier = nil
end

gCoreHudQteVisualMgr = gCoreHudQteVisualMgr or C_CoreHudQteVisualMgr.new()
