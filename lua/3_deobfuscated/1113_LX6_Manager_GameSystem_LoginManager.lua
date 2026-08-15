local MessageConfig = LTConfig.MessageConfig
local MessageExplainConfig = LTConfig.MessageExplainConfig
local SerializeRegister = UX.Game.Client.SerializeRegister.Instance
local PatchPackageMgr = LX6.Engine.Patch.PatchPackageMgr.Instance
local PlayerPrefs = UnityEngine.PlayerPrefs
local NpcCultivationConfig = LTConfig.NpcCultivationConfig
local TextScriptTextConfig = LTConfig.TextScriptTextConfig
local BanUserConfig = LTConfig.BanUserConfig
local StaticProps = {}
C_LoginManager = DefClass("C_LoginManager", C_LoginManager, nil, StaticProps)
local M = C_LoginManager
local LOGIN_PATCH_FILE = "Login.bin"
local GET_SERVERINFO_LIMIT = 3

function M:ctor()
	self._MsgEvents = {}
	self.cs = gCS.LoginManager
end

function M:RegisterSingleEvent(enentId, func)
	self._MsgEvents[#self._MsgEvents + 1] = {
		eventid = enentId,
		func = func
	}

	gMessageManager:AddMessageListener(enentId, func)
end

function M:RegisterMessageEvents(eventHandlers)
	for k, v in pairs(eventHandlers) do
		self:RegisterSingleEvent(k, v)
	end
end

function M:ClearMessageEvents()
	for i, v in pairs(self._MsgEvents) do
		gMessageManager:RemoveMessageListener(v.eventid, v.func)
	end

	table.clear(self._MsgEvents)
end

function M:OnInit()
	self.availableServerList = {}
	self.myMD5 = nil
	self.codeVersion = 0
	self.artifactVersion = 0
	self.branchName = nil
	self.versionTag = ""
	self.getServerInfoCount = 0
	self.reconnectCo = nil
	self.isServerOutOfVersion = true
	self.account = ""
	self.editorAccount = ""
	self.isCreateNewRole = self:CheckIsTgsPack()
	self.afterCreateRole = {}

	self:ReadPlayerPrefs()
	self:ResetServerInfo()

	self.store = gStoreManager:GetStoreGroup("LoginPanelStore")

	if self:CheckIsTgsPack() then
		self.store = gStoreManager:GetStoreGroup("SwitchGameModePanelStore")
	end

	self:CheckLoginLuaPatch()
	self:SetCodeVersion()

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
		[gEventConstants.BEFORE_SWITCH_SCENE] = self:CreateAction(self.OnBeforeSwitchScene),
		[gEventConstants.UNISDK_ON_LOGOUT_DONE] = self:CreateAction(self.OnSdkLogoutDone)
	}

	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnBeforeSwitchScene(eventId, switchType)
	if switchType == gSwitchSceneType.KickToLogin then
		self.isCreateNewRole = self:CheckIsTgsPack()
	end
end

function M:OnUpdate()
	self:OnUpdate_CheckNet()
end

function M:OnEndQueue()
	self:Log("排队完成")
	self.store:SetFullUI(true)
	gDisplayMessageMgr:ShowMessage(MessageConfig.LineUpFinishTitle, function ()
		self:OnLogin()
	end)
end

function M:OnStartQueue()
	self.store:SetFullUI(false)
end

function M:OnLoginServerSuccess()
	if gCS.NetworkManager.currentState == gNetworkState.Queue then
		if not gCS.LuaUtils.IsPublish then
			gDisplayMessageMgr:ShowMessageContent(gString.Format("服务器连接完成，进入排队状态"))
		end

		self:Log("Login服务器连接完成，进入排队状态")
	else
		self:Log("Login服务器连接完成")
		self:SaveEditorAccount()

		if self:CheckIsSkipCreateCharacter() and self.isCreateNewRole then
			self:RequstCreateRole()
		end
	end

	self.store:SetFullUI(true)
end

function M:OnSelectetServerDone(eventId, flag)
	if flag then
		self:DoLoginUniSDK()
	end
end

