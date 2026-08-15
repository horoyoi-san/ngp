local UXTime = LTUtils.UXTime
local ProfileManager = LX6.Engine.ProfileManager
local M = {
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

		if hour > 0 then
			str = str .. hour .. LTConfig.TextScriptTextConfig.GetConfig(89900058).Text
		end

		if min > 0 then
			str = min < 60 and str .. min .. LTConfig.TextScriptTextConfig.GetConfig(89900059).Text or str .. min - 60 .. LTConfig.TextScriptTextConfig.GetConfig(89900059).Text
		end

		local second = time % 60
		str = str .. second .. LTConfig.TextScriptTextConfig.GetConfig(89900060).Text

		return str
	end,
	Format02d = function (self, time)
		return time > 9 and time or "0" .. time
	end,
	FormatMs = function (self, time)
		return string.format("%03d", time * 1000 % 1000)
	end,
	FormatTime = function (self, mTime, noHour)
		if mTime > 0 then
			local sec = math.floor(mTime % 60)
			local mins = math.floor(mTime / 60)
			local min = math.floor(mins % 60)
			local hour = math.floor(mins / 60)

			if hour > 0 then
				if not noHour then
					if hour > 99 then
						return hour .. ":" .. self:Format02d(min) .. ":" .. self:Format02d(sec)
					else
						return self:Format02d(hour) .. ":" .. self:Format02d(min) .. ":" .. self:Format02d(sec)
					end
				elseif mins > 99 then
					return mins .. ":" .. self:Format02d(sec)
				else
					return self:Format02d(mins) .. ":" .. self:Format02d(sec)
				end
			else
				return self:Format02d(min) .. ":" .. self:Format02d(sec)
			end
		end

		return "00:00"
	end,
	FormatTimeHMS = function (self, mTime)
		if mTime > 0 then
			local sec = math.floor(mTime % 60)
			local mins = math.floor(mTime / 60)
			local min = math.floor(mins % 60)
			local hour = math.floor(mins / 60)

			if hour > 0 then
				if hour > 99 then
					return hour .. ":" .. self:Format02d(min) .. ":" .. self:Format02d(sec)
				else
					return self:Format02d(hour) .. ":" .. self:Format02d(min) .. ":" .. self:Format02d(sec)
				end
			else
				return "00:" .. self:Format02d(min) .. ":" .. self:Format02d(sec)
			end
		end

		return "00:00:00"
	end,
	FormatTime2 = function (self, mTime, noHour)
		if mTime > 0 then
			local mins = math.floor(mTime / 60)
			local min = math.floor(mins % 60)
			local hour = math.floor(mins / 60)

			if hour > 0 then
				if not noHour then
					if hour > 99 then
						if min > 0 then
							return hour .. "小时" .. min .. LTConfig.TextScriptTextConfig.GetConfig(89900059).Text
						else
							return hour .. "小时"
						end
					elseif min > 0 then
						return hour .. "小时" .. min .. LTConfig.TextScriptTextConfig.GetConfig(89900059).Text
					else
						return hour .. "小时"
					end
				elseif mins > 99 then
					return mins .. LTConfig.TextScriptTextConfig.GetConfig(89900059).Text
				elseif mins > 0 then
					return mins .. LTConfig.TextScriptTextConfig.GetConfig(89900059).Text
				end
			elseif min > 0 then
				return min .. LTConfig.TextScriptTextConfig.GetConfig(89900059).Text
			end
		end

		return LTConfig.TextScriptTextConfig.GetConfig(89900094).Text
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

		if hour > 0 then
			return gString.Format(LTConfig.TextScriptTextConfig.GetConfig(89900063).Text, hour, min)
		elseif min > 0 then
			if sec > 0 then
				return gString.Format(LTConfig.TextScriptTextConfig.GetConfig(89900064).Text, min, sec)
			else
				return gString.Format(LTConfig.TextScriptTextConfig.GetConfig(89900065).Text, min)
			end
		else
			return gString.Format(LTConfig.TextScriptTextConfig.GetConfig(89900066).Text, sec)
		end
	end,
	GetLongTimeStrWithoutSec = function (self, time)
		time = time + 60
		local min = math.floor(time / 60) % 60
		local hour = math.floor(time / 3600) % 24
		local day = math.floor(time / 86400)
		local str = ""

		if day > 0 then
			str = gString.Format(LTConfig.TextScriptTextConfig.GetConfig(89900067).Text, str, day)
		end

		if hour > 0 then
			str = gString.Format(LTConfig.TextScriptTextConfig.GetConfig(89900068).Text, str, hour)
		end

		if min > 0 then
			str = gString.Format(LTConfig.TextScriptTextConfig.GetConfig(89900069).Text, str, min)
		end

		if str == "" then
			str = LTConfig.TextScriptTextConfig.GetConfig(89900070).Text
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
		if activeDay == -1 then
			return LTConfig.TextScriptTextConfig.GetConfig(89900088).Text
		end

		local DayOfWeekStr = {
			LTConfig.TextScriptTextConfig.GetConfig(89900073).Text,
			LTConfig.TextScriptTextConfig.GetConfig(89900074).Text,
			LTConfig.TextScriptTextConfig.GetConfig(89900075).Text,
			LTConfig.TextScriptTextConfig.GetConfig(89900076).Text,
			LTConfig.TextScriptTextConfig.GetConfig(89900077).Text,
			LTConfig.TextScriptTextConfig.GetConfig(89900078).Text,
			LTConfig.TextScriptTextConfig.GetConfig(89900089).Text
		}
		local returnDays = ""

		while activeDay >= 1 do
			local day = activeDay % 10
			returnDays = returnDays ~= "" and DayOfWeekStr[day] .. (splitChar or "") .. returnDays or DayOfWeekStr[day]
			activeDay = math.floor(activeDay / 10)
		end

		return LTConfig.TextScriptTextConfig.GetConfig(89900090).Text .. returnDays
	end,
	GetDayStr = function (self, time)
		time = time + 60
		local day = math.floor(time / 86400)

		return gString.Format(LTConfig.TextScriptTextConfig.GetConfig(89900067).Text, "", day)
	end,
	GetLongTimeStrHaveDay = function (self, time)
		local hour = math.floor(time / 3600) % 24
		local day = math.floor(time / 86400)
		local str = ""
		local count = 0

		if day > 0 then
			str = gString.Format(LTConfig.TextScriptTextConfig.GetConfig(89900067).Text, str, day)
			count = count + 1
		end

		if hour > 0 then
			str = gString.Format(LTConfig.TextScriptTextConfig.GetConfig(89900068).Text, str, hour)
			count = count + 1
		end

		if count >= 2 then
			return str
		end

		local min = math.floor(time / 60) % 60

		if min > 0 then
			str = gString.Format(LTConfig.TextScriptTextConfig.GetConfig(89900069).Text, str, min)
			count = count + 1
		end

		if count >= 2 then
			return str
		end

		local sec = time % 60

		return str .. gString.Format(LTConfig.TextScriptTextConfig.GetConfig(89900066).Text, sec)
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
	ConvertAgentDateToOsDate = function (self, agentDate, year)
		local currentYear = year or os.date("*t").year
		local timeTable = {
			hour = 0,
			min = 0,
			sec = 0,
			year = currentYear,
			month = agentDate.month,
			day = agentDate.day
		}

		return os.time(timeTable)
	end
}
local EN_MONTH = {
	"January",
	"February",
	"March",
	"April",
	"May",
	"June",
	"July",
	"August",
	"September",
	"October",
	"November",
	"December"
}

function M:TransFormatTime(yearTime, monthTime, dayTime)
	if ProfileManager.languageProfile.textLanguage == LTConfig.ShezhiPanelLanguagesConfig.EN then
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

function M:TransFormatTimeWithSec(sec)
	local date = UXTime.UnixTimeToDateTime(sec)

	return self:TransFormatTime(date.Year, date.Month, date.Day)
end

gTimeUtils = M
