-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\DivinationBranchPanelStore.lua
-- Decompiled from: 01849_DivinationBranchPanelStore.lua_3be209d3bfda.luajit

C_DivinationBranchPanelStore = DefClass("C_DivinationBranchPanelStore", C_DivinationBranchPanelStore, C_StoreGroup)
GroupName2Class.DivinationBranchPanelStore = C_DivinationBranchPanelStore
local M = C_DivinationBranchPanelStore

M.ctor = function(self)
	self.INDEX_TO_PREFIX = {
		"\\xdd\\xde\t*\\xe8",
		"M\\x97\\x81\\x91D",
		"\\xc9\\xc9*\\xe5",
		"\\xdf\\xde\t6\\xf4"
	}
	self.PANEL_STAGE = {
		["^Nx"] = 1,
		["WTu"] = 0
	}
end

M.OnAwake = function(self)
	self.bindData.destinyBtn.luaRightClick = self.CreateAction(self, "OnDestinyBtnRightClick")
	self.bindData.destinyBtn.luaEndLongPress = self.CreateAction(self, "OnDestinyBtnEndLongPress")
	self.bindData.presentBtn.luaClick = self.CreateAction(self, "OnPresentBtnClick")
	self.bindData.presentBtn.luaRightClick = self.CreateAction(self, "OnPresentBtnRightClick")
	self.bindData.presentBtn.luaEndLongPress = self.CreateAction(self, "OnPresentBtnEndLongPress")
	self.bindData.featureBtn.luaClick = self.CreateAction(self, "OnFeatureBtnClick")
	self.bindData.featureBtn.luaRightClick = self.CreateAction(self, "OnFeatureBtnRightClick")
	self.bindData.featureBtn.luaEndLongPress = self.CreateAction(self, "OnFeatureBtnEndLongPress")
	self.bindData.beforeBtn.luaClick = self.CreateAction(self, "OnBeforeBtnClick")
	self.bindData.beforeBtn.luaRightClick = self.CreateAction(self, "OnBeforeBtnRightClick")
	self.bindData.beforeBtn.luaEndLongPress = self.CreateAction(self, "OnBeforeBtnEndLongPress")
	self.bindData.backBtn.luaClick = self.CreateAction(self, "OnBackBtnRightClick")
	self.bindData.fullBackBtn.luaClick = self.CreateAction(self, "OnFullBackBtnRightClick")
	self.bindData.okBtn.luaClick = self.CreateAction(self, "OnOkBtnRightClick")
	self.bindData.DetailRespond.luaGamePadInputChanged = self.CreateAction(self, "OnGamepadDetailControl")
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	self.closeCallback = data.closeCallback

	self.OnInit(self, data.demandId)
end

M.OnClose = function(self)
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

	gDivinerManager.divinerTable:DisableCamera()
end

M.OnActiveDeviceChange = function(self, device)
end

M.OnInit = function(self, demandId)
	local demandCfg = LTConfig.DivinerDemandConfig.GetConfig(demandId)

	if demandCfg then
		local tarotInitialOrder = demandCfg.TarotInitialOrder
		self.tarotOrder = {}

		for i = 1, #tarotInitialOrder do
			table.insert(self.tarotOrder, {
				["\\xd0\\xd5\t*\\xe5"] = false,
				id = tarotInitialOrder[i],
				hide = i == 1
			})
			self:RefreshCard(i)
		end

		self.branchId = demandCfg.BranchId
		self.bindData.demandDes = demandCfg.DemandDes
		self.bindData.demandTips = LTConfig.DivinerConfig.FlippingTarotCardsText
	end

	self.RefreshBranch(self)

	self.currentStage = self.PANEL_STAGE.MAIN
	self.bindData.stage = self.currentStage
end

M.RefreshCard = function(self, index)
	local card = self.tarotOrder[index]
	local cardCfg = LTConfig.DivinerDivinationCardConfig.GetConfig(card.id)

	if cardCfg then
		local varPrefix = self.INDEX_TO_PREFIX[index]
		local posVar = string.format("%sPos", varPrefix)
		local setVar = string.format("%sSet", varPrefix)
		local iconVar = string.format("%sIcon", varPrefix)
		local descVar = string.format("%sDesc", varPrefix)
		local btnVar = string.format("%sBtn", varPrefix)
		local btn = self.bindData[btnVar]

		if card.hide then
			self.bindData[posVar] = 0
			self.bindData[iconVar] = LTConfig.DivinerConfig.CardBackIcon
		else
			if card.instant then
				card.instant = false

				btn:TryChangePage("Pos", cardCfg.IsPositive and 1 or 2, true)
			else
				self.bindData[posVar] = cardCfg.IsPositive and 1 or 2
			end

			self.bindData[iconVar] = cardCfg.img
		end

		self.bindData[descVar] = cardCfg.ShortDes
		self.bindData[setVar] = index ~= 1 and 1 or 0

		gDivinerManager:ShowCardInsInDeskBack(index, not card.hide, card.id, cardCfg.IsPositive)

		local divinerCard = gDivinerManager.divinerTable:GetCard(index - 1)

		if divinerCard then
			local min, size = divinerCard.GetFaceScreenPos(divinerCard, nil, )
			local parentRect = btn.rectTransform.parent

			if gClientUtils.IsNil(parentRect) then
				return
			end

			local max = min + size
			local localMin = gCS.LuaUtils.TransformScreenPointToUI(parentRect, min)
			local localMax = gCS.LuaUtils.TransformScreenPointToUI(parentRect, max)
			local localSize = localMax - localMin
			btn.rectTransform.anchoredPosition = localMin + Vector2.New(localSize.x * 0.5, localSize.y * 0.5)
			btn.rectTransform.sizeDelta = localSize
		end
	end
