-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\MapSubSystem\MapSubSystem_PublicEvent.lua
-- Decompiled from: 02312_MapSubSystem_PublicEvent.lua_fce706e10a55.luajit

local TaskEventConfig = LTConfig.TaskEventConfig
local PublicEventConfig = LTConfig.PublicEventConfig
MapSubSystem_PublicEvent = DefClass("MapSubSystem_PublicEvent", MapSubSystem_PublicEvent, MapSubSystemBase)
local M = MapSubSystem_PublicEvent

M.OnInit = function(self)
	self.publicEventElements = {}
end

M.OnLoadData = function(self)
	self.ClearData(self)
end

M.OnLogin = function(self)
	self:ClearData()
	self:InitEventHandlers()
	gMessageManager:RegisterEventHandlers(self.eventHandlers)
end

M.OnLogout = function(self)
	self.ClearData(self)
end

M.ClearData = function(self)
end

M.OnSceneInit = function(self)
	self.UpdateAllPublicEventRange(self)
end

M.CheckPublicEventLinkMode = function(self)
	return gLinkManager.LinkMode ~= UX.Game.LinkMode.Public or gLinkManager.LinkMode ~= UX.Game.LinkMode.Private
end

M.OnFlushData = function(self)
	self.UpdateAllPublicEventRange(self)
end

M.UpdateAllPublicEventRange = function(self)
	if not self.CheckPublicEventLinkMode(self) then
		for publicEventId, element in pairs(self.publicEventElements) do
			element.Dispose(element)

			self.publicEventElements[publicEventId] = nil
		end

		return
	end

	self.activePublicEventIds = {}
	local now = LTUtils.UXTime.GetNowUnixTime()

	if gTaskManager.PublicEventInfos and gTaskManager.PublicEventInfos.Count then
		for i = 1, gTaskManager.PublicEventInfos.Count do
			local publicEventInfo = gTaskManager.PublicEventInfos[i]

			self.UpdatePublicEventRange(self, publicEventInfo, now)
		end
	end

	for publicEventId, element in pairs(self.publicEventElements) do
		if not self.activePublicEventIds[publicEventId] or not gTaskManager:GetPublicEventInfo(publicEventId) then
			element.Dispose(element)

			self.publicEventElements[publicEventId] = nil
		end
	end
end

M.GetRelatedPublicEventId = function(self, eventId)
	for i = 0, PublicEventConfig.count - 1 do
		local cfg = PublicEventConfig.LoadAt(i)

		if cfg.EventId ~= eventId then
			return cfg.Id
		end
	end

	return nil
end

M.UpdatePublicEventRange = function(self, publicEventInfo, now)
	if not self.CheckPublicEventLinkMode(self) or not publicEventInfo or not gTaskManager:GetPublicEventInfo(publicEventInfo.CfgId) then
		self.TryDisposePublicEventRangeElement(self, publicEventInfo.CfgId)

		return
	end

	local publicEventId = publicEventInfo.CfgId
	local endTime = publicEventInfo.EndTime or 0

	if endTime <= 0 and endTime < now then
		return
	end

	local publicEventCfg = PublicEventConfig.GetConfig(publicEventId)

	if not publicEventCfg then
		return
	end

	local eventId = publicEventCfg.EventId
	local cfg = TaskEventConfig.GetConfig(eventId)

	if not cfg then
		return
	end

	local taskCfg = gTaskManager:GetTaskConfigInfo(cfg.StartTask)

	if cfg.CenterPos and #cfg.CenterPos > 3 and cfg.CenterRange then
		if not self.publicEventElements[publicEventId] then
			local element = MapElement.CreateLegacy(EMapElementType.PublicEvent, publicEventId, EMapSubSystemType.PublicEvent, EMapViewMask.AllSgui, taskCfg.RelatedRaid, 0)

			element:SetVisible(true)
			element:SetPositionXYZ(cfg.CenterPos[1], cfg.CenterPos[2], cfg.CenterPos[3])

			element.mData.rangeInfo = {
				["\\xe6\\x96\\xed\\xd5\\xe5\\x9fā/&"] = true,
				["QFbnK*="] = 3,
				radius = (cfg.CenterRange or 0) * 0.5,
				color = Color.NewByStr(gTaskManager.TaskColor[taskCfg.Title])
			}
			element.mData.dontCull = true
			element.mData.sIconId = publicEventCfg.SQuestIcon or 0
			element.mData.name = publicEventCfg.Name or ""
			element.gpsData.endTime = gMapSystem:GetCurLinkTag() == UX.Game.LinkTag.PublicEvent and endTime or nil
			element.bigMapData.filterTag = LTConfig.GpsFilterTagConfig.LinkModeCollection
			element.fData.ignoreFog = true
			element.userdata = {
				publicEventId = publicEventId
			}

			element:SetActions(self.NormalTraceableActions)
			gMapSubSystemUtils:SetupScaleLevel(element, publicEventCfg.ShowType, publicEventCfg.SQuestIcon2)

			self.publicEventElements[publicEventId] = element
		else
			local element = self.publicEventElements[publicEventId]
			element.gpsData.endTime = gMapSystem:GetCurLinkTag() == UX.Game.LinkTag.PublicEvent and endTime or nil
		end

		self.activePublicEventIds[publicEventId] = true
	else
		self.TryDisposePublicEventRangeElement(self, publicEventId)
	end
