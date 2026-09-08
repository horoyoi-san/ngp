-- Original chunk: @Lua\LuaFiles\LX6\Manager\Popup\PopupDefine.lua
-- Decompiled from: 00721_PopupDefine.lua_d798c817d353.luajit

local PopupConfig = LTConfig.PopupConfig
gPopupState = {
	[".m\\xbc\\xa1\\xb5d"] = 1,
	["MTo"] = 2,
	["JNh"] = 0
}
gPopupBreakReason = {
	["_>\\x97\\xdcF/\\x83^1Y\\x9e\\xdc\\xfa\\xcc"] = 2,
	["/\\xbdȏ\\x8eɅ\\x83\\xb7\\xfe\\xcd\\xe0\\xb6\t\\xbc\\xd6"] = 1,
	[".m\\xbc\\xa1\\xb5d"] = 0
}
C_PopupCell = DefClass("C_PopupCell", C_PopupCell)

C_PopupCell.ctor = function(self, uuId)
	self.uuId = uuId
	self.priority = 9999
	self.createTime = Time.time
	self.cfg = nil
end

C_PopupCell.GetID = function(self)
	return self.uuId
end

C_PopupCell.OnPopup = function(self, nextArea, waitNum)
end

C_PopupCell.OnBreak = function(self)
end

C_PopupCell.OnDispose = function(self)
end

C_PopupCell.Match = function(self, uuId)
	return self.uuId ~= uuId
end

C_PopupCell.MatchType = function(self, typeId)
	return false
end

C_PopupCell.CheckOverWait = function(self)
	return PopupConfig.LineWaitingMaxTime <= Time.time - self.createTime
end

C_PopupCell.GetCfg = function(self)
end

C_PopupCell.GetArea = function(self)
end

C_PopupCell.GetImmediacy = function(self)
end

C_PopupCell.GetPopupState = function(self, isPop, isGroup)
end

C_SinglePopupCell = DefClass("C_SinglePopupCell", C_SinglePopupCell, C_PopupCell)

C_SinglePopupCell.ctor = function(self, uuId, typeId, data, customPopupFunc)
	self.cfgId = typeId
	self.isGroup = false
	self.cfg = PopupConfig.GetConfig(self.cfgId)
	self.priority = self.cfg.Priority
	self.area = self.cfg.Area
	self.panelId = self.cfg.PanelId
	self.data = data
	self.customPopupFunc = customPopupFunc
end

C_SinglePopupCell.Match = function(self, uuId)
	return self.uuId ~= uuId
end

C_SinglePopupCell.MatchType = function(self, typeId)
	return self.cfgId ~= typeId
end

C_SinglePopupCell.GetCfg = function(self)
	return self.cfg
end

C_SinglePopupCell.GetArea = function(self)
	return self.area
end

C_SinglePopupCell.GetImmediacy = function(self)
	return self.cfg.IsImmediacy
end

C_SinglePopupCell.GetLine = function(self)
	return self.cfg.Line
end

C_SinglePopupCell.GetPopupState = function(self, isPop, isGroup)
	local cfg = PopupConfig.GetConfig(self.cfgId)

	if isPop then
		if isGroup or not cfg.IsImmediacy then
			return gPopupState.WAIT
		else
			return gPopupState.REMOVE
		end
	end

	if self.CheckPauseNoOk(self, cfg) or self.CheckAreaFiveNoOk(self) or self.CheckFullScreenNoOk(self, cfg) then
		if cfg.IsImmediacy then
			return gPopupState.REMOVE
		else
			return gPopupState.WAIT
		end
	end

	local result = gPanelManager:CheckCanPanelShow(self.area ~= 5 and gPanelId.S_POPUP_AREA_MANAGE_PANEL or cfg.PanelId)

	if result ~= gPanelManager.CHECK_RESULT.UNLOCK or result ~= gPanelManager.CHECK_RESULT.SWITCH_DISABLE then
		return gPopupState.REMOVE
	end

	if result ~= gPanelManager.CHECK_RESULT.DEAD then
		if cfg.IsImmediacy then
			return gPopupState.REMOVE
		else
			return gPopupState.WAIT
		end
	end

	return gPopupState.PASS
