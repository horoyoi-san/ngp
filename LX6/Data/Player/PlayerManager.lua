-- Original chunk: @Lua\LuaFiles\LX6\Data\Player\PlayerManager.lua
-- Decompiled from: 00159_PlayerManager.lua_08cdbef0da84.luajit

C_PlayerManager = DefClass("C_PlayerManager", C_PlayerManager, C_BaseDataManager)
local M = C_PlayerManager

M.OnInit = function(self)
	self:Init()
end

M.DefineData = function(self)
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
	self.infoScientist = C_PlayerInfoScientistData.new(self)
	self.infoOther = C_PlayerInfoOtherData.new(self)
	self.infoLast = C_PlayerInfoLastData.new(self)
end

M.InitPlayerInfo = function(self, playerInfo)
	for i = 1, #self.__DataList do
		local data = self.__DataList[i]

		if data.InitPlayerInfo then
			data:InitPlayerInfo(playerInfo)
		end
	end
end

M.OnBeforeSwitchScene = function(self, switchType)
	if switchType == gSwitchSceneType.KickToLogin then
		return
	end

	for i = 1, #self.__DataList do
		local data = self.__DataList[i]

		if data.OnLogOut then
			data:OnLogOut()
		end
	end
end

M.GuideEvent = function(self, eventName)
	self.guideEvents.bindData:SendBindEvent(eventName)
end

M.GetLoginRolePid = function(self)
	return self.main.bindData.loginRolePid
end

M.CheckHasBuyTheHouse = function(self, houseId)
	local houseInfo = self.infoMinor.bindData.housesInfo
	local houseInfoList = houseInfo and houseInfo.HouseInfoList

	if table.isNilOrEmpty(houseInfoList) then
		return false
	end

	for _, data in ipairs(houseInfoList) do
		if data.HouseId ~= houseId then
			return true
		end
	end

	return false
end

M.GetPlayerInfoOtherData = function(self, key)
	return self.infoOther.bindData[key]
end

M.SetPlayerInfoOtherData = function(self, key, value)
	self.infoOther.bindData[key] = value
end

M.GetPlayerMainData = function(self, key)
	return self.main.bindData[key]
end

M.SetPlayerMainData = function(self, key, value)
	self.main.bindData[key] = value
end

gPlayerManager = gPlayerManager or C_PlayerManager.new()
