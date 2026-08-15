local M = {}

function M:Init()
	self.store = gStoreManager:GetStoreGroup("PalmKingPanelStore")
end

function M:SetSelect(index)
	self.store:SetSelect(index)
end

function M:OnPalmBtnClick()
	self.store:Do_PalmBtnClick()
end

function M:OnPalmDefenceBtnClick()
	self.store:OnPalmBtnClick()
end

function M:PlayerHit(direction, force)
	print_debug("玩家攻击，方向: " .. direction .. ", 力量: " .. force)
	gPalmKingManager:SyncHit(direction, force)
end

function M:PlayerDefence(select)
	gPalmKingGamer:Defence(select)
end

function M:GetCurForce()
	return self.store:GetCurForce()
end

function M:SetHudState(index)
	self.gameState = index

	self.store:SetCurState(index)
end

function M:SetCamera(type, index)
	self.store:SetCamera(type, index)
end

function M:SetQTEList(qtes)
	self.qtelist = {}

	for k, v in pairs(qtes) do
		table.insert(self.qtelist, v.direction)
	end
end

function M:GetQTEList()
	print_debug(self.qtelist)

	return self.qtelist
end

function M:SendQTE(index)
	print_debug("输入QTE :  " .. index)
	gPalmKingGamer:ActionQte(index)
end

function M:SetQTEPos(index)
	self.store:SetQTEPos(index)
end

function M:RefreshQteList(qtes)
	self.store:RefreshQteList(qtes)
end

function M:SetQTEProgress(num)
	self.store:SetQTEProgress(num)
end

function M:SetMeHp(num)
	self.store:SetMeHp(num)
end

function M:SetOtherHp(num)
	self.store:SetOtherHp(num)
end

function M:GetMeMaxHp()
	return self.store.slapCfg.Hp
end

function M:GetOtherMaxHp()
	return self.store.slapCfg.Hp
end

function M:GetSlapCfgId()
	return self.store.slapAIId
end

function M:SetResultText(type, num)
	self.store:SetHpText(type, num)
end

gPalmKingInterface = M
