-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\StorageBoxMenuPanelStore.lua
-- Decompiled from: 01299_StorageBoxMenuPanelStore.lua_c1916b69ee33.luajit

local HudInterfacestorageBoxConfig = LTConfig.HudInterfacestorageBoxConfig
local InputButtonNameConfig = LTConfig.InputButtonNameConfig
C_StorageBoxMenuPanelStore = DefClass("C_StorageBoxMenuPanelStore", C_StorageBoxMenuPanelStore, C_StoreGroup)
GroupName2Class.StorageBoxMenuPanelStore = C_StorageBoxMenuPanelStore
local M = C_StorageBoxMenuPanelStore

M.DefineAllVariables = function(self)
	self.configList = {}
	self.LIST_COL_COUNT = 3
	self.MENU_INDEX = {
		["I\\u"] = 3,
		["p{\\xfc\\x82\\xb7=\\x95)\\xe6\\xc6"] = 1,
		["B_\\x80\\s\\x84\\xd7oCYRi"] = 2,
		["/\\xcck%\\xfe#\\x97b\\x95\\x9f\\x98"] = 4
	}
	self.STORAGE_BOX = {
		[self.MENU_INDEX.CAR_SUMMON] = {
			getEnable = function ()
				return gCoreHudUIManager:GetBattleSkillInteractable(gCoreHudUIManager.skillType.PhoneCall)
			end,
			onClick = function ()
				gCallPhoneUtils.OnCarSummonBtnClick()
			end
		},
		[self.MENU_INDEX.MILK_VEHICLE] = {
			getEnable = function ()
				return gCoreHudUIManager:GetBattleSkillInteractable(gCoreHudUIManager.skillType.MilkCar)
			end,
			onClick = function ()
				gCallPhoneUtils.OnMilkCarSummonBtnClick()
			end
		},
		[self.MENU_INDEX.SCAN] = {
			getEnable = function ()
				return gUIFunctionStateManager:GetScanEnable()[2]
			end,
			onClick = function ()
				gUIFunctionStateManager:Scan()
			end
		},
		[self.MENU_INDEX.MOTION_ACTION] = {
			getEnable = function ()
				return gCoreHudUIManager:GetBattleSkillInteractable(gCoreHudUIManager.skillType.MotionAction)
			end,
			onClick = function ()
				gMainPhoneFunctionAction.OpenCharMotionPanel()
			end
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

M.OnGroupEnable = function(self)
	self.RegisterDataSetEvents(self, self.dataSetEvents)
end

M.OnGroupDisable = function(self)
	self.ClearDataSetEvents(self)
end

M.OnShow = function(self)
	self:LoadConfigList()
	self.bindData.menuList:SetSimpleList(#self.configList)
end

M.GenMessageEvents = function(self)
	self.dataSetEvents = {
		{
			gUIFunctionStateManager.StateMonitor,
			"@Yϳ\\xa1\\xb9\\xc5\\xed",
			self.CreateActionWithArgs(self, "RefreshElementAtIndex", self.MENU_INDEX.SCAN),
			nil,
			false
		},
		{
			gCoreHudUIManager.buttonStateMonitor,
			gCoreHudUIManager.skillType.MotionAction,
			self.CreateActionWithArgs(self, "RefreshElementAtIndex", self.MENU_INDEX.MOTION_ACTION),
			nil,
			false
		},
		{
			gCoreHudUIManager.buttonStateMonitor,
			gCoreHudUIManager.skillType.PhoneCall,
			self.CreateActionWithArgs(self, "RefreshElementAtIndex", self.MENU_INDEX.CAR_SUMMON),
			nil,
			false
		},
		{
			gCoreHudUIManager.buttonStateMonitor,
			gCoreHudUIManager.skillType.MilkCar,
			self.CreateActionWithArgs(self, "RefreshElementAtIndex", self.MENU_INDEX.MILK_VEHICLE),
			nil,
			false
		}
	}
end

M.RegisterWidget = function(self)
	self.bindData.exitBtn.luaClick = self.CreateAction(self, "OnExitBtnClick")
	self.bindData.menuList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderMenuListItem")
	self.bindData.menuList.luaSimpleClick = self.CreateAction(self, "OnSimpleClickMenuList")
end

M.OnExitBtnClick = function(self)
	gPanelManager:Close(gPanelId.S_STORAGE_BOX_MENU_WINDOW)
end

M.LoadConfigList = function(self)
	table.clear(self.configList)

	for i = 0, HudInterfacestorageBoxConfig.count - 1 do
		local cfg = HudInterfacestorageBoxConfig.LoadAt(i)

		if cfg then
			table.insert(self.configList, cfg)
		end
	end

	table.sort(self.configList, function (a, b)
		return a.SortingOrder <= b.SortingOrder
	end)
end

M.RefreshElementAtIndex = function(self, index)
	if not self.STATE_OnShowOnce then
		return
	end

	self.bindData.menuList:RefreshElement(index - 1)
end

M.OnSimpleRenderMenuListItem = function(self, btn, index)
	local cfg = self.configList[index + 1]

	if not cfg then
		return
	end

	local store = gStoreManager:GetStoreGroup("StorageBoxTemplateStore"):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.iconId = cfg.SguiImageId
	local nameCfg = InputButtonNameConfig.GetConfig(cfg.InputId)
	store.titleText = nameCfg and nameCfg.Name or ""
	local isRowEnd = (index + 1) % self.LIST_COL_COUNT ~= 0
	local isLastItem = index ~= #self.configList - 1
	store.lineActivate = not isRowEnd and not isLastItem
	store.guideID = cfg.guide or ""
	local entry = self.STORAGE_BOX[cfg.Id]
	btn.interactable = entry and entry.getEnable() or false
end

M.OnSimpleClickMenuList = function(self, btn, index)
	local cfg = self.configList[index + 1]

	if not cfg then
		return
	end

	local entry = self.STORAGE_BOX[cfg.Id]

	if not entry or not entry.getEnable() then
		return
	end

	entry.onClick()
	gPanelManager:Close(gPanelId.S_STORAGE_BOX_MENU_WINDOW)
end
