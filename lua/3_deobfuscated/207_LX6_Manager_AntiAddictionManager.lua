local GameConfig = LTConfig.GameConfig
local MessageConfig = LTConfig.MessageConfig
local M = {
	OnlineTimeLeft = 0,
	OnLineTimeLeft_StartTime = 0,
	MsgContent = nil,
	ShowNoIdentity = false,
	TimeLeftTimers = {},
	OnBeforeSwitchScene = function (self, switchType)
		if switchType == gSwitchSceneType.KickToLogin then
			self.OnlineTimeLeft = 0
			self.MsgContent = nil
			self.ShowNoIdentity = false

			self:ClearTimeLeftTimers()
		end
	end,
	ClearTimeLeftTimers = function (self)
		for _, t in ipairs(self.TimeLeftTimers) do
			t:Stop()
		end

		self.TimeLeftTimers = {}
	end,
	OnMsg = function (self, onlineTime, content)
		self.OnlineTimeLeft = onlineTime
		self.OnLineTimeLeft_StartTime = Time.realtimeSinceStartup
		self.MsgContent = content

		if gCS.LoginManager.NeedRoleEnter and self.OnlineTimeLeft > 0 then
			self:SetOnlineTimeLeftTimers()
		end
	end,
	ShowNoIdentityUI = function (self)
		if not self.ShowNoIdentity then
			self.ShowNoIdentity = true

			if gCS.LoginManager.NeedRoleEnter then
				gCS.LoginManager:ShowAntiAdditionMessage(self.MsgContent, false)

				if #self.TimeLeftTimers == 0 and self.OnlineTimeLeft > 0 then
					self:SetOnlineTimeLeftTimers()
				end
			end
		end
	end,
	SetOnlineTimeLeftTimers = function (self)
		local timePass = Time.realtimeSinceStartup - self.OnLineTimeLeft_StartTime
		local onlineTimeLeft = self.OnlineTimeLeft - timePass
		self.TimeLeftTimers = {}

		for _, t in ipairs(GameConfig.TimeReminder) do
			local tt = t

			if onlineTimeLeft > t * 60 then
				table.insert(self.TimeLeftTimers, Timer.New(function ()
					self:RemindOnlineTimeLeft(tt)
				end, onlineTimeLeft - t * 60):Start(true))
			end
		end
	end,
	RemindOnlineTimeLeft = function (self, tt)
		local isRealNameVerified = gCS.LoginManager:IsRealNameVerified()

		if not isRealNameVerified then
			gDisplayMessageMgr:ShowMessage(MessageConfig.NoIdentityPlayerLessTime, nil, nil, tt)
		else
			gDisplayMessageMgr:ShowMessage(MessageConfig.MinorPlayerLessTime, nil, nil, tt)
		end
	end
}
gAntiAddictionManager = M
