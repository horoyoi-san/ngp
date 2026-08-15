local M = C_MiniMapPanelStore
local MAP_CRIME_MODE = 0
local MAP_NORMAL_MODE = 1
local MAP_ESCAPE_SUCCESS_MODE = 2
local ARREST_CRIME_STAR_MODE = 0
local ARREST_ESCAPE_MODE = 1
local ARREST_BE_DETECTED_MODE = 2

function M:InitCrime()
	self.bindData.starList.luaSimpleRenderItem = self:CreateAction("OnRenderCrimeStarItem")

	self:ClearCrime()
end

function M:OnCrimeStatusUpdate(eventId, params)
	if params.clear ~= nil then
		self:ClearCrime()
	elseif params.progress ~= nil then
		self:OnCrimeProgressUpdate(params.progress)
	elseif params.crimeLevel ~= nil then
		self:OnCrimeLevelUpdate(params.crimeLevel)
	elseif params.isEscaping ~= nil then
		self:OnEscapeStateUpdate(params.isEscaping)
	elseif params.escapeSuccess then
		self:ShowEscapeSuccessNotice()
	elseif params.playerFound then
		self:ShowPlayerFoundNotice()
	end
end

function M:ResumeCrimeState()
	local state = gMapSubSystem_Crime:GetCrimeState()
	self._crimeLevel = state.crimeLevel
	self._isEscaping = state.isEscaping

	self:OnCrimeLevelUpdate(self._crimeLevel)
	self:OnEscapeStateUpdate(self._isEscaping)
	self:OnCrimeProgressUpdate(state.progress or 0)
end

function M:ClearCrime()
	self._crimeLevel = 0
	self._isEscaping = false
	self.bindData.isArrested = MAP_NORMAL_MODE
	self.bindData.arrestMode = ARREST_CRIME_STAR_MODE
	self.bindData.escapeProgress = 0
end

function M:OnCrimeProgressUpdate(progress)
	self.bindData.escapeProgress = progress
end

function M:OnCrimeLevelUpdate(level)
	self._crimeLevel = level
	self.bindData.isArrested = level > 0 and MAP_CRIME_MODE or MAP_NORMAL_MODE
	self.bindData.arrestMode = self:GetCorrectArrestMode()

	self.bindData.starList:SetSimpleList(5)
end

function M:OnEscapeStateUpdate(isEscaping)
	self._isEscaping = isEscaping
	self.bindData.arrestMode = self:GetCorrectArrestMode()
end

function M:OnRenderCrimeStarItem(btn, index)
	local store = gStoreManager:GetStoreGroup("MiniMapArrestStar"):GetStoreByWidget(btn)
	store.redStar = index < self._crimeLevel and 1 or 0
end

function M:ShowEscapeSuccessNotice()
	self.bindData.isArrested = MAP_ESCAPE_SUCCESS_MODE

	coroutine.start(function ()
		coroutine.wait(2)

		if self ~= nil and self.bindData ~= nil then
			self.bindData.isArrested = MAP_NORMAL_MODE
		end
	end)
end

function M:ShowPlayerFoundNotice()
	self.bindData.arrestMode = ARREST_BE_DETECTED_MODE

	coroutine.start(function ()
		coroutine.wait(2)

		if self ~= nil and self.bindData ~= nil then
			self.bindData.arrestMode = self:GetCorrectArrestMode()
		end
	end)
end

function M:GetCorrectArrestMode()
	if self._crimeLevel == 0 then
		return MAP_NORMAL_MODE
	elseif self._isEscaping then
		return ARREST_ESCAPE_MODE
	else
		return ARREST_CRIME_STAR_MODE
	end
end
