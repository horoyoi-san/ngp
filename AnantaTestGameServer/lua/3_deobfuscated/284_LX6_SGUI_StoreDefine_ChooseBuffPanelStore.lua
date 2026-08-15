local SeasonItemType = require("LX6.GUI.Season.SeasonItemType")
local bit = require("bit")
local MessageConfig = LTConfig.MessageConfig
local UIText = LTConfig.TextScriptTextConfig

local function GetText(id)
	local c = UIText.GetConfig(id)

	return c and c.Text or "nil"
end

local SeasonItemMask = {
	buff = bit.lshift(1, SeasonItemType.buff - 1),
	qiwu = bit.lshift(1, SeasonItemType.qiwu - 1)
}
local uiTextIds = {
	SELECT_SOMETHING = 89900927,
	VIEW_SOMETHING_HAD = 89900928,
	itemName = {
		[SeasonItemMask.buff] = 89900923,
		[SeasonItemMask.qiwu] = 89900924
	}
}
C_ChooseBuffPanelStore = DefClass("C_ChooseBuffPanelStore", C_ChooseBuffPanelStore, C_StoreGroup)
GroupName2Class.ChooseBuffPanelStore = C_ChooseBuffPanelStore
local M = C_ChooseBuffPanelStore

function M:ctor()
	return
end

function M:DefineAllVariables()
	self.cardList = {}
	self.selectedCardIndex = 0
	self.showItemTypeMask = 0
	self.isInCommunication = false
end

function M:OnAwake()
	self:DefineAllVariables()
	self:RegisterButtons()
	self:RegisterLists()
end

function M:OnShow(panelId, data)
	if data == nil then
		data = {
			itemIds = {
				92292001,
				36501904,
				92291003
			}
		}
	end

	self:RefreshData(data.itemIds)
end

function M:RegisterButtons()
	self.bindData.confirmBtn.luaClick = self:CreateAction("OnConfirmBtnClick")
end

function M:OnConfirmBtnClick()
	if not self.selectedCardIndex or self.selectedCardIndex == 0 then
		return
	end

	local selected = self.cardList[self.selectedCardIndex]
	local del = gClientToGameSceneDelegate

	if selected.id == nil or selected.id == 0 then
		print_error("选中的奖励Id为空")

		return
	end

	self.bindData.confirmBtn.interactable = false

	self:SetBuffListDisable(true)

	self.isInCommunication = true

	del:AskSelectChaosObject(selected.id).callback = function (err)
		self:SetBuffListDisable(false)

		self.bindData.confirmBtn.interactable = true

		if err == MessageConfig.Ok then
			gPanelManager:Close(self.m_Id)
		else
			gDisplayMessageMgr:ShowMessage(err)
		end

		self.isInCommunication = false
	end
end

function M:RegisterLists()
	self.bindData.buffList.luaRenderItem = self:CreateAction("OnRenderBuffList")
	self.bindData.buffList.luaClick = self:CreateAction("OnClickBuffList")
end

function M:OnRenderBuffList(btn, index, data)
	local id = btn.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup("SeasonCardTemplate"):GetStoreById(id)

	if store then
		local cfg = data.template
		store.buffName = cfg.name
		store.qualityCtrl = cfg.Quality
		store.buffIcon = cfg.iconId
		store.buffTag = cfg.tagName or ""
		local desCom = gStoreManager:GetStoreGroup("SeasonCardTemplate_BuffDes"):GetStoreByWidget(store.buffDes.content)
		desCom.buffDes = cfg.desc
	end
end

function M:OnClickBuffList(btn, data)
	self.selectedCardIndex = data.cardIndex
end

function M:SetBuffListDisable(disable)
	for _, data in ipairs(self.cardList) do
		data.disabled = disable
	end

	self.bindData.buffList:SetList(self.cardList)
end

function M:RefreshData(itemIds)
	table.clear(self.cardList)

	local itemTypeMask = 0

	for i, itemId in ipairs(itemIds) do
		local template, itemType = gSeasonRaidUtils:GenerateCardTemplateData(itemId)

		if itemType == SeasonItemType.buff then
			itemTypeMask = bit.bor(itemTypeMask, SeasonItemMask.buff)
		elseif itemType == SeasonItemType.qiwu then
			itemTypeMask = bit.bor(itemTypeMask, SeasonItemMask.qiwu)
		end

		local data = {
			id = itemId,
			template = template,
			selected = i == 1,
			cardIndex = i
		}

		table.insert(self.cardList, data)
	end

	self.selectedCardIndex = 1

	self.bindData.buffList:SetList(self.cardList)

	self.showItemTypeMask = itemTypeMask
	local isSingleType = bit.band(itemTypeMask, itemTypeMask - 1) == 0

	if isSingleType then
		local itemTypeString = GetText(uiTextIds.itemName[itemTypeMask])
		self.bindData.titleText = gString.Format(GetText(uiTextIds.SELECT_SOMETHING), itemTypeString)
	else
		local rewardString = GetText(89900929)
		self.bindData.titleText = gString.Format(GetText(uiTextIds.SELECT_SOMETHING), rewardString)
	end
end
