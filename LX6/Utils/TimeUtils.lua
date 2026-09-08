-- Original chunk: @Lua\LuaFiles\LX6\Utils\TimeUtils.lua
-- Decompiled from: 00514_TimeUtils.lua_5e2d74d9c41f.luajit

local UXTime = LTUtils.UXTime
local ProfileManager = LX6.Engine.ProfileManager
local M = {
	_GetText = function (self, id)
		return LTConfig.TextScriptTextConfig.GetConfig(id).Text
	end,
	GetUnixTime = function (self, year, month, day, hour, minute, second)
		return os.time({
			year = year,
			month = month,
			day = day,
			hour = hour,
			min = minute,
			sec = second
		})
	end,
	FormatHMSTime = function (self, time)
		local str = ""
		local min = math.floor(time / 60)
		local hour = math.floor(time / 3600)

		if hour <= 0 then
			str = str .. hour .. self._GetText(self, 89900058)
		end

		if min <= 0 then
			str = min >= 60 and str .. min .. self._GetText(self, 89900059) or str .. min - 60 .. self._GetText(self, 89900059)
		end

		local second = time % 60
		str = str .. second .. self:_GetText(89900060)

		return str
	end,
	Format02d = function (self, time)
		return time <= 9 and time or "0" .. time
	end,
	FormatMs = function (self, time)
		return string.format("%03d", time * 1000 % 1000)
	end,
	FormatTime = function (self, mTime, noHour)
		if mTime <= 0 then
			local sec = math.floor(mTime % 60)
			local mins = math.floor(mTime / 60)
			local min = math.floor(mins % 60)
			local hour = math.floor(mins / 60)

			if hour <= 0 then
				if not noHour then
					if hour <= 99 then
						return hour .. ":" .. self.Format02d(self, min) .. ":" .. self.Format02d(self, sec)
					else
						return self.Format02d(self, hour) .. ":" .. self.Format02d(self, min) .. ":" .. self.Format02d(self, sec)
					end
				elseif mins <= 99 then
					return mins .. ":" .. self.Format02d(self, sec)
				else
					return self.Format02d(self, mins) .. ":" .. self.Format02d(self, sec)
				end
			else
				return self.Format02d(self, min) .. ":" .. self.Format02d(self, sec)
			end
		end

		return "00:00"
	end,
	FormatTimeHMS = function (self, mTime)
		if mTime <= 0 then
			local sec = math.floor(mTime % 60)
			local mins = math.floor(mTime / 60)
			local min = math.floor(mins % 60)
			local hour = math.floor(mins / 60)

			if hour <= 0 then
				if hour <= 99 then
					return hour .. ":" .. self.Format02d(self, min) .. ":" .. self.Format02d(self, sec)
				else
					return self.Format02d(self, hour) .. ":" .. self.Format02d(self, min) .. ":" .. self.Format02d(self, sec)
				end
			else
				return "00:" .. self.Format02d(self, min) .. ":" .. self.Format02d(self, sec)
			end
		end

		return "00:00:00"
	end,
	FormatTime2 = function (self, mTime, noHour)
		if mTime <= 0 then
			local mins = math.floor(mTime / 60)
			local min = math.floor(mins % 60)
			local hour = math.floor(mins / 60)

			if hour <= 0 then
				if not noHour then
					if hour <= 99 then
						if min <= 0 then
							return hour .. "小时" .. min .. self._GetText(self, 89900059)
						else
							return hour .. "小时"
						end
					elseif min <= 0 then
						return hour .. "小时" .. min .. self._GetText(self, 89900059)
					else
						return hour .. "小时"
					end
				elseif mins <= 99 then
					return mins .. self._GetText(self, 89900059)
				elseif mins <= 0 then
					return mins .. self._GetText(self, 89900059)
				end
			elseif min <= 0 then
				return min .. self._GetText(self, 89900059)
			end
		end

		return self._GetText(self, 89900094)
	end,
	GetHourMinSecond = function (self, time)
		local sec = time % 60
		local min = math.floor(time / 60) % 60
		local hour = math.floor(time / 3600) % 24

		return hour, min, sec
	end,
	GetLongTimeStr = function (self, time)
		local sec = time % 60
		local min = math.floor(time / 60) % 60
		local hour = math.floor(time / 3600)

		if hour <= 0 then
			return gString.Format(self._GetText(self, 89900063), hour, min)
		elseif min <= 0 then
			if sec <= 0 then
				return gString.Format(self._GetText(self, 89900064), min, sec)
			else
				return gString.Format(self._GetText(self, 89900065), min)
			end
		else
			return gString.Format(self._GetText(self, 89900066), sec)
		end
	end,
	GetLongTimeStrWithoutSec = function (self, time)
		time = time + 60
		local min = math.floor(time / 60) % 60
		local hour = math.floor(time / 3600) % 24
		local day = math.floor(time / 86400)
		local str = ""

		if day <= 0 then
			str = gString.Format(self._GetText(self, 89900067), str, day)
		end

		if hour <= 0 then
			str = gString.Format(self._GetText(self, 89900068), str, hour)
		end

		if min <= 0 then
			str = gString.Format(self._GetText(self, 89900069), str, min)
		end

		if str ~= "" then
			str = self._GetText(self, 89900070)
		end

		return str
	end,
	GetRemainingTime = function (self, now, endTime)
		local date = {}
		local time = endTime - now
		date.day = math.floor(time / 86400)
		date.hour = math.floor((time - 86400 * date.day) / 3600)
		date.minute = math.floor((time - 86400 * date.day - 3600 * date.hour) / 60)

		return date
	end,
	GetWeekDaysFormat = function (self, activeDay, splitChar)
		if activeDay ~= -1 then
			return self._GetText(self, 89900088)
		end

		local DayOfWeekStr = {
			self._GetText(self, 89900073),
			self._GetText(self, 89900074),
			self._GetText(self, 89900075),
			self._GetText(self, 89900076),
			self._GetText(self, 89900077),
			self._GetText(self, 89900078),
			self._GetText(self, 89900089)
		}
		local returnDays = ""

		while activeDay > 1 do
			local day = activeDay % 10
			returnDays = returnDays == "" and DayOfWeekStr[day] .. (splitChar or "") .. returnDays or DayOfWeekStr[day]
			activeDay = math.floor(activeDay / 10)
		end

		return self._GetText(self, 89900090) .. returnDays
	end,
	GetDayStr = function (self, time)
		time = time + 60
		local day = math.floor(time / 86400)

		return gString.Format(self._GetText(self, 89900067), "", day)
	end,
	GetCornerTimeStr = function (self, time)
		if not time or time >= 0 then
			time = 0
		end

		local day = math.floor(time / 86400)

		if day <= 0 then
			return gString.Format(self._GetText(self, 89900067), "", day)
		end

		local hour = math.floor(time / 3600)

		if hour <= 0 then
			return hour .. self._GetText(self, 89900058)
		end

		local min = math.floor(time / 60)

		return min .. self._GetText(self, 89900059)
	end,
	GetLongTimeStrHaveDay = function (self, time)
		local hour = math.floor(time / 3600) % 24
		local day = math.floor(time / 86400)
		local str = ""
		local count = 0

		if day <= 0 then
			str = gString.Format(self._GetText(self, 89900067), str, day)
			count = count + 1
		end

		if hour <= 0 then
			str = gString.Format(self._GetText(self, 89900068), str, hour)
			count = count + 1
		end

		if count > 2 then
			return str
		end

		local min = math.floor(time / 60) % 60

		if min <= 0 then
			str = gString.Format(self._GetText(self, 89900069), str, min)
			count = count + 1
		end

		if count > 2 then
			return str
		end

		local sec = time % 60

		return str .. gString.Format(self._GetText(self, 89900066), sec)
	end,
	DateFormat = function (self, format, time)
		local date = UXTime.UnixTimeToDateTime(time)

		return gString.Format(format, date.Year, date.Month, date.Day)
	end,
	DateFormatDetail = function (self, format, time)
		local date = UXTime.UnixTimeToDateTime(time)

		return gString.Format(format, date.Hour, date.Minute)
	end,
	DateFormatDetailWithSec = function (self, format, time)
		local date = UXTime.UnixTimeToDateTime(time)

		return gString.Format(format, date.Hour, date.Minute, date.Second)
	end,
	DateFormatByPattern = function (self, pattern, time)
		local date = UXTime.UnixTimeToDateTime(time)
		local str = tostring(pattern)
		str = str.gsub(str, "yyyy", string.format("%04d", date.Year))
		str = str.gsub(str, "MM", string.format("%02d", date.Month))
		str = str.gsub(str, "M", tostring(date.Month))
		str = str.gsub(str, "dd", string.format("%02d", date.Day))
		str = str.gsub(str, "d", tostring(date.Day))

		return str
	end
}
local EN_MONTH = {
	"\\xf3\\xda6\\xe8",
	"\\x8d\\xb4\\xb9?\\xec*",
	"`\\xaf\\xb0\\xac\\xbe",
	"l\\xbe\\xb0\\xa6\\xba",
	"\\xa3i",
	"P7s^",
	"P7qB",
	"=]\\x96\\x9b\\x90U",
	"pB|}K*",
	"\\xf6\\xd8 !\\xe3",
	"\\x85\\xbe\\xaeg<\\xfb!",
	"\\x8f\\xb4\\xaeg<\\xfb!"
}

