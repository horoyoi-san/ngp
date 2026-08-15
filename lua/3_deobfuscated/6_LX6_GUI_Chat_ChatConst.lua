local ChatConst = {
	MsgTemplateMode = L50.Chat.ChatMsgTemplateMode,
	MsgMode = L50.Chat.ChatMsgMode
}
local M = ChatConst
ChatConst.TabShowType = {
	PersonalPage = 11,
	EditRemarkName = 9,
	NpcToNpcChatting = 5,
	Setting = 12,
	Invite = 1,
	ChattingGroup = 16,
	EditGroupMember = 18,
	GroupMemberPage = 19,
	NpcChatting = 2,
	ChatingToFriend = 14,
	ApplicationPage = 4,
	BlackList = 13,
	AddFriend = 7,
	Channel = 0,
	NpcPhoneChannel = 6,
	NewRequest = 8,
	EditPersonalNote = 10,
	WebPage = 3,
	CreateGroup = 15,
	GroupSetting = 17
}
ChatConst.TabInfo = {
	Default = {
		BgType = 0,
		HideCloseBtn = false
	},
	[ChatConst.TabShowType.Channel] = {
		BgType = 1,
		HideCloseBtn = true
	},
	[ChatConst.TabShowType.NpcPhoneChannel] = {
		BgType = 1,
		HideCloseBtn = true
	}
}
ChatConst.CloseButtonType = {
	Return = 1,
	CloseApp = 2,
	Hide = 0,
	ClosePhone = 3
}
ChatConst.SpecialMsgType = {
	Team = 9,
	Photo = 4,
	Place = 1,
	Location = 2,
	SendPhoto = 5,
	Money = 8,
	TakePhoto = 6,
	Emoji = 3,
	Link = 7
}
ChatConst.MessageType = {
	Text = 1,
	Photo = 7,
	Voice = 4,
	Emoji = 8,
	BubbleNotice = 10,
	Waiting = 3,
	HintSimple = -1,
	Restaurant = 5,
	Task = -4,
	NewJoinGroup = 13,
	Channel = 2,
	Tips = -2,
	Money = 11,
	TipsWithIcon = -5,
	Team = 12,
	Link = 9,
	Map = 6
}
ChatConst.SpecialMsgType2MsgType = {
	[M.SpecialMsgType.Place] = M.MessageType.Restaurant,
	[M.SpecialMsgType.Location] = M.MessageType.Map,
	[M.SpecialMsgType.Emoji] = M.MessageType.Emoji,
	[M.SpecialMsgType.Photo] = M.MessageType.Photo,
	[M.SpecialMsgType.SendPhoto] = M.MessageType.Photo,
	[M.SpecialMsgType.TakePhoto] = M.MessageType.Photo,
	[M.SpecialMsgType.Link] = M.MessageType.Link,
	[M.SpecialMsgType.Money] = M.MessageType.Money,
	[M.SpecialMsgType.Team] = M.MessageType.Team
}
ChatConst.MsgType2Template = {
	[M.MessageType.Text] = {
		Left = 0,
		Right = 1
	},
	[M.MessageType.Channel] = {},
	[M.MessageType.Waiting] = {
		Left = 2,
		Right = 3
	},
	[M.MessageType.Voice] = {
		Left = 4,
		Right = 5
	},
	[M.MessageType.Restaurant] = {
		Left = 6,
		Right = 7
	},
	[M.MessageType.Map] = {
		Left = 8
	},
	[M.MessageType.Photo] = {
		Left = 9,
		Right = 10
	},
	[M.MessageType.Emoji] = {
		Left = 11,
		Right = 12
	},
	[M.MessageType.Link] = {
		Left = 13
	},
	[M.MessageType.BubbleNotice] = {
		Left = 14,
		Right = 15
	},
	[M.MessageType.HintSimple] = {
		Mid = 16
	},
	[M.MessageType.Tips] = {
		Mid = 17
	},
	[M.MessageType.Task] = {
		Mid = 18
	},
	[M.MessageType.TipsWithIcon] = {
		Mid = 19
	},
	[M.MessageType.Money] = {
		Left = 20,
		Right = 21
	},
	[M.MessageType.Team] = {
		Left = 22,
		Right = 23
	},
	[M.MessageType.NewJoinGroup] = {
		mid = 24
	}
}
gChatConst = M
