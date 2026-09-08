-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\HotCenterMainPageTabPanelStore_PC.lua
-- Decompiled from: 01762_HotCenterMainPageTabPanelStore_PC.lua_c83a0d37eb27.luajit

local AtmosphereManager = LX6.Manager.AtmosphereManager
local AnimMgr = SGUI.AnimMgr

local SetWidgetActive = function(widget, isActive)
	if widget and widget.SetActive then
		widget.SetActive(widget, isActive)
	elseif widget and widget.gameObject then
		widget.gameObject:SetActive(isActive)
	end
end

local IsSameTabs = function(a, b)
	if not a or not b then
		return false
	end

	if #a == #b then
		return false
	end

	for i = 1, #a do
		local ta = a[i]
		local tb = b[i]

		if not ta or not tb then
			return false
		end

		if ta.name == tb.name or ta.redKey == tb.redKey or ta.mainType == tb.mainType then
			return false
		end
	end

	return true
end

C_HotCenterMainPageTabPanelStore_PC = DefClass("C_HotCenterMainPageTabPanelStore_PC", C_HotCenterMainPageTabPanelStore_PC, C_StoreGroup)
GroupName2Class.HotCenterMainPageTabPanelStore_PC = C_HotCenterMainPageTabPanelStore_PC
local M = C_HotCenterMainPageTabPanelStore_PC

M.ctor = function(self)
	self.DEFINE_DynamicOnUpdate = true
end

M.EnsureInitialized = function(self)
	if self.tabs == nil and self.tabBtnList == nil then
		return
	end

	self.DefineAllVariables(self)
end

M.DefineAllVariables = function(self)
	self.SIGNAL_STATE = {
		["M'|P"] = 0,
		["1A\\x95\\x8a\\x8fD"] = 2,
		["\\xa2gq"] = 1,
		["/\\\\x83\\x81\\x8dF"] = 3
	}
	self.TOTAL_ANI_TIME = 0.3
	self.TAB_ANI_NAME = "HotCenterMainPageTabMove"
	self.tabs = {}
	self.currTabIndex = 1
	self.tabBtnList = {}
	self.selectCallback = nil
	self.moveBarSize = nil
	self.isDynamicUpdateRegistered = false
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.RegisterWidget(self)
end

M.OnDestroy = function(self)
	self.UnregisterDynamicUpdate(self)
end

M.RegisterWidget = function(self)
	if self.bindData.btnLeft then
		self.bindData.btnLeft.luaClick = self.CreateAction(self, "OnClickBtnLeft")
	end

	if self.bindData.btnRight then
		self.bindData.btnRight.luaClick = self.CreateAction(self, "OnClickBtnRight")
	end

	if self.bindData.tabList then
		self.bindData.tabList.luaSimpleRenderItem = self.CreateAction(self, "OnTabListRenderItem")
		self.bindData.tabList.luaSimpleClick = self.CreateAction(self, "OnTabListClick")
		self.bindData.tabList.luaLayoutSet = self.CreateAction(self, "OnTabListLayoutSet")
	end
end

M.RegisterDynamicUpdate = function(self)
	if self.isDynamicUpdateRegistered then
		return
	end

	gStoreManager:RegisterDynamicOnUpdate(self)

	self.isDynamicUpdateRegistered = true
end

M.UnregisterDynamicUpdate = function(self)
	if not self.isDynamicUpdateRegistered then
		return
	end

	gStoreManager:UnregisterDynamicOnUpdate(self)

	self.isDynamicUpdateRegistered = false
end

M.GetItemStore = function(self, widget)
	local storeGroup = gStoreManager:GetStoreGroup("MainPageTabPanelStore")

	if not storeGroup then
		return
	end

	return storeGroup.GetStoreByWidget(storeGroup, widget)
end

