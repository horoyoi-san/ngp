local M = gGaoQiaoManager or {}
M.IsInit = M.IsInit or false
local MyPlayerManager = gCS.MyPlayerManager
local LogicStateMachineManager = gCS.LogicStateMachineManager
local ABPCCCEventConfig = LTConfig.ABPCCCEventConfig

function M:OnInit()
	if self.IsInit then
		return
	end

	self.stepOnBambooAnimSpeedStage = 0
	self.commonPressValue = 0
	self.GAO_QIAO_END_TYPE = {
		HOLD_MAX = 3,
		RELEASE_HOLD = 2,
		NO_PRESS_HOLD_BUTTON = 1
	}
	self.IsInit = true
end

function M:ChengGanTiaoPanel(maxWaitTime)
	self.chengGanTiaoTriggered = false
	self.cachedChengGanTiaoEvent = nil
	self.percentCount = nil

	gPanelManager:CheckShow(gPanelId.S_GAMEPLAY_HUD_PANEL, {
		gameplayType = "ChengGanTiao",
		params = {
			maxWaitTime = maxWaitTime
		}
	})
end

function M:BeginChengGanTiaoHold(remainTime)
	local store = gStoreManager:GetStoreGroup("ChengGanTiaoGamePanelStore")

	if store then
		store:BeginHoldProcessByVMotion(remainTime)
	end
end

function M:TriggerChengGanTiaoEnd(type, normalizedProgress)
	if type == self.GAO_QIAO_END_TYPE.RELEASE_HOLD then
		self.percentCount = math.floor(normalizedProgress * 100)
		self.cachedChengGanTiaoEvent = ABPCCCEventConfig.ChengGanTiaoSuccess
	elseif type == self.GAO_QIAO_END_TYPE.HOLD_MAX then
		self.percentCount = 0
		self.cachedChengGanTiaoEvent = ABPCCCEventConfig.ChengGanTiaoFail
	elseif type == self.GAO_QIAO_END_TYPE.NO_PRESS_HOLD_BUTTON then
		LogicStateMachineManager.Send3CEvent(MyPlayerManager.PlayerUnit, ABPCCCEventConfig.ChengGanTiaoNoPressEnd, 0)
	end

	self:TriggerChengGanTiaoFinalEnd()
end

function M:TriggerChengGanTiaoFinalEnd()
	self.chengGanTiaoTriggered = true

	if self.cachedChengGanTiaoEvent then
		gMessageManager:SendMessage(gEventConstants.POLE_RELEASE)
		LogicStateMachineManager.Send3CEvent(MyPlayerManager.PlayerUnit, self.cachedChengGanTiaoEvent, self.percentCount)

		self.cachedChengGanTiaoEvent = nil
		self.percentCount = nil
	end
end

function M:StartStepOnBamboo(barIncreaseLength, barDecreaseInterval, barDecreaseSpeedCurve, animSpeedsAreaList, speedDecreaseFactorsList, speedMapToStateTreeIndexList, sendEventDeltaTime, changeSpeedSignal, stageTwoDelay, stageTwoAnimSpeedsAreaList, outGreenAreaFailTime, greatStateTreeIndexList, perfectStateTreeIndexList, failSignal)
	self.stepOnBambooAnimSpeedStage = 0
	local animSpeedsArea = nil

	if animSpeedsAreaList then
		local animSpeedsAreaTab = animSpeedsAreaList:ToTable()

		if animSpeedsAreaTab and #animSpeedsAreaTab > 0 then
			animSpeedsArea = animSpeedsAreaTab
		end
	end

	local speedDecreaseFactors = nil

	if speedDecreaseFactorsList then
		local speedDecreaseFactorsTab = speedDecreaseFactorsList:ToTable()

		if speedDecreaseFactorsTab and #speedDecreaseFactorsTab > 0 then
			speedDecreaseFactors = speedDecreaseFactorsTab
		end
	end

	local speedMapToStateTreeIndex = nil

	if speedMapToStateTreeIndexList then
		local speedMapToStateTreeIndexTab = speedMapToStateTreeIndexList:ToTable()

		if speedMapToStateTreeIndexTab and #speedMapToStateTreeIndexTab > 0 then
			speedMapToStateTreeIndex = speedMapToStateTreeIndexTab
		end
	end

	local stageTwoAnimSpeedsArea = nil

	if stageTwoAnimSpeedsAreaList then
		local stageTwoAnimSpeedsAreaTab = stageTwoAnimSpeedsAreaList:ToTable()

		if stageTwoAnimSpeedsAreaTab and #stageTwoAnimSpeedsAreaTab > 0 then
			stageTwoAnimSpeedsArea = stageTwoAnimSpeedsAreaTab
		end
	end

	local greatStateTreeIndex = nil

	if greatStateTreeIndexList then
		local greatStateTreeIndexTab = greatStateTreeIndexList:ToTable()

		if greatStateTreeIndexTab and #greatStateTreeIndexTab > 0 then
			greatStateTreeIndex = greatStateTreeIndexTab
		end
	end

	local perfectStateTreeIndex = nil

	if perfectStateTreeIndexList then
		local perfectStateTreeIndexTab = perfectStateTreeIndexList:ToTable()

		if perfectStateTreeIndexTab and #perfectStateTreeIndexTab > 0 then
			perfectStateTreeIndex = perfectStateTreeIndexTab
		end
	end

	gPanelManager:CheckShow(gPanelId.S_GAMEPLAY_HUD_PANEL, {
		gameplayType = "StepOnBamboo",
		params = {
			barIncreaseLength = barIncreaseLength,
			barDecreaseInterval = barDecreaseInterval,
			sendEventDeltaTime = sendEventDeltaTime,
			animSpeedsArea = animSpeedsArea,
			speedDecreaseFactors = speedDecreaseFactors,
			speedMapToStateTreeIndex = speedMapToStateTreeIndex,
			barDecreaseSpeedCurve = barDecreaseSpeedCurve,
			changeSpeedSignal = changeSpeedSignal,
			stageTwoDelay = stageTwoDelay,
			stageTwoAnimSpeedsArea = stageTwoAnimSpeedsArea,
			outGreenAreaFailTime = outGreenAreaFailTime,
			greatStateTreeIndex = greatStateTreeIndex,
			perfectStateTreeIndex = perfectStateTreeIndex,
			failSignal = failSignal
		}
	})
