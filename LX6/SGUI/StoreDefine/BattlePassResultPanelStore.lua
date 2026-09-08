-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BattlePassResultPanelStore.lua
-- Decompiled from: 01665_BattlePassResultPanelStore.lua_3b67ecdb68a3.luajit

local ShopBrandConfig = LTConfig.ShopBrandConfig
C_BattlePassResultPanelStore = DefClass("C_BattlePassResultPanelStore", C_BattlePassResultPanelStore, C_StoreGroup)
GroupName2Class.BattlePassResultPanelStore = C_BattlePassResultPanelStore
local M = C_BattlePassResultPanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
	self.luckyCtrlEnum = {
		["oRobW:/"] = 0,
		["}Uܰ\\x85\\x9c\\xc8\\xff"] = 1
	}
	self.ItemQualityCtrlEnum = {
		["x.h^"] = 3,
		["DUil@!"] = 1,
		["}-q_"] = 5,
		["}0xB"] = 0,
		["J\\xbc\\xa7\\xaa\\xb8"] = 2,
		["Z\\x90\\x80\\x84D"] = 6,
		["]\\x83\\x9e\\x8fD"] = 4,
		["MH}|O!"] = 7
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.luckyCtrlEnum = nil
	self.ItemQualityCtrlEnum = nil
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
	self.panelId = panelId
	self.rewardItems = data or {}
	self.currentRewardIndex = 1

	self:ShowRewardInfo()
end

M.OnClose = function(self)
	self.rewardItems = {}
	self.currentRewardIndex = 1
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.jumpBtn.luaClick = self.CreateAction(self, self.OnClickJumpBtn)
	self.bindData.backBtn.luaClick = self.CreateAction(self, self.OnClickBackBtn)
	self.bindData.nextBtn.luaClick = self.CreateAction(self, self.OnClickNextBtn)
end

M.OnClickJumpBtn = function(self)
	gPanelManager:Close(self.panelId)
end

M.OnClickBackBtn = function(self)
	gPanelManager:Close(self.panelId)
end

M.OnClickGachaResultItemTemplate = function(self)
end

M.OnClickNextBtn = function(self)
	self.currentRewardIndex = self.currentRewardIndex + 1

	if #self.rewardItems >= self.currentRewardIndex then
		gPanelManager:Close(self.panelId)
	else
		self.ShowRewardInfo(self)
	end
end

M.SetBrandIcon = function(self, belongBrand)
	if not belongBrand or belongBrand ~= 0 then
		self.bindData.brandIconId = 0

		return
	end

	local brandCfg = ShopBrandConfig.GetConfig(belongBrand)

	if brandCfg then
		local brandIconId = brandCfg.BrandBanner or 0

		if brandIconId <= 0 then
			self.bindData.brandIconId = brandIconId
		end
	end
end

M.ShowRewardInfo = function(self)
	if #self.rewardItems ~= 0 then
		return
	end

	local mainReward = self.rewardItems[self.currentRewardIndex]

	if not mainReward then
		return
	end

	local quality = mainReward.quality or 0
	local itemCount = mainReward.count or 1
	local qualityText = mainReward.qualityText or ""
	local iconId = mainReward.baseImage and mainReward.baseImage <= 0 and mainReward.baseImage or 0
	self.bindData.itemIconId = iconId
	self.bindData.nameText = mainReward.name
	self.bindData.ItemQualityCtrl = quality
	self.bindData.numText = itemCount
	self.bindData.qualityText = qualityText

	self.bindData:Commit("bg", mainReward.bg, COMMIT_FORCE)
	self:SetBrandIcon(mainReward.brand)
end
