-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\Majiang\MajiangTeachPanelStore.lua
-- Decompiled from: 01227_MajiangTeachPanelStore.lua_a08bea5bc22a.luajit

local MahjongHelpConfig = LTConfig.MahjongHelpConfig
local MahjongConfig = LTConfig.MahjongConfig
C_MajiangTeachPanelStore = DefClass("C_MajiangTeachPanelStore", C_MajiangTeachPanelStore, C_StoreGroup)
GroupName2Class.MajiangTeachPanelStore = C_MajiangTeachPanelStore
local M = C_MajiangTeachPanelStore

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.bindData.pageList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderPageListItem")
	self.bindData.pageList.luaSelectedChanged = self.CreateAction(self, "OnTabSelectChange")
	self.bindData.closeBtn.luaClick = self.CreateAction(self, "OnExit")
	self.bindData.leftBtn.luaClick = self.CreateActionWithArgs(self, "OnStep", -1)
	self.bindData.rightBtn.luaClick = self.CreateActionWithArgs(self, "OnStep", 1)
end

M.OnTabSelectChange = function(self, list)
	local index = list.selectedIndex
	self.bindData.tabIndex = index
end

M.OnShow = function(self, panelId, data)
	self:GetGuideInfo()

	local pageList = self:GetGuideFistPageList()
	self.pageListData = pageList
	self.tabLength = #pageList

	self.bindData.pageList:SetSimpleList(#pageList)
	self.bindData.pageList:SelectItem(0)

	self.callback = data and data.callback
end

M.OnClose = function(self)
	if self.callback then
		self.callback()
	end
end

M.OnDestroy = function(self)
	self.pageList = nil
	self.pageListData = nil
	self.tabLength = nil
	self.callback = nil
end

M.GetPageList = function(self)
	if not self.pageList then
		self.GetGuideInfo(self)
	end

	return self.pageList
end

M.GetGuideInfo = function(self)
	self.pageList = {}

	for i = 0, MahjongHelpConfig.count - 1 do
		local cfg = MahjongHelpConfig.LoadAt(i)

		if not self.pageList[cfg.Page] then
			self.pageList[cfg.Page] = {}
		end

		if cfg.SecPage then
			if not self.pageList[cfg.Page][cfg.SecPage] then
				self.pageList[cfg.Page][cfg.SecPage] = {
					sort = cfg.SecPageSort
				}
			end

			table.insert(self.pageList[cfg.Page][cfg.SecPage], cfg.Id)
		else
			table.insert(self.pageList[cfg.Page], cfg.Id)
		end
	end
end

M.GetGuideFistPageList = function(self)
	local pageList = {}

	for k, _ in pairs(self.pageList) do
		local label = MahjongConfig.MahjongHelpPage[k + 1]

		table.insert(pageList, {
			label = label
		})
	end

	return pageList
end

M.OnRenderPageListItem = function(self, btn, index)
	local data = self.pageListData[index + 1]
	btn.title.text = data.label
end

M.RenderTechTemplate = function(self, btn, index, data)
	local store = gStoreManager:GetStoreGroup("MajiangTeachTemplateStore"):GetStoreByWidget(btn)

	if data.cfgId then
		data = self.GetTechTemplate(self, data.cfgId)
	end

	store.titleLabel = data.title
	store.descLabel = data.desc

	if data.icon == 0 then
		store.iconId = data.icon
	end

	if not table.isNilOrEmpty(data.cards) then
		local paiIcons = MahjongConfig.MahjongSPai
		local cardList = {}

		for i = 1, #data.cards do
			if data.cards[i] < 0 then
				table.insert(cardList, {
					["s!rU"] = 0,
					["a\\x9f\\x8a\\x86Y"] = 1
				})
			else
				local paiId = (math.floor(data.cards[i] / 10) - 1) * 9 + data.cards[i] % 10

				table.insert(cardList, {
					["a\\x9f\\x8a\\x86Y"] = 0,
					icon = paiIcons[paiId]
				})
			end
		end

		store.cardList.luaSimpleRenderItem = self:CreateActionWithArgs("OnRenderHandCard", cardList)

		store.cardList.onGetTIndex = function(csIndex)
			return (cardList[csIndex + 1] or {
				["a\\x9f\\x8a\\x86Y"] = 0
			}).tIndex
		end

		store.cardList:SetSimpleList(#cardList)
	end
end

M.OnRenderHandCard = function(self, listData, btn, index)
	local data = listData[index + 1]
	local store = gStoreManager:GetStoreGroup("MaJiangHandCardTemplate"):GetStoreByWidget(btn)
	store.iconId = data.icon
	store.isMask = 1
	btn.draggable = false
	btn.interactable = false
end

M.GetTechTemplate = function(self, index)
	local cfg = MahjongHelpConfig.GetConfig(index)

	if not cfg then
		return {}
	end

	local ele = {
		tIndex = #cfg.Cards <= 0 and 0 or 1,
		title = cfg.Title,
		desc = cfg.Desc,
		icon = cfg.IconId,
		cards = cfg.Cards
	}

	return ele
end

M.OnExit = function(self)
	gPanelManager:Close(gPanelId.S_MA_JIANG_TEACH_PANEL)
end

M.OnStep = function(self, step)
	local next = self.bindData.pageList.selectedIndex + step

	if next >= 0 then
		next = self.tabLength - 1
	end

	if self.tabLength < next then
		next = 0
	end

	self.bindData.pageList:SelectItem(next)
end
