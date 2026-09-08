-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\Majiang\MajiangRimaFinalPanelStore.lua
-- Decompiled from: 01222_MajiangRimaFinalPanelStore.lua_14db494510e5.luajit

C_MajiangRimaFinalPanelStore = DefClass("C_MajiangRimaFinalPanelStore", C_MajiangRimaFinalPanelStore, C_StoreGroup)
GroupName2Class.MajiangRimaFinalPanelStore = C_MajiangRimaFinalPanelStore
local M = C_MajiangRimaFinalPanelStore
local ReachTile = require("LX6/Gameplay/Majiang/Reach/ReachTile")
local MahjongConfig = LTConfig.MahjongConfig

M.DefineAllEnumsAutoGen = function(self)
	self.yakumanCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.yakumanCtrlEnum = nil
end

M.OnAwake = function(self)
	self.bindData.nextPageBtn.luaClick = self.CreateAction(self, self.OnClickNextPageBtn)
	self.bindData.doraList.luaSimpleRenderItem = self.CreateAction(self, self.OnDoraListItemRender)
	self.bindData.uraDoraList.luaSimpleRenderItem = self.CreateAction(self, self.OnUraDoraListItemRender)
	self.bindData.yakuList.luaSimpleRenderItem = self.CreateAction(self, self.OnYakuListItemRender)
end

M.OnShow = function(self, panelId, data)
	local game = gMaJiangManager:GetGameOrEmpty()
	local result = game and game.reachGameState and game.reachGameState.Result

	if result ~= nil then
		return
	end

	local WinType = gReachMahjongConst.WinType
	local pointInfo, totalPoints, winnerName, doraIndicators, uraDoraIndicators = nil

	if result.WinType ~= WinType.Tsumo then
		local info = result.TsumoInfo
		pointInfo = info.TsumoPointInfo
		totalPoints = info.TotalPoints
		winnerName = info.TsumoPlayerName
		doraIndicators = info.DoraIndicators
		uraDoraIndicators = info.UraDoraIndicators
		self.bindData.agariReasonText = LTConfig.MahjongConfig.AgariText[1]
	elseif result.WinType ~= WinType.Rong then
		local info = result.RongInfo
		local myIndex = game.reachGameState.CurrentRound.MyPlayerIndex
		local idx = 1

		for i, seat in ipairs(info.RongPlayerIndices) do
			if seat ~= myIndex then
				idx = i

				break
			end
		end

		pointInfo = info.RongPointInfos[idx]
		totalPoints = info.TotalPoints[idx]
		winnerName = info.RongPlayerNames[idx]
		doraIndicators = info.DoraIndicators
		uraDoraIndicators = info.UraDoraIndicators
		self.bindData.agariReasonText = LTConfig.MahjongConfig.AgariText[2]
	else
		return
	end

	local YakuType = gReachMahjongConst.YakuType
	local yakuValues = pointInfo.YakuValues or {}
	local hasYakuman = false
	local totalHan = 0

	for _, yaku in ipairs(yakuValues) do
		if yaku.Type ~= YakuType.Yakuman then
			hasYakuman = true
			totalHan = totalHan + yaku.Value * gReachMahjongConst.ReachConstants.YakumanBaseFan
		else
			totalHan = totalHan + yaku.Value
		end
	end

	self.bindData.fuText = pointInfo.Fu
	local pts = totalPoints or 0
	self.bindData.pointText = (pts > 0 and "+" or "") .. pts

	if hasYakuman then
		self.bindData.yakumanText = "役满"
	else
		self.bindData.yakumanText = ""
	end

	self.bindData.hanText = totalHan
	self.doraTiles = doraIndicators or {}
	self.uraDoraTiles = uraDoraIndicators or {}
	self.yakuValues = yakuValues

	self.bindData.doraList:SetSimpleList(gReachMahjongConst.ReachConstants.MaxKongs + 1)
	self.bindData.uraDoraList:SetSimpleList(gReachMahjongConst.ReachConstants.MaxKongs + 1)
	self.bindData.yakuList:SetSimpleList(#self.yakuValues)
end

M.OnClickNextPageBtn = function(self)
	gPanelManager:Close(gPanelId.MAJIANG_RIMA_FINAL_PANEL)
	self:FinishRima()
end

M.FinishRima = function(self)
	local game = gMaJiangManager:GetGameOrEmpty()

	if game ~= nil then
		return
	end

	game.rimaPending = nil
	local pending = game.pendingGameEndInfo

	if pending == nil then
		game.pendingGameEndInfo = nil

		game.OpenFinal(game, pending)
	end
end

M.OnDestroy = function(self)
	self.FinishRima(self)

	self.doraTiles = nil
	self.uraDoraTiles = nil
	self.yakuValues = nil
end

M.OnDoraListItemRender = function(self, btn, index)
	local tile = self.doraTiles[index + 1]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if tile then
		store.iconId = ReachTile.GetIconId(tile)
		store.isBack = 0
	else
		store.isBack = 1
	end

	store.isMask = 1
end

M.OnUraDoraListItemRender = function(self, btn, index)
	local tile = self.uraDoraTiles[index + 1]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if tile then
		store.iconId = ReachTile.GetIconId(tile)
		store.isBack = 0
	else
		store.isBack = 1
	end

	store.isMask = 1
end

M.OnYakuListItemRender = function(self, btn, index)
	local yaku = self.yakuValues[index + 1]
	local store = self:GetStoreByWidget(btn)
	store.yakuNameText = LTConfig.MahjongConfig.YakuNameText[yaku.Name + 1] or ""
	store.yakuNumText = tostring(yaku.Value)
	store.yakumanCtrl = yaku.Type ~= gReachMahjongConst.YakuType.Yakuman and self.yakumanCtrlEnum._true or self.yakumanCtrlEnum._false
end
