local M = L50.Spoon.SpoonRunTime.SpoonIdEvent
M.EventOutToOtherType = {
	[M.OnDestructibleEvent] = gEventConstants.DESTRUCTIBLE_EVENT
}
M.DestructibleEventType = {
	Hit = 5,
	LeaveHoldByShoot = 9,
	Damage = 6,
	EnterMagnet = 7,
	HoldInterrupted = 11,
	Q = 0,
	LeaveHoldNotByShoot = 10,
	VehicleHit = 12,
	HandHold = 13,
	PutDown = 14,
	EnterHold = 2,
	Raise = 1,
	LeaveMagnet = 8,
	LeaveHold = 3,
	Break = 4
}
M.TriggerConditionType = {
	Enter = 1,
	EnterAndExit = 3,
	Exit = 2
}
M.LimitEventType = {
	[M.OnGadgetValueAt] = true,
	[M.StateChange] = true
}
gSpoonEventType = M
