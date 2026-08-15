C_RoadSignStore = DefClass("C_RoadSignStore", C_RoadSignStore, C_StoreGroup)
GroupName2Class.RoadSignStore = C_RoadSignStore
local M = C_RoadSignStore
local json, RoadSignManager, suggestControl, username = nil

function M:ctor()
	return
end

function M:OnAwake()
	json = require("cjson/json")
	RoadSignManager = LX6.RoadSign.RoadSignManager
	suggestControl = {
		hide = 0,
		show = 1
	}
	username = RoadSignManager.CalcMail(L50.Gm.AutoQaFunctions.GetEnvironmentUserName())
	self.bindData.closeButton.luaClick = self:CreateAction("OnExitClick")
	self.bindData.previousButton.luaClick = self:CreateAction("GoToPrevious")
	self.bindData.nextButton.luaClick = self:CreateAction("GoToNext")
	self.bindData.suggestButton.luaClick = self:CreateAction("EnterSuggestMode")
	self.bindData.contentList.luaSimpleRenderItem = self:CreateAction("OnRenderContentListItem")
	self.bindData.contentList.luaSimpleDynamicRenderItem = self:CreateAction("OnRenderContentListItem")
	self.bindData.contentList.onGetTIndex = self:CreateAction("OnGetContentTindex")
	self.bindData.commitButton.luaClick = self:CreateAction("CommitComment")
	self.bindData.cancelSuggestButton.luaClick = self:CreateAction("CancelSuggest")
	self.bindData.roadSignInfos = {}
	self.bindData.curRoadSignInfo = {}
	self.bindData.curIndex = 1
	self.bindData.closeBigImageBtn.luaClick = self:CreateAction("CloseBigImage")
end

function M:OnGetContentTindex(index)
	local luaIndex = index + 1

	return self.bindData.curRoadSignInfo[luaIndex].tIndex
end

