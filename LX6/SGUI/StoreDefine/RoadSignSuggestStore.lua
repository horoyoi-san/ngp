-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\RoadSignSuggestStore.lua
-- Decompiled from: 00922_RoadSignSuggestStore.lua_85fcacc7b6a3.luajit

C_RoadSignSuggestStore = DefClass("C_RoadSignSuggestStore", C_RoadSignSuggestStore, C_StoreGroup)
GroupName2Class.RoadSignSuggestStore = C_RoadSignSuggestStore
local M = C_RoadSignSuggestStore
local RoadSignManager = LX6.RoadSign.RoadSignManager
local json = require("cjson/json")
local PhotoUtils = LX6.Utils.PhotoUtils
local username = ""
local postUrlformat = gRoadSignManager.DbUrl .. "?reqtype=2&filepath=%s"
local cdnFormat = "https://l50.gsf.inner.netease.com/RoadSign/%s/%s"

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.bindData.closeButton.luaClick = self.CreateAction(self, "OnExitClick")
	self.bindData.commitButton.luaClick = self.CreateAction(self, "OnCommitClick")
	self.bindData.imgsDatas = {
		{
			["a\\x9f\\x8a\\x86Y"] = 1
		}
	}
	self.bindData.imgList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderImgListItem")
	self.bindData.imgList.onGetTIndex = self.CreateAction(self, "OnGetTindex")
	self.bindData.shootScreenButton.luaClick = self.CreateAction(self, "ShootScreen")
	self.bindData.pasteImageButton.luaClick = self.CreateAction(self, "PasteImage")
	self.bindData.inputField.characterLimit = 100
end

M.OnGetTindex = function(self, index)
	local luaIndex = index + 1

	return self.bindData.imgsDatas[luaIndex].tIndex
end

M.OnRenderImgListItem = function(self, btn, index)
	print(#self.bindData.imgsDatas)

	local data = self.bindData.imgsDatas[index + 1]

	if data.tIndex ~= 0 then
		slot4 = gStoreManager
		slot4 = slot4:GetStoreGroup("PictureStore")
		local store = slot4:GetStoreByWidget(btn)
		local texture = data.texture
		store.image.texture = texture

		store.deleteButton.luaClick = function()
			table.remove(self.bindData.imgsDatas, index + 1)

			local imgNumber = #self.bindData.imgsDatas

			if imgNumber >= 5 and self.bindData.imgsDatas[imgNumber].tIndex == 1 then
				table.insert(self.bindData.imgsDatas, imgNumber + 1, {
					["a\\x9f\\x8a\\x86Y"] = 1
				})
			end

			self:RefreshImgList()
		end
	elseif data.tIndex ~= 1 then
		slot4 = gStoreManager
		slot4 = slot4:GetStoreGroup("EmptyPictureStore")
		local store = slot4:GetStoreByWidget(btn)

		store.addButton.luaClick = function()
			slot0 = gRoadSignManager

			slot0:PickImage(function (texture)
				table.insert(self.bindData.imgsDatas, #self.bindData.imgsDatas, {
					["a\\x9f\\x8a\\x86Y"] = 0,
					texture = texture
				})
				self:CheckAndDeleteAddImageButton()
				self:RefreshImgList()
			end)
		end
	end
end

