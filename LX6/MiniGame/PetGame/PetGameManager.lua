-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\PetGame\PetGameManager.lua
-- Decompiled from: 02131_PetGameManager.lua_7f9378b5e4b0.luajit

local PlayerPrefs = UnityEngine.PlayerPrefs
C_PetGameManager = DefClass("C_PetGameManager", C_PetGameManager, gBaseMiniGameManager)
local PetGameManager = C_PetGameManager
local LAST_PET_GAME_STORGE_KEY = "LAST_PET_GAME_ID"
local PET_GAME_STORGE_KEY = "PET_GAME_DATA_%s"
local PET_GAME_BAG_STORGE_KEY = "PET_GAME_BAG_%s"
local PET_GAME_ROOM_STORGE_KEY = "PET_GAME_ROOM_%s"
local PET_GAME_ACHIEVEMENT_STORGE_KEY = "PET_GAME_ACHIEVEMENT_%s"
local PET_GAME_POO_STORGE_KEY = "PET_GAME_POO_%s"
local PET_GAME_ALBUM_STORGE_KEY = "PET_GAME_ALBUM_%s"
local PET_GAME_SIGN_IN_STORGE_KEY = "PET_GAME_SIGN_IN_%s"
local PET_GAME_ARCADE_SHOP_STORGE_KEY = "PET_GAME_ARCADE_SHOP_%s"

PetGameManager.GetLastPetGameId = function(self)
	return PlayerPrefs.GetInt(LAST_PET_GAME_STORGE_KEY, 0)
end

PetGameManager.SaveLastPetGameId = function(self, petGameId)
	PlayerPrefs.SetInt(LAST_PET_GAME_STORGE_KEY, petGameId)
	PlayerPrefs.Save()
end

PetGameManager.GetNextPetGameId = function(self)
	local petGameId = self:GetLastPetGameId() + 1

	self:SaveLastPetGameId(petGameId)

	return petGameId
end

PetGameManager.GetGameId = function(self)
	return self.petGameId
end

PetGameManager.StartNew = function(self, newPetId)
	local prevId = self.petGameId or self:GetLastPetGameId()

	self:_CleanupCurrentGame(true)

	if prevId and prevId <= 0 then
		self:_DeleteGameData(prevId)
	end

	local newId = self:GetNextPetGameId()

	self:_DeleteGameData(newId)
	self:CreateGame({
		petGameId = newId,
		newPetId = newPetId
	})
end

PetGameManager.StartContinue = function(self)
	local petGameId = self:GetLastPetGameId()

	if petGameId ~= 0 then
		self:StartNew()

		return
	end

	self:CreateGame({
		petGameId = petGameId
	})
end

PetGameManager.CreateGame = function(self, args)
	if type(args) == "table" then
		args = {
			petGameId = args
		}
	end

	self:_CleanupCurrentGame()

	self.petGameId = args.petGameId

	gPetGameTime:LoadForGame(self.petGameId)
	self:RegisterEvent()

	self.currentGame = C_PetGame.new(args)

	if gPetGameSocialPlayManager and gPetGameSocialPlayManager:IsSupported() then
		gPetGameSocialPlayManager:Initialize(self.currentGame)
		gPetGameSocialPlayManager:StartListenPlayInvite()
	end

	self.currentGame:StartGame()
end

PetGameManager._CleanupCurrentGame = function(self, skipSave)
	if not self.currentGame then
		return
	end

	if gPetGameSocialPlayManager then
		gPetGameSocialPlayManager:Clear()
	end

	if not skipSave then
		self.currentGame:SaveGameData2File()
		gPetGameTime:SaveForGame()
	end

	self.currentGame:DestroyGame()

	self.currentGame = nil
end

PetGameManager._DeleteGameData = function(self, petGameId)
	if not petGameId or petGameId < 0 then
		return
	end

	PlayerPrefs.DeleteKey(string.format(PET_GAME_STORGE_KEY, petGameId))
	PlayerPrefs.DeleteKey(string.format(PET_GAME_BAG_STORGE_KEY, petGameId))
	PlayerPrefs.DeleteKey(string.format(PET_GAME_ROOM_STORGE_KEY, petGameId))
	PlayerPrefs.DeleteKey(string.format(PET_GAME_ACHIEVEMENT_STORGE_KEY, petGameId))
	PlayerPrefs.DeleteKey(string.format(PET_GAME_POO_STORGE_KEY, petGameId))
	PlayerPrefs.DeleteKey(string.format(PET_GAME_ALBUM_STORGE_KEY, petGameId))
	PlayerPrefs.DeleteKey(string.format(PET_GAME_SIGN_IN_STORGE_KEY, petGameId))
	PlayerPrefs.DeleteKey(string.format(PET_GAME_ARCADE_SHOP_STORGE_KEY, petGameId))
	gPetGameTime:DeleteForGame(petGameId)
	gPetGameOutSideDataManager:DeleteForGame(petGameId)
	PlayerPrefs.Save()
end

PetGameManager.WipeAllSaves = function(self, maxId)
	local oldId = gPetGameManager:GetLastPetGameId()

	if oldId <= 0 then
		gPetGameManager:_DeleteGameData(oldId)
	end

	UnityEngine.PlayerPrefs.SetInt("LAST_PET_GAME_ID", 0)
	UnityEngine.PlayerPrefs.Save()
end

PetGameManager.DestroyGame = function(self)
	self:UnRegisterEvent()
	self:_CleanupCurrentGame()
	gPanelManager:Close(gPanelId.MINI_GAMES_PET_GAME_MACHINE_PANEL)
	gPanelManager:Close(gPanelId.MINI_GAMES_PET_GAME_BEGINE_PANEL)
end

PetGameManager.SaveGameData2File = function(self)
	if not self.currentGame then
		return
	end

	self.currentGame:SaveGameData2File()
end

PetGameManager.RegisterEvent = function(self)
	if self.isInit then
		return
	end

	self.isInit = true
	self.eventHandle = {
		[gEventConstants.MINIGAME_PET_GAME_RESTART] = function (eventId, newPetId)
			self:StartNew(newPetId)
		end
	}

	gMessageManager:RegisterEventHandlers(self.eventHandle)
end

PetGameManager.UnRegisterEvent = function(self)
	self.isInit = false

	if not self.eventHandle then
		return
	end

	gMessageManager:UnregisterEventHandlers(self.eventHandle)

	self.eventHandle = nil
end

OnApplicationQuit = function()
	if gPetGameManager then
		gPetGameManager:OnApplicationQuit()
	end
end

PetGameManager.OnApplicationQuit = function(self)
	if self.isQuit then
		return
	end

	self.isQuit = true

	self:DestroyGame()
end

gPetGameManager = gPetGameManager or C_PetGameManager.new()
