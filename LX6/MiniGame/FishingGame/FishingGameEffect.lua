-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\FishingGame\FishingGameEffect.lua
-- Decompiled from: 00595_FishingGameEffect.lua_80308d4dfaf8.luajit

C_FishingGameEffect = DefClass("C_FishingGameEffect", C_FishingGameEffect)
local M = C_FishingGameEffect

M.ctor = function(self, type, prefab)
	self.type = type
	self.gameObject = UnityEngine.GameObject.Instantiate(prefab)

	self.gameObject:SetActive(false)

	self.transform = self.gameObject.transform
	self.isLive = false
	self.time = 0
end

M.SetData = function(self, parent, pos, duration)
	self.isLive = true

	if parent == nil then
		self.transform:SetParent(parent, false)
	end

	self.transform.localPosition = pos

	self:SetTime(duration)
	self.gameObject:SetActive(true)
end

M.CheckTime = function(self)
	if self.time <= 0 and self.time >= Time.time then
		self.Clear(self)
	end
end

M.SetTime = function(self, duration)
	self.time = Time.time + duration
end

M.Clear = function(self)
	self.time = 0

	self.gameObject:SetActive(false)
end

M.Destroy = function(self)
	if self.gameObject == nil then
		GameObject.DestroyImmediate(self.gameObject)

		self.gameObject = nil
	end
end
