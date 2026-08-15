local M = gGamePlayTransitionFunc or {}

function M.Test()
	return true
end

function M.AutoPlayInActionEnd()
	return gGamePlayTransitionMgr.isActionEndPlay
end

function M.GamePlayEnd()
	return gGamePlayTransitionMgr.curGamePlayEndFlag
end

function M.IsGymSitupBeginUp()
	return gGymManager:IsGymSitupBeginUp()
end

function M.IsGymSitupDownBreak()
	return gGymManager:IsGymSitupDownBreak()
end

function M.IsGymSitupDownNormal()
	return gGymManager:IsGymSitupDownNormal()
end

function M.IsGymSitupDownOver()
	return gGymManager:IsGymSitupDownOver()
end

function M.IsGymSquatDoAction()
	return gGymManager:IsGymSquatDoAction()
end

function M.IsGymSettleExercise()
	return gGymManager:IsGymSettleExercise()
end

function M.IsGymExitExercise()
	return gGymManager:IsGymExitExercise()
end

function M.IsRestaurantEnterEat()
	return gRestaurantManager:IsRestaurantEnterEat()
end

function M.IsRestaurantExitEat()
	return gRestaurantManager:IsRestaurantExitEat()
end

function M.IsRestaurantDrink()
	return gRestaurantManager:IsRestaurantDrink()
end

function M.IsRestaurantCheers()
	return gRestaurantManager:IsRestaurantCheers()
end

function M.IsRestaurantChat()
	return gRestaurantManager:IsRestaurantChat()
end

function M.IsDinnerAlone()
	return gRestaurantManager:IsDinnerAlone()
end

function M.IsOnSenDabble()
	return gHotSpringManager:IsOnSenDabble()
end

function M.IsOnSenHoldBreath()
	return gHotSpringManager:IsOnSenHoldBreath()
end

function M.IsOnSenExit()
	return gHotSpringManager:IsOnSenExit()
end

function M.IsOnsenHighPoint()
	return gHotSpringManager:IsOnsenHighPoint()
end

function M.IsOnSenLowPoint()
	return gHotSpringManager:IsOnSenLowPoint()
end

function M.IsOnsenPointExit()
	return gHotSpringManager:IsOnSenPointExit()
end

function M.IsHomeLeftTurn()
	return gHomeInteractionManager:CheckSignalState(C_HomeInteractionManager.SIGNAL.LEFT_TURN)
end

function M.IsHomeRightTurn()
	return gHomeInteractionManager:CheckSignalState(C_HomeInteractionManager.SIGNAL.RIGHT_TURN)
end

function M.IsHomeMidTurn()
	return gHomeInteractionManager:CheckSignalState(C_HomeInteractionManager.SIGNAL.MID_TURN)
end

function M.IsHomeLeftSwitchSide()
	return gHomeInteractionManager:CheckSignalState(C_HomeInteractionManager.SIGNAL.LEFT_SIDE)
end

function M.IsHomeRightSwitchSide()
	return gHomeInteractionManager:CheckSignalState(C_HomeInteractionManager.SIGNAL.RIGHT_SIDE)
end

function M.IsHomeGetUpLeft()
	return gHomeInteractionManager:CheckSignalState(C_HomeInteractionManager.SIGNAL.LEFT_GET_UP)
end

function M.IsHomeGetUpRight()
	return gHomeInteractionManager:CheckSignalState(C_HomeInteractionManager.SIGNAL.RIGHT_GET_UP)
end

function M.IsHomeSitUp()
	return gHomeInteractionManager:CheckSignalState(C_HomeInteractionManager.SIGNAL.SIT_UP)
end

gGamePlayTransitionFunc = M
