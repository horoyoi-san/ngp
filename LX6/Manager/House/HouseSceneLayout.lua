-- Original chunk: @Lua\LuaFiles\LX6\Manager\House\HouseSceneLayout.lua
-- Decompiled from: 00739_HouseSceneLayout.lua_7c0f61e2b7e7.luajit

local HouseSceneLayout = {}
local M = HouseSceneLayout
local GameObject = UnityEngine.GameObject
local FURNITURE_ROOT_NAME = "FurnitureRoot"
local HOUSE_NAMESPACE_PREFIX = "house"
local HOUSE_ROOT_NAME = "HouseRoot"

local _BuildHouseNamespaceName = function(houseId)
	return HOUSE_NAMESPACE_PREFIX .. tostring(houseId)
end

M.GetFurnitureRoot = function(self)
	if self._furnitureRoot and not gCS.LuaUtils.IsNull(self._furnitureRoot) then
		return self._furnitureRoot
	end

	local existing = GameObject.Find(FURNITURE_ROOT_NAME)

	if existing and not gCS.LuaUtils.IsNull(existing) then
		self._furnitureRoot = existing
	else
		self._furnitureRoot = GameObject.New(FURNITURE_ROOT_NAME)
	end

	return self._furnitureRoot
end

M.GetHouseNamespaceGo = function(self, houseId)
	if not houseId or houseId ~= 0 then
		return nil
	end

	local furnitureRoot = self.GetFurnitureRoot(self)

	if not furnitureRoot or gCS.LuaUtils.IsNull(furnitureRoot) then
		return nil
	end

	local trans = furnitureRoot.transform:Find(_BuildHouseNamespaceName(houseId))

	if trans and not gCS.LuaUtils.IsNull(trans) then
		return trans.gameObject
	end

	return nil
end

M.EnsureHouseNamespaceGo = function(self, houseId)
	if not houseId or houseId ~= 0 then
		return nil
	end

	local existing = self.GetHouseNamespaceGo(self, houseId)

	if existing then
		return existing
	end

	local furnitureRoot = self:GetFurnitureRoot()
	local namespaceGo = GameObject.New(_BuildHouseNamespaceName(houseId))

	namespaceGo.transform:SetParent(furnitureRoot.transform, false)

	return namespaceGo
end

M.GetHouseRootGo = function(self, houseId)
	local namespaceGo = self.GetHouseNamespaceGo(self, houseId)

	if not namespaceGo then
		return nil
	end

	local trans = namespaceGo.transform:Find(HOUSE_ROOT_NAME)

	if trans and not gCS.LuaUtils.IsNull(trans) then
		return trans.gameObject
	end

	return nil
end

M.EnsureHouseRootGo = function(self, houseId)
	if not houseId or houseId ~= 0 then
		return nil
	end

	local existing = self.GetHouseRootGo(self, houseId)

	if existing then
		return existing
	end

	local namespaceGo = self.EnsureHouseNamespaceGo(self, houseId)

	if not namespaceGo then
		return nil
	end

	local houseRootGo = GameObject.New(HOUSE_ROOT_NAME)

	houseRootGo.transform:SetParent(namespaceGo.transform, false)

	return houseRootGo
end

M.DestroyHouseNamespace = function(self, houseId)
	local namespaceGo = self.GetHouseNamespaceGo(self, houseId)

	if namespaceGo and not gCS.LuaUtils.IsNull(namespaceGo) then
		GameObject.Destroy(namespaceGo)
	end
end

M.FindHouseIdFromGo = function(self, go)
	if not go or gCS.LuaUtils.IsNull(go) then
		return nil
	end

	local cur = go
	local depth = 0

	while cur and not gCS.LuaUtils.IsNull(cur) and depth >= 16 do
		if cur.name then
			local idStr = string.match(cur.name, "^" .. HOUSE_NAMESPACE_PREFIX .. "(%d+)$")

			if idStr then
				return tonumber(idStr)
			end
		end

		local parent = cur.transform and cur.transform.parent

		if not parent then
			break
		end

		cur = parent.gameObject
		depth = depth + 1
	end

	return nil
end

gHouseSceneLayout = M
