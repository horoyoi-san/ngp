-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CollectionRoomMainPanelStore.lua
-- Decompiled from: 01438_CollectionRoomMainPanelStore.lua_c926e8c3bb16.luajit

local MessageConfig = LTConfig.MessageConfig
local ItemTypeCtrl = {
	["2G\\x85\\xa9\\x86U"] = 1,
	["\\x88\\xb0\\x9bf?\\xfd6"] = 2,
	["V-~P"] = 3,
	["2G\\x83\\x83\\x82M"] = 0
}
local ItemCanChangeCtrl = {
	["#N\\x90\\x82\\x90D"] = 0,
	["r\\xba\\xb0\\xba\\xb3"] = 1
}
local SLOT_FLUSH_DELAY = 2

local SlotKey = function(boothId, slot)
	return boothId .. "_" .. slot
end

C_CollectionRoomMainPanelStore = DefClass("C_CollectionRoomMainPanelStore", C_CollectionRoomMainPanelStore, C_StoreGroup)
GroupName2Class.CollectionRoomMainPanelStore = C_CollectionRoomMainPanelStore
local M = C_CollectionRoomMainPanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.boothId = 0
	self.mainBoothId = 0
	self.collectionList = {}
	self.curCollectionId = 0
	self.cameraReady = false
	self.isChangeMode = false
	self.changeCollectionId = 0
	self.pendingSlotOps = {}
	self.slotServerItemId = {}
	self.slotDispatched = {}
	self.slotFlushTimer = nil
	self.slotFlushing = false
	self.slotFlushDone = nil
end

