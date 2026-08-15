local Formula_cs = require("LuaGen/AutoGen/Formula_cs")
local ProduceConfig = LTConfig.ProduceConfig
local BreakConfig = LTConfig.ProduceBreakDownConfig
local MessageConfig = LTConfig.MessageConfig
local ScriptBattleUnit = require("LX6/Utils/FormulaScriptBattleUnit")
local StaticProps = {
	TAB_INDEX = {
		BreakDown = 2,
		Produce = 1
	}
}
C_ProduceManager = DefClass("C_ProduceManager", C_ProduceManager, nil, StaticProps)
local M = C_ProduceManager

function M:ctor()
	self:InitData()
end

function M:InitData()
	self.availableProduces = {}
	self.instanceToBreakId = {}
	self.craftMachine = nil
	self.produceCount = 0
	self.produceId = 0
	self.produceLevel = #ProduceConfig.CoincidenceDegree
	self.entityInstanceId = nil
end

function M:OnInit()
	gMessageManager:AddMessageListener(gEventConstants.PRODUCE_END, self:CreateAction("OnCurrentProduceEnd"))
end

function M:CheckProduceHard(produceId)
	local cfg = ProduceConfig.GetConfig(produceId)

	return cfg and cfg.Difficulty == ProduceConfig.DifficultyType.Hard or false
end

function M:GetTabIndexByFormula(formulaId)
	local cfg = ProduceConfig.GetConfig(formulaId)

	if cfg then
		return cfg.Type
	end

	return 0
end

function M:GetProduceTab(selectedIndex)
	local imgList = ProduceConfig.ProduceTabImg
	local ret = {}

	for i = 1, #imgList do
		local ele = {
			id = i - 1,
			iconId = imgList[i],
			selected = i - 1 == selectedIndex
		}

		table.insert(ret, ele)
	end

	return ret
end

function M:SetAvailableProduces(produces)
	self.availableProduces = {}

	for i = 1, #produces do
		local cfg = ProduceConfig.GetConfig(produces[i])

		if cfg then
			if not self.availableProduces[cfg.Type] then
				self.availableProduces[cfg.Type] = {}
			end

			table.insert(self.availableProduces[cfg.Type], produces[i])
		end
	end

	gMessageManager:SendMessage(gEventConstants.PRODUCE_AVAILABLE_CHANGE)
end

function M:GetAvailableProduces(type, selectedItem)
	local ret = {}
	local produces = self.availableProduces[type] or {}
	local unlocked = {}

	for i = 1, #produces do
		unlocked[produces[i]] = true
	end

	local isSelected = false

	for i = 0, ProduceConfig.count - 1 do
		local cfg = ProduceConfig.LoadAt(i)

		if cfg and cfg.Type == type then
			local _, itemId = gCommonItemManager:GetRewardList(cfg.DropId)
			local isLock = unlocked[cfg.Id] == nil
			local tmpMat = array.concat_new(cfg.Material, cfg.Material_circulation)
			local fullMat = array.concat(tmpMat, cfg.Material_special)
			local isWeapon = type == BreakConfig.TypeType.Battle

			if isWeapon then
				itemId = cfg.WeaponItemId or itemId
			end

			local ele = {
				itemId = itemId,
				material = fullMat,
				selected = selectedItem and cfg.Id == selectedItem.produceId or false,
				countCtl = C_CommonItemManager.CommonItemRenderCountCtl.UP,
				isLock = isLock,
				produceId = cfg.Id,
				cost = cfg.Cost,
				unique = cfg.Unique
			}

			if cfg.Unique > 0 then
				ele.isBan = gPlayerItemManager:GetPackItemNum(itemId) > 0
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

	if not isSelected and #ret > 0 then
		local ele = ret[1]

		for k, v in pairs(ele) do
			selectedItem[k] = v
		end

		ret[1].selected = true
	end

	return ret
end

function M:AskProduce(produceId, count, bias, callback)
	gClientToGameDelegate:AskItemProduce(produceId, count, bias).Callback = function (err)
		if err ~= MessageConfig.Ok then
			print_warn("ProduceManager AskProduce err:", err)

			return
		end

		if callback then
			callback()
		end
	end
end

