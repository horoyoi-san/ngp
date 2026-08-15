local FightSpiritConfig = LTConfig.FightSpiritConfig
C_Xuwei6DemensionDetailPanelStore = DefClass("C_Xuwei6DemensionDetailPanelStore", C_Xuwei6DemensionDetailPanelStore, C_StoreGroup)
GroupName2Class.Xuwei6DemensionDetailPanelStore = C_Xuwei6DemensionDetailPanelStore
local M = C_Xuwei6DemensionDetailPanelStore

function M:ctor()
	self.selectedCardId = 0
end

function M:OnAwake()
	self.bindData.backBtn.luaClick = self:CreateAction("OnBackBtnClick")
	self.bindData.detailTree.luaRenderItem = self:CreateAction("OnRenderTreeItem")
	self.bindData.detailTree.luaClick = self:CreateAction("OnTreeItemClick")
end

function M:OnBackBtnClick()
	gPanelManager:Close(gPanelId.S_XUWEI6_DEMENSION_DETAIL_PANEL)
end

function M:OnRenderTreeItem(btn, index, data)
	local store = self:GetStoreByWidget(btn)

	if not store then
		return
	end

	if data.tIndex == 0 then
		store.icon = data.icon
		store.nameLabel = data.name
		store.descLabel = data.desc
		store.valueLabel = data.value
		store.additionLabel = "+" .. data.addition
		store.maxValue = "/" .. data.maxValue
		store.hasAddition = data.addition > 0 and 0 or 1
	else
		store.nameLabel = data.name
		store.state = data.state
	end
end

function M:OnTreeItemClick(btn, data)
	if data.callback then
		self:OnBackBtnClick()
		data.callback()
	end
end

function M:OnShow(panelId, data)
	if not data or not data.selectedCardTid then
		print_error("C_Xuwei6DemensionDetailPanelStore:OnShow data is nil")

		return
	end

	self.selectedCardId = data.selectedCardTid
	local urbanAttrs = gUrbanAbilityManager:GetUrbanAttrs(self.selectedCardId)
	local cfg = FightSpiritConfig.GetConfig(self.selectedCardId)
	local baseAttrs = cfg and cfg.UrbanAttribute
	urbanAttrs = urbanAttrs or baseAttrs

	if not urbanAttrs or not baseAttrs then
		self:OnBackBtnClick()

		return
	end

	local lifeAttrRuleList = gSpiritManager:GetUrbanRuleList(true)
	local detailList = {}

	for i = 1, #urbanAttrs do
		self.bindData.radarChart:SetVertexValue(i - 1, urbanAttrs[i])

		local component = self.bindData["radarTitle" .. i]
		local store = self:GetStoreByWidget(component)

		if store then
			store.icon = lifeAttrRuleList[i].attrIcon
			store.nameLabel = lifeAttrRuleList[i].attrName
		end

		local detailItem = {
			depth = 0,
			tIndex = 0,
			expanded = false,
			icon = lifeAttrRuleList[i].attrIcon,
			name = lifeAttrRuleList[i].attrName,
			value = urbanAttrs[i],
			desc = lifeAttrRuleList[i].attrDesc,
			addition = urbanAttrs[i] - baseAttrs[i],
			maxValue = lifeAttrRuleList[i].attrMax
		}

		table.insert(detailList, detailItem)

		for j = 1, #lifeAttrRuleList[i].attrHyper do
			local hyper, _ = gItemHyperLinkManager:GetSourceBehaviorByHyperLink(lifeAttrRuleList[i].attrHyper[j], self.selectedCardId)
			local descDetailItem = {
				depth = 1,
				tIndex = 1,
				name = hyper.text,
				state = hyper.state,
				callback = hyper.callback
			}

			table.insert(detailList, descDetailItem)
		end
	end

	self.bindData.detailTree:SetList(detailList)
end

function M:OnClose()
	return
end
