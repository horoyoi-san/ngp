-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\AgentTrustLevelUpStore.lua
-- Decompiled from: 01596_AgentTrustLevelUpStore.lua_6e1d6fe61fe0.luajit

local AgentProfileConfig = LTConfig.ProfileAgentProfileConfig
local AgentProfileRewardConfig = LTConfig.ProfileRewardConfig
local TextScriptTextConfig = LTConfig.TextScriptTextConfig
C_AgentTrustLevelUpStore = DefClass("C_AgentTrustLevelUpStore", C_AgentTrustLevelUpStore, C_StoreGroup)
GroupName2Class.AgentTrustLevelUpStore = C_AgentTrustLevelUpStore
local M = C_AgentTrustLevelUpStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.currentProfileId = nil
	self.isMaxTrust = false
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)

	self.bindData.jumpBtn.luaClick = self.CreateAction(self, "OnClickJumpBtn")
	self.bindData.jumpBtn2.luaClick = self.CreateAction(self, "OnClickJumpBtn")
end

M.OnShow = function(self, panelId, data)
	local profileId = data.profileId
	self.currentProfileId = profileId
	local config = AgentProfileConfig.GetConfig(profileId)
	local text = TextScriptTextConfig.GetConfig(89901192).Text
	self.bindData.trustText = string.format(text, config.Name)
	text = TextScriptTextConfig.GetConfig(89901436).Text
	self.bindData.maxTrustText = string.format(text, config.Name)
	self.bindData.iconId = config.HeadIcon

	self:RefreshRewardStatus(profileId, data.targetValue)

	local isMaxTrust = config.MaxTrust and config.MaxTrust <= 0 and config.MaxTrust > data.targetValue
	self.isMaxTrust = isMaxTrust
	local clipName = isMaxTrust and "S_NewCharacterCompendiumLevelUp_Max" or "S_NewCharacterCompendiumLevelUp_open"

	self.bindData.ani:Play(clipName)
	gLuaTimeMgrUtils.Delay(function ()
		gPanelManager:Close(self.m_Id)
	end, self.bindData.ani:GetClip(clipName).length)
end

M.OnClickJumpBtn = function(self)
	if not self.isMaxTrust then
		return
	end

	local profileId = self.currentProfileId

	if not profileId or profileId < 0 then
		return
	end

	gPanelManager:CheckShow(gPanelId.NEW_AGENT_PROFILE_PANEL, {
		jumpRelationProfileId = profileId
	})
end

M.RefreshRewardStatus = function(self, profileId, nowTrust)
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
		return a.needTrust <= b.needTrust
	end)

	local rewardCount = math.min(#sortedRewards, 4)
	self.bindData.totalNumCtrl = math.max(0, rewardCount - 1)
	local isTafei = profileId ~= 38000002
	local isGetFields = {
		"[\\xb6\\x8b\\x97",
		"[\\xb6\\x8b\\x97",
		"[\\xb6\\x8b\\x97",
		"[\\xb6\\x8b\\x97"
	}

	for i = 1, 4 do
		if i < rewardCount then
			local reward = sortedRewards[i]
			local rewardCfg = AgentProfileRewardConfig.GetConfig(reward.id)
			local canGet = isTafei or rewardCfg.NeedTrust > nowTrust
			self.bindData[isGetFields[i]] = canGet
		else
			self.bindData[isGetFields[i]] = false
		end
	end
end
