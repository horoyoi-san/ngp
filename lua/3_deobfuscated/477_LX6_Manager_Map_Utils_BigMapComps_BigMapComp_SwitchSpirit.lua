local RedDotMgr = SGUI.RedDotMgr
local SpiritBtnRedDotKey = "BigMapSpiritFilter"
BigMapComp_SwitchSpirit = BigMapComp_SwitchSpirit or {}
local M = BigMapComp_SwitchSpirit
M.__index = M

function M:OnInit()
	self.store = nil
	self.widget = nil
	self.bindData.characterTab.OnRenderTab = self.bigMap:CreateAction("OnPanelLoaded", self)
end

function M:Refresh()
	if not self:CheckLoaded() then
		if self.actived then
			self:LoadPanel()
		end

		return
	end

	if self.actived then
		self.widget:SetActive(true)
		self.bigMap:RegisterNavArea(EBigMapNavArea.SwitchSpirit, self.store.navArea)
		self.bigMap:RegisterControllerKey(EBigMapControllerKey.SwitchSpirit, self.store.controllerKey)
	else
		self.widget:SetActive(false)
		self.bigMap:UnRegisterNavArea(EBigMapNavArea.SwitchSpirit, self.store.navArea)
		self.bigMap:UnRegisterControllerKey(EBigMapControllerKey.SwitchSpirit)
	end
end

function M:CheckLoaded()
	return self.store ~= nil and self.widget ~= nil
end

function M:LoadPanel()
	self.bindData.characterTab.selectedIndex = 0
end

function M:OnPanelLoaded(index, tab)
	self.widget = tab
	self.store = gStoreManager:GetStoreGroup("BigMap_SwitchSpirit"):GetStoreByWidget(self.widget)
	self.store.list.luaSimpleRenderItem = self.bigMap:CreateAction("OnSGUIRenderCharacterItem", self)
	self.store.list.luaSimpleClick = self.bigMap:CreateAction("OnSelectSpirit", self)
	self.store.clickEntry = self.bigMap:CreateAction("OnClickEntry", self)
	self.store.clickClose = self.bigMap:CreateAction("OnClickCloseMap", self)
	self.navArea = self.store.navArea

	self.store.escCloseBtn:SetActive(false)

	function self.hideFunc()
		self:CollapseList()
	end

	self.bigMap:RegisterConflictComp("SwitchBigMapSpirit", self.hideFunc)
	self:Refresh()
	self:CollapseList()
	self.bigMap:SetFilterSpiritTid(gSpiritManager:GetCurFirstSpiritTid())
end

function M:OnActive()
	self:Refresh()
end

function M:OnInactive()
	self:Refresh()
end

function M:OnEnd()
	self.bindData.characterTab.selectedIndex = -1

	self.bindData.characterTab:ClearUnusedTabInstances()
end

function M:RecoverList()
	if not self.store then
		return
	end

	self:CollapseList()
end

function M:CollapseList()
	if self.expanded == false then
		return
	end

	self.expanded = false
	self.store.expand = 0

	self.store.escCloseBtn:SetActive(false)
	self.bigMap:SetControllerMouseHideMask(EControllerPointerHideMask.CharacterList, false)
	SGUI.UNavigationMgr.Inst:UnRegisterArea(self.navArea)

	local curSpiritId = self.bigMap.filterCharacterTid or gSpiritManager:GetCurFirstSpiritTid()

	self:InnerRenderCharacterItem(self.store.expandEntry, curSpiritId, true)
end

