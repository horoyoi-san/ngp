-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\UrbanAbilityLUExpTipsStore.lua
-- Decompiled from: 01189_UrbanAbilityLUExpTipsStore.lua_48da04251e0e.luajit

C_UrbanAbilityLUExpTipsStore = DefClass("C_UrbanAbilityLUExpTipsStore", C_UrbanAbilityLUExpTipsStore, C_StoreGroup)
GroupName2Class.UrbanAbilityLUExpTipsStore = C_UrbanAbilityLUExpTipsStore
local M = C_UrbanAbilityLUExpTipsStore

M.ctor = function(self)
end

M.OnShow = function(self, panelId, args)
	self.panelId = panelId
	self.areaIndex = args.areaIndex
	self.spiritId = args.spiritId
	self.info = args.info
	self.lastInfo = args.lastInfo

	self.InitView(self)
	self.SetData(self)
end

M.InitView = function(self)
	if self.autoCloseCo then
		coroutine.stop(self.autoCloseCo)

		self.autoCloseCo = nil
	end

	self.autoCloseCo = coroutine.start(function ()
		coroutine.wait(3)
		gPanelManager:Close(self.panelId)
	end)
end

M.SetData = function(self)
	local aCfg = LTConfig.UrbanAbilityConfig.GetConfig(self.info.TemplateId)

	if not aCfg then
		return
	end

	self.bindData.title = aCfg.Name
	self.bindData.abilityIcon = aCfg.Icon
	self.bindData.rise = " + " .. self.info.Exp - self.lastInfo.Exp
	local maxExp = gUrbanAbilityManager:GetAbilityInfoMaxExp(self.info.TemplateId)
	self.bindData.progressText = self.info.Exp .. "/" .. maxExp
end

M.OnClose = function(self)
end
