C_FeedbackPanelStore = DefClass("C_FeedbackPanelStore", C_FeedbackPanelStore, C_StoreGroup)
GroupName2Class.FeedbackPanelStore = C_FeedbackPanelStore
local M = C_FeedbackPanelStore
local FeedbackUtils = LX6.Utils.Feedback.FeedbackUtils

function M:ctor()
	self.jpgList = {}
	self.jpgListNextId = 1
end

function M:DefineAllEnumsAutoGen()
	self.selectedCtrlEnum = {
		_false = 0,
		_true = 1
	}
	self.brokenCtrlEnum = {
		_false = 0,
		_true = 1
	}
end

function M:ClearAllEnumsAutoGen()
	self.selectedCtrlEnum = nil
	self.brokenCtrlEnum = nil
end

function M:OnAwake()
	self.config = {
		maxImageCount = 4,
		keywordType = {
			"cbtbug",
			"cbtfeedback"
		}
	}
	self.instance = {
		showAddBtn = false,
		selectedType = 0,
		imageList = {}
	}
	self.bindData.commitBtn.luaClick = self:CreateAction(self.OnCommitBtnClick)
	self.bindData.closeBtn.luaClick = self:CreateAction(self.OnCloseBtnClick)
	self.bindData.feedbackType1Btn.luaClick = self:CreateActionWithArgs(self.OnFeedbackTypeNBtnClick, 1)
	self.bindData.feedbackType2Btn.luaClick = self:CreateActionWithArgs(self.OnFeedbackTypeNBtnClick, 2)
	self.bindData.imageList.luaSimpleRenderItem = self:CreateAction(self.OnRenderImageListItem)
	self.bindData.imageList.onGetTIndex = self:CreateAction(self.OnImageListGetTIndex)
	self.bindData.imageList.luaSimpleClick = self:CreateAction(self.OnImageListItemClick)
	self.bindData.inputField.luaValueChanged = self:CreateAction(self.OnInputTextChanged)
end

function M:OnShow(panelId, data)
	self.instance.panelId = panelId
	self.instance.data = data

	gMessageManager:SendMessage(gEventConstants.FEEDBACK_PANEL_SHOW, true)

	if data and data.imageList then
		self.instance.imageList = data.imageList
	end

	self:GetImagesFromJpg()
	self:OnFeedbackTypeNBtnClick(1)
	self:UpdateLimitText("")
	self:UpdateList()
end

function M:OnInputTextChanged()
	local text = self.bindData.inputField.text
	local textNew = text:gsub("[\r\n]+", "")

	if textNew ~= text then
		self.bindData.inputField.text = textNew
	end

	self:UpdateLimitText(textNew)
end

function M:UpdateLimitText(text)
	self.bindData.limitText = "(" .. tostring(string.utf8len(text)) .. "/" .. tostring(self.bindData.inputField.characterLimit) .. ")"
end

function M:TryRemoveJpgListItem(id)
	if id == nil or self.jpgList == nil then
		return
	end

	array.remove_if(self.jpgList, function (v)
		return v.id == id
	end)
end

function M:GetImagesFromJpg()
	if gGameManager.Env.IsENABLE_PROFILER then
		gCS.LuaUtils.BeginSample("FeedbackPanelStore.GetImagesFromJpg")
	end

	local imageList = self.instance.imageList or {}
	self.jpgList = self.jpgList or {}
	local jpgList = self.jpgList

	for _, v in pairs(jpgList) do
		local tex = FeedbackUtils.JpgToTex(v.data)

		if tex then
			local item = {
				name = "screenshot_jpg",
				tex = tex,
				jpgListId = v.id,
				jpgListItem = v
			}

			table.insert(imageList, item)
		end
	end

	self.instance.imageList = imageList

	if gGameManager.Env.IsENABLE_PROFILER then
		gCS.LuaUtils.EndSample()
	end
end

