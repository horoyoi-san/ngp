-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ChaosFilterPanelStore.lua
-- Decompiled from: 01463_ChaosFilterPanelStore.lua_f2613998be75.luajit

C_ChaosFilterPanelStore = DefClass("C_ChaosFilterPanelStore", C_ChaosFilterPanelStore, C_StoreGroup)
GroupName2Class.ChaosFilterPanelStore = C_ChaosFilterPanelStore
local M = C_ChaosFilterPanelStore
local EquipType = {
	["+M\\x90\\x9e\\x8cO"] = 3,
	["X-yB"] = 1,
	["Y#pK"] = 2
}

M.ctor = function(self)
	self.infoQualityData = {
		{
			["D\\xa0\\xa6\\xaa\\xae"] = 1,
			["\\xc8\\xce0\\xe8"] = 3,
			["\\xb8\\xb4\t\\xaei*\\xfb7"] = false,
			["M\\x89\\x9a\\xaaE"] = 89901198
		},
		{
			["D\\xa0\\xa6\\xaa\\xae"] = 2,
			["\\xc8\\xce0\\xe8"] = 4,
			["\\xb8\\xb4\t\\xaei*\\xfb7"] = false,
			["M\\x89\\x9a\\xaaE"] = 89901199
		},
		{
			["D\\xa0\\xa6\\xaa\\xae"] = 3,
			["\\xc8\\xce0\\xe8"] = 5,
			["\\xb8\\xb4\t\\xaei*\\xfb7"] = false,
			["M\\x89\\x9a\\xaaE"] = 89901200
		}
	}
	self.infoConstructData = {
		{
			["D\\xa0\\xa6\\xaa\\xae"] = 1,
			["\\xb8\\xb4\t\\xaei*\\xfb7"] = false,
			["M\\x89\\x9a\\xaaE"] = 89901213,
			type = EquipType.Weapon
		},
		{
			["D\\xa0\\xa6\\xaa\\xae"] = 2,
			["\\xb8\\xb4\t\\xaei*\\xfb7"] = false,
			["M\\x89\\x9a\\xaaE"] = 89901214,
			type = EquipType.Body
		},
		{
			["D\\xa0\\xa6\\xaa\\xae"] = 3,
			["\\xb8\\xb4\t\\xaei*\\xfb7"] = false,
			["M\\x89\\x9a\\xaaE"] = 89901215,
			type = EquipType.Camp
		}
	}
	self.recycleQualityData = {
		{
			["D\\xa0\\xa6\\xaa\\xae"] = 1,
			["\\xc8\\xce0\\xe8"] = 3,
			["\\xb8\\xb4\t\\xaei*\\xfb7"] = false,
			["M\\x89\\x9a\\xaaE"] = 89901198
		},
		{
			["D\\xa0\\xa6\\xaa\\xae"] = 2,
			["\\xc8\\xce0\\xe8"] = 4,
			["\\xb8\\xb4\t\\xaei*\\xfb7"] = false,
			["M\\x89\\x9a\\xaaE"] = 89901199
		},
		{
			["D\\xa0\\xa6\\xaa\\xae"] = 3,
			["\\xc8\\xce0\\xe8"] = 5,
			["\\xb8\\xb4\t\\xaei*\\xfb7"] = false,
			["M\\x89\\x9a\\xaaE"] = 89901200
		}
	}
	self.recycleConstructData = {
		{
			["D\\xa0\\xa6\\xaa\\xae"] = 1,
			["\\xb8\\xb4\t\\xaei*\\xfb7"] = false,
			["M\\x89\\x9a\\xaaE"] = 89901213,
			type = EquipType.Weapon
		},
		{
			["D\\xa0\\xa6\\xaa\\xae"] = 2,
			["\\xb8\\xb4\t\\xaei*\\xfb7"] = false,
			["M\\x89\\x9a\\xaaE"] = 89901214,
			type = EquipType.Body
		},
		{
			["D\\xa0\\xa6\\xaa\\xae"] = 3,
			["\\xb8\\xb4\t\\xaei*\\xfb7"] = false,
			["M\\x89\\x9a\\xaaE"] = 89901215,
			type = EquipType.Camp
		}
	}
	self.qualityListData = {}
	self.constructListData = {}
