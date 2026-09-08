-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\GalleryWeaponPreviewPanel.lua
-- Decompiled from: 01732_GalleryWeaponPreviewPanel.lua_51426532709e.luajit

local SceneitemConfig = LTConfig.SceneitemConfig
local WeaponPediaTabConfig = LTConfig.SceneitemWeaponPediatabConfig
local TextConfig = LTConfig.TextConfig
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}
C_GalleryWeaponPreviewPanel = DefClass("C_GalleryWeaponPreviewPanel", C_GalleryWeaponPreviewPanel, C_StoreGroup)
GroupName2Class.GalleryWeaponPreviewPanel = C_GalleryWeaponPreviewPanel
local M = C_GalleryWeaponPreviewPanel

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.tab1List = {}
	self.tab1IndexToTab2List = {}
	self.tab2IdToWeaponIds = {}
	self.weaponTypeToTab2Id = {}
	self.currentTab1Index = nil
	self.currentTab2Index = nil
	self.currentWeaponIndex = nil
	self.currentWeaponId = nil
	self.currentTab2List = {}
	self.currentWeaponIds = {}
	self.tooltipStore = nil
	self.rootArea = nil
end

M.DefineAllEnumsAutoGen = function(self)
	self.hideCtrlEnum = {
		["r+y^"] = 1,
		["i*rL"] = 0
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.hideCtrlEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
	self.InitWeaponData(self)
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
	if self.rootGo then
		self.rootArea = self.rootGo:GetComponent("UNavigationArea")
	end

	SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.rootArea
	self.bindData.hideCtrl = self.hideCtrlEnum.show

	self.SetCameraBtnsActive(self, false)
	self.InitTooltipStore(self)
	self.InitTopTemplate(self)
	self.UpdateTipVisibility(self)
	self.PlayOpenAnimation(self)

	if #self.tab1List ~= 0 then
		self.bindData.tabLv1List:SetSimpleList(0)
		self.bindData.tabList:SetSimpleList(0)
		self.bindData.itemList:SetSimpleList(0)

		return
	end

	self.bindData.tabLv1List:SetSimpleList(#self.tab1List)

	local targetWeaponId = data and data.targetItemId

	if targetWeaponId then
		self.JumpToWeapon(self, targetWeaponId)
	else
		self.SelectTab1(self, 0)
	end
end

M.OnClose = function(self)
end

M.PlayOpenAnimation = function(self)
	if not gClientUtils.NotNil(self.bindData.anim) then
		return
	end

	gCS.LuaUtils.PlayAnimationByName(self.bindData.anim, "s_vx_BaikeCarPreviewPanel_open")
end

M.OnActiveDeviceChange = function(self, device)
	self.UpdateTipVisibility(self)
end

M.InitWeaponData = function(self)
	self.tab1List = {}
	self.tab1IndexToTab2List = {}
	self.tab2IdToWeaponIds = {}
	local tab2Rows = {}
	local tab1ValueSet = {}

	for i = 0, WeaponPediaTabConfig.count - 1 do
		local tabCfg = WeaponPediaTabConfig.LoadAt(i)

		if tabCfg then
			table.insert(tab2Rows, tabCfg)

			tab1ValueSet[tabCfg.Tab1] = true
		end
	end

	local tab1Values = {}

	for tab1Value, _ in pairs(tab1ValueSet) do
		table.insert(tab1Values, tab1Value)
	end

	table.sort(tab1Values)

	local tab1ValueToIndex = {}

	for i, tab1Value in ipairs(tab1Values) do
		tab1ValueToIndex[tab1Value] = i
	end

	local pediaTab1 = SceneitemConfig.WeaponPediaTab1

	if pediaTab1 then
		for i = 1, #pediaTab1 do
			local textKey = pediaTab1[i]
			local textCfg = textKey and TextConfig.GetConfig(textKey)

			table.insert(self.tab1List, {
				textKey = textKey,
				title = textCfg and textCfg.Text or "",
				tab1Value = tab1Values[i]
			})

			self.tab1IndexToTab2List[i] = {}
		end
	end

	self.weaponTypeToTab2Id = {}

	for _, tabCfg in ipairs(tab2Rows) do
		local tab1Index = tab1ValueToIndex[tabCfg.Tab1]
		local bucket = tab1Index and self.tab1IndexToTab2List[tab1Index]

		if bucket then
			table.insert(bucket, tabCfg)
		end

		self.tab2IdToWeaponIds[tabCfg.Id] = {}

		if tabCfg.WeaponType then
			for j = 1, #tabCfg.WeaponType do
				self.weaponTypeToTab2Id[tabCfg.WeaponType[j]] = tabCfg.Id
			end
		end
	end

	for _, tab2List in pairs(self.tab1IndexToTab2List) do
		table.sort(tab2List, function (a, b)
			return a.Id <= b.Id
		end)
	end

	local weaponCount = SceneitemConfig.count

	for i = 0, weaponCount - 1 do
		local cfg = SceneitemConfig.LoadAt(i)

		if cfg and cfg.ShowInPedia and cfg.Type then
			local tab2Id = self.weaponTypeToTab2Id[cfg.Type]
			local bucket = tab2Id and self.tab2IdToWeaponIds[tab2Id]

			if bucket then
				table.insert(bucket, cfg.Id)
			end
		end
	end

	for _, weaponIds in pairs(self.tab2IdToWeaponIds) do
		table.sort(weaponIds)
	end
end

M.SelectTab1 = function(self, index, skipAutoSelect)
	if index <= 0 or index > #self.tab1List then
		return
	end

	self.currentTab1Index = index

	self.bindData.tabLv1List:SelectItem(index)
	self.bindData.tabLv1List:RefreshList()

	self.currentTab2List = self.tab1IndexToTab2List[index + 1] or {}

	self.bindData.tabList:SetSimpleList(#self.currentTab2List)

	if #self.currentTab2List ~= 0 then
		self.currentTab2Index = nil
		self.currentTab2List = {}

		self.bindData.itemList:SetSimpleList(0)

		return
	end

	if not skipAutoSelect then
		self.SelectTab2(self, 0)
	end
end

M.SelectTab2 = function(self, index, skipAutoSelect)
	if index <= 0 or index > #self.currentTab2List then
		return
	end

	self.currentTab2Index = index

	self.bindData.tabList:SelectItem(index)

	local tabCfg = self.currentTab2List[index + 1]
	self.currentWeaponIds = tabCfg and self.tab2IdToWeaponIds[tabCfg.Id] or {}

	self.bindData.itemList:SetSimpleList(#self.currentWeaponIds)
	self.bindData.itemList:PlayStartOffsetAnim(0)

	if #self.currentWeaponIds ~= 0 then
		self.currentWeaponIndex = nil
		self.currentWeaponId = nil

		return
	end

	if not skipAutoSelect then
		self.SelectWeapon(self, 0)
	end
end

M.SelectWeapon = function(self, index, needJump)
	if index <= 0 or index > #self.currentWeaponIds then
		return
	end

	self.currentWeaponIndex = index
	self.currentWeaponId = self.currentWeaponIds[index + 1]

	self.bindData.itemList:SelectItem(index, true)

	if needJump then
		SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.rootArea
		local success, btn = self.bindData.itemList:TryGetChildAt(index, nil)

		if success then
			SGUI.UNavigationMgr.Inst.CurrentActiveArea.CurrentActiveContent = btn
		end
	end

	self.UpdateWeaponInfo(self, self.currentWeaponId)
end

M.UpdateWeaponInfo = function(self, weaponId)
	if not weaponId then
		return
	end

	self.RefreshTooltip(self, weaponId)
end

M.InitTooltipStore = function(self)
	local tooltip = self.bindData.weaponTooltip

	if not tooltip then
		return
	end

	self.tooltipStore = gStoreManager:GetStoreGroup(tooltip.Store)

	if not self.tooltipStore then
		return
	end

	self.tooltipStore:SetShowChipList(false)
	self.tooltipStore:SetTipShowMode(0)
	self.tooltipStore:ClearButtonState()
end

M.RefreshTooltip = function(self, weaponId)
	if not self.tooltipStore then
		return
	end

	self.tooltipStore:SetBaseWeapon({
		["-\\xf3Z>\\xc4\\xa4g\\xadW\\xb7\\xa5"] = 0,
		["Ή!\\xe0\\xe3\tƇ\\xee\\x89%,"] = false,
		TemplateId = weaponId
	})
end

M.InitTopTemplate = function(self)
	local topTemplate = self.bindData.topTemplate

	if not topTemplate then
		return
	end

	local topStore = gStoreManager:GetStoreGroup(topTemplate.Store)

	if not topStore then
		return
	end

	topStore.SetData(topStore, {
		creditItemType = LTConfig.AssetGalleryAssetGalleryTypeConfig.Weapon
	})
end

M.SetCameraBtnsActive = function(self, value)
	if not self.bindData.cameraBtns then
		return
	end

	self.bindData.cameraBtns.gameObject:SetActive(value ~= true)
end

M.UpdateTipVisibility = function(self)
	local isGamepad = SGUI.GameDevice.KeyboardMouse <= gCS.LuaUtils.GetActiveDevice()

	if isGamepad then
		self.bindData.tipVisibility = 1
	else
		local isHide = self.bindData.hideCtrl ~= self.hideCtrlEnum.hide

		if isHide then
			self.bindData.tipVisibility = 0
		else
			self.bindData.tipVisibility = 1
		end
	end
end

M.JumpToWeapon = function(self, targetWeaponId)
	if not targetWeaponId then
		self.SelectTab1(self, 0)

		return
	end

	local cfg = SceneitemConfig.GetConfig(targetWeaponId)
	local tab2Id = cfg and cfg.Type and self.weaponTypeToTab2Id[cfg.Type]

	if not tab2Id then
		self.SelectTab1(self, 0)

		return
	end

	local tab1Index, tab2Index = nil

	for i = 1, #self.tab1List do
		local tab2List = self.tab1IndexToTab2List[i]

		if tab2List then
			for j, t in ipairs(tab2List) do
				if t.Id ~= tab2Id then
					tab2Index = j - 1
					tab1Index = i - 1

					break
				end
			end
		end

		if tab1Index then
			break
		end
	end

	if not tab1Index or not tab2Index then
		self.SelectTab1(self, 0)

		return
	end

	self:SelectTab1(tab1Index, true)
	self.bindData.tabList:GoToIndex(tab2Index, false)
	self:SelectTab2(tab2Index, true)

	for i, weaponId in ipairs(self.currentWeaponIds) do
		if weaponId ~= targetWeaponId then
			self.SelectWeapon(self, i - 1, true)

			return
		end
	end

	self.SelectWeapon(self, 0)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.exitButton.luaClick = self.CreateAction(self, "OnClickExitButton")
	self.bindData.hideBtn.luaClick = self.CreateAction(self, "OnClickHideBtn")
	self.bindData.tabUpBtn.luaClick = self.CreateActionWithArgs(self, "OnClickTabNavBtn", -1)
	self.bindData.tabDownBtn.luaClick = self.CreateActionWithArgs(self, "OnClickTabNavBtn", 1)
	self.bindData.tabLv1List.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderTabLv1ListItem")
	self.bindData.tabLv1List.luaSimpleClick = self.CreateAction(self, "OnSimpleClickTabLv1List")
	self.bindData.tabList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderTabListItem")
	self.bindData.tabList.luaSimpleClick = self.CreateAction(self, "OnSimpleClickTabList")
	self.bindData.itemList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderItemListItem")
	self.bindData.itemList.luaSimpleClick = self.CreateAction(self, "OnSimpleClickItemList")
end

M.OnClickExitButton = function(self)
	gPanelManager:Close(self.m_Id)
end

M.OnClickHideBtn = function(self)
	self.bindData.hideCtrl = 1 - self.bindData.hideCtrl
	local isHide = self.bindData.hideCtrl ~= self.hideCtrlEnum.hide

	if self.rootArea then
		self.rootArea:ChangeButtonNameByActionId(10, isHide and 126 or 104)
	end

	self.bindData.backBtnActive = not isHide

	self.UpdateTipVisibility(self)
end

M.OnClickTabNavBtn = function(self, direction)
	if not self.currentTab2Index or #self.currentTab2List ~= 0 then
		return
	end

	local targetIndex = self.currentTab2Index + direction

	if targetIndex <= 0 or targetIndex > #self.currentTab2List then
		return
	end

	self:SelectTab2(targetIndex)
	self.bindData.tabList:GoToIndex(targetIndex, false)
	self.bindData.itemList:GoToPos(Vector2.zero, true)
end

M.OnSimpleRenderTabLv1ListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local data = self.tab1List[index + 1]

	if not data then
		return
	end

	store.title = data.title or ""
	store.inSelected = BOOL2CTL[index ~= self.currentTab1Index]
end

M.OnSimpleClickTabLv1List = function(self, btn, index)
	if index ~= self.currentTab1Index then
		return
	end

	self:SelectTab1(index)
	self.bindData.tabList:GoToPos(Vector2.zero, true)
	self.bindData.itemList:GoToPos(Vector2.zero, true)
end

M.OnSimpleRenderTabListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local tabCfg = self.currentTab2List[index + 1]

	if not tabCfg then
		return
	end

	store.icon = tabCfg.Icon or 0
end

M.OnSimpleClickTabList = function(self, btn, index)
	if index ~= self.currentTab2Index then
		return
	end

	self:SelectTab2(index)
	self.bindData.itemList:GoToPos(Vector2.zero, true)
end

M.OnSimpleRenderItemListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local weaponId = self.currentWeaponIds[index + 1]
	local cfg = weaponId and SceneitemConfig.GetConfig(weaponId)

	if not cfg then
		return
	end

	store.iconId = cfg.WeaponConsumableIcon or 0
	store.quality = cfg.Quality or 1
	btn.enabledTooltip = false
end

M.OnSimpleClickItemList = function(self, btn, index)
	self.SelectWeapon(self, index)
end
