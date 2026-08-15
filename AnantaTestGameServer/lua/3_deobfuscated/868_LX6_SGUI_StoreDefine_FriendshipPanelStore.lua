local NpcCultivationConfig = LTConfig.NpcCultivationConfig
C_FriendshipPanelStore = DefClass("C_FriendshipPanelStore", C_FriendshipPanelStore, C_StoreGroup)
GroupName2Class.FriendshipPanelStore = C_FriendshipPanelStore
local M = C_FriendshipPanelStore

function M:ctor()
	self.FavorStateCount = {
		[4.0] = 3,
		[5.0] = 6
	}
	self.ANIME_TYPE = {
		OPEN = "S_Vx_FriendshipPanel_open",
		UP = "S_Vx_FriendshipPanel_LevelUpMax",
		ADD = "S_Vx_FriendshipPanel_LevelUp",
		CLOSE = "S_Vx_FriendshipPanel_close"
	}
	self.switchLevelTime = 0.2
	self.switchLevel = false
	self.switchAnimePhase1 = false
	self.switchAnimePhase2 = false
	self.updateTime = 0
	self.finishTime = -1
	self.needUpdateNormal = false
	self.needUpdateClose = false
end

function M:OnAwake()
	return
end

function M:OnDestroy()
	return
end

function M:OnStart()
	return
end

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	return
end

function M:OnShow(panelId, param)
	self:ProcessData(param)
	self:InitAnime()
end

function M:OnClose()
	return
end

function M:ProcessData(param)
	local data = param.Param
	self.npcCultivationId = data.NpcId
	self.npcCfg = NpcCultivationConfig.GetConfig(self.npcCultivationId)
	self.areaIndex = param.areaIndex
	self.npcRare = self.npcCfg.Quality == 3 and 4 or 5
	local favor = data.favor
	local delta = data.delta
	local favorBefore = delta > 0 and favor - delta or favor
	local from = 0
	local fromBefore = 0
	local LevelMax = self.FavorStateCount[self.npcRare]
	local to = NpcCultivationConfig.FavorLevel[LevelMax]
	local toBefore = NpcCultivationConfig.FavorLevel[LevelMax]
	local favorLevelNow = LevelMax
	local favorLevelBefore = LevelMax

	for i = 1, LevelMax do
		if favor < NpcCultivationConfig.FavorLevel[i] then
			to = NpcCultivationConfig.FavorLevel[i]
			favorLevelNow = i - 1

			break
		else
			from = NpcCultivationConfig.FavorLevel[i]
		end
	end

	for i = 1, LevelMax do
		if favorBefore < NpcCultivationConfig.FavorLevel[i] then
			toBefore = NpcCultivationConfig.FavorLevel[i]
			favorLevelBefore = i - 1

			break
		else
			fromBefore = NpcCultivationConfig.FavorLevel[i]
		end
	end

	local fillAmountNow = from < to and (favor - from) / (to - from) or 0
	fillAmountNow = Mathf.Clamp01(fillAmountNow)

	if favorLevelNow == LevelMax then
		fillAmountNow = 1
	end

	local fillAmountBefore = fromBefore < toBefore and (favorBefore - fromBefore) / (toBefore - fromBefore) or 0
	fillAmountBefore = Mathf.Clamp01(fillAmountBefore)

	if favorLevelBefore == LevelMax then
		fillAmountBefore = 1
	end

	self.isLevelUp = favorLevelBefore < favorLevelNow
	self.isBeforeMax = favorLevelBefore == LevelMax
	self.isNowMax = favorLevelNow == LevelMax
	self.favorLevelBefore = "LV." .. favorLevelBefore
	self.favorLevelNow = "LV." .. favorLevelNow

	if self.isBeforeMax then
		self.favorLevelBeforeStart = toBefore
		self.favorLevelBeforeEnd = toBefore
		self.fillAmountBeforeStart = 1
		self.fillAmountBeforeEnd = 1
	else
		self.favorLevelBeforeStart = fromBefore
		self.favorLevelBeforeEnd = self.isLevelUp and toBefore or favorLevelNow
		self.fillAmountBeforeStart = fillAmountBefore
		self.fillAmountBeforeEnd = self.isLevelUp and 1 or fillAmountNow
	end

	if self.isNowMax then
		self.favorLevelNowStart = to
		self.favorLevelNowEnd = to
		self.fillAmountNowStart = 1
		self.fillAmountNowEnd = 1
	else
		self.favorLevelNowStart = self.isLevelUp and from or favorLevelNow
		self.favorLevelNowEnd = favorLevelNow
		self.fillAmountNowStart = self.isLevelUp and 0 or fillAmountNow
		self.fillAmountNowEnd = fillAmountNow
	end

	self.addAnimeTime = self.bindData.anime:GetClip(self.ANIME_TYPE.ADD).length
	self.upAnimeTime = self.bindData.anime:GetClip(self.ANIME_TYPE.UP).length
	self.closeAnimeTime = self.bindData.rootAnime:GetClip(self.ANIME_TYPE.CLOSE).length
	self.phase1 = self.isLevelUp and self.addAnimeTime or self.addAnimeTime + 1
	self.phase2 = self.addAnimeTime + self.upAnimeTime
	self.finishTime = self.isLevelUp and self.addAnimeTime + self.upAnimeTime + self.addAnimeTime or self.addAnimeTime + 1
