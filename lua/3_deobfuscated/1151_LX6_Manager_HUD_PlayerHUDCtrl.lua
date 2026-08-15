local HUDManager = LX6.GUI.HUDNew.HUDManager
local HUDCtrl = require("LX6/Manager/HUD/HudController")
local GameConfig = LTConfig.GameConfig
C_PlayerHUDCtrl = DefClass("C_PlayerHUDCtrl", C_PlayerHUDCtrl, HUDCtrl)
local PlayerHUDCtrl = C_PlayerHUDCtrl

function PlayerHUDCtrl:ctor()
	self.tType = gHudMgr.HUDTargetType.Player
	self.hasCreatFlight = false
	self.isFlightVisible = false
	self.lastFlightBarRate = -1
	self.hasPlayFlightFullEnergy = false
	self.playerNameShow = false
	self.playerNameAllowShow = false
	self.playerNumShow = false
	self.playerNumAllowShow = false
end

function PlayerHUDCtrl:CustomProcedure()
	self.playerEventSet = C_DataEventSet.New()
	self.playerDataSet = gDataSetManager:GetOrCreateUserData(self.unitDataSet.ownerId)

	if not self.playerDataSet then
		return
	end

	if gLinkManager:CheckInLinkMode() and not self.unit.IsMe then
		HUDManager.AddHUDTemplate(gHudMgr.HUDTemplateType.PlayerName, self.unit.Pid)
		self.playerEventSet:BindHandler(self.playerDataSet, "AllowHeadInfo", self.OnChangeAllowHeadInfo, self)

		if gLinkManager.LinkMode ~= UX.Game.LinkMode.Public then
			HUDManager.AddHUDTemplate(gHudMgr.HUDTemplateType.PlayerIdentifiedNumber, self.unit.Pid)
		end
	end
end

function PlayerHUDCtrl:CustomClearProcedure()
	self.playerDataSet = nil
	self.hasCreatFlight = false
	self.isFlightVisible = false
	self.isBtnShowNew = false

	if self.playerEventSet then
		self.playerEventSet:Clear(false)
	end
end

function PlayerHUDCtrl:OnCreatePlayerName()
	self.playerEventSet:BindHandler(self.playerDataSet, "DisplayName", self.OnChangePlayerName, self)
	gFriendManager:GetPlayerRealName(self.unitDataSet.ownerId, function (name)
		self.template.playerName.playerNameText = name
		self.playerNameShow = true
		self.playerNameAllowShow = true
	end)
end

function PlayerHUDCtrl:OnCreatePlayerIdentifiedNumber()
	local index = gLinkManager:GetLinkIndex(self.unitDataSet.ownerId)

	if not index then
		return
	end

	self.template.PlayerNum.playerNumText = index
	self.playerNumShow = true
	self.playerNumAllowShow = true
end

function PlayerHUDCtrl:OnCreatCommonTopText()
	self.playerDataSet.AllowHeadInfo = false
end

function PlayerHUDCtrl:SetTopIconText(text)
	if self.template.TopText then
		self.template.TopText.topText = text
	end
end

function PlayerHUDCtrl:RemoveTopText()
	if self.template.TopText then
		local instanceId = self.template.TopText.wgtId

		self:RemoveHudTemplate(instanceId)
	end

	self.playerDataSet.AllowHeadInfo = true
end

function PlayerHUDCtrl:SetPlayerHeadInfoVisible(visible)
	if self.template.playerName then
		self.playerNameShow = self.playerNameAllowShow and not self.isBtnShowNew and visible

		self.template.playerName.template:SetTemplateVisibility(self.playerNameShow)
	end

	if self.template.PlayerNum then
		self.playerNumShow = self.playerNumAllowShow and not self.isBtnShowNew and visible

		self.template.PlayerNum.template:SetTemplateVisibility(self.playerNumShow)
	end
end

function PlayerHUDCtrl:HandleLevitationBar()
	local barRate = gCS.LuaUtils.GetUnitFloatFlightEnergyRate(self.unit.Pid)

	if barRate == -1 then
		if self.isFlightVisible then
			self.template.Levitation.template:SetTemplateVisibility(false)

			self.isFlightVisible = false
		end
	elseif barRate == 1 then
		if self.isFlightVisible and not self.barRateHideTimer then
			self.barRateHideTimer = gLuaTimeMgrUtils.Delay(function ()
				if self.template.Levitation then
					self.template.Levitation.template:SetTemplateVisibility(false)

					self.isFlightVisible = false
				end

				self.barRateHideTimer = nil
			end, GameConfig.LevitationBarDisappearTime)
		end
	elseif not self.isFlightVisible then
		self.template.Levitation.template:SetTemplateVisibility(true)

		self.isFlightVisible = true
	end

	self.template.Levitation.energyFillAmount = barRate

	if barRate < 0.1 then
		self.template.Levitation.colorCtrl = 1
	else
		self.template.Levitation.colorCtrl = 0
	end

	if self.lastFlightBarRate == -1 then
		self.lastFlightBarRate = barRate
	else
		if self.lastFlightBarRate - barRate < 0 and barRate == 1 and self.isFlightVisible then
			self.template.Levitation.anim:Play("S_vx_LevitationBarTemplate_Full")

			self.hasPlayFlightFullEnergy = true
		end

		self.lastFlightBarRate = barRate
	end
end

function PlayerHUDCtrl:PlayEnergyShortageAnim()
	if self.template.Levitation and self.isFlightVisible then
		if self.template.Levitation.anim:IsPlaying("S_vx_LevitationBarTemplate_Shake") then
			return
		end

		self.template.Levitation.anim:Play("S_vx_LevitationBarTemplate_Shake")
	end
end

function PlayerHUDCtrl:RemoveLevitationBar()
	if self.template.Levitation then
		local instanceId = self.template.Levitation.wgtId

		self:RemoveHudTemplate(instanceId)
	end
end

function PlayerHUDCtrl.OnChangePlayerName(cell)
	local self = cell.param

	gFriendManager:GetPlayerRealName(self.unitDataSet.ownerId, function (name)
		self.template.playerName.playerNameText = name
	end)
end

function PlayerHUDCtrl.OnChangeAllowHeadInfo(cell)
	local self = cell.param
	local allow = cell.value
	self.playerNumAllowShow = allow
	self.playerNameAllowShow = allow

	self:SetPlayerHeadInfoVisible(allow)
end

function PlayerHUDCtrl:Update()
	if self.template.Levitation then
		if self:GetCanFloatFlight() and not self.hasCreatFlight then
			self.hasCreatFlight = true
			self.isFlightVisible = true
		end

		if not self:NeedUpdate() then
			return
		end

		self:HandleLevitationBar()
	end

	local btnShow = gInteractionManager:CheckUnitPcBtnShow(self.unit.Pid)

	if btnShow ~= self.isBtnShowNew then
		self.isBtnShowNew = btnShow

		self:SetPlayerHeadInfoVisible(not btnShow)
	end
end

function PlayerHUDCtrl:GetCanFloatFlight()
	return self.unit.IsMe
end

function PlayerHUDCtrl:NeedUpdate()
	return self.hasCreatFlight
end

return PlayerHUDCtrl
