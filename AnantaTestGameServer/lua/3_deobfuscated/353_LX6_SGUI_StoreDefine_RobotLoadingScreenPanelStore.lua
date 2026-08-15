C_RobotLoadingScreenPanelStore = DefClass("C_RobotLoadingScreenPanelStore", C_RobotLoadingScreenPanelStore, C_StoreGroup)
GroupName2Class.RobotLoadingScreenPanelStore = C_RobotLoadingScreenPanelStore
local M = C_RobotLoadingScreenPanelStore

function M:ctor()
	self.loadFinish = false
end

function M:DefineAllVariables()
	return
end

function M:OnAwake()
	self:DefineAllVariables()
	self:GenMessageEvents()
end

function M:OnGroupEnable()
	self.startTime = Time.time

	self:SetFillAmount(0)
end

function M:OnShow(panelId, data)
	self.needUpdate = true
end

function M:OnClose()
	self.loadFinish = false
	self.needUpdate = false
	self.needClose = false
	self.lastFill = 0
end

function M:SetFillAmount(fill)
	self.bindData.fillAmount = fill
	self.lastFill = fill
end

function M:OnUpdate()
	if self.needClose then
		self.needClose = false

		gPanelManager:Close(gPanelId.S_ROBOT_LOADING_SCREEN_PANEL)
	end

	if self.needUpdate then
		local passTime = Time.time - self.startTime

		if passTime < 0.8 then
			self:SetFillAmount(passTime)
		elseif self.loadFinish then
			if passTime > 1 then
				self:SetFillAmount(1)

				self.needClose = true
				self.needUpdate = false
			else
				self:SetFillAmount(passTime)
			end
		elseif passTime < 0.9 then
			self:SetFillAmount(passTime)
		elseif passTime <= 1 then
			self:SetFillAmount(0.9 + (passTime - 0.9) / 2)
		else
			self:SetLoadFinish()
		end
	end
end

function M:GenMessageEvents()
	return
end

function M:SetLoadFinish()
	self.loadFinish = true
end
