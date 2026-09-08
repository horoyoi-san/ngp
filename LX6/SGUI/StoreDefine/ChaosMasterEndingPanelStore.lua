-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ChaosMasterEndingPanelStore.lua
-- Decompiled from: 01469_ChaosMasterEndingPanelStore.lua_8514275f7b92.luajit

C_ChaosMasterEndingPanelStore = DefClass("C_ChaosMasterEndingPanelStore", C_ChaosMasterEndingPanelStore, C_StoreGroup)
GroupName2Class.ChaosMasterEndingPanelStore = C_ChaosMasterEndingPanelStore
local M = C_ChaosMasterEndingPanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
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
	self.rewardInfo = data.rewardInfo
	self.bindData.typeCtrl = gBattlePetsMgr.bvbOnlineType ~= gBattlePetsMgr.BVBOnlineType.Single and 1 or 0
	self.bindData.showRewardCtrl = data.resultType ~= UX.Game.BVBEndType.Win and 0 or 1
	self.bindData.rank = data.resultType ~= UX.Game.BVBEndType.Win and 1 or 2
	self.bindData.winCtrl = data.resultType ~= UX.Game.BVBEndType.Win and 0 or 1

	self:RefreshRewardList()
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.exitBtn.luaClick = self.CreateAction(self, "OnClickExitBtn")
	self.bindData.restartBtn.luaClick = self.CreateAction(self, "OnClickRestartBtn")
	self.bindData.playAgainBtn.luaClick = self.CreateAction(self, "OnClickPlayAgainBtn")
	self.bindData.rewardLessThan7List.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderRewardListItem)
end

M.OnClickExitBtn = function(self)
	self.Close(self)
end

M.OnClickRestartBtn = function(self)
	gPanelManager:CheckShow(gPanelId.CHAOS_EDIT_TEAM_FULLSCREEN, {
		["\\xa2\\xa27\\xaez2\\xff*"] = true
	})
	self:Close(true)
end

M.OnClickPlayAgainBtn = function(self)
	self.Close(self)
end

M.OnRenderRewardListItem = function(self, btn, index)
	local itemData = self.itemList[index + 1]

	if not itemData then
		return
	end

	gCommonItemManager:OnCommonItemRender(btn, index, itemData)
end

M.RefreshRewardList = function(self)
	if not self.rewardInfo then
		return
	end

	local popupParam = gItemUtils:ConvertRewardDetail(self.rewardInfo)
	self.itemList = gCommonItemManager:GetSingleSortedListRenderDataByList(popupParam.Rewards)

	self.bindData.rewardLessThan7List:SetSimpleList(#self.itemList)
end

M.Close = function(self, isReplay)
	isReplay = isReplay or false

	gLuaTimeMgrUtils.NotDestroyDelay(function ()
		gBattlePetsMgr:DisableCamera()
	end, 1)
	gPanelManager:Close(gPanelId.CHAOS_MASTER_ENDING_PANEL)

	if not isReplay then
		slot2 = gClientToGameSceneDelegate

		slot2:AskPlayerOnBVBFinish(false).Callback = function (err)
			if err == LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)
			end
		end
	end
end
