-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ArcadeGalaPanelStore.lua
-- Decompiled from: 01558_ArcadeGalaPanelStore.lua_11ec2884927f.luajit

local MessageDescriptionConfig = LTConfig.MessageDescriptionConfig
local LayerConstants = LX6.Constants.LayerConstants
local MiniGameConfig = LTConfig.MiniGameConfig
C_ArcadeGalaPanelStore = DefClass("C_ArcadeGalaPanelStore", C_ArcadeGalaPanelStore, C_StoreGroup)
GroupName2Class.ArcadeGalaPanelStore = C_ArcadeGalaPanelStore
local M = C_ArcadeGalaPanelStore

M.ctor = function(self)
	self.PAGE_TYPE = {
		["]P~"] = 2,
		[":a\\xbf\\xa7\\xb0i"] = 1,
		["~\\x9a\\x83\\x9d\\x82"] = 0,
		["S[t"] = 3
	}
	self.CONTROL_TYPE = {
		["k\\x8f\\x8e\\x9c\\x93"] = 0,
		["NH~"] = 1
	}
	self.PLAYER_TYPE = {
		["^\\"] = 1,
		["l\\x82\\x8b\\x99\\x93"] = 0
	}
	self.ENEMY_TYPE = {
		["^\\"] = 1,
		["l\\x82\\x8b\\x99\\x93"] = 0
	}
	self.HEART_ANIM_NAME = {
		"\\x82!\\xc1D&H\\x9c`L\\x93LBl#\\x80f\\xf9\\xb6\\xae6\\xd2]}\\xdeI",
		"\\x82!\\xc1D&H\\x9c`L\\x93LBl#\\x80f\\xf9\\xb6\\xae6\\xd2]}\\xdeH",
		"\\x82!\\xc1D&H\\x9c`L\\x93LBl#\\x80f\\xf9\\xb6\\xae6\\xd2]}\\xdeK"
	}
	self.ENEMY_BOOM_ANIM_NAME = {
		"l\\x9a5\\x82\\x96\\xb0Q\\xf2\\xa2\\xd3\t\\xcd\\xebu\\xef3㐒:\\xa5\\xab3\\xe9Α\\xf7p\\xaa.\\xac\\xb1\\xc1",
		"l\\x9a5\\x82\\x96\\xb0Q\\xf2\\xa2\\xd3\t\\xcd\\xebu\\xef3㐒:\\xa5\\xab3\\xe9Α\\xf7p\\xaa.\\xac\\xb1\\xc1",
		"l\\x9a5\\x82\\x96\\xb0Q\\xf2\\xa2\\xd3\t\\xcd\\xebu\\xef3㐒:\\xa5\\xab3\\xe9Α\\xf7p\\xaa.\\xac\\xb1\\xc1",
		"l\\x9a5\\x82\\x96\\xb0Q\\xf2\\xa2\\xd3\t\\xcd\\xebu\\xef3㐒:\\xa5\\xab3\\xe9Α\\xf7p\\xaa.\\xac\\xb1\\xc1"
	}
	self.CHANGE_BG_ANIM_NAME = "s_vx_ArcadeCommonPage"
	self.PANEL_CLOSE_ANIM_NAME = "s_vx_ArcadeGalaPanel_close"
	self.PLAYER_INVINCIBLE_ANIM_NAME = "s_vx_ArcadeGalaPanel_player_InvincibleTime"
	self.PLAYER_NORMAL_ANIM_NAME = "s_vx_ArcadeGalaPanel_player"
	self.PLAYER_GUN_ANIM_NAME = "s_vx_ArcadeGalaPanel_player_gun"
	self.PLAYER_BOOM_ANIM_NAME = "s_vx_ArcadeGalaPanel_PlayerBoomVx"
	self.MAX_HP = 3
end

