-- Original chunk: @Lua\LuaFiles\LX6\Manager\House\HouseGadgetManager.lua
-- Decompiled from: 00750_HouseGadgetManager.lua_24a9b1165505.luajit

local HouseFurnitureConfig = LTConfig.HouseFurnitureConfig
local MessageConfig = LTConfig.MessageConfig
local CSFurnitureMono = LX6.UGC.HouseFurniture
C_HouseGadgetManager = DefClass("C_HouseGadgetManager", C_HouseGadgetManager)
local M = C_HouseGadgetManager

M.ctor = function(self)
	self:DefineAllData()
end

M.DefineAllData = function(self)
	self.placedId2GadgetIdMap = {}
	self.gadgetGoDict = {}
	self.gadgetGoRetryTimerDict = {}
	self.luaSlotReplaceGoDict = {}
	self.fenestrationMetaDict = {}
	self.isEditMode = false
	self.curHouseId = 0
	self.curFloor = 0
end

M.OnInit = function(self)
	gMessageManager:AddMessageListener(gEventConstants.ON_GADGET_SLOT_COMP_LOADED, self:CreateAction("OnGadgetSlotCompLoaded"))
end

M.OnBeforeSwitchScene = function(self, switchType)
	if gSwitchSceneType.SameImage < switchType then
		self:ClearAll()
	end
end

M.CreateGadgetsForFurnitures = function(self, houseId, floor, placedIdList)
	if not placedIdList or #placedIdList ~= 0 then
		return
	end

	self.curHouseId = houseId
	self.curFloor = floor
	local ulongList = {}

	for _, placedId in ipairs(placedIdList) do
		table.insert(ulongList, ulong.new(placedId, 0))
	end

	gClientToGameDelegate:AskCreateHouseFurnitureGadgets(houseId, floor, ulongList).Callback = function (err, mapping)
		if err == MessageConfig.Ok then
			print_error("HouseGadgetManager: AskCreateHouseFurnitureGadgets 失败, err =", err)
			gDisplayMessageMgr:ShowServerMessage(err)

			return
		end

		if not mapping or not mapping.placedID2GadgetInstanceID then
			print_warn("HouseGadgetManager: 服务端返回的映射数据为空")

			return
		end

		for placedId, gadgetInstanceId in pairs(mapping.placedID2GadgetInstanceID) do
			local numPlacedId = gFurnitureUtils:ConvertServerUidToNumber(placedId)
			local numGadgetId = gFurnitureUtils:ConvertServerUidToNumber(gadgetInstanceId)

			if numPlacedId and numGadgetId and numGadgetId == 0 then
				self.placedId2GadgetIdMap[numPlacedId] = numGadgetId

				self:OnGadgetSlotCompLoaded(nil, numGadgetId)

				local furnitureGo = gFurnitureUIDManager.uid2FurnitureGoDict[numPlacedId]

				if furnitureGo and not gCS.LuaUtils.IsNull(furnitureGo) then
					gFurnitureUtils:TrySetGadgetInstanceId(furnitureGo, numGadgetId)
				end
			end
		end

		gHouseManager:CreateAquariumFishesForPlacedIds(houseId, placedIdList)
		print_debug("HouseGadgetManager: 机关映射创建完成, 数量 =", table.count(self.placedId2GadgetIdMap))
	end
end

M.DestroyGadgetsForFurnitures = function(self, houseId, floor, placedIdList)
	if not placedIdList then
		placedIdList = {}

		for placedId, _ in pairs(self.placedId2GadgetIdMap) do
			table.insert(placedIdList, placedId)
		end
	end

	if #placedIdList ~= 0 then
		return
	end

	if gLuaDataManager.isNetworkAvailable then
		local ulongList = {}

		for _, placedId in ipairs(placedIdList) do
			table.insert(ulongList, ulong.new(placedId, 0))
		end

		gClientToGameDelegate:AskDestoryHouseFurnitureGadgets(houseId, floor, ulongList).Callback = function (err)
			if err ~= MessageConfig.Ok or err ~= MessageConfig.Disconnect or err ~= MessageConfig.TimeOut or err ~= MessageConfig.PeerTimeOut then
				return
			end

			print_error("HouseGadgetManager: AskDestoryHouseFurnitureGadgets 失败, err =", err)
		end
	end

	for _, placedId in ipairs(placedIdList) do
		local gadgetId = self.placedId2GadgetIdMap[placedId]

		if gadgetId then
			self:StopGadgetGoRetryTimer(gadgetId)

			self.gadgetGoDict[gadgetId] = nil
		end

		self.placedId2GadgetIdMap[placedId] = nil
		self.luaSlotReplaceGoDict[placedId] = nil
	end
