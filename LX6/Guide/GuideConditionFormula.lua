-- Original chunk: @Lua\LuaFiles\LX6\Guide\GuideConditionFormula.lua
-- Decompiled from: 00544_GuideConditionFormula.lua_f397839c15aa.luajit

local ActionTransitionRuleTypesConfig = LTConfig.ActionTransitionRuleTypesConfig
C_CheckFuncBlock = DefClass("C_CheckFuncBlock", C_CheckFuncBlock, nil)
local B = C_CheckFuncBlock

B.ctor = function(self, checkFunc, EventId)
	self.checkFunc = checkFunc
	self.EventId = EventId or false
	self.finish = false
	self.disposed = false

	if self.EventId then
		self.eventFunc = function(eventId, data)
			self.finish = self.checkFunc(eventId, data)
		end

		gMessageManager:AddMessageListener(self.EventId, self.eventFunc)

		self.listenerAdd = true
	end
end

B.Check = function(self)
	if self.disposed then
		return false
	end

	if self.EventId then
		if self.finish and self.listenerAdd then
			gMessageManager:RemoveMessageListener(self.EventId, self.eventFunc)

			self.listenerAdd = false
		end

		return self.finish
	else
		return self.checkFunc()
	end
end

B.Dispose = function(self)
	self.checkFunc = nil

	if self.EventId and self.listenerAdd then
		gMessageManager:RemoveMessageListener(self.EventId, self.eventFunc)

		self.eventFunc = nil
		self.listenerAdd = false
	end

	self.disposed = true
end

C_GuideConditionFormula = DefClass("C_GuideConditionFormula", C_GuideConditionFormula)
local M = C_GuideConditionFormula

M.ctor = function(self)
end

M.ExampleFormula = function(self)
	return B.new(function (eventId, data)
		if gCommonItemManager:IsInventoryPanelId(data) then
			return true
		end
	end, gEventConstants.PANEL_ON_SHOW)
end

M.IsDoingSwing = function(self)
	return B.new(function ()
		return gCS.PaoKuManager.ParkourStateLua ~= ActionTransitionRuleTypesConfig.ParkourStateType.Swing
	end)
end

M.IsDoingFeiSuo = function(self)
	return B.new(function ()
		return gCS.PaoKuManager.ParkourStateLua ~= ActionTransitionRuleTypesConfig.ParkourStateType.Feisuo
	end)
end

M.IsDoingJump = function(self)
	return B.new(function ()
		return gCS.PaoKuManager.ParkourStateLua ~= ActionTransitionRuleTypesConfig.ParkourStateType.Jump
	end)
end

M.IsDoingClimbSlow = function(self)
	return B.new(function ()
		return gCS.PaoKuManager.ParkourStateLua ~= ActionTransitionRuleTypesConfig.ParkourStateType.ClimbSlow
	end)
end

M.IsDoingClimbRun = function(self)
	return B.new(function ()
		return gCS.PaoKuManager.ParkourStateLua ~= ActionTransitionRuleTypesConfig.ParkourStateType.ClimbRun
	end)
end

M.IsDoingClimbStay = function(self)
	return B.new(function ()
		return gCS.PaoKuManager.ParkourStateLua ~= ActionTransitionRuleTypesConfig.ParkourStateType.ClimbStay
	end)
end

M.IsDoingClimbSlowStay = function(self)
	return B.new(function ()
		return gCS.PaoKuManager.ParkourStateLua ~= ActionTransitionRuleTypesConfig.ParkourStateType.ClimbSlowStay
	end)
end

M.IsDoingRun = function(self)
	return B.new(function ()
		return gCS.PaoKuManager.ParkourStateLua ~= ActionTransitionRuleTypesConfig.ParkourStateType.Run
	end)
end

M.IsDoingRush = function(self)
	return B.new(function ()
		return gCS.PaoKuManager.ParkourStateLua ~= ActionTransitionRuleTypesConfig.ParkourStateType.Rush
	end)
end

M.IsNonMobileAdaptive = function(self)
	return B.new(function ()
		return gCS.LuaUtils.IsNonMobileAdaptive()
	end)
end

M.IsMobile = function(self)
	return B.new(function ()
		return not gCS.LuaUtils.IsNonMobileAdaptive()
	end)
end

M.IsControllerMode = function(self)
	return B.new(function ()
		return SGUI.GameDevice.KeyboardMouse <= gCS.LuaUtils.GetActiveDevice()
	end)
end

M.IsActionStateHoldBlend = function(self)
	return B.new(function ()
		return gCS.PaoKuManager.ParkourStateLua ~= ActionTransitionRuleTypesConfig.ParkourStateType.HoldBlend
	end)
end

M.IsActionStateMagnet = function(self)
	return B.new(function ()
		return gCS.PaoKuManager.ParkourStateLua ~= ActionTransitionRuleTypesConfig.ParkourStateType.Magnet
	end)
end

gGuideConditionFormula = gGuideConditionFormula or C_GuideConditionFormula.new()
