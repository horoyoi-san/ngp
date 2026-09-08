-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\MAClueBagPanelStore.lua
-- Decompiled from: 01793_MAClueBagPanelStore.lua_6de71e947efb.luajit

C_MAClueBagPanelStore = DefClass("C_MAClueBagPanelStore", C_MAClueBagPanelStore, C_StoreGroup)
GroupName2Class.MAClueBagPanelStore = C_MAClueBagPanelStore
local M = C_MAClueBagPanelStore
local MartialArtistRumorConfig = LTConfig.MartialArtistRumorConfig

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.TAB_TYPE = {
		["\\xafDJ"] = 0,
		["OX"] = 4,
		["\\xb9@I"] = 1,
		["M\n\\o"] = 3,
		["z\\x86\\x87\\x9d\\x93"] = 2
	}
	self.TAB_TYPE_MAP_TO_SLOT_TYPE = {
		[self.TAB_TYPE.WHO] = MartialArtistRumorConfig.SlotTypeType.who,
		[self.TAB_TYPE.WHERE] = MartialArtistRumorConfig.SlotTypeType.where,
		[self.TAB_TYPE.WHAT] = MartialArtistRumorConfig.SlotTypeType.what
	}
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
	self.InitBagData(self)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.ON_MARTIAL_ARTIST_RUMOR_BACKPACK_CHANGED] = self.CreateAction(self, "OnRumorBackpackChanged")
	}
end

M.OnRumorBackpackChanged = function(self, eventId, rumorId)
	self.RefreshContent(self)
end

M.RegisterWidget = function(self)
	self.bindData.closeBtn.luaClick = self.CreateAction(self, self.OnClickCloseBtn)
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderListItem)
end

M.OnClickCloseBtn = function(self)
	gPanelManager:Close(gPanelId.MA_CLUE_BAG)
end

M.OnSimpleRenderListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local rumorId = self.listData[index + 1]

	if not rumorId then
		return
	end

	local rumorCfg = MartialArtistRumorConfig.GetConfig(rumorId)

	if rumorCfg then
		store.title = rumorCfg.Title
		store.desc = rumorCfg.Description
		store.from = rumorCfg.SourceText
	end

	store.tagCtrl = 1
	btn.draggable = false
end

M.InitBagData = function(self)
	self.tabList = {
		{
			id = self.TAB_TYPE.ALL,
			title = LTConfig.MartialArtistConfig.BackpackAllTitle
		},
		{
			id = self.TAB_TYPE.WHO,
			title = LTConfig.MartialArtistConfig.BackpackWhoTitle
		},
		{
			id = self.TAB_TYPE.WHERE,
			title = LTConfig.MartialArtistConfig.BackpackWhereTitle
		},
		{
			id = self.TAB_TYPE.WHAT,
			title = LTConfig.MartialArtistConfig.BackpackWhatTitle
		},
		{
			id = self.TAB_TYPE.USED,
			title = LTConfig.MartialArtistConfig.BackpackUsedTitle
		}
	}
	self.curType = nil

	self.SubGroup.CommonTabSingleStore:SetData(self.tabList, nil, 0, nil, self:CreateAction(self.OnChangeTab), nil)
end

M.OnChangeTab = function(self, uList, isSub)
	self.ChangeListContent(self, self.tabList[uList.selectedIndex + 1])
end

M.ChangeListContent = function(self, data)
	if data and self.curType == data.id then
		self.curType = data.id

		self.RefreshContent(self)
	end
end

M.RefreshContent = function(self)
	self.listData = {}

	if self.curType ~= self.TAB_TYPE.ALL then
		self.listData = gMartialArtistManager:GetAllRumorsInBackpack(true)
	elseif self.curType ~= self.TAB_TYPE.USED then
		self.listData = gMartialArtistManager:GetAllEquipRumors()
	else
		local slotType = self.TAB_TYPE_MAP_TO_SLOT_TYPE[self.curType]

		if slotType then
			self.listData = gMartialArtistManager:GetAllRumorsInBackpackBySlotType(slotType, true)
		end
	end

	self.bindData.list:SetSimpleList(#self.listData)
end
