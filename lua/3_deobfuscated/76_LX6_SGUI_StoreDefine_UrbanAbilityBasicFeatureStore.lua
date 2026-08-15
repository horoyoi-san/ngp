C_UrbanAbilityBasicFeatureStore = DefClass("C_UrbanAbilityBasicFeatureStore", C_UrbanAbilityBasicFeatureStore, C_StoreGroup)
GroupName2Class.UrbanAbilityBasicFeatureStore = C_UrbanAbilityBasicFeatureStore
local M = C_UrbanAbilityBasicFeatureStore

function M:ctor()
	return
end

function M:OnAwake()
	self.bindData.sumBasicList.luaRenderItem = self:CreateAction("OnRenderSumBasicTemplateItem")
	self.bindData.abilityTemplateList.luaRenderItem = self:CreateAction("OnRenderAbilityTemplateItem")
	self.bindData.rightList.luaRenderItem = self:CreateAction("OnRenderRightListItem")
	self.bindData.iconList.luaSimpleRenderItem = self:CreateAction("OnRenderIconItem")

	function self.bindData.iconList.onGetTIndex(_)
		return 0
	end

	self.bindData.IconTipsBtn.luaRenderTooltip = self:CreateAction(self.OnRenderToolTips)
	self.urbanAbilityStore = gStoreManager:GetStoreGroup("UrbanAbilityPanelStore")
	self.bindData.changeLeftAreaBtn.luaClick = self:CreateAction("OnChangeLeftAreaBtnClick")
	self.msgEvents = {
		[gEventConstants.ON_CHANGE_SPIRITVIEW_DATA] = self:CreateAction("ChangeSpiriViewData")
	}
end

function M:OnRenderToolTips(btn, popup, index)
	if table.isNilOrEmpty(self.itemToolTipData) then
		return
	end

	gCommonItemManager:OnRenderToolTips(self.itemToolTipData, btn, popup, index)
end

function M:OnEnable()
	self:InitData()
	self.bindData.videoPlayer:Init()
	self:PlayVideo()
end

function M:PlayVideo()
	local cfg = LTConfig.FightSpiritConfig.GetConfig(self.urbanAbilityStore:GetCurSpiritTid())

	self.bindData.videoPlayer:PlayVideo(cfg.HeadIconVideoId, true, nil)
end

function M:InitData()
	if self.urbanAbilityStore.SetPageDataPara then
		local para = self.urbanAbilityStore.SetPageDataPara

		if para.pageId == gUrbanAbilityManager.URBANABILITY_PAGE.BASIC_FEATURE then
			Timer.New(function ()
				self:AbilitySumTemplateBtnClick(para.selectId)

				self.urbanAbilityStore.SetPageDataPara = nil
			end, 0.1):Start()

			return
		end
	end

	self:RegisterMessageEvents(self.msgEvents)

	self.spiritViewData = gSpiritManager:GetSpirit(self.urbanAbilityStore:GetCurSpiritTid())

	self:SetData()
end

function M:OnDisable()
	if self.lastSelectId then
		self:AskClearRedPoint(self.lastSelectId)

		self.lastSelectId = nil
	end

	self.lastSelectStore = nil

	self:ClearMessageEvents()
end

function M:SyncSpiritAbilityInfo()
	self:SetData()
end

function M:ChangeSpiriViewData(eventId, data)
	if not data.data.alreadyJoin and not data.data.canJoin then
		return
	end

	self.spiritViewData = gSpiritManager:GetSpirit(data.data.id)

	self:SetData()
	self:PlayVideo()
end

function M:SetDefaultData(data)
	local index = 1

	Timer.New(function ()
		self.spiritViewData = gSpiritManager:GetSpirit(self.urbanAbilityStore:GetCurSpiritTid())

		if data then
			self.selectUrbanAbilityId = data.urbanAbilityId
			local cfg = LTConfig.UrbanAbilityConfig.GetConfig(self.selectUrbanAbilityId)
			index = cfg.AbilityType
		end

		self:SetAbilitySumList(index)
		self:AbilitySumTemplateBtnClick(index)
	end, 0.3):Start()
end

