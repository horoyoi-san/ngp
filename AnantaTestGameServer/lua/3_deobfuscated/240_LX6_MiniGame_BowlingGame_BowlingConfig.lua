local BowlingConfig = {
	AnimatorControllerPath = "Res/MiniGame/Other/Bowling/Animation/Middle_MaleOverrideControllerBat.overrideController",
	Launcher = {
		maxLaunchOffset = -0.45,
		forwardSpinSpeed = 15,
		maxLaunchDir = 4.5,
		forwardSpinTime = 0.1,
		spawnZOffset = -0.5,
		maxLaunchTor = 5,
		minLaunchOffset = 0.45,
		minLaunchTor = -5,
		minLaunchDir = -4.5,
		fCamFov = 28,
		chargeTime = {
			0.65,
			0.6,
			0.55,
			0.5,
			0.45
		},
		chargeTimePower = {
			1.2,
			1.05,
			0.9,
			0.75,
			0.6
		},
		minLaunchForce = {
			10,
			15,
			20,
			25,
			35
		},
		maxLaunchForce = {
			30,
			37,
			45,
			50,
			55
		},
		LaunchTorParam = {
			{
				force = 0.1,
				slip = 12,
				rot = 2
			},
			{
				force = 0.3,
				slip = 10,
				rot = 9
			},
			{
				force = 0.6,
				slip = 8,
				rot = 16
			},
			{
				force = 0.9,
				slip = 5,
				rot = 23
			},
			{
				force = 1.3,
				slip = 2,
				rot = 30
			}
		},
		spawnPosition = {
			z = 9.5,
			x = 0,
			y = 3.01
		},
		fCamPosOffset = {
			z = 1.8,
			x = 0,
			y = 0.4
		},
		fCamRot = {
			z = 0,
			x = 5,
			y = 180
		},
		prefabPaths = {
			pin = "Res/MiniGame/Prefab/Bowling/BowlingPinL.prefab",
			arrowTips = "Res/MiniGame/Prefab/Bowling/ArrowTIps.prefab",
			clamp = "Res/MiniGame/Prefab/Bowling/Clamp.prefab",
			scene = "Res/MiniGame/Prefab/Bowling/BowlingSceneNode.prefab",
			ballLight = "Res/MiniGame/Prefab/Bowling/BallLight.prefab",
			balls = {
				{
					mass = 3.628736,
					name = 89901314,
					path = "Res/MiniGame/Prefab/Bowling/Ball1.prefab"
				},
				{
					mass = 4.53592,
					name = 89901315,
					path = "Res/MiniGame/Prefab/Bowling/Ball2.prefab"
				},
				{
					mass = 5.443104,
					name = 89901316,
					path = "Res/MiniGame/Prefab/Bowling/Ball3.prefab"
				},
				{
					mass = 6.350288,
					name = 89901317,
					path = "Res/MiniGame/Prefab/Bowling/Ball4.prefab"
				},
				{
					mass = 7.257472,
					name = 89901318,
					path = "Res/MiniGame/Prefab/Bowling/Ball5.prefab"
				}
			}
		}
	}
}

return BowlingConfig
