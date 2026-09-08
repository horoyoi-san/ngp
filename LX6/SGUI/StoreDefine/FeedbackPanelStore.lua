-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\FeedbackPanelStore.lua
-- Decompiled from: 01844_FeedbackPanelStore.lua_db7eee76682a.luajit

C_FeedbackPanelStore = DefClass("C_FeedbackPanelStore", C_FeedbackPanelStore, C_StoreGroup)
GroupName2Class.FeedbackPanelStore = C_FeedbackPanelStore
local M = C_FeedbackPanelStore
local FeedbackUtils = LX6.Utils.Feedback.FeedbackUtils

M.ctor = function(self)
	self.jpgList = {}
	self.jpgListNextId = 1
end

M.DefineAllEnumsAutoGen = function(self)
	self.selectedCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.brokenCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.selectedCtrlEnum = nil
	self.brokenCtrlEnum = nil
end

M.OnAwake = function(self)
	self.config = {
		["\\xe2G\\xd1\\xb3b\\xaeC\\xbe\\xa2"] = 4,
		keywordType = {
			"\\xea\\x8f\\xf8\\xea\\xf3\\x8d\\xff\\x805/",
			"p\\xbe%\\xfei\\xacc$1/t\\xa5\\xfc$\\xda\\xec"
		}
	}
	self.instance = {
		["@R\\xc1\\xaa\\xa5\\xbc&\\xdd\\xe6"] = false,
		["|s\\xa0rO\\xa6\\xf7C^cnI"] = 0,
		imageList = {}
	}
	self.bindData.commitBtn.luaClick = self.CreateAction(self, self.OnCommitBtnClick)
	self.bindData.closeBtn.luaClick = self.CreateAction(self, self.OnCloseBtnClick)
	self.bindData.feedbackType1Btn.luaClick = self.CreateActionWithArgs(self, self.OnFeedbackTypeNBtnClick, 1)
	self.bindData.feedbackType2Btn.luaClick = self.CreateActionWithArgs(self, self.OnFeedbackTypeNBtnClick, 2)
	self.bindData.imageList.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderImageListItem)
	self.bindData.imageList.onGetTIndex = self.CreateAction(self, self.OnImageListGetTIndex)
	self.bindData.imageList.luaSimpleClick = self.CreateAction(self, self.OnImageListItemClick)
	self.bindData.inputField.luaValueChanged = self.CreateAction(self, self.OnInputTextChanged)
end

M.OnShow = function(self, panelId, data)
	self.instance.panelId = panelId
	self.instance.data = data

	gMessageManager:SendMessage(gEventConstants.FEEDBACK_PANEL_SHOW, true)

	if data and data.imageList then
		self.instance.imageList = data.imageList
	end

	self.GetImagesFromJpg(self)
	self.OnFeedbackTypeNBtnClick(self, 1)
	self.UpdateLimitText(self, "")
	self.UpdateList(self)
end

M.OnInputTextChanged = function(self)
	local text = self.bindData.inputField.text
	local textNew = text.gsub(text, "[\r\n]+", "")

	if textNew == text then
		self.bindData.inputField.text = textNew
	end

	self.UpdateLimitText(self, textNew)
end

M.UpdateLimitText = function(self, text)
	self.bindData.limitText = "(" .. tostring(string.utf8len(text)) .. "/" .. tostring(self.bindData.inputField.characterLimit) .. ")"
end

M.TryRemoveJpgListItem = function(self, id)
	if id ~= nil or self.jpgList ~= nil then
		return
	end

	array.remove_if(self.jpgList, function (v)
		return v.id ~= id
	end)
end

M.GetImagesFromJpg = function(self)
	if gGameManager.Env.IsENABLE_PROFILER then
		gGameManager:BeginSample("FeedbackPanelStore.GetImagesFromJpg")
	end

	local imageList = self.instance.imageList or {}
	self.jpgList = self.jpgList or {}
	local jpgList = self.jpgList

	for _, v in pairs(jpgList) do
		local tex = FeedbackUtils.JpgToTex(v.data)

		if tex then
			local item = {
				["t#p^"] = "\\xf4\\x99\\xe9\\xf5\\xe5\\x9c҈0/",
				tex = tex,
				jpgListId = v.id,
				jpgListItem = v
			}

			table.insert(imageList, item)
		end
	end

	self.instance.imageList = imageList

	if gGameManager.Env.IsENABLE_PROFILER then
		gGameManager:EndSample()
	end
end

M.OnCommitBtnClick = function(self)
	if self.instance.postingFeedback then
		return
	end

	local message = self.bindData.inputField.text

	if string.is_null_or_empty(message) then
		self.ShowMessageSuper(self, LTConfig.MessageConfig.FeedbackDetailNeeded)

		return
	end

	self.instance.postingFeedback = true
	local keywordType = self.config.keywordType[self.instance.selectedType]
	local imageDataList = {}
	local imageNameList = {}

	for i, item in ipairs(self.instance.imageList) do
		local data = nil

		if item.jpgListId then
			data = item.jpgListItem.data

			self.TryRemoveJpgListItem(self, item.jpgListId)
		else
			data = LX6.Utils.PhotoUtils.EncodeToJPG(item.tex)
		end

		imageDataList[i] = data
		imageNameList[i] = item.name
	end

	local callback = function(success, retStr)
		self.instance.postingFeedback = false

		if success then
			self:ShowMessageSuper(LTConfig.MessageConfig.SendFeedbackSuccess)
		else
			self:ShowMessageSuper(LTConfig.MessageConfig.SendFeedbackFail)
			print_error("@liulijun04 error in upload feedback", retStr)
		end

		self:ClosePanel()
	end

	FeedbackUtils.DoFeedback(keywordType, message, callback, imageDataList, imageNameList)
