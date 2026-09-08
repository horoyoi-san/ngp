-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\SocialMediaReleasePanelStore.lua
-- Decompiled from: 01285_SocialMediaReleasePanelStore.lua_01a887be0faf.luajit

local MessageConfig = LTConfig.MessageConfig
local SocialMediaConfig = LTConfig.SocialMediaConfig
local PhotoUtils = LX6.Utils.PhotoUtils
local INPUT_MAX_LENGTH = 42
C_SocialMediaReleasePanelStore = DefClass("C_SocialMediaReleasePanelStore", C_SocialMediaReleasePanelStore, C_StoreGroup)
GroupName2Class.SocialMediaReleasePanelStore = C_SocialMediaReleasePanelStore
local M = C_SocialMediaReleasePanelStore

M.ctor = function(self)
	self.isCustomUpload = false
	self.fakePost = false
	self.customTargetData = nil
	self.customTargetType = nil
	self.closeCB = nil
	self.posted = false
	self.isLocalImage = false
	self.imageURL = nil
end

M.OnAwake = function(self)
	self.RegisterButtons(self)
	self.RegisterInputField(self)
end

M.OnShow = function(self, panelId, data)
	if not data then
		print_error("SocialMediaPostPanel data is nil")
		gPanelManager:Close(self.m_Id)
	end

	self.RefreshPlayerInfo(self)

	if data.texture then
		self.AdaptPhotoTex(self, data.texture)

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
			if cfg.Publisher == 1 then
				print_error("【配置错误】SocialMediaId =", data.SocialMediaId, "的发布者不是玩家")
			end

			local url = cfg.Image and #cfg.Image <= 0 and cfg.Image[1]
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

M.OnClose = function(self)
	if self.closeCB then
		self.closeCB(self.posted)
	end

	self.postLock = false
end

M.RegisterButtons = function(self)
	self.bindData.closeBtn.luaClick = function()
		slot0 = self.bindData.anim

		slot0:Play("S_Vx_NewCommonWindow_Close")

		slot3 = self.bindData.anim

		gLuaTimeMgrUtils.Delay(function ()
			gPanelManager:Close(self.m_Id)
		end, slot3:GetClip("S_Vx_NewCommonWindow_Close").length)
	end

	self.bindData.shareBtn.luaClick = function()
		if self.fakePost then
			self.posted = true
			slot0 = self.bindData.anim

			slot0:Play("S_Vx_NewCommonWindow_Close")

			slot3 = self.bindData.anim

			gLuaTimeMgrUtils.Delay(function ()
				gPanelManager:Close(self.m_Id)
			end, slot3:GetClip("S_Vx_NewCommonWindow_Close").length)
		else
			self:Post()
		end
	end
end

M.RegisterInputField = function(self)
	self.bindData.inputField.maxLength = INPUT_MAX_LENGTH

	self.bindData.inputField.luaExceedLength = function()
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

M.Post = function(self)
	if self.postLock then
		return
	end

	self.bindData.shareBtn.interactable = false
	self.postLock = true
	local text = self.bindData.inputField.text
	slot2 = gNewBubbleMgr

	slot2:EnvSdkTextFilter(text, function ()
		local bytes = PhotoUtils.EncodeToJPG(self.bindData.shareImage.texture)

		if self.isLocalImage then
			slot1 = gSocialFriendManager

			slot1:UploadLocalImage(bytes, function (success, url)
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

				slot2 = gClientToGameDelegate

				slot2:AskMomentsShareCustomPost(url, text).Callback = function (err, data)
					if err == MessageConfig.Ok then
						print_error("[DebugLog]动态失败", gCS.Error.GetNameById(err))

						self.postLock = false
						self.bindData.shareBtn.interactable = true

						return
					else
						self.posted = true
						self.postLock = false
						self.bindData.shareBtn.interactable = true
						slot2 = self.bindData.anim

						slot2:Play("S_Vx_NewCommonWindow_Close")

						slot5 = self.bindData.anim

						gLuaTimeMgrUtils.Delay(function ()
							gPanelManager:Close(self.m_Id)
							gPanelManager:Close(gPanelId.S_PHOTO_POST_PROCESS_PANEL)
							gMessageManager:SendMessage(gEventConstants.CLOSE_PHOTO_PANEL)
							gNewBubbleMgr:OpenMyPostPanel()
						end, slot5:GetClip("S_Vx_NewCommonWindow_Close").length)
					end
				end
			end)
		else
			slot1 = gClientToGameDelegate

			slot1:AskMomentsShareCustomPost(self.imageURL, text).Callback = function (err, data)
				if err == MessageConfig.Ok then
					print_error("[DebugLog]动态失败", gCS.Error.GetNameById(err))

					self.postLock = false
					self.bindData.shareBtn.interactable = true

					return
				else
					self.posted = true
					self.postLock = false
					self.bindData.shareBtn.interactable = true
					slot2 = self.bindData.anim

					slot2:Play("S_Vx_NewCommonWindow_Close")

					slot5 = self.bindData.anim

					gLuaTimeMgrUtils.Delay(function ()
						gPanelManager:Close(self.m_Id)
						gPanelManager:Close(gPanelId.S_PHOTO_POST_PROCESS_PANEL)
						gMessageManager:SendMessage(gEventConstants.CLOSE_PHOTO_PANEL)
						gNewBubbleMgr:OpenMyPostPanel()
					end, slot5:GetClip("S_Vx_NewCommonWindow_Close").length)
				end
			end
		end
	end, function ()
		self.postLock = false
		self.bindData.shareBtn.interactable = true

		gDisplayMessageMgr:ShowMessage(MessageConfig.SNSCheckFail)
	end)
end

M.CustomPost = function(self, url, text)
	if self.customTargetType ~= gTakePhotoUtils.PhotoCustomTargetType.Npc then
		local photoMode = self.customTargetData.PhotoMode
		self.customTargetData.PhotoMode = nil
		self.customTargetData.customTargetType = nil

		for pid, _ in pairs(self.customTargetData) do
			local npcSpawn = gCS.SpoonAgentMgr:GetSpawn(pid)

			if not npcSpawn then
				-- Nothing
			else
				local cfgId = npcSpawn.spiritAcquisitionCfgId

				if cfgId >= 0 then
					local cb = function(err, data)
						if err == MessageConfig.Ok then
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
								gNewBubbleMgr:OpenMyPostPanel()
							end, self.bindData.anim:GetClip("S_Vx_NewCommonWindow_Close").length)
						end
					end

					gClientToGameDelegate:AskPublishNpcMoment(cfgId, photoMode ~= 1, url, text).Callback = cb
				end
			end
		end
	else
		self.bindData.shareBtn.interactable = true
		self.postLock = false

		print_error("未识别的目标类型：", self.customTargetType)
	end
end

M.AdaptPhotoTex = function(self, tex)
	local X = tex.width
	local Y = tex.height
	local texX = self.bindData.shareImage:GetTargetWidth()
	local texY = self.bindData.shareImage:GetTargetHeight()
	local ratio = texX / texY
	local sRatio = X / Y

	if ratio >= sRatio then
		texY = texX / sRatio
	else
		texX = texY * sRatio
	end

	self.bindData.shareImage.rectTransform.sizeDelta = Vector2.New(texX, texY)
end

M.RefreshPlayerInfo = function(self)
	self.bindData.avatarId = gStoreStaticMethod:GetHeadIcon(gPlayerManager.infoLogin.bindData.infoPzHeadInfo.SystemHeadId)
	self.bindData.nameText = gPlayerManager.infoLogin.bindData.name
end
