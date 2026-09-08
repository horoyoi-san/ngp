-- Original chunk: @Lua\LuaFiles\LX6\GUI\NpcChat\NpcChatConst.lua
-- Decompiled from: 00300_NpcChatConst.lua_5614d50dd407.luajit

local NpcChatConst = {}
local M = NpcChatConst
NpcChatConst.PlayerSelfIndex = 1
NpcChatConst.TabShowType = {
	["5F\\x87\\x87\\x97D"] = 1,
	["I\\x99\\xa4\\xb0\\xf2\\xa0\\xc6\\xa1>\\xa68"] = 5,
	["\r:#\\xd4{\\x97\\xf91\\x8b'\\xe7\\xfc\\xe8q\\xf7"] = 6,
	["\\xb1$#p\\x9cU\\xcd>\\xa4\\xbe"] = 2,
	["\\xee\\xde-#\\xf4"] = 3,
	["\\xfa\\xd3!\\xfd"] = 0,
	[":0\\xe8z\\x9b\\xf6 \\xa1 \\xe8\\xc2\\xe7s\\xfe"] = 4
}
NpcChatConst.TabInfo = {
	Default = {
		[">O\\xa5\\x97\\x93D"] = 0,
		["G\\xa8ro\\xbe\\xfdToXjB"] = false
	},
	[NpcChatConst.TabShowType.Channel] = {
		[">O\\xa5\\x97\\x93D"] = 1,
		["G\\xa8ro\\xbe\\xfdToXjB"] = false
	},
	[NpcChatConst.TabShowType.NpcPhoneChannel] = {
		[">O\\xa5\\x97\\x93D"] = 1,
		["G\\xa8ro\\xbe\\xfdToXjB"] = false
	}
}
NpcChatConst.CloseButtonType = {
	[".M\\x85\\x9b\\x91O"] = 1,
	["\\x88\\xbd\n\\xb8o\\xee#"] = 2,
	["R+y^"] = 0,
	["pV\\xc1\\xae\\x818\\xb0\\xc7\\xed"] = 3
}
NpcChatConst.SpecialMsgType = {
	["pBbm~7"] = 5,
	["}\\xa6\\xad\\xbb\\xb9"] = 4,
	["}\\xa2\\xa3\\xac\\xb3"] = 1,
	["\\x87\\xbe\\xaa~7\\xf1="] = 2,
	["wFgl~7"] = 6,
	["h\\xa3\\xad\\xa5\\xbf"] = 3,
	["V+sP"] = 7,
	["`\\xa1\\xac\\xaa\\xaf"] = 8
}
NpcChatConst.MessageType = {
	["N'eO"] = 1,
	["}\\xa6\\xad\\xbb\\xb9"] = 7,
	["{\\xa1\\xab\\xac\\xb3"] = 4,
	["h\\xa3\\xad\\xa5\\xbf"] = 8,
	["Mc\\xaeu@\\xb7\\xdcH~s}I"] = 10,
	["`\\xa1\\xac\\xaa\\xaf"] = 11,
	["\\xfa\\xd3!\\xfd"] = 2,
	["N#nP"] = -4,
	["N+mH"] = -2,
	["\\xee\\xda\t*\\xf6"] = 3,
	["[\\xbcd{\\xbb\\xe6OCyqB"] = -5,
	["{S\\xc0\\xa9\\xb7\\xb5\\xc5\\xed"] = -1,
	["a_ݩ\\x85\\xaa\\xc7\\xfc"] = 5,
	["V+sP"] = 9,
	["\\xa3iv"] = 6
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
		["V'{O"] = 0,
		["\\xa7\\xa5\\xa7\\xa2"] = 1
	},
	[M.MessageType.Channel] = {},
	[M.MessageType.Waiting] = {
		["V'{O"] = 2,
		["\\xa7\\xa5\\xa7\\xa2"] = 3
	},
	[M.MessageType.Voice] = {
		["V'{O"] = 4,
		["\\xa7\\xa5\\xa7\\xa2"] = 5
	},
	[M.MessageType.Restaurant] = {
		["V'{O"] = 6,
		["\\xa7\\xa5\\xa7\\xa2"] = 7
	},
	[M.MessageType.Map] = {
		["V'{O"] = 8,
		["\\xa7\\xa5\\xa7\\xa2"] = 22
	},
	[M.MessageType.Photo] = {
		["V'{O"] = 9,
		["\\xa7\\xa5\\xa7\\xa2"] = 10
	},
	[M.MessageType.Emoji] = {
		["V'{O"] = 11,
		["\\xa7\\xa5\\xa7\\xa2"] = 12
	},
	[M.MessageType.Link] = {
		["V'{O"] = 13,
		["\\xa7\\xa5\\xa7\\xa2"] = 23
	},
	[M.MessageType.BubbleNotice] = {
		["V'{O"] = 14,
		["\\xa7\\xa5\\xa7\\xa2"] = 15
	},
	[M.MessageType.HintSimple] = {
		["\\xa3ab"] = 16
	},
	[M.MessageType.Tips] = {
		["\\xa3ab"] = 17
	},
	[M.MessageType.Task] = {
		["\\xa3ab"] = 18
	},
	[M.MessageType.TipsWithIcon] = {
		["\\xa3ab"] = 19
	},
	[M.MessageType.Money] = {
		["V'{O"] = 20,
		["\\xa7\\xa5\\xa7\\xa2"] = 21
	}
}
M.ChatMessageSource = {
	["`NϿ\\x88\r\\x94\r\\xda\\xfc"] = 3,
	["\\xb63.0j\\x98b\\xd12\\xa9\\xb2"] = 4,
	["0I\\x85\\x8b\\x90U"] = 2,
	["`S\\xc0\\xba\\x88\r\\x8b\\xc7\\xeb"] = 1,
	["a\\xa1\\xa1\\xae\\xba"] = 0
}
M.ChatMsgTemplateMode = {
	["/Q\\x82\\x9a\\x86L"] = 2,
	["1Q\\xb2\\x86\\x82U"] = 0,
	["wOi`\\=,"] = 1
}
M.HeadIconType = {
	["/Q\\x82\\x9a\\x86L"] = 2,
	["\\xfa\\xd3!\\xfd"] = 3,
	["\\x85\\x81&\\x8cx1\\xeb#"] = 4
}
M.ChatTopChannel = {
	["I'q]"] = 2,
	["\\x85\\xa1\\x8cx1\\xeb#"] = 11,
	["\\xa0xe"] = 10
}
gNpcChatConst = M
