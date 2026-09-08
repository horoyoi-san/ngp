-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\FishingGame\FishingGameFish.lua
-- Decompiled from: 00601_FishingGameFish.lua_b98fb0dec0db.luajit

C_FishingGameFish = DefClass("C_FishingGameFish", C_FishingGameFish)
local M = C_FishingGameFish
local GameObject = UnityEngine.GameObject

M.ctor = function(self, fishGO, parent)
	self.gameObject = GameObject.Instantiate(fishGO)
	self.transform = self.gameObject.transform

	self.transform:SetParent(parent, false)

	self.animator = self.transform:Find("player"):GetComponent("Animator")
	self.rootTF = self.transform:Find("player/Reference/MotionRoot/Root")
	self.mouthTF = self.transform:Find("player/Reference/MotionRoot/Root/head/head_end")
	self.offset = self.mouthTF.localPosition
	self.isLive = true
	self.aiTime = 0
	self.action = ""
	self.isAttract = false
	self.isLookAt = false
end

M.SetData = function(self, system, data, config)
	self.system = system
	self.data = data
	self.config = config
	self.gameObject.name = "fish" .. data.id
	self.rootTF.localScale = Vector3.New(data.scale, data.scale, data.scale)

	self.PlayAction(self, gFishingGameConst.FishingGameAction.Idle)
	self.SetPos(self, data.pos)
end

M.TakeFish = function(self, parent, offset, rotation)
	self.targetPos = nil

	self:ClearFlounderEffect(false)
	self:PlayAction(gFishingGameConst.FishingGameAction.TakeFish)
	self.transform:SetParent(parent, false)

	self.transform.localPosition = offset
	self.transform.localRotation = rotation
end

M.PlayAction = function(self, action)
	self:ClearAction()

	self.action = action

	self.animator:SetBool(action, true)
end

M.Pause = function(self)
	self.animator.speed = 0
end

M.Resume = function(self)
	self.animator.speed = 1
end

M.ClearAction = function(self)
	self.animator:SetBool(gFishingGameConst.FishingGameAction.Idle, false)
	self.animator:SetBool(gFishingGameConst.FishingGameAction.Bite, false)
	self.animator:SetBool(gFishingGameConst.FishingGameAction.Swim, false)
	self.animator:SetBool(gFishingGameConst.FishingGameAction.Flounder, false)
	self.animator:SetBool(gFishingGameConst.FishingGameAction.Exhausted, false)
	self.animator:SetBool(gFishingGameConst.FishingGameAction.TakeFish, false)
end

M.SetSpeed = function(self, speed)
	self.animator:SetFloat(gFishingGameConst.FishingGameAction.Speed, speed)
end

M.Update = function(self)
	self.CheckAI(self)
	self.CheckLookAt(self)
	self.CheckMove(self)
end

M.Clear = function(self)
	self.ClearFlounderEffect(self, true)
	self.ClearMove(self)

	self.system = nil
	self.data = nil
	self.config = nil
end

M.Destroy = function(self)
	self.Clear(self)

	if self.gameObject == nil then
		GameObject.Destroy(self.gameObject)

		self.gameObject = nil
	end
end

M.MoveTo = function(self, targetPos, time, lookAt, ignoreY)
	self.targetPos = targetPos
	self.pos = self:GetPos()
	self.distPos = self.pos - self.targetPos
	local distance = gUtils:GetXZDistance(self.pos, self.targetPos)
	self.startTime = Time.time
	self.isLookAt = false
	local isFlounder = self:IsFlounder()

	if time == nil then
		self.endTime = self.startTime + time

		if lookAt then
			self.LookAt(self, self.targetPos, ignoreY)
		end
	else
		if lookAt then
			if not isFlounder then
				local lookAtDir = self.targetPos - self.pos

				if ignoreY then
					lookAtDir.y = 0
				end

				if lookAtDir.Magnitude(lookAtDir) <= 1e-06 then
					local angle = Vector3.Angle(self.transform.forward, lookAtDir)
					self.lookAtTime = 0
					self.lookAtNeedTime = angle / 500
					self.startTime = self.startTime + self.lookAtNeedTime
					self.lookAtRotation = Quaternion.LookRotation(lookAtDir, Vector3.up)
					self.isLookAt = true
				end
			else
				self.LookAt(self, self.targetPos, ignoreY)
			end
		end

		if self.isAttract then
			if isFlounder then
				self.endTime = self.startTime + distance / self.config.spendStruggle
			else
				self.endTime = self.startTime + distance / self.config.spendNormal
			end
		else
			self.endTime = self.startTime + distance / self.config.spendRest
		end
	end

	self.aiTime = self.endTime + self.config.idleTime

	if isFlounder then
		self.PlayAction(self, gFishingGameConst.FishingGameAction.Flounder)
		self.PlayFlounderEffect(self)
	else
		self.PlayAction(self, gFishingGameConst.FishingGameAction.Swim)
		self.ClearFlounderEffect(self, false)
	end
end

M.ClearMove = function(self)
	self.targetPos = nil
	self.pos = nil
	self.distPos = nil
	self.lookAtRotation = nil
end

