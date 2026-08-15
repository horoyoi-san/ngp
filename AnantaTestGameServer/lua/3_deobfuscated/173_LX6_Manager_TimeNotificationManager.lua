local UXTime = LTUtils.UXTime
local M = {
	count = 0,
	handlers = {},
	funcs = {},
	handlersUnixTime = {},
	defaultNewDay = {
		hour = 0,
		minute = 0
	}
}

function M:RegisterConfigNewDay(func)
	self:Register(M.defaultNewDay.hour, M.defaultNewDay.minute, func)
end

function M:Register(hour, minute, func)
	local minutes = nil

	if self.handlers[minute] then
		minutes = self.handlers[minute]
	else
		minutes = {}
		self.handlers[minute] = minutes
	end

	local hours = nil

	if minutes[hour] then
		hours = minutes[hour]
	else
		hours = {}
		minutes[hour] = hours
	end

	array.push(hours, func)

	self.funcs[func] = minute
end

function M:Unregister(func)
	local minute = self.funcs[func]

	if minute then
		self.funcs[func] = nil
		local minutes = self.handlers[minute]

		if minutes then
			for _, hours in pairs(minutes) do
				array.remove(hours, func)
			end
		end
	else
		for i = #self.handlersUnixTime, 1, -1 do
			if self.handlersUnixTime[i][2] == func then
				table.remove(self.handlersUnixTime, i)
			end
		end
	end
end

function M:Update()
	self.count = self.count - 1

	if self.count <= 0 then
		self.count = 30
		local time = gCS.TimeManager.ServerUnixTime
		local dateTime = UXTime.UnixTimeDoubleToDateTime(time)
		local absoluteMinute = math.floor(time / 60)
		local minute = dateTime.Minute
		local hour = dateTime.Hour

		if self.absoluteMinute and self.absoluteMinute ~= absoluteMinute then
			local minutes = self.handlers[minute]

			if minutes then
				local hours = minutes[hour]

				if hours then
					for _, func in ipairs(hours) do
						func()
					end
				end
			end
		end

		self.absoluteMinute = absoluteMinute

		while #self.handlersUnixTime > 0 and self.handlersUnixTime[1][1] < time do
			local func = self.handlersUnixTime[1][2]

			table.remove(self.handlersUnixTime, 1)
			func()
		end
	end
end

function M:OnBeforeSwitchScene(switchType)
	if switchType == gSwitchSceneType.KickToLogin then
		self.funcs = {}
		self.handlers = {}
	end
end

gTimeNotificationManager = M
