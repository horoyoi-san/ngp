-- Original chunk: @Lua\LuaFiles\LX6\Manager\HUD\StoreButtonMgr.lua
-- Decompiled from: 02224_StoreButtonMgr.lua_78cb59a24b1f.luajit

local HudDescConfig = LTConfig.HudDescConfig
local HudDescOperationConfig = LTConfig.HudDescOperationConfig
local HudDescStateConfig = LTConfig.HudDescStateConfig
local HudDescGroupConfig = LTConfig.HudDescGroupConfig
local ProfileManager = LX6.Engine.ProfileManager
local gameProfile = ProfileManager.gameProfile
local SkillType = LX6.Engine.SkillType
local StaticProps = {}
C_StoreButtonMgr = DefClass("C_StoreButtonMgr", C_StoreButtonMgr, nil, StaticProps)
local M = C_StoreButtonMgr

M.ctor = function(self)
	self.instanceId = 0
	self.op_vis = HudDescOperationConfig.ChangeVis
	self.op_inter = HudDescOperationConfig.ChangeInteractable
	self.op_enterBar = HudDescOperationConfig.ChangeEnterBar
	self.baseOfBtn = {}
	self.curOpOfBtn = {}
	self._hudBtnStateParam = {}
end

M.OnInit = function(self)
	gMessageManager:AddMessageListener(gEventConstants.CORE_HUD_DESC_REFRESH, self:CreateAction(self.OnHudDescRefresh))
	self:InitBase()
end

M.InitBase = function(self)
	self.instanceId = 0
	self.operationList = {}
	self.operationId2Btn = {}
	self.baseOfBtn = {}
	self.curOpOfBtn = {}
	self.store2BtnList = {}
	self.defaultAction = {}
	self._hudBtnStateParam = {}

	for i = 0, HudDescConfig.count - 1 do
		local cfg = HudDescConfig.LoadAt(i)
		local btnId = cfg.Id
		self.operationList[btnId] = {}
		self.baseOfBtn[btnId] = {}
		self.curOpOfBtn[btnId] = {}

		for j = 0, HudDescOperationConfig.count - 1 do
			local oCfg = HudDescOperationConfig.LoadAt(j)
			self.baseOfBtn[btnId][oCfg.Id] = true
			self.curOpOfBtn[btnId][oCfg.Id] = self:GetDefaultOp(btnId, oCfg.Id)
		end

		if not self.store2BtnList[cfg.parent] then
			self.store2BtnList[cfg.parent] = {}
		end

		table.insert(self.store2BtnList[cfg.parent], btnId)
	end

	for i = 0, HudDescOperationConfig.count - 1 do
		local cfg = HudDescOperationConfig.LoadAt(i)
		self.defaultAction[cfg.Id] = self:CreateAction(cfg.SetAction)
	end
end

M.Clear = function(self)
end

M.RegisterOperation = function(self, operation, spoonId)
	local btnList = {}

	if operation.groupId and operation.groupId == 0 then
		btnList = self:GetBtnListByGroupId(operation.groupId)
	elseif operation.btnId and operation.btnId == 0 then
		btnList[1] = operation.btnId
	end

	local priority = operation.priority or 1

	if not operation.stateId then
		print_error("[C_StoreButtonMgr] RegisterOperation operation.stateId is nil")

		return -1
	end

	if table.isNilOrEmpty(btnList) then
		print_error("[C_StoreButtonMgr] RegisterOperation btnList is nil operation = ", operation, "spoonId = ", spoonId)

		return -1
	end

	local stateCfg = HudDescStateConfig.GetConfig(operation.stateId)
	local instanceId = self.instanceId

	if spoonId then
		instanceId = spoonId
	else
		self.instanceId = self.instanceId + 1
	end

	self:_UnRegisterOperationByInstId(instanceId)

	for i = 1, #btnList do
		local btnId = btnList[i]

		if self.operationList[btnId] then
			for j = 0, HudDescOperationConfig.count - 1 do
				local cfg = HudDescOperationConfig.LoadAt(j)
				local op = {
					value = stateCfg[cfg.Name],
					operationId = cfg.Id,
					instId = instanceId,
					priority = priority
				}

				table.insert(self.operationList[btnId], op)
			end

			self:RefreshBtnCurOp(btnId)
		end
	end

	self.operationId2Btn[instanceId] = btnList

	print_debug("[C_StoreButtonMgr] RegisterOperation instanceId = ", instanceId, "nodeId = ", spoonId, "operation = ", operation)
	self:RunListOperation(btnList)

	return instanceId
