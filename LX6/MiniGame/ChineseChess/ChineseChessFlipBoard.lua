-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\ChineseChess\ChineseChessFlipBoard.lua
-- Decompiled from: 02166_ChineseChessFlipBoard.lua_c1776c070d6c.luajit

C_ChineseChessFlipBoard = DefClass("C_ChineseChessFlipBoard", C_ChineseChessFlipBoard, C_ChineseChessBoardBase)
local M = C_ChineseChessFlipBoard

M.ctor = function(self)
end

M.Init = function(self, boardGo, Chart, player1, player2, isReverse)
	M.base.Init(self, boardGo, Chart, player1, player2, isReverse)

	self.BoardGo1 = boardGo.transform:Find("Objects_1")
	self.BoardGo2 = boardGo.transform:Find("Objects_2")

	self.BoardGo1.gameObject:SetActive(not gChineseChessMgr.IsMirror)
	self.BoardGo2.gameObject:SetActive(gChineseChessMgr.IsMirror)
end

M.InitPointMarkers = function(self)
	self.PointTransforms = {}

	for i = 0, 7 do
		for j = 0, 3 do
			local point = gChineseChessTools.GetFlipPointByPosition(i, j)
			local pointGo = self.PointsGo.transform:Find(point)

			if gChineseChessMgr.IsMirror then
				self.PointTransforms[31 - point] = pointGo
			else
				self.PointTransforms[point] = pointGo
			end
		end
	end
end

M.GetPointTransform = function(self, point)
	return self.PointTransforms[point]
end

M.InitChessBoard = function(self)
	self.RemoveAllChess(self)

	self.ChessGoMap = {}

	for chessId, point in pairs(self.Chart.ChessPointMap) do
		if point and point == -1 then
			local chessGo = nil

			if self.Chart:IsFaceDown(chessId) then
				chessGo = self.FaceDownChessGoMap[chessId]

				if gClientUtils.IsNil(chessGo) then
					chessGo = UnityEngine.GameObject.Instantiate(gChineseChessMgr:GetFaceDownPrefab(), self.ChesssGo)

					gChineseChessTools.ForceChessLOD0(chessGo)

					chessGo.name = tostring(chessId)
					self.FaceDownChessGoMap[chessId] = chessGo
				end
			else
				chessGo = self.ChessGoMap[chessId]

				if gClientUtils.IsNil(chessGo) then
					print("InitChessBoard chessId:", chessId, " point:", point, self.Chart:IsFaceDown(chessId))

					chessGo = gChineseChessTools.InstantiateChess(chessId, self.ChesssGo)
					self.ChessGoMap[chessId] = chessGo
				end
			end

			chessGo:SetActive(true)

			local pointTf = self:GetPointTransform(point)

			chessGo.transform:SetParent(self.ChesssGo)
			chessGo.transform:SetPosition(pointTf.position)
		end
	end
end

M.ClickPoint = function(self, point)
	if not gChineseChessMgr:IsMyAction() then
		print("不是自己的回合，不处理点击")

		return
	end

	if gChineseChessMgr:IsPlayerAction() or gChineseChessMgr.IsWaitingServerMove then
		return
	end

	local chessId = self.Chart:GetChessByPoint(point)

	if self.Chart:PointHasFaceDown(point) then
		if self.SelectedChessId then
			local chessType = gChineseChessTools.GetChessType(self.SelectedChessId)

			if chessType ~= gChineseChessType.Pao and self.Chart:IsValidMove(self.SelectedChessId, point) then
				gChineseChessMgr:MoveChess(self.SelectedChessId, point)

				return
			end
		end

		self:DeselectChess()
		gChineseChessMgr:FlipChess(point)

		return
	end

	if self.SelectedChessId ~= nil then
		if chessId and not self.Chart:IsFaceDown(chessId) and gChineseChessTools.IsRedChess(chessId) ~= self.Chart.IsRedPlayChess then
			self.SelectChess(self, chessId)
		end
	elseif chessId ~= self.SelectedChessId then
		self.DeselectChess(self)
	elseif chessId and not self.Chart:IsFaceDown(chessId) and gChineseChessTools.IsRedChess(chessId) ~= self.Chart.IsRedPlayChess then
		self.SelectChess(self, chessId)
	elseif self.Chart:IsValidMove(self.SelectedChessId, point) then
		gChineseChessMgr:MoveChess(self.SelectedChessId, point)
	else
		print("无效移动")
	end
