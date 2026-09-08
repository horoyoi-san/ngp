-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\ShuttlecockGame\Shuttlecock.lua
-- Decompiled from: 00606_Shuttlecock.lua_6e92b0224446.luajit

gShuttlecock = DefClass("Shuttlecock", gShuttlecock, nil)
local Shuttlecock = gShuttlecock
local PEAK_TIME = 0.5
local ARC_SHARPNESS = 1
local HEIGHT_SCALE = 1.2
local SPIN_SPEED = 50
local WOBBLE_AMPLITUDE = 2
local WOBBLE_FREQUENCY = 7
local ROTATION_SMOOTHNESS = 10

Shuttlecock.ctor = function(self, args)
	self.args = args
	self.rawTime = 0
	self.parabolaHeight = 1
	self.moveDuration = 1
	self.normalizedT = 0
	self.moveEnd = true
	self.prevPosition = nil
	self.targetRotation = nil
	self.spinAccum = 0

	self.SpawnShuttlecock(self)
end

Shuttlecock.InitNode = function(self, shuttlecockGameObject)
	self.transform = shuttlecockGameObject.transform
	self.rigidbody = shuttlecockGameObject:GetComponent("Rigidbody")

	self:SetRigidbodyKinematic(true)
	self:SetInitPosition()
	shuttlecockGameObject:SetActive(true)

	self.moveTimer = Timer.New(function ()
		self:NaturalParabolaMove()
	end, 0, -1, false, true)

	self.moveTimer:Start()
end

Shuttlecock.SpawnShuttlecock = function(self)
	local SHUTTLECOCK_PATH = "Res/MiniGame/Prefab/ShuttlecockGame/Shuttlecock.prefab"
	local CUJU_PATH = "Res/env/3dmodels/common/prop/public/common_prop_public_playground001a/p_common_prop_public_playground001a.prefab"
	local game = gShuttlecockGameManager.currentGame
	local isCuJu = game and game.isCuJuVariant
	local ballPath = isCuJu and CUJU_PATH or SHUTTLECOCK_PATH

	gResourceManager:LoadAssetWithCallBack(ballPath, typeof(UnityEngine.GameObject), function (loadOp)
		if self.hasDestroy then
			gResourceManager:UnloadAssetLoadOp(loadOp)
		else
			self.loadOp = loadOp
			local go = UnityEngine.GameObject.Instantiate(self.loadOp.asset)

			self:InitNode(go)
		end
	end)
end

Shuttlecock.SetInitPosition = function(self)
	local parentTransform = self.args.pointTransform

	self.transform:SetParent(parentTransform.parent)

	self.transform.localPosition = Vector3.zero
	self.transform.localRotation = Quaternion.identity
	self.transform.localScale = Vector3.one
	self.initPosition = self.transform.position
end

Shuttlecock.SetRigidbodyKinematic = function(self, value)
	if gClientUtils.NotNil(self.rigidbody) then
		self.rigidbody.isKinematic = value
	end
end

Shuttlecock.NaturalParabolaMove = function(self)
	if self.startPoint ~= nil or self.endPoint ~= nil then
		return
	end

	self.moveEnd = false

	if self.rawTime < 0 then
		self.prevPosition = nil
		self.targetRotation = nil
		self.spinAccum = 0
	end

	self.rawTime = self.rawTime + Time.deltaTime

	if self.moveDuration < self.rawTime then
		self.moveEnd = true
		self.transform.position = self.endPoint

		return
	end

	self.normalizedT = Mathf.Clamp01(self.rawTime / self.moveDuration)
	local vertT = self.GetVerticalArc(self, self.normalizedT)
	self.transform.position = self.CalculateParabola(self, self.startPoint, self.endPoint, self.normalizedT, vertT, self.parabolaHeight * HEIGHT_SCALE)

	self.DoRotate(self)
end

Shuttlecock.GetVerticalArc = function(self, t)
	local p = PEAK_TIME
	local exp = 1 + ARC_SHARPNESS

	if t < p then
		return 1 - (1 - t / p)^exp
	else
		return 1 - ((t - p) / (1 - p))^exp
	end
end

Shuttlecock.CalculateParabola = function(self, startPoint, endPoint, dragT, vertT, height)
	local horizontalPos = Vector3.Lerp(startPoint, endPoint, dragT)
	local yOffset = height * vertT

	return Vector3.New(horizontalPos.x, horizontalPos.y + yOffset, horizontalPos.z)
end

Shuttlecock.DoRotate = function(self)
	if self.prevPosition ~= nil then
		self.prevPosition = Vector3.New(self.transform.position.x, self.transform.position.y, self.transform.position.z)

		return
	end

	local velocity = self.transform.position - self.prevPosition
	self.prevPosition = Vector3.New(self.transform.position.x, self.transform.position.y, self.transform.position.z)

	if velocity.magnitude <= 0.0001 then
		local velDir = velocity.normalized
		self.targetRotation = Quaternion.LookRotation(velDir, Vector3.up)
		self.targetRotation = self.targetRotation * Quaternion.Euler(-90, 0, 0)
	end

	if self.targetRotation then
		self.transform.rotation = Quaternion.Slerp(self.transform.rotation, self.targetRotation, Time.deltaTime * ROTATION_SMOOTHNESS)
	end

	self.transform:Rotate(self.transform.up, SPIN_SPEED * Time.deltaTime)

	local wobble = Mathf.Sin(self.normalizedT * Mathf.PI * WOBBLE_FREQUENCY) * WOBBLE_AMPLITUDE

	self.transform:Rotate(self.transform.right, wobble * Time.deltaTime * 4)
end

Shuttlecock.StopMovement = function(self)
	self.moveEnd = true
	self.startPoint = nil
	self.endPoint = nil
	self.rawTime = 0
end

Shuttlecock.Reset = function(self)
	self.prevPosition = nil
	self.targetRotation = nil
	self.spinAccum = 0
end

Shuttlecock.ResetToInitPosition = function(self)
	self.Reset(self)

	self.rawTime = 0
	self.startPoint = nil
	self.endPoint = nil
	self.moveEnd = true

	if gClientUtils.NotNil(self.transform) then
		self.transform.parent = nil

		self.SetInitPosition(self)
	end
end

Shuttlecock.Destroy = function(self)
end

Shuttlecock.GetBezierPoint = function(self, t, p0, p1, p2)
	local p0p1 = p0 * (1 - t) + p1 * t
	local p1p2 = p1 * (1 - t) + p2 * t

	return p0p1 * (1 - t) + p1p2 * t
end

Shuttlecock.MapDegree = function(self, value, fromSource, toSource, fromTarget, toTarget)
	local normalizedValue = (value - fromSource) / (toSource - fromSource)

	return normalizedValue * (toTarget - fromTarget) + fromTarget
end

Shuttlecock.DestroyGameObject = function(self)
	self.loadOp = gResourceManager:UnloadAssetLoadOp(self.loadOp)

	if self.moveTimer then
		self.moveTimer:Stop()

		self.moveTimer = nil
	end

	if gClientUtils.NotNil(self.transform) then
		self.transform:DOKill()
		UnityEngine.GameObject.Destroy(self.transform.gameObject)
	end

	if self.sequence then
		self.sequence:Kill()

		self.sequence = nil
	end

	self.transform = nil
end
