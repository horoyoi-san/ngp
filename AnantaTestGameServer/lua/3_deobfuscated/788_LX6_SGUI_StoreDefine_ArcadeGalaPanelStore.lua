local MessageDescriptionConfig = LTConfig.MessageDescriptionConfig
local LayerConstants = LX6.Constants.LayerConstants
local MiniGameConfig = LTConfig.MiniGameConfig
local GAME_TAB = {
	Over = 2,
	Playing = 1,
	Prepare = 0
}
C_ArcadeGalaPanelStore = DefClass("C_ArcadeGalaPanelStore", C_ArcadeGalaPanelStore, C_StoreGroup)
GroupName2Class.ArcadeGalaPanelStore = C_ArcadeGalaPanelStore
local M = C_ArcadeGalaPanelStore

function M:ctor()
	self.PAGE_TYPE = {
		GAME = 2,
		FINISH = 1,
		START = 0,
		INFO = 3
	}
	self.CONTROL_TYPE = {
		FALSE = 0,
		TRUE = 1
	}
	self.PLAYER_TYPE = {
		DEAD = 1,
		ALIVE = 0
	}
	self.ENEMY_TYPE = {
		DEAD = 1,
		ALIVE = 0
	}
	self.HEART_ANIM_NAME = {
		"s_vx_ArcadeGalaPanel_Heart03",
		"s_vx_ArcadeGalaPanel_Heart02",
		"s_vx_ArcadeGalaPanel_Heart01"
	}
	self.ENEMY_BOOM_ANIM_NAME = {
		"s_vx_ArcadeGalaPanel_EnemyBoomVx01",
		"s_vx_ArcadeGalaPanel_EnemyBoomVx02",
		"s_vx_ArcadeGalaPanel_EnemyBoomVx03",
		"s_vx_ArcadeGalaPanel_EnemyBoomVx04"
	}
	self.CHANGE_BG_ANIM_NAME = "s_vx_ArcadeCommonPage"
	self.PANEL_CLOSE_ANIM_NAME = "s_vx_ArcadeGalaPanel_close"
	self.PLAYER_INVINCIBLE_ANIM_NAME = "s_vx_ArcadeGalaPanel_player_InvincibleTime"
	self.PLAYER_NORMAL_ANIM_NAME = "s_vx_ArcadeGalaPanel_player"
	self.PLAYER_GUN_ANIM_NAME = "s_vx_ArcadeGalaPanel_player_gun"
	self.PLAYER_BOOM_ANIM_NAME = "s_vx_ArcadeGalaPanel_PlayerBoomVx"
	self.MAX_HP = 3
end

function M:OnAwake()
	self.Timer = {}
	self.doDelTimer = {}
	self.isFinish = false
	self.bgmUUId = 0
	self.SHOWED_INFO_FILE_NAME = "GalaxianShowedInfoPid"
	self.EnemyInOrOut = self:CreateAction("EnemyInOrOutDelegate")
	self.GameOver = self:CreateAction("GameOverDelegate")
	self.bindData.btnStart.luaClick = self:CreateAction("OnBtnStartClick")
	self.bindData.btnInfo.luaClick = self:CreateAction("OnBtnInfoClick")
	self.bindData.btnInfoClose.luaClick = self:CreateAction("OnBtnInfoCloseClick")
	self.bindData.btnBack.luaClick = self:CreateAction("OnBtnBackClick")
	self.bindData.btnFinishExit.luaClick = self:CreateAction("OnBtnBackClick")
	self.bindData.btnLeft.luaPress = self:CreateAction("OnBtnLeftDown")
	self.bindData.btnLeft.luaRelease = self:CreateAction("OnBtnLeftUp")
	self.bindData.btnRight.luaPress = self:CreateAction("OnBtnRightDown")
	self.bindData.btnRight.luaRelease = self:CreateAction("OnBtnRightUp")
	self.bindData.btnShoot.luaPress = self:CreateAction("OnBtnShootDown")
	self.bindData.btnShoot.luaRelease = self:CreateAction("OnBtnShootUp")
	self.bindData.joystick.luaValueChanged = self:CreateAction("OnJoystickValueChange")
	self.bindData.moveNavRespond.luaGamePadInputChanged = self:CreateAction("OnPlayerMove")
	self.parentTrans = {}
	self.listPosDirty = {}

	for i = 1, 6 do
		local list = self.bindData["EnemyTeamList" .. i]
		list.luaSimpleRenderItem = self:CreateActionWithArgs("OnRenderEnemyItem", i)
		list.luaLayoutSet = self:CreateActionWithArgs("OnListLayoutSet", i)
	end

	self.moveVector = Vector2.New(0, 0)
	self.MoveJs = 0
end

function M:OnEnable()
	return
end

function M:OnStart()
	return
end

function M:OnDisable()
	return
end

function M:OnDestroy()
	return
end

function M:OnGroupEnable()
	for i = 1, 6 do
		self.parentTrans[i] = self.bindData["EnemyTeamList" .. i].gameObject:FindChild("View/Content").transform
		self.listPosDirty[i] = false
	end
