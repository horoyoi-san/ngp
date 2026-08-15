local MahjongRoomType = UX.Game.MahjongRoomType
C_MajiangFinalRankPanelStore = DefClass("C_MajiangFinalRankPanelStore", C_MajiangFinalRankPanelStore, C_StoreGroup)
GroupName2Class.MajiangFinalRankPanelStore = C_MajiangFinalRankPanelStore
local M = C_MajiangFinalRankPanelStore

function M:ctor()
	self.isRank = false
	self.cache = {}
end

function M:OnAwake()
	self.bindData.nextBtn.luaClick = self:CreateAction("SwitchToDetailPage", gMaJiangManager)
end

function M:OnShow(panelId, data)
	local actionData = data[1].MJActions
	self.isRank = gMaJiangManager.roomInfo.RoomType == MahjongRoomType.Pve

	gMaJiangManager:GetAllScoreAndMyRecord(actionData)
	gMaJiangManager:GetAllRanking()
	self:RefreshPage()
end

function M:OnClose()
	return
end

local seatStr = {
	"Self",
	"Next",
	"Oppo",
	"Last"
}

function M:RefreshPage()
	local players = gMaJiangManager.roomInfo.PlayerInfos

	for i = 1, 4 do
		local index = gMaJiangManager:GetSeatIndex(i) + 1
		local bindWidget = self.bindData["rankTemplate" .. seatStr[index]]
		local store = gStoreManager:GetStoreGroup("MajiangRenTemplate"):GetStoreByWidget(bindWidget)

		if store then
			local type = false
			store.scoreLabel, type = gMaJiangManager:FormatScoreString(gMaJiangManager.finalScores[index])
			store.rankLabel = gMaJiangManager.finalRankings[index]
			store.nameLabel = players[index].Name
			store.iconId = gMaJiangManager:GetPlayerLiHui(players[index])
			store.rankType = gMaJiangManager.finalRankings[index] - 1
			store.scoreType = type and 0 or 1
		end
	end
end
