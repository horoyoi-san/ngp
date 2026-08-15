local MainPageConfig = LTConfig.MainPageConfig
local SwitchSceneManager = gCS.SwitchSceneManager
local MobileMenuSGuiConfig = LTConfig.MobileMenuSGuiConfig
C_MainPageManager = DefClass("C_MainPageManager", C_MainPageManager)
local M = C_MainPageManager

function M:OnInit()
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

function M:InitTab()
	self.panelId2PageCheckName = {}
	self.pageLockDict = {}
	self.validPageMobile = {}
	self.validPagePC = {}

	for i = 0, MainPageConfig.count - 1 do
		local cfg = MainPageConfig.LoadAt(i)

		if cfg.ValidMobile or cfg.ValidPC then
			self.panelId2PageCheckName[cfg.PanelId] = cfg.CheckName

			if cfg.ValidMobile then
				self.validPageMobile[cfg.CheckName] = cfg
			end

			if cfg.ValidPC then
				self.validPagePC[cfg.CheckName] = cfg
			end
		end
	end
end

function M:CheckPageCanShow(pageCheckName)
	if self[pageCheckName .. "CheckCanShow"] then
		return self[pageCheckName .. "CheckCanShow"](self)
	else
		print_error("界面未实现是否显示的检测方法", pageCheckName .. "CheckCanShow", "is nil")
	end

	return false
end

function M:CheckPageEquipped(pageCheckName)
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		if self.validPagePC[pageCheckName] then
			return true
		end
	elseif self.validPageMobile[pageCheckName] then
		return true
	end

	return false
end

function M:CheckMainPageShowById(panelId)
	if not self.ENABLE then
		return false
	end

	if not gUIFunctionStateManager:GetMainPageEnable()[2] then
		return false
	end

	if SwitchSceneManager.gameStage ~= SwitchSceneManager.GameStage.GameScene then
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

function M:CheckMainPageShowByName(pageCheckName)
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

function M:GetTabList()
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
		return a.cfg.SortingOrder < b.cfg.SortingOrder
	end)

	for i = 1, #list do
		list[i].index = i
	end

	return list
end

function M:OnPanelShow(eventId, panelId)
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

function M:OnDoClose(eventId, panelId)
	self:UnlockMainPage(panelId)
end

function M:CheckTouchLimit()
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

			if page == "UrbanAbility" then
				table.remove(self.tabShowStack, i)

				self.tabShowCount = self.tabShowCount - 1

				self:ClosePageTrigger(page)

				break
			end
		end
	end
end

