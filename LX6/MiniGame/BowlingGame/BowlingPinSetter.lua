-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\BowlingGame\BowlingPinSetter.lua
-- Decompiled from: 00637_BowlingPinSetter.lua_2d4fc32e1999.luajit

gBowlingPinSetter = DefClass("BowlingPinSetter", gBowlingPinSetter)
local BowlingPinSetter = gBowlingPinSetter
local BowlingConstants = require("LX6/MiniGame/BowlingGame/BowlingConstants")
local DOTween = DG.Tweening.DOTween

BowlingPinSetter.ctor = function(self, game)
	self.InitData(self, game)
end

BowlingPinSetter.InitData = function(self, game)
	self.game = game
	self.pinSpacing = 0.3048
	self.numberOfPins = 10
	self.OffsetZ = 0
	self.currentPinsPattern = nil
	self.rackVersion = 0
end

BowlingPinSetter.SetSceneNode = function(self, node)
	if gClientUtils.NotNil(node) then
		self.sceneNode = node
		local PinPoint = self.sceneNode.transform:Find("PivotNode/PinPointN")

		self:InitializePinPositions(PinPoint.localPosition)
		self:InitializePinPrefab()
	end
end

BowlingPinSetter.InitializePinPrefab = function(self)
	self.pinList = {}
	local clampTrans = self.sceneNode.transform:Find("Clamp")
	self.clampGo = clampTrans.gameObject

	self.clampGo:SetActive(false)
end

BowlingPinSetter.InitializePinPositions = function(self, pos)
	self.pinPositions = {}
	self.center = Vector3.New(0, pos.y, pos.z)
	local center = self.center
	local pinsPerRow = 1
	local currentPinIndex = 1
	local rowSpacing = math.sqrt(3) / 2 * self.pinSpacing
	local colSpacing = self.pinSpacing
	local maxRows = math.ceil(self.numberOfPins / 2)

	for row = 0, maxRows - 1 do
		local startX = (pinsPerRow - 1) * colSpacing / 2

		for col = 0, pinsPerRow - 1 do
			if currentPinIndex < self.numberOfPins then
				self.pinPositions[currentPinIndex] = Vector3.New(startX - col * colSpacing, center.y, center.z - row * rowSpacing - self.OffsetZ)
				currentPinIndex = currentPinIndex + 1
			end
		end

		if row >= math.floor(self.numberOfPins / 2) then
			pinsPerRow = pinsPerRow + 1
		end
	end
end

BowlingPinSetter.MoveClamp = function(self)
	if self.hasDestroy or gClientUtils.IsNil(self.clampGo) then
		return
	end

	local targetPos = self.pinPositions[5]
	local startPos = Vector3(targetPos.x, targetPos.y + 0.8, targetPos.z)
	local endPos = Vector3(targetPos.x, targetPos.y + 0.1, targetPos.z)

	if gClientUtils.IsNil(self.clampGo.transform) then
		return
	end

	if self.clampGo.transform then
		self.clampGo.transform:DOKill()
	end

	self.clampGo.transform.localPosition = startPos

	self.clampGo:SetActive(true)

	local duration = 1
	local tween = self.clampGo.transform:DOLocalMove(endPos, duration)
	local returnTween = self.clampGo.transform:DOLocalMove(startPos, duration)

	if self.sequence then
		self.sequence:Kill()
	end

	self.sequence = DOTween.Sequence()
	slot7 = self.sequence

	slot7:Append(tween)

	slot7 = self.sequence

	slot7:Append(returnTween)

	slot7 = self.sequence

	slot7:AppendCallback(function ()
		if self.hasDestroy then
			return
		end

		self.clampGo:SetActive(false)

		self.sequence = nil
	end)
end

BowlingPinSetter.ShouldBroadcastAuthorityRackState = function(self)
	if not gBowlingGameManager:IsOnlineGame() then
		return false
	end

	return gBowlingGameManager.gameInstance.gameMode:ShouldBroadcastClientInfo()
