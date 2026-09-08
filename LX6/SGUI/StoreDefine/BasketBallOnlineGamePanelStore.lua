-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BasketBallOnlineGamePanelStore.lua
-- Decompiled from: 01659_BasketBallOnlineGamePanelStore.lua_a06f5126aa15.luajit

C_BasketBallOnlineGamePanelStore = DefClass("C_BasketBallOnlineGamePanelStore", C_BasketBallOnlineGamePanelStore, C_StoreGroup)
GroupName2Class.BasketBallOnlineGamePanelStore = C_BasketBallOnlineGamePanelStore
local M = C_BasketBallOnlineGamePanelStore
local LinkBasketballStatus = L18.Gameplay.LinkBasketball.LinkBasketballStatus
local PlayerNamePrefabPath = "Assets/Res/SGUI/Panel/BasketballOnline/S_BasketPlayerNameTemplate.prefab"
local PlayerNameOffset = tonumber(LTConfig.BasketBallConfig.NickNameOffset)

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.leftTimeTimer = nil
	self.showBubbleTimer = nil
	self._policeInfoHidden = false
	self.playerNameItems = {}
	self.playerNameLoadVersion = 0
end

M.DefineAllEnumsAutoGen = function(self)
	self.stateCtrlEnum = {
		["o\\xab\\xa5\\xa6\\xb8"] = 4,
		["\\xee\\xda\t*\\xf6"] = 3,
		["\\x8f\\xb4\\xado0\\xfd6"] = 2,
		["\\xf6\\xdd'\\xf4"] = 1,
		["z\\xaf\\xb6\\xac\\xbe"] = 0,
		["Xw\\xa5cE\\xbc\\xf5jvjE"] = 5
	}
	self.bubbleTextCtrlEnum = {
		["\\x8cib"] = 1,
		["}-r_"] = 0
	}
	self.bubbleStateCtrlEnum = {
		["N'eO"] = 1,
		["/K\\x9e\\x9c\\x86"] = 2,
		["/K\\x9e\\x9c\\x86"] = 3,
		["T-s^"] = 0
	}
	self.possessionCtrlEnum = {
		["-"] = 0,
		["h\\xa0\\xa7\\xa2\\xaf"] = 1,
		["T-s^"] = 2
	}
	self.prohibiteCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.stateCtrlEnum = nil
	self.bubbleTextCtrlEnum = nil
	self.bubbleStateCtrlEnum = nil
	self.possessionCtrlEnum = nil
	self.prohibiteCtrlEnum = nil
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
	self.ClearPlayerNameHud(self)
	self.ClearCountDown(self)

	if self.showBubbleTimer then
		self.showBubbleTimer:Stop()

		self.showBubbleTimer = nil
	end
end

M.OnGroupEnable = function(self)
	self.ClearCountDown(self)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	self:GenMessageEvents()
	self:RegisterMessageEvents(self.msgEvents)
	self.bindData.exitBtn.gameObject:SetActive(not data or not data.hideExitBtn)
	gStoreManager:GetStoreGroup("CoreHudTaskGuideStore").bindData.entranceBtn:SetActive(false)

	if data and data.callback then
		if type(data.callback) ~= "function" then
			data.callback()
		elseif type(data.callback) ~= "userdata" then
			data.callback:DynamicInvoke()
		end
	end

	self:SwitchState()
	self:UpdateSideInfo()
	self:StartUpdateLeftTime()

	self._policeInfoHidden = false
	local policeInfoStore = gStoreManager:GetStoreGroup("PoliceInfoStore")

	if policeInfoStore and policeInfoStore.STATE_EnableOnce and not gClientUtils.IsNil(policeInfoStore.rootGo) then
		policeInfoStore.rootGo:SetActive(false)

		self._policeInfoHidden = true
	end

	gBlackScreenManager:ClearTransition(gBlackScreenId.LINK_BASKETBALL, true)
	self.bindData.threePointNode.gameObject:SetActive(false)
	self.bindData.twoPointNode.gameObject:SetActive(false)
	self.bindData.bubbleTextNode.gameObject:SetActive(false)
	self:RefreshPlayerNameHud("OnShow")
end

M.OnClose = function(self)
	self:ClearPlayerNameHud()
	gStoreManager:GetStoreGroup("CoreHudTaskGuideStore").bindData.entranceBtn:SetActive(true)

	if self._policeInfoHidden then
		local policeInfoStore = gStoreManager:GetStoreGroup("PoliceInfoStore")

		if policeInfoStore and not gClientUtils.IsNil(policeInfoStore.rootGo) then
			policeInfoStore.rootGo:SetActive(true)
		end

		self._policeInfoHidden = false
	end
