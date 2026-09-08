-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CommonSingleTeamRankPanelStore.lua
-- Decompiled from: 01534_CommonSingleTeamRankPanelStore.lua_3c569d637847.luajit

C_CommonSingleTeamRankPanelStore = DefClass("C_CommonSingleTeamRankPanelStore", C_CommonSingleTeamRankPanelStore, C_StoreGroup)
GroupName2Class.CommonSingleTeamRankPanelStore = C_CommonSingleTeamRankPanelStore
local M = C_CommonSingleTeamRankPanelStore
local HEADER_TEMPLATE = 0

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.showList = {}
	self.columnDefs = {}
	self.onClickBack = nil
	self.onClickAgain = nil
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
	self.completeStateCtrlEnum = {
		["|#tW"] = 0,
		["\\xaf\\xb4\\xaa2\\xea`"] = 3,
		["\\xca\\xce!\\xf5"] = 1,
		["t-s^"] = 2
	}
	self.showWatchPlayerBtnCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.againStateEnum = nil
	self.showProgressEnum = nil
	self.completeStateCtrlEnum = nil
	self.showWatchPlayerBtnCtrlEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
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
	if table.isNilOrEmpty(data) then
		print_error("CommonSingleTeamRankPanelStore OnShow data is nil")
		self.OnClickBackGround(self)

		return
	end

	self.showList = data.data or {}
	self.columnDefs = data.columnDefs or {}
	self.isSuccess = data.isSuccess
	self.onClickBack = data.onClickBack
	self.onClickAgain = data.onClickAgain
	self.bindData.titleLabel = data.title or ""
	self.bindData.completeStateCtrl = data.isSuccess and self.completeStateCtrlEnum.succeed or self.completeStateCtrlEnum.fail
	self.bindData.succeedTitle = data.succeedTitle or ""
	self.bindData.failedTitle = data.failedTitle or ""
	self.bindData.againState = data.showAgain and self.againStateEnum.Again or self.againStateEnum.None
	self.bindData.againBtn.interactable = data.showAgain and true or false
	self.bindData.backGround.interactable = true
	local keyNameId = data.againKeyNameId or 244

	self.bindData.againBtn:SetPCKeyInfoTipNameId(keyNameId)
	self.bindData.navigationArea:SetButtonInfoTipNameId(keyNameId, 0)
	self:InitTableColumns()
	self.bindData.rankTable:SetTable(#self.showList)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
	self.bindData.rankTable:RefreshTable()
end

M.RegisterWidget = function(self)
	self.bindData.backGround.luaClick = self.CreateAction(self, self.OnClickBackGround)
	self.bindData.againBtn.luaClick = self.CreateAction(self, self.OnClickAgainBtn)
	self.bindData.watchBtn.luaClick = self.CreateAction(self, self.OnClickWatchBtn)
	self.bindData.rankTable.luaRenderCol = self.CreateAction(self, self.OnRenderCol)
	self.bindData.rankTable.luaRenderRow = self.CreateAction(self, self.OnRenderRow)
end

M.OnClickBackGround = function(self)
	if self.onClickBack then
		self.onClickBack()
	end

	gPanelManager:Close(gPanelId.COMMON_SINGLE_TEAM_RANK)
end

M.OnClickAgainBtn = function(self)
	self.bindData.backGround.interactable = false
	self.bindData.againBtn.interactable = false

	if self.onClickAgain then
		self.onClickAgain()
	end

	gPanelManager:Close(gPanelId.COMMON_SINGLE_TEAM_RANK)
end

M.OnClickWatchBtn = function(self)
end

M.InitTableColumns = function(self)
	local uTable = self.bindData.rankTable
	local colCount = #self.columnDefs

	uTable.SetColData(uTable, colCount)

	for i = 0, colCount - 1 do
		local colDef = self.columnDefs[i + 1]
		local col = uTable.colData[i]
		col.title = colDef.headerName
		col.colTemplateIndex = HEADER_TEMPLATE
		col.elementTemplateIndex = colDef.templateIndex
		col.width = colDef.width
	end

	uTable.ResetColData(uTable)
end

M.OnRenderCol = function(self, col)
	local btn = col.colButton
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if store then
		local colDef = self.columnDefs[col.index + 1]
		store.title = colDef and colDef.headerName or ""
	end
end

M.OnRenderRow = function(self, row)
	local uTable = self.bindData.rankTable
	local dataIndex = uTable.GetChildIndex(uTable, row)
	local data = self.showList[dataIndex + 1]

	if not data then
		return
	end

	for i = 0, row.rowElements.Count - 1 do
		local colDef = self.columnDefs[i + 1]

		if not colDef then
			break
		end

		local element = row.rowElements[i]
		local store = gStoreManager:GetStoreGroup(element.Store):GetStoreByWidget(element)

		if store then
			self.RenderCell(self, store, colDef, data, dataIndex)
		end
	end
end

M.RenderCell = function(self, store, colDef, data, dataIndex)
	local colType = colDef.colType

	if colType ~= "rank" then
		self.RenderRankCell(self, store, data, dataIndex)
	elseif colType ~= "player" then
		self.RenderPlayerCell(self, store, data)
	elseif colType ~= "custom_text" then
		self.RenderCustomTextCell(self, store, colDef, data)
	elseif colType ~= "reward" then
		self.RenderRewardCell(self, store, data)
	end
end

M.RenderRankCell = function(self, store, data, dataIndex)
	store.title = tostring(dataIndex + 1)
end

M.RenderPlayerCell = function(self, store, data)
	store.nameLabel = data.playerName or ""
	store.headIcon = data.playerHeadIcon or 0
	store.numberLabelName = data.playerNumber or ""
	store.numberLabelAvatar = data.playerNumber or ""
	local color = data.playerColor or ""
	store.colorName = color
	store.colorAvatar = color
	store.showPlayerNumberCtrlAvatar = data.showPlayerNumber or 0
	store.showPlayerNumberCtrlName = 0
	store.showAvatarCtrl = 1
	store.headBtn.interactable = false
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
