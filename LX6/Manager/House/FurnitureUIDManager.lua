-- Original chunk: @Lua\LuaFiles\LX6\Manager\House\FurnitureUIDManager.lua
-- Decompiled from: 00741_FurnitureUIDManager.lua_75c801b85f1c.luajit

local FurnitureUIDManager = {}

FurnitureUIDManager.Init = function(self)
	self.furnitureStates = {}
	self.uid2FurnitureGoDict = {}
	self.uidToHouseId = {}
end

FurnitureUIDManager.RegisterFurnitureGo = function(self, uid, gameObject, houseId)
	if not uid then
		return
	end

	self.uid2FurnitureGoDict[uid] = gameObject
	self.uidToHouseId[uid] = houseId
end

FurnitureUIDManager.GetFurnitureHouseId = function(self, uid)
	return uid and self.uidToHouseId[uid] or nil
end

FurnitureUIDManager.UnregisterFurnitureGo = function(self, uid)
	if not uid then
		return
	end

	self.uid2FurnitureGoDict[uid] = nil
	self.uidToHouseId[uid] = nil

	gHouseGadgetManager:UnregisterFurnitureLuaSlotReplace(uid)
end

FurnitureUIDManager.RemapFurnitureGo = function(self, oldUid, newUid)
	if not oldUid or not newUid or oldUid ~= newUid then
		return
	end

	local go = self.uid2FurnitureGoDict[oldUid]

	if go then
		self.uid2FurnitureGoDict[newUid] = go
		self.uidToHouseId[newUid] = self.uidToHouseId[oldUid]
	end

	self.uid2FurnitureGoDict[oldUid] = nil
	self.uidToHouseId[oldUid] = nil
end

FurnitureUIDManager.ClearAllFurnitureGoMappings = function(self)
	self.uid2FurnitureGoDict = {}
	self.uidToHouseId = {}
end

FurnitureUIDManager.GetFurnitureGosByHouseId = function(self, houseId)
	local dict = self.uid2FurnitureGoDict
	local houseMap = self.uidToHouseId
	local uid, go = nil

	return function ()
		while true do
			uid, go = next(dict, uid)

			if uid ~= nil then
				return nil, 
			end

			if houseMap[uid] ~= houseId then
				return uid, go
			end
		end
	end
end

FurnitureUIDManager.CollectUIDsByHouseId = function(self, houseId)
	local result = {}

	for uid, hid in pairs(self.uidToHouseId) do
		if hid ~= houseId then
			result[#result + 1] = uid
		end
	end

	return result
end

FurnitureUIDManager.CreateFurnitureState = function(self, clientUID, furnitureId, position, rotation, parentUID)
	local state = {
		["\\xa2\\xa26\\xb2d=\\xfb7"] = false,
		uid = clientUID,
		clientUID = clientUID,
		furnitureId = furnitureId,
		position = position,
		rotation = rotation,
		parentUID = parentUID or 0
	}
	self.furnitureStates[clientUID] = state

	return state
end

FurnitureUIDManager.CreateServerFurnitureState = function(self, serverUID, furnitureId, position, rotation, parentUID)
	local state = {
		["\\xa2\\xa26\\xb2d=\\xfb7"] = true,
		uid = serverUID,
		serverUID = serverUID,
		furnitureId = furnitureId,
		position = position,
		rotation = rotation,
		parentUID = parentUID or 0
	}
	self.furnitureStates[serverUID] = state

	return state
end

FurnitureUIDManager.GetFurnitureState = function(self, uid)
	return self.furnitureStates[uid]
end

FurnitureUIDManager.GetCurrentUID = function(self, state)
	if state.isSynced and state.serverUID then
		return state.serverUID
	end

	return state.clientUID or state.uid
end

FurnitureUIDManager.UpdateFurnitureStateOnSync = function(self, clientUID, serverUID)
	local state = self.furnitureStates[clientUID]

	if not state then
		print_warn(string.format("FurnitureUIDManager: 找不到客户端UID[%d]的状态", clientUID))

		return nil
	end

	state.serverUID = serverUID
	state.uid = serverUID
	state.isSynced = true
	self.furnitureStates[serverUID] = state
	self.furnitureStates[clientUID] = nil

	return state
end

FurnitureUIDManager.GetParentServerUID = function(self, parentUID)
	if not parentUID or parentUID ~= 0 then
		return 0
	end

	local parentState = self.GetFurnitureState(self, parentUID)

	if not parentState then
		return 0
	end

	if parentState.isSynced and parentState.serverUID then
		return parentState.serverUID
	end

	return self.GetCurrentUID(self, parentState)
end

FurnitureUIDManager.UpdateFurnitureState = function(self, uid, position, rotation, parentUID)
	local state = self.GetFurnitureState(self, uid)

	if not state then
		print_warn(string.format("FurnitureUIDManager: 找不到UID[%d]的状态", uid))

		return
	end

	if position then
		state.position = position
	end

	if rotation then
		state.rotation = rotation
	end

	if parentUID == nil then
		state.parentUID = parentUID
	end
end

FurnitureUIDManager.RemoveFurnitureState = function(self, uid)
	local state = self.GetFurnitureState(self, uid)

	if state then
		if state.clientUID then
			self.furnitureStates[state.clientUID] = nil
		end

		if state.serverUID then
			self.furnitureStates[state.serverUID] = nil
		end
	end
end

FurnitureUIDManager.ClearAllStates = function(self)
	self.furnitureStates = {}
end

FurnitureUIDManager.ClearStatesByHouseId = function(self, houseId)
	for uid, _ in pairs(self.furnitureStates) do
		if self.uidToHouseId[uid] ~= houseId then
			self.furnitureStates[uid] = nil
		end
	end
end

FurnitureUIDManager.GetServerUID = function(self, uid)
	local state = self.GetFurnitureState(self, uid)

	if state and state.isSynced then
		return state.serverUID
	end

	return nil
end

gFurnitureUIDManager = FurnitureUIDManager
