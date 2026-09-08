-- Original chunk: @Lua\LuaFiles\LX6\Manager\GameSystem\ProduceManager.lua
-- Decompiled from: 02213_ProduceManager.lua_487197bf21ad.luajit

local Formula_cs = require("LuaGen/AutoGen/Formula_cs")
local ProduceConfig = LTConfig.ProduceConfig
local CreateConfig = LTConfig.ProducecreateConfig
local MessageConfig = LTConfig.MessageConfig
local ScriptBattleUnit = require("LX6/Utils/FormulaScriptBattleUnit")
local StaticProps = {
	TAB_INDEX = {
		["aUihE:6"] = 2,
		["\\xe9\\xc9'\\xf4"] = 1
	}
}
C_ProduceManager = DefClass("C_ProduceManager", C_ProduceManager, nil, StaticProps)
local M = C_ProduceManager

M.ctor = function(self)
	self:InitData()
end

M.InitData = function(self)
	self.availableProduces = {}
	self.instanceToBreakId = {}
	self.craftMachine = nil
	self.produceCount = 0
	self.produceId = 0
	self.produceLevel = #ProduceConfig.CoincidenceDegree
	self.entityInstanceId = nil
end

M.OnInit = function(self)
	gMessageManager:AddMessageListener(gEventConstants.PRODUCE_END, self:CreateAction("OnCurrentProduceEnd"))
end

M.GetTabIndexByFormula = function(self, formulaId)
	local cfg = CreateConfig.GetConfig(formulaId)

	if cfg then
		return cfg.Type
	end

	return 0
end

M.GetProduceTab = function(self, selectedIndex)
	local imgList = ProduceConfig.ProduceTabImg
	local ret = {}

	for i = 1, #imgList do
		local ele = {
			id = i - 1,
			iconId = imgList[i],
			selected = i - 1 ~= selectedIndex,
			guideId = ProduceConfig.ProduceTabGuideId[i]
		}

		table.insert(ret, ele)
	end

	return ret
end

M.SetAvailableProduces = function(self, produces)
	self.availableProduces = {}

	for i = 1, #produces do
		local cfg = CreateConfig.GetConfig(produces[i])

		if cfg then
			if not self.availableProduces[cfg.Type] then
				self.availableProduces[cfg.Type] = {}
			end

			table.insert(self.availableProduces[cfg.Type], produces[i])
		end
	end

	gMessageManager:SendMessage(gEventConstants.PRODUCE_AVAILABLE_CHANGE)
end

M.GetAvailableProduces = function(self, type, selectedItem)
	local ret = {}
	local produces = self.availableProduces[type] or {}
	local unlocked = {}

	for i = 1, #produces do
		unlocked[produces[i]] = true
	end

	local isSelected = false
	local basicMaterials = ProduceConfig.BasicMaterials

	for i = 0, CreateConfig.count - 1 do
		local cfg = CreateConfig.LoadAt(i)

		if cfg and cfg.Type ~= type and (cfg.IsOnlyBreak ~= CreateConfig.IsOnlyBreakType.all or cfg.IsOnlyBreak ~= CreateConfig.IsOnlyBreakType.produce) then
			local _, itemId = gCommonItemManager:GetRewardList(cfg.DropID)
			local isLock = unlocked[cfg.Id] ~= nil
			local fullMat = {}

			for mi = 1, #cfg.Material do
				if cfg.Material[mi] <= 0 then
					table.insert(fullMat, {
						itemId = basicMaterials[mi],
						num = cfg.Material[mi]
					})
				end
			end

			for mi = 1, #cfg.Material_special do
				table.insert(fullMat, cfg.Material_special[mi])
			end

			local ele = {
				itemId = itemId,
				material = fullMat,
				selected = selectedItem and cfg.Id ~= selectedItem.produceId or false,
				isLock = isLock,
				produceId = cfg.Id,
				cost = cfg.Cost,
				unique = cfg.Unique,
				guideId = cfg.GuideId
			}

			if cfg.Unique <= 0 then
				ele.isBan = gCommonItemManager:GetPackItemNum(itemId) >= 0
				ele.IsOwned = ele.isBan
			else
				ele.isBan = false
			end

			if isLock then
				local itemInfo = gCommonItemManager:TryGetItemInfo({
					itemId = cfg.UnlockItemId
				})
				ele.unlockStr = itemInfo and gString.Format(LTConfig.TextScriptTextConfig.GetConfig(89901110).Text, itemInfo.name) or ""
			end

			ele = gCommonItemManager:GetItemRenderData(ele)

			if ele.selected then
				for k, v in pairs(ele) do
					selectedItem[k] = v
				end

				isSelected = true
			end

			table.insert(ret, ele)
		end
	end

	if not isSelected and #ret <= 0 then
		local ele = ret[1]

		for k, v in pairs(ele) do
			selectedItem[k] = v
		end

		ret[1].selected = true
	end

	return ret