end

M.RemoveAllChess = function(self)
	slot1 = pairs
	slot3 = self.FaceDownChessGoMap or {}

	for _, v in slot1(slot3) do
		gClientUtils.DestroyUnityObject(v)
	end

	slot1 = pairs
	slot3 = self.ChessGoMap or {}

	for _, v in slot1(slot3) do
		gClientUtils.DestroyUnityObject(v)
	end

	self.FaceDownChessGoMap = {}
	self.ChessGoMap = {}
	self._chessYOriginMap = {}
end

M.FlipChess = function(self, point)
	if self.Chart.FlipChess ~= nil then
		return
	end

	local flippedChessID = self.Chart:FlipChess(point)

	if flippedChessID then
		local isRed = gChineseChessTools.IsRedChess(flippedChessID)
		local newChessGo = self:FlipChessImpl(flippedChessID, point)

		self:OnChessFlipped(flippedChessID, point)
		self.CurrentPlayer:FlipChess(self:GetPointTransform(point), newChessGo)
	end
end

M.OnChessFlipped = function(self, chessID, point)
end

M.FlipChessImpl = function(self, chessID, point)
	local oldGo = self.FaceDownChessGoMap[chessID]
	local newGo = self.ChessGoMap[chessID]

	if gClientUtils.IsNil(newGo) then
		newGo = gChineseChessTools.InstantiateChess(chessID, self.ChesssGo)
		self.ChessGoMap[chessID] = newGo
	end

	local pointTf = self:GetPointTransform(point)

	newGo.transform:SetPosition(pointTf.position)

	newGo.transform.localRotation = Quaternion.Euler(180, 0, 0)

	if gClientUtils.NotNil(oldGo) then
		gClientUtils.DestroyUnityObject(oldGo)
	end

	self.FaceDownChessGoMap[chessID] = nil

	return newGo
end

M.DeductScore = function(self, capturedChessID)
	local chessType = gChineseChessTools.GetChessType(capturedChessID)
	local damage = gChineseChessTools.GetChessScore(chessType)
	local isRed = gChineseChessTools.IsRedChess(capturedChessID)
	local playerInfo = gChineseChessMgr:GetPlayerInfo(isRed)

	if playerInfo then
		playerInfo.Score = math.max(0, playerInfo.Score - damage)
	end
end

M.MoveChessTo = function(self, chessId, point)
	if not gChineseChessMgr.IsPlaying then
		return
	end

	self:RemoveAllMovePoint()

	local isFaceDown = self.Chart:PointHasFaceDown(point)
	local toChessId = self.Chart:GetChessByPoint(point)
	local fromChessGo = self.ChessGoMap[chessId]
	local toChessGo = nil
	local selectedPoint = self.Chart:GetChessPoint(chessId)
	local isRed = gChineseChessTools.IsRedChess(chessId)
	local player = isRed and self.RedPlayer or self.BlackPlayer

	self:ShowLastPoint(selectedPoint)

	if toChessId then
		if isFaceDown then
			self.FlipChessImpl(self, toChessId, point)
		end

		toChessGo = self.ChessGoMap[toChessId]
		local target, success, isSelfDamage = self.Chart:MoveChess(chessId, point)

		if not success then
			print("翻棋吃子失败，等级不够")

			return
		end

		self.DeductScore(self, toChessId)
		self.RemoveChess(self, toChessId)

		player.ChessId = toChessId

		player.KillChess(player, self.GetPointTransform(self, selectedPoint), self.GetPointTransform(self, point), fromChessGo, toChessGo)
	else
		player:MoveChess(self:GetPointTransform(selectedPoint), self:GetPointTransform(point), fromChessGo)
		self.Chart:MoveChess(chessId, point)
	end
end

M.Restart = function(self)
	self.RoundStartTime = os.time()

	self.Chart:Start()
	self:Clear()
	self:InitChessBoard()
end

return M