M.IsFlounder = function(self)
	if self.system.fish == self then
		return false
	end

	local sysTime = Time.time

	if sysTime >= self.data.flounderTime then
		return true
	end

	if sysTime >= self.data.flounderCDTime then
		return false
	end

	local time = math.random(self.config.struggleTimeMin, self.config.struggleTimeMax)
	self.data.flounderTime = sysTime + time
	local cdTime = math.random(self.config.struggleCdMin, self.config.struggleCdMax)
	self.data.flounderCDTime = sysTime + time + cdTime

	return true
end

M.Reelin = function(self, offset)
	if self.IsMove(self) then
		self.targetPos.x = self.targetPos.x - offset.x
		self.targetPos.z = self.targetPos.z - offset.z
		self.pos.x = self.pos.x - offset.x
		self.pos.z = self.pos.z - offset.z
	else
		local pos = self.GetPos(self)
		pos.x = pos.x - offset.x
		pos.z = pos.z - offset.z

		self.SetPos(self, pos)
	end
end

M.PlayFlounderEffect = function(self)
	if self.flounderWaveEffect == nil and self.flounderWaveEffect.isLive then
		self.system.effectMgr:Resume(self.flounderWaveEffect, Vector3.New(0, 0.4, 0))
	else
		self.flounderWaveEffect = self.system.effectMgr:Add(gFishingGameConst.FishingGameEffectType.FishFlounderWaveEffect, self.transform, Vector3.New(0, 0.4, 0))
	end

	if self.flounderWaterEffect == nil and self.flounderWaterEffect.isLive then
		self.system.effectMgr:Resume(self.flounderWaterEffect, Vector3.New(0, 0.4, 0))
	else
		self.flounderWaterEffect = self.system.effectMgr:Add(gFishingGameConst.FishingGameEffectType.FishFlounderWaterEffect, self.transform, Vector3.New(0, 0.4, 0))
	end
end

M.ClearFlounderEffect = function(self, kill)
	if self.flounderWaveEffect == nil then
		if kill then
			self.system.effectMgr:Remove(self.flounderWaveEffect)

			self.flounderWaveEffect = nil
		else
			self.system.effectMgr:DelayHide(self.flounderWaveEffect, 0.2)
		end
	end

	if self.flounderWaterEffect == nil then
		if kill then
			self.system.effectMgr:Remove(self.flounderWaterEffect)

			self.flounderWaterEffect = nil
		else
			self.system.effectMgr:DelayHide(self.flounderWaterEffect, 0.2)
		end
	end
end

M.CheckMove = function(self)
	if self.targetPos ~= nil then
		return
	end

	if self.isLookAt then
		return
	end

	local time = Time.time

	if time >= self.endTime then
		local percent = (time - self.startTime) / (self.endTime - self.startTime)
		local p = self.pos - self.distPos * (percent >= 0 and 0 or percent)

		self:SetPos(p)
	else
		self.SetPos(self, self.targetPos)

		if not self.IsFlounder(self) then
			self.PlayAction(self, gFishingGameConst.FishingGameAction.Idle)
		end

		self.targetPos = nil
		self.pos = nil
	end
end

M.CheckAI = function(self)
	if self.isAttract or Time.time < self.aiTime then
		return
	end

	local refreshFishPosition = FishingGameConfig.ConstantsConfig.refreshFishPosition
	local refreshFishRange = FishingGameConfig.ConstantsConfig.refreshFishRange
	local targetPos = Vector3.New(refreshFishPosition[1], 0, refreshFishPosition[3])
	targetPos.x = targetPos.x + math.random(-refreshFishRange[1], refreshFishRange[1])
	targetPos.z = targetPos.z + math.random(-refreshFishRange[2], refreshFishRange[2])
	targetPos = self.transform.parent:TransformPoint(targetPos)
	targetPos.y = self.data.pos.y

	self:MoveTo(targetPos, nil, true, true)
end

M.IsMove = function(self)
	return self.targetPos == nil
end

M.LookAt = function(self, lookPos, ignoreY)
	local direction = lookPos - self.GetPos(self)

	if ignoreY then
		direction.y = 0
	end

	if direction.Magnitude(direction) <= 1e-06 then
		self.transform.localRotation = Quaternion.LookRotation(direction, Vector3.up)
	end
end

M.CheckLookAt = function(self)
	if not self.isLookAt then
		return
	end

	self.lookAtTime = self.lookAtTime + Time.deltaTime

	if self.targetPos == nil then
		if self.lookAtNeedTime < self.lookAtTime then
			self.transform.localRotation = self.lookAtRotation
			self.isLookAt = false
		else
			local t = Mathf.Clamp01(self.lookAtTime / self.lookAtNeedTime)
			local rotation = Quaternion.LookRotation(self.transform.forward, Vector3.up)
			self.transform.localRotation = Quaternion.Lerp(rotation, self.lookAtRotation, t)
		end
	else
		self.isLookAt = false
	end
end

M.GetPos = function(self)
	return self.transform.position
end

M.SetPos = function(self, pos)
	self.transform.position = pos
end

M.SetRotation = function(self, rotation)
	self.transform.localRotation = rotation
end

M.GetForward = function(self)
	return self.transform.forward
end

M.GetMouthPos = function(self)
	return self.mouthTF.position
end
