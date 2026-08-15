gBasketballNpcCharacter = DefClass("BasketballNpcCharacter", gBasketballNpcCharacter, gBasketballCharacter)
local BasketballNpcCharacter = gBasketballNpcCharacter

function BasketballNpcCharacter:InitData(basketballRackList)
	BasketballNpcCharacter.base.InitData(self, basketballRackList)

	self.hitRateList = self:GetHitRateList()
	self.playerIndex = 2
end

function BasketballNpcCharacter:GetHitRateList()
	local config = self:GetBasketballShootConfig()

	return config.ScoreRate
end

function BasketballNpcCharacter:LoadCharacterModel()
	local agentTemplateId = self.id
	local targetBaseUnit = gCS.NpcMgr:GetNpcByTemplateId(agentTemplateId)

	local function Onload(baseUnit, _)
		BasketballNpcCharacter.base.OnCharacterLoadCompleted(self, baseUnit)
	end

	local args = LX6.Utils.LuaUtils.CreateDialogModelArgs.New()
	args.AgentId = agentTemplateId
	args.OnLoad = Onload
	args.TargetUnit = targetBaseUnit
	args.IgnoreLOD = true
	args.WithWeapon = true

	gCS.LuaUtils.GetDialogModelByAgentId(args)
end

function BasketballNpcCharacter:GetBasketballShootConfig()
	local npcCfg = LTConfig.AgentConfig.GetConfig(self.id)

	if not npcCfg then
		print_error("@linminghe BasketballNpcCharacter npcCfg nil, id:", self.id)
	end

	local modelId = npcCfg.GeneralModelId

	return gBasketballGameUtils.GetBasketballShootConfigByModelId(modelId)
end

function BasketballNpcCharacter:StartGame()
	BasketballNpcCharacter.base.StartGame(self)
	self:SetAnimatorBool(self.animConst.bMirror, true)
	self:AutoStartShoot()
end

function BasketballNpcCharacter:AutoStartShoot()
	self.autoStartCoroutine = coroutine.start(function ()
		while not self:CheckCanShoot() do
			coroutine.wait(0.1)
		end

		local shootType = self:GetShootTypeByHitRateList(self.hitRateList)

		self:PlayShootAnimation()

		if self.id == 42071029 then
			coroutine.wait(1.5)
		else
			coroutine.wait(0.5)
		end

		self:StartShoot(shootType)
		math.randomseed(os.time())

		local min, max = unpack(LTConfig.PoiGameConfig.Npc_Shoot_Random_Time)
		local waitTime = math.random(min, max)

		coroutine.wait(waitTime)
		self:AutoStartShoot()
	end)
end

function BasketballNpcCharacter:SendRefreshViewMessage()
	gMessageManager:SendMessage(gEventConstants.BASKETBALL_GAME_REFRESH_NPC_VIEW, {
		totalScore = self.score,
		countdown = self.countdown
	})
end

function BasketballNpcCharacter:CheckShootConflict()
	return gBasketballGameManager.currentGame:CheckShootTimeConflict(false)
end

function BasketballNpcCharacter:ClearCoroutines()
	BasketballNpcCharacter.base.ClearCoroutines(self)

	self.autoStartCoroutine = coroutine.stop(self.autoStartCoroutine)
end
