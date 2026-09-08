-- Original chunk: @Lua\LuaFiles\LX6\Manager\House\WallEditManager.lua
-- Decompiled from: 00748_WallEditManager.lua_c46845652f73.luajit

C_WallEditManager = DefClass("C_WallEditManager", C_WallEditManager)
local M = C_WallEditManager
local MessageConfig = LTConfig.MessageConfig
local Vector3 = UnityEngine.Vector3
local GameObject = UnityEngine.GameObject
local Quaternion = UnityEngine.Quaternion
local Color = UnityEngine.Color
local HouseConfig = LTConfig.HouseConfig
local HouseFurnitureConfig = LTConfig.HouseFurnitureConfig
local CSFurnitureManager = LX6.GamePlay.House.FurnitureManager
local CSFurnitureMono = LX6.UGC.HouseFurniture
local WallPreviewPlaceColor = Color.New(0, 1, 0, 0.3)
local WallPreviewBlockedColor = Color.New(1, 0, 0, 0.3)
local DoorFenestrationType = 0
local HouseExternalWallTag = "HouseExternalWall"

local IsExternalWallTag = function(tag, extraTag)
	return tag ~= HouseExternalWallTag or extraTag ~= HouseExternalWallTag
end

local FenestrationPreviewIntent = {
	["\\x8f\\xa3\\xacG1\\xe86"] = "GUmnq=",
	["pVǾ\\x8f8\\xb4\\xca\\xed"] = "\\x9c8)<s\\xa2Q\\xd56\\xa9\\xbc"
}

local GetGridMeshColor = function()
	local gridMeshColor = HouseConfig.GridMeshColor

	return Color.New(gridMeshColor[1], gridMeshColor[2], gridMeshColor[3], gridMeshColor[4])
end

local FenestrationPreviewYawOffset = 90
local EditMode = gWallEditUtils.WallEditMode
local WallPreviewType = {
	["IS\\x82R\\x86\\xc0f^SQb"] = 3,
	["e\\x81\\x94\\x8a\\x84"] = 1,
	["^\\|"] = 2,
	["T\rS~"] = 0
}

local _AttachToCurHouseNamespace = function(go)
	if not go or gCS.LuaUtils.IsNull(go) then
		return
	end

	local parent = gHouseSceneLayout:EnsureHouseNamespaceGo(gHouseManager:GetCurHouseId())

	if parent and not gCS.LuaUtils.IsNull(parent) then
		go.transform:SetParent(parent.transform, true)
	end
end

local _IsFenestrationOnExternalWall = function(gridSystem, edgeA, edgeB)
	if not gridSystem or gCS.LuaUtils.IsNull(gridSystem) or not edgeA or not edgeB then
		return false
	end

	local edgesTransform = gridSystem.edgesTransform

	if not edgesTransform or gCS.LuaUtils.IsNull(edgesTransform) then
		return false
	end

	local targetKey = gWallEditUtils:BuildEdgeKey(edgeA, edgeB)

	for i = 0, edgesTransform.childCount - 1 do
		local child = edgesTransform.GetChild(edgesTransform, i)

		if child and not gCS.LuaUtils.IsNull(child) then
			local edgeGo = child.gameObject
			local checkA, checkB = gWallEditUtils:ParseEdgeFromObjectName(edgeGo)

			if checkA and checkB and gWallEditUtils:BuildEdgeKey(checkA, checkB) ~= targetKey then
				local edgeTag, edgeExtraTag = gCS.LuaUtils.GetGameObjectTags(edgeGo, "")

				return IsExternalWallTag(edgeTag, edgeExtraTag)
			end
		end
	end

	return false
end

M.GetFenestrationHitInfo = function(self, hitGo)
	if not hitGo or gCS.LuaUtils.IsNull(hitGo) then
		return nil
	end

	local houseFurniture = hitGo.GetComponentInParent(hitGo, typeof(CSFurnitureMono))

	if not houseFurniture or not houseFurniture.furnitureId or not gWallEditUtils:IsFenestrationFurnitureId(houseFurniture.furnitureId) then
		return nil
	end

	local namedGo, edgeA, edgeB, runtimeID = gWallEditUtils:FindFenestrationNameObject(hitGo)

	if not namedGo or not edgeA or not edgeB or not runtimeID then
		return nil
	end

	local rootGo = houseFurniture.gameObject
	local tagIndex = gWallEditUtils:GetWallTagIndexFromObject(namedGo) or gWallEditUtils:GetWallTagIndexFromObject(rootGo)
	local namedTag, namedExtraTag = gCS.LuaUtils.GetGameObjectTags(namedGo, "")
	local rootTag, rootExtraTag = gCS.LuaUtils.GetGameObjectTags(rootGo, "")
	local isExternalWall = IsExternalWallTag(namedTag, namedExtraTag) or IsExternalWallTag(rootTag, rootExtraTag) or tagIndex ~= gWallEditUtils.WallTagIndex.HouseExternalWall or _IsFenestrationOnExternalWall(self.gridSystemProxy, edgeA, edgeB)
	local effectiveTag = namedTag and namedTag == "Untagged" and namedTag or namedExtraTag or namedTag

	return {
		nameGo = namedGo,
		rootGo = rootGo,
		uid = houseFurniture.uid,
		furnitureId = houseFurniture.furnitureId,
		edgeA = edgeA,
		edgeB = edgeB,
		runtimeID = runtimeID,
		tag = effectiveTag,
		tagIndex = tagIndex,
		isExternalWall = isExternalWall
	}
end

M.ctor = function(self)
	self.gridSystemProxy = nil
	self.isEditing = false
	self.loadedHouseID = 0
	self.loadedHouseIDs = {}
	self.mode = EditMode.BUILD
	self.dragStartPos = nil
	self.dragCurrentPos = nil
	self.brushTexID = 0
	self.fenestrationPrefabID = 0
	self.fenestrationType = 0
	self.wallPreviewMeshGo = nil
	self.wallPreviewMeshLoadOp = nil
	self.wallPreviewType = WallPreviewType.NONE
	self.wallPreviewHoverPos = nil
	self.wallPreviewDragStartPos = nil
	self.wallPreviewDragEndPos = nil
	self.wallPreviewFenestrationPos = nil
	self.wallPreviewFenestrationScale = nil
	self.wallPreviewFenestrationBoundsSize = nil
	self.wallPreviewFenestrationYaw = 0
	self.wallPreviewFenestrationHitPoint = nil
	self.wallPreviewFenestrationHitNormal = nil
	self.wallPreviewFenestrationRayDirection = nil
	self.wallPreviewFenestrationEdgeA = nil
	self.wallPreviewFenestrationEdgeB = nil
	self.wallPreviewFenestrationCanPlace = true
	self.wallPreviewFenestrationIgnoreEdgeA = nil
	self.wallPreviewFenestrationIgnoreEdgeB = nil
	self.wallPreviewFenestrationIgnoreRuntimeID = nil
	self.wallPreviewFenestrationIgnoreRootGo = nil
	self.fenestrationPreviewGo = nil
	self.fenestrationPreviewLoadOp = nil
	self.fenestrationPreviewLoadToken = 0
	self.fenestrationPreviewPrefabID = 0
	self.fenestrationPreviewType = 0
	self.fenestrationPreviewIntent = nil
	self.fenestrationPreviewBaseMeshGo = nil
	self.fenestrationPreviewBaseMeshLoadOp = nil
	self.fenestrationPreviewBaseMeshLoadToken = 0
	self.groundHintMeshGo = nil
	self.groundHintMeshLoadOp = nil
	self.selectedWallData = nil
	self.selectedWallMeshGo = nil
	self.selectedWallMeshLoadOp = nil
	self.stretchArrowStartGo = nil
	self.stretchArrowStartLoadOp = nil
	self.stretchArrowEndGo = nil
	self.stretchArrowEndLoadOp = nil
	self.stretchDragState = nil
	self.dragBeginScreenPos = nil
	self.dragBeginEdgeObj = nil
	self.clickDragThresholdSqr = 4
	self.lastDragPlacedNewWall = false
	self.gridMeshPrefabAsset = nil
end

M.ClearFenestrationPreviewBaseMesh = function(self)
	self.fenestrationPreviewBaseMeshLoadToken = self.fenestrationPreviewBaseMeshLoadToken + 1
	self.fenestrationPreviewBaseMeshLoadOp = nil

	if self.fenestrationPreviewBaseMeshGo and not gCS.LuaUtils.IsNull(self.fenestrationPreviewBaseMeshGo) then
		GameObject.Destroy(self.fenestrationPreviewBaseMeshGo)
	end

	self.fenestrationPreviewBaseMeshGo = nil
end

M.AdjustFenestrationPreviewBaseMesh = function(self)
	if not self.fenestrationPreviewBaseMeshGo or gCS.LuaUtils.IsNull(self.fenestrationPreviewBaseMeshGo) then
		return
	end

	local previewGo = self.fenestrationPreviewGo

	if not previewGo or gCS.LuaUtils.IsNull(previewGo) then
		return
	end

	local size = self.wallPreviewFenestrationBoundsSize or self.wallPreviewFenestrationScale

	if not size then
		return
	end

	local center = Vector3.New(0, 0, 0)
	local houseFurniture = previewGo.GetComponent(previewGo, typeof(CSFurnitureMono))

	if houseFurniture and houseFurniture.boundsBox then
		center = houseFurniture.boundsBox.center
	end

	local scaleX = math.max(size.x, 0.1)
	local scaleZ = math.max(size.z, 0.1)
	local bottomY = center.y - math.max(size.y, 0.1) * 0.5 + 0.01
	local trans = self.fenestrationPreviewBaseMeshGo.transform
	trans.localRotation = Quaternion.identity
	trans.localScale = Vector3.New(scaleX, 1, scaleZ)
	trans.localPosition = Vector3.New(scaleX * 0.5 + center.x, bottomY, scaleZ * 0.5 + center.z)
end

M.EnsureFenestrationPreviewBaseMesh = function(self)
	if self.fenestrationType == DoorFenestrationType then
		self.ClearFenestrationPreviewBaseMesh(self)

		return
	end

	local previewGo = self.fenestrationPreviewGo

	if not previewGo or gCS.LuaUtils.IsNull(previewGo) then
		return
	end

	if self.fenestrationPreviewBaseMeshGo and not gCS.LuaUtils.IsNull(self.fenestrationPreviewBaseMeshGo) then
		self.fenestrationPreviewBaseMeshGo:SetActive(true)
		self:AdjustFenestrationPreviewBaseMesh()
		self:SetFenestrationPreviewColor(self.wallPreviewFenestrationCanPlace ~= true)

		return
	end

	local baseMeshPath = HouseConfig.BaseMeshPath
	local token = self.fenestrationPreviewBaseMeshLoadToken + 1
	self.fenestrationPreviewBaseMeshLoadToken = token
	slot4 = gResourceManager
	self.fenestrationPreviewBaseMeshLoadOp = slot4:LoadAssetWithCallBack(baseMeshPath, typeof(GameObject), function (loadOp)
		if self.fenestrationPreviewBaseMeshLoadToken == token then
			return
		end

		if not loadOp or not loadOp.asset then
			self.fenestrationPreviewBaseMeshLoadOp = nil

			return
		end

		if not self.fenestrationPreviewGo or gCS.LuaUtils.IsNull(self.fenestrationPreviewGo) or self.fenestrationType == DoorFenestrationType then
			self.fenestrationPreviewBaseMeshLoadOp = nil

			return
		end

		local baseMeshGo = GameObject.Instantiate(loadOp.asset)
		baseMeshGo.name = "FenestrationPreviewBaseMesh"

		baseMeshGo.transform:SetParent(self.fenestrationPreviewGo.transform, false)
		CSFurnitureManager.SetCollidersEnabled(baseMeshGo, false)

		self.fenestrationPreviewBaseMeshGo = baseMeshGo

		self:AdjustFenestrationPreviewBaseMesh()
		self:SetFenestrationPreviewColor(self.wallPreviewFenestrationCanPlace ~= true)

		self.fenestrationPreviewBaseMeshLoadOp = nil
	end)
end

M.ClearFenestrationPreviewPrefab = function(self)
	self.fenestrationPreviewLoadToken = self.fenestrationPreviewLoadToken + 1
	self.fenestrationPreviewLoadOp = nil

	self.ClearFenestrationPreviewBaseMesh(self)

	if self.fenestrationPreviewGo and not gCS.LuaUtils.IsNull(self.fenestrationPreviewGo) then
		GameObject.Destroy(self.fenestrationPreviewGo)
	end

	self.fenestrationPreviewGo = nil
	self.fenestrationPreviewPrefabID = 0
end

M.SetFenestrationPreviewVisible = function(self, isVisible)
	if not self.fenestrationPreviewGo or gCS.LuaUtils.IsNull(self.fenestrationPreviewGo) then
		return
	end

	self.fenestrationPreviewGo:SetActive(isVisible ~= true)