end

M._UnRegisterOperationByInstId = function(self, instanceId)
	if not self.operationId2Btn[instanceId] then
		return false
	end

	for i = 1, #self.operationId2Btn[instanceId] do
		local btnId = self.operationId2Btn[instanceId][i]

		if self.operationList[btnId] then
			for j = #self.operationList[btnId], 1, -1 do
				if self.operationList[btnId][j].instId ~= instanceId then
					table.remove(self.operationList[btnId], j)
				end
			end

			self:RefreshBtnCurOp(btnId)
		end
	end

	return true
end

M.UnRegisterOperation = function(self, instanceId)
	if not self:_UnRegisterOperationByInstId(instanceId) then
		return
	end

	print_debug("[C_StoreButtonMgr] UnRegisterOperation instanceId = ", instanceId)
	self:RunListOperation(self.operationId2Btn[instanceId])

	self.operationId2Btn[instanceId] = nil
end

M.GetBtnListByGroupId = function(self, groupId)
	local btnList = {}
	local groupCfg = HudDescGroupConfig.GetConfig(groupId)

	if not groupCfg then
		print_error("C_StoreButtonMgr:GetBtnListByGroupId groupCfg is nil groupId = ", groupId)

		return btnList
	end

	for i = 1, #groupCfg.group do
		table.insert(btnList, groupCfg.group[i])
	end

	return btnList
end

M.GetDefaultOp = function(self, btnId, operation)
	local cfg = HudDescOperationConfig.GetConfig(operation)

	if not cfg then
		print_error("C_StoreButtonMgr:GetDefaultOp cfg is nil", operation)

		return nil
	end

	return {
		["F\\x82\\x9a\\xaaE"] = -1,
		["\\xbb\\xa3\\xa4x7\\xea*"] = 0,
		value = self.baseOfBtn[btnId][operation],
		operationId = operation
	}
end

M.DefaultGetInfstRefBypath = function(self, store, path)
	local inst = store.bindData[path]

	if not inst then
		return nil
	end

	return inst
end

M.GetInstById = function(self, id)
	local cfg = HudDescConfig.GetConfig(id)

	if not cfg then
		print_debug("C_StoreButtonMgr:GetInstById cfg is nil", id)

		return nil
	end

	local store = gStoreManager:GetStoreGroup(cfg.parent)

	if not store then
		print_debug("C_StoreButtonMgr:GetInstById store is nil", id)

		return nil
	end

	local inst = store.GetInstRefByPath and store:GetInstRefByPath(cfg.refPath, cfg.childRefPath) or self:DefaultGetInfstRefBypath(store, cfg.refPath)

	if not inst then
		print_debug("C_StoreButtonMgr:GetInstById inst is nil", id)

		return nil
	end

	return inst, store
end

M.SetButtonVisibleById = function(self, data)
	local inst, store = self:GetInstById(data.id)

	if not inst then
		return
	end

	local instStore = store:GetStoreByWidget(inst)

	if not instStore then
		return nil
	end

	local value = self.baseOfBtn[data.id][self.op_vis] and data.value or false

	if instStore and instStore.btnHideCtrl then
		instStore.btnHideCtrl = value and 0 or 1
	else
		inst:SetWidgetFaraway(not value)
	end

	if inst:GetTypeName() ~= "UButton" and inst.redDot then
		inst.redDot:SetWidgetFaraway(not value)
	end

	if store and store.SetInstActive then
		store:SetInstActive(inst, value)
	end
end

M.SetButtonInteractableById = function(self, data)
	local inst, store = self:GetInstById(data.id)

	if not inst or inst:GetTypeName() == "UButton" then
		return
	end

	local instStore = store:GetStoreByWidget(inst)

	if instStore and instStore.interactable == nil then
		instStore.interactable = self.baseOfBtn[data.id][self.op_inter] and data.value
	else
		inst.interactable = self.baseOfBtn[data.id][self.op_inter] and data.value
	end
end