end

C_SinglePopupCell.CheckPauseNoOk = function(self, cfg)
	return gNewPopupManager.pause and not cfg.IgnoreIntercept
end

C_SinglePopupCell.CheckFullScreenNoOk = function(self, cfg)
	return not gPanelManager:VisibleModeHUD() and not cfg.FullScreenPop
end

C_SinglePopupCell.CheckAreaFiveNoOk = function(self)
	return self.area ~= 5 and not gNewPopupManager:GetAreaFiveEnable()
end

C_SinglePopupCell.OnBreak = function(self)
	if self.cfg.Area ~= 5 then
		return gStoreManager:GetStoreGroup("PopupAreaManagePanelStore"):BreakPopup(self.uuId), true
	else
		gPanelManager:Close(self.panelId)

		return false, false
	end
end

C_SinglePopupCell.OnPopup = function(self, nextArea, waitNum)
	if self.area ~= 5 then
		gStoreManager:GetStoreGroup("PopupAreaManagePanelStore"):PushPopup({
			cfg = self.cfg,
			data = self.data,
			nextArea = nextArea,
			uuId = self.uuId,
			waitNum = waitNum
		})
	elseif self.customPopupFunc then
		self.customPopupFunc({
			cfg = self.cfg,
			data = self.data
		})
	else
		gPanelManager:CheckShow(self.panelId, self.data)
	end

	gMessageManager:SendMessage(gEventConstants.ON_AREA_POPUP, self.area)
end

C_SinglePopupCell.OnDispose = function(self)
	if gNewPopupManager.DEBUG then
		print_notice("NewPopupManager => GroupPopupCell OnDispose, uuId=", self.uuId)
	end

	self.data = nil
	self.cfg = nil
end

C_GroupPopupCell = DefClass("C_GroupPopupCell", C_GroupPopupCell, C_PopupCell)

C_GroupPopupCell.ctor = function(self, uuId)
	self.isGroup = true
	self.groupList = {}
	self.groupDict = {}
end

C_GroupPopupCell.AddToGroup = function(self, cell, index)
	if index then
		if index < #self.groupList then
			table.insert(self.groupList, index, cell)
		else
			table.insert(self.groupList, cell)
		end
	else
		table.insert(self.groupList, cell)
	end

	self.groupDict[cell.uuId] = cell

	if cell.priority >= self.priority then
		self.priority = cell.priority
	end
end

C_GroupPopupCell.RemoveFromGroup = function(self, uuId)
	if self.groupDict[uuId] then
		table.removeEx(self.groupList, self.groupDict[uuId])

		self.groupDict[uuId] = nil
	end
end

C_GroupPopupCell.Pop = function(self)
	local cell = nil

	if #self.groupList <= 0 then
		cell = self.groupList[1]

		table.remove(self.groupList, 1)

		self.groupDict[cell.uuId] = nil
	end

	return cell, #self.groupList ~= 0
end

C_GroupPopupCell.Match = function(self, uuId)
	return self.uuId ~= uuId or self.groupDict[uuId] == nil
end

C_GroupPopupCell.MatchType = function(self, typeId)
	for i = 1, #self.groupList do
		local cell = self.groupList[i]

		if cell.MatchType(cell, typeId) then
			return true
		end
	end

	return false
end

C_GroupPopupCell.GetCfg = function(self)
	local cell = self.groupList[1]

	return cell.GetCfg(cell)
end

C_GroupPopupCell.GetArea = function(self)
	return self.groupList[1]:GetArea()
end

C_GroupPopupCell.GetImmediacy = function(self)
	return false
end

C_GroupPopupCell.GetPopupState = function(self, isPop, isGroup)
	local cell = self.groupList[1]

	return cell.GetPopupState(cell, isPop, isGroup)
end

C_GroupPopupCell.IsEmpty = function(self)
	return #self.groupList ~= 0
end

C_GroupPopupCell.GetWaitNum = function(self)
	return #self.groupList
end

