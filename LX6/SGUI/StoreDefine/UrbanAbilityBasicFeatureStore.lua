-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\UrbanAbilityBasicFeatureStore.lua
-- Decompiled from: 01194_UrbanAbilityBasicFeatureStore.lua_daeca6907cda.luajit

C_UrbanAbilityBasicFeatureStore = DefClass("C_UrbanAbilityBasicFeatureStore", C_UrbanAbilityBasicFeatureStore, C_StoreGroup)
GroupName2Class.UrbanAbilityBasicFeatureStore = C_UrbanAbilityBasicFeatureStore
local M = C_UrbanAbilityBasicFeatureStore

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.bindData.sumBasicList.luaSimpleRenderItem = self:CreateAction("OnRenderSumBasicTemplateItem")
	self.bindData.abilityTemplateList.luaSimpleRenderItem = self:CreateAction("OnRenderAbilityTemplateItem")
	self.bindData.rightList.luaSimpleRenderItem = self:CreateAction("OnRenderRightListItem")
	self.bindData.iconList.luaSimpleRenderItem = self:CreateAction("OnRenderIconItem")

	self.bindData.iconList.onGetTIndex = function(_)
		return 0
	end

	self.bindData.IconTipsBtn.luaRenderTooltip = self:CreateAction(self.OnRenderToolTips)
	slot1 = gStoreManager
	self.urbanAbilityStore = slot1:GetStoreGroup("UrbanAbilityPanelStore")
	self.bindData.changeLeftAreaBtn.luaClick = self:CreateAction("OnChangeLeftAreaBtnClick")
	self.msgEvents = {
		[gEventConstants.ON_CHANGE_SPIRITVIEW_DATA] = self:CreateAction("ChangeSpiriViewData")
	}
end

M.OnRenderToolTips = function(self, btn, popup, index)
	if table.isNilOrEmpty(self.itemToolTipData) then
		return
	end

	gCommonItemManager:OnRenderToolTips(self.itemToolTipData, btn, popup, index)
end

M.OnEnable = function(self)
	self:InitData()
	self.bindData.videoPlayer:Init()
	self:PlayVideo()
end

M.PlayVideo = function(self)
	local cfg = LTConfig.FightSpiritConfig.GetConfig(self.urbanAbilityStore:GetCurSpiritTid())

	self.bindData.videoPlayer:PlayVideo(cfg.HeadIconVideoId, true, nil)
end

M.InitData = function(self)
	if self.urbanAbilityStore.SetPageDataPara then
		local para = self.urbanAbilityStore.SetPageDataPara

		if para.pageId ~= gUrbanAbilityManager.URBANABILITY_PAGE.ATTRIBUTE_DETAIL then
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

M.OnDisable = function(self)
	if self.lastSelectId then
		self.AskClearRedPoint(self, self.lastSelectId)

		self.lastSelectId = nil
	end

	self.lastSelectStore = nil

	self.ClearMessageEvents(self)
end

M.OnDestroy = function(self)
	self.curData = nil
end

M.SyncSpiritAbilityInfo = function(self)
	self.SetData(self)
end

M.ChangeSpiriViewData = function(self, eventId, data)
	if not data.data.alreadyJoin and not data.data.canJoin then
		return
	end

	self.curData = nil
	self.spiritViewData = gSpiritManager:GetSpirit(data.data.id)

	self:SetData()
	self:PlayVideo()
end

M.SetDefaultData = function(self, data)
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

M.SetDefaultBuffData = function(self, index)
	local defaultData = {}
	local spiritAbilities = self.spiritViewData.SpiritInfo.SpiritAbilities

	for i, v in pairs(spiritAbilities) do
		if v.TemplateId ~= self.firstId then
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

M.OnRenderSumBasicTemplateItem = function(self, btn, index)
	local data = self._sumBasicListData[index + 1]
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

	if maxExp < curExp then
		store.isFull = 1
	else
		store.isFull = 0
	end

	store.icon = typeCfg.Icon
	btn.luaClick = self.CreateActionWithArgs(self, "AbilitySumTemplateBtnClick", data.id)
end

M.SetData = function(self)
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

