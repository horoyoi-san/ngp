local AnimMgr = SGUI.AnimMgr
local SocialMediaConfig = LTConfig.SocialMediaConfig
C_BubbleFilmPanelStore = DefClass("C_BubbleFilmPanelStore", C_BubbleFilmPanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.BubbleFilmPanelStore = C_BubbleFilmPanelStore
local M = C_BubbleFilmPanelStore
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}

function M:ctor(name, id, isSub)
	self.data = {}
	self.timer = 0
	self.currentTime = 0
	self.nowEmojiId = 0
	self.nowEmojiCount = 0
	self.emojiUseList = {}
	self.showEmojiList = {}
	self.lastPlayCountDown = 0
end

function M:OnAwake()
	self.mgr = gNewBubbleMgr
	self.bindData.emojiBtn.luaClick = self:CreateAction("OnEmojiBtnClick")
	self.bindData.emojiBackBtn.luaClick = self:CreateAction("OnEmojiBtnClick")
	self.bindData.emojiShowList.luaRenderItem = self:CreateAction("OnRenderEmojiEffectItem")

	function self.bindData.emojiShowList.onGetTIndex(_)
		return 0
	end

	self.bindData.emojiList.luaSimpleRenderItem = self:CreateAction(self.OnRenderEmojiItem)
	self.preTime = 0
	self.emojiList = {}
end

function M:OnDestroy()
	return
end

function M:OnStart()
	return
end

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	return
end

function M:InitView(data)
	self.emojiUseList = {}

	if data and data.postId then
		self.bindData.showEmoji = 0

		self:RefreshPage(data.postId)
	end
end

function M:OnClose()
	self:OnEmojiBtnClickEnd()

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

function M:OnBackBtnClick(isForce)
	if not self.STATE_EnableOnce then
		return
	end

	local scheme = gCS.LuaUtils.GetActiveDevice()

	if not isForce and SGUI.GameDevice.KeyboardMouse < scheme and self.bindData.showEmoji == 1 then
		self.bindData.showEmoji = 0

		return
	end

	self.mgr:ExitCurrentPanel()
end

function M:OnEmojiBtnClick()
	self.bindData.showEmoji = self.bindData.showEmoji == 1 and 0 or 1

	if self.bindData.showEmoji == 1 then
		FrameTimer.New(function ()
			self.bindData.emojiList:SetNavSelectToTop()
		end, 1):Start()
	end
end

function M:OnHeadBtnClick()
	if self.data and self.data.publishId then
		self.mgr:OpenNpcBubblePanel(self.data.publishId)
	end
end

function M:OnUpdate()
	if self.isShow then
		if self.bindData.showEmoji == 0 and self.timer ~= 0 and self.currentTime < self.timer then
			self.currentTime = self.currentTime + Time.deltaTime

			self.bindData.progress:ProgressToValue(self.currentTime)

			if self.timer <= self.currentTime then
				self:OnBackBtnClick(true)
			end
		end

		if self.lastPlayCountDown ~= 0 and Time.time - self.lastPlayCountDown > 2 then
			self.bindData.showCount = ""
		end

		self:OnEmojiRefreshTick()
	end
end

function M:OnRenderEmojiEffectItem(btn, index)
	local store = self:GetStoreByWidget(btn)

	if not store then
		return
	end

	store.iconId = self.nowEmojiId

	btn:SetActive(false)

	self.emojiStore[index + 1] = btn
end

function M:PlayAni(index)
	if not self.emojiStore[index] then
		return
	end

	local btn = self.emojiStore[index]

	btn:SetActive(true)

	btn.renderOpacity = btn.originRenderOpacity

	AnimMgr.DoAlpha(btn, "BubbleFilmEmojiShowAni", 0, SocialMediaConfig.EmojiShowTime, 0)

	local showX = math.random(SocialMediaConfig.EmojiShowDeltaX[1], SocialMediaConfig.EmojiShowDeltaX[2])
	local showY = math.random(SocialMediaConfig.EmojiShowDeltaY[1], SocialMediaConfig.EmojiShowDeltaY[2])
	local target = Vector3.New(showX, showY, 0)
	btn.localPosition = Vector3.zero

	AnimMgr.Move(btn.rectTransform, "BubbleFilmEmojiShowAni", target, SocialMediaConfig.EmojiShowTime, 0, DG.Tweening.Ease.OutQuad, nil)
end

function M:OnRenderEmojiItem(btn, index)
	local store = self:GetStoreByWidget(btn)

	if not store then
		return
	end

	local data = self.emojiList[index + 1]
	store.iconId = data.iconId
	btn.luaBeginLongPress = self:CreateActionWithArgs("OnEmojiBtnClickBegin", data)
	btn.luaEndLongPress = self:CreateAction("OnEmojiBtnClickEnd")
end

function M:OnEmojiBtnClickBegin(data)
	self.nowEmojiCount = 0
	self.nowEmojiId = data.iconId

	self:InitEmoji()
	self:OnEmojiRefreshTick()
end

function M:OnEmojiBtnClickEnd()
	if self.nowEmojiId == 0 then
		return
	end

	self.emojiUseList[self.nowEmojiId] = (self.emojiUseList[self.nowEmojiId] or 0) + self.nowEmojiCount
	self.nowEmojiId = 0
end

function M:OnEmojiRefreshTick()
	if self.nowEmojiId == 0 or Time.unscaledTime <= self.preTime + SocialMediaConfig.EmojiPressTime then
		return
	end

	self.preTime = Time.unscaledTime
	self.nowEmojiCount = self.nowEmojiCount + 1
	self.bindData.showCount = "X" .. self.nowEmojiCount

	self.bindData.countAni:Play()

	self.lastPlayCountDown = Time.time

	self:PlayAni(self.nowEmojiCount % SocialMediaConfig.EmojiShowCount + 1)
end

function M:RefreshTimer()
	self.currentTime = 0

	if self.data.isVideo == true then
		self.timer = self.bindData.CCPlayer:GetDuration()
	else
		self.timer = SocialMediaConfig.StoryImageTime
	end

	self.bindData.progress:ResetValue(0, 0, 0, self.timer)
end

function M:GetEmojiList()
	local emojiList = {}

	for i = 1, #SocialMediaConfig.EmojiList do
		local ele = {
			iconId = SocialMediaConfig.EmojiList[i]
		}

		table.insert(emojiList, ele)
	end

	return emojiList
end

function M:RefreshPage(pid)
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
		self.bindData.CCPlayer:PlayVideoUrl(imageUrl, false, self:CreateAction("OnBackBtnClick"), self:CreateAction("RefreshTimer"))
	else
		self.bindData.url = imageUrl

		self:RefreshTimer()
	end
end

function M:InitEmoji()
	self.emojiStore = {}

	self.bindData.emojiShowList:SetList(SocialMediaConfig.EmojiShowCount)
end
