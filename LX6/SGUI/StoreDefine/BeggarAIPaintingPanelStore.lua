-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BeggarAIPaintingPanelStore.lua
-- Decompiled from: 01671_BeggarAIPaintingPanelStore.lua_69fc31c5281a.luajit

C_BeggarAIPaintingPanelStore = DefClass("C_BeggarAIPaintingPanelStore", C_BeggarAIPaintingPanelStore, C_StoreGroup)
GroupName2Class.BeggarAIPaintingPanelStore = C_BeggarAIPaintingPanelStore
local M = C_BeggarAIPaintingPanelStore
local BeggarAiPaintingConfig = LTConfig.BeggarAiPaintingConfig
local BeggarConfig = LTConfig.BeggarConfig
local BeggarDrawToolConfig = LTConfig.BeggarDrawToolConfig
local TextScriptTextConfig = LTConfig.TextScriptTextConfig
local MessageConfig = LTConfig.MessageConfig

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
	self.toolCtrlEnum = {
		["N\\xa1\\xae\\xa0\\xa4"] = 0,
		["\\x9emh"] = 1,
		["Z\\x90\\x9d\\x86S"] = 2
	}
	self.stepCtrlEnum = {
		["N\\xbc\\xa3\\xa9\\xb3"] = 0,
		["=a\\x82\\x86\\x8cV"] = 3,
		["\\xa8\\xb9\n\\xa4y;\\xdf"] = 1,
		["rs޼\\x8d\\xac\r\\xc7\\xef"] = 2
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.toolCtrlEnum = nil
	self.stepCtrlEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
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
	self.isShow = true

	self.ShowPanel(self, data)
end

M.OnClose = function(self)
	self.isShow = false
	self.uploadPresignedUrl = nil
	self.uploadObjectKey = nil
	self.selectObjectKey = nil
	self.aiGenerateRes = nil
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.undoBtn.luaClick = self.CreateAction(self, self.OnClickUndoBtn)
	self.bindData.redoBtn.luaClick = self.CreateAction(self, self.OnClickRedoBtn)
	self.bindData.confirmBtn.luaClick = self.CreateAction(self, self.OnClickConfirmBtn)
	self.bindData.backBtn.luaClick = self.CreateAction(self, self.OnClickBackBtn)
	self.bindData.generateBtn.luaClick = self.CreateAction(self, self.OnClickGenerateBtn)
	self.bindData.styleList.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderStyleItem)
end

M.OnClickUndoBtn = function(self)
	if self.curStep ~= self.stepCtrlEnum.crafe then
		self.bindData.drawingBoard:Undo()
		self:RefreshButtonState()
	elseif self.curStep ~= self.stepCtrlEnum.AIshow and self.selectGenerateIndex <= 1 then
		self.selectGenerateIndex = self.selectGenerateIndex - 1

		self.UpdateGenerateShowImg(self)
		self.RefreshButtonState(self)
	end
end

M.OnClickRedoBtn = function(self)
	if self.curStep ~= self.stepCtrlEnum.crafe then
		self.bindData.drawingBoard:Redo()
		self:RefreshButtonState()
	elseif self.curStep ~= self.stepCtrlEnum.AIshow and self.selectGenerateIndex >= #self.aiGenerateRes then
		self.selectGenerateIndex = self.selectGenerateIndex + 1

		self.UpdateGenerateShowImg(self)
		self.RefreshButtonState(self)
	end
end

M.OnClickClearBtn = function(self)
	if self.curStep ~= self.stepCtrlEnum.crafe then
		self.bindData.drawingBoard:Clear()
		self:RefreshButtonState()
	end
end

M.OnClickConfirmBtn = function(self)
	if self.usingAi then
		if self.curStep ~= self.stepCtrlEnum.crafe then
			self.StepToChooseAI(self)
		elseif self.curStep ~= self.stepCtrlEnum.chooseAI then
			self.CompleteArt(self)
		elseif self.curStep ~= self.stepCtrlEnum.AIshow then
			self.CompleteArt(self)
		end
	else
		self.CompleteArt(self)
	end
end

M.OnClickBackBtn = function(self)
	if self.usingAi and self.curStep ~= self.stepCtrlEnum.chooseAI then
		self.curStep = self.stepCtrlEnum.crafe
		self.bindData.stepCtrl = self.curStep
	else
		local usedAi = self.curStep ~= self.stepCtrlEnum.AIpainting or self.curStep ~= self.stepCtrlEnum.AIshow
		local content = usedAi and self:GetText(89901840) or self:GetText(89901841)

		gDisplayMessageMgr:ShowMessageContent(content, gDisplayMessageId.SELECT, nil, function ()
			gPanelManager:Close(self.m_Id)
		end, nil, LTConfig.TextScriptTextConfig.GetConfig(89900149).Text, LTConfig.TextCommonTextConfig.GetConfig(74009093).Text)
	end
