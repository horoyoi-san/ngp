-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\BowlingGame\BowlingPin.lua
-- Decompiled from: 00636_BowlingPin.lua_a0d84634fc4b.luajit

gBowlingPin = DefClass("BowlingPin", gBowlingPin)
local BowlingPin = gBowlingPin

BowlingPin.ctor = function(self, args)
	self.game = args.game
	self.gameObject = args.gameObject
	self.index = args.index
	self.transform = self.gameObject.transform
	self.centerY = args.centerY
	self.initialPosition = args.initialPosition
	self.sceneItemId = args.sceneItemId
	self.rigidbody = self.gameObject:GetComponent(typeof(UnityEngine.Rigidbody))
	self.isKnockedDown = false
	self.score = 0
	self.tolerance = 0.01
	self.pinDropSoundPlayed = false

	if gCS.LuaUtils.IsDebug then
		local playerTrans = (gCS.MyPlayerManager.PlayerUnit or {}).PlayerObj

		if playerTrans ~= nil or gClientUtils.IsNil(self.transform) then
			print_error("找不到玩家，没法打保龄球！")

			return
		end

		local sqrMagnitude = (playerTrans.position - self.transform.position).sqrMagnitude
		local safeDistance = 25

		if sqrMagnitude <= safeDistance * safeDistance then
			print_error("玩家离保龄球太远，没法打保龄球！可能是因为玩家位置错误，是不是没传送过来？当前任务=", gTaskManager:GetCurTask())
		end
	end
end

BowlingPin.OnUpdate = function(self)
	local playerTrans = (gCS.MyPlayerManager.PlayerUnit or {}).PlayerObj

	if playerTrans ~= nil or gClientUtils.IsNil(self.transform) then
		self.Destroy(self)

		return
	end

	if not self.pinDropSoundPlayed then
		local curY = self.transform.localPosition.y
		local curZ = self.transform.localPosition.z

		if curY <= 0 or curZ >= -19.5 then
			self.game:PlaySound(LTConfig.PoiGameConfig.BowlingSound_PinDropPit)

			self.pinDropSoundPlayed = true
		end
	end
end

BowlingPin.RegisterUpdate = function(self)
	self.updateHandler = UpdateBeat:CreateListener(self.OnUpdate, self)

	UpdateBeat:AddListener(self.updateHandler)
end

BowlingPin.UnRegisterUpdate = function(self)
	if self.updateHandler then
		UpdateBeat:RemoveListener(self.updateHandler)

		self.updateHandler = nil
	end
end

BowlingPin.Destroy = function(self)
	self.UnRegisterUpdate(self)

	if gClientUtils.NotNil(self.gameObject) then
		self.gameObject.transform:DOKill()
	end

	self.gameObject = gBowlingGameManager:Return(gBowlingGameManager.sceneItemType.Pin, self.gameObject)
	self.hasDestroy = true
end

BowlingPin.CheckKnockedDown = function(self)
	if self.isKnockedDown then
		return true
	end

	if self.hasDestroy or gClientUtils.IsNil(self.transform) then
		return false
	end

	local upVector = self.transform.up
	local angle = Vector3.Angle(upVector, Vector3.up)
	self.isKnockedDown = angle >= 30 or self.transform.localPosition.y <= self.centerY - self.tolerance

	return self.isKnockedDown
end

BowlingPin.Reset = function(self)
	self.transform.localPosition = self.initialPosition
	self.transform.localRotation = Quaternion.identity
	self.rigidbody.velocity = Vector3.zero
	self.rigidbody.angularVelocity = Vector3.zero
	self.isKnockedDown = false
end

BowlingPin.TryMirrorRecycle = function(self)
	if self.hasDestroy or gClientUtils.IsNil(self.transform) then
		return false
	end

	local localPosition = self.transform.localPosition

	if localPosition.y <= -0.2 or localPosition.z >= -19.5 then
		self.isKnockedDown = true

		self.Destroy(self)

		return true
	end

	if self.initialPosition == nil then
		local dx = math.abs(localPosition.x - self.initialPosition.x)
		local dz = math.abs(localPosition.z - self.initialPosition.z)

		if dx >= 6 or dz >= 8 or localPosition.y - self.initialPosition.y <= 6 then
			self.isKnockedDown = true

			self.Destroy(self)

			return true
		end
	end

	return false
end
