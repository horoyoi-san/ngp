local Ease = DG.Tweening.Ease
C_HackerArcadeSkillStore = DefClass("C_HackerArcadeSkillStore", C_HackerArcadeSkillStore, C_StoreGroup)
GroupName2Class.HackerArcadeSkillStore = C_HackerArcadeSkillStore
local M = C_HackerArcadeSkillStore

function M:ctor()
	return
end

function M:DefineAllVariables()
	self.skillText = nil
	self.skillCb = nil
	self.skillTime = 0
	self.timeGet = nil
	self.cfgId = 0
	self.isColdDown = false
	self.isDestroy = false
	self.lastUpdateTime = 0
	self.initFinish = false
	self.netBlock = false
	self.allowSkillUse = false
	self.skillCost = 0
	self.isUpdate = false
	self.allowSkillUseOut = true
end

function M:OnAwake()
	self:DefineAllVariables()
	self:RegisterWidget()
	self:GenMessageEvents()
end

function M:OnGroupEnable()
	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnGroupDisable()
	self:ClearMessageEvents()
end

function M:OnDestroy()
	self.isDestroy = true

	self.bindData.skillProgress:StopProgress()
end

function M:GenMessageEvents()
	self.msgEvents = {
		[gEventConstants.HACK_BATTERY_CHANGE] = function (eventId, data)
			self:SyncHackInfo()
		end
	}
end

function M:RegisterSkill(skillText, skillCb, skillTime, cfgId)
	self.skillText = skillText
	self.skillCb = skillCb
	self.skillTime = skillTime
	self.cfgId = cfgId
	self.skillCost = LTConfig.HackerHackTypeConfig.GetConfig(self.cfgId).HackCost

	if skillText then
		self.bindData.skillText = skillText
	end

	self.bindData.skillCostText = string.format(LTConfig.TextScriptTextConfig.GetConfig(89901282).Text, self.skillCost)

	self:SyncHackInfo()
end

function M:RegisterSkillWithTimeGet(skillText, skillCb, timeGet, cfgId)
	self.skillText = skillText
	self.skillCb = skillCb
	self.timeGet = timeGet
	self.cfgId = cfgId
	self.skillCost = LTConfig.HackerHackTypeConfig.GetConfig(self.cfgId).HackCost

	if skillText then
		self.bindData.skillText = skillText
	end

	self.bindData.skillCostText = string.format(LTConfig.TextScriptTextConfig.GetConfig(89901282).Text, self.skillCost)

	self:SyncHackInfo()
end

function M:RegisterWidget()
	self.bindData.skillBtn.luaClick = self:CreateAction("OnClickSkillBtn")
end

function M:OnClickSkillBtn()
	if not self.initFinish then
		return
	end

	if self.netBlock then
		return
	end

	if not self.allowSkillUse then
		return
	end

	self.netBlock = true
	self.bindData.stateCtrl = 1

	gClientToGameDelegate:AskHack(self.cfgId).Callback = function (err)
		if err == LTConfig.MessageConfig.Ok then
			self:RealUseSkill()
		end

		self.netBlock = false
	end
end

function M:RealUseSkill()
	if self.skillCb then
		self.skillCb()
	end

	if self.timeGet then
		self.skillTime = self.timeGet()
	end

	self.bindData.skillBtn.interactable = false
	self.isColdDown = true
	local urgentTime = self.skillTime * 0.9
	self.bindData.stateCtrl = 1
	local maxValue = self.bindData.skillProgress.maxValue
	self.bindData.skillProgress.value = 0

	self.bindData.skillProgress:ProgressToValue(maxValue * 0.9, urgentTime, 0, Ease.Linear)
	self.bindData.ani:Play("S_Vx_HackerArcadeSkillTemplate_Btn_loop")
	gLuaTimeMgrUtils.Delay(function ()
		if self.isDestroy then
			return
		end

		self.bindData.colorCtrl = 1

		self.bindData.skillProgress:ProgressToValue(maxValue, self.skillTime - urgentTime, 0, Ease.Linear)
	end, urgentTime)
	gLuaTimeMgrUtils.Delay(function ()
		if self.isDestroy then
			return
		end

		self.bindData.ani:Stop("S_Vx_HackerArcadeSkillTemplate_Btn_loop")

		self.bindData.colorCtrl = 0

		self:SyncHackInfo()
	end, self.skillTime)
end

function M:SetSkillCanUse(enable)
	self.allowSkillUseOut = enable

	if enable and self.isColdDown then
		return
	end

	self.bindData.skillBtn.interactable = enable
end

function M:SyncHackInfo()
	if not self.bindData.powerProgress then
		return
	end

	local info = gInteractionManager.hackInfo

	self:RefreshFill(info)

	self.initFinish = true
end

function M:RefreshFill(info)
	local maxPower = Mathf.Floor(info.BatteryTotalCount)
	local nowPower = Mathf.Floor(info.BatteryCurrentCount)
	self.bindData.maxPowerText = maxPower
	self.bindData.nowPowerText = nowPower
	local rate = nowPower / maxPower
	self.bindData.powerProgress.normalizedValue = rate
	self.allowSkillUse = self.skillCost <= nowPower and self.allowSkillUseOut

	if self.allowSkillUse then
		self.bindData.stateCtrl = 0
		self.bindData.skillBtn.interactable = true
	elseif self.allowSkillUseOut then
		self.bindData.stateCtrl = 2
	end
end
