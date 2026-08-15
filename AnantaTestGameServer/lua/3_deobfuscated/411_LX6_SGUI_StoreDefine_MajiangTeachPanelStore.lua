local MahjongHelpConfig = LTConfig.MahjongHelpConfig
local MahjongConfig = LTConfig.MahjongConfig
C_MajiangTeachPanelStore = DefClass("C_MajiangTeachPanelStore", C_MajiangTeachPanelStore, C_StoreGroup)
GroupName2Class.MajiangTeachPanelStore = C_MajiangTeachPanelStore
local M = C_MajiangTeachPanelStore

function M:ctor()
	return
end

function M:OnAwake()
	self.bindData.pageList.luaSelectedChanged = self:CreateAction("OnTabSelectChange")
	self.bindData.closeBtn.luaClick = self:CreateAction("OnExit")
	self.bindData.leftBtn.luaClick = self:CreateActionWithArgs("OnStep", -1)
	self.bindData.rightBtn.luaClick = self:CreateActionWithArgs("OnStep", 1)
end

function M:OnTabSelectChange(list)
	local index = list.selectedIndex
	self.bindData.tabIndex = index
end

function M:OnShow(panelId, data)
	self:GetGuideInfo()

	local pageList = self:GetGuideFistPageList()
	self.tabLength = #pageList

	self.bindData.pageList:SetList(pageList)
	self.bindData.pageList:SelectItem(0)

	self.callback = data and data.callback
end

function M:OnClose()
	if self.callback then
		self.callback()
	end
end

function M:GetPageList()
	if not self.pageList then
		self:GetGuideInfo()
	end

	return self.pageList
end

function M:GetGuideInfo()
	self.pageList = {}

	for i = 0, MahjongHelpConfig.count - 1 do
		local cfg = MahjongHelpConfig.LoadAt(i)

		if not self.pageList[cfg.Page] then
			self.pageList[cfg.Page] = {}
		end

		if cfg.SecPage then
			if not self.pageList[cfg.Page][cfg.SecPage] then
				self.pageList[cfg.Page][cfg.SecPage] = {}
			end

			table.insert(self.pageList[cfg.Page][cfg.SecPage], cfg.Id)
		else
			table.insert(self.pageList[cfg.Page], cfg.Id)
		end
	end
end

function M:GetGuideFistPageList()
	local pageList = {}

	for k, _ in pairs(self.pageList) do
		local label = MahjongConfig.MahjongHelpPage[k + 1]

		table.insert(pageList, {
			label = label
		})
	end

	return pageList
end

function M:RenderTechTemplate(btn, index, data)
	local store = gStoreManager:GetStoreGroup("MajiangTeachTemplateStore"):GetStoreByWidget(btn)

	if not store then
		return
	end

	if data.cfgId then
		data = self:GetTechTemplate(data.cfgId)
	end

	store.titleLabel = data.title
	store.descLabel = data.desc

	if data.icon ~= 0 then
		store.iconId = data.icon
	end

	if not table.isNilOrEmpty(data.cards) then
		store.cardList.luaRenderItem = self:CreateAction("OnRenderHandCard")
		local paiIcons = MahjongConfig.MahjongSPai
		local cardList = {}

		for i = 1, #data.cards do
			if data.cards[i] <= 0 then
				table.insert(cardList, {
					icon = 0,
					tIndex = 1
				})
			else
				local paiId = (math.floor(data.cards[i] / 10) - 1) * 9 + data.cards[i] % 10

				table.insert(cardList, {
					tIndex = 0,
					icon = paiIcons[paiId]
				})
			end
		end

		store.cardList:SetList(cardList)
	end
end

function M:OnRenderHandCard(btn, index, data)
	local store = gStoreManager:GetStoreGroup("MaJiangHandCardTemplate"):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.iconId = data.icon
	store.isMask = 1
	btn.draggable = false
	btn.interactable = false
end

function M:GetTechTemplate(index)
	local cfg = MahjongHelpConfig.GetConfig(index)

	if not cfg then
		return {}
	end

	local ele = {
		tIndex = #cfg.Cards > 0 and 0 or 1,
		title = cfg.Title,
		desc = cfg.Desc,
		icon = cfg.IconId,
		cards = cfg.Cards
	}

	return ele
end

function M:OnExit()
	gPanelManager:Close(gPanelId.S_MA_JIANG_TEACH_PANEL)
end

function M:OnStep(step)
	local next = self.bindData.pageList.selectedIndex + step

	if next < 0 then
		next = self.tabLength - 1
	end

	if self.tabLength <= next then
		next = 0
	end

	self.bindData.pageList:SelectItem(next)
end
