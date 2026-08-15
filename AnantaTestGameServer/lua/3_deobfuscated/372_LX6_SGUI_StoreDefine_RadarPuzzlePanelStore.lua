C_RadarPuzzlePanelStore = DefClass("C_RadarPuzzlePanelStore", C_RadarPuzzlePanelStore, C_StoreGroup)
GroupName2Class.RadarPuzzlePanelStore = C_RadarPuzzlePanelStore
local M = C_RadarPuzzlePanelStore
local Config = LTConfig.PuzzleIrisPuzzleConfig
local AnimName = {
	Big = "vx_S_RadarPuzzle_SelectBig_loop",
	Mid = "vx_S_RadarPuzzle_SelectMid_loop",
	Small = "vx_S_RadarPuzzle_SelectSmall_loop"
}

function M:ctor()
	return
end

function M:OnAwake()
	self:RegisterEvents()

	self.curDragIndex = 0
	self.curUsed = 0
	self.curLeftCount = {}
	self.ring = {}
	self.Answer = {}
	self.occupiedRing = {}
	self.curSelect = nil

	self:ControlRLBtn(false)

	self.isWin = false
	self.isDragRight = false
	self.startDragPos = nil
	self.curLeftTotal = {}
	self.cfgs = {}
	self.angle = {}
	self.lastIsAtRight = false

	for i = 1, 3 do
		self["pr" .. i] = self.bindData["r" .. i].gameObject:GetLocalPosition()
	end

	for i = 1, 16 do
		self.curLeftCount[i] = {}
		self.curLeftTotal[i] = 0
	end

	self.msgEvents = {
		[gEventConstants.ON_ACTIVE_DEVICE_CHANGED] = self:CreateAction("OnActiveDeviceChanged")
	}

	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnActiveDeviceChanged(eventId, device)
	self.gamepadMode = SGUI.GameDevice.KeyboardMouse < device
end

