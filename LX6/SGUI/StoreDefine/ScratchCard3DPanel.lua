-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ScratchCard3DPanel.lua
-- Decompiled from: 00870_ScratchCard3DPanel.lua_f68a493f1c56.luajit

C_ScratchCard3DPanel = DefClass("C_ScratchCard3DPanel", C_ScratchCard3DPanel, C_StoreGroup)
GroupName2Class.ScratchCard3DPanel = C_ScratchCard3DPanel
local M = C_ScratchCard3DPanel

M.ctor = function(self)
	self.maxRewardIndex = 2
	self.waitHideUITime = 3
	self.GameplayStartOutWardSignal = 3300
	self.GameplayEndInwardSignal = 10003
end

M.OnAwake = function(self)
	self.bindData.tabRect.OnRenderTab = self.CreateAction(self, "OnRenderTab")

	self.InitMessages(self)
end

M.InitMessages = function(self)
	self.RegisterMessageEvents(self, {
		[gEventConstants.ON_SHOW_SCRATCH_CARD_RESULT] = self.CreateAction(self, "ShowResultView"),
		[gEventConstants.ON_SCRATCH_CARD_GAME_LOSE] = self.CreateAction(self, "ShowLoseView"),
		[gEventConstants.COMMON_GAMEPLAY_OUTWARD_SIGNAL] = self.CreateAction(self, "SignalHandler")
	})
end

M.OnShow = function(self, _, args)
	self.InitModel(self, args)
	self.InitView(self, args)
	self.InitPos(self, args)
end

M.InitPos = function(self, args)
	local uiPivot = args.uiPivot
	self.rootGo.transform.position = uiPivot.position
	self.rootGo.transform.rotation = uiPivot.rotation
	self.rootGo.transform.localScale = uiPivot.localScale
end

M.InitModel = function(self, args)
	self.args = args
	local entity = self.args[3]
	self.entityInstanceId = entity.entityInstanceId
end

M.InitView = function(self, args)
	local gamePlayId = args.gamePlayId
	local selectedIndex = gamePlayId - 1
	self.bindData.tabRect.selectedIndex = -1
	self.bindData.tabRect.selectedIndex = selectedIndex

	gPanelManager:CheckShow(gPanelId.SCRATCHCARD2D_PANEL, {
		gamePlayId = gamePlayId
	})
end

M.OnExitClick = function(self)
	gPanelManager:Close(gPanelId.SCRATCHCARD2D_PANEL)
	gPanelManager:Close(self.m_Id)
end

M.OnRenderTab = function(self, _, widget)
	local store = gStoreManager:GetStoreGroup(widget.Store)

	store:ShowPanel(self.args)
end

M.ShowResultView = function(self, _, args)
	local rewardTipsControl = args.rewardTipsControl

	if self.maxRewardIndex >= rewardTipsControl then
		rewardTipsControl = self.maxRewardIndex
	end

	local sellerDialogId, playerDialogId = self:GetDialogIdByReward(rewardTipsControl)

	gDialogManager:ShowGeneralDialog(sellerDialogId, gDialogSource.ScratchCard, nil, , function (_, _, state, nextDialogId)
		if state ~= 2 or nextDialogId == 0 then
			return
		end

		gDialogManager:ShowGeneralDialog(playerDialogId, gDialogSource.ScratchCard)
		gCS.LogicStateMachineManager.SendGameplayInwardSignal(gCS.MyPlayerManager.PlayerUnit, self.GameplayEndInwardSignal, rewardTipsControl)
		gPanelManager:Close(gPanelId.SCRATCHCARD_PANEL)
		gPanelManager:Close(gPanelId.SCRATCHCARD2D_PANEL)
	end)
	self:AskFinishScratchGame(args.totalReward)
end

M.ShowLoseView = function(self)
	self:AskLoseScratchGame()

	self.waitTimer = Timer.New(function ()
		self.waitTimer = nil

		gCS.LogicStateMachineManager.SendGameplayInwardSignal(gCS.MyPlayerManager.PlayerUnit, self.GameplayEndInwardSignal, 0)
		gPanelManager:Close(gPanelId.SCRATCHCARD_PANEL)
		gPanelManager:Close(gPanelId.SCRATCHCARD2D_PANEL)
	end, 2):Start()
end

M.AskFinishScratchGame = function(self, totalReward)
	slot2 = gClientToGameSceneDelegate

	slot2:AskFinishScratchGame(self.entityInstanceId, totalReward).Callback = function (errorId)
		if errorId == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end
	end
end

M.AskLoseScratchGame = function(self)
	slot1 = gClientToGameSceneDelegate

	slot1:AskLoseScratchGame(self.entityInstanceId).Callback = function (errorId)
		if errorId == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end
	end
end

M.GetDialogIdByReward = function(self, rewardTipsControl)
	local rewardConfig = {
		[0] = {
			seller = LTConfig.PoiGameConfig.Scratch_Dialog_Bad_Seller,
			player = LTConfig.PoiGameConfig.Scratch_Dialog_Bad_Player
		},
		{
			seller = LTConfig.PoiGameConfig.Scratch_Dialog_Soso_Seller,
			player = LTConfig.PoiGameConfig.Scratch_Dialog_Soso_Player
		},
		{
			seller = LTConfig.PoiGameConfig.Scratch_Dialog_Good_Seller,
			player = LTConfig.PoiGameConfig.Scratch_Dialog_Good_Player
		}
	}
	local rewards = rewardConfig[rewardTipsControl]
	local sellerRewardDialogId = rewards.seller[math.random(1, #rewards.seller)]
	local playerRewardDialogId = rewards.player[math.random(1, #rewards.player)]

	return sellerRewardDialogId, playerRewardDialogId
end

M.SignalHandler = function(self, _, data)
	local signalId = data.GetCfgId(data)

	if signalId ~= self.GameplayStartOutWardSignal then
		gCS.AnimationManager.SetAnimatorParams(gCS.MyPlayerManager.PlayerUnit, 1, -1, 0)
	end
end

M.OnClose = function(self)
	if self.waitTimer then
		self.waitTimer:Stop()

		self.waitTimer = nil
	end
end

M.OnDestroy = function(self)
	gCS.LuaUtils.SetPanelCursor(nil)
	self.ClearMessageEvents(self)
end
