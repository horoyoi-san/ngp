-- Original chunk: @Lua\LuaFiles\LX6\Manager\Link\LinkManager_Extension.lua
-- Decompiled from: 00704_LinkManager_Extension.lua_57efa09cd486.luajit

local LinkMode = UX.Game.LinkMode
local LinkModeConfig = LTConfig.LinkModeConfig
local LinkMultiPlayerConfig = LTConfig.LinkMultiPlayerConfig
local PrepareRoomState = UX.Game.PrepareRoomState
local LinkStageConfig = LTConfig.LinkStageConfig
local M = C_LinkManager

M.CheckIsInRace = function(self)
	if self.LinkMode == LinkMode.Match or not self.currentGameCfg then
		return false
	end

	return self.currentGameCfg.MultiType ~= LinkMultiPlayerConfig.MultiTypeType.Race
end

M.CheckIsInHideAndSeek = function(self)
	if self.LinkMode == LinkMode.Match or not self.currentGameCfg then
		return false
	end

	return self.currentGameCfg.MultiType ~= LinkMultiPlayerConfig.MultiTypeType.HideAndSeek
end

M.CheckIsInBattle = function(self)
	if self.LinkMode == LinkMode.Match or not self.currentGameCfg then
		return false
	end

	return self.currentGameCfg.MultiType ~= LinkMultiPlayerConfig.MultiTypeType.Battle
end

M.CheckIsInRaid = function(self)
	if self.LinkMode == LinkMode.Match or not self.currentGameCfg then
		return false
	end

	return self.currentGameCfg.MultiType ~= LinkMultiPlayerConfig.MultiTypeType.Raid
end

M.CheckIsExtractionShooter = function(self)
	if self.LinkMode == LinkMode.Match then
		return false
	end

	local multiType = self.currentGameCfg and self.currentGameCfg.MultiType or self.curMultiType

	return multiType ~= LinkMultiPlayerConfig.MultiTypeType.ExtractionShooter
end

M.CheckIsExtractionShooterSettling = function(self)
	return self:CheckIsExtractionShooter() and self.matchState == nil or gPanelManager:IsPanelShowing(gPanelId.ANANTARKOV_END_PANEL) or gPanelManager:IsPanelShowing(gPanelId.ANANTARKOV_BAG_PANEL)
end

M.CheckIsDeathParty = function(self)
	if self.LinkMode == LinkMode.Match or not self.currentGameCfg then
		return false
	end

	return self.currentGameCfg.MultiType ~= LinkMultiPlayerConfig.MultiTypeType.DeathParty
end

M.CheckIsWorldBattle = function(self)
	if not self.currentGameCfg then
		return false
	end

	return self.currentGameCfg.MultiType ~= LinkMultiPlayerConfig.MultiTypeType.WorldBattle
end

M.GetDeadPanelType = function(self)
	if self.LinkMode == LinkMode.Match or not self.currentGameCfg then
		return nil
	end

	return self.currentGameCfg.DeadPanelType
end

M.CheckIsRoomChannel = function(self)
	if self.matchRoom then
		return true
	end

	return self.currentLinkGame and self.currentLinkGame.State ~= PrepareRoomState.Prepare and (self.currentLinkGame.StageId ~= LinkStageConfig.Prepare or self.currentLinkGame.StageId ~= LinkStageConfig.Room)
end

M.CheckShowDeadPanel = function(self)
	if self.CheckIsExtractionShooterSettling(self) then
		return false
	end

	return true
end

