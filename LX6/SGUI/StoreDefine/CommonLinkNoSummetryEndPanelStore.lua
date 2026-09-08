-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CommonLinkNoSummetryEndPanelStore.lua
-- Decompiled from: 01528_CommonLinkNoSummetryEndPanelStore.lua_0c8d89a17858.luajit

local LinkConfig = LTConfig.LinkConfig
local LinkMultiPlayerConfig = LTConfig.LinkMultiPlayerConfig
local InputButtonNameConfig = LTConfig.InputButtonNameConfig
C_CommonLinkNoSummetryEndPanelStore = DefClass("C_CommonLinkNoSummetryEndPanelStore", C_CommonLinkNoSummetryEndPanelStore, C_StoreGroup)
GroupName2Class.CommonLinkNoSummetryEndPanelStore = C_CommonLinkNoSummetryEndPanelStore
local M = C_CommonLinkNoSummetryEndPanelStore
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}
local HEADER_TEMPLATE = 0

M.ctor = function(self)
	self.mgr = gLinkManager
end

M.DefineAllVariables = function(self)
	self.showList1 = {}
	self.showList2 = {}
	self.columnDefs1 = {}
	self.columnDefs2 = {}
	self.friendInvited = {}
	self.likeInvited = {}
	self.playerInfoCache = {}
	self.againKeyNameId = 0
	self.leaveEndTime = nil
	self.leaveShownSec = -1
end

M.DefineAllEnumsAutoGen = function(self)
	self.againStateEnum = {
		[".M\\x81\\x82\\x82X"] = 3,
		["l\\xa9\\xa3\\xa6\\xb8"] = 1,
		["T'eO"] = 2,
		["T-s^"] = 0
	}
	self.showProgressEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.showWatchPlayerBtnCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.proposalStateCtrlEnum = {
		["J\\xa1\\xab\\xa1\\xb1"] = 0,
		["I\\x84\\x9d\\x86E"] = 1
	}
	self.resultCtrl1Enum = {
		["\\xca\\xce7\\xe2"] = 0,
		["|#tW"] = 1
	}
	self.resultCtrl2Enum = {
		["\\xca\\xce7\\xe2"] = 0,
		["|#tW"] = 1
	}
	self.showSingleMatchBtnCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.againStateEnum = nil
	self.showProgressEnum = nil
	self.showWatchPlayerBtnCtrlEnum = nil
	self.proposalStateCtrlEnum = nil
	self.resultCtrl1Enum = nil
	self.resultCtrl2Enum = nil
	self.showSingleMatchBtnCtrlEnum = nil
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
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	if table.isNilOrEmpty(data) then
		print_error("CommonLinkNoSummetryEndPanelStore OnShow data is nil")
		self.OnClickBackGround(self)

		return
	end

	self.showList1 = data.list1 or {}
	self.showList2 = data.list2 or {}
	self.columnDefs1 = data.columnDefs1 or {}
	self.columnDefs2 = data.columnDefs2 or {}
	self.isSuccess = data.isSuccess
	self.friendInvited = {}
	self.likeInvited = {}
	self.showLoading = data.showLoading
	self.reportUseSystem = data.reportUseSystem
	self.noAgain = data.noAgain or false
	self.bindData.showSingleMatchBtnCtrl = self.mgr:CanSingleMatch() and self.showSingleMatchBtnCtrlEnum._true or self.showSingleMatchBtnCtrlEnum._false

	self:StartLeaveCountDown(data.autoLeaveTime)

	self.bindData.titleLabel1 = data.title1 or ""
	self.bindData.titleLabel2 = data.title2 or ""

	self:SetTableResult(1, data.isSuccess1, data.succeedTitle, data.failedTitle)
	self:SetTableResult(2, data.isSuccess2, data.succeedTitle, data.failedTitle)
	self:InitTableColumns(self.bindData.rankTable1, self.columnDefs1)
	self:InitTableColumns(self.bindData.rankTable2, self.columnDefs2)
	self:RequestAllPlayerInfo()
	self.bindData.rankTable1:SetTable(#self.showList1)
	self.bindData.rankTable2:SetTable(#self.showList2)
	self:RefreshInfo()
	self:RefreshWatchState()

	if not self.mgr.hasPersonalResult then
		if not self.isSuccess then
			gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnimation, "S_vx_CommonOnlineTeam_openFailed")
		end
	end
end

M.OnClose = function(self)
	self.leaveEndTime = nil
end

M.OnActiveDeviceChange = function(self, device)
	self.bindData.rankTable1:RefreshTable()
	self.bindData.rankTable2:RefreshTable()
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.ADD_CHAT_FRIEND] = self.CreateAction(self, self.OnLinkMemberInfoChange),
		[gEventConstants.LINK_MEMBER_CHANGE] = self.CreateAction(self, self.OnLinkMemberInfoChange),
		[gEventConstants.ONLINE_INGAME_WATCH_STATE_CHANGE] = self.CreateAction(self, self.RefreshWatchState),
		[gEventConstants.LINK_MATCH_MEMBER_INFO_CHANGE] = self.CreateAction(self, self.RefreshInfo)
	}
