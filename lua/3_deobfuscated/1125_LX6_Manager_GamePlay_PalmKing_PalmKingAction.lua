local M = {}

function M:Change(dir, isNpc)
	local key = 510 + dir

	if isNpc then
		gCS.LogicStateMachineManager.SendGameplayEvent(self.npcUnit, key)
	else
		gCS.LogicStateMachineManager.SendGameplayEvent(gCS.MyPlayerManager.PlayerUnit, key)
	end
end

function M:Attack(dir, isNpc)
	local param = 400 + dir

	if isNpc then
		print_debug("NPC_PalmKingAction PalmKingAttack   param1  " .. param)
		gCS.LogicStateMachineManager.SendGameplayEvent(self.npcUnit, MuGenStates.Logic.GameplayEvent.PalmKingAttack, param)
	else
		print_debug("Player_PalmKingAction PalmKingAttack   param1  " .. param)
		gCS.LogicStateMachineManager.SendGameplayEvent(gCS.MyPlayerManager.PlayerUnit, MuGenStates.Logic.GameplayEvent.PalmKingAttack, param)
	end
end

function M:PrepareDefend(dir, isNpc)
	local param = 400 + dir

	if isNpc then
		print_debug("NPC_PalmKingAction PalmKingPrepareDefend   param1  " .. param)
		gCS.LogicStateMachineManager.SendGameplayEvent(self.npcUnit, MuGenStates.Logic.GameplayEvent.PalmKingPrepareDefend, param)
	else
		print_debug("Player_PalmKingAction PalmKingPrepareDefend   param1  " .. param)
		gCS.LogicStateMachineManager.SendGameplayEvent(gCS.MyPlayerManager.PlayerUnit, MuGenStates.Logic.GameplayEvent.PalmKingPrepareDefend, param)
	end
end

function M:Defend(dir, isNpc)
	local param = 400 + dir

	if isNpc then
		print_debug("PalmKingDefenceLog   NPC_PalmKingAction PalmKingDefend   ", param)
		gCS.LogicStateMachineManager.SendGameplayEvent(self.npcUnit, MuGenStates.Logic.GameplayEvent.PalmKingDefend, param)
	else
		print_debug("PalmKingDefenceLog   Player_PalmKingAction PalmKingDefend  ", param)
		gCS.LogicStateMachineManager.SendGameplayEvent(gCS.MyPlayerManager.PlayerUnit, MuGenStates.Logic.GameplayEvent.PalmKingDefend, param)
	end
end

function M:Stunned(dir, isNpc)
	local param = 400 + dir

	if isNpc then
		print_debug("PalmKingDefenceLog   NPC_PalmKingAction PalmKingStunned   ", param)
		gCS.LogicStateMachineManager.SendGameplayEvent(self.npcUnit, MuGenStates.Logic.GameplayEvent.PalmKingStunned, param)
	else
		print_debug("PalmKingDefenceLog   Player_PalmKingAction PalmKingStunned   ", param)
		gCS.LogicStateMachineManager.SendGameplayEvent(gCS.MyPlayerManager.PlayerUnit, MuGenStates.Logic.GameplayEvent.PalmKingStunned, param)
	end
end

function M:DefenceBroken(dir, isNpc)
	local param = 400 + dir

	if isNpc then
		print_debug("PalmKingDefenceLog   NPC_PalmKingAction PalmKingDefenceBroken  ", param)
		gCS.LogicStateMachineManager.SendGameplayEvent(self.npcUnit, MuGenStates.Logic.GameplayEvent.PalmKingDefenceBroken, param)
	else
		print_debug("PalmKingDefenceLog   Player_PalmKingAction PalmKingDefenceBroken   ", param)
		gCS.LogicStateMachineManager.SendGameplayEvent(gCS.MyPlayerManager.PlayerUnit, MuGenStates.Logic.GameplayEvent.PalmKingDefenceBroken, param)
	end
end

function M:StunnedDefend(dir, isNpc)
	local param = 400 + dir

	if isNpc then
		print_debug("PalmKingDefenceLog   NPC_PalmKingAction PalmKingStunnedDefend  ", param)
		gCS.LogicStateMachineManager.SendGameplayEvent(self.npcUnit, MuGenStates.Logic.GameplayEvent.PalmKingStunnedDefend, param)
	else
		print_debug("PalmKingDefenceLog   Player_PalmKingAction PalmKingStunnedDefend  ", param)
		gCS.LogicStateMachineManager.SendGameplayEvent(gCS.MyPlayerManager.PlayerUnit, MuGenStates.Logic.GameplayEvent.PalmKingStunnedDefend, param)
	end
end

function M:StunnedFallen(dir, isNpc)
	local param = 400 + dir

	if isNpc then
		print_debug("PalmKingDefenceLog   NPC_PalmKingAction PalmKingStunnedFallen   ", param)
		gCS.LogicStateMachineManager.SendGameplayEvent(self.npcUnit, MuGenStates.Logic.GameplayEvent.PalmKingStunnedFallen, param)
	else
		print_debug("PalmKingDefenceLog   Player_PalmKingAction PalmKingStunnedFallen   ", param)
		gCS.LogicStateMachineManager.SendGameplayEvent(gCS.MyPlayerManager.PlayerUnit, MuGenStates.Logic.GameplayEvent.PalmKingStunnedFallen, param)
	end
end

function M:ReturnToPosition()
	print_debug("PalmKingAction_PalmKingReturnToPosition")
	gCS.LogicStateMachineManager.SendGameplayEvent(gCS.MyPlayerManager.PlayerUnit, MuGenStates.Logic.GameplayEvent.PalmKingReturnToPosition)
end

gPalmKingAction = M
