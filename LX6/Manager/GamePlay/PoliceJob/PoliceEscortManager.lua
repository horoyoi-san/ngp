-- Original chunk: @Lua\LuaFiles\LX6\Manager\GamePlay\PoliceJob\PoliceEscortManager.lua
-- Decompiled from: 00551_PoliceEscortManager.lua_c1c488fb5c23.luajit

local PoliceEscortManager = gPoliceJobManager and gPoliceJobManager.escortMgr or {}
local SceneDataMgr = gCS.SceneDataMgr

PoliceEscortManager.GetArrestDispatchSupportDailyLimit = function(self)
	local dailyLimit = LTConfig.PoliceConfig.ArrestSupportDefaultDailyLimit
	local badgeAddDailyLimits = LTConfig.PoliceConfig.ArrestSupportBadgeAddDailyLimit

	for badgeId, addValue in pairs(badgeAddDailyLimits) do
		if gSpiritJobManager:CheckCurSpiritContainBadge(badgeId) then
			dailyLimit = dailyLimit + addValue
		end
	end

	return dailyLimit
end

PoliceEscortManager.IsEscortSupportEnabled = function(self)
	local tid = gSpiritManager:GetCurFirstSpiritTid()

	if tid then
		local dispatchInfo = gPoliceJobManager.panelMgr.dispatchInfo[tid]

		if dispatchInfo then
			local arrestDispatchInfo = dispatchInfo[LTConfig.PoliceDispatchConfig.AutoArrest]

			if arrestDispatchInfo and arrestDispatchInfo.NextAvailableTime < gCS.TimeManager.ServerUnixTime then
				local timeLimit = self:GetArrestDispatchSupportDailyLimit()

				if arrestDispatchInfo.TodayArrestSupportTimes >= timeLimit then
					return true
				end
			end
		end
	end

	return false
end

PoliceEscortManager.EnterEscort_Story = function(self, data)
	local npcUnit = SceneDataMgr.GetUnit(data.targetPid)

	if not gPoliceJobManager.IsUnitValid(npcUnit) then
		print_error("PoliceEscortManager: InitScene npcUnit is nil!, targetPid", data.targetPid)

		return
	end

	print_notice("EnterEscort_Story")

	local module = LX6.Units.Module.Character.AgentCharacterModule.GetModule(npcUnit)

	if module then
		local extraData = module.ClientExtraData

		if not extraData then
			extraData = {}
			module.ClientExtraData = extraData
		end

		if data.hideEscortLeaveBtn ~= true or data.hideEscortLeaveBtn ~= false then
			extraData.hideEscortLeaveBtn = data.hideEscortLeaveBtn
		elseif extraData.hideEscortLeaveBtn ~= nil then
			extraData.hideEscortLeaveBtn = false
		end

		if data.hideEscortReleaseBtn ~= true or data.hideEscortReleaseBtn ~= false then
			extraData.hideEscortReleaseBtn = data.hideEscortReleaseBtn
		elseif extraData.hideEscortReleaseBtn ~= nil then
			extraData.hideEscortReleaseBtn = false
		end

		if data.hideEscortToExamineBtn ~= true or data.hideEscortToExamineBtn ~= false then
			extraData.hideEscortToExamineBtn = data.hideEscortToExamineBtn
		elseif extraData.hideEscortToExamineBtn ~= nil then
			extraData.hideEscortToExamineBtn = false
		end

		if data.traceToNearestPoliceCar ~= true or data.traceToNearestPoliceCar ~= false then
			extraData.traceToNearestPoliceCar = data.traceToNearestPoliceCar
		elseif extraData.traceToNearestPoliceCar ~= nil then
			extraData.traceToNearestPoliceCar = true
		end

		if data.showTraceToPoliceOfficeBtn ~= true or data.showTraceToPoliceOfficeBtn ~= false then
			extraData.showTraceToPoliceOfficeBtn = data.showTraceToPoliceOfficeBtn
		elseif extraData.showTraceToPoliceOfficeBtn ~= nil then
			extraData.showTraceToPoliceOfficeBtn = true
		end
	end
end

PoliceEscortManager.EnterEscortFromExamine_Story = function(self, targetPid, fromExamine, switchWeaponToHand)
	self.targetPid = targetPid
	self.lastTargetPid = targetPid
	local params = {
		targetPid = targetPid
	}
	self.hideEscortLeaveBtn = self.hideEscortLeaveBtnPid and self.hideEscortLeaveBtnPid ~= targetPid

	if switchWeaponToHand then
		gPoliceJobManager:SwitchWeaponToHand()
	end

	self.hideEscortLeaveBtn = false
	self.hideEscortReleaseBtn = false
	self.hideEscortToExamineBtn = false
	self.traceToNearestPoliceCar = true
	self.showTraceToPoliceOfficeBtn = true
	local unit = SceneDataMgr.GetUnit(targetPid)

	if gPoliceJobManager.IsUnitValid(unit) then
		local module = LX6.Units.Module.Character.AgentCharacterModule.GetModule(unit)

		if module and module.ClientExtraData then
			self.hideEscortLeaveBtn = module.ClientExtraData.hideEscortLeaveBtn
			self.hideEscortReleaseBtn = module.ClientExtraData.hideEscortReleaseBtn
			self.hideEscortToExamineBtn = module.ClientExtraData.hideEscortToExamineBtn

			if module.ClientExtraData.traceToNearestPoliceCar == nil then
				self.traceToNearestPoliceCar = module.ClientExtraData.traceToNearestPoliceCar
			end

			if module.ClientExtraData.showTraceToPoliceOfficeBtn == nil then
				self.showTraceToPoliceOfficeBtn = module.ClientExtraData.showTraceToPoliceOfficeBtn
			end
		end
	end

	self.desiredNpcState = nil
	local gameplayControlStore = gStoreManager:GetStoreGroup("CoreHudGameplayControlStore")

	gameplayControlStore:StartGameplayByType(gHUDGameplayType.POLICE_ESCORT, params)
end

PoliceEscortManager.EscortToRelease_Story = function(self, targetPid)
	gPoliceJobManager.cs:AskPoliceEscortInteract(targetPid, LTConfig.PoliceExamInteractConfig.Clearance)
end

PoliceEscortManager.ExitEscort_Story = function(self)
	local gameplayControlStore = gStoreManager:GetStoreGroup("CoreHudGameplayControlStore")

	gameplayControlStore:StopGameplayByType(gHUDGameplayType.POLICE_ESCORT)
end

PoliceEscortManager.EscortToExamine_Story = function(self, targetPid)
	local data = {}
	local npcUnit = SceneDataMgr.GetUnit(targetPid)
	data.targetPid = targetPid
	data.npcUnit = npcUnit
	data.npcTargetDir = npcUnit.Forward
	self.waitEscortToExamineData = data

	gPoliceJobManager.cs:AskPoliceEscortInteract(targetPid, LTConfig.PoliceExamInteractConfig.Examine)
end

PoliceEscortManager.EscortToLeave_Story = function(self, targetPid)
	gPoliceJobManager.cs:AskPoliceEscortInteract(targetPid, LTConfig.PoliceExamInteractConfig.TemporaryLeave)
end

PoliceEscortManager.EscortSupport_Story = function(self, targetPid)
	gPoliceJobManager.cs:AskPoliceEscortInteract(targetPid, LTConfig.PoliceExamInteractConfig.EscortSupport)
end

return PoliceEscortManager
