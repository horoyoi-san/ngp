C_ScreenRecordingWindowStore = DefClass("C_ScreenRecordingWindowStore", C_ScreenRecordingWindowStore, C_StoreGroup)
GroupName2Class.ScreenRecordingWindowStore = C_ScreenRecordingWindowStore
local M = C_ScreenRecordingWindowStore

function M:ctor()
	return
end

function M:OnAwake(panelId, data)
	self.bindData.readyBtn.luaClick = self:CreateAction("OnReadyBtnClick")
	self.bindData.stopBtn.luaClick = self:CreateAction("OnStopBtnClick")
	self.bindData.closeBtn.luaClick = self:CreateAction("OnCloseBtnClick")
	self.recordState = "Stop"
end

function M:OnReadyBtnClick()
	if self.recordState ~= "Stop" then
		return
	end

	L50.Gm.AutoQaFunctions.StartScreenRecord()

	self.bindData.showStatus = 1
end

function M:OnStopBtnClick()
	self.bindData.showStatus = 0
	self.bindData.timeText.text = "00:00"

	L50.Gm.AutoQaFunctions.EndScreenRecord()
end

function M:OnCloseBtnClick()
	if self.recordState ~= "Stop" then
		L50.Gm.AutoQaFunctions.EndScreenRecord()

		if self.recordState == "Recording" then
			gDisplayMessageMgr:ShowMessageContentDebug("结束录制，并在后台进行上传")
		else
			gDisplayMessageMgr:ShowMessageContentDebug("后台会继续进行上传")
		end
	end

	gPanelManager:Close(gPanelId.VIDEO_RECORDING_WINDOW)
end

function M:OnEnable()
	return
end

function M:OnUpdate()
	self.recordState = L50.Gm.AutoQaFunctions.GetScreenRecordState()
	local stateDisplay = {
		Ready = "准备中",
		Recording = "录制中",
		Sending = "正在上传"
	}
	local displayText = stateDisplay[self.recordState]

	if displayText then
		self.bindData.showStatus = 1
		self.bindData.timeText.text = displayText

		return
	end

	self.bindData.showStatus = 0

	if self.recordState == "Stop" then
		self.bindData.notifyText.text = "点击录制"
	end
end

function M:OnShow(panelId, data)
	return
end

function M:OnClose()
	return
end
