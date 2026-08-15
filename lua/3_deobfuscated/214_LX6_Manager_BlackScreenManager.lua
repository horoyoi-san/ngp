C_BlackScreenManager = DefClass("C_BlackScreenManager", C_BlackScreenManager)
local M = C_BlackScreenManager

function M:ctor()
	self.isTransition = false
	self.blackPanel = nil
	self.debug = false
	self.setId = nil
	self.text = ""
	self.isWhite = false
	self.crossScene = false
	self.openTime = -1
	self.stayTimeMin = -1
	self.stayTimeMax = -1
	self.closeTime = -1
	self.openCallback = nil
	self.stayCallback = nil
	self.closeCallback = nil
	self.transitionStartTime = -1
	self.delayCloseTimer = gMessageManager:AddMessageListener(gEventConstants.PANEL_ON_SHOW, function (eventId, data)
		if data == gPanelId.PVP_LOADING_PANEL then
			if self.crossScene then
				if self.blackPanel and self.isTransition then
					self.blackPanel:DisableControl(true)
				end
			else
				self:ClearTransition(nil, true)
			end
		end
	end)

	gMessageManager:AddMessageListener(gEventConstants.AFTER_SWITCH_SCENE, function (eventId, switchType)
		if switchType == gSwitchSceneType.KickToLogin then
			self:ClearTransition(nil, true)
		end
	end)
end

function M:OpenTransition(id, text, isWhite, crossScene, openTime, stayTimeMin, stayTimeMax, closeTime, openCb, stayCb, closeCb)
	if not self.blackPanel then
		if self.debug then
			print_notice("BLACK_SCREEN_MANAGER => OpenTransition Failed, blackPanel is nil. 参数 = ", id, text, isWhite, crossScene, openTime, stayTimeMin, stayTimeMax, closeTime, openCb, stayCb, closeCb, Time.time, Time.frameCount)
		end

		return
	end

	if self.isTransition and self.debug then
		print_notice("BLACK_SCREEN_MANAGER => OpenTransition 冲突, 黑屏覆盖, 有前置黑屏未结束 [已设置id,当前id]=", self.setId, id, Time.time, Time.frameCount)
	end

	if self.debug then
		print_notice("BLACK_SCREEN_MANAGER => OpenTransition Success, 参数 = ", id, text, isWhite, crossScene, openTime, stayTimeMin, stayTimeMax, closeTime, openCb, stayCb, closeCb, Time.time, Time.frameCount)
	end

	self:SetTransition(id, text, isWhite, crossScene, openTime, stayTimeMin, stayTimeMax, closeTime, openCb, stayCb, closeCb)
	self.blackPanel:SetTransition(text, isWhite, openTime, stayTimeMax, closeTime, openCb, stayCb, closeCb)
end

function M:CloseTransition(id, closeTime, stayCb, closeCb)
	if not self.blackPanel then
		if self.debug then
			print_notice("BLACK_SCREEN_MANAGER => CloseTransition Failed, blackPanel is nil. [已设置id,当前id]=", self.setId, id, closeTime, stayCb, closeCb, Time.time, Time.frameCount)
		end

		return
	end

	if not self.isTransition then
		if self.debug then
			print_notice("BLACK_SCREEN_MANAGER => CloseTransition Failed. 当前未设置黑屏，无需关闭 [已设置id,当前id]=", self.setId, id, closeTime, stayCb, closeCb, Time.time, Time.frameCount)
		end

		return
	end

	local span = self.transitionStartTime + self.stayTimeMin + self.openTime - Time.time

	if self.debug then
		print_notice("BLACK_SCREEN_MANAGER => Try CloseTransition.  [已设置id,当前id]=", self.setId, id, closeTime, stayCb, closeCb, Time.time, Time.frameCount)
	end

	if self:CheckIdMatch(id) then
		self:UpdateTransitionClose(closeTime, stayCb, closeCb)

		if self.stayTimeMin > 0 and self.transitionStartTime > 0 and span > 0 then
			if self.debug then
				print_notice("BLACK_SCREEN_MANAGER => CloseTransition 延迟关闭, 不满足最短时间限制, [已设置id,当前id]=", self.setId, id, self.transitionStartTime, self.openTime, self.stayTimeMin, span, Time.time, Time.frameCount)
			end

			self:ClearDelayClose()

			self.delayCloseTimer = Timer.New(function ()
				if self.debug then
					print_notice("BLACK_SCREEN_MANAGER => CloseTransition Delay Success， [已设置id,当前id]=", self.setId, id, Time.time, Time.frameCount)
				end

				self.blackPanel:CloseTransition()
			end, span):Start()
		else
			if self.debug then
				print_notice("BLACK_SCREEN_MANAGER => CloseTransition Direct Success， [已设置id,当前id]=", self.setId, id, Time.time, Time.frameCount)
			end

			self.blackPanel:CloseTransition()
		end
	elseif self.debug then
		print_notice("BLACK_SCREEN_MANAGER => CloseTransition Fail, id 不匹配,[已设置id,当前id]=", self.setId, id, Time.time, Time.frameCount)
	end
end

