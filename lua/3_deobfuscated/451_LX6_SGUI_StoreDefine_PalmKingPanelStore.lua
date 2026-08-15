C_PalmKingPanelStore = DefClass("C_PalmKingPanelStore", C_PalmKingPanelStore, C_StoreGroup)
GroupName2Class.PalmKingPanelStore = C_PalmKingPanelStore
local M = C_PalmKingPanelStore

function M:ctor()
	self.DIRECTION = {
		RIGHT_UPPER = 2,
		RIGHT_LOWER = 4,
		LEFT_LOWER = 3,
		LEFT_UPPER = 1
	}
	self.DIRECTION_COLOR = {
		BLUE = 2,
		NORMAL = 0,
		RED = 1
	}
	self.HUD_TYPE = {
		PLAY = 2,
		END = 6,
		OPPOSITE_QTE = 7,
		WAIT = 4,
		ROUND = 0,
		DEFEND = 3,
		QTE = 5,
		CHANGE = 1
	}
	self.QTE_TYPE = {
		RIGHT = 4,
		UP = 1,
		LEFT = 3,
		DOWN = 2
	}
end

function M:OnAwake()
	self.bindData.backBtn.luaClick = self:CreateAction("OnBackBtnClick")
	self.bindData.hitBtn.luaClick = self:CreateAction("OnPalmBtnClick")
	self.bindData.defineBtn.luaClick = self:CreateAction("OnPalmBtnClick")
	self.bindData.qteList.luaRenderItem = self:CreateAction("OnRenderQTEItem")
	self.bindData.mouseMoveRespond.luaGamePadInputChanged = self:CreateAction("OnMouseMove")
	self.bindData.upBtn.luaClick = self:CreateAction("OnUpBtnClick")
	self.bindData.downBtn.luaClick = self:CreateAction("OnDownBtnClick")
	self.bindData.leftBtn.luaClick = self:CreateAction("OnLeftBtnClick")
	self.bindData.rightBtn.luaClick = self:CreateAction("OnRightBtnClick")
	self.bindData.joystick.luaValueChanged = self:CreateAction("OnJoyStickValueChange")
	self.bindData.controllerMoveRespond.luaGamePadInputChanged = self:CreateAction("OnControllerMove")

	self.bindData.qteWgt:SetActive(false)

	self.isInitGame = false
	self.slapAIId = 100
	self.npcId = 42071200
end

function M:OnShow(panelId, data)
	self.data = data

	if data.slapAIId then
		self.slapAIId = data.slapAIId
	end

	self.slapCfg = LTConfig.PoiGameSlapAIConfig.GetConfig(self.slapAIId)
	self.npcId = self.slapCfg.ModelID[1]

	gPalmKingInterface:Init()

	if self.data and self.data[3] then
		self:LoadSceneNode(self.data[3].gameObject)
	end

	self:InitData()
	self:InitGame()
end

function M:OnUpdate()
	gPalmKingManager:Update(Time.deltaTime)
end

function M:OnClose()
	gPalmKingAction.npcUnit:DestroyUnit(true)
	gResourceManager:UnloadAssetLoadOp(self.sceneNodeOp)

	if self.sceneNodeGo and not gCS.LuaUtils.IsNull(self.sceneNodeGo) then
		GameObject.Destroy(self.sceneNodeGo)
	end

	if self.waitTimer then
		self.waitTimer:Stop()

		self.waitTimer = nil
	end

	if self.playTimer then
		self.playTimer:Stop()

		self.playTimer = nil
	end

	if self.progressTimer then
		self.progressTimer:Stop()

		self.progressTimer = nil
	end

	if self.waitResultTextTimer then
		self.waitResultTextTimer:Stop()

		self.waitResultTextTimer = nil
	end
end

function M:InitData()
	self:InitDirectionList()
	self:InitNameAndIcon()
end

function M:InitGame()
	gPalmKingManager:Init()
	gPalmKingManager:GameStart()
end

function M:LoadSceneNode(parent)
	local sceneNodePath = "Res/MiniGame/Prefab/Slap/SlapSceneNode.prefab"
	self.sceneNodeOp = gResourceManager:LoadAssetWithCallBack(sceneNodePath, typeof(UnityEngine.GameObject), function (loadOp)
		local sceneNodeGo = UnityEngine.GameObject.Instantiate(loadOp.asset)
		sceneNodeGo.gameObject.name = "SlapSceneNode"

		sceneNodeGo.gameObject.transform:SetParent(parent.transform)
		sceneNodeGo.gameObject.transform:SetLocalPosition(Vector3.zero)

		sceneNodeGo.gameObject.transform.localRotation = Quaternion.Euler(0, 0, 0)
		self.sceneNodeGo = sceneNodeGo

		self:InitSceneNode()
	end)