function M:SetDefaultBuffData(index)
	local defaultData = {}
	local spiritAbilities = self.spiritViewData.SpiritInfo.SpiritAbilities

	for i, v in pairs(spiritAbilities) do
		if v.TemplateId == self.firstId then
			local cfg = LTConfig.UrbanAbilityConfig.GetConfig(v.TemplateId)
			defaultData.id = v.TemplateId
			defaultData.cfg = cfg
			defaultData.data = v
			defaultData.maxExp = gUrbanAbilityManager:GetAbilityInfoMaxExp(v.TemplateId)
			defaultData.curExp = v.Exp

			return defaultData
		end
	end
end

function M:OnRenderSumBasicTemplateItem(btn, _, data)
	local store = gStoreManager:GetStoreGroup("AbilitySumTemplateStore"):GetStoreByWidget(btn)
	local typeCfg = LTConfig.UrbanAbilityUrbanAbilityTypeConfig.GetConfig(data.id)
	store.title = typeCfg.Name
	local curExp = 0

	if self.spiritViewData then
		curExp = gUrbanAbilityManager:GetAbilityClassCurExp(self.spiritViewData.SpiritInfo.SpiritAbilities, data.id)
	end

	local maxExp = gUrbanAbilityManager:GetAbilityClassMaxExp(data.id)

	store.progress:ProgressToValue(curExp / maxExp)
	store.progress2:ProgressToValue(curExp / maxExp)

	store.level = gUrbanAbilityManager:GetAbilityInterval(curExp / maxExp)

	if maxExp <= curExp then
		store.isFull = 1
	else
		store.isFull = 0
	end

	store.icon = typeCfg.Icon
	btn.luaClick = self:CreateActionWithArgs("AbilitySumTemplateBtnClick", data.id)
end

function M:SetData()
	local sumExp = 0

	if self.spiritViewData then
		sumExp = gUrbanAbilityManager:GetAbilitySumExp(self.spiritViewData.SpiritInfo.SpiritAbilities)
	end

	self.bindData.abilityNum = sumExp

	self:SetAbilitySumList()
	Timer.New(function ()
		self:AbilitySumTemplateBtnClick(1)
	end, 0.1):Start()
end

function M:SetAbilitySumList(index)
	local list = {}

	for i, v in pairs(gUrbanAbilityManager:GetAbilityClassList()) do
		local info = {
			id = i
		}

		if index then
			info.selected = i == index
		else
			info.selected = i == 1
		end

		table.insert(list, info)
	end

	self.bindData.sumBasicList:SetList(list)
end

function M:AbilitySumTemplateBtnClick(index)
	local spiritAbilities = self.spiritViewData.SpiritInfo.SpiritAbilities
	local list = {}

	for i, v in pairs(spiritAbilities) do
		local cfg = LTConfig.UrbanAbilityConfig.GetConfig(v.TemplateId)

		if cfg.AbilityType == index then
			local info = {
				id = v.TemplateId,
				selected = false,
				cfg = cfg,
				data = v
			}

			table.insert(list, info)
		end
	end

	if #list > 0 then
		table.sort(list, function (a, b)
			return a.id < b.id
		end)

		local index = 1

		if self.selectUrbanAbilityId then
			for i, v in pairs(list) do
				if v.id == self.selectUrbanAbilityId then
					v.selected = true
					index = i
				else
					v.selected = false
				end
			end

			self.selectUrbanAbilityId = nil
		end

		self.firstId = list[index].id
		list[index].selected = true
	end

	self:SetDefaultBuffList(index)
	self.bindData.abilityTemplateList:SetList(list)
end

