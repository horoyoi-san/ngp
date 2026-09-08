-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\ShuttlecockGame\ShuttlecockCharacter.lua
-- Decompiled from: 00607_ShuttlecockCharacter.lua_42b7cc5b5d25.luajit

local UnitModelManager = LX6.Units.UnitModelManager
local static_props = {
	CHARACTER_STATUS = {
		["\\xe9\\xf75$7\n\\xd6"] = 2,
		["\\xabFB"] = 4,
		["SQ~"] = 1,
		["\\Tw"] = 3
	},
	GAME_STATUS = {
		["}\\x8f\\x97\\x9c\\x93"] = 3,
		["\\xabFB"] = 4,
		["~\\x9a\\x83\\x9d\\x82"] = 2,
		["T\rS~"] = 1
	}
}
gShuttlecockCharacter = DefClass("ShuttlecockCharacter", gShuttlecockCharacter, nil, static_props)
local ShuttlecockCharacter = gShuttlecockCharacter

ShuttlecockCharacter.ctor = function(self, args)
	self.InitData(self, args)
	self.InitCharacter(self)
end

ShuttlecockCharacter.InitCharacter = function(self)
	self.InitAnimatorController(self, function ()
		self:LoadCharacterModel()
	end)
end

ShuttlecockCharacter.InitAnimatorController = function(self, callback)
	local cfg = self:GetShuttlecockConfig()
	local animatorControllerPath = cfg.AnimatorControllerPath
	slot4 = gResourceManager
	self.loadOp = slot4:LoadAssetWithCallBack(animatorControllerPath, typeof(UnityEngine.AnimatorOverrideController), function (loadOp)
		if self.hasDestroy then
			return
		end

		self.animatorController = loadOp.asset

		callback()
	end)
end

ShuttlecockCharacter.LoadCharacterModel = function(self)
end

ShuttlecockCharacter.OnCharacterLoadCompleted = function(self, baseUnit)
	if self.hasDestroy then
		baseUnit = baseUnit and baseUnit:DestroyUnit(true)

		return
	end

	self.baseUnit = baseUnit
	self.transform = baseUnit.ModelSlot.transform

	UnitModelManager.SetShadow(baseUnit, true)
	self.InitNodes(self)
	self.InitPosition(self)
	self.InitAnimationEvents(self)
end

ShuttlecockCharacter.InitPosition = function(self)
	self.transform.position = self.playerPoint.position
	self.transform.rotation = self.playerPoint.rotation
end

ShuttlecockCharacter.InitNodes = function(self)
	self.playerNode = self.transform:Find("player")
	self.animator = self.playerNode:GetOrAddComponent(typeof(UnityEngine.Animator))
	self.animator.runtimeAnimatorController = self.animatorController
	self.animationEvents = self.playerNode.gameObject:GetOrAddComponent(typeof(L18.MiniGame.AnimationEventLuaReceiver))
end

ShuttlecockCharacter.InitAnimationEvents = function(self)
end

ShuttlecockCharacter.InitData = function(self, args)
	self.lookAtPoint = args.lookAtPoint
	self.virtualCamera = args.virtualCamera
	self.playerPoint = args.playerPoint
	self.id = args.id
	self.gameStatus = ShuttlecockCharacter.GAME_STATUS.NONE
	self.characterStatus = ShuttlecockCharacter.CHARACTER_STATUS.IDLE
end

ShuttlecockCharacter.StartGame = function(self, startId)
end

ShuttlecockCharacter.Destroy = function(self)
	self.ClearCoroutines(self)

	self.hasDestroy = true
	self.transform = nil

	if gClientUtils.NotNil(self.animator) then
		self.animator.runtimeAnimatorController = nil
	end

	self.animator = nil
	self.animatorController = nil

	if self.baseUnit then
		self.baseUnit:DestroyUnit(true)

		self.baseUnit = nil
	end

	self.loadOp = gResourceManager:UnloadAssetLoadOp(self.loadOp)
end

ShuttlecockCharacter.ClearCoroutines = function(self)
end

ShuttlecockCharacter.GameOver = function(self)
	self.gameStatus = ShuttlecockCharacter.GAME_STATUS.END

	self.ClearCoroutines(self)
end

ShuttlecockCharacter.IsGameOver = function(self)
	return self.gameStatus ~= ShuttlecockCharacter.GAME_STATUS.END
end

ShuttlecockCharacter.Reset = function(self)
	self.characterStatus = ShuttlecockCharacter.CHARACTER_STATUS.IDLE
	self.gameStatus = ShuttlecockCharacter.GAME_STATUS.NONE

	self.InitPosition(self)
end

ShuttlecockCharacter.Pause = function(self)
	if self.gameStatus ~= ShuttlecockCharacter.GAME_STATUS.START then
		self.gameStatus = ShuttlecockCharacter.GAME_STATUS.PAUSE
	end
end

ShuttlecockCharacter.Resume = function(self)
	if self.gameStatus ~= ShuttlecockCharacter.GAME_STATUS.PAUSE then
		self.gameStatus = ShuttlecockCharacter.GAME_STATUS.START
	end
end