end

M.SetFenestrationPreviewColor = function(self, canPlace)
	if not self.fenestrationPreviewGo or gCS.LuaUtils.IsNull(self.fenestrationPreviewGo) then
		return
	end

	local color = canPlace and Color.New(0.25, 1, 0.25, 0.85) or Color.New(1, 0.3, 0.3, 0.85)

	CSFurnitureManager.SetPreviewMaterialColor(self.fenestrationPreviewGo, color)
end

M.SyncFenestrationPreviewBoundsFromGo = function(self, previewGo)
	if not previewGo or gCS.LuaUtils.IsNull(previewGo) then
		return
	end

	local houseFurniture = previewGo.GetComponent(previewGo, typeof(CSFurnitureMono))

	if houseFurniture and houseFurniture.boundsBox then
		local bounds = houseFurniture.boundsBox
		self.wallPreviewFenestrationBoundsSize = bounds.size
		self.wallPreviewFenestrationScale = Vector3.New(math.max(bounds.size.x, 0.1), math.max(bounds.size.y, 0.1), math.max(bounds.size.z, 0.1))

		self.AdjustFenestrationPreviewBaseMesh(self)

		return
	end

	local renderers = previewGo.GetComponentsInChildren(previewGo, typeof(UnityEngine.Renderer), true)

	if not renderers or renderers.Length < 0 then
		return
	end

	local mergedBounds = renderers[0].bounds

	for i = 1, renderers.Length - 1 do
		mergedBounds.Encapsulate(mergedBounds, renderers[i].bounds)
	end

	local size = mergedBounds.size
	self.wallPreviewFenestrationBoundsSize = size
	self.wallPreviewFenestrationScale = Vector3.New(math.max(size.x, 0.1), math.max(size.y, 0.1), math.max(size.z, 0.1))

	self.AdjustFenestrationPreviewBaseMesh(self)
end

M.CreateFenestrationPreviewPrefab = function(self, prefabID, fenestrationType, worldPos, yaw)
	if not prefabID or prefabID < 0 then
		return false
	end

	self.fenestrationPreviewPrefabID = prefabID
	self.fenestrationPreviewType = fenestrationType or self.fenestrationType or 0

	self:SetFenestrationParams(prefabID, self.fenestrationPreviewType)

	local previewYaw = yaw

	if previewYaw ~= nil then
		previewYaw = self.wallPreviewFenestrationYaw or 0
	end

	if self.fenestrationPreviewGo and not gCS.LuaUtils.IsNull(self.fenestrationPreviewGo) then
		if worldPos then
			self.fenestrationPreviewGo.transform.position = worldPos
		end

		self.fenestrationPreviewGo.transform.rotation = Quaternion.Euler(0, previewYaw + FenestrationPreviewYawOffset, 0)

		self.SyncFenestrationPreviewBoundsFromGo(self, self.fenestrationPreviewGo)
		self.EnsureFenestrationPreviewBaseMesh(self)
		self.SetFenestrationPreviewVisible(self, true)
		self.RefreshFenestrationPreviewCanPlace(self)
		self.ApplyFenestrationPreviewPoseFromWallState(self, true)

		return true
	end

	local cfg = HouseFurnitureConfig.GetConfig(prefabID)

	if not cfg or not cfg.ModelName or cfg.ModelName ~= "" then
		return false
	end

	local token = self.fenestrationPreviewLoadToken + 1
	self.fenestrationPreviewLoadToken = token
	slot8 = gResourceManager
	self.fenestrationPreviewLoadOp = slot8:LoadAssetWithCallBack(cfg.ModelName, typeof(GameObject), function (loadOp)
		if self.fenestrationPreviewLoadToken == token then
			return
		end

		if not loadOp or not loadOp.asset then
			self.fenestrationPreviewLoadOp = nil

			return
		end

		local previewGo = GameObject.Instantiate(loadOp.asset)
		previewGo.name = string.format("FenestrationPreview_%d", prefabID)

		_AttachToCurHouseNamespace(previewGo)

		if worldPos then
			previewGo.transform.position = worldPos
		end

		previewGo.transform.rotation = Quaternion.Euler(0, previewYaw + FenestrationPreviewYawOffset, 0)

		CSFurnitureManager.SetCollidersEnabled(previewGo, false)

		self.fenestrationPreviewGo = previewGo

		self:SyncFenestrationPreviewBoundsFromGo(previewGo)
		self:EnsureFenestrationPreviewBaseMesh()
		self:SetFenestrationPreviewVisible(true)
		self:RefreshFenestrationPreviewCanPlace()
		self:ApplyFenestrationPreviewPoseFromWallState(true)

		self.fenestrationPreviewLoadOp = nil
	end)

	return true
end

M.ApplyFenestrationPreviewPoseFromWallState = function(self, isVisible)
	if not self.fenestrationPreviewGo or gCS.LuaUtils.IsNull(self.fenestrationPreviewGo) then
		return
	end

	if not isVisible then
		self.fenestrationPreviewGo:SetActive(false)

		return
	end

	self.fenestrationPreviewGo:SetActive(true)

	if self.wallPreviewFenestrationPos then
		self.fenestrationPreviewGo.transform.position = self.wallPreviewFenestrationPos
	end

	self.fenestrationPreviewGo.transform.rotation = Quaternion.Euler(0, (self.wallPreviewFenestrationYaw or 0) + FenestrationPreviewYawOffset, 0)

	self:SetFenestrationPreviewColor(self.wallPreviewFenestrationCanPlace ~= true)
end

M.SetWallPreviewMeshColor = function(self, canPlace)
	if not self.wallPreviewMeshGo or gCS.LuaUtils.IsNull(self.wallPreviewMeshGo) then
		return
	end

	local renderer = self.wallPreviewMeshGo:GetComponent(typeof(UnityEngine.Renderer))

	if not renderer or not renderer.material then
		return
	end

	local targetColor = canPlace and WallPreviewPlaceColor or WallPreviewBlockedColor
	local material = renderer.material

	if material:HasProperty("_OutlineColor") then
		material.SetColor(material, "_OutlineColor", targetColor)
	elseif material.HasProperty(material, "_BaseColor") then
		material.SetColor(material, "_BaseColor", targetColor)
	elseif material.HasProperty(material, "_MainColor") then
		material.SetColor(material, "_MainColor", targetColor)
	end
end

M.RefreshFenestrationPreviewCanPlace = function(self)
	local previewPos = self.wallPreviewFenestrationPos
	local boundsSize = self.wallPreviewFenestrationBoundsSize

	if not boundsSize and self.wallPreviewFenestrationScale then
		boundsSize = self.wallPreviewFenestrationScale
	end

	if not previewPos or not boundsSize then
		self.wallPreviewFenestrationCanPlace = true

		return true
	end

	local gridSystem = self.gridSystemProxy

	if gridSystem and not gCS.LuaUtils.IsNull(gridSystem) then
		local rayDir = self.wallPreviewFenestrationRayDirection or Vector3.zero
		local edgeA = self.wallPreviewFenestrationEdgeA or 0
		local edgeB = self.wallPreviewFenestrationEdgeB or 0
		local prefabID = self.fenestrationPreviewPrefabID == 0 and self.fenestrationPreviewPrefabID or self.fenestrationPrefabID
		local fenestrationType = self.fenestrationPreviewType or self.fenestrationType or 0

		if prefabID and prefabID <= 0 then
			local canPlaceOnGrid = gridSystem.CanPlaceFenestrationOnGrid(gridSystem, previewPos, rayDir, edgeA, edgeB, prefabID, fenestrationType)

			if not canPlaceOnGrid then
				self.wallPreviewFenestrationCanPlace = false

				return false
			end
		end
	end

	local halfExtents = Vector3.New(math.max(boundsSize.x * 0.5 * 0.95, 0.01), math.max(boundsSize.y * 0.5 * 0.95, 0.01), math.max(boundsSize.z * 0.5 * 0.95, 0.01))
	local rotation = Quaternion.Euler(0, self.wallPreviewFenestrationYaw or 0, 0)
	local furnitureRoot = gHouseSceneLayout:EnsureHouseNamespaceGo(gHouseManager:GetCurHouseId())
	local ignoreRootGo = self.wallPreviewFenestrationIgnoreRootGo
	local ignoreSet = {}

	if self.wallPreviewMeshGo and not gCS.LuaUtils.IsNull(self.wallPreviewMeshGo) then
		ignoreSet[self.wallPreviewMeshGo] = true
	end

	if self.fenestrationPreviewGo and not gCS.LuaUtils.IsNull(self.fenestrationPreviewGo) then
		ignoreSet[self.fenestrationPreviewGo] = true
	end

	local isBlocked, blockedGo = gHouseCollisionUtils:CheckBoxBlocked(previewPos, halfExtents, rotation, {
		layerMask = gHouseCollisionUtils:GetDefaultOverlapLayerMask(),
		enableBoundsRootGo = furnitureRoot,
		ignoreSet = ignoreSet,
		shouldIgnoreHit = function (hitGo)
			if hitGo.name and string.sub(hitGo.name, 1, 6) ~= "Floor_" then
				return true
			end

			if self.wallPreviewMeshGo and not gCS.LuaUtils.IsNull(self.wallPreviewMeshGo) and hitGo.transform:IsChildOf(self.wallPreviewMeshGo.transform) then
				return true
			end

			if self.fenestrationPreviewGo and not gCS.LuaUtils.IsNull(self.fenestrationPreviewGo) and hitGo.transform:IsChildOf(self.fenestrationPreviewGo.transform) then
				return true
			end

			if gWallEditUtils:IsEdgeObject(hitGo) then
				return true
			end

			if ignoreRootGo and not gCS.LuaUtils.IsNull(ignoreRootGo) and (hitGo ~= ignoreRootGo or hitGo.transform:IsChildOf(ignoreRootGo.transform)) then
				return true
			end

			return false
		end
	})

	if isBlocked then
		local blockedName = blockedGo and blockedGo.name or "nil"
		local blockedTag = blockedGo and gCS.LuaUtils.GetGameObjectTags(blockedGo, "") or "nil"
		local blockedExtraTag = nil
		local blockedParentName = "nil"

		if blockedGo and blockedName ~= "boundsBox" and blockedGo.transform then
			local parentTransform = blockedGo.transform.parent

			if parentTransform and not gCS.LuaUtils.IsNull(parentTransform) then
				blockedParentName = parentTransform.name
			end
		end

		print_debug(string.format("WallEditManager: 门窗碰撞到了 go=%s tag=%s parent=%s", tostring(blockedName), tostring(blockedTag), tostring(blockedParentName)))
	end

	local canPlace = not isBlocked
	self.wallPreviewFenestrationCanPlace = canPlace

	return canPlace
end

M.SetGridSystem = function(self, gridSystem)
	if self.gridSystemProxy ~= gridSystem then
		return
	end

	self.gridSystemProxy = gridSystem
	self.loadedHouseID = 0

	if self.gridSystemProxy and not gCS.LuaUtils.IsNull(self.gridSystemProxy) and gGameManager.Env.isEditor then
		self.gridSystemProxy:RefreshSettings()
	end

	self.ClearSelectedWallState(self)
	self.RefreshGroundHintMesh(self)
end

M.AttachToHouse = function(self, houseId)
	local ctx = gHouseManager:GetContext(houseId)

	if not ctx then
		return
	end

	local proxy = ctx.GetGridSystemProxy(ctx)

	if proxy then
		self.SetGridSystem(self, proxy)
	end
end

M.DetachFromHouse = function(self, houseId)
	if houseId and houseId <= 0 then
		self.loadedHouseIDs[houseId] = nil
	else
		self.loadedHouseIDs = {}
	end

	self.gridSystemProxy = nil
	self.loadedHouseID = 0

	self.ClearSelectedWallState(self)
end

M.ClearAllLoadedStates = function(self)
	self.gridSystemProxy = nil
	self.loadedHouseID = 0
	self.loadedHouseIDs = {}

	self.ClearSelectedWallState(self)
end

M.EnterEditMode = function(self, gridSystem)
	if not gridSystem then
		local houseId = gHouseManager:GetEditingHouseId()
		local ctx = houseId and houseId <= 0 and gHouseManager:GetContext(houseId) or nil
		gridSystem = ctx and ctx:GetGridSystemProxy() or nil
	end

	if gridSystem and self.gridSystemProxy == gridSystem then
		self.gridSystemProxy = gridSystem
		self.loadedHouseID = 0

		if not gCS.LuaUtils.IsNull(self.gridSystemProxy) then
			self.gridSystemProxy:RefreshSettings()
		end
	end

	self.isEditing = self.gridSystemProxy and not gCS.LuaUtils.IsNull(self.gridSystemProxy)

	self:ClearSelectedWallState()
	self:RefreshGroundHintMesh()

	return self.isEditing
