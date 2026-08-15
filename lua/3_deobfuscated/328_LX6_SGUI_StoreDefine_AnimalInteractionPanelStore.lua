C_AnimalInteractionPanelStore = DefClass("C_AnimalInteractionPanelStore", C_AnimalInteractionPanelStore, C_StoreGroup)
GroupName2Class.AnimalInteractionPanelStore = C_AnimalInteractionPanelStore
local M = C_AnimalInteractionPanelStore
local InputButtonNameConfig = LTConfig.InputButtonNameConfig

function M:OnAwake()
	self.bindData.btn1.luaClick = self:CreateAction("OnClickInteractBtn1")
	self.bindData.btn2.luaClick = self:CreateAction("OnClickInteractBtn2")
	self.bindData.btn3.luaClick = self:CreateAction("OnClickInteractBtn3")
	self.bindData.btnRename.luaClick = self:CreateAction("OnRenameAnimal")
end

function M:OnShow(panelId, data)
	self.target = data.target
	self.interactUnit = data.unit

	self:RefreshMenus(data.menus)

	self.doingInteract = false
	self.emojiStartHideTime = 0
	self.emojiRealHideTime = 0
	self.playingEmojiCloseAnim = false

	gStoreManager:GetStoreGroup("GameplayHudPanelStore"):RegisterBtnBackCallback(self:CreateAction("OnBtnBack"))
	gPanelManager:SwitchPanelContext(gPanelId.S_GAMEPLAY_HUD_PANEL, 3)
end

function M:RefreshMenus(menus)
	self.renameMenu = nil
	self.interactMenus = {}

	for _, menu in ipairs(menus) do
		if menu.changeCatName then
			self.renameMenu = menu
		else
			table.insert(self.interactMenus, menu)
		end
	end
end

function M:OnClose()
	gPanelManager:SwitchPanelContext(gPanelId.S_GAMEPLAY_HUD_PANEL, 1)

	self.target = nil
	self.interactMenus = {}
	self.renameMenu = nil
	self.interactUnit = nil
	self.emojiStartHideTime = 0
	self.emojiRealHideTime = 0
	self.playingEmojiCloseAnim = false
end

function M:OnEnable()
	return
end

function M:OnStart()
	self:RefreshInteractButtons()

	self.bindData.renameControl = 0
end

function M:OnAnimalFavorChanged(menus)
	self:RefreshMenus(menus)
	self:RefreshInteractButtons()
end

function M:RefreshInteractButtons()
	if not self.STATE_EnableOnce then
		return
	end

	local naviIds = {
		4,
		1,
		3
	}

	for i = 1, 3 do
		local menu = self.interactMenus[i]

		if not menu then
			self.bindData["btn" .. i]:SetActive(false)
		else
			self.bindData["btn" .. i]:SetActive(true)

			self.bindData["btnText" .. i] = InputButtonNameConfig.GetConfig(menu.interactNameId).Name
			self.bindData["btnIcon" .. i] = menu.iconId

			self.bindData["btn" .. i]:SetPCKeyInfoTipNameId(menu.interactNameId)
			self.bindData.naviArea:ChangeButtonNameByActionId(naviIds[i], menu.interactNameId)
		end
	end

	if self.renameMenu then
		self.bindData.panelRename:SetActive(true)

		self.bindData.nameText = self.renameMenu.nickName
	else
		self.bindData.panelRename:SetActive(false)
	end
end

function M:SetDoingInteract(state)
	self.doingInteract = state
	self.bindData.interactStateCtrl = state and 1 or 0
end

function M:ShowEmoji(emojiId, duration)
	if not self.doingInteract then
		return
	end

	self.bindData.emojiIcon = emojiId
	self.emojiStartHideTime = uTime.timeSinceLevelLoad + duration
	self.emojiRealHideTime = self.emojiStartHideTime + self.bindData.emojiAnimation:GetClip("S_Vx_AnimalInteractionPanel_Emoji_close").length
end

function M:OnUpdate()
	if self.doingInteract then
		self:UpdateEmoji()
	else
		self.bindData.emojiCtrl = 0
		self.playingEmojiCloseAnim = false

		self:UpdateName()
	end
end

function M:UpdateEmoji()
	local now = uTime.timeSinceLevelLoad

	if not self.interactUnit then
		self.bindData.emojiCtrl = 0

		return
	end

	if self.emojiRealHideTime < now then
		self.bindData.emojiCtrl = 0
		self.playingEmojiCloseAnim = false
	elseif self.emojiStartHideTime < now then
		if not self.playingEmojiCloseAnim then
			self.playingEmojiCloseAnim = true

			gCS.LuaUtils.PlayAnimationByName(self.bindData.emojiAnimation, "S_Vx_AnimalInteractionPanel_Emoji_close")
		end
	else
		self.playingEmojiCloseAnim = false
		local emojiCtrl = self.bindData.emojiCtrl

		if emojiCtrl == 0 then
			gCS.LuaUtils.PlayAnimationByName(self.bindData.emojiAnimation, "S_Vx_AnimalInteractionPanel_Emoji_open")
		end

		self.bindData.emojiCtrl = 1
		local pos = self.interactUnit.HeadPos + Vector3.New(0, 0.2, 0)
		local localPos = gCS.LuaUtils.CalcPositionInScreen(self.bindData.emojiRootTransform, pos)
		self.bindData.emojiTransform.localPosition = localPos
	end
end

function M:UpdateName()
	if not self.renameMenu then
		return
	end

	local pos = self.interactUnit.HeadPos + Vector3.New(0, 0.5, 0)
	local screenPos = gCS.LuaUtils.CalcPositionInScreen(self.bindData.renameRootTransform, pos)
	self.bindData.renameTransform.localPosition = screenPos
end

function M:OnDisable()
	return
end

function M:OnDestroy()
	return
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end

function M:ClosePanel()
	gStoreManager:GetStoreGroup("GameplayHudPanelStore"):ClosePanel()
end

function M:OnClickInteractBtn1()
	self:OnClickInteractBtn(1)
end

function M:OnClickInteractBtn2()
	self:OnClickInteractBtn(2)
end

function M:OnClickInteractBtn3()
	self:OnClickInteractBtn(3)
end

function M:OnClickInteractBtn(index)
	local menu = self.interactMenus[index]

	if not menu then
		return
	end

	if self.target then
		self.target:OnSubClick(menu.interactionId)
	end
end

function M:OnRenameAnimal()
	if self.renameMenu and self.target then
		self.target:OnSubClick(self.renameMenu.interactionId)
	end
end

function M:OnBtnBack()
	self.target:StopAnimalInteraction()
	self:ClosePanel()
end
