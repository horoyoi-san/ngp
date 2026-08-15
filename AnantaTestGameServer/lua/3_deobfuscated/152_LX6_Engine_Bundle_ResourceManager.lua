local ResourceManager = LX6.Engine.ResourceManager
local M = {
	Init = function (self)
		self.Manager = ResourceManager.Instance
	end,
	LoadAsset = function (self, path, resType)
		return self.Manager:LoadAsset(path, resType)
	end,
	LoadAssetAsync = function (self, path, resType, priority)
		if priority == nil then
			priority = ResourceManager.LOAD_PRIORITY.PRIORITY_LEVEL2
		end

		return self.Manager:LoadAssetAsync(path, resType, priority)
	end,
	LoadAssetWithCallBack = function (self, path, resType, callback, priority)
		if priority == nil then
			priority = ResourceManager.LOAD_PRIORITY.PRIORITY_LEVEL2
		end

		return self.Manager:LoadAssetWithCallBack(path, resType, callback, priority)
	end,
	AddAssetTaskOp = function (self, groupId, path, loadOp)
		self.Manager:AddAssetTaskOp(groupId, path, loadOp)
	end,
	UnloadAssetLoadOp = function (self, loadOp)
		if loadOp then
			self.Manager:UnloadAsset(loadOp)
		end
	end,
	UnloadAsset = function (self, groupId, assetPath)
		self.Manager:UnloadAssetTaskOp(groupId, assetPath)
	end,
	UnloadAssetGroup = function (self, groupId)
		self.Manager:UnloadAssetTaskOpGroup(groupId)
	end,
	LoadScene = function (self, sceneName)
		return self.Manager:LoadScene(sceneName)
	end,
	LoadSceneAdditively = function (self, sceneName)
		return self.Manager:LoadSceneAdditively(sceneName)
	end,
	UnloadLastScene = function (self)
		return self.Manager:UnloadLastScene()
	end,
	AddInstanceToCache = function (self, gameObject)
		self.Manager:AddInstanceToCache(gameObject)
	end,
	IsSubSectorLoadingBusy = function (self, count)
		return self.Manager:IsSubSectorLoadingBusy(count)
	end,
	InsideColliderAllLoaded = function (self)
		return self.Manager.InsideColliderAllLoaded
	end,
	InsideSubSectorLoadingBusy = function (self, subSectorLoadingCount)
		return self.Manager.InsideSectorLoadingCount > 0 or subSectorLoadingCount < self.Manager.InsideSubSectorLoadingCount
	end,
	IsAssetLoadingBusy = function (self, count)
		return self.Manager:IsAssetLoadingBusy(count)
	end,
	EnterLoadingMode = function (self, isLoading)
		self.Manager:EnterLoadingMode(isLoading)
	end,
	GetXinqiPlayMode = function (self)
		return self.Manager.GetXinqiPlayMode()
	end,
	ManualUpdateSectorCollider = function (self)
		self.Manager:ManualUpdateSectorCollider()
	end
}

M:Init()

gResourceManager = M
