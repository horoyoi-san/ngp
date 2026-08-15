C_PlayerManager = DefClass("C_PlayerManager", C_PlayerManager, C_BaseDataManager)
local M = C_PlayerManager

function M:OnInit()
	self:Init()
end

function M:DefineData()
	self.main = C_PlayerMainData.new(self)
	self.achieve = C_PlayerAchieveData.new(self)
	self.guideEvents = C_PlayerGuideEventsData.new(self)
	self.cacheInfo = C_PlayerCacheInfoData.new(self)
	self.infoBase = C_PlayerInfoBaseData.new(self)
	self.infoLogin = C_PlayerInfoLoginData.new(self)
	self.infoItem = C_PlayerInfoItemData.new(self)
	self.infoSpirit = C_PlayerInfoSpiritData.new(self)
	self.infoAchievement = C_PlayerInfoAchievementData.new(self)
	self.infoMinor = C_PlayerInfoMinorData.new(self)
	self.infoMinorNpcCultivation = C_PlayerInfoMinorNpcCultivationData.new(self)
	self.infoMinorNpcProfile = C_PlayerInfoMinorNpcProfileData.new(self)
	self.infoMinorSpiritStandingDrawing = C_PlayerInfoMinorSpiritStandingDrawingData.new(self)
	self.infoMinorWorldBeliefs = C_PlayerInfoMinorWorldBeliefsData.new(self)
	self.infoMinorAtmosphereGameplay = C_PlayerInfoMinorAtmosphereGameplayData.new(self)
	self.infoOther = C_PlayerInfoOtherData.new(self)
	self.infoLast = C_PlayerInfoLastData.new(self)
end

function M:InitPlayerInfo(playerInfo)
	for i = 1, #self.__DataList do
		local data = self.__DataList[i]

		if data.InitPlayerInfo then
			data:InitPlayerInfo(playerInfo)
		end
	end
end

function M:OnBeforeSwitchScene(switchType)
	if switchType ~= gSwitchSceneType.KickToLogin then
		return
	end

	for i = 1, #self.__DataList do
		local data = self.__DataList[i]

		if data.OnLogOut then
			data:OnLogOut()
		end
	end
end

function M:GuideEvent(eventName)
	self.guideEvents.bindData:SendBindEvent(eventName)
end

function M:GetLoginRolePid()
	return self.main.bindData.loginRolePid
end

function M:CheckHasBuyTheHouse(houseId)
	local houseInfo = self.infoMinor.bindData.housesInfo
	local houseInfoList = houseInfo and houseInfo.HouseInfoList

	if table.isNilOrEmpty(houseInfoList) then
		return false
	end

	for _, data in ipairs(houseInfoList) do
		if data.HouseId == houseId then
			return true
		end
	end

	return false
end

function M:GetPlayerInfoOtherData(key)
	return self.infoOther.bindData[key]
end

function M:SetPlayerInfoOtherData(key, value)
	self.infoOther.bindData[key] = value
end

function M:GetPlayerMainData(key)
	return self.main.bindData[key]
end

function M:SetPlayerMainData(key, value)
	self.main.bindData[key] = value
end

gPlayerManager = gPlayerManager or C_PlayerManager.new()
