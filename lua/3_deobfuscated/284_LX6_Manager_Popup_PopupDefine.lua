local PopupConfig = LTConfig.PopupConfig
gPopupState = {
	REMOVE = 1,
	WAIT = 2,
	PASS = 0
}
gPopupBreakReason = {
	BREAK_AND_PUSH_BACK = 2,
	IMMEDIACY_CONFLICT = 1,
	REMOVE = 0
}
C_PopupCell = DefClass("C_PopupCell", C_PopupCell)

function C_PopupCell:ctor(uuId)
	self.uuId = uuId
	self.priority = 9999
	self.createTime = Time.time
	self.cfg = nil
end

function C_PopupCell:GetID()
	return self.uuId
end

function C_PopupCell:OnPopup(nextArea, waitNum)
	return
end

function C_PopupCell:OnBreak()
	return
end

function C_PopupCell:OnDispose()
	return
end

function C_PopupCell:Match(uuId)
	return self.uuId == uuId
end

function C_PopupCell:CheckOverWait()
	return PopupConfig.LineWaitingMaxTime < Time.time - self.createTime
end

function C_PopupCell:GetCfg()
	return
end

function C_PopupCell:GetArea()
	return
end

function C_PopupCell:GetImmediacy()
	return
end

function C_PopupCell:GetPopupState(isPop, isGroup)
	return
end

C_SinglePopupCell = DefClass("C_SinglePopupCell", C_SinglePopupCell, C_PopupCell)

function C_SinglePopupCell:ctor(uuId, typeId, data, customPopupFunc)
	self.cfgId = typeId
	self.isGroup = false
	self.cfg = PopupConfig.GetConfig(self.cfgId)
	self.priority = self.cfg.Priority
	self.area = self.cfg.Area
	self.panelId = self.cfg.PanelId
	self.data = data
	self.customPopupFunc = customPopupFunc
end

function C_SinglePopupCell:Match(uuId)
	return self.uuId == uuId
end

function C_SinglePopupCell:GetCfg()
	return self.cfg
end

function C_SinglePopupCell:GetArea()
	return self.area
end

function C_SinglePopupCell:GetImmediacy()
	return self.cfg.IsImmediacy
end

function C_SinglePopupCell:GetLine()
	return self.cfg.Line
end

function C_SinglePopupCell:GetPopupState(isPop, isGroup)
	local cfg = PopupConfig.GetConfig(self.cfgId)

	if isPop and (isGroup or not cfg.IsImmediacy) then
		return gPopupState.WAIT
	end

	if self:CheckPauseNoOk(cfg) or self:CheckAreaFiveNoOk() or self:CheckFullScreenNoOk(cfg) then
		if cfg.IsImmediacy then
			return gPopupState.REMOVE
		else
			return gPopupState.WAIT
		end
	end

	local result = gPanelManager:CheckCanPanelShow(cfg.PanelId)

	if result == gPanelManager.CHECK_RESULT.UNLOCK then
		return gPopupState.REMOVE
	end

	if result == gPanelManager.CHECK_RESULT.DEAD then
		if cfg.IsImmediacy then
			return gPopupState.REMOVE
		else
			return gPopupState.WAIT
		end
	end

	return gPopupState.PASS
end

function C_SinglePopupCell:CheckPauseNoOk(cfg)
	return gNewPopupManager.pause and not cfg.IgnoreIntercept
end

function C_SinglePopupCell:CheckFullScreenNoOk(cfg)
	return not gPanelManager:VisibleModeHUD() and not cfg.FullScreenPop
end

function C_SinglePopupCell:CheckAreaFiveNoOk()
	return self.area == 5 and not gNewPopupManager:GetAreaFiveEnable()
end

function C_SinglePopupCell:OnBreak()
	if self.cfg.Area == 5 then
		return gStoreManager:GetStoreGroup("PopupAreaManagePanelStore"):BreakPopup(self.uuId), true
	else
		gPanelManager:Close(self.panelId)

		return false, false
	end
end

function C_SinglePopupCell:OnPopup(nextArea, waitNum)
	if self.area == 5 then
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

function C_SinglePopupCell:OnDispose()
	self.data = nil
	self.cfg = nil
end

C_GroupPopupCell = DefClass("C_GroupPopupCell", C_GroupPopupCell, C_PopupCell)

function C_GroupPopupCell:ctor(uuId)
	self.isGroup = true
	self.groupList = {}
	self.groupDict = {}
end

