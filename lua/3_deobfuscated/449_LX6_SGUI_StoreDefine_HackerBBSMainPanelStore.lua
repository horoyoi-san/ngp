local HackerPostConfig = LTConfig.HackerPostConfig
local HackerConfig = LTConfig.HackerConfig
local HackerCommentConfig = LTConfig.HackerCommentConfig
local HackerRankConfig = LTConfig.HackerRankConfig
local MessageConfig = LTConfig.MessageConfig
local HackerPostState = UX.Game.HackerPostState
C_HackerBBSMainPanelStore = DefClass("C_HackerBBSMainPanelStore", C_HackerBBSMainPanelStore, C_StoreGroup)
GroupName2Class.HackerBBSMainPanelStore = C_HackerBBSMainPanelStore
local M = C_HackerBBSMainPanelStore
local POST_TYPE = {
	Task = 2,
	Normal = 1
}

function M:ctor()
	return
end

function M:OnAwake()
	self.bindData.backBtn.luaClick = self:CreateAction("OnBackBtnClick")
	self.bindData.finishRenameBtn.luaClick = self:CreateAction("OnFinishRenameBtnClick")
	self.bindData.sendBtn.luaClick = self:CreateAction("OnSendBtnClick")
	self.bindData.homeBtn.luaClick = self:CreateAction("OnHomeBtnClick")
	self.bindData.tabList.luaSimpleRenderItem = self:CreateAction("OnRefreshTabBarList")
	self.bindData.tabList.luaSimpleClick = self:CreateAction("OnChangeTabBarItem")
	self.bindData.inputNameFirst.characterLimit = 0
	self.bindData.inputNameFirst.maxLength = LTConfig.GameConfig.PlayerNameMaxLength
	self.bindData.inputNameFirst.luaValueChanged = self:CreateAction("OnInputNameValueChanged")
end

function M:OnEnable()
	return
end

function M:OnStart()
	return
end

function M:OnDisable()
	return
end

function M:OnDestroy()
	return
end

function M:OnShow(panelId, data)
	self.bindData.page = 0
	self.tabTopIndex = 0

	SGUI.UCursorInput.ResetCursorPos()
	self:CheckIsNew()
end

function M:OnClose()
	self.bindData.inputNameFirst:DeactivateInputField()
end

function M:OnActiveDeviceChange(device)
	if SGUI.GameDevice.KeyboardMouse < device then
		self:ActivateInputField()
	end
end

function M:CheckIsNew()
	local cardId = gCS.MyPlayerManager.PlayerUnit.ClientData.cardId
	local info = gHackManager.HackerSpiritInfo[cardId]
	self.hackerSpiritInfo = info

	if info and info.HackerName and info.HackerName ~= "" then
		self.name = info.HackerName
		self.rank = info.Rank

		self:ActivateInputField()

		self.bindData.inputNameFirst.placeHolder.text = info.HackerName
		self.bindData.isNew = 0
	else
		self.rank = 0
		self.name = ""
		self.bindData.isNew = 1
	end

	self.icon = HackerConfig.HackBBSPlayerHeadIcon
	self.bindData.icon = self.icon
	self.bindData.topNameText = self.name
	self.bindData.topRankText = self.rank

	self:InitInfo()
end

