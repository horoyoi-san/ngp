-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ChangeFashionPanelStore_OCMode.lua
-- Decompiled from: 01458_ChangeFashionPanelStore_OCMode.lua_eae100e0fcd3.luajit

local FashionConfig = LTConfig.FashionConfig
local FightSpiritConfig = LTConfig.FightSpiritConfig
local M = C_ChangeFashionPanelStore

M.DefineOCVariables = function(self)
	self.ocInitSnapshot = nil
	self.ocFashionOCId = nil
end

M.InitOCMode = function(self, data)
	local unit = data.unit
	local fashionOCId = data.fashionOCId
	local fakeSpiritId = unit.ClientData.cardId
	local spiritCfg = FightSpiritConfig.GetConfig(fakeSpiritId)
	local agentCfg = spiritCfg and LTConfig.AgentConfig.GetConfig(spiritCfg.AgentId)
	local generalModelId = agentCfg and agentCfg.GeneralModelId
	local modelCfg = generalModelId and LTConfig.GeneralModelConfig.GetConfig(generalModelId)
	local spiritInfo = agentCfg and {
		Sex = agentCfg.SexType,
		CameraBodyType = modelCfg and modelCfg.BodyType or 0,
		ModelId = generalModelId
	} or {}
	self.spiritContext = {
		spiritId = fakeSpiritId,
		unit = unit,
		unitPid = unit and unit.Pid,
		spiritInfo = spiritInfo
	}
	self.ocFashionOCId = fashionOCId

	gDressManager:InitSteps(self.spiritContext)

	self.ocInitSnapshot = gDressManager:GetCurrentFashionListInfoRecord(self.spiritContext)

	self:InitSubStores(data)
end

M.OnRefreshOCMode = function(self)
	if self.ocInitSnapshot then
		gDressManager:DressNewFashionListAndEdit(self.ocInitSnapshot.WearFashionInfoList, self.ocInitSnapshot.WearFashionEditInfoList, self.spiritContext)
	end
end

M.DestroyOCMode = function(self)
end

M.SaveOCFashion = function(self, cb)
	if not self.ocFashionOCId then
		return
	end

	LX6.Units.Module.UnitFashionInfoModule.AskSetOCFashions(self.ocFashionOCId, self.spiritContext.spiritId, self.spiritContext.unit, cb)
end

M.CheckOCFashionCanShow = function(self, fashionId)
	if self.fashionChangeType == gClientConst.FashionChangeType.OC then
		return false
	end

	local fashionCfg = FashionConfig.GetConfig(fashionId)

	if not fashionCfg then
		return false
	end

	local belongSpiritId = fashionCfg.BelongSpiritId

	if not belongSpiritId or belongSpiritId ~= 0 then
		return true
	end

	local spiritCfg = FightSpiritConfig.GetConfig(belongSpiritId)

	if not spiritCfg then
		return false
	end

	local agentCfg = LTConfig.AgentConfig.GetConfig(spiritCfg.AgentId)

	if not agentCfg then
		return false
	end

	local belongModelCfg = LTConfig.GeneralModelConfig.GetConfig(agentCfg.GeneralModelId)

	if not belongModelCfg then
		return false
	end

	local modelId = self.spiritContext and self.spiritContext.spiritInfo and self.spiritContext.spiritInfo.ModelId

	if not modelId then
		return false
	end

	local modelCfg = LTConfig.GeneralModelConfig.GetConfig(modelId)

	if not modelCfg then
		return false
	end

	return belongModelCfg.BodyType ~= modelCfg.BodyType
end