end

function M:InitSceneNode()
	self.node = self.sceneNodeGo.transform:GetComponent(typeof(L18.Gameplay.SlapSceneNode))

	self:SetCamera(1, 0)
	self:LoadNpc(self.npcId)
	self:LoadOtherNpc()
end

function M:LoadOtherNpc()
	if not self.node.otherNPCPoint then
		return
	end

	local npcIdList = LTConfig.PoiGameConfig.Slap_NPCPool

	for i, v in ipairs(npcIdList) do
		if self.node.otherNPCPoint.Count < i then
			return
		end

		local go = self.node.otherNPCPoint[i - 1]
		local trans = go.transform

		gCS.LuaUtils.CreateLocalUnit(v, trans.position, trans.eulerAngles, function (baseUnit)
			baseUnit.PlayerObj:SetParent(go)

			baseUnit.PlayerObj.localPosition = Vector3.zero
			baseUnit.PlayerObj.localEulerAngles = Vector3.zero
		end)
	end
end

function M:LoadNpc(cfgId)
	local goNpc = self:GetGoNpc()

	if not goNpc then
		return
	end

	local trans = goNpc.transform
	local npc = gCS.LuaUtils.CreateLocalUnit(cfgId, trans.position, trans.eulerAngles, function (baseUnit)
		gCS.BaseUnitUtils.ScheduleBehaviorTask(baseUnit.Pid, 1001023)

		gPalmKingAction.npcUnit = baseUnit
	end)
	npc.ValidCulling = false

	npc:RefreshCullingStatus()

	npc.forbidAetherAI = true
end

function M:GetGoNpc()
	if self.node then
		return self.node.goNpc
	end
end

function M:InitDirectionList()
	self.lastSelect = 1
	self.directionList = {}

	for i = 1, 4 do
		self.directionList[i] = self.bindData["IndicatorTemplate" .. i]
	end
end

function M:InitNameAndIcon()
	self.bindData.leftPlayerIcon = gHunLunManager:GetHeadIconAndName(gPlayerManager.infoLogin.bindData.infoPzHeadInfo.SystemHeadId)
	self.bindData.leftPlayerName = gPlayerManager.infoLogin.bindData.name
	local cfg = LTConfig.AgentConfig.GetConfig(self.npcId)

	if cfg then
		self.bindData.rightPlayerName = cfg.Name
		self.bindData.rightPlayerIcon = cfg.HeadIcon
	end

	self:SetMeHp(gPalmKingInterface:GetMeMaxHp())
	self:SetOtherHp(gPalmKingInterface:GetOtherMaxHp())
end

function M:OnRenderQTEItem(btn, _, data)
	self.qteList[data.id] = btn
	local store = gStoreManager:GetStoreGroup("PalmKingQTETemplateStore"):GetStoreByWidget(btn)
	store.direction = data.direction - 1
end

function M:SetSelect(index)
	if self.lastSelect == index then
		return
	end

	if not index or index < 1 or index > 4 then
		return
	end

	self.bindData.joystickCtrl = index

	gSoundMgr:PlaySoundByExternalSource("ExHandle_QTECommon1", LX6.Audio.ExternalSourceType.Motion_2D)

	if self.lastSelect then
		self:SetDirectionColor(self.lastSelect, self.DIRECTION_COLOR.NORMAL)
	end

	if not gPalmKingGamer.isdefence then
		self:SetDirectionColor(index, self.DIRECTION_COLOR.RED)
		self:SetAttackDirectionUI(index)
	else
		self:SetDirectionColor(index, self.DIRECTION_COLOR.BLUE)
		gPalmKingManager:SyncDefence(index)
	end

	self.lastSelect = index
end

function M:SetAttackDirectionUI(index)
	local rotateValues = LTConfig.PoiGameConfig.Slap_AttackDirRotate

	self.bindData.attackDirectionWidget:DORotate(Vector3.New(0, 0, rotateValues[index]), 0.2, DG.Tweening.RotateMode.Fast)
end

function M:SetDirectionColor(index, color)
	local storeName = "PalmKingIndicatorTemplateStore"
	local store = gStoreManager:GetStoreGroup(storeName):GetStoreByWidget(self.directionList[index])
	store.color = color
end

