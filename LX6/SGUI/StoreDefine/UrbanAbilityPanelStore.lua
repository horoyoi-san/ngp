-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\UrbanAbilityPanelStore.lua
-- Decompiled from: 01134_UrbanAbilityPanelStore.lua_a6ee429a788d.luajit

C_UrbanAbilityPanelStore = DefClass("C_UrbanAbilityPanelStore", C_UrbanAbilityPanelStore, C_StoreGroup)
GroupName2Class.UrbanAbilityPanelStore = C_UrbanAbilityPanelStore
local M = C_UrbanAbilityPanelStore

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.defaultId = 0
	self.bindData.tabList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderTabItem")
	self.bindData.tabRect.OnRenderTab = self.CreateAction(self, "OnRenderTab")
	self.tabText = {
		[0] = LTConfig.TextCommonTextConfig.GetConfig(74003505).Text,
		LTConfig.TextCommonTextConfig.GetConfig(74003506).Text,
		LTConfig.TextCommonTextConfig.GetConfig(74003501).Text,
		LTConfig.TextCommonTextConfig.GetConfig(74003500).Text
	}
	self.bindData.spiritList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderSpiritItem")
	self.bindData.spiritList.luaSelectedChanged = self.CreateAction(self, "OnSpiritItemSelectedChange")
	self.bindData.closeBtn.luaClick = self.CreateAction(self, "OnCloseBtnClick")
	self.isUnfold = true
	self.bindData.unfoldBtn.luaClick = self.CreateAction(self, "OnUnfoldBtnClick")
	self.bindData.chatBtn.luaClick = self.CreateAction(self, "OnChatBtnClick")
	self.bindData.changeBtn.luaClick = self.CreateAction(self, "OnChangeBtnClick")
	self.bindData.modelTab.OnRenderTab = self.CreateAction(self, "OnModelPanelDisplay")
	self.bindData.changeAreaBtn.luaClick = self.CreateAction(self, "OnChangeAreaBtnClick")
	self.bindData.curWidget.luaPlatformAdaptor = self.CreateAction(self, "OnLuaPlatformAdaptor")

	if self.bindData.QBtn then
		self.bindData.QBtn.luaClick = self.CreateAction(self, "OnQBtnClick")
	end

	if self.bindData.EBtn then
		self.bindData.EBtn.luaClick = self.CreateAction(self, "OnEBtnClick")
	end

	if self.bindData.L2Btn then
		self.bindData.L2Btn.luaPress = self.CreateAction(self, "OnL2BtnBeginLongPress")
		self.bindData.L2Btn.luaRelease = self.CreateAction(self, "OnL2BtnEndLongPress")
	end

	if self.bindData.R2Btn then
		self.bindData.R2Btn.luaPress = self.CreateAction(self, "OnR2BtnBeginLongPress")
		self.bindData.R2Btn.luaRelease = self.CreateAction(self, "OnR2BtnEndLongPress")
	end

	local msgEvents = {
		[gEventConstants.ON_CHANGE_JOBTAB] = self.CreateAction(self, "OnChangeJobTab")
	}

	self.RegisterMessageEvents(self, msgEvents)
end

M.OnLuaPlatformAdaptor = function(self, scale)
	self.bindData.curWidget.transform.localScale = Vector3.New(scale, scale, scale)
end

M.OnGroupEnable = function(self)
	self.bindData.ShowMainPageCtrl = gMainPageManager:CheckMainPageShowById(gPanelId.S_URBAN_ABILITY_PANEL) and 1 or 0
end

M.OnShow = function(self, panelId, data)
	self.bindData.modelTab.selectedIndex = 0
	local needDefaultSelect = false

	if data then
		if data.tab then
			self.defaultId = data.tab
			self.defaultData = data
			needDefaultSelect = true
		else
			self.defaultId = nil
			self.defaultData = nil
		end

		if data.selectedTid then
			self.tid = data.selectedTid

			self.SetSpiritList(self)

			self.tid = 0

			self.OnSpiritItemSelectedChange(self, self.bindData.spiritList)
		end

		if needDefaultSelect then
			self.DefaultSelect(self)
		end
	end

	gUrbanAbilityManager:GetAllSpiritPanelData()
	gUrbanAbilityManager:SetPanelEnterTime()
	gCS.LuaUtils.SetUrbanAbility(true)
	self:SetQEBtnPos()

	self.L2BtnAreaActive = false
	self.R2BtnAreaActive = false
	self.lastTabRectId = -1
