-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\OneLineDrawingStore.lua
-- Decompiled from: 01058_OneLineDrawingStore.lua_9af8c7e42e18.luajit

local Utils = SGUI.Utils
C_OneLineDrawingStore = DefClass("C_OneLineDrawingStore", C_OneLineDrawingStore, C_StoreGroup)
GroupName2Class.OneLineDrawingStore = C_OneLineDrawingStore
local M = C_OneLineDrawingStore
local OneLineDrawingConfig = LTConfig.PuzzleOneLineDrawingConfig
local PoiGameConfig = LTConfig.PoiGameConfig
local StickCheckLimitDistance = 150
local VertexOnObjectFailAnimationName = "S_Vx_OneLineDrawingDotsFalse"
local EdgeOnObjectFailAnimationName = "S_Vx_OneLineDrawingLine_Failed"
local UCursorInput = SGUI.UCursorInput
local NoPlayerCullingMask = LX6.Constants.LayerConstants.VegetationWithoutPlayer
local AbsFunc = math.abs

M.ctor = function(self)
	self.vertexStatusList = {}
	self.edgeStatusList = {}
end

M.OnAwake = function(self)
	self.bindData.dotList.luaRenderItem = self.CreateAction(self, "OnRenderDotItem")

	self.bindData.dotList.onGetTIndex = function(_)
		return 0
	end

	self.bindData.dotList.luaPress = self.CreateAction(self, "StartPress")
	self.bindData.dotList.luaRelease = self.CreateAction(self, "ReleasePoint")
	self.bindData.lineList.luaRenderItem = self.CreateAction(self, "OnRenderLineItem")
	self.bindData.lineList.luaPress = self.CreateAction(self, "StartPress")
	self.bindData.lineList.luaRelease = self.CreateAction(self, "ReleasePoint")

	self.bindData.lineList.onGetTIndex = function(_)
		return 0
	end

	self.bindData.exitBtn.luaClick = self.CreateAction(self, "ExitGame")
	self.bindData.ctrlResetBtn.luaClick = self.CreateAction(self, self.ControllerReset)
	self.bindData.leftJoyStick.luaGamePadInputChanged = self.CreateAction(self, self.OnLeftJoyStickMove)

	self.PrepareData(self)
end

M.StartPress = function(self)
	if self.isPlayingFailAnimation then
		return
	end

	if self.enableController then
		self.attachPoint = nil
	end

	self.isUpdate = true
end

M.ExitGame = function(self)
	gPanelManager:Close(gPanelId.ONE_LINE_DRAWING_PANEL)
end

M.PrepareData = function(self)
	self.movingEdge = self.bindData.moveLine

	self.movingEdge.gameObject:SetActive(false)

	self.movingEdgeStartVertex = nil
	self.isUpdate = false
	self.isPlayingFailAnimation = false
	self.leftJoyStick = false
	self.attachDistance = PoiGameConfig.OneLineDrawAttachDistance
	self.attachSpeed = PoiGameConfig.OneLineDrawAttachSpeed
	local movingEdgeTransform = self.movingEdge.gameObject.transform
	movingEdgeTransform.localScale = Vector3.New(1, 1, 1)
end

M.OnRenderDotItem = function(self, btn, index)
	local id = btn.gameObject:GetInstanceID()
	local store = self:GetStoreById(id)
	local vertexStatusData = self.vertexStatusList[index + 1]

	if store and vertexStatusData then
		store.dotTransform.localPosition = vertexStatusData.pos
		store.dotState = 0
		store.greySize = self.isSmall and 1 or 0
		store.size = self.isSmall and 1 or 0
		vertexStatusData.store = store
	end
end

M.OnRenderLineItem = function(self, btn, index)
	local id = btn.gameObject:GetInstanceID()
	local store = self:GetStoreById(id)
	local edgeStatusData = self.edgeStatusList[index + 1]

	if store and edgeStatusData then
		store.lineTransform.localPosition = edgeStatusData.createdEdgeData.startPos
		store.lineTransform.sizeDelta = Vector2.New(edgeStatusData.createdEdgeData.width, store.lineTransform.sizeDelta.y)
		store.lineTransform.right = edgeStatusData.createdEdgeData.right
		store.lineState = 0
		edgeStatusData.store = store
	end
end

M.CheckStickVertex = function(self, xPos, yPos)
	for _, vertex in ipairs(self.vertexStatusList) do
		local localPosition = vertex.pos

		if AbsFunc(xPos - localPosition.x) + AbsFunc(yPos - localPosition.y) >= StickCheckLimitDistance then
			return vertex
		end
	end

	return nil
end

