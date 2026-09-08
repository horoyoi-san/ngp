-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CommonLinkSummetryEndPanelStore.lua
-- Decompiled from: 01529_CommonLinkSummetryEndPanelStore.lua_16a3a17dc5a4.luajit

local InputButtonNameConfig = LTConfig.InputButtonNameConfig
C_CommonLinkSummetryEndPanelStore = DefClass("C_CommonLinkSummetryEndPanelStore", C_CommonLinkSummetryEndPanelStore, C_StoreGroup)
GroupName2Class.CommonLinkSummetryEndPanelStore = C_CommonLinkSummetryEndPanelStore
local M = C_CommonLinkSummetryEndPanelStore

M.ctor = function(self)
	self.mgr = gLinkManager
end

M.DefineAllVariables = function(self)
	self.myScoreData = {}
	self.enemyScoreData = {}
	self.columns = {}
	self.friendInvited = {}
	self.likeInvited = {}
	self.playerInfoCache = {}
	self.againKeyNameId = 0
	self.leaveEndTime = nil
	self.leaveShownSec = -1
end

M.DefineAllEnumsAutoGen = function(self)
	self.resultCtrlEnum = {
		["\\xca\\xce7\\xe2"] = 0,
		["|#tW"] = 1
	}
	self.againStateCtrlEnum = {
		[".M\\x81\\x82\\x82X"] = 3,
		["l\\xa9\\xa3\\xa6\\xb8"] = 1,
		["T'eO"] = 2,
		["T-s^"] = 0
	}
	self.showProgressCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.proposalStateCtrlEnum = {
		["J\\xa1\\xab\\xa1\\xb1"] = 0,
		["I\\x84\\x9d\\x86E"] = 1
	}
	self.showSingleMatchBtnCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.resultCtrlEnum = nil
	self.againStateCtrlEnum = nil
	self.showProgressCtrlEnum = nil
	self.proposalStateCtrlEnum = nil
	self.showSingleMatchBtnCtrlEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)

	self.friendInvited = {}
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
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	if not data then
		return
	end

	self.bindData.gameName = self.mgr:GetPlayModeName()
	self.columns = data.columns or {}
	self.myScoreData = data.myTeamData or {}
	self.enemyScoreData = data.enemyTeamData or {}
	self.friendInvited = {}
	self.likeInvited = {}

	self:InitTableColumns(self.bindData.myTable)
	self:InitTableColumns(self.bindData.enemyTable)
	self:RequestAllPlayerInfo()
	self:RefreshTable()
	self:UpdateTotalScore(data.myTotalScore, data.enemyTotalScore)

	self.closeCallback = data.callback
	self.isSuccess = data.isSuccess
	self.bindData.resultCtrl = data.isSuccess and self.resultCtrlEnum.success or self.resultCtrlEnum.fail
	self.bindData.succeedTitle = data.succeedTitle or ""
	self.bindData.failedTitle = data.failedTitle or ""
	self.noAgain = data.noAgain or false
	self.bindData.showSingleMatchBtnCtrl = self.mgr:CanSingleMatch() and self.showSingleMatchBtnCtrlEnum._true or self.showSingleMatchBtnCtrlEnum._false

	self:StartLeaveCountDown(data.autoLeaveTime)

	self.showLoading = data.showLoading
	self.reportUseSystem = data.reportUseSystem
	self.bindData.againStateCtrl = self.noAgain and self.againStateCtrlEnum.None or self.againStateCtrlEnum.Again

	self:RefreshInfo()

	if data.showCallback then
		if type(data.showCallback) ~= "function" then
			data.showCallback()
		elseif type(data.showCallback) ~= "userdata" then
			data.showCallback:DynamicInvoke()
		end
	end

	if not self.mgr.hasPersonalResult then
		if self.isSuccess then
			gCS.LuaUtils.PlayAnimation(self.bindData.panelAnimation)
		else
			gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnimation, "S_vx_CommonOnlineTeam_openFailed")
		end
	end
end