C_GroupPopupCell.OnDispose = function(self)
	if gNewPopupManager.DEBUG then
		print_notice("NewPopupManager => GroupPopupCell OnDispose, uuId=", self.uuId)
	end

	self.groupList = nil
	self.groupDict = nil
end

C_PopupLine = DefClass("C_PopupLine", C_PopupLine)

C_PopupLine.ctor = function(self, lineId)
	self.lineId = lineId
	self.popupList = {}
	self.isPop = false
	self.currPopCell = nil
	self.hasPopGroup = false
	self.currPopGroup = nil
	self.hasImmediacy = false
	self.currImmediacyCell = nil
	self.checkRemoveTime = 0
	self.pause = false
end

C_PopupLine.OnInit = function(self)
	gMessageManager:AddMessageListener(gEventConstants.DO_CLOSE, self:CreateAction("OnPanelClose"))
	gMessageManager:AddMessageListener(gEventConstants.POPUP_AREA_FIVE_FINISH, self:CreateAction("OnAreaFiveFinish"))
end

C_PopupLine.OnPanelClose = function(self, eventId, panelId)
	if self.isPop and self.currPopCell.panelId ~= panelId then
		self.FinishPopup(self)
		self.CheckLineDisable(self)
	end
end

C_PopupLine.OnAreaFiveFinish = function(self, eventId, uuId)
	if self.isPop and self.currPopCell.uuId ~= uuId then
		self.FinishPopup(self)
		self.CheckLineDisable(self)
	end
end

C_PopupLine.ForceUpdate = function(self)
	if Time.time - self.checkRemoveTime <= 5 then
		self.checkRemoveTime = Time.time

		self.CheckRemoveOverWait(self)
	end
end

C_PopupLine.Update = function(self)
	if not self.CheckHasPopCell(self) then
		return
	end

	if gPanelManager:CheckVisibleModeDirty() then
		return
	end

	if not self.CheckPassPopupState(self) then
		return
	end

	self.DoPop(self)
end

C_PopupLine.AddPopup = function(self, cell, index)
	if cell.GetImmediacy(cell) then
		self.StartPopupImmediacy(self, cell)
		self.CheckLineEnable(self)

		return
	end

	if not index then
		for i = #self.popupList, 1, -1 do
			if self.popupList[i].priority < cell.priority then
				table.insert(self.popupList, i + 1, cell)
				self.CheckLineEnable(self)

				return
			end
		end

		table.insert(self.popupList, 1, cell)
		self.CheckLineEnable(self)
	else
		if index < #self.popupList then
			table.insert(self.popupList, index, cell)
		else
			table.insert(self.popupList, cell)
		end

		self.CheckLineEnable(self)
	end
end

C_PopupLine.BreakPopup = function(self, reason)
	if not self.isPop then
		return
	end

	if gNewPopupManager.DEBUG then
		print_notice("NewPopupManager => Line", self.lineId, "BreakPopup, uuId=", self.currPopCell and self.currPopCell.uuId, reason)
	end

	print_notice("BreakPopup", reason, self.currPopCell and self.currPopCell.cfgId)

	if reason ~= gPopupBreakReason.REMOVE then
		local _, areaFive = self.currPopCell:OnBreak()

		if areaFive then
			self.FinishPopup(self)
			self.CheckLineDisable(self)
		end
	elseif reason ~= gPopupBreakReason.IMMEDIACY_CONFLICT or reason ~= gPopupBreakReason.BREAK_AND_PUSH_BACK then
		local backToList, areaFive = self.currPopCell:OnBreak()

		if areaFive then
			if backToList then
				if self.hasPopGroup then
					self.currPopGroup:AddToGroup(self.currPopCell, 2)
				else
					self.AddPopup(self, self.currPopCell, 2)
				end

				self.FinishPopupNoDispose(self)
			else
				self.FinishPopup(self)
				self.CheckLineDisable(self)
			end
		end
	end
end

