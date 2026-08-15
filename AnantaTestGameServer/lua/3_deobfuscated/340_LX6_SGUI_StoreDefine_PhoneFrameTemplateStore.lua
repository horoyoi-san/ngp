C_PhoneFrameTemplateStore = DefClass("C_PhoneFrameTemplateStore", C_PhoneFrameTemplateStore, C_StoreGroup)
GroupName2Class.PhoneFrameTemplateStore = C_PhoneFrameTemplateStore
local M = C_PhoneFrameTemplateStore
local AtmosphereManager = LX6.Manager.AtmosphereManager
local NetworkReachability = UnityEngine.NetworkReachability
local batteryUtils = LX6.Engine.BatteryUtils
local NetworkState = {
	Bad = 1,
	Good = 4,
	SoSo = 2,
	NoConnect = 0,
	Normal = 3
}

function M:OnAwake()
	self:RefreshNetworkView()
	self:InitModel()
	self:InitMessages()
end

function M:InitMessages()
	self:ClearMessageEvents()
	self:RegisterMessageEvents({
		[gEventConstants.ON_PHONE_APP_HOME_SHOW] = function (_)
			self.waitShowTipsCo = coroutine.stop(self.waitShowTipsCo)
		end
	})
end

function M:OnStart()
	local widget = self.bindData.basicTopBar

	if widget then
		self.basicTopBarStore = gStoreManager:GetStoreGroup("PhoneBasicTopBarStore"):GetStoreByWidget(widget)

		if self.basicTopBarStore.copyButton then
			self.basicTopBarStore.copyButton.luaClick = self:CreateAction("OnCopyButtonClick")
		end

		if self.basicTopBarStore.copyButtonDark then
			self.basicTopBarStore.copyButtonDark.luaClick = self:CreateAction("OnCopyButtonClick")
		end

		self:InitView()
	end
end

function M:OnEnable()
	if self.basicTopBarStore then
		self:RefreshTimeView()
		self:RefreshNetworkView()
	end
end

function M:InitModel()
	self.timer = 0
	self.updateInterval = 0.5
end

function M:InitView()
	self:InitBasicTopBarView()
end

function M:InitBasicTopBarView()
	self:RefreshBaseInfo()
	self:RefreshBattery()
	self:RefreshNetworkView()
	self:RefreshTimeView()
end

function M:RefreshBaseInfo()
	self.basicTopBarStore.uid = ulong.tostring(gPlayerManager.infoBase.bindData.Pid)
end

function M:RefreshBattery()
	if self.basicTopBarStore then
		local level = batteryUtils.BatteryLevel
		self.basicTopBarStore.batteryFill = level
		self.basicTopBarStore.inChargeControl = batteryUtils.IsBatteryCharge and 1 or 0
	end
end

function M:RefreshNetworkView()
	if not self.basicTopBarStore then
		return
	end

	if gCS.LuaUtils.GetInternetReachability() == NetworkReachability.NotReachable then
		self.basicTopBarStore.networkSignal = NetworkState.NoConnect
	else
		local pingDelayTime = gCS.TimeManager.DelayTime * 1000

		if pingDelayTime <= 50 then
			self.basicTopBarStore.networkSignal = NetworkState.Good
		elseif pingDelayTime > 50 and pingDelayTime <= 100 then
			self.basicTopBarStore.networkSignal = NetworkState.Normal
		elseif pingDelayTime >= 100 and pingDelayTime < 200 then
			self.basicTopBarStore.networkSignal = NetworkState.SoSo
		else
			self.basicTopBarStore.networkSignal = NetworkState.Bad
		end
	end
end

function M:OnUpdate()
	if self.bindData.basicTopBar and self.timer then
		self.timer = self.timer + Time.deltaTime

		if self.updateInterval < self.timer then
			self.timer = 0

			self:RefreshTimeView()
			self:RefreshBattery()
		end
	end
end

function M:RefreshTimeView()
	local gameTime = AtmosphereManager.Instance:GetGameTime()
	local min = math.floor(gameTime / 60 % 60)
	local hour = math.floor(gameTime / gClientConst.SECONDS_PER_HOUR)
	self.basicTopBarStore.gameTime = ("%02d:%02d"):format(hour, min)
end

function M:OnCopyButtonClick()
	if self.waitShowTipsCo then
		return
	end

	gCS.LuaUtils.PasteText2Clipboard(self.basicTopBarStore.uid)
	gMessageManager:SendMessage(gEventConstants.ON_SHOW_PHONE_MESSAGE_TIPS, {
		showType = gClientConst.PHONE_MESSAGE_TYPE.Copy_UID_TIPS,
		text = LTConfig.MobileMenuConfig.CopyIDCompleteTips
	})

	self.waitShowTipsCo = coroutine.start(function ()
		coroutine.wait(2.5)

		self.waitShowTipsCo = nil
	end)
end

function M:OnDestroy()
	self.waitShowTipsCo = coroutine.stop(self.waitShowTipsCo)
end