function M:OnPanelClose(eventId, panelId)
	local pageCheckName = self.panelId2PageCheckName[panelId]

	if pageCheckName and table.contains(self.tabShowStack, pageCheckName) then
		local topVal = self.tabShowStack[#self.tabShowStack]

		if topVal == pageCheckName then
			for i = #self.tabShowStack, 1, -1 do
				local page = self.tabShowStack[i]
				self.tabShowStack[i] = nil

				if page ~= pageCheckName then
					self:ClosePageTrigger(page)
				end
			end

			self.tabShowCount = 0

			gPanelManager:Close(gPanelId.S_MAIN_PAGE_TAB_PANEL)
		else
			table.removeEx(self.tabShowStack, pageCheckName)

			self.tabShowCount = self.tabShowCount - 1

			if self.tabShowCount == 0 then
				gPanelManager:Close(gPanelId.S_MAIN_PAGE_TAB_PANEL)
			end
		end
	end
end

function M:ShowMainPageTab(pageCheckName, showData)
	if self:CheckPageEquipped(pageCheckName) then
		if not self:CheckPageCanShow(pageCheckName) then
			print_notice("界面打开条件不满足，目前无法打开！！", pageCheckName)

			return
		end

		if not self[pageCheckName .. "OpenTrigger"] then
			print_error("界面未实现打开方法", pageCheckName .. "OpenTrigger", "is nil")

			return
		end

		self[pageCheckName .. "OpenTrigger"](self, showData)
	else
		if not self[pageCheckName .. "IndependentShow"] then
			print_error("界面未实现非聚合打开方法", pageCheckName .. "IndependentShow", "is nil")

			return
		end

		self[pageCheckName .. "IndependentShow"](self, showData)
	end
end

function M:CloseMainPageTab(pageCheckName)
	if table.contains(self.tabShowStack, pageCheckName) then
		self:ClosePageTrigger(pageCheckName)
	else
		self:PageIndependentClose(pageCheckName)
	end
end

function M:ClosePageTrigger(pageCheckName)
	if self[pageCheckName .. "CloseTrigger"] then
		self[pageCheckName .. "CloseTrigger"](self)
	else
		print_error("界面未实现关闭方法", pageCheckName .. "CloseTrigger", "is nil")
	end
end

function M:PageIndependentClose(pageCheckName)
	if self[pageCheckName .. "IndependentClose"] then
		self[pageCheckName .. "IndependentClose"](self)
	else
		print_error("界面未实现关闭方法", pageCheckName .. "IndependentClose", "is nil")
	end
end

function M:LockMainPage(panelId)
	self.pageLockDict[panelId] = true
end

function M:UnlockMainPage(panelId)
	self.pageLockDict[panelId] = nil
end

function M:MapCheckCanShow()
	return gMapSystem:Tmp_CanPlayerOpenMap(false)
end

function M:MapOpenTrigger()
	gMapUtils:PlayerOpenBigMap({
		fromMainPageSwitch = true
	})
end

function M:MapCloseTrigger()
	gPanelManager:Close(gPanelId.S_NEW_MAP_PANEL)
end

function M:MapIndependentShow(showData)
	gMapUtils:PlayerOpenBigMap()
end

function M:MapIndependentClose()
	gPanelManager:Close(gPanelId.S_NEW_MAP_PANEL)
end

function M:UrbanAbilityCheckCanShow()
	return gMainPhoneUtils.CheckAppCanShow(LTConfig.MobileMenuSGuiConfig.LingListId)
end

function M:UrbanAbilityOpenTrigger(showData)
	gPanelManager:CheckShow(gPanelId.S_URBAN_ABILITY_PANEL, showData)
end

function M:UrbanAbilityCloseTrigger()
	gPanelManager:Close(gPanelId.S_URBAN_ABILITY_PANEL)
end

function M:UrbanAbilityIndependentShow(showData)
	gPanelManager:CheckShow(gPanelId.S_URBAN_ABILITY_PANEL, showData)
end

function M:UrbanAbilityIndependentClose()
	gPanelManager:Close(gPanelId.S_URBAN_ABILITY_PANEL)
end

function M:TaskCheckCanShow()
	return gMainPhoneUtils.CheckAppCanShow(LTConfig.MobileMenuSGuiConfig.TaskId)
end

function M:TaskOpenTrigger(showData)
	gPanelManager:CheckShow(gPanelId.S_TASK_LIST)
end

function M:TaskCloseTrigger(showData)
	gPanelManager:Close(gPanelId.S_TASK_LIST)
end

function M:TaskIndependentShow(showData)
	gPanelManager:CheckShow(gPanelId.S_TASK_LIST, showData)
end

function M:TaskIndependentClose()
	gPanelManager:Close(gPanelId.S_TASK_LIST)
end

function M:MailCheckCanShow()
	return gMainPhoneUtils.CheckAppCanShow(LTConfig.MobileMenuSGuiConfig.EmailId)
end

function M:MailOpenTrigger(showData)
	gPanelManager:CheckShow(gPanelId.S_MAIL_PANEL, showData)
end

function M:MailCloseTrigger()
	gPanelManager:Close(gPanelId.S_MAIL_PANEL)
end

function M:MailIndependentShow(showData)
	gPanelManager:CheckShow(gPanelId.S_MAIL_PANEL, showData)
end

function M:MailIndependentClose()
	gPanelManager:Close(gPanelId.S_MAIL_PANEL)
end

function M:InventoryCheckCanShow()
	return gMainPhoneUtils.CheckAppCanShow(LTConfig.MobileMenuSGuiConfig.PackageId)
end

function M:InventoryOpenTrigger(showData)
	gPanelManager:CheckShow(gPanelId.S_INVENTORY_PANEL, showData)
end

function M:InventoryCloseTrigger()
	gPanelManager:Close(gPanelId.S_INVENTORY_PANEL)
end

function M:InventoryIndependentShow(showData)
	gPanelManager:CheckShow(gPanelId.S_INVENTORY_PANEL, showData)
end

function M:InventoryIndependentClose()
	gPanelManager:Close(gPanelId.S_INVENTORY_PANEL)
end

function M:SettingCheckCanShow()
	return gMainPhoneUtils.CheckAppCanShow(LTConfig.MobileMenuSGuiConfig.SettingId)
end

function M:SettingOpenTrigger(showData)
	gPanelManager:CheckShow(gPanelId.S_SETTINGS_PANEL, showData)
end

function M:SettingCloseTrigger()
	gPanelManager:Close(gPanelId.S_SETTINGS_PANEL)
end

function M:SettingIndependentShow(showData)
	gPanelManager:CheckShow(gPanelId.S_SETTINGS_PANEL, showData)
end

function M:SettingIndependentClose()
	gPanelManager:Close(gPanelId.S_SETTINGS_PANEL)
end

function M:CollectionCheckCanShow()
	return gMainPhoneUtils.CheckAppCanShow(LTConfig.MobileMenuSGuiConfig.BaiKeId)
end

function M:CollectionOpenTrigger(showData)
	gPanelManager:CheckShow(gPanelId.BAIKE_MAIN_PANEL, showData)
end

function M:CollectionCloseTrigger()
	gPanelManager:Close(gPanelId.BAIKE_MAIN_PANEL)
end

function M:CollectionIndependentShow(showData)
	gPanelManager:CheckShow(gPanelId.BAIKE_MAIN_PANEL, showData)
end

function M:CollectionIndependentClose()
	gPanelManager:Close(gPanelId.BAIKE_MAIN_PANEL)
end

function M:AchievementCheckCanShow()
	return gMainPhoneUtils.CheckAppCanShow(LTConfig.MobileMenuSGuiConfig.AchivementId)
end

function M:AchievementOpenTrigger(showData)
	gPanelManager:CheckShow(gPanelId.S_ACHIEVEMENT_COVER, showData)
end

function M:AchievementCloseTrigger()
	gPanelManager:Close(gPanelId.S_ACHIEVEMENT_COVER)
end

function M:AchievementIndependentShow(showData)
	gPanelManager:CheckShow(gPanelId.S_ACHIEVEMENT_COVER, showData)
end

function M:AchievementIndependentClose()
	gPanelManager:Close(gPanelId.S_ACHIEVEMENT_COVER)
end

function M:TeachCheckCanShow()
	return gMainPhoneUtils.CheckAppCanShow(LTConfig.MobileMenuSGuiConfig.TeachingId)
end

function M:TeachOpenTrigger(showData)
	gPanelManager:CheckShow(gPanelId.S_GUIDE_MAIN_PANEL, showData)
end

function M:TeachCloseTrigger()
	gPanelManager:Close(gPanelId.S_GUIDE_MAIN_PANEL)
end

function M:TeachIndependentShow(showData)
	gPanelManager:CheckShow(gPanelId.S_GUIDE_MAIN_PANEL, showData)
end

function M:TeachIndependentClose()
	gPanelManager:Close(gPanelId.S_GUIDE_MAIN_PANEL)
end

function M:TalentTreeCheckCanShow()
	return gMainPhoneUtils.CheckAppCanShow(MobileMenuSGuiConfig.TalentTreeId)
end

function M:TalentTreeOpenTrigger(showData)
	gPanelManager:CheckShow(gPanelId.TALENT_TREE_PANEL, showData)
end

function M:TalentTreeCloseTrigger()
	gPanelManager:Close(gPanelId.TALENT_TREE_PANEL)
end

function M:TalentTreeIndependentShow(showData)
	gPanelManager:CheckShow(gPanelId.TALENT_TREE_PANEL, showData)
end

function M:TalentTreeIndependentClose()
	gPanelManager:Close(gPanelId.TALENT_TREE_PANEL)
end

function M:PoliceArchiveCheckCanShow()
	return gMainPhoneUtils.CheckAppCanShow(MobileMenuSGuiConfig.PoliceArchive)
end

function M:PoliceArchiveOpenTrigger(showData)
	gPanelManager:CheckShow(gPanelId.POLICE_ARCHIVE_PANEL, showData)
end

function M:PoliceArchiveCloseTrigger()
	gPanelManager:Close(gPanelId.POLICE_ARCHIVE_PANEL)
end

function M:PoliceArchiveIndependentShow(showData)
	gPanelManager:CheckShow(gPanelId.POLICE_ARCHIVE_PANEL, showData)
end

function M:PoliceArchiveIndependentClose()
	gPanelManager:Close(gPanelId.POLICE_ARCHIVE_PANEL)
end

function M:SetMainPageEnable(enable)
	self.ENABLE = enable
end

function M:OnLanguageChange(lang)
	for i = #self.tabShowStack - 1, 1, -1 do
		local page = self.tabShowStack[i]

		table.remove(self.tabShowStack, i)

		self.tabShowCount = self.tabShowCount - 1

		self:ClosePageTrigger(page)
	end
end

function M:SetMainPageHide(hide, skipEvent)
	self.hideMode = hide

	if not skipEvent then
		gStoreManager:GetStoreGroup("MainPageTabPanelStore"):RefreshHide()
	end
end

function M:GetMainPageHide()
	return self.hideMode
end

gMainPageManager = gMainPageManager or C_MainPageManager.new()