function C_GroupPopupCell:AddToGroup(cell, index)
	if index then
		if index <= #self.groupList then
			table.insert(self.groupList, index, cell)
		else
			table.insert(self.groupList, cell)
		end
	else
		table.insert(self.groupList, cell)
	end

	self.groupDict[cell.uuId] = cell

	if cell.priority < self.priority then
		self.priority = cell.priority
	end
end

function C_GroupPopupCell:RemoveFromGroup(uuId)
	if self.groupDict[uuId] then
		table.removeEx(self.groupList, self.groupDict[uuId])

		self.groupDict[uuId] = nil
	end
end

function C_GroupPopupCell:Pop()
	local cell = nil

	if #self.groupList > 0 then
		cell = self.groupList[1]

		table.remove(self.groupList, 1)

		self.groupDict[cell.uuId] = nil
	end

	return cell, #self.groupList == 0
end

function C_GroupPopupCell:Match(uuId)
	return self.uuId == uuId or self.groupDict[uuId] ~= nil
end

function C_GroupPopupCell:GetCfg()
	local cell = self.groupList[1]

	return cell:GetCfg()
end

function C_GroupPopupCell:GetArea()
	return self.groupList[1]:GetArea()
end

function C_GroupPopupCell:GetImmediacy()
	return false
end

function C_GroupPopupCell:GetPopupState(isPop, isGroup)
	local cell = self.groupList[1]

	return cell:GetPopupState(isPop, isGroup)
end

function C_GroupPopupCell:IsEmpty()
	return #self.groupList == 0
end

function C_GroupPopupCell:GetWaitNum()
	return #self.groupList
end

function C_GroupPopupCell:OnDispose()
	self.groupList = nil
	self.groupDict = nil
end

C_PopupLine = DefClass("C_PopupLine", C_PopupLine)

function C_PopupLine:ctor(lineId)
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

function C_PopupLine:OnInit()
	gMessageManager:AddMessageListener(gEventConstants.DO_CLOSE, self:CreateAction("OnPanelClose"))
	gMessageManager:AddMessageListener(gEventConstants.POPUP_AREA_FIVE_FINISH, self:CreateAction("OnAreaFiveFinish"))
end

function C_PopupLine:OnPanelClose(eventId, panelId)
	if self.isPop and self.currPopCell.panelId == panelId then
		self:FinishPopup()
		self:CheckLineDisable()
	end
end

function C_PopupLine:OnAreaFiveFinish(eventId, uuId)
	if self.isPop and self.currPopCell.uuId == uuId then
		self:FinishPopup()
		self:CheckLineDisable()
	end
end

function C_PopupLine:ForceUpdate()
	if Time.time - self.checkRemoveTime > 5 then
		self.checkRemoveTime = Time.time

		self:CheckRemoveOverWait()
	end
end

function C_PopupLine:Update()
	if not self:CheckHasPopCell() then
		return
	end

	if not self:CheckPassPopupState() then
		return
	end

	self:DoPop()
end

function C_PopupLine:AddPopup(cell, index)
	if cell:GetImmediacy() then
		self:StartPopupImmediacy(cell)
		self:CheckLineEnable()

		return
	end

	if not index then
		for i = #self.popupList, 1, -1 do
			if self.popupList[i].priority <= cell.priority then
				table.insert(self.popupList, i + 1, cell)
				self:CheckLineEnable()

				return
			end
		end

		table.insert(self.popupList, 1, cell)
		self:CheckLineEnable()
	else
		if index <= #self.popupList then
			table.insert(self.popupList, index, cell)
		else
			table.insert(self.popupList, cell)
		end

		self:CheckLineEnable()
	end
end

function C_PopupLine:BreakPopup(reason)
	if not self.isPop then
		return
	end

	print_notice("BreakPopup", reason, self.currPopCell and self.currPopCell.cfgId)

	if reason == gPopupBreakReason.REMOVE then
		local _, areaFive = self.currPopCell:OnBreak()

		if areaFive then
			self:FinishPopup()
			self:CheckLineDisable()
		end
	elseif reason == gPopupBreakReason.IMMEDIACY_CONFLICT or reason == gPopupBreakReason.BREAK_AND_PUSH_BACK then
		local backToList, areaFive = self.currPopCell:OnBreak()

		if areaFive then
			if backToList then
				if self.hasPopGroup then
					self.currPopGroup:AddToGroup(self.currPopCell, 2)
				else
					self:AddPopup(self.currPopCell, 2)
				end

				self:FinishPopupNoDispose()
			else
				self:FinishPopup()
				self:CheckLineDisable()
			end
		end
	end