end

M.LoadHouseByConfig = function(self, houseID)
	return self.LoadHouseByConfigWithProxy(self, houseID, self.gridSystemProxy)
end

M.LoadHouseByConfigWithProxy = function(self, houseID, proxy)
	if not proxy or gCS.LuaUtils.IsNull(proxy) then
		return false
	end

	local success = proxy.LoadHouseByConfig(proxy, houseID)

	if success then
		self.loadedHouseID = houseID
		self.loadedHouseIDs[houseID] = true
	end

	return success
end

M.EnsureWallLoaded = function(self, houseID, wallInfo, explicitProxy)
	print_debug(string.format("WallEditManager: EnsureWallLoaded, houseID=%s, wallInfo=%s", houseID, wallInfo and "Yes" or "No"))

	local proxy = explicitProxy or self.gridSystemProxy

	if not proxy or gCS.LuaUtils.IsNull(proxy) then
		return false
	end

	local edgesTransform = proxy.edgesTransform
	local hasEdgesRendered = edgesTransform and not gCS.LuaUtils.IsNull(edgesTransform) and edgesTransform.childCount >= 0
	local hasHouseRoot = hasEdgesRendered or proxy.floorsTransform and not gCS.LuaUtils.IsNull(proxy.floorsTransform)

	if self.loadedHouseIDs[houseID] and hasHouseRoot and hasEdgesRendered then
		return true
	end

	if wallInfo and self.HasWallInfoData(self, wallInfo) then
		return self.LoadHouseByServerWallInfoWithProxy(self, wallInfo, houseID, proxy)
	end

	return self.LoadHouseByConfigWithProxy(self, houseID, proxy)
end

M.HasWallInfoData = function(self, wallInfo)
	if not wallInfo then
		return false
	end

	if wallInfo.Nodes then
		for _ in pairs(wallInfo.Nodes) do
			return true
		end
	end

	return false
end

M.LoadHouseByServerWallInfo = function(self, wallInfo, configHouseID)
	return self.LoadHouseByServerWallInfoWithProxy(self, wallInfo, configHouseID, self.gridSystemProxy)
end

M.LoadHouseByServerWallInfoWithProxy = function(self, wallInfo, configHouseID, proxy)
	if not proxy or gCS.LuaUtils.IsNull(proxy) then
		return false
	end

	if wallInfo.Nodes then
		local xs = {}
		local ys = {}
		local fls = {}
		local nids = {}
		local idx = 0

		for nodeId, nodeData in pairs(wallInfo.Nodes) do
			idx = idx + 1
			nids[idx] = nodeId
			xs[idx] = nodeData.X
			ys[idx] = nodeData.Y
			fls[idx] = nodeData.Z
		end

		if idx <= 0 then
			proxy.SetServerNodes(proxy, xs, ys, fls, nids)
		end
	end

	if wallInfo.Edges then
		local nodeAs = {}
		local nodeBs = {}
		local tags = {}
		local texEdgeAs = {}
		local texEdgeBs = {}
		local texLs = {}
		local texRs = {}
		local idx = 0
		local texIdx = 0

		for edgeulong, edgeData in pairs(wallInfo.Edges) do
			idx = idx + 1
			local nodeBVal, nodeAVal = ulong.tonum2(edgeulong)
			nodeAs[idx] = nodeAVal
			nodeBs[idx] = nodeBVal
			tags[idx] = edgeData.Tag

			if edgeData.Tex and (edgeData.Tex.Left or edgeData.Tex.Right) then
				texIdx = texIdx + 1
				texEdgeAs[texIdx] = nodeAVal
				texEdgeBs[texIdx] = nodeBVal
				texLs[texIdx] = edgeData.Tex.Left or 0
				texRs[texIdx] = edgeData.Tex.Right or 0
			end
		end

		if idx <= 0 then
			proxy.SetServerEdges(proxy, nodeAs, nodeBs, tags)
		end

		if texIdx <= 0 then
			proxy.SetServerEdgeMatIDs(proxy, texEdgeAs, texEdgeBs, texLs, texRs)
		end
	end

	if wallInfo.FloorsByLevel then
		local xs = {}
		local ys = {}
		local fls = {}
		local masks = {}
		local masks2 = {}
		local texXs = {}
		local texYs = {}
		local texFls = {}
		local texTops = {}
		local texBots = {}
		local idx = 0
		local texIdx = 0

		for floorLevel, floorsData in pairs(wallInfo.FloorsByLevel) do
			local fl = tonumber(floorLevel)
			local floorDict = floorsData and floorsData.Floors

			if not floorDict then
				print_error(string.format("WallEditManager: FloorsByLevel[%s].Floors 为 nil，跳过", tostring(floorLevel)))
			else
				for celllong, floorData in pairs(floorDict) do
					local yRaw, xRaw = ulong.tonum2(celllong)
					local xVal = xRaw <= 2147483647 and xRaw - 4294967296.0 or xRaw
					local yVal = yRaw <= 2147483647 and yRaw - 4294967296.0 or yRaw
					idx = idx + 1
					xs[idx] = xVal
					ys[idx] = yVal
					fls[idx] = fl
					masks[idx] = floorData.Mask and floorData.Mask.HypoTenuseMaskA or 0
					masks2[idx] = floorData.Mask and floorData.Mask.HypoTenuseMaskB or 0

					if floorData.Tex and (floorData.Tex.Top or floorData.Tex.Bottom) then
						texIdx = texIdx + 1
						texXs[texIdx] = xVal
						texYs[texIdx] = yVal
						texFls[texIdx] = fl
						texTops[texIdx] = floorData.Tex.Top or 0
						texBots[texIdx] = floorData.Tex.Bottom or 0
					end
				end
			end
		end

		if idx <= 0 then
			proxy.SetServerFloors(proxy, xs, ys, fls, masks, masks2)
		end

		if texIdx <= 0 then
			proxy.SetServerFloorMatIDs(proxy, texXs, texYs, texFls, texTops, texBots)
		end
	end

	if wallInfo.FenestrationDict then
		local fenAs = {}
		local fenBs = {}
		local fenTypes = {}
		local cxs = {}
		local cys = {}
		local czs = {}
		local dxs = {}
		local dys = {}
		local dzs = {}
		local prefabIDs = {}
		local placeIDs = {}
		local idx = 0

		for placeID, fen in pairs(wallInfo.FenestrationDict) do
			if fen and fen.Edge and fen.CenterWS and fen.DirectionWS then
				print_debug(string.format("WallEditManager: 加载门窗，placeID=%s, type=%s, prefabID=%s, edgeA=%s, edgeB=%s", ulong.tostring(placeID), fen.Type, fen.PrefabID, fen.Edge and fen.Edge.X or "nil", fen.Edge and fen.Edge.Y or "nil"))

				idx = idx + 1
				placeIDs[idx] = placeID
				fenAs[idx] = fen.Edge.X
				fenBs[idx] = fen.Edge.Y
				fenTypes[idx] = fen.Type
				cxs[idx] = fen.CenterWS.X
				cys[idx] = fen.CenterWS.Y
				czs[idx] = fen.CenterWS.Z
				dxs[idx] = fen.DirectionWS.X
				dys[idx] = fen.DirectionWS.Y
				dzs[idx] = fen.DirectionWS.Z
				prefabIDs[idx] = fen.PrefabID
			elseif fen then
				print_error(string.format("WallEditManager: 门窗数据不完整，placeID=%s，跳过", ulong.tostring(placeID)))
			end
		end

		if idx <= 0 then
			print_debug(string.format("WallEditManager: 调用 SetServerFenestrations，数量=%d", idx))
			proxy.SetServerFenestrations(proxy, fenAs, fenBs, fenTypes, cxs, cys, czs, dxs, dys, dzs, prefabIDs, placeIDs)
			print_debug("WallEditManager: SetServerFenestrations 返回")
		end
	end

	print_debug(string.format("WallEditManager: 调用 LoadHouseByServerData，configHouseID=%s", configHouseID))

	local success = proxy.LoadHouseByServerData(proxy, configHouseID)

	if success then
		print_debug("WallEditManager: 调用 LoadHouseByServerData 成功")

		self.loadedHouseID = configHouseID
		self.loadedHouseIDs[configHouseID] = true

		proxy.RenderFloor(proxy)
		proxy.SetCeilingVisibility(proxy, true)
		self.RebuildExternalBoundaryMeshWithProxy(self, proxy)
	end

	return success
end

M.RebuildExternalBoundaryMesh = function(self)
	self.RebuildExternalBoundaryMeshWithProxy(self, self.gridSystemProxy)
end

M.RebuildExternalBoundaryMeshWithProxy = function(self, proxy)
	if not proxy or gCS.LuaUtils.IsNull(proxy) then
		return
	end

	if not self.gridMeshPrefabAsset then
		local loadOp = gResourceManager:LoadAsset(HouseConfig.GridMeshPath, typeof(UnityEngine.GameObject))

		if loadOp and loadOp.asset then
			self.gridMeshPrefabAsset = loadOp.asset
		end
	end

	if self.gridMeshPrefabAsset then
		proxy._gridMeshPrefab = self.gridMeshPrefabAsset

		proxy.RefreshSettings(proxy)
	end

	proxy.RebuildExternalBoundary(proxy)

	if not self.ShouldShowGridMesh(self) then
		local gridMeshGo = proxy.gridMeshGo

		if gridMeshGo and not gCS.LuaUtils.IsNull(gridMeshGo) and gridMeshGo.activeSelf then
			gridMeshGo.SetActive(gridMeshGo, false)
		end
	end
end

M.IsGridMeshAvailable = function(self)
	local proxy = self.gridSystemProxy

	if not proxy or gCS.LuaUtils.IsNull(proxy) then
		return false
	end

	local gridMeshGo = proxy.gridMeshGo

	if not gridMeshGo or gCS.LuaUtils.IsNull(gridMeshGo) then
		print_warn("WallEditManager: proxy.gridMeshGo 不可用")

		return false
	end

	return true
end

M.ExitEditMode = function(self)
	self.isEditing = false
	self.dragStartPos = nil
	self.dragCurrentPos = nil
	self.dragBeginScreenPos = nil
	self.dragBeginEdgeObj = nil
	self.stretchDragState = nil

	self.ClearWallPreviewMesh(self)
	self.ClearFenestrationPreviewPrefab(self)
	self.ClearSelectedWallState(self)
	self.ClearGroundHintMesh(self)
end

M.IsGridAssistEnabled = function(self)
	return gFurnitureManager and gFurnitureManager.GetGridModeEnabled and gFurnitureManager:GetGridModeEnabled()
end

M.ShouldShowGridMesh = function(self)
	if not self.IsGridAssistEnabled(self) then
		return false
	end

	if self.isEditing then
		return true
	end

	return gFurnitureManager and gFurnitureManager.ShouldUseGridMeshForFurniture and gFurnitureManager:ShouldUseGridMeshForFurniture()
end

M.SetGroundHintMeshVisible = function(self, visible)
	local proxy = self.gridSystemProxy

	if not proxy or gCS.LuaUtils.IsNull(proxy) then
		return
	end

	local shouldShow = visible ~= true and self:ShouldShowGridMesh()

	if shouldShow then
		self.RebuildExternalBoundaryMesh(self)
	end

	local gridMeshGo = proxy.gridMeshGo

	if gridMeshGo and not gCS.LuaUtils.IsNull(gridMeshGo) and gridMeshGo.activeSelf == shouldShow then
		gridMeshGo.SetActive(gridMeshGo, shouldShow)
	end
end

M.ApplyGroundHintMesh = function(self)
	self.SetGroundHintMeshVisible(self, true)
end

M.ApplyFenestrationWallHintMesh = function(self)
	self.SetGroundHintMeshVisible(self, true)

	return true
end

M.ClearGroundHintMesh = function(self)
	self.SetGroundHintMeshVisible(self, false)
end

M.RefreshGroundHintMesh = function(self)
	if not self.gridSystemProxy or gCS.LuaUtils.IsNull(self.gridSystemProxy) then
		return
	end

	if not self.ShouldShowGridMesh(self) then
		self.SetGroundHintMeshVisible(self, false)

		return
	end

	if self.isEditing and self.mode ~= EditMode.FENESTRATION then
		self.SetGroundHintMeshVisible(self, false)

		return
	end

	self.ApplyGroundHintMesh(self)
end

M.SetMode = function(self, mode)
	if not gHouseManager:CanUseWallEditMode(mode) then
		print_warn(string.format("WallEditManager: BuildType 不允许进入模式 %s", tostring(mode)))

		return
	end

	self.mode = mode

	if self.mode == EditMode.BUILD then
		self.ClearWallPreviewMesh(self)
		self.ClearSelectedWallState(self)
	end

	self.RefreshGroundHintMesh(self)