function M:OnMouseMove(context)
	local dir = nil

	if gPalmKingGamer.isdefence then
		dir = gCS.LuaUtils.GetMousePositionInQuadrant(self.bindData.defencePoint)
	else
		dir = gCS.LuaUtils.GetMousePositionInQuadrant(self.bindData.attackPoint)
	end

	if dir == self.DIRECTION.RIGHT_UPPER then
		dir = self.DIRECTION.LEFT_UPPER
	elseif dir == self.DIRECTION.LEFT_UPPER then
		dir = self.DIRECTION.RIGHT_UPPER
	end

	if dir and self:IsCanMouseMove() then
		self:SetSelect(dir)

		if gPalmKingGamer.isdefence then
			dir = self:GetMirrorDir(dir)
		else
			gPalmKingGamer.hitDir = dir
		end

		gPalmKingAction:Change(dir)
	end
end

function M:GetRectTransformCenter()
	return Vector3.New(UnityEngine.Screen.width / 2, UnityEngine.Screen.height / 2, 0)
end

function M:GetMirrorDir(dir)
	local mirrorDir = {
		[self.DIRECTION.LEFT_UPPER] = self.DIRECTION.RIGHT_UPPER,
		[self.DIRECTION.RIGHT_UPPER] = self.DIRECTION.LEFT_UPPER,
		[self.DIRECTION.LEFT_LOWER] = self.DIRECTION.RIGHT_LOWER,
		[self.DIRECTION.RIGHT_LOWER] = self.DIRECTION.LEFT_LOWER
	}

	return mirrorDir[dir] or dir
end

function M:IsCanMouseMove()
	return gPalmKingManager.nowState == gPalmKingManager.STATE.PREPARE
end

function M:SetMeHp(num)
	self.bindData.leftPlayerProgress = num / gPalmKingInterface:GetMeMaxHp()

	if num < 0 then
		num = 0
	end

	self.bindData.leftPlayerProgressText = num .. "/" .. gPalmKingInterface:GetMeMaxHp()
end

function M:SetOtherHp(num)
	self.bindData.rightPlayerProgress = num / gPalmKingInterface:GetOtherMaxHp()

	if num < 0 then
		num = 0
	end

	self.bindData.rightPlayerProgressText = num .. "/" .. gPalmKingInterface:GetOtherMaxHp()
end

function M:SetQTEProgress(num)
	self.bindData.qtrProgress.fillAmount = num / gPalmKingManager.Config.maxQTETime
	self.bindData.qteCountDown = math.ceil(num)
end

function M:SetCurState(hudType)
	if self.lastSelect then
		self:SetDirectionColor(self.lastSelect, self.DIRECTION_COLOR.NORMAL)
	end

	self.bindData.hudType = hudType

	if hudType == self.HUD_TYPE.ROUND then
		-- Nothing
	elseif hudType == self.HUD_TYPE.PLAY then
		self.bindData.joystickCtrl = 0

		self:SetAttackDirectionUI(1)
		self:SetDirectionColor(1, self.DIRECTION_COLOR.RED)

		self.lastSelect = 1

		LX6.Manager.GameInputManager.SetCursorPositionInPC(UnityEngine.Screen.width / 2, UnityEngine.Screen.height / 2)
		self:PlayState()
	elseif hudType == self.HUD_TYPE.DEFEND then
		self.bindData.joystickCtrl = 0

		self:SetDirectionColor(1, self.DIRECTION_COLOR.BLUE)

		self.lastSelect = 1

		LX6.Manager.GameInputManager.SetCursorPositionInPC(UnityEngine.Screen.width / 2, UnityEngine.Screen.height / 2)
		self:PlayProgress()
	elseif hudType == self.HUD_TYPE.CHANGE then
		-- Nothing
	elseif hudType == self.HUD_TYPE.WAIT then
		-- Nothing
	elseif hudType == self.HUD_TYPE.QTE then
		self:QTEState()
	elseif hudType == self.HUD_TYPE.OPPOSITE_QTE then
		self:QTEState()
	elseif hudType == self.HUD_TYPE.END then
		-- Nothing
	end
end

function M:RefreshQteList(qtes)
	local list = {}

	for i, v in pairs(qtes) do
		if not v.success then
			local data = {
				id = i,
				direction = v.direction
			}

			table.insert(list, data)
		end
	end

	self.bindData.qteList:SetList(list)
end

