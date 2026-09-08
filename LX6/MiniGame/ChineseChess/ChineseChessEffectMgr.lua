-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\ChineseChess\ChineseChessEffectMgr.lua
-- Decompiled from: 02170_ChineseChessEffectMgr.lua_8673ced498f9.luajit

C_ChineseChessEffectMgr = DefClass("C_ChineseChessEffectMgr", C_ChineseChessEffectMgr)
local M = C_ChineseChessEffectMgr

M.PlayMovePointEffect = function(self, position, pointType)
	local effectId = nil

	if pointType ~= gChineseChessMovePointType.Blocked then
		effectId = LTConfig.EffectConfig.ChineseChessBlockedPoint
	else
		effectId = LTConfig.EffectConfig.ChineseChessMovablePoint
	end

	local uuid = gCS.EffectMgr:PlayEffect(effectId, LX6.Effect.EffectPlayTag.Gameplay, position)

	return uuid
end

M.StopMovePointEffect = function(self, uuid)
	if uuid and uuid == 0 then
		gCS.EffectMgr:StopEffectAndSetCacheByUUID(uuid)
	end
end

M.PlayBlockedPointAnimation = function(self, uuid)
	if uuid and uuid == 0 then
		gCS.EffectMgr:PlayAnimationByNameByUUId(uuid, "fx_gp_chess_jinzhi_start")
	end
end

M.StopAllMovePoints = function(self, uuidMap)
	slot2 = pairs
	slot4 = uuidMap or {}

	for _, uuid in slot2(slot4) do
		self.StopMovePointEffect(self, uuid)
	end
end

M.PlayLastPointEffect = function(self, position)
	if self._lastPointUUID ~= nil or self._lastPointUUID ~= 0 then
		self._lastPointUUID = gCS.EffectMgr:PlayEffect(LTConfig.EffectConfig.ChineseChessLastPoint, LX6.Effect.EffectPlayTag.Gameplay, position)
	else
		gCS.EffectMgr:SetPositionByUUId(self._lastPointUUID, position)
	end

	return self._lastPointUUID
end

M.HideLastPoint = function(self)
	self.StopLastPointEffect(self, self._lastPointUUID)

	self._lastPointUUID = nil
end

M.StopLastPointEffect = function(self, uuid)
	if uuid and uuid == 0 then
		gCS.EffectMgr:StopEffectAndSetCacheByUUID(uuid)
	end
end

M.ShowHoverIndicator = function(self, position)
	if self.HoverIndicatorUUID ~= nil or self.HoverIndicatorUUID ~= 0 then
		self.HoverIndicatorUUID = gCS.EffectMgr:PlayEffect(LTConfig.EffectConfig.ChineseChessHoverIndicator, LX6.Effect.EffectPlayTag.Gameplay, position)
	else
		gCS.EffectMgr:SetPositionByUUId(self.HoverIndicatorUUID, position)
	end
end

M.HideHoverIndicator = function(self)
	if self.HoverIndicatorUUID and self.HoverIndicatorUUID == 0 then
		gCS.EffectMgr:StopEffectAndSetCacheByUUID(self.HoverIndicatorUUID)

		self.HoverIndicatorUUID = nil
	end
end

M.ShowChessHoverHighlight = function(self, chessGo)
end

M.HideChessHoverHighlight = function(self)
	if self.ChessHoverHighlightUUID and self.ChessHoverHighlightUUID == 0 then
		gCS.EffectMgr:StopEffectAndSetCacheByUUID(self.ChessHoverHighlightUUID)

		self.ChessHoverHighlightUUID = nil
	end
end

M.ShowChessSelectHighlight = function(self, chessGo)
	self:HideChessSelectHighlight()

	local transform = chessGo.transform
	self.ChessSelectHighlightUUID = gCS.EffectMgr:PlayEffectsOnTransform(LTConfig.EffectConfig.ChineseChessChessSelectHighlight, LX6.Effect.EffectPlayTag.Gameplay, transform, transform.position)
end

M.HideChessSelectHighlight = function(self)
	if self.ChessSelectHighlightUUID and self.ChessSelectHighlightUUID == 0 then
		gCS.EffectMgr:StopEffectAndSetCacheByUUID(self.ChessSelectHighlightUUID)

		self.ChessSelectHighlightUUID = nil
	end
end

M.Destroy = function(self)
	self.HideHoverIndicator(self)
	self.HideChessHoverHighlight(self)
	self.HideChessSelectHighlight(self)
	self.HideLastPoint(self)
end

return M
