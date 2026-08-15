C_HomeBuildSettingPanelStore = DefClass("C_HomeBuildSettingPanelStore", C_HomeBuildSettingPanelStore, C_StoreGroup)
GroupName2Class.HomeBuildSettingPanelStore = C_HomeBuildSettingPanelStore
local M = C_HomeBuildSettingPanelStore
local MessageConfig = LTConfig.MessageConfig

function M:ctor()
	self.viewDataList = {}
end

function M:DefineAllVariables()
	self.SettingItemTemplateType = {
		HomeSettingBtn = 1,
		HomeSetting = 0
	}
end

function M:OnAwake()
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()
	self:InitSettingsData()
end

function M:OnEnable()
	return
end

function M:OnStart()
	return
end

function M:OnDisable()
	return
end

function M:OnDestroy()
	return
end

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	return
end

function M:OnShow(panelId, data)
	self.panelId = panelId

	self:RefreshSettingsListView()
end

function M:OnClose()
	return
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end

function M:GenMessageEvents()
	return
end

function M:RegisterWidget()
	self.bindData.backBtn.luaClick = self:CreateAction("OnClickBackBtn")
	self.bindData.fullScreenBackBtn.luaClick = self:CreateAction("OnClickBackBtn")
	self.bindData.settingsList.luaSimpleRenderItem = self:CreateAction("OnRenderSettingsListItem")
	self.bindData.settingsList.onGetTIndex = self:CreateAction("OnGetSettingsListTIndex")
end

function M:OnClickBackBtn()
	gPanelManager:Close(self.panelId)
end

function M:OnRenderSettingsListItem(btn, index)
	local data = self.viewDataList[index + 1]

	if not data then
		return
	end

	local itemStore = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not itemStore then
		return
	end

	itemStore.typeTitle = LTConfig.TextScriptTextConfig.GetConfig(data.typeTextId).Text

	if data.settingsItems then
		local groupIndex = index

		function itemStore.list.luaSimpleRenderItem(btn, itemIndex)
			self:OnRenderSettingsItem(btn, itemIndex, groupIndex)
		end

		function itemStore.list.onGetTIndex(itemIndex)
			return self:OnGetSettingsItemTIndex(itemIndex, groupIndex)
		end

		itemStore.list:SetSimpleList(#data.settingsItems)
	end
end

function M:OnGetSettingsListTIndex(index)
	return 0
end

function M:OnRenderSettingsItem(btn, index, groupIndex)
	local groupData = self.viewDataList[groupIndex + 1]

	if not groupData or not groupData.settingsItems then
		return
	end

	local data = groupData.settingsItems[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	if data.tIndex == self.SettingItemTemplateType.HomeSetting then
		self:RefreshHomeSettingView(store, data)
	elseif data.tIndex == self.SettingItemTemplateType.HomeSettingBtn then
		self:RefreshHomeSettingBtnView(store, data)
	end
end

function M:OnGetSettingsItemTIndex(index, groupIndex)
	local groupData = self.viewDataList[groupIndex + 1]

	if not groupData or not groupData.settingsItems then
		return 0
	end

	local data = groupData.settingsItems[index + 1]

	if not data then
		return 0
	end

	return data.tIndex or 0
end

function M:RefreshHomeSettingView(store, data)
	store.itemTitle = LTConfig.TextScriptTextConfig.GetConfig(data.itemTextId).Text
	store.state = not data.enable and 1 or 0

	if data.btnAction and self[data.btnAction] then
		store.switchStateBtn.luaClick = self:CreateActionWithArgs(data.btnAction, {
			store = store,
			data = data
		})
	end
end

function M:RefreshHomeSettingBtnView(store, data)
	store.titleText = LTConfig.TextScriptTextConfig.GetConfig(data.titleTextId).Text

	if store.btn and data.btnAction and self[data.btnAction] then
		store.bindWidget.luaClick = self:CreateActionWithArgs(data.btnAction, {
			store = store,
			data = data
		})
	end
end

function M:InitSettingsData()
	self.viewDataList = {
		{
			typeTextId = 89901257,
			settingsItems = {
				{
					enable = false,
					btnAction = "OnToggleGridAssist",
					id = 1,
					itemTextId = 89901258,
					tIndex = self.SettingItemTemplateType.HomeSetting
				},
				{
					enable = true,
					btnAction = "OnToggleShowWall",
					id = 2,
					itemTextId = 89901259,
					tIndex = self.SettingItemTemplateType.HomeSetting
				}
			}
		},
		{
			typeTextId = 89901260,
			settingsItems = {
				{
					id = 4,
					btnAction = "OnCollectAllFurniture",
					titleTextId = 89901261,
					tIndex = self.SettingItemTemplateType.HomeSettingBtn
				}
			}
		}
	}
end

function M:RefreshSettingsListView()
	if self.viewDataList and self.viewDataList[1] and self.viewDataList[1].settingsItems then
		self.viewDataList[1].settingsItems[1].enable = gFurnitureManager:GetGridModeEnabled()
	end

	if self.viewDataList and self.viewDataList[1] and self.viewDataList[1].settingsItems then
		self.viewDataList[1].settingsItems[2].enable = gFurnitureManager.showCeiling
	end

	self.bindData.settingsList:SetSimpleList(#self.viewDataList)
end

function M:OnToggleGridAssist(info)
	local store = info.store
	local data = info.data
	data.enable = not data.enable
	store.state = not data.enable and 1 or 0

	gFurnitureManager:SetGridModeEnabled(data.enable)
end

function M:OnToggleShowWall(info)
	local store = info.store
	local data = info.data
	data.enable = not data.enable
	store.state = not data.enable and 1 or 0
	gFurnitureManager.showCeiling = data.enable

	if data.enable then
		gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnReceiveSignal, {
			signalKey = "FurnitureCameraEnterIndoor"
		})
	else
		gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnReceiveSignal, {
			signalKey = "FurnitureCameraExitIndoor"
		})
	end
end

function M:OnCollectAllFurniture(info)
	gDisplayMessageMgr:ShowMessage(MessageConfig.HouseBuildResetConfirm, function ()
		gFurnitureManager:StorageAllFurniture()
	end, nil)
end