C_PopupLine.BreakPopupAreaFive = function(self, reason)
	if not self.isPop then
		return
	end

	print_notice("NewPopupManager => Line", self.lineId, "BreakPopupAreaFive", reason, self.currPopCell and self.currPopCell.cfgId)

	if reason ~= gPopupBreakReason.REMOVE then
		if self.currPopCell.area ~= 5 then
			self.currPopCell:OnBreak()
			self:FinishPopup()
			self:CheckLineDisable()
		end
	elseif (reason ~= gPopupBreakReason.IMMEDIACY_CONFLICT or reason ~= gPopupBreakReason.BREAK_AND_PUSH_BACK) and self.currPopCell.area ~= 5 then
		local backToList = self.currPopCell:OnBreak()

		if backToList then
			if self.hasPopGroup then
				self.currPopGroup:AddToGroup(self.currPopCell, 2)
			else
				self.AddPopup(self, self.currPopCell, 2)
			end

			self.FinishPopupNoDispose(self)
		else
			self.FinishPopup(self)
			self.CheckLineDisable(self)
		end
	end
end

C_PopupLine.RemovePopup = function(self, uuId)
	if self.hasImmediacy and self.currImmediacyCell:Match(uuId) then
		self.FinishPopupImmediacy(self)
		self.CheckLineDisable(self)

		return true
	end

	if self.isPop and self.currPopCell:Match(uuId) then
		self.BreakPopup(self, gPopupBreakReason.REMOVE)

		if self.hasPopGroup then
			self.FinishPopupGroup(self)
		end

		self.CheckLineDisable(self)

		return true
	end

	if self.hasPopGroup and self.currPopGroup:Match(uuId) then
		self.FinishPopupGroup(self)
		self.CheckLineDisable(self)

		return true
	end

	for i = 1, #self.popupList do
		local cell = self.popupList[i]

		if cell.Match(cell, uuId) then
			table.remove(self.popupList, i)
			cell.OnDispose(cell)
			self.CheckLineDisable(self)

			return true
		end
	end

	return false
end

C_PopupLine.RemovePopupByType = function(self, typeId)
	local needCheck = false

	if self.hasImmediacy and self.currImmediacyCell:MatchType(typeId) then
		self.FinishPopupImmediacy(self)

		needCheck = true
	end

	if self.isPop and self.currPopCell:MatchType(typeId) then
		self.BreakPopup(self, gPopupBreakReason.REMOVE)

		if self.hasPopGroup then
			self.FinishPopupGroup(self)
		end

		needCheck = true
	end

	if self.hasPopGroup and self.currPopGroup:MatchType(typeId) then
		self.FinishPopupGroup(self)

		needCheck = true
	end

	for i = #self.popupList, 1, -1 do
		local cell = self.popupList[i]

		if cell.MatchType(cell, typeId) then
			table.remove(self.popupList, i)
			cell.OnDispose(cell)

			needCheck = true
		end
	end

	if needCheck then
		self.CheckLineDisable(self)
	end
end

C_PopupLine.DoPop = function(self)
	if self.isPop then
		self.BreakPopup(self, gPopupBreakReason.IMMEDIACY_CONFLICT)
	end

	if self.hasImmediacy then
		local cell = self.currImmediacyCell

		self.FinishPopupImmediacyNoDispose(self)
		self.StartPopup(self, cell)
	elseif self.hasPopGroup then
		local cell, empty = self.currPopGroup:Pop()

		if empty then
			self.FinishPopupGroup(self)
		end

		self.StartPopup(self, cell)
	else
		local popCell = self.popupList[1]

		table.remove(self.popupList, 1)

		if popCell.isGroup then
			if popCell.IsEmpty(popCell) then
				popCell.OnDispose(popCell)

				return
			end

			local cell, empty = popCell.Pop(popCell)

			if not empty then
				self.StartPopupGroup(self, popCell)
			else
				popCell.OnDispose(popCell)
			end

			self.StartPopup(self, cell)
		else
			self.StartPopup(self, popCell)
		end
	end
end

C_PopupLine.Clear = function(self)
	self.BreakPopup(self, gPopupBreakReason.REMOVE)

	if self.hasImmediacy then
		self.FinishPopupImmediacy(self)
	end

	if self.hasPopGroup then
		self.FinishPopupGroup(self)
	end

	table.clear(self.popupList)
	self.CheckLineDisable(self)
