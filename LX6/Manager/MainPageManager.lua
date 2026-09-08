-- Original chunk: @Lua\LuaFiles\LX6\Manager\MainPageManager.lua
-- Decompiled from: 00559_MainPageManager.lua_101c43e31bd8.luajit

local MainPageConfig = LTConfig.MainPageConfig
local SwitchSceneManager = gCS.SwitchSceneManager
local MobileMenuSGuiConfig = LTConfig.MobileMenuSGuiConfig
C_MainPageManager = DefClass("C_MainPageManager", C_MainPageManager)
local M = C_MainPageManager

M.OnInit = function(self)
	self.ENABLE = true
	self.tabShowStack = {}
	self.tabShowCount = 0
	self.hideMode = false

	self:InitTab()
	gMessageManager:AddMessageListener(gEventConstants.PANEL_ON_SHOW, self:CreateAction("OnPanelShow"))
	gMessageManager:AddMessageListener(gEventConstants.PANEL_ON_CLOSE, self:CreateAction("OnPanelClose"))
	gMessageManager:AddMessageListener(gEventConstants.DO_CLOSE, self:CreateAction("OnDoClose"))
	gMessageManager:AddMessageListener(gEventConstants.LANGUAGE_CHANGE, self:CreateAction("OnLanguageChange"))
end

M.InitTab = function(self)
	self.pageCheckName2Cfg = {}
	self.pageLockDict = {}
	self.validPageMobile = {}
	self.validPagePC = {}
	self.panelId2PageCheckName = {}

	for i = 0, MainPageConfig.count - 1 do
		local cfg = MainPageConfig.LoadAt(i)

		if cfg.ValidMobile or cfg.ValidPC then
			self.panelId2PageCheckName[cfg.PanelId] = cfg.CheckName
			self.pageCheckName2Cfg[cfg.CheckName] = cfg

			if cfg.ValidMobile then
				self.validPageMobile[cfg.CheckName] = cfg
			end

			if cfg.ValidPC then
				self.validPagePC[cfg.CheckName] = cfg
			end
		end
	end
end

M.GetAppIdByCheckName = function(self, pageCheckName)
	return self.pageCheckName2Cfg[pageCheckName] and self.pageCheckName2Cfg[pageCheckName].AppId or 0
end

M.GetPanelIdByCheckName = function(self, pageCheckName)
	return self.pageCheckName2Cfg[pageCheckName] and self.pageCheckName2Cfg[pageCheckName].PanelId or 0
end

M.CheckPageCanShow = function(self, pageCheckName)
	local appId = self:GetAppIdByCheckName(pageCheckName)

	if self[pageCheckName .. "CheckCanShow"] then
		return self[pageCheckName .. "CheckCanShow"](self)
	elseif appId <= 0 then
		return gMainPhoneUtils.CheckAppCanShow(appId)
	else
		print_error("聚合界面未配置AppId，且未实现是否显示的检测方法", pageCheckName .. "CheckCanShow", "无法判断是否要显示")
	end

	return false
end

M.CheckPageEquipped = function(self, pageCheckName)
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		if self.validPagePC[pageCheckName] then
			return true
		end
	elseif self.validPageMobile[pageCheckName] then
		return true
	end

	return false
end

M.CheckMainPageShowById = function(self, panelId)
	if not self.ENABLE then
		return false
	end

	if not gUIFunctionStateManager:GetMainPageEnable()[2] then
		return false
	end

	if SwitchSceneManager.gameStage == SwitchSceneManager.GameStage.GameScene then
		return false
	end

	if not self.panelId2PageCheckName[panelId] then
		return false
	end

	if self.pageLockDict[panelId] then
		return false
	end

	if not self:CheckPageEquipped(self.panelId2PageCheckName[panelId]) then
		return false
	end

	if not self:CheckPageCanShow(self.panelId2PageCheckName[panelId]) then
		return false
	end

	return true
end

M.CheckMainPageShowByName = function(self, pageCheckName)
	if not self.ENABLE then
		return false
	end

	if not self:CheckPageEquipped(pageCheckName) then
		return false
	end

	if not self:CheckPageCanShow(pageCheckName) then
		return false
	end

	return true
end

M.GetTabList = function(self)
	local list = {}

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		for checkName, cfg in pairs(self.validPagePC) do
			if self:CheckMainPageShowByName(checkName) then
				table.insert(list, {
					cfg = cfg
				})
			end
		end
	else
		for checkName, cfg in pairs(self.validPageMobile) do
			if self:CheckMainPageShowByName(checkName) then
				table.insert(list, {
					cfg = cfg
				})
			end
		end
	end

	table.sort(list, function (a, b)
		return a.cfg.SortingOrder <= b.cfg.SortingOrder
	end)

	for i = 1, #list do
		list[i].index = i
	end

	return list
end

M.OnPanelShow = function(self, eventId, panelId)
	if self:CheckMainPageShowById(panelId) then
		local pageCheckName = self.panelId2PageCheckName[panelId]

		if not table.contains(self.tabShowStack, pageCheckName) then
			table.insert(self.tabShowStack, pageCheckName)

			self.tabShowCount = self.tabShowCount + 1
		else
			table.removeEx(self.tabShowStack, pageCheckName)
			table.insert(self.tabShowStack, pageCheckName)
		end

		gPanelManager:CheckShow(gPanelId.S_MAIN_PAGE_TAB_PANEL, pageCheckName)
		self:CheckTouchLimit()
	end
end

