-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\XinShouRaidQuitPanelStore.lua
-- Decompiled from: 01246_XinShouRaidQuitPanelStore.lua_ab9c4e482277.luajit

local TextScriptTextConfig = LTConfig.TextScriptTextConfig
C_XinShouRaidQuitPanelStore = DefClass("C_XinShouRaidQuitPanelStore", C_XinShouRaidQuitPanelStore, C_StoreGroup)
GroupName2Class.XinShouRaidQuitPanelStore = C_XinShouRaidQuitPanelStore
local M = C_XinShouRaidQuitPanelStore

M.OnAwake = function(self)
	self.btnTypeRnum = {
		["tSظ\\x91\\x8c\\xda\\xe3"] = 5,
		["\\x8e\\xa9\\xbfM?\\xf36"] = 3,
		["2)\\xf0^\\x8d\\xfb \\xa1?\\xea\\xf3\\xffq\\xe9"] = 6,
		["qBlZ*3"] = 4,
		["q[Ͷ\\xb0\\x9f\\xc4\\xed"] = 1,
		["\\xb85-:K\\x98U\\xcd>\\xa4\\xbe"] = 2
	}
	self.bindData.btnList.luaSimpleClick = self:CreateAction(self.OnClickBtn)
	self.bindData.backBtn.luaClick = self:CreateAction(self.ClosePanel)
	self.actionList = {
		{
			label = LTConfig.RaidSideExitConfig.GetConfig(self.btnTypeRnum.BackToGame).Text,
			action = self:CreateAction(self.ClosePanel)
		},
		{
			label = LTConfig.RaidSideExitConfig.GetConfig(self.btnTypeRnum.GameSetting).Text,
			action = self:CreateAction(self.OnSettingBtnClick)
		}
	}

	if gLinkManager:CheckIsInRace() or gLinkManager:CheckIsInHideAndSeek() then
		table.insert(self.actionList, {
			label = LTConfig.RaidSideExitConfig.GetConfig(self.btnTypeRnum.ExitMultiplayer).Text,
			action = self.CreateAction(self, self.OnExitMultiPlayerBtnClick)
		})
	else
		table.insert(self.actionList, {
			label = LTConfig.RaidSideExitConfig.GetConfig(self.btnTypeRnum.ExitGame).Text,
			action = self:CreateAction(self.OnExitBtnClick)
		})

		if not gUIUtils:IsInXinShouRaid() then
			table.insert(self.actionList, 2, {
				label = TextScriptTextConfig.GetConfig(89901343).Text,
				action = self.CreateAction(self, self.RestartCurrentTask)
			})
			table.insert(self.actionList, 3, {
				label = TextScriptTextConfig.GetConfig(89900709).Text,
				action = self.CreateAction(self, self.GiveUpCurrentTask)
			})
		end
	end
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
end

M.OnShow = function(self, panelId, data)
	self.currentTaskId = gTaskNodeManager:GetNowDoingTask()

	self.bindData.btnList:InitSimpleList()

	for i = 1, #self.actionList do
		self.bindData.btnList:AddSimpleLabel(0, self.actionList[i].label)
	end

	self.bindData.btnList:RefreshList()
end

M.OnClose = function(self)
end

M.ClosePanel = function(self)
	gPanelManager:Close(gPanelId.XINSHOU_EXIT)
end

M.OnSettingBtnClick = function(self)
	self:ClosePanel()
	gPanelManager:CheckShow(gPanelId.S_SETTINGS_PANEL)
end

M.OnExitBtnClick = function(self)
	slot1 = gLoginManager

	slot1:OnQuitInSetting(function ()
		gPanelManager:Close(self.m_Id)
	end)
end

M.OnExitMultiPlayerBtnClick = function(self)
	self:ClosePanel()
	gLinkManager:TryExit()
end

M.RestartCurrentTask = function(self)
	self:ClosePanel()
	gTaskNodeManager:AskResetTask(self.currentTaskId)
end

M.GiveUpCurrentTask = function(self)
	self:ClosePanel()
	gTaskNodeManager:AskCancelChasing(self.currentTaskId)
end

M.OnClickBtn = function(self, btn, index)
	local data = self.actionList[index + 1]

	if data.action then
		data.action()
	end
end