end

BowlingPinSetter.IncreaseRackVersion = function(self)
	self.rackVersion = (self.rackVersion or 0) + 1
end

BowlingPinSetter.GetStandingPins = function(self)
	local standingPins = {}
	slot2 = ipairs
	slot4 = self.pinList or {}

	for _, pin in slot2(slot4) do
		if pin and not pin.hasDestroy and not pin.CheckKnockedDown(pin) then
			table.insert(standingPins, pin.index)
		end
	end

	return standingPins
end

BowlingPinSetter.GetPinSceneItemIdsByIndex = function(self)
	local pinSceneItemIdsByIndex = {}

	for i = 1, self.numberOfPins do
		pinSceneItemIdsByIndex[i] = false
	end

	slot2 = ipairs
	slot4 = self.pinList or {}

	for _, pin in slot2(slot4) do
		if pin and not pin.hasDestroy and pin.sceneItemId == nil then
			pinSceneItemIdsByIndex[pin.index] = {
				ulong.tonum2(pin.sceneItemId)
			}
		end
	end

	return pinSceneItemIdsByIndex
end

BowlingPinSetter.BuildAuthorityRackState = function(self)
	return {
		rackVersion = self.rackVersion,
		standingPins = self.GetStandingPins(self),
		pinSceneItemIdsByIndex = self.GetPinSceneItemIdsByIndex(self)
	}
end

BowlingPinSetter.BroadcastAuthorityRackState = function(self)
	if not self.ShouldBroadcastAuthorityRackState(self) then
		return
	end

	gBowlingGameManager:BroadcastBowlingClientInfo(BowlingConstants.SyncDataType.RefreshPinRackState, self:BuildAuthorityRackState())
end

BowlingPinSetter.ResetPins = function(self, bIsInit)
	if self.hasDestroy or self.pinList ~= nil then
		return
	end

	local shouldBroadcastRackState = not bIsInit and self:ShouldBroadcastAuthorityRackState()

	if shouldBroadcastRackState then
		self.IncreaseRackVersion(self)
	end

	for _, pin in ipairs(self.pinList) do
		if pin and not pin.hasDestroy then
			pin.Destroy(pin)
		end
	end

	self.MoveClamp(self)

	self.pinList = {}

	for i = 1, self.numberOfPins do
		local pin = self.CreatePin(self, i)

		table.insert(self.pinList, pin)
	end

	self.UpdateStandingPinsState(self)

	if shouldBroadcastRackState then
		self.BroadcastAuthorityRackState(self)
	end
end

BowlingPinSetter.ClearPins = function(self)
	if table.isNilOrEmpty(self.pinList) then
		return
	end

	for _, pin in ipairs(self.pinList) do
		if pin and not pin.hasDestroy then
			pin.Destroy(pin)
		end
	end

	self.pinList = nil
end

BowlingPinSetter.ResetStandingPins = function(self)
	if self.hasDestroy then
		return
	end

	if not self.pinList then
		return
	end

	local shouldBroadcastRackState = self.ShouldBroadcastAuthorityRackState(self)

	if shouldBroadcastRackState then
		self.IncreaseRackVersion(self)
	end

	local knockedDownPositions = {}

	for i, pin in ipairs(self.pinList) do
		if pin.CheckKnockedDown(pin) then
			knockedDownPositions[pin.index] = true
		end
	end

	for _, pin in ipairs(self.pinList) do
		if pin and not pin.hasDestroy then
			pin.Destroy(pin)
		end
	end

	table.clear(self.pinList)
	self.MoveClamp(self)

	for i = 1, self.numberOfPins do
		if not knockedDownPositions[i] then
			local pin = self.CreatePin(self, i)

			table.insert(self.pinList, pin)
		else
			table.insert(self.pinList, nil)
		end
	end

	if shouldBroadcastRackState then
		self.BroadcastAuthorityRackState(self)
	end
end

