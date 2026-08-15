gBowlingTimelineClipManager = DefClass("BowlingTimelineClipManager", gBowlingTimelineClipManager)
local BowlingTimelineClipManager = gBowlingTimelineClipManager
local BowlingConstants = require("LX6/MiniGame/BowlingGame/BowlingConstants")
local TimelineScene = BowlingConstants.TimelineScene
local prefabPath = "Res/MiniGame/Other/Bowling/TimeLine/TimelineBowling.prefab"
local bindings_path = {
	[1.0] = "allmove/actor/actorA_offset/actorA_position/main_A103001_gm",
	[2.0] = "allmove/actor/actorB_offset/actorB_position/main_A103001_gm"
}
local bindings_tracks = {
	player_animator_tracks = {
		{
			[gClientUtils.ModelType.MiddleMale] = "Animation_actorA"
		},
		{
			[gClientUtils.ModelType.MiddleMale] = "Animation_actorB"
		}
	},
	player_activation_tracks = {
		[1.0] = "Activation_actorA",
		[2.0] = "Activation_actorB"
	},
	cam_tracks = {
		{
			[gClientUtils.ModelType.MiddleMale] = "Animation_cam_bat01_1"
		},
		{
			[gClientUtils.ModelType.MiddleMale] = "Animation_cam_bat01_1"
		}
	}
}
local config_clips = {
	[TimelineScene.ENTER] = {
		{
			startFrame = 0,
			description = "进入场景",
			endFrame = 120
		},
		{
			startFrame = 2000,
			description = "进入场景",
			endFrame = 2120
		}
	},
	[TimelineScene.LAUNCH] = {
		{
			startFrame = 150,
			description = "投球动作",
			endFrame = 310
		},
		{
			startFrame = 2150,
			description = "投球动作",
			endFrame = 2310
		}
	},
	[TimelineScene.BACK] = {
		{
			startFrame = 340,
			description = "返回位置",
			endFrame = 440
		},
		{
			startFrame = 2340,
			description = "返回位置",
			endFrame = 2440
		}
	},
	[TimelineScene.BACK_S] = {
		{
			startFrame = 450,
			description = "返回位置(胜利)",
			endFrame = 550
		},
		{
			startFrame = 2450,
			description = "返回位置(胜利)",
			endFrame = 2550
		}
	},
	[TimelineScene.END] = {
		{
			startFrame = 580,
			description = "单人结算",
			endFrame = 670
		},
		{
			startFrame = 2580,
			description = "单人结算",
			endFrame = 2670
		}
	},
	[TimelineScene.WIN] = {
		{
			startFrame = 700,
			description = "胜利动画(双人)",
			endFrame = 805
		},
		{
			startFrame = 2700,
			description = "胜利动画(双人)",
			endFrame = 2805
		}
	},
	[TimelineScene.LOSE] = {
		{
			startFrame = 850,
			description = "失败动画(双人)",
			endFrame = 955
		},
		{
			startFrame = 2850,
			description = "失败动画(双人)",
			endFrame = 2955
		}
	},
	[TimelineScene.DRAW] = {
		{
			startFrame = 990,
			description = "平局动画(双人)",
			endFrame = 1095
		},
		{
			startFrame = 2990,
			description = "平局动画(双人)",
			endFrame = 3095
		}
	},
	[TimelineScene.SWITCH_S] = {
		{
			startFrame = 1120,
			description = "角色切换(成功)首次",
			endFrame = 1270
		},
		{
			startFrame = 3120,
			description = "角色切换(成功)首次",
			endFrame = 3270
		}
	},
	[TimelineScene.SWITCH_N_S] = {
		{
			startFrame = 1320,
			description = "角色切换(成功)",
			endFrame = 1470
		},
		{
			startFrame = 3320,
			description = "角色切换(成功)",
			endFrame = 3470
		}
	},
	[TimelineScene.SWITCH] = {
		{
			startFrame = 1510,
			description = "角色切换(失败)首次",
			endFrame = 1660
		},
		{
			startFrame = 3510,
			description = "角色切换(失败)首次",
			endFrame = 3660
		}
	},
	[TimelineScene.SWITCH_N] = {
		{
			startFrame = 1700,
			description = "角色切换(失败)",
			endFrame = 1850
		},
		{
			startFrame = 3700,
			description = "角色切换(失败)",
			endFrame = 3850
		}
	}
}

