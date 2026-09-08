-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BubbleFilmPanelStore.lua
-- Decompiled from: 02010_BubbleFilmPanelStore.lua_fb6ee8e70881.luajit

local AnimMgr = SGUI.AnimMgr
local SocialMediaConfig = LTConfig.SocialMediaConfig
C_BubbleFilmPanelStore = DefClass("C_BubbleFilmPanelStore", C_BubbleFilmPanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.BubbleFilmPanelStore = C_BubbleFilmPanelStore
local M = C_BubbleFilmPanelStore
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}

M.ctor = function(self, name, id, isSub)
	self.data = {}
	self.nowEmojiId = 0
	self.nowEmojiCount = 0
	self.emojiUseList = {}
	self.showEmojiList = {}
	self.lastPlayCountDown = 0
end

M.OnAwake = function(self)
	self.mgr = gNewBubbleMgr
	self.bindData.emojiBtn.luaClick = self.CreateAction(self, "OnEmojiBtnClick")
	self.bindData.emojiBackBtn.luaClick = self.CreateAction(self, "OnEmojiBtnClick")
	self.bindData.emojiShowList.luaRenderItem = self.CreateAction(self, "OnRenderEmojiEffectItem")

	self.bindData.emojiShowList.onGetTIndex = function(_)
		return 0
	end

	self.bindData.emojiList.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderEmojiItem)
	self.preTime = 0
	self.emojiList = {}
end

M.OnDestroy = function(self)
end

M.OnStart = function(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.InitView = function(self, data)
	self.emojiUseList = {}

	if data and data.postId then
		self.bindData.showEmoji = 0

		self.RefreshPage(self, data.postId)
	end
end

M.OnClose = function(self)
	self.OnEmojiBtnClickEnd(self)

	self.isShow = false

	if not table.isNilOrEmpty(self.emojiUseList) then
		local postList = {}

		for k, v in pairs(self.emojiUseList) do
			table.insert(postList, {
				Id = k,
				Count = v
			})
		end

		self.mgr:AskMomentsTapPost(self.data.Id, postList)
	end
end

M.OnBackBtnClick = function(self, isForce)
	if not self.STATE_EnableOnce then
		return
	end

	local scheme = gCS.LuaUtils.GetActiveDevice()

	if not isForce and SGUI.GameDevice.KeyboardMouse >= scheme and self.bindData.showEmoji ~= 1 then
		self.bindData.showEmoji = 0

		return
	end

	self.mgr:ExitCurrentPanel()
end

M.OnEmojiBtnClick = function(self)
	self.bindData.showEmoji = self.bindData.showEmoji ~= 1 and 0 or 1

	if self.bindData.showEmoji ~= 1 then
		FrameTimer.New(function ()
			self.bindData.emojiList:SetNavSelectToTop()
		end, 1):Start()
	end
end

M.OnUpdate = function(self)
	if self.isShow then
		if self.lastPlayCountDown == 0 and Time.time - self.lastPlayCountDown <= 2 then
			self.bindData.showCount = ""
		end

		self.OnEmojiRefreshTick(self)
	end
end

M.OnRenderEmojiEffectItem = function(self, btn, index)
	local store = self.GetStoreByWidget(self, btn)

	if not store then
		return
	end

	store.iconId = self.nowEmojiId

	btn.SetActive(btn, false)

	self.emojiStore[index + 1] = btn
end

M.PlayAni = function(self, index)
	if not self.emojiStore[index] then
		return
	end

	local btn = self.emojiStore[index]

	btn.SetActive(btn, true)

	btn.renderOpacity = btn.originRenderOpacity

	AnimMgr.DoAlpha(btn, "BubbleFilmEmojiShowAni", 0, SocialMediaConfig.EmojiShowTime, 0)

	local showX = math.random(SocialMediaConfig.EmojiShowDeltaX[1], SocialMediaConfig.EmojiShowDeltaX[2])
	local showY = math.random(SocialMediaConfig.EmojiShowDeltaY[1], SocialMediaConfig.EmojiShowDeltaY[2])
	local target = Vector3.New(showX, showY, 0)
	btn.localPosition = Vector3.zero

	AnimMgr.Move(btn.rectTransform, "BubbleFilmEmojiShowAni", target, SocialMediaConfig.EmojiShowTime, 0, DG.Tweening.Ease.OutQuad, nil)
end

M.OnRenderEmojiItem = function(self, btn, index)
	local store = self.GetStoreByWidget(self, btn)

	if not store then
		return
	end

	local data = self.emojiList[index + 1]
	store.iconId = data.iconId
	btn.luaBeginLongPress = self.CreateActionWithArgs(self, "OnEmojiBtnClickBegin", data)
	btn.luaEndLongPress = self.CreateAction(self, "OnEmojiBtnClickEnd")
end

M.OnEmojiBtnClickBegin = function(self, data)
	self.nowEmojiCount = 0
	self.nowEmojiId = data.iconId

	self.InitEmoji(self)
	self.OnEmojiRefreshTick(self)
end

M.OnEmojiBtnClickEnd = function(self)
	if self.nowEmojiId ~= 0 then
		return
	end

	self.emojiUseList[self.nowEmojiId] = (self.emojiUseList[self.nowEmojiId] or 0) + self.nowEmojiCount
	self.nowEmojiId = 0
end

M.OnEmojiRefreshTick = function(self)
	if self.nowEmojiId ~= 0 or Time.unscaledTime < self.preTime + SocialMediaConfig.EmojiPressTime then
		return
	end

	self.preTime = Time.unscaledTime
	self.nowEmojiCount = self.nowEmojiCount + 1
	self.bindData.showCount = "X" .. self.nowEmojiCount

	self.bindData.countAni:Play()

	self.lastPlayCountDown = Time.time

	self:PlayAni(self.nowEmojiCount % SocialMediaConfig.EmojiShowCount + 1)
end

M.GetEmojiList = function(self)
	local emojiList = {}

	for i = 1, #SocialMediaConfig.EmojiList do
		local ele = {
			iconId = SocialMediaConfig.EmojiList[i]
		}

		table.insert(emojiList, ele)
	end

	return emojiList
end

M.RefreshPage = function(self, pid)
	self.isShow = true
	local data = self.mgr.postDict[pid]

	if table.isNilOrEmpty(data) then
		return
	end

	self.data = data
	local isVideo, imageUrl = self.mgr:CheckIsVideo(pid)

	self.mgr:OnRenderBubbleCommonAvatar(self.bindData.headAvatar, 0, self.mgr:GetPostPublisher(pid))

	self.bindData.dateLabel = self.mgr:GetInfoTime(gCS.TimeManager.ServerUnixTime - self.data.Date)
	self.bindData.showCount = ""
	self.emojiList = self:GetEmojiList()

	self.bindData.emojiList:SetSimpleList(#self.emojiList)

	self.bindData.isVideo = BOOL2CTL[isVideo]

	if isVideo then
		self.bindData.CCPlayer:Init()
		self.bindData.CCPlayer:PlayVideoUrl(imageUrl, false, nil, )
	else
		self.bindData.url = imageUrl
	end
end

M.InitEmoji = function(self)
	self.emojiStore = {}

	self.bindData.emojiShowList:SetList(SocialMediaConfig.EmojiShowCount)
end
