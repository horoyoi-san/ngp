local M = {
	ShowBlackScreen = function (self, blackTime)
		if not gBlackScreenManager:IsOccupiedById(gBlackScreenId.VIDEO) then
			if not blackTime or blackTime < -0.001 then
				gBlackScreenManager:AutoTransition(gBlackScreenId.VIDEO, "", false, false, 0, -1, 0)
			else
				gBlackScreenManager:AutoTransition(gBlackScreenId.VIDEO, "", false, false, 0, blackTime, 0)
			end
		end
	end,
	CloseBlackScreen = function (self)
		if gBlackScreenManager:IsOccupiedById(gBlackScreenId.VIDEO) then
			gBlackScreenManager:CloseTransition(gBlackScreenId.VIDEO, 0)
		end
	end,
	UnitVideo_Stop = function (self, cs_unit)
		local player = cs_unit.PlayerObj:GetComponentInChildren(typeof(Live.Engine.CCPlayer.CCPlayerCore), true)

		if player then
			player:Stop()
		end
	end
}

function M:UnitVideo_PlayPhase(cs_unit, videoId, screenParamIndex, startTime, endTime, isLoop)
	local timer = nil
	local loop = isLoop

	if type(isLoop) == "number" then
		loop = isLoop == 1
	end

	timer = Timer.New(function ()
		if cs_unit.IsDead or cs_unit.IsDestroyed then
			timer:Stop()

			return
		end

		local player = cs_unit.PlayerObj:GetComponentInChildren(typeof(Live.Engine.CCPlayer.CCPlayerCore), true)

		if player then
			timer:Stop()
			player:Init()
			player:PlayUnitPhaseVideo(videoId, screenParamIndex, startTime, endTime, isLoop == 1)
		end
	end, 1, 3)

	timer:Start()
end

function M:UnitVideo_CloseSubScreen(cs_unit, indexArray)
	local player = cs_unit.PlayerObj:GetComponentInChildren(typeof(Live.Engine.CCPlayer.CCScenePlayer), true)

	if player then
		if not indexArray then
			print_error("VideoManager UnitVideo_CloseSubScreen indexArray is nil")

			return
		end

		player:CloseSubScreen(indexArray)
	end
end

function M:UnitVideo_OpenSubScreen(cs_unit, indexArray)
	local player = cs_unit.PlayerObj:GetComponentInChildren(typeof(Live.Engine.CCPlayer.CCScenePlayer), true)

	if player then
		if not indexArray then
			print_error("VideoManager UnitVideo_CloseSubScreen indexArray is nil")

			return
		end

		player:OpenSubScreen(indexArray)
	end
end

gVideoManager = M
