-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\GangMap3DPanelStore.lua
-- Decompiled from: 01750_GangMap3DPanelStore.lua_3843d8b17b47.luajit

local FactionConfig = LTConfig.FactionConfig
local FactionInfluenceAreaConfig = LTConfig.FactionInfluenceAreaConfig
local TaskEventConfig = LTConfig.TaskEventConfig
C_GangMap3DPanelStore = DefClass("C_GangMap3DPanelStore", C_GangMap3DPanelStore, C_StoreGroup)
GroupName2Class.GangMap3DPanelStore = C_GangMap3DPanelStore
local M = C_GangMap3DPanelStore
local StateCtrl = {
	["\\x91;4{\\x9eT\\xc9>\\xaf\\xbd"] = 0,
	["G\\x92\\x85\\x86E"] = 3,
	["\\xa4\\xb2\\xbez7\\xfb7"] = 1,
	["\\xad\\xb8\\xa3~7\\xf04"] = 2
}
local BtnCode2AreaId = {
	[0] = 1001,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	1021,
	1022,
	1023,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	1061,
	1062,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	1041,
	1042,
	1043,
	1044,
	1045,
	nil,
	nil,
	nil,
	nil,
	nil,
	1011,
	1012,
	1013,
	1014,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	1051,
	1052,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	1031,
	1032,
	[72.0] = 1072,
	[71.0] = 1071
}

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.taskEventId = 0
	self.rewardListData = {}
	self.areaOwnerMap = {}
end

M.DefineAllEnumsAutoGen = function(self)
	self.selectCtrlEnum = {
		["\\xaf\\xb4\\xaa2\\xeac"] = 0,
		["\\xaf\\xb4\\xaa2\\xeae"] = 6,
		["\\xaf\\xb4\\xaa2\\xeab"] = 1,
		["\\xaf\\xb4\\xaa2\\xead"] = 7,
		["\\xaf\\xb4\\xaa2\\xeaa"] = 2,
		["\\xaf\\xb4\\xaa2\\xeag"] = 4,
		["\\xaf\\xb4\\xaa2\\xea`"] = 3,
		["\\xaf\\xb4\\xaa2\\xeaf"] = 5
	}
	self.stateCtrl1Enum = {
		["\\x91;4{\\x9eT\\xc9>\\xaf\\xbd"] = 0,
		["G\\x92\\x85\\x86E"] = 3,
		["\\xa4\\xb2\\xbez7\\xfb7"] = 1,
		["\\xad\\xb8\\xa3~7\\xf04"] = 2
	}
	self.stateCtrl2Enum = {
		["\\x91;4{\\x9eT\\xc9>\\xaf\\xbd"] = 0,
		["G\\x92\\x85\\x86E"] = 3,
		["\\xa4\\xb2\\xbez7\\xfb7"] = 1,
		["\\xad\\xb8\\xa3~7\\xf04"] = 2
	}
	self.stateCtrl3Enum = {
		["\\x91;4{\\x9eT\\xc9>\\xaf\\xbd"] = 0,
		["G\\x92\\x85\\x86E"] = 3,
		["\\xa4\\xb2\\xbez7\\xfb7"] = 1,
		["\\xad\\xb8\\xa3~7\\xf04"] = 2
	}
	self.stateCtrl4Enum = {
		["\\x91;4{\\x9eT\\xc9>\\xaf\\xbd"] = 0,
		["G\\x92\\x85\\x86E"] = 3,
		["\\xa4\\xb2\\xbez7\\xfb7"] = 1,
		["\\xad\\xb8\\xa3~7\\xf04"] = 2
	}
	self.stateCtrl5Enum = {
		["\\x91;4{\\x9eT\\xc9>\\xaf\\xbd"] = 0,
		["G\\x92\\x85\\x86E"] = 3,
		["\\xa4\\xb2\\xbez7\\xfb7"] = 1,
		["\\xad\\xb8\\xa3~7\\xf04"] = 2
	}
	self.stateCtrl6Enum = {
		["\\x91;4{\\x9eT\\xc9>\\xaf\\xbd"] = 0,
		["G\\x92\\x85\\x86E"] = 3,
		["\\xa4\\xb2\\xbez7\\xfb7"] = 1,
		["\\xad\\xb8\\xa3~7\\xf04"] = 2
	}
	self.stateCtrl7Enum = {
		["\\x91;4{\\x9eT\\xc9>\\xaf\\xbd"] = 0,
		["G\\x92\\x85\\x86E"] = 3,
		["\\xa4\\xb2\\xbez7\\xfb7"] = 1,
		["\\xad\\xb8\\xa3~7\\xf04"] = 2
	}
	self.toolTipCtrlEnum = {
		["\\xad\\xb8\\xa3~7\\xf04"] = 3,
		["G\\x92\\x85\\x86E"] = 4,
		["\\xa4\\xb2\\xbez7\\xfb7"] = 2,
		["\\x91;4{\\x9eT\\xc9>\\xaf\\xbd"] = 1,
		["t-s^"] = 0
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.selectCtrlEnum = nil
	self.stateCtrl1Enum = nil
	self.stateCtrl2Enum = nil
	self.stateCtrl3Enum = nil
	self.stateCtrl4Enum = nil
	self.stateCtrl5Enum = nil
	self.stateCtrl6Enum = nil
	self.stateCtrl7Enum = nil
	self.toolTipCtrlEnum = nil
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
	self.curBtnCode = 0

	self.RefreshAllAreaOwners(self)
	self.RefreshAllAreaColors(self)
	self.RefreshFactionState(self)
	self.RefreshSelectState(self)
	self.RefreshToolTip(self)

	if data and data.enableNavi then
		self.bindData.navi.enabled = true

		self.rootGo.transform:ChangeLayersRecursively(Layer.WorldUI_HitMaterial)
	else
		self.bindData.navi.enabled = false

		self.rootGo.transform:ChangeLayersRecursively(Layer.Default)
	end

	if data and data.uiPivot then
		local uiPivot = data.uiPivot

		if not gClientUtils.IsNil(uiPivot) then
			self.rootGo.transform.position = uiPivot.position
			self.rootGo.transform.rotation = uiPivot.rotation
			self.rootGo.transform.localScale = uiPivot.localScale
		end
	end
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.TASK_EVENT_CHANGE] = function ()
			self:RefreshFactionState()
		end,
		[gEventConstants.ON_MAP_GANGSTER_AREA_DIRTY] = function ()
			self:RefreshAllAreaOwners()
			self:RefreshAllAreaColors()
			self:RefreshToolTip()
		end
	}