end

M.TryDisposePublicEventRangeElement = function(self, publicEventId)
	if self.publicEventElements[publicEventId] then
		self.publicEventElements[publicEventId]:Dispose()

		self.publicEventElements[publicEventId] = nil
	end
end

M.ExecuteAction = function(self, element, action, ctx)
	if action ~= gMapSystemElementAction.Trace then
		element.SetMainTrace(element)
	elseif action ~= gMapSystemElementAction.Untrace then
		element.ClearMainTrace(element)
	end
end

M.SGetTooltipInfo = function(self, id, element)
	local publicEventId = element.userdata and element.userdata.publicEventId
	local cfg = PublicEventConfig.GetConfig(publicEventId)
	local eventId = cfg and cfg.EventId or 0
	local taskLineInfo = gTaskNodeManager:GetTaskLineById(eventId)
	local taskLineCfg = taskLineInfo and LTConfig.TaskEventConfig.GetConfig(eventId)
	local taskCfg = LTConfig.TaskConfig.GetConfig(taskLineInfo.StartTask)
	local titleCfg = LTConfig.TaskTitleConfig.GetConfig(taskCfg.Title)
	local dropIds = {}
	local dropIdDic = {}

	if cfg then
		if not table.isNilOrEmpty(cfg.SuccessDrop) then
			for _, dropId in pairs(cfg.SuccessDrop) do
				if not dropIdDic[dropId] then
					dropIdDic[dropId] = true

					table.insert(dropIds, dropId)
				end
			end
		end

		if not table.isNilOrEmpty(cfg.FailDrop) then
			for _, dropId in pairs(cfg.FailDrop) do
				if not dropIdDic[dropId] then
					dropIdDic[dropId] = true

					table.insert(dropIds, dropId)
				end
			end
		end
	end

	local tooltipInfo = {
		type = EMapTooltipType.LinkGameplay,
		header = {
			name = element:GetName(),
			imageId = cfg and cfg.STooltipPicId or 0,
			subtitle = titleCfg and titleCfg.Name or ""
		}
	}
	slot13 = {
		title = taskCfg.Title,
		desc = gUtils:GetSpecialDescription(taskLineInfo.EventDescription),
		simpleDropIds = dropIds,
		specificSpirits = gMapSubSystemUtils:GetTaskSpiritRoleTeamList(taskLineCfg),
		timeLimitText = element.userdata.timeLimitTooltipText,
		hideDropInfo = element.bigMapData.hideDropInfo or false
	}

	if element.mData.linkSpecificAgentId ~= 0 then
		-- Nothing
	end

	slot13.linkSpecificAgentId = element.mData.linkSpecificAgentId
	tooltipInfo.linkGameplayInfo = slot13

	return tooltipInfo
end

M.OnSceneDestroy = function(self)
	self.ClearData(self)
end

M.InitEventHandlers = function(self)
	self.eventHandlers = {
		[gEventConstants.TASK_EVENT_CHANGE] = function (eventId, taskEventInfo)
			self:UpdateAllPublicEventRange()
		end,
		[gEventConstants.LINK_MODE_CHANGE] = function ()
			self:UpdateAllPublicEventRange()
		end,
		[gEventConstants.ON_EVENT_STATE_CHANGE] = function ()
			self:UpdateAllPublicEventRange()
		end
	}
end

return M
