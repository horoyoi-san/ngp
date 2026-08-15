local MahjongConfig = LTConfig.MahjongConfig
C_MajiangRankingPanelStore = DefClass("C_MajiangRankingPanelStore", C_MajiangRankingPanelStore, C_StoreGroup)
GroupName2Class.MajiangRankingPanelStore = C_MajiangRankingPanelStore
local M = C_MajiangRankingPanelStore

function M:ctor()
	return
end

function M:OnAwake()
	self.bindData.backGround.luaClick = self:CreateAction("OnBackGroundClick")
	self.bindData.rankList.luaSimpleRenderItem = self:CreateAction(self.OnRenderRankingList)
	self.maxLength = MahjongConfig.MahjongRankMaxLen
end

function M:OnShow(panelId, data)
	local myRankScore = gMaJiangManager.myRankInfo.Score or 0
	local allRankList = gMaJiangManager:GetRankingList()
	local rankListViews = {}
	local headIcon, _ = gHunLunManager:GetHeadIconAndName(gPlayerManager.infoLogin.bindData.infoPzHeadInfo.SystemHeadId)
	local selfView = {
		ranking = self.maxLength + 1,
		name = gPlayerManager.infoLogin.bindData.name,
		score = myRankScore,
		icon = headIcon
	}
	self.isOnList = false

	for i = 1, #allRankList do
		if allRankList[i].score <= myRankScore and not self.isOnList then
			selfView.ranking = #rankListViews + 1

			table.insert(rankListViews, selfView)

			if self.maxLength <= #rankListViews then
				break
			end
		end

		local view = {
			ranking = #rankListViews + 1,
			name = allRankList[i].name,
			score = allRankList[i].score,
			icon = allRankList[i].icon
		}

		table.insert(rankListViews, view)

		if self.maxLength <= #rankListViews then
			break
		end
	end

	if #rankListViews < self.maxLength then
		selfView.ranking = #rankListViews + 1

		table.insert(rankListViews, selfView)
	end

	self.rankListData = rankListViews

	self.bindData.rankList:SetSimpleList(#rankListViews)
	self:OnRenderRankingList(self.bindData.selfRank, 0, selfView)
end

function M:OnRenderRankingList(btn, csIndex)
	local data = self.rankListData[csIndex + 1]
	local store = self:GetStoreByWidget(btn)

	if not store then
		return
	end

	store.rankScore = data.score

	if data.ranking <= 3 then
		store.rankType = data.ranking - 1
	else
		store.rankLabel = data.ranking
		store.rankType = self.maxLength < data.ranking and 4 or 3
	end

	local avatarStore = gStoreManager:GetStoreGroup("MaJiangAvatarTemplate"):GetStoreByWidget(store.avatarHead)

	if not avatarStore then
		return
	end

	avatarStore.nameLabel = data.name
	avatarStore.iconId = data.icon
end

function M:OnClose()
	return
end

function M:OnBackGroundClick()
	gPanelManager:Close(gPanelId.S_MA_JIANG_RANKING_PANEL)
end