function BowlingTimelineClipManager:InitData()
	self.hasDestroy = false
	self.timelineController = nil
	self.activeClip = nil
	self.currentCoroutine = nil
	self.sceneNode = nil
	self.virtualCamera = nil
	self.timelineCameras = {}
	self.timelineCameraPriorities = {}
	self.defaultCameraPriority = 11
	self.isLoaded = false
	self.isLoading = false
	self.BallPoint = nil
	self.FPS = 30
end

function BowlingTimelineClipManager:Init(sceneNode, virtualCamera, playerPoint, preload)
	self:InitData()

	if not gClientUtils.NotNil(sceneNode) then
		print_debug("Scene node is nil, cannot initialize timeline clip manager")

		return
	end

	self.sceneNode = sceneNode
	self.virtualCamera = virtualCamera
	self.playerPoint = playerPoint

	if preload ~= false then
		self:LoadMainTimeline(function ()
			self.isLoaded = true
		end)
	end
end

function BowlingTimelineClipManager:LoadMainTimeline(onLoaded)
	if self.hasDestroy then
		return
	end

	if self.isLoaded and gClientUtils.NotNil(self.timelineController) then
		if onLoaded then
			onLoaded()
		end

		return
	end

	if self.isLoading then
		print_debug("Main timeline is already loading")

		return
	end

	if not prefabPath then
		print_debug("Main timeline prefab path not configured")

		return
	end

	self.isLoading = true

	gResourceManager:LoadAssetWithCallBack(prefabPath, typeof(UnityEngine.GameObject), function (loadOp)
		if self.hasDestroy then
			gResourceManager:UnloadAssetLoadOp(loadOp)

			return
		end

		local controller = UnityEngine.GameObject.Instantiate(loadOp.asset, self.sceneNode.transform)
		self.timelineController = controller:GetComponent(typeof(UnityEngine.Playables.PlayableDirector))

		controller.gameObject:SetActive(false)

		self.isLoaded = true
		self.isLoading = false

		if onLoaded then
			onLoaded()
		end
	end)
end

function BowlingTimelineClipManager:FrameToTime(frame)
	return frame / self.FPS
end

