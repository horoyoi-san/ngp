-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\UniqueSkillControlsStore.lua
-- Decompiled from: 01177_UniqueSkillControlsStore.lua_e840b18683d7.luajit

local FightSpiritConfig = LTConfig.FightSpiritConfig
C_UniqueSkillControlsStore = DefClass("C_UniqueSkillControlsStore", C_UniqueSkillControlsStore, C_StoreGroup)
GroupName2Class.UniqueSkillControlsStore = C_UniqueSkillControlsStore
local M = C_UniqueSkillControlsStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.curType = -1
	self.curTypeStore = nil
	self.characterContext = {}

	self.GetAllCharacterContext(self)
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

M.OnDestroy = function(self)
	if self.curTypeStore then
		self.curTypeStore:OnClose()

		self.curTypeStore = nil
	end
end

M.OnGroupEnable = function(self)
	self.OnSpiritChange(self)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnLanguageChange = function(self, lang)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.CHANGE_MY_UNIT] = self.CreateAction(self, "OnSpiritChange")
	}

	self.RegisterMessageEvents(self, self.msgEvents)
end

M.RegisterWidget = function(self)
	self.bindData.tabRect.OnRenderTab = self.CreateAction(self, "OnTabRectRender")
end

M.OnTabRectRender = function(self, index, widget)
	self.curTypeStore = gStoreManager:GetStoreGroup(widget.Store)

	if self.curTypeStore then
		self.curTypeStore:OnShow()
	end
end

M.OnSpiritChange = function(self)
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

		if spiritId ~= 15021023 or spiritId ~= 15022089 then
			self.curType = gUniqueSkillType.Saimo
		elseif spiritId ~= FightSpiritConfig.Taffy then
			self.curType = gUniqueSkillType.TaFei
		elseif spiritId ~= 15020997 then
			self.curType = gUniqueSkillType.DiLa
		elseif spiritId ~= FightSpiritConfig.DefaultMale or spiritId ~= FightSpiritConfig.DefaultFemale then
			self.curType = gUniqueSkillType.Protagonist
		elseif spiritId ~= 15020989 then
			self.curType = gUniqueSkillType.JiaMu
		elseif spiritId ~= 15021040 then
			self.curType = gUniqueSkillType.YingLong
		end
	end

	self.bindData.tabRect.selectedIndex = self.curType

	self.RefreshCharacterContext(self, spiritId)
end

M.GetAllCharacterContext = function(self)
	for i = 0, LTConfig.InputCharacterContextConfig.count - 1 do
		local config = LTConfig.InputCharacterContextConfig.LoadAt(i)
		self.characterContext[config.FightSpiritId] = config.ContextName
	end
end

M.RefreshCharacterContext = function(self, cardId)
	local curSpiritId = cardId

	if curSpiritId and self.characterContext[curSpiritId] then
		gPanelManager:SwitchContextPart(LTConfig.InputUIContextConfig.UICoreHUD_Exploration, "Character", self.characterContext[curSpiritId] or "Def_None")
	else
		gPanelManager:SwitchContextPart(LTConfig.InputUIContextConfig.UICoreHUD_Exploration, "Character", "Def_None")
	end
end
