local SkillConfig = LTConfig.SkillConfig
local FightSpiritConfig = LTConfig.FightSpiritConfig
local BossTestConfig = LTConfig.AutoTestBossTestConfig
local EnemyFliterType = LTConfig.AutoTestBossTestConfig.EnemyFliterType
local DestrutibleTestConfig = LTConfig.AutoTestBattleDestrutibleTestConfig
C_SkillDebugPanelStore = DefClass("C_SkillDebugPanelStore", C_SkillDebugPanelStore, C_StoreGroup)
GroupName2Class.SkillDebugPanelStore = C_SkillDebugPanelStore
local M = C_SkillDebugPanelStore
local ShowAddEnemyType = {
	Hide = 1,
	Show = 0
}
local IsEnemyType = {
	NoEnemy = 1,
	IsEnemy = 0
}
local ShowAddDestructible = {
	Hide = 1,
	Show = 0
}

function M:ctor()
	self.EnemyFilterInfos = {
		[EnemyFliterType.Popular] = {
			Name = "常用"
		},
		[EnemyFliterType.Version] = {
			Name = "版本投放"
		},
		[EnemyFliterType.Boss] = {
			Name = "Boss"
		},
		[EnemyFliterType.Normal] = {
			Name = "小怪"
		},
		[EnemyFliterType.Elite] = {
			Name = "精英"
		},
		[EnemyFliterType.Functional] = {
			Name = "功能性"
		}
	}
	self.selectEnemyList = {}
	self.skillList = {}
	self.enemyTypeList = {}
	self.enemyList = {}
	self.DestructibleTypes = {}
	self.destructibleList = {}
	self.Skills = {}
	self.DestructibleDict = {}
end

function M:OnGroupEnable()
	self:RegisterBtnEvent()
	self:RegisterMessageEvent()
end

