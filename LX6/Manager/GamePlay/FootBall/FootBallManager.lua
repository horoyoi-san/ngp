-- Original chunk: @Lua\LuaFiles\LX6\Manager\GamePlay\FootBall\FootBallManager.lua
-- Decompiled from: 00558_FootBallManager.lua_350c8c54fda4.luajit

C_FootBallManager = DefClass("C_FootBallManager", C_FootBallManager)
local M = C_FootBallManager

M.ctor = function(self)
	self.isInArea = false
	self.isShowFootBallPanel = false
	self.waitTimer = nil

	gMessageManager:AddMessageListener(gEventConstants.FOOTBALL_OUT_CONTROL, function (eventId, outControl)
		self:SetHUDPanel(outControl)
	end)
	gMessageManager:AddMessageListener(gEventConstants.SETTING_OUT_OF_STUCK, function ()
		self:ClosePanel()
	end)
	gMessageManager:AddMessageListener(gEventConstants.FOOTBALL_AREA_CHANGE, function (eventId, isInArea)
		self:FootballAreaChange(isInArea)
	end)
end

M.GetGameplayControlStore = function(self)
	if not self.gameplayControlStore then
		self.gameplayControlStore = gStoreManager:GetStoreGroup("CoreHudGameplayControlStore")
	end

	return self.gameplayControlStore
end

M.SetHUDPanel = function(self, outControl)
	if self.waitTimer then
		self.waitTimer:Stop()

		self.waitTimer = nil
	end

	local gameplayControlStore = self:GetGameplayControlStore()

	if not outControl then
		self.isShowFootBallPanel = true

		gameplayControlStore:StopGameplayByType(gHUDGameplayType.FOOTBALL)
		gameplayControlStore:StartGameplayByType(gHUDGameplayType.FOOTBALL)
	end
end

M.FBShootOrThorwTask = function(self)
	self.waitTimer = Timer.New(function ()
		local gameplayControlStore = self:GetGameplayControlStore()

		gameplayControlStore:StopGameplayByType(gHUDGameplayType.FOOTBALL)

		self.isShowFootBallPanel = false

		if self.isInArea then
			gameplayControlStore:StartGameplayByType(gHUDGameplayType.FOOTBALL_OFFBALL)
		end
	end, gCS.LuaUtils.GetFootballUIHideDelayTime()):Start()
end

M.ClosePanel = function(self)
	local gameplayControlStore = self:GetGameplayControlStore()

	gameplayControlStore:StopGameplayByType(gHUDGameplayType.FOOTBALL)
	gameplayControlStore:StopGameplayByType(gHUDGameplayType.FOOTBALL_OFFBALL)
end

M.FootballAreaChange = function(self, isInArea)
	self.isInArea = isInArea
	local gameplayControlStore = self:GetGameplayControlStore()

	if isInArea then
		if not self.isShowFootBallPanel then
			gameplayControlStore:StartGameplayByType(gHUDGameplayType.FOOTBALL_OFFBALL)
		end
	else
		gameplayControlStore:StopGameplayByType(gHUDGameplayType.FOOTBALL_OFFBALL)
	end
end

gFootBallManager = gFootBallManager or C_FootBallManager.new()
