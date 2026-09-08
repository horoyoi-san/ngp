-- Original chunk: @Lua\LuaFiles\LX6\Manager\Popup\NewPopupManager.lua
-- Decompiled from: 00722_NewPopupManager.lua_0f968ea7afed.luajit

local PopupConfig = LTConfig.PopupConfig
C_NewPopupManager = DefClass("C_NewPopupManager", C_NewPopupManager)
local M = C_NewPopupManager

M.ctor = function(self)
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
	self.XSRaid = false
	self.areaFiveEnable = true
	self.AREA_FIVE_CONTROL = {
		["j\\x9b\\x8b\\x8b\\x93"] = 0
	}
	self.areaFiveControlDict = {}
	self.areaFiveControlCount = 0
	self.currId = 0
	self.MAX_ID = 1000000
	self.msgEvents = {
		[gEventConstants.CHANGE_MY_UNIT] = self:CreateAction("OnSpiritChange")
	}
end

M.OnInit = function(self)
	for _, line in pairs(PopupConfig.LineType) do
		self.popupLine[line] = C_PopupLine.new(line)

		self.popupLine[line]:OnInit()

		self.popupLineEnable[line] = false
	end

	for event, func in pairs(self.msgEvents) do
		gMessageManager:AddMessageListener(event, func)
	end
end

M.SetLineEnable = function(self, line)
	if not self.popupLineEnable[line] then
		if self.DEBUG then
			print_notice("PopupUpdateRegister => SetLineEnable", line)
		end

		self.popupLineEnable[line] = true

		if self.popupLineEnableCount ~= 0 then
			if self.DEBUG then
				print_notice("PopupUpdateRegister => RegisterUpdate")
			end

			gLuaClient:RegisterDynamicUpdate("gNewPopupManager", self)
		end

		self.popupLineEnableCount = self.popupLineEnableCount + 1

		gMessageManager:SendMessageMultiParamLuaOnly(gEventConstants.POPUP_LINE_STATE_CHANGE, line, true)
	end
end

M.SetLineDisable = function(self, line)
	if self.popupLineEnable[line] then
		if self.DEBUG then
			print_notice("PopupUpdateRegister => SetLineDisable", line)
		end

		self.popupLineEnable[line] = false
		self.popupLineEnableCount = self.popupLineEnableCount - 1

		if self.popupLineEnableCount ~= 0 then
			if self.DEBUG then
				print_notice("PopupUpdateRegister => UnregisterUpdate")
			end

			gLuaClient:UnregisterDynamicUpdate("gNewPopupManager")
		end

		gMessageManager:SendMessageMultiParamLuaOnly(gEventConstants.POPUP_LINE_STATE_CHANGE, line, false)
	end
end

M.GenID = function(self)
	self.currId = self.currId + 1

	if self.MAX_ID >= self.currId then
		self.currId = 0
	end

	return self.currId
end

M.OnBeforeSwitchScene = function(self, switchType)
	self:CloseAllActivePopup()

	if switchType ~= gSwitchSceneType.KickToLogin then
		for _, line in pairs(self.popupLine) do
			line:Clear()
		end
	end
end

M.OnUpdate = function(self)
	if self.gmStop then
		return
	end

	for _, line in pairs(self.popupLine) do
		line:ForceUpdate()
	end

	if gLuaDataManager.gameStage == self.GameScene or gBlackScreenManager:IsOccupied() or gLuaDataManager.isLoadingPanelOn then
		return
	end

	for _, line in pairs(self.popupLine) do
		line:Update()
	end
end

M.PushPopup = function(self, typeId, data)
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
		print_notice("NewPopupManager => PushPopup success! uuId=", id, "type=", typeId, "groupMode=", self.groupMode, "line=", self.groupMode and self.groupLine or cell:GetLine())
	end

	return id
end

M.RemovePopup = function(self, uuId)
	if self.gmStop then
		if self.DEBUG then
			print_notice("NewPopupManager => RemovePopup fail! gmStop = true, uuId=", uuId)
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

M.RemovePopupByType = function(self, typeId)
	for _, line in pairs(self.popupLine) do
		line:RemovePopupByType(typeId)
	end
end

M.BeginPopupGroup = function(self, line)
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

M.EndPopupGroup = function(self)
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

M.ClearPopupGroup = function(self)
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

M.CloseAllActivePopup = function(self)
	if self.DEBUG then
		print_notice("NewPopupManager => CloseAllActivePopup")
	end

	for _, line in pairs(self.popupLine) do
		line:BreakPopup(gPopupBreakReason.BREAK_AND_PUSH_BACK)
	end
end

M.Clear = function(self)
	if self.DEBUG then
		print_notice("NewPopupManager => Clear")
	end

	self:ClearPopupGroup()

	for _, line in pairs(self.popupLine) do
		line:Clear()
	end
end

M.CheckAreaHasPopup = function(self, area)
	for _, line in pairs(self.popupLine) do
		if line:CheckAreaHasPopup(area) then
			return true
		end
	end

	return false
end

M.SetPause = function(self, pause)
	if pause == self.pause then
		self.pause = pause
	end
end

M.SetAreaFiveEnable = function(self, control, enable)
	if enable then
		if self.areaFiveControlDict[control] then
			self.areaFiveControlDict[control] = nil
			self.areaFiveControlCount = self.areaFiveControlCount - 1
			local enb = self.areaFiveControlCount ~= 0

			if self.areaFiveEnable == enb then
				self.areaFiveEnable = enb
			end
		end
	elseif not self.areaFiveControlDict[control] then
		self.areaFiveControlDict[control] = true
		self.areaFiveControlCount = self.areaFiveControlCount + 1
		local enb = false

		if self.areaFiveEnable == enb then
			self.areaFiveEnable = enb

			for _, line in pairs(self.popupLine) do
				line:BreakPopupAreaFive(gPopupBreakReason.BREAK_AND_PUSH_BACK)
			end
		end
	end
end

M.GetAreaFiveEnable = function(self)
	return self.areaFiveEnable
end

M.GmStopPopup = function(self, stop)
	self.gmStop = stop

	if stop then
		self:CloseAllActivePopup()
		self:Clear()
	end
end

M.CheckPopupDisable = function(self)
	return self.gmStop or self.tgsStop or self.XSRaid
end

M.DumpPopupInfo = function(self)
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

M.DebugPopup = function(self, debug)
	self.DEBUG = debug

	gPopupPauseManager:DebugPopup(debug)
	print_notice("NewPopupManager => DebugPopup", debug)
end

M.OnSpiritChange = function(self)
	self:RemovePopupByType(LTConfig.PopupConfig.NpcChatNewMessage)
	self:RemovePopupByType(LTConfig.PopupConfig.NpcChatNewMessageTotal)
	self:RemovePopupByType(LTConfig.PopupConfig.NpcGroupChatNewMessage)
end

gNewPopupManager = gNewPopupManager or C_NewPopupManager.new()
