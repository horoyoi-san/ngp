-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BowlingTechPinsPanelStore.lua
-- Decompiled from: 01624_BowlingTechPinsPanelStore.lua_dea99e0ddec7.luajit

C_BowlingTechPinsPanelStore = DefClass("C_BowlingTechPinsPanelStore", C_BowlingTechPinsPanelStore, C_StoreGroup)
GroupName2Class.BowlingTechPinsPanelStore = C_BowlingTechPinsPanelStore
local M = C_BowlingTechPinsPanelStore

M.OnAwake = function(self)
	self.bindData.BtnLeft.luaClick = self.CreateAction(self, "OnPinsMoveLeft")
	self.bindData.BtnRight.luaClick = self.CreateAction(self, "OnPinsMoveRight")
	self.bindData.BtnEnter.luaClick = self.CreateAction(self, "OnStartGameClick")
	self.bindData.exitButton.luaClick = self.CreateAction(self, "OnExitClick")
	self.bindData.uLoopList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderItem")
	self.bindData.uLoopList.luaSelectedChanged = self.CreateAction(self, "OnSelectedChanged")
end

M.OnShow = function(self, _, data)
	self.game = gBowlingGameManager.currentGame
	self.gameMode = self.game.gameMode
	self.count = data and data.count or 3
	self.completedList = data and data.completed or {}
	local selectedIndex = data and data.selectIndex or 1

	self:RefreshLoopList(selectedIndex - 1)
end

M.RefreshLoopList = function(self, selectedIndex)
	self.viewDataList = self:GetLoopListDataList()

	self.bindData.uLoopList:SetSimpleList(#self.viewDataList)
	self.bindData.uLoopList:SelectItem(selectedIndex, true)
end

M.GetLoopListDataList = function(self)
	local bowlingTechPatternList = require("LX6/MiniGame/BowlingGame/BowlingTechPatterns")

	return bowlingTechPatternList
end

M.OnExitClick = function(self)
	gPanelManager:CheckShow(gPanelId.S_CHALLENGE_END_PANEL, {
		["JT_|M+"] = true
	})
	gBowlingGameManager:ExecuteExitGame()
end

M.OnStartGameClick = function(self)
	local luaIndex = self.bindData.uLoopList.selectedIndex + 1

	self.game:ExecuteTechPinsSelected(luaIndex)
end

M.OnPinsMoveLeft = function(self)
	local selectedIndex = self.bindData.uLoopList.selectedIndex

	self.bindData.uLoopList:GoToIndex(selectedIndex - 1, true)
end

M.OnPinsMoveRight = function(self)
	local selectedIndex = self.bindData.uLoopList.selectedIndex

	self.bindData.uLoopList:GoToIndex(selectedIndex + 1, true)
end

M.OnRenderItem = function(self, btn, csIndex)
	local data = self.viewDataList[csIndex + 1]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local pinsList = data.pins

	for i = 1, #self.viewDataList do
		local key = "p" .. i
		local isSelected = table.contains(pinsList, i)
		local pinButton = store[key]
		local pinStore = gStoreManager:GetStoreGroup(pinButton.Store):GetStoreByWidget(pinButton)
		pinStore.isSelected = isSelected and 1 or 0
	end

	store.button.luaClick = function()
		self.bindData.uLoopList:GoToIndex(csIndex, false)
	end
end

M.OnSelectedChanged = function(self)
	local selectedIndex = self.bindData.uLoopList.selectedIndex
	local selectedItem = self.viewDataList[selectedIndex + 1]
	self.gameMode.dataSet.selectedIndex = selectedIndex
	local textId = selectedItem.name
	self.bindData.T0.text = LTConfig.TextScriptTextConfig.GetConfig(textId).Text

	self.RefreshSelectedInfoView(self)
end

M.RefreshSelectedInfoView = function(self)
	local isCompleted = false
	local lusSelectedIndex = self.bindData.uLoopList.selectedIndex + 1

	for _, completedIndex in ipairs(self.completedList) do
		if completedIndex ~= lusSelectedIndex then
			isCompleted = true

			break
		end
	end

	local selectedItem = self.viewDataList[lusSelectedIndex]
	local ball = self.bindData.Pins0.transform:Find("PinsState")

	for i = 1, 10 do
		local cIName = "PT" .. i
		local ptObj = ball.transform:Find(cIName)

		ptObj.gameObject:SetActive(false)
	end

	for _, pinNum in ipairs(selectedItem.pins) do
		local pIName = "PT" .. pinNum
		local ptObj = ball.transform:Find(pIName)

		ptObj.gameObject:SetActive(true)
	end

	self.bindData.completedNode:SetActive(isCompleted)

	self.bindData.BtnEnter.interactable = not isCompleted
end

M.OnDestroy = function(self)
end