function M:AskGetFinalProduce()
	gClientToGameDelegate:AskTakeItemProduced().Callback = function (err)
		if err ~= MessageConfig.Ok then
			print_warn("ProduceManager AskTakeItemProduced err:", err)

			return
		end
	end
end

function M:GetBreakDownTab(selectedIndex)
	local imgList = ProduceConfig.BreakdownTabImg
	local ret = {}

	for i = 1, #imgList do
		local ele = {
			id = i - 1,
			iconId = imgList[i],
			selected = i - 1 == selectedIndex
		}

		table.insert(ret, ele)
	end

	return ret
end

function M:GetBreakDownLists(type)
	local ret = {}
	local temp = {}
	local weaponTemp = {}

	for i = 0, BreakConfig.count - 1 do
		local cfg = BreakConfig.LoadAt(i)

		if cfg and cfg.Type == type then
			local rewardList, _ = gCommonItemManager:ConvertDropToFakeItem(cfg.DropId, 1)
			temp[cfg.ItemId] = {
				Reward = rewardList,
				Id = cfg.Id
			}

			if type == BreakConfig.TypeType.Battle then
				weaponTemp[cfg.WeaponItemId] = cfg.ItemId
			end
		end
	end

	if type == BreakConfig.TypeType.Battle then
		for _, weapon in pairs(gPlayerManager.infoSpirit.bindData.ArmoryWeapons) do
			local item = weapon
			local templateId = weaponTemp[item.TemplateId]

			if templateId and not table.isNilOrEmpty(temp[templateId]) then
				local weaponCfg = LTConfig.WeaponConfig.GetConfig(item.TemplateId)
				local ele = {
					count = 1,
					isWeapon = true,
					itemId = weaponCfg.Id,
					instanceId = item.InstanceId,
					reward = temp[templateId].Reward,
					itemNum = "x" .. 1,
					durability = math.floor(weapon.Durability * 100 / weaponCfg.Durability) .. "%"
				}
				self.instanceToBreakId[item.InstanceId] = temp[templateId].Id

				table.insert(ret, gCommonItemManager:GetItemRenderData(ele))
			end
		end
	else
		for i = 1, #gPlayerItemManager.packItems do
			local item = gPlayerItemManager.packItems[i]

			if not table.isNilOrEmpty(temp[item.TemplateId]) then
				local ele = {
					itemId = item.TemplateId,
					instanceId = item.UniqueId,
					reward = temp[item.TemplateId].Reward,
					itemNum = "x" .. item.Count,
					count = item.Count
				}
				self.instanceToBreakId[item.UniqueId] = temp[item.TemplateId].Id

				table.insert(ret, gCommonItemManager:GetItemRenderData(ele))
			end
		end
	end

	return ret
end

function M:AskItemBreakDown(selectedList, callback)
	local idList = {}
	local breakList = {}
	local countList = {}

	for k, v in pairs(selectedList) do
		table.insert(idList, k)
		table.insert(breakList, self.instanceToBreakId[k])
		table.insert(countList, v)
	end

	gClientToGameDelegate:AskItemBreakdown(breakList, idList, countList).Callback = function (err)
		if err ~= MessageConfig.Ok then
			print_warn("ProduceManager AskItemBreakdown err:", err)

			return
		end

		if callback then
			callback()
		end
	end
end

function M:GetPanelTabList(selectedIndex)
	local ret = {}

	for i = 1, #ProduceConfig.PanelTabName do
		local ele = {
			title = ProduceConfig.PanelTabName[i],
			selected = i == selectedIndex
		}

		table.insert(ret, ele)
	end

	return ret
end

function M:GetPanelSubTitle(tab, subTab)
	if tab == M.TAB_INDEX.Produce then
		return ProduceConfig.ProduceTabName[subTab] or ""
	elseif tab == M.TAB_INDEX.BreakDown then
		return ProduceConfig.BreakdownTabName[subTab] or ""
	end

	return ""
end

function M:OnRenderSubTabList(btn, index, data)
	local store = gStoreManager:GetStoreGroup("SynthesizeSubTabTemplateStore"):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.iconId = data.iconId
end

local TIP_STATE = {
	Lock = 1,
	Normal = 0
}

function M:RegisterMachine(machine, entity)
	self.craftMachine = machine
	self.entityInstanceId = entity

	self:StartMachine()
end

