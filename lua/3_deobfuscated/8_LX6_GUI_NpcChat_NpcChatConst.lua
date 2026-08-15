local NpcChatConst = {}
local M = NpcChatConst
NpcChatConst.PlayerSelfIndex = 1
NpcChatConst.TabShowType = {
	Invite = 1,
	NpcToNpcChatting = 5,
	NpcPhoneChannel = 6,
	NpcChatting = 2,
	WebPage = 3,
	Channel = 0,
	ApplicationPage = 4
}
NpcChatConst.TabInfo = {
	Default = {
		BgType = 0,
		HideCloseBtn = false
	},
	[NpcChatConst.TabShowType.Channel] = {
		BgType = 1,
		HideCloseBtn = false
	},
	[NpcChatConst.TabShowType.NpcPhoneChannel] = {
		BgType = 1,
		HideCloseBtn = false
	}
}
NpcChatConst.CloseButtonType = {
	Return = 1,
	CloseApp = 2,
	Hide = 0,
	ClosePhone = 3
}
NpcChatConst.SpecialMsgType = {
	SendPhoto = 5,
	Photo = 4,
	Place = 1,
	Location = 2,
	TakePhoto = 6,
	Emoji = 3,
	Link = 7,
	Money = 8
}
NpcChatConst.MessageType = {
	Text = 1,
	Photo = 7,
	Voice = 4,
	Emoji = 8,
	BubbleNotice = 10,
	Money = 11,
	Channel = 2,
	Task = -4,
	Tips = -2,
	Waiting = 3,
	TipsWithIcon = -5,
	HintSimple = -1,
	Restaurant = 5,
	Link = 9,
	Map = 6
}
NpcChatConst.SpecialMsgType2MsgType = {
	[M.SpecialMsgType.Place] = M.MessageType.Restaurant,
	[M.SpecialMsgType.Location] = M.MessageType.Map,
	[M.SpecialMsgType.Emoji] = M.MessageType.Emoji,
	[M.SpecialMsgType.Photo] = M.MessageType.Photo,
	[M.SpecialMsgType.SendPhoto] = M.MessageType.Photo,
	[M.SpecialMsgType.TakePhoto] = M.MessageType.Photo,
	[M.SpecialMsgType.Link] = M.MessageType.Link,
	[M.SpecialMsgType.Money] = M.MessageType.Money
}
NpcChatConst.MsgType2Template = {
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
		Left = 8,
		Right = 22
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
		Left = 13,
		Right = 23
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
	}
}
M.ChatMessageSource = {
	StableList = 3,
	IgnoreCheck = 4,
	Latest = 2,
	SingleSync = 1,
	Local = 0
}
M.ChatMsgTemplateMode = {
	System = 2,
	MyChat = 0,
	TheirChat = 1
}
M.HeadIconType = {
	System = 2,
	Channel = 3,
	NPCGroup = 4
}
M.ChatTopChannel = {
	Self = 2,
	NpcGroup = 11,
	Npc = 10
}
gNpcChatConst = M
