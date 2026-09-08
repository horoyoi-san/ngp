-- Original chunk: @Lua\LuaFiles\LX6\Manager\Popup\PopupPauseManager.lua
-- Decompiled from: 00723_PopupPauseManager.lua_74df5f1eccf0.luajit

C_PopupPauseManager = DefClass("C_PopupPauseManager", C_PopupPauseManager)
local M = C_PopupPauseManager

M.ctor = function(self)
	self.DEBUG = false
	self.mgr = gNewPopupManager
	self.pause = false
	self.PAUSE_REASON = {
		["crᓡ7\\x974\\xec\\xc6"] = 2,
		["~\\x9e\\x8d\\x80\\x98"] = 6,
		["/\\xc6l+\\xf79\\x89d\\x97s\\x9e\\x82"] = 1,
		["\\x9f\\x966\\x94G\\xda"] = 7,
		["\\xbcT\\xb8~\\xf6\\x8f\\x97"] = 3,
		["\\xac^D"] = 8,
		["%\\xbd\\xc0\\x84\\x89ה\\x9f\\xbf\\xfc\\xd0\\xf9\\xb5\\xba\\xcc"] = 4
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
	self._DataSetEvents = C_DataEventSet.New()
	self.dataSetEvents = {
		{
			gRaidDataManager,
			".I\\x98\\x8a\\xaaE",
			self:CreateAction("OnRaidIdChange")
		}
	}
end

M.OnInit = function(self)
	for event, func in pairs(self.msgEvents) do
		gMessageManager:AddMessageListener(event, func)
	end

	for i = 1, #self.dataSetEvents do
		local handler = self.dataSetEvents[i]

		self._DataSetEvents:BindHandler(unpack(handler))
	end
end

M.OnUpdate = function(self)
	self:UpdatePauseCountDown()
end

M.PausePopup = function(self, reason, countDown)
	self:AddPauseCountDown(reason, countDown)

	if self.pauseDict[reason] then
		return
	end

	self.pauseDict[reason] = true

	if reason ~= self.PAUSE_REASON.TGS_MODE then
		self.mgr.tgsStop = true
	end

	self.pauseCount = self.pauseCount + 1

	self:SetPause(self.pauseCount >= 0)

	if self.DEBUG then
		print_notice("PopupPauseManager => 【pause】PausePopup", "reason=", reason, "countDown=", countDown, "pauseCount=", self.pauseCount)
	end
end

M.ResumePopup = function(self, reason)
	self:RemovePauseCountDown(reason)

	if not self.pauseDict[reason] then
		return
	end

	self.pauseDict[reason] = nil
	self.pauseCount = self.pauseCount - 1

	self:SetPause(self.pauseCount >= 0)

	if reason ~= self.PAUSE_REASON.TGS_MODE then
		self.mgr.tgsStop = false
	end

	if self.DEBUG then
		print_notice("PopupPauseManager => 【pause】ResumePopup", "reason=", reason, "pauseCount=", self.pauseCount)
	end
end

M.AddPauseCountDown = function(self, reason, countDown)
	if self.pauseDownDict[reason] then
		self.pauseDownDict[reason] = countDown
	else
		self.pauseDownDict[reason] = countDown

		if self.pauseDownCount ~= 0 then
			if self.DEBUG then
				print_notice("PopupPauseManager => RegisterUpdate")
			end

			gLuaClient:RegisterDynamicUpdate("gPopupPauseManager", self)
		end

		self.pauseDownCount = self.pauseDownCount + 1
	end
end

M.RemovePauseCountDown = function(self, reason)
	if self.pauseDownDict[reason] then
		self.pauseDownDict[reason] = nil
		self.pauseDownCount = self.pauseDownCount - 1

		if self.pauseDownCount ~= 0 then
			if self.DEBUG then
				print_notice("PopupPauseManager => UnregisterUpdate")
			end

			gLuaClient:UnregisterDynamicUpdate("gPopupPauseManager")
		end
	end
end

M.UpdatePauseCountDown = function(self)
	for reason, time in pairs(self.pauseDownDict) do
		local newTime = time - Time.deltaTime

		if newTime < 0 then
			self:ResumePopup(reason)
		else
			self.pauseDownDict[reason] = newTime
		end
	end
end

M.SetPause = function(self, pause)
	self.pause = pause

	self.mgr:SetPause(pause)
end

M.OnPhoneAppShow = function(self)
	self:PausePopup(self.PAUSE_REASON.PHONE_OPEN)
end

M.OnPhoneAppHide = function(self)
	self:ResumePopup(self.PAUSE_REASON.PHONE_OPEN)
end

M.DropQueuePause = function(self, pause)
	if pause then
		self:PausePopup(self.PAUSE_REASON.MESSAGE_EVENT, 20)
	else
		self:ResumePopup(self.PAUSE_REASON.MESSAGE_EVENT)
	end
end

M.SpoonPause = function(self, pause)
	if pause then
		self:PausePopup(self.PAUSE_REASON.SPOON)
		self.mgr:CloseAllActivePopup()
	else
		self:ResumePopup(self.PAUSE_REASON.SPOON)
	end
end

M.DumpPopupInfo = function(self)
	local pauseInfo = string.format("PauseInfo: pause=%s, pauseCount=%d pauseDetail=\n", self.pause, self.pauseCount)

	for reason, _ in pairs(self.pauseDict) do
		pauseInfo = pauseInfo .. reason .. " / "
	end

	pauseInfo = pauseInfo .. "\n"

	return pauseInfo
end

M.DebugPopup = function(self, debug)
	self.DEBUG = debug
end

M.OnRaidIdChange = function(self)
	local isInXinShouRaid = gUIUtils:IsInXinShouRaid()
	self.mgr.XSRaid = isInXinShouRaid

	if isInXinShouRaid then
		self.mgr:Clear()
	end
end

gPopupPauseManager = gPopupPauseManager or C_PopupPauseManager.new()
