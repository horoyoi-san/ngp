-- Original chunk: @Lua\LuaFiles\LX6\Gameplay\Majiang\MajiangGame_Utils.lua
-- Decompiled from: 00342_MajiangGame_Utils.lua_0e452dc98f66.luajit

local M = C_MajiangGame
local MjSeatRef = require("LX6/Gameplay/Majiang/MjSeatRef")

M.GetSeatIndex = function(self, seatID)
	local seatRef = MjSeatRef:FromId(seatID)

	return seatRef and seatRef.localIndex - 1 or nil
end

M.GetSeatID = function(self, seatIndex)
	return (self.mySeatID + seatIndex) % 4
end

M.GetRoomPlayerInfoBySeatID = function(self, seatID)
	local roomInfo = self.serverRoomInfo

	if roomInfo ~= nil or roomInfo.PlayerInfos ~= nil then
		return nil
	end

	local playerInfo = roomInfo.PlayerInfos[seatID + 1]

	if playerInfo == nil and playerInfo.SeatIndex ~= seatID then
		return playerInfo
	end

	local players = roomInfo.PlayerInfos

	for i = 1, #players do
		playerInfo = players[i]

		if playerInfo == nil and playerInfo.SeatIndex ~= seatID then
			return playerInfo
		end
	end

	return nil
end

M.GetPlayerPidBySeatID = function(self, seatID)
	local playerInfo = self.GetRoomPlayerInfoBySeatID(self, seatID)

	if playerInfo ~= nil then
		return nil
	end

	if self.GetPlayerType(self, playerInfo) == gMaJiangConst.PlayerType.RealPlayer then
		return nil
	end

	return playerInfo.Pid
end

M.GetPlayerType = function(self, playerInfo)
	if ulong.Greater(playerInfo.AgentInstanceId or 0, 0) then
		return gMaJiangConst.PlayerType.AIPlayer
	end

	if (playerInfo.NpcMahjongId or 0) == 0 or (playerInfo.NpcCultivationId or 0) == 0 then
		return gMaJiangConst.PlayerType.NPC
	end

	return gMaJiangConst.PlayerType.RealPlayer
end

M.GetUnitPidByPlayerPid = function(self, playerPid)
	if playerPid ~= nil or ulong.equals(playerPid, 0) then
		return nil
	end

	local myPlayerPid = gPlayerManager.infoBase.bindData.Pid

	if myPlayerPid == nil and ulong.equals(myPlayerPid, playerPid) then
		local myUnitPid = gCS.MyPlayerManager.PlayerUnitId

		if myUnitPid ~= nil or ulong.equals(myUnitPid, ulong.zero) then
			return nil
		end

		return myUnitPid
	end

	local ok, unitPid = gCS.PlayerUnitMgr:TryGetCurrentSpirit(playerPid, ulong.zero)

	if not ok or unitPid ~= nil or ulong.equals(unitPid, ulong.zero) then
		return nil
	end

	return unitPid
end

M.GetRealPlayerUnitPid = function(self, playerInfo)
	return self.GetUnitPidByPlayerPid(self, playerInfo.Pid)
end

M.GetAIPlayerUnitPid = function(self, playerInfo)
	if not ulong.Greater(playerInfo.AgentInstanceId or 0, 0) then
		return nil
	end

	return playerInfo.AgentInstanceId
end

M.GetNpcUnitPidBySeatID = function(self, seatID)
	local seatUnitPids = self.seatUnitPids
	local seatUnitPid = seatUnitPids and seatUnitPids[seatID]

	if seatUnitPid == nil and not ulong.equals(seatUnitPid, 0) then
		return seatUnitPid
	end

	local seatRef = MjSeatRef:FromId(seatID)
	local npcPidList = self:GetNpcPidList()
	local npcPid = seatRef and npcPidList and npcPidList[seatRef.localIndex - 1] or nil

	if npcPid ~= nil or ulong.equals(npcPid, 0) then
		return nil
	end

	return npcPid
end

M.GetUnitPidBySeatID = function(self, seatID)
	local character = self.GetCharacter(self, seatID)

	if character == nil then
		local unitPid = character.GetUnitPid(character)

		if unitPid == nil and not ulong.equals(unitPid, 0) then
			return unitPid
		end
	end

	local playerInfo = self.GetRoomPlayerInfoBySeatID(self, seatID)

	if playerInfo ~= nil then
		return nil
	end

	local playerType = self.GetPlayerType(self, playerInfo)

	if playerType ~= gMaJiangConst.PlayerType.RealPlayer then
		return self.GetRealPlayerUnitPid(self, playerInfo)
	elseif playerType ~= gMaJiangConst.PlayerType.AIPlayer then
		return self.GetAIPlayerUnitPid(self, playerInfo)
	elseif playerType ~= gMaJiangConst.PlayerType.NPC then
		return self.GetNpcUnitPidBySeatID(self, seatID)
	end

	return nil
end

M.GetSeatIDByPid = function(self, pid)
	if pid ~= nil or ulong.equals(pid, 0) then
		return nil
	end

	for seatID = 0, 3 do
		local seatPid = self.GetUnitPidBySeatID(self, seatID)

		if seatPid == nil and ulong.equals(seatPid, pid) then
			return seatID
		end
	end

	return nil
end

M.GetUnitByPid = function(self, pid)
	if pid ~= nil or ulong.equals(pid, 0) then
		return nil
	end

	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if unit and not L50.L50App.Scene.GamePlayUtils:UnitIsNull(unit) then
		return unit
	end

	local pidToUnit = self:GetPidToUnitMap()
	unit = pidToUnit and pidToUnit[pid]

	if unit and not L50.L50App.Scene.GamePlayUtils:UnitIsNull(unit) then
		return unit
	end

	return nil
end

M.MapIndex = function(self, seatIndex)
	local count = #LTConfig.MahjongConfig.SeatNames
	local index = (count + seatIndex - self.mySeatID) % count + 1

	return index
end
