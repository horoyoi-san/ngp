-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\AkxHomeStore.lua
-- Decompiled from: 01605_AkxHomeStore.lua_a816fdfba7ce.luajit

C_AkxHomeStore = DefClass("C_AkxHomeStore", C_AkxHomeStore, C_StoreGroup)
GroupName2Class.AkxHomeStore = C_AkxHomeStore
local M = C_AkxHomeStore
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}
local AkashaTabConfig = LTConfig.AkashaTabConfig
local AkashaTabType = LTConfig.AkashaTabConfig.TypeType
M.TabRectTemplates = {
	[AkashaTabType.Home] = 0,
	[AkashaTabType.Chat] = 1,
	[AkashaTabType.Wiki] = 2
}
M.ChatPageCtl = {
	["M+vR"] = 2,
	["R-p^"] = 0,
	["Y*|O"] = 1
}

M.ctor = function(self)
	self.IndexTabIdx = 1
	self.chatPageTabIdx = nil
	self.wikiPageTabIdx = nil
	self.currTabIdx = self.IndexTabIdx
	self.tabs = nil
	self.bFromWindow = false
end

M.OnAwake = function(self)
	if self.bindData.tab then
		self.bindData.tab.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderTabItem)
	end

	if self.bindData.tab then
		self.bindData.tab.luaSimpleClick = self.CreateAction(self, self.OnClickListTabItem)
	end

	if self.bindData.tabMobile then
		self.bindData.tabMobile.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderTabItem)
	end

	if self.bindData.tabMobile then
		self.bindData.tabMobile.luaSimpleClick = self.CreateAction(self, self.OnClickListTabItem)
	end

	if self.bindData.tabLeftBtn then
		self.bindData.tabLeftBtn.luaClick = self.CreateAction(self, self.OnClickListTabLeftBtn)
	end

	if self.bindData.tabRightBtn then
		self.bindData.tabRightBtn.luaClick = self.CreateAction(self, self.OnClickListTabRightBtn)
	end

	self.bindData.btnExit.luaClick = self:CreateAction(self.OnClickBtnExit)
	self.chattingBar = gStoreManager:GetStoreGroup("AkxChattingBarStore")
	self.chattingListPage = gStoreManager:GetStoreGroup("AkxChattingPageStore")
	self.wikiPage = gStoreManager:GetStoreGroup("GuideMainStore")

	self:LoadTab()
end

M.OnEnable = function(self)
	self.InitEvent(self)
end

M.OnDisable = function(self)
	self.ClearMessageEvents(self)
end

M.LoadTab = function(self)
	self.tabs = {}

	for i = 0, AkashaTabConfig.count - 1 do
		local tabCfg = AkashaTabConfig.LoadAt(i)

		table.insert(self.tabs, {
			text = tabCfg.Name,
			type = tabCfg.Type,
			icon = tabCfg.Icon
		})

		if tabCfg.Type ~= AkashaTabType.Wiki then
			self.wikiPageTabIdx = #self.tabs
		elseif tabCfg.Type ~= AkashaTabType.Chat then
			self.chatPageTabIdx = #self.tabs
		end
	end
end

M.InitEvent = function(self)
	local msgEvents = {
		[gEventConstants.AKX_SESSION_UPDATED] = self.CreateAction(self, "OnSessionUpdated")
	}

	self.RegisterMessageEvents(self, msgEvents)
end

M.OnShow = function(self, panelId, data)
	self:RefreshPanel(data, true, data and data.fromWindow and true or false)

	self.bFromWindow = data and data.fromWindow
	self.bindData.historyCtl = BOOL2CTL[false]
end