end

M.OnFeedbackTypeNBtnClick = function(self, type)
	if self.instance.selectedType ~= type then
		return
	end

	if self.instance.selectedType <= 0 then
		local lastBtn = self.bindData["feedbackType" .. tostring(self.instance.selectedType) .. "Btn"]
		local lastBtnStore = self.GetStoreByWidget(self, lastBtn)
		lastBtnStore.selectedCtrl = self.selectedCtrlEnum._false
	end

	local btn = self.bindData["feedbackType" .. tostring(type) .. "Btn"]
	local btnStore = self.GetStoreByWidget(self, btn)
	btnStore.selectedCtrl = self.selectedCtrlEnum._true
	self.instance.selectedType = type
end

M.OnRenderImageListItem = function(self, btn, csIndex)
	local index = csIndex + 1

	if index <= #self.instance.imageList then
		return
	end

	local data = self.instance.imageList[index]
	local store = self.GetStoreByWidget(self, btn)
	store.brokenCtrl = self.brokenCtrlEnum._false
	store.texture = data.tex

	store.deleteBtn.luaClick = function()
		local needResetNav = nil

		if gClientUtils.IsControllerMode() then
			needResetNav = btn.cachedNavArea.CurrentActiveContent ~= btn
		end

		self:TryRemoveJpgListItem(data.jpgListId)
		self:RemoveImageAt(index)
		self:UpdateList()

		if needResetNav then
			if #self.instance.imageList <= 0 then
				self.bindData.imageList:SetNavSelectToTop(true)
			else
				SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.navArea
			end
		end
	end
end

M.OnImageListGetTIndex = function(self, csIndex)
	return csIndex >= #self.instance.imageList and 0 or 1
end

M.OnImageListItemClick = function(self, btn, csIndex)
	local index = csIndex + 1
	local data = self.instance.imageList[index]

	if data then
		gPanelManager:CheckShow(gPanelId.S_SHOW_PHOTO_PANEL, {
			texture = data.tex
		})
	else
		if self.instance.pickImageTimer then
			return
		end

		if gClientUtils.IsControllerMode() then
			self.instance.pickImageTimer = FrameTimer.New(function ()
				self.instance.pickImageTimer = nil

				self:PickImage()
			end, 1)

			self.instance.pickImageTimer:Start()
		else
			self.PickImage(self)
		end
	end
end

M.PickImage = function(self)
	if not self.STATE_EnableOnce then
		return
	end

	self.instance.instanceId = self.rootGo:GetInstanceID()

	if #self.instance.imageList ~= self.config.maxImageCount then
		self.ShowMessageSuper(self, LTConfig.MessageConfig.FeedbackMaxImageCountExceed)

		return
	end

	FeedbackUtils.PickImage(function (success, path, tex)
		if success and self.instance and self.instance.instanceId ~= self.rootGo:GetInstanceID() then
			table.insert(self.instance.imageList, {
				name = path,
				tex = tex
			})
			self:UpdateList()
		elseif gClientUtils.NotNil(tex) then
			GameObject.Destroy(tex)
		end
	end)
end

M.RemoveImageAt = function(self, index)
	local item = self.instance.imageList[index]

	GameObject.Destroy(item.tex)
	table.remove(self.instance.imageList, index)
end

M.UpdateList = function(self)
	local listCount = #self.instance.imageList

	if self.instance.showAddBtn then
		listCount = listCount + 1
	end

	self.bindData.imageList:SetSimpleList(listCount)
end

M.DoBackgroundScreenShot = function(self)
	if not gSystemUnlockMgr:IsUnlock(LTConfig.SystemUnlockConfig.FeedbackUnlock) or not LTConfig.InformConfig.EnableFeedback then
		return
	end

	local maxImageCount = 5
	local jpgList = self.jpgList

	if maxImageCount < #jpgList then
		self.ShowMessageSuper(self, LTConfig.MessageConfig.FeedbackScreenshotLimitReached)

		return
	end

	FeedbackUtils.GetScreenShot(function (tex)
		if gClientUtils.IsNil(tex) then
			return
		end

		if maxImageCount < #jpgList then
			self:ShowMessageSuper(LTConfig.MessageConfig.FeedbackScreenshotLimitReached)
			UnityEngine.Object.Destroy(tex)

			return
		end

		local jpg = LX6.Utils.PhotoUtils.EncodeToJPG(tex)

		UnityEngine.Object.Destroy(tex)

		local id = self.jpgListNextId
		self.jpgListNextId = id + 1
		local item = {
			id = id,
			data = jpg
		}

		table.insert(self.jpgList, item)
		self:ShowMessageSuper(LTConfig.MessageConfig.FeedbackScreenshotOk, #jpgList, maxImageCount)
	end)
end

M.OnCloseBtnClick = function(self)
	self.ClosePanel(self)
end

M.ClosePanel = function(self)
	gPanelManager:Close(self.instance.panelId)
end

M.OnClose = function(self)
	gMessageManager:SendMessage(gEventConstants.FEEDBACK_PANEL_SHOW, false)
end

M.OnDestroy = function(self)
	for i = #self.instance.imageList, 1, -1 do
		self.RemoveImageAt(self, i)
	end

	self.config = nil
	self.instance = nil
end

M.ShowMessageSuper = function(self, mid, ...)
	local cfg = LTConfig.MessageConfig.GetConfig(mid)
	local content = gString.Format(cfg.Content, ...)

	gDisplayMessageMgr:MsgEnqueue(content, cfg.HideMessageAfter)
end