function M:SetMachineFormula(formulaId)
	if not self.craftMachine then
		return
	end

	self.produceId = formulaId
	self.craftMachine.formulaId = formulaId
end

function M:UnRegisterMachine()
	if not self.craftMachine then
		return
	end

	self.craftMachine.formulaId = 0

	self.craftMachine:ResetGame()
	self.craftMachine:ExitGame()

	self.craftMachine = nil
	self.entityInstanceId = nil

	gPanelManager:Close(gPanelId.S_SYNTHESIZE_HUD_PANEL)
	LX6.TouchNew.TouchProxy.SetForceHide(false)
end

function M:StartMachine()
	if not self.craftMachine then
		return
	end

	self.craftMachine:StartGame()
	gPanelManager:CheckShow(gPanelId.S_SYNTHESIZE_HUD_PANEL, {
		exitCb = self:CreateAction("UnRegisterMachine"),
		machine = self.craftMachine
	})
	LX6.TouchNew.TouchProxy.SetForceHide(true)
end

function M:StartGameInteraction()
	gMessageManager:SendMessage(gEventConstants.PRODUCE_INTERACTION_CHANGE, true)
end

function M:OnProduceEnd()
	if not self.entityInstanceId or not self.craftMachine then
		return
	end

	gSpoonClientMgr:TryCallInnerSignal(self.entityInstanceId, "OnProduceEnd")

	self.craftMachine.isLocked = true
	self.craftMachine.formulaId = 0

	self.craftMachine:ResetGame()
end

function M:OnProduceSelectedStart()
	if not self.entityInstanceId then
		return
	end

	gSpoonClientMgr:TryCallInnerSignal(self.entityInstanceId, "OnProduceSelectedStart")
end

function M:ReSelectStart()
	if not self.craftMachine then
		return
	end

	self.craftMachine:ReturnToSelect()
	gMessageManager:SendMessage(gEventConstants.PRODUCE_INTERACTION_CHANGE, false)
end

function M:OnCurrentProduceEnd(eventId, level)
	self.produceLevel = level

	self:OnProduceEnd()
end

function M:OnAskCurrentProduce()
	self:AskProduce(self.produceId, self.produceCount, self.produceLevel)

	self.produceLevel = #ProduceConfig.CoincidenceDegree

	if self.craftMachine then
		self.craftMachine.isLocked = false
	end
end

function M:GetMakeLevel()
	if self.craftMachine then
		return self.craftMachine.produceLevel
	end

	return 3
end

function M:SetPanelEnterCam()
	if self.craftMachine then
		self.craftMachine:SetPanelEnterCam()
	end
end

function M:GetInertiaDamping()
	local unit = ScriptBattleUnit.New(gDataSetManager.myUnit.pid)

	return Formula_cs:CalcCraftMachineInertiaDamping(unit)
end

function M:MakeProduce(produceId, count)
	if not self.craftMachine then
		return
	end

	self.produceCount = count

	self:SetMachineFormula(produceId)
	self.craftMachine:BeginProduce()
end

function M:OnSlotButtonClickDown(index)
	if self.craftMachine then
		self.craftMachine:OnSlotButtonClickDown(index)
	end
end

function M:OnSlotButtonRelease(index)
	if self.craftMachine then
		self.craftMachine:OnSlotButtonClickRelease(index)
	end
end

function M:ClickFirstButton()
	self:OnSlotButtonClickDown(0)
end

function M:ClickSecButton()
	self:OnSlotButtonClickDown(1)
end

function M:ClickTrdButton()
	self:OnSlotButtonClickDown(2)
end

function M:ClickFourButton()
	self:OnSlotButtonClickDown(3)
end

function M:ClickFirstButtonRelease()
	self:OnSlotButtonRelease(0)
end

function M:ClickSecButtonRelease()
	self:OnSlotButtonRelease(1)
end

function M:ClickTrdButtonRelease()
	self:OnSlotButtonRelease(2)
end

function M:ClickFourButtonRelease()
	self:OnSlotButtonRelease(3)
end

function M:OnMachineBeginMake()
	if self.craftMachine then
		self.craftMachine:MakeProduce()
	end
end

function M:OnMachineReset()
	if self.craftMachine then
		self.craftMachine:PlayResetBtnAni()
		self.craftMachine:ResetGame()
	end
end

gProduceManager = gProduceManager or C_ProduceManager.new()
