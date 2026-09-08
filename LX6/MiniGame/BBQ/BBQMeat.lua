-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\BBQ\BBQMeat.lua
-- Decompiled from: 00671_BBQMeat.lua_fd2d77c7dc55.luajit

local BBQConstants = require("LX6/MiniGame/BBQ/BBQConstants")
local MeatState = BBQConstants.MeatState
local MeatCookedLevel = BBQConstants.MeatCookedLevel
gBBQMeat = DefClass("BBQMeat", gBBQMeat)
local BBQMeat = gBBQMeat

BBQMeat.ctor = function(self, args)
	self.id = args.id
	self.meatType = args.meatType
	self.upSideTransform = nil
	self.downSideTransform = nil
	self.upSideRenderer = nil
	self.downSideRenderer = nil
	self.meatData = nil
	self.isPlacedOnGrill = false
	self.isCooking = false
	self.grillPosition = nil
	self.grillRotation = nil
	self.ownerPlayerId = nil
	self.gameObject = UnityEngine.GameObject.Instantiate(args.templateGo)
	self.gameObject.name = string.format("BBQMeat_%d_Type%d", args.id, args.meatType)

	if args.poolParent then
		self.gameObject.transform:SetParent(args.poolParent, true)
	end

	self.gameObject.transform.position = args.position

	self.gameObject:SetActive(true)

	self.upSideTransform = self.gameObject.transform:Find("Sides/1")
	self.downSideTransform = self.gameObject.transform:Find("Sides/2")
	local renderers = self.gameObject:GetComponentsInChildren(typeof(UnityEngine.MeshRenderer))

	if renderers then
		for i = 0, renderers.Length - 1 do
			local r = renderers[i]
			local goName = r.gameObject.name

			if goName ~= "SubMesh_0" then
				self.upSideRenderer = r
				self._defaultUpMaterial = r.sharedMaterial
			elseif goName ~= "SubMesh_1" then
				self.downSideRenderer = r
				self._defaultDownMaterial = r.sharedMaterial
			end
		end
	end

	self.meatData = gBBQMeatData.new(args.meatType)
	self.meatData.uniqueId = args.id
	self.state = MeatState.Dragging
end

BBQMeat.ResetData = function(self)
	self.StopCooking(self)

	self.state = MeatState.OnGrill
	self.isPlacedOnGrill = false
	self.isCooking = false
	self.grillPosition = nil
	self.grillRotation = nil
	self.ownerPlayerId = nil
	self.meatData = gBBQMeatData.new(self.meatType)
	self.meatData.uniqueId = self.id

	if self.upSideRenderer and self._defaultUpMaterial then
		self.upSideRenderer.material = self._defaultUpMaterial
	end

	if self.downSideRenderer and self._defaultDownMaterial then
		self.downSideRenderer.material = self._defaultDownMaterial
	end

	if self.gameObject then
		self.gameObject.transform.rotation = UnityEngine.Quaternion.identity
	end
end

BBQMeat.Deactivate = function(self)
	self.ResetData(self)

	if self.gameObject then
		self.gameObject:SetActive(false)
	end
end

BBQMeat.SetPosition = function(self, pos)
	if self.gameObject then
		self.gameObject.transform.position = pos
	end
end

BBQMeat.SetRotation = function(self, rot)
	if self.gameObject then
		self.gameObject.transform.rotation = rot
	end
end

BBQMeat.RandomizeHorizontalRotation = function(self)
	if not self.gameObject then
		return
	end

	local euler = self.gameObject.transform.localRotation.eulerAngles
	self.gameObject.transform.localRotation = UnityEngine.Quaternion.Euler(euler.x, math.random() * 360, euler.z)
end

BBQMeat.GetPosition = function(self)
	if self.gameObject then
		return self.gameObject.transform.position
	end

	return nil
end

BBQMeat.SetParent = function(self, parent, worldPositionStays)
	if self.gameObject and parent then
		self.gameObject.transform:SetParent(parent, worldPositionStays or false)
	end
end

BBQMeat.SetDragOffset = function(self, yOffset)
	if not self.gameObject then
		return
	end

	local pos = self.gameObject.transform.position
	self.gameObject.transform.position = UnityEngine.Vector3.New(pos.x, pos.y + yOffset, pos.z)
end

