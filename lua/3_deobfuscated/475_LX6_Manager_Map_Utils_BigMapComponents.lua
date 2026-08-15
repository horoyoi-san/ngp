EBigMapComponentType = {
	SwitchMapMode = 5,
	InScreenElementsList = 8,
	TaxiTargetList = 3,
	RightTopFilterList = 11,
	GameTipVisibility = 103,
	LegendOverride = 104,
	FactionOverride = 4,
	Tooltip = 101,
	CommonView = 200,
	Money = 7,
	MetroView = 202,
	AreaSelector = 6,
	GangsterArea = 9,
	TaxiView = 201,
	FilterMenu = 2,
	SwitchBigMapSpirit = 1
}
local SystemConfig = LTConfig.SystemUnlockConfig
BigMapComp_TaxiTargetList = BigMapComp_TaxiTargetList or {}
local M = BigMapComp_TaxiTargetList
M.__index = M

function M:OnInit()
	self.bindData.elementListBtn:SetActive(false)
end

function M:OnActive()
	self.bindData.elementListBtn:SetActive(true)
end

function M:OnInactive()
	self.bindData.elementListBtn:SetActive(false)
end

BigMapComp_CommonView = BigMapComp_CommonView or {}
local M = BigMapComp_CommonView
M.__index = M

function M:OnActive()
	if self.bigMap:IsJiaMuViewEnabled() then
		self.bigMap:SetViewMask(EMapViewMask.Gangster + EMapViewMask.BigMap)
	else
		self.bigMap:SetViewMask(EMapViewMask.BigMap)
	end

	self.bigMap.compRefs.SwitchMapMode:SetMode("Common")
	self.bigMap:RefreshPinBtnState()
end

function M:OnInactive()
	return
end

BigMapComp_TaxiView = BigMapComp_TaxiView or {}
local M = BigMapComp_TaxiView
M.__index = M

function M:OnActive()
	self.bigMap:SetViewMask(EMapViewMask.Taxi)
end

function M:OnInactive()
	return
end

BigMapComp_MetroView = BigMapComp_MetroView or {}
local M = BigMapComp_MetroView
M.__index = M

function M:OnActive()
	self.bigMap:SetViewMask(EMapViewMask.Metro)
end

function M:OnInactive()
	return
end

BigMapComp_AreaSelector = BigMapComp_AreaSelector or {}
local M = BigMapComp_AreaSelector
M.__index = M

function M:OnInit()
	self.bindData.mapAreaListPanel:SetActive(false)
end

function M:OnActive()
	self.bindData.mapAreaListPanel:SetActive(true)
end

function M:OnInactive()
	self.bindData.mapAreaListPanel:SetActive(false)
end

BigMapComp_Money = BigMapComp_Money or {}
local M = BigMapComp_Money
M.__index = M

function M:OnInit()
	return
end

function M:OnStart()
	self.bigMap.SubGroup.MoneyTemplateStore:SetData({})
end

function M:OnActive()
	self.bigMap.SubGroup.MoneyTemplateStore:SetData({
		{
			DisableInteract = true,
			Type = LTConfig.ConsumableConfig.RewardMoney
		}
	})
end

function M:OnInactive()
	self.bigMap.SubGroup.MoneyTemplateStore:SetData({})
end

dofile("LX6/Manager/Map/Utils/BigMapComps/BigMapComp_FactionOverride")
dofile("LX6/Manager/Map/Utils/BigMapComps/BigMapComp_SwitchSpirit")
dofile("LX6/Manager/Map/Utils/BigMapComps/BigMapComp_SwitchMapMode")
dofile("LX6/Manager/Map/Utils/BigMapComps/BigMapComp_Tooltip")
dofile("LX6/Manager/Map/Utils/BigMapComps/BigMapComp_LegendOverride")
dofile("LX6/Manager/Map/Utils/BigMapComps/FilterMenu/BigMapComp_FilterMenu")
dofile("LX6/Manager/Map/Utils/BigMapComps/BigMapComp_InScreenElementsList")
dofile("LX6/Manager/Map/Utils/BigMapComps/BigMapComp_GangsterArea")
dofile("LX6/Manager/Map/Utils/BigMapComps/BigMapComp_RightTopFilterList")

