-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ChooseBuffPanelStore.lua
-- Decompiled from: 01427_ChooseBuffPanelStore.lua_7f46dc988c1a.luajit

local SeasonItemType = require("LX6.GUI.Season.SeasonItemType")
local bit = require("bit")
local MessageConfig = LTConfig.MessageConfig
local UIText = LTConfig.TextScriptTextConfig

local GetText = function(id)
	local c = UIText.GetConfig(id)

	return c and c.Text or "nil"
end

local SeasonItemMask = {
	buff = bit.lshift(1, SeasonItemType.buff - 1),
	qiwu = bit.lshift(1, SeasonItemType.qiwu - 1)
}
local uiTextIds = {
	["T\"\\xb6\\xb5\\x9c\\xe8\\x8f\\xf6\\x849\\x9a+,"] = 89900927,
	["0\\xb5ڔ\\x94ǋ\\x9f\\xbc\\xf5\\xcb\\xe1\\xa5\\xbe\\xc6"] = 89900928,
	itemName = {
		[SeasonItemMask.buff] = 89900923,
		[SeasonItemMask.qiwu] = 89900924
	}
}
C_ChooseBuffPanelStore = DefClass("C_ChooseBuffPanelStore", C_ChooseBuffPanelStore, C_StoreGroup)
GroupName2Class.ChooseBuffPanelStore = C_ChooseBuffPanelStore
local M = C_ChooseBuffPanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.cardList = {}
	self.selectedCardIndex = 0
	self.showItemTypeMask = 0
	self.isInCommunication = false
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.RegisterButtons(self)
	self.RegisterLists(self)
end

M.OnShow = function(self, panelId, data)
	if data ~= nil then
		data = {
			itemIds = {
				92292001,
				36501904,
				92291003
			}
		}
	end

	self.RefreshData(self, data.itemIds)
end

M.RegisterButtons = function(self)
	self.bindData.confirmBtn.luaClick = self.CreateAction(self, "OnConfirmBtnClick")
end

M.OnConfirmBtnClick = function(self)
	if not self.selectedCardIndex or self.selectedCardIndex ~= 0 then
		return
	end

	local selected = self.cardList[self.selectedCardIndex]
	local del = gClientToGameSceneDelegate

	if selected.id ~= nil or selected.id ~= 0 then
		print_error("选中的奖励Id为空")

		return
	end

	self.bindData.confirmBtn.interactable = false

	self.SetBuffListDisable(self, true)

	self.isInCommunication = true

	del.AskSelectChaosObject(del, selected.id).callback = function (err)
		self:SetBuffListDisable(false)

		self.bindData.confirmBtn.interactable = true

		if err ~= MessageConfig.Ok then
			gPanelManager:Close(self.m_Id)
		else
			gDisplayMessageMgr:ShowMessage(err)
		end

		self.isInCommunication = false
	end
end

M.RegisterLists = function(self)
	self.bindData.buffList.luaRenderItem = self.CreateAction(self, "OnRenderBuffList")
	self.bindData.buffList.luaClick = self.CreateAction(self, "OnClickBuffList")
end

M.OnRenderBuffList = function(self, btn, index, data)
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

M.OnClickBuffList = function(self, btn, data)
	self.selectedCardIndex = data.cardIndex
end

M.SetBuffListDisable = function(self, disable)
	for _, data in ipairs(self.cardList) do
		data.disabled = disable
	end

	self.bindData.buffList:SetList(self.cardList)
end

M.RefreshData = function(self, itemIds)
	table.clear(self.cardList)

	local itemTypeMask = 0

	for i, itemId in ipairs(itemIds) do
		local template, itemType = gSeasonRaidUtils:GenerateCardTemplateData(itemId)

		if itemType ~= SeasonItemType.buff then
			itemTypeMask = bit.bor(itemTypeMask, SeasonItemMask.buff)
		elseif itemType ~= SeasonItemType.qiwu then
			itemTypeMask = bit.bor(itemTypeMask, SeasonItemMask.qiwu)
		end

		local data = {
			id = itemId,
			template = template,
			selected = i ~= 1,
			cardIndex = i
		}

		table.insert(self.cardList, data)
	end

	self.selectedCardIndex = 1

	self.bindData.buffList:SetList(self.cardList)

	self.showItemTypeMask = itemTypeMask
	local isSingleType = bit.band(itemTypeMask, itemTypeMask - 1) ~= 0

	if isSingleType then
		local itemTypeString = GetText(uiTextIds.itemName[itemTypeMask])
		self.bindData.titleText = gString.Format(GetText(uiTextIds.SELECT_SOMETHING), itemTypeString)
	else
		local rewardString = GetText(89900929)
		self.bindData.titleText = gString.Format(GetText(uiTextIds.SELECT_SOMETHING), rewardString)
	end
end
