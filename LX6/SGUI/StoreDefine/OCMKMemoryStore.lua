-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\OCMKMemoryStore.lua
-- Decompiled from: 00950_OCMKMemoryStore.lua_416e658d5e18.luajit

C_OCMKMemoryStore = DefClass("C_OCMKMemoryStore", C_OCMKMemoryStore, C_StoreGroup)
GroupName2Class.OCMKMemoryStore = C_OCMKMemoryStore
local M = C_OCMKMemoryStore
local MemoryConfig = LTConfig.MeccaGrandpaRobotMemoryConfig
local MemoryType = MemoryConfig.MemoryTypeType
local MeccaGrandpaRobotConfig = LTConfig.MeccaGrandpaRobotConfig
local TAB = {
	["bpM[k04!"] = 2,
	["\\xe9\\xfe&.1\n\\xd0"] = 3,
	["1m\\xbc\\xa1\\xb1x"] = 1
}
local ITEM = {
	["^Nx"] = 5,
	["y\\x87\\x96\\x83\\x93"] = 0,
	["pb\\H|?%=\n"] = 3,
	["^I~"] = 1,
	["bpM[k04!"] = 4,
	["\\x8d\\x83$\\x8cG\\xd0"] = 2
}

M.ctor = function(self)
	self.mgr = gOCMgr
end

M.DefineAllVariables = function(self)
	self.currentTab = TAB.MEMORY
	self.displayItems = {}
	self.logListItems = {}
	self._tabs = {
		{
			id = TAB.MEMORY,
			title = MeccaGrandpaRobotConfig.TabTitleMemory
		},
		{
			id = TAB.PERSONA,
			title = MeccaGrandpaRobotConfig.TabTitlePersona
		},
		{
			id = TAB.AWARENESS,
			title = MeccaGrandpaRobotConfig.TabTitleAwareness
		}
	}
	self.parentStore = nil
end

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
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
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	self.panelId = panelId

	self.InitTabList(self)
	self.RefreshAll(self)
	self.OnMemoryTabViewed(self)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.OC_MEMORY_CHANGE] = self.CreateAction(self, self.OnMemoryChange)
	}
end

M.RegisterWidget = function(self)
	self.bindData.editBtn.luaClick = self.CreateAction(self, self.OnClickEditBtn)
	self.bindData.infoList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderInfoListItem)
	self.bindData.infoList.luaSimpleDynamicRenderItem = self.CreateAction(self, self.OnSimpleRenderInfoListItem)
	self.bindData.infoList.onGetTIndex = self.CreateAction(self, self.OnGenTIndex)
	self.bindData.logList.luaRenderItem = self.CreateAction(self, self.OnSimpleRenderLogItem)
	self.bindData.logList.onGetTIndex = self.CreateAction(self, self.OnGetLogItemTIndex)
end

M.OnClickEditBtn = function(self)
	if self.parentStore then
		self.parentStore:ConfirmCurrent()
	end
end

M.OnGenTIndex = function(self, index)
	return self.displayItems[index + 1].type
end

M.OnSimpleRenderInfoListItem = function(self, btn, index)
	local item = self.displayItems[index + 1]

	if not item then
		return
	end

	local storeGroup = gStoreManager:GetStoreGroup(btn.Store)

	if not storeGroup then
		return
	end

	local store = storeGroup.GetStoreByWidget(storeGroup, btn)

	if not store then
		return
	end

	if item.type ~= ITEM.SEPARATOR then
		return
	elseif item.type ~= ITEM.DATE then
		store.timeLabel = item.dateTimeText or item.dateText or ""
	elseif item.type ~= ITEM.FRAGMENT then
		store.titleLabel = item.title or ""

		store:Commit("descLabel", item.text or "", COMMIT_IMMEDIATELY)

		if store.itemView and item.itemId and item.itemId <= 0 then
			local renderData = gCommonItemManager:GetItemRenderData({
				itemId = item.itemId
			})

			gCommonItemManager:OnCommonItemRender(store.itemView, 0, renderData)
		end
	elseif item.type ~= ITEM.TITLE then
		store:Commit("titleLabel", item.title or "", COMMIT_IMMEDIATELY)
	elseif item.type ~= ITEM.DESC then
		store:Commit("descLabel", item.text or "", COMMIT_IMMEDIATELY)
	elseif item.type ~= ITEM.AWARENESS then
		store:Commit("titleLabel", item.title or "", COMMIT_IMMEDIATELY)
	end
end

M.InitTabList = function(self)
	local tabList = {}

	for i, tab in ipairs(self._tabs) do
		table.insert(tabList, {
			id = i,
			title = tab.title
		})
	end

	self._tabInited = false

	self.SubGroup.CommonTabSingleStore:SetData(tabList, nil, 0, nil, self:CreateAction(self.OnTabChanged), self:CreateAction(self.OnRenderTabItem))

	self._tabInited = true
end

M.OnTabChanged = function(self, uList, isSub)
	local index = uList.selectedIndex

	if index >= 0 then
		return
	end

	self.currentTab = self._tabs[index + 1].id

	self.RefreshInfoList(self)

	if self._tabInited then
		self.OnMemoryTabViewed(self)
	end
end

M.OnRenderTabItem = function(self, btn, index, data, store, isSub, uList)
	store.title = data.title or ""
