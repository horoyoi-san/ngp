-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\RoguelikeResultPanelStore.lua
-- Decompiled from: 00859_RoguelikeResultPanelStore.lua_95831818f4ae.luajit

C_RoguelikeResultPanelStore = DefClass("C_RoguelikeResultPanelStore", C_RoguelikeResultPanelStore, C_StoreGroup)
GroupName2Class.RoguelikeResultPanelStore = C_RoguelikeResultPanelStore
local M = C_RoguelikeResultPanelStore
local UrbanAttributeConfig = LTConfig.UrbanAttributeConfig
local AttributeNameConfig = LTConfig.AttributeNameConfig
local BuffConfig = LTConfig.BuffConfig
local SceneitemConfig = LTConfig.SceneitemConfig
local RogueRaidConfig = LTConfig.RogueRaidConfig
local TextCommonTextConfig = LTConfig.TextCommonTextConfig
local TextScriptTextConfig = LTConfig.TextScriptTextConfig

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.MAX_WEAPON_SLOT = 8
	self.LIST_TEMPLATE_INDEX = {
		["F\\xd9\\xd9\\xe0N\\xf9n\\xaf8k\\xe9\\xc8"] = 4,
		["y\\x87\\x96\\x83\\x93"] = 1,
		["prNVz7%>"] = 0,
		["5\\xc6~%\\xfe#\\x95h\\x93u\\x9c\\x93"] = 3,
		["D/\\xbb\\xa2\\x9e\\xff\\x84\\xe0\t\\x969\\x9368"] = 5,
		["0\\xc6l&\\xe4#\\x84d\\x96w\\x82\\x92"] = 2
	}
end

M.DefineAllEnumsAutoGen = function(self)
	self.statusCtrlEnum = {
		["@R\\xc1\\xaa\\xb6\r\\xab\\xc5\\xfc"] = 0,
		["@R\\xc1\\xaa\\xad\\x9f\\xc4\\xed"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.statusCtrlEnum = nil
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

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	self.isShow = true

	self.InitContent(self, data.rewardInfo, data.weaponIds, data.score, data.rogueId)
end

M.OnClose = function(self)
	self.isShow = false
	self.dropItemList = nil
	self.weaponIds = nil
	self.weaponData = nil
	self.resContentData = nil
	self.inGameContentData = nil
	self.playerAttrData = nil
	self.curWeaponInfo = nil
	self.buffData = nil
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.reviewBtn.luaClick = self.CreateAction(self, self.OnClickReviewBtn)
	self.bindData.showRewardBtn.luaClick = self.CreateAction(self, self.OnClickShowRewardBtn)
	self.bindData.exitBtn.luaClick = self.CreateAction(self, self.OnClickExitBtn)
	self.bindData.oneMoreBtn.luaClick = self.CreateAction(self, self.OnClickOneMoreBtn)
	self.bindData.resList.luaSimpleDynamicRenderItem = self.CreateAction(self, self.OnSimpleRenderResListItem)
	self.bindData.resList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderResListItem)
	self.bindData.resList.onGetTIndex = self.CreateAction(self, self.OnGetResListTIndex)
	self.bindData.inGameList.luaSimpleDynamicRenderItem = self.CreateAction(self, self.OnSimpleRenderInGameListItem)
	self.bindData.inGameList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderInGameListItem)
	self.bindData.inGameList.onGetTIndex = self.CreateAction(self, self.OnGetInGameListTIndex)
end

M.OnClickReviewBtn = function(self)
	self.bindData.statusCtrl = self.statusCtrlEnum.showInGame
end

M.OnClickShowRewardBtn = function(self)
	self.bindData.statusCtrl = self.statusCtrlEnum.showResult
end

M.OnClickExitBtn = function(self)
	gPanelManager:Close(self.m_Id)
	gRoguelikeManager:LeaveRogueLikeGame()
end

M.OnClickOneMoreBtn = function(self)
	gPanelManager:Close(self.m_Id)
	gRoguelikeManager:LeaveRogueLikeGame()
end

M.OnSimpleRenderResListItem = function(self, btn, index)
	local data = self.resContentData[index + 1]

	if not data then
		return
	end

	self.OnCommonRenderListItem(self, btn, data)
end

M.OnGetResListTIndex = function(self, index)
	local data = self.resContentData[index + 1]

	if not data then
		return self.LIST_TEMPLATE_INDEX.SUB_TITLE
	end

	return data.tIndex or self.LIST_TEMPLATE_INDEX.SUB_TITLE
end

