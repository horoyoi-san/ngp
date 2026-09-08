-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BasketBallBar.lua
-- Decompiled from: 01655_BasketBallBar.lua_12515bfadc54.luajit

local BasketBallShootType = {
	["h\\xaf\\xb0\\xa3\\xaf"] = 1,
	["V#i^"] = 4,
	["I-NT"] = 2,
	["\\xe9\\xde'\\xe5"] = 3,
	["T-s^"] = 0
}
local LinkBasketballStatus = L18.Gameplay.LinkBasketball.LinkBasketballStatus
C_BasketBallBar = DefClass("C_BasketBallBar", C_BasketBallBar, C_StoreGroup)
GroupName2Class.BasketBallBar = C_BasketBallBar
local M = C_BasketBallBar

M.OnDestroy = function(self)
	self.ClearMessageEvents(self)
end

M.DefineAllVariables = function(self)
	self.earlyEndTime = 0
	self.perfectStartTime = 0
	self.perfectEndTime = 0
	self.clipLength = 0
	self.keyDownTime = 0
	self.checkFunc = nil
	self.releaseCb = nil
	self.closeCb = nil
	self.needUpdate = false
	self.lastProgressTime = 0
	self.linkBasketballManager = gCS.LinkBasketballManager.Instance
end

M.FollowPlayerUpbody = function(self)
	if self.linkBasketballManager.basketballStatus == LinkBasketballStatus.InMatch then
		return
	end

	local playerUnit = gCS.MyPlayerManager.PlayerUnit

	if not playerUnit or not playerUnit.ModelSlot then
		return
	end

	local modelSlot = playerUnit.ModelSlot
	local targetPos = modelSlot.upbody and modelSlot.upbody.position or playerUnit.LocalPosition
	local x, y, z = gCS.LuaUtils.WorldToScreenPointProjected(targetPos, gCS.CameraDataMgr.MainCamera, 0, 0, 0)
	local uiPos = gCS.LuaUtils.ScreenPointToUINoRay(x, y)

	self.rootGo.transform:SetLocalPositionXY(uiPos.x + 140, uiPos.y - 0.5)
end

M.OnUpdate = function(self)
	self.FollowPlayerUpbody(self)

	if not self.needUpdate then
		return
	end

	local time = Time.time - self.keyDownTime

	if time >= self.shootStartTime then
		return
	end

	self.UpdatePerfectBarScale(self)

	self.bindData.renderOpacity = 1
	local barShowTime = time - self.shootStartTime
	local progress = 0

	if barShowTime < self.barLength then
		progress = barShowTime / self.barLength
	else
		local downTime = barShowTime - self.barLength
		progress = self.barLength < downTime and 0 or 1 - downTime / self.barLength
	end

	self.lastProgressTime = time
	self.bindData.currentValue = progress
	self.bindData.earlyFillAmount = progress
	self.bindData.sosoFillAmount = progress
	self.bindData.perfect1FillAmount = progress
	self.bindData.perfect2FillAmount = progress

	if self.clipLength <= barShowTime or self.checkFunc() then
		local shootType, shootPressPer = self.GetShootResult(self, time)

		self.releaseCb(shootType, shootPressPer)

		self.needUpdate = false

		self.PlayShootEffect(self, shootType)
		gLuaTimeMgrUtils.Delay(function ()
			gMessageManager:SendMessage(gEventConstants.BASKETBALL_SHOOTING_OVER, true)
			self.closeCb()
		end, 0.6)
	end
end

M.UpdatePerfectBarScale = function(self)
	local scale = gCS.BaseUnitModuleUtils.CheckBasketballHitProbability(gCS.MyPlayerManager.PlayerUnit)
	self.midPerfectLength = self.originMidPerfectLength * scale
	self.perfectStartTime = self.midTime - self.midPerfectLength
	self.perfectEndTime = self.midTime + self.midPerfectLength

	self.RefreshPerfectBar(self)
end

M.OnCameraUpdate = function(self)
	if not self.needUpdate then
		return
	end
end

