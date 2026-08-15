C_ScratchCard3DPanel = DefClass("C_ScratchCard3DPanel", C_ScratchCard3DPanel, C_StoreGroup)
GroupName2Class.ScratchCard3DPanel = C_ScratchCard3DPanel
local M = C_ScratchCard3DPanel

function M:ctor()
	self.maxRewardIndex = 2
	self.waitHideUITime = 3
	self.GameplayStartOutWardSignal = 3300
	self.GameplayEndInwardSignal = 10003
end

function M:OnAwake()
	self.bindData.tabRect.OnRenderTab = self:CreateAction("OnRenderTab")

	self:InitMessages()
end

function M:InitMessages()
	self:RegisterMessageEvents({
		[gEventConstants.ON_SHOW_SCRATCH_CARD_RESULT] = self:CreateAction("ShowResultView"),
		[gEventConstants.COMMON_GAMEPLAY_OUTWARD_SIGNAL] = self:CreateAction("SignalHandler")
	})
end

function M:OnShow(_, args)
	self:InitModel(args)
	self:InitView(args)
	self:InitPos(args)
end

function M:InitPos(args)
	local uiPivot = args.uiPivot
	self.rootGo.transform.position = uiPivot.position
	self.rootGo.transform.rotation = uiPivot.rotation
	self.rootGo.transform.localScale = uiPivot.localScale
end

function M:InitModel(args)
	self.args = args
end

function M:InitView(args)
	local gamePlayId = args.gamePlayId
	local selectedIndex = gamePlayId - 1
	self.bindData.tabRect.selectedIndex = selectedIndex

	gPanelManager:CheckShow(gPanelId.SCRATCHCARD2D_PANEL, {
		gamePlayId = gamePlayId
	})
end

function M:OnExitClick()
	gPanelManager:Close(gPanelId.SCRATCHCARD2D_PANEL)
	gPanelManager:Close(self.m_Id)
end

function M:OnRenderTab(_, widget)
	local store = gStoreManager:GetStoreGroup(widget.Store)

	store:ShowPanel(self.args)
end

function M:ShowResultView(_, args)
	local rewardTipsControl = args.rewardTipsControl

	if self.maxRewardIndex < rewardTipsControl then
		rewardTipsControl = self.maxRewardIndex
	end

	local sellerDialogId, playerDialogId = self:GetDialogIdByReward(rewardTipsControl)

	gDialogManager:ShowGeneralDialog(sellerDialogId, gDialogSource.ScratchCard)

	self.waitTimer = Timer.New(function ()
		gDialogManager:ShowGeneralDialog(playerDialogId, gDialogSource.ScratchCard)
		gCS.LogicStateMachineManager.SendGameplayInwardSignal(gCS.MyPlayerManager.PlayerUnit, self.GameplayEndInwardSignal, rewardTipsControl)
		gPanelManager:Close(gPanelId.SCRATCHCARD_PANEL)
		gPanelManager:Close(gPanelId.SCRATCHCARD2D_PANEL)
	end, self.waitHideUITime):Start()
end

function M:GetDialogIdByReward(rewardTipsControl)
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

function M:SignalHandler(_, data)
	local signalId = data:GetCfgId()

	if signalId == self.GameplayStartOutWardSignal then
		gCS.AnimationManager.SetAnimatorParams(gCS.MyPlayerManager.PlayerUnit, 1, -1, 0)
	end
end

function M:OnClose()
	if self.waitTimer then
		self.waitTimer:Stop()

		self.waitTimer = nil
	end
end

function M:OnDestroy()
	gCS.LuaUtils.SetPanelCursor(nil)
	self:ClearMessageEvents()
end