BBQMeat.FollowScreenPosition = function(self, screenPos)
	if not self.gameObject then
		return
	end

	local mainCamera = gCS.CameraDataMgr.Instance.MainCamera
	local ray = mainCamera.ScreenPointToRay(mainCamera, Vector3.New(screenPos.x, screenPos.y, 0))
	local currentPos = self.gameObject.transform.position
	local plane = Plane.New(Vector3.up, 0)

	plane.SetNormalAndPosition(plane, Vector3.up, Vector3.New(0, currentPos.y, 0))

	local hit, enter = plane.Raycast(plane, ray)

	if hit then
		local hitPoint = ray.GetPoint(ray, enter)
		self.gameObject.transform.position = hitPoint
	end
end

BBQMeat.OnBeginDrag = function(self)
	if self.state ~= MeatState.OnGrill then
		self.state = MeatState.Dragging

		self.RandomizeHorizontalRotation(self)
		self.SetDragOffset(self, BBQConstants.MeatDragYOffset)
		self.StopCooking(self)
	end
end

BBQMeat.OnEndDrag = function(self, targetPos)
	if self.state == MeatState.Dragging then
		return
	end

	self.state = MeatState.MovingToTarget

	self.MoveToPosition(self, targetPos, function ()
		self:OnMoveComplete()
	end)
end

BBQMeat.OnClick = function(self)
	if self.state ~= MeatState.OnGrill then
		self.state = MeatState.Flipping

		self.DoFlipAnimation(self, function ()
			self.state = MeatState.OnGrill

			self:StartCooking()
		end)
	end
end

BBQMeat.OnMoveComplete = function(self)
	if self.state ~= MeatState.MovingToTarget then
		self.state = MeatState.OnGrill
		self.grillPosition = self:GetPosition()
		self.grillRotation = self.gameObject and self.gameObject.transform.rotation or nil
		self.isPlacedOnGrill = true
		self.ownerPlayerId = nil

		self:StartCooking()

		local putPos = self:GetPosition()

		if putPos then
			gSoundMgr:PlaySoundByTid(BBQConstants.SoundTid.MeatPut, putPos)
		end
	end
end

BBQMeat.OnScored = function(self)
	self.state = MeatState.Scored

	self.StopCooking(self)
end

BBQMeat.OnDragCancelled = function(self, originalPos)
	if self.state ~= MeatState.Dragging then
		self.state = MeatState.MovingToTarget

		self.MoveToPosition(self, originalPos, function ()
			self.state = MeatState.OnGrill
			self.isPlacedOnGrill = true

			self:StartCooking()
		end)
	end
end

BBQMeat.OnReturnToPlate = function(self, targetPos, onComplete)
	self.state = MeatState.MovingToTarget

	self.MoveToPosition(self, targetPos, onComplete)
end

BBQMeat.MoveToPosition = function(self, targetPos, onComplete)
	if not self.gameObject then
		if onComplete then
			onComplete()
		end

		return
	end

	local go = self.gameObject
	local startPos = go.transform.position
	local duration = 0.2
	local elapsed = 0

	coroutine.start(function ()
		while elapsed >= duration do
			if gCS.LuaUtils.IsNull(go) then
				return
			end

			elapsed = elapsed + UnityEngine.Time.deltaTime
			local t = math.min(elapsed / duration, 1)
			go.transform.position = UnityEngine.Vector3.Lerp(startPos, targetPos, t)

			coroutine.wait(0)
		end

		if gCS.LuaUtils.IsNull(go) then
			return
		end

		go.transform.position = targetPos

		if onComplete then
			onComplete()
		end
	end)
end

BBQMeat.DoFlipAnimation = function(self, onComplete)
	if not self.gameObject then
		if onComplete then
			onComplete()
		end

		return
	end

	local flipPos = self.GetPosition(self)

	if flipPos then
		gSoundMgr:PlaySoundByTid(BBQConstants.SoundTid.MeatFlip, flipPos)
	end

	local go = self.gameObject
	local upDot = self:GetUpSideDot()
	local cookingSideIndex = upDot > 0 and 1 or 0
	local groupId = cookingSideIndex ~= 0 and 1 or 0
	local tweens = go:GetComponents(typeof(TweenRotation))

	if tweens then
		for i = 0, tweens.Length - 1 do
			local t = tweens[i]

			if t.tweenGroup ~= groupId then
				t.enabled = true
				local cur = go.transform.localRotation.eulerAngles
				t.from = Vector3.New(cur.x, cur.y, cur.z)
				t.to = Vector3.New(cur.x, cur.y, (groupId ~= 0 and cur.z + 180 or cur.z - 180 + 360) % 360)

				t:ResetToBeginning()
				t:PlayForward()
				coroutine.start(function ()
					coroutine.wait(t.duration)

					if onComplete then
						onComplete()
					end
				end)

				return
			end
		end
	end

	if onComplete then
		onComplete()
	end