end

M.DestroyAllGadgets = function(self)
	local houseId = self.curHouseId
	local floor = self.curFloor

	if houseId and houseId == 0 then
		self:DestroyGadgetsForFurnitures(houseId, floor, nil)
	end

	self:ClearAll()
end

M.DestroyGadgetsByHouseId = function(self, houseId, floor)
	if not houseId or houseId ~= 0 then
		return
	end

	self:RefreshFenestrationHouseOwnership()

	local placedIdList = {}

	for placedId, _ in pairs(self.placedId2GadgetIdMap) do
		if gFurnitureUIDManager:GetFurnitureHouseId(placedId) ~= houseId then
			table.insert(placedIdList, placedId)
		end
	end

	if #placedIdList ~= 0 then
		return
	end

	self:DestroyGadgetsForFurnitures(houseId, floor or 0, placedIdList)
end

M.RegisterFurnitureLuaSlotReplace = function(self, placedId, furnitureGo, furnitureId)
	if not furnitureGo or gCS.LuaUtils.IsNull(furnitureGo) then
		return
	end

	local cfg = HouseFurnitureConfig.GetConfig(furnitureId)

	if cfg.PathId ~= 0 then
		return
	end

	local houseFurniture = furnitureGo:GetComponentInChildren(typeof(CSFurnitureMono))
	local luaSlotReplaceGo = houseFurniture.gadgetGameObject

	if not luaSlotReplaceGo or gCS.LuaUtils.IsNull(luaSlotReplaceGo) then
		luaSlotReplaceGo = furnitureGo
	end

	self.luaSlotReplaceGoDict[placedId] = luaSlotReplaceGo

	luaSlotReplaceGo:SetActive(self.isEditMode)
	gFurnitureShowCaseUtils:OnFurnitureRegistered(placedId, furnitureGo, furnitureId, self.isEditMode)
end

M.RegisterFenestrationLuaSlotReplace = function(self, placedId, fenGo, furnitureId, houseId, serverPlaceId)
	if houseId and placedId then
		gFurnitureUIDManager.uidToHouseId[placedId] = houseId
	end

	self.fenestrationMetaDict[placedId] = {
		furnitureId = furnitureId,
		houseId = houseId,
		serverPlaceId = serverPlaceId or placedId
	}

	if fenGo and not gCS.LuaUtils.IsNull(fenGo) then
		self:_ApplyFenestrationSlotReplace(placedId, fenGo, furnitureId)
	end
end

M.RefreshFenestrationHouseOwnership = function(self)
	if not gFurnitureUIDManager or not gFurnitureUIDManager.uidToHouseId or not self.fenestrationMetaDict then
		return
	end

	for placedId, meta in pairs(self.fenestrationMetaDict) do
		if placedId and meta and meta.houseId then
			gFurnitureUIDManager.uidToHouseId[placedId] = meta.houseId
		end
	end
end

M._ApplyFenestrationSlotReplace = function(self, placedId, fenGo, furnitureId)
	local cfg = HouseFurnitureConfig.GetConfig(furnitureId)

	if not cfg or cfg.PathId ~= 0 then
		return
	end

	local houseFurniture = fenGo:GetComponentInChildren(typeof(CSFurnitureMono))
	local luaSlotReplaceGo = nil

	if houseFurniture and not gCS.LuaUtils.IsNull(houseFurniture) then
		luaSlotReplaceGo = houseFurniture.gadgetGameObject
	end

	if not luaSlotReplaceGo or gCS.LuaUtils.IsNull(luaSlotReplaceGo) then
		luaSlotReplaceGo = fenGo
	end

	self.luaSlotReplaceGoDict[placedId] = luaSlotReplaceGo

	luaSlotReplaceGo:SetActive(self.isEditMode)
end

M.UnregisterFurnitureLuaSlotReplace = function(self, placedId)
	self.luaSlotReplaceGoDict[placedId] = nil
	self.fenestrationMetaDict[placedId] = nil
end

M.StopGadgetGoRetryTimer = function(self, gadgetId)
	local timer = self.gadgetGoRetryTimerDict[gadgetId]

	if timer then
		timer:Stop()

		self.gadgetGoRetryTimerDict[gadgetId] = nil
	end
end

