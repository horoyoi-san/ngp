local BeginConfig = LTConfig.GameplayHudDescBeginConfig
local OptionConfig = LTConfig.GameplayHudDescBeginOptionConfig
local DropConfig = LTConfig.DropConfig
C_GamePlayBeginManager = DefClass("C_GamePlayBeginManager", C_GamePlayBeginManager)
local M = C_GamePlayBeginManager

function M:ctor()
	return
end

function M:OnBegin(id, options)
	local cfg = BeginConfig.GetConfig(id)

	if not cfg then
		return
	end

	local action = self:CreateAction(cfg.StartAction)

	if action then
		action(options)
	end
end

function M:BeginGobang()
	print_debug("[C_GamePlayBeginManager] BeginGobang")
	gPanelManager:Close(gPanelId.COMMON_GAMEPLAY_START_PANEL)
end

function M:GetRewardListByOptions(id, options)
	local rewardList = {}
	local cfg = BeginConfig.GetConfig(id)

	if not cfg then
		return rewardList
	end

	for i = 1, #cfg.Options do
		local oCfg = OptionConfig.GetConfig(cfg.Options[i])

		if oCfg then
			local option = options[i] + 1 or 1
			local drop = oCfg.Drops[option] or 0
			local dropConfig = DropConfig.GetConfig(drop)

			if dropConfig then
				table.insert(rewardList, {
					dropId = drop
				})
			end
		end
	end

	return rewardList
end

gGamePlayBeginMgr = gGamePlayBeginMgr or C_GamePlayBeginManager.new()