M.DefineAllEnumsAutoGen = function(self)
	self.typeCtrlEnum = {
		["M\\x90\\x9e\\x8cO"] = 0,
		["I\\xbc\\xa7\\xbc\\xa5"] = 1
	}
	self.hasSelectCtrlEnum = {
		["Gw\\xbfZY\\xbe\\xe6NCn{A"] = 3,
		["\\xf1\\xda\n!\\xfc"] = 2,
		["#N\\x90\\x82\\x90D"] = 0,
		["c\\xa1\\x85\\xaa\\xa2"] = 4,
		["?@\\x90\\x80\\x84D"] = 5,
		["h\\xa3\\xb2\\xbb\\xaf"] = 1
	}
	self.qualityCtrlEnum = {
		["x.h^"] = 3,
		["DUil@!"] = 1,
		["}-q_"] = 5,
		["}0xB"] = 0,
		["J\\xbc\\xa7\\xaa\\xb8"] = 2,
		["Z\\x90\\x80\\x84D"] = 6,
		["]\\x83\\x9e\\x8fD"] = 4,
		["MH}|O!"] = 7
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.typeCtrlEnum = nil
	self.hasSelectCtrlEnum = nil
	self.qualityCtrlEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
	if self.boothId == 0 then
		self.RefreshAll(self)
	end
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
	self.FlushSlotOps(self)
	self.TeardownCamera(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	self.boothId = data and data.boothId or 0

	if self.boothId ~= 0 then
		print_error("[CollectionRoomMainPanel] 打开面板没带 boothId, data = ", data)
	end

	self.mainBoothId = data and data.mainBoothId or 0

	if self.mainBoothId ~= 0 then
		self.mainBoothId = gCollectionRoomManager:GetMainBoothId(self.boothId)
	end

	self.isChangeMode = false
	self.changeCollectionId = 0

	self:FlushSlotOps()
	self.SubGroup.MoneyTemplateStore:SetData(UX.Game.MoneyType.Money)
	self:SetupCamera()
	self:RefreshItemList()
end

M.OnClose = function(self)
	self.FlushSlotOps(self)
	self.TeardownCamera(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.SetupCamera = function(self)
	self.cameraReady = gCollectionRoomManager:SetupPanelCamera(self.bindData.cameraRootRT, self.bindData.vCamera, "[CollectionRoomMainPanel]")
end

M.TeardownCamera = function(self)
	if not self.cameraReady then
		return
	end

	self.cameraReady = false

	gCollectionRoomManager:TeardownPanelCamera(self.bindData and self.bindData.cameraRootRT, self.bindData and self.bindData.vCamera)
end

M.ApplyPreviewCamera = function(self, collectionId)
	if not self.cameraReady then
		return
	end

	local scenePointId = 0

	if collectionId and collectionId == 0 then
		local itemData = gCollectionRoomManager:GetCollectionItem(collectionId)
		scenePointId = itemData and itemData.previewScenePointId or 0
	end

	if scenePointId ~= 0 then
		scenePointId = gCollectionRoomManager:GetBoothPathScenePointId(self.boothId)

		if scenePointId ~= 0 and self.mainBoothId == 0 and self.mainBoothId == self.boothId then
			scenePointId = gCollectionRoomManager:GetBoothPathScenePointId(self.mainBoothId)
		end
	end

	if scenePointId ~= 0 then
		print_warn("[CollectionRoomMainPanel] 藏品没配 PreviewScenePointId 且展位没配 PathScenePointId, 镜头保持不动, boothId = ", self.boothId, ", mainBoothId = ", self.mainBoothId, ", collectionId = ", collectionId)

		return
	end

	local placement = gCollectionRoomManager:GetScenePointCameraPlacement(scenePointId)

	if not placement then
		print_warn("[CollectionRoomMainPanel] 预览机位解析不出位姿(CameraNodeTransform / CameraNodeName 都没有效值), scenePointId = ", scenePointId)

		return
	end

	gCollectionRoomManager:MovePanelCameraTo(self.bindData.cameraRootRT, placement)
end

M.RefreshItemList = function(self)
	self.collectionList = gCollectionRoomManager:GetBoothCollectionItemList(self.boothId)

	if self:GetCollectionIndex(self.curCollectionId) ~= 0 then
		self.curCollectionId = 0
	end

	self.bindData.itemList:SetSimpleList(self:GetItemListCount())
	self:RefreshBoothInfo()
	self:RefreshSelectedInfo()
	self:ApplyPreviewCamera(self.curCollectionId)
end

M.RefreshBoothInfo = function(self)
	self.bindData.closetName = gCollectionRoomManager:GetBoothName(self.boothId)
	local capacity = gCollectionRoomManager:GetBoothCapacity(self.boothId)
	local placedCount = gCollectionRoomManager:GetBoothPlacedCount(self.boothId)
	self.bindData.haveNum = string.format("%d/%d", placedCount, capacity)
	self.bindData.valueNum = tostring(gCollectionRoomManager:GetCollectibility())
end

M.RefreshSelectedInfo = function(self)
	local itemData = self.GetSelectedItemData(self)

	if not itemData then
		self.bindData.hasSelectCtrl = self.hasSelectCtrlEnum._false
		self.bindData.collectionItemName = ""
		self.bindData.infoText = ""
		self.bindData.qualityCtrl = self.qualityCtrlEnum.noquality
		self.bindData.levelNum = ""

		return
	end

	self.bindData.collectionItemName = itemData.name
	self.bindData.infoText = itemData.desc
	self.bindData.qualityCtrl = itemData.quality or self.qualityCtrlEnum.noquality
	self.bindData.typeCtrl = self:GetTypeCtrl(itemData)
	local slot = gCollectionRoomManager:GetBoothSlotByItemId(self.boothId, itemData.itemId)
	self.bindData.levelNum = slot == 0 and tostring(gCollectionRoomManager:GetBoothSlotLevel(self.boothId, slot)) or ""
	self.bindData.hasSelectCtrl = self:GetSelectStateCtrl(itemData, slot)
end

M.GetSelectedItemData = function(self)
	local index = self.GetCollectionIndex(self, self.curCollectionId)

	if index ~= 0 then
		return nil
	end

	return self.collectionList[index]
end

M.GetTypeCtrl = function(self, itemData)
	local category = gCollectionRoomManager:GetCollectionCategoryEnum()

	if itemData.category ~= category.Weapon then
		return self.typeCtrlEnum.weapon
	end

	return self.typeCtrlEnum.dress
end

M.GetSelectStateCtrl = function(self, itemData, slot)
	if self.isChangeMode then
		return self.hasSelectCtrlEnum.Change
	end

	if not gCollectionRoomManager:IsCollectionOwned(itemData) then
		return self.hasSelectCtrlEnum.NoGet
	end

	if slot == 0 then
		return self.hasSelectCtrlEnum.Hasitem
	end

	if gCollectionRoomManager:GetBoothFirstEmptySlot(self.boothId) == 0 then
		return self.hasSelectCtrlEnum.Empty
	end

	return self.hasSelectCtrlEnum.HasMultiItem
end

M.GetCollectionIndex = function(self, collectionId)
	if not collectionId or collectionId ~= 0 then
		return 0
	end

	for i = 1, #self.collectionList do
		if self.collectionList[i].id ~= collectionId then
			return i
		end
	end

	return 0
end

M.GetItemListCount = function(self)
	local capacity = gCollectionRoomManager:GetBoothCapacity(self.boothId)

	return math.max(#self.collectionList, capacity)
end

M.RefreshAll = function(self)
	self.bindData.itemList:SetSimpleList(self:GetItemListCount())
	self:RefreshBoothInfo()
	self:RefreshSelectedInfo()
end

M.RequestUpdateSlotItem = function(self, slot, itemId)
	local boothId = self.boothId
	local key = SlotKey(boothId, slot)
	itemId = itemId or 0

	if self.slotServerItemId[key] ~= nil then
		self.slotServerItemId[key] = gCollectionRoomManager:GetBoothSlotItemId(boothId, slot)
	end

	local serverItemId = self.slotServerItemId[key]

	gCollectionRoomManager:SetBoothSlotItemLocal(boothId, slot, itemId)

	if itemId ~= serverItemId and not self.slotDispatched[key] then
		self.pendingSlotOps[key] = nil
		self.slotServerItemId[key] = nil
	else
		self.pendingSlotOps[key] = {
			boothId = boothId,
			slot = slot,
			itemId = itemId
		}
	end

	self.isChangeMode = false
	self.changeCollectionId = 0

	self.RefreshAll(self)

	if next(self.pendingSlotOps) == nil then
		self.ScheduleSlotFlush(self)
	else
		self.StopSlotFlushTimer(self)
	end
end

M.StopSlotFlushTimer = function(self)
	if self.slotFlushTimer then
		self.slotFlushTimer:Stop()

		self.slotFlushTimer = nil
	end
end

M.ScheduleSlotFlush = function(self)
	self:StopSlotFlushTimer()

	self.slotFlushTimer = Timer.New(function ()
		self.slotFlushTimer = nil

		self:FlushSlotOps()
	end, SLOT_FLUSH_DELAY):Start()
end

M.FlushSlotOps = function(self, onDone)
	self.StopSlotFlushTimer(self)

	if self.slotFlushing then
		if onDone then
			local prev = self.slotFlushDone
			self.slotFlushDone = prev and function ()
				prev()
				onDone()
			end or onDone
		end

		return
	end

	local queue = {}

	for key, op in pairs(self.pendingSlotOps) do
		self.slotDispatched[key] = true

		table.insert(queue, op)
	end

	self.pendingSlotOps = {}

	if #queue ~= 0 then
		if onDone then
			onDone()
		end

		return
	end

	self.slotFlushing = true
	self.slotFlushDone = onDone

	self.SendSlotOpQueue(self, queue, 1)
end

M.SendSlotOpQueue = function(self, queue, index)
	local op = queue[index]

	if not op then
		self.slotFlushing = false
		local done = self.slotFlushDone
		self.slotFlushDone = nil

		if next(self.pendingSlotOps) == nil then
			if done then
				self.FlushSlotOps(self, done)
			else
				self.ScheduleSlotFlush(self)
			end

			return
		end

		if done then
			done()
		end

		return
	end

	local key = SlotKey(op.boothId, op.slot)
	local info = op.itemId == 0 and {
		ItemId = op.itemId
	} or nil
	local task = gClientToGameDelegate:RpcUpdatePlayerCollectionItemInfo(op.boothId, op.slot, info)

	task.Callback = function(err)
		self.slotDispatched[key] = nil

		if err ~= MessageConfig.Ok then
			self:OnSlotOpSucceeded(key, op)
		else
			self:OnSlotOpFailed(key, op)
			gDisplayMessageMgr:DisplayServerMessageId(err)
		end

		self:SendSlotOpQueue(queue, index + 1)
	end
end

M.OnSlotOpSucceeded = function(self, key, op)
	if self.pendingSlotOps[key] then
		self.slotServerItemId[key] = op.itemId
	else
		self.slotServerItemId[key] = nil
	end
end

M.OnSlotOpFailed = function(self, key, op)
	if self.pendingSlotOps[key] then
		return
	end

	gCollectionRoomManager:SetBoothSlotItemLocal(op.boothId, op.slot, self.slotServerItemId[key] or 0)

	self.slotServerItemId[key] = nil

	if gClientUtils.IsNil(self.rootGo) or op.boothId == self.boothId then
		return
	end

	self.RefreshAll(self)
end

M.RegisterWidget = function(self)
	self.bindData.backBtn.luaClick = self.CreateAction(self, self.OnClickBackBtn)
	self.bindData.placeBtn.luaClick = self.CreateAction(self, self.OnClickPlaceBtn)
	self.bindData.outBtn.luaClick = self.CreateAction(self, self.OnClickOutBtn)
	self.bindData.getBtn.luaClick = self.CreateAction(self, self.OnClickGetBtn)
	self.bindData.changeBtn.luaClick = self.CreateAction(self, self.OnClickChangeBtn)
	self.bindData.changeOutBtn.luaClick = self.CreateAction(self, self.OnClickChangeOutBtn)
	self.bindData.backBtn2.luaClick = self.CreateAction(self, self.OnClickBackBtn2)
	self.bindData.levelUpBtn.luaClick = self.CreateAction(self, self.OnClickLevelUpBtn)
	self.bindData.itemList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderItemListItem)
	self.bindData.itemList.luaSimpleClick = self.CreateAction(self, self.OnSimpleClickItemList)
end

M.OnClickBackBtn = function(self)
	if self.curCollectionId == 0 then
		self.isChangeMode = false
		self.changeCollectionId = 0

		self.SelectCollection(self, 0)

		return
	end

	gPanelManager:Close(self.m_Id)
end

M.OnClickBackBtn2 = function(self)
	if not self.isChangeMode then
		self.OnClickBackBtn(self)

		return
	end

	self.isChangeMode = false
	self.changeCollectionId = 0

	self.RefreshAll(self)
end

M.OnClickPlaceBtn = function(self)
	local itemData = self.GetSelectedItemData(self)

	if not itemData or itemData.itemId ~= 0 then
		return
	end

	if not gCollectionRoomManager:IsCollectionOwned(itemData) then
		gDisplayMessageMgr:ShowMessage(MessageConfig.ItemNotExist)

		return
	end

	if gCollectionRoomManager:GetBoothSlotByItemId(self.boothId, itemData.itemId) == 0 then
		self.RefreshSelectedInfo(self)

		return
	end

	local slot = gCollectionRoomManager:GetBoothFirstEmptySlot(self.boothId)

	if slot ~= 0 then
		self.EnterChangeMode(self, itemData.id)

		return
	end

	self.RequestUpdateSlotItem(self, slot, itemData.itemId)
end

M.OnClickOutBtn = function(self)
	local itemData = self.GetSelectedItemData(self)

	if not itemData or itemData.itemId ~= 0 then
		return
	end

	local slot = gCollectionRoomManager:GetBoothSlotByItemId(self.boothId, itemData.itemId)

	if slot ~= 0 then
		self.RefreshSelectedInfo(self)

		return
	end

	self.RequestUpdateSlotItem(self, slot, 0)
end

M.OnClickGetBtn = function(self)
	local itemData = self.GetSelectedItemData(self)

	if not itemData then
		return
	end

	if itemData.hyperlinkId ~= 0 then
		print_warn("[CollectionRoomMainPanel] 藏品没配获取超链(hyperlinkid), collectionId = ", itemData.id)

		return
	end

	local hyperLinkInfo = gItemHyperLinkManager:GetSourceBehaviorByHyperLink(itemData.hyperlinkId, itemData.itemId)

	if not hyperLinkInfo then
		print_warn("[CollectionRoomMainPanel] 获取超链解析不出行为, collectionId = ", itemData.id, ", hyperlinkId = ", itemData.hyperlinkId)

		return
	end

	gCommonItemManager:OnDescItemClick(nil, hyperLinkInfo)
end

M.OnClickChangeBtn = function(self)
	local itemData = self.GetSelectedItemData(self)

	if not itemData or itemData.itemId ~= 0 then
		return
	end

	if not gCollectionRoomManager:IsCollectionOwned(itemData) then
		gDisplayMessageMgr:ShowMessage(MessageConfig.ItemNotExist)

		return
	end

	self.EnterChangeMode(self, itemData.id)
end

M.OnClickChangeOutBtn = function(self)
	if not self.isChangeMode then
		return
	end

	local newItemData = gCollectionRoomManager:GetCollectionItem(self.changeCollectionId)

	if not newItemData or newItemData.itemId ~= 0 then
		print_error("[CollectionRoomMainPanel] 更换模式下拿不到待摆放藏品, changeCollectionId = ", self.changeCollectionId)

		return
	end

	local outItemData = self:GetSelectedItemData()
	local slot = outItemData and gCollectionRoomManager:GetBoothSlotByItemId(self.boothId, outItemData.itemId) or 0

	if slot ~= 0 then
		print_warn("[CollectionRoomMainPanel] 更换时选中的藏品不在展位上, 无法确定要换下的槽位, collectionId = ", outItemData and outItemData.id)

		return
	end

	self.RequestUpdateSlotItem(self, slot, newItemData.itemId)
end

M.OnClickLevelUpBtn = function(self)
	local itemData = self.GetSelectedItemData(self)

	if not itemData or itemData.itemId ~= 0 then
		return
	end

	local slot = gCollectionRoomManager:GetBoothSlotByItemId(self.boothId, itemData.itemId)

	if slot ~= 0 then
		return
	end

	if #gCollectionRoomManager:GetCollectionUpgradeList(itemData.id) ~= 0 then
		local msgId = MessageConfig.CollectionRoomCannotUpgrade

		if msgId then
			gDisplayMessageMgr:ShowMessage(msgId)
		else
			print_warn("[CollectionRoomMainPanel] 藏品不支持升级(UpgradeGroupID 为空), 且 MessageConfig 缺少对应提示, collectionId = ", itemData.id)
		end

		return
	end

	local itemId = itemData.itemId

	self.FlushSlotOps(self, function ()
		if gClientUtils.IsNil(self.rootGo) then
			return
		end

		local curSlot = gCollectionRoomManager:GetBoothSlotByItemId(self.boothId, itemId)

		if curSlot ~= 0 then
			return
		end

		gPanelManager:CheckShow(gPanelId.COLLECTION_ROOM_LEVEL_UP, {
			boothId = self.boothId,
			slot = curSlot
		})
	end)
end

M.EnterChangeMode = function(self, collectionId)
	self.isChangeMode = true
	self.changeCollectionId = collectionId

	self.RefreshAll(self)
end

M.OnSimpleRenderItemListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local itemData = self.collectionList[index + 1]

	if not itemData then
		store.name = ""
		store.itemIcon = 0
		store.qualityCtrl = self.qualityCtrlEnum.noquality
		store.level = ""
		store.canChangeCtrl = ItemCanChangeCtrl._false
		store.typeCtrl = ItemTypeCtrl.Lock
		btn.isSelected = false

		return
	end

	store.name = itemData.name
	store.itemIcon = itemData.iconId
	store.qualityCtrl = itemData.quality or self.qualityCtrlEnum.noquality
	local slot = gCollectionRoomManager:GetBoothSlotByItemId(self.boothId, itemData.itemId)
	local owned = gCollectionRoomManager:IsCollectionOwned(itemData)
	store.level = slot == 0 and tostring(gCollectionRoomManager:GetBoothSlotLevel(self.boothId, slot)) or ""
	store.canChangeCtrl = self.isChangeMode and slot == 0 and ItemCanChangeCtrl._true or ItemCanChangeCtrl._false

	if not owned then
		store.typeCtrl = ItemTypeCtrl.NotGet
	elseif slot == 0 then
		store.typeCtrl = ItemTypeCtrl.Normal
	else
		store.typeCtrl = ItemTypeCtrl.CanPlace
	end

	btn.isSelected = itemData.id ~= self.curCollectionId
end

M.OnSimpleClickItemList = function(self, btn, index)
	local itemData = self.collectionList[index + 1]

	if not itemData then
		return
	end

	if self.isChangeMode and gCollectionRoomManager:GetBoothSlotByItemId(self.boothId, itemData.itemId) ~= 0 then
		return
	end

	if itemData.id ~= self.curCollectionId then
		return
	end

	self.SelectCollection(self, itemData.id)
end

M.SelectCollection = function(self, collectionId)
	self.curCollectionId = collectionId or 0

	self.bindData.itemList:SetSimpleList(self:GetItemListCount())
	self:RefreshSelectedInfo()
	self:ApplyPreviewCamera(self.curCollectionId)
end
