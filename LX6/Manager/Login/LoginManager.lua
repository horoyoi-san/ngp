-- Original chunk: @Lua\LuaFiles\LX6\Manager\Login\LoginManager.lua
-- Decompiled from: 02217_LoginManager.lua_a640a2c98aaa.luajit

local MessageConfig = LTConfig.MessageConfig
local PlayerPrefs = UnityEngine.PlayerPrefs
local NpcCultivationConfig = LTConfig.NpcCultivationConfig
local TextScriptTextConfig = LTConfig.TextScriptTextConfig
local BanUserConfig = LTConfig.BanUserConfig
local MultiverseJumpEventConfig = LTConfig.MultiverseJumpEventConfig
local TaskEventConfig = LTConfig.TaskEventConfig
local MultiverseMetaConfig = LTConfig.MultiverseMultiverseMetaConfig
local ConstConfig = LX6.Manager.ConstConfig
local StaticProps = {}
local LoginFlowState = {
	["$!\\xf1g\\x90\\xf2:\\xbc&\\xe5\\xf3\\xf2q\\xff"] = 3,
	["~\\xba\\xa3\\xbd\\xa2"] = 0,
	["o\\xbc\\xa3\\xa1\\xb2"] = 2,
	["~O©\\x8d\\xbd\\xda\\xed"] = 5,
	["/3\\xebf\\x8a\\xf41\\x84 \\xe7\\xf6\\xefz\\xfc"] = 1,
	["#\\xf6K$\\xde\\xbfB\\xa0B\\xb5\\xb2"] = 4
}
local LoginInterceptState = {
	["Nx\\xa2xY\\xbc\\xf1BgpX"] = 3,
	["\\xb25)1l\\x98O\\xd89\\xa9\\xbc"] = 2,
	[">I\\x9f\\x80\\x86E"] = 1,
	["T-s^"] = 0
}
local StartupAutoRestoreState = {
	["qB}A?"] = 1,
	["˕\\xe5\"\\xf3\\xe9\\x8d\\xe8\\x86%,"] = 3,
	["]s\\xadsU\\x86\\xfdbdn{^"] = 4,
	["aU¸\\xb7\\xb6\\xcc\\xec"] = 2,
	["T-s^"] = 0
}
local LoginMainPanelState = {
	["\\xab\\xa3\\xab\\xaf"] = 2,
	["\\x85\\xbe\\x99o?\\xfa*"] = 0,
	["\\xf5\\xd4*\\xf6"] = 1
}
local ActivationState = {
	["Xw\\xa5cE\\xbc\\xf5ndjkX"] = 1,
	["`O̰\\x8d\\xac\r\\xc7\\xef"] = 2,
	["S&q^"] = 0,
	["\\x9d\\xb4\\xa2l7\\xfb7"] = 3
}
local ACTIVATION_GUARD_TIMEOUT = 30
local LoginFailedReason = {
	["ß\\xe5\\xc8\\xfe\\xa5\\xec\\x96# "] = 13,
	["X\\xf3 \\xe5' \\xc8d.\\xfcE\\x9a\rN\\xcf\\xe2"] = 14,
	["%5\\x9e㮤\\xfc\\x8a\\xb5\\x8f\\xd4\\xecǓ,\\x9a\\xe6"] = 4,
	["S\\xfd3\\xe99+\\xe4`-\\xd0m\\x8dN\\xc3\\xe2"] = 9,
	["\\xfd\\xde(\\xe5"] = 0,
	["qWoKO<"] = 15,
	["5?\\x9c訳ۣ\\xa8\\x9e\\xd8\\xf0Ǔ,\\x9a\\xe6"] = 3,
	["Ծ:\\xc0\\xef̉\\xe4\\x8e%,"] = 2,
	["D\\x9f\\x93\\xb4\\xec\\xb1\\xd18\\xa1\\xbb3"] = 7,
	[":%\\xeaZ\\x9c\\xdb;\\xaf&\\xe8\\xc5\\xe7}\\xef"] = 1,
	["%2\\x95\\xed\\xb4\\xa9\\x81\\xd2\\xecǓ,\\x9a\\xe6"] = 5,
	["%2\\x95륵\\x9d\\xd3\\xf6Ǔ,\\x9a\\xe6"] = 6,
	["ɕ\\xc5&\\xee\\xfe\\x8d\\xc1\\x8b3<"] = 10,
	["ɟ\\xe8=\\xf2\\xfc\\x89\\xf9\\x8b/&"] = 12,
	["G\\xf95\\xfa,%\\xc2h.\\xc1N\\x82\rL\\xc5\\xe3"] = 16,
	["fI˯\\xa6\t\\xb6\n\\xcc\\xec"] = 11,
	["ӈ\\xc0\\xef̉\\xe4\\x8e%,"] = 8
}

local IsTerminalLoginError = function(reason)
	return reason ~= LoginFailedReason.NotInWhiteList or reason ~= LoginFailedReason.UserBanned or reason ~= LoginFailedReason.RpcBanned or reason ~= LoginFailedReason.NeedActivation or reason ~= LoginFailedReason.DeviceNotMatch or reason ~= LoginFailedReason.LoginTokenInvalid
end

C_LoginManager = DefClass("C_LoginManager", C_LoginManager, nil, StaticProps)
local M = C_LoginManager
M.LoginFlowState = LoginFlowState
M.LoginInterceptState = LoginInterceptState
M.StartupAutoRestoreState = StartupAutoRestoreState
M.LoginMainPanelState = LoginMainPanelState
M.ActivationState = ActivationState
local LoginStateTransitions = {
	[LoginFlowState.Start] = {
		[LoginFlowState.ResourceLoading] = true,
		[LoginFlowState.Brand] = true,
		[LoginFlowState.Unauthenticated] = true
	},
	[LoginFlowState.ResourceLoading] = {
		[LoginFlowState.Brand] = true,
		[LoginFlowState.Unauthenticated] = true
	},
	[LoginFlowState.Brand] = {
		[LoginFlowState.Unauthenticated] = true,
		[LoginFlowState.Authenticated] = true
	},
	[LoginFlowState.Unauthenticated] = {
		[LoginFlowState.Unauthenticated] = true,
		[LoginFlowState.Authenticated] = true,
		[LoginFlowState.Brand] = true
	},
	[LoginFlowState.Authenticated] = {
		[LoginFlowState.Authenticated] = true,
		[LoginFlowState.Unauthenticated] = true,
		[LoginFlowState.Multiverse] = true,
		[LoginFlowState.Brand] = true
	},
	[LoginFlowState.Multiverse] = {
		[LoginFlowState.Multiverse] = true,
		[LoginFlowState.Brand] = true,
		[LoginFlowState.Start] = true
	}
}

M.IsNewLoginSystem = function(self)
	return self.cs and self.cs.newLoginSystem ~= true
end

M.GetLoginFlowState = function(self)
	if self.loginFlowState == nil then
		return self.loginFlowState
	end

	if self.cs and self.cs.loginFlowState == nil then
		return self.cs.loginFlowState
	end

	return LoginFlowState.Start
end

M.SetLoginFlowState = function(self, state, reason, force)
	if state ~= nil or LoginStateTransitions[state] ~= nil then
		self:LogLoginDebug("忽略非法登录状态=" .. tostring(state))

		return false
	end

	local previousState = self:GetLoginFlowState()

	if previousState == state then
		local canTransit = LoginStateTransitions[previousState] and LoginStateTransitions[previousState][state]

		if not canTransit and not force then
			self:LogLoginDebug(string.format("拒绝非法登录状态迁移 %s -> %s", tostring(previousState), tostring(state)))

			return false
		end
	end

	self.loginFlowState = state

	if self.cs and self.cs.SetLoginFlowState then
		self.cs:SetLoginFlowState(state)
	end

	if previousState == state then
		self:LogLoginDebug(string.format("登录状态迁移 %s -> %s，reason=%s", tostring(previousState), tostring(state), tostring(reason)))
		gMessageManager:SendMessage(gEventConstants.LOGIN_FLOW_STATE_CHANGE, {
			fromState = previousState,
			state = state,
			reason = reason
		})
	end

	return true
end

M.EnterResourceLoadingState = function(self, reason)
	return self:SetLoginFlowState(LoginFlowState.ResourceLoading, reason or "resource_loading")
end

M.EnterBrandState = function(self, reason)
	return self:SetLoginFlowState(LoginFlowState.Brand, reason or "brand")
end

M.EnterUnauthenticatedState = function(self, reason, force)
	return self:SetLoginFlowState(LoginFlowState.Unauthenticated, reason or "unauthenticated", force)
end

M.EnterAuthenticatedState = function(self, reason)
	return self:SetLoginFlowState(LoginFlowState.Authenticated, reason or "authenticated")
end

M.EnterMultiverseState = function(self, reason)
	return self:SetLoginFlowState(LoginFlowState.Multiverse, reason or "multiverse")
end

M.ClearLoginState = function(self, preserveMainPanelState, reason, preserveStartupAutoRestore)
	self:LogLoginDebug("ClearLoginState begin preserveMainPanelState=" .. tostring(preserveMainPanelState) .. " preserveStartupAutoRestore=" .. tostring(preserveStartupAutoRestore) .. " reason=" .. tostring(reason))

	self.loginInterceptState = LoginInterceptState.None

	if not preserveStartupAutoRestore then
		self.isAutoRestore = false
		self.startupAutoRestoreState = StartupAutoRestoreState.None
	end

	if not preserveMainPanelState then
		self.loginMainPanelState = LoginMainPanelState.NotReady
	end

	self.forcedAnnouncementCompleted = false
	self.forcedAnnouncementShowing = false
	self.maintenanceAnnouncementShowing = false
	self.announcementCheckPending = false
	self.loginInterceptMessageShowing = false
	self.startupAutoProbeActive = false
	self.returnLoginAutoConnectActive = false

	self:ResetActivationState(reason)
	self:LogLoginDebug("ClearLoginState end")
end

M.ctor = function(self)
	self._MsgEvents = {}
	self.loginFlowState = LoginFlowState.Start

	self:ClearLoginState(false, "ctor")

	self.sdkReloginPending = false
	self.sdkReloginPanelReady = false
	self.cs = gCS.LoginManager
end

M.RegisterSingleEvent = function(self, enentId, func)
	self._MsgEvents[#self._MsgEvents + 1] = {
		eventid = enentId,
		func = func
	}

	gMessageManager:AddMessageListener(enentId, func)
end

M.RegisterMessageEvents = function(self, eventHandlers)
	for k, v in pairs(eventHandlers) do
		self:RegisterSingleEvent(k, v)
	end
end

M.ClearMessageEvents = function(self)
	for i, v in pairs(self._MsgEvents) do
		gMessageManager:RemoveMessageListener(v.eventid, v.func)
	end

	table.clear(self._MsgEvents)
end

