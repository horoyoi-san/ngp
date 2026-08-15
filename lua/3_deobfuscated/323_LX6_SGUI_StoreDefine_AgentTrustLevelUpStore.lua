local AgentProfileConfig = LTConfig.ProfileAgentProfileConfig
local AgentProfileRewardConfig = LTConfig.ProfileRewardConfig
local TextScriptTextConfig = LTConfig.TextScriptTextConfig
C_AgentTrustLevelUpStore = DefClass("C_AgentTrustLevelUpStore", C_AgentTrustLevelUpStore, C_StoreGroup)
GroupName2Class.AgentTrustLevelUpStore = C_AgentTrustLevelUpStore
local M = C_AgentTrustLevelUpStore

function M:ctor()
	return
end

function M:DefineAllVariables()
	return
end

function M:OnAwake()
	self:DefineAllVariables()
end

function M:OnShow(panelId, data)
	local profileId = data.profileId
	local config = AgentProfileConfig.GetConfig(profileId)
	local text = TextScriptTextConfig.GetConfig(89901192).Text
	self.bindData.trustText = string.format(text, config.Name)
	self.bindData.iconId = config.HeadIcon

	self:RefreshRewardStatus(profileId, data.targetValue)
	gLuaTimeMgrUtils.Delay(function ()
		gPanelManager:Close(self.m_Id)
	end, self.bindData.ani:GetClip("S_NewCharacterCompendiumLevelUp_open").length)
end

function M:RefreshRewardStatus(profileId, nowTrust)
	if not profileId then
		return
	end

	local config = AgentProfileConfig.GetConfig(profileId)

	if not config or not config.TrustReward then
		self.bindData.totalNumCtrl = 0
		self.bindData.isGet1 = false
		self.bindData.isGet2 = false
		self.bindData.isGet3 = false
		self.bindData.isGet4 = false

		return
	end

	local sortedRewards = {}

	for _, rewardId in ipairs(config.TrustReward) do
		local rewardCfg = AgentProfileRewardConfig.GetConfig(rewardId)

		if rewardCfg then
			table.insert(sortedRewards, {
				id = rewardId,
				needTrust = rewardCfg.NeedTrust
			})
		end
	end

	table.sort(sortedRewards, function (a, b)
		return a.needTrust < b.needTrust
	end)

	local rewardCount = math.min(#sortedRewards, 4)
	self.bindData.totalNumCtrl = math.max(0, rewardCount - 1)
	local isTafei = profileId == 38000002
	local isGetFields = {
		"isGet1",
		"isGet2",
		"isGet3",
		"isGet4"
	}

	for i = 1, 4 do
		if i <= rewardCount then
			local reward = sortedRewards[i]
			local rewardCfg = AgentProfileRewardConfig.GetConfig(reward.id)
			local canGet = isTafei or rewardCfg.NeedTrust <= nowTrust
			self.bindData[isGetFields[i]] = canGet
		else
			self.bindData[isGetFields[i]] = false
		end
	end
end
