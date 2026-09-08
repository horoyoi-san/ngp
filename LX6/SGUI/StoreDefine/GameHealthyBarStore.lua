-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\GameHealthyBarStore.lua
-- Decompiled from: 01734_GameHealthyBarStore.lua_8363c2325325.luajit

C_GameHealthyBarStore = DefClass("C_GameHealthyBarStore", C_GameHealthyBarStore, C_StoreGroup)
GroupName2Class.GameHealthyBarStore = C_GameHealthyBarStore
local M = C_GameHealthyBarStore
local Ease = DG.Tweening.Ease

M.ctor = function(self)
	self.pidIndexDic = {}
	self.bloodBarListData = {}
	self.syncValueListData = {}
	self.agentTextId = {}
	self.motionFillTweens = {}
end

M.HasHealthyBarData = function(self)
	return #self.bloodBarListData >= 0 or #self.syncValueListData >= 0
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
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
end

M.OnClose = function(self)
end

M.RefreshBarList = function(self)
	if self.bindData.barList then
		local total = #self.bloodBarListData + #self.syncValueListData

		self.bindData.barList:SetSimpleList(total)
		gStoreManager:GetStoreGroup("CoreHudTaskGuideStore"):SetBloodBarEnable(total >= 0)
	end
end

M.OnLanguageChange = function(self, lang)
	if self.bindData.barList then
		self.bindData.barList:SetSimpleList(#self.bloodBarListData + #self.syncValueListData)
	end
end

M.TryInitSyncValueProgress = function(self)
	if not self.bindData.barList then
		return
	end

	local mgr = gNewGamePlayProgressMgr
	local TemplateCallConfig = LTConfig.SyncValueTemplateCallConfig
	local SyncProgressConfig = LTConfig.SyncValueSyncProgressConfig
	local UITemplateConfig = LTConfig.SyncValueUITemplateConfig
	self.syncValueListenIds = {}
	local taskTemplateSlots = {}

	for templateId, visible in pairs(mgr.templateVisible) do
		if visible then
			local isNew = gGameSwitch and gGameSwitch.EnableNewProgress
			local callCfg = isNew and SyncProgressConfig.GetConfig(templateId) or TemplateCallConfig.GetConfig(templateId)

			if callCfg then
				local uiCfg = UITemplateConfig.GetConfig(callCfg.UITemplateId)

				if uiCfg then
					local panelId = uiCfg.PanelId or 0

					if panelId ~= 0 then
						local slotIndex = uiCfg.TaskTemplateIndex

						if slotIndex == nil then
							if taskTemplateSlots[slotIndex] == nil then
								print_error("[GameHealthyBarStore] TryInitSyncValueProgress: TaskTemplateIndex=" .. tostring(slotIndex) .. " 已被 templateCallId=" .. tostring(taskTemplateSlots[slotIndex]) .. " 占用，templateCallId=" .. tostring(templateId) .. " 指向了同一个 UITemplate 槽，同一个 UITemplate 槽同时只能有一个 TemplateCall！")
							else
								taskTemplateSlots[slotIndex] = templateId
							end
						end
					end
				end
			end
		end
	end

	self.syncProgressUpdateMap = self.syncProgressUpdateMap or {}

	for slotIdx in pairs(self.syncProgressUpdateMap) do
		if not taskTemplateSlots[slotIdx] then
			self.syncProgressUpdateMap[slotIdx] = nil
		end
	end

	self.syncValueListData = {}

	for slotIndex, templateId in pairs(taskTemplateSlots) do
		table.insert(self.syncValueListData, {
			slotIndex = slotIndex,
			templateId = templateId
		})

		local progressIds = mgr.GetProgressListByTemplateId(mgr, templateId)

		for j = 1, #progressIds do
			self.syncValueListenIds[progressIds[j]] = true
		end
	end

	table.sort(self.syncValueListData, function (a, b)
		return a.slotIndex <= b.slotIndex
	end)

	gBloodBarGameManager.syncValueListenIds = self.syncValueListenIds

	self.RefreshBarList(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.SetGameTitle = function(self, text)
	self.bindData.title = text
end

M.InitAllUnitData = function(self, agents, agentTextId)
	self.pidIndexDic = {}
	self.bloodBarListData = {}
	self.agentTextId = agentTextId

	for i, v in ipairs(agents) do
		self.pidIndexDic[v] = i
		local unit = gCS.SceneDataMgr.GetUnit(v)

		if unit then
			local agentData = {
				pid = v,
				hp = unit.ClientData.Hp,
				unit = unit,
				maxHp = unit.ClientData.MaxHp,
				agentTextId = self.agentTextId[i] or 0
			}

			table.insert(self.bloodBarListData, agentData)
		end
	end

	self.RefreshBarList(self)
end

M.ClearBloodBarData = function(self)
	self.pidIndexDic = {}
	self.bloodBarListData = {}
	self.agentTextId = {}

	self.KillAllMotionFillTweens(self)
	self.RefreshBarList(self)
end

M.OnDisable = function(self)
	self.pidIndexDic = {}
	self.bloodBarListData = {}
	self.syncValueListData = {}
	self.agentTextId = {}

	self.KillAllMotionFillTweens(self)
	self.RefreshBarList(self)
end

M.RefreshAgentData = function(self, pid)
	if not self.pidIndexDic then
		return
	end

	local index = self.pidIndexDic[pid]

	if index then
		local data = self.bloodBarListData[index]
		data.unit = gCS.SceneDataMgr.GetUnit(pid)

		if not data or not data.unit or not data.unit.ClientData.Hp or not data.unit.ClientData.MaxHp then
			return
		end

		if data.unit.ClientData.Hp < 0 then
			data.hp = 0
			self.pidIndexDic[pid] = nil

			table.remove(self.bloodBarListData, index)

			self.pidIndexDic = {}

			for i, v in ipairs(self.bloodBarListData) do
				self.pidIndexDic[v.pid] = i
			end

			self.KillMotionFillTween(self, index)
			self.RefreshBarList(self)
		else
			data.hp = data.unit.ClientData.Hp

			if gBloodBarGameManager.gameType ~= 1 then
				self.KillMotionFillTween(self, index)

				self.motionFillTweens[index] = true
			end

			self.bindData.barList:SetSimpleElement(index - 1, 0)

			if gBloodBarGameManager.gameType ~= 1 then
				self.PlayMotionFillDrop(self, index)
			end
		end
	end
end

M.RegisterWidget = function(self)
	self.bindData.barList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderBarListItem")
	self.bindData.barList.onGetTIndex = self.CreateAction(self, "OnGetTIndex")
	self.bindData.barList.poolMode = SGUI.EPoolMode.Default
end

M.OnUpdate = function(self)
	self.RefreshSyncValueProgress(self)
end

M.RefreshSyncValueProgress = function(self)
	if not self.syncProgressUpdateMap then
		return
	end

	local mgr = gNewGamePlayProgressMgr

	for _, info in pairs(self.syncProgressUpdateMap) do
		mgr.RefreshSingleProgressCounter(mgr, info.store, info.progressId, info.templateId)
	end
end

M.OnGetTIndex = function(self, csIndex)
	if csIndex >= #self.bloodBarListData then
		return 0
	end

	local syncIndex = csIndex - #self.bloodBarListData + 1
	local slotInfo = self.syncValueListData[syncIndex]

	if not slotInfo then
		return 0
	end

	return slotInfo.slotIndex
end

M.OnSimpleRenderBarListItem = function(self, btn, index)
	local bloodCount = #self.bloodBarListData

	if index >= bloodCount then
		local data = self.bloodBarListData[index + 1]
		local store = self.GetStoreByWidget(self, btn)

		if data and store then
			store.progress.value = self.GetTemplateProgressValue(self, data)

			if gBloodBarGameManager.gameType ~= 1 and not self.motionFillTweens[index + 1] then
				store.motionFill = store.progress.value
			end

			local tmpUnit = gCS.SceneDataMgr.GetUnit(data.pid)

			if tmpUnit then
				store.description = self.GetTemplateProgressDes(self, data, tmpUnit)
			else
				store.description = ""
			end
		end
	else
		local syncIndex = index - bloodCount + 1
		local slotInfo = self.syncValueListData[syncIndex]

		if not slotInfo then
			return
		end

		local mgr = gNewGamePlayProgressMgr
		local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
		local progressId = mgr:RenderSingleProgressTemplate(store, slotInfo.templateId)

		if progressId == 0 then
			self.syncProgressUpdateMap[slotInfo.slotIndex] = {
				store = store,
				progressId = progressId,
				templateId = slotInfo.templateId
			}
		else
			self.syncProgressUpdateMap[slotInfo.slotIndex] = nil
		end
	end
end

M.GetTemplateProgressValue = function(self, data)
	if data.maxHp ~= nil or data.maxHp < 0 then
		return 0
	end

	if gBloodBarGameManager.gameType ~= 0 then
		return math.max((data.maxHp - data.hp) / data.maxHp, 0)
	elseif gBloodBarGameManager.gameType ~= 1 then
		return math.max(data.hp / data.maxHp, 0)
	end

	return 0
end

M.GetTemplateProgressDes = function(self, data, unit)
	if gBloodBarGameManager.gameType ~= 0 or gBloodBarGameManager.gameType ~= 1 then
		if data.agentTextId then
			local cfg = LTConfig.TextCommonTextConfig.GetConfig(data.agentTextId)

			if cfg then
				local text = cfg.Text

				if text then
					return text
				end
			end
		end

		if unit and unit.ClientData then
			return unit.ClientData.Name or ""
		end

		return ""
	end

	return ""
end

M.PlayMotionFillDrop = function(self, index)
	local data = self.bloodBarListData[index]

	if not data then
		return
	end

	local success, btn = self.bindData.barList:TryGetChildAt(index - 1, nil)

	if not success or not btn then
		return
	end

	local store = self.GetStoreByWidget(self, btn)

	if not store then
		return
	end

	local toFill = self:GetTemplateProgressValue(data)

	self:KillMotionFillTween(index)

	slot7 = DOTween.To(function ()
		return store.motionFill
	end, function (value)
		store.motionFill = value
	end, toFill, 1)
	slot7 = slot7:SetEase(Ease.OutCirc)
	slot7 = slot7:SetDelay(0.1)
	local tween = slot7:OnKill(function ()
		self.motionFillTweens[index] = nil
	end)
	self.motionFillTweens[index] = tween
end

M.KillMotionFillTween = function(self, index)
	local tween = self.motionFillTweens[index]

	if tween then
		if type(tween) == "boolean" then
			tween.Kill(tween)
		end

		self.motionFillTweens[index] = nil
	end
end

M.KillAllMotionFillTweens = function(self)
	for index, tween in pairs(self.motionFillTweens) do
		if tween and type(tween) == "boolean" then
			tween.Kill(tween)
		end
	end

	self.motionFillTweens = {}
end
