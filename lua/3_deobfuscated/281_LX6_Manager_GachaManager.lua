local FightSpiritConfig = LTConfig.FightSpiritConfig
local StoneConfig = LTConfig.StoneConfig
local StaticProps = {
	ItemType = {
		STONE = 1,
		FIGHT_SPIRIT = 0
	}
}
C_GachaManager = DefClass("C_GachaManager", C_GachaManager, nil, StaticProps)
local M = C_GachaManager
M.EventHandler = {
	[gEventConstants.GACHA_VIDEO_STOP] = function (eventId, settleImmediately)
		if not gGachaManager.isGachaing then
			print_error("抽卡结果为空")

			return
		end

		if not gGachaManager.isDeca then
			gPanelManager:CheckShow(gPanelId.GACHA_SETTLE_ONCE, {
				result = gGachaManager.gachaResult[1],
				clickCB = function ()
					gGachaManager:OnSettleEnd()
				end
			})
		else
			gGachaManager:DecaSettle(settleImmediately)
		end
	end
}

function M:ctor()
	for event, func in pairs(self.EventHandler) do
		gMessageManager:AddMessageListener(event, func)
	end

	self.configDataTypeList = {
		FightSpiritConfig,
		StoneConfig
	}
	self.poolCfg = nil
end

function M:OnBeforeSwitchScene(switchType)
	if gSwitchSceneType.Image <= switchType and self.isGachaing then
		self:OnSettleEnd()
	end
end

function M:OnAskGachaSuccess(count, result, rewards, itemMap)
	if self.isGachaing then
		self:OnSettleEnd()
	end

	self.isGachaing = true
	self.isDeca = count == 10
	self.itemMap = itemMap
	self.gachaCount = #result
	self.gachaResult = {}
	self.totalRewards = {}
	local totalRewardsMap = {}

	for i = 1, self.gachaCount do
		local oneGacha = {
			isDupSpiritDrop = false,
			id = result[i].TemplateId,
			uid = result[i].InstanceId,
			isNew = itemMap[result[i].TemplateId] == nil
		}
		itemMap[result[i].TemplateId] = true
		local spriteCfg, _ = self:GetGachaResultCfg(result[i].TemplateId)

		if rewards[i] then
			local popupParam = gItemUtils:ConvertRewardDetail(rewards[i])
			oneGacha.rewards = popupParam.Rewards

			for j = 1, #popupParam.Rewards do
				local r = popupParam.Rewards[j]

				if not totalRewardsMap[r.ItemId] then
					totalRewardsMap[r.ItemId] = {
						ItemId = r.ItemId,
						Count = r.Count,
						Icon = r.Icon,
						Quality = r.Quality
					}
				else
					totalRewardsMap[r.ItemId].Count = totalRewardsMap[r.ItemId].Count + r.Count
				end
			end
		end

		self.gachaResult[i] = oneGacha
	end

	for _, v in pairs(totalRewardsMap) do
		table.insert(self.totalRewards, v)
	end

	gDropManager:AddToNextFrameList({
		Rewards = self.gachaResult
	}, C_DropManager.DEFAULT_SHOW_TYPE)
	gDropManager:AddToNextFrameList({
		Rewards = self.totalRewards
	}, C_DropManager.DEFAULT_SHOW_TYPE)
end

function M:OnSettleEnd()
	self.isGachaing = false
	self.isDeca = nil
	self.gachaResult = nil
	self.gachaCount = nil
	self.currentGachaIndex = nil
	self.totalRewards = nil
	self.itemMap = {}
end

function M:OnDecaSettleClose()
	if self.isGachaing then
		local data = self.totalRewards

		FrameTimer.New(function ()
			gDropManager:ShowRewardWindow({
				ExtraRewardParam = 2,
				Rewards = data
			})
		end, 3):Start()
		self:OnSettleEnd()
	end
end

function M:DecaSettle(showDecaSettle)
	if showDecaSettle then
		gPanelManager:CheckShow(gPanelId.GACHA_SETTLE_DECA, {
			showAnim = true,
			result = self.gachaResult,
			closeCB = function ()
				self:OnDecaSettleClose()
			end
		})

		return
	end

	self.currentGachaIndex = (self.currentGachaIndex or 0) + 1

	if self.gachaCount < self.currentGachaIndex then
		gPanelManager:CheckShow(gPanelId.GACHA_SETTLE_DECA, {
			showAnim = true,
			result = self.gachaResult,
			closeCB = function ()
				self:OnDecaSettleClose()
			end
		})
	else
		gPanelManager:CheckShow(gPanelId.GACHA_SETTLE_ONCE, {
			showJump = true,
			result = self.gachaResult[self.currentGachaIndex],
			clickCB = self.JumpToNext,
			jumpCB = function ()
				gGachaManager:DecaSettle(true)
			end
		})
	end
end

function M.JumpToNext()
	gGachaManager:DecaSettle()
end

function M:GetGachaResultCfg(id)
	local configType, cfg = nil

	for i = 1, #self.configDataTypeList do
		configType = self.configDataTypeList[i]
		cfg = configType.GetConfig(id)

		if cfg then
			return cfg, configType
		end
	end
end

gGachaManager = gGachaManager or C_GachaManager.new()