end

function M:OnGroupDisable()
	return
end

function M:OnShow(panelId, data)
	if self.GameManager then
		return
	end

	self.GameManager = data or gSceneGameRuleManager:GetGameRule(gSceneGameRuleManager.GameRuleType.Galaxian)
	self.GameManager.Panel = self

	self:ClearDataSetEvents()

	self.dataSetEvents = {
		{
			self.GameManager.score,
			"Score",
			self:CreateAction("UpdateScore")
		}
	}

	self:RegisterDataSetEvents(self.dataSetEvents)
	self:RefreshPlayerHeightRecord()

	local playerInfo = gUIUtils:LoadJsonToLuaTable(self.SHOWED_INFO_FILE_NAME) or {}
	local myPid = ulong.tostring(gCS.MyPlayerManager.PlayerUnitId)

	if not table.contains(playerInfo, myPid) then
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

function M:OnClose()
	self:ClearDataSetEvents()
	self:StopPlayBgm()

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

function M:ManualUpdate()
	self:UpdatePlayerMove()
	self:CheckTimer()

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

function M:UpdatePlayerMove()
	local moveValue = 0

	if self.MoveJs == 0 then
		if self.MoveLeft then
			moveValue = moveValue - 1
		end

		if self.MoveRight then
			moveValue = moveValue + 1
		end
	else
		moveValue = self.MoveJs
	end

	if moveValue ~= 0 then
		self.moveVector.x = moveValue

		self.GameManager:MovePlayer(self.moveVector)
	end
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end

function M:RefreshPlayerHeightRecord()
	self.bindData.HistoryScore = self.GameManager.historyScore.Score
end

function M:UpdateScore(cell)
	self.bindData.Score = cell.value
	self.bindData.Reward = math.floor(cell.value / LTConfig.MiniGameConfig.Bee_Point)
end

function M:ShowGameRule()
	self.bindData.PageCtrl = self.PAGE_TYPE.INFO
	local cfg = MessageDescriptionConfig.GetConfig(1000012)

	if not cfg then
		return
	end

	self.bindData.infoDesc = cfg.Message
end

function M:CalScale()
	local p1 = self.bindData.enemyAttackArea:TransformPoint(0, 0, 0)
	local p2 = self.bindData.enemyAttackArea:TransformPoint(0, 100, 0)
	local dis = Vector3.Distance(p1, p2)

	return dis / 100
end

function M:GetMoveBoundOffset()
	return {
		self.bindData.MoveBg.sizeDelta.x / 2 - 100,
		self.bindData.MoveBg.sizeDelta.y / 2 - 100
	}
end

function M:GetScreenSizeInfo()
	return {
		self.bindData.ScreenBg.sizeDelta.x,
		self.bindData.ScreenBg.sizeDelta.y
	}
end

function M:StartPlayBgm(bgmId)
	self:StopPlayBgm()
	gSoundMgr:PlaySoundByTid(bgmId, nil, function (uuid)
		self.bgmUUId = uuid
	end)
end

function M:StopPlayBgm()
	if self.bgmUUId > 0 then
		gSoundMgr:StopSound(self.bgmUUId)

		self.bgmUUId = 0
	end
end

function M:OnDragJoyStick()
	return
end

function M:CheckTimer()
	table.clear(self.doDelTimer)

	for i, timer in ipairs(self.Timer) do
		timer.time = timer.time - Time.deltaTime

		if timer.time <= 0 then
			timer.func()
			table.insert(self.doDelTimer, i)
		end
	end

	for i = #self.doDelTimer, 1, -1 do
		table.remove(self.Timer, self.doDelTimer[i])
	end
end

function M:InitPanel()
	self.bindData.enemyBullet.gameObject:SetActive(false)

	self.bindData.EnemyBoomCtrl = 0

	self:RefreshPlayerAnim()
	self:RefreshPlayerHp()
end

function M:RefreshPlayerHp(needDeduction)
	if needDeduction and self.bindData.HeartCtrl > 0 then
		gUIUtils:PlayOpenAni(self.bindData.heartAnim, self.HEART_ANIM_NAME[self.bindData.HeartCtrl])

		self.bindData.HeartCtrl = self.bindData.HeartCtrl - 1
	else
		self.bindData.HeartCtrl = self.MAX_HP
	end
end

function M:GetPlayerRef()
	return self.bindData.PlayerRef, self.bindData.fakePlayerBullet, self.bindData.PlayerBulletRef
end

function M:GetEnemyTeamRef()
	return self.bindData.EnemyTeamList1.transform.parent
end

function M:EnemyInOrOutDelegate(ref, isInTeam, teamId)
	if isInTeam then
		ref:SetParent(self.parentTrans[teamId], true)
	else
		ref:SetParent(self.bindData.enemyAttackArea, true)
	end
end

