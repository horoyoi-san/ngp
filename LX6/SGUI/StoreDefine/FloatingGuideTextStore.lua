-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\FloatingGuideTextStore.lua
-- Decompiled from: 01863_FloatingGuideTextStore.lua_067808e4ff0f.luajit

C_FloatingGuideTextStore = DefClass("C_FloatingGuideTextStore", C_FloatingGuideTextStore, C_StoreGroup)
GroupName2Class.FloatingGuideTextStore = C_FloatingGuideTextStore
local M = C_FloatingGuideTextStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
end

M.OnAwake = function(self)
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
	local sg = gStoreManager:GetStoreGroup(self.rootWidget.Store)
	self.store = sg:GetStoreByWidget(self.rootWidget)
	self.guideTextStore = gStoreManager:GetStoreGroup("GuideTextBaseStore"):GetStoreByWidget(self.store.guideTextBase)
	self.guideTextDualSenseStore = gStoreManager:GetStoreGroup("GuideTextBaseStore"):GetStoreByWidget(self.store.guideTextDualSense)
	self.isDualSense = gCS.LuaUtils.GetActiveDevice() ~= SGUI.GameDevice.PlayStation

	self:SetupGuideText(data.guideTextData)
end

M.OnClose = function(self)
end

M.OnLanguageChange = function(self, lang)
	self.RefreshGuideTextList(self)
	self.RefreshGuideDualSenseText(self)
end

M.OnActiveDeviceChange = function(self, device)
	self.isDualSense = device ~= SGUI.GameDevice.PlayStation

	self:RefreshGuideTextList()
	self:RefreshGuideDualSenseText()
end

M.GenMessageEvents = function(self)
end

M.SetupGuideText = function(self, guideTextData)
	self.guideTextData = guideTextData

	self.RefreshGuideTextList(self)
	self.RefreshGuideDualSenseText(self)
end

M.RefreshGuideTextList = function(self)
	if not self.guideTextStore then
		print_error("C_FloatingGuideTextStore:RefreshGuideTextList 没有guideTextStore")

		return
	end

	self.guideTextStore.guideText = gGuideGlyph:GetGuideRichText(self.guideTextData)
end

M.RefreshGuideDualSenseText = function(self)
	if self.isDualSense then
		if not self.guideTextDualSenseStore then
			return
		end

		local id = self.guideTextData.dualSenseId

		if not id or id ~= 0 then
			self.store.dualsenseCtrl = 1

			return
		end

		self.store.dualsenseCtrl = 0
		local cfg = LTConfig.GuideGuideTextConfig.GetConfig(id)

		if not cfg then
			print_error("找不到DS手柄引导文本 in GuideGuideTextConfig:" .. id)

			return
		end

		local text = cfg.Text
		self.guideTextDualSenseStore.textComp.forceSyncLoad = true
		self.guideTextDualSenseStore.guideText = gGuideGlyph:GetRichTextByGuideStr(text)
	else
		self.store.dualsenseCtrl = 1
	end
end