end

BBQMeat.StartCooking = function(self)
	self.isCooking = true
end

BBQMeat.StopCooking = function(self)
	self.isCooking = false
end

BBQMeat.UpdateCooking = function(self, getUpSideDot, onBurnt)
	if not self.isCooking or self.meatData.isBurnt then
		return
	end

	local upDot = getUpSideDot(self)
	local cookingSideIndex = 0
	cookingSideIndex = upDot >= 0 and 0 or 1
	local cookingSide = self.meatData.sides[cookingSideIndex]
	cookingSide.timer = cookingSide.timer + UnityEngine.Time.deltaTime

	cookingSide:UpdateCookedLevel(self.meatType, function (direction, level)
		self:UpdateMaterial(direction, level)
	end, function ()
	end)

	if cookingSide.cookedLevel ~= MeatCookedLevel.Burnt then
		self.meatData.isBurnt = true

		self.OnBurnt(self, cookingSideIndex)

		if onBurnt then
			onBurnt(self)
		end
	end
end

BBQMeat.GetUpSideDot = function(self)
	if not self.upSideTransform then
		return 1
	end

	return Vector3.Dot(self.upSideTransform.up, Vector3.up)
end

BBQMeat.UpdateMaterial = function(self, direction, level)
	if level ~= MeatCookedLevel.Raw then
		return
	end

	local material = self.GetMaterialForLevel(self, level)

	if not material then
		print_error(string.format("[BBQMeat] UpdateMaterial failed: material is nil, id=%d meatType=%d direction=%d level=%s", self.id or -1, self.meatType or -1, direction or -1, tostring(level)))

		return
	end

	if direction ~= 0 then
		if self.upSideRenderer then
			self.upSideRenderer.material = material
		else
			print_error(string.format("[BBQMeat] UpdateMaterial failed: upSideRenderer is nil, id=%d meatType=%d level=%s", self.id or -1, self.meatType or -1, tostring(level)))
		end
	elseif direction ~= 1 then
		if self.downSideRenderer then
			self.downSideRenderer.material = material
		else
			print_error(string.format("[BBQMeat] UpdateMaterial failed: downSideRenderer is nil, id=%d meatType=%d level=%s", self.id or -1, self.meatType or -1, tostring(level)))
		end
	else
		print_error(string.format("[BBQMeat] UpdateMaterial failed: invalid direction=%s, id=%d meatType=%d", tostring(direction), self.id or -1, self.meatType or -1))
	end
end

BBQMeat.GetMaterialForLevel = function(self, level)
	if not self._materialProvider then
		print_error(string.format("[BBQMeat] GetMaterialForLevel failed: _materialProvider is nil, id=%d meatType=%d level=%s", self.id or -1, self.meatType or -1, tostring(level)))

		return nil
	end

	local mat = self._materialProvider(self.meatType, level)

	if not mat then
		print_error(string.format("[BBQMeat] GetMaterialForLevel failed: provider returned nil (material not loaded?), id=%d meatType=%d level=%s", self.id or -1, self.meatType or -1, tostring(level)))
	end

	return mat
end

BBQMeat.SetMaterialProvider = function(self, provider)
	self._materialProvider = provider
end

BBQMeat.OnBurnt = function(self, burntSideIndex)
	self:StopCooking()

	local otherSideIndex = burntSideIndex ~= 0 and 1 or 0
	local otherSide = self.meatData.sides[otherSideIndex]
	otherSide.cookedLevel = MeatCookedLevel.Burnt
	otherSide.score = self:GetBurntScore()
	otherSide.timer = 0

	self:UpdateMaterial(otherSideIndex, MeatCookedLevel.Burnt)
end

BBQMeat.GetBurntScore = function(self)
	local BBQConfig = require("LX6/MiniGame/BBQ/BBQConfig")
	local configs = BBQConfig.MeatCookConfigs[self.meatType]

	if configs then
		for _, cfg in ipairs(configs) do
			if cfg.level ~= MeatCookedLevel.Burnt then
				return cfg.score
			end
		end
	end

	return -10
end

BBQMeat.GetTotalScore = function(self)
	return self.meatData:GetTotalScore()
end

BBQMeat.Destroy = function(self)
	self.StopCooking(self)

	if self.gameObject and not gCS.LuaUtils.IsNull(self.gameObject) then
		UnityEngine.Object.Destroy(self.gameObject)
	end

	self.gameObject = nil
	self.meatDefine = nil
	self.meatData = nil
	self._materialProvider = nil
end
