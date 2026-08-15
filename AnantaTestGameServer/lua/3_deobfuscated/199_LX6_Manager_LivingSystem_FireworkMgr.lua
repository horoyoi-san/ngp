local FireworkPlanConfig = LTConfig.FireworkFireworkPlanConfig
local FireworkConfig = LTConfig.FireworkConfig
local FireworkNpcConfig = LTConfig.FireworkNpcCommentConfig
local M = gFireworkMgr or {}
M.isPlaying = false
M.dataIsEnd = true
local eventHandler = {
	[gEventConstants.FIREWORK_PLAY_EFFECT] = function (eventId, data)
		M:PlayEffectList()
	end,
	[gEventConstants.FIREWORK_PLAY_TIMELINE] = function (eventId, data)
		M:PlayTimeLine()
	end
}

function M:OnInit()
	for k, v in pairs(eventHandler) do
		gMessageManager:AddMessageListener(k, v)
	end
end

function M:OnUpdate()
	if not self.isPlaying then
		return
	end

	self.past = Time.time - self.startTime + self.skipTime

	if self.past < 0 then
		return
	end

	if self.curRound < self:GetCurRound() then
		self.curRound = self:GetCurRound()

		if self.roundNum < self.curRound then
			self:OnEffectEnd()

			return
		end

		self:PlayEffect(1)
	elseif self.curEffect < self:GetCurEffect() then
		self:PlayEffect(self.curEffect + 1)
	end
end

function M:PlayTimeLine()
	self.TimeLinePos = self:GetWayPointPos(self.data.timeLineWayPoint)
	self.TimeLineFace = self:GetWayPointFace(self.data.timeLineWayPoint)
	local data = gTimelineManager:Timeline_CreateTimelineData()
	data.pos = self.TimeLinePos
	data.rot = Vector3.New(0, self.TimeLineFace, 0)
	data.loadWithBlackScreen = true

	function data.onFinishCb()
		M:OnEndTimeLine()
	end
end

function M:OnEndTimeLine()
	gClientToGameSceneDelegate:AskReleaseClientEvent("FireworkTimeLineEnd")
end

function M:PlayEffectList()
	if self.data.isAgain then
		return
	end

	local cfg = FireworkPlanConfig.GetConfig(self.data.planId)
	self.effectList = cfg.FireworkEffectid
	self.posList = self:GetEffectPosList(cfg.FireworkPosition)
	self.delayStart = FireworkConfig.StartLightoffTime
	self.effectInterval = FireworkConfig.FireworkInterval
	self.roundInterval = FireworkConfig.RoundInterval
	self.roundNum = FireworkConfig.FireworkRound
	self.startTime = Time.time + self.delayStart
	self.effectNum = #self.effectList
	self.curEffect = 0
	self.curRound = 0
	self.effectPos = self:GetWayPointPos(self.data.effectWayPoint)
	self.effectFace = -self:GetWayPointFace(self.data.effectWayPoint) * Mathf.Deg2Rad
	self.skipTime = 0
	self.isPlaying = true

	gLuaClient:RegisterDynamicUpdate("gFireworkMgr", self)
end

function M:GMOnlyPlayEffect(planId, skipTime, wayPoint)
	local cfg = FireworkPlanConfig.GetConfig(planId)
	self.effectList = cfg.FireworkEffectid
	self.posList = self:GetEffectPosList(cfg.FireworkPosition)
	self.delayStart = FireworkConfig.StartLightoffTime
	self.effectInterval = FireworkConfig.FireworkInterval
	self.roundInterval = FireworkConfig.RoundInterval
	self.roundNum = FireworkConfig.FireworkRound
	self.startTime = Time.time + self.delayStart
	self.effectNum = #self.effectList
	self.curEffect = 0
	self.curRound = 0
	self.effectPos = self:GetWayPointPos(wayPoint)
	self.effectFace = -self:GetWayPointFace(wayPoint) * Mathf.Deg2Rad
	self.skipTime = skipTime
	self.isPlaying = true

	gLuaClient:RegisterDynamicUpdate("gFireworkMgr", self)
end

function M:GMStopEffect()
	self.isPlaying = false

	gLuaClient:UnregisterDynamicUpdate("gFireworkMgr")
end

function M:GetCurEffect()
	local delt = self.past - (self:GetCurRound() - 1) * self:GetOneRoundTime()

	if delt > (self.effectNum - 1) * self.effectInterval then
		return self.effectNum
	end

	return Mathf.Floor(delt / self.effectInterval) + 1
end

function M:GetCurRound()
	return Mathf.Floor(self.past / self:GetOneRoundTime()) + 1
end

function M:GetOneRoundTime()
	return (self.effectNum - 1) * self.effectInterval + self.roundInterval
end

function M:PlayEffect(index)
	self.curEffect = index

	gCS.EffectMgr:PlayEffectsRotate(self.effectList[index], self:GetEffectPos(index), -self.effectFace * Mathf.Rad2Deg)
end

function M:OnEffectEnd()
	self.isPlaying = false

	gLuaClient:UnregisterDynamicUpdate("gFireworkMgr")
end

function M:GetEffectPosList(list)
	local posList = {}

	for i = 1, #list do
		table.insert(posList, Vector3.New(list[i].x, list[i].y, list[i].z))
	end

	return posList
end

function M:GetEffectPos(index)
	local pos = Vector3.zero
	pos.x = self.posList[index].x * Mathf.Cos(self.effectFace) - self.posList[index].z * Mathf.Sin(self.effectFace)
	pos.y = self.posList[index].y
	pos.z = self.posList[index].x * Mathf.Sin(self.effectFace) + self.posList[index].z * Mathf.Cos(self.effectFace)

	return self.effectPos + pos
end

function M:GetWayPointPos(wayPointName)
	if wayPointName then
		local wp = gSpoonMgr:GetWayPointPositionByNameOrId(wayPointName)

		if wp then
			return wp
		end
	end

	return gCS.MyPlayerManager.PlayerUnit.LocalPosition
end

function M:GetWayPointFace(wayPointName)
	if wayPointName then
		local f = gSpoonMgr:GetWayPointFacingByNameOrId(wayPointName)

		if f then
			return f
		end
	end

	return 0
end

gFireworkMgr = M