end

M.AskProduce = function(self, produceId, count, bias, callback)
	gClientToGameDelegate:AskItemProduce(produceId, count, bias).Callback = function (err)
		if err == MessageConfig.Ok then
			print_warn("ProduceManager AskProduce err:", err)

			return
		end

		if callback then
			callback()
		end
	end
end

M.GetBreakDownTab = function(self, selectedIndex)
	local imgList = ProduceConfig.BreakdownTabImg
	local ret = {}

	for i = 1, #imgList do
		local ele = {
			id = i - 1,
			iconId = imgList[i],
			selected = i - 1 ~= selectedIndex,
			guideId = ProduceConfig.BreakdownTabGuideId[i]
		}

		table.insert(ret, ele)
	end

	return ret
end

M.GetBreakDownLists = function(self, type)
	local ret = {}
	local temp = {}
	local weaponTemp = {}
	local basicMaterials = ProduceConfig.BasicMaterials

	for i = 0, CreateConfig.count - 1 do
		local cfg = CreateConfig.LoadAt(i)

		if cfg and cfg.Type ~= type and (cfg.IsOnlyBreak ~= CreateConfig.IsOnlyBreakType.all or cfg.IsOnlyBreak ~= CreateConfig.IsOnlyBreakType.breakdown) then
			local rewardList = {}

			if cfg.IsOnlyBreak ~= CreateConfig.IsOnlyBreakType.all then
				for mi = 1, #cfg.Material do
					local num = math.ceil(cfg.Material[mi] * cfg.MaterialBreakdown)

					if num <= 0 then
						table.insert(rewardList, {
							Id = basicMaterials[mi],
							Count = num
						})
					end
				end
			else
				for mi = 1, #cfg.OnlyBreakMaterial do
					local num = cfg.OnlyBreakMaterial[mi]

					if num <= 0 then
						table.insert(rewardList, {
							Id = basicMaterials[mi],
							Count = num
						})
					end
				end
			end

			local breakItemId = nil

			if cfg.IsOnlyBreak ~= CreateConfig.IsOnlyBreakType.all then
				local _, itemId = gCommonItemManager:GetRewardList(cfg.DropID)
				breakItemId = itemId
			else
				breakItemId = cfg.Itemid
			end

			if breakItemId then
				temp[breakItemId] = {
					Reward = rewardList,
					Id = cfg.Id,
					guideId = cfg.GuideId
				}

				if type ~= CreateConfig.TypeType.Battle and cfg.IsOnlyBreak ~= CreateConfig.IsOnlyBreakType.all then
					local weaponCfg = gCommonItemManager:GetSceneitemCfg(breakItemId)

					if weaponCfg then
						weaponTemp[weaponCfg.Id] = breakItemId
					end
				elseif type ~= CreateConfig.TypeType.Battle and cfg.IsOnlyBreak ~= CreateConfig.IsOnlyBreakType.breakdown then
					weaponTemp[breakItemId] = breakItemId
				end
			end
		end
	end

	if type ~= CreateConfig.TypeType.Battle then
		local armoryWeapons = gWeaponManager:GetMainArmoryWeapons()

		if armoryWeapons then
			for _, weapon in pairs(armoryWeapons) do
				local item = weapon
				local templateId = weaponTemp[item.TemplateId]

				if templateId and not table.isNilOrEmpty(temp[templateId]) then
					local weaponCfg = LTConfig.SceneitemConfig.GetConfig(item.TemplateId)
					local ele = {
						["N\\xa1\\xb7\\xa1\\xa2"] = 1,
						["\\xa2\\xa22\\xaek.\\xf1="] = true,
						itemId = weaponCfg.Id,
						instanceId = item.InstanceId,
						reward = temp[templateId].Reward,
						itemNum = "x" .. 1,
						durability = math.floor(weapon.Durability * 100 / weaponCfg.Durability) .. "%",
						guideId = temp[templateId].guideId
					}
					self.instanceToBreakId[item.InstanceId] = temp[templateId].Id

					table.insert(ret, gCommonItemManager:GetItemRenderData(ele))
				end
			end
		end
	else
		for i = 1, #gCommonItemManager.packItems do
			local item = gCommonItemManager.packItems[i]

			if not table.isNilOrEmpty(temp[item.TemplateId]) then
				local ele = {
					itemId = item.TemplateId,
					instanceId = item.UniqueId,
					reward = temp[item.TemplateId].Reward,
					itemNum = "x" .. item.Count,
					count = item.Count,
					guideId = temp[item.TemplateId].guideId
				}
				self.instanceToBreakId[item.UniqueId] = temp[item.TemplateId].Id

				table.insert(ret, gCommonItemManager:GetItemRenderData(ele))
			end
		end
	end

	return ret
