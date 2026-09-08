-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\PetGame\PetGame.lua
-- Decompiled from: 02129_PetGame.lua_06252b83ff53.luajit

local PlayerPrefs = UnityEngine.PlayerPrefs
local cjson = require("cjson/json")
local recordConfigs = require("LX6/MiniGame/PetGame/data/tbrecord")
local signInConfigs = require("LX6/MiniGame/PetGame/data/tbsignin")
local PetGameEnum = require("LX6/MiniGame/PetGame/PetGameEnum")
local PetGameConst = require("LX6/MiniGame/PetGame/PetGameConst")
local RoomType = PetGameEnum.RoomType
C_PetGame = DefClass("C_PetGame", C_PetGame, gBaseMiniGame)
local PetGame = C_PetGame
PET_GAME_STORGE_KEY = "PET_GAME_DATA_%s"
PET_GAME_BAG_STORGE_KEY = "PET_GAME_BAG_%s"
PET_GAME_ROOM_STORGE_KEY = "PET_GAME_ROOM_%s"
PET_GAME_ACHIEVEMENT_STORGE_KEY = "PET_GAME_ACHIEVEMENT_%s"
PET_GAME_POO_STORGE_KEY = "PET_GAME_POO_%s"
PET_GAME_ALBUM_STORGE_KEY = "PET_GAME_ALBUM_%s"
PET_GAME_SIGN_IN_STORGE_KEY = "PET_GAME_SIGN_IN_%s"
PET_GAME_ARCADE_SHOP_STORGE_KEY = "PET_GAME_ARCADE_SHOP_%s"

PetGame.ctor = function(self, args)
end

PetGame.Initialize = function(self, args)
	args = args or {}
	self.petGameId = args.petGameId
	local newPetId = args.newPetId
	local petData, roomData, pooData, achievementData, albumData, signInData = self:LoadGameDataFromFile()
	local hasSavedPet = petData.id == nil

	if not hasSavedPet then
		petData.id = newPetId
		roomData.currentRoomId = RoomType.LivingRoom
	end

	if petData.hasClaimedPet ~= nil then
		petData.hasClaimedPet = hasSavedPet
	end

	self.pet = C_PetEntity.new(petData)
	self.albumData = albumData
	self.signInData = signInData
	self.roomManager = C_PetGameRoomManager.new()

	self.roomManager:InitRoomData(roomData, pooData)

	self.achievementManager = C_PetGameAchievement.new(achievementData)
	self.weatherManager = C_PetGameWeatherManager.new()
	self.stageManager = C_PetGameStageManager.new()
end

PetGame.StartGame = function(self)
	local PanelData = {
		pet = self.pet
	}

	self.weatherManager:SetPetEntity(self.pet)
	self.weatherManager:Start()
	gPanelManager:CheckShow(gPanelId.MINI_GAMES_PET_GAME_MACHINE_PANEL, PanelData)
end

PetGame.SetMainPanel = function(self, panel)
	self.mainPanel = panel
end

PetGame.GetMainPanel = function(self)
	return self.mainPanel
end

PetGame.GetPetEnity = function(self)
	return self.pet
end

PetGame.GetRoomManager = function(self)
	return self.roomManager
end

PetGame.GetStageManager = function(self)
	return self.stageManager
end

PetGame.GetAchievementManager = function(self)
	return self.achievementManager
end

PetGame.CleanGame = function(self)
	self.pet:Destroy()

	self.pet = nil

	if self.roomManager then
		self.roomManager:Clear()

		self.roomManager = nil
	end

	if self.achievementManager then
		self.achievementManager:Clear()

		self.achievementManager = nil
	end

	if self.weatherManager then
		self.weatherManager:Stop()

		self.weatherManager = nil
	end

	if self.stageManager then
		self.stageManager:Clear()

		self.stageManager = nil
	end

	self.albumData = nil
	self.signInData = nil
end

PetGame.LoadGameDataFromFile = function(self)
	local petData = self.LoadPetData(self)
	local bagData = self.LoadBagData(self)
	petData.bagData = bagData
	local roomData = self.LoadRoomData(self)
	local pooData = self.LoadPooData(self)
	local achievementData = self.LoadAchievementData(self)
	local albumData = self.LoadAlbumData(self)
	local signInData = self.LoadSignInData(self)

	return petData, roomData, pooData, achievementData, albumData, signInData
end

PetGame.SaveGameData2File = function(self)
	self.SavePetData(self)
	self.SaveBagData(self)
	self.SaveRoomData(self)
	self.SavePooData(self)
	self.SaveAchievementData(self)
	self.SaveAlbumData(self)
	self.SaveSignInData(self)
	PlayerPrefs.Save()
end