end

M.OnMemoryChange = function(self, eventId, data)
	if not self.STATE_EnableOnce then
		return
	end

	if not data then
		return
	end

	self.RefreshAll(self)
	self.OnMemoryTabViewed(self)
end

M.RefreshAll = function(self)
	self.RefreshDensity(self)
	self.RefreshInfoList(self)
	self.RefreshLogList(self)
end

M.RefreshDensity = function(self)
	local percent = self.mgr:GetMemoryProgressPercent() or 0
	percent = math.max(0, math.min(100, percent))
	local fmt = MeccaGrandpaRobotConfig.MemoryProgressFmt

	self.bindData:Commit("progressLabel", string.format(fmt, percent), COMMIT_IMMEDIATELY)
end

M.RefreshInfoList = function(self)
	self.displayItems = self:BuildDisplayItems(self.currentTab)

	self.bindData.infoList:SetSimpleList(#self.displayItems)
end

M.RefreshLogList = function(self)
	local pool = {}
	local unlockedList = self.mgr:GetUnlockedAwarenessList()

	for _, item in ipairs(unlockedList) do
		table.insert(pool, item.text)
	end

	self.logListItems = self.PickRandom(self, pool, 2)
	self._logPositions = {}

	if self.bindData.logList then
		self.bindData.logList:SetList(#self.logListItems)
	end
end

M.OnSimpleRenderLogItem = function(self, btn, index)
	local text = self.logListItems[index + 1]

	if not text then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if store then
		store.titleLabel = text
	end

	local count = math.max(1, #self.logListItems)
	local slotHeight = 500 / count
	local y = -250 + slotHeight * index + slotHeight / 2 - 25
	local x = math.random(-100, 100)

	btn.SetLocalPos(btn, Vector3(x, y, 0))
end

M.OnGetLogItemTIndex = function(self, index)
	return 0
end

M.PickRandom = function(self, pool, n)
	local copy = {
		unpack(pool)
	}
	local result = {}

	for _ = 1, math.min(n, #copy) do
		local i = math.random(#copy)

		table.insert(result, copy[i])
		table.remove(copy, i)
	end

	return result
end

M.BuildDisplayItems = function(self, tabId)
	local items = {}
	local entryDict = self.mgr:GetMemoryEntryDict()

	if tabId ~= TAB.MEMORY then
		local list = {}

		for memoryId, entry in pairs(entryDict) do
			local cfg = MemoryConfig.GetConfig(memoryId)

			if cfg and cfg.MemoryType ~= MemoryType.Fragment then
				table.insert(list, {
					type = cfg.BindItemId == 0 and ITEM.FRAGMENT or ITEM.TITLE,
					title = cfg.Title or "",
					text = cfg.Text or "",
					time = entry.UnlockTime or 0,
					dateText = self:FormatDate(entry.UnlockTime or 0),
					dateTimeText = self:FormatDateTime(entry.UnlockTime or 0),
					itemId = cfg.BindItemId or 0,
					memoryId = memoryId
				})
			end
		end

		table.sort(list, function (a, b)
			return b.time <= a.time
		end)

		local lastDate = nil

		for _, it in ipairs(list) do
			if it.dateText == lastDate then
				if lastDate == nil then
					table.insert(items, {
						type = ITEM.SEPARATOR
					})
				end

				lastDate = it.dateText

				table.insert(items, {
					type = ITEM.DATE,
					dateText = it.dateText,
					dateTimeText = it.dateTimeText
				})
			end

			table.insert(items, it)

			if it.type ~= ITEM.TITLE and not string.is_null_or_empty(it.text) then
				table.insert(items, {
					type = ITEM.DESC,
					text = it.text
				})
			end
		end
	elseif tabId ~= TAB.PERSONA then
		local list = {}

		for memoryId, entry in pairs(entryDict) do
			local cfg = MemoryConfig.GetConfig(memoryId)

			if cfg and cfg.MemoryType ~= MemoryType.Record then
				table.insert(list, {
					type = ITEM.TITLE,
					title = cfg.Text or "",
					showPriority = cfg.ShowPriority or 0,
					memoryId = memoryId
				})
			end
		end

		table.sort(list, function (a, b)
			return a.showPriority <= b.showPriority
		end)

		for _, it in ipairs(list) do
			table.insert(items, it)
		end
	elseif tabId ~= TAB.AWARENESS then
		local unlockedList = self.mgr:GetUnlockedAwarenessList()

		for _, item in ipairs(unlockedList) do
			table.insert(items, {
				type = ITEM.AWARENESS,
				title = item.text or ""
			})
		end
	end

	return items
end

M.FormatDate = function(self, ts)
	if not ts or ts < 0 then
		return ""
	end

	return gTimeUtils:DateFormat("%d/%02d/%02d", ts)
end

M.FormatDateTime = function(self, ts)
	if not ts or ts < 0 then
		return ""
	end

	return gTimeUtils:DateFormat("%d/%02d/%02d", ts) .. " " .. gTimeUtils:DateFormatDetail("%02d:%02d", ts)
end

M.OnMemoryTabViewed = function(self)
	if self.currentTab ~= TAB.MEMORY then
		self.mgr:ClearMemoryRedDot()
	end
end
