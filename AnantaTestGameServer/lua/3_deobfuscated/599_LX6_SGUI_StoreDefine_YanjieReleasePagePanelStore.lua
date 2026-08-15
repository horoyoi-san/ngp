C_YanjieReleasePagePanelStore = DefClass("C_YanjieReleasePagePanelStore", C_YanjieReleasePagePanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.YanjieReleasePagePanelStore = C_YanjieReleasePagePanelStore
local M = C_YanjieReleasePagePanelStore

function M:OnAwake()
	self.bindData.fullScreenButton.luaClick = self:CreateAction(self.OnExitClick)
	self.bindData.exitButton.luaClick = self:CreateAction(self.OnExitClick)
	self.bindData.sendButton.luaClick = self:CreateAction(self.OnSendClick)
end

function M:InitModel(args)
	M.base.InitModel(self, args)

	self.id = args.id

	gYanJieReleaseManager:Add(args)
end

function M:InitView(args)
	M.base.InitView(self, args)

	local tuiteCfg = LTConfig.TuiteConfig.GetConfig(self.id)
	self.bindData.content = tuiteCfg.Txt
end

function M:OnSendClick()
	gClientToGameDelegate:AskPublishTuite(self.id).Callback = function (err)
		if err ~= LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		gYanJieReleaseManager:Remove(self.id)
		gMessageManager:SendMessage(gEventConstants.ON_YANJIE_CONTENT_CLOSE)
	end
end

function M:ClearData()
	self.id = nil

	gYanJieReleaseManager:ExecuteCheckQueue()
end

function M:OnExecuteExitAction()
	return
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end
