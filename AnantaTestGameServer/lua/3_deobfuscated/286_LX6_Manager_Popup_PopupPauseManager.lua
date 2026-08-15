C_PopupPauseManager = DefClass("C_PopupPauseManager", C_PopupPauseManager)
local M = C_PopupPauseManager

function M:ctor()
	self.DEBUG = false
	self.mgr = gNewPopupManager
	self.pause = false
	self.PAUSE_REASON = {
		PHONE_OPEN = 2,
		SPOON = 6,
		MESSAGE_EVENT = 1,
		TGS_MODE = 7,
		CIRCLE_OPEN = 3,
		BVB = 8,
		COMMON_REWARD_OPEN = 4
	}
	self.pauseCount = 0
	self.pauseDict = {}
	self.pauseDownCount = 0
	self.pauseDownDict = {}
	self.msgEvents = {
		[gEventConstants.DROP_QUEUE_PAUSE] = self:CreateActionWithArgs("DropQueuePause", true),
		[gEventConstants.DROP_QUEUE_RESUME] = self:CreateActionWithArgs("DropQueuePause", false),
		[gEventConstants.ON_PHONE_APP_HOME_SHOW] = self:CreateAction("OnPhoneAppShow"),
		[gEventConstants.ON_PHONE_APP_HOME_HIDE] = self:CreateAction("OnPhoneAppHide")
	}
end

function M:OnInit()
	for event, func in pairs(self.msgEvents) do
		gMessageManager:AddMessageListener(event, func)
	end
end

function M:OnUpdate()
	self:UpdatePauseCountDown()
end

function M:PausePopup(reason, countDown)
	self:AddPauseCountDown(reason, countDown)

	if self.pauseDict[reason] then
		return
	end

	self.pauseDict[reason] = true

	if reason == self.PAUSE_REASON.TGS_MODE then
		self.mgr.tgsStop = true
	end

	self.pauseCount = self.pauseCount + 1

	self:SetPause(self.pauseCount > 0)
	print_notice("PopupPauseManager => 【pause】PausePopup", "reason=", reason, "countDown=", countDown, "pauseCount=", self.pauseCount)
end

function M:ResumePopup(reason)
	self:RemovePauseCountDown(reason)

	if not self.pauseDict[reason] then
		return
	end

	self.pauseDict[reason] = nil
	self.pauseCount = self.pauseCount - 1

	self:SetPause(self.pauseCount > 0)

	if reason == self.PAUSE_REASON.TGS_MODE then
		self.mgr.tgsStop = false
	end

	print_notice("PopupPauseManager => 【pause】ResumePopup", "reason=", reason, "pauseCount=", self.pauseCount)
end

function M:AddPauseCountDown(reason, countDown)
	if self.pauseDownDict[reason] then
		self.pauseDownDict[reason] = countDown
	else
		self.pauseDownDict[reason] = countDown

		if self.pauseDownCount == 0 then
			print_notice("PopupPauseManager => RegisterUpdate")
			gLuaClient:RegisterDynamicUpdate("gPopupPauseManager", self)
		end

		self.pauseDownCount = self.pauseDownCount + 1
	end
end

function M:RemovePauseCountDown(reason)
	if self.pauseDownDict[reason] then
		self.pauseDownDict[reason] = nil
		self.pauseDownCount = self.pauseDownCount - 1

		if self.pauseDownCount == 0 then
			print_notice("PopupPauseManager => UnregisterUpdate")
			gLuaClient:UnregisterDynamicUpdate("gPopupPauseManager")
		end
	end
end

function M:UpdatePauseCountDown()
	for reason, time in pairs(self.pauseDownDict) do
		local newTime = time - Time.deltaTime

		if newTime <= 0 then
			self:ResumePopup(reason)
		else
			self.pauseDownDict[reason] = newTime
		end
	end
end

function M:SetPause(pause)
	self.pause = pause

	self.mgr:SetPause(pause)
end

function M:OnPhoneAppShow()
	self:PausePopup(self.PAUSE_REASON.PHONE_OPEN)
end

function M:OnPhoneAppHide()
	self:ResumePopup(self.PAUSE_REASON.PHONE_OPEN)
end

function M:DropQueuePause(pause)
	if pause then
		self:PausePopup(self.PAUSE_REASON.MESSAGE_EVENT, 20)
	else
		self:ResumePopup(self.PAUSE_REASON.MESSAGE_EVENT)
	end
end

function M:SpoonPause(pause)
	if pause then
		self:PausePopup(self.PAUSE_REASON.SPOON)
		self.mgr:CloseAllActivePopup()
	else
		self:ResumePopup(self.PAUSE_REASON.SPOON)
	end
end

function M:DumpPopupInfo()
	local pauseInfo = string.format("PauseInfo: pause=%s, pauseCount=%d pauseDetail=\n", self.pause, self.pauseCount)

	for reason, _ in pairs(self.pauseDict) do
		pauseInfo = pauseInfo .. reason .. " / "
	end

	pauseInfo = pauseInfo .. "\n"

	return pauseInfo
end

gPopupPauseManager = gPopupPauseManager or C_PopupPauseManager.new()