M.GetEdge = function(self, startVertex, endVertex, isUnfinished)
	for _, edge in ipairs(self.edgeStatusList) do
		if (edge.startVertex ~= startVertex and edge.endVertex ~= endVertex or edge.startVertex ~= endVertex and edge.endVertex ~= startVertex) and (not isUnfinished or not edge.isOn) then
			return edge
		end
	end

	return nil
end

M.SetVertexIsOn = function(self, vertex, isOn)
	vertex.isOn = isOn
	vertex.store.dotState = isOn and 1 or 0

	if isOn then
		gSoundMgr:PlaySoundByExternalSource("exhandle_qtecommon1", LX6.Audio.ExternalSourceType.Motion_2D)
	end
end

M.SetEdgeIsOn = function(self, edge, isOn)
	edge.isOn = isOn
	edge.store.lineState = isOn and 1 or 0
end

M.PressPoint = function(self)
	local touchVector = Utils.GetInputCenterPosition()
	local uiPos = gCS.LuaUtils.ScreenPointUI(self.bindData.rootRect, touchVector)
	local xPos = uiPos.x
	local yPos = uiPos.y
	local mousePos = Vector3.New(xPos, yPos, 0)
	local stickVertex = self.CheckStickVertex(self, xPos, yPos)

	if self.movingEdgeStartVertex ~= nil then
		if stickVertex ~= nil then
			return
		end

		local movingEdgeObject = self.movingEdge.gameObject

		movingEdgeObject.SetActive(movingEdgeObject, true)
		self.SetVertexIsOn(self, stickVertex, true)

		self.movingEdgeStartVertex = stickVertex
	end

	if stickVertex == nil then
		local currentFinishedEdge = self.GetEdge(self, self.movingEdgeStartVertex, stickVertex, true)

		if currentFinishedEdge == nil then
			self.SetVertexIsOn(self, stickVertex, true)
			self.SetEdgeIsOn(self, currentFinishedEdge, true)

			self.movingEdgeStartVertex = stickVertex
		end
	end

	self.UpdateMovingEdge(self, mousePos)
	self.CheckMovingEdgeStickVertex(self, mousePos)
end

M.CheckMovingEdgeStickVertex = function(self, mousePos)
	local stickVertex, edge = self.GetNearestVertexInMovingEdgeProjection(self, mousePos)

	if stickVertex ~= nil then
		return
	end

	self.SetVertexIsOn(self, stickVertex, true)
	self.SetEdgeIsOn(self, edge, true)

	self.movingEdgeStartVertex = stickVertex

	self.PressPoint(self)
end

M.GetNearestVertexInMovingEdgeProjection = function(self, mousePos)
	local startVertexLocalPosition, movingEdgeLengthSquare, stickVertex = nil
	local minDist = StickCheckLimitDistance
	local edge = nil

	for _, vertex in ipairs(self.vertexStatusList) do
		if vertex.index == self.movingEdgeStartVertex.index then
			local vertexLocalPosition = vertex.store.dotTransform.localPosition

			if startVertexLocalPosition ~= nil then
				startVertexLocalPosition = self.movingEdgeStartVertex.store.dotTransform.localPosition
			end

			local vectorStartMouse = mousePos - startVertexLocalPosition
			local vectorEdge = vertexLocalPosition - startVertexLocalPosition
			local cross = vectorStartMouse.x * vectorEdge.x + vectorStartMouse.y * vectorEdge.y

			if movingEdgeLengthSquare ~= nil then
				local xDiff = mousePos.x - startVertexLocalPosition.x
				local yDiff = mousePos.y - startVertexLocalPosition.y
				movingEdgeLengthSquare = xDiff * xDiff + yDiff * yDiff
			end

			if cross > 0 and cross < movingEdgeLengthSquare then
				local currentEdge = self.GetEdge(self, self.movingEdgeStartVertex, vertex, true)

				if currentEdge == nil then
					local r = cross / movingEdgeLengthSquare
					local xFoot = startVertexLocalPosition.x + (mousePos.x - startVertexLocalPosition.x) * r
					local yFoot = startVertexLocalPosition.y + (mousePos.y - startVertexLocalPosition.y) * r
					local dist = AbsFunc(xFoot - vertexLocalPosition.x) + AbsFunc(yFoot - vertexLocalPosition.y)

					if minDist <= dist then
						stickVertex = vertex
						edge = currentEdge
						minDist = dist
					end
				end
			end
		end
	end

	return stickVertex, edge
end

M.OnUpdate = function(self)
	self.ControllerAttachTick(self)

	if not self.isUpdate then
		return
	end

	self.PressPoint(self)
end

