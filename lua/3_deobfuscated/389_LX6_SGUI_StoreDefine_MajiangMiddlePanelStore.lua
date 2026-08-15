C_MajiangMiddlePanelStore = DefClass("C_MajiangMiddlePanelStore", C_MajiangMiddlePanelStore, C_StoreGroup)
GroupName2Class.MajiangMiddlePanelStore = C_MajiangMiddlePanelStore
local M = C_MajiangMiddlePanelStore

function M:ctor()
	self.storeDict = {}
	self.storeCount = 0
end

function M:OnAwake(widget)
	return
end

function M:OnEnable(widget)
	local store = self:GetStoreByWidget(widget)

	if not store then
		return
	end

	self.storeDict[widget.gameObject:GetInstanceID()] = store
	self.storeCount = self.storeCount + 1

	gMaJiangManager:RegisterMiddleStore(self)
end

function M:OnStart(widget)
	return
end

function M:OnDisable(widget)
	if self.storeDict[widget.gameObject:GetInstanceID()] ~= nil then
		self.storeDict[widget.gameObject:GetInstanceID()] = nil
		self.storeCount = self.storeCount - 1
	end

	if self.storeCount == 0 then
		gMaJiangManager:UnRegisterMiddleStore()
	end
end

function M:OnDestroy(widget)
	return
end

function M:RefreshSeat(nowSeatId)
	for _, store in pairs(self.storeDict) do
		store.nowSeatId = nowSeatId
	end
end

function M:RefreshSeatName(seatNames)
	for _, store in pairs(self.storeDict) do
		store.seatName1 = seatNames[1]
		store.seatName2 = seatNames[2]
		store.seatName3 = seatNames[3]
		store.seatName4 = seatNames[4]
	end
end

function M:RefreshCountDown(countDown)
	for _, store in pairs(self.storeDict) do
		store.countDown = countDown
	end
end

function M:RefreshIsShow(isShow)
	for _, store in pairs(self.storeDict) do
		store.isShow = isShow
	end
end
