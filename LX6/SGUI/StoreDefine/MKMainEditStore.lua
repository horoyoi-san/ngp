-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\MKMainEditStore.lua
-- Decompiled from: 00984_MKMainEditStore.lua_f6340e338afa.luajit

C_MKMainEditStore = DefClass("C_MKMainEditStore", C_MKMainEditStore, C_StoreGroup)
GroupName2Class.MKMainEditStore = C_MKMainEditStore
local M = C_MKMainEditStore
local OriginalCharacterTemplateConfig = LTConfig.OriginalCharacterTemplateConfig
local OriginalCharacterConfig = LTConfig.OriginalCharacterConfig
local EditTabConfig = LTConfig.MeccaGrandpaRobotEditTabConfig

local getEditTabCfg = function(id)
	return EditTabConfig and EditTabConfig.GetConfig(id)
end

M.ctor = function(self)
	self.mgr = gOCMgr
	self.parentStore = nil
end

M.DefineAllVariables = function(self)
	self.currentTabStore = nil
	self.currentTabIndex = -1
	self.templateProfile = nil
	self.TAB = {
		["~\\xa1\\xb7\\xa1\\xb2"] = 0,
		["\\xaf12,w\\x93@\\xd5>\\xbe\\xa0"] = 1
	}
	local personalityCfg = getEditTabCfg(0)
	local soundCfg = getEditTabCfg(1)
	self._tabs = {
		{
			["FCe}z;<"] = 0,
			id = self.TAB.Personality,
			title = personalityCfg and personalityCfg.TabText or OriginalCharacterConfig.MainPageTabText[3]
		},
		{
			["FCe}z;<"] = 1,
			id = self.TAB.Sound,
			title = soundCfg and soundCfg.TabText or OriginalCharacterConfig.MainPageTabText[2]
		}
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
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	self.mgr.isMeikaGrandpa = true
	self.templateProfile = nil

	self:SetEditTabCamera(self.TAB.Personality)

	local profile = self.mgr:GetMeikaGrandpaTemplateProfile()

	if not profile then
		self.Log(self, "[MKMainEditStore] 模板不存在(Id:" .. tostring(OriginalCharacterTemplateConfig.MeikaGrandpa) .. "),禁用确认")

		return
	end

	self.templateProfile = profile
	self.mgr.personalityAndStory.desc = profile.description or ""
	self.mgr.personalityAndStory.labels = profile.labels or {}
	self.mgr.personalityAndStory.story = profile.story or ""

	self:InitTabList()
end

M.OnClose = function(self)
	if self.currentTabStore and self.currentTabStore.OnClose then
		self.currentTabStore:OnClose()
	end

	self.currentTabStore = nil

	if self.parentStore and self.parentStore.SetCameraGaze then
		self.parentStore:SetCameraGaze(true)
	end
end

M.OnActiveDeviceChange = function(self, device)
end

M.BuildFinalStory = function(self, ps)
	if not ps then
		return ""
	end

	local story = ps.story or ""
	slot3 = pairs
	slot5 = ps.backGroundDetails or {}

	for _, content in slot3(slot5) do
		if not string.is_null_or_empty(content) then
			story = story .. "\n" .. content
		end
	end

	slot3 = pairs
	slot5 = ps.personalityDetails or {}

	for _, content in slot3(slot5) do
		if not string.is_null_or_empty(content) then
			story = story .. "\n" .. content
		end
	end

	return story
end

M.OnClickConfirmCreate = function(self)
	if not self.templateProfile then
		gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.OCNotPrepared)

		return
	end

	local tmpl = self.templateProfile
	local ps = self.mgr.personalityAndStory
	local story = self:BuildFinalStory(ps)
	local profile = {
		name = tmpl.name,
		gender = tmpl.gender,
		age = tmpl.age,
		identity = tmpl.identity,
		labels = ps.labels or {},
		description = ps.desc or "",
		story = story,
		voiceFiles = tmpl.voiceFiles,
		speechName = self.mgr.confirmVoice and self.mgr.confirmVoice.name or nil
	}

	if self.mgr:HasGrandpa() then
		slot5 = self.mgr

		slot5:AskModifyGrandpa(profile, function (success)
			if success then
				self.parentStore:OnChat(false)
			end
		end)

		return
	end

	slot5 = self.mgr

	slot5:AskCreateGrandpaWithProfile(profile, function (success)
		if success then
			self.parentStore:OnChat(true)
		end
	end)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.tabRect.OnRenderTab = self.CreateAction(self, self.OnTabRectRender)
end

M.InitTabList = function(self)
	local tabList = {}

	for _, tab in ipairs(self._tabs) do
		table.insert(tabList, {
			id = tab.id,
			title = tab.title
		})
	end

	self.SubGroup.CommonTabSingleStore:SetData(tabList, nil, 0, nil, self:CreateAction(self.OnTabChanged), self:CreateAction(self.OnRenderTabItem))
end

M.OnTabChanged = function(self, uList, isSub)
	local index = uList.selectedIndex

	if index >= 0 then
		return
	end

	local tab = self._tabs[index + 1]

	if not tab then
		return
	end

	self.bindData.tabRect.selectedIndex = tab.id
end

M.OnRenderTabItem = function(self, btn, index, data, store, isSub, uList)
	store.title = data.title or ""
end

M.SelectTab = function(self, tabId)
	for i, tab in ipairs(self._tabs) do
		if tab.id ~= tabId then
			self.SubGroup.CommonTabSingleStore:SetSelectedIndex(i - 1, true)

			return
		end
	end
end

M.OnTabRectRender = function(self, index, widget)
	if self.currentTabStore and self.currentTabStore.OnClose then
		self.currentTabStore:OnClose()
	end

	local store = gStoreManager:GetStoreGroup(widget.Store)

	if not store then
		return
	end

	store.parentStore = self

	store.OnShow(store, self.m_Id)

	self.currentTabStore = store
	self.currentTabIndex = index

	self.SetEditTabCamera(self, index)
end

M.GetEditTabId = function(self, tabId)
	for _, tab in ipairs(self._tabs) do
		if tab.id ~= tabId then
			return tab.editTabId
		end
	end

	return nil
end

M.SetEditTabCamera = function(self, tabId)
	if not self.parentStore or not self.parentStore.SetCameraGazeByActionId then
		return
	end

	local editTabId = self.GetEditTabId(self, tabId)

	if editTabId ~= nil then
		return
	end

	local cfg = getEditTabCfg(editTabId)
	local actionId = cfg and cfg.CameraActionStatusId

	if actionId and actionId <= 0 then
		self.parentStore:SetCameraGazeByActionId(actionId)
	end
end

M.OnExit = function(self)
	if self.bindData.tabRect.selectedIndex ~= self.TAB.Sound then
		self.SelectTab(self, self.TAB.Personality)

		return true
	end

	return false
end

M.OnClickBackBtn = function(self)
	self.OnExit(self)
end

M.GoToNext = function(self)
	if self.bindData.tabRect.selectedIndex ~= self.TAB.Personality then
		self.SelectTab(self, self.TAB.Sound)
	else
		self.OnClickConfirmCreate(self)
	end
end
