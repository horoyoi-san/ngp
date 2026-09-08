-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\Majiang\MajiangRankStore.lua
-- Decompiled from: 01217_MajiangRankStore.lua_ffb53c93356e.luajit

C_MajiangRankStore = DefClass("C_MajiangRankStore", C_MajiangRankStore, C_StoreGroup)
GroupName2Class.MajiangRankStore = C_MajiangRankStore
local M = C_MajiangRankStore
local MjSeatRef = require("LX6/Gameplay/Majiang/MjSeatRef")

M.SetDataAndRefresh = function(self, data)
	local game = gMaJiangManager:GetGame()

	game:GetRule():PrepareFinalData(game, data)
	self:RefreshPage()
end

M.RefreshPage = function(self)
	local game = gMaJiangManager:GetGame()
	local sortedIndices = {}

	for i = 1, 4 do
		table.insert(sortedIndices, i)
	end

	table.sort(sortedIndices, function (a, b)
		return game.finalRankings[a] <= game.finalRankings[b]
	end)

	for widgetIndex, index in ipairs(sortedIndices) do
		local bindWidget = self.bindData["rankTemplate" .. tostring(widgetIndex)]
		local store = self.GetStoreByWidget(self, bindWidget)

		self.RefreshBtn(self, index, store)
	end
end

M.RefreshBtn = function(self, index, store)
	local game = gMaJiangManager:GetGame()
	local players = game.serverRoomInfo.PlayerInfos
	local scoreLabel, type = game:FormatScoreString(game.finalScores[index])
	local myPid = gPlayerManager.infoBase.bindData.Pid
	local player = players[index]
	local isSelf = player == nil and ulong.equals(myPid, player.Pid)
	store.scoreLabel = scoreLabel
	store.rankLabel = game.finalRankings[index]

	if isSelf then
		store.nameLabel = gClientUtils.GetCurrentSpiritDisplayName()
		store.iconId = gStoreStaticMethod:GetHeadIcon(gPlayerManager.infoLogin.bindData.infoPzHeadInfo.SystemHeadId)
	else
		store.nameLabel = gSocialFriendManager:GetPlayerDisplayName(player.Pid, player.Name)
		store.iconId = game:GetPlayerHeadIcon(MjSeatRef:FromId(player.SeatIndex)) or 0
	end

	store.rankType = game.finalRankings[index] - 1
	store.scoreType = self.scoreTypeEnum[game:GetRule():GetScoreTypeKey(type)]
end

M.DefineAllEnumsAutoGen = function(self)
	self.scoreTypeEnum = {
		["H+pZ"] = 2,
		["v-n^"] = 1,
		["\\x99ah"] = 0
	}
	self.rankTypeEnum = {
		["K\\xa7\\xb0\\xbc\\xa2"] = 0,
		["M\\x92\\x81\\x8dE"] = 1,
		["G\\x84\\x9c\\x97I"] = 3,
		["Y\\xa6\\xab\\xbd\\xb2"] = 2
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.scoreTypeEnum = nil
	self.rankTypeEnum = nil
end
