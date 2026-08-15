local M = {}

function M:OnInit()
	self.mGameRules = {}
	self.mOverRules = {}
	self.GameRuleType = {
		Galaxian = 1,
		Universeeker = 2
	}
	self.mGameRuleType2RaidId = {}
	self.exitInteractionType = -1
end

function M:OnBeforeSwitchScene(switchType)
	if switchType == gSwitchSceneType.KickToLogin then
		self:ClearAllRule()
	end

	if switchType == gSwitchSceneType.Reconnect then
		return
	end

	gSceneGameRuleManager:CheckGameRule()
end

function M:CreateProcedureGameRule(ruleType, exitExitInteractionType)
	if ruleType == self.GameRuleType.Galaxian then
		local GalaxianGameRule = require("LX6/Manager/SceneGameRule/ArcadeGalaxianGameRule")
		self.mGameRules[ruleType] = GalaxianGameRule.new()
	end

	self.exitInteractionType = exitExitInteractionType or -1

	self:RefreshDynamicUpdate()
end

function M:DestroyGameRule(ruleType)
	if self.mGameRules[ruleType] and self.mGameRules[ruleType].Destroy then
		self.mGameRules[ruleType]:Destroy()

		self.mGameRules[ruleType] = nil
	end

	self:RefreshDynamicUpdate()

	if self.exitInteractionType > 0 then
		gInteractionManager:SetCommonInteractEnd(self.exitInteractionType)
	end

	self.exitInteractionType = -1
end

function M:GetGameRule(ruleType)
	return self.mGameRules[ruleType]
end

function M:CheckGameRule()
	local lastRaidId = gRaidDataManager.LastRaidId
	local curRaidId = gRaidDataManager.RaidId

	for k, v in pairs(self.mGameRuleType2RaidId) do
		if table.contains(v, lastRaidId) then
			self:DestroyGameRule(k)
		end

		if table.contains(v, curRaidId) then
			self:CreateProcedureGameRule(k)
		end
	end

	if curRaidId ~= lastRaidId then
		-- Nothing
	end

	self:DestroyGameRule(self.GameRuleType.Galaxian)
	self:DestroyGameRule(self.GameRuleType.Universeeker)
end

function M:ClearAllRule()
	for k, v in pairs(self.mGameRules) do
		if v.Destroy then
			v:Destroy()
		end

		self.mGameRules[k] = nil
	end

	self:RefreshDynamicUpdate()
end

function M:RefreshDynamicUpdate()
	if table.isNilOrEmpty(self.mGameRules) then
		gLuaClient:UnregisterDynamicUpdate("gSceneGameRuleManager")
	else
		gLuaClient:RegisterDynamicUpdate("gSceneGameRuleManager", self)
	end
end

function M:OnUpdate()
	if gPauseManager.isBreak then
		return
	end

	self.mOverRules = {}

	for k, v in pairs(self.mGameRules) do
		if not v:Update() then
			table.insert(self.mOverRules, k)
		end
	end

	for i = #self.mOverRules, 1, -1 do
		local type = self.mOverRules[i]

		if self.mGameRules[type] then
			self.mGameRules[type]:Destroy()

			self.mGameRules[type] = nil
		end
	end

	if table.is_empty(self.mGameRules) then
		self:RefreshDynamicUpdate()
	end
end

M:OnInit()

gSceneGameRuleManager = M

return M