function M:SetIconList(cfg)
	self.iconListData = {}

	for i, v in pairs(cfg.IncreaseIconList) do
		local info = {
			IconId = v
		}

		if cfg.IncreaseDescription then
			info.Des = cfg.IncreaseDescription[i]
		end

		table.insert(self.iconListData, info)
	end

	self.bindData.iconList:SetSimpleList(#self.iconListData)

	self.itemToolTipData = gCommonItemManager:GetItemRenderData(cfg.ConsumableId)
	self.bindData.IconTipsBtn.interactable = cfg.ConsumableId ~= 0
end

function M:SetDefaultBuffList(index)
	local defaultData = self:SetDefaultBuffData(index)

	if defaultData then
		self:SetRightData(defaultData)
	end
end

function M:OnRenderAbilityTemplateItem(btn, _, data)
	store = gStoreManager:GetStoreGroup("UrbanAbilityBasicFeatureTemplate2Store"):GetStoreByWidget(btn)
	store.title = data.cfg.Name
	local max = gUrbanAbilityManager:GetAbilityInfoMaxExp(data.id)
	local cur = data.data.Exp
	data.maxExp = max
	data.curExp = cur
	store.rank = gUrbanAbilityManager:GetAbilityInterval(cur / max)
	store.button.luaClick = self:CreateActionWithArgs("SetRightData", data)
end

function M:SetRightData(data)
	if self.redPointAbilityId then
		self:AskClearRedPoint(self.redPointAbilityId)

		self.redPointAbilityId = nil
	end

	self.curData = data
	self.bindData.title = data.cfg.Name
	self.bindData.rightLevel = gUrbanAbilityManager:GetAbilityInterval(data.curExp / data.maxExp)

	if data.curExp == 0 then
		self.bindData.progress:ProgressToValue(0)
	else
		self.bindData.progress:ProgressToValue(data.curExp / data.maxExp)
	end

	self.bindData.progressNum.text = data.curExp .. "/" .. data.maxExp

	self:SetBuffList()
	self:SetIconList(data.cfg)
end

function M:SetBuffList()
	local list = {}
	local buffId = self.curData.cfg.InitBuffId
	local index = 0
	local cfg = LTConfig.UrbanAbilityBuffConfig.GetConfig(buffId)

	for i = 1, self.curData.cfg.MaxLevel do
		cfg = LTConfig.UrbanAbilityBuffConfig.GetConfig(buffId + index)

		if cfg then
			index = index + 1
			local info = {
				id = index,
				selected = false,
				cfg = cfg
			}

			table.insert(list, info)
		end
	end

	self.bindData.rightList:SetList(list)
	gCS.LuaUtils.PlayAnimationByName(self.bindData.ani, "S_Vx_UrbanAbilityBasicFeaturePanel_Right_open")
end

function M:OnRenderRightListItem(btn, _, data)
	local redDotKey = self:GetTypeRedDotKey(data.id)
	btn.redKey = redDotKey
	store = gStoreManager:GetStoreGroup("CommonOccupationDetailTemplate2Store"):GetStoreByWidget(btn)
	store.des = data.cfg.Name
	store.buff = data.cfg.BuffExplain
	local lockExp = self:GetExpByLevel(data.id)
	store.unlockDes = lockExp

	if data.id <= self.curData.data.Level then
		store.isLock = 0
	else
		store.isLock = 1
	end

	if self:GetIsNewLevel(self.curData.id, data.id) then
		SGUI.RedDotMgr.LuaSetRedDot(true, redDotKey)
	else
		SGUI.RedDotMgr.LuaSetRedDot(false, redDotKey)
	end
end

function M:GetTypeRedDotKey(Id)
	return ("BasicFeatureRedDot:%d"):format(Id)
end

function M:GetExpByLevel(level)
	local cfg = LTConfig.UrbanAbilityLevelUpExpConfig.GetConfig(self.curData.cfg.Id)

	if cfg then
		local sumExp = 0
		local index = 1

		while level > index do
			sumExp = sumExp + cfg["Exp" .. index]
			index = index + 1
		end

		return sumExp
	end

	return 0
end

function M:GetIsNewLevel(abilityId, level)
	if level == 1 then
		return false
	end

	local spirit = gSpiritManager:GetSpirit(self.urbanAbilityStore:GetCurSpiritTid())

	if not spirit then
		return false
	end

	local ability = spirit.SpiritInfo.SpiritAbilities[abilityId]

	if not ability.NewLevel then
		return false
	end

	self.redPointAbilityId = abilityId

	return ability.ConfirmedLevel < level and level <= ability.Level
end

function M:AskClearRedPoint(abilityId)
	gSpiritManager:AskClearAbilityRedPoint(self.urbanAbilityStore:GetCurSpiritTid(), abilityId)
end

function M:OnRenderIconItem(btn, index)
	local store = gStoreManager:GetStoreGroup("FeatureSourceIconStore"):GetStoreByWidget(btn)
	local data = self.iconListData[index + 1]
	store.icon = data.IconId
end

function M:OnChangeLeftAreaBtnClick()
	SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.urbanAbilityStore.bindData.navigationArea
end