M.SetButtonEnterBar = function(self, data)
	local inst, store = self:GetInstById(data.id)

	if not inst or inst:GetTypeName() == "UButton" then
		return
	end

	local base = self.baseOfBtn[data.id]

	if not base then
		return
	end

	inst:SetShowTipTotally(base[self.op_enterBar] and data.value)
end

M.RefreshBtnCurOp = function(self, btnId)
	local ready = {
		false,
		false,
		false
	}
	local opList = self.operationList[btnId]

	table.sort(opList, function (a, b)
		if a.priority ~= b.priority then
			return a.instId <= b.instId
		end

		return a.priority <= b.priority
	end)

	for j = 1, #opList do
		local operation = opList[j]

		if ready[operation.operationId] ~= false then
			ready[operation.operationId] = true
			self.curOpOfBtn[btnId][operation.operationId] = operation
		end
	end

	for j = 1, #ready do
		if ready[j] ~= false then
			self.curOpOfBtn[btnId][j] = self:GetDefaultOp(btnId, j)
		end
	end
end

M.RunListOperation = function(self, btnList)
	if table.isNilOrEmpty(btnList) then
		return
	end

	for i = 1, #btnList do
		self:RunBtnOperation(btnList[i])
	end

	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		self:OnShowBtnText(btnList)
	end
end

M.RunBtnOperation = function(self, btnId)
	if not self.operationList[btnId] then
		return
	end

	for i = 1, #self.curOpOfBtn[btnId] do
		local action = self.defaultAction[i]

		if action then
			action({
				value = self.curOpOfBtn[btnId][i].value,
				id = btnId
			})
		end
	end
end

M.SetButtonVisibleBase = function(self, btnStore, visible)
	if not btnStore then
		return
	end

	local btnId = btnStore.btnId

	if btnId and self.baseOfBtn[btnId] then
		self.baseOfBtn[btnId][self.op_vis] = visible
		local curValue = self.curOpOfBtn[btnId][self.op_vis]

		if curValue and curValue.instId == -1 then
			local value = visible and (curValue.value ~= true and 0 or 1) or 1
			btnStore.btnHideCtrl = value

			return
		end
	end

	btnStore.btnHideCtrl = visible and 0 or 1
end

M.SendHudButtonStateChange = function(self, btnId, interactable)
	local temp = self._hudBtnStateParam
	temp.btnId = btnId
	temp.interactable = interactable

	gMessageManager:SendMessage(gEventConstants.ON_HUD_BUTTON_STATE_CHANGE, temp)

	if not interactable then
		local cfg = HudDescConfig.GetConfig(btnId)

		if cfg and table.contains(SkillType, cfg.ButtonInfoEnum) then
			gCS.SceneBattleBtnMgr.OnBattleBtnInteractDisable(cfg.ButtonInfoEnum)
		end
	end
end

M.SetButtonInteractableBase = function(self, btnStore, interactable)
	local btnId = btnStore.btnId

	if btnId and self.baseOfBtn[btnId] then
		self.baseOfBtn[btnId][self.op_inter] = interactable
		local curValue = self.curOpOfBtn[btnId][self.op_inter]

		if curValue and curValue.instId == -1 then
			btnStore.interactable = interactable and curValue.value

			self:SendHudButtonStateChange(btnId, btnStore.interactable)

			return
		end
	end

	btnStore.interactable = interactable

	self:SendHudButtonStateChange(btnId, interactable)
end

M.SetButtonEnterBarBsae = function(self, btnStore, enterBar)
	local btnId = btnStore.btnId

	if btnId and self.baseOfBtn[btnId] then
		self.baseOfBtn[btnId][self.op_enterBar] = enterBar
		local curValue = self.curOpOfBtn[btnId][self.op_enterBar]

		if curValue and curValue.instId == -1 then
			self:SetButtonEnterBar({
				id = btnId,
				value = enterBar and curValue.value
			})

			return
		end

		self:SetButtonEnterBar({
			id = btnId,
			value = enterBar
		})

		return
	end

	local inst, store = self:GetInstById(btnId)

	if inst and inst:GetTypeName() ~= "UButton" then
		inst:SetShowTipTotally(enterBar)
	end
end

M.SetButtonControlBase = function(self, btnStore, visible, interactable)
	self:SetButtonInteractableBase(btnStore, interactable)
	self:SetButtonVisibleBase(btnStore, visible)
