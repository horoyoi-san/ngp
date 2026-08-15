C_DivinationBranchPanelStore = DefClass("C_DivinationBranchPanelStore", C_DivinationBranchPanelStore, C_StoreGroup)
GroupName2Class.DivinationBranchPanelStore = C_DivinationBranchPanelStore
local M = C_DivinationBranchPanelStore

function M:ctor()
	self.INDEX_TO_PREFIX = {
		"destiny",
		"before",
		"present",
		"feature"
	}
	self.PANEL_STAGE = {
		DESC = 1,
		MAIN = 0
	}
end

function M:OnAwake()
	self.bindData.destinyBtn.luaRightClick = self:CreateAction("OnDestinyBtnRightClick")
	self.bindData.destinyBtn.luaEndLongPress = self:CreateAction("OnDestinyBtnEndLongPress")
	self.bindData.presentBtn.luaClick = self:CreateAction("OnPresentBtnClick")
	self.bindData.presentBtn.luaRightClick = self:CreateAction("OnPresentBtnRightClick")
	self.bindData.presentBtn.luaEndLongPress = self:CreateAction("OnPresentBtnEndLongPress")
	self.bindData.featureBtn.luaClick = self:CreateAction("OnFeatureBtnClick")
	self.bindData.featureBtn.luaRightClick = self:CreateAction("OnFeatureBtnRightClick")
	self.bindData.featureBtn.luaEndLongPress = self:CreateAction("OnFeatureBtnEndLongPress")
	self.bindData.beforeBtn.luaClick = self:CreateAction("OnBeforeBtnClick")
	self.bindData.beforeBtn.luaRightClick = self:CreateAction("OnBeforeBtnRightClick")
	self.bindData.beforeBtn.luaEndLongPress = self:CreateAction("OnBeforeBtnEndLongPress")
	self.bindData.backBtn.luaClick = self:CreateAction("OnBackBtnRightClick")
	self.bindData.fullBackBtn.luaClick = self:CreateAction("OnFullBackBtnRightClick")
	self.bindData.okBtn.luaClick = self:CreateAction("OnOkBtnRightClick")
	self.bindData.DetailRespond.luaGamePadInputChanged = self:CreateAction("OnGamepadDetailControl")
end

function M:OnEnable()
	return
end

function M:OnStart()
	return
end

function M:OnDisable()
	return
end

function M:OnDestroy()
	return
end

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	return
end

function M:OnShow(panelId, data)
	self.closeCallback = data.closeCallback

	self:OnInit(data.demandId)
end

function M:OnClose()
	if self.closeCallback then
		local result = 1

		if self.success then
			local branchCfg = LTConfig.DivinerBranchConfig.GetConfig(self.currentBranchId or 0)

			if branchCfg then
				result = branchCfg.DemandBranch + 1
			end
		end

		self.closeCallback(result)

		self.closeCallback = nil
	end

	local data = {
		cardData = {}
	}

	for index = 1, #self.tarotOrder do
		local currentCard = self.tarotOrder[index]

		table.insert(data.cardData, {
			id = currentCard.id,
			face = not currentCard.hide
		})
	end

	data.branchId = self.success and self.currentBranchId or 0

	gDivinerManager:EndBranchSelect(data)

	self.branchId = nil
	self.tarotOrder = nil
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end

function M:OnInit(demandId)
	local demandCfg = LTConfig.DivinerDemandConfig.GetConfig(demandId)

	if demandCfg then
		local tarotInitialOrder = demandCfg.TarotInitialOrder
		self.tarotOrder = {}

		for i = 1, #tarotInitialOrder do
			table.insert(self.tarotOrder, {
				instant = false,
				id = tarotInitialOrder[i],
				hide = i ~= 1
			})
			self:RefreshCard(i)
		end

		self.branchId = demandCfg.BranchId
		self.bindData.demandDes = demandCfg.DemandDes
		self.bindData.demandTips = LTConfig.DivinerConfig.FlippingTarotCardsText
	end

	self:RefreshBranch()

	self.currentStage = self.PANEL_STAGE.MAIN
	self.bindData.stage = self.currentStage
end

function M:RefreshCard(index)
	local card = self.tarotOrder[index]
	local cardCfg = LTConfig.DivinerDivinationCardConfig.GetConfig(card.id)

	if cardCfg then
		local varPrefix = self.INDEX_TO_PREFIX[index]
		local posVar = string.format("%sPos", varPrefix)
		local setVar = string.format("%sSet", varPrefix)
		local iconVar = string.format("%sIcon", varPrefix)
		local descVar = string.format("%sDesc", varPrefix)

		if card.hide then
			self.bindData[posVar] = 0
			self.bindData[iconVar] = LTConfig.DivinerConfig.CardBackIcon
		else
			if card.instant then
				card.instant = false
				local btnVar = string.format("%sBtn", varPrefix)

				self.bindData[btnVar]:TryChangePage("Pos", cardCfg.IsPositive and 1 or 2, true)
			else
				self.bindData[posVar] = cardCfg.IsPositive and 1 or 2
			end

			self.bindData[iconVar] = cardCfg.img
		end

		self.bindData[descVar] = cardCfg.ShortDes
		self.bindData[setVar] = index == 1 and 1 or 0
	end
end

