-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\TouTingPanelStore.lua
-- Decompiled from: 01370_TouTingPanelStore.lua_50df233d12a7.luajit

C_TouTingPanelStore = DefClass("C_TouTingPanelStore", C_TouTingPanelStore, C_StoreGroup)
GroupName2Class.TouTingPanelStore = C_TouTingPanelStore
local M = C_TouTingPanelStore
local MartialArtistgossipConfig = LTConfig.MartialArtistgossipConfig
local MartialArtistdialogConfig = LTConfig.MartialArtistdialogConfig
local MartialArtistRumorConfig = LTConfig.MartialArtistRumorConfig
local MartialArtistConfig = LTConfig.MartialArtistConfig
local MyPlayerManager = gCS.MyPlayerManager
local CameraDataMgr = gCS.CameraDataMgr

M.ctor = function(self)
	self.playedDialog = {}
end

M.DefineAllVariables = function(self)
	self.rightStickValue = {
		["\\xd5"] = 0,
		["\\xd4"] = 0
	}
	self.gamepadUpdateRotate = false
	self.gamepadMode = false
	self.findStageMaxNum = 3
	self.STAGE = {
		["]P~"] = 1,
		["l\\x82\\x8b\\x88\\x98"] = 0,
		["I\nRl"] = 2
	}
	self.freeListPos = {}
	self.PLAYER_SIGNAL = {
		["_To"] = 55127,
		["h\\x80\\x96\\x8a\\x84"] = 55126
	}
end

M.DefineAllEnumsAutoGen = function(self)
	self.finishCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.lockCtrlCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 1,
		["r\\xba\\xb0\\xba\\xb3"] = 0
	}
	self.correctCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.modeCtrlEnum = {
		["\\x99!,3{\\x92S\\xcb2\\xa9\\xad"] = 2,
		["#N\\x90\\x82\\x90D"] = 0,
		["\\T˾\\x8b\\xaa\\xca\\xfc"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.finishCtrlEnum = nil
	self.lockCtrlCtrlEnum = nil
	self.correctCtrlEnum = nil
	self.modeCtrlEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	self.isShow = true

	LX6.TouchNew.TouchProxy.SetJoyStickViewRotateContent(self.m_Id, 1)
	self:InitContent(data)

	self.gamepadMode = SGUI.GameDevice.KeyboardMouse <= gCS.LuaUtils.GetActiveDevice()

	gCS.LogicStateMachineManager.SendGameplayInwardSignal(MyPlayerManager.PlayerUnit, self.PLAYER_SIGNAL.ENTER)
end

M.OnClose = function(self)
	self.isShow = false

	if self.showCo then
		coroutine.stop(self.showCo)

		self.showCo = nil
	end

	self.gossipData = nil
	self.curGameData = nil
	self.dialogs = nil
	self.dataReady = nil
	self.curStage = nil
	self.minCheckDis = nil
	self.rotateMulti = nil
	self.maxCheckDis = nil
	self.scaleCheckRange = nil
	self.rotateCheckRange = nil
	self.alignmentWaitTime = nil
	self.curAlignmentWaitTime = nil
	self.curAlignId = nil
	self.waitShowTime = nil
	self.curWaitShowTime = nil
	self.centerWidthPercent = nil
	self.centerHeightPercent = nil
	self.rotateSpeed = nil
	self.messageWaitTime = nil
	self.dialogNextWaitTime = nil
	self.centerX = nil
	self.centerY = nil
	self.halfWidth = nil
	self.halfHeight = nil
	self.bestFitScale = nil
	self.maxFitScale = nil
	self.showDialogNum = nil
	self.readyNum = nil
	self.lastShowDialog = nil
	self.gossipRumors = nil
	self.freeListPos = nil
	self.freePosGeo = nil

	self.EnableHudBtn(self)
	gCS.LogicStateMachineManager.SendGameplayInwardSignal(MyPlayerManager.PlayerUnit, self.PLAYER_SIGNAL.EXIT)
end

M.OnActiveDeviceChange = function(self, device)
	self.gamepadMode = SGUI.GameDevice.KeyboardMouse <= device
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.ON_MARTIAL_ARTIST_RUMOR_BACKPACK_CHANGED] = self.CreateAction(self, self.RefreshRumorsUnlockState)
	}
