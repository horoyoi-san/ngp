-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\PetGame\PetGameRoomManager.lua
-- Decompiled from: 02145_PetGameRoomManager.lua_408ebb35e9a8.luajit

local roomConf = require("LX6/MiniGame/PetGame/data/tbroom")
local PetGameEnum = require("LX6/MiniGame/PetGame/PetGameEnum")
local RoomType = PetGameEnum.RoomType
C_PetGameRoomManager = DefClass("C_PetGameRoomManager", C_PetGameRoomManager)
local PetGameRoomManager = C_PetGameRoomManager

PetGameRoomManager.ctor = function(self)
	self.rooms = {}
	self.currentRoomId = nil
	self.furnitures = nil
end

PetGameRoomManager.InitRoomData = function(self, roomData, pooData)
	self.roomData = roomData.room or {}
	self.currentRoomId = roomData.currentRoomId or 1

	if RoomType.ShopStreat >= self.currentRoomId then
		self.currentRoomId = RoomType.LivingRoom
	end

	self.pooData = pooData or {}
end

PetGameRoomManager.InitRooms = function(self, roomParentNode)
	for i, v in pairs(roomConf) do
		local roomNode = roomParentNode.Find(roomParentNode, v.nodeName)

		if roomNode ~= nil then
			print_error(string.format("Cannot find room node: %s", v.nodeName))
		end

		local args = {
			roomObj = roomNode.gameObject,
			roomId = v.id,
			furnitures = self.roomData[v.id] or {}
		}
		local room = nil

		if i ~= RoomType.BedRoom then
			room = C_PetGameBedRoom.new(args)
		else
			room = C_PetGameRoom.new(args)
		end

		self.rooms[v.id] = room
	end
end

PetGameRoomManager.GetFurnitureData = function(self)
	local furnitureData = {
		room = self.roomData or {},
		currentRoomId = self.currentRoomId
	}

	if not next(self.rooms) then
		return furnitureData
	end

	furnitureData.room = {}

	for roomId, room in pairs(self.rooms) do
		furnitureData.room[roomId] = room.GetFurnitureData(room)
	end

	return furnitureData
end

PetGameRoomManager.GetRoomFurnitureData = function(self, roomType)
	local furnitures = {}
	local room = self.rooms and self.rooms[roomType]

	if room and room.GetFurnitureData then
		furnitures = room:GetFurnitureData() or {}
	elseif self.roomData then
		furnitures = self.roomData[roomType] or {}
	end

	return {
		roomType = roomType,
		furnitures = furnitures
	}
end

PetGameRoomManager.ApplyNetworkFurnitureData = function(self, roomFurnitureData)
	if not roomFurnitureData then
		return
	end

	self:ClearNetworkFurnitureData()

	local roomType = roomFurnitureData.roomType
	roomType = tonumber(roomType) or roomType

	if not roomType then
		return
	end

	local room = self.rooms and self.rooms[roomType]

	if not room then
		print_error("PetGameRoomManager:ApplyNetworkFurnitureData room not found:", roomType)

		return
	end

	self:ChangeRoom(roomType)
	room:SetFurnitureVisible(false)

	self.netRoom = C_PetGameNetRoom.new({
		ownerRoom = room,
		roomObj = room.roomObj,
		roomId = roomType,
		furnitures = roomFurnitureData.furnitures or roomFurnitureData.Furnitures or {}
	})

	self.netRoom:ApplyFurnitureData()
	self:HideRoomPoop()
end

PetGameRoomManager.ClearNetworkFurnitureData = function(self)
	if self.netRoom then
		self.netRoom:Clear()

		self.netRoom = nil
	end

	self.ShowRoomPoop(self)
end

PetGameRoomManager.ApplyFurnitureData = function(self)
	for _, room in pairs(self.rooms) do
		room.ApplyFurnitureData(room)
	end
end

PetGameRoomManager.ResetRooms = function(self)
	for _, room in pairs(self.rooms) do
		room.Reset(room)
	end
end