end

M.OnLinkMemberInfoChange = function(self)
	self.bindData.rankTable1:RefreshTable()
	self.bindData.rankTable2:RefreshTable()
	self:RefreshInfo()
end

M.RegisterWidget = function(self)
	self.bindData.backGround.luaClick = self.CreateAction(self, self.OnClickBackGround)
	self.bindData.againBtn.luaClick = self.CreateAction(self, self.OnClickAgainBtn)
	self.bindData.watchBtn.luaClick = self.CreateAction(self, self.OnClickWatchBtn)
	self.bindData.singleMatchBtn.luaClick = self.CreateAction(self, self.OnClickSingleMatch)
	self.bindData.rankTable1.luaRenderCol = self.CreateAction(self, self.OnRenderCol1)
	self.bindData.rankTable1.luaRenderRow = self.CreateAction(self, self.OnRenderRow1)
	self.bindData.rankTable2.luaRenderCol = self.CreateAction(self, self.OnRenderCol2)
	self.bindData.rankTable2.luaRenderRow = self.CreateAction(self, self.OnRenderRow2)
	self.bindData.countDown.luaFinished = self.CreateAction(self, self.OnCountDownFinished)
end

M.OnClickBackGround = function(self)
	if self.mgr:CheckInLinkMode() then
		self.mgr:AskLeaveGameByEnd(self.showLoading)
	end

	gMessageManager:SendMessage(gEventConstants.LINK_SETTLEMENT_CONTINUE_CLICKED, self.mgr.targetPlayId)
end

M.OnClickAgainBtn = function(self)
	self.bindData.againBtn.interactable = false
	slot1 = self.mgr

	slot1:AskPlayGameAgain(self.bindData.againState, function (isSuccess)
	end)
end

M.OnClickWatchBtn = function(self)
	self.mgr:OnWatchOnlinePlayer(nil, true)
end

M.OnClickSingleMatch = function(self)
	self.mgr:AskSingleMatch()
end

M.SetTableResult = function(self, tableIndex, isWin, succeedTitle, failedTitle)
	if tableIndex ~= 1 then
		self.bindData.resultCtrl1 = isWin and self.resultCtrl1Enum.success or self.resultCtrl1Enum.fail
		self.bindData.succeedTitle1 = isWin and (succeedTitle or "") or ""
		self.bindData.failedTitle1 = isWin and "" or failedTitle or ""
	else
		self.bindData.resultCtrl2 = isWin and self.resultCtrl2Enum.success or self.resultCtrl2Enum.fail
		self.bindData.succeedTitle2 = isWin and (succeedTitle or "") or ""
		self.bindData.failedTitle2 = isWin and "" or failedTitle or ""
	end
end

M.RequestAllPlayerInfo = function(self)
	local pidList = {}

	local collect = function(list)
		for i = 1, #list do
			local pid = list[i].id

			if pid then
				table.insert(pidList, pid)
			end
		end
	end

	collect(self.showList1)
	collect(self.showList2)

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

		self.bindData.rankTable1:RefreshTable()
		self.bindData.rankTable2:RefreshTable()
	end)
end

M.InitTableColumns = function(self, uTable, columnDefs)
	local colCount = #columnDefs

	uTable.SetColData(uTable, colCount)

	for i = 0, colCount - 1 do
		local colDef = columnDefs[i + 1]
		local col = uTable.colData[i]
		col.title = colDef.headerName
		col.colTemplateIndex = HEADER_TEMPLATE
		col.elementTemplateIndex = colDef.templateIndex
		col.width = colDef.width
	end

	uTable.ResetColData(uTable)
end

M.OnRenderCol1 = function(self, col)
	self.RenderCol(self, col, self.columnDefs1)
end

M.OnRenderCol2 = function(self, col)
	self.RenderCol(self, col, self.columnDefs2)
end

M.OnRenderRow1 = function(self, row)
	self.RenderRow(self, self.bindData.rankTable1, self.showList1, self.columnDefs1, row)
	self.RefreshTitleRootPos(self, self.bindData.rankTable1, self.bindData.titleRoot1, row)
