EMapSwitchType = {
	ShowVehicleNavRoute = 2,
	HideWorkActionGps = 3,
	IsPv = 1
}
EMapSubSystemType = {
	TaxiDest = 11,
	TaskGps = 4,
	CommonUnit = 9,
	SlotEntity = 12,
	Task = 6,
	RangeEvent = 5,
	SituationalEvent = 10,
	SpiritAcquisition = 17,
	Player = 18,
	Gangster = 22,
	Vehicle = 13,
	Boss = 7,
	Legend = 21,
	Entrance = 1,
	LinkGameplay = 23,
	CollectionType5 = 15,
	CommonGps = 90,
	Camp = 16,
	Gadget = 24,
	LegacyGps = 99,
	Debug = 114514,
	Collection = 3,
	Faction = 20,
	Pin = 8,
	Doctor = 19,
	NearByMisc = 14,
	Misc = 98,
	Crime = 25,
	FunctionPoint = 2
}
gMapSubSystemTickInterval = {
	[EMapSubSystemType.Collection] = 2,
	[EMapSubSystemType.CollectionType5] = 1.9,
	[EMapSubSystemType.RangeEvent] = 0.74,
	[EMapSubSystemType.SituationalEvent] = 1.61,
	[EMapSubSystemType.Camp] = 0.54,
	[EMapSubSystemType.LegacyGps] = 0.24,
	[EMapSubSystemType.Gadget] = 0.39
}
gMapSubSystemInfo = {}

for k, v in pairs(EMapSubSystemType) do
	gMapSubSystemInfo[v] = k
end

