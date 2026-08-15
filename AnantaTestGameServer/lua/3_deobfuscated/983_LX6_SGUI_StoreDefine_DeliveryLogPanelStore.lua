C_DeliveryLogPanelStore = DefClass("C_DeliveryLogPanelStore", C_DeliveryLogPanelStore, C_StoreGroup)
GroupName2Class.DeliveryLogPanelStore = C_DeliveryLogPanelStore
local M = C_DeliveryLogPanelStore
local OrderConfig = LTConfig.UberSimOrderConfig
local DropConfig = LTConfig.DropConfig
local TextConfig = LTConfig.TextConfig
local UXTime = LTUtils.UXTime
local DeliveryJobId = 11300005

function M:ctor()
	return
end

function M:OnAwake()
	self.allMoney = 0
	self.bindData.logList.luaSimpleRenderItem = self:CreateAction("OnRenderLogItem")
end

function M:OnShow(panelId, data)
	self.allMoney = 0
	self.bindData.totalMoney = ""
	self.commentText = TextConfig.GetConfig(73970528).Text
	self.timeText = TextConfig.GetConfig(73970527).Text

	if data then
		self:InitLogList(data)
	end
end

function M:InitLogList(data)
	self.historyInfos = {}

	if data.Length == 0 then
		return
	end

	for i = 1, #data do
		local v = data[i]

		if v then
			local log = {
				EventId = v.EventId
			}
			local date = UXTime.UnixTimeToDateTime(v.FinishTime)
			log.time = gString.Format("%d.%d.%d", date.Year, date.Month, date.Day)
			log.PassengerId = v.PassengerId
			log.commentId = v.AppraiseId

			for j = 0, OrderConfig.count - 1 do
				local cfg = OrderConfig.LoadAt(j)

				if cfg.EventId == v.EventId then
					log.destination = cfg.information
					local limitText = ""
					local time = v.FinishTime - v.StartTime

					if time > cfg.TimeLimit * 60 then
						limitText = self.timeText
					end

					local rawMin = time <= 0 and 0 or math.floor(time / 60)
					local rawSec = 0
					rawSec = time <= 0 and 0 or math.floor((time - rawMin * 60) % 60)
					log.orderTime = gString.Format("%02d:%02d ", rawMin, rawSec) .. limitText

					break
				end
			end

			log.comment = gString.Format(self.commentText, math.floor(v.Completeness * 100 + 0.5)) .. "%"
			local dropId = v.DropId
			local dropConfig = DropConfig.GetConfig(dropId)

			if dropConfig ~= nil then
				log.income = dropConfig.Money

				for _, val in pairs(dropConfig.JobExp) do
					if val.Jobclassid == DeliveryJobId then
						log.exp = val.count

						break
					end
				end

				self.allMoney = self.allMoney + dropConfig.Money
			else
				print_error("Truck dropId error dropId is ", dropId, "eventId is ", v.EventId)

				log.exp = 0
			end

			log.arrayIndex = #self.historyInfos + 1

			table.insert(self.historyInfos, log)
		end
	end

	self.bindData.totalMoney = tostring(self.allMoney)

	self.bindData.logList:SetSimpleList(#self.historyInfos)
end

function M:OnRenderLogItem(btn, index)
	local id = btn.gameObject:GetInstanceID()
	local store = self:GetStoreById(id)
	local data = self.historyInfos[index + 1]

	if store and data then
		store.incomeText = tostring(data.income)
		store.time = data.time
		store.orderTime = data.orderTime
		store.destination = data.destination
		store.integrity = data.comment
		store.exp = "+" .. data.exp
	end
end
