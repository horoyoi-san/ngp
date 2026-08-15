local M = {}

function M:Init()
	self.hitDir = 1
	self.blood = gPalmKingInterface:GetMeMaxHp()

	gPalmKingInterface:SetMeHp(self.blood)
end

function M:StartPrepareHit()
	print_debug("玩家准备--攻击")

	self.isdefence = false

	gPalmKingAction:Attack(1)
	gPalmKingInterface:SetCamera(1, 1)
end

function M:StartPrepareBeHit()
	print_debug("玩家准备--被打")

	self.isdefence = true
	self.prepareDefend = true
	self.headDefence = false

	gPalmKingAction:PrepareDefend(1)
end

function M:Defence(direction)
	print_debug("玩家防御 方向: " .. direction)

	self.prepareDefend = false
	self.direction = direction

	gPalmKingManager:SyncDefence(direction)
	self:HeadDefence()
end

function M:HeadDefence()
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

function M:IsHeadDefence()
	return self.headDefence
end

function M:ActionQte(direction)
	print_debug("玩家输入QTE -- 方向: " .. direction)
	gPalmKingManager:SyncQteAction(direction)
end

gPalmKingGamer = M
