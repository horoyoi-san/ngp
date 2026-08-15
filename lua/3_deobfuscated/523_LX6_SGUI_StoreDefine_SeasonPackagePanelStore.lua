local TextScriptTextConfig = LTConfig.TextScriptTextConfig
local ImageConfig = LTConfig.SguiImageConfig
local ChaosBuff = LTConfig.SeasonRaidChaosBuffConfig
local ChaosItem = LTConfig.SeasonRaidChaosItemConfig
local SeasonRaidConfig = LTConfig.SeasonRaidConfig
local TabType = require("LX6.GUI.Season.SeasonItemType")
local tabInfos = {
	{
		name = TextScriptTextConfig.GetConfig(89900923).Text,
		iconId = ImageConfig.PackageGrowthIcon,
		id = TabType.buff
	},
	{
		name = TextScriptTextConfig.GetConfig(89900924).Text,
		iconId = ImageConfig.PackageConsumableIcon,
		id = TabType.qiwu
	}
}
C_SeasonPackagePanelStore = DefClass("C_SeasonPackagePanelStore", C_SeasonPackagePanelStore, C_StoreGroup)
GroupName2Class.SeasonPackagePanelStore = C_SeasonPackagePanelStore
local M = C_SeasonPackagePanelStore

function M:ctor()
	return
end

function M:DefineAllVariables()
	self.tabList = nil
	self.selectedSpiritIndex = 1
	self.currentSelectTab = 0
	self.buffList = {}
	self.spiritList = {}
	self.qiwuList = {}
	self.toolTipStore = nil
end

function M:OnAwake()
	self:DefineAllVariables()
	self:RegisterButtons()
	self:RegisterLists()
end

function M:OnShow(panelId, data)
	self.SubGroup.MoneyTemplateStore:SetData(SeasonRaidConfig.SeasonRaidMoney)

	self.toolTipStore = gStoreManager:GetStoreGroup("SeasonBagTooltip"):GetStoreByWidget(self.bindData.toolTipWidget.content)

	self:RefreshTab(data)
end

function M:RegisterButtons()
	self.bindData.closeBtn.luaClick = self:CreateAction("OnCloseBtnClick")
	self.bindData.leftTabBtn.luaClick = self:CreateActionWithArgs("OnTabBtnClick", -1)
	self.bindData.rightTabBtn.luaClick = self:CreateActionWithArgs("OnTabBtnClick", 1)
end

function M:OnCloseBtnClick()
	gPanelManager:Close(self.m_Id)
end

function M:OnTabBtnClick(direction)
	self.currentSelectTab = Mathf.Clamp(self.currentSelectTab + direction, 1, #tabInfos)

	self:RefreshPage()
end

function M:RegisterLists()
	self.bindData.typeList.luaRenderItem = self:CreateAction("OnRenderTypeList")
	self.bindData.buffList.luaRenderItem = self:CreateAction("OnRenderBuffList")
	self.bindData.qiwuList.luaRenderItem = self:CreateAction("OnRenderQiwuList")
	self.bindData.typeList.luaClick = self:CreateAction("OnClickTypeList")
	self.bindData.buffList.luaClick = self:CreateAction("OnClickBuffList")
	self.bindData.qiwuList.luaClick = self:CreateAction("OnClickQiwuList")
end

function M:OnRenderTypeList(btn, index, data)
	local id = btn.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup("CommonShortTab"):GetStoreById(id)

	if store then
		store.iconId = data.iconId
	end
end

function M:OnClickTypeList(btn, data)
	self.currentSelectTab = data.id

	self:RefreshPage()
end

function M:OnRenderBuffList(btn, index, data)
	local id = btn.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup("SeasonBagBuffTemplate"):GetStoreById(id)

	if store then
		store.qualityCtrl = data.Quality
		store.buffIconId = data.iconId
		store.buffTagText = data.Tag
		store.buffNameText = data.name
	end
end

function M:OnClickBuffList(btn, data)
	if not self.toolTipStore then
		return
	end

	self.bindData.showToolTipCtrl = 1
	self.toolTipStore.tipTypeCtrl = TabType.buff - 1
	self.toolTipStore.tipQualityCtrl = data.Quality
	self.toolTipStore.buffTagText = data.Tag
	self.toolTipStore.tipIconId = data.iconId
	self.toolTipStore.tipNameText = data.name
	self.toolTipStore.tipDesBenefitText = data.benefitText or ""
	self.toolTipStore.tipDesText = data.desc
end

function M:OnRenderQiwuList(btn, index, data)
	local id = btn.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup("SeasonQiwuTemplate"):GetStoreById(id)

	if store then
		store.qualityCtrl = data.Quality
		store.itemIconId = data.iconId
	end
end

function M:OnClickQiwuList(btn, data)
	if not self.toolTipStore then
		return
	end

	self.bindData.showToolTipCtrl = 1
	self.toolTipStore.tipTypeCtrl = TabType.qiwu - 1
	self.toolTipStore.tipQualityCtrl = data.Quality
	self.toolTipStore.buffTagText = ""
	self.toolTipStore.tipIconId = data.iconId
	self.toolTipStore.tipNameText = data.name
	self.toolTipStore.tipDesBenefitText = data.benefitText or ""
	self.toolTipStore.tipDesText = data.desc
end

function M:RefreshTab(data)
	local selectedTab = data or 1
	self.tabList = tabInfos

	if not self.tabList[selectedTab] then
		selectedTab = 1
	end

	for _, tab in ipairs(self.tabList) do
		tab.selected = false
	end

	self.tabList[selectedTab].selected = true
	self.currentSelectTab = self.tabList[selectedTab].id
	self.bindData.titleText = self.tabList[selectedTab].name

	self.bindData.typeList:SetList(self.tabList)
	self:BuildBuffData()
	self:BuildQiwuData()
	self:RefreshPage()
end

function M:BuildBuffData()
	table.clear(self.spiritList)

	for i, id in ipairs(gSeasonDataMgr:GetFightSpiritIds()) do
		local cell = {
			id = id,
			icon = 0,
			select = false
		}

		table.insert(self.spiritList, cell)
	end

	table.clear(self.buffList)

	local selectedSpiritId = self.spiritList[self.selectedSpiritIndex].id.templateId

	for i, buffId in ipairs(gSeasonDataMgr.buffIds) do
		local buff = ChaosBuff.GetConfig(buffId)

		if buff.FightSpiritId == selectedSpiritId then
			local cell = {
				Id = buff.Id,
				Quality = buff.Quality,
				iconId = buff.ImageId,
				name = buff.Name,
				IsNew = true,
				Tag = buff.Tag,
				isSelected = false,
				desc = buff.Description
			}

			table.insert(self.buffList, cell)
		end
	end

	self.bindData.buffList:SetList(self.buffList)
end

function M:BuildQiwuData()
	table.clear(self.qiwuList)

	for i, itemId in ipairs(gSeasonDataMgr.itemIds) do
		local config = ChaosItem.GetConfig(itemId)
		local cell = {
			Id = config.Id,
			Quality = config.Quality,
			iconId = config.ImageId,
			IsNew = true,
			name = config.Name,
			desc = config.Description
		}

		table.insert(self.qiwuList, cell)
	end

	self.bindData.qiwuList:SetList(self.qiwuList)
end

function M:RefreshPage()
	if self.bindData.contentCtrl == self.currentSelectTab then
		return
	end

	self.bindData.contentCtrl = self.currentSelectTab
	self.bindData.showToolTipCtrl = 0
end