function M:OnRenderContentListItem(btn, index)
	local data = self.bindData.curRoadSignInfo[index + 1]

	if data.tIndex == 0 then
		local store = gStoreManager:GetStoreGroup("DesStore"):GetStoreByWidget(btn)
		store.name.text = data.name
		store.desc.text = data.desc
	elseif data.tIndex == 1 then
		local store = gStoreManager:GetStoreGroup("ImageStore"):GetStoreByWidget(btn)
		self.bindData.imgUrls = data.imgUrls
		store.imageList.luaSimpleRenderItem = self:CreateAction("OnRenderImageListItem")

		store.imageList:SetSimpleList(#self.bindData.imgUrls)
	elseif data.tIndex == 2 then
		local store = gStoreManager:GetStoreGroup("SuggestAgreeStore"):GetStoreByWidget(btn)
		self.bindData.curRoadSignId = data.id
		store.agreeText.text = #data.agreeUsers

		function store.agreeButton.luaClick()
			self:AgreeSuggest(data)
		end

		store.isDeleteBtnShow = data.couldDelete and 1 or 0

		function store.deleteButton.luaClick()
			gDisplayMessageMgr:ShowMessageContentDebug("删除路牌")

			local url = gRoadSignManager.DbUrl .. "?reqtype=9&id=" .. self.bindData.id .. "&deleteuser=" .. username .. "&roadsignid=" .. data.id

			gCS.LuaUtils.HttpGet(url, function (isSuccess, res, code)
				if isSuccess then
					if res == "empty" then
						RoadSignManager.Instance:CompletelyDelete(self.bindData.id)
					end

					self:OnExitClick()
				end
			end)
		end
	elseif data.tIndex == 3 then
		local store = gStoreManager:GetStoreGroup("CommonTopStore"):GetStoreByWidget(btn)
		store.topText.text = string.format("评论  #F(24)%s条#z", data.commentCount)
	elseif data.tIndex == 4 then
		local store = gStoreManager:GetStoreGroup("CommentStore"):GetStoreByWidget(btn)

		function store.agreeButton.luaClick()
			self:AgreeComment(data)
		end

		store.agreeText.text = #data.agreeUsers
		store.commentText.text = string.format("#c7A7A7A%s：#z%s", data.username, data.content)
		store.timeText.text = string.format("%s天前", self:CalcDaysDiff(data.createTime))
	end
end

function M:OnRenderImageListItem(btn, index)
	local data = self.bindData.imgUrls[index + 1]
	local store = gStoreManager:GetStoreGroup("WebPictureStore"):GetStoreByWidget(btn)
	store.image.url = data.imgUrl

	function store.bigBtn.luaClick()
		self.bindData.bigImage.gameObjectActive = true
		local bigImageStore = gStoreManager:GetStoreGroup("BigImageStore"):GetStoreByWidget(self.bindData.bigImage)
		bigImageStore.image.url = data.imgUrl
	end
end

function M:AgreeSuggest(data)
	if not table.find(data.agreeUsers, username) then
		local getUrl = gRoadSignManager.DbUrl .. "?reqtype=5&id=" .. self.bindData.id .. "&agreeuser=" .. username .. "&roadsignid=" .. data.id

		gCS.LuaUtils.HttpGet(getUrl, function (isSuccess, res, code)
			if isSuccess then
				table.insert(data.agreeUsers, username)
				self.bindData.contentList:RefreshList()
			end
		end)
	else
		gDisplayMessageMgr:ShowMessageContentDebug("已经点赞过啦！")
	end
end

function M:AgreeComment(data)
	if not table.find(data.agreeUsers, username) then
		local getUrl = gRoadSignManager.DbUrl .. "?reqtype=6&id=" .. self.bindData.id .. "&agreeuser=" .. username .. "&roadsignid=" .. self.bindData.curRoadSignId .. "&commentid=" .. data.id

		gCS.LuaUtils.HttpGet(getUrl, function (isSuccess, res, code)
			if isSuccess then
				table.insert(data.agreeUsers, username)
				self.bindData.contentList:RefreshList()
			end
		end)
	end
end

function M:RequestSuggestInfo()
	local getUrl = gRoadSignManager.DbUrl .. "?reqtype=3&id=" .. self.bindData.id

	gCS.LuaUtils.HttpGet(getUrl, function (isSuccess, res, code)
		if not self.STATE_EnableOnce then
			return
		end

		if isSuccess then
			self.bindData.roadSignInfos = {}

			if res == "no data" then
				gDisplayMessageMgr:ShowMessageContentDebug("路牌已被删除！")

				return
			end

			local roadSignInfo = json.decode(res)

			for _, info in ipairs(roadSignInfo.items) do
				local imgDatas = {}

				for _, url in ipairs(info.ImgUrls) do
					table.insert(imgDatas, {
						tIndex = 0,
						imgUrl = url
					})
				end

				local temp = {
					{
						tIndex = 0,
						name = info.Author,
						desc = info.Desc
					}
				}

				if #imgDatas > 0 then
					table.insert(temp, {
						tIndex = 1,
						imgUrls = imgDatas
					})
				end

				table.insert(temp, {
					tIndex = 2,
					agreeUsers = info.agreeUsers,
					id = info.Id,
					couldDelete = info.Author == username
				})
				table.insert(temp, {
					tIndex = 3,
					commentCount = #info.comments
				})

				if #info.comments == 0 then
					table.insert(temp, {
						tIndex = 5
					})
				else
					for _, comment in ipairs(info.comments) do
						table.insert(temp, {
							tIndex = 4,
							username = comment.Author,
							content = comment.Desc,
							id = comment.Id,
							agreeUsers = comment.agreeUsers,
							createTime = comment.createTime
						})
					end
				end

				table.insert(self.bindData.roadSignInfos, temp)
			end

			self:RequestRoadSignAuthorName()
			self:RefreshContent()
		else
			gDisplayMessageMgr:ShowMessageContentDebug("请求路牌内容失败！")

			return
		end
	end)
end

function M:RequestRoadSignAuthorName()
	for _, content in ipairs(self.bindData.roadSignInfos) do
		local getUrl = gRoadSignManager.UsermanagerUrl .. "?reqtype=2&mail=" .. content[1].name

		gCS.LuaUtils.HttpGet(getUrl, function (isSuccess, res, code)
			if not self.STATE_EnableOnce then
				return
			end

			local userInfo = json.decode(res)

			if userInfo.name ~= "" then
				content[1].name = userInfo.name
			end

			self:RefreshContent()
		end)
	end
end

function M:CalcDaysDiff(timestampStr)
	local timestamp = tonumber(timestampStr)

	if not timestamp then
		return nil
	end

	local oldTime = os.date("*t", timestamp)
	local currentTime = os.date("*t")
	local daysDiff = (os.time(currentTime) - os.time(oldTime)) / 86400

	return math.floor(daysDiff)
end

function M:RefreshContent()
	self:UpdateCurRoadSignInfo()
	self:RefreshContentList()
end

function M:UpdateCurRoadSignInfo()
	self.bindData.curRoadSignInfo = self.bindData.roadSignInfos[self.bindData.curIndex]
end

function M:RefreshContentList()
	self.bindData.contentList:SetSimpleList(#self.bindData.curRoadSignInfo)
end

function M:RefreshButtons()
	self.bindData.previousButton.gameObjectActive = self.bindData.curIndex > 1
	self.bindData.nextButton.gameObjectActive = self.bindData.curIndex < #self.bindData.roadSignInfos
end

function M:GoToPrevious()
	if self.bindData.curIndex < 2 then
		gDisplayMessageMgr:ShowMessageContentDebug("前面没有了！")
	end

	self.bindData.curIndex = self.bindData.curIndex - 1

	self:RefreshContent()
end

function M:GoToNext()
	self.bindData.curIndex = self.bindData.curIndex + 1

	self:RefreshContent()
end

function M:EnterSuggestMode()
	self.bindData.commentInputActive = suggestControl.show
end

function M:QuitSuggestMode()
	self.bindData.commentInputActive = suggestControl.hide
end

function M:CommitComment()
	if self.bindData.curRoadSignId == nil then
		gDisplayMessageMgr:ShowMessageContentDebug("留言失败，路牌id不存在")

		return
	end

	local commnetText = self.bindData.suggestInput.text
	local postUrl = gRoadSignManager.DbUrl .. "?reqtype=4&id=" .. self.bindData.id .. "&username=" .. username .. "&roadsignid=" .. self.bindData.curRoadSignId

	gCS.LuaUtils.HttpPost(postUrl, commnetText, function (isSuccess, res, code)
		if isSuccess then
			self.bindData.suggestInput.text = ""

			self:RequestSuggestInfo()
			self:QuitSuggestMode()
		end
	end)
end

function M:CancelSuggest()
	self:QuitSuggestMode()
end

function M:CloseBigImage()
	self.bindData.bigImage.gameObjectActive = false
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

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	return
end

function M:OnShow(panelId, data)
	self.bindData.panelId = panelId
	self.bindData.id = data

	LX6.Manager.GameInputManager.SetDisableInput(self.bindData.panelId, false, true, true)
	self:RequestSuggestInfo()
end

function M:OnClose()
	LX6.Manager.GameInputManager.SetEnableInput(self.bindData.panelId, true, true, true)
end

function M:OnExitClick()
	gPanelManager:Close(gPanelId.S_ROADSGIN_PANEL)
end