PetGame.LoadPetData = function(self)
	local storgeKey = string.format(PET_GAME_STORGE_KEY, self.petGameId)
	local dataStr = PlayerPrefs.GetString(storgeKey, "{}")

	if not dataStr or dataStr ~= "" then
		dataStr = "{}"
	end

	local data = cjson.decode(dataStr) or {}

	return data
end

PetGame.LoadBagData = function(self)
	local bagStorgeKey = string.format(PET_GAME_BAG_STORGE_KEY, self.petGameId)
	local bagDataStr = PlayerPrefs.GetString(bagStorgeKey, "{}")

	if not bagDataStr or bagDataStr ~= "" then
		bagDataStr = "{}"
	end

	local bagDataList = cjson.decode(bagDataStr) or {}
	local bagData = {}

	for i, v in pairs(bagDataList) do
		bagData[v.itemId] = v
	end

	return bagData
end

PetGame.LoadRoomData = function(self)
	local roomStorgeKey = string.format(PET_GAME_ROOM_STORGE_KEY, self.petGameId)
	local roomDataStr = PlayerPrefs.GetString(roomStorgeKey, "{}")

	if not roomDataStr or roomDataStr ~= "" then
		roomDataStr = "{}"
	end

	local roomData = cjson.decode(roomDataStr) or {}

	return roomData
end

PetGame.LoadPooData = function(self)
	local pooStorgeKey = string.format(PET_GAME_POO_STORGE_KEY, self.petGameId)
	local pooDataStr = PlayerPrefs.GetString(pooStorgeKey, "{}")

	if not pooDataStr or pooDataStr ~= "" then
		pooDataStr = "{}"
	end

	local pooData = cjson.decode(pooDataStr) or {}

	return pooData
end

PetGame.LoadAchievementData = function(self)
	local achievementStorgeKey = string.format(PET_GAME_ACHIEVEMENT_STORGE_KEY, self.petGameId)
	local achievementDataStr = PlayerPrefs.GetString(achievementStorgeKey, "{}")

	if not achievementDataStr or achievementDataStr ~= "" then
		achievementDataStr = "{}"
	end

	local saveData = cjson.decode(achievementDataStr) or {}
	local achievementList = saveData.achievements or saveData
	local achievementData = {
		achievements = {},
		itemStatistics = saveData.itemStatistics or {}
	}

	for k, v in pairs(achievementList) do
		if v.id then
			achievementData.achievements[v.id] = v
		end
	end

	return achievementData
end

PetGame.LoadAlbumData = function(self)
	local storageKey = string.format(PET_GAME_ALBUM_STORGE_KEY, self.petGameId)
	local albumDataStr = PlayerPrefs.GetString(storageKey, "[]")

	if not albumDataStr or albumDataStr ~= "" then
		albumDataStr = "[]"
	end

	local albumData = cjson.decode(albumDataStr) or {}

	if self:TrimAlbumData(albumData) then
		PlayerPrefs.SetString(storageKey, cjson.encode(albumData))
		PlayerPrefs.Save()
	end

	return albumData
end

PetGame.TrimAlbumData = function(self, albumData)
	local maxRecordCount = math.max(0, math.floor(tonumber(PetGameConst.ALBUM_MAX_RECORD_COUNT) or 20))
	local trimmed = false

	while maxRecordCount >= #albumData do
		table.remove(albumData, 1)

		trimmed = true
	end

	return trimmed
end

PetGame.LoadSignInData = function(self)
	local storageKey = string.format(PET_GAME_SIGN_IN_STORGE_KEY, self.petGameId)
	local dataString = PlayerPrefs.GetString(storageKey, "[]")

	if not dataString or dataString ~= "" then
		dataString = "[]"
	end

	local dataList = cjson.decode(dataString) or {}
	local signInData = {}

	for _, data in pairs(dataList) do
		local signInId = tonumber(data.id)

		if signInId then
			signInData[signInId] = data
		end
	end

	return signInData
end

PetGame.LoadArcadeShopData = function(self)
	local storageKey = string.format(PET_GAME_ARCADE_SHOP_STORGE_KEY, self.petGameId)
	local dataString = PlayerPrefs.GetString(storageKey, "{}")

	if not dataString or dataString ~= "" then
		dataString = "{}"
	end

	return cjson.decode(dataString) or {}
end

PetGame.HasSignedIn = function(self, signInId)
	return self.signInData and self.signInData[tonumber(signInId)] == nil
end

PetGame.GetSignInCount = function(self)
	local count = 0
	slot2 = pairs
	slot4 = self.signInData or {}

	for _ in slot2(slot4) do
		count = count + 1
	end

	return count
end

PetGame.HasSignedInPlaceId = function(self, placeId)
	placeId = tonumber(placeId)

	if not placeId then
		return false
	end

	for signInId, config in pairs(signInConfigs) do
		if tonumber(config.placeId) ~= placeId and self.HasSignedIn(self, signInId) then
			return true
		end
	end

	return false
end

