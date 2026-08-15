local M = {
	gpsTypeToTaskType = {
		4,
		19,
		19,
		19,
		19,
		19
	},
	GpsTargetType = {
		Enemy = 4,
		EnemyGroup = 5,
		Destructible = 2,
		NearestMetro = 10,
		DestructibleGroup = 3,
		LuaSlot = 6,
		WayPoint = 1,
		Vehicle = 7,
		CarChallenge = 9
	},
	GpsNameSourceType = {
		CargoTarget = 1,
		NodeConfig = 0,
		CargoPickup = 2,
		Cargo = 3
	},
	DiDiType = {
		CarryIn = 0,
		DropOff = 1
	},
	SoundTriggerTiming = {
		Error = 2,
		Start = 0,
		Complete = 1
	}
}
gSpoonCommonData = M
