-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PlayerGalleryPanelStore.lua
-- Decompiled from: 00837_PlayerGalleryPanelStore.lua_15217a82e3a0.luajit

local WorthLevelConfig = LTConfig.AssetGalleryWorthLevelConfig
local HomePageConfig = LTConfig.AssetGalleryHomePageConfig
local AssetGalleryType = LTConfig.AssetGalleryAssetGalleryTypeConfig
C_PlayerGalleryPanelStore = DefClass("C_PlayerGalleryPanelStore", C_PlayerGalleryPanelStore, C_StoreGroup)
GroupName2Class.PlayerGalleryPanelStore = C_PlayerGalleryPanelStore
local M = C_PlayerGalleryPanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.fashionTemplateStore = nil
	self.playerFashionHeadStore = nil
	self.rewardListData = {}
	self.rewardBtnList = {}
	self.lastReachedRewardIndex = -1
	self.currentTypeCtrl = 0
	self.typePointListData = {}
	local TypeType = HomePageConfig.TypeType
	self.typeToAssetGalleryType = {
		[TypeType.Fashion] = AssetGalleryType.Fashion,
		[TypeType.Vehicle] = AssetGalleryType.Vehicle,
		[TypeType.Weapon] = AssetGalleryType.Weapon,
		[TypeType.Furniture] = AssetGalleryType.Furniture
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
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	self.InitFashionTemplate(self)
	self.RefreshFashionTemplateData(self)
end

M.InitFashionTemplate = function(self)
	self.fashionTemplateStore = gStoreManager:GetStoreGroup(self.bindData.fashionTemplate.Store):GetStoreByWidget(self.bindData.fashionTemplate)
	local tpl = self.fashionTemplateStore

	if not tpl then
		return
	end

	tpl.rewardList.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderRewardItem)
	tpl.rewardList.poolMode = SGUI.EPoolMode.Default
	tpl.typePointList.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderTypePointItem)
	tpl.category1Btn.luaClick = self.CreateAction(self, self.OnClickCategory1)
	tpl.category2Btn.luaClick = self.CreateAction(self, self.OnClickCategory2)

	if gClientUtils.NotNil(tpl.gamepadCategoryBtn) then
		tpl.gamepadCategoryBtn.luaClick = self.CreateAction(self, self.OnClickGamepadCategory)
	end

	tpl.gamepadCategoryBtn1.luaClick = self:CreateAction(self.OnClickGamepadCategory)
	tpl.gamepadCategoryBtn2.luaClick = self:CreateAction(self.OnClickGamepadCategory)
	local playerFashionHead = tpl.playerFashionHead
	self.playerFashionHeadStore = gStoreManager:GetStoreGroup(playerFashionHead.Store):GetStoreByWidget(playerFashionHead)

	self:RefreshPlayerAvatar()

	self.currentTypeCtrl = 0
	tpl.category1Btn.isSelected = true
	tpl.category2Btn.isSelected = false
end

M.RefreshPlayerAvatar = function(self)
	local headStore = self.playerFashionHeadStore

	if not headStore or not gClientUtils.NotNil(headStore.avatar) then
		return
	end

	local avatarStore = gStoreManager:GetStoreGroup(headStore.avatar.Store):GetStoreByWidget(headStore.avatar)

	if not avatarStore or not avatarStore.userInfoLight then
		return
	end

	avatarStore.userInfoLight.pid = gPlayerManager.infoLogin.bindData.pid
	avatarStore.isSelfCtrl = 1
	avatarStore.isEmptyCtrl = 0
end

M.RefreshFashionTemplateData = function(self)
	local tpl = self.fashionTemplateStore

	if not tpl then
		return
	end

	local currentCredit = gGalleryManager.GetTotalCredit()
	local currentLevel = gGalleryManager.GetCreditLevel(currentCredit)
	local nextLevelPoint = gGalleryManager.GetNextLevelPoint(currentCredit)
	tpl.minePoint = tostring(currentCredit)
	tpl.totalPoint = tostring(nextLevelPoint)
	tpl.playerName = gPlayerManager.infoLogin.bindData.playerName or ""
	tpl.levelText = "V" .. currentLevel

	if self.playerFashionHeadStore then
		self.playerFashionHeadStore.fillPercent = nextLevelPoint <= 0 and currentCredit / nextLevelPoint or 1
	end

	self.RefreshTypeCtrl(self)
end

M.RefreshTypeCtrl = function(self)
	local tpl = self.fashionTemplateStore

	if not tpl then
		return
	end

	tpl.typeCtrl = self.currentTypeCtrl

	if self.currentTypeCtrl ~= 0 then
		self.RefreshRewardList(self)
	else
		self.RefreshTypePointList(self)
	end
end