end

function C_PopupLine:BreakPopupAreaFive(reason)
	if not self.isPop then
		return
	end

	print_notice("BreakPopupAreaFive", reason, self.currPopCell and self.currPopCell.cfgId)

	if reason == gPopupBreakReason.REMOVE then
		if self.currPopCell.area == 5 then
			self.currPopCell:OnBreak()
			self:FinishPopup()
			self:CheckLineDisable()
		end
	elseif (reason == gPopupBreakReason.IMMEDIACY_CONFLICT or reason == gPopupBreakReason.BREAK_AND_PUSH_BACK) and self.currPopCell.area == 5 then
		local backToList = self.currPopCell:OnBreak()

		if backToList then
			if self.hasPopGroup then
				self.currPopGroup:AddToGroup(self.currPopCell, 2)
			else
				self:AddPopup(self.currPopCell, 2)
			end

			self:FinishPopupNoDispose()
		else
			self:FinishPopup()
			self:CheckLineDisable()
		end
	end
end

function C_PopupLine:RemovePopup(uuId)
	if self.hasImmediacy and self.currImmediacyCell:Match(uuId) then
		self:FinishPopupImmediacy()
		self:CheckLineDisable()

		return true
	end

	if self.isPop and self.currPopCell:Match(uuId) then
		self:BreakPopup(gPopupBreakReason.REMOVE)

		if self.hasPopGroup then
			self:FinishPopupGroup()
		end

		self:CheckLineDisable()

		return true
	end

	if self.hasPopGroup and self.currPopGroup:Match(uuId) then
		self:FinishPopupGroup()
		self:CheckLineDisable()

		return true
	end

	for i = 1, #self.popupList do
		local cell = self.popupList[i]

		if cell:Match(uuId) then
			table.remove(self.popupList, i)
			cell:OnDispose()
			self:CheckLineDisable()

			return true
		end
	end

	return false
end

function C_PopupLine:DoPop()
	if self.isPop then
		self:BreakPopup(gPopupBreakReason.IMMEDIACY_CONFLICT)
	end

	if self.hasImmediacy then
		local cell = self.currImmediacyCell

		self:FinishPopupImmediacyNoDispose()
		self:StartPopup(cell)
	elseif self.hasPopGroup then
		local cell, empty = self.currPopGroup:Pop()

		if empty then
			self:FinishPopupGroup()
		end

		self:StartPopup(cell)
	else
		local popCell = self.popupList[1]

		table.remove(self.popupList, 1)

		if popCell.isGroup then
			if popCell:IsEmpty() then
				popCell:OnDispose()

				return
			end

			local cell, empty = popCell:Pop()

			if not empty then
				self:StartPopupGroup(popCell)
			else
				popCell:OnDispose()
			end

			self:StartPopup(cell)
		else
			self:StartPopup(popCell)
		end
	end
end

function C_PopupLine:Clear()
	self:BreakPopup(gPopupBreakReason.REMOVE)

	if self.hasImmediacy then
		self:FinishPopupImmediacy()
	end

	if self.hasPopGroup then
		self:FinishPopupGroup()
	end

	table.clear(self.popupList)
	self:CheckLineDisable()
end

function C_PopupLine:StartPopup(cell)
	self.isPop = true
	self.currPopCell = cell

	cell:OnPopup(self:GetNextPopupArea(), self:GetTotalWaitNum())
end

function C_PopupLine:FinishPopup()
	self.isPop = false

	self.currPopCell:OnDispose()

	self.currPopCell = nil
end

function C_PopupLine:FinishPopupNoDispose()
	self.isPop = false
	self.currPopCell = nil
end

function C_PopupLine:StartPopupGroup(groupCell)
	self.hasPopGroup = true
	self.currPopGroup = groupCell
end

function C_PopupLine:FinishPopupGroup()
	self.hasPopGroup = false

	self.currPopGroup:OnDispose()

	self.currPopGroup = nil
end

function C_PopupLine:StartPopupImmediacy(cell)
	self.hasImmediacy = true
	self.currImmediacyCell = cell
end

function C_PopupLine:FinishPopupImmediacy()
	self.hasImmediacy = false

	self.currImmediacyCell:OnDispose()

	self.currImmediacyCell = nil
end

function C_PopupLine:FinishPopupImmediacyNoDispose()
	self.hasImmediacy = false
	self.currImmediacyCell = nil
end