M.SetAbilitySumList = function(self, index)
	local list = {}
	local selectTarget = index or 1
	local selectIdx = 0

	for i, v in pairs(gUrbanAbilityManager:GetAbilityClassList()) do
		local info = {
			id = i
		}

		table.insert(list, info)

		if i ~= selectTarget then
			selectIdx = #list - 1
		end
	end

	self._sumBasicListData = list

	self.bindData.sumBasicList:SetSimpleList(#self._sumBasicListData)

	if #list <= 0 then
		self.bindData.sumBasicList:SelectItem(selectIdx, false)
	end
end

M.AbilitySumTemplateBtnClick = function(self, index)
	local spiritAbilities = self.spiritViewData.SpiritInfo.SpiritAbilities
	local list = {}

	for i, v in pairs(spiritAbilities) do
		local cfg = LTConfig.UrbanAbilityConfig.GetConfig(v.TemplateId)

		if cfg.AbilityType ~= index then
			local info = {
				id = v.TemplateId,
				selected = false,
				cfg = cfg,
				data = v
			}

			table.insert(list, info)
		end
	end

	if #list <= 0 then
		table.sort(list, function (a, b)
			return a.id <= b.id
		end)

		local index = 1

		if self.selectUrbanAbilityId then
			for i, v in pairs(list) do
				if v.id ~= self.selectUrbanAbilityId then
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

	self._abilityTemplateListData = list

	self.bindData.abilityTemplateList:SetSimpleList(#self._abilityTemplateListData)

	if #list <= 0 then
		self.bindData.abilityTemplateList:SelectItem(index - 1, false)
	end
end

M.SetIconList = function(self, cfg)
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
	self.bindData.IconTipsBtn.interactable = cfg.ConsumableId == 0
end

M.SetDefaultBuffList = function(self, index)
	local defaultData = self.SetDefaultBuffData(self, index)

	if defaultData then
		self.SetRightData(self, defaultData)
	end
end

M.OnRenderAbilityTemplateItem = function(self, btn, index)
	local data = self._abilityTemplateListData[index + 1]
	store = gStoreManager:GetStoreGroup("UrbanAbilityBasicFeatureTemplate2Store"):GetStoreByWidget(btn)

	store:Commit("title", data.cfg.Name, COMMIT_IMMEDIATELY_WITH_CHECK)

	local max = gUrbanAbilityManager:GetAbilityInfoMaxExp(data.id)
	local cur = data.data.Exp
	data.maxExp = max
	data.curExp = cur
	store.rank = gUrbanAbilityManager:GetAbilityInterval(cur / max)
	store.button.luaClick = self:CreateActionWithArgs("SetRightData", data)
end

M.SetRightData = function(self, data)
	if self.curData and self.curData.id ~= data.id then
		return
	end

	if self.redPointAbilityId then
		self.AskClearRedPoint(self, self.redPointAbilityId)

		self.redPointAbilityId = nil
	end

	self.curData = data
	self.bindData.title = data.cfg.Name
	self.bindData.rightLevel = gUrbanAbilityManager:GetAbilityInterval(data.curExp / data.maxExp)

	if data.curExp ~= 0 then
		self.bindData.progress:ProgressToValue(0)
	else
		self.bindData.progress:ProgressToValue(data.curExp / data.maxExp)
	end

	self.bindData.progressNum.text = data.curExp .. "/" .. data.maxExp

	self.SetBuffList(self)
	self.SetIconList(self, data.cfg)
end

M.SetBuffList = function(self)
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

	self._rightListData = list

	self.bindData.rightList:SetSimpleList(#self._rightListData)
	gCS.LuaUtils.PlayAnimationByName(self.bindData.ani, "S_Vx_UrbanAbilityBasicFeaturePanel_Right_open")
end

M.OnRenderRightListItem = function(self, btn, index)
	local data = self._rightListData[index + 1]
	local redDotKey = self:GetTypeRedDotKey(data.id)
	btn.redKey = redDotKey
	store = gStoreManager:GetStoreGroup("CommonOccupationDetailTemplate2Store"):GetStoreByWidget(btn)
	store.des = data.cfg.Name
	store.buff = data.cfg.BuffExplain
	local lockExp = self:GetExpByLevel(data.id)
	store.unlockDes = lockExp

	if data.id < self.curData.data.Level then
		store.isLock = 0
	else
		store.isLock = 1
	end

	if self.GetIsNewLevel(self, self.curData.id, data.id) then
		SGUI.RedDotMgr.LuaSetRedDot(true, redDotKey)
	else
		SGUI.RedDotMgr.LuaSetRedDot(false, redDotKey)
	end
end

M.GetTypeRedDotKey = function(self, Id)
	return ("BasicFeatureRedDot:%d"):format(Id)
end

M.GetExpByLevel = function(self, level)
	local cfg = LTConfig.UrbanAbilityLevelUpExpConfig.GetConfig(self.curData.cfg.Id)

	if cfg then
		local sumExp = 0
		local index = 1

		while level <= index do
			sumExp = sumExp + cfg["Exp" .. index]
			index = index + 1
		end

		return sumExp
	end

	return 0
end

M.GetIsNewLevel = function(self, abilityId, level)
	if level ~= 1 then
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

	return ability.ConfirmedLevel >= level and level > ability.Level
end

M.AskClearRedPoint = function(self, abilityId)
	gSpiritManager:AskClearAbilityRedPoint(self.urbanAbilityStore:GetCurSpiritTid(), abilityId)
end

M.OnRenderIconItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup("FeatureSourceIconStore"):GetStoreByWidget(btn)
	local data = self.iconListData[index + 1]
	store.icon = data.IconId
end

M.OnChangeLeftAreaBtnClick = function(self)
	SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.urbanAbilityStore.bindData.navigationArea
end