end

M.DefineAllVariables = function(self)
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

M.RegisterWidget = function(self)
	self.bindData.qualityList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderQualityListItem")
	self.bindData.qualityList.luaSimpleClick = self.CreateAction(self, "OnClickQualityListItem")
	self.bindData.qualityList.onGetTIndex = self.CreateAction(self, "OnGetQualityListTIndex")
	self.bindData.constructList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderConstructListItem")
	self.bindData.constructList.luaSimpleClick = self.CreateAction(self, "OnClickConstructListItem")
	self.bindData.constructList.onGetTIndex = self.CreateAction(self, "OnGetConstructListTIndex")
	self.bindData.backBtn.luaClick = self.CreateAction(self, "OnClickCloseBtn")
	self.bindData.clearAllBtn.luaClick = self.CreateAction(self, "OnClickClearAllBtn")
	self.bindData.confirmBtn.luaClick = self.CreateAction(self, "OnClickConfirmBtn")
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.RegisterWidget(self)
end

M.OnClickCloseBtn = function(self, btn, data)
	gPanelManager:Close(gPanelId.CHAOS_FILTER_PANEL)
end

M.OnClickConfirmBtn = function(self, btn, data)
	local filterQuality = nil

	if self.filterQuality[1] ~= false and self.filterQuality[2] ~= false and self.filterQuality[3] ~= false then
		filterQuality = nil
	else
		filterQuality = self.filterQuality
	end

	local filterConstruct = nil

	if self.filterConstruct[1] ~= false and self.filterConstruct[2] ~= false and self.filterConstruct[3] ~= false then
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

M.OnClickClearAllBtn = function(self, btn, data)
	self.ClearAllFilter(self)
end

M.ClearAllFilter = function(self)
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

		self.ShowInfoFilter(self)
	else
		for _, data in ipairs(self.recycleQualityData) do
			data.selected = false
		end

		for _, data in ipairs(self.recycleConstructData) do
			data.selected = false
		end

		self.ShowRecycleFilter(self)
	end
end

M.OnRenderQualityListItem = function(self, btn, index)
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

M.OnClickQualityListItem = function(self, btn, index)
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

M.OnRenderConstructListItem = function(self, btn, index)
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

M.OnClickConstructListItem = function(self, btn, index)
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

M.OnGetQualityListTIndex = function(self, index)
	return 0
end

M.OnGetConstructListTIndex = function(self, index)
	return 0
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

M.InitData = function(self)
	self.lastQualityBtn = nil
	self.lastConstructBtn = nil
	self.isFromInfo = false
end

M.OnShow = function(self, panelId, data)
	self.InitData(self)

	if data.from ~= gPanelId.CHAOS_CULTIVATION_MAIN_PANEL then
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

		self.ShowInfoFilter(self)
	elseif data.from ~= gPanelId.CHAOS_RECYCLE_PANEL then
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

		self.ShowRecycleFilter(self)
	end
end

M.ShowInfoFilter = function(self)
	self.qualityListData = self.infoQualityData
	self.constructListData = self.infoConstructData

	self.bindData.qualityList:SetSimpleList(#self.infoQualityData)
	self.bindData.constructList:SetSimpleList(#self.infoConstructData)
end

M.ShowRecycleFilter = function(self)
	self.qualityListData = self.recycleQualityData
	self.constructListData = self.recycleConstructData

	self.bindData.qualityList:SetSimpleList(#self.recycleQualityData)
	self.bindData.constructList:SetSimpleList(#self.recycleConstructData)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end