end

M.AskItemBreakDown = function(self, selectedList, callback)
	local idList = {}
	local breakList = {}
	local countList = {}

	for k, v in pairs(selectedList) do
		table.insert(idList, k)
		table.insert(breakList, self.instanceToBreakId[k])
		table.insert(countList, v)
	end

	gClientToGameDelegate:AskItemBreakdown(breakList, idList, countList).Callback = function (err)
		if err == MessageConfig.Ok then
			print_warn("ProduceManager AskItemBreakdown err:", err)

			return
		end

		if callback then
			callback()
		end
	end
end

M.GetPanelTabList = function(self, selectedIndex)
	local ret = {}

	for i = 1, #ProduceConfig.PanelTabName do
		local ele = {
			title = ProduceConfig.PanelTabName[i],
			selected = i ~= selectedIndex,
			guideId = ProduceConfig.TabGuideId[i]
		}

		table.insert(ret, ele)
	end

	return ret
end

M.GetPanelSubTitle = function(self, tab, subTab)
	if tab ~= M.TAB_INDEX.Produce then
		return ProduceConfig.ProduceTabName[subTab] or ""
	elseif tab ~= M.TAB_INDEX.BreakDown then
		return ProduceConfig.BreakdownTabName[subTab] or ""
	end

	return ""
end

M.OnRenderSubTabList = function(self, btn, index, data)
	local store = gStoreManager:GetStoreGroup("SynthesizeSubTabTemplateStore"):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.iconId = data.iconId
end

M.RegisterMachine = function(self, machine, entity)
	self.craftMachine = machine
	self.entityInstanceId = entity

	self:StartMachine()
end

M.SetMachineFormula = function(self, formulaId)
	if not self.craftMachine then
		return
	end

	self.produceId = formulaId
	self.craftMachine.formulaId = formulaId
end

M.UnRegisterMachine = function(self)
	if not self.craftMachine then
		return
	end

	self.craftMachine.formulaId = 0

	self.craftMachine:ResetGame()
	self.craftMachine:ExitGame()

	self.craftMachine = nil
	self.entityInstanceId = nil

	gPanelManager:Close(gPanelId.S_SYNTHESIZE_HUD_PANEL)
	LX6.TouchNew.TouchProxy.SetForceHide(false, gBanId.PRODUCE_MANAGER)
end