gBigMapComponentConfigs = {
	[EBigMapComponentType.SwitchBigMapSpirit] = {
		cls = BigMapComp_SwitchSpirit,
		conflictState = {
			EBigMapFSMState.Interaction_Selected
		},
		requireState = {
			EBigMapFSMState.BigWorld,
			EBigMapFSMState.CommonMode
		},
		systemUnlock = {
			SystemConfig.SwitchSpiritWheel
		}
	},
	[EBigMapComponentType.FilterMenu] = {
		cls = BigMapComp_FilterMenu,
		requireState = {
			EBigMapFSMState.BigWorld,
			EBigMapFSMState.CommonMode
		}
	},
	[EBigMapComponentType.TaxiTargetList] = {
		cls = BigMapComp_TaxiTargetList,
		requireState = {
			EBigMapFSMState.TaxiMode
		}
	},
	[EBigMapComponentType.CommonView] = {
		cls = BigMapComp_CommonView,
		requireState = {
			EBigMapFSMState.CommonMode
		}
	},
	[EBigMapComponentType.TaxiView] = {
		cls = BigMapComp_TaxiView,
		requireState = {
			EBigMapFSMState.TaxiMode
		}
	},
	[EBigMapComponentType.MetroView] = {
		cls = BigMapComp_MetroView,
		requireState = {
			EBigMapFSMState.MetroMode
		}
	},
	[EBigMapComponentType.FactionOverride] = {
		cls = BigMapComp_FactionOverride,
		requireState = {
			EBigMapFSMState.FactionMode
		}
	},
	[EBigMapComponentType.SwitchMapMode] = {
		cls = BigMapComp_SwitchMapMode,
		requireState = {
			EBigMapFSMState.BigWorld
		},
		conflictState = {
			EBigMapFSMState.TaxiMode,
			EBigMapFSMState.MetroMode,
			EBigMapFSMState.Interaction_Selected
		}
	},
	[EBigMapComponentType.AreaSelector] = {
		cls = BigMapComp_AreaSelector,
		requireState = {
			EBigMapFSMState.CommonMode
		},
		conflictState = {
			EBigMapFSMState.OtherRaid
		}
	},
	[EBigMapComponentType.Tooltip] = {
		cls = BigMapComp_Tooltip,
		requireState = {
			EBigMapFSMState.Interaction_Selected
		}
	},
	[EBigMapComponentType.GameTipVisibility] = {
		cls = BigMapComp_GameTipVisibility,
		conflictState = {
			EBigMapFSMState.Interaction_Selected
		}
	},
	[EBigMapComponentType.LegendOverride] = {
		cls = BigMapComp_LegendOverride,
		requireState = {
			EBigMapFSMState.LegendMode
		}
	},
	[EBigMapComponentType.Money] = {
		cls = BigMapComp_Money,
		requireState = {
			EBigMapFSMState.BigWorld,
			EBigMapFSMState.TaxiMode
		}
	},
	[EBigMapComponentType.InScreenElementsList] = {
		cls = BigMapComp_InScreenElementsList,
		requireState = {
			EBigMapFSMState.BigWorld,
			EBigMapFSMState.CommonMode,
			EBigMapFSMState.Filter_Disable
		},
		conflictState = {
			EBigMapFSMState.Interaction_Selected
		}
	},
	[EBigMapComponentType.GangsterArea] = {
		cls = BigMapComp_GangsterArea,
		requireState = {
			EBigMapFSMState.BigWorld,
			EBigMapFSMState.CommonMode,
			EBigMapFSMState.JiaMuView_Open
		}
	},
	[EBigMapComponentType.RightTopFilterList] = {
		cls = BigMapComp_RightTopFilterList,
		requireState = {
			EBigMapFSMState.BigWorld,
			EBigMapFSMState.CommonMode,
			EBigMapFSMState.Filter_Enable
		},
		conflictState = {
			EBigMapFSMState.Interaction_Selected
		}
	}
}