end

M.RefreshBranch = function(self)
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

				if branchCfg and #branchCfg.TarotOrder ~= 4 then
					local found = true

					for i = 1, 4 do
						if branchCfg.TarotOrder[i] == self.tarotOrder[i].id then
							found = false

							break
						end
					end

					if found then
						branchFound = true

						self.RefreshBranchDisplay(self, branchCfg)

						break
					end
				end
			end
		end
	end

	if not branchFound then
		self.RefreshBranchDisplay(self)
	end
end

M.RefreshBranchDisplay = function(self, branchCfg)
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

	if gDivinerManager.isDebug and #self.tarotOrder ~= 4 then
		local debugBranchOut = branchCfg and branchCfg.DemandBranch or 0
		local info = string.format("Diviner branch %d|%d|%d|%d, branch id %d, out demand branch %d", self.tarotOrder[1].id, self.tarotOrder[2].id, self.tarotOrder[3].id, self.tarotOrder[4].id, self.currentBranchId or 0, debugBranchOut)

		print_notice(info)
	end
end

M.OnDestinyBtnClick = function(self)
	self.OnCardBtnClick(self, 1)
end

M.OnDestinyBtnRightClick = function(self)
	self.OnCardBtnRightClick(self, 1)
end

M.OnDestinyBtnEndLongPress = function(self)
	self.OnCardBtnEndLongPress(self, 1)
end

M.OnPresentBtnClick = function(self)
	self.OnCardBtnClick(self, 3)
end

M.OnPresentBtnRightClick = function(self)
	self.OnCardBtnRightClick(self, 3)
end

M.OnPresentBtnEndLongPress = function(self)
	self.OnCardBtnEndLongPress(self, 3)
end

M.OnFeatureBtnClick = function(self)
	self.OnCardBtnClick(self, 4)
end

M.OnFeatureBtnRightClick = function(self)
	self.OnCardBtnRightClick(self, 4)
end

M.OnFeatureBtnEndLongPress = function(self)
	self.OnCardBtnEndLongPress(self, 4)
end

M.OnBeforeBtnClick = function(self)
	self.OnCardBtnClick(self, 2)
end

M.OnBeforeBtnRightClick = function(self)
	self.OnCardBtnRightClick(self, 2)
end

M.OnBeforeBtnEndLongPress = function(self)
	self.OnCardBtnEndLongPress(self, 2)
end

M.OnBackBtnRightClick = function(self)
	if self.currentStage ~= self.PANEL_STAGE.DESC then
		self.currentStage = self.PANEL_STAGE.MAIN
		self.bindData.stage = self.currentStage
	else
		self.success = false

		gPanelManager:Close(gPanelId.DIVINATIONV_PANEL)
	end
end

M.OnFullBackBtnRightClick = function(self)
	if self.currentStage ~= self.PANEL_STAGE.DESC then
		self.currentStage = self.PANEL_STAGE.MAIN
		self.bindData.stage = self.currentStage
	end
end

M.OnOkBtnRightClick = function(self)
	self.success = true

	gPanelManager:Close(gPanelId.DIVINATIONV_PANEL)
end

M.OnCardBtnClick = function(self, index)
	local currentCard = self.tarotOrder[index]

	if currentCard then
		local cardCfg = LTConfig.DivinerDivinationCardConfig.GetConfig(currentCard.id)

		if cardCfg then
			if currentCard.hide then
				currentCard.hide = false
				currentCard.instant = true

				self.RefreshCard(self, index)

				local allCardFace = true

				for i = 1, #self.tarotOrder do
					if self.tarotOrder[i].hide then
						allCardFace = false
					end
				end

				if allCardFace then
					self.bindData.demandTips = LTConfig.DivinerConfig.SortingTarotCardsText
				end

				self.RefreshBranch(self)
			else
				self.tarotOrder[index].id = cardCfg.CorrespondingCard

				self.RefreshCard(self, index)
				self.RefreshBranch(self)
			end
		end
	end
end

M.OnCardBtnRightClick = function(self, index)
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.ShowDetail(self, index)
	end
end

M.OnCardBtnEndLongPress = function(self, index)
	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		self.ShowDetail(self, index)
	end
end

M.ShowDetail = function(self, index)
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

M.OnGamepadDetailControl = function(self, context)
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
			self.ShowDetail(self, focusIndex)
		end
	end
end