M.OnInit = function(self)
	self:LogLoginDebug("OnInit begin")

	self.loginFlowState = LoginFlowState.Start

	self:ClearLoginState(false, "on_init")

	self.sdkReloginPending = false
	self.sdkReloginPanelReady = false
	self.availableServerList = {}
	self.versionTag = ""
	self.getServerInfoCount = 0
	self.reconnectCo = nil
	self.hasPreConnected = false
	self.isServerOutOfVersion = true
	self.isConnecting = false
	self.isLogining = false
	self.account = ""
	self.editorAccount = ""
	self.isCreateNewRole = false
	self.afterCreateRole = {}

	self:ReadPlayerPrefs()
	self:ResetServerInfo()

	self.store = gStoreManager:GetStoreGroup("LoginPanelStore")
	self.msgEvents = {
		[gEventConstants.LOGIN_SERVER_FAILED] = self:CreateAction(self.OnLoginServerFailed),
		[gEventConstants.SYNC_SERVER_LIST] = self:CreateAction(self.GetServerListDone),
		[gEventConstants.DOWNLOAD_SERVER_LIST_FAILED] = self:CreateAction(self.GetServerListFailed),
		[gEventConstants.SELECT_SERVER_DONE] = self:CreateAction(self.OnSelectetServerDone),
		[gEventConstants.LOGIN_SERVER_SUCCESS] = self:CreateAction(self.OnLoginServerSuccess),
		[gEventConstants.SYNC_ROLE_LIST] = self:CreateAction(self.OnSyncRoleList),
		[gEventConstants.BEGINNER_LOGIN_CREATE_END] = self:CreateAction(self.OnCharacterCreated),
		[gEventConstants.LOGIN_QUEUE_NEED_QUEUE] = self:CreateAction(self.OnStartQueue),
		[gEventConstants.LOGIN_QUEUE_SUCCESS] = self:CreateAction(self.OnEndQueue),
		[gEventConstants.LOGIN_LUA_FILE_UPDATE] = self:CreateAction(self.OnLoginLuaUpdate),
		[gEventConstants.UNISDK_ON_LOGOUT_DONE] = self:CreateAction(self.OnSdkLogoutDone),
		[gEventConstants.UNISDK_ON_LOGIN_BEGIN] = self:CreateAction(self.OnSdkLoginBegin),
		[gEventConstants.UNISDK_CDKEY_GAME_INPUT] = self:CreateAction(self.OnCdkeyGameInput),
		[gEventConstants.UNISDK_CDKEY_ACTIVATE] = self:CreateAction(self.OnCdkeyActivate),
		[gEventConstants.UNISDK_CDKEY_AUTH] = self:CreateAction(self.OnCdkeyAuth),
		[gEventConstants.PANEL_CLOSE] = self:CreateAction(self.OnPanelClose),
		[gEventConstants.ON_KICK_TO_LOGIN] = self:CreateAction(self.OnKickToLoginEvent),
		[gEventConstants.L50_BEFORE_SWITCH_SCENE] = self:CreateAction(self.OnBeforeSwitchScene),
		[gEventConstants.ON_EVENT_STATE_CHANGE] = self:CreateAction(self.OnCurrentTaskChangeForGamescom),
		[gEventConstants.ON_REMOVE_CURRENT_TASK_SUCCESS] = self:CreateAction(self.OnRemoveCurrentTaskSuccessForGamescom),
		[gEventConstants.TASK_STATE_CHANGED] = self:CreateAction(self.OnTaskStateChangeForFinishTask)
	}

	self:RegisterMessageEvents(self.msgEvents)
	self:LogLoginDebug("OnInit end")
end

M.OnUpdate = function(self)
	self:OnUpdate_CheckNet()
end

M.OnEndQueue = function(self)
	self:LogLoginDebug("排队完成回调")
	self.store:SetFullUI(true)
	gDisplayMessageMgr:ShowMessage(MessageConfig.LineUpFinishTitle, function ()
		self:LogLoginDebug("排队完成提示关闭，准备继续登录；startupState=" .. tostring(self.startupAutoRestoreState))

		if self.startupAutoRestoreState ~= StartupAutoRestoreState.ReadyToEnter then
			local entered = self:TryAutoEnterAfterStartupRestore()

			self:LogLoginDebug("排队完成后的自动进入结果=" .. tostring(entered))
		else
			self:OnLogin()
		end
	end)
end

M.OnSdkLoginBegin = function(self)
	self:LogLoginDebug("收到 UNISDK_ON_LOGIN_BEGIN")

	if not self:IsNewLoginSystem() then
		self:LogLoginDebug("忽略 UNISDK_ON_LOGIN_BEGIN：旧登录系统")

		return
	end

	self:EnterUnauthenticatedState("sdk_login_begin")
end

M.OnKickToLoginEvent = function(self)
	self:LogLoginDebug("收到 ON_KICK_TO_LOGIN")

	if not self:IsNewLoginSystem() then
		self:LogLoginDebug("忽略 ON_KICK_TO_LOGIN：旧登录系统")

		return
	end

	self:ClearLoginState(false, "on_kick_to_login_event")
	self:EnterUnauthenticatedState("kick_to_login", true)

	if self.sdkReloginPanelReady then
		self:TryResumeSdkLoginAfterLogout("on_kick_to_login_event")
	end

	self:LogLoginDebug("ON_KICK_TO_LOGIN 处理完成")
end

M.OnPanelClose = function(self, _, panelMessage)
	if not panelMessage then
		self:LogLoginDebug("收到 PANEL_CLOSE，但 panelMessage=nil")

		return
	end

	local panelId = panelMessage

	if type(panelMessage) ~= "table" then
		panelId = panelMessage.panelId
	end

	if panelId == gPanelId.ANNOUNCEMENT_PANEL then
		return
	end

	self:LogLoginDebug("公告面板关闭，maintenanceShowing=" .. tostring(self.maintenanceAnnouncementShowing) .. " forcedShowing=" .. tostring(self.forcedAnnouncementShowing))

	if self.maintenanceAnnouncementShowing then
		self.maintenanceAnnouncementShowing = false

		self:LogLoginDebug("维护公告关闭，仍停留在维护拦截")

		return
	end

	if not self.forcedAnnouncementShowing then
		self:LogLoginDebug("普通公告关闭，未命中强制公告流程")

		return
	end

	self.forcedAnnouncementShowing = false
	self.forcedAnnouncementCompleted = true
	self.announcementCheckPending = false
	self.loginInterceptState = LoginInterceptState.None

	self:EnterAuthenticatedState("announcement_closed")

	local entered = self:TryAutoEnterAfterStartupRestore()

	self:LogLoginDebug("强制公告关闭后的自动进入结果=" .. tostring(entered))
end

M.OnStartQueue = function(self)
	self:LogLoginDebug("开始排队")
	self.store:SetFullUI(false)
end

M.OnLoginServerSuccess = function(self)
	self.isConnecting = false
	self.isLogining = false

	self:LogLoginDebug("OnLoginServerSuccess begin")

	if self:IsNewLoginSystem() then
		self.loginInterceptState = LoginInterceptState.None
		self.forcedAnnouncementCompleted = false
		self.forcedAnnouncementShowing = false
		self.maintenanceAnnouncementShowing = false
		self.announcementCheckPending = false

		if self.startupAutoRestoreState ~= StartupAutoRestoreState.Restoring then
			self.startupAutoRestoreState = StartupAutoRestoreState.LoginSucceeded
		elseif self.startupAutoRestoreState ~= StartupAutoRestoreState.RoleSynced then
			self.startupAutoRestoreState = StartupAutoRestoreState.ReadyToEnter
		end

		self:EnterAuthenticatedState("login_server_success")

		local resolved = self:TryResolveStartupAutoRestore()

		self:LogLoginDebug("Login成功后的自动恢复状态同步结果=" .. tostring(resolved))
	end

	self:LogLoginDebug("Login成功处理状态更新完成，准备判断排队")

	if gCS.NetworkManager.currentState ~= gNetworkState.Queue then
		if not gCS.LuaUtils.IsPublish then
			gDisplayMessageMgr:ShowMessageContent(gString.Format("服务器连接完成，进入排队状态"))
		end

		self:LogLoginDebug("Login服务器连接完成，进入排队状态")
	else
		self:LogLoginDebug("Login服务器连接完成，进入正常登录成功分支")
		self:SaveEditorAccount()

		if self:CheckIsSkipCreateCharacter() and self.isCreateNewRole then
			self:RequstCreateRole()
		end

		if self:IsNewLoginSystem() then
			local interceptionPassed = self:CheckLoginInterception()

			self:LogLoginDebug("Login成功后的拦截检查结果=" .. tostring(interceptionPassed))

			if interceptionPassed then
				local entered = self:TryAutoEnterAfterStartupRestore(true)

				self:LogLoginDebug("Login成功后的自动进入结果=" .. tostring(entered))
			end
		elseif not self:IsGamescomDemo() and self.cs.isFirstLogin then
			self:OnLogin()
		end
	end

	self.store:SetFullUI(true)
end

M.OnSelectetServerDone = function(self, eventId, flag)
	self.isConnecting = false

	self:LogLoginDebug("OnSelectetServerDone eventId=" .. tostring(eventId) .. " flag=" .. tostring(flag))

	if flag then
		if self:IsNewLoginSystem() then
			self:EnterUnauthenticatedState("server_selected")
		end

		self:DoLoginUniSDK()
	else
		self:LogLoginDebug("OnSelectetServerDone 选服失败，不调用 SDK 登录")
	end
end

M.OnChangeServer = function(self, serverData)
	self:LogLoginDebug("OnChangeServer begin id=" .. tostring(serverData and serverData.Id) .. " name=" .. tostring(serverData and serverData.Name) .. " status=" .. tostring(serverData and serverData.Status))

	self.loginUrl = serverData.LoginListUrl
	self.serverId = serverData.Id
	self.serverName = serverData.Name
	self.loginServerId = serverData.Id
	self.serverStatus = serverData.Status
	self.isCreateNewRole = false
	local preserveStartupAutoRestore = self.isAutoRestore and self.startupAutoRestoreState == StartupAutoRestoreState.None

	self:LogLoginDebug("OnChangeServer preserveStartupAutoRestore=" .. tostring(preserveStartupAutoRestore))
	self:ClearLoginState(true, "change_server", preserveStartupAutoRestore)

	if self:IsNewLoginSystem() then
		self:EnterUnauthenticatedState("server_changed", true)
	end

	gMessageManager:SendMessage(gEventConstants.LOGIN_SERVER_CHANGE, serverData)

	if serverData.Id then
		self:SelectServer()
	else
		self:Error("OnChangeServer serverData.Id is nil")
	end

	self:LogLoginDebug("OnChangeServer end")
end

M.IsPersistentBanReason = function(self, reason)
	return reason ~= LoginFailedReason.NotInWhiteList or reason ~= LoginFailedReason.UserBanned or reason ~= LoginFailedReason.RpcBanned
end

M.IsSelectedServerMaintenance = function(self, reason)
	if reason ~= LoginFailedReason.ServerMaintenance then
		return true
	end

	return self.serverId == nil and self.serverId == 0 and (tonumber(self.serverStatus) or 0) > 0
end

M.GetLoginFailedMessage = function(self, reason)
	if reason ~= LoginFailedReason.NotInWhiteList then
		return MessageConfig.NotInWhiteList
	elseif reason ~= LoginFailedReason.UserBanned then
		return MessageConfig.UserBanned
	elseif reason ~= LoginFailedReason.RpcBanned then
		return MessageConfig.RPCBan
	elseif reason ~= LoginFailedReason.LoginTokenInvalid then
		return MessageConfig.LoginTokenInvalid
	elseif reason ~= LoginFailedReason.DeviceNotMatch then
		return MessageConfig.DeviceNotMatch
	elseif reason ~= LoginFailedReason.NeedActivation then
		return MessageConfig.NeedActivation
	end

	return nil
end

