C_ChaosFilterPanelStore = DefClass("C_ChaosFilterPanelStore", C_ChaosFilterPanelStore, C_StoreGroup)
GroupName2Class.ChaosFilterPanelStore = C_ChaosFilterPanelStore
local M = C_ChaosFilterPanelStore
local EquipType = {
	Weapon = 3,
	Body = 1,
	Camp = 2
}

function M:ctor()
	self.infoQualityData = {
		{
			index = 1,
			quality = 3,
			selected = false,
			textId = 89901198
		},
		{
			index = 2,
			quality = 4,
			selected = false,
			textId = 89901199
		},
		{
			index = 3,
			quality = 5,
			selected = false,
			textId = 89901200
		}
	}
	self.infoConstructData = {
		{
			index = 1,
			selected = false,
			textId = 89901213,
			type = EquipType.Weapon
		},
		{
			index = 2,
			selected = false,
			textId = 89901214,
			type = EquipType.Body
		},
		{
			index = 3,
			selected = false,
			textId = 89901215,
			type = EquipType.Camp
		}
	}
	self.recycleQualityData = {
		{
			index = 1,
			quality = 3,
			selected = false,
			textId = 89901198
		},
		{
			index = 2,
			quality = 4,
			selected = false,
			textId = 89901199
		},
		{
			index = 3,
			quality = 5,
			selected = false,
			textId = 89901200
		}
	}
	self.recycleConstructData = {
		{
			index = 1,
			selected = false,
			textId = 89901213,
			type = EquipType.Weapon
		},
		{
			index = 2,
			selected = false,
			textId = 89901214,
			type = EquipType.Body
		},
		{
			index = 3,
			selected = false,
			textId = 89901215,
			type = EquipType.Camp
		}
	}
	self.qualityListData = {}
	self.constructListData = {}
end

function M:DefineAllVariables()
	self.isFromInfo = true
	self.filterQuality = {
		false,
		false,
		false
	}
	self.filterConstruct = {
		false,
		false,
		false
	}
end

function M:RegisterWidget()
	self.bindData.qualityList.luaSimpleRenderItem = self:CreateAction("OnRenderQualityListItem")
	self.bindData.qualityList.luaSimpleClick = self:CreateAction("OnClickQualityListItem")
	self.bindData.qualityList.onGetTIndex = self:CreateAction("OnGetQualityListTIndex")
	self.bindData.constructList.luaSimpleRenderItem = self:CreateAction("OnRenderConstructListItem")
	self.bindData.constructList.luaSimpleClick = self:CreateAction("OnClickConstructListItem")
	self.bindData.constructList.onGetTIndex = self:CreateAction("OnGetConstructListTIndex")
	self.bindData.backBtn.luaClick = self:CreateAction("OnClickCloseBtn")
	self.bindData.clearAllBtn.luaClick = self:CreateAction("OnClickClearAllBtn")
	self.bindData.confirmBtn.luaClick = self:CreateAction("OnClickConfirmBtn")
end

function M:OnAwake()
	self:DefineAllVariables()
	self:RegisterWidget()
end

function M:OnClickCloseBtn(btn, data)
	gPanelManager:Close(gPanelId.CHAOS_FILTER_PANEL)
end

function M:OnClickConfirmBtn(btn, data)
	local filterQuality = nil

	if self.filterQuality[1] == false and self.filterQuality[2] == false and self.filterQuality[3] == false then
		filterQuality = nil
	else
		filterQuality = self.filterQuality
	end

	local filterConstruct = nil

	if self.filterConstruct[1] == false and self.filterConstruct[2] == false and self.filterConstruct[3] == false then
		filterConstruct = nil
	else
		filterConstruct = self.filterConstruct
	end

	gMessageManager:SendMessage(gEventConstants.CHAOS_MASTER_FILTER, {
		quality = filterQuality,
		construct = filterConstruct,
		isFromInfo = self.isFromInfo
	})
	gPanelManager:Close(gPanelId.CHAOS_FILTER_PANEL)
end

function M:OnClickClearAllBtn(btn, data)
	self:ClearAllFilter()
end