end

function M:GetStepOnBambooAnimSpeedStage()
	return self.stepOnBambooAnimSpeedStage
end

function M:TestStepOnBamboo()
	gPanelManager:CheckShow(gPanelId.S_GAMEPLAY_HUD_PANEL, {
		gameplayType = "StepOnBamboo",
		params = {
			stageTwoDelay = 10,
			sendEventDeltaTime = 0.5,
			changeSpeedSignal = 0,
			barIncreaseLength = 0.05,
			failSignal = 0,
			outGreenAreaFailTime = 3,
			barDecreaseInterval = 30,
			animSpeedsArea = {
				0.25,
				0.5,
				0.75,
				1
			},
			speedDecreaseFactors = {
				1,
				1,
				1,
				1
			},
			speedMapToStateTreeIndex = {
				1,
				2,
				3,
				2
			},
			stageTwoAnimSpeedsArea = {
				0.1,
				0.2,
				0.8,
				1
			},
			greatStateTreeIndex = {
				2
			},
			perfectStateTreeIndex = {
				3
			}
		}
	})
end

function M:OpenGaoQiaoPanel(leftSuccessSignal, leftMissSignal, rightSuccessSignal, rightMissSignal, endSignal)
	self.cachedGaoQiaoVmEvent = nil

	gPanelManager:CheckShow(gPanelId.S_GAMEPLAY_HUD_PANEL, {
		gameplayType = "GaoQiao",
		params = {
			leftSuccessSignal = leftSuccessSignal,
			leftMissSignal = leftMissSignal,
			rightSuccessSignal = rightSuccessSignal,
			rightMissSignal = rightMissSignal,
			endSignal = endSignal
		}
	})
end

function M:OnGaoQiaoVMEvent(type)
	if self.gaoqiaoPanel and self.gaoqiaoPanel.isShow then
		self.gaoqiaoPanel:OnVmSignal(type)
	else
		self.cachedGaoQiaoVmEvent = type
	end
end

function M:OpenCommonPressBar(minValue, maxValue, maxTime, randomShake, shakeTriggerValue, shakeValue, shakeStrength, completeAction)
	gPanelManager:CheckShow(gPanelId.S_GAMEPLAY_HUD_PANEL, {
		gameplayType = "CommonPressBar",
		params = {
			minValue = minValue,
			maxValue = maxValue,
			maxTime = maxTime,
			randomShake = randomShake,
			shakeTriggerValue = shakeTriggerValue,
			shakeValue = shakeValue,
			shakeStrength = shakeStrength,
			completeAction = completeAction
		}
	})
end

function M:SetCommonPressValue(normalizeValue, minValue, maxValue)
	self.commonPressValue = minValue + (maxValue - minValue) * normalizeValue
end

function M:GetCommonPressValue()
	return self.commonPressValue
end

gGaoQiaoManager = M
