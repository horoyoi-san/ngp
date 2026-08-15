local ActionTransitionRuleTypesConfig = LTConfig.ActionTransitionRuleTypesConfig
C_CheckFuncBlock = DefClass("C_CheckFuncBlock", C_CheckFuncBlock, nil)
local B = C_CheckFuncBlock

function B:ctor(checkFunc, EventId)
	self.checkFunc = checkFunc
	self.EventId = EventId or false
	self.finish = false
	self.disposed = false

	if self.EventId then
		function self.eventFunc(eventId, data)
			self.finish = self.checkFunc(eventId, data)
		end

		gMessageManager:AddMessageListener(self.EventId, self.eventFunc)

		self.listenerAdd = true
	end
end

function B:Check()
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

function B:Dispose()
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

function M:ctor()
	return
end

function M:ExampleFormula()
	return B.new(function (eventId, data)
		if data == gPanelId.S_INVENTORY_PANEL then
			return true
		end
	end, gEventConstants.PANEL_ON_SHOW)
end

function M:IsDoingSwing()
	return B.new(function ()
		return gCS.PaoKuManager.ParkourStateLua == ActionTransitionRuleTypesConfig.ParkourStateType.Swing
	end)
end

function M:IsDoingFeiSuo()
	return B.new(function ()
		return gCS.PaoKuManager.ParkourStateLua == ActionTransitionRuleTypesConfig.ParkourStateType.Feisuo
	end)
end

function M:IsDoingJump()
	return B.new(function ()
		return gCS.PaoKuManager.ParkourStateLua == ActionTransitionRuleTypesConfig.ParkourStateType.Jump
	end)
end

function M:IsDoingClimbSlow()
	return B.new(function ()
		return gCS.PaoKuManager.ParkourStateLua == ActionTransitionRuleTypesConfig.ParkourStateType.ClimbSlow
	end)
end

function M:IsDoingClimbRun()
	return B.new(function ()
		return gCS.PaoKuManager.ParkourStateLua == ActionTransitionRuleTypesConfig.ParkourStateType.ClimbRun
	end)
end

function M:IsDoingClimbStay()
	return B.new(function ()
		return gCS.PaoKuManager.ParkourStateLua == ActionTransitionRuleTypesConfig.ParkourStateType.ClimbStay
	end)
end

function M:IsDoingClimbSlowStay()
	return B.new(function ()
		return gCS.PaoKuManager.ParkourStateLua == ActionTransitionRuleTypesConfig.ParkourStateType.ClimbSlowStay
	end)
end

function M:IsDoingRun()
	return B.new(function ()
		return gCS.PaoKuManager.ParkourStateLua == ActionTransitionRuleTypesConfig.ParkourStateType.Run
	end)
end

function M:IsDoingRush()
	return B.new(function ()
		return gCS.PaoKuManager.ParkourStateLua == ActionTransitionRuleTypesConfig.ParkourStateType.Rush
	end)
end

function M:IsNonMobileAdaptive()
	return B.new(function ()
		return gCS.LuaUtils.IsNonMobileAdaptive()
	end)
end

function M:IsMobile()
	return B.new(function ()
		return not gCS.LuaUtils.IsNonMobileAdaptive()
	end)
end

function M:IsControllerMode()
	return B.new(function ()
		return SGUI.GameDevice.KeyboardMouse < gCS.LuaUtils.GetActiveDevice()
	end)
end

function M:IsActionStateHoldBlend()
	return B.new(function ()
		return gCS.PaoKuManager.ParkourStateLua == ActionTransitionRuleTypesConfig.ParkourStateType.HoldBlend
	end)
end

function M:IsActionStateMagnet()
	return B.new(function ()
		return gCS.PaoKuManager.ParkourStateLua == ActionTransitionRuleTypesConfig.ParkourStateType.Magnet
	end)
end

gGuideConditionFormula = gGuideConditionFormula or C_GuideConditionFormula.new()
