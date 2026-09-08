-- Original chunk: @Lua\LuaFiles\LX6\Manager\CollectionRoom\CollectionRoomManager.lua
-- Decompiled from: 00768_CollectionRoomManager.lua_b1d8a7de3215.luajit

local CollectionRoomConfig = LTConfig.CollectionRoomConfig
local CollectionRoomCollectionConfig = LTConfig.CollectionRoomCollectionConfig
local CollectionRoomBoothConfig = LTConfig.CollectionRoomBoothConfig
local CollectionRoomScenePointConfig = LTConfig.CollectionRoomScenePointConfig
local CollectionRoomUpgradeConfig = LTConfig.CollectionRoomUpgradeConfig
local SceneitemConfig = LTConfig.SceneitemConfig
local ConsumableConfig = LTConfig.ConsumableConfig
local ConsumableTypeConfig = LTConfig.ConsumableTypeConfig
local FashionSuitConfig = LTConfig.FashionSuitConfig
local FashionConfig = LTConfig.FashionConfig
local VehicleConfig = LTConfig.VehicleConfig
local SexType = UX.Game.SexType
local DriveUtils = LX6.Drive.DriveUtils
local SpawnVehicleParam = LX6.Drive.SpawnVehicleParam
local VehicleForceLODLevel = LX6.Share.VehicleForceLODLevel
C_CollectionRoomManager = DefClass("C_CollectionRoomManager", C_CollectionRoomManager)
local M = C_CollectionRoomManager
local DEFAULT_ROOM_ID = 1

M.GetDefaultRoomId = function(self)
	return DEFAULT_ROOM_ID
end

