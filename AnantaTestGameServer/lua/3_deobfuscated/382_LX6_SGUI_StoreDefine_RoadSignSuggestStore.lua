C_RoadSignSuggestStore = DefClass("C_RoadSignSuggestStore", C_RoadSignSuggestStore, C_StoreGroup)
GroupName2Class.RoadSignSuggestStore = C_RoadSignSuggestStore
local M = C_RoadSignSuggestStore
local RoadSignManager = LX6.RoadSign.RoadSignManager
local json = require("cjson/json")
local PhotoUtils = LX6.Utils.PhotoUtils
local username = ""
local postUrlformat = gRoadSignManager.DbUrl .. "?reqtype=2&filepath=%s"
local cdnFormat = "https://l50.gsf.inner.netease.com/RoadSign/%s/%s"

function M:ctor()
	return
end

function M:OnAwake()
	self.bindData.closeButton.luaClick = self:CreateAction("OnExitClick")
	self.bindData.commitButton.luaClick = self:CreateAction("OnCommitClick")
	self.bindData.imgsDatas = {
		{
			tIndex = 1
		}
	}
	self.bindData.imgList.luaSimpleRenderItem = self:CreateAction("OnRenderImgListItem")
	self.bindData.imgList.onGetTIndex = self:CreateAction("OnGetTindex")
	self.bindData.shootScreenButton.luaClick = self:CreateAction("ShootScreen")
	self.bindData.pasteImageButton.luaClick = self:CreateAction("PasteImage")
	self.bindData.inputField.characterLimit = 100
end

function M:OnGetTindex(index)
	local luaIndex = index + 1

	return self.bindData.imgsDatas[luaIndex].tIndex
end

function M:OnRenderImgListItem(btn, index)
	print(#self.bindData.imgsDatas)

	local data = self.bindData.imgsDatas[index + 1]

	if data.tIndex == 0 then
		local store = gStoreManager:GetStoreGroup("PictureStore"):GetStoreByWidget(btn)
		local texture = data.texture
		store.image.texture = texture

		function store.deleteButton.luaClick()
			table.remove(self.bindData.imgsDatas, index + 1)

			local imgNumber = #self.bindData.imgsDatas

			if imgNumber < 5 and self.bindData.imgsDatas[imgNumber].tIndex ~= 1 then
				table.insert(self.bindData.imgsDatas, imgNumber + 1, {
					tIndex = 1
				})
			end

			self:RefreshImgList()
		end
	elseif data.tIndex == 1 then
		local store = gStoreManager:GetStoreGroup("EmptyPictureStore"):GetStoreByWidget(btn)

		function store.addButton.luaClick()
			gRoadSignManager:PickImage(function (texture)
				table.insert(self.bindData.imgsDatas, #self.bindData.imgsDatas, {
					tIndex = 0,
					texture = texture
				})
				self:CheckAndDeleteAddImageButton()
				self:RefreshImgList()
			end)
		end
	end
end