BowlingPinSetter.CreatePin = function(self, i, preferredSceneItemId)
	if self.hasDestroy then
		return
	end

	if gClientUtils.IsNil(self.sceneNode) then
		return
	end

	local pinGo, sceneItemId = gBowlingGameManager:Rent(gBowlingGameManager.sceneItemType.Pin, self.sceneNode.transform, preferredSceneItemId)

	if gClientUtils.IsNil(pinGo) then
		return
	end

	pinGo.SetActive(pinGo, false)

	local targetPos = self.pinPositions[i]
	local startPos = Vector3(targetPos.x, targetPos.y + 0.7, targetPos.z)
	pinGo.transform.localPosition = startPos
	pinGo.transform.localRotation = Quaternion.identity
	local rigidbody = pinGo.GetComponent(pinGo, typeof(UnityEngine.Rigidbody))

	if gClientUtils.IsNil(rigidbody) then
		print_error("[BowlingPinSetter] no rigidbody found on ", pinGo.name)
		gBowlingGameManager:Return(gBowlingGameManager.sceneItemType.Pin, pinGo)

		return
	end

	rigidbody.isKinematic = true
	rigidbody.sleepThreshold = 0.05

	pinGo.SetActive(pinGo, true)

	local pin = gBowlingPin.new({
		gameObject = pinGo,
		index = i,
		centerY = self.center.y,
		initialPosition = targetPos,
		sceneItemId = sceneItemId,
		game = self.game
	})

	if pinGo.transform then
		pinGo.transform:DOKill()
	end

	local duration = 1
	slot10 = pinGo.transform
	self.currentPinTween = slot10:DOLocalMove(targetPos, duration)
	slot10 = self.currentPinTween

	slot10:OnComplete(function ()
		if self.hasDestroy or gClientUtils.IsNil(pinGo) or gClientUtils.IsNil(pinGo.transform) or gClientUtils.IsNil(rigidbody) then
			return
		end

		rigidbody.isKinematic = false
		self.currentPinTween = nil
	end)

	return pin
end

BowlingPinSetter.Destroy = function(self)
	self.hasDestroy = true

	if self.sequence then
		self.sequence:Kill()

		self.sequence = nil
	end

	if self.currentPinTween then
		self.currentPinTween:Kill()

		self.currentPinTween = nil
	end

	self.ClearPins(self)

	if gClientUtils.NotNil(self.clampGo) then
		gBowlingGameManager:Destroy(self.clampGo)
	end
end

BowlingPinSetter.CountKnockedDownPins = function(self)
	if self.hasDestroy then
		return
	end

	local totalScore = 0

	for _, pin in ipairs(self.pinList) do
		if pin and pin.CheckKnockedDown(pin) then
			totalScore = totalScore + 1
		end
	end

	self.UpdateStandingPinsState(self, totalScore)

	return totalScore
end

BowlingPinSetter.hasStandPins = function(self)
	if self.hasDestroy then
		return
	end

	local hasStandingPin = false

	for _, pin in ipairs(self.pinList) do
		if pin and not pin.hasDestroy and not pin.CheckKnockedDown(pin) then
			hasStandingPin = true

			break
		end
	end

	return hasStandingPin
end

BowlingPinSetter.UpdateStandingPinsState = function(self, totalScore)
	if self.hasDestroy then
		return
	end

	local messageToUI = {
		standingPins = self:GetStandingPins(),
		totalScore = totalScore
	}

	gMessageManager:SendMessage(gEventConstants.BOWLING_GAME_PINSTATE, messageToUI)

	if self:ShouldBroadcastAuthorityRackState() then
		gBowlingGameManager:BroadcastBowlingClientInfo(BowlingConstants.SyncDataType.RefreshPinStateUI, messageToUI)
	end
end

