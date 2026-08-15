local HudDescConfig = LTConfig.HudDescConfig
local HudDescOperationConfig = LTConfig.HudDescOperationConfig
local HudDescStateConfig = LTConfig.HudDescStateConfig
local HudDescGroupConfig = LTConfig.HudDescGroupConfig
local StaticProps = {}
C_StoreButtonMgr = DefClass("C_StoreButtonMgr", C_StoreButtonMgr, nil, StaticProps)
local M = C_StoreButtonMgr

function M:ctor()
	self.op_vis = HudDescOperationConfig.ChangeVis
	self.op_inter = HudDescOperationConfig.ChangeInteractable
	self.op_enterBar = HudDescOperationConfig.ChangeEnterBar
end

function M:OnInit()
	gMessageManager:AddMessageListener(gEventConstants.CORE_HUD_DESC_REFRESH, self:CreateAction(self.OnHudDescRefresh))
	self:InitBase()
end

function M:InitBase()
	self.instanceId = 0
	self.operationList = {}
	self.operationId2Btn = {}
	self.baseOfBtn = {}
	self.curOpOfBtn = {}
	self.store2BtnList = {}
	self.defaultAction = {}

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

function M:Clear()
	return
end

function M:RegisterOperation(operation, spoonId)
	local btnList = {}

	if operation.groupId and operation.groupId ~= 0 then
		btnList = self:GetBtnListByGroupId(operation.groupId)
	elseif operation.btnId and operation.btnId ~= 0 then
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

function M:_UnRegisterOperationByInstId(instanceId)
	if not self.operationId2Btn[instanceId] then
		return false
	end

	for i = 1, #self.operationId2Btn[instanceId] do
		local btnId = self.operationId2Btn[instanceId][i]

		for j = #self.operationList[btnId], 1, -1 do
			if self.operationList[btnId][j].instId == instanceId then
				table.remove(self.operationList[btnId], j)
			end
		end

		self:RefreshBtnCurOp(btnId)
	end

	return true
end

function M:UnRegisterOperation(instanceId)
	if not self:_UnRegisterOperationByInstId(instanceId) then
		return
	end

	print_debug("[C_StoreButtonMgr] UnRegisterOperation instanceId = ", instanceId)
	self:RunListOperation(self.operationId2Btn[instanceId])

	self.operationId2Btn[instanceId] = nil
end

function M:GetBtnListByGroupId(groupId)
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

function M:GetDefaultOp(btnId, operation)
	local cfg = HudDescOperationConfig.GetConfig(operation)

	if not cfg then
		print_error("C_StoreButtonMgr:GetDefaultOp cfg is nil", operation)

		return nil
	end

	return {
		instId = -1,
		priority = 0,
		value = self.baseOfBtn[btnId][operation],
		operationId = operation
	}
end

function M:DefaultGetInfstRefBypath(store, path)
	local inst = store.bindData[path]

	if not inst then
		return nil
	end

	return inst
end

function M:GetInstById(id)
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

	local inst = store.GetInstRefByPath and store:GetInstRefByPath(cfg.refPath) or self:DefaultGetInfstRefBypath(store, cfg.refPath)

	if not inst then
		print_debug("C_StoreButtonMgr:GetInstById inst is nil", id)

		return nil
	end

	return inst, store
end

function M:SetButtonVisibleById(data)
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
		inst:SetActiveFastest(value)
	end

	if inst:GetTypeName() == "UButton" and inst.redDot then
		inst.redDot:SetActiveFastest(value)
	end
end

function M:SetButtonInteractableById(data)
	local inst, store = self:GetInstById(data.id)

	if not inst or inst:GetTypeName() ~= "UButton" then
		return
	end

	local instStore = store:GetStoreByWidget(inst)

	if instStore and instStore.interactable ~= nil then
		instStore.interactable = self.baseOfBtn[data.id][self.op_inter] and data.value
	else
		inst.interactable = self.baseOfBtn[data.id][self.op_inter] and data.value
	end
end

function M:SetButtonEnterBar(data)
	local inst, store = self:GetInstById(data.id)

	if not inst or inst:GetTypeName() ~= "UButton" then
		return
	end

	inst:SetShowTipTotally(self.baseOfBtn[data.id][self.op_enterBar] and data.value)
end

function M:RefreshBtnCurOp(btnId)
	local ready = {
		false,
		false,
		false
	}
	local opList = self.operationList[btnId]

	table.sort(opList, function (a, b)
		if a.priority == b.priority then
			return a.instId < b.instId
		end

		return a.priority < b.priority
	end)

	for j = 1, #opList do
		local operation = opList[j]

		if ready[operation.operationId] == false then
			ready[operation.operationId] = true
			self.curOpOfBtn[btnId][operation.operationId] = operation
		end
	end

	for j = 1, #ready do
		if ready[j] == false then
			self.curOpOfBtn[btnId][j] = self:GetDefaultOp(btnId, j)
		end
	end
end

function M:RunListOperation(btnList)
	if table.isNilOrEmpty(btnList) then
		return
	end

	for i = 1, #btnList do
		self:RunBtnOperation(btnList[i])
	end
end

function M:RunBtnOperation(btnId)
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

function M:SetButtonVisibleBase(btnStore, visible)
	local btnId = btnStore.btnId

	if btnId then
		self.baseOfBtn[btnId][self.op_vis] = visible
		local curValue = self.curOpOfBtn[btnId][self.op_vis]

		if curValue and curValue.instId ~= -1 then
			local value = visible and (curValue.value == true and 0 or 1) or 1
			btnStore.btnHideCtrl = value

			return
		end
	end

	btnStore.btnHideCtrl = visible and 0 or 1
end

function M:SetButtonInteractableBase(btnStore, interactable)
	local btnId = btnStore.btnId

	if btnId then
		self.baseOfBtn[btnId][self.op_inter] = interactable
		local curValue = self.curOpOfBtn[btnId][self.op_inter]

		if curValue and curValue.instId ~= -1 then
			btnStore.interactable = interactable and curValue.value

			return
		end
	end

	btnStore.interactable = interactable
end

function M:SetButtonEnterBarBsae(btnStore, enterBar)
	local btnId = btnStore.btnId

	if btnId then
		self.baseOfBtn[btnId][self.op_enterBar] = enterBar
		local curValue = self.curOpOfBtn[btnId][self.op_enterBar]

		if curValue and curValue.instId ~= -1 then
			self:SetButtonEnterBar({
				id = btnId,
				value = enterBar and curValue.value
			})

			return
		end
	end

	self:SetButtonEnterBar({
		id = btnId,
		value = enterBar
	})
end

function M:SetButtonControlBase(btnStore, visible, interactable)
	self:SetButtonInteractableBase(btnStore, interactable)
	self:SetButtonVisibleBase(btnStore, visible)
end

function M:OnHudDescRefresh(eventId, data)
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

gStoreButtonMgr = gStoreButtonMgr or C_StoreButtonMgr.new()