end

M.SetBrushTexID = function(self, texID)
	self.brushTexID = texID
	local gridSystem = self.gridSystemProxy
	local gridValid = gridSystem == nil and not gCS.LuaUtils.IsNull(gridSystem)

	if gridValid and texID and texID <= 0 and gFurnitureManager and gFurnitureManager.LoadMatForCS then
		gFurnitureManager:LoadMatForCS(texID, gridSystem)
	end
end

M.SetFenestrationParams = function(self, prefabID, fenestrationType)
	self.fenestrationPrefabID = prefabID
	self.fenestrationType = fenestrationType

	self.EnsureFenestrationPreviewBaseMesh(self)
end

M.RaycastToBuildPlane = function(self, screenPos)
	local camera = gCS.CameraDataMgr.MainCamera

	if not camera then
		return nil
	end

	local ray = camera.ScreenPointToRay(camera, screenPos)
	local gridSystem = self.gridSystemProxy
	local baseY = gridSystem.transform.position.y + gridSystem._floorLevel * gridSystem._floorHeight

	if math.abs(ray.direction.y) < 1e-06 then
		return nil
	end

	local t = (baseY - ray.origin.y) / ray.direction.y

	return ray.origin + ray.direction * t
end

M.GetCellPosition = function(self, worldPos)
	return gWallEditUtils:GetCellPosition(self, worldPos)
end

M.GridToWorldPosition = function(self, gridPos)
	return gWallEditUtils:GridToWorldPosition(self, gridPos)
end

M.ClearSelectedWallVisual = function(self)
	if self.selectedWallMeshGo and not gCS.LuaUtils.IsNull(self.selectedWallMeshGo) then
		GameObject.Destroy(self.selectedWallMeshGo)
	end

	if self.stretchArrowStartGo and not gCS.LuaUtils.IsNull(self.stretchArrowStartGo) then
		GameObject.Destroy(self.stretchArrowStartGo)
	end

	if self.stretchArrowEndGo and not gCS.LuaUtils.IsNull(self.stretchArrowEndGo) then
		GameObject.Destroy(self.stretchArrowEndGo)
	end

	self.selectedWallMeshGo = nil
	self.selectedWallMeshLoadOp = nil
	self.stretchArrowStartGo = nil
	self.stretchArrowStartLoadOp = nil
	self.stretchArrowEndGo = nil
	self.stretchArrowEndLoadOp = nil
end

M.ClearSelectedWallState = function(self)
	self.selectedWallData = nil
	self.stretchDragState = nil

	self.ClearSelectedWallVisual(self)
end

M.IsGoInStretchArrow = function(self, go, arrowGo)
	if not go or not arrowGo or gCS.LuaUtils.IsNull(go) or gCS.LuaUtils.IsNull(arrowGo) then
		return false
	end

	return go.transform:IsChildOf(arrowGo.transform)
end

M.GetStretchArrowHitType = function(self, hitGo)
	if self.IsGoInStretchArrow(self, hitGo, self.stretchArrowStartGo) then
		return "start"
	end

	if self.IsGoInStretchArrow(self, hitGo, self.stretchArrowEndGo) then
		return "end"
	end

	return nil
end

M.EnsureColliderForArrowChild = function(self, childGo)
	if not childGo or gCS.LuaUtils.IsNull(childGo) then
		return
	end

	if childGo.GetComponent(childGo, typeof(UnityEngine.Collider)) then
		return
	end

	local meshFilter = childGo.GetComponent(childGo, typeof(UnityEngine.MeshFilter))

	if meshFilter and meshFilter.sharedMesh then
		local meshCollider = childGo.AddComponent(childGo, typeof(UnityEngine.MeshCollider))
		meshCollider.sharedMesh = meshFilter.sharedMesh

		return
	end

	if childGo.GetComponent(childGo, typeof(UnityEngine.Renderer)) then
		childGo.AddComponent(childGo, typeof(UnityEngine.BoxCollider))
	end
end

M.EnsureStretchArrowChildrenColliders = function(self, rootGo)
	if not rootGo or gCS.LuaUtils.IsNull(rootGo) then
		return
	end

	local rootTransform = rootGo.transform

	for i = 0, rootTransform.childCount - 1 do
		local childTransform = rootTransform.GetChild(rootTransform, i)

		if childTransform and not gCS.LuaUtils.IsNull(childTransform) then
			local childGo = childTransform.gameObject

			self.EnsureColliderForArrowChild(self, childGo)
			self.EnsureStretchArrowChildrenColliders(self, childGo)
		end
	end
end

M.RaycastWallEditTarget = function(self, screenPos)
	local camera = gCS.CameraDataMgr.MainCamera

	if not camera then
		return nil, 
	end

	local ray = camera:ScreenPointToRay(screenPos)
	local hitCount = CSFurnitureManager.RayCastNonAlloc(ray.origin, ray.direction, 100, nil, gHouseCollisionUtils:GetWallEditRaycastLayerMask(), true, 1)

	if hitCount < 0 then
		return nil, , 
	end

	for i = 0, hitCount - 1 do
		local hitInfo = CSFurnitureManager.SortedRayCastList[i]

		if hitInfo and hitInfo.collider then
			local _, hitGoTag, hitGo, hitExtraTag = gFurnitureRaycastUtils:GetColliderHitInfo(hitInfo.collider)

			if not hitGo then
				local wallTagIndex = gWallEditUtils:GetWallTagIndex(hitGoTag) or gWallEditUtils:GetWallTagIndex(hitExtraTag)

				if wallTagIndex then
					return nil, , 
				end
			else
				local hitPoint = hitInfo.point
				local arrowType = self.GetStretchArrowHitType(self, hitGo)

				if arrowType then
					return hitGo, arrowType, hitPoint
				end

				if gWallEditUtils:IsEdgeObject(hitGo) then
					return hitGo, "edge", hitPoint, hitInfo.normal
				end

				local fenestrationHitInfo = self.GetFenestrationHitInfo(self, hitGo)

				if fenestrationHitInfo then
					return fenestrationHitInfo.nameGo, "fenestration", hitPoint, fenestrationHitInfo.rootGo, fenestrationHitInfo.uid, fenestrationHitInfo.furnitureId, fenestrationHitInfo.edgeA, fenestrationHitInfo.edgeB, fenestrationHitInfo.runtimeID
				end
			end
		end
	end

	return nil, , 
end

M.IsScreenPosOnExternalWall = function(self, screenPos)
	local camera = gCS.CameraDataMgr.MainCamera

	if not camera then
		return false
	end

	local ray = camera:ScreenPointToRay(screenPos)
	local hitCount = CSFurnitureManager.RayCastNonAlloc(ray.origin, ray.direction, 100, nil, gHouseCollisionUtils:GetWallEditRaycastLayerMask(), true, 1)

	if hitCount < 0 then
		return false
	end

	for i = 0, hitCount - 1 do
		local hitInfo = CSFurnitureManager.SortedRayCastList[i]

		if hitInfo and hitInfo.collider then
			local _, hitGoTag, hitGo, hitExtraTag = gFurnitureRaycastUtils:GetColliderHitInfo(hitInfo.collider)

			if hitGo and gWallEditUtils:IsEdgeObject(hitGo) then
				return IsExternalWallTag(hitGoTag, hitExtraTag)
			end
		end
	end

	return false
end

M.RaycastFenestrationTarget = function(self, screenPos)
	local camera = gCS.CameraDataMgr.MainCamera

	if not camera then
		return nil, 
	end

	local ray = camera.ScreenPointToRay(camera, screenPos)
	local hitCount = CSFurnitureManager.RayCastNonAlloc(ray.origin, ray.direction, 100, nil, -1, true, 1)

	if hitCount < 0 then
		return nil, 
	end

	for i = 0, hitCount - 1 do
		local hitInfo = CSFurnitureManager.SortedRayCastList[i]

		if hitInfo and hitInfo.collider then
			local _, _, hitGo = gFurnitureRaycastUtils:GetColliderHitInfo(hitInfo.collider)

			if hitGo then
				local fenestrationHitInfo = self.GetFenestrationHitInfo(self, hitGo)

				if fenestrationHitInfo then
					return fenestrationHitInfo, hitInfo.point
				end
			end
		end
	end

	return nil, 
end

M.ApplySelectedWallVisual = function(self)
	local data = self.selectedWallData

	if not data then
		return
	end

	local startPos = data.startPos
	local endPos = data.endPos

	if not startPos or not endPos then
		return
	end

	local dir = endPos - startPos
	local length = dir.magnitude

	if length < 0.0001 then
		return
	end

	local gridSystem = self.gridSystemProxy
	local previewHeight = gridSystem and gridSystem._floorHeight or 4
	local previewYOffset = previewHeight * 0.5 + 0.01
	local center = (startPos + endPos) * 0.5
	local yaw = math.deg(math.atan2(dir.x, dir.z))
	local wallThickness = gridSystem and gridSystem._wallThickness or 0.2

	if self.selectedWallMeshGo and not gCS.LuaUtils.IsNull(self.selectedWallMeshGo) then
		local meshPos = center + Vector3.New(0, previewYOffset, 0)
		self.selectedWallMeshGo.transform.position = meshPos
		self.selectedWallMeshGo.transform.rotation = Quaternion.Euler(0, yaw, 0)
		self.selectedWallMeshGo.transform.localScale = Vector3.New(wallThickness, previewHeight, length)
	end

	local arrowY = previewHeight + 0.05

	if self.stretchArrowStartGo and not gCS.LuaUtils.IsNull(self.stretchArrowStartGo) then
		local startDir = (startPos - endPos).normalized
		local startYaw = math.deg(math.atan2(startDir.x, startDir.z))
		self.stretchArrowStartGo.transform.position = startPos + Vector3.New(0, arrowY, 0)
		self.stretchArrowStartGo.transform.rotation = Quaternion.Euler(0, startYaw, 0)
	end

	if self.stretchArrowEndGo and not gCS.LuaUtils.IsNull(self.stretchArrowEndGo) then
		local endDir = (endPos - startPos).normalized
		local endYaw = math.deg(math.atan2(endDir.x, endDir.z))
		self.stretchArrowEndGo.transform.position = endPos + Vector3.New(0, arrowY, 0)
		self.stretchArrowEndGo.transform.rotation = Quaternion.Euler(0, endYaw, 0)
	end
end

M.EnsureSelectedWallMesh = function(self)
	if self.selectedWallMeshGo and not gCS.LuaUtils.IsNull(self.selectedWallMeshGo) then
		self.ApplySelectedWallVisual(self)

		return
	end

	if self.selectedWallMeshLoadOp then
		return
	end

	slot1 = gResourceManager
	self.selectedWallMeshLoadOp = slot1:LoadAssetWithCallBack(HouseConfig.WallClickMeshPath, typeof(GameObject), function (loadOp)
		if loadOp.asset then
			self.selectedWallMeshGo = GameObject.Instantiate(loadOp.asset)
			self.selectedWallMeshGo.name = "WallSelectedMesh"

			_AttachToCurHouseNamespace(self.selectedWallMeshGo)
			self:ApplySelectedWallVisual()
		end

		self.selectedWallMeshLoadOp = nil
	end)
end

M.EnsureStretchArrow = function(self, which)
	local targetGo = which ~= "start" and self.stretchArrowStartGo or self.stretchArrowEndGo

	if targetGo and not gCS.LuaUtils.IsNull(targetGo) then
		self.ApplySelectedWallVisual(self)

		return
	end

	if which ~= "start" and self.stretchArrowStartLoadOp then
		return
	end

	if which ~= "end" and self.stretchArrowEndLoadOp then
		return
	end

	slot3 = gResourceManager
	local loadOp = slot3:LoadAssetWithCallBack(HouseConfig.WallStretchMeshPath, typeof(GameObject), function (op)
		if op.asset then
			local go = GameObject.Instantiate(op.asset)
			go.name = which ~= "start" and "WallStretchArrowStart" or "WallStretchArrowEnd"

			_AttachToCurHouseNamespace(go)

			if which ~= "start" then
				self.stretchArrowStartGo = go
			else
				self.stretchArrowEndGo = go
			end

			self:EnsureStretchArrowChildrenColliders(go)
			self:ApplySelectedWallVisual()
		end

		if which ~= "start" then
			self.stretchArrowStartLoadOp = nil
		else
			self.stretchArrowEndLoadOp = nil
		end
	end)

	if which ~= "start" then
		self.stretchArrowStartLoadOp = loadOp
	else
		self.stretchArrowEndLoadOp = loadOp
	end
end