function C_PopupLine:CheckHasPopCell()
	if self.hasImmediacy or self.hasPopGroup then
		print_notice("HasPopCell", self.hasImmediacy, self.hasPopGroup, #self.popupList)

		return true
	end

	if #self.popupList == 0 then
		return false
	end

	return true
end

function C_PopupLine:CheckPassPopupState()
	if self.hasImmediacy then
		local cell = self.currImmediacyCell
		local state = cell:GetPopupState(self.isPop, false)

		if state == gPopupState.PASS then
			return true
		end

		if state == gPopupState.REMOVE then
			self:FinishPopupImmediacy()

			return false
		end
	elseif self.hasPopGroup then
		local group = self.currPopGroup
		local state = group:GetPopupState(self.isPop, self.hasPopGroup)

		if state == gPopupState.PASS then
			return true
		end

		if state == gPopupState.REMOVE then
			local cell, empty = group:Pop()

			cell:OnDispose()

			if empty then
				self:FinishPopupGroup()
			end

			return false
		end
	else
		local cell = self.popupList[1]
		local state = cell:GetPopupState(self.isPop, self.hasPopGroup)

		if state == gPopupState.PASS then
			return true
		end

		if state == gPopupState.REMOVE then
			table.remove(self.popupList, 1)
			cell:OnDispose()

			return false
		end
	end

	return false
end

function C_PopupLine:CheckRemoveOverWait()
	local checkDisable = false

	for i = #self.popupList, 1, -1 do
		local cell = self.popupList[i]

		if cell:CheckOverWait() then
			checkDisable = true

			table.remove(self.popupList, i)
			cell:OnDispose()
		end
	end

	if checkDisable then
		self:CheckLineDisable()
	end
end

function C_PopupLine:GetNextPopupArea()
	if self.hasPopGroup then
		return self.currPopGroup:GetArea()
	end

	if #self.popupList > 0 then
		return self.popupList[1]:GetArea()
	end
end

function C_PopupLine:CheckAreaHasPopup(area)
	if self.isPop and self.currPopCell.area == area then
		return true
	end

	return false
end

function C_PopupLine:CheckLineDisable()
	if gNewPopupManager.DEBUG then
		print_notice("PopupUpdateRegister => CheckLineDisable", self.lineId)
	end

	if not self.isPop and not self:CheckHasPopCell() then
		gNewPopupManager:SetLineDisable(self.lineId)
	end
end

function C_PopupLine:CheckLineEnable()
	if gNewPopupManager.DEBUG then
		print_notice("PopupUpdateRegister => CheckLineEnable", self.lineId)
	end

	gNewPopupManager:SetLineEnable(self.lineId)
end

function C_PopupLine:GetTotalWaitNum()
	local num = #self.popupList

	if self.hasPopGroup and self.currPopGroup then
		num = num + self.currPopGroup:GetWaitNum()
	end

	return num
end

function C_PopupLine:SetPause(pause)
	self.pause = pause
end

function C_PopupLine:DumpInfo()
	local baseInfo = string.format("----------DumpPopupLineInfo lineId=%d----------\n", self.lineId)
	local immInfo = string.format("hasImmediacy=%s, uuId=%s, cfgId=%s \n", self.hasImmediacy, self.hasImmediacy and self.currImmediacyCell.uuId or "nil", self.hasImmediacy and self.currImmediacyCell.cfgId or "nil")
	local groupInfo = string.format("hasGroup=%s, group uuId=%s, waitNum=%s \n", self.hasPopGroup, self.hasPopGroup and self.currPopGroup.uuId or "nil", self.hasPopGroup and self.currPopGroup:GetWaitNum() or "nil")
	local currInfo = string.format("isPop=%s, uuId=%s, cfgId=%s \n", self.isPop, self.isPop and self.currPopCell.uuId or "nil", self.isPop and self.currPopCell.cfgId or "nil")
	local listInfo = string.format("listCount=%d, Detail=\n", #self.popupList)

	for i = 1, #self.popupList do
		local cell = self.popupList[1]

		if cell.isGroup then
			listInfo = listInfo .. string.format("[%d] group-uuId=%d, groupNum=%d / \n", i, cell.uuId, cell:GetWaitNum())
		else
			listInfo = listInfo .. string.format("[%d] uuId=%d, cfgId=%d, area=%d / \n", i, cell.uuId, cell.cfgId, cell.area)
		end
	end

	return baseInfo .. currInfo .. immInfo .. groupInfo .. listInfo
end
