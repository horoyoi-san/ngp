-- Original chunk: @Lua\LuaFiles\LX6\Manager\GamePlay\Ferris\FerrisMgr.lua
-- Decompiled from: 00538_FerrisMgr.lua_de7bc8f3f1a8.luajit

local M = gFerrisMgr or {}
M.ferrisDataList = {}
M.ticketTypeList = {}
M.curPanelGameId = nil
M.curIsDouble = false
local eventHandler = {}

eventHandler[gEventConstants.SET_FERRIS_RATE] = function (eventId, rate)
	if LX6.Game.FerrisMgr.useNew then
		return
	end

	if type(rate) ~= "number" then
		gFerrisMgr:SetFerrisRate(rate)
	elseif rate and rate[0] then
		gFerrisMgr:SetFerrisRate(tonumber(rate[0]))
	end
end

M.OnInit = function(self)
	for k, v in pairs(eventHandler) do
		gMessageManager:AddMessageListener(k, v)
	end
end

M.SetFerrisRotComp = function(self, gameId, rotComp)
	if LX6.Game.FerrisMgr.useNew then
		return
	end

	if gameId ~= 0 then
		print_error("SetFerrisRotComp gameId is 0")

		return
	end

	if not self.ferrisDataList[gameId] then
		self.ferrisDataList[gameId] = {}
	end

	self.ferrisDataList[gameId].rotComp = rotComp
end

M.GetFerrisRotComp = function(self, gameId)
	if LX6.Game.FerrisMgr.useNew then
		return
	end

	if gameId ~= 0 then
		print_error("GetFerrisRotComp gameId is 0")

		return nil
	end

	if self.ferrisDataList[gameId] then
		return self.ferrisDataList[gameId].rotComp
	end

	return nil
end

M.SetNpcId = function(self, npcId)
	if LX6.Game.FerrisMgr.useNew then
		return
	end

	self.npcId = npcId

	if npcId then
		self.timelineInviteNpcId = npcId
	end
end

M.GetTimelineInviteNpcId = function(self)
	if LX6.Game.FerrisMgr.useNew then
		return L50.L50App.Scene.FerrisMgr:GetNpcId()
	end

	return self.timelineInviteNpcId or 0
end

M.GetNpcId = function(self)
	if LX6.Game.FerrisMgr.useNew then
		return
	end

	return self.npcId or 0
end

M.SetNpcPid = function(self, npcPid)
	if LX6.Game.FerrisMgr.useNew then
		return
	end

	self.npcPid = npcPid

	if npcPid and not ulong.equals(npcPid, 0) then
		gMessageManager:SendMessage(gEventConstants.UNIT_ENABLE_FORCE_LOD0, npcPid)
	end
end

M.GetNpcPid = function(self)
	if LX6.Game.FerrisMgr.useNew then
		return
	end

	return self.npcPid or 0
end

M.SetCurActiveBox = function(self, gameId, comp)
	if LX6.Game.FerrisMgr.useNew then
		return
	end

	if gameId ~= 0 then
		print_error("SetCurActiveBox gameId is 0")

		return
	end

	if not self.ferrisDataList[gameId] then
		self.ferrisDataList[gameId] = {}
	end

	local data = self.ferrisDataList[gameId]

	if not gCS.LuaUtils.IsNull(data.curActiveBox) then
		gSpoonClientMgr:ReleaseContextEvent(data.curActiveBox.LuaEntityId, L50.Spoon.SpoonRunTime.ClientGraphType.GADGET, gSpoonEventType.OnClearGraph)

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

M.GetCurActiveBox = function(self, gameId)
	if LX6.Game.FerrisMgr.useNew then
		return
	end

	if gameId ~= 0 then
		print_error("GetCurActiveBox gameId is 0")

		return nil
	end

	if self.ferrisDataList[gameId] then
		return self.ferrisDataList[gameId].curActiveBox
	end

	return nil
end

M.IsInFarCam = function(self)
	if LX6.Game.FerrisMgr.useNew then
		return false
	end

	return self.curPanelGameId and L50.L50App.Scene.GamePlayUtils.ferrisPlayViewMode ~= 2
end

M.GetTicketType = function(self, gameId)
	if LX6.Game.FerrisMgr.useNew then
		return L50.L50App.Scene.FerrisMgr:GetTicketType()
	end

	if gameId ~= 0 then
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

M.SetTicketType = function(self, gameId, ticketType)
	if LX6.Game.FerrisMgr.useNew then
		L50.L50App.Scene.FerrisMgr:SetTicketType(ticketType, gameId)

		return
	end

	if gameId ~= 0 then
		print_error("SetTicketType gameId is 0")

		return
	end

	self.ticketTypeList[gameId] = ticketType
end

M.SetFerrisRate = function(self, rate)
	if LX6.Game.FerrisMgr.useNew then
		L50.L50App.Scene.FerrisMgr:SetFerrisRate(rate)

		return
	end

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

M.OnFerrisPanelChange = function(self, open)
	if LX6.Game.FerrisMgr.useNew then
		L50.L50App.Scene.FerrisMgr:OnFerrisPanelChange(open)

		return
	end

	gCS.FeiSuoCrouchManager.SetHideUI(LX6.Units.FeiSuoCrouchManager.HideUIReason.Ferris, open ~= true)

	L50.L50App.Scene.GamePlayUtils.ferrisPanelIsShow = open

	if open then
		gMessageManager:SendMessage(gEventConstants.UNIT_ENABLE_FORCE_LOD0, gCS.MyPlayerManager.PlayerUnit.Pid)
	else
		gMessageManager:SendMessage(gEventConstants.UNIT_DISABLE_FORCE_LOD0, gCS.MyPlayerManager.PlayerUnit.Pid)
	end
end

M.OnBeforeSwitchScene = function(self, switchType)
	if LX6.Game.FerrisMgr.useNew then
		return
	end

	if gSwitchSceneType.SameImage < switchType then
		self.curPanelGameId = nil
		self.curIsDouble = false
		self.ticketTypeList = {}
		self.ferrisDataList = {}
		self.npcId = nil
		self.npcPid = nil
	end
end

M.CurIsDouble = function(self)
	if LX6.Game.FerrisMgr.useNew then
		return not L50.L50App.Scene.FerrisMgr:GetIsSingle()
	else
		return gFerrisMgr.curIsDouble
	end
end

M.ClearFerrisNpc = function(self, pid)
	if LX6.Game.FerrisMgr.useNew then
		return
	end

	if ulong.equals(self:GetNpcPid(), pid) then
		self.curIsDouble = false

		self:SetNpcPid(nil)
		self:SetNpcId(nil)
	end
end

gFerrisMgr = M
