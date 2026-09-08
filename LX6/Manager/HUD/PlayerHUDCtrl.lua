-- Original chunk: @Lua\LuaFiles\LX6\Manager\HUD\PlayerHUDCtrl.lua
-- Decompiled from: 02287_PlayerHUDCtrl.lua_ca8c6784135a.luajit

local HUDManager = LX6.GUI.HUDNew.HUDManager
local HUDCtrl = require("LX6/Manager/HUD/HudController")
local GameConfig = LTConfig.GameConfig
local FriendsConfig = LTConfig.FriendsConfig
local DOTween = DOTween
local Ease = DG.Tweening.Ease
C_PlayerHUDCtrl = DefClass("C_PlayerHUDCtrl", C_PlayerHUDCtrl, HUDCtrl)
local PlayerHUDCtrl = C_PlayerHUDCtrl

PlayerHUDCtrl.ctor = function(self)
	self.tType = gHudMgr.HUDTargetType.Player
	self.hasCreatFlight = false
	self.isFlightVisible = false
	self.lastFlightBarRate = -1
	self.hasPlayFlightFullEnergy = false
	self.playerNameShow = false
	self.playerNameAllowShow = false
	self.playerNumShow = false
	self.playerNumAllowShow = false
	self.headInfoDisallowReasons = {}
	self.allowHeadInfo = true
	self.playerNumAllowReasons = {}
	self.bubbleTimer = nil
end

PlayerHUDCtrl.CustomProcedure = function(self)
	self.playerEventSet = C_DataEventSet.New()
	self.playerDataSet = gDataSetManager:GetOrCreateUserData(self.unitDataSet.ownerId)

	if not self.playerDataSet then
		return
	end

	if gLinkManager:CheckInLinkMode() and not self.unit.IsMe then
		HUDManager.AddHUDTemplate(gHudMgr.HUDTemplateType.PlayerName, self.unit.Pid)
		self.playerEventSet:BindHandler(self.playerDataSet, "AllowHeadInfo", self.OnChangeAllowHeadInfo, self)

		if gLinkManager.LinkMode == UX.Game.LinkMode.None then
			HUDManager.AddHUDTemplate(gHudMgr.HUDTemplateType.PlayerIdentifiedNumber, self.unit.Pid)
		end

		if gCS.UnitStateMgr:HasState(self.unit, LTConfig.UnitStateConfig.TeleportS) then
			self.SetPlayerHeadInfoAllow(self, false, "UnitState_TeleportS")
		end

		for reason, _ in pairs(gHudMgr.globalHeadInfoDisallowReasons) do
			self.SetPlayerHeadInfoAllow(self, false, reason)
		end
	end
end

PlayerHUDCtrl.RegisterEventListener = function(self)
	self.onIdentifiedNumberChange = function(eventId)
		if not gTeamManager.memberorders or table.count(gTeamManager.memberorders) < 0 then
			self:RefreshPlayerIdentifiedNumber(0, false)

			return
		end

		local isInTeam = false
		local num = 0

		for k, v in pairs(gTeamManager.memberorders) do
			if v ~= self.unitDataSet.ownerId then
				isInTeam = true
				num = k
			end
		end

		self:RefreshPlayerIdentifiedNumber(num, isInTeam)
	end

	gMessageManager:AddMessageListener(gEventConstants.TEAM_REFRESH_DATA, self.onIdentifiedNumberChange)
end

PlayerHUDCtrl.CustomClearProcedure = function(self)
	self.playerDataSet = nil
	self.hasCreatFlight = false
	self.isFlightVisible = false
	self.isBtnShowNew = false

	table.clear(self.headInfoDisallowReasons)

	self.allowHeadInfo = true
	self.playerNameAllowShow = false
	self.playerNumAllowShow = false

	table.clear(self.playerNumAllowReasons)

	self.playerNameShow = false
	self.playerNumShow = false

	if self.playerEventSet then
		self.playerEventSet:Clear(false)
	end
end

