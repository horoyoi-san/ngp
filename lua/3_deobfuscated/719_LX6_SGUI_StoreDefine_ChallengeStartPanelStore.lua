C_ChallengeStartPanelStore = DefClass("C_ChallengeStartPanelStore", C_ChallengeStartPanelStore, C_StoreGroup)
GroupName2Class.ChallengeStartPanelStore = C_ChallengeStartPanelStore
local M = C_ChallengeStartPanelStore

function M:OnAwake()
	self.animeName = "S_Vx_ChallengeStartPanel"
	self.animeTime = 4
	self.needUpdate = false
	self.finishTime = 4
end

function M:OnShow(panelId, data)
	self.closeCallback = data and data.callBack or data.CallBack
	self.animeTime = 4
	self.finishTime = self.animeTime
	self.needUpdate = true

	gCS.LuaUtils.PlayAnimationByName(self.bindData.anime, self.animeName)
end

function M:OnUpdate()
	if self.needUpdate then
		if self.finishTime <= 0 then
			self.needUpdate = false

			gPanelManager:Close(gPanelId.S_CHALLENGE_START_PANEL)
		end

		self.finishTime = self.finishTime - Time.deltaTime
	end
end

function M:OnClose()
	if self.closeCallback then
		self:InvokeCallBack(self.closeCallback, self.needUpdate)
	end

	self.closeCallback = nil
end

function M:InvokeCallBack(cb, param)
	if type(cb) == "userdata" then
		cb:DynamicInvoke(param)
	else
		cb(param)
	end
end
