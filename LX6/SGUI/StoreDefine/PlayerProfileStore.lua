-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PlayerProfileStore.lua
-- Decompiled from: 00777_PlayerProfileStore.lua_354d40acd1f1.luajit

local ImageHeadTabConfigType = LTConfig.ImageHeadTabConfig.TypeType
C_PlayerProfileStore = DefClass("C_PlayerProfileStore", C_PlayerProfileStore, C_StoreGroup)
GroupName2Class.PlayerProfileStore = C_PlayerProfileStore
local M = C_PlayerProfileStore
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}

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
	self.pid = nil
	self.info = nil
	self.isSelf = false
	self.tooltips = {}
	self.previewBg = nil
	self.nextUpdateTime = 0
	self.UpdateInterval = 0.1
	self.nextLikesPollTime = 0
	self.LikesPollInterval = 3
	self._sceneTeardownDone = false
	self.RankId = {
		["q[ݶ\\x81\\xba\\xc5\\xe4"] = 1004,
		["\\xeb\\xda#\\xa3"] = 1003,
		[".I\\x92\\x87\\x8dF"] = 1002
	}
end

M.SetPreviewBg = function(self, bg)
	if self.previewBg ~= bg then
		return
	end

	if gPanelManager:IsPanelShowing(gPanelId.PLAYER_PROFILE_CHANGE_BACKGROUND_PANEL) then
		local config = LTConfig.ImageBackGroudConfig.GetConfig(bg)

		self.bindData:Commit("bg", config.Resource, COMMIT_FORCE)

		self.previewBg = bg
	end
end

M.OnAwake = function(self)
	self.bindData.btnCopyUID.luaClick = self.CreateAction(self, self.OnCopyUIDBtnClick)
	self.bindData.btnExit.luaClick = self.CreateAction(self, self.OnExitBtnClick)
	self.bindData.btnEdit.luaRenderTooltip = self.CreateAction(self, "OnRenderToolTips")
	self.bindData.editSceneBtn.luaClick = self.CreateAction(self, self.OnEditSceneBtnClick)
	self.bindData.collectionBtn.luaClick = self.CreateAction(self, self.OnClickCollectionBtn)

	self.InitEvent(self)
end

M.OnGroupEnable = function(self)
	local playerLikes = self.bindData.playerLikes
	local likesGroup = gStoreManager:GetStoreGroup(playerLikes.Store)
	self.likesStore = likesGroup and likesGroup:GetStoreByWidget(playerLikes)

	if not self.likesStore then
		return
	end

	self.likesStore.playerLikeBtn.luaClick = self.CreateAction(self, self.OnPlayerLikeBtnClick)
	self.likesStore.friendsLikeBtn.luaClick = self.CreateAction(self, self.OnFriendsLikeBtnClick)
end

M.OnUpdate = function(self)
	local nowTime = gLuaDataManager.serverTime

	if nowTime < self.nextUpdateTime then
		return
	end

	self.nextUpdateTime = nowTime + self.UpdateInterval

	if self.previewBg and not gPanelManager:IsPanelShowing(gPanelId.PLAYER_PROFILE_CHANGE_BACKGROUND_PANEL) then
		if self.info and self.info.background and self.info.background == 0 and self.info.background == self.previewBg then
			local config = LTConfig.ImageBackGroudConfig.GetConfig(self.info.background)

			self.bindData:Commit("bg", config.Resource, COMMIT_FORCE)
		end

		self.previewBg = nil
	end

	if self.isSelf and self.likesStore and self.nextLikesPollTime < nowTime then
		self.nextLikesPollTime = nowTime + self.LikesPollInterval

		self.RefreshBeLikeCount(self)
	end
end

M.InitEvent = function(self)
	local msgEvents = {
		[gEventConstants.PLAYER_PROFILE_INFO_CHANGED] = self.CreateActionWithArgs(self, "RefreshData"),
		[gEventConstants.ON_PLAYER_SCENARIO_INFO_CHANGED] = self.CreateAction(self, "OnScenarioInfoChanged")
	}

	self.RegisterMessageEvents(self, msgEvents)
end

