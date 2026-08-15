C_BowlingTechPinsPanelStore = DefClass("C_BowlingTechPinsPanelStore", C_BowlingTechPinsPanelStore, C_StoreGroup)
GroupName2Class.BowlingTechPinsPanelStore = C_BowlingTechPinsPanelStore
local M = C_BowlingTechPinsPanelStore

function M:OnAwake()
	self.bindData.BtnLeft.luaClick = self:CreateAction("OnPinsMoveLeft")
	self.bindData.BtnRight.luaClick = self:CreateAction("OnPinsMoveRight")
	self.bindData.BtnEnter.luaClick = self:CreateAction("OnStartGameClick")
	self.bindData.exitButton.luaClick = self:CreateAction("OnExitClick")
	self.bindData.uLoopList.luaRenderItem = self:CreateAction("OnRenderItem")
	self.bindData.uLoopList.luaSelectedChanged = self:CreateAction("OnSelectedChanged")
end

function M:OnShow(_, data)
	self.count = data and data.count or 3
	self.completedList = data and data.completed or {}
	local selectedIndex = data and data.selectIndex or 1

	self:RefreshLoopList(selectedIndex - 1)
end

function M:RefreshLoopList(selectedIndex)
	self.viewDataList = self:GetLoopListDataList()

	self.bindData.uLoopList:SetList(self.viewDataList)
	self.bindData.uLoopList:SelectItem(selectedIndex, true)
end

function M:GetLoopListDataList()
	local bowlingTechPatternList = require("LX6/MiniGame/BowlingGame/BowlingTechPatterns")

	return bowlingTechPatternList
end

function M:OnExitClick()
	gBowlingGameManager:ExecuteExitGame()
end

function M:OnStartGameClick()
	local luaIndex = self.bindData.uLoopList.selectedIndex + 1

	gBowlingGameManager.currentGame:ExecuteTechPinsSelected(luaIndex)
end

function M:OnPinsMoveLeft()
	local selectedIndex = self.bindData.uLoopList.selectedIndex

	self.bindData.uLoopList:GoToIndex(selectedIndex - 1, true)
end

function M:OnPinsMoveRight()
	local selectedIndex = self.bindData.uLoopList.selectedIndex

	self.bindData.uLoopList:GoToIndex(selectedIndex + 1, true)
end

function M:OnRenderItem(btn, csIndex, data)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local pinsList = data.pins

	for i = 1, #self.viewDataList do
		local key = "p" .. i
		local isSelected = table.contains(pinsList, i)
		local pinButton = store[key]
		local pinStore = gStoreManager:GetStoreGroup(pinButton.Store):GetStoreByWidget(pinButton)
		pinStore.isSelected = isSelected and 1 or 0
	end

	function store.button.luaClick()
		self.bindData.uLoopList:GoToIndex(csIndex, false)
	end
end

function M:OnSelectedChanged()
	local selectedItem = self.bindData.uLoopList.selectedItem
	gBowlingGameManager.currentGame.gameMode.dataSet.selectedIndex = self.bindData.uLoopList.selectedIndex
	local textId = selectedItem.name
	self.bindData.T0.text = LTConfig.TextScriptTextConfig.GetConfig(textId).Text

	self:RefreshSelectedInfoView()
end

function M:RefreshSelectedInfoView()
	local isCompleted = false
	local lusSelectedIndex = self.bindData.uLoopList.selectedIndex + 1

	for _, completedIndex in ipairs(self.completedList) do
		if completedIndex == lusSelectedIndex then
			isCompleted = true

			break
		end
	end

	local selectedItem = self.bindData.uLoopList.selectedItem
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

function M:OnDestroy()
	return
end
