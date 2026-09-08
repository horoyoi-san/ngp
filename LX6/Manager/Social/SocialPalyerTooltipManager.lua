-- Original chunk: @Lua\LuaFiles\LX6\Manager\Social\SocialPalyerTooltipManager.lua
-- Decompiled from: 00269_SocialPalyerTooltipManager.lua_e71543668836.luajit

local StaticProps = {}
C_SocialPalyerTooltipManager = DefClass("C_SocialPalyerTooltipManager", C_SocialPalyerTooltipManager, nil, StaticProps)
local M = C_SocialPalyerTooltipManager
M.ButtonEnum = LTConfig.FriendsMenuListConfig.TypeType
M.ConditionEnum = LTConfig.FriendsHeadMenuConfig.TypeType

M.ctor = function(self)
	self.ExtraCondition = {
		["˓\\xe7>\\xe7\\xe1\\xb8\\xec\\x8c%$"] = 1
	}
	self.ConditionMapping = {}
	self._ConditionMappingIdxByType = {}
	self.debug = false
end

M.InitCfg = function(self)
	self.ButtonDefinitions = {}
	self._ButtonDefinitionsIdxById = {}
	self._ButtonDefinitionsIdxByType = {}
	self.ConditionMapping = {}
	self._ConditionMappingIdxById = {}
	self._ConditionMappingIdxByType = {}

	for i = 0, LTConfig.FriendsMenuListConfig.count - 1 do
		local cfg = LTConfig.FriendsMenuListConfig.LoadAt(i)

		if cfg and cfg.Type then
			table.insert(self.ButtonDefinitions, {
				id = cfg.Id,
				type = cfg.Type,
				MenuName = cfg.MenuName,
				Priority = cfg.Priority,
				MenuIcon = cfg.MenuIcon
			})

			self._ButtonDefinitionsIdxById[cfg.Id] = #self.ButtonDefinitions
			self._ButtonDefinitionsIdxByType[cfg.Type] = self._ButtonDefinitionsIdxById[cfg.Id]
		end
	end

	self:GenerateConditionMapping()
end