function M:OnChangeServer(serverData)
	self.loginUrl = serverData.LoginListUrl
	self.serverId = serverData.Id
	self.serverName = serverData.Name
	self.loginServerId = serverData.Id
	self.serverStatus = serverData.Status
	self.isCreateNewRole = self:CheckIsTgsPack()

	self.store:OnChangeServer(serverData)

	if serverData.Id then
		self:SelectServer()
	else
		self:Error("OnChangeServer serverData.Id is nil")
	end
end

function M:OnLoginServerFailed()
	self:Log(gString.Format("Login服务器 %s 连接失败", self.serverName))
	self:ClearClickablePopMsg()

	if self.cs.canSelectServer then
		gDisplayMessageMgr:ShowMessage(MessageConfig.LoginErrorWithOtherServer, function ()
			self:OpenSelectServerPanel(true)
		end)
	elseif self.serverStatus <= 0 then
		gDisplayMessageMgr:ShowMessage(MessageConfig.LoginMaintain, function ()
			self:SelectServer()
		end)
	else
		gDisplayMessageMgr:ShowMessage(MessageConfig.LoginFailed, function ()
			return
		end)
	end

	self.store:SetFullUI(true)
end

function M:OnSdkLogoutDone()
	if not gCS.LuaUtils.IsOnEditor or self.cs.loginBySDK then
		return
	end

	self:SetEditorAccount("")
end

function M:GetServerListDone(eventId, serverInfo)
	if not self:RetryServerInfo(serverInfo) then
		self.store:SetFullUI(true)

		return
	end

	if not self:FilterServer(serverInfo) then
		self.store:SetFullUI(true)

		return
	end

	self:MatchServer()
end

function M:GetServerListFailed()
	self:ClearClickablePopMsg()
	gDisplayMessageMgr:ShowMessage(MessageConfig.CanNotGetSeverData, function ()
		self:GetServerList()
	end, function ()
		gCS.LuaUtils.QuitApplication()
	end)
	self.store:SetFullUI(true)
end

function M:BackToLogin()
	if self:CheckIsTgsPack() then
		gPanelManager:CheckShow(gPanelId.SWITCH_GAME_MODE_PANEL, {
			isFirst = false
		})

		return
	end

	gPanelManager:CheckShow(gPanelId.USER_LOGIN, {
		isFirst = false,
		isInloginQueue = true
	})
end

function M:KickToLogin()
	if self:CheckIsTgsPack() then
		gPanelManager:CheckShow(gPanelId.SWITCH_GAME_MODE_PANEL, {
			isFirst = false
		})

		return
	end

	gPanelManager:CheckShow(gPanelId.USER_LOGIN, {
		isFirst = false,
		isKickToLogin = true
	})
end

function M:ResetServerInfo()
	self.loginUrl = ""
	self.serverId = 0
	self.serverName = ""
	self.serverStatus = 0
	self.loginServerId = 0
end

function M:SetCodeVersion()
	local versionStr = PatchPackageMgr:FetchVersionStr()
	self.artifactVersion = PatchPackageMgr:FetchArtifactVersion()
	self.branchName = PatchPackageMgr:FetchBranch()
	self.versionTag = PatchPackageMgr:FetchVersionTag()
	local info = string.split(versionStr, "_")

	if info and #info == 2 then
		local versionInfo = string.split(info[2], "%.")
		self.codeVersion = tonumber(versionInfo[1])
	end
end

function M:Log(content)
	self.cs.Log(gString.Format("[Lua LoginManager] %s", content))
end

function M:Error(content)
	self.cs.LogError(gString.Format("[Lua LoginManager] %s", content))
end

function M:CheckVersion(serverInfo)
	return not gCS.LuaUtils.IsPublish and serverInfo.Version == self.codeVersion
end

function M:CheckLoginLuaPatch()
	gCS.LuaUtils.GetHttpData(gCS.LuaUtils.GetAnnouncementUrl(), gEventConstants.LOGIN_LUA_FILE_UPDATE, LOGIN_PATCH_FILE)
end

local UPDATE_FRAQ = 30
local frameCount = 0
local isConnected = true

function M:OnUpdate_CheckNet()
	frameCount = frameCount + 1

	if UPDATE_FRAQ <= frameCount then
		self:CheckNetworkState()

		frameCount = 0
	end
