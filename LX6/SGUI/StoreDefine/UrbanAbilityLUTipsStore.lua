-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\UrbanAbilityLUTipsStore.lua
-- Decompiled from: 01188_UrbanAbilityLUTipsStore.lua_94623c7b6b01.luajit

C_UrbanAbilityLUTipsStore = DefClass("C_UrbanAbilityLUTipsStore", C_UrbanAbilityLUTipsStore, C_StoreGroup)
GroupName2Class.UrbanAbilityLUTipsStore = C_UrbanAbilityLUTipsStore
local M = C_UrbanAbilityLUTipsStore

M.ctor = function(self)
	self.aniNameOpen = "S_Vx_UrbanAbilityLUTips_open"
	self.aniName02 = "S_Vx_UrbanAbilityLUTips_open02"
end

M.OnAwake = function(self)
	self.bindData.gotoBtn.luaClick = self.CreateAction(self, "OnBtnClick")
end

M.OnShow = function(self, panelId, args)
	self.panelId = panelId
	self.areaIndex = args.areaIndex
	self.spiritId = args.spiritId
	self.info = args.info
	self.upLevel = args.upLevel

	self:SetData()
	self.bindData.gotoBtn:SetActive(gSystemUnlockMgr:IsUnlock(LTConfig.SystemUnlockConfig.Character))
end

M.OnEnable = function(self)
	self.InitView(self)
end

M.OnDisable = function(self)
	if self.autoCloseCo then
		coroutine.stop(self.autoCloseCo)

		self.autoCloseCo = nil
	end
end

M.InitView = function(self)
	if self.autoCloseCo then
		coroutine.stop(self.autoCloseCo)

		self.autoCloseCo = nil
	end

	self.autoCloseCo = coroutine.start(function ()
		coroutine.wait(5)
		gPanelManager:Close(self.panelId)
	end)
end

M.SetData = function(self)
	local aCfg = LTConfig.UrbanAbilityConfig.GetConfig(self.info.TemplateId)

	if not aCfg then
		return
	end

	gCS.LuaUtils.PlayAnimationByName(self.bindData.ani, self.aniNameOpen)

	local buffCfg = LTConfig.UrbanAbilityBuffConfig.GetConfig(aCfg.InitBuffId + self.upLevel - 1)
	self.bindData.title = buffCfg.Name
	self.bindData.abilityIcon = aCfg.Icon
end

M.OnClose = function(self)
end

M.OnBtnClick = function(self)
	local data = {
		tab = gUrbanAbilityManager.URBANABILITY_PAGE.ABILITY,
		urbanAbilityId = self.info.TemplateId
	}

	gPanelManager:CheckShow(gPanelId.S_URBAN_ABILITY_PANEL, data)
end
