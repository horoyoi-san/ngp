local AtmosphereManager = LX6.Manager.AtmosphereManager
C_BeachClockStore = DefClass("C_BeachClockStore", C_BeachClockStore, C_StoreGroup)
GroupName2Class.BeachClockStore = C_BeachClockStore
local M = C_BeachClockStore

function M:ctor()
	return
end

function M:OnAwake()
	self.timer = 0
	self.updateInterval = 0.5
end

function M:OnEnable()
	return
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
	if type(data) ~= "table" then
		data = data:ToTable()
	end

	local uiPivot = data.uiPivot
	self.rootGo.transform.position = uiPivot.position
	self.rootGo.transform.rotation = uiPivot.rotation
	self.rootGo.transform.localScale = uiPivot.localScale
end

function M:OnUpdate()
	if self.timer == nil or self.updateInterval == nil then
		return
	end

	self.timer = self.timer + Time.deltaTime

	if self.updateInterval < self.timer then
		self.timer = 0

		self:RefreshTimeView()
	end
end

function M:RefreshTimeView()
	local gameTime = AtmosphereManager.Instance:GetGameTime()
	local min = math.floor(gameTime / 60 % 60)
	local hour = math.floor(gameTime / gClientConst.SECONDS_PER_HOUR)
	local hourTime = gUIUtils:NumberTo2String(hour)
	local minTime = gUIUtils:NumberTo2String(min)
	self.bindData.text = ("%s:%s"):format(hourTime, minTime)
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
