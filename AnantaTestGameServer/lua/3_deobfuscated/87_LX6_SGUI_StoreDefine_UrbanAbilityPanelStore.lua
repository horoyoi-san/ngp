C_UrbanAbilityPanelStore = DefClass("C_UrbanAbilityPanelStore", C_UrbanAbilityPanelStore, C_StoreGroup)
GroupName2Class.UrbanAbilityPanelStore = C_UrbanAbilityPanelStore
local M = C_UrbanAbilityPanelStore

function M:ctor()
	return
end

function M:OnAwake()
	self.defaultId = 0
	self.bindData.tabList.luaRenderItem = self:CreateAction("OnRenderTabItem")
	self.bindData.tabRect.OnRenderTab = self:CreateAction("OnRenderTab")
	self.tabText = {
		[0] = LTConfig.TextCommonTextConfig.GetConfig(74003505).Text,
		LTConfig.TextCommonTextConfig.GetConfig(74003506).Text,
		LTConfig.TextCommonTextConfig.GetConfig(74003501).Text,
		LTConfig.TextCommonTextConfig.GetConfig(74003500).Text
	}
	self.bindData.spiritList.luaRenderItem = self:CreateAction("OnRenderSpiritItem")
	self.bindData.spiritList.luaSelectedChanged = self:CreateAction("OnSpiritItemSelectedChange")
	self.bindData.closeBtn.luaClick = self:CreateAction("OnCloseBtnClick")
	self.isUnfold = true
	self.bindData.unfoldBtn.luaClick = self:CreateAction("OnUnfoldBtnClick")
	self.bindData.chatBtn.luaClick = self:CreateAction("OnChatBtnClick")
	self.bindData.changeBtn.luaClick = self:CreateAction("OnChangeBtnClick")
	self.bindData.modelTab.OnRenderTab = self:CreateAction("OnModelPanelDisplay")
	self.bindData.changeAreaBtn.luaClick = self:CreateAction("OnChangeAreaBtnClick")

	self.bindData.chatGroup:SetActive(false)

	self.bindData.curWidget.luaPlatformAdaptor = self:CreateAction("OnLuaPlatformAdaptor")

	if self.bindData.QBtn then
		self.bindData.QBtn.luaClick = self:CreateAction("OnQBtnClick")
	end

	if self.bindData.EBtn then
		self.bindData.EBtn.luaClick = self:CreateAction("OnEBtnClick")
	end

	if self.bindData.L2Btn then
		self.bindData.L2Btn.luaPress = self:CreateAction("OnL2BtnBeginLongPress")
		self.bindData.L2Btn.luaRelease = self:CreateAction("OnL2BtnEndLongPress")
	end

	if self.bindData.R2Btn then
		self.bindData.R2Btn.luaPress = self:CreateAction("OnR2BtnBeginLongPress")
		self.bindData.R2Btn.luaRelease = self:CreateAction("OnR2BtnEndLongPress")
	end

	local msgEvents = {
		[gEventConstants.ON_CHANGE_JOBTAB] = self:CreateAction("OnChangeJobTab")
	}

	self:RegisterMessageEvents(msgEvents)
end

function M:OnLuaPlatformAdaptor(scale)
	self.bindData.curWidget.transform.localScale = Vector3.New(scale, scale, scale)
end

function M:OnGroupEnable()
	self.bindData.ShowMainPageCtrl = gMainPageManager:CheckMainPageShowById(gPanelId.S_URBAN_ABILITY_PANEL) and 1 or 0
end

function M:OnShow(panelId, data)
	self.bindData.modelTab.selectedIndex = 0

	if data then
		if data.tab then
			self.defaultId = data.tab
			self.defaultData = data

			self:DefaultSelect()
		else
			self.defaultId = nil
			self.defaultData = nil
		end

		if data.SelectedTid then
			self.tid = data.SelectedTid

			self:SetSpiritList()

			self.tid = 0

			self:OnSpiritItemSelectedChange(self.bindData.spiritList)
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

function M:SetQEBtnPos()
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

function M:OnClose()
	gCS.LuaUtils.SetUrbanAbility(false)
end

function M:OnModelPanelDisplay()
	self.subModelStore = gStoreManager:GetStoreGroup("UrbanAbilityModelViewerStore")

	self.subModelStore:LoadModel(self:GetCurSpiritTid())
end

function M:OnDestroy()
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

function M:OnEnable()
	self.tid = nil

	self:DefaultSelect()
	self:SetLiHui()
	self:SetSpiritList()
	self.bindData.chatGroup:SetActive(gUrbanAbilityManager.isNewMsg)
	self:InitModelBg()
end

function M:InitModelBg()
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