M.TryCacheGadgetGo = function(self, gadgetId)
	local entity = gGadgetManager:GetEntitySearchByInstanceId(gadgetId)

	if not entity or not entity.gameObject or gCS.LuaUtils.IsNull(entity.gameObject) then
		return nil
	end

	self.gadgetGoDict[gadgetId] = entity.gameObject

	return entity.gameObject
end

M.RefreshAllGadgetGo = function(self)
	for _, gadgetId in pairs(self.placedId2GadgetIdMap) do
		local gadgetGo = self.gadgetGoDict[gadgetId]

		if not gadgetGo or gCS.LuaUtils.IsNull(gadgetGo) then
			self:TryCacheGadgetGo(gadgetId)
		end
	end
end

M.EnterEditMode = function(self)
	self.isEditMode = true

	gHouseManager:SetAquariumFishesHouseEditState(true)

	local editingHouseId = gHouseManager:GetEditingHouseId()

	self:RefreshFenestrationHouseOwnership()
	self:RefreshAllGadgetGo()
	self:RefreshFenestrationSlotReplaceGos()

	for placedId, gadgetId in pairs(self.placedId2GadgetIdMap) do
		if gFurnitureUIDManager:GetFurnitureHouseId(placedId) ~= editingHouseId then
			local gadgetGo = self.gadgetGoDict[gadgetId]

			if gadgetGo and not gCS.LuaUtils.IsNull(gadgetGo) then
				gadgetGo:SetActive(false)
			end
		end
	end

	for placedId, slotGo in pairs(self.luaSlotReplaceGoDict) do
		if gFurnitureUIDManager:GetFurnitureHouseId(placedId) ~= editingHouseId and slotGo and not gCS.LuaUtils.IsNull(slotGo) then
			slotGo:SetActive(true)
			gFurnitureShowCaseUtils:ResolveUnitParent(placedId)
		end
	end

	print_debug("HouseGadgetManager: 进入编辑模式, editingHouseId =", editingHouseId)
end

M.ExitEditMode = function(self)
	self.isEditMode = false

	gHouseManager:SetAquariumFishesHouseEditState(false)

	local editingHouseId = gHouseManager:GetEditingHouseId()

	self:RefreshFenestrationHouseOwnership()
	self:RefreshAllGadgetGo()
	self:RefreshFenestrationSlotReplaceGos()

	for placedId, gadgetId in pairs(self.placedId2GadgetIdMap) do
		if gFurnitureUIDManager:GetFurnitureHouseId(placedId) ~= editingHouseId then
			local gadgetGo = self.gadgetGoDict[gadgetId]

			if gadgetGo and not gCS.LuaUtils.IsNull(gadgetGo) then
				gadgetGo:SetActive(true)
			end
		end
	end

	for placedId, slotGo in pairs(self.luaSlotReplaceGoDict) do
		if gFurnitureUIDManager:GetFurnitureHouseId(placedId) ~= editingHouseId then
			gFurnitureShowCaseUtils:ResolveUnitParent(placedId)

			if slotGo and not gCS.LuaUtils.IsNull(slotGo) then
				slotGo:SetActive(false)
			end
		end
	end

	print_debug("HouseGadgetManager: 退出编辑模式, editingHouseId =", editingHouseId)
end

M.OnGadgetSlotCompLoaded = function(self, eventId, luaEntityId)
	local isGenuineEvent = luaEntityId == nil

	if luaEntityId ~= nil then
		luaEntityId = eventId
	end

	luaEntityId = gFurnitureUtils:ConvertServerUidToNumber(luaEntityId)

	if not luaEntityId or luaEntityId ~= 0 then
		return
	end

	local isOurGadget = false

	for placedId, gadgetId in pairs(self.placedId2GadgetIdMap) do
		if gadgetId ~= luaEntityId then
			isOurGadget = true

			break
		end
	end

	if not isOurGadget then
		return
	end

	local gadgetGo = self.gadgetGoDict[luaEntityId]

	if not gadgetGo or gCS.LuaUtils.IsNull(gadgetGo) then
		gadgetGo = self:TryCacheGadgetGo(luaEntityId)
	end

	if not gadgetGo then
		if self.gadgetGoRetryTimerDict[luaEntityId] then
			return
		end

		local tryCount = 0
		self.gadgetGoRetryTimerDict[luaEntityId] = FrameTimer.New(function ()
			tryCount = tryCount + 1
			local retryGo = self:TryCacheGadgetGo(luaEntityId)

			if retryGo then
				if self.isEditMode then
					retryGo:SetActive(false)
					print_debug("HouseGadgetManager: 编辑态下隐藏重试加载成功的机关, gadgetId =", luaEntityId)
				end

				self:StopGadgetGoRetryTimer(luaEntityId)
				gFurnitureShowCaseUtils:OnGadgetGoReady(luaEntityId)

				return
			end

			if tryCount > 10 then
				self:StopGadgetGoRetryTimer(luaEntityId)
			end
		end, 1, -1, false):Start()

		return
	end

	if self.isEditMode then
		gadgetGo:SetActive(false)
		print_debug("HouseGadgetManager: 编辑态下隐藏新加载的机关, gadgetId =", luaEntityId)
	end

	if isGenuineEvent then
		gFurnitureShowCaseUtils:OnGadgetGoReady(luaEntityId)
	end