function BowlingTimelineClipManager:PlayClip(clipType, callBackTimeline, offset, playerIndex, modelType)
	if self.hasDestroy then
		return
	end

	local clipInfo = config_clips[clipType]

	if not clipInfo then
		print_debug("Clip type not found: " .. tostring(clipType))

		return
	end

	if playerIndex and clipInfo[playerIndex] then
		clipInfo = clipInfo[playerIndex]
	elseif clipInfo[1] then
		clipInfo = clipInfo[1]

		print_debug("Using default player index 1 for clip: " .. tostring(clipType))
	else
		print_debug("No valid clip configuration found for clipType: " .. tostring(clipType))

		return
	end

	if self.activeClip then
		self:StopClip()
	end

	self.timelineController.gameObject:SetActive(true)

	self.timelineController.time = self:FrameToTime(clipInfo.startFrame)

	if playerIndex and modelType then
		local activeCameraTrack = self:GetCameraTrackName(playerIndex, modelType)

		if activeCameraTrack then
			local allCameraTracks = self:GetAllCameraTrackNames(playerIndex)

			self:ControlCameraTracks(activeCameraTrack, allCameraTracks)
		end
	end

	self.timelineController:Play()
	self:ControlCameraPriority(true, self.defaultCameraPriority + 1, self.defaultCameraPriority)

	local clipDuration = self:FrameToTime(clipInfo.endFrame - clipInfo.startFrame)

	if self.currentCoroutine then
		coroutine.stop(self.currentCoroutine)

		self.currentCoroutine = nil
	end

	local co = coroutine.start(function ()
		coroutine.wait(clipDuration)

		if self.hasDestroy then
			return
		end

		if gClientUtils.NotNil(self.timelineController) then
			self.timelineController:Pause()
		end

		self:ControlCameraPriority(false)

		if gClientUtils.NotNil(self.timelineController) then
			self.timelineController.gameObject:SetActive(false)
		end

		self.activeClip = nil

		if callBackTimeline then
			local status, err = pcall(function ()
				callBackTimeline()
			end)

			if not status then
				print_debug("[BowlingTimelineClipManager] Error in onComplete callback: " .. tostring(err))
			end
		end

		self.currentCoroutine = nil
	end)
	self.activeClip = {
		clipType = clipType,
		clipInfo = clipInfo,
		startFrame = clipInfo.startFrame,
		endFrame = clipInfo.endFrame,
		duration = clipDuration
	}

	if offset then
		self:SetTimelineOffset(offset)
	end

	self.currentCoroutine = co
end

function BowlingTimelineClipManager:StopClip()
	if self.hasDestroy then
		return
	end

	if self.currentCoroutine then
		coroutine.stop(self.currentCoroutine)

		self.currentCoroutine = nil
	end

	if gClientUtils.NotNil(self.timelineController) then
		self.timelineController:Pause()
		self.timelineController.gameObject:SetActive(false)
	end

	self:ControlCameraPriority(false)

	self.activeClip = nil
end

function BowlingTimelineClipManager:JumpToClipProgress(clipType, progress, playerIndex)
	if self.hasDestroy then
		return
	end

	local clipInfo = config_clips[clipType]

	if not clipInfo then
		print_debug("Clip type not found: " .. tostring(clipType))

		return
	end

	if playerIndex and clipInfo[playerIndex] then
		clipInfo = clipInfo[playerIndex]
	elseif clipInfo[1] then
		clipInfo = clipInfo[1]

		print_debug("Using default player index 1 for clip: " .. tostring(clipType))
	else
		print_debug("No valid clip configuration found for clipType: " .. tostring(clipType))

		return
	end

	if not self.isLoaded or not gClientUtils.NotNil(self.timelineController) then
		print_debug("Timeline not loaded, cannot jump to clip progress")

		return
	end

	progress = math.max(0, math.min(1, progress))
	local targetTime = clipInfo.startFrame + (clipInfo.endFrame - clipInfo.startFrame) * progress
	self.timelineController.time = targetTime
end

function BowlingTimelineClipManager:GetCurrentClipProgress()
	if not self.activeClip or not gClientUtils.NotNil(self.timelineController) then
		return nil
	end

	local currentTime = self.timelineController.time
	local clipInfo = self.activeClip.clipInfo

	if currentTime < clipInfo.startFrame then
		return 0
	elseif clipInfo.endFrame < currentTime then
		return 1
	else
		return (currentTime - clipInfo.startFrame) / (clipInfo.endFrame - clipInfo.startFrame)
	end
end

function BowlingTimelineClipManager:SetTimelineOffset(offset)
	if not gClientUtils.NotNil(self.timelineController) or not offset then
		return
	end

	self.timelineController.transform.localPosition = offset
end

function BowlingTimelineClipManager:ResetTimelinePosition()
	if not gClientUtils.NotNil(self.timelineController) then
		return
	end

	self.timelineController.transform.localPosition = Vector3.zero
end

