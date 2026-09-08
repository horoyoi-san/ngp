-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PartyDanceEndPanelStore.lua
-- Decompiled from: 01071_PartyDanceEndPanelStore.lua_09ac774cb3e2.luajit

local Mathf = UnityEngine.Mathf
local LivehouseConfig = LTConfig.LivehouseConfig
local LivehouseMusicConfig = LTConfig.LivehouseMusicConfig
C_PartyDanceEndPanelStore = DefClass("C_PartyDanceEndPanelStore", C_PartyDanceEndPanelStore, C_StoreGroup)
GroupName2Class.PartyDanceEndPanelStore = C_PartyDanceEndPanelStore
local M = C_PartyDanceEndPanelStore
local EvaluatePage = {
	["W+nH"] = "w+nH",
	["]-r_"] = "}-r_",
	["\\xe9\\xde'\\xe5"] = "\\xc9\\xde'\\xe5"
}
local ScoreData = {
	{
		["\\x85m"] = "s\\xbeqI\\xb1\\xe6deopX",
		type = EvaluatePage.Perfect
	},
	{
		["\\x85m"] = "DHcmm,",
		type = EvaluatePage.Good
	},
	{
		["\\x85m"] = "NNzm,",
		type = EvaluatePage.Miss
	}
}

M.DefineAllVariables = function(self)
	self.musicId = nil
	self.liveHouseId = nil
	self.difficulty = 1
	self.perfectCount = 0
	self.goodCount = 0
	self.missCount = 0
	self.score = 0
	self.rankLevel = 0
end

M.RegisterWidget = function(self)
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, "OnRenderItem")
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.RegisterWidget(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	data = data or {}
	self.musicId = data.id
	self.liveHouseId = data.liveHouseId
	self.difficulty = data.difficulty or 1
	self.perfectCount = data.perfectCount or 0
	self.goodCount = data.goodCount or 0
	self.missCount = data.missCount or 0
	self.score = data.score or 0
	self.rankLevel = data.rankLevel or 0

	self:RefreshView()
end

M.OnClose = function(self)
end

M.RefreshView = function(self)
	self.bindData.scoreText = tostring(self.score)
	self.bindData.rankLevel = self.rankLevel

	self.bindData.list:SetSimpleList(#ScoreData)
end

M.OnRenderItem = function(self, btn, index)
	local luaIndex = index + 1
	local data = ScoreData[luaIndex]

	if not data then
		return
	end

	local count = 0

	if luaIndex ~= 1 then
		count = self.perfectCount
	elseif luaIndex ~= 2 then
		count = self.goodCount
	elseif luaIndex ~= 3 then
		count = self.missCount
	end

	local widget = btn.GetComponent(btn, typeof(SGUI.UComponent))

	if widget then
		widget.TryChangePage(widget, "Evaluate", data.type, true, false)
	end

	local scoreTrans = btn.transform:Find("score")

	if scoreTrans then
		local scoreText = scoreTrans.GetComponent(scoreTrans, typeof(SGUI.UBaseText))

		if scoreText then
			scoreText.text = "x" .. count
		end
	end
end
