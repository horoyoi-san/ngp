-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\InitializationPanelStore.lua
-- Decompiled from: 01815_InitializationPanelStore.lua_c28e7e461b2c.luajit

local SettingsScriptFunc = require("LX6/GUI/Setting/SettingsScriptFunc")
local ShezhiPanelShezhiConfig = LTConfig.ShezhiPanelShezhiConfig
local ShezhiPanelConfig = LTConfig.ShezhiPanelConfig
local ProfileManager = LX6.Engine.ProfileManager
local languageProfile = ProfileManager.languageProfile
local SettingTemplateType = {
	["G\\xf93\\xf8 9(\\xf7d-\\xc5G\\x8dG\\xf9\\xb0"] = 1,
	["G\\xf93\\xf8 9(\\xf7d-\\xc5G\\x8dG\\xf9\\xb4"] = 0
}
C_InitializationPanelStore = DefClass("C_InitializationPanelStore", C_InitializationPanelStore, C_StoreGroup)
GroupName2Class.InitializationPanelStore = C_InitializationPanelStore
local M = C_InitializationPanelStore

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
	self.RefreshSettingList(self)
end

M.OnClose = function(self)
	if gDlcDownLoadMgr:IsAllMandatoryDownloaded() then
		gLoginManager:OpenMainPanel()
	else
		gLoginManager:PreConnect()
		gDlcDownLoadMgr:EnterDownloadPanelByNetwork(0, true)
	end
end

M.OnLanguageChange = function(self, lang)
	self.RefreshSettingList(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.confirmBtn.luaClick = self.CreateAction(self, self.OnClickConfirmBtn)
	self.bindData.settingList.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderSettingListItem)
	self.bindData.settingList.onGetTIndex = self.CreateAction(self, self.OnSettingListItemGetTIndex)
end

M.OnClickConfirmBtn = function(self)
	self.ClosePanel(self)
end

M.OnRenderSettingListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local data = self.settingDataList[index + 1]

	if data.tIndex ~= SettingTemplateType.SettingTemplate_2 then
		store.title = data.title
		local optionList = data.getOptionsFunc()
		store.dropMenu.interactable = true

		store.dropMenu.luaSelectedChanged = function(uSelector)
			local index = uSelector.selectedIndex

			data.setFunc(index + 1)
		end

		store.dropMenu.luaSimpleRenderSelector = nil

		store.dropMenu:SetSimpleOptions(#optionList)

		for i = 0, #optionList - 1 do
			store.dropMenu:SetItemLabel(i, optionList[i + 1].label)
		end

		store.dropMenu:SelectOption(data.value - 1)
	elseif data.tIndex ~= SettingTemplateType.SettingTemplate_6 then
		store.title = data.title
	end
end

M.OnSettingListItemGetTIndex = function(self, index)
	local data = self.settingDataList[index + 1]

	return data.tIndex
end

M.RefreshSettingList = function(self)
	local dataList = {
		{
			["a\\x9f\\x8a\\x86Y"] = 0,
			title = ShezhiPanelShezhiConfig.GetConfig(36).Title,
			getOptionsFunc = self.GetLanguageOptions,
			setFunc = self.SetLanguage,
			value = languageProfile.textLanguage or 1
		},
		{
			["a\\x9f\\x8a\\x86Y"] = 0,
			title = ShezhiPanelShezhiConfig.GetConfig(37).Title,
			getOptionsFunc = self.GetVoiceLanguageOptions,
			setFunc = self.SetVoiceLanguage,
			value = languageProfile.voiceLanguage or 1
		}
	}
	self.settingDataList = dataList

	self.bindData.settingList:SetSimpleList(#dataList)
end

M.GetLanguageOptions = function()
	local cfg = ShezhiPanelShezhiConfig.GetConfig(36)
	local options = {}

	for i = 1, #cfg.iOSName do
		options[i] = {
			label = cfg.iOSName[i].name
		}
	end

	return options
end

M.SetLanguage = function(index)
	print_debug("SetLanguage", index)
	SettingsScriptFunc._RealSetLanguage(index)
end

M.GetVoiceLanguageOptions = function()
	local cfg = ShezhiPanelShezhiConfig.GetConfig(37)
	local options = {}

	for i = 1, #cfg.iOSName do
		options[i] = {
			label = cfg.iOSName[i].name
		}
	end

	return options
end

M.SetVoiceLanguage = function(index)
	print_debug("SetVoiceLanguage", index)
	gDlcDownLoadMgr:SetMandatoryVoiceDLCByIndex(index)

	local voiceLang = ShezhiPanelConfig.VoiceLanguagesDisplay[index]

	gSoundMgr:SetVoiceLanguage(voiceLang)

	languageProfile.voiceLanguage = index

	ProfileManager.SaveLanguageProperty()
end

M.ClosePanel = function(self)
	gPanelManager:Close(gPanelId.INITIALIZATION_PANEL)
end
