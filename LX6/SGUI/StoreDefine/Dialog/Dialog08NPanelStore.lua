-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\Dialog\Dialog08NPanelStore.lua
-- Decompiled from: 01943_Dialog08NPanelStore.lua_25bbd4222842.luajit

local CS_DialogSGUIUtils = L18.Script.LX6.Dialog.DialogSGUIUtils
C_Dialog08NPanelStore = DefClass("C_Dialog08NPanelStore", C_Dialog08NPanelStore, C_DialogBasePanelStore)
GroupName2Class.Dialog08NPanelStore = C_Dialog08NPanelStore
local M = C_Dialog08NPanelStore

M.InitDialogComponent = function(self, data)
	self.openAnimeName = "S_Vx_NewAddNotice_open"
	self.closeAnimeName = "S_Vx_NewAddNotice_close"
	self.blackContinueTime = -1
	self.closeAnimeDuration = gCS.LuaUtils.GetAnimationTime(self.bindData.panelAnimation, self.closeAnimeName)
	self.bindData.Text.text = data.Content_Message

	self.AdjustAlignmentByLines(self, self.bindData.Text, data.Content_Message)

	local func = function()
		if self.blackContinueTime <= 0 then
			self.blackContinueTime = self.blackContinueTime + Time.deltaTime

			if self.dialogDurationTime < self.blackContinueTime then
				gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnimation, self.closeAnimeName)

				self.blackContinueTime = -1
			end
		end
	end

	if not self.Tags or not table.contains(self.Tags, "NoFadeOut") then
		self.blackContinueTime = self.closeAnimeDuration
		self.dialogDurationTime = data.DialogDuration

		table.insert(self.updateFunc, func)
	end
end

M.OnDialogDurationChanged = function(self, newDuration)
	self.dialogDurationTime = newDuration
end

M.AdjustAlignmentByLines = function(self, contentText, text)
	if not contentText then
		return
	end

	slot3 = gCoroutineManager

	slot3:StartCoroutine(function ()
		local lines = CS_DialogSGUIUtils.GetLines(contentText)
		local limit = 3

		while contentText and lines >= 0 and limit <= 0 do
			coroutine.yield(nil)

			lines = CS_DialogSGUIUtils.GetLines(contentText)
			limit = limit - 1
		end

		if not contentText or lines >= 0 then
			return
		end

		if lines <= 1 then
			contentText.alignment = 513
		else
			contentText.alignment = 514
		end

		contentText.text = text
	end)
end
