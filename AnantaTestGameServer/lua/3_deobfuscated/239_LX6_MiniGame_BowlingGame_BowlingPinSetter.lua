gBowlingPinSetter = DefClass("BowlingPinSetter", gBowlingPinSetter)
local BowlingPinSetter = gBowlingPinSetter
local Config = require("LX6/MiniGame/BowlingGame/BowlingConfig").Launcher
local BowlingMessageManager = require("LX6/MiniGame/BowlingGame/BowlingMessageManager")
local BowlingConstants = require("LX6/MiniGame/BowlingGame/BowlingConstants")
local DOTween = DG.Tweening.DOTween

function BowlingPinSetter:ctor()
	self:InitData()
end

function BowlingPinSetter:InitData()
	self.pinSpacing = 0.3048
	self.numberOfPins = 10
	self.OffsetZ = 0
	self.currentPinsPattern = nil
end

function BowlingPinSetter:SetSceneNode(node)
	if gClientUtils.NotNil(node) then
		self.sceneNode = node
		local PinPoint = self.sceneNode.transform:Find("PivotNode/PinPointN")

		self:InitializePinPositions(PinPoint.localPosition)
		self:InitializePinPrefab()
	end
end

function BowlingPinSetter:InitializePinPrefab()
	self.pinList = {}
	local clampPrefabPath = Config.prefabPaths.clamp

	gResourceManager:LoadAssetWithCallBack(clampPrefabPath, typeof(UnityEngine.GameObject), function (loadOp)
		if self.hasDestroy then
			gResourceManager:UnloadAssetLoadOp(loadOp)

			return
		end

		self.ClampPfb = loadOp.asset

		self:CreateClamp()
	end)
end

function BowlingPinSetter:InitializePinPositions(pos)
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
			if currentPinIndex <= self.numberOfPins then
				self.pinPositions[currentPinIndex] = Vector3.New(startX - col * colSpacing, center.y, center.z - row * rowSpacing - self.OffsetZ)
				currentPinIndex = currentPinIndex + 1
			end
		end

		if row < math.floor(self.numberOfPins / 2) then
			pinsPerRow = pinsPerRow + 1
		end
	end
end

function BowlingPinSetter:MoveClamp()
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

	self.sequence:Append(tween)
	self.sequence:Append(returnTween)
	self.sequence:AppendCallback(function ()
		if self.hasDestroy then
			return
		end

		self.clampGo:SetActive(false)

		self.sequence = nil
	end)
end

function BowlingPinSetter:ResetPins(bIsInit)
	if self.hasDestroy or self.pinList == nil then
		return
	end

	for _, pin in ipairs(self.pinList) do
		if pin and not pin.hasDestroy then
			pin:Destroy()
		end
	end

	self:MoveClamp()

	self.pinList = {}

	for i = 1, self.numberOfPins do
		local pin = self:CreatePin(i)

		table.insert(self.pinList, pin)
	end

	if not bIsInit then
		self:UpdateStandingPinsState()
	end
end

function BowlingPinSetter:ClearPins()
	if table.isNilOrEmpty(self.pinList) then
		return
	end

	for _, pin in ipairs(self.pinList) do
		if pin and not pin.hasDestroy then
			pin:Destroy()
		end
	end

	self.pinList = nil
end

function BowlingPinSetter:ResetStandingPins()
	if self.hasDestroy then
		return
	end

	if not self.pinList then
		return
	end

	local knockedDownPositions = {}

	for i, pin in ipairs(self.pinList) do
		if pin:CheckKnockedDown() then
			knockedDownPositions[i] = true
		end
	end

	for _, pin in ipairs(self.pinList) do
		if pin and not pin.hasDestroy then
			pin:Destroy()
		end
	end

	table.clear(self.pinList)
	self:MoveClamp()

	for i = 1, self.numberOfPins do
		if not knockedDownPositions[i] then
			local pin = self:CreatePin(i)

			table.insert(self.pinList, pin)
		else
			table.insert(self.pinList, nil)
		end
	end
end

function BowlingPinSetter:CreateClamp()
	if self.hasDestroy then
		return
	end

	self.clampGo = UnityEngine.GameObject.Instantiate(self.ClampPfb, self.sceneNode.transform)

	self.clampGo:SetActive(false)
end

