local MessageConfig = LTConfig.MessageConfig
local SocialMediaConfig = LTConfig.SocialMediaConfig
local PhotoUtils = LX6.Utils.PhotoUtils
local INPUT_MAX_LENGTH = 42
C_SocialMediaReleasePanelStore = DefClass("C_SocialMediaReleasePanelStore", C_SocialMediaReleasePanelStore, C_StoreGroup)
GroupName2Class.SocialMediaReleasePanelStore = C_SocialMediaReleasePanelStore
local M = C_SocialMediaReleasePanelStore

function M:ctor()
	self.isCustomUpload = false
	self.fakePost = false
	self.customTargetData = nil
	self.customTargetType = nil
	self.closeCB = nil
	self.posted = false
	self.isLocalImage = false
	self.imageURL = nil
end

function M:OnAwake()
	self:RegisterButtons()
	self:RegisterInputField()
end

function M:OnShow(panelId, data)
	if not data then
		print_error("SocialMediaPostPanel data is nil")
		gPanelManager:Close(self.m_Id)
	end

	self:RefreshPlayerInfo()

	if data.texture then
		self:AdaptPhotoTex(data.texture)

		self.bindData.shareImage.texture = data.texture
		self.isLocalImage = true
	elseif data.imageURL then
		self.imageURL = data.imageURL
		self.bindData.shareImage.url = data.imageURL
	elseif data.SocialMediaId then
		self.fakePost = true
		local cfg = SocialMediaConfig.GetConfig(data.SocialMediaId)

		if not cfg then
			print_error("【配置错误】SocialMediaId不存在", data.SocialMediaId)
		else
			if cfg.Publisher ~= 1 then
				print_error("【配置错误】SocialMediaId =", data.SocialMediaId, "的发布者不是玩家")
			end

			local url = cfg.Image and #cfg.Image > 0 and cfg.Image[1]
			self.bindData.shareImage.url = url
			self.bindData.inputField.text = cfg.Txt
			self.bindData.inputField.interactable = false
		end
	end

	if data.params and next(data.params) then
		self.isCustomUpload = true
		self.customTargetData = data.params
		self.customTargetType = self.customTargetData.customTargetType
	else
		self.isCustomUpload = false
	end

	self.closeCB = data.CallBack
end

function M:OnClose()
	if self.closeCB then
		self.closeCB(self.posted)
	end

	self.postLock = false
end

function M:RegisterButtons()
	function self.bindData.closeBtn.luaClick()
		self.bindData.anim:Play("S_Vx_NewCommonWindow_Close")
		gLuaTimeMgrUtils.Delay(function ()
			gPanelManager:Close(self.m_Id)
		end, self.bindData.anim:GetClip("S_Vx_NewCommonWindow_Close").length)
	end

	function self.bindData.shareBtn.luaClick()
		if self.fakePost then
			self.posted = true

			self.bindData.anim:Play("S_Vx_NewCommonWindow_Close")
			gLuaTimeMgrUtils.Delay(function ()
				gPanelManager:Close(self.m_Id)
			end, self.bindData.anim:GetClip("S_Vx_NewCommonWindow_Close").length)
		else
			self:Post()
		end
	end
end

function M:RegisterInputField()
	self.bindData.inputField.maxLength = INPUT_MAX_LENGTH

	function self.bindData.inputField.luaExceedLength()
		self.bindData.numLimitTipCtrl = 1

		if self.timer then
			self.timer:Stop()

			self.timer = nil
		end

		self.timer = Timer.New(function ()
			self.bindData.numLimitTipCtrl = 0
			self.timer = nil
		end, 1):Start()
	end
end