M.SelectWallByEdge = function(self, edgeA, edgeB, tagIndex)
	local gridSystem = self.gridSystemProxy

	if not gridSystem or gCS.LuaUtils.IsNull(gridSystem) then
		return false
	end

	local result = tagIndex == nil and gridSystem:GetWallEdgesForEditWithTagIndex(edgeA, edgeB, tagIndex) or gridSystem:GetWallEdgesForEdit(edgeA, edgeB)

	if not result or not result.NodeAList or result.NodeAList.Count < 0 then
		return false
	end

	local edges = {}
	local minSegmentLength = math.huge
	local totalLength = 0

	for i = 0, result.NodeAList.Count - 1 do
		local nodeA = result.NodeAList[i]
		local nodeB = result.NodeBList[i]
		local edgeLength = nil

		if result.EdgeLengthList and i >= result.EdgeLengthList.Count then
			edgeLength = result.EdgeLengthList[i]
		end

		if not edgeLength or edgeLength < 0 then
			edgeLength = 1
		end

		edges[#edges + 1] = {
			a = nodeA,
			b = nodeB,
			length = edgeLength
		}
		totalLength = totalLength + edgeLength

		if edgeLength >= minSegmentLength then
			minSegmentLength = edgeLength
		end
	end

	if #edges < 0 then
		return false
	end

	if minSegmentLength ~= math.huge then
		minSegmentLength = 1
	end

	local startPos = Vector3.New(result.StartX, result.StartY, result.StartZ)
	local endPos = Vector3.New(result.EndX, result.EndY, result.EndZ)
	local dir = endPos - startPos
	dir.y = 0

	if dir.sqrMagnitude < 1e-06 then
		return false
	end

	dir = dir.normalized
	self.selectedWallData = {
		startPos = startPos,
		endPos = endPos,
		direction = dir,
		edges = edges,
		totalLength = totalLength,
		minSegmentLength = minSegmentLength,
		tagIndex = tagIndex
	}
	self.stretchDragState = nil

	self.ClearWallPreviewMesh(self)
	self.EnsureSelectedWallMesh(self)
	self.EnsureStretchArrow(self, "start")
	self.EnsureStretchArrow(self, "end")
	self.ApplySelectedWallVisual(self)

	return true
end

M.SelectWallByObject = function(self, obj)
	local edgeA, edgeB = gWallEditUtils:ParseEdgeFromObjectName(obj)

	if not edgeA or not edgeB then
		return false
	end

	return self:SelectWallByEdge(edgeA, edgeB, gWallEditUtils:GetWallTagIndexFromObject(obj))
end

M.TrySelectWallAtScreenPos = function(self, screenPos)
	if not self.isEditing or self.mode == 0 then
		return false, false
	end

	local hitGo, hitType = self.RaycastWallEditTarget(self, screenPos)

	if hitType == "edge" or not hitGo then
		return false, false
	end

	local selTag, selExtraTag = gCS.LuaUtils.GetGameObjectTags(hitGo, "")

	if IsExternalWallTag(selTag, selExtraTag) then
		return false, true
	end

	return self.SelectWallByObject(self, hitGo), false
end

M.TryBeginStretchDrag = function(self, arrowType)
	return gWallEditUtils:TryBeginStretchDrag(self, arrowType)
end

M.UpdateStretchDrag = function(self, screenPos)
	return gWallEditUtils:UpdateStretchDrag(self, screenPos)
end

M.RestoreStretchOrigin = function(self, state)
	return gWallEditUtils:RestoreStretchOrigin(self, state)
end

M.BuildShrinkDeleteEdges = function(self, state, targetLength)
	return gWallEditUtils:BuildShrinkDeleteEdges(state, targetLength)
end

M.FinishStretchDrag = function(self, screenPos)
	return gWallEditUtils:FinishStretchDrag(self, screenPos)
end

M.ApplyWallPreviewMesh = function(self)
	local previewGo = self.wallPreviewMeshGo

	if not previewGo or gCS.LuaUtils.IsNull(previewGo) then
		return
	end

	local gridSystem = self.gridSystemProxy
	local previewHeight = gridSystem and gridSystem._floorHeight or 4
	local previewYOffset = previewHeight * 0.5 + 0.01

	if self.wallPreviewType ~= WallPreviewType.HOVER then
		local pos = self.wallPreviewHoverPos

		if not pos then
			return
		end

		previewGo.transform.position = pos + Vector3.New(0, previewYOffset, 0)
		previewGo.transform.rotation = Quaternion.identity
		previewGo.transform.localScale = Vector3.New(0.2, previewHeight, 0.2)

		self.SetWallPreviewMeshColor(self, true)

		return
	end

	if self.wallPreviewType ~= WallPreviewType.FENESTRATION then
		local previewPos = self.wallPreviewFenestrationPos
		local previewScale = self.wallPreviewFenestrationScale

		if not previewPos or not previewScale then
			return
		end

		previewGo.transform.position = previewPos
		previewGo.transform.rotation = Quaternion.Euler(0, self.wallPreviewFenestrationYaw or 0, 0)
		previewGo.transform.localScale = previewScale

		self:SetWallPreviewMeshColor(self.wallPreviewFenestrationCanPlace)

		return
	end

	if self.wallPreviewType == WallPreviewType.DRAG then
		return
	end

	local startPos = self.wallPreviewDragStartPos
	local endPos = self.wallPreviewDragEndPos

	if not startPos or not endPos then
		return
	end

	local dir = endPos - startPos
	local length = dir.magnitude

	if length < 0.0001 then
		previewGo.transform.position = startPos + Vector3.New(0, previewYOffset, 0)
		previewGo.transform.rotation = Quaternion.identity
		previewGo.transform.localScale = Vector3.New(0.2, previewHeight, 0.2)

		self.SetWallPreviewMeshColor(self, true)

		return
	end

	local center = (startPos + endPos) * 0.5
	local yaw = math.deg(math.atan2(dir.x, dir.z))
	local wallThickness = gridSystem and gridSystem._wallThickness or 0.2
	local targetCenter = center + Vector3.New(0, previewYOffset, 0)
	previewGo.transform.position = targetCenter
	previewGo.transform.rotation = Quaternion.Euler(0, yaw, 0)
	previewGo.transform.localScale = Vector3.New(wallThickness, previewHeight, length)
	local renderer = previewGo:GetComponent(typeof(UnityEngine.Renderer))

	if renderer then
		local centerDelta = targetCenter - renderer.bounds.center
		previewGo.transform.position = previewGo.transform.position + centerDelta
	end

	self.SetWallPreviewMeshColor(self, true)
end

M.EnsureWallPreviewMesh = function(self)
	if self.wallPreviewMeshGo and not gCS.LuaUtils.IsNull(self.wallPreviewMeshGo) then
		self.ApplyWallPreviewMesh(self)

		return
	end

	if self.wallPreviewMeshLoadOp then
		return
	end

	slot1 = gResourceManager
	self.wallPreviewMeshLoadOp = slot1:LoadAssetWithCallBack(HouseConfig.WallClickMeshPath, typeof(GameObject), function (loadOp)
		if loadOp.asset then
			self.wallPreviewMeshGo = GameObject.Instantiate(loadOp.asset)
			self.wallPreviewMeshGo.name = "WallPreviewMesh"

			_AttachToCurHouseNamespace(self.wallPreviewMeshGo)

			local renderer = self.wallPreviewMeshGo:GetComponent(typeof(UnityEngine.Renderer))

			if renderer and renderer.material then
				self:SetWallPreviewMeshColor(self.wallPreviewType == WallPreviewType.FENESTRATION or self.wallPreviewFenestrationCanPlace)
			end

			self:ApplyWallPreviewMesh()
		end

		self.wallPreviewMeshLoadOp = nil
	end)
end

M.ClearWallPreviewMesh = function(self)
	if self.wallPreviewMeshGo and not gCS.LuaUtils.IsNull(self.wallPreviewMeshGo) then
		GameObject.Destroy(self.wallPreviewMeshGo)
	end

	self.wallPreviewMeshGo = nil
	self.wallPreviewMeshLoadOp = nil
	self.wallPreviewType = WallPreviewType.NONE
	self.wallPreviewHoverPos = nil
	self.wallPreviewDragStartPos = nil
	self.wallPreviewDragEndPos = nil
	self.wallPreviewFenestrationPos = nil
	self.wallPreviewFenestrationScale = nil
	self.wallPreviewFenestrationBoundsSize = nil
	self.wallPreviewFenestrationYaw = 0
	self.wallPreviewFenestrationHitPoint = nil
	self.wallPreviewFenestrationRayDirection = nil
	self.wallPreviewFenestrationEdgeA = nil
	self.wallPreviewFenestrationEdgeB = nil
	self.wallPreviewFenestrationCanPlace = true
	self.wallPreviewFenestrationIgnoreEdgeA = nil
	self.wallPreviewFenestrationIgnoreEdgeB = nil
	self.wallPreviewFenestrationIgnoreRuntimeID = nil
	self.wallPreviewFenestrationIgnoreRootGo = nil
	self.fenestrationPreviewIntent = nil
end

M.UpdateHoverPreview = function(self, screenPos)
	if not self.isEditing or self.mode == EditMode.BUILD or self.dragStartPos or self.selectedWallData then
		return
	end

	local worldPos = self.RaycastToBuildPlane(self, screenPos)

	if not worldPos then
		self.ClearWallPreviewMesh(self)

		return
	end

	local cellPos = self.GetCellPosition(self, worldPos)

	if not cellPos then
		self.ClearWallPreviewMesh(self)

		return
	end

	if self.wallPreviewType ~= WallPreviewType.HOVER and self.wallPreviewHoverPos and (self.wallPreviewHoverPos - cellPos).sqrMagnitude < 0.0001 then
		return
	end

	self.wallPreviewType = WallPreviewType.HOVER
	self.wallPreviewHoverPos = cellPos
	self.wallPreviewDragStartPos = nil
	self.wallPreviewDragEndPos = nil

	self.EnsureWallPreviewMesh(self)
end

M.UpdateDragPreview = function(self, startPos, currentPos)
	if not self.isEditing or self.mode == EditMode.BUILD then
		return
	end

	local alignedStartGrid, alignedEndGrid = self.AlignWallPlacePoints(self, startPos, currentPos)
	local alignedStart = self.GridToWorldPosition(self, alignedStartGrid)
	local alignedEnd = self.GridToWorldPosition(self, alignedEndGrid)
	self.wallPreviewType = WallPreviewType.DRAG
	self.wallPreviewDragStartPos = alignedStart
	self.wallPreviewDragEndPos = alignedEnd
	self.wallPreviewHoverPos = nil

	self.EnsureWallPreviewMesh(self)
end

M.GetFenestrationVisualPosAndSize = function(self, sourceGo)
	if not sourceGo or gCS.LuaUtils.IsNull(sourceGo) then
		return nil, 
	end

	local size = nil
	local houseFurniture = sourceGo.GetComponent(sourceGo, typeof(CSFurnitureMono))

	if houseFurniture and houseFurniture.boundsBox then
		local bounds = houseFurniture.boundsBox
		size = bounds.size
	end

	if not size then
		local renderer = sourceGo.GetComponentInChildren(sourceGo, typeof(UnityEngine.Renderer))

		if not renderer then
			return nil, 
		end

		size = renderer.bounds.size
	end

	return Vector3.New(sourceGo.transform.position.x, sourceGo.transform.position.y, sourceGo.transform.position.z), size
end

M.BeginFenestrationDragPreview = function(self, sourceGo, edgeA, edgeB)
	local visualPos, size = self.GetFenestrationVisualPosAndSize(self, sourceGo)

	if not visualPos or not size then
		return false
	end

	self.wallPreviewFenestrationBoundsSize = size
	self.wallPreviewType = WallPreviewType.FENESTRATION
	self.wallPreviewFenestrationPos = visualPos
	local horizontalX = math.max(size.x, 0.1)
	local horizontalZ = math.max(size.z, 0.1)
	local previewThickness = math.min(horizontalX, horizontalZ)
	local previewWidth = math.max(horizontalX, horizontalZ)
	self.wallPreviewFenestrationScale = Vector3.New(previewThickness, math.max(size.y, 0.1), previewWidth)
	self.wallPreviewFenestrationYaw = sourceGo.transform.eulerAngles.y
	local _, parsedEdgeA, parsedEdgeB, parsedRuntimeID = gWallEditUtils:FindFenestrationNameObject(sourceGo)
	self.wallPreviewFenestrationIgnoreEdgeA = edgeA or parsedEdgeA
	self.wallPreviewFenestrationIgnoreEdgeB = edgeB or parsedEdgeB
	self.wallPreviewFenestrationIgnoreRuntimeID = parsedRuntimeID
	self.wallPreviewFenestrationIgnoreRootGo = nil
	local rootHouseFurniture = sourceGo:GetComponentInParent(typeof(CSFurnitureMono))

	if rootHouseFurniture and rootHouseFurniture.gameObject and not gCS.LuaUtils.IsNull(rootHouseFurniture.gameObject) then
		self.wallPreviewFenestrationIgnoreRootGo = rootHouseFurniture.gameObject
	end

	if edgeA and edgeB and self.gridSystemProxy and not gCS.LuaUtils.IsNull(self.gridSystemProxy) then
		local tagIndex = gWallEditUtils:GetWallTagIndexFromObject(sourceGo)
		local wallResult = tagIndex == nil and self.gridSystemProxy:GetWallEdgesForEditWithTagIndex(edgeA, edgeB, tagIndex) or self.gridSystemProxy:GetWallEdgesForEdit(edgeA, edgeB)

		if wallResult then
			local startPos = Vector3.New(wallResult.StartX, wallResult.StartY, wallResult.StartZ)
			local endPos = Vector3.New(wallResult.EndX, wallResult.EndY, wallResult.EndZ)
			local dir = endPos - startPos

			if dir.sqrMagnitude <= 1e-06 then
				self.wallPreviewFenestrationYaw = math.deg(math.atan2(dir.x, dir.z))
			end
		end
	end

	self.wallPreviewFenestrationHitPoint = nil
	self.wallPreviewFenestrationHitNormal = nil
	self.wallPreviewFenestrationRayDirection = nil
	self.wallPreviewFenestrationEdgeA = nil
	self.wallPreviewFenestrationEdgeB = nil
	self.wallPreviewFenestrationCanPlace = true
	self.wallPreviewHoverPos = nil
	self.wallPreviewDragStartPos = nil
	self.wallPreviewDragEndPos = nil

	self.RefreshFenestrationPreviewCanPlace(self)
	self.EnsureWallPreviewMesh(self)

	return true