function BowlingPinSetter:CreatePin(i)
	if self.hasDestroy then
		return
	end

	if gClientUtils.IsNil(self.sceneNode) then
		return
	end

	local pinGo = gBowlingGameManager:Rent(gBowlingGameManager.sceneItemType.Pin, self.sceneNode.transform)

	if gClientUtils.IsNil(pinGo) then
		return
	end

	pinGo:SetActive(false)

	local targetPos = self.pinPositions[i]
	local startPos = Vector3(targetPos.x, targetPos.y + 0.7, targetPos.z)
	pinGo.transform.localPosition = startPos
	pinGo.transform.localRotation = Quaternion.identity
	local rigidbody = pinGo:GetComponent(typeof(UnityEngine.Rigidbody))

	if gClientUtils.IsNil(rigidbody) then
		print_error("[BowlingPinSetter] no rigidbody found on ", pinGo.name)
		gBowlingGameManager:Return(gBowlingGameManager.sceneItemType.Pin, pinGo)

		return
	end

	rigidbody.isKinematic = true
	rigidbody.sleepThreshold = 0.05

	pinGo:SetActive(true)

	local pin = gBowlingPin.new({
		gameObject = pinGo,
		index = i,
		centerY = self.center.y
	})

	if pinGo.transform then
		pinGo.transform:DOKill()
	end

	local duration = 1
	self.currentPinTween = pinGo.transform:DOLocalMove(targetPos, duration)

	self.currentPinTween:OnComplete(function ()
		if self.hasDestroy or gClientUtils.IsNil(pinGo) or gClientUtils.IsNil(pinGo.transform) or gClientUtils.IsNil(rigidbody) then
			return
		end

		rigidbody.isKinematic = false
		self.currentPinTween = nil
	end)

	return pin
end

function BowlingPinSetter:Destroy()
	self.hasDestroy = true

	if self.sequence then
		self.sequence:Kill()

		self.sequence = nil
	end

	if self.currentPinTween then
		self.currentPinTween:Kill()

		self.currentPinTween = nil
	end

	self:ClearPins()

	if gClientUtils.NotNil(self.clampGo) then
		gBowlingGameManager:Destroy(self.clampGo)
	end
end

function BowlingPinSetter:CountKnockedDownPins()
	if self.hasDestroy then
		return
	end

	local totalScore = 0

	for _, pin in ipairs(self.pinList) do
		if pin and pin:CheckKnockedDown() then
			totalScore = totalScore + 1
		end
	end

	self:UpdateStandingPinsState(totalScore)

	return totalScore
end

function BowlingPinSetter:hasStandPins()
	if self.hasDestroy then
		return
	end

	local hasStandingPin = false

	for _, pin in ipairs(self.pinList) do
		if pin and not pin.hasDestroy and not pin:CheckKnockedDown() then
			hasStandingPin = true

			break
		end
	end

	return hasStandingPin
end

function BowlingPinSetter:UpdateStandingPinsState(totalScore)
	if self.hasDestroy then
		return
	end

	local standingPins = {}

	for _, pin in ipairs(self.pinList) do
		if pin and not pin.hasDestroy and not pin:CheckKnockedDown() then
			table.insert(standingPins, pin.index)
		end
	end

	local messageToUI = {
		standingPins = standingPins,
		totalScore = totalScore
	}

	BowlingMessageManager:SendMessage(gEventConstants.BOWLING_GAME_PINSTATE, messageToUI)

	if gBowlingGameManager:IsOnlineGame() then
		gBowlingGameManager:BroadcastBowlingClientInfo(BowlingConstants.SyncDataType.RefreshPinStateUI, messageToUI)
	end
end

function BowlingPinSetter:SetPinsPattern(pattern)
	if self.hasDestroy then
		return
	end

	if #pattern ~= self.numberOfPins then
		print_debug("Error: Pattern length does not match pin count")

		return
	end

	self.currentPinsPattern = pattern

	self:ClearPins()
	self:MoveClamp()

	self.pinList = {}

	for i = 1, self.numberOfPins do
		if pattern[i] then
			local pin = self:CreatePin(i)

			table.insert(self.pinList, pin)
		else
			table.insert(self.pinList, nil)
		end
	end

	self:UpdateStandingPinsState()
end

function BowlingPinSetter:GetTotalPins()
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

function BowlingPinSetter:CheckSplit()
	if self.hasDestroy then
		return false
	end

	local standingPins = {}

	for _, pin in ipairs(self.pinList) do
		if pin and not pin.hasDestroy and not pin:CheckKnockedDown() then
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

	local function dfs(pinIndex)
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

	if standingCount <= 1 then
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

function BowlingPinSetter:WakeupAllPins()
	for _, pin in ipairs(self.pinList) do
		if pin and gClientUtils.NotNil(pin.rigidbody) then
			pin.rigidbody.sleepThreshold = 0.01
		end
	end
end