M.StartMachine = function(self)
	if not self.craftMachine then
		return
	end

	self.craftMachine:StartGame()
	gPanelManager:CheckShow(gPanelId.S_SYNTHESIZE_HUD_PANEL, {
		exitCb = self:CreateAction("UnRegisterMachine"),
		machine = self.craftMachine
	})
	LX6.TouchNew.TouchProxy.SetForceHide(true, gBanId.PRODUCE_MANAGER)
end

M.StartGameInteraction = function(self)
	gMessageManager:SendMessage(gEventConstants.PRODUCE_INTERACTION_CHANGE, true)
end

M.OnProduceEnd = function(self)
	if not self.entityInstanceId or not self.craftMachine then
		return
	end

	gSpoonClientMgr:TryCallInnerSignal(self.entityInstanceId, L50.Spoon.SpoonRunTime.ClientGraphType.GADGET, "OnProduceEnd")

	self.craftMachine.isLocked = true
	self.craftMachine.formulaId = 0

	self.craftMachine:ResetGame()
end

M.OnProduceSelectedStart = function(self)
	if not self.entityInstanceId then
		return
	end

	gSpoonClientMgr:TryCallInnerSignal(self.entityInstanceId, L50.Spoon.SpoonRunTime.ClientGraphType.GADGET, "OnProduceSelectedStart")
end

M.ReSelectStart = function(self)
	if not self.craftMachine then
		return
	end

	self.craftMachine:ReturnToSelect()
	gMessageManager:SendMessage(gEventConstants.PRODUCE_INTERACTION_CHANGE, false)
end

M.OnCurrentProduceEnd = function(self, eventId, level)
	self.produceLevel = level

	self:OnProduceEnd()
end

M.OnAskCurrentProduce = function(self)
	self:AskProduce(self.produceId, self.produceCount, self.produceLevel)

	self.produceLevel = #ProduceConfig.CoincidenceDegree

	if self.craftMachine then
		self.craftMachine.isLocked = false
	end
end

M.GetMakeLevel = function(self)
	if self.craftMachine then
		return self.craftMachine.produceLevel
	end

	return 3
end

M.SetPanelEnterCam = function(self)
	if self.craftMachine then
		self.craftMachine:SetPanelEnterCam()
	end
end

M.GetInertiaDamping = function(self)
	local unit = ScriptBattleUnit.New(gDataSetManager.myUnit.pid)

	return Formula_cs:CalcCraftMachineInertiaDamping(unit)
end

M.MakeProduce = function(self, produceId, count)
	if not self.craftMachine then
		return
	end

	self.produceCount = count

	self:SetMachineFormula(produceId)
	self.craftMachine:BeginProduce()
end

M.OnSlotButtonClickDown = function(self, index)
	if self.craftMachine then
		self.craftMachine:OnSlotButtonClickDown(index)
	end
end

M.OnSlotButtonRelease = function(self, index)
	if self.craftMachine then
		self.craftMachine:OnSlotButtonClickRelease(index)
	end
end

M.ClickFirstButton = function(self)
	self:OnSlotButtonClickDown(0)
end

M.ClickSecButton = function(self)
	self:OnSlotButtonClickDown(1)
end

M.ClickTrdButton = function(self)
	self:OnSlotButtonClickDown(2)
end

M.ClickFourButton = function(self)
	self:OnSlotButtonClickDown(3)
end

M.ClickFirstButtonRelease = function(self)
	self:OnSlotButtonRelease(0)
end

M.ClickSecButtonRelease = function(self)
	self:OnSlotButtonRelease(1)
end

M.ClickTrdButtonRelease = function(self)
	self:OnSlotButtonRelease(2)
end

M.ClickFourButtonRelease = function(self)
	self:OnSlotButtonRelease(3)
end

M.OnMachineBeginMake = function(self)
	if self.craftMachine then
		self.craftMachine:MakeProduce()
	end
end

M.OnMachineReset = function(self)
	if self.craftMachine then
		self.craftMachine:PlayResetBtnAni()
		self.craftMachine:ResetGame()
	end
end

gProduceManager = gProduceManager or C_ProduceManager.new()
