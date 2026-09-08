-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\RoadSignStore.lua
-- Decompiled from: 00923_RoadSignStore.lua_2dd547f94dfc.luajit

C_RoadSignStore = DefClass("C_RoadSignStore", C_RoadSignStore, C_StoreGroup)
GroupName2Class.RoadSignStore = C_RoadSignStore
local M = C_RoadSignStore
local json, RoadSignManager, suggestControl, username = nil

M.ctor = function(self)
end

M.OnAwake = function(self)
	json = require("cjson/json")
	RoadSignManager = LX6.RoadSign.RoadSignManager
	suggestControl = {
		["r+y^"] = 0,
		["i*rL"] = 1
	}
	username = RoadSignManager.CalcMail(L50.Gm.AutoQaFunctions.GetEnvironmentUserName())
	self.bindData.closeButton.luaClick = self.CreateAction(self, "OnExitClick")
	self.bindData.previousButton.luaClick = self.CreateAction(self, "GoToPrevious")
	self.bindData.nextButton.luaClick = self.CreateAction(self, "GoToNext")
	self.bindData.suggestButton.luaClick = self.CreateAction(self, "EnterSuggestMode")
	self.bindData.contentList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderContentListItem")
	self.bindData.contentList.luaSimpleDynamicRenderItem = self.CreateAction(self, "OnRenderContentListItem")
	self.bindData.contentList.onGetTIndex = self.CreateAction(self, "OnGetContentTindex")
	self.bindData.commitButton.luaClick = self.CreateAction(self, "CommitComment")
	self.bindData.cancelSuggestButton.luaClick = self.CreateAction(self, "CancelSuggest")
	self.bindData.roadSignInfos = {}
	self.bindData.curRoadSignInfo = {}
	self.bindData.curIndex = 1
	self.bindData.closeBigImageBtn.luaClick = self.CreateAction(self, "CloseBigImage")
end

M.OnGetContentTindex = function(self, index)
	local luaIndex = index + 1

	return self.bindData.curRoadSignInfo[luaIndex].tIndex
end

