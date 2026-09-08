-- Original chunk: @Lua\LuaFiles\LX6\Gameplay\Majiang\MaJiangManager.lua
-- Decompiled from: 00318_MaJiangManager.lua_8f99229e5900.luajit

C_MaJiangManager = DefClass("C_MaJiangManager", C_MaJiangManager)
local M = C_MaJiangManager

require("LX6/Gameplay/Majiang/MaJiangConst")
require("LX6/Gameplay/Majiang/MajiangGame")
require("LX6/Gameplay/Majiang/MajiangUtils")
dofile("LX6/Gameplay/Majiang/MaJiangManager_Flow.lua")
dofile("LX6/Gameplay/Majiang/MaJiangManager_Link.lua")
dofile("LX6/Gameplay/Majiang/MaJiangManager_Rank.lua")
dofile("LX6/Gameplay/Majiang/MaJiangManager_GM.lua")

M.ctor = function(self)
	self.debug = gCS.LuaUtils.IsOnEditor
	self.reachDebug = gCS.LuaUtils.IsOnEditor
	self.game = nil
	self.isInServerGame = false
	self.machine = nil
	self.entityId = nil
	self.inviteTimelinePosList = nil
	self.npcCultivationList = nil
	self.pveNpcList = {}
	self.npcPidList = nil
	self.pidToUnit = nil
	self.toDestroyPidQueue = {}
	self.destroyNpcCo = nil
	self.gameInitCo = nil
	self.myRankInfo = nil
	self.rankingList = nil

	self:InitLinkState()

	self.eventHandler = {
		[gEventConstants.L50_AFTER_SWITCH_SCENE] = self:CreateAction(self.OnEvent_AfterSwitchScene),
		[gEventConstants.L50_BEFORE_SWITCH_SCENE] = self:CreateAction(self.OnEvent_BeforeSwitchScene),
		[gEventConstants.ON_BEGIN_PORTAL] = self:CreateAction(self.OnEvent_BeginPortal),
		[gEventConstants.ON_LINK_MEMBER_REJECT_CONFIRM] = self:CreateAction(self.OnEvent_MemberRejectConfirm),
		[gEventConstants.LOGIC_AGENT_MANAGED] = self:CreateAction(self.OnEvent_LogicAgentManaged)
	}

	for event, func in pairs(self.eventHandler) do
		gMessageManager:AddMessageListener(event, func)
	end
end

M.SetInServerGame = function(self, inServerGame)
	self.isInServerGame = inServerGame
end

M.SetLocalPosition = function(self, transform, localPosition)
	if self.debug and gClientUtils.IsNil(transform) then
		print_error("[Majiang-Manager] SetLocalPosition to a null object", localPosition)
	end

	transform.localPosition = localPosition
end

M.SetPosition = function(self, transform, position)
	if self.debug and gClientUtils.IsNil(transform) then
		print_error("[Majiang-Manager] SetPosition to a null object", position)
	end

	transform.position = position
end

M.GetGame = function(self)
	if self.game ~= nil and self.debug then
		print_error("[Majiang-Manager] GetGame: game is nil")
	end

	return self.game
end

M.Temp_EnsureGame = function(self)
	if self.game == nil then
		return self.game
	end

	return self:CreateGame()
end

M.CreateGame = function(self)
	if self.game then
		print_error("[Majiang-Manager] CreateGame: game already exists")
		self.game:Dispose("New Game")
	end

	self.ignoreInServerGame = false
	self.game = C_MajiangGame.new(self)

	return self.game
end

local nullableCallTable = nil
nullableCallTable = setmetatable({}, {
	__index = function (t, k)
		return t
	end,
	__call = function ()
		return nullableCallTable
	end,
	__newindex = function ()
	end
})

M.GetGameNullableCall = function(self)
	return self.game or nullableCallTable
end

M.GetMainPanelNullableCall = function(self)
	local store = self.game and self.game.store

	if store == nil and store.STATE_EnableOnce then
		return store
	end

	return nullableCallTable
end

M.InvokeNullableGameFunction = function(self, functionName, ...)
	local func = self.game and self.game[functionName]

	if func then
		return func(self.game, ...)
	end
end

M.GetGameOrEmpty = function(self)
	return self.game or gMaJiangConst.EmptyTable
end

M.DestroyGame = function(self, reason)
	self:SetInServerGame(false)

	self.gameType = nil

	if self.gameInitCo then
		coroutine.stop(self.gameInitCo)

		self.gameInitCo = nil
	end

	gPanelManager:Close(gPanelId.S_MA_JIANG)
	gPanelManager:Close(gPanelId.S_MA_JIANG_NEW_FINAL)
	gPanelManager:Close(gPanelId.S_MA_JIANG_TEACH_PANEL)
	gPanelManager:Close(gPanelId.S_EMPTY_FULL_SCREEN_PANEL)

	local game = self.game

	if game ~= nil then
		return
	end

	game:Dispose(reason)

	self.game = nil
end

M.RegisterMiddleStore = function(self, store)
	self.middleStore = store
end

M.UnRegisterMiddleStore = function(self)
	self.middleStore = nil
end

M.PrintLuaDebug = function(self, msg)
	if not self.debug then
		return
	end

	local luaTrace = debug.traceback()

	print_error_without_stack(string.format("#NoCreateIssue [Majiang-Manager] [DEBUG] %s\nlua=", msg, luaTrace))
end

M.ReachLog = function(self, ...)
	if not self.reachDebug then
		return
	end

	print_error_without_stack("#NoCreateIssue [Majiang-Reach] ", ...)
end

gMaJiangManager = gMaJiangManager or C_MaJiangManager.new()