function M:OnShow(panelId, data)
	if data then
		for i, v in pairs(data) do
			if data[i] then
				self[i] = data[i]
			end
		end
	end

	if not self.puzzleId then
		print_error("光栅的puzzleId配置错误")

		return
	end

	self.cfgs = Config.GetConfig(self.puzzleId)
	local gratingNum = nil

	for r = 1, 4 do
		if #self.cfgs["Grating" .. r] == 16 then
			self.ring[r] = {}
			self["pring" .. r] = self.bindData["ring" .. r].gameObject:GetLocalPosition()

			self:ShowDragRing(self.cfgs, r)

			gratingNum = r
		else
			if #self.cfgs["Grating" .. r] ~= 0 then
				print_error("第" .. r .. "个光栅数组长度配置错误，请策划检查,长度 = ", #self.cfgs["Grating" .. r])
			end

			self.bindData["ring" .. r].gameObject:SetActive(false)
			self.bindData["grey" .. r].gameObject:SetActive(false)

			gratingNum = r - 1

			break
		end
	end

	gratingNum = gratingNum or 4
	self.gratingNum = gratingNum

	for i = 1, #self.cfgs.Answer do
		self.Answer[i] = self.cfgs.Answer[i]

		if self.Answer[i] ~= 0 then
			self:SetGray(self.bindData["p" .. i], i)
		end

		for j = 1, 3 do
			self.angle[j] = 0

			if i >= 1 and i <= 9 then
				self.bindData["r" .. j].gameObject.transform:Find("ring/ring0" .. i).gameObject:SetActive(false)
			else
				self.bindData["r" .. j].gameObject.transform:Find("ring/ring" .. i).gameObject:SetActive(false)
			end

			self:SetSinglePuzzle(self.bindData["p" .. i], 0, self.Answer[i], false)

			self.curLeftCount[i][j] = 0
		end
	end

	self.bindData.panelAnim:Play("vx_S_RadarPuzzlePanel_open")

	if self.gamepadMode then
		self.bindData.select = 1
		self.lastIsAtRight = true
		self.curSelect = 1

		self:ControlRLBtn(false)
		self.bindData.smallAnim:Stop(AnimName.Small)
		self.bindData.midAnim:Stop(AnimName.Mid)
		self.bindData.bigAnim:Stop(AnimName.Big)
	end

	self:SetSelect(1)
end

function M:SetGray(go, index)
	local id = go.gameObject:GetInstanceID()
	local store = self:GetStoreById(id)
	store.bg = 1
end

function M:SetSinglePuzzle(go, color, num, isPlayAnim)
	local id = go.gameObject:GetInstanceID()
	local store = self:GetStoreById(id)

	if store then
		if isPlayAnim then
			store.templateAnim:Play("vx_S_RadarPuzzleTemplate01_loop")
		else
			store.templateAnim:Stop()

			store.bg1.renderOpacity = 1
			store.bg2.renderOpacity = 1
			store.bg3.renderOpacity = 1
		end

		store.color = color
		store.num = num
	end
end

function M:ShowDragRing(cfgs, r)
	for i, v in ipairs(cfgs["Grating" .. r]) do
		if i <= 9 then
			self.bindData["ring" .. r].gameObject.transform:Find("ring/ring0" .. i).gameObject:SetActive(v == 1)
			self.bindData["grey" .. r].gameObject.transform:Find("ring/ring0" .. i).gameObject:SetActive(v == 1)

			self.ring[r][i] = v == 1
		else
			self.bindData["ring" .. r].gameObject.transform:Find("ring/ring" .. i).gameObject:SetActive(v == 1)
			self.bindData["grey" .. r].gameObject.transform:Find("ring/ring" .. i).gameObject:SetActive(v == 1)

			self.ring[r][i] = v == 1
		end
	end
end

function M:OnDestroy()
	self:ClearMessageEvents()
end

local timeCount = 0
local rotateTime = 0.3
local oldAngle, newAngle, rotatingTran = nil

function M:OnUpdate()
	if not self.startRotate then
		return
	end

	timeCount = timeCount + Time.deltaTime

	if rotateTime < timeCount then
		timeCount = rotateTime
		self.startRotate = false
		local tmp = {}

		for i = 1, 16 do
			tmp[i] = self.curLeftCount[i][self.curSelect]
		end

		if self.dir == 1 then
			local last = nil

			for i = 1, 16 do
				if i >= 2 and i <= 16 then
					last = tmp[i - 1]
					self.curLeftCount[i][self.curSelect] = tmp[i - 1]
				else
					last = tmp[16]
					self.curLeftCount[i][self.curSelect] = tmp[16]
				end

				self.curLeftTotal[i] = self.curLeftTotal[i] - tmp[i] + last
			end
		else
			local last = nil

			for i = 1, 16 do
				if i >= 1 and i <= 15 then
					last = tmp[i + 1]
					self.curLeftCount[i][self.curSelect] = tmp[i + 1]
				else
					last = tmp[1]
					self.curLeftCount[i][self.curSelect] = tmp[1]
				end

				self.curLeftTotal[i] = self.curLeftTotal[i] - tmp[i] + last
			end
		end
	end

	self:RefreshResult()

	rotatingTran.localEulerAngles = Vector3.New(0, 0, oldAngle + (newAngle - oldAngle) * timeCount / rotateTime)
end

function M:RegisterEvents()
	self.bindData.ButtonR.luaClick = self:CreateAction("RotateRight")
	self.bindData.ButtonL.luaClick = self:CreateAction("RotateLeft")
	self.bindData.ButtonSwitch.luaClick = self:CreateAction("SwitchSelect")
	self.bindData.ButtonClose.luaClick = self:CreateAction("ClickClose")
	self.bindData.ButtonCancel.luaClick = self:CreateAction("OnCancel")

	for i = 1, 4 do
		self.bindData["ring" .. i].luaClick = self:CreateActionWithArgs("OptionPlayStationClick", i)
		self.bindData["ring" .. i].luaBeginDrag = self:CreateActionWithArgs("OptionDragStart", i)
		self.bindData["ring" .. i].luaDrag = self:CreateActionWithArgs("OptionDrag", i)
		self.bindData["ring" .. i].luaEndDrag = self:CreateActionWithArgs("OptionDragEnd", i)
	end

	for i = 1, 3 do
		self.bindData["r" .. i].luaClick = self:CreateActionWithArgs("SignalClick", i)
		self.bindData["r" .. i].luaBeginDrag = self:CreateActionWithArgs("SignalDragStart", i)
		self.bindData["r" .. i].luaDrag = self:CreateActionWithArgs("SignalDrag", i)
		self.bindData["r" .. i].luaEndDrag = self:CreateActionWithArgs("SignalDragEnd", i)
		self.bindData["r" .. i].luaHover = self:CreateActionWithArgs("OnHover", i)
		self.bindData["r" .. i].luaUnhover = self:CreateActionWithArgs("OnUnHover", i)
	end
end

function M:OnHover(index)
	if self.isDragRight then
		return
	end

	self.bindData["r" .. index].gameObject.transform:SetLocalScale(1.05, 1.05, 1.05)
end

function M:OnUnHover(index)
	if self.isDragRight then
		return
	end

	self.bindData["r" .. index].gameObject.transform:SetLocalScale(1, 1, 1)
end

function M:OnActionDeviceChanged()
	if self.gamepadMode then
		self.lastIsAtRight = true
	end

	if not self.curSelect then
		self.curSelect = 1
		self.bindData.select = 1

		self:ControlRLBtn(false)
	else
		if not self.gamepadMode then
			if self.curSelect == 1 then
				self.bindData.smallAnim:Stop(AnimName.Small)
				self.bindData.smallAnim:Play(AnimName.Small)
			elseif self.curSelect == 2 then
				self.bindData.midAnim:Stop(AnimName.Mid)
				self.bindData.midAnim:Play(AnimName.Mid)
			else
				self.bindData.bigAnim:Stop(AnimName.Big)
				self.bindData.bigAnim:Play(AnimName.Big)
			end

			self:RefreshResult()
		end

		self.bindData.select = self.curSelect

		self:ControlRLBtn(self.occupiedRing[self.curSelect] ~= 0)
	end
end

function M:SignalClick(index)
	if not self.occupiedRing[index] then
		return
	end

	if self:BanOperate() then
		return
	end

	self:SetSelect(index)

	if not self.occupiedRing[index] then
		return
	end

	if self:BanOperate() then
		return
	end

	self:SetSelect(index)
end

function M:OnCancel()
	if self:BanOperate() then
		return
	end

	if not self.occupiedRing[self.curSelect] or not self.curSelect then
		self:ControlRLBtn(false)

		return
	else
		for i = 1, 16 do
			if i >= 1 and i <= 9 then
				self.bindData["r" .. self.curSelect].gameObject.transform:Find("ring/ring0" .. i).gameObject:SetActive(false)
			else
				self.bindData["r" .. self.curSelect].gameObject.transform:Find("ring/ring" .. i).gameObject:SetActive(false)
			end
		end

		self:RemoveRing(self.curSelect)

		if self.curSelect then
			self.bindData.select = self.curSelect
		end

		self:RefreshResult()
	end
end

function M:BanDrag(index, enable)
	for i = 1, 3 do
		if i ~= index then
			if enable then
				if self.occupiedRing[i] then
					self.bindData["r" .. i].draggable = enable
				end
			else
				self.bindData["r" .. i].draggable = enable
			end
		end
	end
end

function M:SignalDragStart(index)
	if self:BanOperate() then
		return
	end

	if not self.occupiedRing[index] then
		self.bindData["r" .. index].draggable = false

		return
	else
		if not self.bindData["r" .. index].draggable then
			self.bindData["r" .. index].draggable = true
		end

		self:SetSelect(index)
		gSoundMgr:PlaySoundByTid(15000088)
		self:BanDrag(self.curSelect, false)
	end
end

function M:SignalDrag(index)
	if not self.curSelect then
		return
	end

	self.bindData["r" .. self.curSelect].gameObject:SetLocalScale(0.5, 0.5, 0.5)
end

function M:SignalDragEnd(index)
	if self:BanOperate() then
		return
	end

	if not self.curSelect then
		return
	end

	self:BanDrag(self.curSelect, true)

	if self:InFingerRange(self.curSelect, 1) then
		for i = 1, 16 do
			if i >= 1 and i <= 9 then
				self.bindData["r" .. self.curSelect].gameObject.transform:Find("ring/ring0" .. i).gameObject:SetActive(false)
			else
				self.bindData["r" .. self.curSelect].gameObject.transform:Find("ring/ring" .. i).gameObject:SetActive(false)
			end
		end

		gSoundMgr:PlaySoundByTid(70850178)
		self.bindData["r" .. self.curSelect].gameObject:SetLocalPosition(self["pr" .. self.curSelect])
		self.bindData["r" .. self.curSelect].gameObject:SetLocalScale(1, 1, 1)
		self:RemoveRing(self.curSelect)
	else
		self.bindData["r" .. self.curSelect].gameObject:SetLocalPosition(self["pr" .. self.curSelect])
		self.bindData["r" .. self.curSelect].gameObject:SetLocalScale(1, 1, 1)
	end

	self:RefreshResult()
end

function M:OptionPlayStationClick(index)
	if not self.bindData["ring" .. index].gameObject:FindChild("ring").gameObject.activeSelf then
		return
	end

	self.lastIsAtRight = true

	self.bindData["ring" .. index].gameObject:FindChild("ring").gameObject:SetActive(false)

	if self.occupiedRing[self.curSelect] then
		for i = 1, 16 do
			if i >= 1 and i <= 9 then
				self.bindData["r" .. self.curSelect].gameObject.transform:Find("ring/ring0" .. i).gameObject:SetActive(false)
			else
				self.bindData["r" .. self.curSelect].gameObject.transform:Find("ring/ring" .. i).gameObject:SetActive(false)
			end
		end

		self:RemoveRing(self.curSelect)
	end

	self:AddRing(index)
	gSoundMgr:PlaySoundByTid(70850178)
	self:RefreshResult()
end

function M:OptionDragStart(index)
	if self:BanOperate() then
		return
	end

	gSoundMgr:PlaySoundByTid(15000088)

	self.curDragIndex = index
	self.isDragRight = true
end

function M:OptionDrag(index)
	if self:BanOperate() then
		return
	end
end

function M:OptionDragEnd(index)
	if self:BanOperate() then
		return
	end

	if self:InFingerRange(index, 2) then
		self.bindData["ring" .. index].gameObject:FindChild("ring").gameObject:SetActive(false)
		self.bindData["ring" .. index].gameObject:SetLocalPosition(self["pring" .. index])
		self:AddRing(index)

		self.isDragRight = false
		self.bindData["ring" .. index].draggable = false

		gSoundMgr:PlaySoundByTid(70850178)
	else
		self.bindData["ring" .. index].gameObject:SetLocalPosition(self["pring" .. index])
	end

	self:RefreshResult()
end

function M:AddRing(index)
	if not self.gamepadMode and self:SignalIsFull() then
		self:RemoveRing(self.curSelect)
	end

	local newIndex = nil
	local lastIndex = self.occupiedRing[self.curSelect]

	if self.gamepadMode then
		newIndex = self.curSelect

		if index ~= lastIndex and lastIndex then
			self.bindData["ring" .. lastIndex].gameObject:FindChild("ring").gameObject:SetActive(true)
		end
	elseif not lastIndex and self.curSelect then
		newIndex = self.curSelect

		if index ~= lastIndex and lastIndex then
			self.bindData["ring" .. lastIndex].gameObject:FindChild("ring").gameObject:SetActive(true)
		end
	else
		newIndex = self:GetEmptyIndex()
	end

	for i = 1, 16 do
		if i >= 1 and i <= 9 then
			self.bindData["r" .. newIndex].gameObject.transform:Find("ring/ring0" .. i).gameObject:SetActive(self.ring[index][i])
		else
			self.bindData["r" .. newIndex].gameObject.transform:Find("ring/ring" .. i).gameObject:SetActive(self.ring[index][i])
		end
	end

	self.bindData["r" .. newIndex].gameObject:SetLocalScale(1, 1, 1)

	self.angle[newIndex] = 0
	self.occupiedRing[newIndex] = index
	local values = {}

	for i = 1, 16 do
		if self.ring[index][i] then
			values[i] = 1
		else
			values[i] = 0
		end
	end

	self:SetSelect(newIndex)
	self:UpdateValue(values, index)
	self:RefreshResult()
end

function M:SetSelect(index)
	self.curSelect = index

	if not index then
		self.bindData.select = 0

		self:ControlRLBtn(false)

		return
	end

	self.bindData.select = index

	if self.occupiedRing[self.curSelect] then
		self:ControlRLBtn(true)
	else
		self:ControlRLBtn(false)
	end

	if index == 1 then
		self.bindData.smallAnim:Stop(AnimName.Small)
		self.bindData.smallAnim:Play(AnimName.Small)
		self.bindData.midAnim:Stop(AnimName.Mid)
		self.bindData.bigAnim:Stop(AnimName.Big)
	elseif index == 2 then
		self.bindData.smallAnim:Stop(AnimName.Small)
		self.bindData.midAnim:Stop(AnimName.Mid)
		self.bindData.midAnim:Play(AnimName.Mid)
		self.bindData.bigAnim:Stop(AnimName.Big)
	else
		self.bindData.smallAnim:Stop(AnimName.Small)
		self.bindData.midAnim:Stop(AnimName.Mid)
		self.bindData.bigAnim:Stop(AnimName.Big)
		self.bindData.bigAnim:Play(AnimName.Big)
	end

	self:RefreshResult()

	if self.bindData["r" .. self.curSelect].draggable == false then
		self.bindData["r" .. self.curSelect].draggable = true
	end
end

function M:RefreshResult()
	for i = 1, 16 do
		local puzzle = self.bindData["p" .. i]

		if self.Answer[i] < self.curLeftTotal[i] and self.Answer[i] ~= 0 then
			self:SetSinglePuzzle(puzzle, 4, self.Answer[i], false)
		else
			local white = self.Answer[i]
			local green = self.curLeftTotal[i]
			local isPlayAnim = false

			if self.Answer[i] ~= 0 then
				if self.curLeftTotal[i] == self.Answer[i] then
					isPlayAnim = true
				else
					isPlayAnim = false
				end
			end

			local store = self:GetStoreById(self.bindData["p" .. i].gameObject:GetInstanceID())

			store.templateAnim:Stop()
			self:SetSinglePuzzle(puzzle, green, white, isPlayAnim)
		end
	end

	self:CheckWin()
end

function M:UpdateValue(values, index)
	for i = 1, 16 do
		self.curLeftCount[i][self.curSelect] = values[i]
	end

	for i = 1, 16 do
		self.curLeftTotal[i] = 0

		for j = 1, 3 do
			self.curLeftTotal[i] = self.curLeftTotal[i] + self.curLeftCount[i][j]
		end
	end
end

function M:ClickClose()
	gCS.CameraDataMgr.cameraControllerManager.IsRotateEnabled = true

	gPanelManager:Close(gPanelId.S_RADAR_PUZZLE_PANEL)
end

function M:ControlRLBtn(isEnable)
	if isEnable then
		self.bindData.ButtonR.interactable = true
		self.bindData.ButtonL.interactable = true
	else
		self.bindData.ButtonR.interactable = false
		self.bindData.ButtonL.interactable = false
	end
end

function M:RotateRight()
	if self:BanOperate() then
		return
	end

	if self.gamepadMode and not self.occupiedRing[self.curSelect] then
		return
	end

	if not self.curSelect then
		return
	end

	self.angle[self.curSelect] = self.angle[self.curSelect] + 1

	self:StartRotate(1)
end

function M:RotateLeft()
	if self:BanOperate() then
		return
	end

	if self.gamepadMode and not self.occupiedRing[self.curSelect] then
		return
	end

	if not self.curSelect then
		return
	end

	self.angle[self.curSelect] = self.angle[self.curSelect] - 1

	self:StartRotate(-1)
end

function M:StartRotate(dir)
	timeCount = 0
	rotatingTran = self.bindData["r" .. self.curSelect].gameObject.transform
	oldAngle = -(self.angle[self.curSelect] - dir) * 22.5
	newAngle = -self.angle[self.curSelect] * 22.5
	self.dir = dir
	self.startRotate = true
end

function M:SwitchSelect()
	if self:BanOperate() then
		return
	end

	self:OnClickSwitch()
end

function M:BanOperate()
	return self.isWin or self.startRotate
end

function M:OnClickSwitch()
	if not self.curSelect then
		self:SetSelect(1)
	end

	self.lastIsAtRight = false

	for i = 1, 2 do
		local index = (self.curSelect + i) % 3

		if index == 0 then
			index = 3
		end

		self:SetSelect(index)

		return
	end
end

function M:SignalIsFull()
	for i = 1, 3 do
		if not self.occupiedRing[i] and i <= self.gratingNum then
			return false
		end
	end

	return true
end

function M:RemoveRing(curSelect)
	local removeRing = self.occupiedRing[curSelect]

	if not self.gamepadMode then
		self.bindData["ring" .. removeRing].gameObject:SetLocalPosition(self["pring" .. removeRing])
	end

	self.bindData["ring" .. removeRing].gameObject:FindChild("ring").gameObject:SetActive(true)

	self.bindData["ring" .. removeRing].draggable = true
	local values = {}

	for i = 1, 16 do
		values[i] = self.curLeftCount[i][curSelect]
	end

	for i = 1, 16 do
		self.curLeftTotal[i] = self.curLeftTotal[i] - values[i]
		self.curLeftCount[i][curSelect] = 0
	end

	self.bindData["r" .. curSelect].gameObject:SetLocalEulerAngles(0, 0, 0)
	self:ShowDragRing(self.cfgs, removeRing)

	self.occupiedRing[curSelect] = nil

	if not self.gamepadMode then
		self.curSelect = nil

		self:ControlRLBtn(false)

		for i = 1, 3 do
			if self.occupiedRing[i] then
				self:SetSelect(i)

				return
			end
		end
	end

	self.bindData.select = 0

	self:ControlRLBtn(false)
end

function M:InFingerRange(index, pos)
	if pos == 1 then
		return Vector3.Magnitude(self.bindData["r" .. index].gameObject.transform.position - self.bindData.centerImage.gameObject.transform.position) <= 100
	else
		return Vector3.Magnitude(self.bindData["ring" .. index].gameObject.transform.position - self.bindData.centerImage.gameObject.transform.position) <= 100
	end
end

function M:GetEmptyIndex()
	for i = 1, 3 do
		if not self.occupiedRing[i] then
			return i
		end
	end
end

function M:CheckWin()
	for i = 1, 16 do
		if self.Answer[i] ~= 0 and self.curLeftTotal[i] ~= self.Answer[i] then
			return
		end
	end

	self.isWin = true

	gSoundMgr:PlaySoundByTid(15000089)
	self.bindData.panelAnim:Play("vx_S_RadarPuzzlePanel_out")
	gSoundMgr:PlaySoundByExternalSource("ExHandle_QTECommon2", LX6.Audio.ExternalSourceType.Motion_2D)

	self.bindData.done = 1

	Timer.New(function ()
		gSpoonClientMgr:ReleaseContextEvent(self.entityInstanceId, gSpoonEventType.OnReceiveSignal, {
			signalKey = self.signalKey,
			entityInstanceId = self.entityInstanceId
		})

		gCS.CameraDataMgr.cameraControllerManager.IsRotateEnabled = true

		gPanelManager:Close(gPanelId.S_RADAR_PUZZLE_PANEL)
	end, 2):Start()
end