end

M.RefreshPlayerNameHud = function(self, reason)
	local oldCount = #self.playerNameItems

	self:ClearPlayerNameHud()

	local linkBasketballManager = gCS.LinkBasketballManager.Instance
	local showDebugPlayerNames = gGameManager.Env.IsDebug or gGameManager.Env.isEditor
	local pids = showDebugPlayerNames and linkBasketballManager:GetAllUnitPids() or linkBasketballManager:GetMyTeamUnitPids()
	local version = self.playerNameLoadVersion
	local pidTexts = {}

	for i = 0, pids.Count - 1 do
		table.insert(pidTexts, ulong.tostring(pids[i]))
	end

	print(string.format("[LinkBasketballV2][NickName] refresh reason=%s status=%s version=%d oldCount=%d pids=[%s] rootNil=%s offset=%s", tostring(reason), tostring(linkBasketballManager.basketballStatus), version, oldCount, table.concat(pidTexts, ","), tostring(gClientUtils.IsNil(self.rootGo)), tostring(PlayerNameOffset)))

	slot8 = gResourceManager

	slot8:LoadAssetWithCallBack(PlayerNamePrefabPath, typeof(UnityEngine.GameObject), function (loadOp)
		local rootNil = gClientUtils.IsNil(self.rootGo)
		local assetNil = not loadOp or gClientUtils.IsNil(loadOp.asset)

		if version == self.playerNameLoadVersion or rootNil or assetNil then
			print(string.format("[LinkBasketballV2][NickName] callback skipped reason=%s version=%d currentVersion=%d rootNil=%s assetNil=%s", tostring(reason), version, self.playerNameLoadVersion, tostring(rootNil), tostring(assetNil)))

			return
		end

		local created = {}
		local missingUnits = {}

		for i = 0, pids.Count - 1 do
			local pid = pids[i]
			local unit = gCS.SceneDataMgr.GetUnit(pid)

			if unit then
				local scoreInfo = linkBasketballManager:GetPlayerScoreInfo(pid)
				local scoreName = scoreInfo and scoreInfo.name or nil
				local clientName = unit.ClientData.Name
				local finalName = scoreName or clientName
				local displayName = showDebugPlayerNames and finalName .. " (" .. ulong.tostring(pid) .. ")" or finalName
				local clone = UnityEngine.GameObject.Instantiate(loadOp.asset, self.rootGo.transform)

				clone:SetActive(false)
				UnityEngine.Object.Destroy(clone:GetComponent(typeof(LX6.GUI.HUDNew.HUDTemplate)))

				local nameText = clone.transform:Find("PerspectivePosScale/VFX_Root/Root/Name"):GetComponent(typeof(SGUI.USDFText))
				nameText.text = displayName

				if showDebugPlayerNames then
					local isMyTeam = linkBasketballManager:IsUnitOffenseSide(pid) ~= linkBasketballManager.isOffenseSide
					nameText.color = isMyTeam and Color.New(0.35, 0.75, 1, 1) or Color.New(0.9568627450980393, 0.25882352941176473, 0.34901960784313724, 1)
				end

				table.insert(self.playerNameItems, {
					pid = pid,
					go = clone,
					rect = clone:GetComponent(typeof(UnityEngine.RectTransform)),
					text = nameText
				})
				table.insert(created, string.format("%s{score=%s,client=%s,final=%s,cloneActive=%s,nameActive=%s}", ulong.tostring(pid), tostring(scoreName), tostring(clientName), tostring(finalName), tostring(clone.activeInHierarchy), tostring(nameText.gameObject.activeInHierarchy)))
			else
				table.insert(missingUnits, ulong.tostring(pid))
			end
		end

		print(string.format("[LinkBasketballV2][NickName] build reason=%s asset=%s created=%d names=[%s] missingUnit=[%s]", tostring(reason), tostring(loadOp.asset.name), #self.playerNameItems, table.concat(created, " | "), table.concat(missingUnits, ",")))
		self:UpdatePlayerNamePositions(reason)
	end)
end

M.ClearPlayerNameHud = function(self)
	self.playerNameLoadVersion = self.playerNameLoadVersion + 1

	for _, item in ipairs(self.playerNameItems) do
		UnityEngine.Object.Destroy(item.go)
	end

	table.clear(self.playerNameItems)
end

M.OnCameraUpdate = function(self)
	self.UpdatePlayerNamePositions(self)
end

M.UpdatePlayerNamePositions = function(self, logReason)
	local camera = gCS.CameraDataMgr.MainCamera
	local positionDetails = logReason and {} or nil

	for _, item in ipairs(self.playerNameItems) do
		local unit = gCS.SceneDataMgr.GetUnit(item.pid)

		if unit then
			local position = unit.ModelSlot.transform.position
			local screenPos = camera:WorldToScreenPoint(Vector3.New(position.x, position.y + PlayerNameOffset, position.z))

			item.go:SetActive(screenPos.z >= 0)

			if screenPos.z <= 0 then
				item.rect.localPosition = gCS.LuaUtils.ScreenPointUI(self.rootGo.transform, screenPos)
			end

			if positionDetails then
				table.insert(positionDetails, string.format("%s{world=%s,screen=%s,local=%s,active=%s,hierarchy=%s,name=%s,font=%s,opacity=%s/%s,textEnabled=%s,nameActive=%s}", ulong.tostring(item.pid), tostring(position), tostring(screenPos), tostring(item.rect.localPosition), tostring(item.go.activeSelf), tostring(item.go.activeInHierarchy), tostring(item.text.text), tostring(item.text.fontUrl), tostring(item.text.renderOpacity), tostring(item.text.actualRenderOpacity), tostring(item.text.enabled), tostring(item.text.gameObject.activeInHierarchy)))
			end
		else
			item.go:SetActive(false)

			if positionDetails then
				table.insert(positionDetails, ulong.tostring(item.pid) .. "{unit=nil}")
			end
		end
	end

	if positionDetails then
		print(string.format("[LinkBasketballV2][NickName] position reason=%s camera=%s count=%d details=[%s]", tostring(logReason), tostring(camera), #self.playerNameItems, table.concat(positionDetails, " | ")))
	end
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.ON_BASKETBALL_STATE_EVENT] = self.CreateAction(self, "OnStateEvent"),
		[gEventConstants.ON_BASKETBALL_SCORE_STATE_EVENT] = self.CreateAction(self, "OnScoreStateEvent"),
		[gEventConstants.ON_SYNC_BASKETBALL_SCORE_INFO] = self.CreateAction(self, "UpdateSideInfo"),
		[gEventConstants.ON_BASKETBALL_ENERGY_EVENT] = self.CreateAction(self, "UpdateEnergy"),
		[gEventConstants.ON_LINK_BASKETBALL_TURN_ROUND] = self.CreateAction(self, "OnTurnRound"),
		[gEventConstants.ON_LINK_BASKETBALL_WATCH_GAME] = self.CreateAction(self, "OnWatchGame"),
		[gEventConstants.ON_LINK_BASKETBALL_ROUND_STOP] = self.CreateAction(self, "OnRoundStop"),
		[gEventConstants.ON_LINK_BASKETBALL_FOUL_EVENT] = self.CreateAction(self, "OnFoulEvent"),
		[gEventConstants.ON_LINK_BASKETBALL_OFFENSE_SIDE_CHANGED] = self.CreateAction(self, "UpdateOffenseSide"),
		[gEventConstants.ON_LINK_BASKETBALL_PLAYER_RECONNECT] = self.CreateAction(self, "OnPlayerReconnect"),
		[gEventConstants.ON_LINK_BASKETBALL_AI_JOIN] = self.CreateAction(self, "OnAIJoin"),
		[gEventConstants.OCCUPY_INFO_CHANGED] = self.CreateAction(self, "OnWaitingPointChanged")
	}
end

M.RegisterWidget = function(self)
	self.bindData.exitBtn.luaClick = self.CreateAction(self, "onExitBtnClick")
end

M.onExitBtnClick = function(self)
	local linkBasketballManager = gCS.LinkBasketballManager.Instance

	linkBasketballManager.ExitMatch(linkBasketballManager)
end

M.SwitchState = function(self)
	local linkBasketballManager = gCS.LinkBasketballManager.Instance

	if linkBasketballManager.basketballStatus ~= LinkBasketballStatus.InMatch then
		if linkBasketballManager.isOffenseSide then
			self.bindData.stateCtrl = self.stateCtrlEnum.Offence
		else
			self.bindData.stateCtrl = self.stateCtrlEnum.Deffence
		end
	elseif linkBasketballManager.basketballStatus ~= LinkBasketballStatus.FreeShooting then
		if linkBasketballManager.IsMulti(linkBasketballManager) then
			self.bindData.stateCtrl = self.stateCtrlEnum.WaitingMulti

			self.UpdateWaitingMulti(self)
		else
			self.bindData.stateCtrl = self.stateCtrlEnum.Waiting
		end
	elseif linkBasketballManager.basketballStatus ~= LinkBasketballStatus.Watching then
		self.bindData.stateCtrl = self.stateCtrlEnum.Watch
	end
end

M.UpdateName = function(self)
	local linkBasketballManager = gCS.LinkBasketballManager.Instance

	if linkBasketballManager.IsMulti(linkBasketballManager) then
		self.bindData.myName = LTConfig.TextScriptTextConfig.GetConfig(89901050).Text
		self.bindData.enemyName = LTConfig.TextScriptTextConfig.GetConfig(89901574).Text

		return
	end

	local myName = linkBasketballManager.GetMyName(linkBasketballManager)
	local enemyName = linkBasketballManager.GetEnemyName(linkBasketballManager)
	self.bindData.myName = myName
	self.bindData.enemyName = enemyName
end

M.UpdateScore = function(self)
	local linkBasketballManager = gCS.LinkBasketballManager.Instance
	local myScore = linkBasketballManager.GetMyScore(linkBasketballManager)
	local enemyScore = linkBasketballManager.GetEnemyScore(linkBasketballManager)
	self.bindData.myScore = myScore
	self.bindData.enemyScore = enemyScore
end

M.UpdateSideInfo = function(self)
	local linkBasketballManager = gCS.LinkBasketballManager.Instance

	if linkBasketballManager.basketballStatus ~= LinkBasketballStatus.Watching then
		self.UpdateWatchingSideInfo(self)

		return
	end

	self.UpdateName(self)
	self.UpdateScore(self)
	self.UpdateOffenseSide(self)
end

M.UpdateWatchingSideInfo = function(self)
	local linkBasketballManager = gCS.LinkBasketballManager.Instance
	local myScoreInfo = linkBasketballManager:GetPlayerScoreInfo(linkBasketballManager:GetWatchingMyFirstUnitPid())
	local enemyScoreInfo = linkBasketballManager:GetPlayerScoreInfo(linkBasketballManager:GetWatchingEnemyFirstUnitPid())
	self.bindData.myName = myScoreInfo and myScoreInfo.name or nil
	self.bindData.enemyName = enemyScoreInfo and enemyScoreInfo.name or nil
	self.bindData.myScore = myScoreInfo and myScoreInfo.score or 0
	self.bindData.enemyScore = enemyScoreInfo and enemyScoreInfo.score or 0

	self:UpdateOffenseSide()
end

M.UpdateOffenseSide = function(self)
	local linkBasketballManager = gCS.LinkBasketballManager.Instance

	if linkBasketballManager.basketballStatus == LinkBasketballStatus.InMatch and linkBasketballManager.basketballStatus == LinkBasketballStatus.Watching then
		self.bindData.possessionCtrl = self.possessionCtrlEnum.None

		return
	end

	if linkBasketballManager.basketballStatus ~= LinkBasketballStatus.Watching then
		if linkBasketballManager.IsUnitOffenseSide(linkBasketballManager, linkBasketballManager.GetWatchingMyFirstUnitPid(linkBasketballManager)) then
			self.bindData.possessionCtrl = self.possessionCtrlEnum.Me
		else
			self.bindData.possessionCtrl = self.possessionCtrlEnum.Enemy
		end

		return
	end

	if linkBasketballManager.isOffenseSide then
		self.bindData.possessionCtrl = self.possessionCtrlEnum.Me
	else
		self.bindData.possessionCtrl = self.possessionCtrlEnum.Enemy
	end
end

M.OnAIJoin = function(self)
	local linkBasketballManager = gCS.LinkBasketballManager.Instance

	if linkBasketballManager.basketballStatus ~= LinkBasketballStatus.FreeShooting and linkBasketballManager.IsMulti(linkBasketballManager) then
		self.SwitchState(self)
		self.RefreshPlayerNameHud(self, "OnAIJoin")

		return
	end

	self.bindData.possessionCtrl = self.possessionCtrlEnum.None
	self.bindData.stateCtrl = self.stateCtrlEnum.Begin

	self.RefreshPlayerNameHud(self, "OnAIJoin")
end

M.OnPlayerReconnect = function(self)
	self.UpdateSideInfo(self)
	self.RefreshPlayerNameHud(self, "OnPlayerReconnect")
end

M.OnWaitingPointChanged = function(self)
	local linkBasketballManager = gCS.LinkBasketballManager.Instance

	if linkBasketballManager.basketballStatus ~= LinkBasketballStatus.FreeShooting and linkBasketballManager.IsMulti(linkBasketballManager) then
		self.UpdateWaitingMulti(self)
	end
end

M.UpdateWaitingMulti = function(self)
	local linkBasketballManager = gCS.LinkBasketballManager.Instance
	self.bindData.waitingMultiSelf = gString.Format(LTConfig.TextScriptTextConfig.GetConfig(89901572).Text, linkBasketballManager.GetWaitingMultiPlayerCount(linkBasketballManager, true), 3)
	self.bindData.waitingMultiEnemy = gString.Format(LTConfig.TextScriptTextConfig.GetConfig(89901573).Text, linkBasketballManager.GetWaitingMultiPlayerCount(linkBasketballManager, false), 3)
end

M.OnTurnRound = function(self)
	self.bindData.exitBtn.gameObject:SetActive(true)
	self:RefreshPlayerNameHud("OnTurnRound")

	local linkBasketballManager = gCS.LinkBasketballManager.Instance

	if linkBasketballManager.basketballStatus ~= LinkBasketballStatus.InMatch then
		gCS.CameraDataMgr.cinemachineManager:EnterMovementState(LX6.Cinemachine.EMovementCamState.BasketBall2K)
	end

	self.StartUpdateLeftTime(self)
end

M.OnWatchGame = function(self)
	self.StartUpdateLeftTime(self)
	self.SwitchState(self)
	self.UpdateSideInfo(self)
end

M.OnRoundStop = function(self)
	self.bindData.exitBtn.gameObject:SetActive(false)

	self.bindData.prohibiteCtrl = self.prohibiteCtrlEnum._false
end

M.StartUpdateLeftTime = function(self)
	local linkBasketballManager = gCS.LinkBasketballManager.Instance

	if linkBasketballManager.basketballStatus ~= LinkBasketballStatus.None then
		return
	end

	if linkBasketballManager.basketballStatus ~= LinkBasketballStatus.FreeShooting then
		return
	end

	self:ClearCountDown()

	self.leftTimeTimer = FrameTimer.New(function ()
		local _, leftTime = nil
		_, leftTime = linkBasketballManager:TryGetCurrentRoundLeftTime(leftTime)

		if leftTime <= 0 then
			local min = math.floor(leftTime / 60)
			local sec = leftTime - min * 60
			self.bindData.leftTime = string.format("%02d:%05.2f", min, sec)
		else
			self:ClearCountDown()
		end
	end, 1, -1, false):Start()
end

M.ClearCountDown = function(self)
	if self.leftTimeTimer then
		self.leftTimeTimer:Stop()

		self.leftTimeTimer = nil
	end

	self.bindData.leftTime = ""
end

M.OnScoreStateEvent = function(self, _, scoreType)
	if scoreType ~= 0 then
		return
	end

	local isThreeScore = scoreType ~= 3
	local node = isThreeScore and self.bindData.threePointNode or self.bindData.twoPointNode

	self:ShowBubble(node)
end

M.OnStateEvent = function(self, _, eventId)
	local cfg = LTConfig.BasketBallStateAnimationConfig.GetConfig(eventId)

	if not cfg then
		return
	end

	if eventId ~= LTConfig.BasketBallStateAnimationConfig.TimeOut then
		self.ClearCountDown(self)
	end

	self.bindData.bubbleText = cfg.AnimationText

	if cfg.IsPositive then
		self.bindData.bubbleTextCtrl = 0
	else
		self.bindData.bubbleTextCtrl = 1
	end

	self.ShowBubble(self, self.bindData.bubbleTextNode)
end

M.OnFoulEvent = function(self, _, foulType, shooterUid)
	if foulType ~= 1 then
		self.bindData.prohibiteCtrl = self.prohibiteCtrlEnum._true

		return
	end
end

M.ShowBubble = function(self, node)
	self.currentBubbleNode = node

	node.gameObject:SetActive(false)
	node.gameObject:SetActive(true)

	if self.showBubbleTimer then
		self.showBubbleTimer:Stop()

		self.showBubbleTimer = nil
	end

	self.showBubbleTimer = Timer.New(function ()
		node.gameObject:SetActive(false)
	end, 2):Start()
end