end

M.OnClickGenerateBtn = function(self)
	local selectIndex = self.bindData.styleList.selectedIndex + 1
	local cfgId = self.allStyle[selectIndex]

	if cfgId and cfgId <= 0 and (self.curStep ~= self.stepCtrlEnum.chooseAI or self.curStep ~= self.stepCtrlEnum.AIshow) then
		self.curStep = self.stepCtrlEnum.AIpainting
		self.bindData.stepCtrl = self.curStep
		slot3 = gClientToGameDelegate

		slot3:GetBeggarAiPaintingUploadUrl().Callback = function (err, urlInfo)
			if err == MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)

				return
			end

			if not self.isShow then
				return
			end

			self.uploadPresignedUrl = urlInfo.PresignedUrl
			self.uploadObjectKey = urlInfo.ObjectKey
			self.selectObjectKey = urlInfo.ObjectKey
			slot2 = self

			slot2:UploadImageToUrl(function (success, objectKey)
				if success then
					slot2 = gClientToGameDelegate

					slot2:GenerateBeggarAiPainting(self.uploadObjectKey, cfgId).Callback = function (err2)
						if err2 == MessageConfig.Ok then
							gDisplayMessageMgr:DisplayServerMessageId(err2)

							if self.isShow then
								self:AIGenerateFailed()
							end

							return
						end
					end
				else
					print_warn("Beggar, 上传绘制图片到oss失败！")

					if self.isShow then
						self:AIGenerateFailed()
					end
				end
			end)
		end
	end
end

M.OnRenderStyleItem = function(self, btn, index)
	local id = self.allStyle[index + 1]

	if not id then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local cfg = BeggarAiPaintingConfig.GetConfig(id)

	if cfg then
		store.name = cfg.Name
		store.icon = cfg.icon
	end
end

M.CompleteArt = function(self)
	slot1 = gDisplayMessageMgr

	slot1:ShowInputBox(self:GetText(89901842), nil, function (inputText)
		self.paintingName = inputText

		if not string.is_null_or_empty(self.paintingName) then
			self:ConfirmCompleteArt()
		end
	end, true)
end

M.ConfirmCompleteArt = function(self)
	if self.usedAi then
		slot1 = gClientToGameDelegate

		slot1:CompleteBeggarAiPainting(self.selectObjectKey, self.paintingName, true).Callback = function (err)
			if err == MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)

				return
			end
		end
	else
		slot1 = gClientToGameDelegate

		slot1:GetBeggarAiPaintingUploadUrl().Callback = function (err, urlInfo)
			if err == MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)

				return
			end

			if not self.isShow then
				return
			end

			self.uploadPresignedUrl = urlInfo.PresignedUrl
			self.uploadObjectKey = urlInfo.ObjectKey
			self.selectObjectKey = self.uploadObjectKey
			slot2 = self

			slot2:UploadImageToUrl(function (success, objectKey)
				if not success then
					print_warn("Beggar, 上传绘制图片到oss失败！")
				end

				slot2 = gClientToGameDelegate

				slot2:CompleteBeggarAiPainting(self.selectObjectKey, self.paintingName, false).Callback = function (err2)
					if err2 == MessageConfig.Ok then
						gDisplayMessageMgr:DisplayServerMessageId(err2)

						return
					end
				end
			end)
		end
	end
end

M.UploadImageToUrl = function(self, successCallback)
	if self.uploadPresignedUrl and self.uploadObjectKey then
		local paintData = self.bindData.drawingBoard:EncodeToPNG()

		LX6.Utils.AliOssManager.Instance:UploadFileToGivenUrl(self.uploadPresignedUrl, self.uploadObjectKey, paintData, nil, true, successCallback)
	end
end

M.ShowPanel = function(self, usingAI)
	self.curStep = self.stepCtrlEnum.crafe
	self.bindData.stepCtrl = self.curStep
	self.usingAi = usingAI
	self.usedAi = false

	self.bindData.drawingBoard:ReInitialize()
	self:RefreshButtonState()
	self.SubGroup.PaintingToolStore:InitData(0, self:CreateAction(self.OnColorChangedCallback), self:CreateAction(self.OnBrushThicknessChangedCallback), self:CreateAction(self.OnBrushChangedCallback), self:CreateAction(self.OnEraserSelectCallback), self:CreateAction(self.OnClickClearBtn))

	self.bindData.title = self.usingAi and self:GetText(89901839) or self:GetText(89901838)
	self.bindData.toolCtrl = 1
	self.aiGenerateRes = {}
	self.selectGenerateIndex = 1
