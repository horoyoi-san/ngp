-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\PetGame\PetGameSocialBlindDate.lua
-- Decompiled from: 02152_PetGameSocialBlindDate.lua_e5cf99984fab.luajit

local cjson = require("cjson/json")
C_PetGameSocialBlindDate = DefClass("C_PetGameSocialBlindDate", C_PetGameSocialBlindDate)
local M = C_PetGameSocialBlindDate

local SafeEncode = function(data)
	local ok, jsonStr = pcall(cjson.encode, data or {})

	if ok then
		return jsonStr
	end

	print_error("PetGameSocialPlayManager encode failed")

	return "{}"
end

M.ctor = function(self, args)
	self.pets = args.pets
	self.points = args.points
	self.network = args.network
	self.socialManager = args.socialManager
	self.successRate = self.socialManager and self.socialManager:GetBlindDateSuccessRate() or 0
	self.isBlindDataSuccess = math.random(1, 100) > self.successRate
end

M.Start = function(self)
	for playerId, petEnity in pairs(self.pets) do
		self.SendInteractionMsg(self, playerId, self.points[playerId], self.isBlindDataSuccess)
	end
end

M.Stop = function(self)
end

M.Clear = function(self)
	self.pets = nil
	self.network = nil
	self.socialManager = nil
	self.successRate = nil
	self.isBlindDataSuccess = nil
end

M.SendInteractionMsg = function(self, playerId, stopPoint, isSucessed)
	local data = {
		["\\x8deb"] = "AKegJ:=",
		playerId = playerId,
		stopPoint = stopPoint,
		isSucessed = isSucessed
	}

	self.network:SendStateSync(0, SafeEncode(data))

	if self.socialManager then
		self.socialManager:HandleStateSync(data)
	end
end
