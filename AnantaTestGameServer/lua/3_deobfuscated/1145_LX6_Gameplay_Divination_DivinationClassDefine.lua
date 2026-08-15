local DivinerCardEventConfig = LTConfig.DivinerCardEventConfig
C_CardEffectInfo = DefClass("C_CardEffectInfo", C_CardEffectInfo)
local CardEffectInfo = C_CardEffectInfo

function CardEffectInfo:ctor(eventId, effectType, param1, param2, countDown, triggerNum, isNPC)
	self.eventId = eventId
	self.effectType = effectType
	self.param1 = param1
	self.param2 = param2
	self.countDown = countDown
	self.triggerNum = triggerNum
	self.isNPC = isNPC
end

function CardEffectInfo:Dispose()
	self.eventId = nil
	self.effectType = nil
	self.param1 = nil
	self.param2 = nil
	self.countDown = nil
	self.triggerNum = nil
	self.isNPC = nil
end

C_HandCardInfo = DefClass("C_HandCardInfo", C_HandCardInfo)
local HandCardInfo = C_HandCardInfo

function HandCardInfo:ctor(cfg)
	self.cfg = cfg
	self.cost = cfg.Cost
	self.event1Cfg = DivinerCardEventConfig.GetConfig(self.cfg.Event1)
	self.event2Cfg = DivinerCardEventConfig.GetConfig(self.cfg.Event2)
	self.e1P1 = self.event1Cfg and self.event1Cfg.Parameter1 or 0
	self.e1P2 = self.event1Cfg and self.event1Cfg.Parameter2 or 0
	self.e2P1 = self.event2Cfg and self.event2Cfg.Parameter1 or 0
	self.e2P2 = self.event2Cfg and self.event2Cfg.Parameter2 or 0
	self.e1P1Extra = 0
	self.e1P2Extra = 0
	self.e2P1Extra = 0
	self.e2P2Extra = 0
	self.costExtra = 0
	self.roundBuffList = {}
	self.gameBuffList = {}
end

function HandCardInfo:Dispose()
	self.cfg = nil
	self.cost = nil
	self.event1Cfg = nil
	self.event2Cfg = nil
	self.e1P1 = nil
	self.e1P2 = nil
	self.e2P1 = nil
	self.e2P2 = nil
	self.e1P1Extra = nil
	self.e1P2Extra = nil
	self.e2P1Extra = nil
	self.e2P2Extra = nil
	self.costExtra = nil
	self.roundBuffList = nil
	self.gameBuffList = nil
end

function HandCardInfo:ClearBuff()
	self.e1P1Extra = 0
	self.e1P2Extra = 0
	self.e2P1Extra = 0
	self.e2P2Extra = 0
	self.costExtra = 0

	table.clear(self.roundBuffList)
	table.clear(self.gameBuffList)
end

function HandCardInfo:TryAddBuff(buff, roundOrGame, index)
	local isAdd = false

	if buff.effectType == DivinerCardEventConfig.EventTypeType.AddTrustValuePCTBuff or buff.effectType == DivinerCardEventConfig.EventTypeType.RemoveTrustValuePCTBuff then
		local invert = buff.effectType == DivinerCardEventConfig.EventTypeType.RemoveTrustValuePCTBuff

		if self.event1Cfg and self.event1Cfg.EventType == DivinerCardEventConfig.EventTypeType.AddTrustValue then
			local val = math.ceil(self.e1P1 * buff.param1 / 100)

			if invert then
				val = -val
			end

			self.e1P1Extra = self.e1P1Extra + val
			isAdd = true
		end

		if self.event2Cfg and self.event2Cfg.EventType == DivinerCardEventConfig.EventTypeType.AddTrustValue then
			local val = math.ceil(self.e2P1 * buff.param1 / 100)

			if invert then
				val = -val
			end

			self.e2P1Extra = self.e2P1Extra + val
			isAdd = true
		end
	end

	if buff.effectType == DivinerCardEventConfig.EventTypeType.AddTrustValueBuff or buff.effectType == DivinerCardEventConfig.EventTypeType.RemoveTrustValueBuff then
		local invert = buff.effectType == DivinerCardEventConfig.EventTypeType.RemoveTrustValueBuff

		if self.event1Cfg and self.event1Cfg.EventType == DivinerCardEventConfig.EventTypeType.AddTrustValue then
			local val = buff.param1

			if invert then
				val = -val
			end

			self.e1P1Extra = self.e1P1Extra + val
			isAdd = true
		end

		if self.event2Cfg and self.event2Cfg.EventType == DivinerCardEventConfig.EventTypeType.AddTrustValue then
			local val = buff.param1

			if invert then
				val = -val
			end

			self.e2P1Extra = self.e2P1Extra + val
			isAdd = true
		end
	end

	if buff.effectType == DivinerCardEventConfig.EventTypeType.AddPatienceValueBuff or buff.effectType == DivinerCardEventConfig.EventTypeType.RemovePatienceValueBuff then
		local invert = buff.effectType == DivinerCardEventConfig.EventTypeType.RemovePatienceValueBuff
		local val = buff.param1

		if invert then
			val = -val
		end

		self.costExtra = self.costExtra + val
		isAdd = true
	end

	if isAdd then
		if roundOrGame then
			self:AddRoundBuff(index)
		else
			self:AddGameBuff(index)
		end
	end
end

function HandCardInfo:AddRoundBuff(index)
	table.insert(self.roundBuffList, index)
end

function HandCardInfo:AddGameBuff(index)
	table.insert(self.gameBuffList, index)
end

function HandCardInfo:GetCost()
	return math.max(self.cost + self.costExtra, 0)
end
