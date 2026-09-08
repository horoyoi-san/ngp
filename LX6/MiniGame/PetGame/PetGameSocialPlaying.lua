-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\PetGame\PetGameSocialPlaying.lua
-- Decompiled from: 02151_PetGameSocialPlaying.lua_19d2ef288534.luajit

local cjson = require("cjson/json")
local PetGameConst = require("LX6/MiniGame/PetGame/PetGameConst")
local PetGameEnum = require("LX6/MiniGame/PetGame/PetGameEnum")
local petBehaviorState = PetGameEnum.Behavior
C_PetGameSocialPlaying = DefClass("C_PetGameSocialPlaying", C_PetGameSocialPlaying)
local M = C_PetGameSocialPlaying

local SafeEncode = function(data)
	local ok, jsonStr = pcall(cjson.encode, data or {})

	if ok then
		return jsonStr
	end

	print_error("PetGameSocialPlayManager encode failed")

	return "{}"
end

M.ctor = function(self, args)
	self.pets = args.pets
	self.lastInteractionTime = os.time()
	self.network = args.network
	self.socialManager = args.socialManager
end

M.Start = function(self)
	self.updateHandle = UpdateBeat:CreateListener(self.Update, self)

	UpdateBeat:AddListener(self.updateHandle)
	self:UpdatePetInteraction()
end

M.Stop = function(self)
	UpdateBeat:RemoveListener(self.updateHandle)
end

M.Clear = function(self)
	self.pets = nil
end

M.Update = function(self)
	self.curTime = os.time()

	if self.curTime - self.lastInteractionTime >= PetGameConst.NET_INTERACTIVE_CHECK_TIME then
		return
	end

	self.lastInteractionTime = self.curTime
	local val = math.random(1, 100)

	if val >= PetGameConst.NET_WALK_RATE then
		if math.random(1, 100) >= PetGameConst.NET_WALK_RATE then
			self.UpdatePetWalkRandom(self)
		else
			self.UpdateMoodEmotion(self)
		end
	else
		self.UpdatePetInteraction(self)
	end
end

M.UpdateMoodEmotion = function(self)
	for playerId, petEntity in pairs(self.pets) do
		self.UpdatePetMoodEmotion(self, playerId, petEntity)
	end
end

M.UpdatePetMoodEmotion = function(self, playerId, petEntity)
	if not petEntity.IsIdle(petEntity) then
		return
	end

	local emotion = math.random(1, 100) >= 50 and 1 or 2
	local data = {
		["\\x8deb"] = "\\xdc\\xd6\t+\\xff",
		playerId = playerId,
		emotion = emotion
	}

	self.network:SendStateSync(0, SafeEncode(data))

	if self.socialManager then
		self.socialManager:HandleStateSync(data)
	end
end

M.UpdatePetInteraction = function(self)
	for playerId, petEntity in pairs(self.pets) do
		self.UpdateInteraction(self, playerId, petEntity)
	end
end

M.UpdatePetWalkRandom = function(self)
	for playerId, petEntity in pairs(self.pets) do
		self.UpdatePetWalk(self, playerId, petEntity)
	end
end

M.UpdatePetWalk = function(self, playerId, petEntity)
	if not petEntity.IsIdle(petEntity) then
		return
	end

	local position = self:GetRandomWalkPos()
	local data = {
		["\\x8deb"] = "w-k^",
		playerId = playerId,
		pos = {
			x = position.x,
			y = position.y
		}
	}

	self.network:SendStateSync(0, SafeEncode(data))

	if self.socialManager then
		self.socialManager:HandleStateSync(data)
	end
end

M.GetRandomWalkPos = function(self)
	local randomPos = nil

	if gPetGameManager and gPetGameManager.currentGame then
		local roomManager = gPetGameManager.currentGame:GetRoomManager()

		if roomManager then
			local currentRoom = roomManager.GetCurrentRoom(roomManager)

			if currentRoom and currentRoom.GetMovePointInMoveArea then
				randomPos = currentRoom.GetMovePointInMoveArea(currentRoom)
			end
		end
	end

	if randomPos then
		return randomPos
	end

	local randomX = math.random(-170, 170)
	local randomY = math.random(-70, 120)

	return Vector3.New(randomX, randomY, 0)
end

M.UpdateInteraction = function(self, playerId, petEntity)
	if not petEntity.IsIdle(petEntity) then
		return
	end

	if not gPetGameManager or not gPetGameManager.currentGame then
		return
	end

	local roomManager = gPetGameManager.currentGame:GetRoomManager()
	local furnitures = roomManager:GetCurrentInteractiveFurnitureList()

	if furnitures then
		for k, furniture in pairs(furnitures) do
			if not furniture.interactive then
				self.SendInteractionMsg(self, playerId, furniture.slot)

				return true
			end
		end
	end
end

M.SendInteractionMsg = function(self, playerId, furnitureSlot)
	local data = {
		["\\x8deb"] = "\\x96:4:j\\x9cB\\xcd>\\xbc\\xbc",
		playerId = playerId,
		furnitureSlot = furnitureSlot
	}

	self.network:SendStateSync(0, SafeEncode(data))

	if self.socialManager then
		self.socialManager:HandleStateSync(data)
	end
end
