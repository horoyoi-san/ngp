-- Original chunk: @Lua\LuaFiles\LX6\Manager\GamePlay\PalmKing\PalmKingAction.lua
-- Decompiled from: 02231_PalmKingAction.lua_d3b84d2b947e.luajit

local M = {}

M.SendEvent = function(self, isNpc, event, param)
	local unit = isNpc and self.npcUnit or gCS.MyPlayerManager.PlayerUnit

	if not gCS.LuaUtils.IsBaseUnitValid(unit) then
		return
	end

	if param == nil then
		gCS.LogicStateMachineManager.SendGameplayEvent(unit, event, param)
	else
		gCS.LogicStateMachineManager.SendGameplayEvent(unit, event)
	end
end

M.Change = function(self, dir, isNpc)
	local key = 510 + dir

	self.SendEvent(self, isNpc, key)
end

M.Attack = function(self, dir, isNpc)
	local param = 400 + dir

	print_debug((isNpc and "NPC" or "Player") .. "_PalmKingAction PalmKingAttack   param1  " .. param)
	self:SendEvent(isNpc, MuGenStates.Logic.GameplayEvent.PalmKingAttack, param)
end

M.PrepareDefend = function(self, dir, isNpc)
	local param = 400 + dir

	print_debug((isNpc and "NPC" or "Player") .. "_PalmKingAction PalmKingPrepareDefend   param1  " .. param)
	self:SendEvent(isNpc, MuGenStates.Logic.GameplayEvent.PalmKingPrepareDefend, param)
end

M.Defend = function(self, dir, isNpc)
	local param = 400 + dir

	print_debug("PalmKingDefenceLog   " .. (isNpc and "NPC" or "Player") .. "_PalmKingAction PalmKingDefend   ", param)
	self:SendEvent(isNpc, MuGenStates.Logic.GameplayEvent.PalmKingDefend, param)
end

M.Stunned = function(self, dir, isNpc)
	local param = 400 + dir

	print_debug("PalmKingDefenceLog   " .. (isNpc and "NPC" or "Player") .. "_PalmKingAction PalmKingStunned   ", param)
	self:SendEvent(isNpc, MuGenStates.Logic.GameplayEvent.PalmKingStunned, param)
end

M.DefenceBroken = function(self, dir, isNpc)
	local param = 400 + dir

	print_debug("PalmKingDefenceLog   " .. (isNpc and "NPC" or "Player") .. "_PalmKingAction PalmKingDefenceBroken   ", param)
	self:SendEvent(isNpc, MuGenStates.Logic.GameplayEvent.PalmKingDefenceBroken, param)
end

M.StunnedDefend = function(self, dir, isNpc)
	local param = 400 + dir

	print_debug("PalmKingDefenceLog   " .. (isNpc and "NPC" or "Player") .. "_PalmKingAction PalmKingStunnedDefend   ", param)
	self:SendEvent(isNpc, MuGenStates.Logic.GameplayEvent.PalmKingStunnedDefend, param)
end

M.StunnedFallen = function(self, dir, isNpc)
	local param = 400 + dir

	print_debug("PalmKingDefenceLog   " .. (isNpc and "NPC" or "Player") .. "_PalmKingAction PalmKingStunnedFallen   ", param)
	self:SendEvent(isNpc, MuGenStates.Logic.GameplayEvent.PalmKingStunnedFallen, param)
end

M.ReturnToPosition = function(self)
	print_debug("PalmKingAction_PalmKingReturnToPosition")
	self.SendEvent(self, false, MuGenStates.Logic.GameplayEvent.PalmKingReturnToPosition)
end

gPalmKingAction = M
