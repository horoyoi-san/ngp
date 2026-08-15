local LinkInteractionConfig = LTConfig.LinkInteractionConfig
local LinkConfig = LTConfig.LinkConfig
C_WatchingGameInteractionStore = DefClass("C_WatchingGameInteractionStore", C_WatchingGameInteractionStore, C_StoreGroup)
GroupName2Class.WatchingGameInteractionStore = C_WatchingGameInteractionStore
local M = C_WatchingGameInteractionStore

function M:OnAwake()
	self.TYPE = {
		ShowInteraction = 1,
		Response = 2,
		HideBtn = 3,
		None = 0
	}
	self.bindData.respond = self:CreateAction("OnRespondBtnClick")
	self.bindData.shield = self:CreateAction("OnShieldBtnClick")
	self.maskList = {}
end

function M:SetData(data)
	if data.isResponse and data.isSource then
		self.bindData.showInteraction = 0

		return
	end

	if self.maskList[data.pid] then
		return
	end

	self.data = data

	self:HideInteraction()

	local cfg = LinkInteractionConfig.GetConfig(data.type)

	if data.isResponse then
		self.bindData.showInteraction = self.TYPE.Response
		self.bindData.respondIcon = cfg.Icon
	else
		if data.isSource then
			self.bindData.showInteraction = self.TYPE.HideBtn
		else
			self.bindData.showInteraction = self.TYPE.ShowInteraction
		end

		if data.context == "" then
			self.bindData.msg = LTConfig.TextCommonTextConfig.GetConfig(tonumber(cfg.Text)).Text
		else
			self.bindData.msg = data.context
		end

		self.bindData.playerName = data.name
		self.bindData.icon = cfg.Icon
	end
end

function M:HideInteraction()
	if self.waitTimer then
		self.waitTimer:Stop()

		self.waitTimer = nil
	end

	self.waitTimer = Timer.New(function ()
		self.bindData.showInteraction = 0
		self.waitTimer = nil
	end, LinkConfig.LinkInteractionPopupShowTime):Start()
end

function M:OnRespondBtnClick()
	if self.data.isSource or self.data.isResponse then
		return
	end

	gClientToGameDelegate:AskSendInteractionInfo(self.data.pid, self.data.type, true).Callback = function (err, data)
		if err ~= LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
		end
	end
end

function M:OnShieldBtnClick()
	self.maskList[self.data.pid] = true
end