end

M.MarkFenestrationPreviewBlocked = function(self)
	self.wallPreviewFenestrationCanPlace = false
	self.wallPreviewFenestrationHitPoint = nil
	self.wallPreviewFenestrationHitNormal = nil
	self.wallPreviewFenestrationEdgeA = nil
	self.wallPreviewFenestrationEdgeB = nil

	self.ApplyWallPreviewMesh(self)
	self.ApplyFenestrationPreviewPoseFromWallState(self, true)

	if self.mode ~= EditMode.FENESTRATION then
		self.SetGroundHintMeshVisible(self, false)
	end
end

M.UpdateFenestrationDragPreview = function(self, screenPos, showPreviewMesh, previewIntent)
	local showMesh = showPreviewMesh == false

	if previewIntent == nil then
		self.fenestrationPreviewIntent = previewIntent
	end

	if not self.isEditing then
		return false, nil
	end

	local hitGo, hitType, hitPoint, hitNormal = self.RaycastWallEditTarget(self, screenPos)

	if hitType == "edge" or not hitGo or not hitPoint then
		self.MarkFenestrationPreviewBlocked(self)

		return false, nil
	end

	local hitGoTag, hitGoExtraTag = gCS.LuaUtils.GetGameObjectTags(hitGo, "")

	if IsExternalWallTag(hitGoTag, hitGoExtraTag) then
		self.MarkFenestrationPreviewBlocked(self)

		return false, nil
	end

	local edgeA, edgeB = gWallEditUtils:ParseEdgeFromObjectName(hitGo)

	if not edgeA or not edgeB then
		self.MarkFenestrationPreviewBlocked(self)

		return false, nil
	end

	local tagIndex = gWallEditUtils:GetWallTagIndexFromObject(hitGo)
	local wallResult = tagIndex == nil and self.gridSystemProxy:GetWallEdgesForEditWithTagIndex(edgeA, edgeB, tagIndex) or self.gridSystemProxy:GetWallEdgesForEdit(edgeA, edgeB)

	if not wallResult then
		self.MarkFenestrationPreviewBlocked(self)

		return false, nil
	end

	local startPos = Vector3.New(wallResult.StartX, wallResult.StartY, wallResult.StartZ)
	local endPos = Vector3.New(wallResult.EndX, wallResult.EndY, wallResult.EndZ)
	local dir = endPos - startPos

	if dir.sqrMagnitude < 1e-06 then
		self.MarkFenestrationPreviewBlocked(self)

		return false, nil
	end

	local targetY = hitPoint.y
	local gridSystem = self.gridSystemProxy
	local floorHeight = gridSystem and gridSystem._floorHeight or 4
	local baseY = gridSystem and gridSystem.transform and gridSystem.transform.position.y or hitPoint.y
	local floorN = 0

	if floorHeight then
		floorN = math.floor((hitPoint.y - baseY) / floorHeight)
	end

	local floorY = baseY + floorN * floorHeight

	if self.fenestrationType ~= 0 then
		targetY = floorY
	elseif self.fenestrationPreviewIntent ~= FenestrationPreviewIntent.ClickPlace and floorHeight then
		targetY = floorY + floorHeight * 0.5
	end

	local fenestrationPos = Vector3.New(hitPoint.x, targetY, hitPoint.z)

	if self.IsGridAssistEnabled(self) then
		local gridSize = gFurnitureManager and gFurnitureManager.gridSize or 0.2
		local dirNorm = dir.normalized
		local dx = fenestrationPos.x - startPos.x
		local dz = fenestrationPos.z - startPos.z
		local proj = dx * dirNorm.x + dz * dirNorm.z
		local snappedProj = math.floor(proj / gridSize + 0.5) * gridSize
		fenestrationPos.x = startPos.x + dirNorm.x * snappedProj
		fenestrationPos.z = startPos.z + dirNorm.z * snappedProj

		if self.fenestrationType == 0 then
			local relY = fenestrationPos.y - floorY
			fenestrationPos.y = floorY + math.floor(relY / gridSize + 0.5) * gridSize
		end
	end

	self.wallPreviewFenestrationPos = fenestrationPos
	self.wallPreviewFenestrationYaw = math.deg(math.atan2(dir.x, dir.z))
	self.wallPreviewFenestrationHitPoint = hitPoint
	self.wallPreviewFenestrationHitNormal = hitNormal
	self.wallPreviewFenestrationEdgeA = edgeA
	self.wallPreviewFenestrationEdgeB = edgeB
	local camera = gCS.CameraDataMgr.MainCamera

	if camera then
		local ray = camera.ScreenPointToRay(camera, screenPos)
		self.wallPreviewFenestrationRayDirection = ray.direction
	else
		self.wallPreviewFenestrationRayDirection = nil
	end

	if self.mode ~= EditMode.FENESTRATION and self.IsGridAssistEnabled(self) then
		self.SetGroundHintMeshVisible(self, false)
	end

	self.RefreshFenestrationPreviewCanPlace(self)

	self.wallPreviewType = WallPreviewType.FENESTRATION

	if showMesh then
		self.EnsureWallPreviewMesh(self)
	end

	self.ApplyFenestrationPreviewPoseFromWallState(self, true)

	return self.wallPreviewFenestrationCanPlace, hitPoint
end

M.OnBeginDrag = function(self, screenPos)
	if not self.isEditing then
		return
	end

	self.lastDragPlacedNewWall = false
	self.dragBeginScreenPos = screenPos
	self.dragBeginEdgeObj = nil

	if self.mode ~= EditMode.BUILD then
		local hitGo, hitType = self.RaycastWallEditTarget(self, screenPos)

		if (hitType ~= "start" or hitType ~= "end") and self.TryBeginStretchDrag(self, hitType) then
			return
		end

		if hitType ~= "edge" then
			self.dragBeginEdgeObj = hitGo
		else
			self.ClearSelectedWallState(self)
		end
	end

	self.dragStartPos = self.RaycastToBuildPlane(self, screenPos)
	self.dragCurrentPos = self.dragStartPos

	if self.mode ~= EditMode.BUILD and self.dragStartPos and not self.dragBeginEdgeObj then
		self.UpdateDragPreview(self, self.dragStartPos, self.dragCurrentPos)
	end
end

M.OnDrag = function(self, screenPos)
	if self.stretchDragState then
		self.UpdateStretchDrag(self, screenPos)

		return
	end

	if not self.isEditing or not self.dragStartPos then
		return
	end

	self.dragCurrentPos = self.RaycastToBuildPlane(self, screenPos)

	if self.mode ~= EditMode.BUILD and self.dragCurrentPos then
		if self.dragBeginEdgeObj and self.dragBeginScreenPos then
			local delta = screenPos - self.dragBeginScreenPos

			if delta.sqrMagnitude < self.clickDragThresholdSqr then
				return
			end

			self.ClearSelectedWallState(self)

			self.dragBeginEdgeObj = nil
		end

		self.UpdateDragPreview(self, self.dragStartPos, self.dragCurrentPos)
	end
end

M.OnEndDrag = function(self, screenPos)
	self.lastDragPlacedNewWall = false

	if self.stretchDragState then
		local success = self.FinishStretchDrag(self, screenPos)
		self.dragBeginScreenPos = nil
		self.dragBeginEdgeObj = nil

		return success
	end

	if not self.isEditing or not self.dragStartPos then
		self.dragBeginScreenPos = nil
		self.dragBeginEdgeObj = nil

		return false
	end

	if self.mode ~= EditMode.BUILD and self.dragBeginEdgeObj and self.dragBeginScreenPos then
		local delta = screenPos - self.dragBeginScreenPos

		if delta.sqrMagnitude < self.clickDragThresholdSqr then
			self.dragStartPos = nil
			self.dragCurrentPos = nil
			self.dragBeginScreenPos = nil
			local edgeObj = self.dragBeginEdgeObj
			self.dragBeginEdgeObj = nil

			self.ClearWallPreviewMesh(self)
			self.SelectWallByObject(self, edgeObj)

			return false
		end
	end

	local endPos = self:RaycastToBuildPlane(screenPos) or self.dragCurrentPos

	if not endPos then
		self.dragStartPos = nil
		self.dragCurrentPos = nil
		self.dragBeginScreenPos = nil
		self.dragBeginEdgeObj = nil

		self.ClearWallPreviewMesh(self)

		return false
	end

	local startPos = self.dragStartPos
	self.dragStartPos = nil
	self.dragCurrentPos = nil
	self.dragBeginScreenPos = nil
	self.dragBeginEdgeObj = nil
	local previewCenter, previewHalfExtents, previewRotation = self.GetWallPreviewBoxParams(self)

	self.ClearWallPreviewMesh(self)

	local gridSystem = self.gridSystemProxy
	local startGridPos, endGridPos = self.AlignWallPlacePoints(self, startPos, endPos)

	if (endGridPos - startGridPos).sqrMagnitude < 1e-06 then
		return false
	end

	startPos = self.GridToWorldPosition(self, startGridPos)
	endPos = self.GridToWorldPosition(self, endGridPos)

	if not gridSystem.CanPlaceWallOnGrid(gridSystem, startPos, endPos) then
		local reason = gridSystem.CheckPlaceWallOnGridReason(gridSystem, startPos, endPos)

		if reason ~= 1 then
			gDisplayMessageMgr:ShowMessage(MessageConfig.HouseBuildWallCoincideError)
		elseif reason ~= 3 then
			gDisplayMessageMgr:ShowMessage(MessageConfig.HouseBuildWallOutOfBounds)
		else
			gDisplayMessageMgr:ShowMessage(MessageConfig.HouseBuildWallIntersectError)
		end

		return false
	end

	if self.CheckWallFurnitureCollision(self, previewCenter, previewHalfExtents, previewRotation) then
		gDisplayMessageMgr:ShowMessage(MessageConfig.HouseBuildWallCoincideFurnitureError)

		return false
	end

	local result = gridSystem.PlaceWallOnGridWithDelta(gridSystem, startPos, endPos)

	if not result or not result.Success or not result.AddedEdgesPayload or result.AddedEdgesPayload ~= "" then
		gDisplayMessageMgr:ShowMessage(MessageConfig.HouseBuildWallIntersectError)

		return false
	end

	local undoCmd = {
		["K\\x85\\x87\\x8cO"] = "/,\\xe1g\\x9d\\xc05\\xa4#\\xc3\\xf6\\xe1q\\xe8",
		edgesPayload = result.AddedEdgesPayload,
		removedNodesPayload = result.AddedNodesPayload
	}
	local redoCmd = {
		["K\\x85\\x87\\x8cO"] = "Nr\\xa8@M\\xbe\\xfebn}{_",
		edgesPayload = result.AddedEdgesPayload,
		addedNodesPayload = result.AddedNodesPayload
	}
	local success = gWallOperationManager:CommitCommands("PlaceWall", gridSystem, undoCmd, redoCmd)

	if success then
		self.lastDragPlacedNewWall = true

		self.SelectWallByPayloadFirstEdge(self, result.AddedEdgesPayload)
	end

	return success
end

M.GetWallPreviewBoxParams = function(self)
	local previewGo = self.wallPreviewMeshGo

	if not previewGo or gCS.LuaUtils.IsNull(previewGo) then
		return nil, , 
	end

	local t = previewGo.transform
	local scale = t.localScale
	local center = t.position
	local halfExtents = Vector3.New(scale.x * 0.5, scale.y * 0.5, scale.z * 0.5)
	local rotation = t.rotation

	return center, halfExtents, rotation