M.OnAwake = function(self)
	self.Timer = {}
	self.doDelTimer = {}
	self.isFinish = false
	self.bgmUUId = 0
	self.SHOWED_INFO_FILE_NAME = "GalaxianShowedInfoPid"
	self.EnemyInOrOut = self.CreateAction(self, "EnemyInOrOutDelegate")
	self.GameOver = self.CreateAction(self, "GameOverDelegate")
	self.bindData.btnStart.luaClick = self.CreateAction(self, "OnBtnStartClick")
	self.bindData.btnInfo.luaClick = self.CreateAction(self, "OnBtnInfoClick")
	self.bindData.btnInfoClose.luaClick = self.CreateAction(self, "OnBtnInfoCloseClick")
	self.bindData.btnBack.luaClick = self.CreateAction(self, "OnBtnBackClick")
	self.bindData.btnFinishExit.luaClick = self.CreateAction(self, "OnBtnBackClick")
	self.bindData.btnLeft.luaPress = self.CreateAction(self, "OnBtnLeftDown")
	self.bindData.btnLeft.luaRelease = self.CreateAction(self, "OnBtnLeftUp")
	self.bindData.btnRight.luaPress = self.CreateAction(self, "OnBtnRightDown")
	self.bindData.btnRight.luaRelease = self.CreateAction(self, "OnBtnRightUp")
	self.bindData.btnShoot.luaPress = self.CreateAction(self, "OnBtnShootDown")
	self.bindData.btnShoot.luaRelease = self.CreateAction(self, "OnBtnShootUp")
	self.bindData.joystick.luaValueChanged = self.CreateAction(self, "OnJoystickValueChange")
	self.bindData.moveNavRespond.luaGamePadInputChanged = self.CreateAction(self, "OnPlayerMove")
	self.parentTrans = {}
	self.listPosDirty = {}

	for i = 1, 6 do
		local list = self.bindData["EnemyTeamList" .. i]
		list.luaSimpleRenderItem = self.CreateActionWithArgs(self, "OnRenderEnemyItem", i)
		list.luaLayoutSet = self.CreateActionWithArgs(self, "OnListLayoutSet", i)
	end

	self.moveVector = Vector2.New(0, 0)
	self.MoveJs = 0
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
	for i = 1, 6 do
		self.parentTrans[i] = self.bindData["EnemyTeamList" .. i].gameObject:FindChild("View/Content").transform
		self.listPosDirty[i] = false
	end
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	if self.GameManager then
		return
	end

	self.GameManager = data or gSceneGameRuleManager:GetGameRule(gSceneGameRuleManager.GameRuleType.Galaxian)
	self.GameManager.Panel = self

	self:ClearDataSetEvents()

	self.dataSetEvents = {
		{
			self.GameManager.score,
			"~\\xad\\xad\\xbd\\xb3",
			self:CreateAction("UpdateScore")
		}
	}

	self:RegisterDataSetEvents(self.dataSetEvents)
	self:RefreshPlayerHeightRecord()

	local playerInfo = gUIUtils:LoadJsonToLuaTable(self.SHOWED_INFO_FILE_NAME) or {}
	local myPid = ulong.tostring(gCS.MyPlayerManager.PlayerUnitId)
	self.bindData.btnStart.interactable = true

	if not table.contains(playerInfo, myPid) then
		self.bindData.btnStart.interactable = false
		self.saveTimer = Timer.New(function ()
			self.saveTimer = nil

			self:ShowGameRule()
			table.insert(playerInfo, myPid)
			gUIUtils:SaveLuaTableToJson(self.SHOWED_INFO_FILE_NAME, playerInfo)
		end, 2.5, false, true):Start()
	end

	self.GameManager:InitDataFromPanel(self:GetMoveBoundOffset(), self:GetScreenSizeInfo(), self:CalScale())
	self.bindData.videoPlayer:Init()
	self.bindData.videoPlayer:PlayVideo(24100064, false)
	self:StartPlayBgm(70600229)
end

M.OnClose = function(self)
	self.ClearDataSetEvents(self)
	self.StopPlayBgm(self)

	self.GameManager.Panel = false
	self.GameManager = nil

	if self.changeBgTimer then
		self.changeBgTimer:Stop()

		self.changeBgTimer = nil
	end

	if self.saveTimer then
		self.saveTimer:Stop()

		self.saveTimer = nil
	end

	self.enemyList = nil
end