end

M.SetButtonShowTextBase = function(self, btnId, isShowText)
	local inst, store = self:GetInstById(btnId)

	if not inst then
		return
	end

	local instStore = nil

	if not string.is_null_or_empty(inst.Store) then
		instStore = gStoreManager:GetStoreGroup(inst.Store) and gStoreManager:GetStoreGroup(inst.Store):GetStoreByWidget(inst)
	end

	if instStore then
		instStore.wordsCtrl = isShowText and 1 or 0
	end
end

M.InitBtnTextVisible = function(self)
	local textImportanceLevel = gameProfile.mobileButtonTextNum

	for i = 0, HudDescConfig.count - 1 do
		local config = HudDescConfig.LoadAt(i)
		local textImportance = config.Importance

		self:SetButtonShowTextBase(config.Id, textImportance <= textImportanceLevel)
	end
end

M.OnShowBtnText = function(self, btnList)
	local textShowLevel = gameProfile.mobileButtonTextNum

	for i = 1, #btnList do
		local cfg = HudDescConfig.GetConfig(btnList[i])

		if not cfg then
			print_error("[C_StoreButtonMgr] OnShowBtnText btnId = ", btnList[i])
		else
			self:SetButtonShowTextBase(btnList[i], cfg.Importance <= textShowLevel)
		end
	end
end

M.OnHudDescRefresh = function(self, eventId, data)
	if table.isNilOrEmpty(data) then
		return
	end

	if data.btnList then
		self:RunListOperation(data.btnList)
	end

	if data.groupId then
		self:RunListOperation(self:GetBtnListByGroupId(data.groupId))
	end

	if data.storeName then
		self:RunListOperation(self.store2BtnList[data.storeName])
	end
end

M.DumpButtonOperations = function(self, btnId)
	if not btnId then
		print_debug("-------------------- StoreButtonMgr Dump All --------------------")

		for i = 0, HudDescConfig.count - 1 do
			local cfg = HudDescConfig.LoadAt(i)

			self:DumpButtonOperations(cfg.Id)
		end

		print_debug("-------------------- StoreButtonMgr Dump End --------------------")

		return
	end

	local cfg = HudDescConfig.GetConfig(btnId)

	if not cfg then
		print_debug(string.format("[StoreBtn] btnId=%s config not found", tostring(btnId)))

		return
	end

	local opList = self.operationList[btnId]
	local opCount = opList and #opList or 0
	local curVis = self.curOpOfBtn[btnId] and self.curOpOfBtn[btnId][self.op_vis]
	local curInter = self.curOpOfBtn[btnId] and self.curOpOfBtn[btnId][self.op_inter]
	local curEnterBar = self.curOpOfBtn[btnId] and self.curOpOfBtn[btnId][self.op_enterBar]
	local visStr = curVis and string.format("val=%s pri=%d inst=%d", tostring(curVis.value), curVis.priority, curVis.instId) or "nil"
	local interStr = curInter and string.format("val=%s pri=%d inst=%d", tostring(curInter.value), curInter.priority, curInter.instId) or "nil"
	local enterBarStr = curEnterBar and string.format("val=%s pri=%d inst=%d", tostring(curEnterBar.value), curEnterBar.priority, curEnterBar.instId) or "nil"
	local baseVis = self.baseOfBtn[btnId] and self.baseOfBtn[btnId][self.op_vis]
	local baseInter = self.baseOfBtn[btnId] and self.baseOfBtn[btnId][self.op_inter]

	print_debug(string.format("[StoreBtn] [%d] store=%s path=%s opCount=%d baseVis=%s baseInter=%s | CurVis:{%s} CurInter:{%s} CurEnterBar:{%s}", btnId, tostring(cfg.parent), tostring(cfg.refPath), opCount, tostring(baseVis), tostring(baseInter), visStr, interStr, enterBarStr))

	if opList then
		for i, op in ipairs(opList) do
			print_debug(string.format("  [StoreBtn]   op#%d: opId=%d val=%s pri=%d instId=%d", i, op.operationId, tostring(op.value), op.priority, op.instId))
		end
	end
end

gStoreButtonMgr = gStoreButtonMgr or C_StoreButtonMgr.new()
