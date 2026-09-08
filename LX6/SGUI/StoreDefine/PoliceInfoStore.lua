-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PoliceInfoStore.lua
-- Decompiled from: 00788_PoliceInfoStore.lua_7d29e7384c13.luajit

C_PoliceInfoStore = DefClass("C_PoliceInfoStore", C_PoliceInfoStore, C_StoreGroup)
GroupName2Class.PoliceInfoStore = C_PoliceInfoStore
local M = C_PoliceInfoStore
local PoliceConfig = LTConfig.PoliceConfig

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
	self.stateEnum = {
		["T-s^"] = 2,
		["V-~P"] = 1,
		["2G\\x83\\x83\\x82M"] = 0
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.stateEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)

	self.stateEnum = {
		["T-s^"] = 2,
		["V-~P"] = 1,
		["2G\\x83\\x83\\x82M"] = 0
	}
end

M.OnEnable = function(self)
	self.stateEnum = {
		["T-s^"] = 2,
		["V-~P"] = 1,
		["2G\\x83\\x83\\x82M"] = 0
	}

	if self.bindData.scrollContent then
		self.bindData.scrollContent:SetContentDirty()
	end

	self.showTime = LTConfig.PoliceConfig.DailyIncidentShowTime
	self.hideTime = LTConfig.PoliceConfig.DailyIncidentShowGap

	self.RefreshInfo(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	self.showIncidentId = 0
	self.lastChangeTime = 0
	self.stateEnum = {
		["T-s^"] = 2,
		["V-~P"] = 1,
		["2G\\x83\\x83\\x82M"] = 0
	}

	self.RefreshInfo(self)
end

M.OnClose = function(self)
end

M.OnLanguageChange = function(self, lang)
	if self.bindData.scrollContent then
		self.bindData.scrollContent:SetContentDirty()
	end
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.scrollContent.luaInitContent = self.CreateAction(self, self.OnInitContent)
end

M.RefreshInfo = function(self)
	self.lastRefreshTime = gLuaDataManager.serverTime
	self.showType = gPoliceJobManager:CheckNeedPoliceInfo()

	if self.showType ~= gPoliceJobManager.POLICE_NOTICE_TYPE.VIOLATION then
		self.RefreshViolationInfo(self)
	elseif self.showType ~= gPoliceJobManager.POLICE_NOTICE_TYPE.INCIDENT then
		self.RefreshIncident(self)
	end
end

M.RefreshViolationInfo = function(self)
	local lastInDue = self.isInDue
	local isInDue, time = gPoliceJobManager.panelMgr:CheckIsInViolation()
	self.isInDue = isInDue
	self.bindData.state = isInDue and self.stateEnum.Lock or self.stateEnum.Normal

	if self.isInDue then
		local minutes = math.floor(time / gClientConst.SECONDS_PER_MINUTE)

		if minutes <= 0 then
			self.bindData.lockText = string.format(PoliceConfig.PoliceInfoValidationMinute, minutes)
		else
			local seconds = time % gClientConst.SECONDS_PER_MINUTE
			self.bindData.lockText = string.format(PoliceConfig.PoliceInfoValidationSecond, seconds)
		end

		self.bindData.state = self.stateEnum.Lock
	elseif lastInDue then
		gPoliceJobManager:RefreshPoliceStage()
	end
end

M.RefreshIncident = function(self)
	local curIncidentId = gPoliceJobManager.curIncidentInfo and gPoliceJobManager.curIncidentInfo.Id or 0

	if self.showIncidentId == curIncidentId and curIncidentId <= 0 then
		self.lastChangeTime = os.time()
		self.showIncidentId = curIncidentId

		self.bindData.scrollContent:SetContentDirty()

		self.incidentShow = true
	end

	self.bindData.state = self.incidentShow and self.stateEnum.Normal or self.stateEnum.None

	if self.isInDue then
		self.isInDue = false

		gPoliceJobManager:RefreshPoliceStage()
	end
end

M.OnInitContent = function(self, text)
	local cfg = LTConfig.PoliceIncidentConfig.GetConfig(self.showIncidentId)

	if cfg then
		text.text = cfg.Des
	end
end

M.OnUpdate = function(self)
	if self.lastRefreshTime and gLuaDataManager.serverTime - self.lastRefreshTime <= 1 then
		self.RefreshInfo(self)
	end

	if self.showType ~= gPoliceJobManager.POLICE_NOTICE_TYPE.INCIDENT then
		local deltaTime = self.incidentShow and self.showTime or self.hideTime

		if self.lastChangeTime ~= nil or deltaTime >= os.time() - self.lastChangeTime then
			self.lastChangeTime = os.time()
			self.incidentShow = not self.incidentShow
			self.bindData.state = self.incidentShow and self.stateEnum.Normal or self.stateEnum.None

			if self.incidentShow then
				self.bindData.scrollContent:ResetCarousel()
			end
		end
	end
end