end

M.RegisterWidget = function(self)
	self.bindData.clockwiseBtn.luaPress = self.CreateAction(self, self.OnPressClockwiseBtn)
	self.bindData.clockwiseBtn.luaRelease = self.CreateAction(self, self.OnReleaseClockwiseBtn)
	self.bindData.counterClockwiseBtn.luaPress = self.CreateAction(self, self.OnPressCounterClockwiseBtn)
	self.bindData.counterClockwiseBtn.luaRelease = self.CreateAction(self, self.OnReleaseCounterClockwiseBtn)
	self.bindData.backBtn.luaClick = self.CreateAction(self, self.OnClickBackBtn)

	if self.bindData.mobileRotateSlider then
		self.bindData.mobileRotateSlider.luaValueChanged = self.CreateAction(self, self.OnMobileRotateSliderValueChanged)
	end

	if self.bindData.mouseScrollCustomNavRespond then
		self.bindData.mouseScrollCustomNavRespond.luaGamePadInputChanged = self.CreateAction(self, self.OnMouseScrollCustomNavRespondInputChanged)
	end

	if self.bindData.padScaleCustomNavRespond then
		self.bindData.padScaleCustomNavRespond.luaGamePadInputChanged = self.CreateAction(self, self.OnPadScaleCustomNavRespondInputChanged)
	end

	if self.bindData.cameraRotateRespond then
		self.bindData.cameraRotateRespond.luaGamePadInputChanged = self.CreateAction(self, "OnRightStickControl")
	end

	self.bindData.freeList.luaRenderItem = self.CreateAction(self, "OnRenderFreeListItem")

	self.bindData.freeList.onGetTIndex = function(_)
		return 0
	end
end

M.OnPressClockwiseBtn = function(self)
	self.rotateMulti = -1
end

M.OnReleaseClockwiseBtn = function(self)
	self.rotateMulti = 0
end

M.OnPressCounterClockwiseBtn = function(self)
	self.rotateMulti = 1
end

M.OnReleaseCounterClockwiseBtn = function(self)
	self.rotateMulti = 0
end

M.OnClickBackBtn = function(self)
	gPanelManager:Close(self.m_Id)
end

M.OnMobileRotateSliderValueChanged = function(self, value)
	if self.curStage == self.STAGE.GAME then
		return
	end

	self.curFitScale = value

	self.UpdateOutCircleScale(self, 0)
end

M.OnMouseScrollCustomNavRespondInputChanged = function(self, context)
	local value = context.ReadValueVector2(context)

	if context.started or context.performed then
		self.UpdateOutCircleScale(self, value.y / 10000)
	end
end

M.OnPadScaleCustomNavRespondInputChanged = function(self, context)
	local value = context.ReadValueFloat(context)

	if context.started or context.performed then
		self.UpdateOutCircleScale(self, value / 100)
	end
end