M.OnShow = function(self, panelId, data)
	self.pidStack = gDataStructureUtils.GetStack()

	self.pidStack:Push({
		info = data
	})

	if gPanelManager:IsPanelShowing(gPanelId.PLAYER_LIKES_INFO) then
		gPanelManager:Close(gPanelId.PLAYER_LIKES_INFO)
	end

	self:LoadProfile(data)

	self.previewBg = nil
	self._sceneTeardownDone = false

	self:SetupScene()

	local bgGo = self.rootGo.transform:Find("Root/Background")

	if bgGo then
		bgGo.gameObject:SetActive(false)
	end
end

M.LoadProfile = function(self, data)
	if data and data.pid then
		self.pid = data.pid
	else
		self.pid = gPlayerManager.infoLogin.bindData.pid
	end

	self.isSelf = self.pid ~= gPlayerManager.infoLogin.bindData.pid
	self.info = data

	self:BuildToolTips()
	self:RefreshDisplay()
end

M.NavigateTo = function(self, data)
	if not self.pidStack then
		self.pidStack = gDataStructureUtils.GetStack()
	end

	local leaving = self.pidStack:Peek()

	if leaving then
		leaving.likesOpen = gPanelManager:IsPanelShowing(gPanelId.PLAYER_LIKES_INFO)
	end

	if gPanelManager:IsPanelShowing(gPanelId.PLAYER_LIKES_INFO) then
		gPanelManager:Close(gPanelId.PLAYER_LIKES_INFO)
	end

	self.pidStack:Push({
		info = data
	})
	self:LoadProfile(data)
	self:ReloadScene()
end

M.ReloadScene = function(self)
	gPlayerProfileSceneManager:ClearScenarioModels()

	if self.isSelf then
		self._LoadSelfScenario(self)
	else
		self._LoadOtherScenario(self)
	end
end

M.SetupScene = function(self)
	gPlayerProfileSceneManager:SetVCamera(self.bindData.VCamera)
	gPlayerProfileSceneManager:StartListenDynamicGoLoaded()
	gCS.LuaUtils.SetShadowRenderDataUIMode(true)
	self.bindData.cameraRT.transform:SetParent(nil, false)
	self.bindData.cameraRT.gameObject:GetOrAddComponent(typeof(LX6.GUI.DestroyOnPlayModeExit))
	self.bindData.cameraRT.transform:GetChild(0).gameObject:SetActive(true)

	self.bindData.cameraRT.transform.position = gCS.CameraDataMgr.MainCamera.transform.position
	self.bindData.cameraRT.transform.rotation = gCS.CameraDataMgr.MainCamera.transform.rotation

	if self.isSelf then
		self._LoadSelfScenario(self)
	else
		self._LoadOtherScenario(self)
	end
end

M._LoadSelfScenario = function(self)
	local publicInfo = self._GetCurrentSlotPublicInfo(self)

	if publicInfo then
		gPlayerProfileSceneManager:LoadScenarioFromData(publicInfo)
	else
		local showInfos = gPlayerManager.infoMinor.bindData.PlayerScenarioInfos
		local curSlot = showInfos and showInfos.CurSlot and showInfos.CurSlot <= 0 and showInfos.CurSlot or 1
		local spiritId = gPlayerProfileSceneManager:GetDefaultSpiritId()

		gPlayerProfileSceneManager:LoadDefaultScenario(spiritId, curSlot)
	end
end

M._GetCurrentSlotPublicInfo = function(self)
	local showInfos = gPlayerManager.infoMinor.bindData.PlayerScenarioInfos

	if not showInfos then
		return nil
	end

	local curSlot = showInfos.CurSlot

	if not curSlot then
		return nil
	end

	if curSlot ~= 0 then
		curSlot = 1
	end

	local dict = showInfos.PlayerScenarioInfoDict

	if not dict or not dict[curSlot] then
		return nil
	end

	return dict[curSlot].PublicInfo
end

M._LoadOtherScenario = function(self)
	slot1 = gClientToAvatarDelegate

	slot1:GetPlayerPublicInfo(self.pid).Callback = function (err, publicInfo)
		if err == LTConfig.MessageConfig.Ok then
			local spiritId = LTConfig.FightSpiritConfig.DefaultMale

			gPlayerProfileSceneManager:LoadDefaultScenario(spiritId)

			return
		end

		local scenarioInfo = publicInfo and publicInfo.ScenarioInfo

		if scenarioInfo then
			gPlayerProfileSceneManager:LoadScenarioFromData(scenarioInfo)
		else
			local sex = self.info and self.info.sex
			local spiritId = nil

			if sex ~= UX.Game.SexType.Female then
				spiritId = LTConfig.FightSpiritConfig.DefaultFemale
			else
				spiritId = LTConfig.FightSpiritConfig.DefaultMale
			end

			gPlayerProfileSceneManager:LoadDefaultScenario(spiritId)
		end
	end
