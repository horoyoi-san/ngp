local ColorConfig = LTConfig.ColorConfig
local M = {
	DRAG_LENGTH = 6,
	GROUP_MEMBER_CREATE = 1,
	GROUP_MEMBER_KICK = 3,
	IMAGE_STR = "[图片]",
	MOVE_BACK_LENGTH = 100,
	GROUP_MEMBER_INVITE = 2,
	CALLBACK = 4,
	XiaoQianRobotSender = "XiaoQianRobot",
	AUDIO_STR = "[语音]",
	MOVE_BACK_LEFT_BOUND = 100,
	TYPE_TEAM_RECOMMEND = 1,
	MOVE_LEFT_LENGTH = 100,
	HIGHTLIGHT_COLOR = ColorConfig.GetConfig(ColorConfig.HIGHTLIGHT_COLOR).Color,
	HIGHTLIGHT_COLOR_VER = ColorConfig.GetConfig(ColorConfig.HIGHTLIGHT_COLOR).Color,
	XiaoQian = {
		Pid = "100",
		Name = "小倩-工作号",
		Level = 150
	},
	XiaoQianRobotInfo = {
		Pid = "100",
		Name = "小倩",
		Level = 150
	},
	CheckChatResultType = {
		TimeFailed = 3,
		SensitiveWords = 6,
		MoneyFailed = 4,
		Unverified = 9,
		PhoneVerified = 5,
		Success = 1,
		Unavailable = 8,
		LevelFailed = 2,
		ChatLimitOther = 7
	}
}
gContactUtils = M