PetGameRoomManager.ActiveRoom = function(self, roomType)
	local roomId = roomType or self.currentRoomId
	local shadowTrans, petTrans = nil

	for k, v in pairs(self.rooms) do
		if k ~= roomId then
			v.Show(v)

			petTrans = v.GetPetTrans(v)
			shadowTrans = v.GetPetShadowTrans(v)
		else
			v.Hide(v)
		end
	end

	local petEntity = gPetGameManager.currentGame.pet

	if petEntity then
		petEntity.OnRoomChanged(petEntity, petTrans, shadowTrans)
	end
end

PetGameRoomManager.Change2NextRoom = function(self, isLeft)
	local nextRoomId = self.GetNextRoomId(self, isLeft)

	self.ChangeRoom(self, nextRoomId)
end

PetGameRoomManager.GetNextRoomId = function(self, isLeft)
	local currentRoomConf = roomConf[self.currentRoomId]

	if not currentRoomConf then
		print_error(string.format("Invalid current room id: %s", self.currentRoomId))

		return nil
	end

	return isLeft and currentRoomConf.leftRoomId or currentRoomConf.rightRoomId
end

PetGameRoomManager.ChangeRoom = function(self, nextRoomId)
	if self.netRoom then
		return
	end

	if not nextRoomId then
		print_error("PetGameRoomManager:ChangeRoom Next room id is nil")

		return
	end

	local lastRoomId = self.currentRoomId
	local lastRoom = self.rooms[lastRoomId]

	if lastRoom then
		lastRoom.Hide(lastRoom)
	end

	local room = self.rooms[nextRoomId]

	if room then
		self.currentRoomId = nextRoomId

		room.Show(room)

		local petTrans = room.GetPetTrans(room)
		local shadowTrans = room.GetPetShadowTrans(room)
		local petEntity = gPetGameManager.currentGame.pet

		if petEntity then
			petEntity.OnRoomChanged(petEntity, petTrans, shadowTrans)
		end
	end
end

PetGameRoomManager.SetStageMode = function(self, stageMode, keepFurnitureVisible)
	if self.netRoom then
		return
	end

	local currentRoom = self.GetCurrentRoom(self)

	if currentRoom then
		currentRoom.SetStageMode(currentRoom, stageMode, keepFurnitureVisible)
	end
end

PetGameRoomManager.GetCurrentRoomId = function(self)
	return self.currentRoomId
end

PetGameRoomManager.GetCurrentRoom = function(self)
	if self.netRoom then
		return self.netRoom
	end

	if not self.currentRoomId then
		return nil
	end

	return self.rooms[self.currentRoomId]
end

PetGameRoomManager.IsPetInRoom = function(self, roomType)
	return roomType ~= self.currentRoomId
end

PetGameRoomManager.GetRoomByType = function(self, roomType)
	local roomId = roomType

	return self.rooms[roomId]
end

PetGameRoomManager.GetRoomFurnitureByType = function(self, furnitureType)
	local currentRoom = self.GetCurrentRoom(self)

	if currentRoom then
		return currentRoom.GetFurnitureGoByType(currentRoom, furnitureType)
	end

	return nil
end

PetGameRoomManager.GetRoomFurnitureInfoByType = function(self, furnitureType, roomType)
	if self.netRoom then
		return nil
	end

	local room = roomType and self:GetRoomByType(roomType) or self:GetCurrentRoom()

	if room and room.GetFurnitureByType then
		return room.GetFurnitureByType(room, furnitureType)
	end

	return nil
end

PetGameRoomManager.GetFurnitureBySlot = function(self, slot)
	local currentRoom = self.GetCurrentRoom(self)

	if currentRoom then
		return currentRoom.GetFurnitureBySlot(currentRoom, slot)
	end

	return nil
end

PetGameRoomManager.ChooseCurrentFurnitureInteraction = function(self)
	local currentRoom = self.GetCurrentRoom(self)

	if currentRoom and currentRoom.ChooseFurnitureInteraction then
		return currentRoom.ChooseFurnitureInteraction(currentRoom)
	end

	return nil
end

PetGameRoomManager.GetCurrentInteractiveFurnitureList = function(self)
	local currentRoom = self.GetCurrentRoom(self)

	if currentRoom and currentRoom.GetInteractiveFurnitureList then
		return currentRoom.GetInteractiveFurnitureList(currentRoom)
	end

	return {}