end

function M:CheckNetworkState()
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

function M:GetServerList(callback)
	self.cs:DownloadServerList(callback)
end

function M:BuildServerMap()
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

		if serverName == "" then
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

function M:FilterServer(serverInfo)
	local dataTable = serverInfo:ToTable()
	self.availableServerList = {}
	self.myMD5 = SerializeRegister:Md5()

	for i = 1, #dataTable do
		if self.cs.ShowAllServers or (dataTable[i].RpcMd5 == nil or dataTable[i].RpcMd5 == self.myMD5) and (dataTable[i].Branch == nil or dataTable[i].Branch == self.branchName) and (dataTable[i].Tag == nil or dataTable[i].Tag == self.versionTag) and (dataTable[i].ArtifactVersion == 0 or self.artifactVersion == 0 or dataTable[i].ArtifactVersion == self.artifactVersion) then
			table.insert(self.availableServerList, dataTable[i])
		else
			self.reason = ""

			if dataTable[i].RpcMd5 and dataTable[i].RpcMd5 ~= self.myMD5 then
				self.reason = string.format("RPC版本不匹配 %s %s", dataTable[i].RpcMd5, self.myMD5)
			elseif dataTable[i].Branch and dataTable[i].Branch ~= self.branchName then
				self.reason = string.format("分支不匹配 %s %s", dataTable[i].Branch, self.branchName)
			elseif dataTable[i].Tag and dataTable[i].Tag ~= self.versionTag then
				self.reason = string.format("VersionTag不匹配 %s %s", dataTable[i].Tag, self.versionTag)
			else
				self.reason = string.format("Artifact版本不匹配 %d %d", dataTable[i].ArtifactVersion, self.artifactVersion)
			end

			if gGameManager.Env.isEditor then
				print_debug(dataTable[i].Name .. " " .. self.reason)
			end
		end
	end

	if #self.availableServerList == 0 then
		if not gCS.LuaUtils.IsPublish then
			self:Error("可用服务器数量为0，请尽快通知程序" .. tostring(self.myMD5))
		end

		self:ClearClickablePopMsg()
		gDisplayMessageMgr:ShowMessage(MessageConfig.NoEnterableService, function ()
			self:GetServerList()
		end)
		self.store:SetFullUI(true)

		return false
	end

	return true
end

function M:MatchServer()
	local uniAppChannel = UniSDKManager.AppChannel
	local channelServerList = {}

	for i = 1, #self.availableServerList do
		local d = self.availableServerList[i]
		local channelName = d.ChannelName

		if uniAppChannel and channelName ~= "*" and channelName == uniAppChannel then
			table.insert(channelServerList, d)
		end
	end

	if #channelServerList > 0 then
		self:OnChangeServer(channelServerList[1])
	else
		local targetList = {}

		for i = 1, #self.availableServerList do
			local d = self.availableServerList[i]
			local channelName = d.ChannelName

			if channelName == "*" then
				table.insert(targetList, d)
			end
		end

		if #targetList > 0 then
			local localServerName = LX6.GUI.Login.ServerData.GetLocalServerName()
			local targetIndex = 0

			if self.loginServerId == 0 then
				self.loginServerId = PlayerPrefs.GetInt("LastServerId")

				for i = 1, #targetList do
					if targetList[i].Id == self.loginServerId then
						targetIndex = i
					end

					if targetList[i].Name == localServerName then
						targetIndex = i

						break
					end
				end
			else
				for i = 1, #targetList do
					if targetList[i].Id == self.loginServerId then
						targetIndex = i

						break
					end

					if targetList[i].Name == localServerName then
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
				self.isServerOutOfVersion = targetData.RpcMd5 and targetData.RpcMd5 ~= self.myMD5 or targetData.Branch and targetData.Branch ~= self.branchName or targetData.Tag and targetData.Tag ~= self.versionTag or self.artifactVersion ~= 0 and targetData.ArtifactVersion ~= 0 and targetData.ArtifactVersion ~= self.artifactVersion

				self:OnChangeServer(targetData)
			else
				self.isServerOutOfVersion = true
			end
		else
			self:Error("可用服务器数量为0")
		end
	end

	self.availableServerList = {}
