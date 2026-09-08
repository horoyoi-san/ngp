-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PetGameChooseRegionPanelStore.lua
-- Decompiled from: 01090_PetGameChooseRegionPanelStore.lua_7665edeb02f3.luajit

local Color = UnityEngine.Color
local regionConf = require("LX6/MiniGame/PetGame/data/tbregion")
local normalTextColor = Color.New(0.03137254901960784, 0.3254901960784314, 0.5450980392156862, 1)
local selectedTextColors = {
	Color.New(0.7764705882352941, 0.27450980392156865, 0.13725490196078433, 1),
	Color.New(0.21176470588235294, 0.33725490196078434, 0.08627450980392157, 1),
	Color.New(0.03137254901960784, 0.3254901960784314, 0.5450980392156862, 1)
}
C_PetGameChooseRegionPanelStore = DefClass("C_PetGameChooseRegionPanelStore", C_PetGameChooseRegionPanelStore, C_StoreGroup)
GroupName2Class.PetGameChooseRegionPanelStore = C_PetGameChooseRegionPanelStore
local M = C_PetGameChooseRegionPanelStore

M.OnAwake = function(self)
end

M.OnDestroy = function(self)
	self.UnBindSystemBtn(self)
end

M.OnStart = function(self)
	if not self.itemObjects then
		self.InitRegionItems(self)
	end
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
	self.UnBindSystemBtn(self)
end

M.OnShow = function(self, panelId, data)
	self.panelId = panelId
	self.parentPanel = data and data.parent or nil
	self.petEntity = gPetGameManager.currentGame and gPetGameManager.currentGame.pet

	if not self.itemObjects then
		self.InitRegionItems(self)
	end

	self.UpdateBtnSelectedState(self, 1)
	self.BindSystemBtn(self)
end

M.OnClose = function(self)
	self.UnBindSystemBtn(self)
end

M.InitRegionItems = function(self)
	self.itemObjects = {}
	local regionList = table.to_array(regionConf)

	table.sort(regionList, function (a, b)
		return a.id <= b.id
	end)

	for index = 1, math.min(3, #regionList) do
		local conf = regionList[index]
		local itemTrans = self.bindData.ItemParent:Find("item" .. index)
		local itemObj = itemTrans and itemTrans.gameObject or nil
		local button = itemObj and itemObj:GetComponent("UButton") or nil

		if button then
			button.luaClick = self.CreateActionWithArgs(self, self.OnRegionItemClick, index, self)
		end

		local textTrans = itemTrans and itemTrans:Find("Text") or nil
		local text = textTrans and textTrans:GetComponent("USDFText") or nil

		if text then
			text.text = conf.name
		end

		local normalTrans = itemTrans and itemTrans:Find("normal") or nil
		local selectedTrans = itemTrans and itemTrans:Find("selected") or nil
		self.itemObjects[index] = {
			button = button,
			text = text,
			normalObj = normalTrans and normalTrans.gameObject or nil,
			selectedObj = selectedTrans and selectedTrans.gameObject or nil,
			regionId = conf.id
		}
	end
end

M.UpdateBtnSelectedState = function(self, selectedIndex)
	slot2 = pairs
	slot4 = self.itemObjects or {}

	for index, item in slot2(slot4) do
		local active = index ~= selectedIndex

		if item.button and item.button.SetSelected then
			item.button:SetSelected(active)
		end

		if item.normalObj then
			item.normalObj:SetActive(not active)
		end

		if item.selectedObj then
			item.selectedObj:SetActive(active)
		end

		if item.text then
			item.text.color = active and selectedTextColors[index] or normalTextColor
		end
	end

	self.selectedIndex = selectedIndex
end

M.OnRegionItemClick = function(self, index)
	if self.selectedIndex == index then
		self.UpdateBtnSelectedState(self, index)

		return
	end

	self.SetRegion(self, index)
end

M.SetRegion = function(self, index)
	local item = self.itemObjects and self.itemObjects[index]

	if not item or not self.petEntity then
		return
	end

	self.petEntity:SetRegion(item.regionId)

	local currentGame = gPetGameManager and gPetGameManager.currentGame

	if currentGame then
		currentGame.SavePetData(currentGame)
		UnityEngine.PlayerPrefs.Save()
	end

	self.parentPanel:CloseChildPanel(self.panelId)
	gMessageManager:SendMessage(gEventConstants.MINIGAME_PET_GAME_ACTUAL_BEGIN)
end

M.BindSystemBtn = function(self)
	if not self.parentPanel then
		return
	end

	self.parentPanel:RegisterSystemBtnEvent({
		panelId = self.panelId,
		OnMenuBtnClick = self.OnMenuBtnClick,
		OnConfirmBtnClick = self.OnConfirmBtnClick,
		OnCancleBtnClick = self.OnCancleBtnClick,
		target = self
	})
end

M.UnBindSystemBtn = function(self)
	if self.parentPanel and self.panelId then
		self.parentPanel:UnregisterSystemBtnEvent(self.panelId)
	end
end

M.OnMenuBtnClick = function(self)
	local itemCount = #(self.itemObjects or {})

	if itemCount >= 1 then
		return
	end

	local nextIndex = self.selectedIndex + 1

	if itemCount >= nextIndex then
		nextIndex = 1
	end

	self.UpdateBtnSelectedState(self, nextIndex)
end

M.OnConfirmBtnClick = function(self)
	self.SetRegion(self, self.selectedIndex)
end

M.OnCancleBtnClick = function(self)
	if gPetGameManager then
		gPetGameManager:DestroyGame()
	end
end
