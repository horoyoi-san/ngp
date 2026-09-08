-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\HousePropertyPanelStore.lua
-- Decompiled from: 01807_HousePropertyPanelStore.lua_064421a3ebbf.luajit

local MoneyType = UX.Game.MoneyType
C_HousePropertyPanelStore = DefClass("C_HousePropertyPanelStore", C_HousePropertyPanelStore, C_StoreGroup)
GroupName2Class.HousePropertyPanelStore = C_HousePropertyPanelStore
local M = C_HousePropertyPanelStore
local ANIM_CUT = "fx_s_houseadpanel_cut"

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
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
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	self.SubGroup.MoneyTemplateStore:SetData(MoneyType.Money)

	self.openedListPage = false
	local houseId = data and data.houseId

	if houseId and houseId == 0 then
		self.selectedHouseId = houseId

		gMapSubSystem_Entrance:TrySelectHouseElementOnBigMap(houseId)

		self.bindData.tabRect.selectedIndex = 1
	else
		self.selectedHouseId = nil
		self.bindData.tabRect.selectedIndex = 0
	end
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.tabRect.OnRenderTab = self.CreateAction(self, self.OnTabRectRender)
end

M.OnTabRectRender = function(self, index, widget)
	self.curWidget = widget
end

M.OnBackBtnClick = function(self)
	gPanelManager:Close(self.m_Id)
	gPanelManager:Close(gPanelId.S_NEW_MAP_PANEL)
end

M.MarkListPageOpened = function(self)
	self.openedListPage = true
end

M.HasOpenedListPage = function(self)
	return self.openedListPage ~= true
end

M.OnSelectHouse = function(self, houseId)
	if self.selectedHouseId ~= houseId then
		return
	end

	self.selectedHouseId = houseId

	if self.bindData.tabRect.selectedIndex ~= 1 then
		local store = gStoreManager:GetStoreGroup(self.curWidget.Store)

		if store and store.RefreshHouseId then
			store.RefreshHouseId(store)
		end
	else
		self.bindData.tabRect.selectedIndex = 1
	end

	if self.bindData.panelAnim then
		gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnim, ANIM_CUT)
	end

	gMapSubSystem_Entrance:TrySelectHouseElementOnBigMap(houseId)
end

M.GoBackToListPage = function(self)
	self.selectedHouseId = nil

	gMapSubSystem_Entrance:TrySelectHouseElementOnBigMap(nil)

	self.bindData.tabRect.selectedIndex = 0
end

M.GoToFurniturePage = function(self)
	self.bindData.tabRect.selectedIndex = 2
end

M.GoBackToDetailPage = function(self)
	self.bindData.tabRect.selectedIndex = 1
end
