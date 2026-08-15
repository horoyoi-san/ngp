local Utils = SGUI.Utils
C_OneLineDrawingStore = DefClass("C_OneLineDrawingStore", C_OneLineDrawingStore, C_StoreGroup)
GroupName2Class.OneLineDrawingStore = C_OneLineDrawingStore
local M = C_OneLineDrawingStore
local OneLineDrawingConfig = LTConfig.PuzzleOneLineDrawingConfig
local StickCheckLimitDistance = 150
local FailAnimationMaxTime = 0
local VertexOnObjectFailAnimationName = "S_Vx_OneLineDrawingDotsFalse"
local EdgeOnObjectFailAnimationName = "S_Vx_OneLineDrawingLine_Failed"
local NoPlayerCullingMask = LX6.Constants.LayerConstants.VegetationWithoutPlayer
local AbsFunc = math.abs

function M:ctor()
	self.vertexStatusList = {}
	self.edgeStatusList = {}
end

function M:OnAwake()
	self.bindData.dotList.luaRenderItem = self:CreateAction("OnRenderDotItem")

	function self.bindData.dotList.onGetTIndex(_)
		return 0
	end

	self.bindData.dotList.luaPress = self:CreateAction("StartPress")
	self.bindData.dotList.luaRelease = self:CreateAction("ReleasePoint")
	self.bindData.lineList.luaRenderItem = self:CreateAction("OnRenderLineItem")
	self.bindData.lineList.luaPress = self:CreateAction("StartPress")
	self.bindData.lineList.luaRelease = self:CreateAction("ReleasePoint")

	function self.bindData.lineList.onGetTIndex(_)
		return 0
	end

	self.bindData.exitBtn.luaClick = self:CreateAction("ExitGame")

	self:PrepareData()
end

function M:StartPress()
	if self.isPlayingFailAnimation then
		return
	end

	self.isUpdate = true
end

function M:ExitGame()
	gPanelManager:Close(gPanelId.ONE_LINE_DRAWING_PANEL)
end

function M:PrepareData()
	self.movingEdge = self.bindData.moveLine

	self.movingEdge.gameObject:SetActive(false)

	self.movingEdgeStartVertex = nil
	self.isUpdate = false
	self.isPlayingFailAnimation = false
	local movingEdgeTransform = self.movingEdge.gameObject.transform
	movingEdgeTransform.localScale = Vector3.New(1, 1, 1)
end

function M:OnRenderDotItem(btn, index)
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

function M:OnRenderLineItem(btn, index)
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

function M:CheckStickVertex(xPos, yPos)
	for _, vertex in ipairs(self.vertexStatusList) do
		local localPosition = vertex.pos

		if AbsFunc(xPos - localPosition.x) + AbsFunc(yPos - localPosition.y) < StickCheckLimitDistance then
			return vertex
		end
	end

	return nil
end

function M:GetEdge(startVertex, endVertex, isUnfinished)
	for _, edge in ipairs(self.edgeStatusList) do
		if (edge.startVertex == startVertex and edge.endVertex == endVertex or edge.startVertex == endVertex and edge.endVertex == startVertex) and (not isUnfinished or not edge.isOn) then
			return edge
		end
	end

	return nil
end

function M:SetVertexIsOn(vertex, isOn)
	vertex.isOn = true
	vertex.store.dotState = isOn and 1 or 0
end

function M:SetEdgeIsOn(edge, isOn)
	edge.isOn = isOn
	edge.store.lineState = isOn and 1 or 0
end

function M:PressPoint()
	local touchVector = Utils.GetInputCenterPosition()
	local uiPos = gCS.LuaUtils.ScreenPointUI(self.bindData.rootRect, touchVector)
	local xPos = uiPos.x
	local yPos = uiPos.y
	local mousePos = Vector3.New(xPos, yPos, 0)
	local stickVertex = self:CheckStickVertex(xPos, yPos)

	if self.movingEdgeStartVertex == nil then
		if stickVertex == nil then
			return
		end

		local movingEdgeObject = self.movingEdge.gameObject

		movingEdgeObject:SetActive(true)
		self:SetVertexIsOn(stickVertex, true)

		self.movingEdgeStartVertex = stickVertex
	end

	if stickVertex ~= nil then
		local currentFinishedEdge = self:GetEdge(self.movingEdgeStartVertex, stickVertex, true)

		if currentFinishedEdge ~= nil then
			self:SetVertexIsOn(stickVertex, true)
			self:SetEdgeIsOn(currentFinishedEdge, true)

			self.movingEdgeStartVertex = stickVertex
		end
	end

	self:UpdateMovingEdge(mousePos)
	self:CheckMovingEdgeStickVertex(mousePos)