end

M.OnScenarioInfoChanged = function(self)
	if not self.isSelf then
		return
	end

	if gPanelManager:IsPanelShowing(gPanelId.PLAYER_PROFILE_SCENE_SELECT_PANEL) then
		return
	end

	if gPanelManager:IsPanelShowing(gPanelId.PLAYER_PROFILE_SCENE_EDIT_PANEL) then
		return
	end

	gPlayerProfileSceneManager:ClearScenarioModels()
	self:_LoadSelfScenario()
end

M.GetCurrentSceneId = function(self)
	local showInfos = gPlayerManager.infoMinor.bindData.PlayerScenarioInfos

	if not showInfos then
		return 1
	end

	local curSlot = showInfos.CurSlot

	if not curSlot then
		return 1
	end

	local dict = showInfos.PlayerScenarioInfoDict

	if not dict or not dict[curSlot] then
		return 1
	end

	return dict[curSlot].SceneId or 1
end

M.TeardownScene = function(self)
	if self._sceneTeardownDone then
		return
	end

	self._sceneTeardownDone = true

	gPlayerProfileSceneManager:ReleaseScene()
	gPlayerProfileSceneManager:ClearVCamera()
	gCS.LuaUtils.SetShadowRenderDataUIMode(false)

	if self.bindData and self.bindData.cameraRT and not gCS.LuaUtils.IsNull(self.bindData.cameraRT.gameObject) then
		GameObject.Destroy(self.bindData.cameraRT.gameObject)
	end
end

M.RefreshData = function(self, data)
	if data and data.bg then
		self.info.background = data.bg
	end

	slot2 = gFriendManager

	slot2:GetPlayerRichProfileInfo(self.pid, function (info)
		self.info = info

		self:BuildToolTips()
		self:RefreshDisplay()
	end, true)
end

M.RefreshDisplay = function(self)
	self.bindData.name.text = self.info.name or ""

	if string.is_null_or_empty(self.info.clubName) then
		self.bindData.clubName.text = LTConfig.ImageConfig.NoClub
	else
		self.bindData.clubName.text = self.info.clubName or ""

		if self.info.clubIconId then
			self.bindData:Commit("clubIcon", self.info.clubIconId, COMMIT_FORCE)
		end
	end

	if self.info.infoPzHeadInfo then
		local iconId, _ = gHunLunManager:GetHeadIconAndName(self.info.infoPzHeadInfo.SystemHeadId)

		if iconId then
			self.bindData:Commit("icon", iconId, COMMIT_FORCE)
		end
	end

	if self.info.birthday then
		self.bindData.birthday.text = self.GetBirthDisplay(self)
	end

	self.bindData.uid.text = string.format(LTConfig.ImageConfig.UIDName, ulong.tostring(self.pid))

	if self.info.background and self.info.background == 0 then
		local config = LTConfig.ImageBackGroudConfig.GetConfig(self.info.background)

		self.bindData:Commit("bg", config.Resource, COMMIT_FORCE)
	end

	if string.is_null_or_empty(self.info.sign) then
		self.bindData.sign.text = LTConfig.ImageConfig.NoSignShown
	else
		self.bindData.sign.text = self.info.sign
	end

	if self.info.cityPediaCredit then
		self.bindData.fashion.text = tostring(self.info.cityPediaCredit)
	end

	self.bindData.saicherank1.text = self.info.rankInfo and self.info.rankInfo[self.RankId.Racing] and self.info.rankInfo[self.RankId.Racing].rank <= 0 and self.info.rankInfo[self.RankId.Racing].rank or ""
	self.bindData.saicherank2.text = self.info.rankInfo and self.info.rankInfo[self.RankId.Racing2] and self.info.rankInfo[self.RankId.Racing2].rank <= 0 and self.info.rankInfo[self.RankId.Racing2].rank or ""
	local basketballScore = nil

	if self.info.rankInfo and self.info.rankInfo[self.RankId.Basketball] then
		basketballScore = self.info.rankInfo[self.RankId.Basketball].score
	end

	if basketballScore then
		self.bindData.lanqiurank.text = ulong.tostring(basketballScore)
	else
		self.bindData.lanqiurank.text = ""
	end

	self.bindData.showEditCtl = BOOL2CTL[self.isSelf]
	self.bindData.hideCtl = BOOL2CTL[false]

	self.RefreshLikes(self)