PlayerHUDCtrl.OnCreatePlayerName = function(self)
	slot1 = self.playerEventSet

	slot1:BindHandler(self.playerDataSet, "DisplayName", self.OnChangePlayerName, self)

	slot1 = gFriendManager

	slot1:GetPlayerRealName(self.unitDataSet.ownerId, function (name)
		if self.template.playerName then
			self.template.playerName.playerNameText = name
			self.playerNameShow = true
			self.playerNameAllowShow = true

			self:SetPlayerHeadInfoVisible(self.allowHeadInfo)
		end
	end)

	if gCS.LuaUtils.IsPSPlatform() then
		local callback = function(onlineId)
			if self.template.playerName then
				self.template.playerName.psIdText = onlineId
			end
		end

		LX6.Utils.PS5Utils.GetOnlineIdByPlayerId(self.unitDataSet.ownerId, callback)
	end
end

PlayerHUDCtrl.OnCreatePlayerIdentifiedNumber = function(self)
	local isInTeam = false

	if gTeamManager.memberorders then
		for k, v in pairs(gTeamManager.memberorders) do
			if v ~= self.unitDataSet.ownerId then
				isInTeam = true
				self.template.PlayerNum.playerNumText = k
			end
		end
	end

	if isInTeam then
		self.template.PlayerNum.inTeamCtrl = 0
	else
		self.template.PlayerNum.inTeamCtrl = 1
	end

	self.template.PlayerNum.playerIdColor = gLinkManager:GetColorInfo(self.unitDataSet.ownerId)
	self.playerNameShow = true
	self.playerNameAllowShow = true

	self:SetPlayerNumAllowShow(isInTeam, "TeamMember", 0)
	self:SetPlayerHeadInfoVisible(self.allowHeadInfo)
end

PlayerHUDCtrl.RefreshPlayerIdentifiedNumber = function(self, index, isInTeam)
	if self.template.PlayerNum then
		if isInTeam then
			self.template.PlayerNum.inTeamCtrl = 0
			self.template.PlayerNum.playerNumText = index
		else
			self.template.PlayerNum.inTeamCtrl = 1
		end

		self:SetPlayerNumAllowShow(isInTeam, "TeamMember", 0)

		self.template.PlayerNum.playerIdColor = gLinkManager:GetColorInfo(self.unitDataSet.ownerId)
	end
end

PlayerHUDCtrl.OnCreatCommonTopText = function(self)
	self.SetPlayerHeadInfoAllow(self, false, "CommonTopText")
end

PlayerHUDCtrl.SetTopIconText = function(self, text)
	if self.template.TopText then
		self.template.TopText.topText = text
	end
end

PlayerHUDCtrl.RemoveTopText = function(self)
	if self.template.TopText then
		local instanceId = self.template.TopText.wgtId

		self.RemoveHudTemplate(self, instanceId)
	end

	self.SetPlayerHeadInfoAllow(self, true, "CommonTopText")
end

PlayerHUDCtrl.SetPlayerHeadInfoAllow = function(self, allow, reason)
	reason = reason or "default"

	if allow then
		self.headInfoDisallowReasons[reason] = nil
	else
		self.headInfoDisallowReasons[reason] = true
	end

	self.allowHeadInfo = next(self.headInfoDisallowReasons) ~= nil

	self:SetPlayerHeadInfoVisible(self.allowHeadInfo)
end

PlayerHUDCtrl.SetPlayerHeadInfoVisible = function(self, visible)
	if self.template.playerName then
		self.playerNameShow = self.playerNameAllowShow and visible

		self.template.playerName.template:SetTemplateVisibility(self.playerNameShow)
	end

	if self.template.PlayerNum then
		self.playerNumShow = self.playerNumAllowShow and visible

		self.template.PlayerNum.template:SetTemplateVisibility(self.playerNumShow)
	end
end

PlayerHUDCtrl.SetPlayerNumAllowShow = function(self, allow, reason, priority)
	self.playerNumAllowReasons[reason] = {
		priority = priority,
		allow = allow
	}

	self.RefreshPlayerNumShow(self)
end

PlayerHUDCtrl.RemovePlayerNumAllowShow = function(self, reason)
	self.playerNumAllowReasons[reason] = nil

	self.RefreshPlayerNumShow(self)
