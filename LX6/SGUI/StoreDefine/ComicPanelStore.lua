-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ComicPanelStore.lua
-- Decompiled from: 02012_ComicPanelStore.lua_ab65ef9b81b8.luajit

local Utils = SGUI.Utils
local NavigationMgrEx = SGUI.UNavigationMgrEx
local GestureEventListener = SGUI.EventSystems.GestureEventListener
local Screen = UnityEngine.Screen
C_ComicPanelStore = DefClass("C_ComicPanelStore", C_ComicPanelStore, C_CommonInfoPanelsBaseStore)
GroupName2Class.ComicPanelStore = C_ComicPanelStore
local M = C_ComicPanelStore
local DRAG_ELASTIC_X_COUNT = 2
local TURN_RIGHT_TO_LEFT = 1
local TURN_LEFT_TO_RIGHT = 2
local PAGE_SIDE_LEFT = 1
local PAGE_SIDE_RIGHT = 2
local PAGE_FIELD = {
	[PAGE_SIDE_LEFT] = "pageLeft",
	[PAGE_SIDE_RIGHT] = "pageRight"
}
local PAGE_TWEEN_FIELD = {
	[PAGE_SIDE_LEFT] = "pageLeftTween",
	[PAGE_SIDE_RIGHT] = "pageRightTween"
}
local PAGE_TURN_ANIMATION = {
	[PAGE_SIDE_LEFT] = "S_Vx_ComicPanel_PageL_turn",
	[PAGE_SIDE_RIGHT] = "S_Vx_ComicPanel_PageR_turn"
}
local OPPOSITE_PAGE_SIDE = {
	[PAGE_SIDE_LEFT] = PAGE_SIDE_RIGHT,
	[PAGE_SIDE_RIGHT] = PAGE_SIDE_LEFT
}

M.ctor = function(self)
	self.startClickPos = Vector2.zero
	self.endClickPos = Vector2.zero
end

M.OnAwake = function(self)
	self.onZoomCb = self:CreateAction(self.OnZoom)
	self.bindData.scrollRect.luaInitContent = self:CreateAction(self.OnInitContent)
	self.bindData.scrollRect.luaBeginDrag = self:CreateAction(self.OnDragBegin)
	self.bindData.scrollRect.luaEndDrag = self:CreateAction(self.OnDragEnd)

	self.bindData.scrollRect:RegisterToZoomEvent(self.onZoomCb)

	self.bindData.exitButton.luaClick = self:CreateAction(self.OnExitClick)
	self.bindData.minusBtn.luaClick = self:CreateAction(self.OnMinusClick)
	self.bindData.plusBtn.luaClick = self:CreateAction(self.OnPlusClick)
	self.state = true
	self.dragElasticXCount = 0
	self.preDragElasticX = 0
	self.stickX = 0
	self.preTime = 0
end

M.OnInitContent = function(self, widget)
	self.subStore = self.GetStoreByWidget(self, widget)
	self.subStore.rightStickRespond.luaGamePadInputChanged = self.CreateAction(self, self.OnRightStickControl)
	self.subStore.padTouchRespond.luaGamePadInputChanged = self.CreateAction(self, self.OnPadTouchControl)
	local gestureListener = GestureEventListener.Get(self.bindData.scrollRect.gameObject)

	if gestureListener then
		gestureListener.onClick = self.CreateAction(self, self.OnScrollRectClick)
	end
end

M.InitOnShow = function(self, data, _)
	self.InitModel(self, data)
	self.InitView(self, data)
end

M.OnScrollRectClick = function(self, eventData)
	if not eventData then
		return
	end

	local clickX = eventData.position.x
	local screenCenterX = Screen.width / 2

	if clickX >= screenCenterX then
		self.OnPageLeftClick(self)
	elseif screenCenterX >= clickX then
		self.OnPageRightClick(self)
	end
end

