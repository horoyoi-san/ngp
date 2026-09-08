-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PhoneFrameTemplateStore.lua
-- Decompiled from: 00847_PhoneFrameTemplateStore.lua_8ccaceaa88ad.luajit

C_PhoneFrameTemplateStore = DefClass("C_PhoneFrameTemplateStore", C_PhoneFrameTemplateStore, C_StoreGroup)
GroupName2Class.PhoneFrameTemplateStore = C_PhoneFrameTemplateStore
local M = C_PhoneFrameTemplateStore
local AtmosphereManager = LX6.Manager.AtmosphereManager
local NetworkReachability = UnityEngine.NetworkReachability
local batteryUtils = LX6.Engine.BatteryUtils
local NetworkState = {
	["\\xacib"] = 1,
	["]-r_"] = 4,
	["I-NT"] = 2,
	["mHOf@,"] = 0,
	["2G\\x83\\x83\\x82M"] = 3
}

M.OnAwake = function(self)
	self.RefreshNetworkView(self)
	self.InitModel(self)
	self.InitMessages(self)
end

M.InitMessages = function(self)
	self.ClearMessageEvents(self)
	self.RegisterMessageEvents(self, {
		[gEventConstants.ON_PHONE_APP_HOME_SHOW] = function (_)
			self.waitShowTipsCo = coroutine.stop(self.waitShowTipsCo)
		end
	})
end

M.OnStart = function(self)
	self.InitBasicTopBarStore(self)

	local widget = self.bindData.basicTopBar

	if widget then
		self.InitView(self)
	end
end

M.InitBasicTopBarStore = function(self, args)
	local widget = self.bindData.basicTopBar

	if widget then
		self.basicTopBarStore = gStoreManager:GetStoreGroup("PhoneBasicTopBarStore"):GetStoreByWidget(widget)

		if self.basicTopBarStore.copyButton then
			self.basicTopBarStore.copyButton.luaClick = self.CreateAction(self, "OnCopyButtonClick")
		end

		if self.basicTopBarStore.copyButtonDark then
			self.basicTopBarStore.copyButtonDark.luaClick = self.CreateAction(self, "OnCopyButtonClick")
		end

		if args then
			local colorCtrl = args and args.colorCtrl

			if colorCtrl then
				self.basicTopBarStore.colorCtrl = colorCtrl
			end
		end
	end
end

M.OnEnable = function(self)
	if self.basicTopBarStore then
		self.RefreshTimeView(self)
		self.RefreshNetworkView(self)
	end
end

M.InitModel = function(self)
	self.timer = 0
	self.updateInterval = 0.5
end

M.InitView = function(self)
	self.InitBasicTopBarView(self)
end

M.InitBasicTopBarView = function(self)
	self.RefreshBaseInfo(self)
	self.RefreshBattery(self)
	self.RefreshNetworkView(self)
	self.RefreshTimeView(self)
end

M.RefreshBaseInfo = function(self)
	self.basicTopBarStore.uid = ulong.tostring(gPlayerManager.infoBase.bindData.Pid)
end

M.RefreshBattery = function(self)
	if self.basicTopBarStore then
		local level = batteryUtils.BatteryLevel
		self.basicTopBarStore.batteryFill = level
		self.basicTopBarStore.inChargeControl = batteryUtils.IsBatteryCharge and 1 or 0
	end
end

M.RefreshNetworkView = function(self)
	if not self.basicTopBarStore then
		return
	end

	if gCS.LuaUtils.GetInternetReachability() ~= NetworkReachability.NotReachable then
		self.basicTopBarStore.networkSignal = NetworkState.NoConnect
	else
		local pingDelayTime = gCS.TimeManager.DelayTime * 1000

		if pingDelayTime < 50 then
			self.basicTopBarStore.networkSignal = NetworkState.Good
		elseif pingDelayTime <= 50 and pingDelayTime < 100 then
			self.basicTopBarStore.networkSignal = NetworkState.Normal
		elseif pingDelayTime > 100 and pingDelayTime >= 200 then
			self.basicTopBarStore.networkSignal = NetworkState.SoSo
		else
			self.basicTopBarStore.networkSignal = NetworkState.Bad
		end
	end
end

M.OnUpdate = function(self)
	if self.bindData.basicTopBar and self.timer then
		self.timer = self.timer + Time.deltaTime

		if self.updateInterval >= self.timer then
			self.timer = 0

			self.RefreshTimeView(self)
			self.RefreshBattery(self)
		end
	end
end

M.RefreshTimeView = function(self)
	local gameTime = AtmosphereManager.Instance:GetGameTime()
	local min = math.floor(gameTime / 60 % 60)
	local hour = math.floor(gameTime / gClientConst.SECONDS_PER_HOUR)
	self.basicTopBarStore.gameTime = ("%02d:%02d"):format(hour, min)
end

M.OnCopyButtonClick = function(self)
	if self.waitShowTipsCo then
		return
	end

	gCS.LuaUtils.PasteText2Clipboard(self.basicTopBarStore.uid)

	slot1 = gMessageManager

	slot1:SendMessage(gEventConstants.ON_SHOW_PHONE_MESSAGE_TIPS, {
		showType = gClientConst.PHONE_MESSAGE_TYPE.Copy_UID_TIPS,
		text = LTConfig.MobileMenuConfig.CopyIDCompleteTips
	})

	self.waitShowTipsCo = coroutine.start(function ()
		coroutine.wait(2.5)

		self.waitShowTipsCo = nil
	end)
end

M.OnDestroy = function(self)
	self.waitShowTipsCo = coroutine.stop(self.waitShowTipsCo)
end

M.OnLanguageChange = function(self, lang)
end