M.UpdateMovingEdge = function(self, mousePos)
	local movingEdgeTransform = self.movingEdge.gameObject.transform
	local movingEdgeStartVertexLocalPosition = self.movingEdgeStartVertex.pos
	movingEdgeTransform.localPosition = movingEdgeStartVertexLocalPosition
	movingEdgeTransform.right = mousePos - movingEdgeStartVertexLocalPosition
	local width = Vector3.Distance(movingEdgeStartVertexLocalPosition, mousePos)
	movingEdgeTransform.sizeDelta = Vector2.New(width, movingEdgeTransform.sizeDelta.y)
end

M.ReleasePoint = function(self)
	self.isUpdate = false

	if not self.CheckAllEdgeIsOn(self) then
		self.OnGameFail(self)
	else
		self.OnGameSucceed(self)
	end
end

M.CheckAllEdgeIsOn = function(self)
	for _, edge in ipairs(self.edgeStatusList) do
		if not edge.isOn then
			return false
		end
	end

	return true
end

M.ControllerReset = function(self)
	self.OnGameFail(self)
	UCursorInput.ResetCursorPos()
end

M.OnGameFail = function(self)
	self.isPlayingFailAnimation = true
	self.enableAttach = false
	local failAnimationMaxTime = 0

	for _, vertex in ipairs(self.vertexStatusList) do
		if vertex.isOn then
			vertex.store.isTrue = 1
			local animationTime = gCS.LuaUtils.GetAnimationTime(vertex.store.failDotAnim, VertexOnObjectFailAnimationName)
			failAnimationMaxTime = math.max(animationTime, failAnimationMaxTime)

			gLuaTimeMgrUtils.Delay(function ()
				vertex.store.isTrue = 0

				self:SetVertexIsOn(vertex, false)
			end, animationTime)
		else
			self.SetVertexIsOn(self, vertex, false)
		end
	end

	for _, edge in ipairs(self.edgeStatusList) do
		if edge.isOn then
			slot7 = edge.store.failLineAnim

			slot7:Play(EdgeOnObjectFailAnimationName)

			local animationTime = gCS.LuaUtils.GetAnimationTime(edge.store.failLineAnim, EdgeOnObjectFailAnimationName)
			failAnimationMaxTime = math.max(animationTime, failAnimationMaxTime)

			gLuaTimeMgrUtils.Delay(function ()
				self:SetEdgeIsOn(edge, false)
			end, animationTime)
		else
			self.SetEdgeIsOn(self, edge, false)
		end
	end

	gLuaTimeMgrUtils.Delay(function ()
		self.isPlayingFailAnimation = false
	end, failAnimationMaxTime)
	self.PrepareData(self)
end

M.OnGameSucceed = function(self)
	gMessageManager:SendMessage(gEventConstants.SLOT_ENTITY_BROAD_CAST_SIGNAL_IN, self.panelData.successSignal)

	if self.panelData.successSignalFunc == nil then
		if type(self.panelData.successSignalFunc) ~= "userdata" then
			self.panelData.successSignalFunc:DynamicInvoke()
		else
			self.panelData.successSignalFunc()
		end
	end

	if self.enableController then
		gSoundMgr:PlaySoundByExternalSource("exhandle_qtecommon2", LX6.Audio.ExternalSourceType.Motion_2D)
	end

	gLuaTimeMgrUtils.Delay(function ()
		gPanelManager:Close(gPanelId.ONE_LINE_DRAWING_PANEL)
	end, 0.5)
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
	if data ~= nil then
		return
	end

	if data.ToTable then
		data = data.ToTable(data)
	end

	self.panelData = data

	self:InitGame(data.configID)
	self:SetEnableController(SGUI.GameDevice.KeyboardMouse <= gCS.LuaUtils.GetActiveDevice())
	gCS.CameraDataMgr:SetMainCameraCullingMask(gPanelId.ONE_LINE_DRAWING_PANEL, NoPlayerCullingMask)

	self.enableAttach = false
end