function BowlingTimelineClipManager:ControlCameraPriority(enableTimelineCamera, timelinePriority, scenePriority)
	if enableTimelineCamera then
		if gClientUtils.NotNil(self.virtualCamera) then
			self.virtualCamera.Priority = scenePriority or self.defaultCameraPriority
		end

		self:SetTimelineCameraPriority(timelinePriority or self.defaultCameraPriority + 1)
	else
		self:SetTimelineCameraPriority(self.defaultCameraPriority - 1)

		if gClientUtils.NotNil(self.virtualCamera) then
			self.virtualCamera.Priority = self.defaultCameraPriority + 1
		end
	end
end

function BowlingTimelineClipManager:SetTimelineCameraPriority(priority)
	if not gClientUtils.NotNil(self.timelineController) then
		return
	end

	local vcListNode = self.timelineController.gameObject.transform:Find("allmove/vcList")

	if not gClientUtils.NotNil(vcListNode) then
		return
	end

	for i = 0, vcListNode.childCount - 1 do
		local vcNode = vcListNode:GetChild(i)

		if gClientUtils.NotNil(vcNode) then
			local virtualCam = vcNode:GetComponent(typeof(Cinemachine.CinemachineVirtualCamera))

			if gClientUtils.NotNil(virtualCam) then
				virtualCam.Priority = priority
			end
		end
	end
end

function BowlingTimelineClipManager:GetClipInfo(clipType, playerIndex)
	local clipInfo = config_clips[clipType]

	if not clipInfo then
		return nil
	end

	if playerIndex and clipInfo[playerIndex] then
		return clipInfo[playerIndex]
	elseif clipInfo[1] then
		return clipInfo[1]
	else
		return nil
	end
end

function BowlingTimelineClipManager:GetAvailableClips()
	local clips = {}

	for clipType, _ in pairs(config_clips) do
		table.insert(clips, clipType)
	end

	return clips
end

function BowlingTimelineClipManager:Destroy()
	self.hasDestroy = true

	self:StopClip()

	if gClientUtils.NotNil(self.timelineController) then
		gBowlingGameManager:Destroy(self.timelineController.gameObject)

		self.timelineController = nil
	end

	self.sceneNode = nil
	self.virtualCamera = nil
	self.timelineCameras = {}
	self.timelineCameraPriorities = {}
	self.BallPoint = nil
end

function BowlingTimelineClipManager:ReplaceCharacterAndBindAnimator(playerCharacter, timelineCharacterPath, playerAnimator, animatorTrackName, activationTrackName)
	if self.hasDestroy then
		return
	end

	if not gClientUtils.NotNil(self.timelineController) then
		print_error("BowlingTimelineClipManager Timeline controller is not loaded")

		return
	end

	if not gClientUtils.NotNil(playerCharacter) then
		print_error("BowlingTimelineClipManager Player character is nil")

		return
	end

	local timelineRoot = self.timelineController.gameObject

	if not gClientUtils.NotNil(timelineRoot) then
		print_error("BowlingTimelineClipManager Timeline root object not found")

		return
	end

	local success = self:ReplaceTimelineCharacter(timelineRoot, playerCharacter, timelineCharacterPath)

	if not success then
		print_error("BowlingTimelineClipManager Failed to replace timeline character")

		return
	end

	local bindSuccess = self:BindPlayerAnimator(animatorTrackName, playerAnimator)

	if not bindSuccess then
		print_error("BowlingTimelineClipManager Failed to bind player animator")

		return
	end

	local bindActSuccess = self:BindPlayerActivation(activationTrackName, playerCharacter)

	if not bindActSuccess then
		print_error("BowlingTimelineClipManager Failed to bind player activation")

		return
	end
end

function BowlingTimelineClipManager:ReplaceTimelineCharacter(timelineRoot, playerCharacter, characterPath)
	local originalCharacter = timelineRoot.transform:Find(characterPath)

	if not gClientUtils.NotNil(originalCharacter) then
		print_debug("Original character not found at path: " .. tostring(characterPath))

		return false
	end

	local parentTransform = originalCharacter.parent

	playerCharacter.transform:SetParent(parentTransform, false)

	playerCharacter.transform.localPosition = Vector3.zero
	playerCharacter.transform.localRotation = Quaternion.identity

	playerCharacter:SetActive(true)
	gBowlingGameManager:Destroy(originalCharacter.gameObject)

	return true