function M:RefreshEnemyList(enemyList)
	self.enemyList = {}

	for i, enemy in ipairs(enemyList) do
		local list = self.enemyList[enemy.teamId]

		if not list then
			list = {}
			self.enemyList[enemy.teamId] = list
		end

		table.insert(list, {
			isDead = false,
			Index = i,
			Enemy = enemy,
			EnemyType = enemy.enemyType,
			deadIcon = self:GetEnemyDeadIcon(enemy.enemyType)
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

function M:GetEnemyDeadIcon(enemyType)
	return MiniGameConfig.Bee_EnemyDead[enemyType]
end

function M:OnRenderEnemyItem(id, btn, index)
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

function M:GameOverDelegate(isNewRecord)
	self.bindData.PageCtrl = self.PAGE_TYPE.FINISH

	if isNewRecord then
		self:RefreshPlayerHeightRecord()

		self.bindData.NewRecordCtrl = self.CONTROL_TYPE.TRUE
	else
		self.bindData.NewRecordCtrl = self.CONTROL_TYPE.FALSE
	end

	self:StopPlayBgm()
	gSoundMgr:PlaySoundByTid(70600228)
	gUIUtils:PlayOpenAni(self.bindData.openAndCloseAnim, self.PANEL_CLOSE_ANIM_NAME)
end

function M:OnEnemyDead(enemy, state)
	self.bindData.enemyBoomRef.transform.position = enemy.ref.position
	self.bindData.EnemyBoomCtrl = enemy.enemyType

	gUIUtils:PlayOpenAni(self.bindData.enemyBoomAnim, self.ENEMY_BOOM_ANIM_NAME[enemy.enemyType])

	enemy.store.LifeCtrl = self.ENEMY_TYPE.DEAD

	gSoundMgr:PlaySoundByTid(70600221)
end

function M:RefreshPlayerAnim()
	self.bindData.PlayerCtrl = self.PLAYER_TYPE.ALIVE

	gUIUtils:SkipAni(self.bindData.playerAnim, self.PLAYER_INVINCIBLE_ANIM_NAME)
	gUIUtils:PlayOpenAni(self.bindData.playerAnim, self.PLAYER_NORMAL_ANIM_NAME)
end

function M:OnPlayerDead()
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

function M:SetBulletIcon(enemyType)
	self.bindData.EnemyBulletCtrl = enemyType
end

function M:CreateBullet(bulletId)
	local ref = SGUITools.AddChild(self.bindData.enemyAttackArea, self.bindData.enemyBullet.gameObject)

	return ref
end

function M:SetBattleBg(level)
	local count = #MiniGameConfig.Bee_BattleBg

	if count > 0 then
		self.bindData.newBattleBg = MiniGameConfig.Bee_BattleBg[level % count + 1]
	end

	if level == 1 then
		self.bindData.oldBattleBg = self.bindData.newBattleBg
	else
		local length = gUIUtils:PlayOpenAni(self.bindData.changeBgAnim, self.CHANGE_BG_ANIM_NAME)
		self.changeBgTimer = Timer.New(function ()
			self.changeBgTimer = nil
			self.bindData.oldBattleBg = self.bindData.newBattleBg
		end, length):Start()
	end
end

function M:OnBtnStartClick()
	self.bindData.PageCtrl = self.PAGE_TYPE.GAME
	self.isFinish = false

	self:SetBattleBg(1)
	self.GameManager:Init()
	self:StartPlayBgm(70600227)
end

function M:OnBtnInfoClick()
	self:ShowGameRule()
end

function M:OnBtnInfoCloseClick()
	self.bindData.PageCtrl = self.PAGE_TYPE.START
end

function M:OnBtnBackClick()
	if not self.isFinish then
		self.GameManager:UpdateScore(function ()
			gSceneGameRuleManager:DestroyGameRule(gSceneGameRuleManager.GameRuleType.Galaxian)
		end)
	else
		gSceneGameRuleManager:DestroyGameRule(gSceneGameRuleManager.GameRuleType.Galaxian)
	end

	gPanelManager:SetActiveById(gPanelId.S_ARCADE_GALA_PANEL, false)
end

function M:OnListLayoutSet(index)
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

function M:OnBtnShootDown()
	self.IsPressShoot = true

	if self.bindData.PlayerCtrl == self.PLAYER_TYPE.ALIVE then
		gUIUtils:PlayOpenAni(self.bindData.playerAnim, self.PLAYER_GUN_ANIM_NAME)
	end
end

function M:OnBtnShootUp()
	self.IsPressShoot = false

	gUIUtils:PlayOpenAni(self.bindData.playerAnim, self.PLAYER_NORMAL_ANIM_NAME)
end

function M:OnBtnLeftDown()
	self.MoveLeft = true
end

function M:OnBtnLeftUp()
	self.MoveLeft = false
end

function M:OnBtnRightDown()
	self.MoveRight = true
end

function M:OnBtnRightUp()
	self.MoveRight = false
end

function M:OnJoystickValueChange(x, y, size)
	self.MoveJs = x
end

function M:OnPlayerMove(context)
	if not self.STATE_EnableOnce then
		return
	end

	self.MoveJs = context:ReadValueVector2().x
end