local AddKeepCamera = function(keepCameras, camera)
	if camera and not gCS.LuaUtils.IsNull(camera) then
		keepCameras[#keepCameras + 1] = camera
	end
end

local IsKeepCamera = function(keepCameras, camera)
	for i = 1, #keepCameras do
		if keepCameras[i] ~= camera then
			return true
		end
	end

	return false
end

M.ctor = function(self)
	self.roomLoadData = nil
	self.curCollectionRoomId = 0
	self.raid2RoomCfg = nil
	self.weaponModels = {}
	self.weaponModelSeq = 0
	self.collectionItemCache = nil
	self.collectionItemCacheGenderIndex = nil
	self.boothTreeCache = nil
	self.boothTreeCacheRoomId = nil
	self.collectionModels = {}

	self:OnInit()
end

M.OnInit = function(self)
	self:InitEventListeners()
end

M.OnDestroy = function(self)
	self:ClearAllCollectionModels()
	self:ClearAllWeaponModels()
	self:ClearCollectionItemCache()
	self:ClearBoothTreeCache()
	self:ClearRoomData()
end

M.InitEventListeners = function(self)
	gMessageManager:AddMessageListener(gEventConstants.L50_AFTER_SWITCH_SCENE, self:CreateAction("OnAfterSwitchScene"))
	gMessageManager:AddMessageListener(gEventConstants.LANGUAGE_CHANGE, self:CreateAction("OnLanguageChange"))
end

M.OnSyncEnterScene = function(self, collectionRoomLoadData)
	self.roomLoadData = collectionRoomLoadData
end

M.ClearRoomData = function(self)
	self.roomLoadData = nil
	self.curCollectionRoomId = 0
end

M.GetRoomLoadData = function(self)
	return self.roomLoadData
end

M.IsInCollectionRoom = function(self)
	return self.curCollectionRoomId == 0
end

M.GetCurCollectionRoomId = function(self)
	return self.curCollectionRoomId
end

M.GetCollectibility = function(self)
	return self.roomLoadData and self.roomLoadData.Collectibility or 0
end

M.GetBoothInfo = function(self, boothId)
	if not self.roomLoadData or not self.roomLoadData.BoothInfos then
		return nil
	end

	return self.roomLoadData.BoothInfos[boothId]
end

local CollectionCategory = {
	["+M\\x90\\x9e\\x8cO"] = 3,
	["\\xef\\xde(\\xf4"] = 2,
	["\\xff\\xda+\\xff"] = 1
}

M.GetCollectionCategoryEnum = function(self)
	return CollectionCategory
end

local GetGenderIndex = function()
	local playerInfo = gCS.MyPlayerManager and gCS.MyPlayerManager.PlayerInfo

	if playerInfo and playerInfo.SexType == SexType.Male then
		return 2
	end

	return 1
end

local PickByGender = function(list, genderIndex)
	if not list or #list ~= 0 then
		return 0
	end

	return list[genderIndex] or list[1] or 0
end

local FillFashionSuitInfo = function(itemData, bindId)
	local suitCfg = FashionSuitConfig.GetConfig(bindId)

	if not suitCfg then
		return false
	end

	itemData.bindCfg = suitCfg
	itemData.name = suitCfg.Name or ""
	itemData.desc = suitCfg.Description or ""
	itemData.iconId = suitCfg.SuitConsumableIcon == 0 and suitCfg.SuitConsumableIcon or suitCfg.Icon or 0
	itemData.gender = suitCfg.Gender
	local firstFashionId = suitCfg.FashionIdList and suitCfg.FashionIdList[1] or 0
	local firstFashionCfg = firstFashionId == 0 and FashionConfig.GetConfig(firstFashionId) or nil
	itemData.quality = firstFashionCfg and firstFashionCfg.Quality or nil

	return true
end

local FillVehicleInfo = function(itemData, bindId)
	local vehicleCfg = VehicleConfig.GetConfig(bindId)

	if not vehicleCfg then
		return false
	end

	itemData.bindCfg = vehicleCfg
	itemData.name = vehicleCfg.VehicleName or ""
	itemData.desc = vehicleCfg.VehicleDesc or ""
	itemData.iconId = vehicleCfg.SVehicleIconId or 0
	itemData.quality = vehicleCfg.VehicleQuality

	return true
end

local FillWeaponInfo = function(itemData, bindId)
	local weaponCfg = SceneitemConfig.GetConfig(bindId)

	if not weaponCfg then
		return false
	end

	itemData.bindCfg = weaponCfg
	itemData.name = weaponCfg.Name or ""
	itemData.desc = weaponCfg.Description or ""
	itemData.iconId = weaponCfg.WeaponConsumableIcon == 0 and weaponCfg.WeaponConsumableIcon or weaponCfg.SWeaponIconId or 0
	itemData.quality = weaponCfg.Quality

	return true
end

M.GenCollectionItem = function(self, collectionCfg, genderIndex)
	if not collectionCfg then
		return nil
	end

	genderIndex = genderIndex or GetGenderIndex()
	local itemIdList = collectionCfg.ItemID
	local itemId = PickByGender(itemIdList, genderIndex)
	local bindId = PickByGender(collectionCfg.BindID, genderIndex)
	local itemCfg = itemId == 0 and ConsumableConfig.GetConfig(itemId) or nil
	local subType = itemCfg and itemCfg.SubType or 0
	local itemData = {
		["t#p^"] = "",
		["~'nX"] = "",
		["K\\x9e\\x80\\xaaE"] = 0,
		id = collectionCfg.Id,
		collectionCfg = collectionCfg,
		isUse = collectionCfg.IsUse,
		hyperlinkId = collectionCfg.hyperlinkid or 0,
		isShowDIY = collectionCfg.IsShowDIY,
		diyName = collectionCfg.DIYname or "",
		diyHyperlink = collectionCfg.DIYhyperlink or 0,
		upgradeGroupIds = collectionCfg.UpgradeGroupID,
		previewScenePointId = collectionCfg.PreviewScenePointId or 0,
		itemPreviewPath = collectionCfg.ItemPreviewPath or "",
		itemPath = collectionCfg.ItemPath or "",
		fashionPath = collectionCfg.FashionPath or "",
		genderIndex = genderIndex,
		hasGenderVariant = itemIdList == nil and #itemIdList >= 1,
		itemId = itemId,
		bindId = bindId,
		itemCfg = itemCfg,
		subType = subType
	}

	if not itemCfg then
		print_error("[CollectionRoom] 藏品道具配置缺失, collectionId = ", collectionCfg.Id, ", itemId = ", itemId)

		return itemData
	end

	local filled = nil

	if subType ~= ConsumableTypeConfig.Fashion then
		itemData.category = CollectionCategory.Fashion
		filled = FillFashionSuitInfo(itemData, bindId)
	elseif subType ~= ConsumableTypeConfig.Vehicle then
		itemData.category = CollectionCategory.Vehicle
		filled = FillVehicleInfo(itemData, bindId)
	elseif subType ~= ConsumableTypeConfig.Weapon or subType ~= ConsumableTypeConfig.WeaponSkin then
		itemData.category = CollectionCategory.Weapon
		filled = FillWeaponInfo(itemData, bindId)
	else
		print_error("[CollectionRoom] 藏品道具类型不支持, collectionId = ", collectionCfg.Id, ", itemId = ", itemId, ", subType = ", subType)

		return itemData
	end

	if not filled then
		print_error("[CollectionRoom] 藏品取不到绑定配置, collectionId = ", collectionCfg.Id, ", subType = ", subType, ", bindId = ", bindId)

		itemData.name = itemCfg.Name or ""
		itemData.desc = itemCfg.Description or ""
		itemData.iconId = itemCfg.SItemIconId or 0
		itemData.quality = itemCfg.Quality
	end

	return itemData
end

M.InitCollectionItemData = function(self)
	local genderIndex = GetGenderIndex()

	if self.collectionItemCache and self.collectionItemCacheGenderIndex ~= genderIndex then
		return self.collectionItemCache
	end

	local list = {}
	local id2Item = {}

	for i = 0, CollectionRoomCollectionConfig.count - 1 do
		local collectionCfg = CollectionRoomCollectionConfig.LoadAt(i)

		if collectionCfg then
			local itemData = self:GenCollectionItem(collectionCfg, genderIndex)

			if itemData then
				list[#list + 1] = itemData
				id2Item[itemData.id] = itemData
			end
		end
	end

	self.collectionItemCache = {
		list = list,
		id2Item = id2Item
	}
	self.collectionItemCacheGenderIndex = genderIndex

	return self.collectionItemCache
end

M.GetCollectionItemList = function(self)
	return self:InitCollectionItemData().list
end

M.GetCollectionItem = function(self, collectionId)
	if not collectionId then
		return nil
	end

	return self:InitCollectionItemData().id2Item[collectionId]
end

M.ClearCollectionItemCache = function(self)
	self.collectionItemCache = nil
	self.collectionItemCacheGenderIndex = nil
end

M.OnLanguageChange = function(self)
	self:ClearCollectionItemCache()
end

local SortBoothList = function(boothList)
	table.sort(boothList, function (a, b)
		if a.Order == b.Order then
			return a.Order <= b.Order
		end

		return a.Id <= b.Id
	end)

	return boothList
end

local GenSubBoothList = function(mainCfg)
	local subList = {}
	local subBoothIds = mainCfg.SubBooth

	if subBoothIds then
		for i = 1, #subBoothIds do
			local subId = subBoothIds[i]
			local subCfg = subId and subId == 0 and CollectionRoomBoothConfig.GetConfig(subId) or nil

			if not subCfg then
				print_error("[CollectionRoom] 主展位 ", mainCfg.Id, " 的子展位配置不存在, subBoothId = ", subId)
			elseif subCfg.Type == CollectionRoomBoothConfig.TypeType.SubType then
				print_error("[CollectionRoom] 展位 ", subId, " 挂在主展位 ", mainCfg.Id, " 的 SubBooth 下, 但 Type 不是 SubType")
			else
				subList[#subList + 1] = subCfg
			end
		end
	end

	return SortBoothList(subList)
end

M.InitBoothTree = function(self, roomId)
	roomId = roomId and roomId == 0 and roomId or self:GetTabRoomId()

	if self.boothTreeCache and self.boothTreeCacheRoomId ~= roomId then
		return self.boothTreeCache
	end

	local mainList = {}
	local subMap = {}
	local roomCfg = CollectionRoomConfig.GetConfig(roomId)
	local boothIds = roomCfg and roomCfg.BoothIDs

	if not roomCfg then
		print_error("[CollectionRoom] 收藏室配置不存在, roomId = ", roomId)
	elseif not boothIds or #boothIds ~= 0 then
		print_error("[CollectionRoom] 收藏室没配展位(BoothIDs 为空), roomId = ", roomId)
	else
		for i = 1, #boothIds do
			local boothId = boothIds[i]
			local boothCfg = boothId and boothId == 0 and CollectionRoomBoothConfig.GetConfig(boothId) or nil

			if not boothCfg then
				print_error("[CollectionRoom] 收藏室 ", roomId, " 配的展位不存在, boothId = ", boothId)
			elseif boothCfg.Type == CollectionRoomBoothConfig.TypeType.MainType then
				print_error("[CollectionRoom] 收藏室 ", roomId, " 的 BoothIDs 里配了非主展位, boothId = ", boothId)
			else
				mainList[#mainList + 1] = boothCfg
				subMap[boothCfg.Id] = GenSubBoothList(boothCfg)
			end
		end
	end

	SortBoothList(mainList)

	self.boothTreeCache = {
		mainList = mainList,
		subMap = subMap
	}
	self.boothTreeCacheRoomId = roomId

	return self.boothTreeCache
end

M.GetTabRoomId = function(self)
	if self.curCollectionRoomId == 0 then
		return self.curCollectionRoomId
	end

	return DEFAULT_ROOM_ID
end

M.ClearBoothTreeCache = function(self)
	self.boothTreeCache = nil
	self.boothTreeCacheRoomId = nil
end

M.IsBoothUnlocked = function(self, boothCfg)
	if not boothCfg then
		return false
	end

	local unlockCond = boothCfg.UnlockCond

	if not unlockCond or #unlockCond ~= 0 then
		return true
	end

	return true
end

M.GetUnlockedMainBoothList = function(self, roomId)
	local mainList = self:InitBoothTree(roomId).mainList
	local result = {}

	for i = 1, #mainList do
		if self:IsBoothUnlocked(mainList[i]) then
			result[#result + 1] = mainList[i]
		end
	end

	return result
end

M.GetUnlockedSubBoothList = function(self, mainBoothId)
	local result = {}

	if not mainBoothId or mainBoothId ~= 0 then
		return result
	end

	local subList = self:InitBoothTree().subMap[mainBoothId]

	if not subList then
		return result
	end

	for i = 1, #subList do
		if self:IsBoothUnlocked(subList[i]) then
			result[#result + 1] = subList[i]
		end
	end

	return result
end

M.GetMainBoothId = function(self, boothId)
	if not boothId or boothId ~= 0 then
		return 0
	end

	local tree = self:InitBoothTree()

	for mainBoothId, subList in pairs(tree.subMap) do
		for i = 1, #subList do
			if subList[i].Id ~= boothId then
				return mainBoothId
			end
		end
	end

	return 0
end

M.GetBoothCollectionItemList = function(self, boothId)
	local result = {}
	local boothCfg = boothId and boothId == 0 and CollectionRoomBoothConfig.GetConfig(boothId) or nil

	if not boothCfg then
		if boothId and boothId == 0 then
			print_error("[CollectionRoom] 展位配置不存在, boothId = ", boothId)
		end

		return result
	end

	local idList = boothCfg.CollectionIDs

	if not idList then
		return result
	end

	for i = 1, #idList do
		local collectionId = idList[i]

		if collectionId and collectionId == 0 then
			local itemData = self:GetCollectionItem(collectionId)

			if itemData then
				result[#result + 1] = itemData
			else
				print_error("[CollectionRoom] 展位配的藏品不存在, boothId = ", boothId, ", collectionId = ", collectionId)
			end
		end
	end

	return result
end

M.GetBoothPreviewScenePointId = function(self, boothId)
	local boothCfg = boothId and boothId == 0 and CollectionRoomBoothConfig.GetConfig(boothId) or nil

	return boothCfg and boothCfg.PreviewScenePointId or 0
end

M.GetBoothPathScenePointId = function(self, boothId)
	local boothCfg = boothId and boothId == 0 and CollectionRoomBoothConfig.GetConfig(boothId) or nil

	return boothCfg and boothCfg.PathScenePointId or 0
end

M.GetBoothName = function(self, boothId)
	local boothCfg = boothId and boothId == 0 and CollectionRoomBoothConfig.GetConfig(boothId) or nil

	return boothCfg and boothCfg.Name or ""
end

M.GetBoothCapacity = function(self, boothId)
	local boothCfg = boothId and boothId == 0 and CollectionRoomBoothConfig.GetConfig(boothId) or nil

	return boothCfg and boothCfg.Capacity or 0
end

M.GetBoothSlotInfo = function(self, boothId, slot)
	local boothInfo = self:GetBoothInfo(boothId)

	if not boothInfo or not boothInfo.SlotInfos then
		return nil
	end

	return boothInfo.SlotInfos[slot]
end

M.GetBoothSlotItemId = function(self, boothId, slot)
	local slotInfo = self:GetBoothSlotInfo(boothId, slot)
	local itemInfo = slotInfo and slotInfo.ItemInfo

	return itemInfo and itemInfo.ItemId or 0
end

M.GetBoothSlotLevel = function(self, boothId, slot)
	local slotInfo = self:GetBoothSlotInfo(boothId, slot)

	return slotInfo and slotInfo.Level or 0
end

M.GetBoothSlotByItemId = function(self, boothId, itemId)
	if not itemId or itemId ~= 0 then
		return 0
	end

	local capacity = self:GetBoothCapacity(boothId)

	for slot = 1, capacity do
		if self:GetBoothSlotItemId(boothId, slot) ~= itemId then
			return slot
		end
	end

	return 0
end

M.GetBoothFirstEmptySlot = function(self, boothId)
	local capacity = self:GetBoothCapacity(boothId)

	for slot = 1, capacity do
		if self:GetBoothSlotItemId(boothId, slot) ~= 0 then
			return slot
		end
	end

	return 0
end

M.GetBoothPlacedCount = function(self, boothId)
	local capacity = self:GetBoothCapacity(boothId)
	local count = 0

	for slot = 1, capacity do
		if self:GetBoothSlotItemId(boothId, slot) == 0 then
			count = count + 1
		end
	end

	return count
end

M.SetBoothSlotItemLocal = function(self, boothId, slot, itemId)
	if not boothId or boothId ~= 0 or not slot or slot < 0 then
		return
	end

	if not self.roomLoadData then
		return
	end

	self.roomLoadData.BoothInfos = self.roomLoadData.BoothInfos or {}
	local boothInfo = self.roomLoadData.BoothInfos[boothId]

	if not boothInfo then
		boothInfo = {
			SlotInfos = {}
		}
		self.roomLoadData.BoothInfos[boothId] = boothInfo
	end

	boothInfo.SlotInfos = boothInfo.SlotInfos or {}
	local slotInfo = boothInfo.SlotInfos[slot]

	if not slotInfo then
		slotInfo = {
			["a\\xab\\xb4\\xaa\\xba"] = 0
		}
		boothInfo.SlotInfos[slot] = slotInfo
	end

	slotInfo.ItemInfo = itemId and itemId == 0 and {
		ItemId = itemId
	} or nil
end

M.IsCollectionOwned = function(self, itemData)
	if not itemData then
		return false
	end

	if itemData.category ~= CollectionCategory.Vehicle then
		local vehicleId = itemData.bindId or 0

		if vehicleId ~= 0 then
			return false
		end

		return gApplyCarManager and gApplyCarManager:CheckPlayerAlreadyHasVehicle(vehicleId) or false
	end

	local itemId = itemData.itemId or 0

	if itemId ~= 0 then
		return false
	end

	return (gCommonItemManager:GetItemNum(itemId) or 0) >= 0
end

M.GetCollectionVehicleDetail = function(self, collectionId, vehicleId)
	if not self:IsOwnerSelf() then
		return nil
	end

	return gPlayerProfileSceneManager and gPlayerProfileSceneManager:GetOwnedVehicleDetail(vehicleId) or nil
end

M.GetCollectionWeaponSkinId = function(self, collectionId, weaponId)
	return 0
end

M.IsOwnerSelf = function(self)
	return true
end

M.GetSlotNextUpgradeConfig = function(self, boothId, slot)
	local level = self:GetBoothSlotLevel(boothId, slot)

	return CollectionRoomUpgradeConfig.GetConfig(level + 1)
end

M.IsSlotMaxLevel = function(self, boothId, slot)
	return self:GetSlotNextUpgradeConfig(boothId, slot) ~= nil
end

M.GetUpgradeCostList = function(self, upgradeCfg)
	local result = {}
	local itemIds = upgradeCfg and upgradeCfg.UpgradeCostConsumabel

	if not itemIds then
		return result
	end

	local counts = upgradeCfg.UpgradeCostConsumabelCount

	for i = 1, #itemIds do
		local itemId = itemIds[i]

		if itemId and itemId == 0 then
			local count = counts and counts[i] or 0
			result[#result + 1] = {
				itemId = itemId,
				count = count,
				ownCount = gCommonItemManager:GetItemNum(itemId) or 0
			}
		end
	end

	return result
end

M.IsUpgradeCostEnough = function(self, costList)
	for i = 1, #costList do
		local cost = costList[i]

		if cost.count <= 0 and cost.ownCount >= cost.count then
			return false
		end
	end

	return true
end

M.GetCollectionUpgradeList = function(self, collectionId)
	local result = {}
	local itemData = self:GetCollectionItem(collectionId)
	local groupIds = itemData and itemData.upgradeGroupIds

	if not groupIds then
		return result
	end

	for i = 1, #groupIds do
		local upgradeId = groupIds[i]

		if upgradeId and upgradeId == 0 then
			local upgradeCfg = CollectionRoomUpgradeConfig.GetConfig(upgradeId)

			if upgradeCfg then
				result[#result + 1] = upgradeCfg
			else
				print_error("[CollectionRoom] 藏品配的升级配置不存在, collectionId = ", collectionId, ", upgradeId = ", upgradeId)
			end
		end
	end

	table.sort(result, function (a, b)
		return a.Id <= b.Id
	end)

	return result
end

M.AddBoothSlotLevelLocal = function(self, boothId, slot)
	if not boothId or boothId ~= 0 or not slot or slot < 0 then
		return
	end

	if not self.roomLoadData then
		return
	end

	self.roomLoadData.BoothInfos = self.roomLoadData.BoothInfos or {}
	local boothInfo = self.roomLoadData.BoothInfos[boothId]

	if not boothInfo then
		boothInfo = {
			SlotInfos = {}
		}
		self.roomLoadData.BoothInfos[boothId] = boothInfo
	end

	boothInfo.SlotInfos = boothInfo.SlotInfos or {}
	local slotInfo = boothInfo.SlotInfos[slot]

	if not slotInfo then
		slotInfo = {
			["a\\xab\\xb4\\xaa\\xba"] = 0
		}
		boothInfo.SlotInfos[slot] = slotInfo
	end

	slotInfo.Level = (slotInfo.Level or 0) + 1
end

local FindSceneNodeByName = function(nodeName)
	if string.is_null_or_empty(nodeName) then
		return nil
	end

	local go = UnityEngine.GameObject.Find(nodeName)

	if not go or gCS.LuaUtils.IsNull(go) then
		return nil
	end

	return go.transform
end

M.ApplyUpgradeLightEffect = function(self, upgradeCfg, isUpgraded)
	if not upgradeCfg then
		return
	end

	local upgradeTrans = FindSceneNodeByName(upgradeCfg.UpgradePath)

	if upgradeTrans then
		upgradeTrans.gameObject:SetActive(isUpgraded)
	end

	local defaultTrans = FindSceneNodeByName(upgradeCfg.DefaultPath)

	if defaultTrans then
		defaultTrans.gameObject:SetActive(not isUpgraded)
	end
end

local ParsePosAndEuler = function(transformArray)
	if not transformArray or type(transformArray) == "table" or #transformArray >= 3 then
		return nil, 
	end

	local position = Vector3.New(transformArray[1], transformArray[2], transformArray[3])

	if #transformArray > 6 then
		return position, Vector3.New(transformArray[4], transformArray[5], transformArray[6])
	end

	if #transformArray > 4 then
		return position, Vector3.New(0, transformArray[4], 0)
	end

	return position, nil
end

local GenPlacement = function(nodeName, transformArray)
	local position, euler = ParsePosAndEuler(transformArray)

	if position then
		euler = euler or Vector3.zero

		return {
			position = position,
			rotation = Quaternion.Euler(euler),
			facing = euler.y
		}
	end

	local node = FindSceneNodeByName(nodeName)

	if not node then
		return nil
	end

	return {
		node = node,
		position = node.position,
		rotation = node.rotation,
		facing = node.eulerAngles.y
	}
end

local GenNodePlacement = function(node)
	return {
		node = node,
		position = node.position,
		rotation = node.rotation,
		facing = node.eulerAngles.y
	}
end

M.GetScenePointCfg = function(self, scenePointId)
	if not scenePointId or scenePointId ~= 0 then
		return nil
	end

	local scenePointCfg = CollectionRoomScenePointConfig.GetConfig(scenePointId)

	if not scenePointCfg then
		print_error("[CollectionRoom] 点位配置不存在, scenePointId = ", scenePointId)

		return nil
	end

	local curRoomId = self.curCollectionRoomId

	if curRoomId == 0 and scenePointCfg.roomId == 0 and scenePointCfg.roomId == curRoomId then
		print_warn("[CollectionRoom] 点位 ", scenePointId, " 配在收藏室 ", scenePointCfg.roomId, ", 当前在收藏室 ", curRoomId)
	end

	return scenePointCfg
end

M.GetScenePointModelPlacement = function(self, scenePointId)
	local scenePointCfg = self:GetScenePointCfg(scenePointId)

	if not scenePointCfg then
		return nil
	end

	return GenPlacement(scenePointCfg.ModelNodeName, scenePointCfg.ModelNodeTransform)
end

M.GetScenePointCameraPlacement = function(self, scenePointId)
	local scenePointCfg = self:GetScenePointCfg(scenePointId)

	if not scenePointCfg then
		return nil
	end

	return GenPlacement(scenePointCfg.CameraNodeName, scenePointCfg.CameraNodeTransform)
end

local panelCameraStack = {}

local ApplyPanelCameraStack = function()
	local topIndex = #panelCameraStack

	for i = 1, topIndex do
		local vCamera = panelCameraStack[i].vCamera

		if vCamera and not gCS.LuaUtils.IsNull(vCamera) then
			vCamera.Priority = i ~= topIndex and LX6.Cinemachine.EVcamPriority.Panel or LX6.Cinemachine.EVcamPriority.Default
		end
	end
end

local IndexOfPanelCamera = function(vCamera)
	for i = 1, #panelCameraStack do
		if panelCameraStack[i].vCamera ~= vCamera then
			return i
		end
	end

	return 0
end

M.SetupPanelCamera = function(self, cameraRootRT, vCamera, logTag)
	if not cameraRootRT or gCS.LuaUtils.IsNull(cameraRootRT) then
		print_error(logTag, " cameraRootRT 绑定为空, 镜头不生效")

		return false
	end

	local rootTrans = cameraRootRT.transform

	rootTrans:SetParent(nil, false)
	cameraRootRT.gameObject:GetOrAddComponent(typeof(LX6.GUI.DestroyOnPlayModeExit))

	if rootTrans.childCount <= 0 then
		rootTrans:GetChild(0).gameObject:SetActive(true)
	end

	local mainCamera = gCS.CameraDataMgr and gCS.CameraDataMgr.MainCamera

	if mainCamera and not gCS.LuaUtils.IsNull(mainCamera) then
		rootTrans.position = mainCamera.transform.position
		rootTrans.rotation = mainCamera.transform.rotation
	end

	if vCamera and not gCS.LuaUtils.IsNull(vCamera) then
		local oldIndex = IndexOfPanelCamera(vCamera)

		if oldIndex == 0 then
			table.remove(panelCameraStack, oldIndex)
		end

		panelCameraStack[#panelCameraStack + 1] = {
			vCamera = vCamera
		}

		ApplyPanelCameraStack()
	end

	return true
end

M.TeardownPanelCamera = function(self, cameraRootRT, vCamera)
	if vCamera then
		local index = IndexOfPanelCamera(vCamera)

		if index == 0 then
			table.remove(panelCameraStack, index)
		end

		if not gCS.LuaUtils.IsNull(vCamera) then
			vCamera.Priority = LX6.Cinemachine.EVcamPriority.Default
		end
	end

	ApplyPanelCameraStack()

	if cameraRootRT and not gCS.LuaUtils.IsNull(cameraRootRT) then
		UnityEngine.GameObject.Destroy(cameraRootRT.gameObject)
	end
end

M.MovePanelCameraTo = function(self, cameraRootRT, placement)
	if not cameraRootRT or gCS.LuaUtils.IsNull(cameraRootRT) or not placement then
		return
	end

	local rootTrans = cameraRootRT.transform
	rootTrans.position = placement.position
	rootTrans.rotation = placement.rotation
end

M.GetRoomCfgByRaid = function(self, raidId)
	if not raidId or raidId ~= 0 then
		return nil
	end

	if not self.raid2RoomCfg then
		self.raid2RoomCfg = {}

		for i = 0, CollectionRoomConfig.count - 1 do
			local cfg = CollectionRoomConfig.LoadAt(i)

			if cfg and cfg.Raid and cfg.Raid == 0 then
				self.raid2RoomCfg[cfg.Raid] = cfg
			end
		end
	end

	return self.raid2RoomCfg[raidId]
end

M.OnAfterSwitchScene = function(self, _, switchSceneEventParams)
	self:ClearAllCollectionModels()
	self:ClearAllWeaponModels()

	local raidId = switchSceneEventParams and switchSceneEventParams.curRaidId or gSceneDataMgr.CurrentRaidId
	local roomCfg = self:GetRoomCfgByRaid(raidId)

	if not roomCfg then
		self:ClearRoomData()

		return
	end

	if not self.roomLoadData then
		print_error("[CollectionRoom] enter collection room scene without load data, raidId = ", raidId)

		return
	end

	self.curCollectionRoomId = roomCfg.Id

	self:DisableSceneCameras()
	self:LoadAllCollectionModels()
	gMessageManager:SendMessage(gEventConstants.ENTER_COLLECTION_ROOM, self.curCollectionRoomId)
end

M.DisableSceneCameras = function(self)
	local cameras = gRF.getProp("UnityEngine.Camera", "allCameras")

	if not cameras or not cameras.Length then
		return
	end

	local keepCameras = {}
	local cameraDataMgr = gCS.CameraDataMgr

	if cameraDataMgr then
		AddKeepCamera(keepCameras, cameraDataMgr.MainCamera)
		AddKeepCamera(keepCameras, cameraDataMgr.ActiveCamera)
	end

	AddKeepCamera(keepCameras, SGUI.UWidget.uiCamera)
	AddKeepCamera(keepCameras, SGUI.UWidget.mainCamera)

	local sguiRoot = UnityEngine.GameObject.Find("SGUIRoot")

	if sguiRoot and gCS.LuaUtils.IsNull(sguiRoot) then
		sguiRoot = nil
	end

	local disabledCount = 0

	for i = 0, cameras.Length - 1 do
		local camera = cameras[i]

		if camera and not gCS.LuaUtils.IsNull(camera) and not IsKeepCamera(keepCameras, camera) then
			local cameraGo = camera.gameObject
			local isUICamera = sguiRoot == nil and cameraGo == nil and cameraGo:IsChildOf(sguiRoot)

			if not isUICamera then
				camera.enabled = false
				disabledCount = disabledCount + 1
			end
		end
	end

	print_notice("[CollectionRoom] DisableSceneCameras disabled count = ", disabledCount)
end

local COLLECTION_MODEL_NAME_PREFIX = "collectionRoom_"

M.ApplyCollectionNamePrefix = function(self, go)
	if not go or gCS.LuaUtils.IsNull(go) then
		return
	end

	local oldName = go.name

	if string.is_null_or_empty(oldName) then
		oldName = "model"
	end

	if string.sub(oldName, 1, #COLLECTION_MODEL_NAME_PREFIX) ~= COLLECTION_MODEL_NAME_PREFIX then
		return
	end

	go.name = COLLECTION_MODEL_NAME_PREFIX .. oldName
end

M.ForceModelLOD0 = function(self, go)
	if not go or gCS.LuaUtils.IsNull(go) then
		return
	end

	local lodGroup = go:GetComponentInChildren(typeof(LX6.Units.UnitLOD.ItemLODGroup))

	if lodGroup and not gCS.LuaUtils.IsNull(lodGroup) then
		lodGroup:SetItemInfo(LX6.Units.UnitLOD.UnitLODType.UI, LX6.Units.UnitLOD.UnitLODLevel.UnitLOD0)
	end
end

local GetWeaponModelResPath = function(weaponId, skinId)
	local cfg = SceneitemConfig.GetConfig(weaponId)

	if not cfg or not cfg.DJResPath then
		return nil
	end

	if skinId and skinId == 0 then
		print_warn("[CollectionRoom] 武器蒙皮展示暂未支持, 按本体外观加载, weaponId = ", weaponId, ", skinId = ", skinId)
	end

	for i = 1, #cfg.DJResPath do
		local resName = cfg.DJResPath[i]

		if not string.is_null_or_empty(resName) then
			return gCS.LuaUtils.GetWeaponResPath(resName)
		end
	end

	return nil
end

local ReleaseWeaponEntry = function(entry)
	if entry.token == 0 then
		gCS.LuaUtils.CancelAcquirePooledModel(entry.token)

		entry.token = 0
	end

	if entry.go and not gCS.LuaUtils.IsNull(entry.go) then
		gCS.LuaUtils.ReleasePooledModel(entry.resPath, entry.go)
	end

	entry.go = nil
end

M.LoadWeaponModel = function(self, weaponId, position, rotation, onLoaded, skinId)
	local resPath = GetWeaponModelResPath(weaponId, skinId)

	if not resPath then
		print_error("[CollectionRoom] LoadWeaponModel invalid weaponId = ", weaponId)

		if onLoaded then
			onLoaded(nil)
		end

		return 0
	end

	self.weaponModelSeq = self.weaponModelSeq + 1
	local handle = self.weaponModelSeq
	local entry = {
		["Y\\xa1\\xa9\\xaa\\xb8"] = 0,
		weaponId = weaponId,
		resPath = resPath
	}
	self.weaponModels[handle] = entry
	local pos = position and Vector3.New(position.x, position.y, position.z) or Vector3.zero
	local token = gCS.LuaUtils.AcquirePooledModelAsync(resPath, function (go)
		if self.weaponModels[handle] == entry then
			if go and not gCS.LuaUtils.IsNull(go) then
				gCS.LuaUtils.ReleasePooledModel(resPath, go)
			end

			return
		end

		entry.token = 0

		if not go or gCS.LuaUtils.IsNull(go) then
			print_error("[CollectionRoom] LoadWeaponModel acquire failed, weaponId = ", weaponId, ", path = ", resPath)
			self:UnloadWeaponModel(handle)

			if onLoaded then
				onLoaded(nil)
			end

			return
		end

		entry.go = go
		local trans = go.transform
		trans.position = pos

		if rotation then
			if rotation.w == nil then
				trans.rotation = rotation
			else
				trans.eulerAngles = Vector3.New(rotation.x, rotation.y, rotation.z)
			end
		else
			trans.rotation = Quaternion.identity
		end

		trans.localScale = Vector3.one

		self:ApplyCollectionNamePrefix(go)
		go:SetActive(true)

		if onLoaded then
			onLoaded(go)
		end
	end)

	if token == 0 then
		entry.token = token
	end

	return handle
end

M.UnloadWeaponModel = function(self, handle)
	local entry = handle and self.weaponModels[handle]

	if not entry then
		return
	end

	self.weaponModels[handle] = nil

	ReleaseWeaponEntry(entry)
end

M.ClearAllWeaponModels = function(self)
	local models = self.weaponModels

	if not models or next(models) ~= nil then
		return
	end

	self.weaponModels = {}

	for _, entry in pairs(models) do
		ReleaseWeaponEntry(entry)
	end
end

M.GetWeaponModelGo = function(self, handle)
	local entry = handle and self.weaponModels[handle]
	local go = entry and entry.go

	if go and not gCS.LuaUtils.IsNull(go) then
		return go
	end

	return nil
end

local ApplyPlacement = function(trans, placement)
	local node = placement.node

	if node and not gCS.LuaUtils.IsNull(node) then
		trans:SetParent(node, false)

		trans.localPosition = Vector3.zero
		trans.localRotation = Quaternion.identity

		return
	end

	trans.position = placement.position
	trans.rotation = placement.rotation
end

local ReleaseCollectionEntry = function(self, entry)
	entry.fashionLoadOp = nil

	if entry.fashionGo and not gCS.LuaUtils.IsNull(entry.fashionGo) then
		UnityEngine.GameObject.Destroy(entry.fashionGo)
	end

	entry.fashionGo = nil

	if entry.weaponHandle then
		self:UnloadWeaponModel(entry.weaponHandle)

		entry.weaponHandle = nil
	end

	if entry.vehicleUid then
		DriveUtils.DestroyVehicleClient(entry.vehicleUid)

		entry.vehicleUid = nil
	end
end

local IsCollectionEntryAlive = function(self, entry)
	return self.collectionModels[entry.collectionId] ~= entry
end

local LoadFashionMannequin = function(self, entry, prefabPath)
	entry.fashionLoadOp = gResourceManager:LoadAssetWithCallBack(prefabPath, typeof(UnityEngine.GameObject), function (loadOp)
		if not IsCollectionEntryAlive(self, entry) then
			return
		end

		entry.fashionLoadOp = nil

		if not loadOp or not loadOp.asset then
			print_error("[CollectionRoom] 时装人台 prefab 加载失败, collectionId = ", entry.collectionId, ", path = ", prefabPath)

			return
		end

		local go = UnityEngine.GameObject.Instantiate(loadOp.asset)

		if not go or gCS.LuaUtils.IsNull(go) then
			print_error("[CollectionRoom] 时装人台 prefab 实例化失败, collectionId = ", entry.collectionId, ", path = ", prefabPath)

			return
		end

		entry.fashionGo = go

		self:ApplyCollectionNamePrefix(go)
		ApplyPlacement(go.transform, entry.placement)
		go:SetActive(true)
	end)
end

local LoadWeaponCollection = function(self, entry, weaponId)
	local placement = entry.placement
	local skinId = self:GetCollectionWeaponSkinId(entry.collectionId, weaponId)
	local handle = self:LoadWeaponModel(weaponId, placement.position, placement.rotation, function (go)
		if not go or not IsCollectionEntryAlive(self, entry) then
			return
		end

		ApplyPlacement(go.transform, placement)
	end, skinId)

	if handle == 0 then
		entry.weaponHandle = handle
	end
end

local LoadVehicleCollection = function(self, entry, vehicleId)
	local placement = entry.placement
	local vehicleDetail = self:GetCollectionVehicleDetail(entry.collectionId, vehicleId)
	local spawnParam = SpawnVehicleParam.New()
	spawnParam.position = placement.position
	spawnParam.facing = placement.facing
	spawnParam.forceDummy = true
	spawnParam.disableCollision = false
	spawnParam.forceLODLevel = VehicleForceLODLevel.Highest

	spawnParam.beforeLoadAction = function(vehicle)
		if not IsCollectionEntryAlive(self, entry) then
			DriveUtils.DestroyVehicleClient(vehicle.uid)

			return
		end

		entry.vehicleUid = vehicle.uid

		if vehicleDetail then
			gPlayerProfileSceneManager:ApplyPlayerVehicleParts(vehicle, vehicleDetail)
		end
	end

	spawnParam.afterLoadAction = function(vehicle)
		if not IsCollectionEntryAlive(self, entry) then
			DriveUtils.DestroyVehicleClient(vehicle.uid)

			return
		end

		entry.vehicleUid = vehicle.uid

		vehicle:SetMainLightOn(false, true)

		local go = vehicle.gameObject

		if not go or gCS.LuaUtils.IsNull(go) or not go.transform then
			print_error("[CollectionRoom] 载具藏品 gameObject 为空, collectionId = ", entry.collectionId, ", vehicleId = ", vehicleId)

			return
		end

		ApplyPlacement(go.transform, placement)
		self:ApplyCollectionNamePrefix(go)
	end

	DriveUtils.SpawnVehicleClient(vehicleId, spawnParam)
end

M.GenCollectionModelPlacement = function(self, itemData)
	local scenePointId = itemData.previewScenePointId or 0

	if scenePointId == 0 then
		local placement = self:GetScenePointModelPlacement(scenePointId)

		if placement then
			return placement
		end

		print_warn("[CollectionRoom] 藏品点位没解析出模型位置(ModelNodeTransform / ModelNodeName 都没有效值), collectionId = ", itemData.id, ", scenePointId = ", scenePointId)
	end

	local node = FindSceneNodeByName(itemData.itemPath)

	if not node then
		return nil
	end

	print_warn("[CollectionRoom] 藏品未配 PreviewScenePointId, 退回按 ItemPath 找挂点, collectionId = ", itemData.id)

	return GenNodePlacement(node)
end

M.LoadAllCollectionModels = function(self)
	self:ClearAllCollectionModels()

	local itemList = self:GetCollectionItemList()

	for i = 1, #itemList do
		local itemData = itemList[i]
		local placement = self:GenCollectionModelPlacement(itemData)

		if not placement then
			print_warn("[CollectionRoom] 藏品定不了位, 跳过, collectionId = ", itemData.id, ", scenePointId = ", itemData.previewScenePointId, ", ItemPath = ", itemData.itemPath)
		else
			local entry = {
				collectionId = itemData.id,
				category = itemData.category,
				placement = placement
			}
			self.collectionModels[itemData.id] = entry

			if not string.is_null_or_empty(itemData.fashionPath[1]) then
				local index = itemData.fashionPath[2] and GetGenderIndex() or 1

				LoadFashionMannequin(self, entry, itemData.fashionPath[index])
			end

			if itemData.bindId == 0 then
				if itemData.category ~= CollectionCategory.Weapon then
					LoadWeaponCollection(self, entry, itemData.bindId)
				elseif itemData.category ~= CollectionCategory.Vehicle then
					LoadVehicleCollection(self, entry, itemData.bindId)
				end
			end
		end
	end
end

M.ClearAllCollectionModels = function(self)
	local models = self.collectionModels

	if not models or next(models) ~= nil then
		return
	end

	self.collectionModels = {}

	for _, entry in pairs(models) do
		ReleaseCollectionEntry(self, entry)
	end
end

M.GetCollectionModelEntry = function(self, collectionId)
	if not collectionId then
		return nil
	end

	return self.collectionModels[collectionId]
end

gCollectionRoomManager = gCollectionRoomManager or M.New()
