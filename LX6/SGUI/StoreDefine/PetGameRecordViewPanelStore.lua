-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PetGameRecordViewPanelStore.lua
-- Decompiled from: 00822_PetGameRecordViewPanelStore.lua_90b307ffa284.luajit

C_PetGameRecordViewPanelStore = DefClass("C_PetGameRecordViewPanelStore", C_PetGameRecordViewPanelStore, C_StoreGroup)
GroupName2Class.PetGameRecordViewPanelStore = C_PetGameRecordViewPanelStore
local M = C_PetGameRecordViewPanelStore

M.OnAwake = function(self)
	if self.bindData and self.bindData.rewardList then
		self.bindData.rewardList.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderRewardItem)
	end
end

M.OnDestroy = function(self)
	self.UnBindSystemBtn(self)
end

M.OnStart = function(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
	self.UnBindSystemBtn(self)
end

M.OnShow = function(self, panelId, data)
	self.parentPanel = data.parent
	self.panelId = panelId
	self.petEntity = gPetGameManager.currentGame and gPetGameManager.currentGame.pet

	self:BindSystemBtn()
	self:RefreshRecordView()
end

M.OnClose = function(self)
	self.UnBindSystemBtn(self)
end

M.RefreshRecordView = function(self)
	if not self.petEntity then
		return
	end

	local saveData = gPetGameOutSideDataManager:GetData()
	self._rewardListData = {}

	if saveData and saveData.rewards then
		for _, reward in ipairs(saveData.rewards) do
			table.insert(self._rewardListData, reward)
		end
	end

	if self.bindData and self.bindData.rewardList then
		self.bindData.rewardList:SetSimpleList(#self._rewardListData)
	end
end

M.OnRenderRewardItem = function(self, widget, index)
	local data = self._rewardListData and self._rewardListData[index + 1]

	if not data or not widget then
		return
	end

	local storeGroup = gStoreManager:GetStoreGroup("PetGameRewardItemStore")

	if not storeGroup then
		return
	end

	local store = storeGroup.GetStoreByWidget(storeGroup, widget)
	local itemId = data.id
	local num = data.num

	if store.numText then
		store.numText.text = tostring(num or 0)
	end

	local ItemDatas = require("LX6/MiniGame/PetGame/data/tbitems")
	local ITEM_ICON_PATH_FORMAT = "Assets/Res/SGUI/Texture/PetGame/ItemIcons/%s.png"
	local itemInfo = ItemDatas[itemId]

	if not itemInfo or not store.icon then
		return
	end

	local spritePath = string.format(ITEM_ICON_PATH_FORMAT, itemInfo.icon)

	gCS.LuaUtils.LoadSpriteAssetWithCallBack(spritePath, function (loadOp)
		if loadOp.asset and store and store.icon then
			store.icon.sprite = loadOp.asset
		end
	end)
end

M.BindSystemBtn = function(self)
	self.isMenuBtnPressed = false
	local eventHandler = {
		panelId = self.panelId,
		OnMenuBtnClick = self.OnMenuBtnClick,
		OnConfirmBtnClick = self.OnConfirmBtnClick,
		OnCancleBtnClick = self.OnCancleBtnClick,
		target = self
	}

	self.parentPanel:RegisterSystemBtnEvent(eventHandler)
end

M.UnBindSystemBtn = function(self)
	self.parentPanel:UnregisterSystemBtnEvent(self.panelId)
end

M.OnMenuBtnClick = function(self)
end

M.OnConfirmBtnClick = function(self)
end

M.OnCancleBtnClick = function(self)
	self.parentPanel:CloseChildPanel(self.panelId)
end
