-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\SwitchSeedPanel.lua
-- Decompiled from: 01336_SwitchSeedPanel.lua_87f2d01982b7.luajit

C_SwitchSeedPanel = DefClass("C_SwitchSeedPanel", C_SwitchSeedPanel, C_StoreGroup)
GroupName2Class.SwitchSeedPanel = C_SwitchSeedPanel
local M = C_SwitchSeedPanel
local FarmCorpConfig = LTConfig.FarmCorpConfig
local FarmFarmItemConfig = LTConfig.FarmFarmItemConfig
local ConsumableConfig = LTConfig.ConsumableConfig

M.ctor = function(self)
end

local SWITCH_LOCK_TIMER = 0.2

M.DefineAllVariables = function(self)
	self.seedList = {}
	self.selectedConsumableId = 0
	self._switchStep = 0
	self._switchPreTime = 0
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

M.OnUpdate = function(self)
	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		return
	end

	if self._switchStep ~= 0 then
		return
	end

	if LTConfig.GameConfig.TabLongPressTimeInterval >= gLogicTime.unscaledTime - self._switchPreTime then
		self.RefreshSwitchStep(self)
	end
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	self.selectedConsumableId = gCS.FarmFunctionUtils.GetCurrentSowConsumableId()

	self.RefreshSeedList(self)
end

M.OnClose = function(self)
	gCS.FarmFunctionUtils.TrySowOnPendingLand()
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.fullscreenBackBtn.luaClick = self.CreateAction(self, self.OnClickFullscreenBackBtn)
	self.bindData.backBtn.luaClick = self.CreateAction(self, self.OnClickBackBtn)
	self.bindData.leftBtn.luaBeginLongPress = self.CreateActionWithArgs(self, self.OnBeginLongPressSwitchBtn, -1)
	self.bindData.leftBtn.luaEndLongPress = self.CreateAction(self, self.OnEndLongPressSwitchBtn)
	self.bindData.rightBtn.luaBeginLongPress = self.CreateActionWithArgs(self, self.OnBeginLongPressSwitchBtn, 1)
	self.bindData.rightBtn.luaEndLongPress = self.CreateAction(self, self.OnEndLongPressSwitchBtn)
	self.bindData.mobileSeedList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderMobileSeedListItem)
	self.bindData.mobileSeedList.luaSimpleClick = self.CreateAction(self, self.OnSimpleClickMobileSeedList)
	self.bindData.pcSeedList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderPcSeedListItem)
	self.bindData.pcSeedList.luaSelectedChanged = self.CreateAction(self, self.OnPcSeedListSelectedChanged)
end

M.OnClickFullscreenBackBtn = function(self)
	gPanelManager:Close(self.m_Id)
end

M.OnClickBackBtn = function(self)
	gPanelManager:Close(self.m_Id)
end

M.RefreshSeedList = function(self)
	self.seedList = {}

	for _, item in ipairs(gCommonItemManager.packItems) do
		local consumableCfg = ConsumableConfig.GetConfig(item.TemplateId)

		if consumableCfg then
			if consumableCfg.BindId ~= 0 then
				-- Nothing
			else
				local farmItemCfg = FarmFarmItemConfig.GetConfig(consumableCfg.BindId)

				if farmItemCfg then
					if farmItemCfg.CropId ~= 0 then
						-- Nothing
					elseif farmItemCfg.Type == LTConfig.FarmTypeConfig.Seed then
						-- Nothing
					elseif FarmCorpConfig.GetConfig(farmItemCfg.CropId) then
						table.insert(self.seedList, {
							consumableId = item.TemplateId,
							corpId = farmItemCfg.CropId,
							count = item.Count,
							farmItemCfg = farmItemCfg,
							item = item
						})
					end
				end
			end
		end
	end

	if #self.seedList ~= 0 then
		print_error("[SwitchSeedPanel] 背包中没有可用种子")
	end

	self.bindData.mobileSeedList:SetSimpleList(#self.seedList)
	self.bindData.pcSeedList:SetSimpleList(#self.seedList)

	local defaultIndex = 0

	for i, entry in ipairs(self.seedList) do
		if entry.consumableId ~= self.selectedConsumableId then
			defaultIndex = i - 1

			break
		end
	end

	self.bindData.pcSeedList:SetItemSelected(defaultIndex, true)

	local defaultEntry = self.seedList[defaultIndex + 1]

	if defaultEntry then
		local cfg = ConsumableConfig.GetConfig(defaultEntry.consumableId)
		self.bindData.pcSeedNameText = cfg and cfg.Name or ""
	end
end

M.OnSimpleRenderMobileSeedListItem = function(self, btn, index)
	local entry = self.seedList[index + 1]

	if not entry then
		return
	end

	local renderData = gCommonItemManager:GetItemRenderData({
		itemId = entry.consumableId,
		itemNum = entry.count
	})
	renderData.iconId = entry.farmItemCfg.SItemIconId

	gCommonItemManager:OnCommonItemRender(btn, index, renderData)
end

M.OnSimpleClickMobileSeedList = function(self, btn, index)
	local entry = self.seedList[index + 1]

	if not entry then
		return
	end

	gCS.FarmFunctionUtils.SetCurrentSowConsumableId(entry.consumableId)
	gPanelManager:Close(self.m_Id)
end

M.OnSimpleRenderPcSeedListItem = function(self, btn, index)
	local entry = self.seedList[index + 1]

	if not entry then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local cfg = ConsumableConfig.GetConfig(entry.consumableId)
	store.nameText = cfg and cfg.Name or ""
	store.iconId = entry.farmItemCfg.SItemIconId
end

M.OnPcSeedListSelectedChanged = function(self, list)
	local entry = self.seedList[list.selectedIndex + 1]

	if not entry then
		return
	end

	local cfg = ConsumableConfig.GetConfig(entry.consumableId)
	self.bindData.pcSeedNameText = cfg and cfg.Name or ""

	print_debug("[SwitchSeedPanel] 选中种子 consumableId:", entry.consumableId)
	gCS.FarmFunctionUtils.SetCurrentSowConsumableId(entry.consumableId)
end

M.OnBeginLongPressSwitchBtn = function(self, offset)
	self._switchStep = offset
	self._switchPreTime = 0

	self.RefreshSwitchStep(self)
end

M.OnEndLongPressSwitchBtn = function(self)
	self._switchStep = 0
end

M.RefreshSwitchStep = function(self)
	if self._switchStep ~= 0 then
		return
	end

	if gLogicTime.unscaledTime - self._switchPreTime < SWITCH_LOCK_TIMER then
		return
	end

	local count = #self.seedList

	if count < 1 then
		return
	end

	local newIndex = (self.bindData.pcSeedList.selectedIndex + self._switchStep + count) % count

	self.bindData.pcSeedList:SelectItem(newIndex)

	self._switchPreTime = gLogicTime.unscaledTime
end