EMapSystemFlushResult = {
	Fail = 1,
	Success = 0
}
EMapElementAnchorType = {
	Bottom = 1,
	Center = 2
}
gMapSystemElementAction = {
	Trace = 1,
	Teleport = 5,
	UntraceTask = 4,
	TraceTask = 3,
	Yanjie = 11,
	DeletePin = 7,
	GoTaxiDest = 9,
	Pin = 6,
	TeleportPortal = 10,
	Untrace = 2,
	PinAndTrace = 8
}
gMapSystemElementActionName = {
	[gMapSystemElementAction.Teleport] = "teleport",
	[gMapSystemElementAction.Trace] = "trace",
	[gMapSystemElementAction.Untrace] = "untrace",
	[gMapSystemElementAction.TraceTask] = "traceTask",
	[gMapSystemElementAction.UntraceTask] = "untraceTask",
	[gMapSystemElementAction.DeletePin] = "deletePin",
	[gMapSystemElementAction.Pin] = "pin",
	[gMapSystemElementAction.PinAndTrace] = "pinAndTrace",
	[gMapSystemElementAction.GoTaxiDest] = "goTaxiDest",
	[gMapSystemElementAction.TeleportPortal] = "teleportPortal",
	[gMapSystemElementAction.Yanjie] = "yanjie"
}
EMapViewMask = {
	RangeEvent = 512,
	Taxi = 16,
	FocusMode = 64,
	MiniMap = 2,
	AllSgui = 7,
	HudGps = 4,
	NearBy = 256,
	Faction = 128,
	All = 1023,
	Gangster = 2048,
	Metro = 32,
	DebugAll = 7,
	AllUi = 15,
	Max = 4096,
	BigMap = 1,
	Legend = 1024,
	MiniMapAndHudGps = 6,
	None = 0
}
gMapSingleViewMask = {
	[EMapViewMask.BigMap] = "BigMap",
	[EMapViewMask.MiniMap] = "MiniMap",
	[EMapViewMask.HudGps] = "HudGps",
	[EMapViewMask.Taxi] = "Taxi",
	[EMapViewMask.Metro] = "Metro"
}
EMapTooltipType = {
	Legend = 10,
	Taxi = 7,
	House = 4,
	Task = 0,
	GangsterInformation = 16,
	GangsterSelf = 11,
	GangsterCoreCamp = 14,
	Common = 9,
	GangsterSmallCamp = 12,
	Max = 16,
	Indoor = 2,
	Collection = 5,
	GangsterRandomEvent = 13,
	Faction = 15,
	Pin = 1,
	Character = 8,
	Battle = 6,
	MapEntrance = 3
}
EMapGTraceType = {
	Other = 2,
	ViewOnly = 99,
	Debug = 999,
	Main = 1,
	NearBy = 3
}
EMapElementType = {
	RangeEvent = 20,
	TaskGps = 28,
	House = 24,
	SlotEntity = 17,
	Metro = 23,
	Enemy = 1,
	ChasingCar = 31,
	PoliceCar = 30,
	TaxiTarget = 21,
	Gangster = 41,
	Debug = 999,
	Boss = 2,
	Entrance = 5,
	SpiritAcquisition = 44,
	Compound = 18,
	Camp = 9,
	Gadget = 45,
	Faction = 38,
	Player = 36,
	Gps = 27,
	NearByPhoto = 33,
	LinkGameplay = 42,
	MilkCar = 32,
	Patient = 37,
	CommonFeisuo = 43,
	Mark = 11,
	Vehicle = 29,
	Police = 39,
	UnacceptTask = 8,
	CommonGps = 35,
	Task = 7,
	Collection = 10,
	Legend = 40,
	TaskFeiSuo = 34
}
EGpsTraceEffectType = {
	GamePlay = 4,
	Task = 3,
	Tower = 2,
	Site = 5,
	Boss = 6,
	Normal = 1
}
gMapElementTypeDesc = {
	[EMapElementType.CommonGps] = {
		"CommonGps_%s"
	},
	[EMapElementType.Enemy] = {
		idTransformer = function (num)
			return "CommonUnit_" .. ulong.tostring(num)
		end,
		effectType = EGpsTraceEffectType.Boss
	},
	[EMapElementType.Player] = {
		idTransformer = function (id)
			return "Player_" .. (ulong.check(id) and ulong.tostring(id) or id)
		end
	},
	[EMapElementType.PoliceCar] = {
		idTransformer = "PoliceCar_%s"
	},
	[EMapElementType.Entrance] = {
		idTransformer = "MapEntrance_%s",
		effectType = EGpsTraceEffectType.Tower
	},
	[EMapElementType.Task] = {
		effectType = EGpsTraceEffectType.Task
	},
	[EMapElementType.TaskGps] = {
		idTransformer = "TaskGps_%s",
		effectType = EGpsTraceEffectType.Task
	},
	[EMapElementType.Camp] = {
		idTransformer = "MapCollection_%s"
	},
	[EMapElementType.Collection] = {
		idTransformer = "MapCollection_%s",
		effectType = EGpsTraceEffectType.GamePlay
	},
	[EMapElementType.SlotEntity] = {
		idTransformer = "MapSlotEntity%s"
	},
	[EMapElementType.Compound] = {
		idTransformer = "Compound_%s",
		effectType = EGpsTraceEffectType.Site
	},
	[EMapElementType.RangeEvent] = {
		idTransformer = "RangeEvent_%s"
	},
	[EMapElementType.TaxiTarget] = {
		idTransformer = "TaxiTarget_%s"
	},
	[EMapElementType.Metro] = {
		idTransformer = "MapEntrance_%s"
	},
	[EMapElementType.House] = {
		idTransformer = "MapEntrance_%s"
	},
	[EMapElementType.Vehicle] = {
		idTransformer = "Vehicle_%s"
	},
	[EMapElementType.CommonGps] = {
		idTransformer = "CommonGps_%s"
	},
	[EMapElementType.SpiritAcquisition] = {
		idTransformer = "SpiritAcquisition_%s"
	},
	[EMapElementType.Patient] = {
		idTransformer = "Patient_%s"
	},
	[EMapElementType.Faction] = {
		idTransformer = "Faction_%s"
	},
	[EMapElementType.Legend] = {
		idTransformer = "Legend_%s"
	},
	[EMapElementType.Gangster] = {
		idTransformer = "Gangster_%s"
	},
	[EMapElementType.Debug] = {
		idTransformer = "Debug_%s"
	}
}
EBigMapSelectSource = {
	CandidatePanel = 5,
	TaxiListPanel = 6,
	ClickElement = 1,
	FactionListSelect = 3,
	LegendListSelect = 4,
	OpenMapParam = 2,
	None = 0
}