function M:AutoTransition(id, text, isWhite, crossScene, openTime, stayTime, closeTime, openCb, stayCb, closeCb)
	if not self.blackPanel then
		if self.debug then
			print_notice("BLACK_SCREEN_MANAGER => AutoTransition Failed, blackPanel is nil. 参数 = ", id, text, isWhite, crossScene, openTime, stayTime, closeTime, openCb, stayCb, closeCb, Time.time, Time.frameCount)
		end

		return
	end

	if self.isTransition and self.debug then
		print_notice("BLACK_SCREEN_MANAGER => AutoTransition 冲突, 黑屏覆盖, 有前置黑屏未结束 [已设置id,当前id]=", self.setId, id, Time.time, Time.frameCount)
	end

	if self.debug then
		print_notice("BLACK_SCREEN_MANAGER => AutoTransition Success, 参数 = ", id, text, isWhite, crossScene, openTime, stayTime, closeTime, openCb, stayCb, closeCb, Time.time, Time.frameCount)
	end

	self:SetTransition(id, text, isWhite, crossScene, openTime, -1, stayTime, closeTime, openCb, stayCb, closeCb)
	self.blackPanel:SetTransition(text, isWhite, openTime, stayTime, closeTime, openCb, stayCb, closeCb)
end

function M:ClearTransition(id, force)
	if not self.blackPanel then
		LX6.GUI.GuiMgr.Instance:SetShowScenePanel(false, gPanelId.COMMON_BLACK_TRANSITION)
		gPanelManager:RemoveVisibleMode(LX6.Manager.VisibleControlType.CommonBlack)
		LX6.Manager.GameInputManager.SetEnableInput(gPanelId.COMMON_BLACK_TRANSITION)

		if self.debug then
			print_notice("BLACK_SCREEN_MANAGER => ClearTransition Failed, blackPanel is nil.", Time.frameCount)
		end

		return
	end

	if not self.isTransition then
		if self.debug then
			print_notice("BLACK_SCREEN_MANAGER => ClearTransition Failed, 当前未设置黑屏，无需清理 [已设置id,当前id]=", self.setId, id, Time.frameCount)
		end

		return
	end

	if self.debug then
		print_notice("BLACK_SCREEN_MANAGER => Try ClearTransition.", Time.frameCount)
	end

	if force or self.setId == id then
		self.blackPanel:Reset()
	end
end

function M:IsOccupiedById(id)
	return self.isTransition and self.setId == id
end

function M:IsOccupied()
	return self.isTransition
end

function M:OpenBlackInstantly(id)
	if self.debug then
		print_notice("BLACK_SCREEN_MANAGER => OpenBlackInstantly", id, Time.time, Time.frameCount)
	end

	self:OpenTransition(id, "", false, false, 0, -1, -1, 0)
end

function M:CheckIdMatch(id)
	local match = false

	if self.setId == gBlackScreenId.SPOON_TASK then
		match = self.setId == id or id == gBlackScreenId.DIALOG_CAMERA_TEMPLATE or id == gBlackScreenId.TIMELINE

		if self.debug then
			print_notice("BLACK_SCREEN_MANAGER => CloseTransition - CheckIdMatch - SPOON_TASK,[已设置id,当前id,match]=", self.setId, id, match, Time.time, Time.frameCount)
		end

		return match
	end

	match = self.setId == id

	if self.debug then
		print_notice("BLACK_SCREEN_MANAGER => CloseTransition - CheckIdMatch - NORMAL,[已设置id,当前id,match]=", self.setId, id, match, Time.time, Time.frameCount)
	end

	return match
end

function M:OnTransitionEnd()
	self.isTransition = false
	self.transitionStartTime = -1

	self:ClearDelayClose()
	self:Record()
end

function M:SetTransition(id, text, isWhite, crossScene, openTime, stayTimeMin, stayTimeMax, closeTime, openCb, stayCb, closeCb)
	self:ClearDelayClose()
	self:Record(id, text, isWhite, crossScene, openTime, stayTimeMin, stayTimeMax, closeTime, openCb, stayCb, closeCb)

	self.transitionStartTime = Time.time
	self.isTransition = true
end

function M:Record(id, text, isWhite, crossScene, openTime, stayTimeMin, stayTimeMax, closeTime, openCb, stayCb, closeCb)
	self.setId = id
	self.text = text or ""
	self.isWhite = isWhite or false
	self.crossScene = crossScene or false
	self.openTime = openTime or -1
	self.stayTimeMin = stayTimeMin or -1
	self.stayTimeMax = stayTimeMax or -1
	self.closeTime = closeTime or -1
	self.openCallback = openCb
	self.stayCallback = stayCb
	self.closeCallback = closeCb
end

function M:UpdateTransitionClose(closeTime, stayCb, closeCb)
	self.closeTime = closeTime or self.closeTime
	self.stayCallback = stayCb or self.stayCallback
	self.closeCallback = closeCb or self.closeCallback

	self.blackPanel:UpdateTransitionClose(closeTime, stayCb, closeCb)
end

function M:ClearDelayClose()
	if self.delayCloseTimer then
		self.delayCloseTimer:Stop()

		self.delayCloseTimer = nil
	end
end

function M:SetDebugMode(debug)
	print_notice("BLACK_SCREEN_MANAGER => SetDebugMode ", debug)

	self.debug = debug
end

gBlackScreenManager = gBlackScreenManager or C_BlackScreenManager.new()
