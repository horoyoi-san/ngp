-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\FansRewardPanelStore.lua
-- Decompiled from: 01862_FansRewardPanelStore.lua_6e2cf36397e8.luajit

C_FansRewardPanelStore = DefClass("C_FansRewardPanelStore", C_FansRewardPanelStore, C_StoreGroup)
GroupName2Class.FansRewardPanelStore = C_FansRewardPanelStore
local M = C_FansRewardPanelStore

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
	self:StartAutoClose()

	local isUpExp = args.preExp <= args.currentExp
	self.bindData.fansCount = gClientUtils.FormatWithThousandsSeparator(args.currentExp)
	self.bindData.upControl = isUpExp and 0 or 1
end

M.StartAutoClose = function(self)
	self.autoCloseCo = coroutine.start(function ()
		coroutine.wait(5.5)
		gPanelManager:Close(self.m_Id)
	end)
end

M.OnDestroy = function(self)
	self.autoCloseCo = coroutine.stop(self.autoCloseCo)
end
