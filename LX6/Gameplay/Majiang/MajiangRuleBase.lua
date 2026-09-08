-- Original chunk: @Lua\LuaFiles\LX6\Gameplay\Majiang\MajiangRuleBase.lua
-- Decompiled from: 00323_MajiangRuleBase.lua_5b4dcc15c94e.luajit

C_MajiangRuleBase = DefClass("C_MajiangRuleBase", C_MajiangRuleBase)
local M = C_MajiangRuleBase

M.ctor = function(self)
	self.game = nil
end

M.GetRuleName = function(self)
	return "Base"
end

M.OnAttachGame = function(self, game)
	self.game = game
end

M.OnDetachGame = function(self)
	self.game = nil
end

M.BuildMyHandDisplayList = function(self, withSort)
end

M.BuildOperationViewData = function(self, action)
end

M.BuildTooltipsViewData = function(self, gameState)
end

M.GetTings = function(self, seatID)
end

M.GetTingTiles = function(self, seatID)
end

M.IsDingque = function(self, paiInfo)
end

M.SetSeatQueList = function(self, ques)
end

M.GetHandCardState = function(self, seatID, paiInfo, open)
	return gMaJiangConst.MahjongState.None
end

M.ResolveSelect = function(self, ctx, card)
	if ctx.forceSelect == nil then
		return ctx.forceSelect
	end

	return card
end

M.GetMyHandCardSelectionState = function(self, handCardItem, i, ctx)
	error("GetMyHandCardSelectionState not implemented for rule: " .. (self:GetRuleName() or "nil"))
end

M.CanClickHandCard = function(self, handCardItem)
	return true
end

M.RefreshTimeOutByState = function(self, elapsedTime)
end

M.GetCardDisplayInfo = function(self, cardInfo)
	error("GetCardDisplayInfo not implemented for rule: " .. (self:GetRuleName() or "nil"))
end

M.IsSamePai = function(self, a, b)
	error("IsSamePai not implemented for rule: " .. (self:GetRuleName() or "nil"))
end

M.GetDiscardLayout = function(self, seat)
	return nil
end

M.GetDiscardRenderList = function(self, seat)
	local serverGameInfo = self.game and self.game.serverGameInfo

	if serverGameInfo ~= nil then
		return nil
	end

	local seatInfo = serverGameInfo.SeatInfos[seat + 1]

	return seatInfo and seatInfo.Folds
end

M.PrepareHandAreaRefresh = function(self, character, tileList, open)
	return true, open
end

M.BuildHandCardInfo = function(self, character, cardInfo, open)
	error("BuildHandCardInfo not implemented for rule: " .. (self:GetRuleName() or "nil"))
end

M.GetOutCardCount = function(self)
	return LTConfig.MahjongConfig.outCardCount
end

M.GetTotalCards = function(self)
	error("GetTotalCards not implemented for rule: " .. (self:GetRuleName() or "nil"))
end

M.CanOperateHandCardDuringAction = function(self, showOp, canGang)
	error("CanOperateHandCardDuringAction not implemented for rule: " .. (self:GetRuleName() or "nil"))
end

M.FormatScoreString = function(self, score)
	error("FormatScoreString not implemented for rule: " .. (self:GetRuleName() or "nil"))
end

M.GetScoreTypeKey = function(self, isWin)
	error("GetScoreTypeKey not implemented for rule: " .. (self:GetRuleName() or "nil"))
end

M.RefreshHandOnSetServerGameInfo = function(self, game, seatID)
	error("RefreshHandOnSetServerGameInfo not implemented for rule: " .. (self:GetRuleName() or "nil"))
end

M.OnChuPaiUpdateTimeout = function(self, game)
	error("OnChuPaiUpdateTimeout not implemented for rule: " .. (self:GetRuleName() or "nil"))
end

M.PrepareFinalData = function(self, game, data)
	error("PrepareFinalData not implemented for rule: " .. (self:GetRuleName() or "nil"))
end

M.ExtractHandCardsFromDisplayList = function(self, displayList)
	error("ExtractHandCardsFromDisplayList not implemented for rule: " .. (self:GetRuleName() or "nil"))
end

return M
