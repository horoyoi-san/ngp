-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\YanjieNew2NpcPersonalCenterPanel.lua
-- Decompiled from: 02002_YanjieNew2NpcPersonalCenterPanel.lua_f9990d7b9c93.luajit

C_YanjieNew2NpcPersonalCenterPanel = DefClass("C_YanjieNew2NpcPersonalCenterPanel", C_YanjieNew2NpcPersonalCenterPanel, C_PhoneAppBaseStoreGroup)
GroupName2Class.YanjieNew2NpcPersonalCenterPanel = C_YanjieNew2NpcPersonalCenterPanel
local M = C_YanjieNew2NpcPersonalCenterPanel

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
	self.hasFollowCtrlEnum = {
		["MHxOA/"] = 1,
		["G\\x9d\\x82\\x8cV"] = 0
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.hasFollowCtrlEnum = nil
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
	self.ClearMessageEvents(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
end

M.InitModel = function(self, args)
	M.base.InitModel(self, args)

	self.data = args.data
end

M.InitView = function(self, args)
	M.base.InitView(self, args)
	self.RefreshAvatarView(self)
	self.RefreshListView(self)
end

M.RefreshAvatarView = function(self)
	local avatarWidget = self.bindData.avatar
	local playerAvatarStore = gStoreManager:GetStoreGroup(avatarWidget.Store):GetStoreByWidget(avatarWidget)
	playerAvatarStore.headIcon = gSocialNetworkUtils.GetSGuiAvatarId(self.data.roleInfo)
	self.bindData.name = gSocialNetworkUtils.GetRoleName(self.data.roleInfo)
	self.bindData.hasFollowCtrl = self.data.roleInfo.isFollow and 0 or 1
end

M.RefreshListView = function(self)
	self.followList = self.SubGroup.CommonNewYanjieListTemplateStore
	self.followList.hideAvatarHeadButton = true

	self.followList.GetList = function()
		local tuiteCfg = LTConfig.TuiteConfig.GetConfig(self.data.id)

		if tuiteCfg then
			return gSocialNetworkUtils.GetTuiteListByPubisher(tuiteCfg.Publisher)
		else
			return {
				list = {}
			}
		end
	end

	self.followList:StartRequest()
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.GetMessageEvents = function(self)
	return {
		[gEventConstants.ON_REQUEST_SOCIAL_NETWORK_FOLLOW] = self.CreateAction(self, "OnFollowStateChange")
	}
end

M.RegisterWidget = function(self)
	self.bindData.exitButton.luaClick = self.CreateAction(self, self.OnExitClick)
	self.bindData.fullScreenButton.luaClick = self.CreateAction(self, self.OnExitClick)
	self.bindData.followButton.luaClick = self.CreateAction(self, self.OnFollowClick)
end

M.OnFollowClick = function(self)
	gSocialNetworkUtils.FollowRole(self.data)
end

M.OnExecuteExitAction = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_YANJIE_CONTENT_CLOSE)
end

M.OnFollowStateChange = function(self, _, args)
	self.data.roleInfo.isFollow = args.isFollow

	self.RefreshAvatarView(self)
end
