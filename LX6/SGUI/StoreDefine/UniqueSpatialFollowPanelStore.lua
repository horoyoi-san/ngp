-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\UniqueSpatialFollowPanelStore.lua
-- Decompiled from: 01184_UniqueSpatialFollowPanelStore.lua_562e52e32513.luajit

C_UniqueSpatialFollowPanelStore = DefClass("C_UniqueSpatialFollowPanelStore", C_UniqueSpatialFollowPanelStore, C_StoreGroup)
GroupName2Class.UniqueSpatialFollowPanelStore = C_UniqueSpatialFollowPanelStore
local M = C_UniqueSpatialFollowPanelStore
local BOOL2CTL = {
	[true] = 0,
	[false] = 1
}

M.ctor = function(self)
	self.DEFINE_DynamicOnUpdate = true
end

M.DefineAllVariables = function(self)
	self.isInteractionTargetShow = true
	self.mindPowerHold = false
	self.mindPowerHelp = false
	self.unitBtnShow = false
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
end

M.OnShow = function(self)
	self.isMobile = not gCS.LuaUtils.IsNonMobileAdaptive()

	self.SetInteractionTargetVisible(self, false)
	self.OnUpdate(self)
end

M.OnUpdate = function(self)
	self.HandleHelpTarget(self)

	if self.isMobile then
		self.HandleInteractionTarget(self)
	end
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnLanguageChange = function(self, lang)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.MIND_POWER_SWITCH_HOLD_MODE] = function (eventId, data)
			self.mindPowerHold = data

			self:RefreshUpdateStatus()
		end,
		[gEventConstants.MIND_POWER_HELP_LOCK_CHANGE] = function (eventId, data)
			self.mindPowerHelp = data

			self:RefreshUpdateStatus()
		end,
		[gEventConstants.INTERACT_BTN_EXIST_CHANGE] = function (eventId, data)
			self.unitBtnShow = data

			self:RefreshUpdateStatus()
		end
	}
end

M.HandleHelpTarget = function(self)
	if gCS.MindPowerMgr.inRefreshHelpLock then
		self.RefreshHelpLockTarget(self)
	else
		self.RefreshHoldHelpTarget(self)
	end
end

M.SwitchShowHelpHold = function(self, show)
	if self.bindData.showHelpTemp ~= BOOL2CTL[show] then
		return
	end

	if show then
		gSoundMgr:PlaySoundByTid(70600180)
	end

	self.bindData.showHelpTemp = BOOL2CTL[show]

	gShootManager:OnRefreshFire()
end

M.RefreshHelpLockTarget = function(self)
	if not gCS.MindPowerMgr.inRefreshHelpLock then
		self.SwitchShowHelpHold(self, false)

		return
	end

	if gCS.MindPowerMgr.refreshLockUnit ~= nil then
		self.SwitchShowHelpHold(self, false)

		return
	end

	local targetPos = nil
	local unit = gCS.MindPowerMgr.refreshLockUnit
	local modelSlot = unit.ModelSlot

	if not modelSlot then
		self.SwitchShowHelpHold(self, false)

		return
	end

	if modelSlot.upbody then
		targetPos = modelSlot.upbody.position
	elseif modelSlot.upbodySlot then
		targetPos = modelSlot.upbodySlot.position
	else
		targetPos = unit.LocalPosition
	end

	local screenPos = gCS.CameraDataMgr.MainCamera:WorldToScreenPoint(targetPos)
	local uiPos = gUtils:ScreenToUIPosition(screenPos)

	self.bindData.helpTemp:SetLocalPosition(uiPos)
	self:SwitchShowHelpHold(true)
end

M.RefreshHoldHelpTarget = function(self)
	local inHoldMode = false
	inHoldMode = gCS.MindPowerMgr.inHoldMode

	if not inHoldMode then
		self.SwitchShowHelpHold(self, false)

		return
	end

	local hasHoldHelpTarget = false
	hasHoldHelpTarget = gCS.MindPowerMgr:HasHoldHelpTarget()

	if not hasHoldHelpTarget then
		self.SwitchShowHelpHold(self, false)

		return
	end

	local targetPos = nil
	local holdHelpUnitPid = gCS.MindPowerMgr.holdHelpUnitPid

	if holdHelpUnitPid and not ulong.equals(holdHelpUnitPid, 0) then
		local modelSlot = gCS.MindPowerMgr.holdHelpUnit.ModelSlot

		if not gCS.LuaUtils.IsNull(modelSlot) and not gCS.LuaUtils.IsNull(modelSlot.upbody) then
			targetPos = modelSlot.upbody.position
		else
			targetPos = gCS.MindPowerMgr:GetUnitCenter(gCS.MindPowerMgr.holdHelpUnit)
		end
	elseif not gCS.LuaUtils.IsNull(gCS.MindPowerMgr.holdHelpSlot) then
		targetPos = gCS.MindPowerMgr.holdHelpSlot:GetPosition()
	end

	if targetPos ~= nil then
		self.SwitchShowHelpHold(self, false)

		return
	end

	local screenPos = gCS.CameraDataMgr.MainCamera:WorldToScreenPoint(targetPos)
	local uiPos = gUtils:ScreenToUIPosition(screenPos)

	self.bindData.helpTemp:SetLocalPosition(uiPos)
	self:SwitchShowHelpHold(true)
end

M.HandleInteractionTarget = function(self)
	local pid, iconId = gInteractionManager:GetMobileCombineUnitBtnInfo()

	if not pid or not gCS.SceneDataMgr.GetUnit(pid) then
		if self.isInteractionTargetShow then
			self.SetInteractionTargetVisible(self, false)
		end

		return
	end

	self.bindData.interactionIconId = iconId

	if not self.isInteractionTargetShow then
		self.SetInteractionTargetVisible(self, true)
	end

	local unit = gCS.SceneDataMgr.GetUnit(pid)

	self.RefreshInteractionTargetPosition(self, unit)
end

M.SetInteractionTargetVisible = function(self, show)
	self.isInteractionTargetShow = show
	local scale = show and 1 or 0

	self.bindData.interactionTarget:SetLocalScale(scale, scale, 1)
end

M.RefreshInteractionTargetPosition = function(self, unit)
	local targetPos = unit.HeadSlotPos
	local screenPos = gCS.CameraDataMgr.MainCamera:WorldToScreenPoint(targetPos)
	local uiPos = gUtils:ScreenToUIPosition(screenPos)

	self.bindData.interactionTarget:SetLocalPosition(uiPos)
end

M.RefreshUpdateStatus = function(self)
	if self.mindPowerHold or self.mindPowerHelp or self.isMobile and self.unitBtnShow then
		gStoreManager:RegisterDynamicOnUpdate(self)
	else
		gStoreManager:UnregisterDynamicOnUpdate(self)
	end

	self.OnUpdate(self)
end
