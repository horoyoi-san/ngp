-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\SignalCirclePanelStore.lua
-- Decompiled from: 01341_SignalCirclePanelStore.lua_6fa14064054d.luajit

C_SignalCirclePanelStore = DefClass("C_SignalCirclePanelStore", C_SignalCirclePanelStore, C_StoreGroup)
GroupName2Class.SignalCirclePanelStore = C_SignalCirclePanelStore
local M = C_SignalCirclePanelStore

M.DefineAllVariables = function(self)
	self.SELECT_MODE = {
		["k\\x8f\\x8e\\x9c\\x93"] = 0,
		["NH~"] = 1
	}
	self.SHOW_TIPS_CTRL = {
		["\\xfd\\xfe2<+\\xc5"] = 0,
		["\\xafLB"] = 2,
		["\\xeb\\xfe$1?\\xd4"] = 3,
		["/m\\xbd\\xab\\xa0u"] = 1,
		[".m\\xbc\\xa1\\xb5d"] = 4
	}
	self.ASSEMBLY_STATE = {
		["qb\\Eo=8<"] = 2,
		["\\x99\\x94(\\x84\\\\xd0"] = 3,
		["\\xfd\\xfe2<+\\xc5"] = 0,
		["=l\\xb5\\xa7\\xadf"] = 1
	}
	self.selectedIndex = 0
	self.selectedBtn = nil
	self.selectedStore = nil
	self.parentStore = nil
	self.targetPageIndex = 1
	self.MAX_SLOT_COUNT = 8
	self.signalTabList = {}
	self.curDragIndex = 0

	table.clear(self.signalTabList)

	for i = 1, 2 do
		table.insert(self.signalTabList, i)
	end
end