M.OnPanelClose = function(self, eventId, panelId)
	local pageCheckName = self.panelId2PageCheckName[panelId]

	if pageCheckName and table.contains(self.tabShowStack, pageCheckName) then
		local topVal = self.tabShowStack[#self.tabShowStack]

		if topVal ~= pageCheckName then
			for i = #self.tabShowStack, 1, -1 do
				local page = self.tabShowStack[i]
				self.tabShowStack[i] = nil

				if page == pageCheckName then
					self:ClosePageTrigger(page)
				end
			end

			self.tabShowCount = 0

			gPanelManager:Close(gPanelId.S_MAIN_PAGE_TAB_PANEL)
		else
			table.removeEx(self.tabShowStack, pageCheckName)

			self.tabShowCount = self.tabShowCount - 1

			if self.tabShowCount ~= 0 then
				gPanelManager:Close(gPanelId.S_MAIN_PAGE_TAB_PANEL)
			end
		end
	end
end

M.OnDoClose = function(self, eventId, panelId)
	self:UnlockMainPage(panelId)
end

M.OnLanguageChange = function(self, lang)
	for i = #self.tabShowStack - 1, 1, -1 do
		local page = self.tabShowStack[i]

		table.remove(self.tabShowStack, i)

		self.tabShowCount = self.tabShowCount - 1

		self:ClosePageTrigger(page)
	end
end

M.CheckTouchLimit = function(self)
	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		for i = #self.tabShowStack - 1, 1, -1 do
			local page = self.tabShowStack[i]

			table.remove(self.tabShowStack, i)

			self.tabShowCount = self.tabShowCount - 1

			self:ClosePageTrigger(page)
		end
	else
		for i = #self.tabShowStack - 1, 1, -1 do
			local page = self.tabShowStack[i]

			if page ~= "UrbanAbility" then
				table.remove(self.tabShowStack, i)

				self.tabShowCount = self.tabShowCount - 1

				self:ClosePageTrigger(page)

				break
			end
		end
	end
end

M.ShowMainPageTab = function(self, pageCheckName)
	if self:CheckPageEquipped(pageCheckName) then
		if not self:CheckPageCanShow(pageCheckName) then
			print_notice("界面打开条件不满足，目前无法打开！！", pageCheckName)

			return
		end

		self:OpenPageTrigger(pageCheckName)
	else
		self:PageIndependentShow(pageCheckName)
	end
end

M.OpenPageTrigger = function(self, pageCheckName)
	local appId = self:GetAppIdByCheckName(pageCheckName)

	if self[pageCheckName .. "OpenTrigger"] then
		self[pageCheckName .. "OpenTrigger"](self)
	elseif appId <= 0 then
		gMainPhoneUtils.OnAppItemClick(appId)
	else
		print_error("界面未配置AppId，且未实现打开方法", pageCheckName .. "OpenTrigger")
	end
end

M.PageIndependentShow = function(self, pageCheckName)
	local appId = self:GetAppIdByCheckName(pageCheckName)

	if self[pageCheckName .. "IndependentShow"] then
		self[pageCheckName .. "IndependentShow"](self)
	elseif appId <= 0 then
		gMainPhoneUtils.OnAppItemClick(appId)
	else
		print_error("界面未配置AppId，且未实现非聚合打开方法", pageCheckName .. "IndependentShow")
	end
end

M.CloseMainPageTab = function(self, pageCheckName)
	if table.contains(self.tabShowStack, pageCheckName) then
		self:ClosePageTrigger(pageCheckName)
	else
		self:PageIndependentClose(pageCheckName)
	end
end

M.ClosePageTrigger = function(self, pageCheckName)
	local panelId = self:GetPanelIdByCheckName(pageCheckName)

	if self[pageCheckName .. "CloseTrigger"] then
		self[pageCheckName .. "CloseTrigger"](self)
	elseif panelId <= 0 then
		gPanelManager:Close(panelId)
	else
		print_error("界面未配置PanelId，且未实现关闭方法", pageCheckName .. "CloseTrigger")
	end
end

M.PageIndependentClose = function(self, pageCheckName)
	local panelId = self:GetPanelIdByCheckName(pageCheckName)

	if self[pageCheckName .. "IndependentClose"] then
		self[pageCheckName .. "IndependentClose"](self)
	elseif panelId <= 0 then
		gPanelManager:Close(panelId)
	else
		print_error("界面未配置PanelId，且未实现关闭方法", pageCheckName .. "IndependentClose")
	end
end

M.LockMainPage = function(self, panelId)
	self.pageLockDict[panelId] = true
end

M.UnlockMainPage = function(self, panelId)
	self.pageLockDict[panelId] = nil
end

M.SetMainPageEnable = function(self, enable)
	self.ENABLE = enable
end

M.SetMainPageHide = function(self, hide, skipEvent)
	self.hideMode = hide

	if not skipEvent then
		gStoreManager:GetStoreGroup("MainPageTabPanelStore"):RefreshHide()
	end
end

M.GetMainPageHide = function(self)
	return self.hideMode
end

M.MapCheckCanShow = function(self)
	return gMapSystem:CanShowMainPageTabPanel()
end

M.MapOpenTrigger = function(self)
	gMapUtils:PlayerOpenBigMap({
		[" (\\x9f\\xe0\\x86\\xa6ᨊ\\x89\\xda\\xe7ѓ4\\x9c\\xea"] = true
	})
end

M.MapCloseTrigger = function(self)
	gPanelManager:Close(gPanelId.S_NEW_MAP_PANEL)
end

M.MapIndependentShow = function(self)
	gMapUtils:PlayerOpenBigMap()
end

M.MapIndependentClose = function(self)
	gPanelManager:Close(gPanelId.S_NEW_MAP_PANEL)
end

M.AppearanceOpenTrigger = function(self)
	gDressManager:EnterFashionPortal()
end

gMainPageManager = gMainPageManager or C_MainPageManager.new()
