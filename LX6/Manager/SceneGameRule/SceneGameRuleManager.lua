-- Original chunk: @Lua\LuaFiles\LX6\Manager\SceneGameRule\SceneGameRuleManager.lua
-- Decompiled from: 00522_SceneGameRuleManager.lua_072ca571077d.luajit

local M = {}

M.OnInit = function(self)
	self.mGameRules = {}
	self.mOverRules = {}
	self.GameRuleType = {
		["\\x8c\\xb0\t\\xaar7\\xff="] = 1,
		["Zx\\xa5aI\\xa0\\xe1Boq{^"] = 2
	}
	self.mGameRuleType2RaidId = {}
	self.exitInteractionType = -1
end

M.OnBeforeSwitchScene = function(self, switchType)
	if switchType ~= gSwitchSceneType.KickToLogin then
		self.ClearAllRule(self)
	end

	if switchType ~= gSwitchSceneType.Reconnect then
		return
	end

	gSceneGameRuleManager:CheckGameRule()
end

M.CreateProcedureGameRule = function(self, ruleType, exitExitInteractionType)
	if ruleType ~= self.GameRuleType.Galaxian then
		local GalaxianGameRule = require("LX6/Manager/SceneGameRule/ArcadeGalaxianGameRule")
		self.mGameRules[ruleType] = GalaxianGameRule.new()
	end

	self.exitInteractionType = exitExitInteractionType or -1

	self:RefreshDynamicUpdate()
end

M.DestroyGameRule = function(self, ruleType)
	if self.mGameRules[ruleType] and self.mGameRules[ruleType].Destroy then
		self.mGameRules[ruleType]:Destroy()

		self.mGameRules[ruleType] = nil
	end

	self.RefreshDynamicUpdate(self)

	if self.exitInteractionType <= 0 then
		gInteractionManager:SetCommonInteractEnd(self.exitInteractionType)
	end

	self.exitInteractionType = -1
end

M.GetGameRule = function(self, ruleType)
	return self.mGameRules[ruleType]
end

M.CheckGameRule = function(self)
	local lastRaidId = gRaidDataManager.LastRaidId
	local curRaidId = gRaidDataManager.RaidId

	for k, v in pairs(self.mGameRuleType2RaidId) do
		if table.contains(v, lastRaidId) then
			self.DestroyGameRule(self, k)
		end

		if table.contains(v, curRaidId) then
			self.CreateProcedureGameRule(self, k)
		end
	end

	if curRaidId == lastRaidId then
		-- Nothing
	end

	self.DestroyGameRule(self, self.GameRuleType.Galaxian)
	self.DestroyGameRule(self, self.GameRuleType.Universeeker)
end

M.ClearAllRule = function(self)
	for k, v in pairs(self.mGameRules) do
		if v.Destroy then
			v.Destroy(v)
		end

		self.mGameRules[k] = nil
	end

	self.RefreshDynamicUpdate(self)
end

M.RefreshDynamicUpdate = function(self)
	if table.isNilOrEmpty(self.mGameRules) then
		gLuaClient:UnregisterDynamicUpdate("gSceneGameRuleManager")
	else
		gLuaClient:RegisterDynamicUpdate("gSceneGameRuleManager", self)
	end
end

M.OnUpdate = function(self)
	if gPauseManager.isBreak then
		return
	end

	self.mOverRules = {}

	for k, v in pairs(self.mGameRules) do
		if not v.Update(v) then
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
		self.RefreshDynamicUpdate(self)
	end
end

M.OnInit(M)

gSceneGameRuleManager = M

return M