M.OnRenderContentListItem = function(self, btn, index)
	if not self.bindData.curRoadSignInfo then
		return
	end

	local data = self.bindData.curRoadSignInfo[index + 1]

	if data.tIndex ~= 0 then
		local store = gStoreManager:GetStoreGroup("DesStore"):GetStoreByWidget(btn)
		store.name.text = data.name
		store.desc.text = data.desc
	elseif data.tIndex ~= 1 then
		local store = gStoreManager:GetStoreGroup("ImageStore"):GetStoreByWidget(btn)
		self.bindData.imgUrls = data.imgUrls
		store.imageList.luaSimpleRenderItem = self:CreateAction("OnRenderImageListItem")

		store.imageList:SetSimpleList(#self.bindData.imgUrls)
	elseif data.tIndex ~= 2 then
		local store = gStoreManager:GetStoreGroup("SuggestAgreeStore"):GetStoreByWidget(btn)
		self.bindData.curRoadSignId = data.id
		store.agreeText.text = #data.agreeUsers

		store.agreeButton.luaClick = function()
			self:AgreeSuggest(data)
		end

		store.isDeleteBtnShow = data.couldDelete and 1 or 0

		store.deleteButton.luaClick = function()
			gDisplayMessageMgr:ShowMessageContentDebug("删除路牌")

			local url = gRoadSignManager.DbUrl .. "?reqtype=9&id=" .. self.bindData.id .. "&deleteuser=" .. username .. "&roadsignid=" .. data.id

			gCS.LuaUtils.HttpGet(url, function (isSuccess, res, code)
				if isSuccess then
					if res ~= "empty" then
						RoadSignManager.Instance:CompletelyDelete(self.bindData.id)
					end

					self:OnExitClick()
				end
			end)
		end
	elseif data.tIndex ~= 3 then
		local store = gStoreManager:GetStoreGroup("CommonTopStore"):GetStoreByWidget(btn)
		store.topText.text = string.format("评论  #F(24)%s条#z", data.commentCount)
	elseif data.tIndex ~= 4 then
		local store = gStoreManager:GetStoreGroup("CommentStore"):GetStoreByWidget(btn)

		store.agreeButton.luaClick = function()
			self:AgreeComment(data)
		end

		store.agreeText.text = #data.agreeUsers
		store.commentText.text = string.format("#c7A7A7A%s：#z%s", data.username, data.content)
		store.timeText.text = string.format("%s天前", self:CalcDaysDiff(data.createTime))
	end
end

M.OnRenderImageListItem = function(self, btn, index)
	local data = self.bindData.imgUrls[index + 1]
	slot4 = gStoreManager
	slot4 = slot4:GetStoreGroup("WebPictureStore")
	local store = slot4:GetStoreByWidget(btn)
	store.image.url = data.imgUrl

	store.bigBtn.luaClick = function()
		self.bindData.bigImage.gameObjectActive = true
		local bigImageStore = gStoreManager:GetStoreGroup("BigImageStore"):GetStoreByWidget(self.bindData.bigImage)
		bigImageStore.image.url = data.imgUrl
	end
end

M.AgreeSuggest = function(self, data)
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

M.AgreeComment = function(self, data)
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

M.RequestSuggestInfo = function(self)
	local getUrl = gRoadSignManager.DbUrl .. "?reqtype=3&id=" .. self.bindData.id
	local requestId = self.bindData.id

	gCS.LuaUtils.HttpGet(getUrl, function (isSuccess, res, code)
		if not self.STATE_EnableOnce then
			return
		end

		if self.bindData.id == requestId then
			return
		end

		if isSuccess then
			self.bindData.roadSignInfos = {}

			if res ~= "no data" then
				gDisplayMessageMgr:ShowMessageContentDebug("路牌已被删除！")

				return
			end

			local roadSignInfo = json.decode(res)

			for _, info in ipairs(roadSignInfo.items) do
				local imgDatas = {}

				for _, url in ipairs(info.ImgUrls) do
					table.insert(imgDatas, {
						["a\\x9f\\x8a\\x86Y"] = 0,
						imgUrl = url
					})
				end

				local temp = {
					{
						["a\\x9f\\x8a\\x86Y"] = 0,
						name = info.Author,
						desc = info.Desc
					}
				}

				if #imgDatas <= 0 then
					table.insert(temp, {
						["a\\x9f\\x8a\\x86Y"] = 1,
						imgUrls = imgDatas
					})
				end

				table.insert(temp, {
					["a\\x9f\\x8a\\x86Y"] = 2,
					agreeUsers = info.agreeUsers,
					id = info.Id,
					couldDelete = info.Author ~= username
				})
				table.insert(temp, {
					["a\\x9f\\x8a\\x86Y"] = 3,
					commentCount = #info.comments
				})

				if #info.comments ~= 0 then
					table.insert(temp, {
						["a\\x9f\\x8a\\x86Y"] = 5
					})
				else
					for _, comment in ipairs(info.comments) do
						table.insert(temp, {
							["a\\x9f\\x8a\\x86Y"] = 4,
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

M.RequestRoadSignAuthorName = function(self)
	local totalCount = #self.bindData.roadSignInfos

	if totalCount ~= 0 then
		return
	end

	local completedCount = 0

	for _, content in ipairs(self.bindData.roadSignInfos) do
		local getUrl = gRoadSignManager.UsermanagerUrl .. "?reqtype=2&mail=" .. content[1].name

		gCS.LuaUtils.HttpGet(getUrl, function (isSuccess, res, code)
			if not self.STATE_EnableOnce then
				return
			end

			if isSuccess then
				local userInfo = json.decode(res)

				if userInfo.name == "" then
					content[1].name = userInfo.name
				end
			end

			completedCount = completedCount + 1

			if totalCount < completedCount then
				self:RefreshContent()
			end
		end)
	end
end

M.CalcDaysDiff = function(self, timestampStr)
	local timestamp = tonumber(timestampStr)

	if not timestamp then
		return nil
	end

	local oldTime = os.date("*t", timestamp)
	local currentTime = os.date("*t")
	local daysDiff = (os.time(currentTime) - os.time(oldTime)) / 86400

	return math.floor(daysDiff)
end

M.RefreshContent = function(self)
	self.UpdateCurRoadSignInfo(self)
	self.RefreshContentList(self)
end

M.UpdateCurRoadSignInfo = function(self)
	self.bindData.curRoadSignInfo = self.bindData.roadSignInfos[self.bindData.curIndex]
end

M.RefreshContentList = function(self)
	self.bindData.contentList:SetSimpleList(#self.bindData.curRoadSignInfo)
end

M.RefreshButtons = function(self)
	self.bindData.previousButton.gameObjectActive = self.bindData.curIndex >= 1
	self.bindData.nextButton.gameObjectActive = self.bindData.curIndex <= #self.bindData.roadSignInfos
end

M.GoToPrevious = function(self)
	if self.bindData.curIndex >= 2 then
		gDisplayMessageMgr:ShowMessageContentDebug("前面没有了！")
	end

	self.bindData.curIndex = self.bindData.curIndex - 1

	self.RefreshContent(self)
end

M.GoToNext = function(self)
	self.bindData.curIndex = self.bindData.curIndex + 1

	self.RefreshContent(self)
end

M.EnterSuggestMode = function(self)
	self.bindData.commentInputActive = suggestControl.show
end

M.QuitSuggestMode = function(self)
	self.bindData.commentInputActive = suggestControl.hide
end

M.CommitComment = function(self)
	if self.bindData.curRoadSignId ~= nil then
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

M.CancelSuggest = function(self)
	self.QuitSuggestMode(self)
end

M.CloseBigImage = function(self)
	self.bindData.bigImage.gameObjectActive = false
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	self.bindData.panelId = panelId
	self.bindData.id = data

	LX6.Manager.GameInputManager.SetDisableInput(self.bindData.panelId, false, true, true)
	self.RequestSuggestInfo(self)
end

M.OnClose = function(self)
	LX6.Manager.GameInputManager.SetEnableInput(self.bindData.panelId, true, true, true)
end

M.OnExitClick = function(self)
	gPanelManager:Close(gPanelId.S_ROADSGIN_PANEL)
end