end

M.RegisterWidget = function(self)
	for btnCode, _ in pairs(BtnCode2AreaId) do
		local btn = self.bindData["btn" .. btnCode]

		if btn then
			btn.luaClick = self.CreateActionWithArgs(self, "OnClickBlockBtn", btnCode)
		end
	end

	self.bindData.acceptTaskBtn.luaClick = self.CreateAction(self, "OnClickAcceptTaskBtn")
	self.bindData.closeBtn.luaClick = self.CreateAction(self, "OnClickCloseBtn")
	self.bindData.rewardList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderRewardListItem")
end

M.OnClickBlockBtn = function(self, btnCode)
	self.curBtnCode = btnCode
	self.curSelectFactionId = self.areaOwnerMap[btnCode]

	self.RefreshSelectState(self)
	self.RefreshToolTip(self)
end

M.OnClickAcceptTaskBtn = function(self)
	if self.taskEventId ~= 0 then
		return
	end

	local taskId = gTaskManager:GetTaskEventNowTask(self.taskEventId)

	if taskId ~= 0 then
		return
	end

	slot2 = gTaskManager

	slot2:SetCurrentTask(taskId, function ()
		self:RefreshFactionState()
		self:RefreshSelectState()
		self:RefreshToolTip()

		self.bindData.navi.enabled = false

		gPanelManager:SetActiveById(self.m_Id, false)
		gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnReceiveSignal, {
			["PNkgO:!"] = "\\xb85.8U\\x9cQ\\xfc/\\xa3\\xad"
		})
	end)
end

M.OnClickCloseBtn = function(self)
	self.bindData.toolTipCtrl = self.toolTipCtrlEnum.none
	self.bindData.navi.enabled = false

	gPanelManager:SetActiveById(self.m_Id, false)
	gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnReceiveSignal, {
		["PNkgO:!"] = "\\xb85.8U\\x9cQ\\xfc/\\xa3\\xad"
	})
	self.rootGo.transform:ChangeLayersRecursively(Layer.Default)
end

M.OnSimpleRenderRewardListItem = function(self, btn, index)
	local itemData = self.rewardListData[index + 1]
	local renderData = gCommonItemManager:GetItemRenderData({
		["\\xd0\\xcf01\\xfc"] = 0,
		itemId = itemData
	})

	gCommonItemManager:OnCommonItemRender(btn, index, renderData)
end

M.GetFactionState = function(self, factionId)
	local cfg = FactionConfig.GetConfig(factionId)

	if not cfg then
		return StateCtrl.locked
	end

	local eventList = cfg.FactionTaskEvent

	if table.isNilOrEmpty(eventList) then
		return StateCtrl.locked
	end

	local isLocked = true
	local curState, curEventId = nil
	local isFinish = false
	local finishCount = 0

	for i = 1, #eventList do
		local eventId = eventList[i]
		local state = gTaskManager:GetTaskEventState(eventId)

		if state ~= UX.Game.TaskEventState.NotAccept or state ~= UX.Game.TaskEventState.Accepted then
			curState = state
			curEventId = eventId
			isLocked = false

			break
		elseif state ~= UX.Game.TaskEventState.Submited then
			finishCount = finishCount + 1

			if finishCount ~= #eventList then
				isFinish = true
			end
		end
	end

	if isFinish then
		return StateCtrl.occupied
	elseif isLocked then
		return StateCtrl.locked
	elseif curState ~= UX.Game.TaskEventState.NotAccept then
		return StateCtrl.notOccupied, curEventId
	elseif curState ~= UX.Game.TaskEventState.Accepted then
		return StateCtrl.fighting, curEventId
	end
