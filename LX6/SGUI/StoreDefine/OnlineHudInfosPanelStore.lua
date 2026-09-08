-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\OnlineHudInfosPanelStore.lua
-- Decompiled from: 01108_OnlineHudInfosPanelStore.lua_0269184d523f.luajit

C_OnlineHudInfosPanelStore = DefClass("C_OnlineHudInfosPanelStore", C_OnlineHudInfosPanelStore, C_StoreGroup)
GroupName2Class.OnlineHudInfosPanelStore = C_OnlineHudInfosPanelStore
local M = C_OnlineHudInfosPanelStore
local RESCUEID = 1000

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.bindData.isRescueCtrl = self.isRescueCtrlEnum._false
	self.curCanRescueTarget = 0
	self.isRescueActive = false
end

M.DefineAllEnumsAutoGen = function(self)
	self.isRescueCtrlEnum = {
		["}Uڍ\\x96\r\\xa8\\xdb\\xed"] = 2,
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.isRescueCtrlEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	if self.bindData.rescueProgress then
		self.bindData.rescueProgress:StopProgress()

		self.bindData.rescueProgress.value = 0
	end

	if data ~= "rescuer" then
		self.isRescuerMode = true
		self.isRescueActive = true

		if self.bindData.showCancelCtrl then
			self.bindData.showCancelCtrl = gCS.LuaUtils.IsNonMobileAdaptive() and 0 or 1
		end

		self.bindData.isRescueCtrl = self.isRescueCtrlEnum.NotPrepare
	else
		self.isRescuerMode = false
		self.isRescueActive = false

		if self.bindData.showCancelCtrl then
			self.bindData.showCancelCtrl = 0
		end

		self.bindData.isRescueCtrl = self.isRescueCtrlEnum._false
	end
end

M.OnClose = function(self)
	self.isRescuerMode = false
	self.isRescueActive = false
	self.bindData.isRescueCtrl = self.isRescueCtrlEnum._false

	if self.bindData.rescueProgress then
		self.bindData.rescueProgress:StopProgress()

		self.bindData.rescueProgress.value = 0
	end
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.RESCUE_PROGRESS_UPDATE] = self.CreateAction(self, "OnReviveProgressUpdate"),
		[gEventConstants.RESCUE_STATE] = self.CreateAction(self, "OnRescueStateChanged"),
		[gEventConstants.REVIVE_TARGET_CHANGED] = self.CreateAction(self, "OnReviveTargetChanged")
	}
end

M.OnRescueStateChanged = function(self, eventId, isRescued)
	self.isRescueActive = isRescued

	if not isRescued then
		if self.bindData.rescueProgress then
			self.bindData.rescueProgress:StopProgress()

			self.bindData.rescueProgress.value = 0
		end

		self.bindData.isRescueCtrl = self.isRescueCtrlEnum._false
	end
end

M.StartPredictProgress = function(self, progress)
	if not self.bindData.rescueProgress then
		return
	end

	local rescueInfo = LTConfig.LinkSucoorConfig.GetConfig(RESCUEID)

	if not rescueInfo then
		return
	end

	local target = math.min((progress + rescueInfo.SuccorRate) / LTConfig.LinkConfig.SuccorMaxValue, self.bindData.rescueProgress.maxValue)

	self.bindData.rescueProgress:ProgressToValue(target, 0.95, 0, DG.Tweening.Ease.Linear)
end

M.OnReviveProgressUpdate = function(self, eventId, progress)
	if not self.bindData.rescueProgress or not self.isRescueActive then
		return
	end

	if self.bindData.isRescueCtrl == self.isRescueCtrlEnum._true then
		self.bindData.isRescueCtrl = self.isRescueCtrlEnum._true
	end

	local maxVal = self.bindData.rescueProgress.maxValue
	local targetValue = progress / LTConfig.LinkConfig.SuccorMaxValue * maxVal

	if self.bindData.rescueProgress.value >= targetValue then
		self.bindData.rescueProgress.value = targetValue
	end

	self.StartPredictProgress(self, progress)
end

M.OnReviveTargetChanged = function(self, eventId, newTarget)
	self.curCanRescueTarget = newTarget
end

M.RegisterWidget = function(self)
	self.bindData.cancelBtn.luaClick = self.CreateAction(self, self.OnClickCancelBtn)
end

M.OnClickCancelBtn = function(self)
	if self.curCanRescueTarget and self.curCanRescueTarget == 0 then
		gClientToGameSceneDelegate:AskStopRescueFallingDownPlayer(self.curCanRescueTarget)
	end
end
