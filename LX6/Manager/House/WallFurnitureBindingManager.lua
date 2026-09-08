-- Original chunk: @Lua\LuaFiles\LX6\Manager\House\WallFurnitureBindingManager.lua
-- Decompiled from: 00754_WallFurnitureBindingManager.lua_b34741c72e98.luajit

C_WallFurnitureBindingManager = DefClass("C_WallFurnitureBindingManager", C_WallFurnitureBindingManager)
local M = C_WallFurnitureBindingManager
local AdsorptionType = gFurnitureConst.AdsorptionType
local LayerToAdsorptionType = gFurnitureConst.LayerToAdsorptionType
local HouseFurnitureConfig = LTConfig.HouseFurnitureConfig
local WallLayer = LX6.Constants.LayerConstants.Wall or 16

M.ctor = function(self)
	self.wallFurnitureBindingHouseId = nil
	self.wallToFurniture = {}
	self.furnitureToWall = {}
end

M.IsActive = function(self)
	return self.wallFurnitureBindingHouseId == nil and self.wallFurnitureBindingHouseId == 0
end

M.ActivateForHouse = function(self, houseId)
	if not houseId or houseId ~= 0 then
		return
	end

	if self.wallFurnitureBindingHouseId ~= houseId then
		return
	end

	self.wallToFurniture = {}
	self.furnitureToWall = {}
	self.wallFurnitureBindingHouseId = houseId
end

M.Deactivate = function(self)
	self.wallToFurniture = {}
	self.furnitureToWall = {}
	self.wallFurnitureBindingHouseId = nil
end

M.GetEdgeKey = function(self, a, b)
	if not a or not b then
		return nil
	end

	return gWallEditUtils:BuildEdgeKey(a, b)
end

M.Bind = function(self, uid, edgeKey)
	if not self:IsActive() then
		return
	end

	if not uid or not edgeKey then
		return
	end

	self:Unbind(uid)

	self.furnitureToWall[uid] = edgeKey
	local set = self.wallToFurniture[edgeKey]

	if not set then
		set = {}
		self.wallToFurniture[edgeKey] = set
	end

	set[uid] = true
end

M.Unbind = function(self, uid)
	if not self:IsActive() then
		return
	end

	if not uid then
		return
	end

	local oldKey = self.furnitureToWall[uid]

	if not oldKey then
		return
	end

	self.furnitureToWall[uid] = nil
	local set = self.wallToFurniture[oldKey]

	if set then
		set[uid] = nil

		if not next(set) then
			self.wallToFurniture[oldKey] = nil
		end
	end
end

M.GetWallEdgeKey = function(self, uid)
	if not self:IsActive() then
		return nil
	end

	if not uid then
		return nil
	end

	return self.furnitureToWall[uid]
end

