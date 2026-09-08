-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CostumNormalStore.lua
-- Decompiled from: 01501_CostumNormalStore.lua_c77f326c227a.luajit

local FashionInteractConfig = LTConfig.FashionInteractConfig
local HudDescConfig = LTConfig.HudDescConfig
local InputButtonNameConfig = LTConfig.InputButtonNameConfig
C_CostumNormalStore = DefClass("C_CostumNormalStore", C_CostumNormalStore, C_StoreGroup)
GroupName2Class.CostumNormalStore = C_CostumNormalStore
local M = C_CostumNormalStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.isStart = false
	self.interactId = 0
	self.queryToInteractId = nil
end

M.DefineAllEnumsAutoGen = function(self)
	self.statusCtrlEnum = {
		["4G\\x9e\\x8a\\xacO"] = 1,
		["\\xf1\\xd41\"\\xf7"] = 0
	}
	self.energyCtrlEnum = {
		["?@\\x90\\x9c\\x84D"] = 1,
		["G\\x83\\x83\\x82M"] = 0
	}
	self.btnInCDCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.btnHideCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.skillTypeCtrlEnum = {
		["\\xb2!,+q\\xbeI\\xd8%\\xad\\xbc"] = 2,
		["~O©\\x8d8\\xb0\\xda\\xed"] = 1,
		["2G\\x83\\x83\\x82M"] = 0
	}
	self.multiChrageCDCtrlEnum = {
		["\\xab\\xa3\\xab\\xaf"] = 1,
		["S,^_"] = 2,
		["?G\\x84\\x80\\x97"] = 0
	}
	self.wordsCtrlEnum = {
		["k\\xaf\\xae\\xbc\\xb3"] = 0,
		["N0h^"] = 1
	}
	self.buttonCtrlEnum = {
		["\\x8c(6\\x95M\\xd00\\xa2\\xad"] = 7,
		["Px|{K\r<"] = 6,
		["KNkaB,"] = 2,
		["\\xca\\xe41\\xe2"] = 8,
		["\\xb8\\x8e\\xa4x3\\xff?"] = 5,
		["\\xaf\\xb8\\xaah2\\xfb7"] = 4,
		["\\xc9\\xc9\r!\\xf5"] = 1,
		["K\\xa1\\xa1\\xba\\xa5"] = 3,
		["G\\x83\\x83\\x82M"] = 0
	}
	self.qteVxCtrlEnum = {
		["\\xaf\\xb4\\xaa2\\xeaa"] = 2,
		["#N\\x90\\x82\\x90D"] = 0,
		["i*rL"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.statusCtrlEnum = nil
	self.energyCtrlEnum = nil
	self.btnInCDCtrlEnum = nil
	self.btnHideCtrlEnum = nil
	self.skillTypeCtrlEnum = nil
	self.multiChrageCDCtrlEnum = nil
	self.wordsCtrlEnum = nil
	self.buttonCtrlEnum = nil
	self.qteVxCtrlEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
	gMessageManager:SendMessage(gEventConstants.CORE_HUD_DESC_REFRESH, {
		storeName = self.m_Name
	})
	self:RefreshInteractableState()
end

M.OnStart = function(self)
	self.onBtn = self.GetStoreByWidget(self, self.bindData.onBtn)
	self.onBtn.btnId = HudDescConfig.ON_BTN
	self.offBtn = self.GetStoreByWidget(self, self.bindData.offBtn)
	self.offBtn.btnId = HudDescConfig.OFF_BTN
	self.isStart = true

	self.SetCostumeText(self, self.interactId)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
	self.BuildQueryMap(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, interactId, interactState)
	self:SetCostumeText(interactId)

	self.interactId = interactId or 0
	self.interactState = interactState or 0
	self.bindData.statusCtrl = interactState or 0

	self:RefreshInteractableState()
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.FASHION_INTERACT_CHANGE] = self.CreateAction(self, "OnFashionInteractChange"),
		[gEventConstants.FASHION_INTERACT_ON_ING] = self.CreateActionWithArgs(self, "OnBanFashionInteract", "onInteractable"),
		[gEventConstants.FASHION_INTERACT_OFF_ING] = self.CreateActionWithArgs(self, "OnBanFashionInteract", "offInteractable")
	}
end

M.RegisterWidget = function(self)
	self.bindData.onBtn.luaClick = self.CreateAction(self, "OnClickOnBtn")
	self.bindData.offBtn.luaClick = self.CreateAction(self, "OnClickOffBtn")
end

M.SetCostumeText = function(self, interactId)
	if not self.isStart then
		return
	end

	if interactId == 0 then
		local interactConfig = FashionInteractConfig.GetConfig(interactId)
		local offText = InputButtonNameConfig.GetConfig(interactConfig.button[1]).Name
		local onText = InputButtonNameConfig.GetConfig(interactConfig.button[2]).Name
		self.offBtn.notifyWord = offText
		self.onBtn.notifyWord = onText

		self.bindData.offBtn:SetPCKeyInfoTipNameId(interactConfig.button[1])
		self.bindData.onBtn:SetPCKeyInfoTipNameId(interactConfig.button[2])
	end
end

M.OnClickOnBtn = function(self)
	local interactConfig = FashionInteractConfig.GetConfig(self.interactId)

	if not interactConfig then
		return
	end

	local onEventId = interactConfig.signal[self.interactState + 1]

	if onEventId then
		gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, onEventId)
	end
end

M.OnClickOffBtn = function(self)
	local interactConfig = FashionInteractConfig.GetConfig(self.interactId)

	if not interactConfig then
		return
	end

	local onEventId = interactConfig.signal[self.interactState + 1]

	if onEventId then
		gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, onEventId)
	end
end

M.OnFashionInteractChange = function(self, eventId, interactId, interactState)
	if interactId == self.interactId then
		self.SetCostumeText(self, interactId)
	end

	self.interactId = interactId
	self.bindData.statusCtrl = interactState
	self.interactState = interactState
end

M.OnBanFashionInteract = function(self, btnName, eventId, queryId, canUse)
	self.bindData[btnName] = canUse
	local interactId = self.queryToInteractId and self.queryToInteractId[queryId]

	if interactId then
		local cfg = FashionInteractConfig.GetConfig(interactId)

		if cfg then
			local actionName = nil

			if btnName ~= "onInteractable" and canUse then
				actionName = cfg.OnAction
			elseif btnName ~= "offInteractable" and not canUse then
				actionName = cfg.OffAction
			end

			if not string.is_null_or_empty(actionName) then
				local func = self[actionName]

				if func then
					func(self)
				end
			end
		end
	end
end

M.BuildQueryMap = function(self)
	self.queryToInteractId = {}

	for i = 0, FashionInteractConfig.count - 1 do
		local cfg = FashionInteractConfig.LoadAt(i)

		if cfg and cfg.QueryIds then
			for _, queryId in ipairs(cfg.QueryIds) do
				self.queryToInteractId[queryId] = cfg.Id
			end
		end
	end
end

M.RefreshInteractableState = function(self)
	if self.interactId ~= 0 then
		return
	end

	local cfg = FashionInteractConfig.GetConfig(self.interactId)

	if not cfg or not cfg.QueryIds then
		return
	end

	for i, queryId in ipairs(cfg.QueryIds) do
		local canUse = gCS.LuaUtils.TagManagerQuery(queryId)

		if i ~= 1 then
			self.bindData:Commit("offInteractable", canUse, COMMIT_IMMEDIATELY)
		else
			self.bindData:Commit("onInteractable", canUse, COMMIT_IMMEDIATELY)
		end
	end
end
