-- Original chunk: @Lua\LuaFiles\LX6\Manager\Trade\TradeManager.lua
-- Decompiled from: 00763_TradeManager.lua_52cbedb95fb9.luajit

C_TradeManager = DefClass("C_TradeManager", C_TradeManager)
local M = C_TradeManager

dofile("LX6/Manager/Trade/TradeManager_RPC")
dofile("LX6/Manager/Trade/TradeManager_Data")
dofile("LX6/Manager/Trade/TradeManager_State")
dofile("LX6/Manager/Trade/TradeManager_UI")

M.ctor = function(self)
	self:OnInit()
end

M.OnInit = function(self)
	self.playerTradeInfo = nil
	self.marketCache = {}
	self.orderListCache = {}
	self.orderListPageState = {}
	self.orderIdToTradeItemId = {}
	self.tradeItemToTradeId = {}
	self.historyPageState = {}
	self.favoriteSet = {}
end

M.OnSyncPlayerTradeInfo = function(self, info)
	self.playerTradeInfo = info

	self:RebuildFavoriteSet()

	self.orderIdToTradeItemId = {}

	self:IndexActiveOrders()
	gMessageManager:SendMessage(gEventConstants.TRADE_PLAYER_INFO_CHANGE, info)
	gMessageManager:SendMessage(gEventConstants.TRADE_ORDER_LIST_CHANGE)
	gMessageManager:SendMessage(gEventConstants.TRADE_FAVORITE_LIST_CHANGE)

	if info and info.BoxCompositeProgressDict then
		gMessageManager:SendMessage(gEventConstants.TRADE_RECYCLE_PROGRESS_CHANGE)
	end
end

M.OnSyncTradeBoxCompositeProgress = function(self, boxId, progress)
	if not self.playerTradeInfo or not self.playerTradeInfo.BoxCompositeProgressDict then
		print_error("OnSyncTradeBoxCompositeProgress playerTradeInfo not initialized, boxId = ", boxId)

		return
	end

	self.playerTradeInfo.BoxCompositeProgressDict[boxId] = progress
end

gTradeManager = gTradeManager or C_TradeManager.new()