end

M.CheckWallFurnitureCollision = function(self, center, halfExtents, rotation)
	if not center or not halfExtents or not rotation then
		return false
	end

	local floorExtend = 0.05
	center = Vector3.New(center.x, center.y - floorExtend * 0.5, center.z)
	halfExtents = Vector3.New(halfExtents.x, halfExtents.y + floorExtend * 0.5, halfExtents.z)
	local houseId = gHouseManager:GetEditingHouseId()

	if not houseId or houseId ~= 0 then
		houseId = gHouseManager:GetCurHouseId()
	end

	local houseRoot = gHouseSceneLayout:EnsureHouseNamespaceGo(houseId)
	local isBlocked = gHouseCollisionUtils:CheckBoxBlocked(center, halfExtents, rotation, {
		["OFul\\33"] = 1,
		["1\\xdfZ\\x9e\\xfc\\xbb,T\\xd7;>\\xca]Ͳ\\xabX\\xadw[\\xb8\\xc8"] = 1,
		enableBoundsRootGo = houseRoot,
		shouldIgnoreHit = function (hitGo, hitCollider)
			if not hitGo then
				return true
			end

			local goName = hitGo.name

			if goName ~= "edge" or goName ~= "floor" or goName ~= "ceiling" then
				return true
			end

			if goName == "boundsBox" then
				return true
			end

			return false
		end
	})

	return isBlocked
end

M.AlignWallPlacePoints = function(self, startPos, endPos)
	return gWallEditUtils:AlignWallPlacePoints(self, startPos, endPos)
end

M.GetWallEdgesByEdge = function(self, edgeA, edgeB, tagIndex)
	if not edgeA or not edgeB then
		return nil
	end

	local gridSystem = self.gridSystemProxy

	if not gridSystem or gCS.LuaUtils.IsNull(gridSystem) then
		return nil
	end

	local result = tagIndex == nil and gridSystem:GetWallEdgesForEditWithTagIndex(edgeA, edgeB, tagIndex) or gridSystem:GetWallEdgesForEdit(edgeA, edgeB)

	if not result or not result.NodeAList or result.NodeAList.Count < 0 then
		return nil
	end

	local edges = {}

	for i = 0, result.NodeAList.Count - 1 do
		edges[#edges + 1] = {
			a = result.NodeAList[i],
			b = result.NodeBList[i]
		}
	end

	return edges
end

M.PaintWallByWall = function(self, edgeA, edgeB, hitPositionWS, texID)
	if not edgeA or not edgeB or not hitPositionWS then
		return false
	end

	local gridSystem = self.gridSystemProxy

	if not gridSystem or gCS.LuaUtils.IsNull(gridSystem) then
		return false
	end

	local edgesPayload = tostring(edgeA) .. "_" .. tostring(edgeB)
	local result = gridSystem:UpdateWallEdgesMatWithDelta(edgesPayload, hitPositionWS, texID or self.brushTexID)

	if not result or not result.Success or not result.EdgesPayload or result.EdgesPayload ~= "" then
		return false
	end

	local undoCmd = {
		["K\\x85\\x87\\x8cO"] = "כ\\xe2&\\xe7\\xe6\\xaa\\xec\\x96# ",
		edgesPayload = result.EdgesPayload,
		texIDsPayload = result.BeforeMatIDsPayload,
		hitX = result.HitX,
		hitY = result.HitY,
		hitZ = result.HitZ
	}
	local redoCmd = {
		["K\\x85\\x87\\x8cO"] = "כ\\xe2&\\xe7\\xe6\\xaa\\xec\\x96# ",
		edgesPayload = result.EdgesPayload,
		texIDsPayload = result.AfterMatIDsPayload,
		hitX = result.HitX,
		hitY = result.HitY,
		hitZ = result.HitZ
	}

	return gWallOperationManager:CommitCommands("PaintWallBatch", gridSystem, undoCmd, redoCmd)
end

M.PaintWallByFullWall = function(self, edgeA, edgeB, hitPositionWS, texID, tagIndex)
	if not hitPositionWS then
		return false
	end

	local gridSystem = self.gridSystemProxy

	if not gridSystem or gCS.LuaUtils.IsNull(gridSystem) then
		return false
	end

	local edgeList = self.GetWallEdgesByEdge(self, edgeA, edgeB, tagIndex)

	if not edgeList or #edgeList < 0 then
		return false
	end

	local edgesPayload = gWallEditUtils:BuildEdgePayloadFromEdges(edgeList)

	if edgesPayload ~= "" then
		return false
	end

	local result = gridSystem:UpdateWallEdgesMatWithDelta(edgesPayload, hitPositionWS, texID or self.brushTexID)

	if not result or not result.Success or not result.EdgesPayload or result.EdgesPayload ~= "" then
		return false
	end

	local undoCmd = {
		["K\\x85\\x87\\x8cO"] = "כ\\xe2&\\xe7\\xe6\\xaa\\xec\\x96# ",
		edgesPayload = result.EdgesPayload,
		texIDsPayload = result.BeforeMatIDsPayload,
		hitX = result.HitX,
		hitY = result.HitY,
		hitZ = result.HitZ
	}
	local redoCmd = {
		["K\\x85\\x87\\x8cO"] = "כ\\xe2&\\xe7\\xe6\\xaa\\xec\\x96# ",
		edgesPayload = result.EdgesPayload,
		texIDsPayload = result.AfterMatIDsPayload,
		hitX = result.HitX,
		hitY = result.HitY,
		hitZ = result.HitZ
	}

	return gWallOperationManager:CommitCommands("PaintWallBatch", gridSystem, undoCmd, redoCmd)
end

M.PaintWallByRoomWithResult = function(self, hitPositionWS, texID, edgeA, edgeB, tagIndex)
	local gridSystem = self.gridSystemProxy

	if not gridSystem or gCS.LuaUtils.IsNull(gridSystem) or not hitPositionWS then
		return false
	end

	local brushTexID = texID or self.brushTexID
	local result = nil

	if edgeA and edgeB and gridSystem.IsEdgeInRoom then
		if gridSystem.IsEdgeInRoom(gridSystem, edgeA, edgeB) then
			result = gridSystem.UpdateRoomEdgesMatWithDelta(gridSystem, hitPositionWS, brushTexID)
		else
			local wallEdgesResult = tagIndex == nil and gridSystem:GetWallEdgesForEditWithTagIndex(edgeA, edgeB, tagIndex) or gridSystem:GetWallEdgesForEdit(edgeA, edgeB)

			if not wallEdgesResult or not wallEdgesResult.NodeAList or wallEdgesResult.NodeAList.Count < 0 then
				return false
			end

			local edgeList = {}

			for i = 0, wallEdgesResult.NodeAList.Count - 1 do
				edgeList[#edgeList + 1] = {
					a = wallEdgesResult.NodeAList[i],
					b = wallEdgesResult.NodeBList[i]
				}
			end

			local edgesPayload = gWallEditUtils:BuildEdgePayloadFromEdges(edgeList)

			if edgesPayload ~= "" then
				return false
			end

			result = gridSystem.UpdateStandaloneEdgesMatWithDelta(gridSystem, edgesPayload, hitPositionWS, brushTexID)
		end
	else
		result = gridSystem.UpdateRoomEdgesMatWithDelta(gridSystem, hitPositionWS, brushTexID)
	end

	if not result or not result.Success or not result.EdgesPayload or result.EdgesPayload ~= "" then
		return false
	end

	local undoCmd = {
		["K\\x85\\x87\\x8cO"] = "כ\\xe2&\\xe7\\xe6\\xaa\\xec\\x96# ",
		edgesPayload = result.EdgesPayload,
		texIDsPayload = result.BeforeMatIDsPayload,
		hitX = result.HitX,
		hitY = result.HitY,
		hitZ = result.HitZ
	}
	local redoCmd = {
		["K\\x85\\x87\\x8cO"] = "כ\\xe2&\\xe7\\xe6\\xaa\\xec\\x96# ",
		edgesPayload = result.EdgesPayload,
		texIDsPayload = result.AfterMatIDsPayload,
		hitX = result.HitX,
		hitY = result.HitY,
		hitZ = result.HitZ
	}

	return gWallOperationManager:CommitCommands("PaintWallBatch", gridSystem, undoCmd, redoCmd)
end

M.PaintSurfaceByObject = function(self, obj, hitPositionWS, texID)
	local x, y, z, isCeiling = gWallEditUtils:ParseFloorLocationFromObjectName(obj)

	if not x or not y or not z then
		return false, nil
	end

	local gridSystem = self.gridSystemProxy
	local paintTexID = texID or self.brushTexID
	local result = gridSystem:UpdateFloorMatWithDelta(x, y, z, hitPositionWS, paintTexID)

	if not result or not result.Success then
		return false, nil
	end

	local undoCmd = {
		["K\\x85\\x87\\x8cO"] = "_w\\xa5yX\\x81\\xe7Ul{}I",
		x = result.X,
		y = result.Y,
		z = result.Z,
		texIDA = result.BeforeMatIDA,
		texIDB = result.BeforeMatIDB
	}
	local redoCmd = {
		["K\\x85\\x87\\x8cO"] = "_w\\xa5yX\\x81\\xe7Ul{}I",
		x = result.X,
		y = result.Y,
		z = result.Z,
		texIDA = result.AfterMatIDA,
		texIDB = result.AfterMatIDB
	}
	local opType = isCeiling and "PaintCeiling" or "PaintFloor"

	return gWallOperationManager:CommitCommands(opType, gridSystem, undoCmd, redoCmd), isCeiling
end

M.PaintSurfaceRoomByHit = function(self, hitPositionWS, texIDA, texIDB, isCeiling)
	local gridSystem = self.gridSystemProxy

	if not gridSystem or gCS.LuaUtils.IsNull(gridSystem) or not hitPositionWS then
		return false
	end

	local paintTexIDA = texIDA or self.brushTexID
	local paintTexIDB = texIDB or paintTexIDA

	if isCeiling then
		hitPositionWS = Vector3.New(hitPositionWS.x, hitPositionWS.y - self.gridSystemProxy._floorHeight + 1, hitPositionWS.z)
	end

	local result = gridSystem.UpdateRoomFloorsMatWithDelta(gridSystem, hitPositionWS, paintTexIDA, paintTexIDB, isCeiling)

	if not result or not result.Success or not result.FloorsPayload or result.FloorsPayload ~= "" then
		return false
	end

	local undoCmd = {
		["K\\x85\\x87\\x8cO"] = "D\\xfd.\\xe2=:\\xd1g!\\xd6N\\xae\rV\\xc5\\xee",
		floorsPayload = result.FloorsPayload,
		texIDsPayloadA = result.BeforeMatIDsPayloadA,
		texIDsPayloadB = result.BeforeMatIDsPayloadB
	}
	local redoCmd = {
		["K\\x85\\x87\\x8cO"] = "D\\xfd.\\xe2=:\\xd1g!\\xd6N\\xae\rV\\xc5\\xee",
		floorsPayload = result.FloorsPayload,
		texIDsPayloadA = result.AfterMatIDsPayloadA,
		texIDsPayloadB = result.AfterMatIDsPayloadB
	}
	local opType = isCeiling and "PaintCeiling" or "PaintFloor"

	return gWallOperationManager:CommitCommands(opType, gridSystem, undoCmd, redoCmd)
end

M.DeleteWallByEdge = function(self, edgeA, edgeB)
	local gridSystem = self.gridSystemProxy

	if not edgeA or not edgeB then
		return false
	end

	local result = gridSystem.RemoveWallSegmentWithDelta(gridSystem, edgeA, edgeB)

	if not result or not result.Success or not result.RemovedEdgesPayload or result.RemovedEdgesPayload ~= "" then
		return false
	end

	local undoCmd = {
		["K\\x85\\x87\\x8cO"] = "Nr\\xa8@M\\xbe\\xfebn}{_",
		edgesPayload = result.RemovedEdgesPayload,
		addedNodesPayload = result.RemovedNodesPayload
	}
	local redoCmd = {
		["K\\x85\\x87\\x8cO"] = "/,\\xe1g\\x9d\\xc05\\xa4#\\xc3\\xf6\\xe1q\\xe8",
		edgesPayload = result.RemovedEdgesPayload,
		removedNodesPayload = result.RemovedNodesPayload,
		removedFenestrationsPayload = result.RemovedFenestrationsPayload
	}
	local startBuildIndex = gBuildOperationManager.currentIndex or 0
	local committed = gWallOperationManager:CommitCommands("DeleteWall", gridSystem, undoCmd, redoCmd)

	if committed then
		self._AutoStorageFurnitureOnDeletedWall(self, result.RemovedEdgesPayload, startBuildIndex)
	end

	return committed
