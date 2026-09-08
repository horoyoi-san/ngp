-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\KTVGameEndPanelStore.lua
-- Decompiled from: 01774_KTVGameEndPanelStore.lua_faab70203fc8.luajit

C_KTVGameEndPanelStore = DefClass("C_KTVGameEndPanelStore", C_KTVGameEndPanelStore, C_StoreGroup)
GroupName2Class.KTVGameEndPanelStore = C_KTVGameEndPanelStore
local M = C_KTVGameEndPanelStore
local ITEM_SCORE = 1
local ITEM_PERFECT = 2
local ITEM_GREAT = 3
local ITEM_MISS = 4
local ITEM_MAX_COMBO = 5
local ITEM_HIGH_SCORE = 6

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.data = nil
	self.scorePercent = 0
	self.histHighScore = 0
	self.histPercent = 0
	self.isNewRecord = false
	self.listData = {}
end

M.DefineAllEnumsAutoGen = function(self)
	self.rankCtrlEnum = {
		["\\xec"] = 1,
		["\\xee"] = 3,
		["\\xe9"] = 4,
		["\\xfe"] = 0,
		["\\xef"] = 2
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.rankCtrlEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	if type(data.ToTable) ~= "function" then
		data = data.ToTable(data)
	end

	self:DefineAllVariables()

	self.data = {
		musicId = data.musicId,
		score = data.score or 0,
		maxCombo = data.maxCombo or 0,
		perfectCount = data.perfectCount or 0,
		greatCount = data.greatCount or 0,
		missCount = data.missCount or 0,
		totalPossible = data.totalPossible and data.totalPossible <= 0 and data.totalPossible or 1
	}
	local musicCfg = LTConfig.KTVMusicConfig.GetConfig(self.data.musicId)

	if musicCfg then
		self.bindData.musicName = musicCfg.BGMName or ""
	else
		self.bindData.musicName = ""

		print_error("KTVGameEndPanelStore: KTVMusicConfig not found, musicId =", self.data.musicId)
	end

	self.scorePercent = math.min(100, math.max(0, self.data.score / self.data.totalPossible * 100))
	self.bindData.rankCtrl = self:CalculateRank(self.scorePercent)

	self:BuildListData()

	slot4 = self.bindData.scoreList

	slot4:SetSimpleList(#self.listData)

	slot4 = gClientToGameDelegate

	slot4:AskKTVMusicInfoList({
		self.data.musicId
	}).Callback = function (err, result)
		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		if result and result.MusicInfos then
			local list = result.MusicInfos

			if type(list.ToTable) ~= "function" then
				list = list:ToTable()
			end

			local found = false

			for _, info in ipairs(list) do
				if info.MusicId ~= self.data.musicId then
					self.histHighScore = info.HighScore or 0
					self.histPercent = self.histHighScore / self.data.totalPossible * 100
					self.histPercent = math.min(100, math.max(0, self.histPercent))
					self.isNewRecord = self.histHighScore <= self.data.score
					found = true

					break
				end
			end

			if not found then
				self.isNewRecord = true
			end

			self:BuildListData()
			self.bindData.scoreList:SetSimpleList(#self.listData)
		end
	end
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.continueBtn.luaClick = self.CreateAction(self, self.OnClickContinueBtn)
	self.bindData.scoreList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderScoreListItem)
end

M.CalculateRank = function(self, percent)
	local thresholds = LTConfig.KTVConfig.LevelsStartScore

	if not thresholds then
		return self.rankCtrlEnum.D
	end

	if thresholds[5] < percent then
		return self.rankCtrlEnum.S
	end

	if thresholds[4] < percent then
		return self.rankCtrlEnum.A
	end

	if thresholds[3] < percent then
		return self.rankCtrlEnum.B
	end

	if thresholds[2] < percent then
		return self.rankCtrlEnum.C
	end

	return self.rankCtrlEnum.D
end

M.BuildListData = function(self)
	local s = LTConfig.KTVConfig
	self.listData = {
		{
			type = ITEM_SCORE,
			label = s.ResultScoreText,
			value = string.format("%.2f", self.scorePercent),
			isNew = self.isNewRecord
		},
		{
			type = ITEM_PERFECT,
			label = s.ResultPerfectText,
			value = tostring(self.data.perfectCount)
		},
		{
			type = ITEM_GREAT,
			label = s.ResultGreatText,
			value = tostring(self.data.greatCount)
		},
		{
			type = ITEM_MISS,
			label = s.ResultMissText,
			value = tostring(self.data.missCount)
		},
		{
			type = ITEM_MAX_COMBO,
			label = s.ResultMaxComboText,
			value = tostring(self.data.maxCombo)
		},
		{
			type = ITEM_HIGH_SCORE,
			label = s.ResultHighestScoreText,
			value = string.format("%.2f", self.histPercent)
		}
	}
end

M.OnClickContinueBtn = function(self)
	gKTVGameManager:FinishSettlement()
end

M.OnSimpleRenderScoreListItem = function(self, widget, index)
	local item = self.listData[index + 1]

	if not item then
		return
	end

	if widget.title then
		widget.title.text = item.label
	end

	local valueTrans = widget.transform:Find("Title (1)")

	if valueTrans then
		local valueText = valueTrans.GetComponent(valueTrans, typeof(SGUI.USDFText))

		if valueText then
			valueText.text = item.isNew and item.value .. " ★" or item.value
		end
	end
end