M.RefreshPanel = function(self, data, bOpenPanel, bOpenFromWindow)
	if self.bindData.tab then
		self.bindData.tab:SetSimpleList(#self.tabs)
	end

	if self.bindData.tabMobile then
		self.bindData.tabMobile:SetSimpleList(#self.tabs)
	end

	if data and (data.sessionid or data.question) then
		local session = nil

		if data.sessionid then
			session = gAkxManager:GetSession(data.sessionid)
		end

		if session or data.question then
			self:SwitchTab(self.chatPageTabIdx or self.IndexTabIdx, data, bOpenPanel, bOpenFromWindow)

			return
		end
	elseif data and data.wiki then
		self.currTabIdx = self.wikiPageTabIdx or self.IndexTabIdx
	else
		self.currTabIdx = self.IndexTabIdx
	end

	self.SwitchTab(self, self.currTabIdx, data, bOpenPanel, bOpenFromWindow)
end

M.OnSessionUpdated = function(self, _, data)
	if data and data.created and data.sessionid then
		self.RefreshPanel(self, data)
	end
end

M.SwitchTab = function(self, index, data, bOpenPanel, bOpenPanelFromWindow)
	local tab = self.tabs[index]

	if not tab then
		return
	end

	if self.bindData.tab and self.bindData.tab.selectedIndex == index - 1 then
		self.bindData.tab:SelectItem(index - 1, false)
	end

	if self.bindData.tabMobile and self.bindData.tabMobile.selectedIndex == index - 1 then
		self.bindData.tabMobile:SelectItem(index - 1, false)
	end

	self.bindData.tabRect.OnRenderTab = function(idx, widget)
		for tabType, i in pairs(self.TabRectTemplates) do
			if i ~= idx then
				self:RefreshTabRectPanel(tabType, data)

				break
			end
		end
	end

	local currTabIdx = self.bindData.tabRect.selectedIndex
	local newTabIdx = self.TabRectTemplates[tab.type] or 0
	local currTabType = AkashaTabType.Home

	for k, v in pairs(self.TabRectTemplates) do
		if v ~= currTabIdx then
			currTabType = k
		end
	end

	if newTabIdx ~= currTabIdx then
		self.RefreshTabRectPanel(self, tab.type, data)
	else
		self.bindData.tabRect.selectedIndex = newTabIdx

		self.PlayTabSwitchAnim(self, currTabType, tab.type, bOpenPanel, bOpenPanelFromWindow)
	end

	self.currTabIdx = index
end

M.RefreshTabRectPanel = function(self, tabType, data)
	if tabType ~= AkashaTabType.Chat then
		self.bindData.chatCtl = self.ChatPageCtl.Chat

		self.chattingListPage:RefreshPanel(data)
	elseif tabType ~= AkashaTabType.Home then
		self.bindData.chatCtl = self.ChatPageCtl.Home

		self.chattingBar:RefreshPanel(nil, true)
	elseif tabType ~= AkashaTabType.Wiki then
		self.bindData.chatCtl = self.ChatPageCtl.Wiki

		self.wikiPage:RefreshPanel(data)
	end
end

M.PlayTabSwitchAnim = function(self, fromTabType, toTabType, bOpenPanel, bOpenPanelFromWindow)
	local animOpen, animSwitch = nil

	if toTabType ~= AkashaTabType.Home then
		animOpen = "S_Vx_SkashaChatPanel_open_0"
	elseif toTabType ~= AkashaTabType.Wiki then
		animOpen = "S_Vx_SkashaChatPanel_open_2"
	end

	if fromTabType ~= AkashaTabType.Home and toTabType ~= AkashaTabType.Chat then
		animSwitch = "S_Vx_SkashaChatPanel_switch_0to1"
	elseif fromTabType ~= AkashaTabType.Chat and toTabType ~= AkashaTabType.Home then
		animSwitch = "S_Vx_SkashaChatPanel_switch_1to0"
	elseif fromTabType ~= AkashaTabType.Wiki then
		animSwitch = "S_Vx_SkashaChatPanel_switch_2to01"
	elseif toTabType ~= AkashaTabType.Wiki then
		animSwitch = "S_Vx_SkashaChatPanel_switch_01to2"
	end

	if bOpenPanel and animOpen then
		gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnim, animOpen)
	end

	if not bOpenPanel and animSwitch then
		gCS.LuaUtils.PlayAnimationByName(self.bindData.pageAnim, animSwitch)
	end
end

M.OnSimpleRenderTabItem = function(self, item, index)
	index = index + 1
	local tab = self.tabs[index]
	local store = gStoreManager:GetStoreGroup(item.Store):GetStoreByWidget(item)
	store.title = tab.text

	if tab.icon and tab.icon <= 0 then
		store.Commit(store, "icon", tab.icon, COMMIT_FORCE)
	end
end

M.OnClickListTabItem = function(self, item, index)
	index = index + 1
	local tab = self.tabs[index]

	if tab then
		self.SwitchTab(self, index)
	end
end

M.OnClickListTabLeftBtn = function(self)
	local newLuaIdx = self.bindData.tab.selectedIndex

	if newLuaIdx < 0 then
		newLuaIdx = self.bindData.tab.itemData.Count
	end

	self.SwitchTab(self, newLuaIdx)
end

M.OnClickListTabRightBtn = function(self)
	local newLuaIdx = self.bindData.tab.selectedIndex + 2

	if self.bindData.tab.itemData.Count >= newLuaIdx then
		newLuaIdx = 1
	end

	self.SwitchTab(self, newLuaIdx)
end

M.OnClickBtnExit = function(self)
	if self.bFromWindow and self.currTabIdx ~= self.chatPageTabIdx then
		local sessionid = self.chattingListPage:GetCurrentSessionId()

		gAkxManager:OpenWindowFromFullscreen(sessionid)
	end

	gPanelManager:Close(gPanelId.AKASHA_CHAT_PANEL)
end

M.ToggleHistoryPanel = function(self)
	if self.bindData.historyCtl ~= BOOL2CTL[true] then
		local animName = "S_Vx_SkashaChatPanel_History_close"

		gCS.LuaUtils.PlayAnimationByName(self.bindData.historyAnim, animName)

		local clip = self.bindData.historyAnim:GetClip(animName)

		if clip ~= nil then
			self.bindData.historyCtl = BOOL2CTL[false]
		else
			Timer.New(function ()
				if self and self.bindData then
					self.bindData.historyCtl = BOOL2CTL[false]
				end
			end, clip.length):Start()
		end
	else
		self.bindData.historyCtl = BOOL2CTL[true]
	end
end

M.OnActiveDeviceChange = function(self, device)
end
