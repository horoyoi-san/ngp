-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\OCDialogSettingStore.lua
-- Decompiled from: 00958_OCDialogSettingStore.lua_d4043279c64b.luajit

local ChatSettingsConfig = LTConfig.OriginalCharacterChatSettingsConfig
local TemplateType = LTConfig.OriginalCharacterChatSettingsConfig.TemplateType
C_OCDialogSettingStore = DefClass("C_OCDialogSettingStore", C_OCDialogSettingStore, C_StoreGroup)
GroupName2Class.OCDialogSettingStore = C_OCDialogSettingStore
local M = C_OCDialogSettingStore

M.ctor = function(self)
	self.mgr = gOCMgr
	self.parentStore = nil
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
	self.editmodeEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.editmodeEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
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
	self.settings = self.mgr:GetChatSettings()

	self.bindData.chatSettings:SetSimpleList(#self.settings)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.exitBtn.luaClick = self.CreateAction(self, self.OnClickExitBtn)
	self.bindData.backBtn.luaClick = self.CreateAction(self, self.OnClickExitBtn)
	self.bindData.chatSettings.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderChatSettingsItem)
	self.bindData.chatSettings.luaSimpleDynamicRenderItem = self.CreateAction(self, self.OnSimpleRenderChatSettingsItem)

	self.bindData.chatSettings.onGetTIndex = function(index)
		local cfg = ChatSettingsConfig.GetConfig(self.settings[index + 1])

		return cfg.Template
	end
end

M.OnClickExitBtn = function(self)
	if self.mgr.isMeikaGrandpa then
		self.parentStore:OnClickBackBtn()

		return
	end

	self.parentStore:OnChat()
end

M.OnSimpleRenderChatSettingsItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local cfg = ChatSettingsConfig.GetConfig(self.settings[index + 1])

	if cfg and cfg.Template ~= TemplateType.selector then
		self.OnSelectorRender(self, btn, index, store)
	else
		self.OnEditBoxRender(self, btn, index, store)
	end
end

M.OnEditBoxRender = function(self, btn, index, store)
	local cfg = ChatSettingsConfig.GetConfig(self.settings[index + 1])

	if not cfg then
		return
	end

	store:Commit("nameLabel", cfg.Title, COMMIT_IMMEDIATELY)
	self.mgr:RenderInputBox(btn, self.bindData.baseNavigationArea, nil, cfg.DefalutInput)
end

M.OnSelectorRender = function(self, btn, index, store)
	local cfg = ChatSettingsConfig.GetConfig(self.settings[index + 1])

	if not cfg then
		return
	end

	store.Commit(store, "nameLabel", cfg.Title, COMMIT_IMMEDIATELY)

	local options = cfg.DataGroup

	if options and #options <= 0 then
		store.selector:SetSimpleOptions(#options)

		for i, label in ipairs(options) do
			store.selector:SetItemLabel(i - 1, label)
		end

		local curValue = self.mgr.chatSettings[cfg.DefalutInput] or ""

		for i, label in ipairs(options) do
			if label ~= curValue then
				store.selector:SelectOption(i - 1, false)

				break
			end
		end

		store.selector.luaSimpleOptionClick = function(_, selIndex)
			local action = self:CreateAction(cfg.DataSetAction, self.mgr)

			if action then
				action(options[selIndex + 1])
			end
		end
	end
end
