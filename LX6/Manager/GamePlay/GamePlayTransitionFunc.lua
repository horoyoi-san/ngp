-- Original chunk: @Lua\LuaFiles\LX6\Manager\GamePlay\GamePlayTransitionFunc.lua
-- Decompiled from: 02181_GamePlayTransitionFunc.lua_405a1bfd7775.luajit

local M = gGamePlayTransitionFunc or {}

M.Test = function()
	return true
end

M.AutoPlayInActionEnd = function()
	return gGamePlayTransitionMgr.isActionEndPlay
end

M.IsGymSitupBeginUp = function()
	return gGymManager:IsGymSitupBeginUp()
end

M.IsGymSitupDownBreak = function()
	return gGymManager:IsGymSitupDownBreak()
end

M.IsGymSitupDownNormal = function()
	return gGymManager:IsGymSitupDownNormal()
end

M.IsGymSitupDownOver = function()
	return gGymManager:IsGymSitupDownOver()
end

M.IsGymSquatDoAction = function()
	return gGymManager:IsGymSquatDoAction()
end

M.IsGymSettleExercise = function()
	return gGymManager:IsGymSettleExercise()
end

M.IsGymExitExercise = function()
	return gGymManager:IsGymExitExercise()
end

M.IsRestaurantEnterEat = function()
	return gRestaurantManager:IsRestaurantEnterEat()
end

M.IsRestaurantExitEat = function()
	return gRestaurantManager:IsRestaurantExitEat()
end

M.IsRestaurantDrink = function()
	return gRestaurantManager:IsRestaurantDrink()
end

M.IsRestaurantCheers = function()
	return gRestaurantManager:IsRestaurantCheers()
end

M.IsRestaurantChat = function()
	return gRestaurantManager:IsRestaurantChat()
end

M.IsDinnerAlone = function()
	return gRestaurantManager:IsDinnerAlone()
end

M.IsOnSenDabble = function()
	return gHotSpringManager:IsOnSenDabble()
end

M.IsOnSenHoldBreath = function()
	return gHotSpringManager:IsOnSenHoldBreath()
end

M.IsOnSenExit = function()
	return gHotSpringManager:IsOnSenExit()
end

M.IsOnsenHighPoint = function()
	return gHotSpringManager:IsOnsenHighPoint()
end

M.IsOnSenLowPoint = function()
	return gHotSpringManager:IsOnSenLowPoint()
end

M.IsOnsenPointExit = function()
	return gHotSpringManager:IsOnSenPointExit()
end

M.IsHomeLeftTurn = function()
	return gHomeInteractionManager:CheckSignalState(C_HomeInteractionManager.SIGNAL.LEFT_TURN)
end

M.IsHomeRightTurn = function()
	return gHomeInteractionManager:CheckSignalState(C_HomeInteractionManager.SIGNAL.RIGHT_TURN)
end

M.IsHomeMidTurn = function()
	return gHomeInteractionManager:CheckSignalState(C_HomeInteractionManager.SIGNAL.MID_TURN)
end

M.IsHomeLeftSwitchSide = function()
	return gHomeInteractionManager:CheckSignalState(C_HomeInteractionManager.SIGNAL.LEFT_SIDE)
end

M.IsHomeRightSwitchSide = function()
	return gHomeInteractionManager:CheckSignalState(C_HomeInteractionManager.SIGNAL.RIGHT_SIDE)
end

M.IsHomeGetUpLeft = function()
	return gHomeInteractionManager:CheckSignalState(C_HomeInteractionManager.SIGNAL.LEFT_GET_UP)
end

M.IsHomeGetUpRight = function()
	return gHomeInteractionManager:CheckSignalState(C_HomeInteractionManager.SIGNAL.RIGHT_GET_UP)
end

M.IsHomeSitUp = function()
	return gHomeInteractionManager:CheckSignalState(C_HomeInteractionManager.SIGNAL.SIT_UP)
end

gGamePlayTransitionFunc = M
