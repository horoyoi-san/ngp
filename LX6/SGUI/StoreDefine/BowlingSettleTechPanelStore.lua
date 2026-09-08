-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BowlingSettleTechPanelStore.lua
-- Decompiled from: 01622_BowlingSettleTechPanelStore.lua_6b1b5306248f.luajit

C_BowlingSettleTechPanelStore = DefClass("C_BowlingSettleTechPanelStore", C_BowlingSettleTechPanelStore, C_StoreGroup)
GroupName2Class.BowlingSettleTechPanelStore = C_BowlingSettleTechPanelStore
local M = C_BowlingSettleTechPanelStore

M.OnAwake = function(self)
end

M.OnDestroy = function(self)
end

M.OnStart = function(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	self.ClearPlayerScore(self)

	if data and data.settleData then
		self.RefreshScoreBoardComplete(self, data.settleData)
	end
end

M.OnClose = function(self)
end

M.ClearPlayerScore = function(self)
	self.bindData.S1.gameObject:SetActive(false)
	self.bindData.S2.gameObject:SetActive(false)
	self.bindData.S3.gameObject:SetActive(false)
	self.bindData.S4.gameObject:SetActive(false)
	self.bindData.S5.gameObject:SetActive(false)
	self.bindData.S6.gameObject:SetActive(false)
	self.bindData.S7.gameObject:SetActive(false)
	self.bindData.S8.gameObject:SetActive(false)
	self.bindData.S9.gameObject:SetActive(false)
	self.bindData.S10.gameObject:SetActive(false)
end

M.RefreshScoreBoardComplete = function(self, settleData)
	if not settleData then
		return
	end

	if not settleData.completedPatterns then
		return
	end

	self.RefreshScoreBoardPlayer(self, settleData.completedPatterns)
end

M.RefreshScoreBoardPlayer = function(self, completedPatterns)
	if not completedPatterns then
		return
	end

	for i, succ in ipairs(completedPatterns) do
		local pn = "S" .. tostring(succ)

		if self.bindData[pn] and gClientUtils.NotNil(self.bindData[pn].gameObject) then
			self.bindData[pn].gameObject:SetActive(true)
		end
	end
end