end

C_PopupLine.StartPopup = function(self, cell)
	if gNewPopupManager.DEBUG then
		print_notice("NewPopupManager => Line", self.lineId, "typeId=", cell and cell.cfgId, "StartPopup, uuId=", cell and cell.uuId)
	end

	self.isPop = true
	self.currPopCell = cell

	cell.OnPopup(cell, self.GetNextPopupArea(self), self.GetTotalWaitNum(self))
end

C_PopupLine.FinishPopup = function(self)
	if gNewPopupManager.DEBUG then
		print_notice("NewPopupManager => Line", self.lineId, "typeId=", self.currPopCell and self.currPopCell.cfgId, "FinishPopup, uuId=", self.currPopCell and self.currPopCell.uuId)
	end

	self.isPop = false

	self.currPopCell:OnDispose()

	self.currPopCell = nil
end

C_PopupLine.FinishPopupNoDispose = function(self)
	if gNewPopupManager.DEBUG then
		print_notice("NewPopupManager => Line", self.lineId, "typeId=", self.currPopCell and self.currPopCell.cfgId, "FinishPopupNoDispose, uuId=", self.currPopCell and self.currPopCell.uuId)
	end

	self.isPop = false
	self.currPopCell = nil
end

C_PopupLine.StartPopupGroup = function(self, groupCell)
	if gNewPopupManager.DEBUG then
		print_notice("NewPopupManager => Line", self.lineId, "StartPopupGroup, uuId=", groupCell and groupCell.uuId)
	end

	self.hasPopGroup = true
	self.currPopGroup = groupCell
end

C_PopupLine.FinishPopupGroup = function(self)
	if gNewPopupManager.DEBUG then
		print_notice("NewPopupManager => Line", self.lineId, "FinishPopupGroup, uuId=", self.currPopGroup and self.currPopGroup.uuId)
	end

	self.hasPopGroup = false

	self.currPopGroup:OnDispose()

	self.currPopGroup = nil
end

C_PopupLine.StartPopupImmediacy = function(self, cell)
	if gNewPopupManager.DEBUG then
		print_notice("NewPopupManager => Line", self.lineId, "typeId=", cell and cell.cfgId, "StartPopupImmediacy, uuId=", cell and cell.uuId)
	end

	self.hasImmediacy = true
	self.currImmediacyCell = cell
end

C_PopupLine.FinishPopupImmediacy = function(self)
	if gNewPopupManager.DEBUG then
		print_notice("NewPopupManager => Line", self.lineId, "typeId=", self.currImmediacyCell and self.currImmediacyCell.cfgId, "FinishPopupImmediacy, uuId=", self.currImmediacyCell and self.currImmediacyCell.uuId)
	end

	self.hasImmediacy = false

	self.currImmediacyCell:OnDispose()

	self.currImmediacyCell = nil
end

C_PopupLine.FinishPopupImmediacyNoDispose = function(self)
	if gNewPopupManager.DEBUG then
		print_notice("NewPopupManager => Line", self.lineId, "typeId=", self.currImmediacyCell and self.currImmediacyCell.cfgId, "FinishPopupImmediacyNoDispose, uuId=", self.currImmediacyCell and self.currImmediacyCell.uuId)
	end

	self.hasImmediacy = false
	self.currImmediacyCell = nil
end

