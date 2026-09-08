-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\MainPageTabPanelStore_PC.lua
-- Decompiled from: 01131_MainPageTabPanelStore_PC.lua_f658d533e1b4.luajit

local AtmosphereManager = LX6.Manager.AtmosphereManager
local AnimMgr = SGUI.AnimMgr
C_MainPageTabPanelStore_PC = DefClass("C_MainPageTabPanelStore_PC", C_MainPageTabPanelStore_PC, C_StoreGroup)
GroupName2Class.MainPageTabPanelStore_PC = C_MainPageTabPanelStore_PC
local M = C_MainPageTabPanelStore_PC

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.SIGNAL_STATE = {
		["M'|P"] = 0,
		["1A\\x95\\x8a\\x8fD"] = 2,
		["\\xa2gq"] = 1,
		["/\\\\x83\\x81\\x8dF"] = 3
	}
	self.TOTAL_ANI_TIME = 0.3
	self.TAB_ANI_NAME = "MainPageTabMove"
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnGroupEnable = function(self)
	self.moveBarSize = Vector2.New(0, self.bindData.selectedMoveBar.rect.height)

	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
	self.ClearDataSetEvents(self)

	self.moveBarSize = nil
end

M.GetStoreByWidgetSource = function(self, widget)
	return gStoreManager:GetStoreGroup("MainPageTabPanelStore"):GetStoreByWidget(widget)
end

M.GetStoreByIdSource = function(self, id)
	return gStoreManager:GetStoreGroup("MainPageTabPanelStore"):GetStoreByWidget(id)
end

M.OnShow = function(self, panelId, data)
	self.currTabName = data
	self.currTabIndex = -1

	if not self.STATE_OnShowOnce then
		self.layOutInit = false
		self.tabBtnList = {}
		self.tabs = gMainPageManager:GetTabList()

		self.bindData.selectedMoveBar.gameObject:SetActive(false)

		for i = 1, #self.tabs do
			if self.tabs[i].cfg.CheckName ~= self.currTabName then
				self.currTabIndex = i

				break
			end
		end

		self.bindData.tabList:SetSimpleList(#self.tabs)

		if self.currTabIndex <= 0 and self.currTabIndex < #self.tabs then
			self.bindData.tabList:SelectItem(self.currTabIndex - 1, false)
		end

		if #self.tabs < 1 then
			self.bindData.HideButtonsCtrl = 1
		else
			self.bindData.HideButtonsCtrl = 0
		end
	else
		self.layOutInit = true

		for i = 1, #self.tabs do
			if self.tabs[i].cfg.CheckName ~= self.currTabName then
				self.currTabIndex = i

				break
			end
		end

		local targetBtn = self.tabBtnList[self.currTabIndex]

		if targetBtn and self.bindData.selectedMoveBar then
			self.bindData.tabList:DeselectAll(false)

			if self.timer then
				self.timer:Stop()

				self.timer = nil
			end

			self:AdjustBarSize(targetBtn)

			self.timer = Timer.New(function ()
				if self.STATE_OnShowOnce then
					self.bindData.tabList:SelectItem(self.currTabIndex - 1, false)
				end
			end, self.TOTAL_ANI_TIME - 0.1):Start()

			AnimMgr.Kill(self.bindData.selectedMoveBar, self.TAB_ANI_NAME)
			AnimMgr.Move(self.bindData.selectedMoveBar, self.TAB_ANI_NAME, self:GetTargetPosition(targetBtn), self.TOTAL_ANI_TIME, 0, DG.Tweening.Ease.OutCubic, nil)
		end
	end

	self:RefreshRedPoint()

	self.bindData.semitranslucentBgCtrl = data ~= "UrbanAbility" and 1 or 0
end

M.OnUpdate = function(self)
	self.UpdateSignal(self)
	self.UpdateTime(self)
end

M.OnClose = function(self)
	AnimMgr.Kill(self.bindData.selectedMoveBar, self.TAB_ANI_NAME)

	self.tabBtnList = nil
	self.tabs = nil

	if self.timer then
		self.timer:Stop()

		self.timer = nil
	end
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.LANGUAGE_CHANGE] = self.CreateAction(self, "RefreshRedPointByMessage"),
		[gEventConstants.SYSTEM_UNLOCK_STATE_CHANGE] = self.CreateAction(self, "RefreshRedPointByMessage"),
		[gEventConstants.UPDATE_UNREAD_MSG_TIPS] = self.CreateAction(self, "RefreshRedPointByMessage"),
		[gEventConstants.REFRESH_MAIN_BUTTON_RED_POT] = self.CreateAction(self, "RefreshRedPointByMessage"),
		[gEventConstants.ADJUST_WORLD_LEVEL] = self.CreateAction(self, "RefreshRedPointByMessage"),
		[gEventConstants.PALYER_LEVEL_UP] = self.CreateAction(self, "RefreshRedPointByMessage"),
		[gEventConstants.SYNC_CURRENT_SPIRIT] = self.CreateAction(self, "RefreshRedPointByMessage"),
		[gEventConstants.ON_PLAYER_FAN_CHANGE] = self.CreateAction(self, "RefreshRedPointByMessage"),
		[gEventConstants.JOB_CHANGE_EVENT] = self.CreateAction(self, "RefreshRedPointByMessage"),
		[gEventConstants.ON_LEVEL_REWARD_UPDATE] = self.CreateAction(self, "RefreshRedPointByMessage"),
		[gEventConstants.LINK_MODE_CHANGE] = self.CreateAction(self, "RefreshRedPointByMessage"),
		[gEventConstants.AGENT_PROFILE_RED_POINT_REFRESH] = self.CreateAction(self, "RefreshRedPointByMessage"),
		[gEventConstants.UPDATE_NOTICE_RED_POT] = self.CreateAction(self, "RefreshRedPointByMessage"),
		[gEventConstants.ON_PHONE_CALL_STATE_CHANGE] = self.CreateAction(self, "RefreshRedPointByMessage")
	}