end

function M:RetryServerInfo(serverInfo)
	if serverInfo == nil then
		if self.getServerInfoCount < GET_SERVERINFO_LIMIT then
			self.getServerInfoCount = self.getServerInfoCount + 1

			self:StopReconCo()

			self.reconnectCo = coroutine.start(function ()
				coroutine.wait(1)
				self:GetServerList()
			end)
		else
			self:Error("重新拉取服务器信息次数失败")
		end

		return false
	end

	self.getServerInfoCount = 0

	return true
end

function M:StopReconCo()
	if self.reconnectCo then
		coroutine.stop(self.reconnectCo)

		self.reconnectCo = nil
	end
end

function M:SelectServer()
	if self.isServerOutOfVersion then
		gDisplayMessageMgr:ShowMessage(MessageConfig.SeverIsMaintenance)

		return
	end

	if string.is_null_or_empty(self.loginUrl) then
		self:Error("loginUrl为空")

		return
	end

	if not self.serverId then
		self:Error("serverId为空")

		return
	end

	PlayerPrefs.SetInt("LastServerId", self.serverId)
	PlayerPrefs.Save()
	self.cs:SelectLoginServer(self.loginUrl, self.serverName, self.serverId, self.serverStatus)
end

function M:SaveEditorAccount()
	if not gCS.LuaUtils.IsOnEditor or self.cs.loginBySDK then
		return
	end

	local loginFile = io.open("login", "w")

	if loginFile ~= nil then
		loginFile:write(self.editorAccount)
		loginFile:close()
	end
end

function M:ReadPlayerPrefs()
	if not gCS.LuaUtils.IsOnEditor or self.cs.loginBySDK then
		return
	end

	local loginFile = io.open("login", "r")

	if loginFile ~= nil then
		self:SetEditorAccount(loginFile:read() or "")
		loginFile:close()
	else
		self:SetEditorAccount(PlayerPrefs.GetString("Account", ""))
	end
end

function M:SetEditorAccount(account)
	account = string.trim(account)

	if string.is_null_or_empty(account) then
		account = LX6.GUI.Login.ServerData.GetLocalServerName()
	end

	if string.is_null_or_empty(account) then
		account = math.random(1, 9999999)
	end

	local projName = gCS.LuaUtils.GetProjectName()
	self.editorAccount = tostring(account)

	if string.sub(self.editorAccount, 1, string.len("$")) == "$" then
		self.account = self.editorAccount
	else
		self.account = projName .. self.editorAccount
	end
end

function M:ShowAccountBind()
	UniSDKManager.BindAccount()
end