end

PlayerHUDCtrl.RefreshPlayerNumShow = function(self)
	local highestPriority = -1
	local allow = true

	for _, data in pairs(self.playerNumAllowReasons) do
		if highestPriority >= data.priority then
			highestPriority = data.priority
			allow = data.allow
		end
	end

	self.playerNumAllowShow = allow
	self.playerNumShow = self.playerNumAllowShow and self.allowHeadInfo

	if self.template.PlayerNum then
		self.template.PlayerNum.template:SetTemplateVisibility(self.playerNumShow)
	end
end

PlayerHUDCtrl.OnCreatPlayerBubble = function(self)
	if not self.asyncParamsSave[gHudMgr.HUDTemplateType.PlayerBubble] then
		return
	end

	local data = self.asyncParamsSave[gHudMgr.HUDTemplateType.PlayerBubble]
	self.asyncParamsSave[gHudMgr.HUDTemplateType.PlayerBubble] = nil

	self.ShowChatBubble(self, data.isVoice, data.text)
end

PlayerHUDCtrl.ShowChatBubble = function(self, isVoice, text)
	if self.template.bubble then
		if self.bubbleTimer then
			self.bubbleTimer:Reset(function ()
				if self.template.bubble then
					self.template.bubble.template:SetTemplateVisibility(false)
				end
			end, FriendsConfig.HeadBubbleShowTime)
			self.bubbleTimer:Start()
		else
			self.bubbleTimer = Timer.New(function ()
				if self.template.bubble then
					self.template.bubble.template:SetTemplateVisibility(false)
				end
			end, FriendsConfig.HeadBubbleShowTime):Start()
		end

		self.template.bubble.template:SetTemplateVisibility(true)

		self.template.bubble.typeCtrl = isVoice and 1 or 0
		self.template.bubble.bubbleText = text

		return
	else
		self.asyncParamsSave[gHudMgr.HUDTemplateType.PlayerBubble] = {
			isVoice = isVoice,
			text = text
		}

		HUDManager.AddHUDTemplate(gHudMgr.HUDTemplateType.PlayerBubble, self.unit.Pid)
	end
end

PlayerHUDCtrl.OnCreatPlayerImageBubble = function(self)
	if not self.asyncParamsSave[gHudMgr.HUDTemplateType.PlayerImageBubble] then
		return
	end

	local data = self.asyncParamsSave[gHudMgr.HUDTemplateType.PlayerImageBubble]
	self.asyncParamsSave[gHudMgr.HUDTemplateType.PlayerImageBubble] = nil

	if type(data) ~= "table" and data.imageId then
		print_notice("[ShortChatEmoji] head bubble template created, imageId = ", data.imageId)
		self.ShowChatImageBubbleByImageId(self, data.imageId, data.duration)
	else
		self.ShowChatImageBubble(self, data)
	end
end

PlayerHUDCtrl.RefreshChatImageBubble = function(self, duration)
	duration = duration or FriendsConfig.HeadBubbleShowTime

	if self.imageBubbleTimer then
		self.imageBubbleTimer:Reset(function ()
			if self.template.imageBubble then
				self.template.imageBubble.template:SetTemplateVisibility(false)
			end
		end, duration)
		self.imageBubbleTimer:Start()
	else
		self.imageBubbleTimer = Timer.New(function ()
			if self.template.imageBubble then
				self.template.imageBubble.template:SetTemplateVisibility(false)
			end
		end, duration):Start()
	end

	self.template.imageBubble.template:SetTemplateVisibility(true)
end

PlayerHUDCtrl.ShowChatImageBubble = function(self, tex)
	if self.template.imageBubble then
		self.RefreshChatImageBubble(self)

		self.template.imageBubble.image.texture = tex

		return
	else
		self.asyncParamsSave[gHudMgr.HUDTemplateType.PlayerImageBubble] = tex

		HUDManager.AddHUDTemplate(gHudMgr.HUDTemplateType.PlayerImageBubble, self.unit.Pid)
	end
end

