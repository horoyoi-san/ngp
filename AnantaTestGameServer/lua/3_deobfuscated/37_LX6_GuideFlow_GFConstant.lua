gGuideNodeState = {
	Failure = 3,
	Running = 1,
	Match = 4,
	Ready = 0,
	Success = 2
}
gGFConstant = {
	NodeType = {
		Selector = 6,
		Branch = 3,
		Action = 1,
		Parallel = 5,
		Decorator = 2,
		Sequence = 4
	},
	Policy = {
		OneSuccess = 1,
		AllSuccess = 3,
		AllFailure = 4,
		OneFailure = 2
	},
	State = {
		Ready = 0,
		Running = 1,
		Failure = 3,
		Success = 2
	},
	GameStage = LX6.Scene.SwitchSceneManager.GameStage,
	CheckState = {
		DoingFeisuo = 4,
		DoingAirRush = 8,
		DoingIdle = 5,
		DoingJump = 7,
		FightPowerFill = 20,
		DoingFall = 16,
		DoingClimbSlowStay = 12,
		IsOutDoor = 19,
		HasMindPowerTarget = 18,
		CanSwing = 1,
		DoingRun = 13,
		DoingClimbStay = 11,
		CanAirRush = 17,
		FeisuoBattle = 15,
		DoingSwing = 2,
		DoingClimbSlow = 9,
		FightSpiritBigSkill = 6,
		DoingClimbRun = 10,
		DoingRush = 14,
		CanFeisuo = 3,
		None = 0
	},
	CheckStateSuccessMode = {
		ExecuteFinish = 2,
		StateChange = 1
	},
	JoystickDir = {
		Down = 1,
		Up = 0,
		Left = 2,
		Right = 3
	},
	TextDir = {
		BottomLeft = 6,
		Top = 2,
		TopLeft = 4,
		Left = 0,
		TopRight = 5,
		Right = 1,
		BottomRight = 7,
		Bottom = 3,
		Normal = 8
	},
	ActionType = {
		ShowFreeClickMask = 1
	},
	StartType = {
		Server = 0,
		GuideEvent = 5,
		Count = 6,
		Level = 1,
		PanelClose = 3,
		PanelOpen = 2,
		MessageEvent = 4
	},
	MaskMode = {
		Clickable = 4,
		Normal = 1
	},
	ShowType = {
		PCKey = 1,
		Icon = 2,
		None = 0
	},
	BranchSwitchType = {
		Finish = 2,
		Reset = 1,
		Stop = 0
	},
	GuideGlyphType = {
		ControllerCell = 2,
		KeyboardIcon = 1,
		Text = 4,
		Icon = 3,
		None = 0
	},
	GuideTagType = {
		TaskSubmit = 1,
		ObtainSpirit = 3,
		FashionWear = 5,
		OnPanelOpen = 2,
		SwitchSpirit = 4,
		ObtainVehicle = 6,
		None = 0
	}
}
gGFSignal = {
	LingPanel_LevelUp = 2,
	TestSignal = 1
}

return gGFConstant
