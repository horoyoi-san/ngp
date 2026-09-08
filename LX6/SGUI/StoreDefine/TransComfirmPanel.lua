-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\TransComfirmPanel.lua
-- Decompiled from: 01170_TransComfirmPanel.lua_0eeedea8e88a.luajit

local HouseConfig = LTConfig.HouseConfig
C_TransComfirmPanel = DefClass("C_TransComfirmPanel", C_TransComfirmPanel, C_StoreGroup)
GroupName2Class.TransComfirmPanel = C_TransComfirmPanel
local M = C_TransComfirmPanel

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.oldSpiritId = nil
	self.newSpiritId = nil
	self.msgEvents = {
		[gEventConstants.CHANGE_MY_UNIT_FINISH_LOAD] = function ()
			gCS.GuiUtils.CloseAllFrontUIWithoutTag(nil)
			gHomeInteractionManager:ForcePlayLay()
		end
	}
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

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	if data and data.maleToFemale then
		self.bindData.maleIcon = HouseConfig.SexTransitionMaleIcon
		self.bindData.femaleIcon = HouseConfig.SexTransitionFemaleIcon
	else
		self.bindData.maleIcon = HouseConfig.SexTransitionFemaleIcon
		self.bindData.femaleIcon = HouseConfig.SexTransitionMaleIcon
	end

	self.oldSpiritId = data.maleToFemale and LTConfig.FightSpiritConfig.DefaultMale or LTConfig.FightSpiritConfig.DefaultFemale
	self.newSpiritId = data.maleToFemale and LTConfig.FightSpiritConfig.DefaultFemale or LTConfig.FightSpiritConfig.DefaultMale
	self.bindData.titleText = data.titleText
	self.bindData.explainText = data.explainText
	self.bindData.warningText = data.warningText
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.CancelTransBtn.luaClick = self.CreateAction(self, self.OnClickCancelTransBtn)
	self.bindData.ConfirmTransBtn.luaClick = self.CreateAction(self, self.OnClickConfirmTransBtn)
end

M.OnClickCancelTransBtn = function(self)
	gPanelManager:Close(self.m_Id)
end

M.OnClickConfirmTransBtn = function(self)
	slot1 = L50.L50App.L50Game.CutsceneManager

	slot1:ChangePlayerGender()

	slot1 = gBlackScreenManager

	slot1:OpenTransition(gBlackScreenId.TRANS_SEX, "", false, false, 0, -1, -1, 0)

	slot1 = gClientToGameDelegate

	slot1:AskSpiritSexTransition().Callback = function (err)
		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end
	end
end
