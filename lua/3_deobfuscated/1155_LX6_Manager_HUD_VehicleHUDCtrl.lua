local HUDCtrl = require("LX6/Manager/HUD/HudController")
local DOTween = DOTween
local Ease = DG.Tweening.Ease
local GameConfig = LTConfig.GameConfig
C_VehicleHUDCtrl = DefClass("C_VehicleHUDCtrl", C_VehicleHUDCtrl, HUDCtrl)
local VehicleHUDCtrl = C_VehicleHUDCtrl

function VehicleHUDCtrl:ctor()
	self.tType = gHudMgr.HUDTargetType.Vehicle
	self.vehicleId = nil
	self.vehicle = nil
	self.isDebugCreate = false
end

function VehicleHUDCtrl:CustomProcedure()
	self.vehicleId = gCS.LuaUtils.StringToUlong(string.match(self.uniId, "_(.*)"))
	self.vehicle = gDriveVehiclesManager.cs_manager:GetBaseVehicle(self.vehicleId)
	local cfgId = self.vehicle.cfgId
	local cfg = LTConfig.VehicleConfig.GetConfig(cfgId)
	local offset = cfg.VehicleCenterOffset[2]
	local sizeY = cfg.VehicleSize[2]
	self.uiRoot.ExtraOffset = offset + sizeY / 2 + 0.1
end

function VehicleHUDCtrl:Update()
	if not self.vehicle or not self.vehicle.gameObject then
		return
	end

	local Id = gHudMgr.DebugTag.Id

	if self:CheckDebugTextExist(Id) then
		self:DebugRefresh()
	end
end

function VehicleHUDCtrl:OnCreateEnemyHpBar()
	local ani = self.template.hpBar.anim
	local clip = ani:GetClip("S_vx_EmenyHpTemplate_close")

	clip:SampleAnimation(ani.gameObject, 0)
	ani:Stop("S_vx_EmenyHpTemplate_close")

	self.template.hpBar.hpBar.fillAmount = 1

	self:HpChanged(1)
	self.template.hpBar.levelNode:SetLocalScale(0)
	self.template.hpBar.disarmNode.gameObject:SetActive(false)
end

function VehicleHUDCtrl:HpChanged(hp)
	if not self.template.hpBar then
		return
	end

	local sum = hp

	if sum >= 0 then
		local oldHpValue = self.template.hpBar.hpBar.fillAmount
		local newHpValue = hp

		if oldHpValue <= newHpValue then
			self.template.hpBar.hpBar.fillAmount = newHpValue
			self.template.hpBar.weakHpBar.fillAmount = newHpValue
			self.template.hpBar.flashBar.fillAmount = newHpValue
		else
			if self.flashTweenFill then
				self.flashTweenFill:Kill()
			end

			if self.weakTweenFill then
				self.weakTweenFill:Kill()
			end

			self.template.hpBar.flashBar.renderOpacity = 1
			self.flashTweenFill = DOTween.To(function ()
				return self.template.hpBar.flashBar.renderOpacity
			end, function (value)
				if self.template.hpBar then
					self.template.hpBar.flashBar.renderOpacity = value
				end
			end, 0, 0.1):SetEase(Ease.Linear):OnKill(function ()
				self.flashTweenFill = nil
			end)

			gLuaTimeMgrUtils.NotDestroyDelay(function ()
				if self.template.hpBar then
					local duration = (self.template.hpBar.weakHpBar.fillAmount - newHpValue) * 100 / GameConfig.WeakHpDecreaseSpeed
					self.template.hpBar.flashBar.fillAmount = newHpValue
					self.weakTweenFill = DOTween.To(function ()
						return self.template.hpBar.weakHpBar.fillAmount
					end, function (value)
						if self.template.hpBar then
							self.template.hpBar.weakHpBar.fillAmount = value
						end
					end, newHpValue, duration):SetEase(Ease.Linear):OnKill(function ()
						self.weakTweenFill = nil
					end)
				end
			end, 0.1)

			self.template.hpBar.hpBar.fillAmount = newHpValue
		end
	end
end

function VehicleHUDCtrl:Dead()
	if not self.template.hpBar then
		return
	end

	local ani = self.template.hpBar.anim

	ani:Play("S_vx_EmenyHpTemplate_close")

	local clip = ani:GetClip("S_vx_EmenyHpTemplate_close")

	gLuaTimeMgrUtils.NotDestroyDelay(function ()
		if gCS.LuaUtils.IsNull(ani) or not self.template.hpBar then
			return
		end

		clip:SampleAnimation(ani.gameObject, 0)
		ani:Stop("S_vx_EmenyHpTemplate_close")
		self.template.hpBar.template:SetTemplateVisibility(false)
	end, clip.length)
end

function VehicleHUDCtrl:DebugRefresh()
	if self.vehicle.gameObject.activeInHierarchy then
		local id = self.vehicleId
		local speed = self.vehicle.Speed

		if Mathf.Abs(speed) < 0.01 then
			speed = 0
		end

		local cfgId = self.vehicle.cfgId
		local speedInKm = speed * 3.6
		local lodLevel = self.vehicle:GetCurrentLODLevel()
		local impulse = self.vehicle.LatestImpulse
		local infoStr = gString.Format([[
ID: %s
cfgID: %d
%.2f m/s
%.2f km/h
lod: %d
Impulse: %.1f]], ulong.tostring(id), cfgId, speed, speedInKm, lodLevel, impulse)

		self:OnShowId(true, infoStr)
	else
		self:OnShowId(false, "")
	end
end

function VehicleHUDCtrl:CustomClearProcedure()
	self.vehicleId = nil
	self.vehicle = nil
end

return VehicleHUDCtrl