M.OnRenderFreeListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local showType = 0

	if self.curStage ~= self.STAGE.SHOW then
		showType = 2
	elseif self.curStage ~= self.STAGE.GAME then
		showType = 1
	end

	if showType ~= 2 then
		local dialogId = self.dialogs[index + 1]
		local dialogCfg = MartialArtistdialogConfig.GetConfig(dialogId)

		if dialogCfg.RumorId <= 0 then
			local rumorCfg = MartialArtistRumorConfig.GetConfig(dialogCfg.RumorId)
			store.clueCtrl = 1
			store.clueTypeCtrl = 0

			if rumorCfg then
				if rumorCfg.SlotType ~= MartialArtistRumorConfig.SlotTypeType.who then
					store.clueTypeCtrl = 0
				elseif rumorCfg.SlotType ~= MartialArtistRumorConfig.SlotTypeType.where then
					store.clueTypeCtrl = 1
				else
					store.clueTypeCtrl = 2
				end
			end
		else
			store.clueCtrl = 0
		end

		store.modeCtrl = self.readyNum
		store.content = dialogCfg.Content:gsub("#m", "")
	elseif showType ~= 1 then
		local dialogId = self.dialogs[index + 1]
		local dialogCfg = MartialArtistdialogConfig.GetConfig(dialogId)

		if dialogCfg.RumorId <= 0 then
			local rumorCfg = MartialArtistRumorConfig.GetConfig(dialogCfg.RumorId)
			store.clueCtrl = 1
			store.clueTypeCtrl = 0

			if rumorCfg then
				if rumorCfg.SlotType ~= MartialArtistRumorConfig.SlotTypeType.who then
					store.clueTypeCtrl = 0
				elseif rumorCfg.SlotType ~= MartialArtistRumorConfig.SlotTypeType.where then
					store.clueTypeCtrl = 1
				else
					store.clueTypeCtrl = 2
				end
			end
		else
			store.clueCtrl = 0
		end

		store.modeCtrl = self.readyNum
		store.content = dialogCfg.Content
	else
		store.clueCtrl = 0
		store.clueTypeCtrl = 0
		store.modeCtrl = self.readyNum
		store.content = ""
	end

	local pos = self.freeListPos[index + 1]
	pos = pos or self:GetRandomPos(btn, index + 1)
	btn.rectTransform.anchoredPosition = Vector2.New(pos.x, pos.y)

	if index + 1 ~= self.showDialogNum then
		store.AnimRoot.renderOpacity = 0

		store.Anim:Play("S_Vx_Dialog18Panel_open_TR")
	end
end

M.EnsureFreePosGeo = function(self, parentRect)
	local screenW = UnityEngine.Screen.width
	local screenH = UnityEngine.Screen.height
	local geo = self.freePosGeo

	if geo and geo.screenW ~= screenW and geo.screenH ~= screenH then
		return geo
	end

	local uiScreenA = gCS.LuaUtils.TransformScreenPointToUI(parentRect, Vector3.New(0, 0, 0))
	local uiScreenB = gCS.LuaUtils.TransformScreenPointToUI(parentRect, Vector3.New(screenW, screenH, 0))
	local uiCenter = gCS.LuaUtils.TransformScreenPointToUI(parentRect, Vector3.New(self.centerX, self.centerY, 0))
	local uiTop = gCS.LuaUtils.TransformScreenPointToUI(parentRect, Vector3.New(self.centerX, screenH, 0))
	local uiDetA = gCS.LuaUtils.TransformScreenPointToUI(parentRect, Vector3.New(self.centerX - self.halfWidth, self.centerY - self.halfHeight, 0))
	local uiDetB = gCS.LuaUtils.TransformScreenPointToUI(parentRect, Vector3.New(self.centerX + self.halfWidth, self.centerY + self.halfHeight, 0))
	geo = {
		screenW = screenW,
		screenH = screenH,
		uiMinX = math.min(uiScreenA.x, uiScreenB.x),
		uiMaxX = math.max(uiScreenA.x, uiScreenB.x),
		uiMinY = math.min(uiScreenA.y, uiScreenB.y),
		uiMaxY = math.max(uiScreenA.y, uiScreenB.y),
		detMinX = math.min(uiDetA.x, uiDetB.x),
		detMaxX = math.max(uiDetA.x, uiDetB.x),
		detMinY = math.min(uiDetA.y, uiDetB.y),
		detMaxY = math.max(uiDetA.y, uiDetB.y),
		topDir = uiCenter.y < uiTop.y and 1 or -1,
		topBoundaryY = uiCenter.y
	}
	self.freePosGeo = geo

	return geo
end