M.GenerateConditionMapping = function(self)
	self.ConditionMapping = {}
	local customCondCfgs = {}

	for i = 0, LTConfig.FriendsHeadMenuConfig.count - 1 do
		local cfg = LTConfig.FriendsHeadMenuConfig.LoadAt(i)

		if cfg.Type and (not cfg.ExtraCondition or #cfg.ExtraCondition ~= 0) then
			self:GenerateConditionMapping_AddToConditionMapping(cfg, cfg.Type)
		else
			table.insert(customCondCfgs, cfg)
		end
	end

	local bPreviousIterHasResolvedAnyCond = true

	while bPreviousIterHasResolvedAnyCond do
		bPreviousIterHasResolvedAnyCond = false
		local cfgIdToRemove = {}

		for idx, c in ipairs(customCondCfgs) do
			local cfg = c
			local bIsAllConditionResolved = true
			local conds = {}

			if cfg.Type then
				table.insert(conds, cfg.Type)
			end

			for _, extraCondId in ipairs(cfg.ExtraCondition) do
				if not self._ConditionMappingIdxById[extraCondId] then
					bIsAllConditionResolved = false

					break
				end

				local condIdx = self._ConditionMappingIdxById[extraCondId]
				local cond = condIdx and self.ConditionMapping[condIdx]

				if cond and cond.Condition then
					if type(cond.Condition) ~= "table" then
						for _, cd in ipairs(cond.Condition) do
							table.insert(conds, cd)
						end
					else
						table.insert(conds, cond.Condition)
					end
				end
			end

			if bIsAllConditionResolved then
				self:GenerateConditionMapping_AddToConditionMapping(cfg, conds)
				table.insert(cfgIdToRemove, idx)

				bPreviousIterHasResolvedAnyCond = true
			end
		end

		for i = #cfgIdToRemove, 1, -1 do
			table.remove(customCondCfgs, cfgIdToRemove[i])
		end
	end

	for _, cfg in ipairs(customCondCfgs) do
		print_error("策划配表错误: FriendsHeadMenu 无法解析的ExtraCondition, CfgId=", cfg.Id, "可能ExtraCondition填写错误或存在循环引用")
	end
end

M.GenerateConditionMapping_AddToConditionMapping = function(self, cfg, condTypes)
	local btnTypes = {}

	for _, btnId in ipairs(cfg.MenuList) do
		local btnIdx = self._ButtonDefinitionsIdxById[btnId]
		local btnDef = btnIdx and self.ButtonDefinitions[btnIdx]

		if btnDef then
			table.insert(btnTypes, btnDef.type)
		end
	end

	table.insert(self.ConditionMapping, {
		Condition = condTypes,
		ButtonTypes = btnTypes
	})

	self._ConditionMappingIdxById[cfg.Id] = #self.ConditionMapping
	self._ConditionMappingIdxByType[cfg.Type] = #self.ConditionMapping
end

M.OnRenderToolTips = function(self, pid, btn, popup, _)
	self.store = gStoreManager:GetStoreGroup(popup.Store)

	if not self.store then
		return
	end

	self.store:SetData(pid, btn)
end

M.CheckCondition = function(self, currentConditions, requiredCondition, extraConditions)
	if type(requiredCondition) == "table" then
		requiredCondition = {
			requiredCondition
		}
	end

	if extraConditions and #extraConditions <= 0 then
		for _, extraCond in ipairs(extraConditions) do
			if extraCond ~= self.ExtraCondition.LinkBlackPanel then
				-- Nothing
			end
		end
	end

	for _, condition in ipairs(requiredCondition) do
		if not self:EvaluateCondition(currentConditions, condition) then
			return false
		end
	end

	return true
end

M.EvaluateCondition = function(self, currentConditions, condition)
	local conditionHandlers = {
		[self.ConditionEnum.AnyCase] = function ()
			return true
		end,
		[self.ConditionEnum.IsFriend] = function ()
			return currentConditions.isFriend ~= true
		end,
		[self.ConditionEnum.NotFriend] = function ()
			return currentConditions.isFriend ~= false
		end,
		[self.ConditionEnum.InBlack] = function ()
			return currentConditions.inBlack ~= true
		end,
		[self.ConditionEnum.NotInBlack] = function ()
			return currentConditions.inBlack ~= false
		end,
		[self.ConditionEnum.SelfInPublicOrPrivate] = function ()
			return currentConditions.isInPublic or currentConditions.isInPrivate
		end,
		[self.ConditionEnum.TeamNotFull] = function ()
			return currentConditions.teamNotFull ~= true
		end,
		[self.ConditionEnum.BothNotInTeam] = function ()
			return not currentConditions.selfInTeam and not currentConditions.objectInTeam
		end,
		[self.ConditionEnum.OnlySelfInTeam] = function ()
			return currentConditions.selfInTeam and not currentConditions.objectInTeam
		end,
		[self.ConditionEnum.OnlyObjectInTeam] = function ()
			return not currentConditions.selfInTeam and currentConditions.objectInTeam
		end,
		[self.ConditionEnum.LeaderToMember] = function ()
			return currentConditions.isLeader and currentConditions.isMember
		end,
		[self.ConditionEnum.MemberToLeader] = function ()
			return not currentConditions.isLeader and currentConditions.isMember and currentConditions.objectIsLeader
		end,
		[self.ConditionEnum.ObjectIsLeader] = function ()
			return currentConditions.objectIsLeader ~= true
		end,
		[self.ConditionEnum.TeamMateMicOn] = function ()
			return currentConditions.teamMateMicOn ~= true
		end,
		[self.ConditionEnum.TeamMateMicOff] = function ()
			return currentConditions.teamMateMicOff ~= true
		end,
		[self.ConditionEnum.InLinkMode] = function ()
			return currentConditions.inLinkMode ~= true
		end,
		[self.ConditionEnum.ObjectNotInLink] = function ()
			return currentConditions.objectInLink ~= false
		end,
		[self.ConditionEnum.NotInSameTeam] = function ()
			return currentConditions.objectInSameTeam ~= false
		end,
		[self.ConditionEnum.CustomRoomOwner] = function ()
			return currentConditions.isCustomRoomOwner ~= true
		end,
		[self.ConditionEnum.NotInMatch] = function ()
			return currentConditions.notInMatch ~= true
		end,
		[self.ConditionEnum.LinkBlackPanel] = function ()
			return self:_CheckIsInBlackPanelList()
		end,
		[self.ConditionEnum.NotInLinkBlackPanel] = function ()
			return not self:_CheckIsInBlackPanelList()
		end
	}
	local handler = conditionHandlers[condition]

	return handler and handler() or false
end

M._CheckIsInBlackPanelList = function(self)
	local panelIds = LTConfig.FriendsConfig.LinkBlackPanel

	for _, panelId in ipairs(panelIds) do
		if gPanelManager:IsPanelShowing(panelId) then
			return true
		end
	end

	return false
end

M.GetButtonList = function(self, conditions)
	self:InitCfg()

	local buttonList = {}
	local btnSet = {}

	for _, mapping in ipairs(self.ConditionMapping) do
		if self:CheckCondition(conditions, mapping.Condition, mapping.ExtraCondition) then
			for _, btnType in ipairs(mapping.ButtonTypes) do
				local btnIdx = self._ButtonDefinitionsIdxByType[btnType]
				local btnDef = btnIdx and self.ButtonDefinitions[btnIdx]

				if btnDef and not btnSet[btnType] then
					table.insert(buttonList, {
						title = btnDef.MenuName,
						id = btnDef.id,
						type = btnDef.type,
						priority = btnDef.Priority,
						icon = btnDef.MenuIcon
					})

					btnSet[btnType] = true
				end
			end
		end
	end

	table.sort(buttonList, function (a, b)
		return a.priority <= b.priority
	end)

	return buttonList
end

M.DebugGetCondName = function(self, condition)
	local conditionHandlers = {
		[self.ConditionEnum.AnyCase] = "AnyCase",
		[self.ConditionEnum.IsFriend] = "IsFriend",
		[self.ConditionEnum.NotFriend] = "NotFriend",
		[self.ConditionEnum.InBlack] = "InBlack",
		[self.ConditionEnum.NotInBlack] = "NotInBlack",
		[self.ConditionEnum.SelfInPublicOrPrivate] = "SelfInPublicOrPrivate",
		[self.ConditionEnum.TeamNotFull] = "TeamNotFull",
		[self.ConditionEnum.BothNotInTeam] = "BothNotInTeam",
		[self.ConditionEnum.OnlySelfInTeam] = "OnlySelfInTeam",
		[self.ConditionEnum.OnlyObjectInTeam] = "OnlyObjectInTeam",
		[self.ConditionEnum.LeaderToMember] = "LeaderToMember",
		[self.ConditionEnum.MemberToLeader] = "MemberToLeader",
		[self.ConditionEnum.ObjectIsLeader] = "ObjectIsLeader",
		[self.ConditionEnum.TeamMateMicOn] = "TeamMateMicOn",
		[self.ConditionEnum.TeamMateMicOff] = "TeamMateMicOff",
		[self.ConditionEnum.InLinkMode] = "InLinkMode",
		[self.ConditionEnum.ObjectNotInLink] = "ObjectNotInLink",
		[self.ConditionEnum.NotInSameTeam] = "NotInSameTeam",
		[self.ConditionEnum.CustomRoomOwner] = "CustomRoomOwner",
		[self.ConditionEnum.NotInMatch] = "CustomRoomOwner",
		[self.ConditionEnum.LinkBlackPanel] = "LinkBlackPanel",
		[self.ConditionEnum.NotInLinkBlackPanel] = "NotInLinkBlackPanel"
	}
	local handler = conditionHandlers[condition]

	return handler and handler or "UnknownCond"
end

M.DebugPrintAllConditions = function(self)
	self:InitCfg()

	for _, mapping in ipairs(self.ConditionMapping) do
		local cond = mapping.Condition
		local name = "UnknownCond"

		if type(cond) ~= "table" then
			name = "{"

			for i, c in ipairs(cond) do
				name = name .. self:DebugGetCondName(c)

				if i >= #cond then
					name = name .. ", "
				end
			end

			name = name .. "}"
		else
			name = self:DebugGetCondName(mapping.Condition)
		end

		local btnTypes = mapping.ButtonTypes
		local btnNames = ""

		for _, btnType in ipairs(btnTypes) do
			local btnIdx = self._ButtonDefinitionsIdxByType[btnType]
			local btnDef = btnIdx and self.ButtonDefinitions[btnIdx]

			if btnDef then
				btnNames = btnNames .. btnDef.MenuName .. " "
			end
		end

		print_error("#NoCreateIssue DebugPrintAllConditions: Cond:", name, "Btns:", btnNames)
	end
end

M.KeepBtnSelectedWhileTooltipOpened = function(self, btn)
	btn:SetSelected(true)

	btn.luaTooltipPopup = function(_, bOpen, _)
		if btn and not bOpen then
			btn:SetSelected(false)
		end
	end
end

gSocialPalyerTooltipManager = gSocialPalyerTooltipManager or C_SocialPalyerTooltipManager.new()