end

M.SetQEBtnPos = function(self)
	if not self.bindData.QPCKey or not self.bindData.EPCKey then
		return
	end

	if self.btnTimer then
		self.btnTimer:Stop()

		self.btnTimer = nil
	end

	self.btnTimer = Timer.New(function ()
		local success, min, max = self.bindData.spiritList:TryGetVisualRange(0, 0)

		if not success then
			return
		end

		local haveMin, minIcon = self.bindData.spiritList:TryGetChildAt(min, nil)
		local haveMax, maxIcon = self.bindData.spiritList:TryGetChildAt(max, nil)

		if not haveMin or not haveMax then
			return
		end

		self.bindData.QPCKey.transform:SetPosition(minIcon.transform.position)
		self.bindData.EPCKey.transform:SetPosition(maxIcon.transform.position)
	end, 0.1):Start()
end

M.OnClose = function(self)
	gCS.LuaUtils.SetUrbanAbility(false)
end

M.OnModelPanelDisplay = function(self)
	self.subModelStore = gStoreManager:GetStoreGroup("UrbanAbilityModelViewerStore")

	self.subModelStore:LoadModel(self:GetCurSpiritTid())
end

M.OnDestroy = function(self)
	gCS.LuaUtils.SetUrbanAbility(false)
	gUrbanAbilityManager:PanelExitTime()
	self:ClearMessageEvents()

	if self.modelTimer then
		self.modelTimer:Stop()

		self.modelTimer = nil
	end

	if self.btnTimer then
		self.btnTimer:Stop()

		self.btnTimer = nil
	end
end

M.OnEnable = function(self)
	self.tid = nil

	self.DefaultSelect(self)
	self.SetLiHui(self)
	self.SetSpiritList(self)
	self.InitModelBg(self)
end

M.InitModelBg = function(self)
	self.bindData.imgBg.gameObject:SetActive(true)

	if self.modelTimer then
		self.modelTimer:Stop()

		self.modelTimer = nil
	end

	self.model = Timer.New(function ()
		if self.bindData.imgBg then
			self.bindData.imgBg.gameObject:SetActive(false)
		end
	end, 0.1):Start()
end