M.RefreshTypePointList = function(self)
	local tpl = self.fashionTemplateStore

	if not tpl or not tpl.typePointList then
		return
	end

	self.typePointListData = {}
	local configList = {}

	for i = 0, HomePageConfig.count - 1 do
		table.insert(configList, HomePageConfig.LoadAt(i))
	end

	table.sort(configList, function (a, b)
		return b.Weight <= a.Weight
	end)

	for _, cfg in ipairs(configList) do
		local itemType = self.typeToAssetGalleryType[cfg.Type]

		if itemType then
			table.insert(self.typePointListData, {
				name = cfg.Name,
				credit = gGalleryManager.GetCreditByType(itemType)
			})
		end
	end

	tpl.typePointList:SetSimpleList(#self.typePointListData)
end

M.RefreshRewardList = function(self)
	local tpl = self.fashionTemplateStore

	if not tpl then
		return
	end

	self.rewardListData = {}
	local currentCredit = gGalleryManager.GetTotalCredit()
	local count = WorthLevelConfig.count

	for i = 0, count - 1 do
		local levelCfg = WorthLevelConfig.LoadAt(i)

		if levelCfg then
			local rewardItems = gCommonItemManager:ConvertDropToFakeItem(levelCfg.DropId, 1)

			table.insert(self.rewardListData, {
				level = levelCfg.Id,
				credit = levelCfg.value,
				dropId = levelCfg.DropId,
				rewards = rewardItems,
				reached = levelCfg.value > currentCredit
			})
		end
	end

	self.lastReachedRewardIndex = -1

	for i = #self.rewardListData, 1, -1 do
		if self.rewardListData[i].reached then
			self.lastReachedRewardIndex = i

			break
		end
	end

	tpl.rewardList:SetSimpleList(#self.rewardListData)
	tpl.rewardList:SelectItem(0, true)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.ON_BAIKE_CREDIT_INFO_CHANGE] = self.CreateAction(self, self.OnCreditInfoChange)
	}
end

M.OnCreditInfoChange = function(self)
	if not self.fashionTemplateStore then
		return
	end

	self.RefreshFashionTemplateData(self)
end

M.RegisterWidget = function(self)
	self.bindData.baseButton.luaClick = self.CreateAction(self, self.OnClickBaseButton)
end

M.OnClickBaseButton = function(self)
	gUIUtils:PlayAniClosePanel(self.bindData.anim, "S_Vx_PlayFashionPanel_close", gPanelId.PLAYER_GALLERY_PANEL)
end

M.OnClickCategory1 = function(self)
	self.currentTypeCtrl = 0
	self.fashionTemplateStore.category1Btn.isSelected = true
	self.fashionTemplateStore.category2Btn.isSelected = false

	self.RefreshTypeCtrl(self)
end

M.OnClickCategory2 = function(self)
	self.currentTypeCtrl = 1
	self.fashionTemplateStore.category1Btn.isSelected = false
	self.fashionTemplateStore.category2Btn.isSelected = true

	self.RefreshTypeCtrl(self)
end

M.OnClickGamepadCategory = function(self)
	self.currentTypeCtrl = self.currentTypeCtrl ~= 0 and 1 or 0
	self.fashionTemplateStore.category1Btn.isSelected = self.currentTypeCtrl ~= 0
	self.fashionTemplateStore.category2Btn.isSelected = self.currentTypeCtrl ~= 1

	self:RefreshTypeCtrl()
end

M.OnRenderTypePointItem = function(self, btn, index)
	local data = self.typePointListData[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.nameText = data.name or ""
	store.numText = tostring(data.credit)
end

M.OnRenderRewardItem = function(self, btn, index)
	local data = self.rewardListData[index + 1]

	if not data then
		return
	end

	self.rewardBtnList[index + 1] = btn
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local levelCfg = WorthLevelConfig.GetConfig(data.level)
	store.levelText = levelCfg.levelName or ""
	store.pointText = levelCfg.value
	store.iconId = levelCfg.icon
	local pos = btn.transform.localPosition
	btn.transform.localPosition = UnityEngine.Vector3(pos.x, pos.y, 0)
	store.rewardCtrl = data.reached and 0 or 2

	if not data.reached then
		store.progressCtrl = 0
	elseif index + 1 ~= self.lastReachedRewardIndex then
		store.progressCtrl = 1
	else
		store.progressCtrl = 2
	end

	if store.rewardBtn then
		store.rewardBtn:SetActive(false)
	end

	store.rewardBtns = {}

	if data.rewards and #data.rewards <= 0 then
		store.rewardList.luaSimpleRenderItem = function(itemBtn, itemIndex)
			store.rewardBtns[itemIndex + 1] = itemBtn
			local itemData = data.rewards[itemIndex + 1]

			if itemData then
				local renderData = gCommonItemManager:GetItemRenderData({
					itemId = itemData.Id,
					itemNum = itemData.Count
				})

				gCommonItemManager:OnCommonItemRender(itemBtn, itemIndex, renderData)
			end
		end

		store.rewardList:SetSimpleList(#data.rewards)
	else
		store.rewardList:SetSimpleList(0)
	end
end
