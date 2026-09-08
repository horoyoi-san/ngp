-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\MapSubSystem\MapSubSystem_Crime.lua
-- Decompiled from: 02329_MapSubSystem_Crime.lua_0292506ed6f1.luajit

MapSubSystem_Crime = DefClass("MapSubSystem_Crime", MapSubSystem_Crime, MapSubSystemBase)
local M = MapSubSystem_Crime
local WantedConfig = LTConfig.WantedConfig

M.OnInit = function(self)
	self._tick = false
	self._crimeLevel = 0
	self._escapeDuration = 0
	self._escapeTimer = 0
	self._policeNoticeDuration = 0
	self._policeNoticeTimer = 0
	self._tickHandle = UpdateBeat:CreateListener(self.CrimeTick, self)
end

M.OnBeforeSwitchScene = function(self, switchType)
	self.Clear(self)
end

M.Clear = function(self)
	self._crimeLevel = 0
	self._isEscaping = false
	self._escapeTimer = 0
	self._escapeDuration = 0
	self._policeNoticeTimer = 0
	self._policeNoticeDuration = 0

	self:UnRegistgerTick()
	gMapManager:RemoveMiniMapScaleType(gMapScaleType.Crime)
	gMessageManager:SendMessage(gEventConstants.MINIMAP_CRIME_STATUS_UPDATE, {
		["N\\xa2\\xa7\\xae\\xa4"] = true
	})
end

M.SyncPlayerCrimeLevel = function(self, level)
	self._crimeLevel = level

	if level ~= 0 then
		self.Clear(self)
	else
		gMapManager:SetMiniMapScale(LTConfig.GameConfig.WantedMapScale, gMapScaleType.Crime)
		gMessageManager:SendMessage(gEventConstants.MINIMAP_CRIME_STATUS_UPDATE, {
			crimeLevel = level
		})
	end
end

M.SyncPoliceEscape = function(self, isEscaping)
	self._isEscaping = isEscaping

	if isEscaping then
		if not self._crimeLevel or self._crimeLevel ~= 0 then
			print_error("@xiajingbo SyncPoliceEscape但是CrimeLevel为" .. tostring(self._crimeLevel))

			return
		end

		local config = WantedConfig.GetConfig(self._crimeLevel)

		if not config then
			print_error("@xiajingbo SyncPoliceEscape:WantedConfig不存在CrimeLevel为" .. tostring(self._crimeLevel))

			return
		end

		local duration = config.EscapeTime
		self._escapeTimer = duration
		self._escapeDuration = duration
		duration = config.EscapePlayerRefreshCD
		self._policeNoticeTimer = duration
		self._policeNoticeDuration = duration

		self.RegistgerTick(self)
	else
		self._escapeTimer = nil

		self.UnRegistgerTick(self)
	end

	gMessageManager:SendMessage(gEventConstants.MINIMAP_CRIME_STATUS_UPDATE, {
		isEscaping = isEscaping
	})
end

M.SyncPoliceEscapeSuccess = function(self)
	self:Clear()
	gMessageManager:SendMessage(gEventConstants.MINIMAP_CRIME_STATUS_UPDATE, {
		["\\xf0\\-\\xd5/\\xa3B\\xa2S\\xa3\\xa5"] = true
	})
end

M.CrimeTick = function(self)
	if self._escapeTimer and self._escapeTimer > 0 then
		self._escapeTimer = self._escapeTimer - gLogicTime.deltaTime
		local remainTime = Mathf.Clamp(self._escapeTimer, 0, self._escapeDuration)
		local progress = remainTime / self._escapeDuration

		gMessageManager:SendMessage(gEventConstants.MINIMAP_CRIME_STATUS_UPDATE, {
			progress = progress
		})
	end

	if self._policeNoticeTimer then
		self._policeNoticeTimer = self._policeNoticeTimer - gLogicTime.deltaTime

		if self._policeNoticeTimer < 0 then
			self._policeNoticeTimer = self._policeNoticeDuration

			gMessageManager:SendMessage(gEventConstants.MINIMAP_CRIME_STATUS_UPDATE, {
				["\\x8f8!&}\\x8fg\\xd6\"\\xa4\\xbd"] = true
			})
		end
	end
end

M.RegistgerTick = function(self)
	if self._tick then
		return
	end

	UpdateBeat:AddListener(self._tickHandle)

	self._tick = true
end

M.UnRegistgerTick = function(self)
	if not self._tick then
		return
	end

	UpdateBeat:RemoveListener(self._tickHandle)

	self._tick = false
end

M.InCrimeState = function(self)
	return self._crimeLevel and self._crimeLevel >= 0
end

M.GetCrimeState = function(self)
	local state = {
		crimeLevel = self._crimeLevel,
		isEscaping = self._isEscaping
	}

	if self._escapeDuration and self._escapeTimer then
		local remainTime = Mathf.Clamp(self._escapeTimer, 0, self._escapeDuration)
		local progress = remainTime / self._escapeDuration
		state.progress = progress
	else
		state.progress = 0
	end

	return state
end

return M
