-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\BasketballGame\BasketballNpcCharacter.lua
-- Decompiled from: 00587_BasketballNpcCharacter.lua_abf42b4ecbcf.luajit

gBasketballNpcCharacter = DefClass("BasketballNpcCharacter", gBasketballNpcCharacter, gBasketballCharacter)
local BasketballNpcCharacter = gBasketballNpcCharacter

BasketballNpcCharacter.InitData = function(self, basketballRackList)
	BasketballNpcCharacter.base.InitData(self, basketballRackList)

	self.hitRateList = self.GetHitRateList(self)
	self.playerIndex = 2
end

BasketballNpcCharacter.GetHitRateList = function(self)
	local config = self.GetBasketballShootConfig(self)

	return config.ScoreRate
end

BasketballNpcCharacter.LoadCharacterModel = function(self)
	local agentTemplateId = self.id
	slot2 = gCS.LocalUnitMgr
	local targetBaseUnit = slot2:GetNpcByTemplateId(agentTemplateId)

	local Onload = function(baseUnit, _)
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

BasketballNpcCharacter.GetBasketballShootConfig = function(self)
	local npcCfg = LTConfig.AgentConfig.GetConfig(self.id)

	if not npcCfg then
		print_error("@linminghe BasketballNpcCharacter npcCfg nil, id:", self.id)

		return
	end

	local modelId = npcCfg.GeneralModelId

	return gBasketballGameUtils.GetBasketballShootConfigByModelId(modelId)
end

BasketballNpcCharacter.StartGame = function(self)
	BasketballNpcCharacter.base.StartGame(self)
	self.SetAnimatorBool(self, self.animConst.bMirror, true)
	self.AutoStartShoot(self)
end

BasketballNpcCharacter.AutoStartShoot = function(self)
	self.autoStartCoroutine = coroutine.start(function ()
		while not self:CheckCanShoot() do
			coroutine.wait(0.1)
		end

		local shootType = self:GetShootTypeByHitRateList(self.hitRateList)

		self:PlayShootAnimation()

		if self.id ~= 42071029 then
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

BasketballNpcCharacter.SendRefreshViewMessage = function(self)
	gMessageManager:SendMessage(gEventConstants.BASKETBALL_GAME_REFRESH_NPC_VIEW, {
		totalScore = self.score,
		countdown = self.countdown
	})
end

BasketballNpcCharacter.CheckShootConflict = function(self)
	return gBasketballGameManager.currentGame:CheckShootTimeConflict(false)
end

BasketballNpcCharacter.ClearCoroutines = function(self)
	BasketballNpcCharacter.base.ClearCoroutines(self)

	self.autoStartCoroutine = coroutine.stop(self.autoStartCoroutine)
end
