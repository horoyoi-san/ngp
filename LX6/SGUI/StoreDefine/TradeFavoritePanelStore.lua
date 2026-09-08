-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\TradeFavoritePanelStore.lua
-- Decompiled from: 01373_TradeFavoritePanelStore.lua_49a49bf19c7f.luajit

C_TradeFavoritePanelStore = DefClass("C_TradeFavoritePanelStore", C_TradeFavoritePanelStore, C_StoreGroup)
GroupName2Class.TradeFavoritePanelStore = C_TradeFavoritePanelStore
local M = C_TradeFavoritePanelStore

M.ctor = function(self)
	self.mgr = gTradeManager
end

M.DefineAllVariables = function(self)
	self.favoriteItems = {}
	self.showFavoriteOnly = false
end

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
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
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	self.RebuildFavoriteItems(self)
	self.RenderFavoriteList(self)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.TRADE_FAVORITE_LIST_CHANGE] = self.CreateAction(self, "OnTradeFavoriteListChange")
	}
end

M.OnTradeFavoriteListChange = function(self)
	self.RebuildFavoriteItems(self)
	self.RenderFavoriteList(self)
end

M.RegisterWidget = function(self)
	self.bindData.closeBtn.luaClick = self.CreateAction(self, self.OnClickCloseBtn)

	if self.bindData.favoriteList then
		self.bindData.favoriteList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderFavoriteItem)
		self.bindData.favoriteList.luaSimpleClick = self.CreateAction(self, self.OnSimpleClickFavoriteItem)
	end
end

M.OnClickCloseBtn = function(self)
	gPanelManager:Close(self.m_Id)
end

M.RebuildFavoriteItems = function(self)
	self.favoriteItems = {}
	local info = self.mgr:GetPlayerTradeInfo()

	if not info or not info.FavoriteTradeItemIds then
		return
	end

	local list = info.FavoriteTradeItemIds
	local count = list.Count or #list

	for i = 0, count - 1 do
		local tradeItemId = nil

		if list[0] == nil then
			tradeItemId = list[i]
		else
			tradeItemId = list[i + 1]
		end

		if tradeItemId then
			local itemCfg = self.mgr:GetTradeItemsById(tradeItemId)[1]

			if itemCfg then
				table.insert(self.favoriteItems, itemCfg)
			end
		end
	end
end

M.OnToggleFavorite = function(self, tradeItemId)
	if self.mgr:IsFavorite(tradeItemId) then
		self.mgr:AskTradeFavoriteItems({
			tradeItemId
		}, nil)
	else
		self.mgr:AskTradeFavoriteItems(nil, {
			tradeItemId
		})
	end
end

M.OnUnfavorite = function(self, tradeItemId)
	self.mgr:AskTradeFavoriteItems({
		tradeItemId
	}, nil)
end

M.SetShowFavoriteOnly = function(self, show)
	self.showFavoriteOnly = show

	self.RenderFavoriteList(self)
end

M.IsItemFavorite = function(self, tradeItemId)
	return self.mgr:IsFavorite(tradeItemId)
end

M.RenderFavoriteList = function(self)
	if not self.bindData.favoriteList then
		return
	end

	self.bindData.favoriteList:SetSimpleList(#self.favoriteItems)
end

M.OnSimpleRenderFavoriteItem = function(self, btn, index)
	local itemCfg = self.favoriteItems[index + 1]

	if not itemCfg then
		return
	end

	local store = btn.GetStore(btn)

	if not store then
		return
	end

	store.name = itemCfg.Name or ""

	if store.icon then
		store.icon = itemCfg.TradeImage or 0
	end

	if store.unfavoriteBtn then
		store.unfavoriteBtn.luaClick = self.CreateAction(self, function ()
			self:OnUnfavorite(itemCfg.Id)
		end)
	end
end

M.OnSimpleClickFavoriteItem = function(self, btn, index)
	local itemCfg = self.favoriteItems[index + 1]

	if not itemCfg then
		return
	end

	self.mgr:OpenDetailPanel(itemCfg.Id, true)
end