function M:ClearAllFilter()
	self.filterQuality = {
		false,
		false,
		false
	}
	self.filterConstruct = {
		false,
		false,
		false
	}

	if self.isFromInfo then
		for _, data in ipairs(self.infoQualityData) do
			data.selected = false
		end

		for _, data in ipairs(self.infoConstructData) do
			data.selected = false
		end

		self:ShowInfoFilter()
	else
		for _, data in ipairs(self.recycleQualityData) do
			data.selected = false
		end

		for _, data in ipairs(self.recycleConstructData) do
			data.selected = false
		end

		self:ShowRecycleFilter()
	end
end

function M:OnRenderQualityListItem(btn, index)
	local data = self.qualityListData[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup("FilterTxtTemplateStore"):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.title = LTConfig.TextScriptTextConfig.GetConfig(data.textId).Text
	local selected = nil

	if self.isFromInfo then
		selected = self.infoQualityData[data.index].selected
	else
		selected = self.recycleQualityData[data.index].selected
	end

	btn.isSelected = selected
end

function M:OnClickQualityListItem(btn, index)
	local data = self.qualityListData[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup("FilterTxtTemplateStore"):GetStoreByWidget(btn)

	if not store then
		return
	end

	local selected = nil

	if self.isFromInfo then
		self.infoQualityData[data.index].selected = not self.infoQualityData[data.index].selected
		selected = self.infoQualityData[data.index].selected
	else
		self.recycleQualityData[data.index].selected = not self.recycleQualityData[data.index].selected
		selected = self.recycleQualityData[data.index].selected
	end

	btn.isSelected = selected
	self.lastQualityBtn = btn
	self.filterQuality[data.quality] = btn.isSelected
end

function M:OnRenderConstructListItem(btn, index)
	local data = self.constructListData[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup("FilterTxtTemplateStore"):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.title = LTConfig.TextScriptTextConfig.GetConfig(data.textId).Text
	local selected = nil

	if self.isFromInfo then
		selected = self.infoConstructData[data.index].selected
	else
		selected = self.recycleConstructData[data.index].selected
	end

	btn.isSelected = selected
end

function M:OnClickConstructListItem(btn, index)
	local data = self.constructListData[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup("FilterTxtTemplateStore"):GetStoreByWidget(btn)

	if not store then
		return
	end

	local selected = nil

	if self.isFromInfo then
		self.infoConstructData[data.index].selected = not self.infoConstructData[data.index].selected
		selected = self.infoConstructData[data.index].selected
	else
		self.recycleConstructData[data.index].selected = not self.recycleConstructData[data.index].selected
		selected = self.recycleConstructData[data.index].selected
	end

	btn.isSelected = selected
	self.lastConstructBtn = btn
	self.filterConstruct[data.type] = btn.isSelected
end

function M:OnGetQualityListTIndex(index)
	return 0
end

function M:OnGetConstructListTIndex(index)
	return 0
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

function M:InitData()
	self.lastQualityBtn = nil
	self.lastConstructBtn = nil
	self.isFromInfo = false
end

function M:OnShow(panelId, data)
	self:InitData()

	if data.from == gPanelId.CHAOS_CULTIVATION_MAIN_PANEL then
		self.isFromInfo = true
		self.filterQuality = {
			self.infoQualityData[1].selected,
			self.infoQualityData[2].selected,
			self.infoQualityData[3].selected
		}
		self.filterConstruct = {
			self.infoConstructData[2].selected,
			self.infoConstructData[3].selected,
			self.infoConstructData[1].selected
		}

		self:ShowInfoFilter()
	elseif data.from == gPanelId.CHAOS_RECYCLE_PANEL then
		self.isFromInfo = false
		self.filterQuality = {
			self.recycleQualityData[1].selected,
			self.recycleQualityData[2].selected,
			self.recycleQualityData[3].selected
		}
		self.filterConstruct = {
			self.recycleConstructData[2].selected,
			self.recycleConstructData[3].selected,
			self.recycleConstructData[1].selected
		}

		self:ShowRecycleFilter()
	end
end

function M:ShowInfoFilter()
	self.qualityListData = self.infoQualityData
	self.constructListData = self.infoConstructData

	self.bindData.qualityList:SetSimpleList(#self.infoQualityData)
	self.bindData.constructList:SetSimpleList(#self.infoConstructData)
end

function M:ShowRecycleFilter()
	self.qualityListData = self.recycleQualityData
	self.constructListData = self.recycleConstructData

	self.bindData.qualityList:SetSimpleList(#self.recycleQualityData)
	self.bindData.constructList:SetSimpleList(#self.recycleConstructData)
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