M.CollectFurnitureUIDsByEdgesPayload = function(self, edgesPayload)
	local uids = {}

	if not self:IsActive() then
		return uids
	end

	if not edgesPayload or edgesPayload ~= "" then
		return uids
	end

	local seen = {}

	for token in string.gmatch(edgesPayload, "[^|]+") do
		local a, b = string.match(token, "(-?%d+)_(-?%d+)")

		if a and b then
			local key = self:GetEdgeKey(tonumber(a), tonumber(b))
			local set = self.wallToFurniture[key]

			if set then
				for uid in pairs(set) do
					if not seen[uid] then
						seen[uid] = true
						uids[#uids + 1] = uid
					end
				end
			end
		end
	end

	return uids
end

M._ResolveEdgeKeyFromHitGo = function(self, hitGo)
	if not hitGo or gCS.LuaUtils.IsNull(hitGo) then
		return nil
	end

	local proxy = gWallEditManager and gWallEditManager.gridSystemProxy or nil

	if not proxy or gCS.LuaUtils.IsNull(proxy) then
		return nil
	end

	local edgeGo, edgeA, edgeB = gWallEditUtils:FindEdgeNameObject(hitGo, 5)

	if not edgeGo then
		return nil
	end

	if not edgeGo.transform:IsChildOf(proxy.transform) then
		return nil
	end

	return self:GetEdgeKey(edgeA, edgeB)
end

M.DetectEdgeKeyForFollowingFurniture = function(self)
	local hitLayer = gFurnitureManager and gFurnitureManager.nowHitLayer or 0

	if LayerToAdsorptionType[hitLayer] == AdsorptionType.Wall then
		return nil
	end

	return self:_ResolveEdgeKeyFromHitGo(gFurnitureManager and gFurnitureManager.nowHitGameObject)
end

M.DetectEdgeKeyForExistingFurniture = function(self, furnitureGo, furnitureId)
	if not furnitureGo or gCS.LuaUtils.IsNull(furnitureGo) then
		return nil
	end

	local cfg = HouseFurnitureConfig.GetConfig(furnitureId)

	if not cfg or not cfg.AdsorptionTypeFinal then
		return nil
	end

	local hasWallAdsorption = false

	for _, t in ipairs(cfg.AdsorptionTypeFinal) do
		if t ~= AdsorptionType.Wall then
			hasWallAdsorption = true

			break
		end
	end

	if not hasWallAdsorption then
		return nil
	end

	local position = furnitureGo.transform.position
	local rotation = furnitureGo.transform.rotation
	local hitLayer, _, hitGo = gFurnitureManager:SmartRaycastForPlacedFurniture(cfg, position, rotation)

	if hitLayer == WallLayer then
		return nil
	end

	return self:_ResolveEdgeKeyFromHitGo(hitGo)
end

M.RebuildFromScene = function(self)
	if not self:IsActive() then
		return
	end

	self.wallToFurniture = {}
	self.furnitureToWall = {}
	local houseId = self.wallFurnitureBindingHouseId

	for uid, furnitureGo in gFurnitureUIDManager:GetFurnitureGosByHouseId(houseId) do
		if furnitureGo and not gCS.LuaUtils.IsNull(furnitureGo) then
			local furnitureId = gFurnitureManager:TryGetFurnitureIdFromGo(furnitureGo, uid)

			if furnitureId and not gWallEditUtils:IsFenestrationFurnitureId(furnitureId) then
				local edgeKey = self:DetectEdgeKeyForExistingFurniture(furnitureGo, furnitureId)

				if edgeKey then
					self:Bind(uid, edgeKey)
				end
			end
		end
	end
end

M.StorageFurnitureByUID = function(self, uid)
	if not uid then
		return false
	end

	local furnitureGo = gFurnitureUIDManager.uid2FurnitureGoDict[uid]

	if not furnitureGo or gCS.LuaUtils.IsNull(furnitureGo) then
		return false
	end

	local furnitureId = gFurnitureManager:TryGetFurnitureIdFromGo(furnitureGo, uid)

	if not furnitureId then
		return false
	end

	local carrySurfaceUID = gFurnitureManager:GetAdsorptionSurfaceGoUid(uid)
	local wallEdgeKey = self:GetWallEdgeKey(uid)
	local carryUid2GoInfoDict, adsorbedUIDsList = gFurnitureManager:CollectAdsorbedFurnitureSnapshot(uid)

	if not gFurnitureOperationManager:BeginStorageOperation(furnitureId, furnitureGo, uid, carrySurfaceUID, wallEdgeKey) then
		return false
	end

	gFurnitureOperationManager.currentOperation.beforeState.carryUid2GoInfoDict = carryUid2GoInfoDict

	gHouseManager:RecordRemovedFurniture(uid)

	for _, adsUid in ipairs(adsorbedUIDsList) do
		gHouseManager:RecordRemovedFurniture(adsUid)
	end

	self:Unbind(uid)
	gFurnitureManager:DestroyCarryAndAdsorbedDirect(uid, adsorbedUIDsList)
	gFurnitureManager:RemoveAdsorptionRelation(uid)
	gFurnitureOperationManager:EndStorageOperation()

	return true
end

gWallFurnitureBindingManager = M.New()
