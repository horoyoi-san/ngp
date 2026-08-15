local PopupConfig = LTConfig.PopupConfig
C_NewPopupManager = DefClass("C_NewPopupManager", C_NewPopupManager)
local M = C_NewPopupManager

function M:ctor()
	self.DEBUG = false
	self.GameScene = LX6.Scene.SwitchSceneManager.GameStage.GameScene
	self.popupLine = {}
	self.popupLineEnable = {}
	self.popupLineEnableCount = 0
	self.groupMode = false
	self.groupId = nil
	self.groupLine = nil
	self.groupCell = nil
	self.pause = false
	self.gmStop = false
	self.tgsStop = false
	self.areaFiveEnable = true
	self.AREA_FIVE_CONTROL = {
		GUIDE = 0
	}
	self.areaFiveControlDict = {}
	self.areaFiveControlCount = 0
	self.currId = 0
	self.MAX_ID = 1000000
	self.msgEvents = {}
end

function M:OnInit()
	for _, line in pairs(PopupConfig.LineType) do
		self.popupLine[line] = C_PopupLine.new(line)

		self.popupLine[line]:OnInit()

		self.popupLineEnable[line] = false
	end

	for event, func in pairs(self.msgEvents) do
		gMessageManager:AddMessageListener(event, func)
	end
end

function M:SetLineEnable(line)
	if not self.popupLineEnable[line] then
		if self.DEBUG then
			print_notice("PopupUpdateRegister => SetLineEnable", line)
		end

		self.popupLineEnable[line] = true

		if self.popupLineEnableCount == 0 then
			if self.DEBUG then
				print_notice("PopupUpdateRegister => RegisterUpdate")
			end

			gLuaClient:RegisterDynamicUpdate("gNewPopupManager", self)
		end

		self.popupLineEnableCount = self.popupLineEnableCount + 1
	end
end

function M:SetLineDisable(line)
	if self.popupLineEnable[line] then
		if self.DEBUG then
			print_notice("PopupUpdateRegister => SetLineDisable", line)
		end

		self.popupLineEnable[line] = false
		self.popupLineEnableCount = self.popupLineEnableCount - 1

		if self.popupLineEnableCount == 0 then
			if self.DEBUG then
				print_notice("PopupUpdateRegister => UnregisterUpdate")
			end

			gLuaClient:UnregisterDynamicUpdate("gNewPopupManager")
		end
	end
end

function M:GenID()
	self.currId = self.currId + 1

	if self.MAX_ID < self.currId then
		self.currId = 0
	end

	return self.currId
end

function M:OnBeforeSwitchScene(switchType)
	self:CloseAllActivePopup()

	if switchType == gSwitchSceneType.KickToLogin then
		for _, line in pairs(self.popupLine) do
			line:Clear()
		end
	end
end

function M:OnUpdate()
	if self.gmStop then
		return
	end

	for _, line in pairs(self.popupLine) do
		line:ForceUpdate()
	end

	if gLuaDataManager.gameStage ~= self.GameScene or gBlackScreenManager:IsOccupied() or gLuaDataManager.isLoadingPanelOn then
		return
	end

	for _, line in pairs(self.popupLine) do
		line:Update()
	end
end

function M:PushPopup(typeId, data)
	if self:CheckPopupDisable() then
		if self.DEBUG then
			print_notice("NewPopupManager => PushPopup fail! CheckPopupDisable() = true")
		end

		return
	end

	local id = self:GenID()
	local cell = C_SinglePopupCell.new(id, typeId, data)

	if self.groupMode then
		self.groupCell:AddToGroup(cell)
	else
		self.popupLine[cell:GetLine()]:AddPopup(cell)
	end

	if self.DEBUG then
		print_notice("NewPopupManager => PushPopup success! id=", id, "type=", typeId, "groupMode=", self.groupMode, "line=", self.groupMode and self.groupLine or cell:GetLine())
	end

	return id
end

function M:RemovePopup(uuId)
	if self.gmStop then
		if self.DEBUG then
			print_notice("NewPopupManager => RemovePopup fail! gmStop = true")
		end

		return
	end

	if self.groupMode and self.groupCell:Match(uuId) then
		self.groupCell:RemoveFromGroup(uuId)

		if self.DEBUG then
			print_notice("NewPopupManager => RemovePopup success! Remove from group, uuId=", uuId)
		end

		return true
	end

	for _, line in pairs(self.popupLine) do
		if line:RemovePopup(uuId) then
			if self.DEBUG then
				print_notice("NewPopupManager => RemovePopup success! Remove from line, uuId=", uuId)
			end

			return true
		end
	end

	if self.DEBUG then
		print_notice("NewPopupManager => RemovePopup fail! No match popup, uuId=", uuId)
	end

	return false
end