function M:CheckAndDeleteAddImageButton()
	if #self.bindData.imgsDatas > 5 then
		table.remove(self.bindData.imgsDatas, #self.bindData.imgsDatas)
	end
end

function M:OnEnable()
	if not gCS.LuaUtils.IsNotUseGM then
		username = RoadSignManager.CalcMail(L50.Gm.AutoQaFunctions.GetEnvironmentUserName())
	end

	self:RefreshImgList()
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

	LX6.Manager.GameInputManager.SetDisableInput(self.bindData.panelId, false, true, true)
end

function M:OnClose()
	LX6.Manager.GameInputManager.SetEnableInput(self.bindData.panelId, true, true, true)
end

function M:OnExitClick()
	gPanelManager:Close(gPanelId.S_ROADSGIN_SUGGEST_PANEL)
end

function M:RefreshImgList()
	self.bindData.imgList:SetSimpleList(#self.bindData.imgsDatas)
end

function M:PostImageToFileHubOneByOne(index, urls)
	if index > #self.bindData.imgsDatas then
		return
	end

	local imgData = self.bindData.imgsDatas[index]

	if imgData.tIndex == 0 then
		local texture = imgData.texture

		if not texture then
			if index + 1 == #self.bindData.imgsDatas then
				self:SaveDB(urls)
			else
				self:PostImageToFileHubOneByOne(index + 1, urls)
			end
		else
			local bytes = PhotoUtils.EncodeToJPG(texture)
			local str = RoadSignManager.ByteToBase64Str(bytes)
			local fileName = os.time() .. "_" .. index .. ".png"
			local filePath = "RoadSign/" .. username .. "/" .. fileName
			local postUrl = string.format(postUrlformat, filePath)
			local cdnUrl = string.format(cdnFormat, username, fileName)

			gCS.LuaUtils.HttpPost(postUrl, str, function (success, res, code)
				if not self.STATE_EnableOnce then
					gDisplayMessageMgr:ShowMessageContentDebug("界面关闭，上传失败")

					return
				end

				if not success then
					gDisplayMessageMgr:ShowMessageContentDebug("图片上传失败！")

					return
				else
					table.insert(urls, cdnUrl)

					if index + 1 == #self.bindData.imgsDatas then
						self:SaveDB(urls)
					else
						self:PostImageToFileHubOneByOne(index + 1, urls)
					end
				end
			end)
		end
	else
		self:SaveDB(urls)
	end
end

function M:OnCommitClick()
	local urls = {}

	self:PostImageToFileHubOneByOne(1, urls)
end

function M:GenerateId()
	local idFormat = "%s-%s-%s"
	local timePart = tostring(os.time())
	local randomPart = tostring(math.random(1000, 9999))

	return string.format(idFormat, username, timePart, randomPart)
end

function M:getSubString(str)
	if #str > 15 then
		return string.sub(str, 1, 15)
	else
		return str
	end
end

function M:SaveDB(urls)
	local pos = gCS.MyPlayerManager.PlayerUnit.LocalPosition
	local des = self.bindData.descriptionText.text
	local id = self:GenerateId()
	local raidId = gSceneDataMgr.CurrentRaidId
	local VersionControlNum = LX6.Manager.ConstConfig.GetConfig("VersionControlNum")
	local parts = {}
	local i = 1

	for num in string.gmatch(VersionControlNum, "%d+") do
		parts[i] = num
		i = i + 1
	end

	local milestone = parts[2]
	local bs = {
		Id = id,
		Pos_X = pos.x,
		Pos_Y = pos.y,
		Pos_Z = pos.z,
		RaidId = raidId,
		Author = username,
		Desc = des,
		ImgUrls = urls,
		Milestone = milestone
	}
	local postJson = json.encode(bs)

	local function cb(isSuccess, result, errCode)
		if not isSuccess then
			print_error("一德：SubmitRoadSignSuggest", isSuccess, result, errCode)

			return
		else
			local signId = nil
			signId = result
			local new_s = self:getSubString(des)

			RoadSignManager.Instance:CreateRoadSign(pos, signId, new_s)

			local customfields = {
				raidId = raidId,
				pos_x = pos.x,
				pos_y = pos.y,
				pos_z = pos.z,
				milestone = milestone,
				signId = signId
			}
			local customStr = json.encode(customfields)

			self:PostToQAWeb(des, customStr)
			gPanelManager:Close(gPanelId.S_ROADSGIN_SUGGEST_PANEL)
		end
	end

	local postUrl = gRoadSignManager.DbUrl .. "?reqtype=0"

	gCS.LuaUtils.HttpPost(postUrl, postJson, cb)
end

function M:PostToQAWeb(des, customfields)
	local filesData = {}

	for index, imgData in ipairs(self.bindData.imgsDatas) do
		if imgData.tIndex == 0 then
			local texture = imgData.texture
			local bytes = PhotoUtils.EncodeToJPG(texture)
			local str = RoadSignManager.ByteToBase64Str(bytes)

			table.insert(filesData, str)
		end
	end

	local fileStr = table.concat(filesData, ";")

	RoadSignManager.SendMessageToQAWebsite(fileStr, username, des, customfields, function ()
		gDisplayMessageMgr:ShowMessageContentDebug("问题已提交到反馈网站！")
	end, function ()
		gDisplayMessageMgr:ShowMessageContentDebug("上传出错，问题未提交到反馈网站！")
	end)
end

function M:ShootScreen()
	self.bindData.root.gameObject:SetActive(false)
	gCoroutineManager:StartCoroutine(function ()
		coroutine.yield(nil)
		RoadSignManager.Instance:GetScreenShot()
		coroutine.yield(nil)

		local texture = RoadSignManager.Instance.tex

		table.insert(self.bindData.imgsDatas, #self.bindData.imgsDatas, {
			tIndex = 0,
			texture = texture
		})
		self:CheckAndDeleteAddImageButton()
		self:RefreshImgList()
		self.bindData.root.gameObject:SetActive(true)
	end)
end

function M:PasteImage()
	local texture = RoadSignManager.GetPastImage()

	if texture then
		table.insert(self.bindData.imgsDatas, #self.bindData.imgsDatas, {
			tIndex = 0,
			texture = texture
		})
		self:CheckAndDeleteAddImageButton()
		self:RefreshImgList()
	end
end