M.ShowLoginInterceptMessage = function(self, messageId, callback)
	if self.loginInterceptMessageShowing then
		self:LogLoginDebug("拦截提示已在显示，跳过重复弹窗 messageId=" .. tostring(messageId))

		return
	end

	if not messageId then
		self:LogLoginDebug("拦截提示无 messageId，直接执行回调")

		if callback then
			callback()
		end

		return
	end

	self.loginInterceptMessageShowing = true

	self:LogLoginDebug("显示登录拦截提示 messageId=" .. tostring(messageId))
	gDisplayMessageMgr:ShowMessage(messageId, function ()
		self.loginInterceptMessageShowing = false

		self:LogLoginDebug("登录拦截提示关闭 messageId=" .. tostring(messageId))

		if callback then
			callback()
		end
	end)
end

M.OpenMaintenanceAnnouncement = function(self)
	self.maintenanceAnnouncementShowing = true

	self:LogLoginDebug("准备打开维护公告")

	if gAnnouncementMgr and gAnnouncementMgr.OpenNoticePanel then
		gAnnouncementMgr:OpenNoticePanel()
	else
		self.maintenanceAnnouncementShowing = false

		self:LogLoginDebug("维护公告打开失败：公告管理器或 OpenNoticePanel 不存在")
	end
end

M.OpenForcedAnnouncement = function(self)
	if self.forcedAnnouncementShowing then
		self:LogLoginDebug("强制公告已经打开，跳过重复打开")

		return
	end

	if not gAnnouncementMgr or not gAnnouncementMgr.OpenNoticePanel then
		self.forcedAnnouncementCompleted = true
		self.loginInterceptState = LoginInterceptState.None

		self:LogLoginDebug("强制公告无法打开，视为公告流程完成")

		return
	end

	self.forcedAnnouncementShowing = true

	self:LogLoginDebug("准备打开强制公告")
	gAnnouncementMgr:OpenNoticePanel()
end

M.ShowBannedIntercept = function(self, reason)
	self.loginInterceptState = LoginInterceptState.Banned

	self:LogLoginDebug("进入封禁拦截 reason=" .. tostring(reason))
	self:EnterAuthenticatedState("login_banned", true)
	self:ShowLoginInterceptMessage(self:GetLoginFailedMessage(reason))
end

M.ShowMaintenanceIntercept = function(self)
	self.loginInterceptState = LoginInterceptState.Maintenance

	self:LogLoginDebug("进入维护拦截")
	self:EnterAuthenticatedState("server_maintenance", true)

	if self.maintenanceAnnouncementShowing then
		self:LogLoginDebug("维护拦截公告已在显示，跳过重复打开")

		return
	end

	self:ShowLoginInterceptMessage(MessageConfig.LoginMaintain, function ()
		self:OpenMaintenanceAnnouncement()
	end)
end

M.CheckLoginInterception = function(self)
	local isNewLoginSystem = self:IsNewLoginSystem()
	local loginFlowState = self:GetLoginFlowState()

	self:LogLoginDebug("CheckLoginInterception begin newLoginSystem=" .. tostring(isNewLoginSystem) .. " flow=" .. tostring(loginFlowState))

	if not isNewLoginSystem or loginFlowState == LoginFlowState.Authenticated then
		self:LogLoginDebug("拦截检查直接放行：不是新登录系统或当前不在 S4")

		return true
	end

	if self.loginInterceptState ~= LoginInterceptState.Banned then
		self:LogLoginDebug("拦截检查阻断：封禁状态")
		self:ShowLoginInterceptMessage(self:GetLoginFailedMessage(self.loginFailedReason))

		return false
	elseif self.loginInterceptState ~= LoginInterceptState.Maintenance then
		self:LogLoginDebug("拦截检查阻断：维护状态")

		if not self.maintenanceAnnouncementShowing then
			self:ShowMaintenanceIntercept()
		end

		return false
	elseif self.loginInterceptState ~= LoginInterceptState.Announcement and not self.forcedAnnouncementCompleted then
		self:LogLoginDebug("拦截检查阻断：强制公告未完成")
		self:OpenForcedAnnouncement()

		return false
	end

	if self:IsSelectedServerMaintenance() then
		self:LogLoginDebug("拦截检查阻断：当前服务器维护")
		self:ShowMaintenanceIntercept()

		return false
	end

	if gAnnouncementMgr then
		local noticeListLoaded = true

		if gAnnouncementMgr.IsNoticeListLoaded then
			noticeListLoaded = gAnnouncementMgr:IsNoticeListLoaded()
		elseif gAnnouncementMgr.isFirst == nil then
			noticeListLoaded = not gAnnouncementMgr.isFirst
		end

		self:LogLoginDebug("公告检查 noticeListLoaded=" .. tostring(noticeListLoaded) .. " requestPending=" .. tostring(self.announcementCheckPending) .. " hasRequest=" .. tostring(gAnnouncementMgr.RequestNoticeList == nil))

		if not noticeListLoaded and gAnnouncementMgr.RequestNoticeList then
			if not self.announcementCheckPending then
				self.announcementCheckPending = true

				self:LogLoginDebug("公告列表未加载，发起 RequestNoticeList")
				gAnnouncementMgr:RequestNoticeList(function ()
					self:LogLoginDebug("RequestNoticeList 回调 begin")

					self.announcementCheckPending = false
					local interceptionPassed = self:CheckLoginInterception()

					self:LogLoginDebug("RequestNoticeList 回调拦截结果=" .. tostring(interceptionPassed))

					if interceptionPassed then
						local entered = self:TryAutoEnterAfterStartupRestore(true)

						self:LogLoginDebug("RequestNoticeList 回调自动进入结果=" .. tostring(entered))
					end
				end)
			else
				self:LogLoginDebug("公告列表请求已在进行中，跳过重复 RequestNoticeList")
			end

			return false
		end

		local hasUnreadNotice = gAnnouncementMgr.HasUnreadNotice and gAnnouncementMgr:HasUnreadNotice() ~= true

		self:LogLoginDebug("公告检查未读结果=" .. tostring(hasUnreadNotice) .. " forcedCompleted=" .. tostring(self.forcedAnnouncementCompleted))

		if not self.forcedAnnouncementCompleted and hasUnreadNotice then
			self.loginInterceptState = LoginInterceptState.Announcement

			self:LogLoginDebug("拦截检查阻断：存在未读公告")
			self:OpenForcedAnnouncement()

			return false
		end
	else
		self:LogLoginDebug("公告管理器不存在，跳过公告拦截")
	end

	self.loginInterceptState = LoginInterceptState.None
	self.forcedAnnouncementCompleted = true

	self:LogLoginDebug("拦截检查通过")

	return true
end

M.TryResolveStartupAutoRestore = function(self)
	self:LogLoginDebug("TryResolveStartupAutoRestore begin")

	if self.startupAutoRestoreState == StartupAutoRestoreState.ReadyToEnter then
		self:LogLoginDebug("TryResolveStartupAutoRestore return false：状态不是 ReadyToEnter")

		return false
	end

	local hasRole = self:CheckHasRole()

	self:LogLoginDebug("TryResolveStartupAutoRestore 检查角色 hasRole=" .. tostring(hasRole))

	if not hasRole then
		self:OpenStartupAutoRestorePanel("login_success_without_role")
		self:LogLoginDebug("TryResolveStartupAutoRestore fallback：没有角色，打开登录面板")

		return true
	end

	self:LogLoginDebug("TryResolveStartupAutoRestore ready：已有角色，等待拦截检查")

	return true
end

M.TryAutoEnterAfterStartupRestore = function(self, interceptionPassed)
	self:LogLoginDebug("TryAutoEnterAfterStartupRestore begin interceptionPassed=" .. tostring(interceptionPassed))

	if self.startupAutoRestoreState == StartupAutoRestoreState.ReadyToEnter then
		self:LogLoginDebug("自动进入失败：startupState 不是 ReadyToEnter")

		return false
	end

	local loginFlowState = self:GetLoginFlowState()
	local hasRole = self:CheckHasRole()

	if loginFlowState == LoginFlowState.Authenticated or not hasRole then
		self:LogLoginDebug("自动进入失败：flow=" .. tostring(loginFlowState) .. "，hasRole=" .. tostring(hasRole))

		return false
	end

	if gCS.NetworkManager and gNetworkState and gCS.NetworkManager.currentState ~= gNetworkState.Queue then
		self:LogLoginDebug("自动进入失败：当前仍在排队")

		return false
	end

	if interceptionPassed == true and not self:CheckLoginInterception() then
		self:LogLoginDebug("自动进入失败：登录拦截未通过")

		return false
	end

	self.startupAutoRestoreState = StartupAutoRestoreState.None
	self.isAutoRestore = false

	self:LogLoginDebug("自动进入条件全部满足，调用 AutoLogin")
	self:AutoLogin()

	return true
end

M.HandleNewLoginServerFailed = function(self, reason)
	self.loginFailedReason = reason

	self:LogLoginDebug("HandleNewLoginServerFailed reason=" .. tostring(reason) .. " persistentBan=" .. tostring(self:IsPersistentBanReason(reason)) .. " selectedServerMaintenance=" .. tostring(self:IsSelectedServerMaintenance(reason)))

	if self:IsPersistentBanReason(reason) then
		self:ShowBannedIntercept(reason)
		self.store:SetFullUI(true)

		return
	end

	if self:IsSelectedServerMaintenance(reason) then
		self:ShowMaintenanceIntercept()
		self.store:SetFullUI(true)

		return
	end

	if reason ~= LoginFailedReason.NeedActivation then
		self.loginInterceptState = LoginInterceptState.None
		self.isAutoRestore = false

		self:DoKickToLogin()
		self:OnServerNeedActivation()
		self:OpenActivationCodePanel()
		self.store:SetFullUI(true)

		return
	end

	self.loginInterceptState = LoginInterceptState.None
	self.isAutoRestore = false

	self:EnterUnauthenticatedState("login_failed")

	if IsTerminalLoginError(reason) then
		local msgId = self:GetLoginFailedMessage(reason)

		self:ShowLoginInterceptMessage(msgId, function ()
			self:DoKickToLogin()
		end)
		self.store:SetFullUI(true)

		return
	end

	if self.cs.canSelectServer then
		gDisplayMessageMgr:ShowMessage(MessageConfig.LoginErrorWithOtherServer, function ()
			self:OpenSelectServerPanel(true)
		end)
	else
		gDisplayMessageMgr:ShowMessage(MessageConfig.LoginFailed, function ()
		end)
	end

	self.store:SetFullUI(true)
end

