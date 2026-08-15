C_DeliveryScoreRankStore = DefClass("C_DeliveryScoreRankStore", C_DeliveryScoreRankStore, C_StoreGroup)
GroupName2Class.DeliveryScoreRankStore = C_DeliveryScoreRankStore
local M = C_DeliveryScoreRankStore
local FightSpiritConfig = LTConfig.FightSpiritConfig

function M:ctor()
	self.upAnimation = "S_Vx_DeliveryCreditTemplate_up"
	self.downAnimation = "S_Vx_DeliveryCreditTemplate_down"
	self.openAnimation = "S_Vx_DeliveryScoreRankPanel_open"
	self.closeTime = 2
end

function M:OnAwake()
	self.bindData.list.luaSimpleRenderItem = self:CreateAction(self.RankListRender)
end

function M:RankListRender(btn, index)
	local id = btn.gameObject:GetInstanceID()
	local store = self:GetStoreById(id)
	local data = self.RankInfos[index + 1]

	if store and data.rank then
		store.rank = data.rank
		store.name = data.name
		store.score = data.score

		if self.startRank == store.rank then
			store.playerState = 1
			store.lastState = data.isLast and 1 or 0
		end

		table.insert(self.storeList, store)
	end
end

function M:PlayRankAnimal(curRank, isUp)
	local store = self.storeList[curRank]
	local nextStore = isUp and self.storeList[curRank - 1] or self.storeList[curRank + 1]

	if not nextStore or not store or curRank <= self.finishRank and isUp or self.finishRank <= curRank and not isUp then
		Timer.New(function ()
			gPanelManager:Close(gPanelId.S_DELIVERY_RANK_PANEL)
		end, self.closeTime):Start()

		return
	end

	self:PlayAnimal(store, nextStore, false, isUp)

	local duration = 0.167
	local nextRank = nextStore.rank
	local nextName = nextStore.name
	local nextScore = nextStore.score

	Timer.New(function ()
		self:PlayAnimal(store, nextStore, true, isUp)

		nextStore.name = store.name
		nextStore.score = store.score
		store.name = nextName
		store.score = nextScore
	end, duration):Start()
	Timer.New(function ()
		nextStore.playerState = 1
		store.playerState = 0

		self:PlayRankAnimal(nextRank, isUp)
	end, duration * 2):Start()
end

function M:PlayAnimal(store, nextStore, reverse, isUp)
	if isUp then
		gCS.LuaUtils.PlayAnimationByName(store.root.anim, self.upAnimation, 0, reverse)
		gCS.LuaUtils.PlayAnimationByName(nextStore.root.anim, self.downAnimation, 0, reverse)
	else
		gCS.LuaUtils.PlayAnimationByName(store.root.anim, self.downAnimation, 0, reverse)
		gCS.LuaUtils.PlayAnimationByName(nextStore.root.anim, self.upAnimation, 0, reverse)
	end
end

function M:OnEnable()
	return
end

function M:OnStart()
	return
end

function M:OnDisable()
	return
end

function M:OnDestroy()
	return
end

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	return
end

function M:OnShow(_, data)
	self.areaIndex = data.areaIndex

	self.bindData.root.anim:Play()

	local duration = self.bindData.root.anim:GetClip(self.openAnimation).length
	self.startRank = data.startRank
	self.finishRank = data.finishRank

	self:InitConfig(self.finishRank, data.rewardPoint)
	Timer.New(function ()
		gPanelManager:Close(gPanelId.S_DELIVERY_RANK_PANEL)
	end, duration):Start()
end

local playerMaleId = LTConfig.FightSpiritConfig.DefaultMale
local playerFemaleId = LTConfig.FightSpiritConfig.DefaultFemale

function M:GetPlayRoleName()
	local roleId = gCS.MyPlayerManager.PlayerUnit.ClientData.cardId
	local cfg = FightSpiritConfig.GetConfig(roleId)

	if cfg == nil or roleId == playerMaleId or roleId == playerFemaleId then
		return gPlayerManager.infoLogin.bindData.name
	end

	return cfg.Name
end

function M:InitConfig(startRank, score)
	self.RankInfos = {}
	local PlayName = self:GetPlayRoleName()
	local data = {
		tIndex = 0,
		rank = startRank,
		name = PlayName,
		score = score
	}

	table.insert(self.RankInfos, data)

	self.storeList = {}

	self.bindData.list:SetSimpleList(#self.RankInfos)
end

function M:OnClose()
	return
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end