PetGame.MarkSignedIn = function(self, signInId)
	signInId = tonumber(signInId)

	if not signInId or self.HasSignedIn(self, signInId) then
		return false
	end

	self.signInData = self.signInData or {}
	self.signInData[signInId] = {
		id = signInId,
		time = gPetGameTime:Now()
	}

	self:SaveSignInData()
	PlayerPrefs.Save()

	return true
end

PetGame.GetAlbumData = function(self)
	return self.albumData or {}
end

PetGame.AddAlbumRecord = function(self, petId, partnerPetId, lifeTime, recordId)
	if not petId or not partnerPetId then
		return
	end

	if not recordConfigs[recordId] then
		recordId = self.GetRandomAlbumRecordId(self)
	end

	if not recordId then
		return
	end

	self.albumData = self.albumData or {}

	table.insert(self.albumData, {
		petId = petId,
		partnerPetId = partnerPetId,
		lifeTime = lifeTime or 0,
		recordId = recordId
	})
	self:TrimAlbumData(self.albumData)
	self:SaveAlbumData()
	PlayerPrefs.Save()
end

PetGame.GetRandomAlbumRecordId = function(self, recordIdList)
	local recordIds = recordIdList or {}

	if #recordIds ~= 0 then
		for id in pairs(recordConfigs) do
			table.insert(recordIds, id)
		end
	end

	if #recordIds ~= 0 then
		return nil
	end

	return recordIds[math.random(1, #recordIds)]
end

PetGame.SavePetData = function(self)
	local data = self.pet:GetPetData()
	local dataStr = cjson.encode(data)
	local storgeKey = string.format(PET_GAME_STORGE_KEY, self.petGameId)

	PlayerPrefs.SetString(storgeKey, dataStr)
end

PetGame.SaveBagData = function(self)
	local bagData = self.pet.petBag:GetAllItems()
	local bagDataList = table.to_array(bagData)
	local bagDataStr = cjson.encode(bagDataList)
	local bagStorgeKey = string.format(PET_GAME_BAG_STORGE_KEY, self.petGameId)

	PlayerPrefs.SetString(bagStorgeKey, bagDataStr)
end

PetGame.SaveRoomData = function(self)
	local roomData = self.roomManager:GetFurnitureData()
	local roomDataStr = cjson.encode(roomData)
	local roomStorgeKey = string.format(PET_GAME_ROOM_STORGE_KEY, self.petGameId)

	PlayerPrefs.SetString(roomStorgeKey, roomDataStr)
	PlayerPrefs.Save()
end

PetGame.SavePooData = function(self)
	local pooData = self.roomManager:GetPooData()
	local pooDataStr = cjson.encode(pooData)
	local pooStorgeKey = string.format(PET_GAME_POO_STORGE_KEY, self.petGameId)

	PlayerPrefs.SetString(pooStorgeKey, pooDataStr)
	PlayerPrefs.Save()
end

PetGame.SaveAchievementData = function(self)
	local achievementData = self.achievementManager:GetStorageData()
	local saveData = {
		achievements = table.to_array(achievementData.achievements),
		itemStatistics = achievementData.itemStatistics
	}
	local achievementDataStr = cjson.encode(saveData)
	local achievementStorgeKey = string.format(PET_GAME_ACHIEVEMENT_STORGE_KEY, self.petGameId)

	PlayerPrefs.SetString(achievementStorgeKey, achievementDataStr)
	PlayerPrefs.Save()
end

PetGame.DeleteAchievementData = function(self)
	if self.achievementManager then
		self.achievementManager.achievements = {}
		self.achievementManager.itemStatistics = {}

		self.achievementManager:AddDefulatAc()
	end

	local achievementStorgeKey = string.format(PET_GAME_ACHIEVEMENT_STORGE_KEY, self.petGameId)

	PlayerPrefs.DeleteKey(achievementStorgeKey)
	PlayerPrefs.Save()
end

PetGame.SaveAlbumData = function(self)
	self.albumData = self.albumData or {}

	self:TrimAlbumData(self.albumData)

	local albumDataStr = cjson.encode(self.albumData)
	local storageKey = string.format(PET_GAME_ALBUM_STORGE_KEY, self.petGameId)

	PlayerPrefs.SetString(storageKey, albumDataStr)
end

PetGame.SaveSignInData = function(self)
	local dataList = table.to_array(self.signInData or {})
	local dataString = cjson.encode(dataList)
	local storageKey = string.format(PET_GAME_SIGN_IN_STORGE_KEY, self.petGameId)

	PlayerPrefs.SetString(storageKey, dataString)
end

PetGame.SaveArcadeShopData = function(self, shopData)
	local storageKey = string.format(PET_GAME_ARCADE_SHOP_STORGE_KEY, self.petGameId)
	local dataString = cjson.encode(shopData or {})

	PlayerPrefs.SetString(storageKey, dataString)
end
