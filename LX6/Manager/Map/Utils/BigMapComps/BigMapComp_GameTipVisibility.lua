-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\Utils\BigMapComps\BigMapComp_GameTipVisibility.lua
-- Decompiled from: 01036_BigMapComp_GameTipVisibility.lua_b0ab6ca86d81.luajit

BigMapComp_GameTipVisibility = BigMapComp_GameTipVisibility or {}
local M = BigMapComp_GameTipVisibility
M.__index = M

M.OnInit = function(self)
	self.bindData.gameTips:SetActiveFastest(false)
	self.bindData.whiteGameTips:SetActiveFastest(false)
end

M.OnActive = function(self)
	self.bindData.gameTips:SetActiveFastest(true)
	self.bindData.whiteGameTips:SetActiveFastest(true)
end

M.OnInactive = function(self)
	self.bindData.gameTips:SetActiveFastest(false)
	self.bindData.whiteGameTips:SetActiveFastest(false)
end