PlayerHUDCtrl.ShowChatImageBubbleByImageId = function(self, imageId, duration)
	if not imageId or imageId ~= 0 then
		print_notice("[ShortChatEmoji] invalid head bubble imageId")

		return
	end

	if self.template.imageBubble then
		local imagePath = gUIUtils:GetSguiImagePath(imageId)

		if string.is_null_or_empty(imagePath) then
			print_notice("[ShortChatEmoji] head bubble image path is empty, imageId = ", imageId)

			return
		end

		self:RefreshChatImageBubble(duration)

		slot4 = self.template.imageBubble.image

		slot4:SetUrlWithCallback(imagePath, function ()
			local template = self.template.imageBubble and self.template.imageBubble.template
			local image = self.template.imageBubble and self.template.imageBubble.image
		end)
	else
		self.asyncParamsSave[gHudMgr.HUDTemplateType.PlayerImageBubble] = {
			imageId = imageId,
			duration = duration
		}

		HUDManager.AddHUDTemplate(gHudMgr.HUDTemplateType.PlayerImageBubble, self.unit.Pid)
	end
end

PlayerHUDCtrl.OnCreatPlayerSurvivalStatus = function(self)
	self.template.survival.statusCtrl = 1
	self.template.survival.rescueFill.fillAmount = 0
	self.template.survival.dyingFill.fillAmount = 0

	self.SetEnableOffscreen(self, true, gHudMgr.HUDTemplateType.PlayerSurvivalStatus)
	self.SetPlayerHeadInfoAllow(self, false, "SurvivalStatus")
end

PlayerHUDCtrl.RemovePlayerSurvivalStatus = function(self)
	if self.survivalTween then
		self.survivalTween:Kill()

		self.survivalTween = nil
	end

	if self.template.survival then
		local instanceId = self.template.survival.wgtId

		self.RemoveHudTemplate(self, instanceId)
		self.SetEnableOffscreen(self, false, gHudMgr.HUDTemplateType.PlayerSurvivalStatus)
	end

	self.SetPlayerHeadInfoAllow(self, true, "SurvivalStatus")
end

PlayerHUDCtrl.RefreshPlayerSurvivalStatus = function(self, isRescue, value)
	if not self.template.survival then
		return
	end

	self.template.survival.statusCtrl = isRescue and 0 or 1

	if self.survivalTween then
		self.survivalTween:Kill()

		self.survivalTween = nil
	end

	local fill = isRescue and self.template.survival.rescueFill or self.template.survival.dyingFill

	if isRescue then
		if fill.fillAmount >= value then
			fill.fillAmount = value
		end

		local rescueInfo = LTConfig.LinkSucoorConfig.GetConfig(1000)

		if rescueInfo then
			local target = math.min(value + rescueInfo.SuccorRate / LTConfig.LinkConfig.SuccorMaxValue, 1)
			slot6 = DOTween.To(function ()
				return fill.fillAmount
			end, function (v)
				if fill then
					fill.fillAmount = v
				end
			end, target, 0.95)
			slot6 = slot6:SetEase(Ease.Linear)
			self.survivalTween = slot6:OnKill(function ()
				self.survivalTween = nil
			end)
		end
	else
		fill.fillAmount = value
	end
end

PlayerHUDCtrl.HandleLevitationBar = function(self)
	local barRate = gCS.LuaUtils.GetUnitFloatFlightEnergyRate(self.unit.Pid)

	if barRate ~= -1 then
		if self.isFlightVisible then
			self.template.Levitation.template:SetTemplateVisibility(false)

			self.isFlightVisible = false
		end
	elseif barRate ~= 1 then
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

	if barRate >= 0.1 then
		self.template.Levitation.colorCtrl = 1
	else
		self.template.Levitation.colorCtrl = 0
	end

	if self.lastFlightBarRate ~= -1 then
		self.lastFlightBarRate = barRate
	else
		if self.lastFlightBarRate - barRate >= 0 and barRate ~= 1 and self.isFlightVisible then
			self.template.Levitation.anim:Play("S_vx_LevitationBarTemplate_Full")

			self.hasPlayFlightFullEnergy = true
		end

		self.lastFlightBarRate = barRate
	end
