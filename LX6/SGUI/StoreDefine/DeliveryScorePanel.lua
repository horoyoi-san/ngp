-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\DeliveryScorePanel.lua
-- Decompiled from: 01842_DeliveryScorePanel.lua_b296893d16a6.luajit

C_DeliveryScorePanel = DefClass("C_DeliveryScorePanel", C_DeliveryScorePanel, C_StoreGroup)
GroupName2Class.DeliveryScorePanel = C_DeliveryScorePanel
local M = C_DeliveryScorePanel

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.finishAnimation = "S_Vx_BasketBallGamePanel_Bubble_0point"
	self.eventSet = {
		[gEventConstants.DELIVERY_SCORE_EVENT] = self.CreateAction(self, self.OpenDeliveryScore)
	}
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

M.OpenDeliveryScore = function(self, _, data)
	self.PlayAnimation(self, data)
end

M.PlayAnimation = function(self, data)
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

M.OnShow = function(self, _, data)
	self.PlayAnimation(self, data)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end