end

M.OnRenderRow2 = function(self, row)
	self.RenderRow(self, self.bindData.rankTable2, self.showList2, self.columnDefs2, row)
	self.RefreshTitleRootPos(self, self.bindData.rankTable2, self.bindData.titleRoot2, row)

	if self.bindData.titleRoot1 and self.bindData.titleRoot2 and self.bindData.rankTable2:GetChildIndex(row) ~= 0 then
		local size2 = self.bindData.titleRoot2.sizeDelta
		self.bindData.titleRoot2.sizeDelta = Vector2.New(self.bindData.titleRoot1.rectTransform.rect.width, size2.y)
	end
end

M.RefreshTitleRootPos = function(self, uTable, titleRoot, row)
	if not titleRoot then
		return
	end

	if uTable.GetChildIndex(uTable, row) == 0 then
		return
	end

	local firstElement = row.rowElements.Count <= 0 and row.rowElements[0] or row.rowButton

	if not firstElement then
		return
	end

	local parentRT = titleRoot.rectTransform.parent
	local localPos = parentRT.InverseTransformPoint(parentRT, firstElement.position)
	local curPos = titleRoot.localPosition
	titleRoot.localPosition = Vector3.New(localPos.x, curPos.y, curPos.z)
end

M.RenderCol = function(self, col, columnDefs)
	local btn = col.colButton
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if store then
		local colDef = columnDefs[col.index + 1]
		store.title = colDef and colDef.headerName or ""

		if colDef and colDef.alignment then
			store.alignmentCtrl = colDef.alignment
		end
	end
end

M.RenderRow = function(self, uTable, showList, columnDefs, row)
	local dataIndex = uTable.GetChildIndex(uTable, row)
	local data = showList[dataIndex + 1]

	if not data then
		return
	end

	if row.rowButton then
		local rowStore = gStoreManager:GetStoreGroup(row.rowButton.Store):GetStoreByWidget(row.rowButton)

		if rowStore then
			local myPid = gPlayerManager.infoLogin.bindData.pid
			rowStore.isSelfCtrl = data.id and data.id ~= myPid and 1 or 0
		end
	end

	for i = 0, row.rowElements.Count - 1 do
		local colDef = columnDefs[i + 1]

		if not colDef then
			break
		end

		local element = row.rowElements[i]
		local store = gStoreManager:GetStoreGroup(element.Store):GetStoreByWidget(element)

		if store then
			if colDef.alignment then
				store.alignmentCtrl = colDef.alignment
			end

			self.RenderCell(self, store, colDef, data, dataIndex, element)
		end
	end
end

M.RenderCell = function(self, store, colDef, data, dataIndex, element)
	local colType = colDef.colType
	local COL_TYPE = self.mgr.COL_TYPE

	if colType ~= COL_TYPE.RANK then
		self.RenderRankCell(self, store, data, dataIndex)
	elseif colType ~= COL_TYPE.PLAYER then
		self.RenderPlayerCell(self, store, data)
	elseif colType ~= COL_TYPE.DUTY then
		self.RenderDutyCell(self, store, data)
	elseif colType ~= COL_TYPE.CUSTOM_TEXT then
		self.RenderCustomTextCell(self, store, colDef, data)
	elseif colType ~= COL_TYPE.REWARD then
		self.RenderRewardCell(self, store, data)
	elseif colType ~= COL_TYPE.ACTION then
		self.RenderActionCell(self, store, data, element)
	end
end

M.RenderRankCell = function(self, store, data, dataIndex)
	store.title = tostring(dataIndex + 1)
end

M.RenderPlayerCell = function(self, store, data)
	local pid = data.id
	local memberInfo = self.playerInfoCache[pid]
	store.nameLabel = gFriendManager:GetPlayerRealName(pid) or ""
	local headIcon = 0
	local headId = gClientUtils.GetLinkHeadId(memberInfo)

	if headId == 0 then
		headIcon = gHunLunManager:GetHeadIconAndName(headId)
	end

	store.headIcon = headIcon
	local linkIndex = memberInfo and memberInfo.LinkIndex or self.mgr:GetMatchNumber(pid)
	store.numberLabelName = tostring(linkIndex)
	store.numberLabelAvatar = tostring(linkIndex)
	local color = self.mgr:GetColorInfo(pid)
	store.colorName = color
	store.colorAvatar = color
	store.headBtn.luaRenderTooltip = self:CreateActionWithArgs(self.OnRenderTooltips, pid)
	store.showAvatarCtrl = 1
	store.proposalStateCtrl = self.mgr.tryAgainDict[pid] and 1 or 0
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

