C_FootBallManager = DefClass("C_FootBallManager", C_FootBallManager)
local M = C_FootBallManager

function M:ctor()
	gMessageManager:AddMessageListener(gEventConstants.FOOTBALL_OUT_CONTROL, function (eventId, outControl)
		self:SetHUDPanel(outControl)
	end)
	gMessageManager:AddMessageListener(gEventConstants.SETTING_OUT_OF_STUCK, function ()
		self:ClosePanel()
	end)
end

function M:SetHUDPanel(outControl)
	if self.waitTimer then
		self.waitTimer:Stop()

		self.waitTimer = nil
	end

	local gameplayControlStore = gStoreManager:GetStoreGroup("CoreHudGameplayControlStore")

	if not outControl then
		gameplayControlStore:StopGameplayByType(gHUDGameplayType.FOOTBALL)
		gameplayControlStore:StartGameplayByType(gHUDGameplayType.FOOTBALL)
	end
end

function M:FBShootOrThorwTask()
	self.waitTimer = Timer.New(function ()
		local gameplayControlStore = gStoreManager:GetStoreGroup("CoreHudGameplayControlStore")

		gameplayControlStore:StopGameplayByType(gHUDGameplayType.FOOTBALL)
	end, gCS.LuaUtils.GetFootballUIHideDelayTime()):Start()
end

function M:ClosePanel()
	local gameplayControlStore = gStoreManager:GetStoreGroup("CoreHudGameplayControlStore")

	gameplayControlStore:StopGameplayByType(gHUDGameplayType.FOOTBALL)
end

gFootBallManager = gFootBallManager or C_FootBallManager.new()