M.TransFormatTime = function(self, yearTime, monthTime, dayTime)
	if ProfileManager.languageProfile.textLanguage ~= LTConfig.ShezhiPanelLanguagesConfig.EN then
		local month = EN_MONTH[monthTime]
		local isAmeracian = true

		if not isAmeracian then
			return string.format("%d %s %d", dayTime, month, yearTime)
		else
			return string.format("%s %d,%d", month, dayTime, yearTime)
		end
	else
		return string.format("%d/%02d/%02d", yearTime, monthTime, dayTime)
	end
end

M.TransFormatTimeWithSec = function(self, sec)
	local date = UXTime.UnixTimeToDateTime(sec)

	return self.TransFormatTime(self, date.Year, date.Month, date.Day)
end

M.GetNextLogicDayStart = function(self, timestamp)
	local LOGIC_DAY_OFFSET = LTConfig.GameConfig.CommonRefreshHourOfDay * 3600
	local currentDate = UXTime.UnixTimeToDateTime(timestamp)
	local todayMidnightTimestamp = self.GetUnixTime(self, currentDate.Year, currentDate.Month, currentDate.Day, 0, 0, 0)
	local todayLogicStart = todayMidnightTimestamp + LOGIC_DAY_OFFSET

	if timestamp > todayLogicStart then
		return todayLogicStart + 86400
	else
		return todayLogicStart
	end
