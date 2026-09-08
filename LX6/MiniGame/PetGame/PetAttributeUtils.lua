-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\PetGame\PetAttributeUtils.lua
-- Decompiled from: 02137_PetAttributeUtils.lua_26c205d1abfa.luajit

local petAttributeData = require("LX6/MiniGame/PetGame/data/tbattribute")
C_PetAttributeUtils = DefClass("C_PetAttributeUtils", C_PetAttributeUtils)
local PetAttributeUtils = C_PetAttributeUtils

PetAttributeUtils.ctor = function(self)
	self:InitIdToAttribute()
end

PetAttributeUtils.InitIdToAttribute = function(self)
	self.IdToAttribute = {}

	for k, v in pairs(petAttributeData) do
		self.IdToAttribute[v.id] = k
	end
end

PetAttributeUtils.GetAttributeNameById = function(self, id)
	return self.IdToAttribute[id]
end

PetAttributeUtils.GetAttributeDataById = function(self, id)
	local key = self:GetAttributeNameById(id)

	if key then
		return petAttributeData[key]
	end

	return nil
end

PetAttributeUtils.GetAttributeIdByName = function(self, name)
	return petAttributeData[name].id
end

PetAttributeUtils.GetDefaultAttr = function(self, key)
	return petAttributeData[key] and petAttributeData[key].Initial or 0
end

PetAttributeUtils.GetDefualtAttr = function(self, key)
	return self:GetDefaultAttr(key)
end

PetAttributeUtils.GetMaxAttr = function(self, key)
	return petAttributeData[key] and petAttributeData[key].Max or 0
end

gPetAttributeUtils = gPetAttributeUtils or C_PetAttributeUtils.new()