M.ShowPanel = function(self, data)
	self:EnsureInitialized()

	data = data or {}
	local visible = data.visible == false

	SetWidgetActive(self.rootGo, visible)

	if not visible then
		self.UnregisterDynamicUpdate(self)

		return
	end

	self:RegisterDynamicUpdate()

	local newTabs = data.tabs or {}
	local reuse = IsSameTabs(self.tabs, newTabs) and not table.isNilOrEmpty(self.tabBtnList)
	self.tabs = newTabs
	self.selectCallback = data.selectCallback
	self.tabBtnList = self.tabBtnList or {}
	local targetIndex = data.selectedIndex or 1

	if targetIndex >= 1 then
		targetIndex = 1
	elseif #self.tabs <= 0 and targetIndex <= #self.tabs then
		targetIndex = #self.tabs
	end

	self.bindData.HideButtonsCtrl = #self.tabs < 1 and 1 or 0
	self.bindData.semitranslucentBgCtrl = 0

	if not reuse and self.bindData.tabList then
		self.tabBtnList = {}

		if self.bindData.selectedMoveBar then
			self.bindData.selectedMoveBar.gameObject:SetActive(false)
		end

		self.bindData.tabList:SetSimpleList(#self.tabs)
	end

	if #self.tabs < 0 then
		self.currTabIndex = 1

		return
	end

	self.SelectTabByIndex(self, targetIndex, false)
end

M.SelectTabByIndex = function(self, targetIndex, triggerCallback)
	self.EnsureInitialized(self)

	if #self.tabs < 0 then
		return
	end

	if targetIndex >= 1 then
		targetIndex = #self.tabs
	elseif targetIndex <= #self.tabs then
		targetIndex = 1
	end

	local changed = targetIndex == self.currTabIndex
	self.currTabIndex = targetIndex
	self.tabBtnList = self.tabBtnList or {}
	local targetBtn = self.tabBtnList[self.currTabIndex]

	if targetBtn and self.bindData.selectedMoveBar then
		self:AdjustBarSize(targetBtn)
		self.bindData.selectedMoveBar.gameObject:SetActive(true)

		if changed then
			self.bindData.tabList:DeselectAll(false)
			AnimMgr.Kill(self.bindData.selectedMoveBar, self.TAB_ANI_NAME)
			AnimMgr.Move(self.bindData.selectedMoveBar, self.TAB_ANI_NAME, self:GetTargetPosition(targetBtn), self.TOTAL_ANI_TIME, 0, DG.Tweening.Ease.OutCubic, nil)
		else
			self.bindData.selectedMoveBar.localPosition = self.GetTargetPosition(self, targetBtn)
		end
	end

	if self.bindData.tabList then
		self.bindData.tabList:SelectItem(self.currTabIndex - 1, false)
	end

	if triggerCallback and self.selectCallback then
		self.selectCallback(self.tabs[self.currTabIndex], self.currTabIndex)
	end
end

M.OnClickBtnLeft = function(self)
	self.SelectTabByMainType(self, gClientConst.HotCenterType.Main)
end

M.OnClickBtnRight = function(self)
	self.SelectTabByMainType(self, gClientConst.HotCenterType.Online)
end

M.SelectTabByMainType = function(self, mainType)
	self.EnsureInitialized(self)

	if table.isNilOrEmpty(self.tabs) then
		return
	end

	local target = nil

	for i, tab in ipairs(self.tabs) do
		if tab and tab.mainType ~= mainType then
			target = i

			break
		end
	end

	if not target or target ~= self.currTabIndex then
		return
	end

	self.SelectTabByIndex(self, target, true)
end

M.OnTabListRenderItem = function(self, btn, index)
	self.EnsureInitialized(self)

	local data = self.tabs[index + 1]

	if not data then
		return
	end

	local store = self.GetItemStore(self, btn)

	if store then
		store.title = data.name or ""
		store.redKey = data.redKey or ""
	end

	self.tabBtnList = self.tabBtnList or {}
	self.tabBtnList[index + 1] = btn
end

M.OnTabListClick = function(self, btn, index)
	self.SelectTabByIndex(self, index + 1, true)
end

M.OnTabListLayoutSet = function(self)
	self:EnsureInitialized()

	self.tabBtnList = self.tabBtnList or {}
	local targetBtn = self.tabBtnList[self.currTabIndex]

	if not targetBtn or not self.bindData.selectedMoveBar then
		return
	end

	self:AdjustBarSize(targetBtn)
	self.bindData.selectedMoveBar.gameObject:SetActive(true)

	self.bindData.selectedMoveBar.localPosition = self:GetTargetPosition(targetBtn)
end

M.UpdateSignal = function(self)
	local state = self.SIGNAL_STATE.Weak

	if gCS.NetworkManager.IsNormalConnected then
		local ping = gCS.TimeManager.DelayTime * 1000

		if ping > 200 then
			state = self.SIGNAL_STATE.Low
		elseif ping > 100 then
			state = self.SIGNAL_STATE.Middle
		else
			state = self.SIGNAL_STATE.Strong
		end
	end

	self.bindData.signalStateCtrl = state
end

M.UpdateTime = function(self)
	local gameTime = AtmosphereManager.Instance:GetGameTime()
	local min = math.floor(gameTime / 60 % 60)
	local hour = math.floor(gameTime / gClientConst.SECONDS_PER_HOUR)
	self.bindData.time = ("%s:%s"):format(gUIUtils:NumberTo2String(hour), gUIUtils:NumberTo2String(min))
end

M.GetTargetPosition = function(self, targetBtn)
	local targetPos = self.bindData.tabList.rectTransform:InverseTransformPoint(targetBtn.position)
	targetPos.y = targetPos.y - targetBtn.rectTransform.rect.height * 0.5

	return targetPos
end

M.AdjustBarSize = function(self, targetBtn)
	if not self.bindData.selectedMoveBar then
		return
	end

	self.moveBarSize = self.moveBarSize or Vector2.New(0, self.bindData.selectedMoveBar.rect.height)
	self.moveBarSize.x = targetBtn.rectTransform.rect.width - 30
	self.bindData.selectedMoveBar.sizeDelta = self.moveBarSize
end

M.OnUpdate = function(self)
	if not self.bindData then
		return
	end

	self.UpdateSignal(self)
	self.UpdateTime(self)
end
