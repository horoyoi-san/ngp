-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\YanjieReleasePagePanelStore.lua
-- Decompiled from: 01919_YanjieReleasePagePanelStore.lua_6918c73fc56e.luajit

C_YanjieReleasePagePanelStore = DefClass("C_YanjieReleasePagePanelStore", C_YanjieReleasePagePanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.YanjieReleasePagePanelStore = C_YanjieReleasePagePanelStore
local M = C_YanjieReleasePagePanelStore

M.OnAwake = function(self)
	self.bindData.fullScreenButton.luaClick = self.CreateAction(self, self.OnExitClick)
	self.bindData.exitButton.luaClick = self.CreateAction(self, self.OnExitClick)
	self.bindData.sendButton.luaClick = self.CreateAction(self, self.OnSendClick)
end

M.InitModel = function(self, args)
	M.base.InitModel(self, args)

	self.id = args.id

	gYanJieReleaseManager:Add(args)
end

M.InitView = function(self, args)
	M.base.InitView(self, args)

	local tuiteCfg = LTConfig.TuiteConfig.GetConfig(self.id)
	self.bindData.content = tuiteCfg.Txt
end

M.OnSendClick = function(self)
	slot1 = gClientToGameDelegate

	slot1:AskPublishTuite(self.id).Callback = function (err)
		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		gYanJieReleaseManager:Remove(self.id)
		gMessageManager:SendMessage(gEventConstants.ON_YANJIE_CONTENT_CLOSE)
	end
end

M.ClearData = function(self)
	self.id = nil

	gYanJieReleaseManager:ExecuteCheckQueue()
end

M.OnExecuteExitAction = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end