end

M.RefreshFactionState = function(self)
	local groups = {}

	for btnCode, _ in pairs(BtnCode2AreaId) do
		local idx = math.floor(btnCode / 10)

		if idx > 1 and idx < 7 then
			groups[idx] = groups[idx] or {}

			table.insert(groups[idx], btnCode)
		end
	end

	for factionIndex = 1, 7 do
		local btnCodes = groups[factionIndex]
		local state = nil

		if not btnCodes or #btnCodes ~= 0 then
			state = StateCtrl.locked
		else
			local commonOwner = nil
			local mixed = false

			for i, btnCode in ipairs(btnCodes) do
				local owner = self.areaOwnerMap[btnCode]

				if i ~= 1 then
					commonOwner = owner
				elseif owner == commonOwner then
					mixed = true

					break
				end
			end

			if mixed then
				state = StateCtrl.fighting
			else
				state = self.GetFactionState(self, commonOwner)
			end
		end

		self.bindData["stateCtrl" .. factionIndex] = state
	end
end

M.RefreshAllAreaOwners = function(self)
	local helper = gMapSubSystem_Gangster and gMapSubSystem_Gangster.helper

	if not helper then
		return
	end

	for btnCode, areaId in pairs(BtnCode2AreaId) do
		if areaId ~= 0 then
			print_error("@lujunlin:区块配置错误！btnCode=", btnCode, " 该区块没有对应的AreaId，请联系策划或程序！")
		end

		self.areaOwnerMap[btnCode] = helper.GetAreaOwner(helper, areaId)
	end
end

M.RefreshAreaOwnerByAreaId = function(self, areaId)
	local helper = gMapSubSystem_Gangster and gMapSubSystem_Gangster.helper

	if not helper then
		return
	end

	for btnCode, aid in pairs(BtnCode2AreaId) do
		if aid ~= areaId then
			self.areaOwnerMap[btnCode] = helper.GetAreaOwner(helper, areaId)
			local btn = self.bindData["btn" .. btnCode]

			if btn then
				local color = self.GetAreaColor(self, btnCode)

				if color then
					btn.color = color
				end
			end
		end
	end
end

M.GetAreaColor = function(self, btnCode)
	local ownerFactionId = self.areaOwnerMap[btnCode]

	if ownerFactionId then
		local cfg = FactionConfig.GetConfig(ownerFactionId)

		if cfg and cfg.PolygonColor and cfg.PolygonColor == "" then
			local color = Color.NewByStr(cfg.PolygonColor)
			color.a = 1

			return color
		end
	end

	if FactionConfig.NeturalPolygonColor and FactionConfig.NeturalPolygonColor == "" then
		local color = Color.NewByStr(FactionConfig.NeturalPolygonColor)
		color.a = 1

		return color
	end

	return nil
end

M.RefreshAllAreaColors = function(self)
	for btnCode, _ in pairs(BtnCode2AreaId) do
		local btn = self.bindData["btn" .. btnCode]

		if btn then
			local color = self.GetAreaColor(self, btnCode)

			if color then
				local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
				store.color = color
			end
		end
	end
end

M.RefreshSelectState = function(self)
	self.curBtnCode = self.curBtnCode or 0
	self.bindData.selectCtrl = self.curBtnCode / 10
end

M.RefreshToolTip = function(self)
	local selectFactionId = self.curSelectFactionId
	local cfg = FactionConfig.GetConfig(selectFactionId)

	if not cfg then
		return
	end

	local factionName = cfg.name
	self.bindData.gangNameText = factionName
	local state, eventId = self.GetFactionState(self, self.curSelectFactionId)

	if state ~= StateCtrl.locked then
		local eventList = cfg.FactionTaskEvent

		if not table.isNilOrEmpty(eventList) then
			local taskEventCfg = TaskEventConfig.GetConfig(eventList[1])
			local unlockDes = taskEventCfg.UnlockDescription or ""
			self.bindData.lockText = unlockDes
		else
			self.bindData.lockText = FactionConfig.FactionLockText
		end

		self.bindData.toolTipCtrl = self.toolTipCtrlEnum.locked
		self.taskEventId = 0
	elseif state ~= StateCtrl.occupied then
		self.bindData.toolTipCtrl = self.toolTipCtrlEnum.occupied
		self.taskEventId = 0
	elseif state ~= StateCtrl.notOccupied then
		self.taskEventId = eventId
		self.bindData.toolTipCtrl = self.toolTipCtrlEnum.notOccupied
	elseif state ~= StateCtrl.fighting then
		self.bindData.toolTipCtrl = self.toolTipCtrlEnum.fighting
		self.taskEventId = 0
	end

	local rewardList = cfg.FactionLootPreview

	table.clear(self.rewardListData)

	for _, id in ipairs(rewardList) do
		table.insert(self.rewardListData, id)
	end

	self.bindData.rewardList:SetSimpleList(#self.rewardListData)
end
