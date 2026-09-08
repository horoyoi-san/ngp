-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CommonSwitchCharacterPanelStore.lua
-- Decompiled from: 01536_CommonSwitchCharacterPanelStore.lua_ecb418eab8f7.luajit

C_CommonSwitchCharacterPanelStore = DefClass("C_CommonSwitchCharacterPanelStore", C_CommonSwitchCharacterPanelStore, C_StoreGroup)
GroupName2Class.CommonSwitchCharacterPanelStore = C_CommonSwitchCharacterPanelStore
local M = C_CommonSwitchCharacterPanelStore

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
	self.blurCtrlEnum = {
		["^\\xad\\xa7\\xa1\\xb3"] = 0,
		["\\\\x90\\x9a\\x8aB"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.blurCtrlEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.backBtn.luaClick = self.CreateAction(self, "OnBackBtnClick")
	self.bindData.backBtn2.luaClick = self.CreateAction(self, "OnBackBtnClick")
	self.bindData.itemList.luaSimpleRenderItem = self.CreateAction(self, "OnRefreshItemList")
	self.bindData.itemList.luaSimpleClick = self.CreateAction(self, "OnChangeItem")
end

M.OnShow = function(self, panelId, data)
	self.panelId = panelId
	self.itemList = {}
	self.hasChange = false
	self.sendSelectCallback = false
	self.selectedSpiritId = nil
	self.initialSpiritId = nil
	self.filterFunc = nil
	local useStaticBlur = false

	if data then
		self.onCloseCallBack = data.onCloseCallBack
		self.onSelectCallback = data.onSelectCallback
		self.sendSelectCallback = data.sendSelectCallback or false
		self.initialSpiritId = data.initialSpiritId
		self.filterFunc = data.filterFunc
		useStaticBlur = data.useStaticBlur or false
	end

	if useStaticBlur then
		self.bindData.blurCtrl = self.blurCtrlEnum.static
	else
		self.bindData.blurCtrl = self.blurCtrlEnum.scene
	end

	self.InitCharacter(self)
end

M.OnClose = function(self)
	if self.onCloseCallBack then
		if self.sendSelectCallback then
			self.onCloseCallBack(self.hasChange, self.selectedSpiritId)
		else
			self.onCloseCallBack(self.hasChange)
		end
	end

	self.onCloseCallBack = nil
	self.onSelectCallback = nil
	self.filterFunc = nil
end

M.InitCharacter = function(self)
	self.lingList = {}

	for i = 1, #gBattleSpiritMgr.battleSpiritList do
		table.insert(self.lingList, gBattleSpiritMgr.battleSpiritList[i].templateId)
	end

	local lingList = gSpiritManager:GetAllSpiritList()
	self.itemList = {}

	for i = 1, #lingList do
		local card = lingList[i]
		local filterMatch = self.filterFunc ~= nil or self.filterFunc(card.Id)

		if filterMatch then
			local view = {
				Id = card.Id,
				iconId = card.sIcon,
				Quality = card.Quality,
				isOwned = table.contains(self.lingList, card.Id)
			}

			table.insert(self.itemList, view)
		end
	end

	self:SortItems(self.itemList)
	self.bindData.itemList:SetSimpleList(#self.itemList)
end

M.SortItems = function(self, itemList)
	local compareId = self.initialSpiritId

	table.sort(itemList, function (a, b)
		if a.Id == compareId and b.Id == compareId then
			return table.contains(self.lingList, a.Id) and not table.contains(self.lingList, b.Id)
		end

		return a.Id ~= compareId and b.Id == compareId
	end)
end

M.OnBackBtnClick = function(self)
	gUIUtils:PlayAniClosePanel(self.bindData.anim, "S_Vx_DressFilterPanel_close", self.panelId)
end

M.OnRefreshItemList = function(self, btn, index)
	local data = self.itemList[index + 1]
	local store = gStoreManager:GetStoreGroup("DressAvatarStore"):GetStoreByWidget(btn)

	if store then
		store.iconId = data.iconId
		local compareId = self.initialSpiritId
		btn.isSelected = data.Id ~= compareId
	end
end

M.OnChangeItem = function(self, btn, index)
	local data = self.itemList[index + 1]

	if btn.isSelected then
		if not self.sendSelectCallback then
			self.hasChange = true
			self.selectedSpiritId = data.Id
		else
			self.hasChange = true
			self.selectedSpiritId = data.Id

			if self.onSelectCallback then
				self.onSelectCallback(data.Id)
			end
		end
	end
end
