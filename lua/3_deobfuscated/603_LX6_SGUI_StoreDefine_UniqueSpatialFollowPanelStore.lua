C_UniqueSpatialFollowPanelStore = DefClass("C_UniqueSpatialFollowPanelStore", C_UniqueSpatialFollowPanelStore, C_StoreGroup)
GroupName2Class.UniqueSpatialFollowPanelStore = C_UniqueSpatialFollowPanelStore
local M = C_UniqueSpatialFollowPanelStore
local BOOL2CTL = {
	[true] = 0,
	[false] = 1
}

function M:ctor()
	self.DEFINE_DynamicOnUpdate = true
end

function M:DefineAllVariables()
	self.isInteractionTargetShow = true
	self.mindPowerHold = false
	self.mindPowerHelp = false
	self.unitBtnShow = false
end

function M:OnAwake()
	self:DefineAllVariables()
	self:GenMessageEvents()
end

function M:OnShow()
	self.isMobile = not gCS.LuaUtils.IsNonMobileAdaptive()

	self:SetInteractionTargetVisible(false)
	self:OnUpdate()
end

function M:OnUpdate()
	self:HandleHelpTarget()

	if self.isMobile then
		self:HandleInteractionTarget()
	end
end

function M:OnGroupEnable()
	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnGroupDisable()
	self:ClearMessageEvents()
end

function M:GenMessageEvents()
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

function M:HandleHelpTarget()
	if gCS.MindPowerMgr.inRefreshHelpLock then
		self:RefreshHelpLockTarget()
	else
		self:RefreshHoldHelpTarget()
	end
end

function M:SwitchShowHelpHold(show)
	if self.bindData.showHelpTemp == BOOL2CTL[show] then
		return
	end

	if show then
		gSoundMgr:PlaySoundByTid(70600180)
	end

	self.bindData.showHelpTemp = BOOL2CTL[show]

	gShootManager:OnRefreshFire()
end

function M:RefreshHelpLockTarget()
	if not gCS.MindPowerMgr.inRefreshHelpLock then
		self:SwitchShowHelpHold(false)

		return
	end

	if gCS.MindPowerMgr.refreshLockUnit == nil then
		self:SwitchShowHelpHold(false)

		return
	end

	local targetPos = nil
	local unit = gCS.MindPowerMgr.refreshLockUnit
	local modelSlot = unit.ModelSlot

	if not modelSlot then
		self:SwitchShowHelpHold(false)

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

function M:RefreshHoldHelpTarget()
	local inHoldMode = false
	inHoldMode = gCS.MindPowerMgr.inHoldMode

	if not inHoldMode then
		self:SwitchShowHelpHold(false)

		return
	end

	local hasHoldHelpTarget = false
	hasHoldHelpTarget = gCS.MindPowerMgr:HasHoldHelpTarget()

	if not hasHoldHelpTarget then
		self:SwitchShowHelpHold(false)

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
	elseif not gCS.LuaUtils.IsNull(gCS.MindPowerMgr.holdHelpItem) then
		targetPos = gCS.MindPowerMgr.holdHelpItem.TargetCenter:GetPosition()
	elseif not gCS.LuaUtils.IsNull(gCS.MindPowerMgr.holdHelpSlot) then
		targetPos = gCS.MindPowerMgr.holdHelpSlot:GetPosition()
	end

	if targetPos == nil then
		self:SwitchShowHelpHold(false)

		return
	end

	local screenPos = gCS.CameraDataMgr.MainCamera:WorldToScreenPoint(targetPos)
	local uiPos = gUtils:ScreenToUIPosition(screenPos)

	self.bindData.helpTemp:SetLocalPosition(uiPos)
	self:SwitchShowHelpHold(true)
end

function M:HandleInteractionTarget()
	local pid, iconId = gInteractionManager:GetMobileCombineUnitBtnInfo()

	if not pid or not gCS.SceneDataMgr.GetUnit(pid) then
		if self.isInteractionTargetShow then
			self:SetInteractionTargetVisible(false)
		end

		return
	end

	self.bindData.interactionIconId = iconId

	if not self.isInteractionTargetShow then
		self:SetInteractionTargetVisible(true)
	end

	local unit = gCS.SceneDataMgr.GetUnit(pid)

	self:RefreshInteractionTargetPosition(unit)
end

function M:SetInteractionTargetVisible(show)
	self.isInteractionTargetShow = show
	local scale = show and 1 or 0

	self.bindData.interactionTarget:SetLocalScale(scale, scale, 1)
end

function M:RefreshInteractionTargetPosition(unit)
	local targetPos = unit.HeadSlotPos
	local screenPos = gCS.CameraDataMgr.MainCamera:WorldToScreenPoint(targetPos)
	local uiPos = gUtils:ScreenToUIPosition(screenPos)

	self.bindData.interactionTarget:SetLocalPosition(uiPos)
end

function M:RefreshUpdateStatus()
	if self.mindPowerHold or self.mindPowerHelp or self.isMobile and self.unitBtnShow then
		gStoreManager:RegisterDynamicOnUpdate(self)
	else
		gStoreManager:UnregisterDynamicOnUpdate(self)
	end

	self:OnUpdate()
end