M.InitGame = function(self, configID, isSmall)
	self.vertexStatusList = {}
	self.edgeStatusList = {}
	local config = OneLineDrawingConfig.GetConfig(configID)

	if config ~= nil then
		print_error("一笔画配置未找到，检查Puzzle/OneLineDrawing id: " .. tostring(configID))
		gPanelManager:Close(gPanelId.ONE_LINE_DRAWING_PANEL)

		return
	end

	self.isSmall = config.IsSmallPoint
	local vertexPositions = config.DotData
	local edgeConnections = config.LineData
	local vertexPositionCount = #vertexPositions

	for i = 1, vertexPositionCount, 2 do
		local pos = self.CreateVertex(self, vertexPositions[i], vertexPositions[i + 1])
		local vertexStatus = {
			s1RU = false,
			index = (i + 1) / 2,
			pos = pos
		}

		table.insert(self.vertexStatusList, vertexStatus)
	end

	local edgeConnectionsCount = #edgeConnections

	for i = 1, edgeConnectionsCount, 2 do
		local startVertex = self.vertexStatusList[edgeConnections[i]]
		local endVertex = self.vertexStatusList[edgeConnections[i + 1]]

		if startVertex == endVertex then
			local startVertexLocalPos = startVertex.pos
			local endVertexLocalPos = endVertex.pos
			local createdEdge = self.CreateEdge(self, startVertexLocalPos, endVertexLocalPos)
			local edgeStatus = {
				s1RU = false,
				startVertex = startVertex,
				endVertex = endVertex,
				createdEdgeData = createdEdge
			}

			table.insert(self.edgeStatusList, edgeStatus)
		end
	end

	self.bindData.dotList:SetList(#self.vertexStatusList)
	self.bindData.lineList:SetList(#self.edgeStatusList)
end

M.CreateVertex = function(self, xPos, yPos)
	local data = Vector3.New(xPos, yPos, 0)

	return data
end

M.CreateEdge = function(self, startVertexLocalPos, endVertexLocalPos)
	local data = {
		startPos = startVertexLocalPos,
		width = Vector3.Distance(startVertexLocalPos, endVertexLocalPos),
		right = endVertexLocalPos - startVertexLocalPos
	}

	return data
end

M.OnClose = function(self)
	gCS.CameraDataMgr:RevertMainCameraCullingMask(gPanelId.ONE_LINE_DRAWING_PANEL)

	if self.panelData.exitSignalFunc == nil then
		if type(self.panelData.exitSignalFunc) ~= "userdata" then
			self.panelData.exitSignalFunc:DynamicInvoke()
		else
			self.panelData.exitSignalFunc()
		end
	end

	gMessageManager:SendMessage(gEventConstants.SLOT_ENTITY_BROAD_CAST_SIGNAL_IN, self.panelData.exitSignal)
end

M.OnActiveDeviceChange = function(self, device)
	self:SetEnableController(SGUI.GameDevice.KeyboardMouse <= device)
end

M.SetEnableController = function(self, enable)
	if self.enableController == enable and self.isUpdate then
		self.OnGameFail(self)
	end

	self.enableController = enable

	if self.enableController then
		UCursorInput.ResetCursorPos()
	else
		self.leftJoyStick = false
	end
end

M.OnLeftJoyStickMove = function(self, ctx)
	if ctx.canceled then
		self.SetEnableLeftJoyStick(self, false)
	elseif ctx.performed or ctx.started then
		self.SetEnableLeftJoyStick(self, true)
	end
end

M.SetEnableLeftJoyStick = function(self, enable)
	if self.leftJoyStick ~= enable then
		return
	end

	self.enableAttach = true
	self.leftJoyStick = enable

	self.CheckControllerGame(self)
end

M.CheckControllerGame = function(self)
	if not self.CheckLeftJoyStickAndTouchMove(self) and self.isUpdate and self.CheckAllEdgeIsOn(self) then
		self.OnGameSucceed(self)
	end
end

M.CheckLeftJoyStickAndTouchMove = function(self)
	return self.leftJoyStick
end

M.ControllerAttachTick = function(self)
	if not self.enableController or self.isUpdate or self.CheckLeftJoyStickAndTouchMove(self) or not self.enableAttach then
		return
	end

	self.CheckAttachToPointer(self)
	self.TickAttackToPointer(self)
end

M.CheckAttachToPointer = function(self)
	if self.attachPoint then
		return
	end

	local cursorUiPoint = self.GetPointerUIPosByScreen(self)
	local minDist = self.attachDistance

	for _, vertex in ipairs(self.vertexStatusList) do
		if vertex.store then
			local vertexPos = vertex.store.dotTransform.localPosition
			local dist = Vector3.Distance(cursorUiPoint, vertexPos)

			if dist < minDist then
				minDist = dist
				self.attachPoint = vertexPos
			end
		end
	end
end

M.TickAttackToPointer = function(self)
	if not self.attachPoint then
		return
	end

	local cursorUiPoint = self.GetPointerUIPosByScreen(self)
	local delta = self.attachPoint - cursorUiPoint
	local dir = Vector2.Normalize(delta)
	local distance = Vector2.Magnitude(delta)
	local step = self.attachSpeed * UnityEngine.Time.deltaTime

	if distance <= step then
		cursorUiPoint = cursorUiPoint + dir * step
	else
		cursorUiPoint = self.attachPoint

		self.StartPress(self)
	end

	local screenPos = gCS.LuaUtils.TransformUIPointToScreen(self.bindData.rootRect, cursorUiPoint)

	UCursorInput.SetCursorPos(screenPos)
end

M.GetPointerUIPosByScreen = function(self)
	local screenPos = UCursorInput.GetCursorScreenPos()

	return gCS.LuaUtils.TransformScreenPointToUI(self.bindData.rootRect, screenPos)
end
