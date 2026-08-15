BigMapFSMState = DefClass("BigMapFSMState", BigMapFSMState)
local M = BigMapFSMState

function M:ProcessSignal(signal, ...)
	return nil
end

BigMapFSMState_Selected = DefClass("BigMapFSMState_Selected", BigMapFSMState_Selected, BigMapFSMState)