M.DefaultSelect = function(self)
	local listdata = {}
	self.bindData.tabRect.selectedIndex = self.defaultId
	local num = 3
	self.maxTabIndex = num

	for i = 0, num do
		local info = {
			id = i,
			selected = self.defaultId ~= i
		}

		table.insert(listdata, info)
	end

	self._tabListData = listdata

	self.bindData.tabList:SetSimpleList(#listdata)

	if self.defaultId then
		self.bindData.tabList:SelectItem(self.defaultId, false)
	end
end

M.OnRenderTab = function(self, index, widget)
	if not self.L2BtnAreaActive and not self.R2BtnAreaActive then
		self.OnChangeAreaBtnClick(self)
	end

	if not self.defaultData then
		return
	end

	local store = gStoreManager:GetStoreGroup(widget.Store)

	store:SetDefaultData(self.defaultData)

	self.defaultData = nil
end

M.OnRenderTabItem = function(self, btn, index)
	local data = self._tabListData[index + 1]
	local store = gStoreManager:GetStoreGroup("UrbanAbilityTabStore"):GetStoreByWidget(btn)
	store.title.text = self.tabText[data.id]
	store.icon = LTConfig.UrbanAbilityConfig.TabIcon[data.id + 1]
	store.tabBtn.luaClick = self:CreateActionWithArgs("OnItemClick", data.id)
	store.guideID = data.id ~= 4 and LTConfig.FightSkillConfig.TabGuideId or ""
end

M.SetLiHui = function(self)
	local cfg = LTConfig.FightSpiritConfig.GetConfig(gBattleSpiritMgr.currentSpiritTemplateId)
	self.bindData.iconId = cfg.SguiVerticalDrawing
end

M.SetSpiritList = function(self)
	self.spiritViewData = gSpiritManager:GetSpirit(self:GetCurSpiritTid())
	self.bindData.name.text = gPlayerManager.infoLogin.bindData.name
	local head = gStoreManager:GetStoreGroup("HeadAvatarStore"):GetStoreByWidget(self.bindData.head)
	head.headIcon = gHunLunManager:GetHeadIconAndName(gPlayerManager.infoLogin.bindData.infoPzHeadInfo.SystemHeadId)
	self.spiritList = gUrbanAbilityManager:GetAllLingList()
	self.spiritIndexList = {}
	local ulistData = {}
	local targetTid = self:GetCurSpiritTid()

	for i, v in pairs(self.spiritList) do
		local cfg = LTConfig.FightSpiritConfig.GetConfig(v.Id)

		if not cfg then
			print_error("SetSpiritList Not Find FightSpirit  Id = " .. v.Id)

			return
		end

		local info = {
			id = v.Id,
			selected = v.Id ~= targetTid,
			cfg = cfg,
			alreadyJoin = true
		}

		table.insert(ulistData, info)
	end

	self._spiritListData = ulistData
	local selectIdx = -1

	for i, v in ipairs(ulistData) do
		if v.selected then
			selectIdx = i - 1

			break
		end
	end

	self.bindData.spiritList:SetSimpleList(#ulistData)

	if selectIdx > 0 then
		self.bindData.spiritList:SelectItem(selectIdx, false)
	end

	self.bindData.spiritList:GoToIndex(self.bindData.spiritList.selectedIndex, true)
end

M.GetCurSpiritTid = function(self)
	if not self.tid then
		return gSpiritManager:GetCurFirstSpiritTid()
	end

	return self.tid
end

M.OnRenderSpiritItem = function(self, btn, index)
	local data = self._spiritListData[index + 1]
	local store = gStoreManager:GetStoreGroup("HeadAvatarAquareBtnStore"):GetStoreByWidget(btn)
	local cfg = data.cfg
	store.iconId = cfg.SHeadIconID
	store.bg = Color.NewByStr(cfg.CharListTemplateBgColor)
	store.guide = cfg.GuideId

	if data.alreadyJoin then
		store.type = 0
	elseif data.canJoin then
		store.type = 1
	else
		store.type = 2
	end
end

M.OnSpiritItemSelectedChange = function(self, uList)
	local spiritData = {}
	local selectedIndex = uList.selectedIndex

	if selectedIndex >= 0 then
		return
	end

	local data = self._spiritListData[selectedIndex + 1]

	if not data then
		return
	end

	local cfg = LTConfig.FightSpiritConfig.GetConfig(data.id)

	if not cfg then
		print_debug("FightSpiritConfig 里不存在 " .. data.id)

		return
	end

	spiritData.cfg = cfg
	spiritData.data = data

	self.OnSpiritItemClick(self, spiritData)
end

M.OnChangeJobTab = function(self, eventId, data)
	if data == self.bindData.tabRect.selectedIndex then
		self.bindData.tabRect.selectedIndex = data
	end
end

M.SetPageData = function(self, index, para)
	if index <= 0 then
		self.SetPageDataPara = para

		self:OnItemClick(index)
		self.bindData.tabList:SelectItem(index)
	end
end

M.OnUnfoldBtnClick = function(self)
	self.isUnfold = not self.isUnfold

	self.bindData.goLeft:SetActive(self.isUnfold)
end

M.OnSpiritItemClick = function(self, data)
	if self.tid ~= data.data.id then
		return
	end

	self.tid = data.data.id
	self.fightSpiritCfg = data.cfg
	self.bindData.iconId = data.cfg.SguiVerticalDrawing

	self:SetChangeBtnStatus()

	self.bindData.hideTab = 0

	gMessageManager:SendMessage(gEventConstants.ON_CHANGE_SPIRITVIEW_DATA, data)

	if self.subModelStore then
		self.subModelStore:LoadModel(self:GetCurSpiritTid())
	end
end

M.OnCloseBtnClick = function(self)
	if gCommonItemManager.itemToolTipRefBtn then
		gCommonItemManager:CloseItemToolTips()

		return
	end

	if self.subModelStore then
		self.subModelStore.bindData.camera.enabled = false
	end

	gNewGuideMgr:NotifySignal(EGuideSignal.UrbanAbilityPanelClose)
	Timer.New(function ()
		gPanelManager:Close(gPanelId.S_URBAN_ABILITY_PANEL)
	end, 0.5):Start()
end

M.OnItemClick = function(self, id)
	if self.lastTabRectId ~= id then
		return
	end

	self.bindData.tabRect.selectedIndex = id
	self.lastTabRectId = id
end

M.OnL1BtnClick = function(self)
	local index = self.bindData.tabRect.selectedIndex

	if index <= 0 then
		self:OnItemClick(index - 1)
		self.bindData.tabList:SelectItem(index - 1)
	end
end

M.OnR1BtnClick = function(self)
	local index = self.bindData.tabRect.selectedIndex

	if index >= (self.maxTabIndex or 4) then
		self:OnItemClick(index + 1)
		self.bindData.tabList:SelectItem(index + 1)
	end
end

M.OnChatBtnClick = function(self)
end

M.SetChangeBtnStatus = function(self)
	if self.fightSpiritCfg.Faction ~= 0 then
		self.bindData.changeBtn.interactable = true

		return
	end

	local agentConfig = LTConfig.AgentConfig.GetConfig(self.fightSpiritCfg.AgentId)

	if agentConfig ~= nil then
		return
	end

	local faction = agentConfig.Faction
	local info = gClientUtils.GetFactionInfo(faction)

	if info ~= nil then
		return
	end

	if LTConfig.FactionConfig.DispositionDontSwitch >= info.DispositionLevel then
		self.bindData.changeBtn.interactable = true

		return
	end

	self.bindData.changeBtn.interactable = not self.fightSpiritCfg.DispositionDontSwitch
end

M.OnChangeBtnClick = function(self)
	local selectTid = self:GetCurSpiritTid()

	if selectTid ~= gSpiritManager:GetCurFirstSpiritTid() then
		gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.AbilityHome_ChangeBtn_CurrentRole)

		return
	end

	gLoadingManager:SwitchTeleport_BeginShow(selectTid)
	gPanelManager:Close(gPanelId.S_URBAN_ABILITY_PANEL)
	gMainPhoneUtils.CloseMainPhonePanel()
end

M.OnChangeAreaBtnClick = function(self)
	local store = nil

	if self.bindData.tabRect.selectedIndex ~= 3 then
		store = gStoreManager:GetStoreGroup("UrbanAbilityBadgePanelStore")
	elseif self.bindData.tabRect.selectedIndex ~= 2 then
		store = gStoreManager:GetStoreGroup("UrbanAbilityOccupation1PanelStore")
	elseif self.bindData.tabRect.selectedIndex ~= 1 then
		store = gStoreManager:GetStoreGroup("UrbanAbilityBasicFeatureStore")
	elseif self.bindData.tabRect.selectedIndex ~= 0 then
		store = gStoreManager:GetStoreGroup("AbilityHomePanelStore")
	end

	if store then
		SGUI.UNavigationMgr.Inst.CurrentActiveArea = store.bindData.navigationArea
	else
		SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.navigationArea
	end
end

M.OnQBtnClick = function(self)
	self.SwitchSpiritIndex(self, -1)
end

M.OnEBtnClick = function(self)
	self.SwitchSpiritIndex(self, 1)
end

M.SwitchSpiritIndex = function(self, delta)
	local index = self.bindData.spiritList.selectedIndex + delta

	if index <= 0 or index <= #self.spiritList - 1 then
		return
	end

	self.bindData.spiritList:SelectItem(index)

	local success, min, max = self.bindData.spiritList:TryGetVisualRange(0, 0)

	if success and (index <= min or max >= index) then
		local goToIndex = delta <= 0 and math.max(0, index - (max - min)) or index

		self.bindData.spiritList:GoToIndex(goToIndex, true)
	end

	self.SetQEBtnPos(self)
end

M.OnL2BtnBeginLongPress = function(self)
	if self.R2BtnAreaActive then
		return
	end

	self.L2BtnAreaActive = true
	SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.tabListNavigationArea
	self.bindData.ctrlTab = 1
end

M.OnL2BtnEndLongPress = function(self)
	if self.L2BtnAreaActive then
		self.OnChangeAreaBtnClick(self)

		self.L2BtnAreaActive = false
		self.bindData.ctrlTab = 0
	end
end

M.OnR2BtnBeginLongPress = function(self)
	if self.L2BtnAreaActive then
		return
	end

	self.R2BtnAreaActive = true
	SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.fightSpiritListNavigationArea
	self.bindData.ctrlRolelist = 1
end

M.OnR2BtnEndLongPress = function(self)
	if self.R2BtnAreaActive then
		self.OnChangeAreaBtnClick(self)

		self.R2BtnAreaActive = false
		self.bindData.ctrlRolelist = 0
	end
end
