local FightSpiritConfig = LTConfig.FightSpiritConfig
C_UniqueSkillControlsStore = DefClass("C_UniqueSkillControlsStore", C_UniqueSkillControlsStore, C_StoreGroup)
GroupName2Class.UniqueSkillControlsStore = C_UniqueSkillControlsStore
local M = C_UniqueSkillControlsStore

function M:ctor()
	return
end

function M:DefineAllVariables()
	self.curType = -1
	self.curTypeStore = nil
	self.characterContext = {}

	self:GetAllCharacterContext()
end

function M:DefineAllEnumsAutoGen()
	return
end

function M:ClearAllEnumsAutoGen()
	return
end

function M:OnAwake()
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()
end

function M:OnDestroy()
	self.curTypeStore = nil
end

function M:OnGroupEnable()
	self:OnSpiritChange()
end

function M:OnGroupDisable()
	self:ClearMessageEvents()
end

function M:GenMessageEvents()
	self.msgEvents = {
		[gEventConstants.CHANGE_MY_UNIT] = self:CreateAction("OnSpiritChange")
	}

	self:RegisterMessageEvents(self.msgEvents)
end

function M:RegisterWidget()
	self.bindData.tabRect.OnRenderTab = self:CreateAction("OnTabRectRender")
end

function M:OnTabRectRender(index, widget)
	self.curTypeStore = gStoreManager:GetStoreGroup(widget.Store)

	if self.curTypeStore then
		self.curTypeStore:OnShow()
	end
end

function M:OnSpiritChange()
	if not self.STATE_EnableOnce then
		return
	end

	if self.curTypeStore then
		self.curTypeStore:OnClose()

		self.curTypeStore = nil
	end

	self.curType = -1
	local spiritId = nil

	if gCS.MyPlayerManager.PlayerUnit then
		spiritId = gSpiritManager:GetCurFirstSpiritTid()

		if spiritId == 15021023 then
			self.curType = gUniqueSkillType.Saimo
		elseif spiritId == FightSpiritConfig.Taffy then
			self.curType = gUniqueSkillType.TaFei
		elseif spiritId == 15020997 then
			self.curType = gUniqueSkillType.DiLa
		elseif spiritId == FightSpiritConfig.DefaultMale or spiritId == FightSpiritConfig.DefaultFemale then
			self.curType = gUniqueSkillType.Protagonist
		elseif spiritId == 15020989 then
			self.curType = gUniqueSkillType.JiaMu
		end
	end

	self.bindData.tabRect.selectedIndex = self.curType

	self:RefreshCharacterContext(spiritId)
end

function M:GetAllCharacterContext()
	for i = 0, LTConfig.InputCharacterContextConfig.count - 1 do
		local config = LTConfig.InputCharacterContextConfig.LoadAt(i)
		self.characterContext[config.FightSpiritId] = config.ContextName
	end
end

function M:RefreshCharacterContext(cardId)
	local curSpiritId = cardId

	if curSpiritId and self.characterContext[curSpiritId] then
		gPanelManager:SwitchContextPart(LTConfig.InputUIContextConfig.UICoreHUD_Exploration, "Character", self.characterContext[curSpiritId] or "Def_None")
	else
		gPanelManager:SwitchContextPart(LTConfig.InputUIContextConfig.UICoreHUD_Exploration, "Character", "Def_None")
	end
end
