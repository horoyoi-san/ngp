-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PlayerSceneEditSwitchCharacterStore.lua
-- Decompiled from: 00779_PlayerSceneEditSwitchCharacterStore.lua_7ef41b41c095.luajit

C_PlayerSceneEditSwitchCharacterStore = DefClass("C_PlayerSceneEditSwitchCharacterStore", C_PlayerSceneEditSwitchCharacterStore, C_StoreGroup)
GroupName2Class.PlayerSceneEditSwitchCharacterStore = C_PlayerSceneEditSwitchCharacterStore
local M = C_PlayerSceneEditSwitchCharacterStore

M.ctor = function(self)
	self.itemList = {}
	self.selectedIds = {}
	self.onChangeCallback = nil
	self.onCloseCallback = nil
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
	self.blurCtrlEnum = {
		["^\\xad\\xa7\\xa1\\xb3"] = 0,
		["O\\xaf\\xab\\xa4\\xb3"] = 1
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

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	self.panelId = panelId
	self.itemList = {}
	self.selectedIds = {}
	self.onChangeCallback = nil
	self.onCloseCallback = nil

	if data then
		self.onChangeCallback = data.onChangeCallback
		self.onCloseCallback = data.onCloseCallback

		if data.selectedSpiritIds then
			for _, id in ipairs(data.selectedSpiritIds) do
				self.selectedIds[id] = true
			end
		end
	end

	self.bindData.blurCtrl = self.blurCtrlEnum.scene

	self.InitCharacterList(self)
end

M.OnClose = function(self)
	self.onChangeCallback = nil
	self.itemList = {}
	self.selectedIds = {}
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.backBtn.luaClick = self.CreateAction(self, self.OnClickBackBtn)
	self.bindData.backBtn2.luaClick = self.CreateAction(self, self.OnClickBackBtn)
	self.bindData.itemList.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderItemListItem)
	self.bindData.itemList.luaSimpleClick = self.CreateAction(self, self.OnClickItemList)
end

M.InitCharacterList = function(self)
	self.itemList = {}
	local lingList = gSpiritManager:GetAllSpiritList()

	for i = 1, #lingList do
		local card = lingList[i]

		table.insert(self.itemList, {
			Id = card.Id,
			iconId = card.sIcon
		})
	end

	self.bindData.itemList:SetSimpleList(#self.itemList)
end

M.OnRenderItemListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local data = self.itemList[index + 1]

	if not data then
		return
	end

	store.iconId = data.iconId or 0
	btn.isSelected = self.selectedIds[data.Id] ~= true
end

M.OnClickItemList = function(self, btn, index)
	local data = self.itemList[index + 1]

	if not data then
		return
	end

	if self.selectedIds[data.Id] then
		local selectedCount = 0

		for _ in pairs(self.selectedIds) do
			selectedCount = selectedCount + 1
		end

		if selectedCount < 1 then
			gDisplayMessageMgr:ShowMessage(LTConfig.ImageConfig.MinCharacterLimitReached)

			btn.isSelected = true

			return
		end

		self.selectedIds[data.Id] = nil
		btn.isSelected = false

		if gPlayerProfileSceneEditManager:GetSelectedSpiritId() ~= data.Id then
			local editStore = gStoreManager:GetStoreGroup("PlayerProfileSceneEditPanelStore")

			if editStore then
				editStore.OnClickExitEditBtn(editStore)
			end
		end

		gPlayerProfileSceneEditManager:RemoveCharacterBySpiritIdWithUndo(data.Id)
	else
		local result = gPlayerProfileSceneEditManager:AddCharacterModel(data.Id)

		if result ~= false then
			btn.isSelected = false

			return
		end

		self.selectedIds[data.Id] = true
		btn.isSelected = true
	end
end

M.GetSelectedList = function(self)
	local result = {}

	for id, _ in pairs(self.selectedIds) do
		table.insert(result, id)
	end

	return result
end

M.OnClickBackBtn = function(self)
	if self.onCloseCallback then
		self.onCloseCallback()
	end

	gPanelManager:Close(self.panelId)
end
