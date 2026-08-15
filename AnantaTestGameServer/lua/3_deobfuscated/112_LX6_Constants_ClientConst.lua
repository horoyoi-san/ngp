local M = {
	CallPhoneShowType = {
		Edit = 1,
		Call_Car = 4,
		Dialing = 3,
		Contact = 0,
		Detail = 2
	},
	CallPhoneDialogType = {
		OutCall = 1,
		InCall = 2
	},
	CallPhoneChannelName = "CallPhone",
	PanelState = {
		Hide = 2,
		Show = 1
	},
	PhoneAppShowTypeLevel = {
		FirstLevel = "showType",
		SecondLevel = "secondShowType",
		ThirdLevel = "thirdShowType"
	},
	MainHomeType = {
		FakePhone = 1,
		MainPhone = 0
	},
	MainPhoneTemplateType = {
		MapTIndex = 0,
		FansIndex = 4,
		SingleAppTIndex = 2,
		LevelUpTIndex = 1,
		IndividualizationFansIndex = 5,
		FourAppTIndex = 3,
		TopButton = 6
	},
	MAIN_PHONE_ROOT_SHOW_TYPE = {
		WasherGuide = 13,
		Bubble = 3,
		FakePhoneAlbum = 5,
		YanJie = 2,
		DeliveryApp = 6,
		BeggarPayPanel = 9,
		CallPhone = 0,
		Hacker = 15,
		Chat = 4,
		Message = 12,
		Washer = 11,
		Police = 7,
		Party = 16,
		DeliveryGuide = 8,
		WallPaper = 10,
		Time = 1,
		PoliceFine = 14
	},
	DELIVERY_APP_SHOW_TYPE = {
		DRONE = 6,
		COMPLETE = 2,
		ACCOUNT = 5,
		COMPLETE_DETAIL = 3,
		OCCUPATION = 4,
		BEGIN = 0,
		CallCar = 7,
		ORDER = 1
	},
	MAIN_PHONE_FRONT_SHOW_TYPE = {
		ConfirmMessageBox = 0
	},
	WASHER_APP_SHOW_TYPE = {
		COMPLETE_DETAIL = 3,
		COMPLETE = 2,
		ACCOUNT = 5,
		OCCUPATION = 4,
		ORDER = 1
	},
	FakePhoneTemplateType = {
		TitleTIndex = 0,
		AlbumItemTIndex = 1
	},
	FakePhoneAlbumShowType = {
		PhotoDetail = 1,
		Album = 0
	},
	YanJieImageType = {
		Task = 1,
		Normal = 0
	},
	VideoPlayFinishThresholdTime = 0.5,
	YanJieScrollIngCheckInterval = 0.1,
	YanJieShowType = {
		LevelReward = 9,
		Display = 5,
		Release = 6,
		BenefitsDetail = 8,
		Collect = 3,
		Search = 4,
		MemberCenter = 7,
		Mine = 2,
		Home = 0,
		Detail = 1
	},
	FriendHomeShowType = {
		SCHEDULE = 0,
		SHARE = 2,
		PROCESS = 1
	},
	TakePhotoAnimationState = {
		SelfTakePhoto = 2,
		NormalTakePhoto = 1,
		Clear = 4,
		LookAtPhone = 3,
		None = 0
	},
	PoliceShowType = {
		Begin = 0,
		Occupation = 3,
		Case = 2,
		Notice = 4,
		Call = 5,
		Home = 1
	},
	MAX_INT = 4294967295.0,
	HALF_DAY_HOUR = 12,
	DAY_HOUR = 24,
	SECONDS_PER_MINUTE = 60,
	SECONDS_PER_HOUR = 3600,
	SECONDS_PER_DAY = 86400,
	SECONDS_PER_WEEK = 604800,
	PULL_UP_REFRESH_DISTANCE = -0.003,
	PULL_UP_REFRESH_DISTANCE_GAMEPAD = 0.1,
	PHONE_PANEL_TYPE = {
		Performance = 1,
		Function = 0
	},
	PHONE_PANEL_FUNCTION_START_TYPE = {
		Forbid = 3,
		IgnoreAction = 2,
		Normal = 1
	},
	PHONE_PANEL_PERFORM_START_TYPE = {
		Forbid = 3,
		Wait = 4
	},
	DialogState = {
		Skip = 1,
		End = 0,
		Start = 2
	},
	ComputerAppIdMap = {
		Recycle = 1000,
		Hacker2 = 4,
		Hacker1 = 3,
		File = 1,
		Webpage = 2,
		Email = 0,
		Hacker3 = 5
	}
}
M.ComputerAppId2TabIndex = {
	[M.ComputerAppIdMap.Email] = 0,
	[M.ComputerAppIdMap.File] = 1,
	[M.ComputerAppIdMap.Hacker1] = 2,
	[M.ComputerAppIdMap.Hacker2] = 3,
	[M.ComputerAppIdMap.Hacker3] = 4,
	[M.ComputerAppIdMap.Webpage] = 5
}
M.Computer_File_Type = {
	Video = 3,
	Text = 1,
	PDF = 5,
	Word = 4,
	App = 6,
	Picture = 2,
	Folder = 0
}
M.WALL_PAPER_SHOW_TYPE = {
	HOME = 0,
	DETAIL = 1
}
M.WALL_PAPER_HOME_TAB_TYPE = {
	Decoration = 1,
	Pendant = 2,
	WallPaper = 0,
	Suit = 3
}
M.MOTION_ACTION_SHOW_TYPE = {
	Double = 2,
	Single = 1
}
M.PHONE_CONFIRM_BUTTON_STATE_CONTROL = {
	ShowAll = 0,
	HideAll = 4,
	HideCancel = 1,
	HideConfirm = 2
}
M.PHONE_MESSAGE_TYPE = {
	Copy_UID_TIPS = 0
}
M.PartyShowType = {
	PartyDestination = 1,
	PartySelect = 0
}
M.BOOL2CTL = {
	[true] = 1,
	[false] = 0
}
gClientConst = M
