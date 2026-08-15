local M = gFerrisMgr or {}
M.ferrisDataList = {}
M.ticketTypeList = {}
M.curPanelGameId = nil
M.curIsDouble = false
local eventHandler = {}

eventHandler[gEventConstants.SET_FERRIS_RATE] = function (eventId, rate)
	if type(rate) == "number" then
		gFerrisMgr:SetFerrisRate(rate)
	elseif rate and rate[0] then
		gFerrisMgr:SetFerrisRate(tonumber(rate[0]))
	end
end

function M:OnInit()
	for k, v in pairs(eventHandler) do
		gMessageManager:AddMessageListener(k, v)
	end
end

function M:GetTicketType(gameId)
	if gameId == 0 then
		print_error("GetTicketType gameId is 0")

		return 0
	end

	if not gameId then
		for k, v in pairs(self.ticketTypeList) do
			return v
		end

		return 0
	end

	if self.ticketTypeList[gameId] then
		return self.ticketTypeList[gameId]
	end

	return 0
end

function M:SetTicketType(gameId, ticketType)
	if gameId == 0 then
		print_error("SetTicketType gameId is 0")

		return
	end

	self.ticketTypeList[gameId] = ticketType
end

function M:SetFerrisRotComp(gameId, rotComp)
	if gameId == 0 then
		print_error("SetFerrisRotComp gameId is 0")

		return
	end

	if not self.ferrisDataList[gameId] then
		self.ferrisDataList[gameId] = {}
	end

	self.ferrisDataList[gameId].rotComp = rotComp
end

function M:GetFerrisRotComp(gameId)
	if gameId == 0 then
		print_error("GetFerrisRotComp gameId is 0")

		return nil
	end

	if self.ferrisDataList[gameId] then
		return self.ferrisDataList[gameId].rotComp
	end

	return nil
end

function M:SetNpcId(npcId)
	self.npcId = npcId
	self.timelineInviteNpcId = npcId
end

function M:GetTimelineInviteNpcId()
	return self.timelineInviteNpcId or 0
end

function M:GetNpcId()
	return self.npcId or 0
end

function M:SetNpcPid(npcPid)
	self.npcPid = npcPid

	if npcPid and not ulong.equals(npcPid, 0) then
		gMessageManager:SendMessage(gEventConstants.UNIT_ENABLE_FORCE_LOD0, npcPid)
	end
end

function M:GetNpcPid()
	return self.npcPid or 0
end

function M:SetCurActiveBox(gameId, comp)
	if gameId == 0 then
		print_error("SetCurActiveBox gameId is 0")

		return
	end

	if not self.ferrisDataList[gameId] then
		self.ferrisDataList[gameId] = {}
	end

	local data = self.ferrisDataList[gameId]

	if not gCS.LuaUtils.IsNull(data.curActiveBox) then
		gSpoonClientMgr:ReleaseContextEvent(data.curActiveBox.LuaEntityId, gSpoonEventType.OnClearGraph)

		data.curActiveBox.LuaEntityId = data.curActiveBoxIndex

		data.curActiveBox:SetIsInited(false)
		data.curActiveBox:ClearData()
	end

	data.curActiveBox = comp

	if comp then
		data.curActiveBoxIndex = comp.LuaEntityId
	else
		data.curActiveBoxIndex = nil
	end
end

function M:GetCurActiveBox(gameId)
	if gameId == 0 then
		print_error("GetCurActiveBox gameId is 0")

		return nil
	end

	if self.ferrisDataList[gameId] then
		return self.ferrisDataList[gameId].curActiveBox
	end

	return nil
end

function M:SetFerrisRate(rate)
	if not self:GetCurActiveBox(self.curPanelGameId) then
		return
	end

	local boxTrans = self:GetCurActiveBox(self.curPanelGameId).transform
	local playerPos = gCS.MyPlayerManager.PlayerUnit.LocalPosition
	local localPos = boxTrans:InverseTransformPoint(playerPos)
	local rotComp = self:GetFerrisRotComp(self.curPanelGameId)

	if not gCS.LuaUtils.IsNull(rotComp) then
		rotComp:SetRate(rate)

		gCS.MyPlayerManager.PlayerUnit.LocalPosition = boxTrans:TransformPoint(localPos)

		FrameTimer.New(function ()
			gCS.MyPlayerManager.PlayerUnit.LocalPosition = boxTrans:TransformPoint(localPos)
		end, 1):Start()
	end
end

function M:IsInFarCam()
	return self.curPanelGameId and L50.L50App.Scene.GamePlayUtils.ferrisPlayViewMode == 2
end

function M:SetFerrisPanelOpen(open)
	self.panelOpen = open

	gCS.FeiSuoCrouchManager.SetHideUI(LX6.Units.FeiSuoCrouchManager.HideUIReason.Ferris, open == true)

	L50.L50App.Scene.GamePlayUtils.ferrisPanelIsShow = open

	if open then
		gMessageManager:SendMessage(gEventConstants.UNIT_ENABLE_FORCE_LOD0, gCS.MyPlayerManager.PlayerUnit.Pid)
	else
		gMessageManager:SendMessage(gEventConstants.UNIT_DISABLE_FORCE_LOD0, gCS.MyPlayerManager.PlayerUnit.Pid)
	end
end

function M:OnBeforeSwitchScene(switchType)
	if gSwitchSceneType.Image <= switchType then
		self.curPanelGameId = nil
		self.curIsDouble = false
		self.ticketTypeList = {}
		self.ferrisDataList = {}
		self.npcId = nil
		self.npcPid = nil
	end
end

function M:ClearFerrisNpc(pid)
	if ulong.equals(self:GetNpcPid(), pid) then
		self.curIsDouble = false

		self:SetNpcPid(nil)
		self:SetNpcId(nil)
	end
end

gFerrisMgr = M
