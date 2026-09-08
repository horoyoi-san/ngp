-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\Utils\BigMapComps\BigMapComp_WuxueOverride.lua
-- Decompiled from: 01035_BigMapComp_WuxueOverride.lua_aff0ebb7878d.luajit

BigMapComp_WuxueOverride = BigMapComp_WuxueOverride or {}
local M = BigMapComp_WuxueOverride
M.__index = M

M.OnInit = function(self)
	self.bindData.wuxueTab.OnRenderTab = self.bigMap:CreateAction("OnRenderWuxueTab", self)
	self.allFightSkills = {}
	self.allFightSkillsNum = 0
	self.activeFightSkills = {}
end

M.OnActive = function(self)
	self.bigMap:SetViewMask(EMapViewMask.WuxueMap)

	self.bindData.wuxueTab.selectedIndex = 0
	self.allFightSkills = {}
	self.allFightSkillsNum = 0

	for i = 0, LTConfig.WuxueMapConfig.count - 1 do
		local cfg = LTConfig.WuxueMapConfig.LoadAt(i)

		if cfg and cfg.FightSkill then
			self.allFightSkills[cfg.FightSkill] = true
			self.allFightSkillsNum = self.allFightSkillsNum + 1
		end
	end
end

M.OnInactive = function(self)
	self.allFightSkills = {}
	self.allFightSkillsNum = 0

	self:RefreshTab()
end

M.RefreshTab = function(self)
	if self.actived then
		if self.bindData.wuxueTab.selectedIndex == 0 then
			self.bindData.wuxueTab.selectedIndex = 0
		end

		if self.tabStore and self.widget then
			self:RefreshContent()
		end
	else
		self.tabStore = nil
		self.widget = nil
		self.bindData.wuxueTab.selectedIndex = -1

		self.bindData.wuxueTab:ClearUnusedTabInstances()
	end
end

M.OnRenderWuxueTab = function(self, index, widget)
	self.widget = widget
	self.tabStore = gStoreManager:GetStoreGroup("BigMapComp_WuxueOverride"):GetStoreByWidget(widget)

	self:RefreshTab()
end

M.RefreshContent = function(self)
	local spiritTid = gSpiritManager:GetCurFirstSpiritTid()
	local currentJob, jobCfg = gSpiritJobManager:GetAvailableJobByClass(LTConfig.UrbanJobJobClassConfig.Wuxue)
	local r1, r2 = gSpiritJobManager:GetLevelData(jobCfg, spiritTid)
	local levelCfg = r1
	local levelData = r2
	self.tabStore.levelText = string.format("Lv.%d", levelData and levelData.Level or 0)
	self.tabStore.expProgressBar.maxValue = levelCfg.Exp or 100
	self.tabStore.expProgressBar.value = levelData.Exp or 0

	self.tabStore.clueBtn.luaClick = function()
		gPanelManager:CheckShow(gPanelId.MA_CLUE_BAG)
	end

	local skills = gCS.FightStyleManager.Instance:GetAllUnlockedFightStyles()
	self.activeFightSkills = {}

	if skills then
		for i = 0, skills.Length - 1 do
			local skill = skills[i]

			if self.allFightSkills[skill] then
				table.insert(self.activeFightSkills, skill)
			end
		end
	end

	self.tabStore.collectProgressText = string.format("%d/%d", #self.activeFightSkills, self.allFightSkillsNum)
end