M.CheckAndDeleteAddImageButton = function(self)
	if #self.bindData.imgsDatas <= 5 then
		table.remove(self.bindData.imgsDatas, #self.bindData.imgsDatas)
	end
end

M.OnEnable = function(self)
	if not gCS.LuaUtils.IsPublish then
		username = RoadSignManager.CalcMail(L50.Gm.AutoQaFunctions.GetEnvironmentUserName())
	end

	self.RefreshImgList(self)
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

	LX6.Manager.GameInputManager.SetDisableInput(self.bindData.panelId, false, true, true)
end

M.OnClose = function(self)
	LX6.Manager.GameInputManager.SetEnableInput(self.bindData.panelId, true, true, true)
end

M.OnExitClick = function(self)
	gPanelManager:Close(gPanelId.S_ROADSGIN_SUGGEST_PANEL)
end

M.RefreshImgList = function(self)
	self.bindData.imgList:SetSimpleList(#self.bindData.imgsDatas)
end

M.PostImageToFileHubOneByOne = function(self, index, urls)
	if index <= #self.bindData.imgsDatas then
		return
	end

	local imgData = self.bindData.imgsDatas[index]

	if imgData.tIndex ~= 0 then
		local texture = imgData.texture

		if not texture then
			if index + 1 ~= #self.bindData.imgsDatas then
				self.SaveDB(self, urls)
			else
				self.PostImageToFileHubOneByOne(self, index + 1, urls)
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

					if index + 1 ~= #self.bindData.imgsDatas then
						self:SaveDB(urls)
					else
						self:PostImageToFileHubOneByOne(index + 1, urls)
					end
				end
			end)
		end
	else
		self.SaveDB(self, urls)
	end
end

M.OnCommitClick = function(self)
	local urls = {}

	self.PostImageToFileHubOneByOne(self, 1, urls)
end

M.GenerateId = function(self)
	local idFormat = "%s-%s-%s"
	local timePart = tostring(os.time())
	local randomPart = tostring(math.random(1000, 9999))

	return string.format(idFormat, username, timePart, randomPart)
end

M.getSubString = function(self, str)
	if #str <= 15 then
		return string.sub(str, 1, 15)
	else
		return str
	end
end

M.SaveDB = function(self, urls)
	local pos = gCS.MyPlayerManager.PlayerUnit.LocalPosition
	local des = self.bindData.descriptionText.text
	local id = self.GenerateId(self)
	local raidId = gSceneDataMgr.CurrentRaidId
	local VersionControlNum = LX6.Manager.ConstConfig.GetConfig(LX6.Manager.ConstConfig.VersionControlNum)
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

	local cb = function(isSuccess, result, errCode)
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

M.PostToQAWeb = function(self, des, customfields)
	local filesData = {}

	for index, imgData in ipairs(self.bindData.imgsDatas) do
		if imgData.tIndex ~= 0 then
			local texture = imgData.texture

			if texture then
				local bytes = PhotoUtils.EncodeToJPG(texture)

				if bytes then
					local str = RoadSignManager.ByteToBase64Str(bytes)

					if str and str == "" then
						table.insert(filesData, str)
					end
				end
			end
		end
	end

	local fileStr = table.concat(filesData, ";")

	RoadSignManager.SendMessageToQAWebsite(fileStr, username, des, customfields, function ()
		gDisplayMessageMgr:ShowMessageContentDebug("问题已提交到反馈网站！")
	end, function ()
		gDisplayMessageMgr:ShowMessageContentDebug("上传出错，问题未提交到反馈网站！")
	end)
end

M.ShootScreen = function(self)
	self.bindData.root.gameObject:SetActive(false)

	local instance = RoadSignManager.Instance

	if not instance or not instance.gameObject.activeSelf then
		gDisplayMessageMgr:ShowMessageContentDebug("当前路牌管理未打开，无法截图")
		self.bindData.root.gameObject:SetActive(true)

		return
	end

	slot2 = gCoroutineManager

	slot2:StartCoroutine(function ()
		coroutine.yield(nil)
		instance:GetScreenShot()
		coroutine.yield(nil)

		local texture = RoadSignManager.Instance.tex

		table.insert(self.bindData.imgsDatas, #self.bindData.imgsDatas, {
			["a\\x9f\\x8a\\x86Y"] = 0,
			texture = texture
		})
		self:CheckAndDeleteAddImageButton()
		self:RefreshImgList()
		self.bindData.root.gameObject:SetActive(true)
	end)
end

M.PasteImage = function(self)
	local texture = RoadSignManager.GetPastImage()

	if texture then
		table.insert(self.bindData.imgsDatas, #self.bindData.imgsDatas, {
			["a\\x9f\\x8a\\x86Y"] = 0,
			texture = texture
		})
		self.CheckAndDeleteAddImageButton(self)
		self.RefreshImgList(self)
	end
end