end

function BowlingTimelineClipManager:BindPlayerAnimator(trackName, playerAnimator)
	local success, err = pcall(function ()
		local tracks = self.timelineController.playableAsset:GetOutputTracks()

		if tracks and tracks.Length then
			for i = 0, tracks.Length - 1 do
				local track = tracks[i]

				if track and track.name == trackName then
					self.timelineController:SetGenericBinding(track, playerAnimator)

					break
				end
			end
		else
			print_debug("No tracks found or tracks.Length not available")
		end
	end)

	if not success then
		print_debug("Failed to bind animator: " .. tostring(err))

		return false
	end

	return true
end

function BowlingTimelineClipManager:BindPlayerActivation(trackName, player)
	local success, err = pcall(function ()
		local tracks = self.timelineController.playableAsset:GetOutputTracks()

		if tracks and tracks.Length then
			for i = 0, tracks.Length - 1 do
				local track = tracks[i]

				if track and track.name == trackName then
					self.timelineController:SetGenericBinding(track, player)

					break
				end
			end
		else
			print_debug("No tracks found or tracks.Length not available")
		end
	end)

	if not success then
		print_debug("Failed to bind activation: " .. tostring(err))

		return false
	end

	return true
end

function BowlingTimelineClipManager:GetPlayerAnimatorTrackName(playerIndex, modelType)
	if not bindings_tracks.player_animator_tracks[playerIndex] then
		return nil
	end

	if not bindings_tracks.player_animator_tracks[playerIndex][modelType] then
		return nil
	end

	return bindings_tracks.player_animator_tracks[playerIndex][modelType]
end

function BowlingTimelineClipManager:GetPlayerActivationTrackName(playerIndex)
	if not bindings_tracks.player_activation_tracks[playerIndex] then
		return nil
	end

	return bindings_tracks.player_activation_tracks[playerIndex]
end

function BowlingTimelineClipManager:GetPlayerNodeTimelinePath(playerIndex)
	if not bindings_path[playerIndex] then
		return nil
	end

	return bindings_path[playerIndex]
end

function BowlingTimelineClipManager:GetCameraTrackName(playerIndex, modelType)
	if not bindings_tracks.cam_tracks[playerIndex] then
		return nil
	end

	if not bindings_tracks.cam_tracks[playerIndex][modelType] then
		return nil
	end

	return bindings_tracks.cam_tracks[playerIndex][modelType]
end

function BowlingTimelineClipManager:ControlCameraTracks(activeTrackName, allCameraTrackNames)
	local success, err = pcall(function ()
		local tracks = self.timelineController.playableAsset:GetOutputTracks()

		if tracks and tracks.Length then
			for i = 0, tracks.Length - 1 do
				local track = tracks[i]

				if track and track.name then
					for _, cameraTrackName in ipairs(allCameraTrackNames) do
						if track.name == cameraTrackName then
							if track.name == activeTrackName then
								track.muted = false

								break
							end

							track.muted = true

							break
						end
					end
				end
			end
		else
			print_debug("No tracks found or tracks.Length not available")
		end
	end)

	if not success then
		print_debug("Failed to control camera tracks: " .. tostring(err))

		return false
	end

	return true
end

function BowlingTimelineClipManager:GetAllCameraTrackNames(playerIndex)
	local trackNames = {}

	if not playerIndex or not bindings_tracks.cam_tracks[playerIndex] then
		return trackNames
	end

	local playerTracks = bindings_tracks.cam_tracks[playerIndex]

	for modelType, trackName in pairs(playerTracks) do
		table.insert(trackNames, trackName)
	end

	return trackNames
end
