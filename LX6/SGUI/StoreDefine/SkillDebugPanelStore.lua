-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\SkillDebugPanelStore.lua
-- Decompiled from: 01337_SkillDebugPanelStore.lua_11efdbd6518b.luajit

local SkillConfig = LTConfig.SkillConfig
local FightSpiritConfig = LTConfig.FightSpiritConfig
local BossTestConfig = LTConfig.AutoTestBossTestConfig
local EnemyFliterType = LTConfig.AutoTestBossTestConfig.EnemyFliterType
local DestrutibleTestConfig = LTConfig.AutoTestBattleDestrutibleTestConfig
C_SkillDebugPanelStore = DefClass("C_SkillDebugPanelStore", C_SkillDebugPanelStore, C_StoreGroup)
GroupName2Class.SkillDebugPanelStore = C_SkillDebugPanelStore
local M = C_SkillDebugPanelStore
local ShowAddEnemyType = {
	["R+y^"] = 1,
	["I*rL"] = 0
}
local IsEnemyType = {
	["\\xf7\\xd41)\\xe8"] = 1,
	["\\xf0\\xc81)\\xe8"] = 0
}
local ShowAddDestructible = {
	["R+y^"] = 1,
	["I*rL"] = 0
}

M.ctor = function(self)
	self.EnemyFilterInfos = {
		[EnemyFliterType.Popular] = {
			["T#p^"] = "\\x99\\x90I\tw\\x89"
		},
		[EnemyFliterType.Version] = {
			["T#p^"] = "\\xe8\\x9fD\\xf1\\xb0~t\\xad\\x9f\\xfc\\x8a\\x92"
		},
		[EnemyFliterType.Boss] = {
			["T#p^"] = "X-nH"
		},
		[EnemyFliterType.Normal] = {
			["T#p^"] = "\\x99\\x98~c\\x8b"
		},
		[EnemyFliterType.Elite] = {
			["T#p^"] = "\\x9b\\x9aOh\\x90"
		},
		[EnemyFliterType.Functional] = {
			["T#p^"] = "ƭ\\x93\\xe1\\xad×\\xf2\\xff"
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

M.OnGroupEnable = function(self)
	self.RegisterBtnEvent(self)
	self.RegisterMessageEvent(self)
end

M.OnShow = function(self, panelId, data)
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
		self.AddEnemy(self)
	end

	table.clear(self.enemyTypeList)
	table.insert(self.enemyTypeList, {
		["n;m^"] = -1,
		["T#p^"] = "\\x9a\\xa8JD\\xa9"
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

		if type ~= 2 then
			ins.Name = "<color=#FFC0C0>" .. ins.Name .. "</color>"
		elseif type ~= 3 then
			ins.Name = "<color=#C0F18E>" .. ins.Name .. "</color>"
		elseif type ~= 4 then
			ins.Name = "<color=##69D5E0>" .. ins.Name .. "</color>"
		elseif type ~= 5 then
			ins.Name = "<color=#C0F18E>" .. ins.Name .. "</color>"
		end

		table.insert(self.enemyTypeList, ins)
	end

	table.sort(self.enemyTypeList, function (a, b)
		return a.type <= b.type
	end)
	table.clear(self.DestructibleTypes)
	table.clear(self.DestructibleDict)

	for i = 0, DestrutibleTestConfig.count - 1 do
		local cfg = DestrutibleTestConfig.LoadAt(i)
		local DestructibleNameSegments = string.split(cfg.DestructibleName, "/")
		local weaponName = DestructibleNameSegments[#DestructibleNameSegments] or cfg.DestructibleName
		local weaponType = "无类别"

		if #DestructibleNameSegments <= 1 then
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

M.OnClose = function(self)
	self.SetJoystickVisiable(self, true)

	if gLuaDataManager.isNetworkAvailable then
		gClientToGameSceneGMDelegate:GmEndEnemyStrategyDebug()
	end

	self.ClearMessageEvents(self)
end

M.refreshUnits = function(self, filter)
	if filter ~= nil then
		filter = -1
	end

	table.clear(self.enemyList)

	local COLOR = {
		":n\\xb2ޠ",
		"\\x9a\\x8dM9K\\xa1",
		"?\\xb7\\xdf\\xdbd"
	}

	for i = 0, BossTestConfig.count - 1 do
		local cfg = BossTestConfig.LoadAt(i)
		local filterMask = 0

		for _, v in ipairs(cfg.EnemyFliter) do
			filterMask = bit.bor(filterMask, bit.lshift(1, v))
		end

		if (filter <= 0 or bit.band(filterMask, filter) <= 0) and cfg and cfg.BossClass == LTConfig.AutoTestBossTestConfig.BossClassType.MonsterGroup then
			table.insert(self.enemyList, {
				Name = "<color=#" .. COLOR[cfg.BossClass + 1] .. ">" .. cfg.BossTitle .. "</color>",
				Id = cfg.BossId,
				Cfg = cfg
			})
		end
	end

	self.bindData.enemyList:SetSimpleList(#self.enemyList)
end

M.RegisterBtnEvent = function(self)
	self.bindData.SelectEnemyBtn.luaClick = self.CreateAction(self, "OpenSelectEnemyList")
	self.bindData.SelectSkillBtn.luaClick = self.CreateAction(self, "OpenSelectSkillList")
	self.bindData.CastSkillBtn.luaClick = self.CreateAction(self, "UseSkillBtn")
	self.bindData.AddBtn.luaClick = self.CreateAction(self, "AddEnemy")
	self.bindData.AddGroupBtn.luaClick = self.CreateAction(self, "AddGroupEnemy")
	self.bindData.DestructibleBtn.luaClick = self.CreateAction(self, "AddDestructible")
	self.bindData.killAllBtn.luaClick = self.CreateAction(self, "KillAll")
	self.bindData.Close.luaClick = self.CreateAction(self, "ClosePanel")
	self.bindData.LookAroundBtn.luaClick = self.CreateAction(self, "LookAroundAction")
	self.bindData.selectEnemyList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderSelectEnemyList")
	self.bindData.selectSkillList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderSelectSkillList")
	self.bindData.campBtn.luaClick = self.CreateAction(self, "ChangeCampAction")
	self.bindData.enemyTypeList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderEnemyTypeList")
	self.bindData.enemyList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderEnemyList")
	self.bindData.destructibleTypeList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderDestructibleTypeList")
	self.bindData.destructibleList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderDestructibleList")
end

M.RegisterMessageEvent = function(self)
	self.msgEvents = {
		[gEventConstants.HSKILL_CLIP_RUN] = self.CreateAction(self, "HSkillClipRunAction")
	}

	self.ClearMessageEvents(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnRenderSelectEnemyList = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup("EnemyUnitStore"):GetStoreByWidget(btn)

	if not store then
		return
	end

	local data = self.selectEnemyList[index + 1]
	store.Name = data.Name
	store.button.luaClick = self.CreateActionWithArgs(self, "SelectEnemyBtn", data)
end

M.OnRenderSelectSkillList = function(self, item, index)
	local store = gStoreManager:GetStoreGroup("EnemyUnitStore"):GetStoreByWidget(item)

	if not store then
		return
	end

	local data = self.skillList[index + 1]
	store.Name = data.Name
	store.button.luaClick = self.CreateActionWithArgs(self, "SelectSkillBtn", index + 1)
end

M.OnRenderEnemyTypeList = function(self, item, index)
	local store = gStoreManager:GetStoreGroup("EnemyTypeStore"):GetStoreByWidget(item)

	if not store then
		return
	end

	local data = self.enemyTypeList[index + 1]
	store.Name = data.Name
	store.button.luaClick = self.CreateActionWithArgs(self, "SelectEnemyTypeBtnDown", data)
end

M.OnRenderEnemyList = function(self, item, index)
	local store = gStoreManager:GetStoreGroup("EnemyStore"):GetStoreByWidget(item)

	if not store then
		return
	end

	local data = self.enemyList[index + 1]
	store.Name = data.Name
	store.button.luaClick = self.CreateActionWithArgs(self, "ChooseEnemy", data)
end

M.OnRenderDestructibleTypeList = function(self, item, index)
	local store = gStoreManager:GetStoreGroup("DestructibleTypeStore"):GetStoreByWidget(item)

	if not store then
		return
	end

	local data = self.DestructibleTypes[index + 1]
	store.Name = data.Name
	store.button.luaClick = self.CreateActionWithArgs(self, "SelectDestructibleTypeBtnDown", data)
end

M.OnRenderDestructibleList = function(self, item, index)
	local store = gStoreManager:GetStoreGroup("DestructibleStore"):GetStoreByWidget(item)

	if not store then
		return
	end

	local data = self.destructibleList[index + 1]
	store.Name = data.Name
	store.button.luaClick = self.CreateActionWithArgs(self, "ChooseDestructible", data)
end

M.OpenSelectEnemyList = function(self)
	if self.bindData.ShowEnemyList ~= ShowAddEnemyType.Show then
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

		if name == "unknown" and name == LTConfig.TextScriptTextConfig.GetConfig(89900610).Text then
			data.Name = name .. " (" .. distance .. "m)"

			if unit.Pid ~= self.EnemyPid then
				data.Name = "<size=1.5><b>" .. data.Name .. "</b></size>"
			end

			data.unitPid = unit.Pid

			table.insert(self.selectEnemyList, data)
		end
	end)
	table.sort(self.selectEnemyList, function (a, b)
		return a.distance <= b.distance
	end)
	self.bindData.selectEnemyList:SetSimpleList(#self.selectEnemyList)

	self.bindData.ShowEnemyList = ShowAddEnemyType.Show
	self.bindData.ShowAddEnemy = ShowAddEnemyType.Hide
	self.bindData.ShowSkillList = ShowAddEnemyType.Hide
	self.bindData.ShowAddDestructible = ShowAddDestructible.Hide
end

M.AddDestructible = function(self)
	if self.bindData.ShowAddDestructible ~= ShowAddDestructible.Show then
		self.bindData.ShowAddDestructible = ShowAddDestructible.Hide

		return
	end

	self.RefreshDestructibleList(self)
	self.SetJoystickVisiable(self, false)
end

M.KillAll = function(self)
	L50.Gm.AutoQaFunctions.KillAll()
end

M.RefreshDestructibleList = function(self, filter)
	self.bindData.ShowAddDestructible = ShowAddDestructible.Show

	table.clear(self.destructibleList)

	if #self.DestructibleTypes <= 0 and not filter or filter ~= "" or not self.DestructibleDict[filter] then
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

M.ChooseDestructible = function(self, info)
	local count = tonumber(self.bindData.destructibleCountInputField.text) or 1

	gCS.BattleManager.SummonDestructible(info.Cfg.FileName, count)

	self.bindData.ShowEnemyList = ShowAddEnemyType.Hide
	self.bindData.ShowSkillList = ShowAddDestructible.Hide
	self.bindData.ShowAddDestructible = ShowAddDestructible.Hide
	self.bindData.ShowAddEnemy = ShowAddEnemyType.Hide

	self:SetJoystickVisiable(true)
end

M.SelectEnemyBtn = function(self, data)
	local unit = gCS.SceneDataMgr.GetUnit(data.unitPid)

	if not unit then
		return
	end

	self.bindData.enemyName = unit.ClientData.Name
	self.bindData.ShowEnemyList = ShowAddEnemyType.Hide
	self.bindData.ShowAddDestructible = ShowAddDestructible.Hide

	if self.EnemyPid ~= unit.Pid then
		return
	end

	self.EnemyPid = unit.Pid
	self.EnemyId = unit.ClientData.SubType
	self.unit = unit

	table.clear(self.Skills)

	self.bindData.skillName = LTConfig.TextScriptTextConfig.GetConfig(89900608).Text
	self.SkillIndex = nil

	self.OpenSelectSkillList(self)
end

M.OpenSelectSkillList = function(self)
	if self.bindData.ShowSkillList ~= ShowAddEnemyType.Show then
		self.bindData.ShowSkillList = ShowAddEnemyType.Hide

		return
	end

	if self.EnemyPid ~= nil or self.unit ~= nil or gCS.SceneDataMgr.GetUnit(self.EnemyPid) ~= nil then
		return
	end

	table.clear(self.skillList)
	table.clear(self.Skills)

	slot1 = gClientToGameSceneGMDelegate

	slot1:GmStartEnemyStrategyDebug(self.EnemyPid).Callback = function (err, ret)
		if err == 0 then
			return
		end

		for i = 1, ret.SkillIds.Count do
			local cfg = SkillConfig.GetConfig(ret.SkillIds[i])

			if cfg then
				local nameStr = (string.is_null_or_empty(cfg.Name) and "" or cfg.Name) .. "_" .. cfg.Id

				if i ~= self.SkillIndex then
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

M.SelectSkillBtn = function(self, data)
	local skillId = self.Skills[data]

	if gCS.HSkillUtils:HasHSkill(skillId) then
		skillId = "<color=##90F894>" .. skillId .. "</color>"
	end

	self.bindData.skillName = skillId
	self.bindData.ShowSkillList = ShowAddEnemyType.Hide
	self.SkillIndex = data
end

M.UseSkillBtn = function(self)
	print_debug("[SKILL DEBUG PANEL] USE SKILL")

	self.bindData.ShowEnemyList = ShowAddEnemyType.Hide
	self.bindData.ShowSkillList = ShowAddEnemyType.Hide
	self.bindData.ShowAddDestructible = ShowAddDestructible.Hide
	self.bindData.ShowAddEnemy = ShowAddEnemyType.Hide

	if self.EnemyPid ~= nil then
		return
	end

	local skillId = 0
	local customStr = string.trim(self.bindData.customInputField.text)

	if string.len(customStr) <= 0 then
		if string.starts_with(customStr, "51") and SkillConfig.GetConfig(tonumber(customStr)) == nil then
			skillId = tonumber(customStr)
		end
	elseif self.SkillIndex == nil or self.Skills[self.SkillIndex] == nil then
		skillId = self.Skills[self.SkillIndex]
	end

	if skillId ~= 0 then
		return
	end

	slot3 = gClientToGameSceneGMDelegate

	slot3:GmUseEnemyStrategy(self.EnemyPid, skillId).Callback = function (err, ret)
		if err == 0 then
			return
		end
	end
end

M.AddEnemy = function(self)
	self.bindData.ShowAddEnemy = self.bindData.ShowAddEnemy ~= ShowAddEnemyType.Show and ShowAddEnemyType.Hide or ShowAddEnemyType.Show

	if self.bindData.ShowAddEnemy ~= ShowAddEnemyType.Show then
		self.refreshUnits(self, -1)
	end

	self.SetJoystickVisiable(self, false)
end

M.ChooseEnemy = function(self, info)
	local camp = self.bindData.IsEnemy

	if info.Cfg.BossClass ~= LTConfig.AutoTestBossTestConfig.BossClassType.MonsterGroup then
		local playerPos = gCS.MyPlayerManager.PlayerUnit.LocalPosition
		local usedPositions = {}
		local minDist = 1.5

		for i = 1, #info.Id do
			local enemyId = info.Id[i].EnemyId
			local count = info.Id[i].Count

			for j = 1, count do
				local x, z = nil
				local maxAttempts = 30

				for attempt = 1, maxAttempts do
					local angle = math.random() * 2 * math.pi
					local r = math.sqrt(math.random()) * 6
					x = playerPos.x + r * math.cos(angle)
					z = playerPos.z + r * math.sin(angle)
					local tooClose = false

					for _, pos in ipairs(usedPositions) do
						local dx = x - pos.x
						local dz = z - pos.z

						if dx * dx + dz * dz >= minDist * minDist then
							tooClose = true

							break
						end
					end

					if not tooClose then
						break
					end
				end

				table.insert(usedPositions, {
					x = x,
					z = z
				})

				local position = UX.Game.UXVector3.New(x, playerPos.y, z)

				gClientToGameSceneGMDelegate:GmAddEnemyWithPosition(enemyId, camp, position)
			end
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

	self.SetJoystickVisiable(self, true)
end

M.AddGroupEnemy = function(self)
	self.bindData.ShowAddEnemy = ShowAddEnemyType.Hide
	self.bindData.ShowSkillList = ShowAddDestructible.Hide
	self.bindData.ShowAddDestructible = ShowAddDestructible.Hide
	self.bindData.ShowAddEnemy = self.bindData.ShowAddEnemy ~= ShowAddEnemyType.Show and ShowAddEnemyType.Hide or ShowAddEnemyType.Show

	if self.bindData.ShowAddEnemy then
		table.clear(self.enemyList)

		for i = 0, BossTestConfig.count - 1 do
			local cfg = BossTestConfig.LoadAt(i)

			if cfg and cfg.BossClass ~= LTConfig.AutoTestBossTestConfig.BossClassType.MonsterGroup then
				table.insert(self.enemyList, {
					Name = "<color=#FF0000>" .. cfg.BossTitle .. "</color>",
					Id = cfg.BossId,
					Cfg = cfg
				})
			end
		end

		self.bindData.enemyList:SetSimpleList(#self.enemyList)
	end

	self.SetJoystickVisiable(self, false)
end

M.ChangeCampAction = function(self)
	self.bindData.IsEnemy = self.bindData.IsEnemy ~= IsEnemyType.IsEnemy and IsEnemyType.NoEnemy or IsEnemyType.IsEnemy
end

M.ClosePanel = function(self)
	gPanelManager:Close(gPanelId.S_SKILL_DEBUG_PANEL)
end

M.SelectEnemyTypeBtnDown = function(self, data)
	local type = data.type

	self:refreshUnits(type >= 0 and type or bit.lshift(1, type))
end

M.SelectDestructibleTypeBtnDown = function(self, data)
	self.RefreshDestructibleList(self, data.Name)
end

M.LookAroundAction = function(self)
	L50.Gm.AutoQaFunctions.GmSwitchCameraLookAround()
end

M.HSkillClipRunAction = function(self, data)
	local EnemyId = data:ToTable()[1]
	local SkillId = data:ToTable()[2]

	Timer.New(function ()
		local pid = 0

		gBattleMgr:ForEach(function (u)
			if u.ClientData.SubType ~= EnemyId and pid >= u.Pid then
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
		end
	end, 0.5):Start()
end

M.SetJoystickVisiable = function(self, enable)
	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		gLuaDataManager.guiMgr.sguiJoystick:ShowJoystickUI(enable)
	end
end