M.RenderDutyCell = function(self, store, data)
	local dutyInfo = gLinkManager:GetDutyInfoByPid(data.id)

	if dutyInfo then
		store.dutyIconId = dutyInfo.icon
		store.dutyLable = dutyInfo.name
	else
		store.dutyIconId = 0
		store.dutyLable = ""
	end
end

M.RenderCustomTextCell = function(self, store, colDef, data)
	local fields = data.customFields or {}
	local rawValue = fields[colDef.dataKey]

	if colDef.formatter then
		store.title = colDef.formatter(rawValue, fields)
	else
		store.title = tostring(rawValue or "")
	end
end

M.RenderRewardCell = function(self, store, data)
	if store.rewardList and not table.isNilOrEmpty(data.award) then
		store.rewardList.luaSimpleRenderItem = function(btn, index)
			local info = data.award[index + 1]

			gCommonItemManager:OnCommonItemRender(btn, index, gCommonItemManager:GetFakeItemRenderData(info))
		end

		store.rewardList:SetSimpleList(#data.award)

		store.isEmptyCtrl = 0
	elseif store.rewardList then
		store.isEmptyCtrl = 1
	end
end

M.RenderActionCell = function(self, store, data, element)
	local pid = data.id
	local memberInfo = self.playerInfoCache[pid]

	if memberInfo and memberInfo.IsRobot then
		element.SetActiveFastest(element, false)

		return
	end

	local isSelf = pid ~= gCarRaceManager:GetPlayerId() or pid ~= gPlayerManager.infoLogin.bindData.pid

	if store.addFriendBtn then
		store.addFriendBtn.luaClick = function()
			self.friendInvited[pid] = true

			gFriendManager:AskApplyFriend(pid)

			store.beFriendCtrl = not self.friendInvited[pid] and not isSelf and not gFriendManager:IsFriend(pid) and 0 or 1
		end

		store.beFriendCtrl = not self.friendInvited[pid] and not isSelf and not gFriendManager:IsFriend(pid) and 0 or 1

		if isSelf then
			element.SetActiveFastest(element, false)
		end
	end

	self.SetupLikeBtn(self, store, pid)
end

M.SetupLikeBtn = function(self, store, pid)
	if not store.likeBtn then
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

M.RefreshInfo = function(self)
	local checkAgainState, keyNameId = self.mgr:CheckAgainState(self.isSuccess)

	if self.mgr.currentGameCfg.MultiType ~= LinkMultiPlayerConfig.MultiTypeType.DeathParty then
		checkAgainState = self.againStateEnum.None
	end

	local againState = self.noAgain and self.againStateEnum.None or checkAgainState
	self.bindData.againState = againState
	self.againKeyNameId = keyNameId

	self.bindData.againBtn:SetPCKeyInfoTipNameId(keyNameId)
	self.bindData.navigationArea:SetButtonInfoTipNameId(keyNameId, 0)
	self:RefreshAgainBtnName(self.leaveShownSec > 0 and self.leaveShownSec or 0)

	local showProgress = not table.isNilOrEmpty(self.mgr.tryAgainDict)

	if self.bindData.showProgress == BOOL2CTL[showProgress] then
		self.bindData.countDown:Play(LinkConfig.ClearingMaxTime)
	end

	self.bindData.showProgress = BOOL2CTL[showProgress]
	self.bindData.againLabel = self.mgr:GetAgainLabel(self.bindData.againState)

	if againState ~= C_LinkManager.AGAIN_STATE.None then
		self.bindData.againBtn.interactable = false

		if not self.bindData.backGround.interactable then
			self.bindData.backGround.interactable = true
		end
	end

	self.bindData.proposalStateCtrl = self.proposalStateCtrlEnum.going

	for _, isTryAgain in pairs(self.mgr.tryAgainDict) do
		if not isTryAgain then
			self.bindData.proposalStateCtrl = self.proposalStateCtrlEnum.paused
			self.bindData.againState = C_LinkManager.AGAIN_STATE.None

			break
		end
	end
end

M.OnCountDownFinished = function(self)
	self.bindData.showProgress = BOOL2CTL[false]
	self.bindData.backGround.interactable = true
end

M.RefreshWatchState = function(self)
	self.bindData.showWatchPlayerBtnCtrl = self.showWatchPlayerBtnCtrlEnum._false
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
		self.OnClickBackGround(self)

		return
	end

	if leftSec == self.leaveShownSec then
		self.leaveShownSec = leftSec

		self.RefreshAgainBtnName(self, leftSec)
	end
end