M.OnClose = function(self)
	self.leaveEndTime = nil

	if self.closeCallback then
		if type(self.closeCallback) ~= "function" then
			self.closeCallback()
		elseif type(self.closeCallback) ~= "userdata" then
			self.closeCallback:DynamicInvoke()
		end
	end
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.ADD_CHAT_FRIEND] = self.CreateAction(self, self.OnLinkMemberInfoChange),
		[gEventConstants.LINK_MEMBER_CHANGE] = self.CreateAction(self, self.OnLinkMemberInfoChange),
		[gEventConstants.LINK_MATCH_MEMBER_INFO_CHANGE] = self.CreateAction(self, self.RefreshInfo)
	}
end

M.OnLinkMemberInfoChange = function(self)
	self.bindData.myTable:RefreshTable()
	self.bindData.enemyTable:RefreshTable()
	self:RefreshInfo()
end

M.RequestAllPlayerInfo = function(self)
	local pidList = {}

	local collectPids = function(scoreData)
		for i = 1, #scoreData do
			local rowData = scoreData[i]
			local playerInfo = rowData[1]

			if type(playerInfo) ~= "table" and playerInfo.pid then
				table.insert(pidList, playerInfo.pid)
			end
		end
	end

	collectPids(self.myScoreData)
	collectPids(self.enemyScoreData)

	if #pidList ~= 0 then
		return
	end

	slot3 = gFriendManager

	slot3:GetSimplePlayerInfoByPidList(pidList, function (datas)
		if table.isNilOrEmpty(datas) then
			return
		end

		for i = 1, #datas do
			self.playerInfoCache[datas[i].Pid] = datas[i]
		end

		if self.bindData.myTable and self.bindData.enemyTable then
			self.bindData.myTable:RefreshTable()
			self.bindData.enemyTable:RefreshTable()
		end
	end)
end

M.RegisterWidget = function(self)
	self.bindData.myTable.luaRenderRow = self.CreateAction(self, "onRenderMyRow")
	self.bindData.enemyTable.luaRenderRow = self.CreateAction(self, "onRenderEnemyRow")
	self.bindData.myTable.luaRenderCol = self.CreateAction(self, "onRenderMyCol")
	self.bindData.enemyTable.luaRenderCol = self.CreateAction(self, "onRenderEnemyCol")
	self.bindData.continueBtn.luaClick = self.CreateAction(self, "onContinueBtnClick")
	self.bindData.againBtn.luaClick = self.CreateAction(self, "onAgainBtnClick")
	self.bindData.countDown.luaFinished = self.CreateAction(self, "onCountDownFinished")
	self.bindData.singleMatchBtn.luaClick = self.CreateAction(self, "onClickSingleMatch")
end

M.InitTableColumns = function(self, uTable)
	local colCount = #self.columns

	uTable.SetColData(uTable, colCount)

	for i = 0, colCount - 1 do
		local colDef = self.columns[i + 1]
		local col = uTable.colData[i]
		col.title = colDef.header or ""
		col.colTemplateIndex = 3

		if i ~= 0 then
			col.elementTemplateIndex = 1
		elseif i ~= colCount - 1 then
			col.elementTemplateIndex = 2
		else
			col.elementTemplateIndex = 0
		end

		if colDef.width then
			col.width = colDef.width
		else
			col.width = i ~= 0 and 280 or 120
		end
	end

	uTable.ResetColData(uTable)
end

M.UpdateTotalScore = function(self, myScore, enemyScore)
	myScore = myScore or ""
	enemyScore = enemyScore or ""
	self.bindData.myTotalScore = myScore
	self.bindData.enemyTotalScore = enemyScore
end

M.onRenderMyRow = function(self, row)
	self.RenderRow(self, self.bindData.myTable, self.myScoreData, row)
end

M.onRenderEnemyRow = function(self, row)
	self.RenderRow(self, self.bindData.enemyTable, self.enemyScoreData, row)
end

