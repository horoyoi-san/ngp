C_GuideLongPressPanelStore = DefClass("C_GuideLongPressPanelStore", C_GuideLongPressPanelStore, C_StoreGroup)
GroupName2Class.GuideLongPressPanelStore = C_GuideLongPressPanelStore
local M = C_GuideLongPressPanelStore

function M:OnShow(panelId, data)
	if data.longPressTime and data.longPressTime > 0 then
		if self._timer then
			self._timer:Stop()

			self._timer = nil
		end

		local startTime = Time.time

		self.bindData.progress:ProgressToValue(0)

		self._timer = Timer.New(function ()
			if data.longPressTime < Time.time - startTime then
				self.bindData.progress:ProgressToValue(1)
				self._timer:Stop()

				self._timer = nil

				gPanelManager:Close(gPanelId.S_GUIDE_LONG_PRESS_PANEL)
			end

			local num = (Time.time - startTime) / data.longPressTime

			self.bindData.progress:ProgressToValue(num)
		end, 0.2, -1):Start()
	end
end

function M:OnClose()
	if self._timer then
		self._timer:Stop()

		self._timer = nil
	end
end