function M:OnCommitBtnClick()
	if self.instance.postingFeedback then
		return
	end

	local message = self.bindData.inputField.text

	if string.is_null_or_empty(message) then
		self:ShowMessageSuper(LTConfig.MessageConfig.FeedbackDetailNeeded)

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

			self:TryRemoveJpgListItem(item.jpgListId)
		else
			data = LX6.Utils.PhotoUtils.EncodeToJPG(item.tex)
		end

		imageDataList[i] = data
		imageNameList[i] = item.name
	end

	local function callback(success, retStr)
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

function M:OnFeedbackTypeNBtnClick(type)
	if self.instance.selectedType == type then
		return
	end

	if self.instance.selectedType > 0 then
		local lastBtn = self.bindData["feedbackType" .. tostring(self.instance.selectedType) .. "Btn"]
		local lastBtnStore = self:GetStoreByWidget(lastBtn)
		lastBtnStore.selectedCtrl = self.selectedCtrlEnum._false
	end

	local btn = self.bindData["feedbackType" .. tostring(type) .. "Btn"]
	local btnStore = self:GetStoreByWidget(btn)
	btnStore.selectedCtrl = self.selectedCtrlEnum._true
	self.instance.selectedType = type
end

function M:OnRenderImageListItem(btn, csIndex)
	local index = csIndex + 1

	if index > #self.instance.imageList then
		return
	end

	local data = self.instance.imageList[index]
	local store = self:GetStoreByWidget(btn)
	store.brokenCtrl = self.brokenCtrlEnum._false
	store.texture = data.tex

	function store.deleteBtn.luaClick()
		local needResetNav = nil

		if gClientUtils.IsControllerMode() then
			needResetNav = self.bindData.navArea.CurrentActiveContent == btn
		end

		self:TryRemoveJpgListItem(data.jpgListId)
		self:RemoveImageAt(index)
		self:UpdateList()

		if needResetNav then
			self.bindData.imageList:SetNavSelectToTop(true)
		end
	end
end

function M:OnImageListGetTIndex(csIndex)
	return csIndex < #self.instance.imageList and 0 or 1
end

function M:OnImageListItemClick(btn, csIndex)
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
			self:PickImage()
		end
	end
end

function M:PickImage()
	if not self.STATE_EnableOnce then
		return
	end

	self.instance.instanceId = self.rootGo:GetInstanceID()

	if #self.instance.imageList == self.config.maxImageCount then
		self:ShowMessageSuper(LTConfig.MessageConfig.FeedbackMaxImageCountExceed)

		return
	end

	FeedbackUtils.PickImage(function (success, path, tex)
		if success and self.instance and self.instance.instanceId == self.rootGo:GetInstanceID() then
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

function M:RemoveImageAt(index)
	local item = self.instance.imageList[index]

	GameObject.Destroy(item.tex)
	table.remove(self.instance.imageList, index)
end

function M:UpdateList()
	local listCount = #self.instance.imageList

	if self.instance.showAddBtn then
		listCount = listCount + 1
	end

	self.bindData.imageList:SetSimpleList(listCount)
end

function M:DoBackgroundScreenShot()
	local maxImageCount = 5
	local jpgList = self.jpgList

	if maxImageCount <= #jpgList then
		self:ShowMessageSuper(LTConfig.MessageConfig.FeedbackScreenshotLimitReached)

		return
	end

	FeedbackUtils.GetScreenShot(function (tex)
		if gClientUtils.IsNil(tex) then
			return
		end

		if maxImageCount <= #jpgList then
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

function M:OnCloseBtnClick()
	self:ClosePanel()
end

function M:ClosePanel()
	gPanelManager:Close(self.instance.panelId)
end

function M:OnClose()
	gMessageManager:SendMessage(gEventConstants.FEEDBACK_PANEL_SHOW, false)
end

function M:OnDestroy()
	for i = #self.instance.imageList, 1, -1 do
		self:RemoveImageAt(i)
	end

	self.config = nil
	self.instance = nil
end

function M:ShowMessageSuper(mid, ...)
	local store = gStoreManager:GetStoreGroup("ScreenshotPanelStore")

	if store then
		store:ShowMessage(mid, ...)
	end
end
