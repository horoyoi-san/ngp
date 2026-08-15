C_VolleyballControllerBase = DefClass("C_VolleyballControllerBase", C_VolleyballControllerBase)
local M = C_VolleyballControllerBase

function M:ctor(character, gameInstance)
	self.gameInstance = gameInstance
	self.view = character
end

function M:Init()
	return
end

function M:OnPossessionChange(team)
	return
end

function M:OnTargetChange(target)
	return
end

function M:OnCharacterStateChange(from, to)
	return
end

function M:OnDestroy()
	return
end