end

M.RefreshLikes = function(self)
	local likesStore = self.likesStore

	if not likesStore then
		return
	end

	likesStore.stateCtrl = self.isSelf and 0 or 1

	if self.isSelf then
		self.nextLikesPollTime = gLuaDataManager.serverTime + self.LikesPollInterval
	else
		likesStore.friendStateCtrl = self:HasLikedToday() and 0 or 1
	end

	self.RefreshBeLikeCount(self)
end

M.RefreshBeLikeCount = function(self)
	if not self.likesStore then
		return
	end

	local pid = self.pid
	slot2 = gClientToAvatarDelegate

	slot2:GetPlayerBeLikeCount(pid).Callback = function (err, count)
		if err == LTConfig.MessageConfig.Ok then
			return
		end

		if not ulong.equals(self.pid, pid) then
			return
		end

		if not self.likesStore then
			return
		end

		self.likeCount = LikeCountToNumber(count)
		self.likesStore.likesNum = FormatLikeCount(self.likeCount)
	end
end

M.HasLikedToday = function(self)
	local likeInfo = gPlayerManager.infoMinor.bindData.PlayerLikeInfo

	if not likeInfo or not likeInfo.HomepageLikes then
		return false
	end

	if not UXCommon.Time.UXLogicTime.IsSameDay(likeInfo.LastResetTime or 0, gLuaDataManager.serverTime) then
		return false
	end

	return likeInfo.HomepageLikes[ulong.tostring(self.pid)] ~= true
end

M.MarkLikedToday = function(self)
	local minor = gPlayerManager.infoMinor.bindData
	local likeInfo = minor.PlayerLikeInfo

	if not likeInfo then
		likeInfo = {
			[".\\xe2L88\\xd5\\xb3U\\x95_\\xbd\\xb3"] = 0,
			HomepageLikes = {}
		}
		minor.PlayerLikeInfo = likeInfo
	end

	if not UXCommon.Time.UXLogicTime.IsSameDay(likeInfo.LastResetTime or 0, gLuaDataManager.serverTime) then
		likeInfo.LastResetTime = gLuaDataManager.serverTime
		likeInfo.HomepageLikes = {}
	end

	likeInfo.HomepageLikes = likeInfo.HomepageLikes or {}
	likeInfo.HomepageLikes[ulong.tostring(self.pid)] = true
end

M.OnPlayerLikeBtnClick = function(self)
	gPanelManager:CheckShow(gPanelId.PLAYER_LIKES_INFO, {
		likeCount = self.likeCount
	})
end

M.OnFriendsLikeBtnClick = function(self)
	if self.isSelf then
		return
	end

	if self.HasLikedToday(self) then
		gDisplayMessageMgr:ShowMessage(75109966)

		return
	end

	slot1 = gClientToGameDelegate

	slot1:AskLikePlayer(self.pid, UX.Game.LikeType.Homepage).Callback = function (err)
		if err ~= LTConfig.MessageConfig.Ok or err ~= LTConfig.MessageConfig.TappedDailyLimitReached then
			self:MarkLikedToday()

			if self.likesStore then
				self.likesStore.friendStateCtrl = 0

				if err ~= LTConfig.MessageConfig.Ok and self.likeCount then
					self.likeCount = self.likeCount + 1
					self.likesStore.likesNum = FormatLikeCount(self.likeCount)
				end
			end

			self:RefreshBeLikeCount()
		elseif err ~= LTConfig.MessageConfig.TappedOutforToday then
			gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.TappedOutforToday)
		else
			gDisplayMessageMgr:ShowMessage(err)
		end
	end
end

M.OnCopyUIDBtnClick = function(self)
	gCS.LuaUtils.PasteText2Clipboard(ulong.tostring(self.pid))
	gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.CopyIDComplete)
end

M.OnExitBtnClick = function(self)
	if self.pidStack and self.pidStack.count <= 1 then
		self.pidStack:Pop()

		local prev = self.pidStack:Peek()

		self:LoadProfile(prev.info)
		self:ReloadScene()

		if prev.likesOpen and not gPanelManager:IsPanelShowing(gPanelId.PLAYER_LIKES_INFO) then
			gPanelManager:CheckShow(gPanelId.PLAYER_LIKES_INFO, {
				likeCount = self.likeCount
			})
		end

		return
	end

	self:TeardownScene()
	gPanelManager:Close(gPanelId.PLAYER_PROFILE_PANEL)