end

M.DeleteSelectedWall = function(self)
	local data = self.selectedWallData
	local edges = data and data.edges

	if not edges or #edges < 0 then
		return false
	end

	local payload = gWallEditUtils:BuildEdgePayloadFromEdges(edges)

	if payload ~= "" then
		return false
	end

	local gridSystem = self.gridSystemProxy

	if not gridSystem or gCS.LuaUtils.IsNull(gridSystem) then
		return false
	end

	local result = gridSystem.DeleteWallEdgesWithDelta(gridSystem, payload)

	if not result or not result.Success or not result.RemovedEdgesPayload or result.RemovedEdgesPayload ~= "" then
		return false
	end

	local undoCmd = {
		["K\\x85\\x87\\x8cO"] = "Nr\\xa8@M\\xbe\\xfebn}{_",
		edgesPayload = result.RemovedEdgesPayload,
		addedNodesPayload = result.RemovedNodesPayload
	}
	local redoCmd = {
		["K\\x85\\x87\\x8cO"] = "/,\\xe1g\\x9d\\xc05\\xa4#\\xc3\\xf6\\xe1q\\xe8",
		edgesPayload = result.RemovedEdgesPayload,
		removedNodesPayload = result.RemovedNodesPayload,
		removedFenestrationsPayload = result.RemovedFenestrationsPayload
	}
	local startBuildIndex = gBuildOperationManager.currentIndex or 0
	local success = gWallOperationManager:CommitCommands("DeleteWall", gridSystem, undoCmd, redoCmd)

	if success then
		self._AutoStorageFurnitureOnDeletedWall(self, result.RemovedEdgesPayload, startBuildIndex)
		self.ClearSelectedWallState(self)
	end

	return success
end

M._AutoStorageFurnitureOnDeletedWall = function(self, removedEdgesPayload, startBuildIndex)
	if not gWallFurnitureBindingManager:IsActive() then
		return
	end

	local affectedUIDs = gWallFurnitureBindingManager:CollectFurnitureUIDsByEdgesPayload(removedEdgesPayload)

	if not affectedUIDs or #affectedUIDs ~= 0 then
		return
	end

	local recalledCount = 0

	for _, uid in ipairs(affectedUIDs) do
		if gWallFurnitureBindingManager:StorageFurnitureByUID(uid) then
			recalledCount = recalledCount + 1
		end
	end

	local endBuildIndex = gBuildOperationManager.currentIndex or 0

	if endBuildIndex <= startBuildIndex + 1 then
		gBuildOperationManager:CollapseHistoryRangeToBatch(startBuildIndex + 1, endBuildIndex, "DeleteWallWithFurniture")
	end

	if recalledCount <= 0 then
		gDisplayMessageMgr:ShowMessageContentDebug(string.format("已回收%d件家具temp", recalledCount))
	end
end

M.SelectWallByPayloadFirstEdge = function(self, edgesPayload)
	if not edgesPayload or edgesPayload ~= "" then
		return false
	end

	local edgeA, edgeB = gWallEditUtils:ParseFirstEdgeFromPayload(edgesPayload)

	if not edgeA or not edgeB then
		return false
	end

	return self.SelectWallByEdge(self, edgeA, edgeB)
end

M.PlaceFenestrationAt = function(self, hitPositionWS, prefabID, fenestrationType, rayDirectionWS, edge)
	if self.wallPreviewFenestrationCanPlace ~= false then
		return false
	end

	local gridSystem = self.gridSystemProxy
	local rayDir = rayDirectionWS or Vector3.zero
	local edgeA = edge and edge[1] or 0
	local edgeB = edge and edge[2] or 0
	local result = gridSystem:PlaceFenestrationWithDelta(hitPositionWS, rayDir, edgeA, edgeB, prefabID or self.fenestrationPrefabID, fenestrationType or self.fenestrationType)

	if not result or not result.Success then
		return false
	end

	local undoCmd = gWallEditUtils:BuildDeleteFenestrationCmd(result)
	local redoCmd = gWallEditUtils:BuildPlaceFenestrationCmd(result)

	return gWallOperationManager:CommitCommands("PlaceFenestration", gridSystem, undoCmd, redoCmd)
end

M.PlaceFenestrationNoHistory = function(self, hitPositionWS, prefabID, fenestrationType, rayDirectionWS, edge)
	local gridSystem = self.gridSystemProxy

	if not gridSystem or gCS.LuaUtils.IsNull(gridSystem) or not hitPositionWS then
		return nil
	end

	local rayDir = rayDirectionWS or Vector3.zero
	local edgeA = edge and edge[1] or 0
	local edgeB = edge and edge[2] or 0
	local result = gridSystem:PlaceFenestrationWithDelta(hitPositionWS, rayDir, edgeA, edgeB, prefabID or self.fenestrationPrefabID, fenestrationType or self.fenestrationType)

	if not result or not result.Success then
		return nil
	end

	gridSystem:RenderEdges()

	return gWallEditUtils:BuildPlaceFenestrationCmd(result)
end

M.TakeFenestrationForPreview = function(self, edgeA, edgeB, runtimeID)
	local gridSystem = self.gridSystemProxy

	if not gridSystem or gCS.LuaUtils.IsNull(gridSystem) then
		return nil
	end

	if not edgeA or not edgeB or not runtimeID then
		return nil
	end

	local removedResult = gridSystem.RemoveFenestrationWithDelta(gridSystem, edgeA, edgeB, runtimeID)

	if not removedResult or not removedResult.Success then
		return nil
	end

	gridSystem:RenderEdges()

	return gWallEditUtils:BuildPlaceFenestrationCmd(removedResult)
end

M.CommitFenestrationDeleteByPlaceCmd = function(self, placeCmd)
	local gridSystem = self.gridSystemProxy

	if not gridSystem or gCS.LuaUtils.IsNull(gridSystem) or not placeCmd then
		return false
	end

	local undoCmd = {
		["K\\x85\\x87\\x8cO"] = "D\\xf0&\\xef,*\\xcdd3\\xc1Y\\x8dK\\xc9\\xe8",
		edgeA = placeCmd.edgeA,
		edgeB = placeCmd.edgeB,
		runtimeID = placeCmd.runtimeID,
		prefabID = placeCmd.prefabID,
		fenestrationType = placeCmd.fenestrationType,
		centerX = placeCmd.centerX,
		centerY = placeCmd.centerY,
		centerZ = placeCmd.centerZ,
		dirX = placeCmd.dirX,
		dirY = placeCmd.dirY,
		dirZ = placeCmd.dirZ
	}
	local redoCmd = {
		["K\\x85\\x87\\x8cO"] = "\"?\\x9c迢Σ\\xb4\\x8d\\xce\\xf6 ǎ)\\x90\\xec",
		edgeA = placeCmd.edgeA,
		edgeB = placeCmd.edgeB,
		runtimeID = placeCmd.runtimeID,
		placeID = placeCmd.placeID
	}

	return gWallOperationManager:CommitCommands("DeleteFenestration", gridSystem, undoCmd, redoCmd)
end

M.DeleteFenestrationByData = function(self, edgeA, edgeB, runtimeID)
	local gridSystem = self.gridSystemProxy

	if not gridSystem or gCS.LuaUtils.IsNull(gridSystem) then
		return false
	end

	if not edgeA or not edgeB or not runtimeID then
		return false
	end

	local result = gridSystem.RemoveFenestrationWithDelta(gridSystem, edgeA, edgeB, runtimeID)

	if not result or not result.Success then
		return false
	end

	local undoCmd = gWallEditUtils:BuildPlaceFenestrationCmd(result)
	local redoCmd = gWallEditUtils:BuildDeleteFenestrationCmd(result)

	return gWallOperationManager:CommitCommands("DeleteFenestration", gridSystem, undoCmd, redoCmd)
end

M.ApplyFenestrationPlaceCmdNoHistory = function(self, placeCmd)
	local gridSystem = self.gridSystemProxy

	if not placeCmd or not gridSystem or gCS.LuaUtils.IsNull(gridSystem) then
		return false
	end

	local center = Vector3.New(placeCmd.centerX, placeCmd.centerY, placeCmd.centerZ)
	local direction = Vector3.New(placeCmd.dirX, placeCmd.dirY, placeCmd.dirZ)
	local success = gridSystem.PlaceFenestrationByData(gridSystem, placeCmd.edgeA, placeCmd.edgeB, center, direction, placeCmd.prefabID, placeCmd.fenestrationType, placeCmd.runtimeID)

	if success then
		gridSystem.RenderEdges(gridSystem)
	end

	return success
end

M.ApplyFenestrationDeleteCmdNoHistory = function(self, deleteCmd)
	local gridSystem = self.gridSystemProxy

	if not deleteCmd or not gridSystem or gCS.LuaUtils.IsNull(gridSystem) then
		return false
	end

	local success = gridSystem.DeleteFenestrationByData(gridSystem, deleteCmd.edgeA, deleteCmd.edgeB, deleteCmd.runtimeID)

	if success then
		gridSystem.RenderEdges(gridSystem)
	end

	return success
end

M.MoveFenestrationNoHistory = function(self, edgeA, edgeB, runtimeID, hitPositionWS, prefabID, fenestrationType)
	local gridSystem = self.gridSystemProxy

	if not gridSystem or gCS.LuaUtils.IsNull(gridSystem) or not edgeA or not edgeB or not runtimeID or not hitPositionWS then
		return nil, 
	end

	local removedResult = gridSystem.RemoveFenestrationWithDelta(gridSystem, edgeA, edgeB, runtimeID)

	if not removedResult or not removedResult.Success then
		return nil, 
	end

	local targetPrefabID = prefabID or removedResult.PrefabID
	local targetType = fenestrationType or removedResult.FenestrationType
	local rayDir = Vector3.zero
	local placedResult = gridSystem:PlaceFenestrationWithDelta(hitPositionWS, rayDir, 0, 0, targetPrefabID, targetType)

	if not placedResult or not placedResult.Success then
		self:ApplyFenestrationPlaceCmdNoHistory(gWallEditUtils:BuildPlaceFenestrationCmd(removedResult))

		return nil, 
	end

	gridSystem:RenderEdges()

	return gWallEditUtils:BuildPlaceFenestrationCmd(removedResult), gWallEditUtils:BuildPlaceFenestrationCmd(placedResult)
end

M.CommitFenestrationMove = function(self, startPlaceCmd, finalPlaceCmd)
	local gridSystem = self.gridSystemProxy

	if not gridSystem or gCS.LuaUtils.IsNull(gridSystem) or not startPlaceCmd or not finalPlaceCmd then
		return false
	end

	local undoCmd, redoCmd = gWallEditUtils:BuildMoveFenestrationHistoryCmds(startPlaceCmd, finalPlaceCmd)

	return gWallOperationManager:CommitCommands("MoveFenestration", gridSystem, undoCmd, redoCmd)
end

M.CollectAllFenestrationInfos = function(self, gridSystem, includeExternalWall)
	gridSystem = gridSystem or self.gridSystemProxy
	local infos = {}

	if not gridSystem or gCS.LuaUtils.IsNull(gridSystem) then
		return infos
	end

	local rootTransform = gridSystem.fenestrationsTransform

	if not rootTransform or gCS.LuaUtils.IsNull(rootTransform) then
		return infos
	end

	local visited = {}

	for i = 0, rootTransform.childCount - 1 do
		local child = rootTransform.GetChild(rootTransform, i)

		if child and not gCS.LuaUtils.IsNull(child) then
			local go = child.gameObject
			local info = self.GetFenestrationHitInfo(self, go)

			if info and info.edgeA and info.edgeB and info.runtimeID then
				local key = string.format("%s_%s_%s", tostring(info.edgeA), tostring(info.edgeB), tostring(info.runtimeID))

				if not visited[key] and (includeExternalWall or not info.isExternalWall) then
					visited[key] = true
					infos[#infos + 1] = info
				end
			end
		end
	end

	return infos
end

M.StorageAllFenestrationFurniture = function(self)
	local gridSystem = self.gridSystemProxy

	if not gridSystem or gCS.LuaUtils.IsNull(gridSystem) then
		return 0, 0
	end

	local infos = self.CollectAllFenestrationInfos(self, gridSystem, false)
	local removedCount = 0

	for _, info in ipairs(infos) do
		if self.DeleteFenestrationByData(self, info.edgeA, info.edgeB, info.runtimeID) then
			removedCount = removedCount + 1
		else
			print_warn(string.format("WallEditManager: failed to storage fenestration, edgeA=%s edgeB=%s runtimeID=%s", tostring(info.edgeA), tostring(info.edgeB), tostring(info.runtimeID)))
		end
	end

	return removedCount, #infos
end

gWallEditManager = M.New()