function M:Post()
	if self.postLock then
		return
	end

	self.bindData.shareBtn.interactable = false
	self.postLock = true
	local text = self.bindData.inputField.text

	gNewBubbleMgr:EnvSdkTextFilter(text, function ()
		local bytes = PhotoUtils.EncodeToJPG(self.bindData.shareImage.texture)

		if self.isLocalImage then
			gImageManager:UploadNormalImage(bytes, function (success, url)
				if not success then
					print_error("图片上传失败", url)

					self.postLock = false
					self.bindData.shareBtn.interactable = true

					return
				end

				if self.isCustomUpload then
					self:CustomPost(url, text)

					return
				end

				gClientToGameDelegate:AskMomentsShareCustomPost(url, text).Callback = function (err, data)
					if err ~= MessageConfig.Ok then
						print_error("[DebugLog]动态失败", gCS.Error.GetNameById(err))

						self.postLock = false
						self.bindData.shareBtn.interactable = true

						return
					else
						self.posted = true
						self.postLock = false
						self.bindData.shareBtn.interactable = true

						self.bindData.anim:Play("S_Vx_NewCommonWindow_Close")
						gLuaTimeMgrUtils.Delay(function ()
							gPanelManager:Close(self.m_Id)
							gPanelManager:Close(gPanelId.S_PHOTO_POST_PROCESS_PANEL)
							gMessageManager:SendMessage(gEventConstants.CLOSE_PHOTO_PANEL)
							gClientUtils.CloseMainPhonePanel()
							gNewBubbleMgr:OpenMyPostPanel()
						end, self.bindData.anim:GetClip("S_Vx_NewCommonWindow_Close").length)
					end
				end
			end)
		else
			gClientToGameDelegate:AskMomentsShareCustomPost(self.imageURL, text).Callback = function (err, data)
				if err ~= MessageConfig.Ok then
					print_error("[DebugLog]动态失败", gCS.Error.GetNameById(err))

					self.postLock = false
					self.bindData.shareBtn.interactable = true

					return
				else
					self.posted = true
					self.postLock = false
					self.bindData.shareBtn.interactable = true

					self.bindData.anim:Play("S_Vx_NewCommonWindow_Close")
					gLuaTimeMgrUtils.Delay(function ()
						gPanelManager:Close(self.m_Id)
						gPanelManager:Close(gPanelId.S_PHOTO_POST_PROCESS_PANEL)
						gMessageManager:SendMessage(gEventConstants.CLOSE_PHOTO_PANEL)
						gClientUtils.CloseMainPhonePanel()
						gNewBubbleMgr:OpenMyPostPanel()
					end, self.bindData.anim:GetClip("S_Vx_NewCommonWindow_Close").length)
				end
			end
		end
	end, function ()
		self.postLock = false
		self.bindData.shareBtn.interactable = true

		gDisplayMessageMgr:ShowMessage(MessageConfig.SNSCheckFail)
	end)
end

function M:CustomPost(url, text)
	if self.customTargetType == gTakePhotoUtils.PhotoCustomTargetType.Npc then
		local isSelfIeMode = self.customTargetData.IsSelfIeMode
		self.customTargetData.IsSelfIeMode = nil
		self.customTargetData.customTargetType = nil

		for pid, _ in pairs(self.customTargetData) do
			local npcSpawn = gCS.SpoonAgentMgr:GetSpawn(pid)

			if not npcSpawn then
				-- Nothing
			else
				local cfgId = npcSpawn.spiritAcquisitionCfgId

				if cfgId > 0 then
					local function cb(err, data)
						if err ~= MessageConfig.Ok then
							print_error("[DebugLog]动态失败", gCS.Error.GetNameById(err))

							self.postLock = false
							self.bindData.shareBtn.interactable = true

							return
						else
							self.posted = true
							self.postLock = false

							if not gPanelManager:IsPanelShowing(self.m_Id) then
								return
							end

							self.bindData.shareBtn.interactable = true

							self.bindData.anim:Play("S_Vx_NewCommonWindow_Close")
							gLuaTimeMgrUtils.Delay(function ()
								gPanelManager:Close(self.m_Id)
								gPanelManager:Close(gPanelId.S_PHOTO_POST_PROCESS_PANEL)
								gMessageManager:SendMessage(gEventConstants.CLOSE_PHOTO_PANEL)
								gClientUtils.CloseMainPhonePanel()
								gNewBubbleMgr:OpenMyPostPanel()
							end, self.bindData.anim:GetClip("S_Vx_NewCommonWindow_Close").length)
						end
					end

					gClientToGameDelegate:AskPublishNpcMoment(cfgId, isSelfIeMode, url, text).Callback = cb
				end
			end
		end
	else
		self.bindData.shareBtn.interactable = true
		self.postLock = false

		print_error("未识别的目标类型：", self.customTargetType)
	end
end

function M:AdaptPhotoTex(tex)
	local X = tex.width
	local Y = tex.height
	local texX = self.bindData.shareImage:GetTargetWidth()
	local texY = self.bindData.shareImage:GetTargetHeight()
	local ratio = texX / texY
	local sRatio = X / Y

	if ratio < sRatio then
		texY = texX / sRatio
	else
		texX = texY * sRatio
	end

	self.bindData.shareImage.rectTransform.sizeDelta = Vector2.New(texX, texY)
end

function M:RefreshPlayerInfo()
	self.bindData.avatarId = gStoreStaticMethod:GetHeadIcon(gPlayerManager.infoLogin.bindData.infoPzHeadInfo.SystemHeadId)
	self.bindData.nameText = gPlayerManager.infoLogin.bindData.name
end
