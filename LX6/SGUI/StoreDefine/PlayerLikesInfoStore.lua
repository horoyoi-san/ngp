-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PlayerLikesInfoStore.lua
-- Decompiled from: 00836_PlayerLikesInfoStore.lua_b9229f482ede.luajit

C_PlayerLikesInfoStore = DefClass("C_PlayerLikesInfoStore", C_PlayerLikesInfoStore, C_StoreGroup)
GroupName2Class.PlayerLikesInfoStore = C_PlayerLikesInfoStore
local M = C_PlayerLikesInfoStore

local FormatLikeCount = function(num)
	num = tonumber(tostring(num)) or 0

	if num >= 10000 then
		return tostring(math.floor(num))
	elseif num >= 1000000 then
		return ("%.1fK"):format(math.floor(num / 100) / 10)
	else
		return ("%.1fM"):format(math.floor(num / 100000) / 10)
	end
end

local LikeCountToNumber = function(v)
	if v ~= nil then
		return 0
	end

	if type(v) ~= "number" then
		return v
	end

	local s = type(v) ~= "string" and ulong.tostring(v) or tostring(v)

	return tonumber(s) or 0
end

M.ctor = function(self)
	self.LikesPollInterval = 3
	self.nextLikesPollTime = 0
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
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
	self.bindData.title = LTConfig.ImageConfig.TappedName or ""

	self:InitInfoTemplate()

	if data and data.likeCount == nil and self.infoTemplateStore then
		self.infoTemplateStore.likesNum = FormatLikeCount(data.likeCount)
	end

	self.RequestLikesData(self)

	self.nextLikesPollTime = gLuaDataManager.serverTime + self.LikesPollInterval
end

M.OnUpdate = function(self)
	local nowTime = gLuaDataManager.serverTime

	if nowTime >= (self.nextLikesPollTime or 0) then
		return
	end

	self.nextLikesPollTime = nowTime + self.LikesPollInterval

	self.RequestLikesData(self)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.SOCIAL_FRIEND_INFO_CHANGE] = self.CreateAction(self, self.RefreshRecordList)
	}
end

M.RegisterWidget = function(self)
	self.bindData.backBtn.luaClick = self.CreateAction(self, self.OnClickBackBtn)
	self.bindData.commonBackBtn.luaClick = self.CreateAction(self, self.OnClickBackBtn)
end

M.OnClickBackBtn = function(self)
	gPanelManager:Close(gPanelId.PLAYER_LIKES_INFO)
end

M.InitInfoTemplate = function(self)
	if not self.bindData.likesInfoTemplate then
		return
	end

	local group = gStoreManager:GetStoreGroup(self.bindData.likesInfoTemplate.Store)
	self.infoTemplateStore = group and group:GetStoreByWidget(self.bindData.likesInfoTemplate)

	if self.infoTemplateStore and self.infoTemplateStore.recordList then
		self.infoTemplateStore.recordList.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderRecordItem)
	end
end

M.RequestLikesData = function(self)
	local selfPid = gPlayerManager.infoLogin.bindData.pid
	slot2 = gClientToAvatarDelegate

	slot2:GetPlayerBeLikeCount(selfPid).Callback = function (err, count)
		if err == LTConfig.MessageConfig.Ok then
			return
		end

		if self.infoTemplateStore then
			self.infoTemplateStore.likesNum = FormatLikeCount(LikeCountToNumber(count))
		end
	end

	slot2 = gClientToGameDelegate

	slot2:AskGetBeLikeList().Callback = function (err, list)
		if err == LTConfig.MessageConfig.Ok then
			return
		end

		local records = list or {}

		table.sort(records, function (a, b)
			return b.TimeStamp <= a.TimeStamp
		end)

		self.recordData = records
		local pidList = {}

		for _, data in ipairs(self.recordData) do
			table.insert(pidList, data.Pid)
		end

		slot4 = gFriendManager

		slot4:GetSimplePlayerInfoByPidList(pidList, function (infoList)
			self.pidToInfo = {}

			for _, info in ipairs(infoList) do
				self.pidToInfo[info.Pid] = info
			end

			self:RefreshRecordList()
		end)
	end
end

M.RefreshRecordList = function(self)
	if not self.infoTemplateStore or not self.infoTemplateStore.recordList then
		return
	end

	self.infoTemplateStore.recordList:SetSimpleList(self.recordData and #self.recordData or 0)
end

M.OnRenderRecordItem = function(self, btn, index)
	local data = self.recordData and self.recordData[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.timeText = gTimeUtils:FormatRelativeTime(data.TimeStamp)
	store.friendCtrl = gFriendManager:IsFriend(data.Pid) and 0 or 1

	if store.accountAvator then
		local avatarGroup = gStoreManager:GetStoreGroup(store.accountAvator.Store)
		local avatarStore = avatarGroup and avatarGroup:GetStoreByWidget(store.accountAvator)
		local userInfo = avatarStore and (avatarStore.userInfo or avatarStore.userInfoLight)

		if userInfo then
			userInfo.pid = data.Pid
		end

		local pid = data.Pid

		store.accountAvator.luaRenderTooltip = function(btn, popup, _)
			gSocialPalyerTooltipManager:OnRenderToolTips(pid, btn, popup, _)
		end
	end

	local info = self.pidToInfo and self.pidToInfo[data.Pid]
	store.friendName = info and info.Name or ""
	store.sourceText = self:GetLikeSourceText(data)
end

M.GetLikeSourceText = function(self, data)
	if data.LikeType ~= UX.Game.LikeType.Homepage then
		return LTConfig.ImageConfig.TappedFromProfile or ""
	elseif data.LikeType ~= UX.Game.LikeType.Game then
		local fmt = LTConfig.ImageConfig.TappedFromOhters

		if not fmt then
			return ""
		end

		local name = nil

		if data.MultiPlayerId and data.MultiPlayerId == 0 then
			local cfg = LTConfig.LinkMultiPlayerConfig.GetConfig(data.MultiPlayerId)
			name = cfg and cfg.Name
		end

		if not name or name ~= "" then
			return ""
		end

		return string.format(fmt, name)
	end

	return ""
end
