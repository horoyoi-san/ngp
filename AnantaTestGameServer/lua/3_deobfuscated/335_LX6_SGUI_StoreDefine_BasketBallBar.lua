local BasketBallShootType = {
	Early = 1,
	Late = 4,
	SoSo = 2,
	Perfect = 3
}
C_BasketBallBar = DefClass("C_BasketBallBar", C_BasketBallBar, C_StoreGroup)
GroupName2Class.BasketBallBar = C_BasketBallBar
local M = C_BasketBallBar

function M:DefineAllVariables()
	self.earlyEndTime = 0
	self.perfectStartTime = 0
	self.perfectEndTime = 0
	self.clipLength = 0
	self.keyDownTime = 0
	self.checkFunc = nil
	self.releaseCb = nil
	self.closeCb = nil
	self.needUpdate = false
end

function M:OnUpdate()
	if not self.needUpdate then
		return
	end

	local time = Time.time - self.keyDownTime
	local progress = time / self.clipLength
	self.bindData.currentValue = progress
	self.bindData.earlyFillAmount = progress
	self.bindData.sosoFillAmount = progress
	self.bindData.perfect1FillAmount = progress
	self.bindData.perfect2FillAmount = progress

	if self.clipLength < time or self.checkFunc() then
		local shootType, shootPressPer = self:GetShootResult(time)

		self.releaseCb(shootType, shootPressPer)

		self.needUpdate = false

		self:PlayShootEffect(shootType)
		gLuaTimeMgrUtils.Delay(function ()
			self.closeCb()
		end, 0.6)
	end
end

function M:OnCameraUpdate()
	if not self.needUpdate then
		return
	end
end

function M:SetShootingBarParams(earlyEndTime, perfectStartTime, perfectEndTime, clipLength, keyDownTime, checkFunc, releaseCb, closeCb)
	self:DefineAllVariables()

	self.earlyEndTime = earlyEndTime
	self.perfectStartTime = perfectStartTime
	self.perfectEndTime = perfectEndTime
	self.clipLength = clipLength
	self.keyDownTime = keyDownTime
	self.checkFunc = checkFunc
	self.releaseCb = releaseCb
	self.closeCb = closeCb

	if not self.checkFunc or not self.releaseCb or not self.closeCb then
		print_error("SetShootingBarParams checkFunc or releaseCb or closeCb is nil")

		return
	end

	self.needUpdate = true
	self.bindData.shootEffectCtrl = 0

	self:SetUpUI()
end

function M:SetUpUI()
	self.bindData.badBottomFillAmount = self.perfectStartTime / self.clipLength
	self.bindData.perfectFillAmount = self.perfectEndTime / self.clipLength
	self.bindData.currentValue = 0
end

function M:GetShootResult(releaseTime)
	if releaseTime <= self.earlyEndTime then
		local range = self.earlyEndTime - 0

		return BasketBallShootType.Early, releaseTime / range
	end

	if releaseTime <= self.perfectStartTime then
		local range = self.perfectStartTime - self.earlyEndTime

		return BasketBallShootType.SoSo, (releaseTime - self.earlyEndTime) / range
	end

	if releaseTime <= self.perfectEndTime then
		local range = self.perfectEndTime - self.perfectStartTime

		return BasketBallShootType.Perfect, (releaseTime - self.perfectStartTime) / range
	else
		local range = self.clipLength - self.perfectEndTime
		local percent = (releaseTime - self.perfectEndTime) / range
		percent = math.min(percent, 1)

		return BasketBallShootType.Late, percent
	end
end

function M:PlayShootEffect(shootType)
	self.bindData.currentValue = 0

	if shootType == BasketBallShootType.Early or shootType == BasketBallShootType.Late then
		self.bindData.shootEffectCtrl = 1
		local clip = self.bindData.badAnim:GetClip("S_Vx_BasketBallGamePanel_Bar_bad")

		clip:SampleAnimation(self.bindData.badAnim.gameObject, 0)
		self.bindData.badAnim:Play("S_Vx_BasketBallGamePanel_Bar_bad")

		if gCS.LuaUtils.IsNonMobileAdaptive() then
			gSoundMgr:PlaySoundByExternalSource("ExHandle_QTECommon1", LX6.Audio.ExternalSourceType.Motion_2D)
		end
	elseif shootType == BasketBallShootType.SoSo then
		self.bindData.shootEffectCtrl = 2
		local clip = self.bindData.normalAnim:GetClip("S_Vx_BasketBallGamePanel_Bar_great")

		clip:SampleAnimation(self.bindData.normalAnim.gameObject, 0)
		self.bindData.normalAnim:Play("S_Vx_BasketBallGamePanel_Bar_great")

		if gCS.LuaUtils.IsNonMobileAdaptive() then
			gSoundMgr:PlaySoundByExternalSource("ExHandle_QTECommon1", LX6.Audio.ExternalSourceType.Motion_2D)
		end
	elseif shootType == BasketBallShootType.Perfect then
		self.bindData.shootEffectCtrl = 3
		local clip = self.bindData.goodAnim:GetClip("S_Vx_BasketBallGamePanel_Bar_perfect")

		clip:SampleAnimation(self.bindData.goodAnim.gameObject, 0)
		self.bindData.goodAnim:Play("S_Vx_BasketBallGamePanel_Bar_perfect")

		if gCS.LuaUtils.IsNonMobileAdaptive() then
			gSoundMgr:PlaySoundByExternalSource("ExHandle_QTECommon2", LX6.Audio.ExternalSourceType.Motion_2D)
		end
	end
end