end

function M:CheckMovingEdgeStickVertex(mousePos)
	local stickVertex, edge = self:GetNearestVertexInMovingEdgeProjection(mousePos)

	if stickVertex == nil then
		return
	end

	self:SetVertexIsOn(stickVertex, true)
	self:SetEdgeIsOn(edge, true)

	self.movingEdgeStartVertex = stickVertex

	self:PressPoint()
end

function M:GetNearestVertexInMovingEdgeProjection(mousePos)
	local startVertexLocalPosition, movingEdgeLengthSquare, stickVertex = nil
	local minDist = StickCheckLimitDistance
	local edge = nil

	for _, vertex in ipairs(self.vertexStatusList) do
		if vertex.index ~= self.movingEdgeStartVertex.index then
			local vertexLocalPosition = vertex.store.dotTransform.localPosition

			if startVertexLocalPosition == nil then
				startVertexLocalPosition = self.movingEdgeStartVertex.store.dotTransform.localPosition
			end

			local vectorStartMouse = mousePos - startVertexLocalPosition
			local vectorEdge = vertexLocalPosition - startVertexLocalPosition
			local cross = vectorStartMouse.x * vectorEdge.x + vectorStartMouse.y * vectorEdge.y

			if movingEdgeLengthSquare == nil then
				local xDiff = mousePos.x - startVertexLocalPosition.x
				local yDiff = mousePos.y - startVertexLocalPosition.y
				movingEdgeLengthSquare = xDiff * xDiff + yDiff * yDiff
			end

			if cross >= 0 and cross <= movingEdgeLengthSquare then
				local currentEdge = self:GetEdge(self.movingEdgeStartVertex, vertex, true)

				if currentEdge ~= nil then
					local r = cross / movingEdgeLengthSquare
					local xFoot = startVertexLocalPosition.x + (mousePos.x - startVertexLocalPosition.x) * r
					local yFoot = startVertexLocalPosition.y + (mousePos.y - startVertexLocalPosition.y) * r
					local dist = AbsFunc(xFoot - vertexLocalPosition.x) + AbsFunc(yFoot - vertexLocalPosition.y)

					if minDist > dist then
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

function M:OnUpdate()
	if not self.isUpdate then
		return
	end

	self:PressPoint()
end

function M:UpdateMovingEdge(mousePos)
	local movingEdgeTransform = self.movingEdge.gameObject.transform
	local movingEdgeStartVertexLocalPosition = self.movingEdgeStartVertex.pos
	movingEdgeTransform.localPosition = movingEdgeStartVertexLocalPosition
	movingEdgeTransform.right = mousePos - movingEdgeStartVertexLocalPosition
	local width = Vector3.Distance(movingEdgeStartVertexLocalPosition, mousePos)
	movingEdgeTransform.sizeDelta = Vector2.New(width, movingEdgeTransform.sizeDelta.y)
end

function M:ReleasePoint()
	self.isUpdate = false

	for _, edge in ipairs(self.edgeStatusList) do
		if not edge.isOn then
			self:OnGameFail()

			return
		end
	end

	self:OnGameSucceed()
end

function M:OnGameFail()
	self.isPlayingFailAnimation = true

	for _, vertex in ipairs(self.vertexStatusList) do
		if vertex.isOn then
			vertex.store.isTrue = 1

			gLuaTimeMgrUtils.Delay(function ()
				vertex.store.isTrue = 0

				self:SetVertexIsOn(vertex, false)
			end, gCS.LuaUtils.GetAnimationTime(vertex.store.failDotAnim, VertexOnObjectFailAnimationName))
		else
			self:SetVertexIsOn(vertex, false)
		end
	end

	for _, edge in ipairs(self.edgeStatusList) do
		if edge.isOn then
			edge.store.failLineAnim:Play(EdgeOnObjectFailAnimationName)

			local time = gCS.LuaUtils.GetAnimationTime(edge.store.failLineAnim, EdgeOnObjectFailAnimationName)

			gLuaTimeMgrUtils.Delay(function ()
				self:SetEdgeIsOn(edge, false)
			end, time)
		else
			self:SetEdgeIsOn(edge, false)
		end
	end

	gLuaTimeMgrUtils.Delay(function ()
		self.isPlayingFailAnimation = false
	end, FailAnimationMaxTime)
	self:PrepareData()
