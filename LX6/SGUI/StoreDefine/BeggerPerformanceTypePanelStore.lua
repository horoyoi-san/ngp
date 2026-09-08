-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BeggerPerformanceTypePanelStore.lua
-- Decompiled from: 02047_BeggerPerformanceTypePanelStore.lua_6460c736fd88.luajit

C_BeggerPerformanceTypePanelStore = DefClass("C_BeggerPerformanceTypePanelStore", C_BeggerPerformanceTypePanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.BeggerPerformanceTypePanelStore = C_BeggerPerformanceTypePanelStore
local M = C_BeggerPerformanceTypePanelStore
local BeggarTypeConfig = LTConfig.BeggarTypeConfig

M.DefineAllVariables = function(self)
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.RegisterWidget(self)
end

M.InitModel = function(self, args)
	M.base.InitModel(self, args)
end

M.InitView = function(self, args)
	M.base.InitView(self, args)
	self.RefreshPanelView(self)
end

M.OnExecuteExitAction = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_BEGGAR_APP_CONTENT_CLOSE)
end

M.RegisterWidget = function(self)
	self.bindData.backBtn.luaClick = self.CreateAction(self, self.OnExitClick)
	self.bindData.typeList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderTypeListItem")
	self.bindData.typeList.luaSimpleClick = self.CreateAction(self, "OnSimpleClickTypeList")
end

M.OnSimpleRenderTypeListItem = function(self, btn, index)
	local data = self.typeData[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local cfg = BeggarTypeConfig.GetConfig(data)

	if cfg then
		store.title = cfg.Name
		store.icon = cfg.Icon
	end
end

M.OnSimpleClickTypeList = function(self, btn, index)
	local data = self.typeData[index + 1]

	if not data then
		return
	end

	gMessageManager:SendMessage(gEventConstants.ON_BEGGAR_APP_CONTENT_SHOW, {
		secondShowType = gClientConst.BEGGAR_APP_SHOW_TYPE.STYLE,
		typeId = data
	})
end

M.RefreshPanelView = function(self)
	self.typeData = gBeggarManager:GetBeggarTypeInfo()

	self.bindData.typeList:SetSimpleList(#self.typeData)

	local currentJobInfo, levelCfg, cfg = gBeggarManager:GetBeggarJobInfo()

	if currentJobInfo then
		self.bindData.showLevelCtrl = 1
		local progress = currentJobInfo.Exp / levelCfg.Exp

		self.bindData.levelProgress:ProgressToValue(progress)

		local level = levelCfg and levelCfg.Level or 1
		self.bindData.level = string.format("Lv.%d", level or 1)
		self.bindData.curExp = currentJobInfo.Exp
		self.bindData.maxExp = levelCfg.Exp
	else
		self.bindData.showLevelCtrl = 0
	end
end

M.ClearData = function(self)
	if not gBeggarManager.isInBeggar then
		LX6.GUI.GuiMgr.Instance:SetDisableJoystick(false, gBanId.Beggar)
	end

	gBeggarManager:CheckNeedEndBeggar()
end
