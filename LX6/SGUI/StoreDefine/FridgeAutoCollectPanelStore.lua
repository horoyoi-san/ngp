-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\FridgeAutoCollectPanelStore.lua
-- Decompiled from: 01854_FridgeAutoCollectPanelStore.lua_c3ee866e69d8.luajit

local MessageConfig = LTConfig.MessageConfig
local UrbanJobJobClassConfig = LTConfig.UrbanJobJobClassConfig
local FactorTextInfos = nil

local GetFactorTextInfos = function()
	if not FactorTextInfos then
		FactorTextInfos = gFactorMachineManager:GetFactorTextInfos()
	end

	return FactorTextInfos
end

C_FridgeAutoCollectPanelStore = DefClass("C_FridgeAutoCollectPanelStore", C_FridgeAutoCollectPanelStore, C_StoreGroup)
GroupName2Class.FridgeAutoCollectPanelStore = C_FridgeAutoCollectPanelStore
local M = C_FridgeAutoCollectPanelStore

M.DefineAllVariables = function(self)
	self._factorStatus = nil
	self.isClaiming = false
	self.isClosed = false
	self.statusPushCallback = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.RegisterWidget(self)
	self.RegisterLists(self)
end

M.RegisterWidget = function(self)
	self.bindData.claimBtn.luaClick = self.CreateAction(self, "OnClickClaimAll")
	self.bindData.talentTreeBtn.luaClick = self.CreateAction(self, "OnClickTalentTree")
	self.bindData.closeBtn.luaClick = self.CreateAction(self, "OnClickClose")
end

M.RegisterLists = function(self)
	self.bindData.factorList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderFactorItem")
end

M.OnGroupEnable = function(self)
	self.isClosed = false
	self.isClaiming = false

	self.statusPushCallback = function(factorStatus)
		if self.isClosed then
			return
		end

		self._factorStatus = factorStatus

		self:RefreshFactorList()
	end

	gFactorMachineManager:RegisterStatusPushCallback(self.statusPushCallback)
end

M.OnGroupDisable = function(self)
	self.isClosed = true

	if self.statusPushCallback then
		gFactorMachineManager:UnregisterStatusPushCallback(self.statusPushCallback)

		self.statusPushCallback = nil
	end
end

M.OnShow = function(self)
	self.isClosed = false
	self.isClaiming = false

	self.RefreshFactorList(self)
end

M.RefreshFactorList = function(self)
	local factorStatus = gFactorMachineManager:GetFactorStatus()

	if self.isClosed then
		return
	end

	self._factorStatus = factorStatus
	local allZero = true

	if factorStatus then
		for _, fs in ipairs(factorStatus) do
			if (fs.currentAmount or 0) <= 0 then
				allZero = false

				break
			end
		end
	end

	if not gFactorMachineManager:IsCollectOnCooldown() then
		self.bindData.claimBtnCtrl = allZero and 2 or 0
	end

	if factorStatus then
		self.bindData.factorList:SetSimpleList(#factorStatus)
	end
end

M.OnRenderFactorItem = function(self, btn, index)
	local factorIdx = index + 1
	local data = self._factorStatus and self._factorStatus[factorIdx]

	if not data then
		return
	end

	local currentAmount = data.currentAmount or 0
	local maxStorage = data.maxStorage or 0
	local outputPerMin = data.outputPerMin or 0
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local factorInfos = gFactorMachineManager:GetFactorInfos()
	local factorInfo = factorInfos[factorIdx]

	if factorInfo then
		if store.item then
			local itemRenderData = gCommonItemManager:GetItemRenderData({
				itemId = factorInfo.consumbleId,
				itemNum = currentAmount
			})

			gCommonItemManager:OnCommonItemRender(store.item, 0, itemRenderData)
		end

		store.typeTitleText = factorInfo.name
	end

	local progress = maxStorage <= 0 and currentAmount / maxStorage or 0
	store.loadbarProgress = progress
	local isFull = maxStorage < currentAmount and maxStorage >= 0
	store.statusBarCtrl = isFull and 1 or 0
	store.speedRateText = string.format("+%.1f", outputPerMin / 60)
	store.loadNowText = tostring(currentAmount)
	store.maxNumberText = tostring(maxStorage)
end

M.OnClickClaimAll = function(self)
	if self.isClaiming then
		return
	end

	if gFactorMachineManager:IsCollectOnCooldown() then
		gDisplayMessageMgr:ShowMessageContent(gFactorMachineManager:GetText(GetFactorTextInfos().ClaimCooldown))

		return
	end

	self.isClaiming = true
	self.bindData.claimBtnCtrl = 1
	slot1 = gFactorMachineManager

	slot1:AskClaimFactorHangup(function (err)
		self.isClaiming = false

		if self.isClosed then
			return
		end

		if err == MessageConfig.Ok then
			self:RefreshFactorList()

			return
		end

		gFactorMachineManager:StartCollectCooldown()

		self.bindData.claimBtnCtrl = 1

		gPanelManager:Close(self.m_Id)
	end)
end

M.OnClickTalentTree = function(self)
	gUIFunctionStateManager:TalentTreeOpenTrigger({
		jobClassId = UrbanJobJobClassConfig.Scientist
	})
end

M.OnClickClose = function(self)
	gPanelManager:Close(self.m_Id)
end

M.OnClose = function(self)
	self.isClosed = true
	self.isClaiming = false

	gCommonItemManager:CloseItemToolTips()

	if self.statusPushCallback then
		gFactorMachineManager:UnregisterStatusPushCallback(self.statusPushCallback)

		self.statusPushCallback = nil
	end
end