function M:ExpandList()
	if self.expanded then
		return
	end

	self.expanded = true
	self.store.expand = 1

	self.store.escCloseBtn:SetActive(true)
	self.bigMap:SetControllerMouseHideMask(EControllerPointerHideMask.CharacterList, true)

	SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.navArea

	self.bigMap:HideConflictComps("SwitchBigMapSpirit")

	self.renderDatas = self.renderDatas or {}

	table.clear(self.renderDatas)

	local curSpiritId = self.bigMap.filterCharacterTid or gSpiritManager:GetCurFirstSpiritTid()
	local spiritList = gUrbanAbilityManager:GetAllLingList()

	for i, v in pairs(spiritList) do
		if v.Id ~= curSpiritId then
			table.insert(self.renderDatas, {
				id = v.Id
			})
		end
	end

	self.store.list:SetSimpleList(#self.renderDatas)
	self:InnerRenderCharacterItem(self.store.collapseEntry, curSpiritId, true)
end

function M:OnClickEntry()
	self.bigMap:ClearControllerDropdownCtx()

	if self.expanded then
		self:CollapseList()
	else
		self:ExpandList()
	end
end

function M:OnClickCloseMap()
	gMapUtils:CloseBigMap()
end

function M:OnSelectSpirit(btn, index)
	index = index + 1
	local data = self.renderDatas[index]

	self.bigMap:SetFilterSpiritTid(data.id)
	self:CollapseList()
end

function M:OnSGUIRenderCharacterItem(btn, index)
	index = index + 1
	local data = self.renderDatas[index]

	self:InnerRenderCharacterItem(btn, data.id, false)
end

function M:InnerRenderCharacterItem(btn, spiritId, isEntry)
	local store = gStoreManager:GetStoreGroup("NewMapCharacterBtn"):GetStoreByWidget(btn)
	store.characterIconId = self:GetCharacterHeadIconIdById(spiritId) or 0
	store.bgColorCode = self:GetCharacterBgColorCode(spiritId) or "FFFFFF"

	if isEntry then
		self:OnRenderEntryRedDot(store)
	else
		self:OnRenderMultiRedDot(store, spiritId)
	end
end

function M:OnRenderEntryRedDot(store)
	local hasRedDot = false
	local spiritList = gUrbanAbilityManager:GetAllLingList()

	for i, v in pairs(spiritList) do
		if v.Id == gSpiritManager:GetCurFirstSpiritTid() then
			-- Nothing
		elseif gMapSubSystem_Task:IsSpiritHasRedDot(v.Id) then
			hasRedDot = true

			break
		end
	end

	store.redDotTemplateKey = "Base"
	store.redKey = SpiritBtnRedDotKey

	RedDotMgr.LuaSetRedDot(hasRedDot, SpiritBtnRedDotKey)
end

function M:OnRenderMultiRedDot(store, spiritId)
	local hasRedDot = gMapSubSystem_Task:IsSpiritHasRedDot(spiritId)
	local redKey = SpiritBtnRedDotKey .. "_" .. spiritId
	store.redKey = redKey

	if hasRedDot then
		local title = gMapSubSystem_Task:GetSpiritRedDotTitle(spiritId)
		store.redDotTemplateKey = self:GetRedDotTemplateByTitle(title)
	end

	RedDotMgr.LuaSetRedDot(hasRedDot, redKey)
end

function M:GetCharacterHeadIconIdById(id)
	local cfg = LTConfig.FightSpiritConfig.GetConfig(id)

	if not cfg then
		print_debug("FightSpiritConfig 里不存在 " .. id)

		return nil
	end

	return cfg.SHeadIconID
end

function M:GetCharacterBgColorCode(id)
	local cfg = LTConfig.FightSpiritConfig.GetConfig(id)

	if not cfg then
		print_debug("FightSpiritConfig 里不存在 " .. id)

		return nil
	end

	local color = cfg.CharListTemplateBgColor

	if string.is_null_or_empty(color) then
		print_warn("FightSpiritConfig 里不存在 " .. id .. " 的背景颜色")

		return "FFFFFF"
	end

	return color
end

function M:GetRedDotTemplateByTitle(taskTitle)
	if taskTitle == 6 then
		return "Task6"
	elseif taskTitle == 1 then
		return "Task1"
	elseif taskTitle == 2 then
		return "Task2"
	else
		print_error("@xiajingbo01 角色筛选红点遇到未知的title:" .. taskTitle)

		return "Base"
	end
end