function M:OnShow(panelId, data)
	self.bindData.enemyName = LTConfig.TextScriptTextConfig.GetConfig(89900607).Text
	self.bindData.skillName = LTConfig.TextScriptTextConfig.GetConfig(89900608).Text
	self.bindData.Count = 1
	self.bindData.IsEnemy = IsEnemyType.IsEnemy
	self.bindData.enemyCountInputField.text = 1
	self.bindData.ShowAddEnemy = ShowAddEnemyType.Hide
	self.bindData.ShowEnemyList = ShowAddEnemyType.Hide
	self.bindData.ShowSkillList = ShowAddEnemyType.Hide
	self.bindData.ShowAddDestructible = ShowAddDestructible.Hide

	if data and data.ShowAddEnemy then
		self:AddEnemy()
	end

	table.clear(self.enemyTypeList)
	table.insert(self.enemyTypeList, {
		type = -1,
		Name = "总览"
	})

	for name, type in pairs(EnemyFliterType) do
		local info = self.EnemyFilterInfos[type]
		local ins = nil

		if info then
			ins = table.shallow_clone(info)
		else
			ins = {
				Name = name
			}
		end

		ins.type = type

		if type == 2 then
			ins.Name = "<color=#FFC0C0>" .. ins.Name .. "</color>"
		elseif type == 3 then
			ins.Name = "<color=#C0F18E>" .. ins.Name .. "</color>"
		elseif type == 4 then
			ins.Name = "<color=##69D5E0>" .. ins.Name .. "</color>"
		elseif type == 5 then
			ins.Name = "<color=#C0F18E>" .. ins.Name .. "</color>"
		end

		table.insert(self.enemyTypeList, ins)
	end

	table.sort(self.enemyTypeList, function (a, b)
		return a.type < b.type
	end)
	table.clear(self.DestructibleTypes)
	table.clear(self.DestructibleDict)

	for i = 0, DestrutibleTestConfig.count - 1 do
		local cfg = DestrutibleTestConfig.LoadAt(i)
		local DestructibleNameSegments = string.split(cfg.DestructibleName, "/")
		local weaponName = DestructibleNameSegments[#DestructibleNameSegments] or cfg.DestructibleName
		local weaponType = "无类别"

		if #DestructibleNameSegments > 1 then
			weaponType = DestructibleNameSegments[1]
		end

		if not self.DestructibleDict[weaponType] then
			self.DestructibleDict[weaponType] = {}
			local destructibleType = {
				Name = weaponType
			}

			table.insert(self.DestructibleTypes, destructibleType)
		end

		table.insert(self.DestructibleDict[weaponType], {
			Name = "<color=#C0F18E>" .. weaponName .. "</color>",
			Cfg = cfg
		})
	end

	self.bindData.enemyTypeList:SetSimpleList(#self.enemyTypeList)
	self.bindData.destructibleTypeList:SetSimpleList(#self.DestructibleTypes)
end

function M:OnClose()
	self:SetJoystickVisiable(true)

	if gLuaDataManager.isNetworkAvailable then
		gClientToGameSceneGMDelegate:GmEndEnemyStrategyDebug()
	end

	self:ClearMessageEvents()
end

function M:refreshUnits(filter)
	if filter == nil then
		filter = -1
	end

	table.clear(self.enemyList)

	local COLOR = {
		"FFC0C0",
		"#69D5E0",
		"C0F18E"
	}

	for i = 0, BossTestConfig.count - 1 do
		local cfg = BossTestConfig.LoadAt(i)
		local filterMask = 0

		for _, v in ipairs(cfg.EnemyFliter) do
			filterMask = bit.bor(filterMask, bit.lshift(1, v))
		end

		if (filter < 0 or bit.band(filterMask, filter) > 0) and cfg and cfg.BossClass ~= LTConfig.AutoTestBossTestConfig.BossClassType.MonsterGroup then
			table.insert(self.enemyList, {
				Name = "<color=#" .. COLOR[cfg.BossClass + 1] .. ">" .. cfg.BossTitle .. "</color>",
				Id = cfg.BossId,
				Cfg = cfg
			})
		end
	end

	self.bindData.enemyList:SetSimpleList(#self.enemyList)
end

function M:RegisterBtnEvent()
	self.bindData.SelectEnemyBtn.luaClick = self:CreateAction("OpenSelectEnemyList")
	self.bindData.SelectSkillBtn.luaClick = self:CreateAction("OpenSelectSkillList")
	self.bindData.CastSkillBtn.luaClick = self:CreateAction("UseSkillBtn")
	self.bindData.AddBtn.luaClick = self:CreateAction("AddEnemy")
	self.bindData.AddGroupBtn.luaClick = self:CreateAction("AddGroupEnemy")
	self.bindData.DestructibleBtn.luaClick = self:CreateAction("AddDestructible")
	self.bindData.killAllBtn.luaClick = self:CreateAction("KillAll")
	self.bindData.Close.luaClick = self:CreateAction("ClosePanel")
	self.bindData.LookAroundBtn.luaClick = self:CreateAction("LookAroundAction")
	self.bindData.selectEnemyList.luaSimpleRenderItem = self:CreateAction("OnRenderSelectEnemyList")
	self.bindData.selectSkillList.luaSimpleRenderItem = self:CreateAction("OnRenderSelectSkillList")
	self.bindData.campBtn.luaClick = self:CreateAction("ChangeCampAction")
	self.bindData.enemyTypeList.luaSimpleRenderItem = self:CreateAction("OnRenderEnemyTypeList")
	self.bindData.enemyList.luaSimpleRenderItem = self:CreateAction("OnRenderEnemyList")
	self.bindData.destructibleTypeList.luaSimpleRenderItem = self:CreateAction("OnRenderDestructibleTypeList")
	self.bindData.destructibleList.luaSimpleRenderItem = self:CreateAction("OnRenderDestructibleList")
end

function M:RegisterMessageEvent()
	self.msgEvents = {
		[gEventConstants.HSKILL_CLIP_RUN] = self:CreateAction("HSkillClipRunAction")
	}

	self:ClearMessageEvents()
	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnRenderSelectEnemyList(btn, index)
	local store = gStoreManager:GetStoreGroup("EnemyUnitStore"):GetStoreByWidget(btn)

	if not store then
		return
	end

	local data = self.selectEnemyList[index + 1]
	store.Name = data.Name
	store.button.luaClick = self:CreateActionWithArgs("SelectEnemyBtn", data)
end

function M:OnRenderSelectSkillList(item, index)
	local store = gStoreManager:GetStoreGroup("EnemyUnitStore"):GetStoreByWidget(item)

	if not store then
		return
	end

	local data = self.skillList[index + 1]
	store.Name = data.Name
	store.button.luaClick = self:CreateActionWithArgs("SelectSkillBtn", index + 1)
end

function M:OnRenderEnemyTypeList(item, index)
	local store = gStoreManager:GetStoreGroup("EnemyTypeStore"):GetStoreByWidget(item)

	if not store then
		return
	end

	local data = self.enemyTypeList[index + 1]
	store.Name = data.Name
	store.button.luaClick = self:CreateActionWithArgs("SelectEnemyTypeBtnDown", data)
end

function M:OnRenderEnemyList(item, index)
	local store = gStoreManager:GetStoreGroup("EnemyStore"):GetStoreByWidget(item)

	if not store then
		return
	end

	local data = self.enemyList[index + 1]
	store.Name = data.Name
	store.button.luaClick = self:CreateActionWithArgs("ChooseEnemy", data)
end

function M:OnRenderDestructibleTypeList(item, index)
	local store = gStoreManager:GetStoreGroup("DestructibleTypeStore"):GetStoreByWidget(item)

	if not store then
		return
	end

	local data = self.DestructibleTypes[index + 1]
	store.Name = data.Name
	store.button.luaClick = self:CreateActionWithArgs("SelectDestructibleTypeBtnDown", data)
end

function M:OnRenderDestructibleList(item, index)
	local store = gStoreManager:GetStoreGroup("DestructibleStore"):GetStoreByWidget(item)

	if not store then
		return
	end

	local data = self.destructibleList[index + 1]
	store.Name = data.Name
	store.button.luaClick = self:CreateActionWithArgs("ChooseDestructible", data)
end

function M:OpenSelectEnemyList()
	if self.bindData.ShowEnemyList == ShowAddEnemyType.Show then
		self.bindData.ShowEnemyList = ShowAddEnemyType.Hide

		return
	end

	table.clear(self.selectEnemyList)
	gBattleMgr:ForEach(function (unit)
		local distance = math.floor(gUtils:GetDistance(unit.LocalPosition, gCS.MyPlayerManager.PlayerUnit.LocalPosition) * 10) / 10
		local data = {
			distance = distance
		}
		local name = unit.ClientData.Name or ""

		if name ~= "unknown" and name ~= LTConfig.TextScriptTextConfig.GetConfig(89900610).Text then
			data.Name = name .. " (" .. distance .. "m)"

			if unit.Pid == self.EnemyPid then
				data.Name = "<size=1.5><b>" .. data.Name .. "</b></size>"
			end

			data.unitPid = unit.Pid

			table.insert(self.selectEnemyList, data)
		end
	end)
	table.sort(self.selectEnemyList, function (a, b)
		return a.distance < b.distance
	end)
	self.bindData.selectEnemyList:SetSimpleList(#self.selectEnemyList)

	self.bindData.ShowEnemyList = ShowAddEnemyType.Show
	self.bindData.ShowAddEnemy = ShowAddEnemyType.Hide
	self.bindData.ShowSkillList = ShowAddEnemyType.Hide
	self.bindData.ShowAddDestructible = ShowAddDestructible.Hide
end

function M:AddDestructible()
	if self.bindData.ShowAddDestructible == ShowAddDestructible.Show then
		self.bindData.ShowAddDestructible = ShowAddDestructible.Hide

		return
	end

	self:RefreshDestructibleList()
	self:SetJoystickVisiable(false)
end

function M:KillAll()
	L50.Gm.AutoQaFunctions.KillAll()
end

function M:RefreshDestructibleList(filter)
	self.bindData.ShowAddDestructible = ShowAddDestructible.Show

	table.clear(self.destructibleList)

	if #self.DestructibleTypes > 0 and not filter or filter == "" or not self.DestructibleDict[filter] then
		local defaultType = self.DestructibleTypes[1].Name
		self.destructibleList = table.clone(self.DestructibleDict[defaultType] or {})
	else
		self.destructibleList = table.clone(self.DestructibleDict[filter] or {})
	end

	self.bindData.destructibleList:SetSimpleList(#self.destructibleList)

	self.bindData.ShowEnemyList = ShowAddEnemyType.Hide
	self.bindData.ShowSkillList = ShowAddEnemyType.Hide
	self.bindData.ShowAddEnemy = ShowAddEnemyType.Hide
end

function M:ChooseDestructible(info)
	local count = tonumber(self.bindData.destructibleCountInputField.text) or 1

	gCS.BattleManager.SummonDestructible(info.Cfg.FileName, count)

	self.bindData.ShowEnemyList = ShowAddEnemyType.Hide
	self.bindData.ShowSkillList = ShowAddDestructible.Hide
	self.bindData.ShowAddDestructible = ShowAddDestructible.Hide
	self.bindData.ShowAddEnemy = ShowAddEnemyType.Hide

	self:SetJoystickVisiable(true)
end

function M:SelectEnemyBtn(data)
	local unit = gCS.SceneDataMgr.GetUnit(data.unitPid)

	if not unit then
		return
	end

	self.bindData.enemyName = unit.ClientData.Name
	self.bindData.ShowEnemyList = ShowAddEnemyType.Hide
	self.bindData.ShowAddDestructible = ShowAddDestructible.Hide

	if self.EnemyPid == unit.Pid then
		return
	end

	self.EnemyPid = unit.Pid
	self.EnemyId = unit.ClientData.SubType
	self.unit = unit

	table.clear(self.Skills)

	self.bindData.skillName = LTConfig.TextScriptTextConfig.GetConfig(89900608).Text
	self.SkillIndex = nil

	self:OpenSelectSkillList()
end

function M:OpenSelectSkillList()
	if self.bindData.ShowSkillList == ShowAddEnemyType.Show then
		self.bindData.ShowSkillList = ShowAddEnemyType.Hide

		return
	end

	if self.EnemyPid == nil then
		return
	end

	table.clear(self.skillList)
	table.clear(self.Skills)

	local spiritIds = {}

	for i = 0, FightSpiritConfig.count - 1 do
		local cfg = FightSpiritConfig.LoadAt(i)

		if cfg.GeneralModelId == self.unit.ClientData.ModelId then
			table.insert(spiritIds, cfg.Id)
		end
	end

	if #spiritIds > 0 then
		gClientToGameSceneGMDelegate:GmStartEnemyStrategyDebug(self.EnemyPid).Callback = function (err, ret)
			return
		end
	else
		gClientToGameSceneGMDelegate:GmStartEnemyStrategyDebug(self.EnemyPid).Callback = function (err, ret)
			if err ~= 0 then
				return
			end

			for i = 1, ret.SkillIds.Count do
				local cfg = SkillConfig.GetConfig(ret.SkillIds[i])

				if cfg then
					local nameStr = (string.is_null_or_empty(cfg.Name) and "" or cfg.Name) .. "_" .. cfg.Id

					if i == self.SkillIndex then
						nameStr = "<size><b>" .. nameStr .. "</b></size>"
					end

					if gCS.HSkillUtils:HasHSkill(cfg.Id) then
						nameStr = "<color=##90F894>" .. nameStr .. "</color>"
					end

					local data = {
						Name = nameStr
					}

					table.insert(self.skillList, data)
					table.insert(self.Skills, cfg.Id)
				end
			end

			self.bindData.ShowSkillList = ShowAddEnemyType.Show
			self.bindData.ShowEnemyList = ShowAddEnemyType.Hide
			self.bindData.ShowAddDestructible = ShowAddDestructible.Hide
			self.bindData.ShowAddEnemy = ShowAddEnemyType.Hide

			self.bindData.selectSkillList:SetSimpleList(#self.skillList)
		end
	end
end

function M:SelectSkillBtn(data)
	local skillId = self.Skills[data]

	if gCS.HSkillUtils:HasHSkill(skillId) then
		skillId = "<color=##90F894>" .. skillId .. "</color>"
	end

	self.bindData.skillName = skillId
	self.bindData.ShowSkillList = ShowAddEnemyType.Hide
	self.SkillIndex = data
end

function M:UseSkillBtn()
	self.bindData.ShowEnemyList = ShowAddEnemyType.Hide
	self.bindData.ShowSkillList = ShowAddEnemyType.Hide
	self.bindData.ShowAddDestructible = ShowAddDestructible.Hide
	self.bindData.ShowAddEnemy = ShowAddEnemyType.Hide

	if self.EnemyPid == nil then
		return
	end

	local skillId = 0
	local customStr = string.trim(self.bindData.customInputField.text)

	if string.len(customStr) > 0 then
		if string.starts_with(customStr, "51") and SkillConfig.GetConfig(tonumber(customStr)) ~= nil then
			skillId = tonumber(customStr)
		end
	elseif self.SkillIndex ~= nil or self.Skills[self.SkillIndex] ~= nil then
		skillId = self.Skills[self.SkillIndex]
	end

	if skillId == 0 then
		return
	end

	gClientToGameSceneGMDelegate:GmUseEnemyStrategy(self.EnemyPid, skillId).Callback = function (err, ret)
		if err ~= 0 then
			return
		end
	end
end

function M:AddEnemy()
	self.bindData.ShowAddEnemy = self.bindData.ShowAddEnemy == ShowAddEnemyType.Show and ShowAddEnemyType.Hide or ShowAddEnemyType.Show

	if self.bindData.ShowAddEnemy == ShowAddEnemyType.Show then
		self:refreshUnits(-1)
	end

	self:SetJoystickVisiable(false)
end

function M:ChooseEnemy(info)
	local camp = self.bindData.IsEnemy

	if info.Cfg.BossClass == LTConfig.AutoTestBossTestConfig.BossClassType.MonsterGroup then
		for i = 1, #info.Id do
			local enemyId = info.Id[i].EnemyId
			local count = info.Id[i].Count

			gCS.LuaUtils.AddEnemy(enemyId, 1, camp, count)
		end
	else
		local count = tonumber(self.bindData.enemyCountInputField.text)
		local enemyId = info.Id[1].EnemyId

		gCS.LuaUtils.AddEnemy(enemyId, 1, camp, count)
	end

	self.bindData.ShowAddEnemy = ShowAddEnemyType.Hide
	self.bindData.ShowEnemyList = ShowAddEnemyType.Hide
	self.bindData.ShowSkillList = ShowAddDestructible.Hide
	self.bindData.ShowAddDestructible = ShowAddDestructible.Hide

	self:SetJoystickVisiable(true)
end

function M:AddGroupEnemy()
	self.bindData.ShowAddEnemy = ShowAddEnemyType.Hide
	self.bindData.ShowSkillList = ShowAddDestructible.Hide
	self.bindData.ShowAddDestructible = ShowAddDestructible.Hide
	self.bindData.ShowAddEnemy = self.bindData.ShowAddEnemy == ShowAddEnemyType.Show and ShowAddEnemyType.Hide or ShowAddEnemyType.Show

	if self.bindData.ShowAddEnemy then
		table.clear(self.enemyList)

		for i = 0, BossTestConfig.count - 1 do
			local cfg = BossTestConfig.LoadAt(i)

			if cfg and cfg.BossClass == LTConfig.AutoTestBossTestConfig.BossClassType.MonsterGroup then
				table.insert(self.enemyList, {
					Name = "<color=#FF0000>" .. cfg.BossTitle .. "</color>",
					Id = cfg.BossId,
					Cfg = cfg
				})
			end
		end

		self.bindData.enemyList:SetSimpleList(#self.enemyList)
	end

	self:SetJoystickVisiable(false)
end

function M:ChangeCampAction()
	self.bindData.IsEnemy = self.bindData.IsEnemy == IsEnemyType.IsEnemy and IsEnemyType.NoEnemy or IsEnemyType.IsEnemy
end

function M:ClosePanel()
	gPanelManager:Close(gPanelId.S_SKILL_DEBUG_PANEL)
end

function M:SelectEnemyTypeBtnDown(data)
	local type = data.type

	self:refreshUnits(type < 0 and type or bit.lshift(1, type))
end

function M:SelectDestructibleTypeBtnDown(data)
	self:RefreshDestructibleList(data.Name)
end

function M:LookAroundAction()
	L50.Gm.AutoQaFunctions.GmSwitchCameraLookAround()
end

function M:HSkillClipRunAction(data)
	local EnemyId = data:ToTable()[1]
	local SkillId = data:ToTable()[2]

	Timer.New(function ()
		local pid = 0

		gBattleMgr:ForEach(function (u)
			if u.ClientData.SubType == EnemyId and pid < u.Pid then
				pid = u.Pid
				self.unit = u
			end
		end)

		self.bindData.enemyName = self.unit.ClientData.Name
		self.bindData.ShowEnemyList = ShowAddEnemyType.Hide
		self.bindData.ShowAddDestructible = ShowAddDestructible.Hide
		self.EnemyPid = self.unit.Pid
		self.EnemyId = self.unit.ClientData.SubType
		self.bindData.customInputField.text = SkillId

		gClientToGameSceneGMDelegate:GmStartEnemyStrategyDebug(self.EnemyPid).Callback = function (err, ret)
			return
		end
	end, 0.5):Start()
end

function M:SetJoystickVisiable(enable)
	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		gLuaDataManager.guiMgr.sguiJoystick:ShowJoystickUI(enable)
	end
end
