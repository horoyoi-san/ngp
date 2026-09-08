-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\SocialChatBubbleSelectPanelStore.lua
-- Decompiled from: 01332_SocialChatBubbleSelectPanelStore.lua_83a1cc9203c9.luajit

C_SocialChatBubbleSelectPanelStore = DefClass("C_SocialChatBubbleSelectPanelStore", C_SocialChatBubbleSelectPanelStore, C_StoreGroup)
GroupName2Class.SocialChatBubbleSelectPanelStore = C_SocialChatBubbleSelectPanelStore
local M = C_SocialChatBubbleSelectPanelStore
M.BubbleStatus = {
	["\\xfa\\xce*\\xe5"] = 1,
	["0G\\x92\\x85\\x86E"] = 2,
	["\\xab=-:T\\x94L\\xd0#\\xaf\\xbd"] = 1,
	["2G\\x83\\x83\\x82M"] = 0
}

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, "OnBubbleListRenderItem")
	self.bindData.list.luaSimpleClick = self.CreateAction(self, "OnBubbleListItemClick")
	self.bindData.btnSave.luaClick = self.CreateAction(self, "OnClickSave")
end

M.SetData = function(self, args)
	self.args = args
	self.bubbles = gSocialChatManager:GetChatBubbles()
	self.previewBubble = gSocialChatManager:GetCurrentlyUsingBubble()

	self:Render()
end

M.OnBubbleInfoRefresh = function(self)
	self.bubbles = gSocialChatManager:GetChatBubbles()
	self.previewBubble = gSocialChatManager:GetCurrentlyUsingBubble()

	self:Render()
end

M.Render = function(self)
	self.RenderPreview(self)
	self.RenderBubbleList(self)
end

M.RenderPreview = function(self)
	self.bindData.userInfo.pid = gPlayerManager.infoLogin.bindData.pid

	if self.previewBubble and self.previewBubble.bg then
		self.RenderBubbleInfo(self, self.bindData, self.previewBubble)
	else
		self.bindData.name.text = ""
		self.bindData.getDesc.text = ""
		self.bindData.bubbleStatus = self.BubbleStatus.Normal
	end
end

M.RenderBubbleList = function(self)
	self.bindData.list:SetSimpleList(#self.bubbles)
end

M.OnBubbleListRenderItem = function(self, btn, index)
	local bubbleInfo = self.bubbles[index + 1]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store or not bubbleInfo then
		return
	end

	self.RenderBubbleInfo(self, store, bubbleInfo)
end

M.RenderBubbleInfo = function(self, store, bubbleInfo)
	store.Commit(store, "currBubble", bubbleInfo.bg)

	if store.name then
		store.name.text = bubbleInfo.name
	end

	if store.getDesc then
		store.getDesc.text = bubbleInfo.desc
	end

	if not bubbleInfo.unlocked then
		store.bubbleStatus = self.BubbleStatus.Locked
		store.status = self.BubbleStatus.Locked
	elseif bubbleInfo.timeLimit and bubbleInfo.timeLimit <= 0 then
		store.bubbleStatus = self.BubbleStatus.TimeLimited
		store.tag = self.BubbleStatus.TimeLimited
	else
		store.bubbleStatus = self.BubbleStatus.Normal
		slot3 = self.previewBubble and bubbleInfo.id ~= self.previewBubble.id and self.BubbleStatus.Current or self.BubbleStatus.Normal
		store.status = slot3
	end
end

M.OnBubbleListItemClick = function(self, btn, index)
	local bubbleInfo = self.bubbles[index + 1]

	if bubbleInfo then
		self.previewBubble = bubbleInfo

		self.RenderPreview(self)
	end
end

M.OnClickSave = function(self)
	if self.previewBubble then
		slot1 = gSocialChatManager

		slot1:ChangeUsingBubble(self.previewBubble.id, function (bOk)
			if bOk then
				local store = gStoreManager:GetStoreGroup("SocialChatHomePanelStore")

				if store then
					store:OpenHomePage()
				end
			end
		end)
	end
end

M.OnEnable = function(self)
	local msgEvents = {
		[gEventConstants.SOCIAL_CHAT_BUBBLE_INFO_CHANGED] = self.CreateAction(self, "OnBubbleInfoRefresh")
	}

	self.RegisterMessageEvents(self, msgEvents)
end

M.OnDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnActiveDeviceChange = function(self, device)
end
