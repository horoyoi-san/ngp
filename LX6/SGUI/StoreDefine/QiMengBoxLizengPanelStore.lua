-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\QiMengBoxLizengPanelStore.lua
-- Decompiled from: 00841_QiMengBoxLizengPanelStore.lua_fb133e9055ba.luajit

local GachaConfig = LTConfig.GachaConfig
local MessageConfig = LTConfig.MessageConfig
local TextConfig = LTConfig.TextConfig
C_QiMengBoxLizengPanelStore = DefClass("C_QiMengBoxLizengPanelStore", C_QiMengBoxLizengPanelStore, C_StoreGroup)
GroupName2Class.QiMengBoxLizengPanelStore = C_QiMengBoxLizengPanelStore
local M = C_QiMengBoxLizengPanelStore

M.ctor = function(self)
	self.gachaId = 0
	self.gachaCfg = nil
	self.milestoneList = {}
	self.rewardDataList = {}
	self._closingAnim = false
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
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
	self.gachaId = 0
	self.gachaCfg = nil
	self.milestoneList = {}
	self.rewardDataList = {}
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	if not data or not data.gachaId then
		print_error("QiMengBoxLizengPanelStore:OnShow - 缺少 gachaId 参数")

		return
	end

	self.gachaId = data.gachaId
	self.gachaCfg = GachaConfig.GetConfig(self.gachaId)

	if not self.gachaCfg then
		print_error("QiMengBoxLizengPanelStore:OnShow - 找不到卡池配置，gachaId=", self.gachaId)

		return
	end

	self:ParseMilestones()

	local titleTextCfg = TextConfig.GetConfig(73977004)
	self.bindData.titleText = string.format(titleTextCfg.Text, self.gachaCfg.Name or "")
	local currentDrawCount = self:GetCurrentDrawCount()
	local timesTextCfg = TextConfig.GetConfig(73977005)
	self.bindData.timesText = string.format(timesTextCfg.Text, currentDrawCount)

	self:UpdateRewardList()
end

M.OnClose = function(self)
	self.gachaId = 0
	self.gachaCfg = nil
	self.milestoneList = {}
	self.rewardDataList = {}
	self._closingAnim = false
end

M.OnActiveDeviceChange = function(self, device)
end

M.ParseMilestones = function(self)
	self.milestoneList = {}

	if not self.gachaCfg or not self.gachaCfg.Milestone then
		return
	end

	local milestones = self.gachaCfg.Milestone

	if not milestones or #milestones ~= 0 then
		return
	end

	for i = 1, #milestones do
		local milestone = milestones[i]

		if milestone and milestone.count and milestone.dropId then
			table.insert(self.milestoneList, {
				count = milestone.count,
				dropId = milestone.dropId
			})
		end
	end
end

M.GetCurrentDrawCount = function(self)
	if not self.gachaCfg then
		return 0
	end

	local prizePoolIds = self.gachaCfg.PrizePoolIds

	if not prizePoolIds or #prizePoolIds ~= 0 then
		return 0
	end

	local poolId = prizePoolIds[1].id
	local currentDrawCount = 0
	local playerGachaInfo = gPlayerManager.infoMinor.bindData.PlayerGachaInfos

	if playerGachaInfo and playerGachaInfo.PoolInfos then
		local poolInfo = playerGachaInfo.PoolInfos[poolId]

		if poolInfo then
			currentDrawCount = poolInfo.DrawCount or 0
		end
	end

	return currentDrawCount
end

M.GetClaimedMilestones = function(self)
	local playerGachaInfo = gPlayerManager.infoMinor.bindData.PlayerGachaInfos

	if playerGachaInfo and playerGachaInfo.GroupInfos then
		local groupInfo = playerGachaInfo.GroupInfos[self.gachaId]

		if groupInfo and groupInfo.ClaimedMilestoneCounts then
			return groupInfo.ClaimedMilestoneCounts
		end
	end

	return {}
end

M.UpdateRewardList = function(self)
	self.rewardDataList = {}
	local currentDrawCount = self.GetCurrentDrawCount(self)
	local claimedMap = self.GetClaimedMilestones(self)

	for i = 1, #self.milestoneList do
		local milestone = self.milestoneList[i]
		local isClaimed = claimedMap[milestone.count] or false
		local isClaimable = not isClaimed and milestone.count > currentDrawCount
		local itemList, randomList = gCommonItemManager:ConvertDropToFakeItem(milestone.dropId, 1)
		local renderData = nil

		if itemList and #itemList <= 0 and itemList[1] then
			local item = itemList[1]
			renderData = gCommonItemManager:GetItemRenderData({
				itemId = item.Id,
				itemNum = item.Count or 1
			})
		end

		local rewardData = {
			index = i,
			count = milestone.count,
			dropId = milestone.dropId,
			isClaimed = isClaimed,
			isClaimable = isClaimable,
			renderData = renderData,
			currentDrawCount = currentDrawCount
		}

		table.insert(self.rewardDataList, rewardData)
	end

	self.bindData.rewardList:SetSimpleList(#self.rewardDataList)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.GACHA_POOL_COUNT_CHANGE] = self.CreateAction(self, "OnGachaPoolCountChange")
	}
end

M.OnGachaPoolCountChange = function(self)
	self.UpdateRewardList(self)
end