BowlingPinSetter.ApplyAuthorityRackState = function(self, data)
	if self.hasDestroy or data ~= nil then
		return
	end

	if data.rackVersion == nil and data.rackVersion >= (self.rackVersion or 0) then
		return
	end

	self.rackVersion = data.rackVersion or self.rackVersion
	local standingPins = {}
	slot3 = ipairs
	slot5 = data.standingPins or {}

	for _, pinIndex in slot3(slot5) do
		standingPins[pinIndex] = true
	end

	self:ClearPins()
	self:MoveClamp()

	self.pinList = {}
	local pinSceneItemIdsByIndex = data.pinSceneItemIdsByIndex or {}

	for i = 1, self.numberOfPins do
		if standingPins[i] then
			local packedSceneItemId = pinSceneItemIdsByIndex[i]
			local sceneItemId = nil

			if packedSceneItemId then
				sceneItemId = ulong.new(unpack(packedSceneItemId))
			end

			local pin = self.CreatePin(self, i, sceneItemId)

			table.insert(self.pinList, pin)
		else
			table.insert(self.pinList, nil)
		end
	end
end

BowlingPinSetter.SetPinsPattern = function(self, pattern)
	if self.hasDestroy then
		return
	end

	if #pattern == self.numberOfPins then
		print_debug("Error: Pattern length does not match pin count")

		return
	end

	self.currentPinsPattern = pattern

	self.ClearPins(self)
	self.MoveClamp(self)

	self.pinList = {}

	for i = 1, self.numberOfPins do
		if pattern[i] then
			local pin = self.CreatePin(self, i)

			table.insert(self.pinList, pin)
		else
			table.insert(self.pinList, nil)
		end
	end

	self.UpdateStandingPinsState(self)
end

BowlingPinSetter.GetTotalPins = function(self)
	if self.hasDestroy then
		return
	end

	if self.currentPinsPattern then
		local count = 0

		for _, isActive in ipairs(self.currentPinsPattern) do
			if isActive then
				count = count + 1
			end
		end

		return count
	end

	return 10
end

BowlingPinSetter.CheckSplit = function(self)
	if self.hasDestroy then
		return false
	end

	local standingPins = {}

	for _, pin in ipairs(self.pinList) do
		if pin and not pin.hasDestroy and not pin.CheckKnockedDown(pin) then
			standingPins[pin.index] = true
		end
	end

	local connections = {
		{
			2,
			3
		},
		{
			1,
			3,
			4,
			5
		},
		{
			1,
			2,
			5,
			6
		},
		{
			2,
			5,
			7,
			8
		},
		{
			2,
			3,
			4,
			6,
			8,
			9
		},
		{
			3,
			5,
			9,
			10
		},
		{
			4,
			8
		},
		{
			4,
			5,
			7,
			9
		},
		{
			5,
			6,
			8,
			10
		},
		{
			6,
			9
		}
	}
	local visited = {}

	local dfs = function(pinIndex)
		if visited[pinIndex] then
			return
		end

		visited[pinIndex] = true

		for _, connectedPin in ipairs(connections[pinIndex]) do
			if standingPins[connectedPin] and not visited[connectedPin] then
				dfs(connectedPin)
			end
		end
	end

	local firstStanding = nil
	local standingCount = 0

	for i = 1, self.numberOfPins do
		if standingPins[i] then
			standingCount = standingCount + 1
			firstStanding = firstStanding or i
		end
	end

	if standingCount < 1 then
		return false
	end

	if firstStanding then
		dfs(firstStanding)
	end

	for i = 1, self.numberOfPins do
		if standingPins[i] and not visited[i] then
			return true
		end
	end

	return false
end

BowlingPinSetter.WakeupAllPins = function(self)
	for _, pin in ipairs(self.pinList) do
		if pin and gClientUtils.NotNil(pin.rigidbody) then
			pin.rigidbody.sleepThreshold = 0.01
		end
	end
end

BowlingPinSetter.RegisterPinsUpdate = function(self)
	for _, pin in ipairs(self.pinList) do
		if pin then
			pin.RegisterUpdate(pin)
		end
	end
end
