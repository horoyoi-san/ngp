-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\Xuwei6DemensionDetailPanelStore.lua
-- Decompiled from: 01248_Xuwei6DemensionDetailPanelStore.lua_87f949dd2aaa.luajit

local FightSpiritConfig = LTConfig.FightSpiritConfig
C_Xuwei6DemensionDetailPanelStore = DefClass("C_Xuwei6DemensionDetailPanelStore", C_Xuwei6DemensionDetailPanelStore, C_StoreGroup)
GroupName2Class.Xuwei6DemensionDetailPanelStore = C_Xuwei6DemensionDetailPanelStore
local M = C_Xuwei6DemensionDetailPanelStore

M.ctor = function(self)
	self.selectedCardId = 0
end

M.OnAwake = function(self)
	self.bindData.backBtn.luaClick = self.CreateAction(self, "OnBackBtnClick")
	self.bindData.detailTree.luaRenderItem = self.CreateAction(self, "OnRenderTreeItem")
	self.bindData.detailTree.luaClick = self.CreateAction(self, "OnTreeItemClick")
end

M.OnBackBtnClick = function(self)
	gPanelManager:Close(gPanelId.S_XUWEI6_DEMENSION_DETAIL_PANEL)
end

M.OnRenderTreeItem = function(self, btn, index, data)
	local store = self.GetStoreByWidget(self, btn)

	if not store then
		return
	end

	if data.tIndex ~= 0 then
		store.icon = data.icon
		store.nameLabel = data.name
		store.descLabel = data.desc
		store.valueLabel = data.value
		store.additionLabel = "+" .. data.addition
		store.maxValue = "/" .. data.maxValue
		store.hasAddition = data.addition <= 0 and 0 or 1
	else
		store.nameLabel = data.name
		store.state = data.state
	end
end

M.OnTreeItemClick = function(self, btn, data)
	if data.callback then
		self.OnBackBtnClick(self)
		data.callback()
	end
end

M.OnShow = function(self, panelId, data)
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
		self.OnBackBtnClick(self)

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
			["I\\xab\\xb2\\xbb\\xbe"] = 0,
			["a\\x9f\\x8a\\x86Y"] = 0,
			["\\xae\\xa9\\xaad:\\xfb7"] = false,
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
				["I\\xab\\xb2\\xbb\\xbe"] = 1,
				["a\\x9f\\x8a\\x86Y"] = 1,
				name = hyper.text,
				state = hyper.state,
				callback = hyper.callback
			}

			table.insert(detailList, descDetailItem)
		end
	end

	self.bindData.detailTree:SetList(detailList)
end

M.OnClose = function(self)
end