M.OnLoginServerFailed = function(self, eventId, reason)
	self.isConnecting = false
	self.isLogining = false

	self:LogLoginDebug(gString.Format("Login服务器 %s 连接失败 reason=%s", self.serverName, tostring(reason)))
	self:ClearClickablePopMsg()

	if self:IsNewLoginSystem() then
		self:LogLoginDebug("新登录系统处理 Login 失败：先尝试结束启动自动恢复")
		self:OpenStartupAutoRestorePanel("login_server_failed")
		self:HandleNewLoginServerFailed(reason)

		return
	end

	if reason ~= LoginFailedReason.NeedActivation then
		gDisplayMessageMgr:ShowMessage(MessageConfig.NeedActivation, function ()
			self:DoKickToLogin()
			self:OnServerNeedActivation()
		end)
		self.store:SetFullUI(true)

		return
	end

	if IsTerminalLoginError(reason) then
		local msgId = nil

		if reason ~= LoginFailedReason.NotInWhiteList then
			msgId = MessageConfig.NotInWhiteList
		elseif reason ~= LoginFailedReason.UserBanned then
			msgId = MessageConfig.UserBanned
		elseif reason ~= LoginFailedReason.RpcBanned then
			msgId = MessageConfig.RPCBan
		elseif reason ~= LoginFailedReason.LoginTokenInvalid then
			msgId = MessageConfig.LoginTokenInvalid
		elseif reason ~= LoginFailedReason.DeviceNotMatch then
			msgId = MessageConfig.DeviceNotMatch
		end

		if msgId then
			gDisplayMessageMgr:ShowMessage(msgId, function ()
				self:DoKickToLogin()
			end)
		else
			self:DoKickToLogin()
		end

		self.store:SetFullUI(true)

		return
	end

	if self.cs.canSelectServer then
		gDisplayMessageMgr:ShowMessage(MessageConfig.LoginErrorWithOtherServer, function ()
			self:OpenSelectServerPanel(true)
		end)
	elseif self.serverStatus < 0 then
		gDisplayMessageMgr:ShowMessage(MessageConfig.LoginMaintain, function ()
			self:SelectServer()
		end)
	else
		gDisplayMessageMgr:ShowMessage(MessageConfig.LoginFailed, function ()
		end)
	end

	self.store:SetFullUI(true)
end

M.OnSdkLogoutDone = function(self)
	self.isLogining = false

	self:LogLoginDebug("收到 UNISDK_ON_LOGOUT_DONE")
	self:OpenStartupAutoRestorePanel("sdk_logout_done")
	self:ClearLoginState(true, "sdk_logout_done")
	self:EnterUnauthenticatedState("sdk_logout_done", true)

	self.sdkReloginPending = self:IsNewLoginSystem() and self.cs.loginBySDK ~= true
	self.sdkReloginPanelReady = false

	self:LogLoginDebug("UNISDK_ON_LOGOUT_DONE 自动重新登录 pending=" .. tostring(self.sdkReloginPending))

	if not gCS.LuaUtils.IsOnEditor or self.cs.loginBySDK then
		self:LogLoginDebug("UNISDK_ON_LOGOUT_DONE 处理完成，不清理编辑器账号")

		return
	end

	self:SetEditorAccount("")
	self:LogLoginDebug("UNISDK_ON_LOGOUT_DONE 处理完成，已清理编辑器账号")
end

M.OnBeforeSwitchScene = function(self, _, switchSceneEventParams)
	local switchType = switchSceneEventParams.switchSceneType

	if switchType == gSwitchSceneType.KickToLogin then
		return
	end

	self:LogLoginDebug("收到切场景 KickToLogin")
	gMultiverseMgr:OnBeforeSwitchScene(switchType)

	self.hasPreConnected = false

	self:ClearLoginState(false, "before_kick_to_login")
	self:EnterUnauthenticatedState("before_kick_to_login", true)
	self:LogLoginDebug("切场景 KickToLogin 清理完成")
end