end

M.OnFenestrationRenderComplete = function(self, gridProxy)
	if not gridProxy or gCS.LuaUtils.IsNull(gridProxy) then
		return
	end

	for placedId, meta in pairs(self.fenestrationMetaDict) do
		local cfg = HouseFurnitureConfig.GetConfig(meta.furnitureId)

		if cfg and cfg.PathId == 0 then
			local fenGo = gridProxy:GetFenestrationGameObjectByServerPlacedID(meta.serverPlaceId)

			if fenGo and not gCS.LuaUtils.IsNull(fenGo) then
				self:_ApplyFenestrationSlotReplace(placedId, fenGo, meta.furnitureId)
			end
		end
	end
end

M.RefreshFenestrationSlotReplaceGos = function(self)
	self:RefreshFenestrationHouseOwnership()

	for placedId, meta in pairs(self.fenestrationMetaDict) do
		local cfg = HouseFurnitureConfig.GetConfig(meta.furnitureId)

		if cfg and cfg.PathId == 0 then
			local ctx = gHouseManager:GetContext(meta.houseId)
			local proxy = ctx and ctx:GetGridSystemProxy()

			if proxy and not gCS.LuaUtils.IsNull(proxy) then
				local fenGo = proxy:GetFenestrationGameObjectByServerPlacedID(meta.serverPlaceId)

				if fenGo and not gCS.LuaUtils.IsNull(fenGo) then
					self:_ApplyFenestrationSlotReplace(placedId, fenGo, meta.furnitureId)
				end
			end
		end
	end
end

M.IsFurnitureWithGadget = function(self, furnitureId)
	local cfg = HouseFurnitureConfig.GetConfig(furnitureId)

	if cfg and cfg.PathId == 0 then
		return true
	end

	return false
end

M.GetGadgetInstanceId = function(self, placedId)
	return self.placedId2GadgetIdMap[placedId]
end

M.GetPlacedIdByGadgetId = function(self, gadgetId)
	gadgetId = gFurnitureUtils:ConvertServerUidToNumber(gadgetId)

	if not gadgetId or gadgetId ~= 0 then
		return nil
	end

	for placedId, gid in pairs(self.placedId2GadgetIdMap) do
		if gid ~= gadgetId then
			return placedId
		end
	end

	return nil
end

M.GetShowcaseDataByGadgetId = function(self, gadgetId)
	local placedId = self:GetPlacedIdByGadgetId(gadgetId)

	if not placedId then
		return nil, 
	end

	return placedId, gHouseManager:GetShowcaseData(placedId)
end

M.UpdateMapping = function(self, placedId, gadgetInstanceId)
	if not placedId or not gadgetInstanceId or gadgetInstanceId ~= 0 then
		return
	end

	local numPlacedId = gFurnitureUtils:ConvertServerUidToNumber(placedId)
	local numGadgetId = gFurnitureUtils:ConvertServerUidToNumber(gadgetInstanceId)

	if numPlacedId and numGadgetId and numGadgetId == 0 then
		self.placedId2GadgetIdMap[numPlacedId] = numGadgetId
	end
end

M.ClearAll = function(self)
	for gadgetId, timer in pairs(self.gadgetGoRetryTimerDict) do
		timer:Stop()

		self.gadgetGoRetryTimerDict[gadgetId] = nil
	end

	self.placedId2GadgetIdMap = {}
	self.gadgetGoDict = {}
	self.gadgetGoRetryTimerDict = {}
	self.luaSlotReplaceGoDict = {}
	self.fenestrationMetaDict = {}
	self.isEditMode = false
	self.curHouseId = 0
	self.curFloor = 0
end

gHouseGadgetManager = gHouseGadgetManager or C_HouseGadgetManager.new()