M.OnSimpleRenderInGameListItem = function(self, btn, index)
	local data = self.inGameContentData[index + 1]

	if not data then
		return
	end

	self.OnCommonRenderListItem(self, btn, data)
end

M.OnGetInGameListTIndex = function(self, index)
	local data = self.inGameContentData[index + 1]

	if not data then
		return self.LIST_TEMPLATE_INDEX.SUB_TITLE
	end

	return data.tIndex or self.LIST_TEMPLATE_INDEX.SUB_TITLE
end

M.OnCommonRenderListItem = function(self, btn, data)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	if data.tIndex ~= self.LIST_TEMPLATE_INDEX.TITLE or data.tIndex ~= self.LIST_TEMPLATE_INDEX.SUB_TITLE then
		store.title = data.title
	else
		if data.tIndex ~= self.LIST_TEMPLATE_INDEX.RESULT_REWARD then
			local isReward = data.isReward
			local rewardData = data.isReward and self.dropItemList or self.weaponData

			store.list.luaSimpleRenderItem = function(rewardBtn, rewardIndex)
				local contentData = isReward and self.dropItemList or self.weaponData
				local itemData = contentData[rewardIndex + 1]

				if not itemData then
					return
				end

				gCommonItemManager:OnCommonItemRender(rewardBtn, rewardIndex, itemData)

				rewardBtn.luaRenderTooltip = self:CreateActionWithArgs("RenderCircleWeaponTooltip", itemData, gRoguelikeManager)
				rewardBtn.luaTooltipPopup = self:CreateAction("OnToolTipsClose", gCommonItemManager)
			end

			store.list:SetSimpleList(#rewardData)

			return
		end

		if data.tIndex ~= self.LIST_TEMPLATE_INDEX.CHARACTER_STATUS then
			store.list.luaSimpleRenderItem = function(attrBtn, attrIndex)
				local attrData = self.playerAttrData[attrIndex + 1]

				if not attrData then
					return
				end

				local attrStore = gStoreManager:GetStoreGroup(attrBtn.Store):GetStoreByWidget(attrBtn)

				if not attrStore then
					return
				end

				local cfg = AttributeNameConfig.GetConfig(attrData.id)
				attrStore.title = cfg and cfg.AttributeName or ""
				attrStore.value = gRoguelikeManager:FormatAttributeValue(attrData.value, cfg.ShowType)
			end

			store.list:SetSimpleList(#self.playerAttrData)
		elseif data.tIndex ~= self.LIST_TEMPLATE_INDEX.WEAPON_CIRCLE then
			self.RefreshWeaponWheel(self, store)
		elseif data.tIndex ~= self.LIST_TEMPLATE_INDEX.RESULT_COLLECTION then
			store.list.luaSimpleRenderItem = function(buffBtn, buffIndex)
				local buffId = self.buffData[buffIndex + 1]

				if not buffId then
					return
				end

				local buffStore = gStoreManager:GetStoreGroup(buffBtn.Store):GetStoreByWidget(buffBtn)

				if not buffStore then
					return
				end

				local buffCfg = BuffConfig.GetConfig(buffId)

				if buffCfg then
					buffStore.icon = buffCfg.IconIdSGUI
					buffStore.qualityCtrl = buffCfg.Quality
				end

				buffBtn.enabledTooltip = true
				buffBtn.luaRenderTooltip = self:CreateActionWithArgs("RenderBuffTooltip", buffId)
			end

			store.list:SetSimpleList(#self.buffData)
		end
	end
end

M.RenderBuffTooltip = function(self, buffId, button, popIns, index)
	local tip = gStoreManager:GetStoreGroup(popIns.Store):GetStoreByWidget(popIns)

	if not tip then
		return
	end

	gRoguelikeManager:RenderBuffTooltip(tip, buffId)
end

M.RefreshWeaponWheel = function(self, store)
	if gRoguelikeManager.weaponGuideIndex ~= nil then
		gRoguelikeManager.weaponGuideIndex = -1
	end

	local taskId = gTaskNodeManager:GetNowDoingTask()
	local lowPoint = SceneitemConfig.WeaponDurabilityLow * 100

	for i = 1, self.MAX_WEAPON_SLOT do
		local item = gRoguelikeManager:ProcessWeaponCircle(i, self.curWeaponInfo[i], lowPoint, taskId)

		gRoguelikeManager:RenderWeaponSlot(i, item, store)
	end
end

M.InitContent = function(self, reward, weaponIds, score, rogueId)
	self.bindData.score = score
	self.bindData.progress = ""
	self.rogueId = rogueId
	local rogueCfg = LTConfig.RogueRaidConfig.GetConfig(rogueId)
	self.bindData.name = rogueCfg.Name
	self.bindData.statusCtrl = self.statusCtrlEnum.showResult
	self.rewardInfo = reward
	local popupParam = gItemUtils:ConvertRewardDetail(self.rewardInfo)
	self.dropItemList = gCommonItemManager:GetSingleSortedListRenderDataByList(popupParam.Rewards)
	self.weaponIds = weaponIds
	self.weaponData = {}

	if self.weaponIds and #self.weaponIds <= 0 then
		for i = 1, #self.weaponIds do
			local itemId = self.weaponIds[i]

			if itemId and itemId == 0 then
				local view = {
					["\\x96'6j\\x8eU\\xf2>\\xa6\\xb5"] = false,
					itemId = itemId
				}

				table.insert(self.weaponData, gCommonItemManager:GetItemRenderData(view))
			end
		end
	end

	self.InitResultContent(self)
	self.InitInGameContent(self)
end

M.InitResultContent = function(self)
	self.resContentData = {}

	table.insert(self.resContentData, {
		tIndex = self.LIST_TEMPLATE_INDEX.SUB_TITLE,
		title = TextScriptTextConfig.GetConfig(89901561).Text
	})
	table.insert(self.resContentData, {
		["\\xa2\\xa27\\xae}?\\xec7"] = true,
		tIndex = self.LIST_TEMPLATE_INDEX.RESULT_REWARD
	})
	table.insert(self.resContentData, {
		tIndex = self.LIST_TEMPLATE_INDEX.SUB_TITLE,
		title = TextScriptTextConfig.GetConfig(89901562).Text
	})
	table.insert(self.resContentData, {
		tIndex = self.LIST_TEMPLATE_INDEX.TITLE,
		title = TextCommonTextConfig.GetConfig(74003507).Text
	})
	table.insert(self.resContentData, {
		["\\xa2\\xa27\\xae}?\\xec7"] = false,
		tIndex = self.LIST_TEMPLATE_INDEX.RESULT_REWARD
	})
	self.bindData.resList:SetSimpleList(#self.resContentData)
end

M.InitInGameContent = function(self)
	self.inGameContentData = {}

	table.insert(self.inGameContentData, {
		tIndex = self.LIST_TEMPLATE_INDEX.SUB_TITLE,
		title = TextScriptTextConfig.GetConfig(89901563).Text
	})
	table.insert(self.inGameContentData, {
		tIndex = self.LIST_TEMPLATE_INDEX.WEAPON_CIRCLE
	})
	table.insert(self.inGameContentData, {
		tIndex = self.LIST_TEMPLATE_INDEX.SUB_TITLE,
		title = TextScriptTextConfig.GetConfig(89901564).Text
	})
	table.insert(self.inGameContentData, {
		tIndex = self.LIST_TEMPLATE_INDEX.RESULT_COLLECTION
	})
	table.insert(self.inGameContentData, {
		tIndex = self.LIST_TEMPLATE_INDEX.SUB_TITLE,
		title = TextScriptTextConfig.GetConfig(89901565).Text
	})
	table.insert(self.inGameContentData, {
		tIndex = self.LIST_TEMPLATE_INDEX.CHARACTER_STATUS
	})

	local weapons = gWeaponManager:GetCurrentWeapons()
	local count = weapons and weapons.Length or 0
	self.curWeaponInfo = {}

	for i = 1, self.MAX_WEAPON_SLOT do
		if i < count and weapons[i] then
			self.curWeaponInfo[i] = weapons[i]
		end
	end

	local spiritId = gBattleSpiritMgr.currentSpiritTemplateId or 0
	local panelData = gUrbanAbilityManager:GetUrbanPanelData(spiritId)
	local list = {}

	if panelData then
		local showAttr = RogueRaidConfig.ShowAttrList

		for i = 1, #showAttr do
			local attrId = showAttr[i]
			local value = panelData.Attrs[attrId]

			if value then
				table.insert(list, {
					id = attrId,
					value = value
				})
			end
		end
	end

	self.playerAttrData = list
	self.buffData = {}

	gClientToGameSceneDelegate:AskSelectedTempBuffs().Callback = function (err, buffs)
		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		if self.isShow then
			if buffs and buffs.Count <= 0 then
				local buffCount = buffs.Count

				for i = 1, buffCount do
					table.insert(self.buffData, buffs[i])
				end
			end

			self.bindData.inGameList:SetSimpleList(#self.inGameContentData)
		end
	end

	self.bindData.inGameList:SetSimpleList(#self.inGameContentData)
end
