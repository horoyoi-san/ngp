-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CommonFansLevelUpPanel.lua
-- Decompiled from: 01524_CommonFansLevelUpPanel.lua_c8f4c6e2228d.luajit

C_CommonFansLevelUpPanel = DefClass("C_CommonFansLevelUpPanel", C_CommonFansLevelUpPanel, C_StoreGroup)
GroupName2Class.CommonFansLevelUpPanel = C_CommonFansLevelUpPanel
local M = C_CommonFansLevelUpPanel

M.OnAwake = function(self)
end

M.OnShow = function(self, _, args)
	self.InitModel(self, args)
	self.InitView(self, args)
end

M.InitModel = function(self, args)
	self.areaIndex = args and args.areaIndex
end

M.InitView = function(self, args)
	self.StartAutoClose(self)
	self.RefreshPanelView(self, args)
end

M.RefreshPanelView = function(self, args)
	local preExp, currentExp = nil

	if args and args.data then
		preExp = args.data.preExp
		currentExp = args.data.currentExp
	else
		preExp = args.preExp or 0
		currentExp = args.currentExp or 0
	end

	local fansLevelUp = self.bindData.fansLevelUp
	local fansLevelUpStore = gStoreManager:GetStoreGroup(fansLevelUp.Store):GetStoreByWidget(fansLevelUp)

	gClientUtils.ShowCommonScrollNumber(fansLevelUpStore.scrollNumberWidget, preExp, currentExp)
end

M.StartAutoClose = function(self)
	self.autoCloseCo = coroutine.start(function ()
		coroutine.wait(5.5)
		gPanelManager:Close(self.m_Id)
	end)
end

M.OnRenderItem = function(self, btn, _, data)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	store.number = data.number
end

M.OnDestroy = function(self)
	self.autoCloseCo = coroutine.stop(self.autoCloseCo)
end