function M:DefaultSelect()
	local listdata = {}
	self.bindData.tabRect.selectedIndex = self.defaultId
	local num = 3
	self.maxTabIndex = num

	for i = 0, num do
		local info = {
			id = i,
			selected = self.defaultId == i
		}

		table.insert(listdata, info)
	end

	self.bindData.tabList:SetList(listdata)
end

function M:OnRenderTab(index, widget)
	if not self.L2BtnAreaActive and not self.R2BtnAreaActive then
		self:OnChangeAreaBtnClick()
	end

	if not self.defaultData then
		return
	end

	local store = gStoreManager:GetStoreGroup(widget.Store)

	store:SetDefaultData(self.defaultData)

	self.defaultData = nil
end

function M:OnRenderTabItem(btn, _, data)
	local store = gStoreManager:GetStoreGroup("UrbanAbilityTabStore"):GetStoreByWidget(btn)
	store.title.text = self.tabText[data.id]
	store.icon = LTConfig.UrbanAbilityConfig.TabIcon[data.id + 1]
	store.tabBtn.luaClick = self:CreateActionWithArgs("OnItemClick", data.id)
	store.guideID = data.id == 4 and LTConfig.FightSkillConfig.TabGuideId or ""
end

function M:SetLiHui()
	local cfg = LTConfig.FightSpiritConfig.GetConfig(gBattleSpiritMgr.currentSpiritTemplateId)
	self.bindData.iconId = cfg.SguiVerticalDrawing
end

function M:SetSpiritList()
	self.spiritViewData = gSpiritManager:GetSpirit(self:GetCurSpiritTid())
	self.bindData.name.text = gPlayerManager.infoLogin.bindData.name
	local head = gStoreManager:GetStoreGroup("HeadAvatarStore"):GetStoreByWidget(self.bindData.head)
	head.headIcon = gHunLunManager:GetHeadIconAndName(gPlayerManager.infoLogin.bindData.infoPzHeadInfo.SystemHeadId)
	self.spiritList = gUrbanAbilityManager:GetAllLingList()
	self.spiritIndexList = {}
	local ulistData = {}

	for i, v in pairs(self.spiritList) do
		local cfg = LTConfig.FightSpiritConfig.GetConfig(v.Id)

		if not cfg then
			print_error("SetSpiritList Not Find FightSpirit  Id = " .. v.Id)

			return
		end

		if v.Id ~= 15021040 then
			local info = {
				id = v.Id,
				selected = v.Id == self:GetCurSpiritTid(),
				cfg = cfg,
				alreadyJoin = true
			}

			table.insert(ulistData, info)
		end
	end

	self.bindData.spiritList:SetList(ulistData)
	self.bindData.spiritList:GoToIndex(self.bindData.spiritList.selectedIndex, true)
end

function M:GetCurSpiritTid()
	if self.tid and gSpiritManager:GetSpirit(self.tid) then
		return self.tid
	end

	local firstSpiritTid = gSpiritManager:GetCurFirstSpiritTid()

	if gSpiritManager:GetSpirit(firstSpiritTid) then
		return firstSpiritTid
	end

	return 15020967
end

function M:OnRenderSpiritItem(btn, _, data)
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

function M:OnSpiritItemSelectedChange(uList)
	local spiritData = {}
	local data = uList.selectedItem

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

	self:OnSpiritItemClick(spiritData)
end

function M:OnChangeJobTab(eventId, data)
	if data ~= self.bindData.tabRect.selectedIndex then
		self.bindData.tabRect.selectedIndex = data
	end
end

function M:SetPageData(index, para)
	if index > 0 then
		self.SetPageDataPara = para

		self:OnItemClick(index)
		self.bindData.tabList:SelectItem(index)
	end
end

function M:OnUnfoldBtnClick()
	self.isUnfold = not self.isUnfold

	self.bindData.goLeft:SetActive(self.isUnfold)
end

function M:OnSpiritItemClick(data)
	if self.tid == data.data.id then
		return
	end

	self.tid = data.data.id
	self.fightSpiritCfg = data.cfg
	self.bindData.iconId = data.cfg.SguiVerticalDrawing

	self:SetChangeBtnStatus()

	self.bindData.hideTab = 0

	gMessageManager:SendMessage(gEventConstants.ON_CHANGE_SPIRITVIEW_DATA, data)
	self.subModelStore:LoadModel(self:GetCurSpiritTid())
end

function M:OnCloseBtnClick()
	self.subModelStore.bindData.camera.enabled = false

	gNewGuideMgr:NotifySignal(EGuideSignal.UrbanAbilityPanelClose)
	Timer.New(function ()
		gPanelManager:Close(gPanelId.S_URBAN_ABILITY_PANEL)
	end, 0.5):Start()
