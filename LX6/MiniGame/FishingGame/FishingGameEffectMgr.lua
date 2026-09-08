-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\FishingGame\FishingGameEffectMgr.lua
-- Decompiled from: 00596_FishingGameEffectMgr.lua_5b21669d1a3a.luajit

C_FishingGameEffectMgr = DefClass("C_FishingGameEffectMgr", C_FishingGameEffectMgr)
local M = C_FishingGameEffectMgr
local GameObject = UnityEngine.GameObject

M.ctor = function(self)
	self.resPath = "Res/MiniGame/Prefab/FishingGame/%s.prefab"
	self.effectPool = {}
	self.effectList = {}
end

M.Init = function(self, objPool)
	self.objPool = objPool

	objPool.gameObject:SetActive(false)
end

M.Add = function(self, type, parent, pos, duration)
	local effect = self.GetPool(self, type)

	if effect ~= nil then
		return nil
	end

	effect:SetData(parent, pos, duration or math.huge)
	table.insert(self.effectList, effect)

	return effect
end

M.Resume = function(self, effect, pos, duration)
	effect:SetData(nil, pos, duration or math.huge)
end

M.Remove = function(self, effect)
	effect.isLive = false
end

M.DelayHide = function(self, effect, delay)
	effect.SetTime(effect, delay)
end

M.RemoveType = function(self, type)
	local effect = nil
	local len = #self.effectList

	for i = 1, len do
		effect = self.effectList[i]

		if effect.type ~= type then
			effect.isLive = false
		end
	end
end

M.Update = function(self)
	self.CheckEffect(self)
end

M.Clear = function(self)
	local len = #self.effectList

	for i = 1, len do
		self.AddPool(self, self.effectList[i])
	end

	self.effectList = {}
end

M.Destroy = function(self)
	self.Clear(self)

	if self.effectPool == nil then
		for _, list in pairs(self.effectPool) do
			for _, v in pairs(list) do
				v.Destroy(v)
			end
		end

		self.effectPool = nil
	end
end

M.CheckEffect = function(self)
	local item = nil
	local index = 1
	local len = #self.effectList

	while index < len do
		item = self.effectList[index]

		item.CheckTime(item)

		if item.isLive then
			index = index + 1
		else
			table.remove(self.effectList, index)

			len = len - 1

			self.AddPool(self, item)
		end
	end
end

M.AddPool = function(self, item)
	item:Clear()
	item.transform:SetParent(self.objPool, false)

	local list = self.effectPool[item.type]

	if list ~= nil then
		list = {}
		self.effectPool[item.type] = list
	end

	table.insert(list, item)
end

M.GetPool = function(self, type)
	local list = self.effectPool[type]

	if list == nil then
		local len = #list

		if len <= 0 then
			local item = list[len]
			list[len] = nil

			return item
		end
	end

	local path = string.format(self.resPath, type)
	local result = gResourceManager:LoadAsset(path, typeof(GameObject))

	return C_FishingGameEffect.new(type, result.asset)
end
