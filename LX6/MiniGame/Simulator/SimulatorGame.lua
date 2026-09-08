-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\Simulator\SimulatorGame.lua
-- Decompiled from: 00627_SimulatorGame.lua_f9fd1e327601.luajit

local static_props = {}
gSimulatorGame = DefClass("SimulatorGame", gSimulatorGame, gBaseMiniGame, static_props)
local M = gSimulatorGame

M.Initialize = function(self, args)
	self.InitScene(self)
end

M.InitScene = function(self)
	local sceneNodePath = "Res/MiniGame/Prefab/Tea/TestTea.prefab"
	slot2 = gResourceManager
	self.loadOp = slot2:LoadAssetWithCallBack(sceneNodePath, typeof(UnityEngine.GameObject), function (loadOp)
		if not self.hasDestroy then
			local sceneNodeGo = GameObject.Instantiate(loadOp.asset)
			self.sceneNodeGo = sceneNodeGo
			sceneNodeGo.gameObject.name = "FarmSceneNode"
			local playerPosition = gClientUtils.GetPlayerPosition()
			sceneNodeGo.gameObject.transform.position = Vector3.New(playerPosition.X + 3, 0, playerPosition.Z + 3)
			local context = sceneNodeGo.gameObject:GetComponent(typeof(L50.Gameplay.MiniGameContext))
			self.context = context
		end
	end)
end

M.CleanGame = function(self)
	self.CleanSceneObjects(self)
end

M.CleanSceneObjects = function(self)
	self.context = nil
	local _ = gClientUtils.NotNil(self.sceneNodeGo) and GameObject.Destroy(self.sceneNodeGo)
	self.loadOp = gResourceManager:UnloadAssetLoadOp(self.loadOp)
	self.sceneNodeGo = nil

	self:ClosePanel()
end

M.ClosePanel = function(self)
end