M.GetServerListDone = function(self, eventId, serverInfo)
	self.availableServerList = serverInfo:ToTable()

	self:LogLoginDebug("服务器列表同步完成 count=" .. tostring(self.availableServerList and #self.availableServerList or 0))
	self:MatchServer()
	self.store:SetFullUI(true)
end

M.GetServerListFailed = function(self)
	self.isConnecting = false
	self.isLogining = false

	self:LogLoginDebug("服务器列表获取失败")

	if self:IsNewLoginSystem() then
		self:EnterUnauthenticatedState("server_list_failed")

		self.isAutoRestore = false

		self:OpenStartupAutoRestorePanel("server_list_failed")
	end

	self:ClearClickablePopMsg()
	gDisplayMessageMgr:ShowMessage(MessageConfig.CanNotGetSeverData, function ()
		self.isConnecting = true

		self:GetServerList()
	end, function ()
		gCS.LuaUtils.QuitApplication()
	end)
	self.store:SetFullUI(true)
end

M.BackToLogin = function(self)
	self.isConnecting = false
	self.isLogining = false
	self.hasPreConnected = false

	self:LogLoginDebug("BackToLogin begin")
	self:ClearLoginState(false, "back_to_login")
	self:EnterUnauthenticatedState("back_to_login", true)
	gLoginManager:OpenMainPanel({
		["\\xd0\\xc827\\xe5"] = false,
		["\\xee\\x898\\xe2\\xe1\\xe4\\xb9\\xf8\\x875-"] = true
	})
	self:LogLoginDebug("BackToLogin 已打开登录面板")
end

M.KickToLogin = function(self)
	self.isConnecting = false
	self.isLogining = false
	self.hasPreConnected = false

	self:LogLoginDebug("KickToLogin begin")
	self:ClearLoginState(false, "kick_to_login")
	self:EnterUnauthenticatedState("kick_to_login", true)
	gLoginManager:OpenMainPanel({
		["\\xd0\\xc827\\xe5"] = false,
		["\\xee\\x898\\xe2\\xe1\\xe4\\xb9\\xf8\\x875-"] = true
	})

	self.sdkReloginPanelReady = self.sdkReloginPending ~= true

	self:LogLoginDebug("KickToLogin 已打开登录面板")
end

M.ResetServerInfo = function(self)
	self.loginUrl = ""
	self.serverId = 0
	self.serverName = ""
	self.serverStatus = 0
	self.loginServerId = 0
end

M.Log = function(self, content)
	if not self.cs then
		return
	end

	self.cs.Log(gString.Format("[Lua LoginManager] %s", content))
end

M.GetLoginDebugContext = function(self)
	local roleId = "nil"

	if gPlayerManager and gPlayerManager.main and gPlayerManager.main.bindData then
		local loginRolePid = gPlayerManager.main.bindData.loginRolePid

		if loginRolePid == nil then
			if ulong and ulong.tostring then
				roleId = ulong.tostring(loginRolePid)
			else
				roleId = tostring(loginRolePid)
			end
		end
	end

	local networkState = "nil"

	if gCS and gCS.NetworkManager then
		networkState = tostring(gCS.NetworkManager.currentState)
	end

	local sdkLoginDone = false

	if self.cs then
		sdkLoginDone = self.cs.isSDkLoginDone ~= true or self.cs.uniSDKLoginDone ~= true
	end

	return string.format("flow=%s intercept=%s startup=%s panel=%s autoRestore=%s preConnected=%s connecting=%s logining=%s role=%s network=%s sdkDone=%s", tostring(self:GetLoginFlowState()), tostring(self.loginInterceptState), tostring(self.startupAutoRestoreState), tostring(self.loginMainPanelState), tostring(self.isAutoRestore), tostring(self.hasPreConnected), tostring(self.isConnecting), tostring(self.isLogining), roleId, networkState, tostring(sdkLoginDone))
end

M.LogLoginDebug = function(self, content)
	self:Log("[Login Debug] " .. tostring(content) .. " | " .. self:GetLoginDebugContext())
end

M.Error = function(self, content)
	if not self.cs.printLog then
		return
	end

	self.cs.LogError(gString.Format("[Lua LoginManager] %s", content))
end

M.CheckVersion = function(self, serverInfo)
	return self.cs:CheckVersion(serverInfo)
end

local UPDATE_FRAQ = 30
local frameCount = 0
local isConnected = true

M.OnUpdate_CheckNet = function(self)
	frameCount = frameCount + 1

	if UPDATE_FRAQ < frameCount then
		self:CheckNetworkState()

		frameCount = 0
	end
end

M.CheckNetworkState = function(self)
	if not self.cs.CheckLoginConnected then
		return
	end

	local loginConnected = gCS.NetworkManager:IsLoginConnected()

	if isConnected and not loginConnected then
		isConnected = false

		self.store:SetFullUI(false)

		if gCS.LuaUtils.IsNonMobileAdaptive() then
			gDisplayMessageMgr:ShowMessage(MessageConfig.CheckNetworkConnectionSingle, function ()
				self:DoLoginUniSDK()
			end)
		else
			gDisplayMessageMgr:ShowMessage(MessageConfig.CheckNetworkConnection, function ()
				self:DoLoginUniSDK()
			end, function ()
				gCS.LuaUtils.OpenPermissionSettings()
			end)
		end
	elseif not isConnected and loginConnected then
		isConnected = true

		gDisplayMessageMgr:HideMessage(MessageConfig.CheckNetworkConnection)
	end
end

M.GetServerList = function(self, callback)
	self:LogLoginDebug("GetServerList begin callback=" .. tostring(callback == nil))
	self.cs:DownloadServerList(callback)
end

M.BuildServerMap = function(self)
	local recommendedServer = TextScriptTextConfig.GetConfig(89900286).Text
	local serverSessionNameMap = {
		[recommendedServer] = {}
	}
	local tabs = {
		{
			label = recommendedServer
		}
	}
	local localServerName = LX6.GUI.Login.ServerData.GetLocalServerName()

	for i, server in ipairs(self.availableServerList) do
		local serverName = server.SectionName

		if serverName ~= "" then
			serverName = TextScriptTextConfig.GetConfig(89900287).Text
		end

		local map = serverSessionNameMap[serverName]

		if not map then
			local index = #tabs + 1
			tabs[index] = {
				label = serverName
			}
			map = {}
			serverSessionNameMap[serverName] = map
		end

		local ele = {
			i,
			server
		}

		table.insert(map, ele)

		if localServerName and table.isNilOrEmpty(serverSessionNameMap[recommendedServer]) and string.starts_with(server.Name, localServerName) then
			table.insert(serverSessionNameMap[recommendedServer], ele)
		end
	end

	if table.isNilOrEmpty(serverSessionNameMap[recommendedServer]) then
		table.remove(tabs, 1)
	end

	return tabs, serverSessionNameMap
end

M.MatchServer = function(self)
	self:LogLoginDebug("MatchServer begin availableCount=" .. tostring(self.availableServerList and #self.availableServerList or 0))

	local uniAppChannel = UniSDKManager.AppChannel
	local channelServerList = {}

	for i = 1, #self.availableServerList do
		local d = self.availableServerList[i]
		local channelName = d.ChannelName

		if uniAppChannel and channelName == "*" and channelName ~= uniAppChannel then
			table.insert(channelServerList, d)
		end
	end

	if #channelServerList <= 0 then
		self:OnChangeServer(channelServerList[1])
	else
		local targetList = {}

		for i = 1, #self.availableServerList do
			local d = self.availableServerList[i]
			local channelName = d.ChannelName

			if channelName ~= "*" then
				table.insert(targetList, d)
			end
		end

		if #targetList <= 0 then
			local localServerName = LX6.GUI.Login.ServerData.GetLocalServerName()
			local targetIndex = 0

			if self.loginServerId ~= 0 then
				self.loginServerId = PlayerPrefs.GetInt("LastServerId")

				for i = 1, #targetList do
					if targetList[i].Id ~= self.loginServerId then
						targetIndex = i
					end

					if targetList[i].Name ~= localServerName then
						targetIndex = i

						break
					end
				end
			else
				for i = 1, #targetList do
					if targetList[i].Id ~= self.loginServerId then
						targetIndex = i

						break
					end

					if targetList[i].Name ~= localServerName then
						targetIndex = i
					end
				end
			end

			local targetData = targetList[targetIndex]

			if not targetData then
				local t = math.random(1, #targetList)
				targetData = targetList[t]
			end

			if targetData then
				self.isServerOutOfVersion = not self:CheckVersion(targetData)

				self:LogLoginDebug("MatchServer 选中服务器 id=" .. tostring(targetData.Id) .. " name=" .. tostring(targetData.Name) .. " outOfVersion=" .. tostring(self.isServerOutOfVersion))
				self:OnChangeServer(targetData)
			else
				self.isServerOutOfVersion = true

				self:LogLoginDebug("MatchServer 没有匹配到服务器")
			end
		else
			self:LogLoginDebug("MatchServer 可用目标服务器数量为0")
			self:Error("可用服务器数量为0")
		end
	end
end

M.SelectServer = function(self)
	self:LogLoginDebug("SelectServer begin serverId=" .. tostring(self.serverId) .. " serverName=" .. tostring(self.serverName) .. " outOfVersion=" .. tostring(self.isServerOutOfVersion) .. " loginUrlEmpty=" .. tostring(string.is_null_or_empty(self.loginUrl)))

	if self.isServerOutOfVersion then
		gDisplayMessageMgr:ShowMessage(MessageConfig.SeverIsMaintenance)
		self:LogLoginDebug("SelectServer 失败：服务器版本不可用")

		return
	end

	if string.is_null_or_empty(self.loginUrl) then
		self:Error("loginUrl为空")
		self:LogLoginDebug("SelectServer 失败：loginUrl 为空")

		return
	end

	if not self.serverId then
		self:Error("serverId为空")
		self:LogLoginDebug("SelectServer 失败：serverId 为空")

		return
	end

	PlayerPrefs.SetInt("LastServerId", self.serverId)
	PlayerPrefs.Save()

	self.isConnecting = true

	self.cs:SelectLoginServer(self.loginUrl, self.serverName, self.serverId, self.serverStatus)
	self:LogLoginDebug("SelectServer 已调用 C# SelectLoginServer")
end

M.SaveEditorAccount = function(self)
	if not gCS.LuaUtils.IsOnEditor or self.cs.loginBySDK then
		return
	end

	local loginFile = io.open("login", "w")

	if loginFile == nil then
		loginFile:write(self.editorAccount)
		loginFile:close()
	end
end

M.ReadPlayerPrefs = function(self)
	if not gCS.LuaUtils.IsOnEditor or self.cs.loginBySDK then
		return
	end

	local loginFile = io.open("login", "r")

	if loginFile == nil then
		self:SetEditorAccount(loginFile:read() or "")
		loginFile:close()
	else
		self:SetEditorAccount(PlayerPrefs.GetString("Account", ""))
	end
end

M.SetEditorAccount = function(self, account)
	account = string.trim(account)

	if string.is_null_or_empty(account) then
		account = LX6.GUI.Login.ServerData.GetLocalServerName()
	end

	if string.is_null_or_empty(account) then
		account = math.random(1, 9999999)
	end

	local projName = gCS.LuaUtils.GetProjectName()
	self.editorAccount = tostring(account)

	if string.sub(self.editorAccount, 1, string.len("$")) ~= "$" then
		self.account = self.editorAccount
	else
		self.account = projName .. self.editorAccount
	end
end

M.ShowAccountBind = function(self)
	UniSDKManager.BindAccount()
end

M.RegisterAfterCreateRole = function(self, func)
	self.afterCreateRole[#self.afterCreateRole + 1] = func
end

M.AutoLogin = function(self)
	self:LogLoginDebug("AutoLogin begin hasRole=" .. tostring(self:CheckHasRole()))

	if PlayerPrefs.GetInt("AutoLogin", 0) ~= 1 then
		PlayerPrefs.SetInt("AutoLogin", 0)
		self:LogLoginDebug("AutoLogin 清理 PlayerPrefs.AutoLogin")
	end

	if self.autoLoginCo then
		self:LogLoginDebug("AutoLogin 停止旧协程")
		coroutine.stop(self.autoLoginCo)

		self.autoLoginCo = nil
	end

	self.autoLoginCo = coroutine.start(function ()
		self:LogLoginDebug("AutoLogin 协程开始")
		gMessageManager:SendMessage(gEventConstants.SHOW_WAITING_PANEL)

		local hasRole = self:CheckHasRole()

		if hasRole then
			self:LogLoginDebug("AutoLogin 协程等待 CanRequestEnterGame")

			while not self.cs:CanRequestEnterGame() do
				coroutine.wait(0.1)
			end

			self:LogLoginDebug("AutoLogin 协程结束 CanRequestEnterGame 等待")
		else
			self:LogLoginDebug("AutoLogin 协程无角色，跳过 CanRequestEnterGame 等待")
		end

		local waitLoginCount = 0

		while self.isConnecting or self.isLogining do
			waitLoginCount = waitLoginCount + 1

			coroutine.wait(0.1)
		end

		self:LogLoginDebug("AutoLogin 协程结束连接等待 count=" .. tostring(waitLoginCount))
		gMessageManager:SendMessage(gEventConstants.HIDE_WAITING_PANEL)
		self:LogLoginDebug("AutoLogin 准备调用 OnLogin，CheckHasRole=" .. tostring(self:CheckHasRole()))
		self:OnLogin()
		self:LogLoginDebug("AutoLogin 协程完成 OnLogin 调用")
	end)
end

M.OnSyncRoleList = function(self, eventId, roleId)
	local previousStartupState = self.startupAutoRestoreState

	self:LogLoginDebug("OnSyncRoleList begin eventId=" .. tostring(eventId) .. " roleId=" .. tostring(roleId) .. " previousStartupState=" .. tostring(previousStartupState) .. " startupProbe=" .. tostring(self.startupAutoProbeActive) .. " returnLoginAutoConnect=" .. tostring(self.returnLoginAutoConnectActive))

	gPlayerManager.main.bindData.loginRolePid = roleId

	if self.startupAutoProbeActive then
		self.startupAutoProbeActive = false
		local hasRole = roleId == nil and roleId == ulong.zero
		local sdkReady = self.cs.isSDkLoginDone ~= true or self.cs.uniSDKLoginDone ~= true

		self:LogLoginDebug("启动探测同步角色列表 roleId =" .. ulong.tostring(roleId) .. "|isAutoLogin = " .. (hasRole and sdkReady and "true" or "false"))

		if hasRole and sdkReady then
			self:LogLoginDebug("启动探测命中已有角色和 SDK 登录完成，调用 AutoLogin")
			self:AutoLogin()
		else
			self:LogLoginDebug("启动探测未满足自动进入，打开 StartScreen 检查")
			self:CheckMainPanelShowingOpen()
		end
	elseif self.returnLoginAutoConnectActive then
		self.returnLoginAutoConnectActive = false

		self:LogLoginDebug("回到登录页的自动连接完成，不自动进入游戏")
		self:CheckMainPanelShowingOpen()
	elseif not self:IsNewLoginSystem() then
		local autoLogin = self.cs.loginByOpenId or self:CheckIsSkipLogin() or self.cs.isAlreadyLogin

		self:LogLoginDebug("同步角色列表 roleId =" .. ulong.tostring(roleId) .. "|isAutoLogin = " .. (autoLogin and "true" or "false"))

		if autoLogin then
			self:LogLoginDebug("旧登录系统角色同步命中自动登录，调用 AutoLogin")
			self:AutoLogin()
		end
	elseif self.startupAutoRestoreState == StartupAutoRestoreState.None then
		self:LogLoginDebug("新登录状态机角色同步，准备推进 startupState")

		if self.startupAutoRestoreState ~= StartupAutoRestoreState.Restoring then
			self.startupAutoRestoreState = StartupAutoRestoreState.RoleSynced
		elseif self.startupAutoRestoreState ~= StartupAutoRestoreState.LoginSucceeded then
			self.startupAutoRestoreState = StartupAutoRestoreState.ReadyToEnter
		end

		self:Log("启动自动恢复同步角色列表 roleId =" .. ulong.tostring(roleId) .. "，roleReady=" .. tostring(self:CheckHasRole()) .. "，state=" .. tostring(self.startupAutoRestoreState))

		if self.startupAutoRestoreState ~= StartupAutoRestoreState.ReadyToEnter then
			local resolved = self:TryResolveStartupAutoRestore()
			local entered = self:TryAutoEnterAfterStartupRestore()

			self:LogLoginDebug("角色同步推进到 ReadyToEnter，resolve=" .. tostring(resolved) .. " autoEnter=" .. tostring(entered))
		end
	else
		self:LogLoginDebug("新登录状态机同步角色列表 roleId =" .. ulong.tostring(roleId) .. "，停留在当前登录状态")
	end

	if not table.isNilOrEmpty(self.afterCreateRole) and self:CheckHasRole() then
		self:LogLoginDebug("角色同步后执行 afterCreateRole count=" .. tostring(#self.afterCreateRole))

		for i = 1, #self.afterCreateRole do
			self.afterCreateRole[i]()
		end

		self.afterCreateRole = {}
	end

	self:LogLoginDebug("OnSyncRoleList end")
end

M.CheckHasRole = function(self)
	return gPlayerManager.main.bindData.loginRolePid and gPlayerManager.main.bindData.loginRolePid == ulong.zero and not self.isCreateNewRole
end

M.OnClick_DeleteRole = function(self)
	if not self:CheckHasRole() then
		gDisplayMessageMgr:ShowMessageContentDebug("没有角色")
		self:Log("没角色，点了删除角色，跳过操作")

		return
	end

	gDisplayMessageMgr:ShowMessageContent(TextScriptTextConfig.GetConfig(89900913).Text, gDisplayMessageId.SELECT, -1, function ()
		gMessageManager:SendMessage(gEventConstants.SHOW_WAITING_PANEL, nil)
		self:DeleteRole(function ()
			gMessageManager:SendMessage(gEventConstants.HIDE_WAITING_PANEL, nil)
		end)
	end)
end

M.DeleteRole = function(self, callback)
	self:Log("删除角色")

	local roleId = gPlayerManager.main.bindData.loginRolePid
	gPlayerManager.main.bindData.loginRolePid = ulong.zero

	gCS.GuiUtils.AskDeleteRole(gPlayerManager.main.bindData.loginRolePid, function (err)
		if err == MessageConfig.Ok then
			gDisplayMessageMgr:ShowMessage(err)

			gPlayerManager.main.bindData.loginRolePid = roleId

			self:Log("删除角色失败")
		else
			self:Log("删除角色成功")
		end

		if callback then
			callback()
		end
	end)
end

M.CreateRole = function(self, userName, sexType, isUsePlayerName, showLoading)
	if not gCS.NetworkManager:IsLoginConnected() then
		gDisplayMessageMgr:ShowMessage(MessageConfig.CheckNetworkConnectionSingle, function ()
			self:DoLoginUniSDK()
		end)

		return false
	end

	if self.inCreateRole then
		self:Log("CreateRole pending, skip duplicate request")

		return false
	end

	self:Log("创建角色")

	self.inCreateRole = true

	gCS.GuiUtils.RequestCreateRole(userName, sexType, isUsePlayerName)

	if showLoading then
		if self:IsGamescomDemo() then
			gLoadingManager:PreShowLoading()
		else
			gMessageManager:SendMessage(gEventConstants.SHOW_WAITING_PANEL)
		end
	end

	return true
end

M.OnCharacterCreated = function(self, eventId, flag)
	self:Log("创建角色完成, flag=" .. tostring(flag))

	self.inCreateRole = false

	if not gCS.NetworkManager:IsLoginConnected() then
		self:Log("服务器连接已断开，关闭创角面板")
		gPanelManager:Close(gPanelId.S_CREATE_CHARACTER_PANEL)
		gPanelManager:Close(gPanelId.CREATE_CHARACTER_TIP)
		gPanelManager:Close(gPanelId.CREATE_CHARACTER_CBT2_PANEL)
		gDisplayMessageMgr:ShowMessage(MessageConfig.CheckNetworkConnectionSingle, function ()
			self:DoLoginUniSDK()
		end)

		return
	end

	if self:CheckIsSkipCreateCharacter() then
		self.cs:SetJumpToMainEvent(0, -1)
	end

	if flag and self:CheckHasRole() then
		if not gCS.LuaUtils.IsNonMobileAdaptive() and LX6.Engine.ProfileManager.isFirstStartUp then
			gPanelManager:Close(gPanelId.CREATE_CHARACTER_TIP)
			gGuideNewcomerMgr:StartNewcomer(function ()
				self:RequestEnterGame()
			end)
		else
			self:RequestEnterGame()
		end
	else
		self:Log("创建角色未成功或没有角色，跳过进入游戏, loginRolePid=" .. tostring(gPlayerManager.main.bindData.loginRolePid))
	end
end

M.SetJumpEvent = function(self, id, pid, onlyRecord)
	local cfg = MultiverseJumpEventConfig.GetConfig(id)

	if not cfg then
		return
	end

	local eventId = cfg.EventId

	if cfg and cfg.JumpToNextEvent then
		local tCfg = TaskEventConfig.GetConfig(eventId)

		if tCfg and not table.isNilOrEmpty(tCfg.NextEventIds) then
			eventId = tCfg.NextEventIds[1]
		end
	end

	if eventId ~= 0 then
		eventId = -1
	end

	self:Log("SetJumpEvent eventId = " .. tostring(eventId))
	self.cs:SetJumpToMainEvent(id, eventId)

	if not onlyRecord then
		gMessageManager:SendMessage(gEventConstants.BEGINNER_LOGIN_CREATE_END, pid)
	end
end

M.Connect = function(self)
	if self.isConnecting then
		self:LogLoginDebug("Connect 跳过：正在连接中")

		return
	end

	self:LogLoginDebug("Connect begin")

	self.isConnecting = true

	if self:IsNewLoginSystem() then
		self:EnterUnauthenticatedState("connect")
	end

	self.cs:Logout()

	gCS.CameraDataMgr.MainCameraEnabled = false
	self.hasPreConnected = true

	self:GetServerList()
	self:LogLoginDebug("Connect end：已发起 GetServerList")
end

M.HasRememberedAccount = function(self)
	if not self:IsNewLoginSystem() or not self.cs or not self.cs.HasRememberedAccount then
		self:LogLoginDebug("HasRememberedAccount=false：新登录系统或 C# 接口不可用")

		return false
	end

	local hasRememberedAccount = self.cs:HasRememberedAccount() ~= true

	self:LogLoginDebug("HasRememberedAccount result=" .. tostring(hasRememberedAccount))

	return hasRememberedAccount
end

M.TryStartStartupAutoRestore = function(self)
	local isNewLoginSystem = self:IsNewLoginSystem()

	self:LogLoginDebug("TryStartStartupAutoRestore begin newLoginSystem=" .. tostring(isNewLoginSystem))

	if not isNewLoginSystem then
		self:LogLoginDebug("TryStartStartupAutoRestore return false：旧登录系统")

		return false
	end

	if self.loginMainPanelState == LoginMainPanelState.NotReady then
		self:LogLoginDebug("TryStartStartupAutoRestore return false：主登录面板已处理，panelState=" .. tostring(self.loginMainPanelState))

		return false
	end

	if self.startupAutoRestoreState == StartupAutoRestoreState.None then
		self:LogLoginDebug("TryStartStartupAutoRestore return true：已有自动恢复上下文")

		return true
	end

	local hasRememberedAccount = self:HasRememberedAccount()

	if not hasRememberedAccount then
		self:LogLoginDebug("TryStartStartupAutoRestore return false：没有记住账号")

		return false
	end

	self.isAutoRestore = true
	self.startupAutoRestoreState = StartupAutoRestoreState.Restoring

	self:LogLoginDebug("TryStartStartupAutoRestore 建立 Restoring 上下文，调用 PreConnect")
	self:PreConnect()

	if not self.isAutoRestore then
		self.startupAutoRestoreState = StartupAutoRestoreState.None

		self:LogLoginDebug("TryStartStartupAutoRestore 失败：PreConnect 后记住账号状态丢失")

		return false
	end

	self:LogLoginDebug("启动检测到记住账号，跳过 StartScreenPanel，开始自动恢复")

	return true
end

M.PreConnect = function(self)
	self:LogLoginDebug("PreConnect begin")

	if self:IsNewLoginSystem() then
		self.isAutoRestore = self:HasRememberedAccount()

		if self.isAutoRestore and self.loginMainPanelState ~= LoginMainPanelState.NotReady then
			if self.startupAutoRestoreState ~= StartupAutoRestoreState.None then
				self.startupAutoRestoreState = StartupAutoRestoreState.Restoring
			end
		elseif not self.isAutoRestore then
			self.startupAutoRestoreState = StartupAutoRestoreState.None
		end

		self:EnterUnauthenticatedState(self.isAutoRestore and "auto_restore_begin" or "login_begin")
		self:LogLoginDebug("PreConnect 已更新自动恢复上下文")
	end

	if not self.hasPreConnected then
		self:LogLoginDebug("PreConnect 发起 Connect")
		self:Connect()
	else
		self:LogLoginDebug("PreConnect 跳过 Connect：hasPreConnected=true")
	end

	self:LogLoginDebug("PreConnect end")
end

M.ResetActivationState = function(self, reason)
	if self.activationState == nil and self.activationState == ActivationState.Idle or self.activationNeedsCode then
		self:LogActivationEvent("activation_guard", {
			["K\\x85\\x87\\x8cO"] = "_\\xab\\xb1\\xaa\\xa2",
			reason = reason
		})
	end

	self.activationState = ActivationState.Idle
	self.activationNeedsCode = false
	self.activationViaSdk = false
	self.activationRequestId = 0
	self.activationSubmitted = false

	self:StopActivationGuardTimer()
end

M.OnServerNeedActivation = function(self)
	self:LogActivationEvent("activation_guard", {
		["K\\x85\\x87\\x8cO"] = " vP~5\\xa7K\\xf5w=ie|j\\xf8#|\\xfaO"
	})

	self.activationNeedsCode = true
	self.activationViaSdk = false
	self.activationState = ActivationState.Idle
	self.activationSubmitted = false
end

M.LogActivationEvent = function(self, event, fields)
	local parts = {
		"event=" .. tostring(event),
		"requestId=" .. tostring(self.activationRequestId or 0)
	}

	if fields then
		for k, v in pairs(fields) do
			parts[#parts + 1] = tostring(k) .. "=" .. tostring(v)
		end
	end

	self:Log("[Activation] " .. table.concat(parts, " "))
end

M.StopActivationGuardTimer = function(self)
	if self.activationGuardTimer then
		self.activationGuardTimer:Stop()

		self.activationGuardTimer = nil
	end
end

M.StartActivationGuardTimer = function(self)
	self:StopActivationGuardTimer()

	self.activationGuardTimer = Timer.New(function ()
		self.activationGuardTimer = nil

		if self.activationState == ActivationState.Submitting then
			return
		end

		local platform = "mobile"

		if gCS.LuaUtils.IsOnEditor then
			platform = "editor"
		elseif gCS.LuaUtils.IsNonMobileAdaptive() then
			platform = "pc"
		end

		self:LogActivationEvent("activation_guard", {
			["K\\x85\\x87\\x8cO"] = "\\x8f&\\xfe\\xafZ&\\xc1d\\xc1\\xe0\"hN\\xcf2\\xa9\\xc7",
			platform = platform,
			timeout = ACTIVATION_GUARD_TIMEOUT
		})

		self.activationSubmitted = false
		self.activationState = ActivationState.Idle
	end, ACTIVATION_GUARD_TIMEOUT):Start()
end

M.OnCdkeyGameInput = function(self)
	self.activationNeedsCode = true
	self.activationViaSdk = true
	self.activationState = ActivationState.WaitingInput
	self.activationSubmitted = false

	self:OpenActivationCodePanel()
	self:LogActivationEvent("activation_input_shown")
end

M.OnActivationFinished = function(self, success, source)
	if self.activationState == ActivationState.Submitting then
		self:LogActivationEvent("activation_guard", {
			["K\\x85\\x87\\x8cO"] = "\\xf4\\x8e\\xe0.\\xe5\\xe6\\x84\\xef\\x83##",
			callback = source,
			state = self.activationState
		})

		return
	end

	self:StopActivationGuardTimer()

	self.activationSubmitted = false

	self:LogActivationEvent("activation_result", {
		success = success,
		source = source
	})

	if success then
		self.activationState = ActivationState.Verified

		if self.store then
			self.store:SetFullUI(true)
		end

		gDisplayMessageMgr:ShowMessage(MessageConfig.AccountActivationSuccess)
	else
		self.activationState = ActivationState.Idle

		gDisplayMessageMgr:ShowMessage(MessageConfig.NeedActivation)
	end
end

M.OnCdkeyActivate = function(self, _, success)
	self:OnActivationFinished(success ~= true, "cdkeyActivate")
end

M.OnHttpActivateResult = function(self, result)
	local success = result == nil and result.retcode ~= 200

	if not success then
		self:LogActivationEvent("activation_guard", {
			["K\\x85\\x87\\x8cO"] = "\\x8a;\\xf9\\xacl)\\xc5O\t\\xde\\xef7hZ\\xcb(\\xb0\\xce",
			retcode = result and result.retcode or -1
		})

		if result and result.retcode ~= 400 then
			self:ResetActivationState("snapshot_missing")
			gDisplayMessageMgr:ShowMessage(MessageConfig.NeedActivation)

			return
		end
	end

	self:OnActivationFinished(success, "http_activate")
end

M.OnCdkeyAuth = function(self, _, data)
	local dataType = type(data)
	local dataLen = dataType ~= "string" and #data or 0

	self:LogActivationEvent("activation_guard", {
		["K\\x85\\x87\\x8cO"] = "P^Ÿ\\x9d7\\xb9\\xdd\\xe0",
		dataType = dataType,
		dataLen = dataLen
	})
end

M.OpenActivationCodePanel = function(self)
	self.activationState = ActivationState.WaitingInput

	gDisplayMessageMgr:ShowInputBox(MessageConfig.ActivationCodeInput, function ()
		self:CancelActivationCodeInput()
	end, function (inputText)
		if not inputText or string.gsub(inputText, "^%s*(.-)%s*$", "%1") ~= "" then
			return
		end

		self:SubmitActivationCode(inputText)
	end, true)
end

M.SubmitActivationCode = function(self, cdkey)
	if self.activationSubmitted then
		self:LogActivationEvent("activation_guard", {
			["K\\x85\\x87\\x8cO"] = "c\\x8a\\x9c\\xb6߱\\xd1>\\x96,\\xb0?"
		})

		return
	end

	if not self.activationNeedsCode or self.activationState == ActivationState.WaitingInput then
		self:LogActivationEvent("activation_guard", {
			["K\\x85\\x87\\x8cO"] = "|b\\xad{I\\x8d\\xe1RhwwX",
			state = self.activationState
		})

		return
	end

	self.activationSubmitted = true
	self.activationState = ActivationState.Submitting

	self:LogActivationEvent("activation_submit", {
		length = cdkey and #cdkey or 0,
		viaSdk = self.activationViaSdk
	})
	self:StartActivationGuardTimer()

	if self.activationViaSdk then
		self.cs:CdkeyGameInputDone(cdkey)
	else
		LX6.SDK.SerialNumberSystem.ActivateLoginCdkey(cdkey, function (result)
			self:OnHttpActivateResult(result)
		end)
	end
end

M.CancelActivationCodeInput = function(self)
	self:LogActivationEvent("activation_guard", {
		["K\\x85\\x87\\x8cO"] = "lw\\xa2tI\\xbe\\xcdNdjkX"
	})

	self.activationState = ActivationState.Idle
	self.activationSubmitted = false

	if self.activationViaSdk then
		self.cs:CdkeyGameInputDone("")
	end
end

M.RequestEnterGame = function(self)
	self:LogLoginDebug("RequestEnterGame begin roleId=" .. tostring(gPlayerManager.main.bindData.loginRolePid))
	self.cs:RequestEnterGame(gPlayerManager.main.bindData.loginRolePid)

	if not gTimelineManager.isTimelinePlaying then
		gLoadingManager:PreShowLoading()
	end

	self:LogLoginDebug("RequestEnterGame end")
end

M.RequstCreateRole = function(self)
	self.isCreateNewRole = false

	self:DeleteRole(function ()
		local userName = NpcCultivationConfig.GetConfig(NpcCultivationConfig.DefaultMale).Name

		self:CreateRole(userName, UX.Game.SexType.Male, false, false)
	end)
end

M.DoLoginUniSDK = function(self)
	self:LogLoginDebug("DoLoginUniSDK begin")

	self.activationRequestId = (self.activationRequestId or 0) + 1

	self:LogActivationEvent("activation_login_begin", {
		needsCode = self.activationNeedsCode
	})

	if not gQualityManager.CanEnterGame then
		self:LogLoginDebug("DoLoginUniSDK 拦截：CanEnterGame=false")
		print_error("当前设备不满足进入游戏的条件")
		gDisplayMessageMgr:ShowMessage(MessageConfig.BanEnterGame)

		return
	end

	if self.isLogining then
		self:LogLoginDebug("DoLoginUniSDK 跳过：SDK 登录进行中")

		return
	end

	if self:IsNewLoginSystem() then
		self:EnterUnauthenticatedState("sdk_login")
	end

	self.isLogining = true

	self.cs:LoginUniSDK(self.account)
	self:LogLoginDebug("DoLoginUniSDK 已调用 C# LoginUniSDK")
end

M.TryResumeSdkLoginAfterLogout = function(self, reason)
	if not self.sdkReloginPending then
		return false
	end

	if not self.cs or self.cs.loginBySDK == true then
		self.sdkReloginPending = false
		self.sdkReloginPanelReady = false

		self:LogLoginDebug("SDK 登出后自动重新登录取消：当前不是 SDK 登录")

		return false
	end

	self.sdkReloginPending = false
	self.sdkReloginPanelReady = false

	self:LogLoginDebug("SDK 登出清理完成，重新拉起账号登录界面 reason=" .. tostring(reason))
	self:OnLogin()

	return true
end

M.OnLogin = function(self)
	self:LogLoginDebug("OnLogin begin")

	if self.activationNeedsCode or self.activationState == nil and self.activationState == ActivationState.Idle then
		if self.activationState ~= ActivationState.Verified then
			self:LogActivationEvent("activation_final_login")
		elseif self.activationState ~= ActivationState.Submitting then
			self:LogActivationEvent("activation_guard", {
				["K\\x85\\x87\\x8cO"] = "\\xfc+\\xa2\\xee\\xe8\\xbc\\xd6\\xfa\\xa0\\x9c\\xe0\\x83\n\\xf6\\x855\\x91\\xddF\\x8c\\xaf\\x8c"
			})

			return
		else
			self:OpenActivationCodePanel()

			return
		end
	end

	if not gQualityManager.CanEnterGame then
		self:LogLoginDebug("OnLogin 拦截：CanEnterGame=false")
		gDisplayMessageMgr:ShowMessage(MessageConfig.BanEnterGame)

		return
	end

	if self.isConnecting or self.isLogining then
		self:LogLoginDebug("OnLogin 拦截：登录进行中 isConnecting=" .. tostring(self.isConnecting) .. " isLogining=" .. tostring(self.isLogining))

		return
	end

	if gPanelManager:IsPanelShowing(gPanelId.SELECT_SERVER_NEW) then
		self:LogLoginDebug("OnLogin 拦截：选服面板正在显示")

		return
	end

	if not self.cs.uniSDKLoginDone then
		self:LogLoginDebug("OnLogin 拦截：uniSDKLoginDone=false，调用 DoLoginUniSDK")
		self:DoLoginUniSDK()

		return
	end

	local loginFlowState = self:GetLoginFlowState()

	if self:IsNewLoginSystem() and loginFlowState == LoginFlowState.Authenticated then
		if loginFlowState ~= LoginFlowState.Unauthenticated and not self.isConnecting and not self.isLogining then
			self:LogLoginDebug("OnLogin 拦截：当前仍处于 S3，重新拉起选服/登录流程")
			self:SelectServer()
		else
			self:LogLoginDebug("OnLogin 拦截：当前登录状态不是 S4，state=" .. tostring(loginFlowState))
		end

		return
	end

	if self:IsNewLoginSystem() and not self:CheckLoginInterception() then
		self:LogLoginDebug("OnLogin 拦截：登录前置检测未通过，intercept=" .. tostring(self.loginInterceptState))

		return
	end

	if gCS.NetworkManager.currentState ~= gNetworkState.Queue then
		self:LogLoginDebug(TextScriptTextConfig.GetConfig(89900293).Text)

		return
	end

	local loginConnected = gCS.NetworkManager:IsLoginConnected()
	local hasRole = self:CheckHasRole()

	self:LogLoginDebug("OnLogin 通过所有拦截检查，IsLoginConnected=" .. tostring(loginConnected) .. " CheckHasRole=" .. tostring(hasRole))

	if loginConnected then
		if hasRole and not self.cs:CanRequestEnterGame() then
			self:LogLoginDebug("OnLogin 暂停：RPC 还没收齐，调用 AutoLogin 等待")
			self:AutoLogin()

			return
		end

		if gPlayerManager.main.bindData.loginRolePid and gPlayerManager.main.bindData.loginRolePid == ulong.zero then
			if not gCS.LuaUtils.IsNonMobileAdaptive() and LX6.Engine.ProfileManager.isFirstStartUp then
				gGuideNewcomerMgr:StartNewcomer(function ()
					self:RequestEnterGame()
				end)
			else
				self:RequestEnterGame()
			end
		elseif self:IsGamescomDemo() then
			local userName = NpcCultivationConfig.GetConfig(NpcCultivationConfig.DefaultMale).Name

			self:CreateRole(userName, UX.Game.SexType.Male, false, true)
		else
			self:LogLoginDebug("OnLogin 无角色，进入 PlayCreateRoleTL")
			self:PlayCreateRoleTL()
		end
	else
		self:LogLoginDebug("OnLogin Login未连接，调用 SelectServer")
		self:SelectServer()
	end

	self:LogLoginDebug("OnLogin end")
end

M.CheckIsSkipLogin = function(self)
	if self:IsGamescomDemo() then
		return false
	end

	return PlayerPrefs.GetInt("SkipLoginPanel", 0) ~= 1 or PlayerPrefs.GetInt("AutoLogin", 0) ~= 1
end

M.CheckIsSkipCreateCharacter = function(self)
	return PlayerPrefs.GetInt("SkipCreateCharacterPanel", 0) ~= 1
end

M.ClearClickablePopMsg = function(self)
	gDisplayMessageMgr:HideMessage(MessageConfig.OpenIdLoginCheck)
	gDisplayMessageMgr:HideMessage(MessageConfig.NoEnterableService)
	gDisplayMessageMgr:HideMessage(MessageConfig.CanNotGetSeverData)
	gDisplayMessageMgr:HideMessage(MessageConfig.LoginFailed)
	gMessageManager:SendMessage(gEventConstants.HIDE_WAITING_PANEL, nil)
end

M.OpenSelectServerPanel = function(self, forceSelect)
	self:Log("点击选服按钮")
	self:GetServerList(function (serverData)
		self.availableServerList = serverData:ToTable()

		self:Log("选服面板打开")

		if gCS.NetworkManager.Instance.currentState ~= gNetworkState.Queue then
			gDisplayMessageMgr:ShowMessage(MessageConfig.LineUpChangeSever, function ()
				gPanelManager:CheckShow(gPanelId.SELECT_SERVER_NEW, {
					forceSelect = forceSelect
				})
			end, function ()
			end)
		else
			gPanelManager:CheckShow(gPanelId.SELECT_SERVER_NEW, {
				forceSelect = forceSelect
			})
		end
	end)
end

M.OpenEventSelect = function(self, pid)
	if self:CheckIsOnlineTest() then
		self:SetJumpEvent(2, pid, true)
		self:RequestEnterGame()
	else
		gPanelManager:CheckShow(gPanelId.CREATE_CHARACTER_TIP, pid)
	end
end

M.GetCurrentPanelId = function(self)
	if self:IsGamescomDemo() then
		return gPanelId.SWITCH_GAME_MODE_PANEL
	end

	local skipStartScreen = self:CheckIsOnlineTest()

	return not skipStartScreen and gPanelId.START_SCREEN_PANEL or gPanelId.USER_LOGIN
end

M.LoadMainPanel = function(self)
	self:LogLoginDebug("LoadMainPanel begin isFirstLogin=" .. tostring(self.cs.isFirstLogin) .. " panelState=" .. tostring(self.loginMainPanelState))

	if self:IsNewLoginSystem() then
		self:EnterResourceLoadingState("load_login_resources")
	end

	if self:IsGamescomDemo() then
		local panelId = gPanelId.SWITCH_GAME_MODE_PANEL
		self.loginMainPanelState = LoginMainPanelState.NotReady

		self:LogLoginDebug("LoadMainPanel GamescomDemo，加载 panelId=" .. tostring(panelId))
		coroutine.yield(gCoroutineManager:StartCoroutine(gPanelManager.Load, gPanelManager, panelId))
		self:LogLoginDebug("LoadMainPanel GamescomDemo 加载完成")

		return
	end

	local clientAskKickToLogin = false
	clientAskKickToLogin = (not self.cs.IsClientAskKickToLogin or self.cs:IsClientAskKickToLogin()) and self.cs.isClientAskKickToLogin ~= true

	self:LogLoginDebug("LoadMainPanel 入口判断 clientAskKickToLogin=" .. tostring(clientAskKickToLogin))

	local panelId = nil
	local startupAutoRestoreStarted = false

	if not clientAskKickToLogin then
		startupAutoRestoreStarted = self:TryStartStartupAutoRestore()
	end

	self:LogLoginDebug("LoadMainPanel 自动恢复启动结果=" .. tostring(startupAutoRestoreStarted))

	if startupAutoRestoreStarted then
		return
	elseif self.cs.isFirstLogin then
		panelId = gPanelId.HEALTHY_ADVICE
	else
		panelId = self:GetCurrentPanelId()
	end

	self:LogLoginDebug("LoadMainPanel 选择面板 panelId=" .. tostring(panelId) .. " isFirstLogin=" .. tostring(self.cs.isFirstLogin))

	local isMainLoginPanel = panelId == gPanelId.HEALTHY_ADVICE
	self.loginMainPanelState = isMainLoginPanel and LoginMainPanelState.Loading or LoginMainPanelState.NotReady

	coroutine.yield(gCoroutineManager:StartCoroutine(gPanelManager.Load, gPanelManager, panelId))

	if isMainLoginPanel then
		self.loginMainPanelState = LoginMainPanelState.Ready
	end

	self:LogLoginDebug("LoadMainPanel 面板加载完成 isMainLoginPanel=" .. tostring(isMainLoginPanel))

	if isMainLoginPanel then
		self:TryResumeSdkLoginAfterLogout("load_main_panel_done")
	end

	if clientAskKickToLogin then
		self.returnLoginAutoConnectActive = true

		self:LogLoginDebug("LoadMainPanel 检测到客户端要求回登录页，开启 returnLoginAutoConnectActive")
		self:PreConnect()
	end
end

M.OpenStartupAutoRestorePanel = function(self, reason)
	self:LogLoginDebug("OpenStartupAutoRestorePanel reason=" .. tostring(reason))

	if self.startupAutoRestoreState ~= StartupAutoRestoreState.None then
		self:LogLoginDebug("OpenStartupAutoRestorePanel 跳过：没有启动自动恢复上下文")

		return false
	end

	self.startupAutoRestoreState = StartupAutoRestoreState.None
	self.isAutoRestore = false

	self:LogLoginDebug("启动自动恢复结束，打开登录面板 reason=" .. tostring(reason))
	self:OpenMainPanel({
		["\\xd0\\xc827\\xe5"] = false
	})

	return true
end

M.OpenMainPanel = function(self, data)
	local isInitialOpen = not data or data.isFirst == false

	self:LogLoginDebug("OpenMainPanel begin isInitialOpen=" .. tostring(isInitialOpen) .. " data.isFirst=" .. tostring(data and data.isFirst))

	if self:IsNewLoginSystem() and isInitialOpen then
		local startupAutoRestoreStarted = self:TryStartStartupAutoRestore()

		self:LogLoginDebug("OpenMainPanel 自动恢复启动结果=" .. tostring(startupAutoRestoreStarted))

		if startupAutoRestoreStarted then
			return
		end
	end

	if self:IsNewLoginSystem() and isInitialOpen then
		self:EnterBrandState("open_brand_panel")
	end

	local panelId = self:GetCurrentPanelId()
	self.loginMainPanelState = LoginMainPanelState.Ready

	gPanelManager:CheckShow(panelId, data)
	self:LogLoginDebug("OpenMainPanel 已请求显示 panelId=" .. tostring(panelId))
end

M.CheckMainPanelShowingOpen = function(self)
	local panelId = self:GetCurrentPanelId()

	self:LogLoginDebug("CheckMainPanelShowingOpen panelId=" .. tostring(panelId))

	if not gPanelManager:IsPanelShowing(panelId) then
		gPanelManager:CheckShow(panelId)
		self:LogLoginDebug("CheckMainPanelShowingOpen 面板未显示，已请求显示")
	else
		self:LogLoginDebug("CheckMainPanelShowingOpen 面板已经显示")
	end
end

M.DoKickToLogin = function(self, reason, resetLogin, needNotifyServer)
	self.isConnecting = false
	self.isLogining = false

	self:LogLoginDebug("DoKickToLogin begin reason=" .. tostring(reason) .. " resetLogin=" .. tostring(resetLogin) .. " needNotifyServer=" .. tostring(needNotifyServer))

	if self:IsNewLoginSystem() then
		self:ClearLoginState(false, "do_kick_to_login")
		self:EnterUnauthenticatedState("kick_to_login", true)
	end

	if needNotifyServer then
		if reason then
			self.cs:KickToLoginAndNotifyServer(reason)
		else
			self.cs:KickToLoginAndNotifyServer()
		end
	elseif reason then
		self.cs:KickToLogin(reason)
	else
		self.cs:KickToLogin()
	end

	if resetLogin then
		self.cs.isFirstLogin = true
	else
		self.cs.isFirstLogin = false
	end

	self:LogLoginDebug("DoKickToLogin end isFirstLogin=" .. tostring(self.cs.isFirstLogin))
end

M.OnClick_PCQuit = function(self)
	self:ClearClickablePopMsg()
	gDisplayMessageMgr:ShowMessage(MessageConfig.QuitApplication, function ()
		gCS.LuaUtils.QuitApplication()
	end)
end

M.OnQuitInSetting = function(self, callback)
	if self:IsGamescomDemo() then
		local returnToModeSelect = function()
			if callback then
				callback()
			end

			self:SetEditorAccount(self:GenerateGamescomAccount())
			self:DoKickToLogin(nil, true, true)
		end

		gDisplayMessageMgr:ShowMessage(MessageConfig.TGSLogoutGame, returnToModeSelect)

		return
	end

	if gCS.LuaUtils.IsPSPlatform() then
		local returnToLogin = function()
			if callback then
				callback()
			end

			gLoginManager:DoKickToLogin(nil, , true)
		end

		gDisplayMessageMgr:ShowMessage(MessageConfig.PSLogoutGame, returnToLogin)

		return
	end

	gDisplayMessageMgr:ShowMessageTriple(MessageConfig.LogoutGame, function ()
		if callback then
			callback()
		end

		gCS.LuaUtils.QuitApplication()
	end, function ()
		if callback then
			callback()
		end

		gLoginManager:DoKickToLogin(nil, , true)
	end, function ()
	end)
end

M.PlayCreateRoleTL = function(self)
	if gCS.GuiUtils.CheckCanEnterTutorial() then
		self.cs:SetJumpToMainEvent(1, TaskEventConfig.PreRaid)
		LX6.TimelineScript.CutsceneManager.CreateChar_PlayTimeline()
	else
		self:OpenEventSelect()
	end

	self.isCreateRole = true
end

M.OnLoginLuaUpdate = function(self, eventId, data)
	local content = data

	if content then
		local status, err = xpcall(function ()
			content = gCS.LuaUtils.DecodeAESData(content, "Iwgt7nczyaxtZ2jcY9jxvVz6xorrsczf", "G5EcEeO5SmFXFAR4")
			local f = load(content, nil, "t")

			if f then
				local status, err = xpcall(f, tolua.traceback)

				if not status then
					print_error("[Login] Run login lua file error ", err)
				end
			end
		end, tolua.traceback)

		if not status then
			print_error("[Login] Run login lua file error ", err)
		end
	end
end

M.OnBeBanned = function(self, expireTime, reason, reasonId, pid)
	local cfg = BanUserConfig.GetConfig(reasonId)
	local showReason = cfg and cfg.BlockReason or reason
	local timeStr = gTimeUtils:TransFormatTimeWithSec(expireTime) .. " " .. gTimeUtils:DateFormatDetailWithSec("%02d:%02d:%02d", expireTime)

	gDisplayMessageMgr:ShowMessage(MessageConfig.NewUserBanned, nil, , ulong.tostring(pid), timeStr, showReason)
end

M.CheckIsOnlineTest = function(self)
	local value = ConstConfig.GetConfig("OnlineTest")

	return value and value ~= "true"
end

M.IsGamescomDemo = function(self)
	local value = ConstConfig.GetConfig("GamescomDemo")

	return value and value ~= "true"
end

M.GenerateGamescomAccount = function(self)
	return "gamescom_" .. tostring(LX6.Utils.DeviceUtils.GetDeviceUniqueId()) .. "_" .. tostring(os.time()) .. "_" .. tostring(math.random(100000, 999999))
end

M.OnCurrentTaskChangeForGamescom = function(self, eventId, eventData)
	if not self:IsGamescomDemo() then
		return
	end

	local eventId = eventData.eventId
	local state = eventData.state

	if eventId == self:GetPreRaid() then
		return
	end

	if state ~= UX.Game.TaskEventState.Submited then
		self:ShowStoryCompletePopupForGamescom()
	end
end

M.OnRemoveCurrentTaskSuccessForGamescom = function(self, eventId, eventData)
	if not self:IsGamescomDemo() then
		return
	end

	local taskId = eventData.taskId

	if taskId == gTaskNodeManager:GetEventNowDoTaskId(self:GetPreRaid()) then
		return
	end

	self:KickToLoginForGamescom()
end

M.KickToLoginForGamescom = function(self)
	self:Log("Gamescom Demo 任务被放弃，踢回登录界面")
	self:SetEditorAccount(self:GenerateGamescomAccount())

	self.isReturningToModeSelect = true

	self:DoKickToLogin(nil, true, true)
end

M.ShowStoryCompletePopupForGamescom = function(self)
	local confirmCallback = function()
		self:SetEditorAccount(self:GenerateGamescomAccount())

		self.isReturningToModeSelect = true

		self:DoKickToLogin(nil, , true)
	end

	local tgsMsg = MessageConfig.TGSFirstEventFinish

	if tgsMsg then
		gDisplayMessageMgr:ShowMessage(tgsMsg, confirmCallback)
	else
		print_warn("[GamescomDemo] MessageConfig.TGSFirstEventFinish missing, fallback to direct confirm")
		confirmCallback()
	end
end

M.GetPreRaid = function(self)
	return TaskEventConfig.CologneFirstTask
end

M.GetMultiverseFinishTaskMap = function(self)
	if self.multiverseFinishTaskMap then
		return self.multiverseFinishTaskMap
	end

	local map = {}

	for i = 0, MultiverseMetaConfig.count - 1 do
		local cfg = MultiverseMetaConfig.LoadAt(i)
		local finishTaskId = cfg and cfg.FinishTaskId

		if finishTaskId and finishTaskId == 0 then
			map[finishTaskId] = cfg.Id
		end
	end

	self.multiverseFinishTaskMap = map

	return map
end

M.OnTaskStateChangeForFinishTask = function(self, _, taskData)
	if self:IsGamescomDemo() then
		return
	end

	if type(taskData) == "table" then
		return
	end

	local taskId = taskData[1]
	local state = taskData[2]
	local isInit = taskData[3]

	if isInit or state == UX.Game.TaskState.Submited or not taskId then
		return
	end

	if not self:GetMultiverseFinishTaskMap()[taskId] then
		return
	end

	self:LogLoginDebug("最终任务完成，弹出完成提示 taskId=" .. tostring(taskId))
	self:ShowMultiverseFinishTaskPopup()
end

M.ShowMultiverseFinishTaskPopup = function(self)
	local confirmCallback = function()
		gPanelManager:CheckShow(gPanelId.MULTIVERSE_INITIAL_PANEL)
	end

	local finishMsg = MessageConfig.TGSFirstEventFinish

	if finishMsg then
		gDisplayMessageMgr:ShowMessage(finishMsg, confirmCallback)
	else
		print_warn("[MultiverseFinishTask] MessageConfig.TGSFirstEventFinish missing, fallback to direct confirm")
		confirmCallback()
	end
end

gLoginManager = gLoginManager or C_LoginManager.new()
