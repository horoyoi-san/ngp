local static_props = {}
gSimulatorGame = DefClass("SimulatorGame", gSimulatorGame, gBaseMiniGame, static_props)
local M = gSimulatorGame

function M:Initialize(args)
	self:InitScene()
end

function M:InitScene()
	local sceneNodePath = "Res/MiniGame/Prefab/Tea/TestTea.prefab"
	self.loadOp = gResourceManager:LoadAssetWithCallBack(sceneNodePath, typeof(UnityEngine.GameObject), function (loadOp)
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

function M:CleanGame()
	self:CleanSceneObjects()
end

function M:CleanSceneObjects()
	self.context = nil
	local _ = gClientUtils.NotNil(self.sceneNodeGo) and GameObject.Destroy(self.sceneNodeGo)
	self.loadOp = gResourceManager:UnloadAssetLoadOp(self.loadOp)
	self.sceneNodeGo = nil

	self:ClosePanel()
end

function M:ClosePanel()
	return
end