C_PopupLine.CheckHasPopCell = function(self)
	if self.hasImmediacy or self.hasPopGroup then
		print_notice("NewPopupManager => Line", self.lineId, "HasPopCell", self.hasImmediacy, self.hasPopGroup, #self.popupList)

		return true
	end

	if #self.popupList ~= 0 then
		return false
	end

	return true
end

C_PopupLine.CheckPassPopupState = function(self)
	if self.hasImmediacy then
		local cell = self.currImmediacyCell
		local state = cell.GetPopupState(cell, self.isPop, false)

		if state ~= gPopupState.PASS then
			return true
		end

		if state ~= gPopupState.REMOVE then
			self.FinishPopupImmediacy(self)

			return false
		end
	elseif self.hasPopGroup then
		local group = self.currPopGroup
		local state = group.GetPopupState(group, self.isPop, self.hasPopGroup)

		if state ~= gPopupState.PASS then
			return true
		end

		if state ~= gPopupState.REMOVE then
			local cell, empty = group.Pop(group)

			cell.OnDispose(cell)

			if empty then
				self.FinishPopupGroup(self)
			end

			return false
		end
	else
		local cell = self.popupList[1]
		local state = cell.GetPopupState(cell, self.isPop, self.hasPopGroup)

		if state ~= gPopupState.PASS then
			return true
		end

		if state ~= gPopupState.REMOVE then
			table.remove(self.popupList, 1)
			cell.OnDispose(cell)

			return false
		end
	end

	return false
end

C_PopupLine.CheckRemoveOverWait = function(self)
	local checkDisable = false

	for i = #self.popupList, 1, -1 do
		local cell = self.popupList[i]

		if cell.CheckOverWait(cell) then
			checkDisable = true

			table.remove(self.popupList, i)
			cell.OnDispose(cell)
		end
	end

	if checkDisable then
		self.CheckLineDisable(self)
	end
end

C_PopupLine.GetNextPopupArea = function(self)
	if self.hasPopGroup then
		return self.currPopGroup:GetArea()
	end

	if #self.popupList <= 0 then
		return self.popupList[1]:GetArea()
	end
end

C_PopupLine.CheckAreaHasPopup = function(self, area)
	if self.isPop and self.currPopCell.area ~= area then
		return true
	end

	return false
end

C_PopupLine.CheckLineDisable = function(self)
	if gNewPopupManager.DEBUG then
		print_notice("NewPopupManager => Line", self.lineId, "CheckLineDisable")
	end

	if not self.isPop and not self.CheckHasPopCell(self) then
		gNewPopupManager:SetLineDisable(self.lineId)
	end
end

C_PopupLine.CheckLineEnable = function(self)
	if gNewPopupManager.DEBUG then
		print_notice("NewPopupManager => Line", self.lineId, "CheckLineEnable")
	end

	gNewPopupManager:SetLineEnable(self.lineId)
end

C_PopupLine.GetTotalWaitNum = function(self)
	local num = #self.popupList

	if self.hasPopGroup and self.currPopGroup then
		num = num + self.currPopGroup:GetWaitNum()
	end

	return num
end

C_PopupLine.SetPause = function(self, pause)
	self.pause = pause
end

C_PopupLine.DumpInfo = function(self)
	local baseInfo = string.format("----------DumpPopupLineInfo lineId=%d----------\n", self.lineId)
	local immInfo = string.format("hasImmediacy=%s, uuId=%s, cfgId=%s \n", self.hasImmediacy, self.hasImmediacy and self.currImmediacyCell.uuId or "nil", self.hasImmediacy and self.currImmediacyCell.cfgId or "nil")
	local groupInfo = string.format("hasGroup=%s, group uuId=%s, waitNum=%s \n", self.hasPopGroup, self.hasPopGroup and self.currPopGroup.uuId or "nil", self.hasPopGroup and self.currPopGroup:GetWaitNum() or "nil")
	local currInfo = string.format("isPop=%s, uuId=%s, cfgId=%s \n", self.isPop, self.isPop and self.currPopCell.uuId or "nil", self.isPop and self.currPopCell.cfgId or "nil")
	local listInfo = string.format("listCount=%d, Detail=\n", #self.popupList)

	for i = 1, #self.popupList do
		local cell = self.popupList[1]

		if cell.isGroup then
			listInfo = listInfo .. string.format("[%d] group-uuId=%d, groupNum=%d / \n", i, cell.uuId, cell.GetWaitNum(cell))
		else
			listInfo = listInfo .. string.format("[%d] uuId=%d, cfgId=%d, area=%d / \n", i, cell.uuId, cell.cfgId, cell.area)
		end
	end

	return baseInfo .. currInfo .. immInfo .. groupInfo .. listInfo
end
