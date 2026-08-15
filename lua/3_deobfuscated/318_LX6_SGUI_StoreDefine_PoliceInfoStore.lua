C_PoliceInfoStore = DefClass("C_PoliceInfoStore", C_PoliceInfoStore, C_StoreGroup)
GroupName2Class.PoliceInfoStore = C_PoliceInfoStore
local M = C_PoliceInfoStore
local PoliceConfig = LTConfig.PoliceConfig

function M:ctor()
	return
end

function M:DefineAllVariables()
	return
end

function M:DefineAllEnumsAutoGen()
	self.stateEnum = {
		Lock = 1,
		Normal = 0
	}
end

function M:ClearAllEnumsAutoGen()
	self.stateEnum = nil
end

function M:OnAwake()
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()
end

function M:OnEnable()
	self:RefreshInfo()
end

function M:OnStart()
	return
end

function M:OnDisable()
	return
end

function M:OnDestroy()
	return
end

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	return
end

function M:OnShow(panelId, data)
	self:RefreshInfo()
end

function M:OnClose()
	return
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end

function M:GenMessageEvents()
	return
end

function M:RegisterWidget()
	return
end

function M:RefreshInfo()
	local lastInDue = self.isInDue
	self.lastRefreshTime = gLuaDataManager.serverTime
	local isInDue, time = gPoliceJobManager.panelMgr:CheckIsInViolation()
	self.isInDue = isInDue
	self.bindData.state = isInDue and self.stateEnum.Lock or self.stateEnum.Normal

	if self.isInDue then
		local minutes = math.floor(time / gClientConst.SECONDS_PER_MINUTE)

		if minutes > 0 then
			self.bindData.lockText = string.format(PoliceConfig.PoliceInfoValidationMinute, minutes)
		else
			local seconds = time % gClientConst.SECONDS_PER_MINUTE
			self.bindData.lockText = string.format(PoliceConfig.PoliceInfoValidationSecond, seconds)
		end
	elseif lastInDue then
		gPoliceJobManager:RefreshPoliceStage()
	end
end

function M:OnUpdate()
	if self.isInDue and self.lastRefreshTime and gLuaDataManager.serverTime - self.lastRefreshTime > 1 then
		self:RefreshInfo()
	end
end
