-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PartyEndPanelStore.lua
-- Decompiled from: 01074_PartyEndPanelStore.lua_ed207798fb56.luajit

C_PartyEndPanelStore = DefClass("C_PartyEndPanelStore", C_PartyEndPanelStore, C_StoreGroup)
GroupName2Class.PartyEndPanelStore = C_PartyEndPanelStore
local M = C_PartyEndPanelStore

local timelineDebugLog = function(message)
	if gGameManager.Env.isEditor then
		print_notice("[PartyMultiEnd] " .. message)
	end
end

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.settleData = nil
	self.rewardList = {}
	self.onlineTitleData = {}
end

M.DefineAllEnumsAutoGen = function(self)
	self.appraiseControlEnum = {
		["\\xfe"] = 2,
		["\\xec"] = 3,
		["3:"] = 1,
		["\\xbd[U"] = 0,
		["\\xef"] = 4
	}
	self.gametypeCtrlEnum = {
		["F\\x9d\\x87\\x8dD"] = 1,
		["A\\x9f\\x89\\x8fD"] = 0
	}
	self.partyTitleCtrlEnum = {
		["PSueK-*"] = 1,
		["\\x8c!0:j\\xadM\\xd8.\\xaf\\xab"] = 2,
		["XS\\xc0\\xba\\x8b\\x90\\xc8\\xfc"] = 3,
		["r-nO"] = 0
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.appraiseControlEnum = nil
	self.gametypeCtrlEnum = nil
	self.partyTitleCtrlEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
	timelineDebugLog("listener enabled")
end

M.OnGroupDisable = function(self)
	timelineDebugLog("listener disabled")
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	self.settleData = data
	self.isOnline = gClientUtils.CheckIsLinkMode()

	timelineDebugLog(("panel shown online=%s"):format(tostring(self.isOnline)))
	self:InitView()
end

M.OnClose = function(self)
	if self.isOnline then
		gTimelineManager:Timeline_StopLink(gCS.MyPlayerManager.PlayerUnit.Pid, "ol_play_party_end")
		gClientToGameDelegate:LeavePartyRoom()
	else
		gTimelineManager:Timeline_Stop("play_party_end")
	end

	self.settleData = nil
	self.rewardList = {}
	self.onlineTitleData = {}
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.TIMELINE_TO_PANEL] = self.CreateAction(self, "OnTimelineSignal")
	}
end

M.OnTimelineSignal = function(self, eventId, data)
	timelineDebugLog(("signal event=%s type=%s raw0=%s raw1=%s"):format(tostring(eventId), type(data), tostring(data[0]), tostring(data[1])))

	if data[1] == gPanelId.PARTY_END_PANEL then
		timelineDebugLog(("signal ignored panel=%s expected=%s"):format(tostring(data[1]), tostring(gPanelId.PARTY_END_PANEL)))

		return
	end

	timelineDebugLog(("signal accepted title=%s panel=%s"):format(tostring(data[0]), tostring(data[1])))
	self:RefreshOnlineTitle(data[0])
end

M.RegisterWidget = function(self)
	self.bindData.exitBn.luaClick = self.CreateAction(self, "OnClickExitBtn")
	self.bindData.rewardList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderRewardItem")
end

M.OnClickExitBtn = function(self)
	gPanelManager:Close(self.m_Id)
end

M.OnRenderRewardItem = function(self, btn, index)
	local award = self.rewardList[index + 1]

	gCommonItemManager:OnCommonItemRender(btn, index, gCommonItemManager:GetFakeItemRenderData(award))
end

M.InitView = function(self)
	self.bindData.gametypeCtrl = self.isOnline and self.gametypeCtrlEnum.online or self.gametypeCtrlEnum.single
	self.bindData.appraiseControl = self:GetPopularityControlValue()

	if self.isOnline then
		self.RefreshOnlineView(self)
	else
		self.RefreshSingleView(self)
	end
end

M.RefreshSingleView = function(self)
	local partyCfg = LTConfig.PartyConfig.GetConfig(self.settleData.PartyId)
	local partyTypeCfg = LTConfig.PartyPartyTypeConfig.GetConfig(partyCfg.Type)
	self.bindData.title = self:GetTextScriptText(89901531):format(partyTypeCfg.Name)
	self.rewardList = {}

	if self.settleData.Drop <= 0 then
		self.rewardList = gCommonItemManager:GetItemSortedListByDropList({
			{
				["N\\xa1\\xb7\\xa1\\xa2"] = 1,
				dropId = self.settleData.Drop
			}
		}, true)
	end

	self.bindData.rewardList:SetSimpleList(#self.rewardList)
end

M.RefreshOnlineView = function(self)
	local onlineResult = self.settleData.OnlineSettleResult
	self.onlineTitleData = {
		Host = {
			ctrl = self.partyTitleCtrlEnum.host,
			pid = self.settleData.HostPid
		},
		FashionStar = {
			ctrl = self.partyTitleCtrlEnum.styleStar,
			pid = onlineResult.FashionStarPid
		},
		SuperGamer = {
			ctrl = self.partyTitleCtrlEnum.superPlayer,
			pid = onlineResult.SuperGamerPid
		},
		PopularityKing = {
			ctrl = self.partyTitleCtrlEnum.kingofHeat,
			pid = onlineResult.PopularityKingPid
		}
	}

	self.RefreshOnlineTitle(self, "Host")
end

M.RefreshOnlineTitle = function(self, titleKey)
	local titleData = self.onlineTitleData[titleKey]

	if not titleData then
		timelineDebugLog(("title missing key=%s"):format(tostring(titleKey)))

		return
	end

	local playerName = gFriendManager:GetPlayerRealName(titleData.pid)

	timelineDebugLog(("refresh key=%s ctrl=%s pid=%s name=%s"):format(tostring(titleKey), tostring(titleData.ctrl), tostring(titleData.pid), tostring(playerName)))

	self.bindData.partyTitleCtrl = titleData.ctrl
	self.bindData.playerName = playerName
end

M.GetPopularityControlValue = function(self)
	local popularityLevelList = LTConfig.PartyConfig.GetConfig(self.settleData.PartyId).PopularityLevel

	for i = #popularityLevelList, 1, -1 do
		if popularityLevelList[i] < self.settleData.Popularity then
			return #popularityLevelList - i
		end
	end

	return #popularityLevelList
end

M.GetTextScriptText = function(self, textScriptId)
	return LTConfig.TextScriptTextConfig.GetConfig(textScriptId).Text
end