end

M.OnEditSceneBtnClick = function(self)
	gPanelManager:CheckShow(gPanelId.PLAYER_PROFILE_SCENE_SELECT_PANEL or 278)
end

M.OnClickCollectionBtn = function(self)
	local param = {
		["\\xf1\\xd4\r\\xf5"] = 0,
		[" %,\\xe8v\\x8c\\xfe;\\xa6\\xe9\\xfd\\xeb]\\xff"] = 1,
		Tag = UX.Game.LinkTag.CollectionRoom,
		HouseOwnerPid = ulong.tonum2(self.pid)
	}
	slot2 = gClientToGameDelegate

	slot2:AskCreateCustomLink(param).Callback = function (err)
		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
		end
	end
end

M.GetBirthDisplay = function(self)
	local m, d = nil

	if not self.info.birthday or self.info.birthday ~= 0 then
		return "-/-"
	else
		m = math.floor(self.info.birthday / 100)
		d = self.info.birthday % 100
	end

	return string.format(LTConfig.ImageConfig.BirthName, m, d)
end

M.BuildToolTips = function(self)
	self.tooltips = {}

	for i = 0, LTConfig.ImageHeadTabConfig.count - 1 do
		local bContinue = true
		local headTab = LTConfig.ImageHeadTabConfig.LoadAt(i)

		if headTab.Type ~= ImageHeadTabConfigType.birthday and self.info and self.info.birthday and self.info.birthday == 0 then
			bContinue = false
		end

		if bContinue then
			table.insert(self.tooltips, {
				title = headTab.TabName,
				index = headTab.TabIndex,
				type = headTab.Type
			})
		end
	end

	table.sort(self.tooltips, function (a, b)
		return a.index <= b.index
	end)
end

M.OnRenderToolTips = function(self, _, popup, _)
	local store = gStoreManager:GetStoreGroup("SocialChatSettingTooltipStore"):GetStoreByWidget(popup)

	if not store then
		return
	end

	store.btnList.luaSimpleRenderItem = self:CreateAction("OnToolTipsBtnRenderItem")

	store.btnList:SetSimpleList(#self.tooltips)
end

M.OnToolTipsBtnRenderItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local data = self.tooltips[index + 1]

	if store and data then
		store.title = data.title
	end

	btn.luaClick = self.CreateActionWithArgs(self, "OnToolTipsButtonClick", data.type)
end

M.OnToolTipsButtonClick = function(self, type)
	local data = {
		name = self.info.name,
		pid = self.pid,
		birthday = self.info.birthday,
		note = self.info.sign,
		currentBgId = self.info.background
	}

	if type ~= ImageHeadTabConfigType.avatar then
		gPanelManager:CheckShow(gPanelId.PLAYER_PROFILE_CHANGE_HEAD_PANEL, data)
	elseif type ~= ImageHeadTabConfigType.avatarframe then
		data.isFrame = true

		gPanelManager:CheckShow(gPanelId.PLAYER_PROFILE_CHANGE_HEAD_PANEL, data)
	elseif type ~= ImageHeadTabConfigType.bg then
		gPanelManager:CheckShow(gPanelId.PLAYER_PROFILE_CHANGE_BACKGROUND_PANEL, data)
	elseif type ~= ImageHeadTabConfigType.birthday then
		gPanelManager:CheckShow(gPanelId.PLAYER_PROFILE_CHANGE_BIRTHDAY_PANEL, data)
	elseif type ~= ImageHeadTabConfigType.sign then
		gPanelManager:CheckShow(gPanelId.PLAYER_PROFILE_CHANGE_NOTE_PANEL, data)
	elseif type ~= ImageHeadTabConfigType.name then
		gHunLunManager:TryStartRename()
	elseif type ~= ImageHeadTabConfigType.headInfo then
		data.currentBgId = self.info and self.info.popup

		gPanelManager:CheckShow(gPanelId.PLAYER_PROFILE_CHANGE_POPUP_BACKGROUND_PANEL, data)
	end

	self.bindData.btnEdit:CloseTooltip(true)
end

M.OnActiveDeviceChange = function(self, device)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnDestroy = function(self)
	self.TeardownScene(self)
end