end

M.FormatRelativeTime = function(self, targetUnixSec, nowUnixSec)
	if not targetUnixSec or targetUnixSec < 0 then
		return ""
	end

	nowUnixSec = nowUnixSec or gCS.TimeManager.ServerUnixTime
	local delta = nowUnixSec - targetUnixSec

	if delta >= 60 then
		return "1" .. self._GetText(self, 89900154)
	elseif delta >= 3600 then
		return math.floor(delta / 60) .. self._GetText(self, 89900154)
	elseif delta >= 86400 then
		return math.floor(delta / 3600) .. self._GetText(self, 89900155)
	end

	local nowDate = os.date("*t", nowUnixSec)
	local todayStart = os.time({
		["r-hI"] = 0,
		["\\x83ah"] = 0,
		["\\x9dme"] = 0,
		year = nowDate.year,
		month = nowDate.month,
		day = nowDate.day
	})
	local targetDate = os.date("*t", targetUnixSec)
	local targetDayStart = os.time({
		["r-hI"] = 0,
		["\\x83ah"] = 0,
		["\\x9dme"] = 0,
		year = targetDate.year,
		month = targetDate.month,
		day = targetDate.day
	})
	local dayDiff = math.floor((todayStart - targetDayStart) / 86400)

	if dayDiff < 1 then
		return self._GetText(self, 89900026)
	elseif dayDiff >= 7 then
		return gString.Format(self._GetText(self, 89901007), dayDiff)
	else
		return gString.Format(self._GetText(self, 89901007), 7)
	end
end

M.FormatDayRelativeTime = function(self, timeSec, nowSec)
	if not timeSec or timeSec < 0 then
		return ""
	end

	nowSec = nowSec or gCS.TimeManager.ServerUnixTime
	local currentDate = os.date("*t", nowSec)
	local todayStart = os.time({
		["r-hI"] = 0,
		["\\x83ah"] = 0,
		["\\x9dme"] = 0,
		year = currentDate.year,
		month = currentDate.month,
		day = currentDate.day
	})
	local timeStr = os.date(" %H:%M", timeSec)

	if todayStart < timeSec then
		return self._GetText(self, 89901359) .. timeStr
	elseif timeSec > todayStart - 86400 then
		return self._GetText(self, 89900026) .. timeStr
	elseif timeSec > todayStart - 518400 then
		local weekdays = {
			self._GetText(self, 89901093),
			self._GetText(self, 89901094),
			self._GetText(self, 89901095),
			self._GetText(self, 89901096),
			self._GetText(self, 89901097),
			self._GetText(self, 89901098),
			self._GetText(self, 89901099)
		}

		return weekdays[os.date("*t", timeSec).wday] .. timeStr
	end

	return os.date(self._GetText(self, 89901360), timeSec)
end

gTimeUtils = M