M.RegisterWidget = function(self)
	self.bindData.backBtn.luaClick = self.CreateAction(self, "OnClickBackBtn")
	self.bindData.rewardList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderRewardListItem")
	self.bindData.rewardList.luaSimpleClick = self.CreateAction(self, "OnSimpleClickRewardList")
	self.bindData.rewardList.luaSelectedChanged = self.CreateAction(self, "OnSelectedChangedRewardList")
end

M.OnClickBackBtn = function(self)
	if gCommonItemManager.itemToolTipRefBtn then
		SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.rootGo:GetComponent("UNavigationArea")

		gCommonItemManager:CloseItemToolTips()

		return
	end

	if self._closingAnim then
		return
	end

	self._closingAnim = true

	gUIUtils:PlayAniClosePanel(self.bindData.anim, "S_QiMengBoxLizeng_close", self.m_Id)
end

M.OnSimpleRenderRewardListItem = function(self, btn, index)
	local luaIndex = index + 1
	local data = self.rewardDataList[luaIndex]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.numText = data.count
	store.otherText = TextConfig.GetConfig(73977018).Text

	if data.renderData and store.rewardItem then
		local itemStore = gCommonItemManager:OnCommonItemRender(store.rewardItem, index, data.renderData)

		if data.isClaimed then
			store.Commit(store, "vx_complateCtrl", 0, COMMIT_FORCE)

			itemStore.isOwned = 1
			itemStore.available = 0
		elseif data.isClaimable then
			store.Commit(store, "vx_complateCtrl", 1, COMMIT_FORCE)

			itemStore.available = 1
			itemStore.isOwned = 0
		else
			store.Commit(store, "vx_complateCtrl", 0, COMMIT_FORCE)

			itemStore.available = 0
			itemStore.isOwned = 0
		end

		store.getBtn.luaClick = function()
			self:ClaimMilestone(data.count)
		end

		if store.rewardItem then
			store.rewardItem.luaRenderTooltip = self:CreateActionWithArgs("OnRenderRewardItemTooltip", data.renderData)
			store.rewardItem.luaTooltipPopup = gCommonItemManager:CreateAction("OnToolTipsClose")
		end
	end

	if data.isClaimed then
		store.getBtn.interactable = false
	elseif data.isClaimable then
		store.getBtn.interactable = true
	else
		store.getBtn.interactable = false
	end
end

M.OnSimpleClickRewardList = function(self, btn, index)
	local luaIndex = index + 1
	local data = self.rewardDataList[luaIndex]

	if not data then
		return
	end

	if data.isClaimable then
		self.ClaimMilestone(self, data.count)
	end
end

M.OnSelectedChangedRewardList = function(self)
	if gCommonItemManager.itemToolTipRefBtn then
		SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.rootGo:GetComponent("UNavigationArea")

		gCommonItemManager:CloseItemToolTips()

		return
	end
end

M.ClaimMilestone = function(self, milestoneCount)
	if not self.gachaCfg then
		return
	end

	local milestoneData = nil

	for i = 1, #self.milestoneList do
		if self.milestoneList[i].count ~= milestoneCount then
			milestoneData = self.milestoneList[i]

			break
		end
	end

	slot3 = gClientToGameDelegate

	slot3:AskClaimGachaMilestone(self.gachaId, milestoneCount).Callback = function (err)
		if err ~= MessageConfig.Ok then
			local playerGachaInfo = gPlayerManager.infoMinor.bindData.PlayerGachaInfos

			if not playerGachaInfo.GroupInfos then
				playerGachaInfo.GroupInfos = {}
			end

			if not playerGachaInfo.GroupInfos[self.gachaId] then
				playerGachaInfo.GroupInfos[self.gachaId] = {}
			end

			if not playerGachaInfo.GroupInfos[self.gachaId].ClaimedMilestoneCounts then
				playerGachaInfo.GroupInfos[self.gachaId].ClaimedMilestoneCounts = {}
			end

			playerGachaInfo.GroupInfos[self.gachaId].ClaimedMilestoneCounts[milestoneCount] = true

			self:UpdateRewardList()

			if gEventConstants.GACHA_MILESTONE_CLAIMED then
				gMessageManager:SendMessage(gEventConstants.GACHA_MILESTONE_CLAIMED)
			end

			if milestoneData and milestoneData.dropId and milestoneData.dropId <= 0 then
				local fakeItems = gCommonItemManager:ConvertDropToFakeItem(milestoneData.dropId, 1)
				local previewMaterials = {}

				for _, item in ipairs(fakeItems) do
					table.insert(previewMaterials, {
						ItemId = item.Id,
						Count = item.Count
					})
				end

				if #previewMaterials <= 0 then
					gDropManager:ShowRewardWindow({
						["B\\x8e\\x82\\xbe\\xee\\xb5\\xd2:\\xbb;=\\xb37"] = 2,
						Param = previewMaterials
					})
				end
			end
		else
			gDisplayMessageMgr:DisplayServerMessageId(err)
		end
	end
end

M.OnRenderRewardItemTooltip = function(self, renderData, btn, popup, index)
	if not renderData or not renderData.itemId or renderData.itemId < 0 then
		return
	end

	local data = {
		itemId = renderData.itemId
	}

	gCommonItemManager:OnRenderToolTips(data, btn, popup, index)
end