end

M.RegisterWidget = function(self)
	self.bindData.btnLeft.luaClick = self.CreateAction(self, "OnClickBtnLeft")
	self.bindData.btnRight.luaClick = self.CreateAction(self, "OnClickBtnRight")
	self.bindData.tabList.luaSimpleRenderItem = self.CreateAction(self, "OnTabListRenderItem")
	self.bindData.tabList.luaSimpleClick = self.CreateAction(self, "OnTabListClick")
	self.bindData.tabList.luaLayoutSet = self.CreateAction(self, "OnTabListLayoutSet")
end

M.OnClickBtnLeft = function(self)
	self.currTabIndex = self.currTabIndex - 1

	if self.currTabIndex >= 1 then
		self.currTabIndex = #self.tabs
	end

	gMainPageManager:ShowMainPageTab(self.tabs[self.currTabIndex].cfg.CheckName)
end

M.OnClickBtnRight = function(self)
	self.currTabIndex = self.currTabIndex + 1

	if self.currTabIndex <= #self.tabs then
		self.currTabIndex = 1
	end

	gMainPageManager:ShowMainPageTab(self.tabs[self.currTabIndex].cfg.CheckName)
end

M.OnTabListRenderItem = function(self, btn, index)
	local store = self.GetStoreByWidgetSource(self, btn)
	local data = self.tabs[index + 1]

	if store and data then
		store.name = data.cfg.Name
		local redDotId = data.cfg.RedDotId or 0
		local appId = data.cfg.AppId

		if appId <= 0 and redDotId ~= 0 then
			store.redKey = "MainPage." .. data.cfg.AppId
		else
			btn.redId = data.cfg.RedDotId
		end
	end

	self.tabBtnList[index + 1] = btn
end

M.OnTabListClick = function(self, btn, index)
	if self.currTabIndex ~= index + 1 then
		return
	end

	self.currTabIndex = index + 1

	gMainPageManager:ShowMainPageTab(self.tabs[self.currTabIndex].cfg.CheckName)
end

M.OnTabListLayoutSet = function(self)
	if self.layOutInit then
		return
	end

	local targetBtn = self.tabBtnList and self.tabBtnList[self.currTabIndex]

	if targetBtn then
		self:AdjustBarSize(targetBtn)
		self.bindData.selectedMoveBar.gameObject:SetActive(true)

		self.bindData.selectedMoveBar.localPosition = self:GetTargetPosition(targetBtn)
	end
end

M.UpdateSignal = function(self)
	local state = self.SIGNAL_STATE.Weak

	if gCS.NetworkManager.IsNormalConnected then
		local ping = gCS.TimeManager.DelayTime * 1000

		if ping > 200 then
			state = self.SIGNAL_STATE.Low
		elseif ping > 100 and ping >= 200 then
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
	local hourTime = gUIUtils:NumberTo2String(hour)
	local minTime = gUIUtils:NumberTo2String(min)
	self.bindData.time = ("%s:%s"):format(hourTime, minTime)
end

M.GetTargetPosition = function(self, targetBtn)
	local targetPos = self.bindData.tabList.rectTransform:InverseTransformPoint(targetBtn.position)
	targetPos.y = targetPos.y - targetBtn.rectTransform.rect.height * 0.5

	return targetPos
end

M.AdjustBarSize = function(self, targetBtn)
	self.moveBarSize.x = targetBtn.rectTransform.rect.width - 30
	self.bindData.selectedMoveBar.sizeDelta = self.moveBarSize
end

M.RefreshRedPoint = function(self)
	for i = 1, #self.tabs do
		local appId = self.tabs[i].cfg.AppId
		local redDotId = self.tabs[i].cfg.RedDotId or 0

		if appId <= 0 and redDotId ~= 0 then
			local redKey = "MainPage." .. self.tabs[i].cfg.AppId
			local hasRedDot = gMainPhoneUtils.GetAppHasRedDot(appId)

			SGUI.RedDotMgr.LuaSetRedDot(hasRedDot, redKey)
		end
	end
end

M.RefreshRedPointByMessage = function(self)
	if not self.STATE_OnShowOnce then
		return
	end

	self.RefreshRedPoint(self)
end

M.OnLanguageChange = function(self)
	if self.STATE_OnShowOnce then
		self.layOutInit = false

		self.bindData.tabList:RefreshList()
	end
end
