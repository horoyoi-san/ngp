-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\Club\OnlineClubLevelStore.lua
-- Decompiled from: 01239_OnlineClubLevelStore.lua_fe9dc5034811.luajit

C_OnlineClubLevelStore = DefClass("C_OnlineClubLevelStore", C_OnlineClubLevelStore, C_StoreGroup)
GroupName2Class.OnlineClubLevelStore = C_OnlineClubLevelStore
local M = C_OnlineClubLevelStore

M.OnAwake = function(self)
	self.Init(self)
	self.RegisterWidget(self)
end

M.Init = function(self)
	self.instance = {}
end

M.RegisterWidget = function(self)
	self.bindData.closeBtn.luaClick = self.CreateAction(self, self.ClosePanel)
	self.bindData.rewardList.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderRewardItem)
end

M.OnShow = function(self, panelId, data)
	self.Refresh(self)
end

M.OnDestroy = function(self)
	self.instance = nil
end

M.ClosePanel = function(self)
	gPanelManager:Close(self.m_Id)
end

M.Refresh = function(self)
	local clubInfo = gClubManager:GetClubInfo()
	local currentLevel = 0

	if clubInfo then
		currentLevel = gClubUIUtils:GetClubLevelDisplayData(clubInfo)
	end

	self.instance.currentLevel = currentLevel
	self.bindData.currentLevel = tostring(currentLevel)
	self.instance.levelConfigList = {}

	for i = 0, LTConfig.ClubClubLevelConfig.count - 1 do
		table.insert(self.instance.levelConfigList, LTConfig.ClubClubLevelConfig.LoadAt(i))
	end

	self.bindData.rewardList:SetSimpleList(#self.instance.levelConfigList)

	for index, cfg in ipairs(self.instance.levelConfigList) do
		if cfg.Level ~= currentLevel then
			self.bindData.rewardList:SelectItem(index - 1, false)

			break
		end
	end
end

M.OnRenderRewardItem = function(self, widget, csIndex)
	local cfg = self.instance.levelConfigList[csIndex + 1]

	if not cfg then
		return
	end

	local store = gClubUIUtils:GetStore(widget, "OnlineClubLevelStore")
	store.numText = tostring(cfg.Level)
	local benefitCfg = cfg.BenefitId and LTConfig.ClubBenefitConfig.GetConfig(cfg.BenefitId) or nil
	local benefitText = benefitCfg and benefitCfg.BenefitType or ""
	store.rewardText = gString.Format(benefitText, cfg.Param and cfg.Param[1])
	local commodityId = cfg.ItemUnlocked and cfg.ItemUnlocked[1] or nil

	store.rewardItem:SetActive(commodityId == nil)

	if commodityId == nil then
		local commodityCfg = LTConfig.ShopCommodityConfig.GetConfig(commodityId)
		local itemId = commodityCfg and commodityCfg.ConsumableID

		if itemId then
			local renderData = gCommonItemManager:GetItemRenderData({
				["\\xd0\\xcf01\\xfc"] = 1,
				itemId = itemId
			})

			gClubUIUtils:RenderCommonItem(store.rewardItem, renderData)
		end
	end
end