M.GetRandomPos = function(self, btn, index)
	local desiredWidth = btn.GetTargetWidth(btn)
	local desiredHeight = btn.GetTargetHeight(btn)
	local halfW = desiredWidth * 0.5
	local halfH = desiredHeight * 0.5
	local geo = self.EnsureFreePosGeo(self, btn.rectTransform.parent)
	local axMinX = geo.uiMinX + halfW
	local axMaxX = geo.uiMaxX - halfW
	local ayMinY, ayMaxY = nil

	if geo.topDir ~= 1 then
		ayMinY = geo.topBoundaryY + halfH
		ayMaxY = geo.uiMaxY - halfH
	else
		ayMinY = geo.uiMinY + halfH
		ayMaxY = geo.topBoundaryY - halfH
	end

	local fX0 = geo.detMinX - halfW
	local fX1 = geo.detMaxX + halfW
	local fY0 = geo.detMinY - halfH
	local fY1 = geo.detMaxY + halfH
	local rects = {}
	local totalArea = 0

	local addRect = function(x0, x1, y0, y1)
		if x0 >= x1 and y0 >= y1 then
			local area = (x1 - x0) * (y1 - y0)
			rects[#rects + 1] = {
				x0 = x0,
				x1 = x1,
				y0 = y0,
				y1 = y1,
				area = area
			}
			totalArea = totalArea + area
		end
	end

	local midX0 = math.max(axMinX, fX0)
	local midX1 = math.min(axMaxX, fX1)

	addRect(axMinX, math.min(axMaxX, fX0), ayMinY, ayMaxY)
	addRect(math.max(axMinX, fX1), axMaxX, ayMinY, ayMaxY)
	addRect(midX0, midX1, math.max(ayMinY, fY1), ayMaxY)
	addRect(midX0, midX1, ayMinY, math.min(ayMaxY, fY0))

	local placed = {}

	for i, p in pairs(self.freeListPos) do
		if i == index and p and p.halfW then
			placed[#placed + 1] = p
		end
	end

	local overlapArea = function(cx, cy)
		local total = 0

		for k = 1, #placed do
			local p = placed[k]
			local ox = math.min(cx + halfW, p.x + p.halfW) - math.max(cx - halfW, p.x - p.halfW)
			local oy = math.min(cy + halfH, p.y + p.halfH) - math.max(cy - halfH, p.y - p.halfH)

			if ox <= 0 and oy <= 0 then
				total = total + ox * oy
			end
		end

		return total
	end

	local chosenX, chosenY = nil

	if totalArea <= 0 then
		local bestX, bestY = nil
		local bestOverlap = math.huge
		local attempts = 32

		for _ = 1, attempts do
			local t = math.random() * totalArea
			local pick = rects[#rects]

			for _, r in ipairs(rects) do
				if t < r.area then
					pick = r

					break
				end

				t = t - r.area
			end

			local cx = pick.x0 + math.random() * (pick.x1 - pick.x0)
			local cy = pick.y0 + math.random() * (pick.y1 - pick.y0)
			local ov = overlapArea(cx, cy)

			if ov < 0 then
				chosenY = cy
				chosenX = cx

				break
			elseif ov >= bestOverlap then
				bestY = cy
				bestX = cx
				bestOverlap = ov
			end
		end

		if not chosenX then
			chosenY = bestY
			chosenX = bestX
		end
	else
		chosenX = axMinX < axMaxX and axMinX + math.random() * (axMaxX - axMinX) or (geo.uiMinX + geo.uiMaxX) * 0.5

		if ayMinY < ayMaxY then
			chosenY = geo.topDir ~= 1 and ayMaxY or ayMinY
		else
			chosenY = geo.topDir ~= 1 and geo.uiMaxY - halfH or geo.uiMinY + halfH
		end
	end

	local pos = {
		x = chosenX,
		y = chosenY,
		halfW = halfW,
		halfH = halfH,
		width = desiredWidth,
		height = desiredHeight
	}
	self.freeListPos[index] = pos

	return pos
end

M.InitContent = function(self, gossipId)
	self.dataReady = false

	if gossipId and #gossipId <= 0 then
		self.curStage = self.STAGE.ALIGN
		self.minCheckDis = MartialArtistConfig.TouTingMinCheckDis
		self.rotateMulti = 0
		self.maxCheckDis = MartialArtistConfig.TouTingMaxCheckDis
		self.scaleCheckRange = MartialArtistConfig.TouTingScaleCheckRange
		self.rotateCheckRange = MartialArtistConfig.TouTingRotateCheckRange
		self.alignmentWaitTime = MartialArtistConfig.TouTingAlignmentWaitTime
		self.curAlignmentWaitTime = nil
		self.curAlignId = nil
		self.waitShowTime = MartialArtistConfig.TouTingWaitShowDialogTime
		self.curWaitShowTime = nil
		self.centerWidthPercent = MartialArtistConfig.TouTingCenterWidthCheckPercent
		self.centerHeightPercent = MartialArtistConfig.TouTingCenterHeightCheckPercent
		self.rotateSpeed = MartialArtistConfig.TouTingRotateSpeed
		self.messageWaitTime = MartialArtistConfig.TouTingMsgWaitTime
		self.dialogNextWaitTime = MartialArtistConfig.TouTingNextDialogWaitTime
		self.centerX = UnityEngine.Screen.width / 2
		self.centerY = UnityEngine.Screen.height / 2
		self.halfWidth = UnityEngine.Screen.width * self.centerWidthPercent / 2
		self.halfHeight = UnityEngine.Screen.height * self.centerHeightPercent / 2
		self.bestFitScale = 0.66
		self.maxFitScale = 1
		self.showDialogNum = 0
		self.readyNum = 0
		self.lastShowDialog = 0
		self.gossipData = {}

		for i = 1, #gossipId do
			local id = gossipId[i]
			local cfg = MartialArtistgossipConfig.GetConfig(id)

			if cfg then
				local gossipPos = Vector3.New(cfg.Position[1], cfg.Position[2], cfg.Position[3])

				table.insert(self.gossipData, {
					["\\xeb\\x9b\\xf8/\\xe9΁\\xec\\x8e//"] = 0,
					gossipId = id,
					position = gossipPos
				})
			end
		end

		self.dataReady = #self.gossipData >= 0
		self.bindData.targetBtn.interactable = false
		self.bindData.lockCtrl = self.lockCtrlCtrlEnum._true

		self.bindData.freeList:SetList(0)
		self:RefreshRumorsUnlockState()
		self.bindData.targetBtn:SetActive(self.dataReady)
	else
		print_error("武士偷听玩法打开失败，没有群组id传入！")
		self.bindData.targetBtn:SetActive(false)
	end
end

M.OnUpdate = function(self)
	if self.gamepadMode then
		self.UpdateCameraRotateGamePad(self)
	end

	if self.dataReady then
		self.CheckGossipPosition(self)

		if self.curStage ~= self.STAGE.GAME then
			self.UpdateOutCircleRotate(self)
			self.CheckReady(self)
		end

		self.RefreshLockHUDButtons(self)
	end
end

M.CheckGossipPosition = function(self)
	local mainCamera = CameraDataMgr.MainCamera

	if not mainCamera then
		self.curAlignId = nil

		self.bindData.targetBtn:SetActive(false)

		return
	end

	local playerUnit = MyPlayerManager.PlayerUnit

	if not playerUnit then
		self.curAlignId = nil

		self.bindData.targetBtn:SetActive(false)

		return
	end

	local playerPos = playerUnit.PlayerObj.position
	local bestData = nil
	local bestScreenX = 0
	local bestScreenY = 0
	local bestDeltaX = 0
	local bestDeltaY = 0
	local bestScreenDisSqr = math.huge

	for i = 1, #self.gossipData do
		local data = self.gossipData[i]
		data.playerDis = Vector3.Distance(playerPos, data.position)

		if data.playerDis < self.maxCheckDis and self.minCheckDis < data.playerDis then
			local x, y, z = gCS.LuaUtils.WorldToScreenPointProjected(data.position, mainCamera, 0, 0, 0)
			local deltaX = math.abs(x - self.centerX)
			local deltaY = math.abs(y - self.centerY)
			local screenDisSqr = deltaX * deltaX + deltaY * deltaY

			if bestScreenDisSqr <= screenDisSqr then
				bestScreenDisSqr = screenDisSqr
				bestScreenX = x
				bestScreenY = y
				bestDeltaX = deltaX
				bestDeltaY = deltaY
				bestData = data
			end
		end
	end

	if bestData then
		local UIPos = gCS.LuaUtils.TransformScreenPointToUI(self.bindData.targetBtn.transform.parent, Vector3.New(bestScreenX, bestScreenY, 0))

		self.bindData.targetBtn.transform:SetLocalPositionXY(UIPos.x, UIPos.y)
		self.bindData.targetBtn:SetActive(true)

		if bestDeltaX < self.halfWidth and bestDeltaY < self.halfHeight then
			if self.curAlignId ~= bestData.gossipId then
				if self.curStage ~= self.STAGE.ALIGN then
					self.curAlignmentWaitTime = self.curAlignmentWaitTime - Time.deltaTime

					if self.curAlignmentWaitTime >= 0 then
						self.InitCheckGame(self, bestDeltaX, bestDeltaY, bestData)
					end
				end
			else
				self.curAlignId = bestData.gossipId
				self.curAlignmentWaitTime = self.alignmentWaitTime

				self.CheckLostAlign(self)
			end
		else
			self.curAlignId = nil

			self.CheckLostAlign(self)
		end
	else
		self.curAlignId = nil

		self.bindData.targetBtn:SetActive(false)
		self:CheckLostAlign()
	end
end

M.CheckLostAlign = function(self)
	if self.curStage == self.STAGE.ALIGN then
		self.curStage = self.STAGE.ALIGN
		self.bindData.modeCtrl = self.modeCtrlEnum._false
		self.bindData.correctCtrl = self.correctCtrlEnum._false
		self.bindData.lockCtrl = self.lockCtrlCtrlEnum._true
		self.bindData.targetBtn.interactable = false

		self.RefreshClueDialog(self, 0)
		self.RefreshRumorsUnlockState(self)
	end
end

M.RefreshLockHUDButtons = function(self)
	if self.curStage ~= self.STAGE.GAME then
		self.DisableHudBtn(self)
	else
		self.EnableHudBtn(self)
	end
end

M.DisableHudBtn = function(self)
	if not self.buttonBanId then
		self.buttonBanId = gStoreButtonMgr:RegisterOperation({
			["\\xca\\xcf\t\r\\xf5"] = 5,
			["\\xbb\\xa3\\xa4x7\\xea*"] = 1,
			groupId = LTConfig.HudDescGroupConfig.AllChar3CBattle
		})
	end
end

M.EnableHudBtn = function(self)
	if self.buttonBanId then
		gStoreButtonMgr:UnRegisterOperation(self.buttonBanId)

		self.buttonBanId = nil
	end
end

M.InitCheckGame = function(self, deltaX, deltaY, data)
	self.curStage = self.STAGE.GAME
	self.curWaitShowTime = nil
	self.curFitScale = (1 - data.playerDis / (self.maxCheckDis - self.minCheckDis)) * (self.maxFitScale - self.bestFitScale) + self.bestFitScale
	local len = math.sqrt(deltaX * deltaX + deltaY * deltaY)
	local max = math.sqrt(self.halfWidth * self.halfWidth + self.halfHeight * self.halfHeight)
	self.targetRotate = len / max * 180
	self.curRotate = 0

	math.randomseed(os.time())

	self.initRotate = math.random() * 180
	self.bindData.targetBtn.interactable = true

	self.bindData.outCircleTrans:SetLocalScale(self.curFitScale, self.curFitScale, self.curFitScale)
	self.bindData.outCircleTrans:SetLocalEulerAnglesZ(self.curRotate + self.initRotate)

	if gCS.LuaUtils.IsMobilePlatform() then
		self.bindData.mobileRotateSlider:SetValueWithParams(self.curFitScale, self.bestFitScale, self.maxFitScale, 0.01, false)
	end

	self.bindData.modeCtrl = self.modeCtrlEnum._false
	self.bindData.correctCtrl = self.correctCtrlEnum._false
	self.bindData.lockCtrl = self.lockCtrlCtrlEnum._false

	self.InitClueDialogData(self, data, true)
end

M.UpdateOutCircleRotate = function(self)
	if self.curStage ~= self.STAGE.GAME and self.rotateMulti == 0 then
		self.curRotate = self.curRotate + self.rotateSpeed * Time.deltaTime * self.rotateMulti

		if self.curRotate >= 0 then
			self.curRotate = self.curRotate + 180
		elseif self.curRotate <= 180 then
			self.curRotate = self.curRotate - 180
		end

		self.bindData.outCircleTrans:SetLocalEulerAnglesZ(self.curRotate + self.initRotate)
	end
end

M.UpdateOutCircleScale = function(self, delta)
	if self.curStage ~= self.STAGE.GAME then
		self.curFitScale = math.max(self.bestFitScale, math.min(self.maxFitScale, self.curFitScale + delta))

		self.bindData.outCircleTrans:SetLocalScale(self.curFitScale, self.curFitScale, self.curFitScale)
	end
end

M.CheckReady = function(self)
	self.readyNum = 0

	if self.curFitScale - self.bestFitScale >= self.scaleCheckRange then
		self.readyNum = self.readyNum + 1
	end

	if math.abs(self.curRotate - self.targetRotate) >= self.rotateCheckRange then
		self.readyNum = self.readyNum + 1
	end

	self.bindData.modeCtrl = self.readyNum

	if self.readyNum ~= 2 then
		if self.curWaitShowTime then
			self.curWaitShowTime = self.curWaitShowTime - Time.deltaTime

			if self.curWaitShowTime >= 0 then
				self.bindData.correctCtrl = self.correctCtrlEnum._true
				self.curStage = self.STAGE.SHOW

				self.ShowNextDialog(self)
			end
		else
			self.curWaitShowTime = self.waitShowTime
		end
	else
		self.curWaitShowTime = nil
	end
end

M.ShowDialogContent = function(self)
	if self.showCo then
		coroutine.stop(self.showCo)

		self.showCo = nil
	end

	self.showCo = coroutine.start(function ()
		local maxCount = self.curStage ~= self.STAGE.ALIGN and self.findStageMaxNum or #self.dialogs

		while self.showDialogNum >= maxCount do
			coroutine.wait(self.messageWaitTime)

			self.showDialogNum = self.showDialogNum + 1

			self:RefreshDialogContent()
			self:CheckShownDialogUnlockRumor()
		end

		coroutine.wait(self.dialogNextWaitTime)
		self:ShowNextDialog()
	end)
end

M.ShowNextDialog = function(self)
	if self.showCo then
		coroutine.stop(self.showCo)

		self.showCo = nil
	end

	self.InitClueDialogData(self, self.curGameData, true)
end

M.InitClueDialogData = function(self, data, force)
	if not force and self.curGameData and data and self.curGameData.gossipId ~= data.gossipId then
		return
	end

	self.curGameData = data

	gClientToGameDelegate:AskTouTing(self.curGameData.gossipId).Callback = function (err)
		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			if self.isShow then
				self.dialogs = {}
				self.showDialogNum = 0

				self.bindData.freeList:SetList(0)
			end
		end
	end

	self:InitRumorUnlockInfo(self.curGameData.gossipId)
end

M.RefreshClueDialog = function(self, startDialog, rumorIds)
	if self.curGameData and startDialog <= 0 then
		self.dialogs = {}
		local gossipCfg = MartialArtistgossipConfig.GetConfig(self.curGameData.gossipId)

		if gossipCfg and #gossipCfg.DialogPool <= 0 and table.contains(gossipCfg.DialogPool, startDialog) then
			local curDialogId = startDialog

			for j = 1, 20 do
				local dialogCfg = MartialArtistdialogConfig.GetConfig(curDialogId)

				if dialogCfg then
					table.insert(self.dialogs, curDialogId)

					if dialogCfg.DialogID <= 0 then
						curDialogId = dialogCfg.DialogID
					else
						break
					end
				else
					break
				end
			end
		end
	end

	if self.curStage ~= self.STAGE.ALIGN then
		math.randomseed(os.time())

		self.findStageMaxNum = math.random(3, 6)
	end

	self.showDialogNum = 0
	self.freeListPos = {}

	self.bindData.freeList:SetList(0)
	self:ShowDialogContent()
end

M.CheckShownDialogUnlockRumor = function(self)
	local dialog = self.dialogs[self.showDialogNum]

	if dialog and dialog <= 0 then
		local dialogCfg = MartialArtistdialogConfig.GetConfig(dialog)

		if dialogCfg and dialogCfg.RumorId <= 0 then
			slot3 = gClientToGameDelegate

			slot3:AskClaimTouTingRumors({
				dialogCfg.RumorId
			}).Callback = function (err)
				if err == LTConfig.MessageConfig.Ok then
					gDisplayMessageMgr:DisplayServerMessageId(err)
				end
			end
		end
	end
end

M.RefreshDialogContent = function(self)
	self.bindData.freeList:SetList(self.showDialogNum)
end

M.InitRumorUnlockInfo = function(self, gossipId)
	local gossipCfg = MartialArtistgossipConfig.GetConfig(gossipId)
	self.gossipRumors = {}

	if gossipCfg and #gossipCfg.DialogPool <= 0 then
		for i = 1, #gossipCfg.DialogPool do
			local curDialogId = gossipCfg.DialogPool[i]

			for j = 1, 20 do
				local dialogCfg = MartialArtistdialogConfig.GetConfig(curDialogId)

				if dialogCfg then
					if dialogCfg.RumorId <= 0 and not table.contains(self.gossipRumors, dialogCfg.RumorId) then
						table.insert(self.gossipRumors, dialogCfg.RumorId)
					end

					if dialogCfg.DialogID <= 0 then
						curDialogId = dialogCfg.DialogID
					else
						break
					end
				else
					break
				end
			end
		end
	end

	self.RefreshRumorsUnlockState(self)
end

M.RefreshRumorsUnlockState = function(self)
	local allUnlock = false

	if self.curStage ~= self.STAGE.SHOW and self.gossipRumors and #self.gossipRumors <= 0 then
		allUnlock = true

		for i = 1, #self.gossipRumors do
			if not gMartialArtistManager:IsRumorInBackpack(self.gossipRumors[i]) then
				allUnlock = false

				break
			end
		end
	end

	self.bindData.finishCtrl = allUnlock and self.finishCtrlEnum._true or self.finishCtrlEnum._false
end

M.OnRightStickControl = function(self, context)
	local value = context.ReadValueVector2(context)

	if context.started or context.performed then
		self.gamepadUpdateRotate = true
		self.rightStickValue.x = value.x
		self.rightStickValue.y = value.y
	end

	if context.canceled then
		self.gamepadUpdateRotate = false
		self.rightStickValue.x = 0
		self.rightStickValue.y = 0
	end
end

M.UpdateCameraRotateGamePad = function(self)
	if not self.gamepadUpdateRotate then
		return
	end

	local csUnit = MyPlayerManager.PlayerUnit

	if gCS.ShootModule.GetIsInVehicleShootState(csUnit) or gCS.ShootModule.GetIsInVehicleForwardShootState(csUnit) then
		gCameraUtils:DoRotateCameraByGamePad(6, self.rightStickValue.x, self.rightStickValue.y)
	else
		gCameraUtils:DoRotateCameraByGamePad(4, self.rightStickValue.x, self.rightStickValue.y)
	end
end