end

function M:InitAnime()
	self.bindData.avatarIconId = self.npcCfg.SChatHeadId
	self.bindData.level = self.favorLevelBefore
	self.bindData.preFillAmount = self.fillAmountBeforeEnd
	self.bindData.fillAlpha = 1
	self.switchLevel = false
	self.switchAnimePhase1 = false
	self.switchAnimePhase2 = false
	self.needUpdateNormal = true
	self.needUpdateClose = false
	self.updateTime = 0

	self:PlayAnimation(self.ANIME_TYPE.ADD)
	self:PlayRootAnimation(self.ANIME_TYPE.OPEN)
end

function M:OnUpdate()
	if self.needUpdateNormal then
		if self.finishTime <= self.updateTime then
			self.needUpdateNormal = false
			self.needUpdateClose = true
			self.updateTime = 0

			self:PlayRootAnimation(self.ANIME_TYPE.CLOSE)

			self.bindData.fillAmount = self.fillAmountNowEnd

			return
		end

		if self.updateTime < self.phase1 then
			if self.updateTime < self.addAnimeTime then
				self.bindData.fillAmount = self.fillAmountBeforeStart + (self.fillAmountBeforeEnd - self.fillAmountBeforeStart) / self.addAnimeTime * self.updateTime
			else
				self.bindData.fillAmount = self.fillAmountBeforeEnd
			end
		elseif self.updateTime < self.phase2 then
			if not self.switchAnimePhase1 then
				self:PlayAnimation(self.ANIME_TYPE.UP)

				self.switchAnimePhase1 = true
				self.bindData.fillAmount = 1
			end

			if not self.switchLevel and self.updateTime > self.phase1 + self.switchLevelTime then
				self.bindData.level = self.favorLevelNow
				self.switchLevel = true
			end
		elseif not self.switchAnimePhase2 then
			self.switchAnimePhase2 = true

			if self.fillAmountNowEnd == 0 or self.isNowMax then
				self.finishTime = self.phase2
			else
				self:PlayAnimation(self.ANIME_TYPE.ADD)
			end

			if self.fillAmountNowEnd == 0 then
				self.bindData.fillAlpha = 0
			end

			self.bindData.fillAmount = self.fillAmountNowStart + (self.fillAmountNowEnd - self.fillAmountNowStart) / self.addAnimeTime * (self.updateTime - self.phase2)
			self.bindData.preFillAmount = self.fillAmountNowEnd
		else
			self.bindData.fillAlpha = 1
			self.bindData.fillAmount = self.fillAmountNowStart + (self.fillAmountNowEnd - self.fillAmountNowStart) / self.addAnimeTime * (self.updateTime - self.phase2)
		end

		self.updateTime = self.updateTime + Time.unscaledDeltaTime
	end

	if self.needUpdateClose then
		if self.closeAnimeTime <= self.updateTime then
			gPanelManager:Close(gPanelId.FRIENDSHIP_LEVEL_UP)

			self.needUpdateClose = false
		end

		self.updateTime = self.updateTime + Time.unscaledDeltaTime
	end
end

function M:PlayAnimation(anime)
	gCS.LuaUtils.PlayAnimationByName(self.bindData.anime, anime)
end

function M:PlayRootAnimation(anime)
	gCS.LuaUtils.PlayAnimationByName(self.bindData.rootAnime, anime)
end
