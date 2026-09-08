-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PhotographCountDownPanelStore.lua
-- Decompiled from: 00845_PhotographCountDownPanelStore.lua_68b8f001ca1c.luajit

C_PhotographCountDownPanelStore = DefClass("C_PhotographCountDownPanelStore", C_PhotographCountDownPanelStore, C_StoreGroup)
GroupName2Class.PhotographCountDownPanelStore = C_PhotographCountDownPanelStore
local M = C_PhotographCountDownPanelStore
local DOTween = DOTween
local Ease = DG.Tweening.Ease

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.isMeetCondition = false
	self.videoNotFocusTime = 0
	self.failureTime = 0
	self.hasVideoSettle = false
	self.inPhotoMode = false
	self.photoSuccessTimes = 0
	self.photoNowTimes = 0
	self.photoFailTime = 0
	self.photoTimeTween = nil
end

M.DefineAllEnumsAutoGen = function(self)
	self.showCountDownCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.crazyPhotoCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.showCountDownCtrlEnum = nil
	self.crazyPhotoCtrlEnum = nil
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
	self.isMeetCondition = false
	self.videoNotFocusTime = 0
	self.failureTime = 0
	self.hasVideoSettle = false
	self.inPhotoMode = false
	self.photoSuccessTimes = 0
	self.photoNowTimes = 0
	self.photoFailTime = 0
	self.photoTimeTween = nil
	self.bindData.showCountDownCtrl = 0
	self.bindData.crazyPhotoCtrl = 0
end

M.OnClose = function(self)
	self.isMeetCondition = false
	self.videoNotFocusTime = 0
	self.failureTime = 0
	self.hasVideoSettle = false
	self.inPhotoMode = false
	self.photoSuccessTimes = 0
	self.photoNowTimes = 0
	self.photoFailTime = 0
	self.bindData.showCountDownCtrl = 0
	self.bindData.crazyPhotoCtrl = 0

	if self.photoTimeTween then
		self.photoTimeTween:Kill()

		self.photoTimeTween = nil
	end
end

M.OnActiveDeviceChange = function(self, device)
end

M.OnUpdate = function(self)
	if gCS.PhotoManager.Instance.isUsingNewPhotoTask then
		self.RefreshTaskUI(self)

		return
	end

	if self.hasVideoSettle or self.failureTime < 0 then
		return
	end

	if not self.inPhotoMode then
		if not self.isMeetCondition then
			self.videoNotFocusTime = self.videoNotFocusTime + Time.unscaledDeltaTime
			local time = math.max(self.failureTime - self.videoNotFocusTime, 0)
			local timeStr = math.floor(time) .. "s"
			self.bindData.timeText.text = timeStr
			self.bindData.showCountDownCtrl = 1
		else
			self.bindData.showCountDownCtrl = 0
		end

		if self.failureTime < self.videoNotFocusTime then
			self.DoVideoSettleFail(self)

			return
		end
	end
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.PHOTO_CUSTOM_TARGET] = function (eventId, data)
			if gCS.PhotoManager.Instance.isUsingNewPhotoTask then
				return
			end

			if data and data.Type ~= gTakePhotoUtils.PhotoCustomTargetType.Video and data.failureTime and data.failureTime <= 0 then
				self.failureTime = data.failureTime
			end
		end,
		[gEventConstants.VIDEO_TASK_MULTI_TARGET] = function (eventId, data)
			if gCS.PhotoManager.Instance.isUsingNewPhotoTask then
				return
			end

			if data.failureTime and data.failureTime <= 0 then
				self.failureTime = data.failureTime
			end
		end,
		[gEventConstants.VIDEO_COUNTDOWN_CONDITION] = function (eventId, data)
			if gCS.PhotoManager.Instance.isUsingNewPhotoTask then
				return
			end

			if not data then
				return
			end

			self.isMeetCondition = data.isMeetCondition

			if self.isMeetCondition then
				self.videoNotFocusTime = 0
			end

			if self.hasVideoSettle then
				return
			end
		end,
		[gEventConstants.VIDEO_CRAZY_PHOTO_MODE_SIGNAL] = function (eventId, params)
			if gCS.PhotoManager.Instance.isUsingNewPhotoTask then
				return
			end

			if not gPanelManager:IsPanelShowing(gPanelId.S_PHOTOGRAPH_COUNT_DOWN_PANEL) then
				return
			end

			local isEnter = params.isEnter
			self.photoSuccessTimes = params.successTimes
			self.photoFailTime = isEnter and params.failTime or 0
			self.inPhotoMode = isEnter
			self.bindData.crazyPhotoCtrl = isEnter and 1 or 0

			if not isEnter then
				return
			else
				self.photoNowTimes = 0
			end

			self.bindData.warningCtrl = 0
			self.bindData.photoNum = self.photoNowTimes .. "/" .. self.photoSuccessTimes
			slot4 = DOTween.To(function ()
				return 0
			end, function (value)
				self.bindData.photoProgress = value

				if value <= 0.7 then
					self.bindData.warningCtrl = 1
				end
			end, 1, self.photoFailTime)
			slot4 = slot4:SetEase(Ease.Linear)
			self.photoTimeTween = slot4:OnComplete(function ()
				gMessageManager:SendMessage(gEventConstants.VIDEO_CRAZY_PHOTO_FAIL, true)
			end)
		end,
		[gEventConstants.VIDEO_CRAZY_PHOTO_COUNT_UPDATE] = function ()
			self.photoNowTimes = self.photoNowTimes + 1
			self.bindData.photoNum = self.photoNowTimes .. "/" .. self.photoSuccessTimes

			if self.photoSuccessTimes < self.photoNowTimes then
				if self.photoTimeTween then
					self.photoTimeTween:Kill()

					self.photoTimeTween = nil
				end

				self.bindData.photoSuccessCtrl = 1
				slot0 = self
				slot0 = slot0:PlayAniChain(self.bindData.photoSuccessAni, "S_Vx_PhotographGamePanel_Succeed")

				slot0:OnComplete(function ()
					self.bindData.crazyPhotoCtrl = 0

					gMessageManager:SendMessage(gEventConstants.VIDEO_CRAZY_PHOTO_FAIL, false)
				end)
			end
		end,
		[gEventConstants.VIDEO_SHOOT_SUCCESS] = function (eventId, data)
			self.hasVideoSettle = true
		end,
		[gEventConstants.PHOTOGRAPH_GAME_PANEL_ON_SHOW] = function ()
			gPanelManager:CheckShow(gPanelId.S_PHOTOGRAPH_COUNT_DOWN_PANEL)
		end,
		[gEventConstants.CRAZY_PHOTO_SETTLE_NOTIFY_LUA] = function (eventId, isSuccess)
			if not gCS.PhotoManager.Instance.isUsingNewPhotoTask then
				return
			end

			self:RefreshCrazyPhotoUI()

			if isSuccess then
				self.bindData.photoSuccessCtrl = 1
				slot2 = self
				slot2 = slot2:PlayAniChain(self.bindData.photoSuccessAni, "S_Vx_PhotographGamePanel_Succeed")

				slot2:OnComplete(function ()
					self.bindData.crazyPhotoCtrl = 0

					gMessageManager:SendMessage(gEventConstants.VIDEO_CRAZY_PHOTO_FAIL, false)
				end)
			else
				gMessageManager:SendMessage(gEventConstants.VIDEO_CRAZY_PHOTO_FAIL, true)
			end
		end
	}
