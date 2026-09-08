-- Original chunk: @Lua\LuaFiles\LX6\Manager\Effect\NewEffectFunc.lua
-- Decompiled from: 00232_NewEffectFunc.lua_2aac7c8b1c95.luajit

local EffectConfig = LTConfig.EffectConfig
local M = gNewEffectFunc or {}
M.funcCached = {}
M.effectUUId = 0
M.effectId = 0

M.CheckCfgPlayCondition = function(self, code, pid, effectId)
	local f = self.funcCached[code]

	if not f then
		f = load(code, nil, "t", {
			M = gSkillJumpScriptFunc
		})
		self.funcCached[code] = f
	end

	if not f then
		print_error("EffectId=" .. effectId .. "加载SkillConditionFunc函数失败: " .. tostring(code))

		return
	end

	gSkillJumpScriptFunc.skillClip = nil
	local status, ret = xpcall(f, tolua.traceback)

	if status then
		return ret
	end

	print_error("EffectConfig.ConditionFunc执行报错", ret, "请检查函数是否存在且该函数不能用到skillClip，pid=", pid, "status=", status)

	return false
end

M.ExecuteCfgStartFunc = function(self, uuid, pid, effectId)
	local cfg = EffectConfig.GetConfig(effectId)
	local code = cfg.StartFunc
	local f = self.funcCached[code]

	if not f then
		f = load(code, nil, "t", {
			M = self
		})
		self.funcCached[code] = f
	end

	if not f then
		print_error("EffectId=" .. effectId .. "加载SkillConditionFunc函数失败: " .. tostring(code))

		return
	end

	self:PrepareStartFunc(uuid, effectId, pid)

	local status, ret = xpcall(f, tolua.traceback)

	if status then
		return ret
	end

	print_error("EffectConfig.StartFunc执行报错", ret, "请检查函数是否存在", "status=", status)

	return false
end

M.PrepareStartFunc = function(self, uuid, effectId, pid)
	M.effectUUId = uuid
	M.effectId = effectId
end

M.CloseUnitEffects = function(...)
	local effectIds = {
		...
	}
	local ln = #effectIds

	if ln <= 0 then
		gCS.EffectMgr:AddByFunc_EffectCloseUnitEffectsData(M.effectUUId, effectIds)
	end
end

M.PlayPostProcessing = function(postProcessing)
	postProcessing = postProcessing or 0

	if postProcessing <= 0 then
		gCS.EffectMgr:AddByFunc_EffectPostProcessingData(M.effectUUId, postProcessing)
	end
end

M.PlayCameraAnimation = function(camAnimFileName, cameraQuick)
	if not camAnimFileName then
		return
	end

	cameraQuick = cameraQuick or false

	gCS.EffectMgr:AddByFunc_EffectCameraAnimationData(M.effectUUId, camAnimFileName, cameraQuick)
end

M.EnableMotionVertex = function(boundry, length)
	gCS.EffectMgr:AddByFunc_EffectMotionVertexData(M.effectUUId, boundry, length)
end

M.PlaySound = function(soundId, stopDelaySound, followDelaySound)
	soundId = soundId or 0
	stopDelaySound = stopDelaySound or false

	if followDelaySound ~= nil then
		followDelaySound = true
	end

	if soundId == 0 then
		gCS.EffectMgr:AddByFunc_EffectSoundData(M.effectUUId, soundId, stopDelaySound, followDelaySound)
	end
end

M.PlayBlendShapeAnim = function(renderName, fadeInAnim, loopAnim, fadeOutAnim)
	if renderName then
		gCS.EffectMgr:AddByFunc_EffectBlendShapedAnimData(M.effectUUId, renderName, fadeInAnim, fadeOutAnim, loopAnim)
	end
end

gNewEffectFunc = M