M.ManualUpdate = function(self)
	self.UpdatePlayerMove(self)
	self.CheckTimer(self)

	if self.GameManager.isPause then
		return
	end

	if self.IsPressShoot then
		self.GameManager:PlayerShoot()
	end

	if not gCS.NetworkManager.CheckNetwork then
		-- Nothing
	end
end

M.UpdatePlayerMove = function(self)
	local moveValue = 0

	if self.MoveJs ~= 0 then
		if self.MoveLeft then
			moveValue = moveValue - 1
		end

		if self.MoveRight then
			moveValue = moveValue + 1
		end
	else
		moveValue = self.MoveJs
	end

	if moveValue == 0 then
		self.moveVector.x = moveValue

		self.GameManager:MovePlayer(self.moveVector)
	end
end

M.OnActiveDeviceChange = function(self, device)
end

M.RefreshPlayerHeightRecord = function(self)
	self.bindData.HistoryScore = self.GameManager.historyScore.Score
end

M.UpdateScore = function(self, cell)
	self.bindData.Score = cell.value
	self.bindData.Reward = math.floor(cell.value / LTConfig.MiniGameConfig.Bee_Point)
end

M.ShowGameRule = function(self)
	self.bindData.PageCtrl = self.PAGE_TYPE.INFO
	local cfg = MessageDescriptionConfig.GetConfig(1000012)

	if not cfg then
		return
	end

	self.bindData.infoDesc = cfg.Message
end

M.CalScale = function(self)
	local p1 = self.bindData.enemyAttackArea:TransformPoint(0, 0, 0)
	local p2 = self.bindData.enemyAttackArea:TransformPoint(0, 100, 0)
	local dis = Vector3.Distance(p1, p2)

	return dis / 100
end

M.GetMoveBoundOffset = function(self)
	return {
		self.bindData.MoveBg.sizeDelta.x / 2 - 100,
		self.bindData.MoveBg.sizeDelta.y / 2 - 100
	}
end

M.GetScreenSizeInfo = function(self)
	return {
		self.bindData.ScreenBg.sizeDelta.x,
		self.bindData.ScreenBg.sizeDelta.y
	}
end

M.StartPlayBgm = function(self, bgmId)
	self:StopPlayBgm()

	slot2 = gSoundMgr

	slot2:PlaySoundByTid(bgmId, nil, function (uuid)
		self.bgmUUId = uuid
	end)
end

M.StopPlayBgm = function(self)
	if self.bgmUUId <= 0 then
		gSoundMgr:StopSound(self.bgmUUId)

		self.bgmUUId = 0
	end
end

M.OnDragJoyStick = function(self)
end

M.CheckTimer = function(self)
	table.clear(self.doDelTimer)

	for i, timer in ipairs(self.Timer) do
		timer.time = timer.time - Time.deltaTime

		if timer.time < 0 then
			timer.func()
			table.insert(self.doDelTimer, i)
		end
	end

	for i = #self.doDelTimer, 1, -1 do
		table.remove(self.Timer, self.doDelTimer[i])
	end
end

M.InitPanel = function(self)
	self.bindData.enemyBullet.gameObject:SetActive(false)

	self.bindData.EnemyBoomCtrl = 0

	self:RefreshPlayerAnim()
	self:RefreshPlayerHp()
end

M.RefreshPlayerHp = function(self, needDeduction)
	if needDeduction and self.bindData.HeartCtrl <= 0 then
		gUIUtils:PlayOpenAni(self.bindData.heartAnim, self.HEART_ANIM_NAME[self.bindData.HeartCtrl])

		self.bindData.HeartCtrl = self.bindData.HeartCtrl - 1
	else
		self.bindData.HeartCtrl = self.MAX_HP
	end
end

M.GetPlayerRef = function(self)
	return self.bindData.PlayerRef, self.bindData.fakePlayerBullet, self.bindData.PlayerBulletRef
end

M.GetEnemyTeamRef = function(self)
	return self.bindData.EnemyTeamList1.transform.parent
end

M.EnemyInOrOutDelegate = function(self, ref, isInTeam, teamId)
	if isInTeam then
		ref.SetParent(ref, self.parentTrans[teamId], true)
	else
		ref.SetParent(ref, self.bindData.enemyAttackArea, true)
	end
