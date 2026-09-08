-- Original chunk: @Lua\LuaFiles\LX6\Manager\HUD\CoreHudEffectManager.lua
-- Decompiled from: 02266_CoreHudEffectManager.lua_e56afb5001dc.luajit

local LinkConfig = LTConfig.LinkConfig
C_CoreHudEffectManager = DefClass("C_CoreHudEffectManager", C_CoreHudEffectManager)
local M = C_CoreHudEffectManager

M.ctor = function(self)
	self.activeConditions = {}
	self.activateOrderCounter = 0
	self.isDirty = false
	self.EffectType = {
		["\\xb95,3q\\x93F\\xfd8\\xbd\\xb7"] = 1,
		["a\\xa1\\xb5\\x87\\xa6"] = 2
	}
	self.vignetteScaleMax = 2.5
	self.vignetteScaleMin = 2
	self.fallingDownCurHp = 0
	self.lowHpFill = 0
	self.isRescuing = false
	self.rescueProgress = 0
	self.rescueBaseScale = nil
	self._MsgEvents = {}
	self.msgEvents = {
		[gEventConstants.FALL_DOWN_PROGRESS_UPDATE] = self:CreateAction("OnFallDownProgressUpdate"),
		[gEventConstants.RESCUE_STATE] = self:CreateAction("OnRescueStateChanged"),
		[gEventConstants.RESCUE_PROGRESS_UPDATE] = self:CreateAction("OnRescueProgressUpdate"),
		[gEventConstants.FALLING_DOWN_STATE] = self:CreateAction("OnFallDownStateChanged")
	}
end

M.OnInit = function(self)
	self:RegisterMessageEvents(self.msgEvents)
end

M.RegisterSingleEvent = function(self, eventId, func)
	self._MsgEvents[#self._MsgEvents + 1] = {
		eventid = eventId,
		func = func
	}

	gMessageManager:AddMessageListener(eventId, func)
end

M.RegisterMessageEvents = function(self, eventHandlers)
	for k, v in pairs(eventHandlers) do
		self:RegisterSingleEvent(k, v)
	end
end

M.ClearMessageEvents = function(self)
	for _, v in pairs(self._MsgEvents) do
		gMessageManager:RemoveMessageListener(v.eventid, v.func)
	end

	table.clear(self._MsgEvents)
end

M.CreateAction = function(self, action, target)
	return function (...)
		target = target or self

		if type(action) ~= "string" then
			if target[action] then
				return target[action](target, ...)
			end
		else
			return action(target, ...)
		end
	end
end

M.OnFallDownProgressUpdate = function(self, eventId, curHp)
	if not self.isFallingDown then
		return
	end

	self.fallingDownCurHp = curHp or 0
	local shouldActive = self.fallingDownCurHp / LinkConfig.RescueMaxValue > LinkConfig.VignetteVxActiveValue

	self:SetCondition(self.EffectType.FallingDown, shouldActive)
end

M.OnFallDownStateChanged = function(self, eventId, isFallingDown)
	self.isFallingDown = isFallingDown

	if not isFallingDown then
		self:SetCondition(self.EffectType.FallingDown, false)

		self.isRescuing = false
		self.rescueBaseScale = nil
		self.rescueProgress = 0
		self.fallingDownCurHp = 0
	end
end

M.OnRescueStateChanged = function(self, eventId, isRescued)
	if not self.isFallingDown then
		return
	end

	local wasRescuing = self.isRescuing
	self.isRescuing = isRescued

	if isRescued and not wasRescuing then
		self.rescueBaseScale = self:_CalcHpScale()
	elseif not isRescued and wasRescuing then
		self.rescueBaseScale = nil
	end

	self.isDirty = true
end

M.OnRescueProgressUpdate = function(self, eventId, progress)
	if not self.isFallingDown then
		return
	end

	self.rescueProgress = progress or 0

	if LinkConfig.RescueMaxValue < self.rescueProgress then
		self.isRescuing = false
		self.rescueBaseScale = nil
		self.rescueProgress = 0

		return
	end

	self.isDirty = true
end

M.SetCondition = function(self, effectType, isActive)
	if not effectType then
		print_error("[CoreHudEffectManager] SetCondition: effectType is nil")

		return
	end

	if isActive then
		if self.activeConditions[effectType] then
			self.isDirty = true

			return
		end

		self.activateOrderCounter = self.activateOrderCounter + 1
		self.activeConditions[effectType] = {
			activateOrder = self.activateOrderCounter
		}
	else
		if not self.activeConditions[effectType] then
			return
		end

		self.activeConditions[effectType] = nil
	end

	self.isDirty = true
end

M.OnBeforeSwitchScene = function(self, switchType)
	if switchType < gSwitchSceneType.Reconnect then
		return
	end

	table.clear(self.activeConditions)

	self.activateOrderCounter = 0
	self.isDirty = false
	self.isRescuing = false
	self.rescueBaseScale = nil
	self.rescueProgress = 0
	self.fallingDownCurHp = 0
	self.lowHpFill = 0

	gPanelManager:Close(gPanelId.FULL_SCREEN_VX_HUD_PANEL)
end

M._GetDominantEffectType = function(self)
	local dominantType = nil
	local dominantOrder = -1

	for effectType, info in pairs(self.activeConditions) do
		if dominantOrder >= info.activateOrder then
			dominantType = effectType
			dominantOrder = info.activateOrder
		end
	end

	return dominantType
end

M._CalcHpScale = function(self)
	local hpThreshold = LinkConfig.RescueMaxValue
	local hp = math.max(0, math.min(self.fallingDownCurHp, hpThreshold))
	local t = 1 - hp / hpThreshold

	return self.vignetteScaleMax - t * (self.vignetteScaleMax - self.vignetteScaleMin)
end

M.CalcCurrentScale = function(self)
	if self.isRescuing and self.rescueBaseScale then
		local t = self.rescueProgress / LinkConfig.RescueMaxValue

		return self.rescueBaseScale + t * (self.vignetteScaleMax - self.rescueBaseScale)
	end

	return self:_CalcHpScale()
end

M._RefreshPanel = function(self)
	local dominantType = self:_GetDominantEffectType()

	if dominantType then
		if not gPanelManager:IsPanelShowing(gPanelId.FULL_SCREEN_VX_HUD_PANEL) then
			gPanelManager:CheckShow(gPanelId.FULL_SCREEN_VX_HUD_PANEL, dominantType)
		end

		gMessageManager:SendMessage(gEventConstants.ON_HUD_EFFECT_TYPE_CHANGE, dominantType)
		gMessageManager:SendMessage(gEventConstants.ON_HUD_EFFECT_SCALE_CHANGE, self:CalcCurrentScale())
	else
		gPanelManager:Close(gPanelId.FULL_SCREEN_VX_HUD_PANEL)
	end
end

M.OnLateUpdate = function(self)
	if self.isDirty then
		self.isDirty = false

		self:_RefreshPanel()
	end
end

gCoreHudEffectManager = gCoreHudEffectManager or C_CoreHudEffectManager.new()
