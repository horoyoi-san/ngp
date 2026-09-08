-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\FishingGame\FishingGameFloat.lua
-- Decompiled from: 00599_FishingGameFloat.lua_766017640434.luajit

C_FishingGameFloat = DefClass("C_FishingGameFloat", C_FishingGameFloat)
local M = C_FishingGameFloat
local GameObject = UnityEngine.GameObject

M.ctor = function(self, float)
	self.transform = float
	self.arcHeight = 6
	self.modelAniStep = 0
	self.modelTime = 0
	self.modelRotation = nil
end

M.SetData = function(self, system, pos)
	self.system = system

	self.SetPos(self, pos)
	self.SetModel(self)
end

M.SetModel = function(self)
	local num = math.random(1, 2)
	local path = string.format("Res/MiniGame/Prefab/FishingGame/Float%d.prefab", num)
	local result = gResourceManager:LoadAsset(path, typeof(GameObject))
	self.modelGO = UnityEngine.GameObject.Instantiate(result.asset)
	self.modelTF = self.modelGO.transform

	self.modelTF:SetParent(self.transform, false)
	self:SetModelRotation(Quaternion.identity, true)
	self:SetDisplay(true)
end

M.Update = function(self)
	self.CheckMove(self)
	self.CheckModelAni(self)
	self.CheckModelRotation(self)
end

M.Clear = function(self)
	self.ClearMoveEffect(self)

	self.modelAniStep = 0
	self.modelRotation = nil
end

M.Destroy = function(self)
	self.Clear(self)

	if self.modelGO == nil then
		GameObject.Destroy(self.modelGO)

		self.modelGO = nil
	end
end

M.MoveTo = function(self, targetPos, callback)
	self.targetPos = targetPos
	self.callback = callback
	self.pos = self.transform.position
	self.distPos = self.pos - targetPos
	self.moveTime = 0
	self.prevPos = self.pos
	self.needTime = 1.4
end

M.SetDisplay = function(self, isModel)
	self.modelGO:SetActive(isModel)
end

M.PlayMoveEffect = function(self)
	if self.moveEffect ~= nil then
		self.moveEffect = self.system.effectMgr:Add(gFishingGameConst.FishingGameEffectType.FloatMove, self.transform, Vector3.zero)
	end
end

M.ClearMoveEffect = function(self)
	if self.startMoveEffect == nil then
		self.system.effectMgr:Remove(self.startMoveEffect)

		self.startMoveEffect = nil
	end

	if self.moveEffect == nil then
		self.system.effectMgr:Remove(self.moveEffect)

		self.moveEffect = nil
	end
end

M.PlayEntryEffect = function(self)
	local num = math.random(1, 2)

	if num ~= 1 then
		self.system.effectMgr:Add(gFishingGameConst.FishingGameEffectType.FloatEntry, self.transform, Vector3.zero, 1)
	else
		self.system.effectMgr:Add(gFishingGameConst.FishingGameEffectType.FloatEntry2, self.transform, Vector3.zero, 1)
	end
end

M.CheckMove = function(self)
	if self.targetPos ~= nil then
		return
	end

	self.moveTime = self.moveTime + Time.deltaTime
	local t = Mathf.Clamp01(self.moveTime / self.needTime)

	if t >= 1 then
		local p = self.pos - self.distPos * t
		local oy = Mathf.Sin(t * Mathf.PI) * self.arcHeight
		p.y = p.y + oy
		self.transform.position = p
		local direction = FishingGameUtil.GetDirection(self.prevPos, p)
		local rotation = Quaternion.LookRotation(direction, Vector3.right)
		self.modelTF.localRotation = rotation
		self.prevPos = p
	else
		self.SetPos(self, self.targetPos)

		self.modelTF.localRotation = Quaternion.identity
		self.targetPos = nil
		local callback = self.callback
		self.callback = nil

		if callback == nil then
			callback()
		end
	end
end

M.PlayModelAni = function(self)
	self.modelAniStep = 1
	self.modelAniTime = 0
	self.modelAniEndTime = 0.5
	self.modelAniY = 0
	self.modelAniMaxY = 0.05

	if self.startMoveEffect == nil then
		self.system.effectMgr:Remove(self.startMoveEffect)

		self.startMoveEffect = nil
	end

	self.startMoveEffect = self.system.effectMgr:Add(gFishingGameConst.FishingGameEffectType.FloatStartMove, self.transform, Vector3.zero, 1)
end

M.CheckModelAni = function(self)
	if self.modelAniStep ~= 0 then
		return
	end

	local pos = self.modelTF.localPosition

	if self.modelAniStep ~= 1 then
		self.modelAniTime = self.modelAniTime + Time.deltaTime
		pos.y = FishingGameUtil.SmoothDamp(self.modelAniY, self.modelAniMaxY, self.modelAniEndTime, self.modelAniTime)

		if self.modelAniEndTime < self.modelAniTime then
			self.modelAniStep = -1
			self.modelAniTime = 0
		end
	elseif self.modelAniStep ~= -1 then
		if self.system.isAttractFishReelin then
			self.PlayMoveEffect(self)

			return
		end

		self.modelAniTime = self.modelAniTime + Time.deltaTime
		pos.y = FishingGameUtil.SmoothDamp(self.modelAniMaxY, self.modelAniY, self.modelAniEndTime, self.modelAniTime)

		if self.modelAniEndTime < self.modelAniTime then
			self.modelAniStep = 0

			self.ClearMoveEffect(self)
		end
	end

	self.modelTF.localPosition = pos
end

M.CheckModelRotation = function(self)
	if self.modelRotation == nil then
		self.modelTime = self.modelTime + Time.deltaTime * 5
		self.transform.localRotation = Quaternion.Lerp(self.transform.localRotation, self.modelRotation, self.modelTime)
	end
end

M.GetPos = function(self)
	return self.transform.position
end

M.SetPos = function(self, pos)
	self.transform.position = pos
end

M.SetModelRotation = function(self, rotation, immediate)
	self.modelTime = 0
	self.modelRotation = rotation

	if immediate then
		self.modelTF.localRotation = rotation
	end
end
