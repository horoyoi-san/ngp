-- Original chunk: @Lua\LuaFiles\LX6\Manager\House\HouseCollisionUtils.lua
-- Decompiled from: 00738_HouseCollisionUtils.lua_9db2383a8c24.luajit

local HouseCollisionUtils = {}
local CSFurnitureManager = LX6.GamePlay.House.FurnitureManager
local HouseFurnitureConfig = LTConfig.HouseFurnitureConfig
local CSFurnitureMono = LX6.UGC.HouseFurniture

HouseCollisionUtils.GetDefaultOverlapLayerMask = function(self)
	return bit.band(4294967295.0, bit.bnot(bit.bor(bit.lshift(1, 2), bit.bor(bit.lshift(1, 13), bit.bor(bit.lshift(1, 25), bit.lshift(1, 15))))))
end

HouseCollisionUtils.GetWallEditRaycastLayerMask = function(self)
	return gFurnitureUtils:GetMask({
		LX6.Constants.LayerConstants.Wall,
		LX6.Constants.LayerConstants.Default
	})
end

local IsNull = function(go)
	return not go or gCS.LuaUtils.IsNull(go)
end

local IsChildOf = function(go, parentGo)
	if IsNull(go) or IsNull(parentGo) then
		return false
	end

	return go.transform:IsChildOf(parentGo.transform)
end

HouseCollisionUtils.EnableBoundsBoxByConfig = function(self)
	for uid, go in pairs(gFurnitureUIDManager.uid2FurnitureGoDict) do
		if not IsNull(go) then
			local furnitureId = gFurnitureManager:TryGetFurnitureIdFromGo(go, uid)

			if furnitureId then
				local cfg = HouseFurnitureConfig.GetConfig(furnitureId)

				if cfg and cfg.IsBoundsSelect == false then
					CSFurnitureManager.EnableAllBoundsBox(go, true)
				end
			end
		end
	end

	self._EnableFenestrationBoundsBoxByConfig(self)
end

HouseCollisionUtils._EnableFenestrationBoundsBoxByConfig = function(self)
	local gridSystemProxy = gFurnitureManager:GetGridSystemProxy()

	if not gridSystemProxy or IsNull(gridSystemProxy) then
		return
	end

	local fenTrans = gridSystemProxy.fenestrationsTransform

	if not fenTrans or IsNull(fenTrans) then
		return
	end

	local hasAnyBoundsSelect = false
	local allBoundsSelect = true

	for _, meta in pairs(gHouseGadgetManager.fenestrationMetaDict) do
		local cfg = HouseFurnitureConfig.GetConfig(meta.furnitureId)

		if cfg and cfg.IsBoundsSelect == false then
			hasAnyBoundsSelect = true
		else
			allBoundsSelect = false
		end

		if hasAnyBoundsSelect and not allBoundsSelect then
			break
		end
	end

	if not hasAnyBoundsSelect then
		return
	end

	if allBoundsSelect then
		CSFurnitureManager.EnableAllBoundsBox(fenTrans.gameObject, true)

		return
	end

	for i = 0, fenTrans.childCount - 1 do
		local child = fenTrans.GetChild(fenTrans, i)

		if child and not IsNull(child) then
			local fenGo = child.gameObject
			local comp = fenGo.GetComponent(fenGo, typeof(CSFurnitureMono))

			if comp and comp.furnitureId then
				local cfg = HouseFurnitureConfig.GetConfig(comp.furnitureId)

				if cfg and cfg.IsBoundsSelect == false then
					CSFurnitureManager.EnableAllBoundsBox(fenGo, true)
				end
			end
		end
	end
end

HouseCollisionUtils.CheckBoxBlocked = function(self, center, halfExtents, rotation, options)
	local opts = options or {}
	local layerMask = opts.layerMask or self:GetDefaultOverlapLayerMask()
	local sortResult = opts.sortResult

	if sortResult ~= nil then
		sortResult = true
	end

	local queryTriggerInteraction = opts.queryTriggerInteraction or 1
	local enableBoundsRootGo = opts.enableBoundsRootGo
	local hitCount = 0

	if not IsNull(enableBoundsRootGo) then
		CSFurnitureManager.EnableAllBoundsBox(enableBoundsRootGo, true)
	end

	hitCount = CSFurnitureManager.BoxNonAlloc(center, halfExtents, nil, rotation, layerMask, sortResult, queryTriggerInteraction)

	if not IsNull(enableBoundsRootGo) then
		CSFurnitureManager.EnableAllBoundsBox(enableBoundsRootGo, false)
	end

	for i = 0, hitCount - 1 do
		local hitCollider = CSFurnitureManager.SortedColliderList[i]

		if hitCollider then
			local hitGo = hitCollider.gameObject

			if hitGo and not IsNull(hitGo) then
				local ignored = false
				local ignoreSet = opts.ignoreSet

				if ignoreSet and ignoreSet[hitGo] then
					ignored = true
				end

				if not ignored and opts.ignoreChildOf and IsChildOf(hitGo, opts.ignoreChildOf) then
					ignored = true
				end

				if not ignored and opts.shouldIgnoreHit and opts.shouldIgnoreHit(hitGo, hitCollider, i) then
					ignored = true
				end

				if not ignored then
					local blocked = true

					if opts.isBlockingHit then
						blocked = opts.isBlockingHit(hitGo, hitCollider, i) ~= true
					end

					if blocked then
						return true, hitGo, nil
					end
				end
			end
		end
	end

	return false, nil, 
end

gHouseCollisionUtils = HouseCollisionUtils
