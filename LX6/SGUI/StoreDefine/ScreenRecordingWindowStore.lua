-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ScreenRecordingWindowStore.lua
-- Decompiled from: 00873_ScreenRecordingWindowStore.lua_3dd26be3f190.luajit

C_ScreenRecordingWindowStore = DefClass("C_ScreenRecordingWindowStore", C_ScreenRecordingWindowStore, C_StoreGroup)
GroupName2Class.ScreenRecordingWindowStore = C_ScreenRecordingWindowStore
local M = C_ScreenRecordingWindowStore

M.ctor = function(self)
end

M.OnAwake = function(self, panelId, data)
	self.bindData.readyBtn.luaClick = self.CreateAction(self, "OnReadyBtnClick")
	self.bindData.stopBtn.luaClick = self.CreateAction(self, "OnStopBtnClick")
	self.bindData.closeBtn.luaClick = self.CreateAction(self, "OnCloseBtnClick")
	self.recordState = "Stop"
end

M.OnReadyBtnClick = function(self)
	if self.recordState == "Stop" then
		return
	end

	L50.Gm.AutoQaFunctions.StartScreenRecord()

	self.bindData.showStatus = 1
end

M.OnStopBtnClick = function(self)
	self.bindData.showStatus = 0
	self.bindData.timeText.text = "00:00"

	L50.Gm.AutoQaFunctions.EndScreenRecord()
end

M.OnCloseBtnClick = function(self)
	if self.recordState == "Stop" then
		L50.Gm.AutoQaFunctions.EndScreenRecord()

		if self.recordState ~= "Recording" then
			gDisplayMessageMgr:ShowMessageContentDebug("结束录制，并在后台进行上传")
		else
			gDisplayMessageMgr:ShowMessageContentDebug("后台会继续进行上传")
		end
	end

	gPanelManager:Close(gPanelId.VIDEO_RECORDING_WINDOW)
end

M.OnEnable = function(self)
end

M.OnUpdate = function(self)
	self.recordState = L50.Gm.AutoQaFunctions.GetScreenRecordState()
	local stateDisplay = {
		["\\xab\\xa3\\xab\\xaf"] = "Ơ\\x8a\\xec\\x8a\\xf9\\x95\\xca\\xf5",
		["qBof\\?"] = "ƚ\\x99\\xec\\xa6ȕ\\xca\\xf5",
		["\\xea\\xde*\\xf6"] = "\\xe9\\xbbo\\xf2\\xb0zv\\x9f\\x80\\xfe\\xa2\\x8c"
	}
	local displayText = stateDisplay[self.recordState]

	if displayText then
		self.bindData.showStatus = 1
		self.bindData.timeText.text = displayText

		return
	end

	self.bindData.showStatus = 0

	if self.recordState ~= "Stop" then
		self.bindData.notifyText.text = "点击录制"
	end
end

M.OnShow = function(self, panelId, data)
end

M.OnClose = function(self)
end