end

M.RefreshEnemyList = function(self, enemyList)
	self.enemyList = {}

	for i, enemy in ipairs(enemyList) do
		local list = self.enemyList[enemy.teamId]

		if not list then
			list = {}
			self.enemyList[enemy.teamId] = list
		end

		table.insert(list, {
			["[\\xb5\\x8b\\x82E"] = false,
			Index = i,
			Enemy = enemy,
			EnemyType = enemy.enemyType,
			deadIcon = self.GetEnemyDeadIcon(self, enemy.enemyType)
		})
	end

	for i = 1, self.GameManager.ENEMY_TEAM_COUNT do
		self.bindData["EnemyTeamList" .. i]:SetSimpleList(0)
	end

	for k, list in pairs(self.enemyList) do
		self.bindData["EnemyTeamList" .. k]:SetSimpleList(#list)
	end

	for i = 1, self.GameManager.ENEMY_TEAM_COUNT do
		self.bindData["EnemyTeamList" .. i].ignoreChildrenLayout = false
		self.listPosDirty[i] = true

		self.bindData["EnemyTeamList" .. i]:RefreshList()
	end

	self.IsPressShoot = false
end

M.GetEnemyDeadIcon = function(self, enemyType)
	return MiniGameConfig.Bee_EnemyDead[enemyType]
end

M.OnRenderEnemyItem = function(self, id, btn, index)
	local store = self:GetStoreByWidget(btn)
	local list = self.enemyList[id]
	local data = list and list[index + 1]

	if store and data then
		local enemy = data.Enemy
		enemy.ref = store.EnemyRef
		enemy.colliders = store.collider:GetComponentsInChildren(typeof(UnityEngine.Collider)):ToTable()
		enemy.ref.gameObject.layer = LayerConstants.Enemy
		enemy.store = store
		store.LifeCtrl = self.ENEMY_TYPE.ALIVE
		store.EnemyTypeCtrl = data.EnemyType

		if not btn.gameObject.activeSelf then
			btn.gameObject:SetActive(true)
		end

		self.GameManager.instanceId2EnemyId[enemy.ref.gameObject:GetInstanceID()] = data.Index
	end
end

M.GameOverDelegate = function(self, isNewRecord)
	self.bindData.PageCtrl = self.PAGE_TYPE.FINISH

	if isNewRecord then
		self.RefreshPlayerHeightRecord(self)

		self.bindData.NewRecordCtrl = self.CONTROL_TYPE.TRUE
	else
		self.bindData.NewRecordCtrl = self.CONTROL_TYPE.FALSE
	end

	self:StopPlayBgm()
	gSoundMgr:PlaySoundByTid(70600228)
	gUIUtils:PlayOpenAni(self.bindData.openAndCloseAnim, self.PANEL_CLOSE_ANIM_NAME)
end

M.OnEnemyDead = function(self, enemy, state)
	self.bindData.enemyBoomRef.transform.position = enemy.ref.position
	self.bindData.EnemyBoomCtrl = enemy.enemyType

	gUIUtils:PlayOpenAni(self.bindData.enemyBoomAnim, self.ENEMY_BOOM_ANIM_NAME[enemy.enemyType])

	enemy.store.LifeCtrl = self.ENEMY_TYPE.DEAD

	gSoundMgr:PlaySoundByTid(70600221)
end

M.RefreshPlayerAnim = function(self)
	self.bindData.PlayerCtrl = self.PLAYER_TYPE.ALIVE

	gUIUtils:SkipAni(self.bindData.playerAnim, self.PLAYER_INVINCIBLE_ANIM_NAME)
	gUIUtils:PlayOpenAni(self.bindData.playerAnim, self.PLAYER_NORMAL_ANIM_NAME)
end

M.OnPlayerDead = function(self)
	gUIUtils:SkipAni(self.bindData.playerAnim, self.PLAYER_NORMAL_ANIM_NAME)

	self.bindData.playerBoomRef.transform.position = self.bindData.PlayerRef.transform.position

	gUIUtils:PlayOpenAni(self.bindData.playerBoomAnim, self.PLAYER_BOOM_ANIM_NAME)
	self:RefreshPlayerHp(true)

	local clip = self.bindData.playerAnim:GetClip(self.PLAYER_INVINCIBLE_ANIM_NAME)

	clip:SampleAnimation(self.bindData.playerAnim.gameObject, 0)
	self.bindData.playerAnim:Stop()

	self.bindData.playerAnim:get_Item(self.PLAYER_INVINCIBLE_ANIM_NAME).speed = 0.7

	self.bindData.playerAnim:Play(self.PLAYER_INVINCIBLE_ANIM_NAME)
	gSoundMgr:PlaySoundByTid(70600221)
end

M.SetBulletIcon = function(self, enemyType)
	self.bindData.EnemyBulletCtrl = enemyType
end

M.CreateBullet = function(self, bulletId)
	local ref = SGUITools.AddChild(self.bindData.enemyAttackArea, self.bindData.enemyBullet.gameObject)

	return ref
end

M.SetBattleBg = function(self, level)
	local count = #MiniGameConfig.Bee_BattleBg

	if count <= 0 then
		self.bindData.newBattleBg = MiniGameConfig.Bee_BattleBg[level % count + 1]
	end

	if level ~= 1 then
		self.bindData.oldBattleBg = self.bindData.newBattleBg
	else
		local length = gUIUtils:PlayOpenAni(self.bindData.changeBgAnim, self.CHANGE_BG_ANIM_NAME)
		self.changeBgTimer = Timer.New(function ()
			self.changeBgTimer = nil
			self.bindData.oldBattleBg = self.bindData.newBattleBg
		end, length):Start()
	end
end

M.OnBtnStartClick = function(self)
	self.bindData.PageCtrl = self.PAGE_TYPE.GAME
	self.isFinish = false

	self:SetBattleBg(1)
	self.GameManager:Init()
	self:StartPlayBgm(70600227)
end

M.OnBtnInfoClick = function(self)
	self.ShowGameRule(self)
end

M.OnBtnInfoCloseClick = function(self)
	self.bindData.PageCtrl = self.PAGE_TYPE.START
	self.bindData.btnStart.interactable = true
end

M.OnBtnBackClick = function(self)
	if not self.isFinish then
		slot1 = self.GameManager

		slot1:UpdateScore(function ()
			gSceneGameRuleManager:DestroyGameRule(gSceneGameRuleManager.GameRuleType.Galaxian)
		end)
	else
		gSceneGameRuleManager:DestroyGameRule(gSceneGameRuleManager.GameRuleType.Galaxian)
	end

	gPanelManager:SetActiveById(gPanelId.S_ARCADE_GALA_PANEL, false)
end

M.OnListLayoutSet = function(self, index)
	if not self.listPosDirty[index] then
		return
	end

	self.listPosDirty[index] = false
	local list = self.bindData["EnemyTeamList" .. index]
	list.ignoreChildrenLayout = true
	local data = self.enemyList[index]

	if data then
		for i = 1, #data do
			local item = data[i]
			local enemy = item.Enemy
			enemy.initPos = enemy.ref.localPosition
		end
	end
end

M.OnBtnShootDown = function(self)
	self.IsPressShoot = true

	if self.bindData.PlayerCtrl ~= self.PLAYER_TYPE.ALIVE then
		gUIUtils:PlayOpenAni(self.bindData.playerAnim, self.PLAYER_GUN_ANIM_NAME)
	end
end

M.OnBtnShootUp = function(self)
	self.IsPressShoot = false

	gUIUtils:PlayOpenAni(self.bindData.playerAnim, self.PLAYER_NORMAL_ANIM_NAME)
end

M.OnBtnLeftDown = function(self)
	self.MoveLeft = true
end

M.OnBtnLeftUp = function(self)
	self.MoveLeft = false
end

M.OnBtnRightDown = function(self)
	self.MoveRight = true
end

M.OnBtnRightUp = function(self)
	self.MoveRight = false
end

M.OnJoystickValueChange = function(self, x, y, size)
	self.MoveJs = x
end

M.OnPlayerMove = function(self, context)
	if not self.STATE_EnableOnce then
		return
	end

	self.MoveJs = context.ReadValueVector2(context).x
end
