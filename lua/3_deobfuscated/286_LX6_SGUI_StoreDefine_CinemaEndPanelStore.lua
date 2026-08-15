C_CinemaEndPanelStore = DefClass("C_CinemaEndPanelStore", C_CinemaEndPanelStore, C_StoreGroup)
GroupName2Class.CinemaEndPanelStore = C_CinemaEndPanelStore
local M = C_CinemaEndPanelStore

function M:OnAwake()
	self.bindData.alpha = 0
end

function M:OnShow(panelId, data)
	self.startTime = Time.unscaledTime
	self.needUpdate = true

	if data then
		self.OnAnimStop = data.OnAnimStopCallback
	end
end

function M:OnClose()
	self.startTime = nil
	self.needUpdate = nil
	self.OnAnimStop = nil
end

function M:OnUpdate()
	if not self.needUpdate then
		return
	end

	if Time.unscaledTime - self.startTime > 2 then
		self.needUpdate = false
		self.bindData.alpha = 1

		if self.OnAnimStop then
			self.OnAnimStop()

			self.OnAnimStop = nil
		end
	else
		self.bindData.alpha = (Time.unscaledTime - self.startTime) / 2
	end
end