end

function M:OnGameSucceed()
	gMessageManager:SendMessage(gEventConstants.SLOT_ENTITY_BROAD_CAST_SIGNAL_IN, self.panelData.successSignal)

	if self.panelData.successSignalFunc ~= nil then
		if type(self.panelData.successSignalFunc) == "userdata" then
			self.panelData.successSignalFunc:DynamicInvoke()
		else
			self.panelData.successSignalFunc()
		end
	end

	gLuaTimeMgrUtils.Delay(function ()
		gPanelManager:Close(gPanelId.ONE_LINE_DRAWING_PANEL)
	end, 0.5)
end

function M:OnEnable()
	return
end

function M:OnStart()
	return
end

function M:OnDisable()
	return
end

function M:OnDestroy()
	return
end

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	return
end

function M:OnShow(panelId, data)
	if data == nil then
		return
	end

	if data.ToTable then
		data = data:ToTable()
	end

	self.panelData = data

	self:InitGame(data.configID)
	gCS.CameraDataMgr:SetMainCameraCullingMask(gPanelId.ONE_LINE_DRAWING_PANEL, NoPlayerCullingMask)
end

function M:InitGame(configID, isSmall)
	self.vertexStatusList = {}
	self.edgeStatusList = {}
	local config = OneLineDrawingConfig.GetConfig(configID)

	if config == nil then
		print_error("一笔画配置未找到，检查Puzzle/OneLineDrawing id: " .. tostring(configID))
		gPanelManager:Close(gPanelId.ONE_LINE_DRAWING_PANEL)

		return
	end

	self.isSmall = config.IsSmallPoint
	local vertexPositions = config.DotData
	local edgeConnections = config.LineData
	local vertexPositionCount = #vertexPositions

	for i = 1, vertexPositionCount, 2 do
		local pos = self:CreateVertex(vertexPositions[i], vertexPositions[i + 1])
		local vertexStatus = {
			isOn = false,
			index = (i + 1) / 2,
			pos = pos
		}

		table.insert(self.vertexStatusList, vertexStatus)
	end

	local edgeConnectionsCount = #edgeConnections

	for i = 1, edgeConnectionsCount, 2 do
		local startVertex = self.vertexStatusList[edgeConnections[i]]
		local endVertex = self.vertexStatusList[edgeConnections[i + 1]]

		if startVertex ~= endVertex then
			local startVertexLocalPos = startVertex.pos
			local endVertexLocalPos = endVertex.pos
			local createdEdge = self:CreateEdge(startVertexLocalPos, endVertexLocalPos)
			local edgeStatus = {
				isOn = false,
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

function M:CreateVertex(xPos, yPos)
	local data = Vector3.New(xPos, yPos, 0)

	return data
end

function M:CreateEdge(startVertexLocalPos, endVertexLocalPos)
	local data = {
		startPos = startVertexLocalPos,
		width = Vector3.Distance(startVertexLocalPos, endVertexLocalPos),
		right = endVertexLocalPos - startVertexLocalPos
	}

	return data
end

function M:OnClose()
	gCS.CameraDataMgr:RevertMainCameraCullingMask(gPanelId.ONE_LINE_DRAWING_PANEL)

	if self.panelData.exitSignalFunc ~= nil then
		if type(self.panelData.exitSignalFunc) == "userdata" then
			self.panelData.exitSignalFunc:DynamicInvoke()
		else
			self.panelData.exitSignalFunc()
		end
	end

	gMessageManager:SendMessage(gEventConstants.SLOT_ENTITY_BROAD_CAST_SIGNAL_IN, self.panelData.exitSignal)
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end