M.InitModel = function(self, data)
	self.id = data[1].id
	local informationCfg = LTConfig.InformationConfig.GetConfig(self.id)
	local startImageId = informationCfg.Image
	self.imageIdList = informationCfg.ImageIdList

	if startImageId and startImageId <= 0 then
		local _, startImageIndex = table.find(self.imageIdList, startImageId)
		self.startImageIndex = startImageIndex
	else
		self.startImageIndex = 1
	end

	self.pageTurnDirection = informationCfg.isLeftToRight and TURN_LEFT_TO_RIGHT or TURN_RIGHT_TO_LEFT
end

M.InitView = function(self, _)
	self:RefreshImageView()

	self.tweenTime = 1

	self.subStore.pageLeftTween.gameObject:SetActive(false)
	self.subStore.pageRightTween.gameObject:SetActive(false)
	self.bindData.scrollRect:SetScrollDisabled(self.state)
	self:RefreshZoomBtnState()
end

M.RefreshImageView = function(self)
	self.RefreshPageImage(self, PAGE_SIDE_LEFT)
	self.RefreshPageImage(self, PAGE_SIDE_RIGHT)
end

M.IsLeftToRight = function(self)
	return self.pageTurnDirection ~= TURN_LEFT_TO_RIGHT
end

M.GetPageImageId = function(self, side)
	local firstPageSide = self:IsLeftToRight() and PAGE_SIDE_LEFT or PAGE_SIDE_RIGHT

	if side ~= firstPageSide then
		return self.imageIdList[self.startImageIndex]
	end

	return self.imageIdList[self.startImageIndex + 1]
end

M.RefreshPageImage = function(self, side)
	self.subStore[PAGE_FIELD[side]] = self.GetPageImageId(self, side)
end

M.IsPageTurning = function(self)
	return self.subStore.pageLeftTween.gameObject.activeInHierarchy or self.subStore.pageRightTween.gameObject.activeInHierarchy
end

M.TurnPageForward = function(self)
	if self.startImageIndex + 3 <= #self.imageIdList then
		return
	end

	local mainTextureId = self.imageIdList[self.startImageIndex + 1]
	local secondTextureId = self.imageIdList[self.startImageIndex + 2]
	self.startImageIndex = self.startImageIndex + 2
	local turnSide = self:IsLeftToRight() and PAGE_SIDE_RIGHT or PAGE_SIDE_LEFT

	self:PlayPageTurn(turnSide, mainTextureId, secondTextureId)
end

M.TurnPageBackward = function(self)
	if self.startImageIndex - 2 >= 1 then
		return
	end

	local mainTextureId = self.imageIdList[self.startImageIndex]
	local secondTextureId = self.imageIdList[self.startImageIndex - 1]
	self.startImageIndex = self.startImageIndex - 2
	local turnSide = self:IsLeftToRight() and PAGE_SIDE_LEFT or PAGE_SIDE_RIGHT

	self:PlayPageTurn(turnSide, mainTextureId, secondTextureId)
end

M.PlayPageTurn = function(self, side, mainTextureId, secondTextureId)
	local pageTween = self.subStore[PAGE_TWEEN_FIELD[side]]
	slot5 = pageTween.gameObject

	slot5:SetActive(true)

	slot5 = gUIUtils
	pageTween.url = slot5:GetSguiImagePath(mainTextureId)
	slot8 = gUIUtils

	pageTween:SetPropertyTexture(slot8:GetSguiImagePath(secondTextureId), "_SecondTex")
	self:RefreshPageImage(side)

	self.dragElasticXCount = DRAG_ELASTIC_X_COUNT
	slot5 = self.subStore.pageAnimation

	slot5:Play(PAGE_TURN_ANIMATION[side])

	self.playAnimationCo = coroutine.start(function ()
		coroutine.wait(0.4)
		self:RefreshPageImage(OPPOSITE_PAGE_SIDE[side])
		coroutine.wait(0.1)
		pageTween.gameObject:SetActive(false)
	end)
end