M.ctor = function(self)
	self.shortChatWheel = {}
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
	self.bindData.signalTabList:SetSimpleList(#self.signalTabList)
	self.bindData.signalTabList:SelectItem(self.targetPageIndex - 1, false)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.RegisterWidget = function(self)
	self.bindData.signalTabList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderSignalTabListItem")
	self.bindData.signalTabList.luaSelectedChanged = self.CreateAction(self, "OnSwitchSignalPage")

	for i = 1, self.MAX_SLOT_COUNT do
		local onlineSignalItem = self.bindData["onlineSignalItem" .. i]
		onlineSignalItem.luaClick = self.CreateActionWithArgs(self, self.OnSelectSignalItem, i)
		onlineSignalItem.luaBeginDrag = self.CreateActionWithArgs(self, self.OnBeginDragItem, i)
		onlineSignalItem.luaEndDrag = self.CreateAction(self, self.OnEndDragItem)
		onlineSignalItem.luaEnterDropWidget = self.CreateAction(self, self.OnDragEnterDropItem)
		onlineSignalItem.luaExitDropWidget = self.CreateAction(self, self.OnDragExitDropItem)
	end
end

M.OnSelectSignalItem = function(self, index)
	if self.parentStore then
		self.parentStore:OnSlotClicked(index)
	end
end

M.SelectSlot = function(self, index)
	local btn = self.bindData["onlineSignalItem" .. index]

	if not btn then
		return
	end

	if self.selectedStore then
		self.selectedStore.SelectingActiveCtrl = self.SELECT_MODE.FALSE
	end

	self.selectedIndex = index
	self.selectedBtn = btn
	local shortChatWheels = self.parentStore:GetCurShortChatWheels()
	local id = shortChatWheels[self:GetItemIndex(self.selectedBtn)] and shortChatWheels[self:GetItemIndex(self.selectedBtn)].Id or 0
	local cfg = LTConfig.LinkShortChatWheelConfig.GetConfig(id)

	if cfg then
		self.RefreshCircleCtrl(self, self.SHOW_TIPS_CTRL.SELECT)
	else
		self.RefreshCircleCtrl(self, self.SHOW_TIPS_CTRL.DEFAULT)
	end

	self.selectedStore = gStoreManager:GetStoreGroup("OnlineSignalItemStore"):GetStoreByWidget(self.selectedBtn)

	if self.selectedStore then
		self.selectedStore.SelectingActiveCtrl = self.SELECT_MODE.TRUE
	end
end

M.OnBeginDragItem = function(self, index)
	local shortChatWheels = self.parentStore:GetCurShortChatWheels()
	local btn = self.bindData["onlineSignalItem" .. index]
	self.selectedIndex = index
	self.selectedBtn = btn
	self.bindData.circleDropStateCtrl = 1

	self:RefreshCircleCtrl(self.SHOW_TIPS_CTRL.SELECT)

	local id = shortChatWheels[index + self:GetStartIndex()] and shortChatWheels[index + self:GetStartIndex()].Id or 0
	local cfg = LTConfig.LinkShortChatWheelConfig.GetConfig(id)

	if cfg then
		self.curDragIndex = index + self:GetStartIndex()
		local _, icon = self:GetWheelItemNameAndIcon(cfg)

		self.parentStore:SetDragIconId(icon)
	else
		self.curDragIndex = 0
	end
end

M.OnEndDragItem = function(self, dropWidget)
	self.bindData.circleDropStateCtrl = 0

	if self.curDragIndex == 0 then
		self.parentStore:SetCurDropWidget(nil)

		self.bindData.assemblyState = self.ASSEMBLY_STATE.DEFAULT

		self:RefreshCircleCtrl(self.SHOW_TIPS_CTRL.DEFAULT)

		local infos = {}

		if dropWidget and dropWidget.Store ~= "OnlineSignalItemStore" then
			local shortChatWheels = self.parentStore:GetCurShortChatWheels()
			local beginId = shortChatWheels[self:GetItemIndex(dropWidget)] and shortChatWheels[self:GetItemIndex(dropWidget)].Id or 0
			local endId = shortChatWheels[self.curDragIndex] and shortChatWheels[self.curDragIndex].Id or 0
			local beginInfo = {
				index = self.curDragIndex,
				id = beginId
			}
			local endInfo = {
				index = self:GetItemIndex(dropWidget),
				id = endId
			}

			table.insert(infos, beginInfo)
			table.insert(infos, endInfo)
			self.parentStore:SetShortChatWheel(infos)
		elseif not dropWidget or dropWidget.Store == "SignalCIrcleRemovingStore" then
			local beginInfo = {
				["\t\r"] = 0,
				index = self.curDragIndex
			}

			table.insert(infos, beginInfo)
			self.parentStore:SetShortChatWheel(infos)
		end

		self.curDragIndex = 0

		self.parentStore:SetDragIconId(0)
	end
end

M.OnDragEnterDropItem = function(self, dropWidget)
	if self.curDragIndex == 0 then
		if dropWidget and self.curDragIndex == self.GetItemIndex(self, dropWidget) then
			self.parentStore:SetCurDropWidget(dropWidget)
		end

		if dropWidget then
			if dropWidget.Store ~= "OnlineSignalItemStore" then
				if self.curDragIndex == self.GetItemIndex(self, dropWidget) then
					self.RefreshCircleCtrl(self, self.SHOW_TIPS_CTRL.REPLACE)
				else
					self.RefreshCircleCtrl(self, self.SHOW_TIPS_CTRL.SELECT)
				end
			else
				self.RefreshCircleCtrl(self, self.SHOW_TIPS_CTRL.SELECT)
			end
		else
			self.RefreshCircleCtrl(self, self.SHOW_TIPS_CTRL.REMOVE)
		end
	end
end

M.OnDragExitDropItem = function(self, dropWidget)
	if self.curDragIndex == 0 then
		if dropWidget and self.curDragIndex == self.GetItemIndex(self, dropWidget) then
			self.parentStore:SetCurDropWidget(nil)
		end

		self.RefreshCircleCtrl(self, self.SHOW_TIPS_CTRL.REMOVE)
	end
end

M.GetWheelItemNameAndIcon = function(self, cfg)
	if cfg and cfg.Type ~= LTConfig.LinkShortChatWheelConfig.TypeType.Motion then
		local actionCfg = LTConfig.ActionItemConfig.GetConfig(cfg.ActionItemId)

		if actionCfg then
			return actionCfg.Name, actionCfg.Icon
		end
	end

	return cfg and cfg.ShortName, cfg and cfg.Icon
end

M.SetItemData = function(self, item, id)
	local store = gStoreManager:GetStoreGroup(item.Store):GetStoreByWidget(item)

	if store then
		if id ~= 0 then
			store.iconId = 0
			store.IsEmptyCtrl = 1
			item.draggable = false
		else
			local cfg = LTConfig.LinkShortChatWheelConfig.GetConfig(id)

			if cfg then
				local _, icon = self.GetWheelItemNameAndIcon(self, cfg)
				store.iconId = icon
				store.IsEmptyCtrl = 0
			end

			item.draggable = true
		end

		store.QualityCtrl = 7
	end
end

M.RefreshItemState = function(self, item, isCurDropWidget)
	if item and item.Store ~= "OnlineSignalItemStore" then
		local shortChatWheels = self.parentStore:GetCurShortChatWheels()
		local store = gStoreManager:GetStoreGroup("OnlineSignalItemStore"):GetStoreByWidget(item)

		if store and self.parentStore then
			if self.curDragIndex == self.GetItemIndex(self, item) and isCurDropWidget then
				local id = shortChatWheels[self:GetItemIndex(item)] and shortChatWheels[self:GetItemIndex(item)].Id or 0

				if id == 0 then
					store.assemblyState = 2
				else
					store.assemblyState = 1
				end
			else
				if isCurDropWidget then
					self.RefreshCircleCtrl(self, self.SHOW_TIPS_CTRL.SELECT)
				end

				store.assemblyState = 0
			end
		end
	end
end

M.GetItemIndex = function(self, item)
	local index = item and tonumber(item.name:sub(-1)) or 1

	return index + self:GetStartIndex()
end

M.RefreshCircleCtrl = function(self, ctrlState)
	self.bindData.showTipsCtrl = ctrlState
	local shortChatWheels = self.parentStore:GetCurShortChatWheels()

	if self.bindData.showTipsCtrl ~= self.SHOW_TIPS_CTRL.DEFAULT then
		-- Nothing
	elseif self.bindData.showTipsCtrl ~= self.SHOW_TIPS_CTRL.SELECT then
		if self.selectedBtn then
			local id = shortChatWheels[self:GetItemIndex(self.selectedBtn)] and shortChatWheels[self:GetItemIndex(self.selectedBtn)].Id or 0
			local cfg = LTConfig.LinkShortChatWheelConfig.GetConfig(id)

			if not cfg then
				self.RefreshCircleCtrl(self, self.SHOW_TIPS_CTRL.DEFAULT)

				return
			end

			local name = self.GetWheelItemNameAndIcon(self, cfg)
			self.bindData.signalName = name
			self.bindData.signalType = LTConfig.LinkShortChatTypeConfig.GetConfig(cfg.Type).Title

			if cfg.Type ~= LTConfig.LinkShortChatWheelConfig.TypeType.Mark then
				self.bindData.showKeyCtrl = 1
			else
				self.bindData.showKeyCtrl = 0
			end
		end
	elseif self.bindData.showTipsCtrl ~= self.SHOW_TIPS_CTRL.ADD then
		local id = self.parentStore:GetCurDragId()
		local cfg = LTConfig.LinkShortChatWheelConfig.GetConfig(id)
		local name = self:GetWheelItemNameAndIcon(cfg)
		self.bindData.signalNameAdd = name
	elseif self.bindData.showTipsCtrl ~= self.SHOW_TIPS_CTRL.REPLACE then
		if self.curDragIndex == 0 then
			local beginId = shortChatWheels[self.curDragIndex].Id
			local beginCfg = LTConfig.LinkShortChatWheelConfig.GetConfig(beginId)
			local beginName = self.GetWheelItemNameAndIcon(self, beginCfg)
			self.bindData.signalNameBefore = beginName
		else
			local beginId = self.parentStore:GetCurDragId()
			local beginCfg = LTConfig.LinkShortChatWheelConfig.GetConfig(beginId)
			local beginName = self:GetWheelItemNameAndIcon(beginCfg)
			self.bindData.signalNameBefore = beginName
		end

		local dropWidget = self.parentStore:GetCurDropWidget()

		if dropWidget then
			local endIndex = self.GetItemIndex(self, dropWidget)
			local endId = shortChatWheels[endIndex].Id

			if endId == 0 then
				local endCfg = LTConfig.LinkShortChatWheelConfig.GetConfig(endId)
				local endName = self.GetWheelItemNameAndIcon(self, endCfg)
				self.bindData.signalNameAfter = endName
			else
				self.bindData.signalNameAfter = ""
			end
		end
	elseif self.bindData.showTipsCtrl ~= self.SHOW_TIPS_CTRL.REMOVE and self.curDragIndex == 0 then
		local id = shortChatWheels[self.curDragIndex].Id
		local cfg = LTConfig.LinkShortChatWheelConfig.GetConfig(id)
		local name = self.GetWheelItemNameAndIcon(self, cfg)
		self.bindData.signalNameRemove = name
	end

	if self.bindData.showTipsCtrl ~= self.SHOW_TIPS_CTRL.REMOVE then
		self.bindData.assemblyState = self.ASSEMBLY_STATE.REMOVING
	else
		self.bindData.assemblyState = self.ASSEMBLY_STATE.DEFAULT
	end
end

M.RebuildCircleView = function(self)
	if self.parentStore then
		local shortChatWheels = self.parentStore:GetCurShortChatWheels()

		if shortChatWheels then
			for i = 1, self.MAX_SLOT_COUNT do
				local item = self.bindData["onlineSignalItem" .. i]
				local id = shortChatWheels[i + self:GetStartIndex()] and shortChatWheels[i + self:GetStartIndex()].Id or 0

				self:SetItemData(item, id)
			end
		end
	end
end

M.SetParentStore = function(self, store)
	self.parentStore = store
end

M.ClearSelection = function(self)
	if self.selectedStore then
		self.selectedStore.SelectingActiveCtrl = self.SELECT_MODE.FALSE
		self.selectedStore = nil
	end

	self.selectedIndex = 0
	self.selectedBtn = nil

	self.RefreshCircleCtrl(self, self.SHOW_TIPS_CTRL.DEFAULT)
end

M.OnSimpleRenderSignalTabListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup("CoreHudCircleStore"):GetStoreByWidget(btn)
	local item = self.signalTabList[index + 1]

	if item and store then
		store.text = item
	end
end

M.SwitchSignalTypeLoop = function(self)
	local to = self.targetPageIndex + 1

	if to <= #self.signalTabList then
		to = 1
	end

	self.bindData.signalTabList:SelectItem(to - 1)
end

M.OnSwitchSignalPage = function(self)
	local index = self.bindData.signalTabList.selectedIndex + 1
	local up = index <= self.targetPageIndex
	self.targetPageIndex = index

	self:RebuildCircleView()
	self:PlaySwitchAnime(up)
end

M.ResetSignalPage = function(self)
	if self.targetPageIndex == 1 then
		self.bindData.signalTabList:SelectItem(0)
	else
		self.RebuildCircleView(self)
	end
end

M.PlaySwitchAnime = function(self, up)
	gCS.LuaUtils.PlayAnimationByName(self.bindData.anime, up and self.signalSwitchAnimeUp or self.signalSwitchAnimeDown)
end

M.GetStartIndex = function(self)
	return (self.targetPageIndex - 1) * self.MAX_SLOT_COUNT
end
