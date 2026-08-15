local BowlingConstants = {
	GameMode = {
		TECHNICAL = 3,
		SINGLE = 1,
		ONLINE_BATTLE = 4,
		NPC_BATTLE = 2
	},
	GameState = {
		THROWING = 5,
		MODE = 1,
		ROLLING = 6,
		GAMEOVER = 10,
		CELEBRATE = 9,
		ANIM = 3,
		READY = 4,
		SCORING = 7,
		RESETTING = 8,
		INIT = 2
	},
	LaunchState = {
		POS = 2,
		ROLLING = 6,
		ROT = 5,
		DIR = 3,
		POWER = 4,
		ANIM = 1
	},
	TimelineScene = {
		SWITCH_N = 6,
		LOSE = 9,
		SWITCH_S = 5,
		LAUNCH = 12,
		BACK = 2,
		ENTER = 1,
		BACK_S = 3,
		SWITCH_N_S = 7,
		END = 11,
		SWITCH = 4,
		DRAW = 10,
		WIN = 8
	},
	OnlineGameState = {
		PLAYING = 3,
		READY = 2,
		FINISHED = 4,
		WAITING = 1
	},
	SyncDataType = {
		RefreshLaunchUI = 5,
		PlayLaunchTimeline = 3,
		PlayBackTimeline = 2,
		BallCameraStopFollow = 7,
		Score = 1,
		ResetLaunchObj = 8,
		BallCameraFollow = 6,
		ResetCamera = 9,
		RefreshPinStateUI = 4
	}
}

return BowlingConstants
