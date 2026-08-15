local Utils = SGUI.Utils
local NavigationMgrEx = SGUI.UNavigationMgrEx
C_ComicPanelStore = DefClass("C_ComicPanelStore", C_ComicPanelStore, C_CommonInfoPanelsBaseStore)
GroupName2Class.ComicPanelStore = C_ComicPanelStore
local M = C_ComicPanelStore
local DRAG_ELASTIC_X_COUNT = 2

function M:ctor()
	self.startClickPos = Vector2.zero
	self.endClickPos = Vector2.zero
end

function M:OnAwake()
	self.onZoomCb = self:CreateAction(self.OnZoom)
	self.bindData.scrollRect.luaInitContent = self:CreateAction(self.OnInitContent)
	self.bindData.scrollRect.luaBeginDrag = self:CreateAction(self.OnDragBegin)
	self.bindData.scrollRect.luaEndDrag = self:CreateAction(self.OnDragEnd)

	self.bindData.scrollRect:RegisterToZoomEvent(self.onZoomCb)

	self.bindData.exitButton.luaClick = self:CreateAction(self.OnExitClick)
	self.state = true
	self.dragElasticXCount = 0
	self.preDragElasticX = 0
	self.stickX = 0
	self.preTime = 0
end

function M:OnInitContent(widget)
	self.subStore = self:GetStoreByWidget(widget)
	self.subStore.pageLeftButton.luaClick = self:CreateAction(self.OnPageLeftClick)
	self.subStore.pageRightButton.luaClick = self:CreateAction(self.OnPageRightClick)
	self.subStore.rightStickRespond.luaGamePadInputChanged = self:CreateAction(self.OnRightStickControl)
	self.subStore.padTouchRespond.luaGamePadInputChanged = self:CreateAction(self.OnPadTouchControl)
end

function M:InitOnShow(data, _)
	self:InitModel(data)
	self:InitView(data)
end

function M:InitModel(data)
	self.id = data[1].id
	local informationCfg = LTConfig.InformationConfig.GetConfig(self.id)
	local startImageId = informationCfg.Image
	self.imageIdList = informationCfg.ImageIdList

	if startImageId and startImageId > 0 then
		local _, startImageIndex = table.find(self.imageIdList, startImageId)
		self.startImageIndex = startImageIndex
	else
		self.startImageIndex = 1
	end
end

function M:InitView(_)
	self:RefreshImageView()

	self.tweenTime = 1

	self.subStore.pageLeftTween.gameObject:SetActive(false)
	self.subStore.pageRightTween.gameObject:SetActive(false)
	self.bindData.scrollRect:SetScrollDisabled(self.state)
end

function M:RefreshImageView()
	self.subStore.pageRight = self.imageIdList[self.startImageIndex]
	self.subStore.pageLeft = self.imageIdList[self.startImageIndex + 1]
end

function M:OnPageLeftClick()
	if self.subStore.pageLeftTween.gameObject.activeInHierarchy or self.subStore.pageRightTween.gameObject.activeInHierarchy then
		return
	end

	if self.startImageIndex + 3 <= #self.imageIdList then
		self.subStore.pageLeftTween.gameObject:SetActive(true)

		local mainTextureId = self.imageIdList[self.startImageIndex + 1]
		local mainTextureImageCfg = LTConfig.SguiImageConfig.GetConfig(mainTextureId)
		local mainTextureUrl = LX6.Manager.LocalizeManager.Instance:GetImagePath(mainTextureImageCfg.ImgPath)
		local secondTextureId = self.imageIdList[self.startImageIndex + 2]
		local secondTextureImageCfg = LTConfig.SguiImageConfig.GetConfig(secondTextureId)
		local secondTextureUrl = LX6.Manager.LocalizeManager.Instance:GetImagePath(secondTextureImageCfg.ImgPath)
		self.startImageIndex = self.startImageIndex + 2
		self.subStore.pageLeftTween.url = mainTextureUrl

		self.subStore.pageLeftTween:SetPropertyTexture(secondTextureUrl, "_SecondTex")

		self.subStore.pageLeft = self.imageIdList[self.startImageIndex + 1]
		self.dragElasticXCount = DRAG_ELASTIC_X_COUNT

		self.subStore.pageAnimation:Play("S_Vx_ComicPanel_PageL_turn")

		self.playAnimationCo = coroutine.start(function ()
			coroutine.wait(0.4)

			self.subStore.pageRight = self.imageIdList[self.startImageIndex]

			coroutine.wait(0.1)
			self.subStore.pageLeftTween.gameObject:SetActive(false)
		end)
	end
