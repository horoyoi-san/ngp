-- Original chunk: @Lua\LuaFiles\LX6\Manager\HUD\VehicleHUDCtrl.lua
-- Decompiled from: 02291_VehicleHUDCtrl.lua_eb7771285f88.luajit

local HUDCtrl = require("LX6/Manager/HUD/HudController")
local DOTween = DOTween
local Ease = DG.Tweening.Ease
local GameConfig = LTConfig.GameConfig
C_VehicleHUDCtrl = DefClass("C_VehicleHUDCtrl", C_VehicleHUDCtrl, HUDCtrl)
local VehicleHUDCtrl = C_VehicleHUDCtrl

VehicleHUDCtrl.ctor = function(self)
	self.tType = gHudMgr.HUDTargetType.Vehicle
	self.vehicleId = nil
	self.vehicle = nil
	self.isDebugCreate = false
end

VehicleHUDCtrl.CustomProcedure = function(self)
	self.vehicleId = gCS.LuaUtils.StringToUlong(string.match(self.uniId, "_(.*)"))
	self.vehicle = gDriveVehiclesManager.cs_manager:GetBaseVehicle(self.vehicleId)
	local cfgId = self.vehicle.cfgId
	local cfg = LTConfig.VehicleConfig.GetConfig(cfgId)
	local offset = cfg.VehicleCenterOffset[2]
	local sizeY = cfg.VehicleSize[2]
	self.uiRoot.ExtraOffset = offset + sizeY / 2 + 0.1
end

VehicleHUDCtrl.Update = function(self)
	if not self.vehicle or not self.vehicle.gameObject then
		return
	end

	local Id = gHudMgr.DebugTag.Id

	if self.CheckDebugTextExist(self, Id) then
		self.DebugRefresh(self)
	end
end

VehicleHUDCtrl.OnCreatVehicleHpBar = function(self)
	self.template.vehicleHpBar.hpBar.value = 1
	self.template.vehicleHpBar.weakHpBar.fillAmount = 1

	self.HpChanged(self, 1)
end

VehicleHUDCtrl.HpChanged = function(self, hp)
	if not self.template.vehicleHpBar then
		return
	end

	local sum = hp

	if sum > 0 then
		local oldHpValue = self.template.vehicleHpBar.hpBar.value
		local newHpValue = hp

		if oldHpValue < newHpValue then
			self.template.vehicleHpBar.hpBar.value = newHpValue
			self.template.vehicleHpBar.weakHpBar.fillAmount = newHpValue
		else
			if self.weakTweenFill then
				self.weakTweenFill:Kill()
			end

			gLuaTimeMgrUtils.NotDestroyDelay(function ()
				if self.template.vehicleHpBar then
					local duration = (self.template.vehicleHpBar.weakHpBar.fillAmount - newHpValue) * 100 / GameConfig.WeakHpDecreaseSpeed
					slot2 = DOTween.To(function ()
						return self.template.vehicleHpBar.weakHpBar.fillAmount
					end, function (value)
						if self.template.vehicleHpBar then
							self.template.vehicleHpBar.weakHpBar.fillAmount = value
						end
					end, newHpValue, duration)
					slot2 = slot2:SetEase(Ease.Linear)
					self.weakTweenFill = slot2:OnKill(function ()
						self.weakTweenFill = nil
					end)
				end
			end, 0.1)

			self.template.vehicleHpBar.hpBar.value = newHpValue
		end
	end
end

VehicleHUDCtrl.Dead = function(self)
	if not self.template.vehicleHpBar then
		return
	end

	self.template.vehicleHpBar.template:SetTemplateVisibility(false)
end

VehicleHUDCtrl.DebugRefresh = function(self)
	if not self.vehicle or not self.vehicle.gameObject or gCS.LuaUtils.IsNull(self.vehicle.gameObject) then
		return
	end

	if self.vehicle.gameObject.activeInHierarchy then
		local id = self.vehicleId
		local speed = self.vehicle.Speed

		if Mathf.Abs(speed) >= 0.01 then
			speed = 0
		end

		local cfgId = self.vehicle.cfgId
		local speedInKm = speed * 3.6
		local lodLevel = self.vehicle:GetCurrentLODLevel()
		local textureStreamingBias = self.vehicle.CurrentTextureStreamingBias
		local impulse = self.vehicle.LatestImpulse
		local currentHp = self.vehicle.CurrentHp
		local maxHp = self.vehicle.MaxHp
		local netControllerPid = self.vehicle.NetControllerPid
		local isHost = self.vehicle.IsHost
		local isServerHost = self.vehicle.IsServerHost
		local hostTag = isServerHost and "Host(Server)" or isHost and "Host" or "Clone"
		local isAiControl = self.vehicle.IsAiControl
		local taskAIName = self.vehicle.TaskAIName
		local aiStr = isAiControl and gString.Format("AI: %s", taskAIName == "" and taskAIName or "On") or "AI: Off"
		local infoStr = gString.Format([[
ID: %s
cfgID: %d
%.2f km/h
lod: %d - %d
Impulse: %.1f
Hp: %.0f/%.0f
Ctrl: %s (%s)
%s]], ulong.tostring(id), cfgId, speedInKm, lodLevel, textureStreamingBias, impulse, currentHp, maxHp, ulong.tostring(netControllerPid), hostTag, aiStr)

		self:OnShowId(true, infoStr)
	else
		self.OnShowId(self, false, "")
	end
end

VehicleHUDCtrl.CustomClearProcedure = function(self)
	self.vehicleId = nil
	self.vehicle = nil
end

return VehicleHUDCtrl