function M:QTEState()
	self.bindData.qteWgt.transform.position = Vector3.New(9999, 0, 0)
	local qtelist = gPalmKingInterface:GetQTEList()
	local list = {}

	for i, v in pairs(qtelist) do
		local data = {
			id = i,
			direction = v
		}

		table.insert(list, data)
	end

	self.qteList = {}

	self.bindData.qteList:SetList(list)

	if self.waitTimer then
		self.waitTimer:Stop()

		self.waitTimer = nil
	end

	self.waitTimer = Timer.New(function ()
		self:SetQTEPos(0)
	end, 0.5):Start()
end

function M:PlayState()
	self:PlayGame()
end

function M:PlayGame()
	self.isInitGame = true

	self:PlayProgress()
end

function M:PlayProgress()
	self:StopForceProgress()

	self.currentValue = 0
	local direction = 1
	local maxValue = 0.09
	self.progressTimer = Timer.New(function ()
		self.currentValue = self.currentValue + 0.05 * direction

		if self.currentValue >= 1 then
			self.currentValue = 1
			direction = -1
		elseif self.currentValue <= 0 then
			self.currentValue = 0
			direction = 1
		end

		self.bindData.progress:ProgressToValue(self.currentValue)

		self.bindData.forceProgress1 = self.currentValue * maxValue
		self.bindData.forceProgress2 = self.currentValue * maxValue
	end, 0.05, -1):Start()
end

function M:StopForceProgress()
	if self.progressTimer then
		self.progressTimer:Stop()

		self.progressTimer = nil
	end
end

function M:GetCurForce()
	return self.currentValue or 0
end

function M:SetCamera(type, index)
	if not self.node then
		print_error("SlapSceneNode is not loaded yet")

		return
	end

	self.node:SetCameraActive(type, index)
end

function M:SetQTEPos()
	if not self.qteList or not self.qteList[1] then
		return
	end

	self.bindData.qteWgt.transform.position = self.qteList[1].transform.position
end

function M:OnControllerMove(context)
	local vector2 = context:ReadValueVector2()

	self:OnJoyStickValueChange(vector2.x, vector2.y)
end

function M:OnPalmBtnClick()
	if not self:IsCanMouseMove() then
		return
	end

	self:Do_PalmBtnClick()
end

function M:Do_PalmBtnClick()
	self:StopForceProgress()

	if gPalmKingGamer.isdefence then
		local select = self:GetMirrorDir(self.lastSelect)

		print_debug("防御  方向 ：--------》" .. select)
		gPalmKingAction:PrepareDefend(select)
		gPalmKingInterface:PlayerDefence(select, true)
	else
		print_debug("打出  方向 ：--------》" .. self.lastSelect .. "  力道  -->  " .. self.currentValue)
		self:SetCamera(1, 2)
		gPalmKingAction:Attack(self.lastSelect)
		gPalmKingInterface:PlayerHit(self.lastSelect, self.currentValue)
	end
end

function M:OnUpBtnClick()
	if gPalmKingGamer.isdefence then
		gPalmKingInterface:SendQTE(self.QTE_TYPE.UP)
	end
end

function M:OnDownBtnClick()
	if gPalmKingGamer.isdefence then
		gPalmKingInterface:SendQTE(self.QTE_TYPE.DOWN)
	end
end

function M:OnLeftBtnClick()
	if gPalmKingGamer.isdefence then
		gPalmKingInterface:SendQTE(self.QTE_TYPE.LEFT)
	end
end

function M:OnRightBtnClick()
	if gPalmKingGamer.isdefence then
		gPalmKingInterface:SendQTE(self.QTE_TYPE.RIGHT)
	end
end

function M:OnBackBtnClick()
	gPalmKingManager:GameEnd()
end

function M:OnJoyStickValueChange(x, y, size)
	if x == 0 and y == 0 then
		return
	end

	local dir = nil

	if x > 0 then
		if y > 0 then
			dir = self.DIRECTION.RIGHT_UPPER
		else
			dir = self.DIRECTION.RIGHT_LOWER
		end
	elseif y > 0 then
		dir = self.DIRECTION.LEFT_UPPER
	else
		dir = self.DIRECTION.LEFT_LOWER
	end

	if dir and self:IsCanMouseMove() then
		self:SetSelect(dir)

		if gPalmKingGamer.isdefence then
			dir = self:GetMirrorDir(dir)
		end

		gPalmKingAction:Change(dir)
	end
end

function M:SetHpText(type, num)
	self.bindData.hpNum = "-" .. num
	self.bindData.resultTextCtrl = type

	if self.waitResultTextTimer then
		self.waitResultTextTimer:Stop()

		self.waitResultTextTimer = nil
	end

	self.waitResultTextTimer = Timer.New(function ()
		self.bindData.resultTextCtrl = 0
	end, 3):Start()
end