M.RefreshTable = function(self)
	self.bindData.myTable:SetTable(#self.myScoreData)
	self.bindData.enemyTable:SetTable(#self.enemyScoreData)
end

M.onRenderMyCol = function(self, col)
	self.RenderCol(self, col)
end

M.onRenderEnemyCol = function(self, col)
	self.RenderCol(self, col)
end

M.RenderCol = function(self, col)
	local btn = col.colButton
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if store then
		local colDef = self.columns[col.index + 1]
		store.title = colDef and colDef.header or ""

		if colDef and colDef.alignment then
			store.alignmentCtrl = colDef.alignment
		end
	end
end

M.RenderRow = function(self, uTable, scoreData, row)
	local dataIndex = uTable:GetChildIndex(row)
	local rowData = scoreData[dataIndex + 1] or {}

	if row.rowButton then
		local rowStore = gStoreManager:GetStoreGroup(row.rowButton.Store):GetStoreByWidget(row.rowButton)

		if rowStore then
			local playerInfo = rowData[1]
			local pid = type(playerInfo) ~= "table" and playerInfo.pid or nil
			local myPid = gPlayerManager.infoLogin.bindData.pid
			rowStore.isSelfCtrl = pid and pid ~= myPid and 1 or 0
		end
	end

	for i = 0, row.rowElements.Count - 1 do
		local element = row.rowElements[i]
		local store = gStoreManager:GetStoreGroup(element.Store):GetStoreByWidget(element)

		if store then
			local colDef = self.columns[i + 1]

			if colDef and colDef.alignment then
				store.alignmentCtrl = colDef.alignment
			end

			if i ~= 0 then
				local playerInfo = rowData[1]

				if type(playerInfo) ~= "table" and playerInfo.pid then
					local memberInfo = self.playerInfoCache[playerInfo.pid]
					store.nameLabel = gFriendManager:GetPlayerRealName(playerInfo.pid) or ""
					local headIcon = 0
					local headId = gClientUtils.GetLinkHeadId(memberInfo)

					if headId == 0 then
						headIcon = gHunLunManager:GetHeadIconAndName(headId)
					end

					store.headIcon = headIcon
					local linkIndex = memberInfo and memberInfo.LinkIndex or playerInfo.numberLabel or ""
					store.numberLabelName = tostring(linkIndex)
					store.numberLabelAvatar = tostring(linkIndex)
					local color = self.mgr:GetColorInfo(playerInfo.pid)
					store.colorName = color
					store.colorAvatar = color
					store.headBtn.luaRenderTooltip = self:CreateActionWithArgs(self.OnRenderTooltips, playerInfo.pid)
					store.showAvatarCtrl = 1
					store.proposalStateCtrl = self.mgr.tryAgainDict[playerInfo.pid] and 1 or 0
				end
			elseif i ~= row.rowElements.Count - 1 then
				local playerInfo = rowData[1]
				local memberInfo = playerInfo and self.playerInfoCache[playerInfo.pid]

				if memberInfo and memberInfo.IsRobot then
					element.SetActiveFastest(element, false)
				elseif type(playerInfo) ~= "table" and store.addFriendBtn then
					local pid = playerInfo.pid
					local isSelf = pid ~= gCarRaceManager:GetPlayerId() or pid ~= gPlayerManager.infoLogin.bindData.pid

					store.addFriendBtn.luaClick = function()
						self.friendInvited[pid] = true

						gFriendManager:AskApplyFriend(pid)

						store.beFriendCtrl = 1
					end

					store.beFriendCtrl = not self.friendInvited[pid] and not isSelf and not gFriendManager:IsFriend(pid) and 0 or 1

					if isSelf then
						element.SetActiveFastest(element, false)
					end
				end

				if not memberInfo or not memberInfo.IsRobot then
					self:SetupLikeBtn(store, playerInfo and playerInfo.pid)
				end
			else
				local value = rowData[i + 1]
				store.title = tostring(value or "")
			end
		end
	end
end

M.OnRenderTooltips = function(self, pid, btn, popup, _)
	local store = gStoreManager:GetStoreGroup(popup.Store)

	if not store then
		return
	end

	if self.reportUseSystem then
		store.SetReportUseSystem(store, self.reportUseSystem)
	end

	gSocialPalyerTooltipManager:OnRenderToolTips(pid, btn, popup, _)
end

M.SetupLikeBtn = function(self, store, pid)
	if not store or not store.likeBtn or not pid then
		return
	end

	store.haveZanCtrl = self.likeInvited[pid] and 1 or 0

	store.likeBtn.luaClick = function()
		if self.likeInvited[pid] then
			gDisplayMessageMgr:ShowMessage(75109966)

			return
		end

		gClientToGameDelegate:AskLikePlayer(pid, UX.Game.LikeType.Game).Callback = function (err)
			if err ~= LTConfig.MessageConfig.Ok or err ~= LTConfig.MessageConfig.TappedDailyLimitReached then
				self.likeInvited[pid] = true
				store.haveZanCtrl = 1
			else
				gDisplayMessageMgr:ShowMessage(err)
			end
		end
	end
end

M.onContinueBtnClick = function(self)
	if self.mgr:CheckInLinkMode() then
		self.mgr:AskLeaveGameByEnd(self.showLoading)
	end

	gMessageManager:SendMessage(gEventConstants.LINK_SETTLEMENT_CONTINUE_CLICKED, self.mgr.targetPlayId)
end

M.onAgainBtnClick = function(self)
	self.bindData.againBtn.interactable = false

	self.mgr:AskPlayGameAgain(self.bindData.againStateCtrl)
end

M.onClickSingleMatch = function(self)
	self.mgr:AskSingleMatch()
end

M.RefreshInfo = function(self)
	local checkAgainState, keyNameId = self.mgr:CheckAgainState(self.isSuccess)
	local againState = self.noAgain and self.againStateCtrlEnum.None or checkAgainState
	self.bindData.againStateCtrl = againState
	self.againKeyNameId = keyNameId

	self.bindData.againBtn:SetPCKeyInfoTipNameId(keyNameId)
	self.bindData.navigationArea:SetButtonInfoTipNameId(keyNameId, 1)
	self:RefreshAgainBtnName(self.leaveShownSec > 0 and self.leaveShownSec or 0)

	local showProgress = not table.isNilOrEmpty(self.mgr.tryAgainDict)
	local showProgressVal = showProgress and self.showProgressCtrlEnum._true or self.showProgressCtrlEnum._false

	if self.bindData.showProgressCtrl == showProgressVal then
		self.bindData.countDown:Play(LTConfig.LinkConfig.ClearingMaxTime)
	end

	self.bindData.showProgressCtrl = showProgressVal
	self.bindData.againLable = self.mgr:GetAgainLabel(self.bindData.againStateCtrl)

	if againState ~= C_LinkManager.AGAIN_STATE.None then
		self.bindData.againBtn.interactable = false

		if not self.bindData.continueBtn.interactable then
			self.bindData.continueBtn.interactable = true
		end
	end

	self.bindData.proposalStateCtrl = self.proposalStateCtrlEnum.going

	for _, isTryAgain in pairs(self.mgr.tryAgainDict) do
		if not isTryAgain then
			self.bindData.proposalStateCtrl = self.proposalStateCtrlEnum.paused
			self.bindData.againStateCtrl = C_LinkManager.AGAIN_STATE.None

			break
		end
	end
end

M.onCountDownFinished = function(self)
	self.bindData.showProgressCtrl = self.showProgressCtrlEnum._false
	self.bindData.continueBtn.interactable = true
end

M.RefreshAgainBtnName = function(self, leftSec)
	local baseText = ""
	local cfg = InputButtonNameConfig.GetConfig(708)

	if cfg then
		baseText = cfg.Name or ""
	end

	if leftSec <= 60 then
		self.bindData.escBtnName = baseText
	else
		self.bindData.escBtnName = string.format("%s %ds", baseText, math.max(0, leftSec))
	end
end

M.StartLeaveCountDown = function(self, autoLeaveTime)
	autoLeaveTime = autoLeaveTime or 0

	if autoLeaveTime < 0 then
		self.leaveEndTime = nil
		self.leaveShownSec = -1

		return
	end

	self.leaveEndTime = gLogicTime.unscaledTime + autoLeaveTime
	self.leaveShownSec = math.ceil(autoLeaveTime)

	self.RefreshAgainBtnName(self, self.leaveShownSec)
end

M.OnUpdate = function(self)
	if not self.leaveEndTime then
		return
	end

	local leftSec = math.ceil(self.leaveEndTime - gLogicTime.unscaledTime)

	if leftSec < 0 then
		self.leaveEndTime = nil

		self.RefreshAgainBtnName(self, 0)
		self.onContinueBtnClick(self)

		return
	end

	if leftSec == self.leaveShownSec then
		self.leaveShownSec = leftSec

		self.RefreshAgainBtnName(self, leftSec)
	end
end
