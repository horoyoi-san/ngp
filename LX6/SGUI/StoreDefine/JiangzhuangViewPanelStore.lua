-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\JiangzhuangViewPanelStore.lua
-- Decompiled from: 01769_JiangzhuangViewPanelStore.lua_a2df4472506d.luajit

C_JiangzhuangViewPanelStore = DefClass("C_JiangzhuangViewPanelStore", C_JiangzhuangViewPanelStore, C_StoreGroup)
GroupName2Class.JiangzhuangViewPanelStore = C_JiangzhuangViewPanelStore
local M = C_JiangzhuangViewPanelStore
local FADE_IN_TIME = 0.3
local FADE_OUT_TIME = 0.3
local FADE_OPEN_STAY_TIME = 0.1

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
	if self.isClosing then
		gBlackScreenManager:ClearTransition(gPanelId.CHECK_JIANGZHUANG, true)
	end

	gClientUtils.SetCameraRotateEnabled(true, gPanelId.CHECK_JIANGZHUANG)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	self.bindData.typeCtrl = 2
	self.list = self:BuildList(data and data.fileGroupId)
	self.curIndex = 1

	self:ShowSpecific()
	gClientUtils.SetCameraRotateEnabled(false, gPanelId.CHECK_JIANGZHUANG)
	gBlackScreenManager:AutoTransition(gPanelId.CHECK_JIANGZHUANG, "", false, false, 0, FADE_OPEN_STAY_TIME, FADE_OUT_TIME, nil, , )
end

M.OnClose = function(self)
	gClientUtils.SetCameraRotateEnabled(true, gPanelId.CHECK_JIANGZHUANG)

	self.list = nil
end

M.OnActiveDeviceChange = function(self, device)
end

M.RegisterWidget = function(self)
	self.bindData.leftBtn.luaClick = self.CreateActionWithArgs(self, "OnClickNav", -1)
	self.bindData.rightBtn.luaClick = self.CreateActionWithArgs(self, "OnClickNav", 1)
	self.bindData.backBtn.luaClick = self.CreateAction(self, "OnClickBack")
	self.bindData.backBtnMobile.luaClick = self.CreateAction(self, "OnClickBack")
end

M.BuildList = function(self, fileGroupId)
	local list = {}
	fileGroupId = fileGroupId or 2
	local groupCfg = LTConfig.HouseInteractionFileViewGroupConfig.GetConfig(fileGroupId)

	if groupCfg and groupCfg.FileViewIds then
		for _, fileViewId in ipairs(groupCfg.FileViewIds) do
			local cfg = LTConfig.HouseInteractionFileViewConfig.GetConfig(fileViewId)
			local statsCtrl = 0

			if cfg and cfg.PanelTemplateId ~= 2 then
				statsCtrl = 1
			end

			table.insert(list, {
				cfgId = fileViewId,
				statsCtrl = statsCtrl
			})
		end
	end

	return list
end

M.ShowSpecific = function(self)
	local entry = self.list and self.list[self.curIndex]

	if not entry then
		return
	end

	local cfg = LTConfig.HouseInteractionFileViewConfig.GetConfig(entry.cfgId)
	self.bindData.statsCtrl = entry.statsCtrl
	self.bindData.bgIconId = cfg and cfg.BgImage or 0
	self.bindData.playerName = cfg and cfg.Text or ""
end

M.OnClickNav = function(self, dir)
	local total = self.list and #self.list or 0

	if total < 1 then
		return
	end

	self.curIndex = self.curIndex + dir

	if self.curIndex >= 1 then
		self.curIndex = total
	elseif total >= self.curIndex then
		self.curIndex = 1
	end

	self.ShowSpecific(self)
end

M.OnClickBack = function(self)
	if self.isClosing then
		return
	end

	self.isClosing = true
	slot1 = gBlackScreenManager

	slot1:AutoTransition(gPanelId.CHECK_JIANGZHUANG, "", false, false, FADE_IN_TIME, 0, FADE_OUT_TIME, nil, function ()
		self.isClosing = nil

		gPanelManager:Close(gPanelId.CHECK_JIANGZHUANG)
	end, nil)
end
