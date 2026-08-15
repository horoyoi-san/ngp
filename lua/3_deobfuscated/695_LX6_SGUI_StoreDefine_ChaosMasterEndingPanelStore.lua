C_ChaosMasterEndingPanelStore = DefClass("C_ChaosMasterEndingPanelStore", C_ChaosMasterEndingPanelStore, C_StoreGroup)
GroupName2Class.ChaosMasterEndingPanelStore = C_ChaosMasterEndingPanelStore
local M = C_ChaosMasterEndingPanelStore

function M:ctor()
	return
end

function M:DefineAllVariables()
	return
end

function M:OnAwake()
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()
end

function M:OnEnable()
	return
end

function M:OnStart()
	return
end

function M:OnDisable()
	return
end

function M:OnDestroy()
	return
end

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	return
end

function M:OnShow(panelId, data)
	self.rewardInfo = data.rewardInfo
	self.bindData.typeCtrl = gBattlePetsMgr.bvbOnlineType == gBattlePetsMgr.BVBOnlineType.Single and 1 or 0
	self.bindData.showRewardCtrl = data.resultType == UX.Game.BVBEndType.Win and 0 or 1
	self.bindData.rank = data.resultType == UX.Game.BVBEndType.Win and 1 or 2
	self.bindData.winCtrl = data.resultType == UX.Game.BVBEndType.Win and 0 or 1

	self:RefreshRewardList()
end

function M:OnClose()
	return
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end

function M:GenMessageEvents()
	return
end

function M:RegisterWidget()
	self.bindData.exitBtn.luaClick = self:CreateAction("OnClickExitBtn")
	self.bindData.restartBtn.luaClick = self:CreateAction("OnClickRestartBtn")
	self.bindData.playAgainBtn.luaClick = self:CreateAction("OnClickPlayAgainBtn")
	self.bindData.rewardLessThan7List.luaSimpleRenderItem = self:CreateAction(self.OnRenderRewardListItem)
end

function M:OnClickExitBtn()
	self:Close()
end

function M:OnClickRestartBtn()
	gPanelManager:CheckShow(gPanelId.CHAOS_EDIT_TEAM_FULLSCREEN, {
		isReplay = true
	})
	self:Close(true)
end

function M:OnClickPlayAgainBtn()
	self:Close()
end

function M:OnRenderRewardListItem(btn, index)
	local itemData = self.itemList[index + 1]

	if not itemData then
		return
	end

	gCommonItemManager:OnCommonItemRender(btn, index, itemData)
end

function M:RefreshRewardList()
	if not self.rewardInfo then
		return
	end

	local popupParam = gItemUtils:ConvertRewardDetail(self.rewardInfo)
	self.itemList = gCommonItemManager:GetSingleSortedListRenderDataByList(popupParam.Rewards)

	self.bindData.rewardLessThan7List:SetSimpleList(#self.itemList)
end

function M:Close(isReplay)
	isReplay = isReplay or false

	gLuaTimeMgrUtils.NotDestroyDelay(function ()
		gBattlePetsMgr:DisableCamera()
	end, 1)
	gPanelManager:Close(gPanelId.CHAOS_MASTER_ENDING_PANEL)

	if not isReplay then
		gClientToGameSceneDelegate:AskPlayerOnBVBFinish(false).Callback = function (err)
			if err ~= LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)
			end
		end
	end
end