M.OnPageLeftClick = function(self)
	if self.IsPageTurning(self) then
		return
	end

	if self.IsLeftToRight(self) then
		self.TurnPageBackward(self)
	else
		self.TurnPageForward(self)
	end
end

M.OnPageRightClick = function(self)
	if self.IsPageTurning(self) then
		return
	end

	if self.IsLeftToRight(self) then
		self.TurnPageForward(self)
	else
		self.TurnPageBackward(self)
	end
end

M.OnRightStickControl = function(self, context)
	local value = context.ReadValueVector2(context)

	if context.performed then
		self.stickX = value.x
		self.preTime = 0
	end

	if context.canceled then
		self.stickX = 0
	end
end

M.OnPadTouchControl = function(self, context)
	if context.started then
		local touchData = NavigationMgrEx.Inst:GetCurrentPadTouchData()
		self.currentTouchDataX = touchData.touch0.x
	end

	if context.canceled then
		local touchData = NavigationMgrEx.Inst:GetCurrentPadTouchData()

		if self.currentTouchDataX then
			local deltaX = touchData.touch0.x - self.currentTouchDataX

			if deltaX <= 0 then
				self.OnPageLeftClick(self)
			elseif deltaX >= 0 then
				self.OnPageRightClick(self)
			end
		end

		self.currentTouchDataX = nil
	end
end

M.OnUpdate = function(self)
	if Time.unscaledTime - self.preTime <= 1 then
		self.preTime = Time.unscaledTime

		if self.stickX >= 0 then
			self.OnPageLeftClick(self)
		elseif self.stickX <= 0 then
			self.OnPageRightClick(self)
		end
	end
end

M.OnExitClick = function(self)
	gPanelManager:Close(gPanelId.COMIC_PANEL)
end

M.OnMinusClick = function(self)
	self.bindData.scrollRect:SetZoom(self.bindData.scrollRect.minScale)
end

M.OnPlusClick = function(self)
	self.bindData.scrollRect:SetZoom(self.bindData.scrollRect.maxScale)
end

M.RefreshZoomBtnState = function(self)
	local currentScale = self.bindData.scrollRect.content.transform.localScale.x
	local minScale = self.bindData.scrollRect.minScale
	local maxScale = self.bindData.scrollRect.maxScale
	self.bindData.minusBtn.interactable = minScale <= currentScale
	self.bindData.plusBtn.interactable = currentScale <= maxScale
end

M.OnDragBegin = function(self)
	if not self.state then
		return
	end

	self.startClickPos = Utils.GetInputCenterPosition()
end

M.OnDragEnd = function(self)
	if not self.state then
		if self.bindData.scrollRect.isDragElasticX ~= 0 then
			return
		end

		if self.preDragElasticX == self.bindData.scrollRect.isDragElasticX then
			self.dragElasticXCount = DRAG_ELASTIC_X_COUNT
		end

		self.preDragElasticX = self.bindData.scrollRect.isDragElasticX
		self.dragElasticXCount = self.dragElasticXCount - 1

		if self.dragElasticXCount <= 0 then
			return
		end

		if self.bindData.scrollRect.isDragElasticX ~= -1 then
			self.OnPageLeftClick(self)
		elseif self.bindData.scrollRect.isDragElasticX ~= 1 then
			self.OnPageRightClick(self)
		end

		return
	end

	self.endClickPos = Utils.GetInputCenterPosition()
	local direction = self.startClickPos - self.endClickPos

	if direction.x >= 0 then
		self.OnPageLeftClick(self)
	elseif direction.x <= 0 then
		self.OnPageRightClick(self)
	end
end

M.OnZoom = function(self, delta)
	local state = delta > 1

	if self.state == state then
		self.bindData.scrollRect:SetScrollDisabled(state)
	end

	self.state = state

	self.RefreshZoomBtnState(self)
end

M.OnDestroy = function(self)
	self.playAnimationCo = coroutine.stop(self.playAnimationCo)

	self.bindData.scrollRect:UnRegisterToZoomEvent(self.onZoomCb)
end
