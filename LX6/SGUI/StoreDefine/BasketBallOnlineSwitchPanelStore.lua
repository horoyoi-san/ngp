-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BasketBallOnlineSwitchPanelStore.lua
-- Decompiled from: 01660_BasketBallOnlineSwitchPanelStore.lua_1acbc73719d5.luajit

C_BasketBallOnlineSwitchPanelStore = DefClass("C_BasketBallOnlineSwitchPanelStore", C_BasketBallOnlineSwitchPanelStore, C_StoreGroup)
GroupName2Class.BasketBallOnlineSwitchPanelStore = C_BasketBallOnlineSwitchPanelStore
local M = C_BasketBallOnlineSwitchPanelStore
local LinkBasketballStatus = L18.Gameplay.LinkBasketball.LinkBasketballStatus

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
	self.switchStateEnum = {
		["o\\xab\\xa5\\xa6\\xb8"] = 2,
		["\\x8f\\xb4\\xado0\\xfd6"] = 1,
		["\\xf6\\xdd'\\xf4"] = 0
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.switchStateEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	local linkBasketballManager = gCS.LinkBasketballManager.Instance

	if linkBasketballManager.basketballStatus ~= LinkBasketballStatus.InMatch then
		gCS.CameraDataMgr.cinemachineManager:EnterMovementState(LX6.Cinemachine.EMovementCamState.BasketBall2K)
	end

	if data and data.callback then
		if type(data.callback) ~= "function" then
			data.callback()
		elseif type(data.callback) ~= "userdata" then
			data.callback:DynamicInvoke()
		end
	end

	if linkBasketballManager.isFirstTurn then
		self.bindData.switchState = self.switchStateEnum.Begin

		self.bindData.ani:Play("S_Vx_BasketBallOnlineSwitchPanel_GameStart")
	elseif linkBasketballManager.isOffenseSide then
		self.bindData.switchState = self.switchStateEnum.Offence

		self.bindData.ani:Play("S_Vx_BasketBallOnlineSwitchPanel_ToOffence")
	else
		self.bindData.switchState = self.switchStateEnum.Deffence

		self.bindData.ani:Play("S_Vx_BasketBallOnlineSwitchPanel_ToDeffence")
	end

	self.UpdateName(self)
	self.UpdateHeadUseConfig(self)

	if self.autoSwitchTimer then
		self.autoSwitchTimer:Stop()

		self.autoSwitchTimer = nil
	end

	self.autoSwitchTimer = Timer.New(function ()
		gPanelManager:Close(panelId)

		if linkBasketballManager.basketballStatus ~= LinkBasketballStatus.None then
			return
		end

		gMessageManager:SendMessage(gEventConstants.ON_LINK_BASKETBALL_SWITCH_ANI_END)
		gPanelManager:CheckShow(gPanelId.BASKET_BALL_ONLINE_GAME_PANEL, {
			callback = data.gamePanelCallback,
			hideExitBtn = data.hideExitBtn
		})
	end, LTConfig.BasketBallConfig.SwitchAnimationTime):Start()
end

M.UpdateName = function(self)
	local linkBasketballManager = gCS.LinkBasketballManager.Instance
	local myName = linkBasketballManager.GetMyName(linkBasketballManager)
	local enemyName = linkBasketballManager.GetEnemyName(linkBasketballManager)
	self.bindData.myName = myName
	self.bindData.enemyName = enemyName
end

M.UpdateHead = function(self)
	local linkBasketballManager = gCS.LinkBasketballManager.Instance
	local headDataList = {
		{
			["\\x85m"] = "Q\\xb9\\x8b\\x82E",
			pid = linkBasketballManager.GetMyFirstUnitPid(linkBasketballManager)
		},
		{
			["\\x85m"] = "FIidW6<",
			pid = linkBasketballManager.GetEnemyFirstUnitPid(linkBasketballManager)
		}
	}

	for _, headData in ipairs(headDataList) do
		if headData.pid == 0 then
			local unit = gCS.SceneDataMgr.GetUnit(headData.pid)
			local cfg = gLinkBasketballManager:GetBasketballSkillConfig(unit.ClientData.cardId)
			local headId = cfg and cfg.AvaterImage or 0

			if headId == 0 then
				self.bindData:Commit(headData.key, headId, COMMIT_FORCE)
			end
		end
	end
end

M.UpdateHeadUseConfig = function(self)
	self.UpdateHead(self)
end

M.OnClose = function(self)
	if self.callbackTimer then
		self.callbackTimer:Stop()

		self.callbackTimer = nil
	end

	if self.autoSwitchTimer then
		self.autoSwitchTimer:Stop()

		self.autoSwitchTimer = nil
	end
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.ON_LINK_BASKETBALL_PLAYER_HEAD_ID_CACHED] = function ()
			if not gPanelManager:IsPanelShowing(self.m_Id) then
				return
			end

			self:UpdateHead()
		end
	}
end

M.RegisterWidget = function(self)
end