function M:RefreshBranch()
	local branchFound = false

	if self.branchId and self.tarotOrder then
		local allValid = true

		for i = 1, #self.tarotOrder do
			if self.tarotOrder[i].hide then
				allValid = false

				break
			end
		end

		if allValid then
			for _, branchId in pairs(self.branchId) do
				local branchCfg = LTConfig.DivinerBranchConfig.GetConfig(branchId)

				if branchCfg and #branchCfg.TarotOrder == 4 then
					local found = true

					for i = 1, 4 do
						if branchCfg.TarotOrder[i] ~= self.tarotOrder[i].id then
							found = false

							break
						end
					end

					if found then
						branchFound = true

						self:RefreshBranchDisplay(branchCfg)

						break
					end
				end
			end
		end
	end

	if not branchFound then
		self:RefreshBranchDisplay()
	end
end

function M:RefreshBranchDisplay(branchCfg)
	if branchCfg then
		self.currentBranchId = branchCfg.Id
		self.bindData.briefDes = branchCfg.BriefDes
		self.bindData.detailDes = branchCfg.DetailDes
		self.bindData.okBtn.interactable = true
	else
		self.currentBranchId = nil
		self.bindData.briefDes = LTConfig.DivinerConfig.NoMatchBranchBriefDes
		self.bindData.detailDes = LTConfig.DivinerConfig.NoMatchBranchDetailDes
		self.bindData.okBtn.interactable = false
	end

	if gDivinerManager.isDebug and #self.tarotOrder == 4 then
		local debugBranchOut = branchCfg and branchCfg.DemandBranch or 0
		local info = string.format("Diviner branch %d|%d|%d|%d, branch id %d, out demand branch %d", self.tarotOrder[1].id, self.tarotOrder[2].id, self.tarotOrder[3].id, self.tarotOrder[4].id, self.currentBranchId or 0, debugBranchOut)

		print_notice(info)
	end
end

function M:OnDestinyBtnClick()
	self:OnCardBtnClick(1)
end

function M:OnDestinyBtnRightClick()
	self:OnCardBtnRightClick(1)
end

function M:OnDestinyBtnEndLongPress()
	self:OnCardBtnEndLongPress(1)
end

function M:OnPresentBtnClick()
	self:OnCardBtnClick(3)
end

function M:OnPresentBtnRightClick()
	self:OnCardBtnRightClick(3)
end

function M:OnPresentBtnEndLongPress()
	self:OnCardBtnEndLongPress(3)
end

function M:OnFeatureBtnClick()
	self:OnCardBtnClick(4)
end

function M:OnFeatureBtnRightClick()
	self:OnCardBtnRightClick(4)
end

function M:OnFeatureBtnEndLongPress()
	self:OnCardBtnEndLongPress(4)
end

function M:OnBeforeBtnClick()
	self:OnCardBtnClick(2)
end

function M:OnBeforeBtnRightClick()
	self:OnCardBtnRightClick(2)
end

function M:OnBeforeBtnEndLongPress()
	self:OnCardBtnEndLongPress(2)
end

function M:OnBackBtnRightClick()
	if self.currentStage == self.PANEL_STAGE.DESC then
		self.currentStage = self.PANEL_STAGE.MAIN
		self.bindData.stage = self.currentStage
	else
		self.success = false

		gPanelManager:Close(gPanelId.DIVINATIONV_PANEL)
	end
end

function M:OnFullBackBtnRightClick()
	if self.currentStage == self.PANEL_STAGE.DESC then
		self.currentStage = self.PANEL_STAGE.MAIN
		self.bindData.stage = self.currentStage
	end
end

function M:OnOkBtnRightClick()
	self.success = true

	gPanelManager:Close(gPanelId.DIVINATIONV_PANEL)
end

function M:OnCardBtnClick(index)
	local currentCard = self.tarotOrder[index]

	if currentCard then
		local cardCfg = LTConfig.DivinerDivinationCardConfig.GetConfig(currentCard.id)

		if cardCfg then
			if currentCard.hide then
				currentCard.hide = false
				currentCard.instant = true

				self:RefreshCard(index)

				local allCardFace = true

				for i = 1, #self.tarotOrder do
					if self.tarotOrder[i].hide then
						allCardFace = false
					end
				end

				if allCardFace then
					self.bindData.demandTips = LTConfig.DivinerConfig.SortingTarotCardsText
				end

				self:RefreshBranch()
			else
				self.tarotOrder[index].id = cardCfg.CorrespondingCard

				self:RefreshCard(index)
				self:RefreshBranch()
			end
		end
	end
end

function M:OnCardBtnRightClick(index)
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self:ShowDetail(index)
	end
end

function M:OnCardBtnEndLongPress(index)
	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		self:ShowDetail(index)
	end
end

function M:ShowDetail(index)
	local currentCard = self.tarotOrder[index]

	if currentCard and not currentCard.hide then
		local cardCfg = LTConfig.DivinerDivinationCardConfig.GetConfig(currentCard.id)

		if cardCfg then
			self.bindData.previewIcon = cardCfg.img
			self.bindData.previewName = cardCfg.name
			self.bindData.previewPositive = cardCfg.IsPositive and LTConfig.DivinerConfig.PositiveText or LTConfig.DivinerConfig.NegativeText
			self.bindData.previewShortDesc = cardCfg.ShortDes
			self.bindData.previewLongDesc = cardCfg.Description
		end
	end

	self.currentStage = self.PANEL_STAGE.DESC
	self.bindData.stage = self.currentStage
end

function M:OnGamepadDetailControl(context)
	if context.performed then
		local focusIndex = nil

		for index = 1, 4 do
			local varPrefix = self.INDEX_TO_PREFIX[index]
			local btnVar = string.format("%sBtn", varPrefix)

			if self.bindData[btnVar].isFocus then
				focusIndex = index

				break
			end
		end

		if focusIndex then
			self:ShowDetail(focusIndex)
		end
	end
end