function M:RegisterAfterCreateRole(func)
	self.afterCreateRole[#self.afterCreateRole + 1] = func
end

function M:AutoLogin()
	if PlayerPrefs.GetInt("AutoLogin", 0) == 1 then
		PlayerPrefs.SetInt("AutoLogin", 0)
	end

	if self.autoLoginCo then
		coroutine.stop(self.autoLoginCo)

		self.autoLoginCo = nil
	end

	self.autoLoginCo = coroutine.start(function ()
		gMessageManager:SendMessage(gEventConstants.SHOW_WAITING_PANEL)

		while not self.cs:CanRequestEnterGame() do
			coroutine.wait(0.1)
		end

		self:OnLogin()
	end)
end

function M:OnSyncRoleList(eventId, roleId)
	gPlayerManager.main.bindData.loginRolePid = roleId
	local autoLogin = self:CheckIsAutoLogin()

	self:Log("同步角色列表 roleId =" .. ulong.tostring(roleId) .. "|isAutoLogin = " .. (autoLogin and "true" or "false"))

	if autoLogin then
		self:AutoLogin()
	elseif gAnnouncementMgr.isFirst then
		gAnnouncementMgr:RequestNoticeList(function ()
			if gAnnouncementMgr.hasImport then
				gAnnouncementMgr:OpenNoticePanel()
			end
		end)
	end

	if not table.isNilOrEmpty(self.afterCreateRole) and self:CheckHasRole() then
		for i = 1, #self.afterCreateRole do
			self.afterCreateRole[i]()
		end

		self.afterCreateRole = {}
	end
end

function M:CheckHasRole()
	return gPlayerManager.main.bindData.loginRolePid and gPlayerManager.main.bindData.loginRolePid ~= ulong.zero and not self.isCreateNewRole
end

function M:OnClick_DeleteRole()
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

function M:DeleteRole(callback)
	self:Log("删除角色")

	local roleId = gPlayerManager.main.bindData.loginRolePid
	gPlayerManager.main.bindData.loginRolePid = ulong.zero

	gCS.GuiUtils.AskDeleteRole(gPlayerManager.main.bindData.loginRolePid, function (err)
		if err ~= MessageConfig.Ok then
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

function M:CreateRole(userName, sexType, isUsePlayerName, showLoading)
	if not gCS.NetworkManager:IsLoginConnected() then
		gDisplayMessageMgr:ShowMessage(MessageConfig.CheckNetworkConnectionSingle, function ()
			self:DoLoginUniSDK()
		end)

		return false
	end

	self:Log("创建角色")

	self.inCreateRole = true

	gCS.GuiUtils.RequestCreateRole(userName, sexType, isUsePlayerName)

	if showLoading then
		gMessageManager:SendMessage(gEventConstants.SHOW_WAITING_PANEL)
	end

	return true
end

function M:OnCharacterCreated(flag)
	self:Log("创建角色完成")

	self.inCreateRole = false

	if self:CheckIsTgsPack() then
		return
	end

	if self:CheckIsSkipCreateCharacter() then
		self.cs:SetJumpToMainEvent(-1)
	end

	if flag then
		self:RequestEnterGame()
	end
end

function M:Connect()
	self.cs:Logout()

	gCS.CameraDataMgr.MainCameraEnabled = false

	self:GetServerList()
end

function M:RequestEnterGame()
	self.cs:RequestEnterGame(gPlayerManager.main.bindData.loginRolePid)
	gLoadingManager:PreShowLoading()
end

function M:RequstCreateRole()
	self.isCreateNewRole = false

	self:DeleteRole(function ()
		local userName = NpcCultivationConfig.GetConfig(NpcCultivationConfig.DefaultMale).Name

		self:CreateRole(userName, UX.Game.SexType.Male, false, false)
	end)
end

function M:DoLoginUniSDK()
	if self:CheckIsAutoLogin() or not self:CheckIsFirstLogin() then
		self:_DoLoginUniSDK()
	else
		gDisplayMessageMgr:ShowMessExplain(MessageExplainConfig.CBTLoginInstructionConfirm, self:CreateAction(self._DoLoginUniSDK))
	end
end

function M:_DoLoginUniSDK()
	if not gQualityManager.CanEnterGame then
		print_error("当前设备不满足进入游戏的条件")
		gDisplayMessageMgr:ShowMessage(MessageConfig.BanEnterGame)

		return
	end

	self.cs:LoginUniSDK(self.account)
end

function M:OnLogin()
	if not gQualityManager.CanEnterGame then
		gDisplayMessageMgr:ShowMessage(MessageConfig.BanEnterGame)

		return
	end

	if gPanelManager:IsPanelShowing(gPanelId.SELECT_SERVER_NEW) then
		return
	end

	if not self.cs.uniSDKLoginDone then
		self:DoLoginUniSDK()

		return
	end

	if gCS.NetworkManager.currentState == gNetworkState.Queue then
		self.cs.Log(TextScriptTextConfig.GetConfig(89900293).Text)

		return
	end

	if gCS.NetworkManager:IsLoginConnected() then
		if not self.cs:CanRequestEnterGame() then
			self:Log("跳过点击登录，RPC还没收齐")

			return
		end

		if gPlayerManager.main.bindData.loginRolePid and gPlayerManager.main.bindData.loginRolePid ~= ulong.zero then
			self:RequestEnterGame()
		else
			gPanelManager:CheckShow(gPanelId.S_CREATE_CHARACTER_PANEL)

			self.isCreateRole = true
		end
	else
		self:SelectServer()
	end
end

function M:CheckIsAutoLogin()
	return self.cs.loginByOpenId or self:CheckIsSkipLogin() or self.cs.isAlreadyLogin
end

function M:CheckIsFirstLogin()
	local isFirstLogin = PlayerPrefs.GetInt("IsAlreadyLogin", 0) == 0

	if isFirstLogin then
		PlayerPrefs.SetInt("IsAlreadyLogin", 1)
	end

	return isFirstLogin
end

function M:CheckIsTgsPack()
	return false
end

function M:CheckIsSkipLogin()
	return PlayerPrefs.GetInt("SkipLoginPanel", 0) == 1 or PlayerPrefs.GetInt("AutoLogin", 0) == 1
end

function M:CheckIsSkipCreateCharacter()
	return PlayerPrefs.GetInt("SkipCreateCharacterPanel", 0) == 1 or self:CheckIsTgsPack()
end

function M:ClearClickablePopMsg()
	gDisplayMessageMgr:HideMessage(MessageConfig.OpenIdLoginCheck)
	gDisplayMessageMgr:HideMessage(MessageConfig.NoEnterableService)
	gDisplayMessageMgr:HideMessage(MessageConfig.CanNotGetSeverData)
	gDisplayMessageMgr:HideMessage(MessageConfig.LoginFailed)
	gMessageManager:SendMessage(gEventConstants.HIDE_WAITING_PANEL, nil)
end

function M:OpenSelectServerPanel(forceSelect)
	self:Log("点击选服按钮")
	self:GetServerList(function (serverData)
		if not self:FilterServer(serverData) then
			self:Error("无服务器通过过滤")

			return
		end

		self:Log("选服面板打开")

		if gCS.NetworkManager.Instance.currentState == gNetworkState.Queue then
			gDisplayMessageMgr:ShowMessage(MessageConfig.LineUpChangeSever, function ()
				gPanelManager:CheckShow(gPanelId.SELECT_SERVER_NEW, {
					forceSelect = forceSelect
				})
			end, function ()
				return
			end)
		else
			gPanelManager:CheckShow(gPanelId.SELECT_SERVER_NEW, {
				forceSelect = forceSelect
			})
		end
	end)
end

function M:DoKickToLogin(reason, resetLogin, needNotifyServer)
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
end

function M:TGSSkip()
	self.cs.isFirstLogin = false

	gMessageManager:SendMessage(gEventConstants.INIT_UI_COMPLETE)
end

function M:TGSReset()
	gDisplayMessageMgr:ShowMessage(MessageConfig.TGSReset, function ()
		local switchCnt = PlayerPrefs.GetInt("TGSPlayerSwitchCnt", 0)
		switchCnt = switchCnt + 1

		PlayerPrefs.SetInt("TGSPlayerSwitchCnt", switchCnt)

		self.cs.isFirstLogin = true

		gMessageManager:SendMessage(gEventConstants.INIT_UI_COMPLETE)
	end)
end

function M:TGSExit(isSwitchMode)
	local switchCnt = PlayerPrefs.GetInt("TGSPlayerSwitchCnt", 0)
	switchCnt = switchCnt + 1

	PlayerPrefs.SetInt("TGSPlayerSwitchCnt", switchCnt)
	self:DoKickToLogin(nil, true)
end

function M:OnClick_PCQuit()
	self:ClearClickablePopMsg()
	gDisplayMessageMgr:ShowMessage(MessageConfig.QuitApplication, function ()
		gCS.LuaUtils.QuitApplication()
	end)
end

function M:OnLoginLuaUpdate(eventId, data)
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

function M:OnBeBanned(expireTime, reason, reasonId, pid)
	local cfg = BanUserConfig.GetConfig(reasonId)
	local showReason = cfg and cfg.BlockReason or reason
	local timeStr = gTimeUtils:TransFormatTimeWithSec(expireTime) .. " " .. gTimeUtils:DateFormatDetailWithSec("%02d:%02d:%02d", expireTime)

	gDisplayMessageMgr:ShowMessage(MessageConfig.NewUserBanned, nil, nil, ulong.tostring(pid), timeStr, showReason)
end

gLoginManager = gLoginManager or C_LoginManager.new()