end

M.RegisterWidget = function(self)
end

M.DoVideoSettleFail = function(self)
	if gTakePhotoUtils.DebugVideoTaskNotAllowFail then
		return
	end

	self.videoNotFocusTime = 0
	self.hasVideoSettle = true

	gMessageManager:SendMessage(gEventConstants.VIDEO_SHOOT_MISSING)
end

M.RefreshTaskUI = function(self)
	local pm = gCS.PhotoManager.Instance

	if not pm.HasTargets(pm) then
		self.bindData.showCountDownCtrl = 0

		return
	end

	local taskType = pm.GetCurPhotoTaskType(pm)

	if taskType ~= 2 and not pm.IsVideoStarted(pm) then
		self.bindData.showCountDownCtrl = 0

		return
	end

	if taskType ~= 3 then
		self.RefreshCrazyPhotoUI(self)

		return
	end

	self.bindData.crazyPhotoCtrl = 0

	if pm.IsMeetCondition(pm) then
		self.bindData.showCountDownCtrl = 0
	else
		self.bindData.showCountDownCtrl = 1
		local failureTime = pm.GetVideoFailureTime(pm)
		local notFocusTime = pm.GetCurNotFocusTime(pm)
		local time = math.max(failureTime - notFocusTime, 0)
		self.bindData.timeText.text = math.floor(time) .. "s"
	end
end

M.RefreshCrazyPhotoUI = function(self)
	local pm = gCS.PhotoManager.Instance

	if pm.IsCrazyMode(pm) then
		self.bindData.crazyPhotoCtrl = 1
		self.bindData.warningCtrl = 0
		local successTimes = pm.GetCrazySuccessTimes(pm)
		local curHit = pm.GetCrazyCurHitCount(pm)
		self.bindData.photoNum = curHit .. "/" .. successTimes
		local failTime = pm.GetCrazyFailTime(pm)

		if failTime <= 0 then
			local progress = math.min(pm:GetCrazyCurTimer() / failTime, 1)
			self.bindData.photoProgress = progress
			self.bindData.warningCtrl = progress <= 0.7 and 1 or 0
		end
	else
		self.bindData.crazyPhotoCtrl = 0
	end
end