end

function M:OnPageRightClick()
	if self.subStore.pageLeftTween.gameObject.activeInHierarchy or self.subStore.pageRightTween.gameObject.activeInHierarchy then
		return
	end

	if self.startImageIndex - 2 >= 1 then
		self.subStore.pageRightTween.gameObject:SetActive(true)

		local mainTextureId = self.imageIdList[self.startImageIndex]
		local mainTextureImageCfg = LTConfig.SguiImageConfig.GetConfig(mainTextureId)
		local mainTextureUrl = LX6.Manager.LocalizeManager.Instance:GetImagePath(mainTextureImageCfg.ImgPath)
		local secondTextureId = self.imageIdList[self.startImageIndex - 1]
		local secondTextureImageCfg = LTConfig.SguiImageConfig.GetConfig(secondTextureId)
		local secondTextureUrl = LX6.Manager.LocalizeManager.Instance:GetImagePath(secondTextureImageCfg.ImgPath)
		self.startImageIndex = self.startImageIndex - 2
		self.dragElasticXCount = DRAG_ELASTIC_X_COUNT
		self.subStore.pageRightTween.url = mainTextureUrl

		self.subStore.pageRightTween:SetPropertyTexture(secondTextureUrl, "_SecondTex")

		self.subStore.pageRight = self.imageIdList[self.startImageIndex]

		self.subStore.pageAnimation:Play("S_Vx_ComicPanel_PageR_turn")

		self.playAnimationCo = coroutine.start(function ()
			coroutine.wait(0.4)

			self.subStore.pageLeft = self.imageIdList[self.startImageIndex + 1]

			coroutine.wait(0.1)
			self.subStore.pageRightTween.gameObject:SetActive(false)
		end)
	end
end

function M:OnRightStickControl(context)
	local value = context:ReadValueVector2()

	if context.performed then
		self.stickX = value.x
		self.preTime = 0
	end

	if context.canceled then
		self.stickX = 0
	end
end

function M:OnPadTouchControl(context)
	if context.started then
		local touchData = NavigationMgrEx.Inst:GetCurrentPadTouchData()
		self.currentTouchDataX = touchData.touch0.x
	end

	if context.canceled then
		local touchData = NavigationMgrEx.Inst:GetCurrentPadTouchData()

		if self.currentTouchDataX then
			local deltaX = touchData.touch0.x - self.currentTouchDataX

			if deltaX > 0 then
				self:OnPageLeftClick()
			elseif deltaX < 0 then
				self:OnPageRightClick()
			end
		end

		self.currentTouchDataX = nil
	end
end

function M:OnUpdate()
	if Time.unscaledTime - self.preTime > 1 then
		self.preTime = Time.unscaledTime

		if self.stickX < 0 then
			self:OnPageLeftClick()
		elseif self.stickX > 0 then
			self:OnPageRightClick()
		end
	end
end

function M:OnExitClick()
	gPanelManager:Close(gPanelId.COMIC_PANEL)
end

function M:OnDragBegin()
	if not self.state then
		return
	end

	self.startClickPos = Utils.GetInputCenterPosition()
end

function M:OnDragEnd()
	if not self.state then
		if self.bindData.scrollRect.isDragElasticX == 0 then
			return
		end

		if self.preDragElasticX ~= self.bindData.scrollRect.isDragElasticX then
			self.dragElasticXCount = DRAG_ELASTIC_X_COUNT
		end

		self.preDragElasticX = self.bindData.scrollRect.isDragElasticX
		self.dragElasticXCount = self.dragElasticXCount - 1

		if self.dragElasticXCount > 0 then
			return
		end

		if self.bindData.scrollRect.isDragElasticX == -1 then
			self:OnPageLeftClick()
		elseif self.bindData.scrollRect.isDragElasticX == 1 then
			self:OnPageRightClick()
		end

		return
	end

	self.endClickPos = Utils.GetInputCenterPosition()
	local direction = self.startClickPos - self.endClickPos

	if direction.x < 0 then
		self:OnPageLeftClick()
	elseif direction.x > 0 then
		self:OnPageRightClick()
	end
end

function M:OnZoom(delta)
	local state = delta <= 1

	if self.state ~= state then
		self.bindData.scrollRect:SetScrollDisabled(state)
	end

	self.state = state
end

function M:OnDestroy()
	self.playAnimationCo = coroutine.stop(self.playAnimationCo)

	self.bindData.scrollRect:UnRegisterToZoomEvent(self.onZoomCb)
end
