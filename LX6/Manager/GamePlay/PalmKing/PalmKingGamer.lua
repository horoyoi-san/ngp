-- Original chunk: @Lua\LuaFiles\LX6\Manager\GamePlay\PalmKing\PalmKingGamer.lua
-- Decompiled from: 02228_PalmKingGamer.lua_de95568155d9.luajit

local M = {}

M.Init = function(self)
	self.hitDir = 1
	self.blood = gPalmKingInterface:GetMeMaxHp()

	gPalmKingInterface:SetMeHp(self.blood)
end

M.StartPrepareHit = function(self)
	print_debug("玩家准备--攻击")

	self.isdefence = false

	gPalmKingAction:Attack(1)
	gPalmKingInterface:SetCamera(1, 1)
end

M.StartPrepareBeHit = function(self)
	print_debug("玩家准备--被打")

	self.isdefence = true
	self.prepareDefend = true
	self.headDefence = false

	gPalmKingAction:PrepareDefend(1)
end

M.Defence = function(self, direction)
	print_debug("玩家防御 方向: " .. direction)

	self.prepareDefend = false
	self.direction = direction

	gPalmKingManager:SyncDefence(direction)
	self:HeadDefence(direction)
end

M.HeadDefence = function(self, direction)
	print_debug("玩家闪避 start")

	self.headDefence = true

	if self.waitTimer then
		self.waitTimer:Stop()

		self.waitTimer = nil
	end

	self.waitTimer = Timer.New(function ()
		print_debug("玩家闪避 end")

		self.headDefence = false
	end, LTConfig.PoiGameConfig.Slap_DefenceDurationTime):Start()
end

M.IsHeadDefence = function(self)
	return self.headDefence
end

M.ActionQte = function(self, direction)
	print_debug("玩家输入QTE -- 方向: " .. direction)
	gPalmKingManager:SyncQteAction(direction)
end

gPalmKingGamer = M