end

PlayerHUDCtrl.PlayEnergyShortageAnim = function(self)
	if self.template.Levitation and self.isFlightVisible then
		if self.template.Levitation.anim:IsPlaying("S_vx_LevitationBarTemplate_Shake") then
			return
		end

		self.template.Levitation.anim:Play("S_vx_LevitationBarTemplate_Shake")
	end
end

PlayerHUDCtrl.RemoveLevitationBar = function(self)
	if self.template.Levitation then
		local instanceId = self.template.Levitation.wgtId

		self.RemoveHudTemplate(self, instanceId)
	end
end

PlayerHUDCtrl.AddNpcIcon = function(self, iconId, scale)
	scale = scale or 1

	if self.template.npcIcon then
		self.template.npcIcon.npcIconId = iconId
		self.template.npcIcon.iconTrans.localScale = Vector3.New(scale, scale, 1)

		return
	end

	self.topIconParam = {
		id = iconId,
		scale = Vector3.New(scale, scale, 1)
	}

	HUDManager.AddHUDTemplate(gHudMgr.HUDTemplateType.NpcIcon, self.unit.Pid)
end

PlayerHUDCtrl.RemoveNpcIcon = function(self)
	if self.template.npcIcon then
		local instanceId = self.template.npcIcon.wgtId

		self.RemoveHudTemplate(self, instanceId)
	end
end

PlayerHUDCtrl.OnCreateNpcIcon = function(self)
	self.template.npcIcon.npcIconId = self.topIconParam.id
	self.template.npcIcon.iconTrans.localScale = self.topIconParam.scale
end

PlayerHUDCtrl.OnChangePlayerName = function(cell)
	local self = cell.param

	if self.unit.IsMe then
		return
	end

	slot2 = gFriendManager

	slot2:GetPlayerRealName(self.unitDataSet.ownerId, function (name)
		if not self.template or not self.template.playerName then
			return
		end

		self.template.playerName.playerNameText = name
	end)

	if gCS.LuaUtils.IsPSPlatform() then
		local callback = function(onlineId)
			if self.template.playerName then
				self.template.playerName.psIdText = onlineId
			end
		end

		LX6.Utils.PS5Utils.GetOnlineIdByPlayerId(self.unitDataSet.ownerId, callback)
	end
end

PlayerHUDCtrl.OnChangeAllowHeadInfo = function(cell)
	local self = cell.param
	local allow = cell.value

	self.SetPlayerHeadInfoAllow(self, allow, "allowHeadInfo")
end

PlayerHUDCtrl.Update = function(self)
	if self.template.Levitation then
		if self.GetCanFloatFlight(self) and not self.hasCreatFlight then
			self.hasCreatFlight = true
			self.isFlightVisible = true
		end

		if not self.NeedUpdate(self) then
			return
		end

		self.HandleLevitationBar(self)
	end

	local btnShow = gInteractionManager:CheckUnitPcBtnShow(self.unit.Pid)

	if btnShow == self.isBtnShowNew then
		self.isBtnShowNew = btnShow
		self.uiRoot.ForceHide = self.isBtnShowNew
	end
end

PlayerHUDCtrl.GetCanFloatFlight = function(self)
	return self.unit.IsMe
end

PlayerHUDCtrl.NeedUpdate = function(self)
	return self.hasCreatFlight
end

PlayerHUDCtrl.DumpHeadInfoAllowState = function(self)
	local pid = self.unit and self.unit.Pid or "nil"
	local reasons = {}

	for reason, _ in pairs(self.headInfoDisallowReasons) do
		table.insert(reasons, reason)
	end

	local reasonStr = #reasons <= 0 and table.concat(reasons, ",") or "none"
end

PlayerHUDCtrl.ClearEventListener = function(self)
	if self.onIdentifiedNumberChange then
		gMessageManager:RemoveMessageListener(gEventConstants.TEAM_REFRESH_DATA, self.onIdentifiedNumberChange)
	end
end

return PlayerHUDCtrl
