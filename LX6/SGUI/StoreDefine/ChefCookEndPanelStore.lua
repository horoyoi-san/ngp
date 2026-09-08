-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ChefCookEndPanelStore.lua
-- Decompiled from: 01449_ChefCookEndPanelStore.lua_d763eca80d0f.luajit

C_ChefCookEndPanelStore = DefClass("C_ChefCookEndPanelStore", C_ChefCookEndPanelStore, C_StoreGroup)
GroupName2Class.ChefCookEndPanelStore = C_ChefCookEndPanelStore
local M = C_ChefCookEndPanelStore
local ChefRankConfig = LTConfig.ChefRankConfig

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
	self.rankCtrlEnum = {
		["\\xec"] = 1,
		["\\xee"] = 3,
		["\\xe9"] = 4,
		["\\xfe"] = 0,
		["\\xef"] = 2
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.rankCtrlEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	self.InitContent(self, data)
end

M.OnClose = function(self)
	self.listData = nil
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.continueBtn.luaClick = self.CreateAction(self, self.OnClickContinueBtn)
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderListItem)
end

M.OnClickContinueBtn = function(self)
	L50.Gameplay.ChefGame.ChefManager.StopCookTimeline()
end

M.OnSimpleRenderListItem = function(self, btn, index)
	local data = self.listData[index + 1]

	if not data then
		return
	end

	local store = self.GetStoreByWidget(self, btn)

	if not store then
		return
	end

	store.title = data.title
	store.score = data.score
end

M.InitContent = function(self, game)
	if game.IsOvercookFailed then
		return
	end

	local scoreInfo = game.DishScoreInfo
	self.listData = {}
	local finalScore = math.floor(scoreInfo.FinalScore * 100 + 0.5)

	table.insert(self.listData, {
		title = LTConfig.TextScriptTextConfig.GetConfig(89901483).Text,
		score = string.format("%d", finalScore)
	})

	local finalRankCfg = nil
	local score = 0

	for i = 1, ChefRankConfig.count do
		local rankCfg = ChefRankConfig.LoadAt(i - 1)

		if score < rankCfg.RatePoint and rankCfg.RatePoint < finalScore then
			score = rankCfg.RatePoint
			finalRankCfg = rankCfg
		end
	end

	if finalRankCfg then
		if finalRankCfg.RankType ~= ChefRankConfig.RankTypeType.S then
			self.bindData.rankCtrl = self.rankCtrlEnum.S
		elseif finalRankCfg.RankType ~= ChefRankConfig.RankTypeType.A then
			self.bindData.rankCtrl = self.rankCtrlEnum.A
		elseif finalRankCfg.RankType ~= ChefRankConfig.RankTypeType.B then
			self.bindData.rankCtrl = self.rankCtrlEnum.B
		elseif finalRankCfg.RankType ~= ChefRankConfig.RankTypeType.C then
			self.bindData.rankCtrl = self.rankCtrlEnum.C
		end
	end

	if scoreInfo.RecipeId and scoreInfo.RecipeId <= 0 then
		local recipeConfig = LTConfig.ChefRecipeConfig.GetConfig(scoreInfo.RecipeId)
		self.bindData.name = recipeConfig and recipeConfig.RecipeName
	end

	self.bindData.list:SetSimpleList(#self.listData)

	local recipeId = game:GetCurrentRecipeId()
	local unlockInfo = gPlayerManager.infoMinor.bindData.ChefUnlockInfo.SubRecipeDict[recipeId]
	local mask = self.SubGroup.ChefRadar:GenerateHideMask(recipeId, unlockInfo and unlockInfo.UnlockedDimensions or {})

	self.SubGroup.ChefRadar:InitCompareMode(recipeId, mask)

	local Smell = game:GetDimensionValue(UX.Game.ChefFlavorDimension.Smell)
	local Salt = game:GetDimensionValue(UX.Game.ChefFlavorDimension.Salt)
	local Sweet = game:GetDimensionValue(UX.Game.ChefFlavorDimension.Sweet)
	local Sour = game:GetDimensionValue(UX.Game.ChefFlavorDimension.Sour)
	local Umami = game:GetDimensionValue(UX.Game.ChefFlavorDimension.Umami)
	local Spicy = game:GetDimensionValue(UX.Game.ChefFlavorDimension.Spicy)

	self.SubGroup.ChefRadar:SetRadarValue(Smell, Salt, Sweet, Sour, Umami, Spicy)
end
