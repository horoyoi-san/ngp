-- Original chunk: @Lua\LuaFiles\LX6\Manager\GamePlay\PalmKing\PalmKingInterface.lua
-- Decompiled from: 02230_PalmKingInterface.lua_7fd5bfb21bd9.luajit

local M = {}

M.Init = function(self)
	self.store = gStoreManager:GetStoreGroup("PalmKingPanelStore")
end

M.SetSelect = function(self, index)
	self.store:SetSelect(index)
end

M.OnPalmBtnClick = function(self, isTimeout)
	self.store:Do_PalmBtnClick(isTimeout)
end

M.OnPalmDefenceBtnClick = function(self)
	self.store:OnPalmBtnClick()
end

M.PlayerHit = function(self, direction, force)
	print_debug("玩家攻击，方向: " .. direction .. ", 力量: " .. force)
	gPalmKingManager:SyncHit(direction, force)
end

M.PlayerDefence = function(self, select)
	gPalmKingGamer:Defence(select)
end

M.GetCurForce = function(self)
	return self.store:GetCurForce()
end

M.SetHudState = function(self, index)
	self.gameState = index

	self.store:SetCurState(index)
end

M.SetCamera = function(self, type, index)
	self.store:SetCamera(type, index)
end

M.SetQTEList = function(self, qtes)
	self.qtelist = {}

	for k, v in pairs(qtes) do
		table.insert(self.qtelist, v.direction)
	end
end

M.GetQTEList = function(self)
	print_debug(self.qtelist)

	return self.qtelist
end

M.SendQTE = function(self, index)
	print_debug("输入QTE :  " .. index)
	gPalmKingGamer:ActionQte(index)
end

M.SetQTEPos = function(self, index)
	self.store:SetQTEPos(index)
end

M.PlayQTEResult = function(self, index, success)
	return self.store:PlayQTEResult(index, success)
end

M.RefreshQteList = function(self, qtes)
	self.store:RefreshQteList(qtes)
end

M.SetQTEProgress = function(self, num)
	self.store:SetQTEProgress(num)
end

M.SetMeHp = function(self, num)
	self.store:SetMeHp(num)
end

M.SetOtherHp = function(self, num)
	self.store:SetOtherHp(num)
end

M.PlayDamage = function(self, isHit, damage)
	self.store:PlayDamage(isHit, damage)
end

M.GetMeMaxHp = function(self)
	return self.store.slapCfg.Hp
end

M.GetOtherMaxHp = function(self)
	return self.store.slapCfg.Hp
end

M.GetSlapCfgId = function(self)
	return self.store.slapAIId
end

M.OnExecuteAttack = function(self)
	self.store:OnExecuteAttack()
end

M.SetResultText = function(self, type, num)
	self.store:SetHpText(type, num)
end

gPalmKingInterface = M
