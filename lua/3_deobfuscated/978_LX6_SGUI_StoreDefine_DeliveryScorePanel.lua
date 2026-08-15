C_DeliveryScorePanel = DefClass("C_DeliveryScorePanel", C_DeliveryScorePanel, C_StoreGroup)
GroupName2Class.DeliveryScorePanel = C_DeliveryScorePanel
local M = C_DeliveryScorePanel

function M:ctor()
	return
end

function M:OnAwake()
	self.finishAnimation = "S_Vx_BasketBallGamePanel_Bubble_0point"
	self.eventSet = {
		[gEventConstants.DELIVERY_SCORE_EVENT] = self:CreateAction(self.OpenDeliveryScore)
	}
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

function M:OpenDeliveryScore(_, data)
	self:PlayAnimation(data)
end

function M:PlayAnimation(data)
	self.bindData.score = data.score
	self.bindData.typeText = data.typeText
	local duration = self.bindData.animRoot.anim:GetClip(self.finishAnimation).length

	self.bindData.animRoot.anim:Stop()
	self.bindData.animRoot.anim:Play()

	if self.timer then
		self.timer:Stop()
	end

	self.timer = Timer.New(function ()
		self.timer = nil

		gPanelManager:Close(gPanelId.S_DELIVERY_SCORE_PANEL)
	end, duration):Start()
end

function M:OnShow(_, data)
	self:PlayAnimation(data)
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