function M:BeginPopupGroup(line)
	if self:CheckPopupDisable() then
		if self.DEBUG then
			print_notice("NewPopupManager => 【group】BeginPopupGroup fail! CheckPopupDisable() = true")
		end

		return
	end

	if self.groupMode then
		print_error("NewPopupManager => 【group】BeginPopUpGroup 重复调用，已经是group模式了")

		return
	end

	self.groupMode = true
	self.groupId = self:GenID()
	self.groupLine = line
	self.groupCell = C_GroupPopupCell.new(self.groupId)

	if self.DEBUG then
		print_notice("NewPopupManager => 【group】BeginPopupGroup success! groupId=", self.groupId, "groupLine=", self.groupLine)
	end

	return self.groupId
end

function M:EndPopupGroup()
	if self:CheckPopupDisable() then
		if self.DEBUG then
			print_notice("NewPopupManager => 【group】EndPopupGroup fail! CheckPopupDisable() = true")
		end

		return
	end

	if not self.groupMode then
		print_error("NewPopupManager => 【group】没有调用BeginPopUpGroup，当前不是group模式")

		return
	end

	local groupId = self.groupId

	self.popupLine[self.groupLine]:AddPopup(self.groupCell)

	self.groupMode = false
	self.groupId = nil
	self.groupLine = nil
	self.groupCell = nil

	if self.DEBUG then
		print_notice("NewPopupManager => 【group】EndPopupGroup success! groupId=", groupId)
	end

	return groupId
end

function M:ClearPopupGroup()
	if self.DEBUG then
		print_notice("NewPopupManager => ClearPopupGroup")
	end

	if not self.groupMode then
		return
	end

	self.groupMode = false
	self.groupId = nil
	self.groupLine = nil

	self.groupCell:OnDispose()

	self.groupCell = nil
end

function M:CloseAllActivePopup()
	if self.DEBUG then
		print_notice("NewPopupManager => CloseAllActivePopup")
	end

	for _, line in pairs(self.popupLine) do
		line:BreakPopup(gPopupBreakReason.BREAK_AND_PUSH_BACK)
	end
end

function M:Clear()
	if self.DEBUG then
		print_notice("NewPopupManager => Clear")
	end

	self:ClearPopupGroup()

	for _, line in pairs(self.popupLine) do
		line:Clear()
	end
end

function M:CheckAreaHasPopup(area)
	for _, line in pairs(self.popupLine) do
		if line:CheckAreaHasPopup(area) then
			return true
		end
	end

	return false
end

function M:SetPause(pause)
	if pause ~= self.pause then
		self.pause = pause
	end
end

function M:SetAreaFiveEnable(control, enable)
	if enable then
		if self.areaFiveControlDict[control] then
			self.areaFiveControlDict[control] = nil
			self.areaFiveControlCount = self.areaFiveControlCount - 1
			local enb = self.areaFiveControlCount == 0

			if self.areaFiveEnable ~= enb then
				self.areaFiveEnable = enb
			end
		end
	elseif not self.areaFiveControlDict[control] then
		self.areaFiveControlDict[control] = true
		self.areaFiveControlCount = self.areaFiveControlCount + 1
		local enb = false

		if self.areaFiveEnable ~= enb then
			self.areaFiveEnable = enb

			for _, line in pairs(self.popupLine) do
				line:BreakPopupAreaFive(gPopupBreakReason.BREAK_AND_PUSH_BACK)
			end
		end
	end
end

function M:GetAreaFiveEnable()
	return self.areaFiveEnable
end

function M:GmStopPopup(stop)
	self.gmStop = stop

	if stop then
		self:CloseAllActivePopup()
		self:Clear()
	end
end

function M:CheckPopupDisable()
	return self.gmStop or self.tgsStop
end

function M:DumpPopupInfo()
	local baseInfo = string.format("----------DumpPopupInfo----------\n")
	local modeInfo = string.format("ModeInfo: groupMode=%s, groupId=%s, groupLine=%s, groupCurrCount=%s \n", self.groupMode, self.groupMode and self.groupId or "nil", self.groupMode and self.groupLine or "nil", self.groupMode and self.groupCell:GetWaitNum() or "nil")
	local pauseInfo = gPopupPauseManager:DumpPopupInfo()
	local areaFiveInfo = string.format("AreaFiveInfo: enable=%s, controlCount=%d controlDetail=\n", self.areaFiveEnable, self.areaFiveControlCount)

	for reason, _ in pairs(self.areaFiveControlDict) do
		areaFiveInfo = areaFiveInfo .. reason .. " / "
	end

	areaFiveInfo = areaFiveInfo .. "\n"

	print_warn(baseInfo, pauseInfo, modeInfo, areaFiveInfo)

	for _, line in pairs(self.popupLine) do
		print_warn(line:DumpInfo())
	end
end

gNewPopupManager = gNewPopupManager or C_NewPopupManager.new()