function M:InitInfo()
	if table.isNilOrEmpty(self.hackerSpiritInfo) then
		return
	end

	self.tabList = {}
	local tabData = HackerConfig.HackBBSTitle

	for i = 1, #tabData do
		local view = {
			title = tabData[i],
			index = i - 1
		}

		table.insert(self.tabList, view)
	end

	self.bindData.tabList:SetSimpleList(#self.tabList)

	self.bindData.page = 0
	self.itemList = {}
	local viewSpace1 = {
		tIndex = 1
	}

	table.insert(self.itemList, viewSpace1)

	for i, v in pairs(self.hackerSpiritInfo.PostInfos) do
		local cfg = HackerPostConfig.GetConfig(v.Id)
		local item = {
			tIndex = 0,
			Id = cfg.Id,
			PostType = cfg.PostType,
			TitleType = cfg.TitleType,
			Title = cfg.Title,
			Name = cfg.Name,
			views = cfg.Views,
			Text = cfg.Text,
			Image = cfg.Image,
			haveRead = v.HaveRead,
			Respondid = cfg.Respondid,
			RespondText = cfg.RespondText,
			isAccept = v.State == HackerPostState.Accepted or v.State == HackerPostState.Completed
		}
		item.respondCount = item.isAccept and #cfg.Respondid + 1 or #cfg.Respondid
		item.State = v.State
		item.isNormal = cfg.PostType == POST_TYPE.Normal
		item.icon = cfg.Headicon
		item.GuideId = cfg.GuideId
		item.Eventid = cfg.Eventid

		table.insert(self.itemList, item)
	end

	self.curItemList = self.itemList
	self.bindData.itemList.luaSimpleRenderItem = self:CreateAction("OnRefreshItemList")
	self.bindData.itemList.luaSimpleClick = self:CreateAction("OnChangeItem")
	self.bindData.itemList.luaSimpleDynamicRenderItem = nil

	function self.bindData.itemList.onGetTIndex(index)
		local data = nil

		if self.selectState == HackerPostState.New then
			data = self.itemList[index + 1]
		else
			data = self.curItemList[index + 1]
		end

		return data.tIndex
	end

	self.bindData.itemList:SetSimpleList(#self.curItemList)
end

function M:OnRefreshItemList(item, index)
	local data = nil

	if self.selectState == HackerPostState.New then
		data = self.itemList[index + 1]
	else
		data = self.curItemList[index + 1]
	end

	if data.tIndex == 0 then
		local store = gStoreManager:GetStoreGroup("HackerBBSListTemplateStore"):GetStoreByWidget(item)

		if store then
			store.title = data.Title
			store.titleType = data.TitleType
			store.userName = data.Name
			store.views = data.views
			store.respondCount = data.respondCount
			store.Image = data.Image
			store.icon = data.icon
			store.Respondid = data.Respondid
			store.haveReadCtrl = data.haveRead and 1 or 0
			store.guide.guideID = data.GuideId
			store.textColorType = data.State ~= HackerPostState.Completed and not data.isNormal and 1 or 0
		end
	end
end

function M:OnChangeItem(btn, index)
	local data = nil

	if self.selectState == HackerPostState.New then
		data = self.itemList[index + 1]
	else
		data = self.curItemList[index + 1]
	end

	self:SetContentList(data, data.isAccept or false)
end

function M:OnRefreshTabBarList(btn, index)
	local data = self.tabList[index + 1]
	local store = gStoreManager:GetStoreGroup("S_HackerBBSTabTemplateButton"):GetStoreByWidget(btn)

	if store then
		store.title = data.title
		btn.isSelected = index == self.tabTopIndex
	end
end

function M:OnChangeTabBarItem(btn, index)
	local data = self.tabList[index + 1]
	self.tabTopIndex = data.index

	self:OnStateBtnClick(data.index)
	self.bindData.contentList:RefreshList()
end

function M:SetContentList(data, isAccept)
	if table.isNilOrEmpty(data) then
		print_error("当前未选中任何帖子")

		return
	end

	if not data.haveRead then
		gClientToGameDelegate:AskReadHackerNewPost(data.Id).Callback = function (err)
			if err == MessageConfig.Ok then
				gHackManager:ReadHackerJobRedDot(data.Id)
			else
				print_error("AskReadHackerNewPost failed, error =", gCS.Error.GetNameById(err))
			end
		end
	end

	self.bindData.page = 1
	self.currentPostData = data
	self.currentPostId = data.Id
	self.currentContent = {}
	local viewSpace1 = {
		tIndex = 1
	}

	table.insert(self.currentContent, viewSpace1)

	local floor = 1
	local view = {
		tIndex = 3,
		isTop = true,
		Title = data.Title,
		TitleType = data.TitleType,
		Name = data.Name,
		Ipaddress = data.Ipaddress,
		Text = data.Text,
		Image = data.Image,
		icon = data.icon,
		floor = floor
	}

	if not data.isNormal then
		view.isAccept = data.State == HackerPostState.Accepted
	end

	table.insert(self.currentContent, view)

	floor = floor + 1

	for i = 1, #data.Respondid do
		local cfg = HackerCommentConfig.GetConfig(data.Respondid[i])

		if cfg then
			local view = {
				tIndex = 3,
				isTop = false,
				TitleType = data.TitleType,
				Name = cfg.Name,
				Rank = cfg.Rank,
				Text = cfg.Text,
				Image = cfg.Image,
				icon = cfg.Headicon,
				floor = floor,
				isAccept = false
			}

			table.insert(self.currentContent, view)

			floor = floor + 1
		end
	end

	if not data.isNormal then
		self.bindData.isReply = isAccept and 0 or 1

		if isAccept then
			local view = {
				tIndex = 3,
				isTop = false,
				Name = self.name,
				Rank = self.rank,
				Text = data.RespondText,
				floor = floor,
				isAccept = data.State == HackerPostState.Accepted
			}

			table.insert(self.currentContent, view)

			floor = floor + 1
		else
			local view2 = {
				tIndex = 3
			}

			table.insert(self.currentContent, view2)

			self.bindData.replyDes = data.RespondText
		end
	end

	local viewSpace2 = {
		tIndex = 2
	}

	table.insert(self.currentContent, viewSpace2)

	self.bindData.contentList.luaSimpleDynamicRenderItem = self:CreateAction("OnRefreshContentList")
	self.bindData.contentList.luaSimpleRenderItem = self:CreateAction("OnRefreshContentList")

	function self.bindData.contentList.onGetTIndex(index)
		return self.currentContent[index + 1].tIndex
	end

	self.bindData.contentList.luaSimpleClick = nil

	self.bindData.contentList:SetSimpleList(#self.currentContent)
end

function M:OnRefreshContentList(item, index)
	local data = self.currentContent[index + 1]

	if data.tIndex == 3 then
		local store = gStoreManager:GetStoreGroup("HackerContentListTemplateStore"):GetStoreByWidget(item)

		if store then
			store.name = data.Name
			store.rank = data.Rank
			store.des = data.Text
			store.topTitleType = data.TitleType
			store.icon = data.icon
			store.isTop = data.isTop and 0 or 1
			store.floor = data.floor
			store.isAccept = data.isAccept and 1 or 0
			store.isHasImg = table.isNilOrEmpty(data.Image) and 0 or 1

			if data.isAccept then
				store.goTaskBtn.luaClick = self:CreateAction("OnClickTaskGoBtn")
			end

			if not table.isNilOrEmpty(data.Image) then
				store.imgList.luaSimpleRenderItem = self:CreateAction("OnRefreshImageList")
				self.contentImgList = {}

				for i = 1, #data.Image do
					local view = {
						img = data.Image[i]
					}

					table.insert(self.contentImgList, view)
				end

				store.imgList:SetSimpleList(#self.contentImgList)
			end

			store.layout:ForceRebuildLayoutImmediate()
		end
	end
end

function M:OnClickTaskGoBtn()
	gPanelManager:CheckShow(gPanelId.S_TASK_LIST, {
		eventId = self.currentPostData.Eventid
	})
end

function M:OnRefreshImageList(btn, index)
	local data = self.contentImgList[index + 1]
	local store = gStoreManager:GetStoreGroup("HackerBBSImageTemplateStore"):GetStoreByWidget(btn)

	if store then
		store.img = data.img
	end
end

function M:SetRankList()
	self.bindData.page = 2
	self.bindData.rank = self.rank
	self.bindData.name = self.name
	self.rankList = {}
	local viewSpace1 = {
		tIndex = 1
	}

	table.insert(self.rankList, viewSpace1)

	local hasInsertMe = false

	for i = 0, HackerRankConfig.count - 1 do
		local cfg = HackerRankConfig.LoadAt(i)

		if cfg then
			if self.rank > 0 and self.rank <= cfg.Id and not hasInsertMe then
				hasInsertMe = true
				local view = {
					tIndex = 4,
					Name = self.name,
					rank = self.rank,
					icon = self.icon,
					isMe = 1
				}

				table.insert(self.rankList, view)
			end

			local view = {
				tIndex = 4,
				Name = cfg.RankName
			}

			if self.rank > 0 and self.rank <= cfg.Id then
				view.rank = cfg.Id + 1
			else
				view.rank = cfg.Id
			end

			view.isMe = 0
			view.icon = cfg.Headicon

			table.insert(self.rankList, view)
		end
	end

	local viewSpace2 = {
		tIndex = 2
	}

	table.insert(self.rankList, viewSpace2)

	self.bindData.rankList.luaSimpleRenderItem = self:CreateAction("OnRefreshRankList")
	self.bindData.rankList.luaSimpleDynamicRenderItem = nil

	function self.bindData.rankList.onGetTIndex(index)
		return self.rankList[index + 1].tIndex
	end

	self.bindData.rankList.luaSimpleClick = nil

	self.bindData.rankList:SetSimpleList(#self.rankList)
end

function M:OnRefreshRankList(item, index)
	local data = self.rankList[index + 1]

	if data.tIndex == 4 then
		local store = gStoreManager:GetStoreGroup("HackerBBSRankTemplateStore"):GetStoreByWidget(item)

		if store then
			store.rank = data.rank
			store.des = data.Name
			store.icon = data.icon
			store.isMe = data.isMe

			if data.rank == 1 then
				store.isMe = 4
			elseif data.rank == 2 then
				store.isMe = 3
			elseif data.rank == 3 then
				store.isMe = 2
			end
		end
	end
end

function M:OnBackBtnClick()
	if self.bindData.page == 1 then
		self.bindData.page = 0
		self.bindData.isReply = 0

		self:OnStateBtnClick(self.tabTopIndex)
	else
		gPanelManager:Close(gPanelId.HACKER_MAIN_PANEL)
	end
end

function M:OnHomeBtnClick()
	self.bindData.page = 0
	self.bindData.isReply = 0

	self:OnStateBtnClick(HackerPostState.New)
	self.bindData.tabList:SelectItem(0, false)
end

function M:OnStateBtnClick(state)
	self.bindData.page = 0
	self.bindData.isReply = 0
	self.selectState = state
	local curItemList = {}

	if state == HackerPostState.New then
		self:InitInfo()

		return
	end

	if state == 3 then
		self:SetRankList()

		return
	end

	for i = 1, #self.itemList do
		if self.itemList[i].tIndex == 0 then
			if state == HackerPostState.Accepted then
				if self.itemList[i].State == state or self.itemList[i].State == HackerPostState.New and not self.itemList[i].isNormal then
					table.insert(curItemList, self.itemList[i])
				end
			elseif self.itemList[i].State == state then
				table.insert(curItemList, self.itemList[i])
			end
		else
			table.insert(curItemList, self.itemList[i])
		end
	end

	self.curItemList = curItemList
	self.bindData.itemList.luaSimpleRenderItem = self:CreateAction("OnRefreshItemList")
	self.bindData.itemList.luaSimpleClick = self:CreateAction("OnChangeItem")

	function self.bindData.itemList.onGetTIndex(index)
		local data = nil

		if self.selectState == HackerPostState.New then
			data = self.itemList[index + 1]
		else
			data = self.curItemList[index + 1]
		end

		return data.tIndex
	end

	self.bindData.itemList:SetSimpleList(#self.curItemList)
end

function M:OnInputNameValueChanged(inputText)
	return
end

function M:OnRenameBtnClick()
	self.bindData.isNew = 1
	self.bindData.isRename = 1
end

function M:OnSendBtnClick()
	if not self.currentPostId or self.currentPostId == 0 then
		return
	end

	local selectItem = nil

	for i = 1, #self.itemList do
		if self.itemList[i].tIndex == 0 and self.itemList[i].Id == self.currentPostData.Id then
			self.itemList[i].isAccept = true

			break
		end
	end

	self:SetContentList(self.currentPostData, true)
	self.bindData.contentList:GoToIndex(#self.currentContent - 1, false)

	self.closeTimer = Timer.New(function ()
		self.closeTimer = nil

		gClientToGameDelegate:AskAcceptHackerPostTask(self.currentPostId).Callback = function (err, data)
			if err == MessageConfig.Ok then
				if gPanelManager:IsPanelShowing(gPanelId.HACKER_APP_PANEL) then
					gPanelManager:Close(gPanelId.HACKER_APP_PANEL)
				end

				if gPanelManager:IsPanelShowing(gPanelId.HACKER_MAIN_PANEL) then
					gPanelManager:Close(gPanelId.HACKER_MAIN_PANEL)
				end
			else
				print_error("AskAcceptHackerPostTask 发送失败 err = " .. err)
			end
		end
	end, 1):Start()
end

function M:ActivateInputField()
	if not self.bindData.inputNameFirst then
		return
	end

	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		return
	end

	self.bindData.inputNameFirst:ActivateInputField()
end

function M:OnFinishRenameBtnClick()
	self.inputName = ""
	self.inputName = self.bindData.inputNameFirst.text

	if self:ContentIsEmpty(self.inputName) then
		self.bindData.isRename = 0
		self.bindData.isNew = 0

		return
	end

	self:CheckName(self.inputName, function ()
		gClientToGameDelegate:AskChangeHackerName(self.inputName).Callback = function (err, data)
			if err == MessageConfig.Ok then
				self.bindData.isRename = 0
				self.name = self.inputName

				gNewGuideMgr:NotifySignal(EGuideSignal.SetHackerName)
				self:CheckIsNew()
			else
				self.bindData.isRename = 0
			end
		end
	end)
end

function M:CheckName(userName, cb)
	if self:ContentIsEmpty(userName) then
		cb()

		return
	end

	gCoroutineManager:StartCoroutine(function ()
		local wait = EnvSDK.reviewNickNameAsync(userName)

		coroutine.yield(wait)

		if wait.result.code == 200 then
			local result = gCS.GuiUtils.IsInputNameValidNoMsg(userName, LTConfig.GameConfig.PlayerNameMinLength, LTConfig.GameConfig.PlayerNameMaxLength)

			if result ~= 0 then
				gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.NameInvalid)

				return
			end

			cb()
		else
			print_debug("result code is :" .. wait.result.code)
			gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.FilesCheck)
		end
	end)
end

function M:ContentIsEmpty(str)
	for i = 1, #str do
		if string.sub(str, i, i) ~= "\n" and string.sub(str, i, i) ~= " " then
			return false
		end
	end

	return true
end
