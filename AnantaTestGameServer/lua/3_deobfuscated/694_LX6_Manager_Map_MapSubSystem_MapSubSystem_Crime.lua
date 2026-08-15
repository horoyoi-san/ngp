MapSubSystem_Crime = DefClass("MapSubSystem_Crime", MapSubSystem_Crime, MapSubSystemBase)
local M = MapSubSystem_Crime
local WantedConfig = LTConfig.WantedConfig

function M:OnInit()
	self._tick = false
	self._crimeLevel = 0
	self._escapeDuration = 0
	self._escapeTimer = 0
	self._policeNoticeDuration = 0
	self._policeNoticeTimer = 0
	self._tickHandle = UpdateBeat:CreateListener(self.CrimeTick, self)
end

function M:OnBeforeSwitchScene(switchType)
	self:Clear()
end

function M:Clear()
	self._crimeLevel = 0
	self._isEscaping = false
	self._escapeTimer = 0
	self._escapeDuration = 0
	self._policeNoticeTimer = 0
	self._policeNoticeDuration = 0

	self:UnRegistgerTick()
	gMapManager:RemoveMiniMapScaleType(gMapScaleType.Crime)
	gMessageManager:SendMessage(gEventConstants.MINIMAP_CRIME_STATUS_UPDATE, {
		clear = true
	})
end

function M:SyncPlayerCrimeLevel(level)
	self._crimeLevel = level

	if level == 0 then
		self:Clear()
	else
		gMapManager:SetMiniMapScale(LTConfig.GameConfig.WantedMapScale, gMapScaleType.Crime)
		gMessageManager:SendMessage(gEventConstants.MINIMAP_CRIME_STATUS_UPDATE, {
			crimeLevel = level
		})
	end
end

function M:SyncPoliceEscape(isEscaping)
	self._isEscaping = isEscaping

	if isEscaping then
		if not self._crimeLevel or self._crimeLevel == 0 then
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

		self:RegistgerTick()
	else
		self._escapeTimer = nil

		self:UnRegistgerTick()
	end

	gMessageManager:SendMessage(gEventConstants.MINIMAP_CRIME_STATUS_UPDATE, {
		isEscaping = isEscaping
	})
end

function M:SyncPoliceEscapeSuccess()
	self:Clear()
	gMessageManager:SendMessage(gEventConstants.MINIMAP_CRIME_STATUS_UPDATE, {
		escapeSuccess = true
	})
end

function M:CrimeTick()
	if self._escapeTimer and self._escapeTimer >= 0 then
		self._escapeTimer = self._escapeTimer - gLogicTime.deltaTime
		local remainTime = Mathf.Clamp(self._escapeTimer, 0, self._escapeDuration)
		local progress = remainTime / self._escapeDuration

		gMessageManager:SendMessage(gEventConstants.MINIMAP_CRIME_STATUS_UPDATE, {
			progress = progress
		})
	end

	if self._policeNoticeTimer then
		self._policeNoticeTimer = self._policeNoticeTimer - gLogicTime.deltaTime

		if self._policeNoticeTimer <= 0 then
			self._policeNoticeTimer = self._policeNoticeDuration

			gMessageManager:SendMessage(gEventConstants.MINIMAP_CRIME_STATUS_UPDATE, {
				playerFound = true
			})
		end
	end
end

function M:RegistgerTick()
	if self._tick then
		return
	end

	UpdateBeat:AddListener(self._tickHandle)

	self._tick = true
end

function M:UnRegistgerTick()
	if not self._tick then
		return
	end

	UpdateBeat:RemoveListener(self._tickHandle)

	self._tick = false
end

function M:InCrimeState()
	return self._crimeLevel and self._crimeLevel > 0
end

function M:GetCrimeState()
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