M.SetShootingBarParams = function(self, earlyEndTime, perfectStartTime, perfectEndTime, shootStartTime, shootEndTime, keyDownTime, checkFunc, releaseCb, closeCb)
	self.DefineAllVariables(self)

	self.earlyEndTime = earlyEndTime
	self.perfectStartTime = perfectStartTime
	self.perfectEndTime = perfectEndTime
	self.shootStartTime = shootStartTime
	self.shootEndTime = shootEndTime
	self.clipLength = shootEndTime - shootStartTime
	self.keyDownTime = keyDownTime
	self.checkFunc = checkFunc
	self.releaseCb = releaseCb
	self.closeCb = closeCb
	self.originMidPerfectLength = (self.perfectEndTime - self.perfectStartTime) / 2
	self.midPerfectLength = self.originMidPerfectLength
	self.midTime = self.perfectEndTime - self.originMidPerfectLength
	self.barLength = self.midTime - self.shootStartTime

	if not self.checkFunc or not self.releaseCb or not self.closeCb then
		print_error("SetShootingBarParams checkFunc or releaseCb or closeCb is nil")

		return
	end

	self.needUpdate = true
	self.bindData.shootEffectCtrl = 0

	self.SetUpUI(self)
end

M.SetUpUI = function(self)
	self:RefreshPerfectBar()

	self.bindData.currentValue = 0
	self.bindData.renderOpacity = 0

	self.rootGo.transform:SetLocalPositionXY(199.9, -0.5)
end

M.RefreshPerfectBar = function(self)
	if self.barLength ~= 0 then
		return
	end

	local perfectAmount = self.midPerfectLength / self.barLength
	self.bindData.perfectFillAmount = perfectAmount
end

M.GetShootResult = function(self, releaseTime)
	if releaseTime < self.earlyEndTime then
		local range = self.earlyEndTime - 0

		return BasketBallShootType.Early, releaseTime / range
	end

	if self.perfectStartTime < releaseTime and releaseTime < self.perfectEndTime then
		local range = self.perfectEndTime - self.perfectStartTime

		return BasketBallShootType.Perfect, (releaseTime - self.perfectStartTime) / range
	else
		local range = self.clipLength - self.perfectEndTime
		local percent = (releaseTime - self.perfectEndTime) / range
		percent = math.min(percent, 1)

		return BasketBallShootType.Late, percent
	end
end

M.GetShootResultAndCloseIfPerfect = function(self)
	if not self.needUpdate then
		return BasketBallShootType.None
	end

	local releaseTime = self.lastProgressTime
	local shootType = self.GetShootResult(self, releaseTime)
	self.needUpdate = false

	self.PlayShootEffect(self, shootType)
	gLuaTimeMgrUtils.Delay(function ()
		gMessageManager:SendMessage(gEventConstants.BASKETBALL_SHOOTING_OVER, true)
		self.closeCb()
	end, 0.6)

	return shootType
end

M.PlayShootEffect = function(self, shootType)
	self.bindData.currentValue = 0

	if shootType ~= BasketBallShootType.Early or shootType ~= BasketBallShootType.Late then
		self.bindData.shootEffectCtrl = 1
		local clip = self.bindData.badAnim:GetClip("S_Vx_BasketBallGamePanel_Bar_bad")

		clip:SampleAnimation(self.bindData.badAnim.gameObject, 0)
		self.bindData.badAnim:Play("S_Vx_BasketBallGamePanel_Bar_bad")

		if gCS.LuaUtils.IsNonMobileAdaptive() then
			gSoundMgr:PlaySoundByExternalSource("ExHandle_QTECommon1", LX6.Audio.ExternalSourceType.Motion_2D)
		end
	elseif shootType ~= BasketBallShootType.SoSo then
		self.bindData.shootEffectCtrl = 2
		local clip = self.bindData.normalAnim:GetClip("S_Vx_BasketBallGamePanel_Bar_great")

		clip:SampleAnimation(self.bindData.normalAnim.gameObject, 0)
		self.bindData.normalAnim:Play("S_Vx_BasketBallGamePanel_Bar_great")

		if gCS.LuaUtils.IsNonMobileAdaptive() then
			gSoundMgr:PlaySoundByExternalSource("ExHandle_QTECommon1", LX6.Audio.ExternalSourceType.Motion_2D)
		end
	elseif shootType ~= BasketBallShootType.Perfect then
		self.bindData.shootEffectCtrl = 3
		local clip = self.bindData.goodAnim:GetClip("S_Vx_BasketBallGamePanel_Bar_perfect")

		clip:SampleAnimation(self.bindData.goodAnim.gameObject, 0)
		self.bindData.goodAnim:Play("S_Vx_BasketBallGamePanel_Bar_perfect")

		if gCS.LuaUtils.IsNonMobileAdaptive() then
			gSoundMgr:PlaySoundByExternalSource("ExHandle_QTECommon2", LX6.Audio.ExternalSourceType.Motion_2D)
		end
	end
end