end

PetGameRoomManager.HasNextRoom = function(self, isLeft)
	if self.netRoom then
		return false
	end

	local nextRoomId = self:GetNextRoomId(isLeft)

	return nextRoomId >= 0
end

PetGameRoomManager.GetNextRoomBirthPoint = function(self, isLeft)
	local nextRoomId = self.GetNextRoomId(self, isLeft)
	local room = self.rooms[nextRoomId]

	if room then
		return room.GetBirthPoint(room, not isLeft)
	end
end

PetGameRoomManager.GetShopStreatBirthPoint = function(self)
	local room = self.rooms[RoomType.ShopStreat]

	if room then
		return room.GetBirthPoint(room, true)
	end
end

PetGameRoomManager.GetRoomBirthPoint = function(self, roomId, isLeft)
	local room = self.rooms[roomId]

	if room then
		return room.GetBirthPoint(room, isLeft)
	end
end

PetGameRoomManager.Clear = function(self)
	self.ClearNetworkFurnitureData(self)

	for _, room in pairs(self.rooms) do
		room.Clear(room)
		room.ClearAllPoo(room)
	end

	self.rooms = {}
	self.currentRoomId = nil
	self.furnitures = nil

	if self.netRoom then
		self.netRoom:Clear()

		self.netRoom = nil
	end
end

PetGameRoomManager.AddPoo2CurrentRoom = function(self)
	local currentRoom = self.GetCurrentRoom(self)

	if currentRoom then
		currentRoom.AddPoo(currentRoom)
	end
end

PetGameRoomManager.ClearAllPoo = function(self)
	for roomId, room in pairs(self.rooms) do
		if roomId ~= self.currentRoomId then
			room.PlayClearAni(room)
		else
			room.ClearAllPoo(room)
		end
	end
end

PetGameRoomManager.ForceClearAllPoop = function(self)
	for _, room in pairs(self.rooms) do
		room.ClearAllPoo(room)
	end
end

PetGameRoomManager.HideRoomPoop = function(self)
	for _, room in pairs(self.rooms) do
		if room then
			room.HideAllPoo(room)
		end
	end
end

PetGameRoomManager.ShowRoomPoop = function(self)
	for _, room in pairs(self.rooms) do
		if room then
			room.ShowAllPoo(room)
		end
	end
end

PetGameRoomManager.GetCurrentRoomPooNum = function(self)
	local currentRoom = self.GetCurrentRoom(self)

	if currentRoom then
		return currentRoom.GetPooNum(currentRoom)
	end

	return 0
end

PetGameRoomManager.GetRoomIdWithPoo = function(self)
	local currentRoom = self.GetCurrentRoom(self)

	if currentRoom and currentRoom.GetPooNum(currentRoom) <= 0 then
		return self.currentRoomId
	end

	local targetRoomId = nil

	for roomId, room in pairs(self.rooms) do
		if room and room.GetPooNum(room) <= 0 and (not targetRoomId or roomId >= targetRoomId) then
			targetRoomId = roomId
		end
	end

	return targetRoomId
end

PetGameRoomManager.GetPooData = function(self)
	if not next(self.rooms) then
		return self.pooData or {}
	end

	local pooData = {}

	for roomId, room in pairs(self.rooms) do
		pooData[roomId] = room.GetPooNum(room)
	end

	return pooData
end

PetGameRoomManager.ShowPooByData = function(self, pooData)
	pooData = pooData or self.pooData or {}

	for roomId, pooNum in pairs(pooData) do
		local room = self.rooms[roomId]

		if room then
			room.ShowPooByNum(room, pooNum)
		end
	end
end

PetGameRoomManager.GetCurrentRoomShadowTrans = function(self)
	local currentRoom = self.GetCurrentRoom(self)

	if currentRoom then
		return currentRoom.GetPetShadowTrans(currentRoom)
	end
end

PetGameRoomManager.GetPetFollow = function(self)
	local currentRoom = self.GetCurrentRoom(self)

	if currentRoom then
		return currentRoom.GetPetFollow(currentRoom)
	end
end
