-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\FashionPortalPanelStore.lua
-- Decompiled from: 01904_FashionPortalPanelStore.lua_af0ecc8b45f6.luajit

local TextScriptTextConfig = LTConfig.TextScriptTextConfig
C_FashionPortalPanelStore = DefClass("C_FashionPortalPanelStore", C_FashionPortalPanelStore, C_StoreGroup)
GroupName2Class.FashionPortalPanelStore = C_FashionPortalPanelStore
local M = C_FashionPortalPanelStore
local TabType = gDressSceneManager.TabType
local TabName = {
	[TabType.Fashion] = "89901473",
	[TabType.Makeup] = "89901472",
	[TabType.Weapon] = "89901549"
}

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.tabList = {}
	self.tabIndex = 1
	self._activeStore = nil
end

M.DefineAllEnumsAutoGen = function(self)
	self.hidePageCtrlEnum = {
		["r+y^"] = 0,
		["i*rL"] = 1
	}
	self.showTopTabCtrlEnum = {
		["r+y^"] = 1,
		["i*rL"] = 0
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.hidePageCtrlEnum = nil
	self.showTopTabCtrlEnum = nil
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
	self.bindData.showTopTabCtrl = gMainPageManager:CheckMainPageShowById(gPanelId.S_FASHION_PORTAL_PANEL) and self.showTopTabCtrlEnum.hide or self.showTopTabCtrlEnum.show

	if data and data.unit then
		self.spiritContext = gDressManager:GetSpiritContext(data.spiritId, nil, data.unit)

		self:RefreshTopTab()

		self.bindData.mainTab.selectedIndex = 0
		local hasInit, widget = self.bindData.mainTab:TryGetTabInstance(0, nil)

		if hasInit then
			self.OnMainTabRender(self, 0, widget)
		end

		if data.weatherCb then
			data.weatherCb()
		end
	else
		local spiritId = gCS.MyPlayerManager.PlayerUnit.ClientData.cardId
		slot4 = gDressManager

		slot4:EnterDressScene(spiritId, 1, function (unit, weatherCb)
			weatherCb()

			self.spiritContext = gDressManager:GetSpiritContext(spiritId, nil, unit)

			self:RefreshTopTab()

			self.bindData.mainTab.selectedIndex = 0
		end)
	end
end

M.OnClose = function(self)
	self._activeStore = nil

	gDressManager:ExitDressScene()
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.closeBtn.luaClick = self.CreateAction(self, self.OnClickCloseBtn)
	self.bindData.mainTab.OnRenderTab = self.CreateAction(self, self.OnMainTabRender)
end

M.OnClickCloseBtn = function(self)
	if self.tabIndex ~= TabType.Weapon and self._activeStore and self._activeStore.bindData and self._activeStore.bindData.pageCtrl ~= 1 then
		self._activeStore.bindData.pageCtrl = 0

		return
	end

	gPanelManager:Close(self.m_Id)
end

M.OnMainTabRender = function(self, index, widget)
	local store = gStoreManager:GetStoreGroup(widget.Store)

	if store then
		self._activeStore = store
		local unit = gDressSceneManager.currentModelUnit or self.spiritContext.unit

		store:OnShow({
			unit = unit,
			hideCb = function (hide)
				self.bindData.hidePageCtrl = hide
			end
		})
	end
end

M.OnTabListChange = function(self, data)
	self.tabIndex = data.selectedIndex + 1
	self.currentTabData = self.tabList[self.tabIndex]

	self.RefreshTabRect(self)
end

M.OnSimpleRenderTabListItem = function(self, btn, index)
	local data = self.tabList[index + 1]
	local store = gStoreManager:GetStoreGroup("ControllerTab_Template"):GetStoreByWidget(btn)

	if store then
		store.title = data.name
	end
end

M.RefreshTopTab = function(self)
	table.clear(self.tabList)

	for i = 1, 3 do
		local data = {
			id = i,
			name = TextScriptTextConfig.GetConfig(TabName[i]).Text
		}

		table.insert(self.tabList, data)
	end

	self.SubGroup.CommonTabSingleStore:SetData(self.tabList, nil, self.tabIndex - 1, nil, self:CreateAction(self.OnTabListChange), self:CreateAction(self.OnSimpleRenderTabListItem), 1)
end

M.RefreshTabRect = function(self)
	self.bindData.mainTab.selectedIndex = self.tabIndex - 1
end