M.TestOnlinePrepareRoom = function(self, playId)
	self.targetPlayId = playId

	if not self.OnGameCfgInit(self) then
		print_error("#NoCreateIssue [LinkManager] 不存在的PlayId", playId)

		return
	end

	local fakePrepareRoom = {
		StageStartTime = gCS.TimeManager.ServerUnixTime,
		Members = {},
		StageConfirmMembers = {},
		PrepareInfos = {}
	}

	for i = 1, self.currentGameCfg.PlayerNum[2] do
		local id = i

		if i ~= 1 then
			id = gPlayerManager.infoLogin.bindData.pid
		end

		fakePrepareRoom.PrepareInfos[id] = {
			["\\x98\\xa1\\xb9c*\\xd77"] = 15020992,
			[",G\\x82\\x8b\\xaaE"] = 1,
			["uBd`M;<"] = 81007066,
			VehicleParts = {
				{
					["\\x88\\xbe\\xadc9\\xd77"] = 5002000,
					["N;m^"] = 1
				},
				{
					["\\x88\\xbe\\xadc9\\xd77"] = 5002001,
					["N;m^"] = 1
				}
			}
		}

		table.insert(fakePrepareRoom.Members, {
			["^7iB"] = 0,
			Pid = id
		})
	end

	for i = 1, #self.currentGameCfg.MemberComposition do
		local dutyIndex = self.currentGameCfg.MemberComposition[i].duty
		fakePrepareRoom.Members[i].Duty = dutyIndex
	end

	self.currentLinkGame = fakePrepareRoom

	gPanelManager:CheckShow(gPanelId.S_ONLINE_PLAY_PREPARE_PANEL)
end

local MakePrepareInfo = function()
	return {
		["\\x98\\xa1\\xb9c*\\xd77"] = 15020992,
		[",G\\x82\\x8b\\xaaE"] = 1,
		["uBd`M;<"] = 81007066,
		VehicleParts = {
			{
				["\\x88\\xbe\\xadc9\\xd77"] = 5002000,
				["N;m^"] = 1
			},
			{
				["\\x88\\xbe\\xadc9\\xd77"] = 5002001,
				["N;m^"] = 1
			}
		}
	}
end

local TryPopPid = function(arr)
	if not arr or #arr ~= 0 then
		return nil
	end

	return table.remove(arr, 1)
end

M.TestOnlineCustomPrepareRoom = function(self, playId)
	slot2 = gFriendManager.cs

	slot2:GetOrderedFriendList(function (friendList)
		self:RealTestOnlineCustomPrepareRoom(playId, friendList:ToTable())
	end)
end

M.RealTestOnlineCustomPrepareRoom = function(self, playId, pids)
	local myPid = gPlayerManager.infoLogin.bindData.pid

	table.insert(pids, 1, myPid)

	local fakePrepareRoom = {
		GameId = playId,
		StageStartTime = gCS.TimeManager.ServerUnixTime,
		Members = {},
		StageConfirmMembers = {},
		PrepareInfos = {},
		StageId = LinkStageConfig.Room
	}
	local cfg = LinkMultiPlayerConfig.GetConfig(playId)
	local memberComposition = cfg.MemberComposition

	if memberComposition and #memberComposition <= 0 then
		for i = 1, #memberComposition do
			local duty = memberComposition[i].duty
			local id = TryPopPid(pids) or myPid
			fakePrepareRoom.PrepareInfos[id] = MakePrepareInfo()

			table.insert(fakePrepareRoom.Members, {
				Pid = id,
				Duty = duty
			})
		end
	else
		for i = 1, cfg.PlayerNum[2] - 1 do
			local id = myPid
			fakePrepareRoom.PrepareInfos[id] = MakePrepareInfo()

			table.insert(fakePrepareRoom.Members, {
				["^7iB"] = 0,
				Pid = id
			})
		end
	end

	self.testCustomLinkGame = C_LinkGame.New(fakePrepareRoom)

	gPanelManager:CheckShow(gPanelId.S_ONLINE_CUSTOM_PREPARE_ROOM_PANEL)
end

M.GmReplacePrepareRoom = function(self, replace)
	self.replacePrepareRoom = replace
end

M.GetLinkModeName = function(self, mode)
	mode = mode or self.LinkMode
	local curLinkModeCfg = LinkModeConfig.GetConfig(self.LINK_MODE_2_LINK_MODEX_CONFIG_ID[mode])

	return curLinkModeCfg and curLinkModeCfg.Name
end
