C_HUDlongpressPanelStore = DefClass("C_HUDlongpressPanelStore", C_HUDlongpressPanelStore, C_StoreGroup)
GroupName2Class.HUDlongpressPanelStore = C_HUDlongpressPanelStore
local M = C_HUDlongpressPanelStore

function M:OnShow(panelId, data)
	self._eventHandlers = {
		[gEventConstants.GUIDE_HUD_LONGPRESS_CHANGE] = function (eventId, data)
			if data.countDownStart then
				self:DoStart(data.time)
			elseif data.countDownEnd then
				self:DoEnd()
			elseif data.countDownReset then
				self:DoReset()
			end
		end
	}

	gMessageManager:RegisterEventHandlers(self._eventHandlers)

	self.state = 0
	self.hudBtnStore = gStoreManager:GetStoreGroup("HUDlongPressGuideBtn"):GetStoreByWidget(self.bindData.hudLongPress)

	self:DoReset()
end

function M:OnClose()
	gMessageManager:UnregisterEventHandlers(self._eventHandlers)
end

function M:DoStart(time)
	self.state = 1
	self.timer = time
	self.totalTime = time
	self.hudBtnStore.fill = (self.totalTime - self.timer) / self.totalTime
end

local FINISH_ANIM = "S_Vx_HUDlongpressGuide_Finish"

function M:DoEnd()
	self.state = 2

	self.hudBtnStore.anim:Play(FINISH_ANIM)

	self.endTimer = 1
end

function M:DoReset()
	self.state = 0
	self.timer = 0
	self.hudBtnStore.fill = 0
	self.hudBtnStore.time = ""
	self.totalTime = 0
end

function M:OnUpdate()
	if self.state == 1 then
		if self.timer > 0 then
			self.timer = self.timer - Time.deltaTime
			self.timer = self.timer < 0 and 0 or self.timer
		end

		self.hudBtnStore.fill = (self.totalTime - self.timer) / self.totalTime
	elseif self.state == 2 then
		self.endTimer = self.endTimer - Time.deltaTime

		if self.endTimer <= 0 then
			self.hudBtnStore.anim:Stop(FINISH_ANIM)
			gPanelManager:Close(gPanelId.HUD_LONGPRESS_PANEL)
		end
	end
end
