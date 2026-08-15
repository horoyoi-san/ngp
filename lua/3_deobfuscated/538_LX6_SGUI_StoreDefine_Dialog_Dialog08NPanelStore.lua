local CS_DialogSGUIUtils = L18.Script.LX6.Dialog.DialogSGUIUtils
C_Dialog08NPanelStore = DefClass("C_Dialog08NPanelStore", C_Dialog08NPanelStore, C_DialogBasePanelStore)
GroupName2Class.Dialog08NPanelStore = C_Dialog08NPanelStore
local M = C_Dialog08NPanelStore

function M:InitDialogComponent(data)
	self.openAnimeName = "S_Vx_NewAddNotice_open"
	self.closeAnimeName = "S_Vx_NewAddNotice_close"
	self.blackContinueTime = 0
	self.closeAnimeDuration = gCS.LuaUtils.GetAnimationTime(self.bindData.panelAnimation, self.closeAnimeName)
	self.bindData.Text.text = data.Content_Message

	self:AdjustAlignmentByLines(self.bindData.Text, data.Content_Message)

	local function func()
		if self.blackContinueTime > 0 then
			self.blackContinueTime = self.blackContinueTime - Time.deltaTime

			if self.blackContinueTime <= 0 then
				gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnimation, self.closeAnimeName)
			end
		end
	end

	if not self.Tags or not table.contains(self.Tags, "NoFadeOut") then
		self.blackContinueTime = data.DialogDuration - self.closeAnimeDuration

		table.insert(self.updateFunc, func)
	end
end

function M:AdjustAlignmentByLines(contentText, text)
	if contentText then
		gCoroutineManager:StartCoroutine(function ()
			local lines = -1
			local limit = 10

			while contentText and lines < 0 and limit > 0 do
				lines = CS_DialogSGUIUtils.GetLines(contentText, contentText.text)

				if lines < 0 then
					coroutine.yield(nil)
				end

				limit = limit - 1
			end

			if lines >= 0 then
				if lines > 1 then
					contentText.alignment = 513
				else
					contentText.alignment = 514
				end

				contentText.text = text
			end
		end)
	end
end