end

function M:OnItemClick(id)
	if self.lastTabRectId == id then
		return
	end

	self.bindData.tabRect.selectedIndex = id
	self.lastTabRectId = id
end

function M:OnL1BtnClick()
	local index = self.bindData.tabRect.selectedIndex

	if index > 0 then
		self:OnItemClick(index - 1)
		self.bindData.tabList:SelectItem(index - 1)
	end
end

function M:OnR1BtnClick()
	local index = self.bindData.tabRect.selectedIndex

	if index < (self.maxTabIndex or 4) then
		self:OnItemClick(index + 1)
		self.bindData.tabList:SelectItem(index + 1)
	end
end

function M:OnChatBtnClick()
	self.bindData.chatGroup:SetActive(true)
end

function M:SetChangeBtnStatus()
	if self.fightSpiritCfg.Faction == 0 then
		self.bindData.changeBtn.interactable = true

		return
	end

	local agentConfig = LTConfig.AgentConfig.GetConfig(self.fightSpiritCfg.AgentId)

	if agentConfig == nil then
		return
	end

	local faction = agentConfig.Faction
	local info = gClientUtils.GetFactionInfo(faction)

	if info == nil then
		return
	end

	if LTConfig.FactionConfig.DispositionDontSwitch < info.DispositionLevel then
		self.bindData.changeBtn.interactable = true

		return
	end

	self.bindData.changeBtn.interactable = not self.fightSpiritCfg.DispositionDontSwitch
end

function M:OnChangeBtnClick()
	local selectTid = self:GetCurSpiritTid()

	if selectTid == gSpiritManager:GetCurFirstSpiritTid() then
		gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.AbilityHome_ChangeBtn_CurrentRole)

		return
	end

	gLoadingManager:SwitchTeleport_BeginShow(selectTid)
	gPanelManager:Close(gPanelId.S_URBAN_ABILITY_PANEL)
	gMainPhoneUtils.CloseMainPhonePanel()
end

function M:OnChangeAreaBtnClick()
	local store = nil

	if self.bindData.tabRect.selectedIndex == 3 then
		store = gStoreManager:GetStoreGroup("UrbanAbilityBadgePanelStore")
	elseif self.bindData.tabRect.selectedIndex == 2 then
		store = gStoreManager:GetStoreGroup("UrbanAbilityOccupation1PanelStore")
	elseif self.bindData.tabRect.selectedIndex == 1 then
		store = gStoreManager:GetStoreGroup("UrbanAbilityBasicFeatureStore")
	elseif self.bindData.tabRect.selectedIndex == 0 then
		store = gStoreManager:GetStoreGroup("AbilityHomePanelStore")
	end

	if store then
		SGUI.UNavigationMgr.Inst.CurrentActiveArea = store.bindData.navigationArea
	else
		SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.navigationArea
	end
end

function M:OnQBtnClick()
	local index = self.bindData.spiritList.selectedIndex

	if index > 0 then
		self.bindData.spiritList:SelectItem(index - 1)
	else
		self.bindData.spiritList:SelectItem(#self.spiritList - 1)
	end
end

function M:OnEBtnClick()
	local index = self.bindData.spiritList.selectedIndex

	if index < #self.spiritList - 1 then
		self.bindData.spiritList:SelectItem(index + 1)
	else
		self.bindData.spiritList:SelectItem(0)
	end
end

function M:OnL2BtnBeginLongPress()
	print_debug("zxxx   OnL2BtnBeginLongPress")

	if self.R2BtnAreaActive then
		return
	end

	self.L2BtnAreaActive = true
	SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.tabListNavigationArea
	self.bindData.ctrlTab = 1
end

function M:OnL2BtnEndLongPress()
	print_debug("zxxx   OnL2BtnEndLongPress")

	if self.L2BtnAreaActive then
		self:OnChangeAreaBtnClick()

		self.L2BtnAreaActive = false
		self.bindData.ctrlTab = 0
	end
end

function M:OnR2BtnBeginLongPress()
	print_debug("zxxx   OnR2BtnBeginLongPress")

	if self.L2BtnAreaActive then
		return
	end

	self.R2BtnAreaActive = true
	SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.fightSpiritListNavigationArea
	self.bindData.ctrlRolelist = 1
end

function M:OnR2BtnEndLongPress()
	print_debug("zxxx   OnR2BtnEndLongPress")

	if self.R2BtnAreaActive then
		self:OnChangeAreaBtnClick()

		self.R2BtnAreaActive = false
		self.bindData.ctrlRolelist = 0
	end
end
