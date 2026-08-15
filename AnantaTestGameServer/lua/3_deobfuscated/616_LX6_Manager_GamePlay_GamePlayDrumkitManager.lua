local M = gGamePlayDrumkitManager or {}
local DrumkitActionRuleConfig = LTConfig.DrumkitActionRuleConfig

function M:InitParam()
	self.DrumkitKeyType = -1
	self.curActionMaskLayer = -1
	self.curActionMaskHoldTime = 0
	self.leftHandLayer = 5
	self.rightHandLayer = 6
	self.newestHandAction = 0
	self.curLeftHandType = 0
	self.curRightHandType = 0
end

function M:CheckKeyIsLeftOrRight(key)
	if key == 1 or key == 2 or key == 4 or key == 8 or key == 9 then
		return 1
	elseif key == 3 or key == 5 or key == 6 or key == 7 then
		return 2
	end

	return 3
end

function M:EnterGamePlay()
	self:InitParam()
end

function M:EndGamePlay()
	gCS.BaseUnitModuleUtils.RemoveDrumkitModule(gCS.MyPlayerManager.PlayerUnit)
	table.clear(M.tempActionInfo)
end

function M:DoActionAfter(unit, cfg, actionKey)
	if actionKey == 42050026 or cfg.DrumkitKeyType == 0 then
		return
	end

	local LayerIndex, time = gCS.GamePlayDrumkitMgr.DoActionAfter(actionKey, 0)
	self.curActionMaskLayer = LayerIndex
	self.curActionMaskHoldTime = time
	local keyType = self:CheckKeyIsLeftOrRight(self.DrumkitKeyType)
	local k1, k2 = gUtils:UnpackActionID(actionKey)

	if keyType == 1 then
		self.curLeftHandType = k1
	elseif keyType == 2 then
		self.curRightHandType = k1
	end

	self.DrumkitKeyType = -1
end

function M:JudgeKeyRealActionType()
	local keyType = self:CheckKeyIsLeftOrRight(self.DrumkitKeyType)

	if keyType == 3 then
		return 0
	end

	local leftHandAction = self.curLeftHandType
	local rightHandAction = self.curRightHandType
	local checkHand = 0
	local anotherHand = 0

	if keyType == 1 then
		checkHand = leftHandAction
		anotherHand = rightHandAction
	elseif keyType == 2 then
		checkHand = rightHandAction
		anotherHand = leftHandAction
	end

	if checkHand == 0 and anotherHand == 0 then
		return 0
	end

	print_debug("self.DrumkitKeyType", self.DrumkitKeyType, "checkHand", checkHand, "anotherHand", anotherHand)

	if checkHand == 0 and anotherHand > 0 then
		return DrumkitActionRuleConfig.GetUInt(anotherHand, self.DrumkitKeyType)
	end

	if checkHand > 0 and anotherHand == 0 then
		return DrumkitActionRuleConfig.GetUInt(checkHand, self.DrumkitKeyType)
	end

	if checkHand > 0 and anotherHand > 0 then
		return DrumkitActionRuleConfig.GetUInt(self.newestHandAction, self.DrumkitKeyType)
	end
end

function M:DoActionBeforce(actionKey, startTime)
	local k1, k2 = gUtils:UnpackActionID(actionKey)
	local targetAction = self:JudgeKeyRealActionType()

	if targetAction > 0 then
		actionKey = gUtils:GetActionKey(targetAction, k2)
	end

	local newActionKey = 0
	newActionKey, startTime = gCS.GamePlayDrumkitMgr.DoActionBefore(actionKey, 0, 0)

	if newActionKey > 0 then
		local k3, k4 = gUtils:UnpackActionID(newActionKey)
		self.newestHandAction = k3
	end

	return newActionKey, startTime
end

M.tempActionInfo = {}

function M:GetActionLayer(actionType, actionGroup)
	local key = gUtils:GetActionKey(actionType, actionGroup)

	if not self.tempActionInfo[key] then
		self.tempActionInfo[key] = gCS.AnimationManager.CheckActionConfigLayer(gCS.MyPlayerManager.PlayerUnit, key)
	end

	return self.tempActionInfo[key]
end

function M:CheckConfigNoOk(unit, cfg)
	if cfg.DrumkitKeyType > 0 and self.DrumkitKeyType ~= cfg.DrumkitKeyType then
		return true
	end

	local layer = self:GetActionLayer(cfg.TargetAniType, cfg.TargetAniGroup)

	if layer >= 0 and cfg.ActionMaskHoldTime > 0 and layer == self.curActionMaskLayer and unit.time - self.curActionMaskHoldTime <= cfg.ActionMaskHoldTime then
		return true
	end

	return false
end

function M:ClearHandType(type)
	if type == 1 then
		self.curLeftHandType = 0
	else
		self.curRightHandType = 0
	end
end

gGamePlayDrumkitManager = M