end

M.OnColorChangedCallback = function(self, hex)
	self.isEraser = false
	self.colorHex = hex

	self.bindData.drawingBoard:SetBrushColor(Color.NewByStr(hex))
end

M.OnBrushThicknessChangedCallback = function(self, px)
	self.bindData.drawingBoard:SetBrushSize(px)
end

M.OnBrushChangedCallback = function(self, id)
	local brushCfg = BeggarDrawToolConfig.GetConfig(id)

	if brushCfg then
		self.bindData.drawingBoard:TrySetBrushByName(brushCfg.Name)
	end
end

M.OnEraserSelectCallback = function(self, isEraser)
	self.isEraser = isEraser
	local color = self.isEraser and Color.New(1, 1, 1, 1) or Color.NewByStr(self.colorHex)

	self.bindData.drawingBoard:SetBrushColor(color)
end

M.OnUpdate = function(self)
	self.RefreshButtonState(self)
end

M.RefreshButtonState = function(self)
	if self.curStep ~= self.stepCtrlEnum.crafe then
		self.bindData.redoBtn.interactable = self.bindData.drawingBoard:CanRedo()
		self.bindData.undoBtn.interactable = self.bindData.drawingBoard:CanUndo()
		self.bindData.confirmBtn.interactable = self.bindData.drawingBoard:GetDrawOperationNum() >= 0
		self.bindData.controllerEmptyCtrl = self.bindData.drawingBoard:CanUndo() and 0 or 1
	elseif self.curStep ~= self.stepCtrlEnum.AIshow then
		self.bindData.redoBtn.interactable = self.selectGenerateIndex <= #self.aiGenerateRes
		self.bindData.undoBtn.interactable = self.selectGenerateIndex >= 1
		self.bindData.confirmBtn.interactable = true
		self.bindData.controllerEmptyCtrl = 0
	else
		self.bindData.redoBtn.interactable = false
		self.bindData.undoBtn.interactable = false
		self.bindData.confirmBtn.interactable = false
		self.bindData.controllerEmptyCtrl = 0
	end
end

M.StepToChooseAI = function(self)
	self.curStep = self.stepCtrlEnum.chooseAI
	self.bindData.stepCtrl = self.curStep
	self.allStyle = {}
	local count = BeggarAiPaintingConfig.count

	for i = 0, count - 1 do
		local cfg = BeggarAiPaintingConfig.LoadAt(i)

		if cfg then
			table.insert(self.allStyle, cfg.Id)
		end
	end

	self.bindData.styleList:SetSimpleList(#self.allStyle)
	self.bindData.styleList:SelectItem(0, false)

	local itemData = gCommonItemManager:GetItemRenderData({
		["\\xd0\\xcf01\\xfc"] = 1,
		itemId = BeggarConfig.PaintingItem
	})

	gCommonItemManager:OnCommonItemRender(self.bindData.consumeItem, 0, itemData)
end

M.AIGenerateFailed = function(self)
	self.curStep = self.stepCtrlEnum.chooseAI
	self.bindData.stepCtrl = self.curStep
end

M.OnSyncBeggarAiPaintingDone = function(self, sourceObjectKey, resultObjectKey, success)
	if sourceObjectKey ~= self.uploadObjectKey then
		if success then
			self.usedAi = true
			self.curStep = self.stepCtrlEnum.AIshow
			self.bindData.stepCtrl = self.curStep

			table.insert(self.aiGenerateRes, resultObjectKey)

			self.selectGenerateIndex = #self.aiGenerateRes

			self.UpdateGenerateShowImg(self)
		else
			print_warn("Beggar, 伏羲AI生图失败！")

			if #self.aiGenerateRes <= 0 then
				self.curStep = self.stepCtrlEnum.AIshow
				self.bindData.stepCtrl = self.curStep

				self.UpdateGenerateShowImg(self)
			else
				self.AIGenerateFailed(self)
			end
		end
	end
end

M.UpdateGenerateShowImg = function(self)
	self.selectObjectKey = self.aiGenerateRes[self.selectGenerateIndex]
	self.bindData.showImg = self.selectObjectKey
end

M.GetText = function(self, textId)
	return TextScriptTextConfig.GetConfig(textId).Text
end
