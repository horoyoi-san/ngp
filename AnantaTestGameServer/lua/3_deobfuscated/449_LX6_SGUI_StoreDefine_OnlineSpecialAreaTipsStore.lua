C_OnlineSpecialAreaTipsStore = DefClass("C_OnlineSpecialAreaTipsStore", C_OnlineSpecialAreaTipsStore, C_StoreGroup)
GroupName2Class.OnlineSpecialAreaTipsStore = C_OnlineSpecialAreaTipsStore
local M = C_OnlineSpecialAreaTipsStore

function M:OnShow(panelId, data)
	self.panelId = panelId
	self.data = data

	if self.data.isExit then
		self.bindData.type = 1

		self:ShowCountDown()
	else
		self.bindData.type = 0
	end
end

function M:ShowCountDown()
	local time = self.data.exitDalay
	self.bindData.timer = time
	time = time - 1
	self.timer = Timer.New(function ()
		self.bindData.timer = time
		time = time - 1

		if time < 0 then
			self.timer:Stop()

			self.timer = nil
		end
	end, 1, self.data.exitDalay):Start()
end

function M:OnClose()
	if self.timer then
		self.timer:Stop()

		self.timer = nil
	end
end
