-- chunkname: @Lua\\LuaGen\\AutoGen\\RPCDeserializeAuto.lua

local Base = require("LX6/Service/RPCDeserializeBase")
local LoginToClientImpl = require("LX6/Service/LoginToClientImpl")
local MasterToClientImpl = require("LX6/Service/MasterToClientImpl")
local MasterGMToClientImpl = require("LX6/Service/MasterGMToClientImpl")
local GateToClientImpl = require("LX6/Service/GateToClientImpl")
local GameToClientImpl = require("LX6/Service/GameToClientImpl")
local GameGMToClientImpl = require("LX6/Service/GameGMToClientImpl")
local GameSceneToClientImpl = require("LX6/Service/GameSceneToClientImpl")
local GameSceneGMToClientImpl = require("LX6/Service/GameSceneGMToClientImpl")
local MahjongToClientImpl = require("LX6/Service/MahjongToClientImpl")
local MahjongPlayerToClientImpl = require("LX6/Service/MahjongPlayerToClientImpl")
local ChatToClientImpl = require("LX6/Service/ChatToClientImpl")
local MinorToClientImpl = require("LX6/Service/MinorToClientImpl")
local AllToClientImpl = require("LX6/Service/AllToClientImpl")
local AvatarToClientImpl = require("LX6/Service/AvatarToClientImpl")
local MatchToClientImpl = require("LX6/Service/MatchToClientImpl")
local LinkToClientImpl = require("LX6/Service/LinkToClientImpl")
local Auto = {}
local SerializeObjectMarkNull = 0
local SerializeObjectMarkCommon = 255
local LuaOnly = 0
local CSharpOnly = 1
local LuaAndCSharp = 2

Auto.midToReader = {}
Auto.sidToImpl = {}
Auto.midToName = {}
Auto.Reader = {}
Auto.Dispatch = {}
Auto.Meta = {}

local Concrete = {}

Auto.midToExportOption = {}
Auto.midToReturnMessageReader = {}
Auto.childTypeToParentType = {}

function Auto:Init()
	self.sidToImpl[35] = LoginToClientImpl
	self.sidToImpl[45] = MasterToClientImpl
	self.sidToImpl[47] = MasterGMToClientImpl
	self.sidToImpl[53] = GateToClientImpl
	self.sidToImpl[64] = GameToClientImpl
	self.sidToImpl[66] = GameGMToClientImpl
	self.sidToImpl[68] = GameSceneToClientImpl
	self.sidToImpl[70] = GameSceneGMToClientImpl
	self.sidToImpl[115] = MahjongToClientImpl
	self.sidToImpl[116] = MahjongPlayerToClientImpl
	self.sidToImpl[124] = ChatToClientImpl
	self.sidToImpl[127] = MinorToClientImpl
	self.sidToImpl[128] = AllToClientImpl
	self.sidToImpl[154] = AvatarToClientImpl
	self.sidToImpl[203] = MatchToClientImpl
	self.sidToImpl[204] = LinkToClientImpl
	self.midToExportOption[35056687] = LuaOnly
	self.midToExportOption[35058902] = LuaOnly
	self.midToExportOption[35173411] = LuaOnly
	self.midToExportOption[35212978] = LuaOnly
	self.midToExportOption[35291748] = CSharpOnly
	self.midToExportOption[35500450] = CSharpOnly
	self.midToExportOption[35689543] = LuaOnly
	self.midToExportOption[35842068] = LuaOnly
	self.midToExportOption[35901345] = CSharpOnly
	self.midToExportOption[45025692] = LuaOnly
	self.midToExportOption[45234526] = CSharpOnly
	self.midToExportOption[45236898] = CSharpOnly
	self.midToExportOption[45278185] = CSharpOnly
	self.midToExportOption[45328604] = LuaOnly
	self.midToExportOption[45336979] = CSharpOnly
	self.midToExportOption[45390631] = CSharpOnly
	self.midToExportOption[45513348] = LuaOnly
	self.midToExportOption[45521637] = CSharpOnly
	self.midToExportOption[45661055] = CSharpOnly
	self.midToExportOption[45666168] = CSharpOnly
	self.midToExportOption[45690804] = CSharpOnly
	self.midToExportOption[45720425] = CSharpOnly
	self.midToExportOption[45780556] = CSharpOnly
	self.midToExportOption[45781151] = LuaOnly
	self.midToExportOption[45785020] = CSharpOnly
	self.midToExportOption[45822588] = CSharpOnly
	self.midToExportOption[45835952] = CSharpOnly
	self.midToExportOption[45877241] = CSharpOnly
	self.midToExportOption[45942916] = CSharpOnly
	self.midToExportOption[45977140] = CSharpOnly
	self.midToExportOption[45986513] = CSharpOnly
	self.midToExportOption[45989137] = CSharpOnly
	self.midToExportOption[47004153] = CSharpOnly
	self.midToExportOption[47075951] = CSharpOnly
	self.midToExportOption[47096096] = CSharpOnly
	self.midToExportOption[47351064] = CSharpOnly
	self.midToExportOption[47816155] = CSharpOnly
	self.midToExportOption[53124588] = CSharpOnly
	self.midToExportOption[53411713] = CSharpOnly
	self.midToExportOption[53677964] = LuaOnly
	self.midToExportOption[53848361] = CSharpOnly
	self.midToExportOption[53913220] = LuaOnly
	self.midToExportOption[64000570] = LuaOnly
	self.midToExportOption[64002073] = LuaOnly
	self.midToExportOption[64008630] = CSharpOnly
	self.midToExportOption[64009562] = LuaOnly
	self.midToExportOption[64024664] = LuaOnly
	self.midToExportOption[64024863] = LuaOnly
	self.midToExportOption[64027750] = CSharpOnly
	self.midToExportOption[64028687] = LuaOnly
	self.midToExportOption[64030205] = LuaOnly
	self.midToExportOption[64032762] = LuaOnly
	self.midToExportOption[64033370] = CSharpOnly
	self.midToExportOption[64043553] = LuaOnly
	self.midToExportOption[64050603] = LuaOnly
	self.midToExportOption[64051530] = LuaOnly
	self.midToExportOption[64054119] = LuaOnly
	self.midToExportOption[64055698] = LuaOnly
	self.midToExportOption[64059110] = LuaOnly
	self.midToExportOption[64061100] = LuaOnly
	self.midToExportOption[64062943] = LuaAndCSharp
	self.midToExportOption[64066495] = LuaOnly
	self.midToExportOption[64067604] = LuaOnly
	self.midToExportOption[64074256] = LuaOnly
	self.midToExportOption[64081527] = LuaOnly
	self.midToExportOption[64081924] = LuaAndCSharp
	self.midToExportOption[64082910] = LuaOnly
	self.midToExportOption[64084105] = LuaOnly
	self.midToExportOption[64085008] = LuaOnly
	self.midToExportOption[64086058] = LuaOnly
	self.midToExportOption[64090638] = LuaAndCSharp
	self.midToExportOption[64091591] = LuaOnly
	self.midToExportOption[64094083] = LuaOnly
	self.midToExportOption[64096144] = LuaOnly
	self.midToExportOption[64096520] = LuaAndCSharp
	self.midToExportOption[64099878] = CSharpOnly
	self.midToExportOption[64108636] = LuaOnly
	self.midToExportOption[64113875] = LuaOnly
	self.midToExportOption[64114508] = LuaOnly
	self.midToExportOption[64124614] = LuaOnly
	self.midToExportOption[64125250] = LuaAndCSharp
	self.midToExportOption[64127246] = CSharpOnly
	self.midToExportOption[64127654] = LuaAndCSharp
	self.midToExportOption[64128323] = LuaOnly
	self.midToExportOption[64133996] = LuaOnly
	self.midToExportOption[64138587] = LuaOnly
	self.midToExportOption[64141487] = LuaOnly
	self.midToExportOption[64149542] = LuaAndCSharp
	self.midToExportOption[64158503] = LuaOnly
	self.midToExportOption[64177020] = LuaOnly
	self.midToExportOption[64182413] = LuaOnly
	self.midToExportOption[64184050] = CSharpOnly
	self.midToExportOption[64184789] = LuaOnly
	self.midToExportOption[64190422] = LuaOnly
	self.midToExportOption[64191855] = LuaOnly
	self.midToExportOption[64193396] = LuaOnly
	self.midToExportOption[64196149] = LuaOnly
	self.midToExportOption[64203304] = LuaOnly
	self.midToExportOption[64206120] = LuaOnly
	self.midToExportOption[64208235] = LuaOnly
	self.midToExportOption[64214284] = LuaOnly
	self.midToExportOption[64214885] = LuaOnly
	self.midToExportOption[64220410] = CSharpOnly
	self.midToExportOption[64227768] = LuaAndCSharp
	self.midToExportOption[64227911] = LuaOnly
	self.midToExportOption[64233556] = LuaOnly
	self.midToExportOption[64240574] = LuaOnly
	self.midToExportOption[64250239] = LuaAndCSharp
	self.midToExportOption[64257127] = CSharpOnly
	self.midToExportOption[64263325] = LuaOnly
	self.midToExportOption[64263949] = LuaOnly
	self.midToExportOption[64265105] = LuaOnly
	self.midToExportOption[64268796] = LuaOnly
	self.midToExportOption[64271294] = LuaOnly
	self.midToExportOption[64273706] = CSharpOnly
	self.midToExportOption[64276158] = LuaOnly
	self.midToExportOption[64276238] = LuaOnly
	self.midToExportOption[64276328] = LuaOnly
	self.midToExportOption[64277564] = LuaOnly
	self.midToExportOption[64279408] = CSharpOnly
	self.midToExportOption[64282983] = LuaOnly
	self.midToExportOption[64289993] = CSharpOnly
	self.midToExportOption[64290317] = LuaOnly
	self.midToExportOption[64294476] = LuaOnly
	self.midToExportOption[64300702] = LuaOnly
	self.midToExportOption[64307917] = LuaAndCSharp
	self.midToExportOption[64309285] = LuaAndCSharp
	self.midToExportOption[64314729] = LuaOnly
	self.midToExportOption[64323657] = LuaAndCSharp
	self.midToExportOption[64323859] = LuaAndCSharp
	self.midToExportOption[64325689] = CSharpOnly
	self.midToExportOption[64330159] = LuaOnly
	self.midToExportOption[64333365] = LuaOnly
	self.midToExportOption[64338922] = LuaOnly
	self.midToExportOption[64341180] = LuaOnly
	self.midToExportOption[64349771] = LuaOnly
	self.midToExportOption[64350941] = LuaAndCSharp
	self.midToExportOption[64351404] = LuaOnly
	self.midToExportOption[64352235] = LuaOnly
	self.midToExportOption[64354845] = LuaOnly
	self.midToExportOption[64358420] = LuaOnly
	self.midToExportOption[64358656] = LuaOnly
	self.midToExportOption[64362626] = LuaOnly
	self.midToExportOption[64370898] = LuaOnly
	self.midToExportOption[64373720] = LuaOnly
	self.midToExportOption[64377362] = LuaAndCSharp
	self.midToExportOption[64379333] = LuaOnly
	self.midToExportOption[64383019] = LuaOnly
	self.midToExportOption[64383561] = LuaOnly
	self.midToExportOption[64384300] = LuaOnly
	self.midToExportOption[64389316] = LuaAndCSharp
	self.midToExportOption[64395886] = CSharpOnly
	self.midToExportOption[64402561] = CSharpOnly
	self.midToExportOption[64402770] = LuaOnly
	self.midToExportOption[64415819] = LuaAndCSharp
	self.midToExportOption[64416807] = LuaOnly
	self.midToExportOption[64420640] = LuaOnly
	self.midToExportOption[64423076] = LuaOnly
	self.midToExportOption[64428806] = LuaOnly
	self.midToExportOption[64437425] = LuaOnly
	self.midToExportOption[64438260] = LuaOnly
	self.midToExportOption[64440416] = LuaAndCSharp
	self.midToExportOption[64443578] = LuaOnly
	self.midToExportOption[64444366] = LuaOnly
	self.midToExportOption[64450572] = LuaOnly
	self.midToExportOption[64453933] = LuaAndCSharp
	self.midToExportOption[64454079] = LuaOnly
	self.midToExportOption[64454937] = LuaOnly
	self.midToExportOption[64456279] = LuaOnly
	self.midToExportOption[64462927] = LuaOnly
	self.midToExportOption[64467486] = LuaOnly
	self.midToExportOption[64472143] = LuaOnly
	self.midToExportOption[64484151] = CSharpOnly
	self.midToExportOption[64484280] = LuaOnly
	self.midToExportOption[64485852] = LuaOnly
	self.midToExportOption[64495540] = LuaOnly
	self.midToExportOption[64509181] = LuaOnly
	self.midToExportOption[64517450] = CSharpOnly
	self.midToExportOption[64519765] = LuaAndCSharp
	self.midToExportOption[64534124] = LuaOnly
	self.midToExportOption[64535774] = LuaOnly
	self.midToExportOption[64536148] = CSharpOnly
	self.midToExportOption[64539241] = LuaOnly
	self.midToExportOption[64542461] = LuaAndCSharp
	self.midToExportOption[64544191] = LuaOnly
	self.midToExportOption[64551745] = LuaOnly
	self.midToExportOption[64553341] = LuaAndCSharp
	self.midToExportOption[64557867] = LuaOnly
	self.midToExportOption[64564516] = LuaOnly
	self.midToExportOption[64566661] = LuaOnly
	self.midToExportOption[64573061] = LuaOnly
	self.midToExportOption[64573658] = LuaOnly
	self.midToExportOption[64574748] = LuaOnly
	self.midToExportOption[64574821] = LuaOnly
	self.midToExportOption[64576140] = LuaOnly
	self.midToExportOption[64579368] = LuaAndCSharp
	self.midToExportOption[64580834] = LuaOnly
	self.midToExportOption[64581024] = LuaOnly
	self.midToExportOption[64587006] = LuaOnly
	self.midToExportOption[64589836] = LuaOnly
	self.midToExportOption[64594789] = LuaOnly
	self.midToExportOption[64599072] = LuaOnly
	self.midToExportOption[64599282] = LuaOnly
	self.midToExportOption[64602397] = LuaOnly
	self.midToExportOption[64611093] = CSharpOnly
	self.midToExportOption[64619526] = LuaAndCSharp
	self.midToExportOption[64620949] = LuaOnly
	self.midToExportOption[64621842] = LuaAndCSharp
	self.midToExportOption[64626131] = LuaOnly
	self.midToExportOption[64628013] = LuaOnly
	self.midToExportOption[64630599] = LuaOnly
	self.midToExportOption[64634278] = CSharpOnly
	self.midToExportOption[64638005] = LuaOnly
	self.midToExportOption[64641895] = LuaOnly
	self.midToExportOption[64646049] = LuaOnly
	self.midToExportOption[64652219] = LuaOnly
	self.midToExportOption[64653833] = LuaOnly
	self.midToExportOption[64661996] = LuaOnly
	self.midToExportOption[64662440] = LuaOnly
	self.midToExportOption[64671698] = LuaOnly
	self.midToExportOption[64672612] = LuaOnly
	self.midToExportOption[64676793] = LuaAndCSharp
	self.midToExportOption[64682455] = LuaAndCSharp
	self.midToExportOption[64685674] = LuaOnly
	self.midToExportOption[64690406] = LuaOnly
	self.midToExportOption[64692146] = LuaOnly
	self.midToExportOption[64693614] = LuaOnly
	self.midToExportOption[64697069] = CSharpOnly
	self.midToExportOption[64708333] = LuaAndCSharp
	self.midToExportOption[64709905] = LuaOnly
	self.midToExportOption[64711781] = LuaOnly
	self.midToExportOption[64722012] = CSharpOnly
	self.midToExportOption[64734958] = LuaOnly
	self.midToExportOption[64735329] = LuaOnly
	self.midToExportOption[64737256] = LuaOnly
	self.midToExportOption[64740104] = LuaAndCSharp
	self.midToExportOption[64745458] = LuaAndCSharp
	self.midToExportOption[64745836] = CSharpOnly
	self.midToExportOption[64749352] = LuaOnly
	self.midToExportOption[64750996] = LuaOnly
	self.midToExportOption[64765180] = LuaOnly
	self.midToExportOption[64767077] = CSharpOnly
	self.midToExportOption[64770574] = LuaOnly
	self.midToExportOption[64771401] = LuaOnly
	self.midToExportOption[64772212] = LuaOnly
	self.midToExportOption[64780410] = LuaAndCSharp
	self.midToExportOption[64784818] = LuaOnly
	self.midToExportOption[64786930] = LuaOnly
	self.midToExportOption[64787777] = LuaOnly
	self.midToExportOption[64790694] = LuaAndCSharp
	self.midToExportOption[64791397] = LuaOnly
	self.midToExportOption[64795895] = LuaOnly
	self.midToExportOption[64799473] = LuaAndCSharp
	self.midToExportOption[64804461] = LuaOnly
	self.midToExportOption[64819491] = LuaOnly
	self.midToExportOption[64822851] = LuaAndCSharp
	self.midToExportOption[64822920] = LuaOnly
	self.midToExportOption[64823589] = LuaOnly
	self.midToExportOption[64824976] = LuaOnly
	self.midToExportOption[64826755] = CSharpOnly
	self.midToExportOption[64833906] = LuaOnly
	self.midToExportOption[64842871] = LuaOnly
	self.midToExportOption[64843031] = LuaOnly
	self.midToExportOption[64852033] = LuaAndCSharp
	self.midToExportOption[64854957] = LuaOnly
	self.midToExportOption[64856145] = LuaOnly
	self.midToExportOption[64856470] = LuaOnly
	self.midToExportOption[64857448] = LuaOnly
	self.midToExportOption[64860567] = LuaOnly
	self.midToExportOption[64861390] = LuaOnly
	self.midToExportOption[64861577] = LuaOnly
	self.midToExportOption[64862193] = LuaOnly
	self.midToExportOption[64864346] = LuaOnly
	self.midToExportOption[64865387] = LuaOnly
	self.midToExportOption[64866915] = LuaOnly
	self.midToExportOption[64868156] = LuaAndCSharp
	self.midToExportOption[64870478] = LuaOnly
	self.midToExportOption[64873229] = LuaOnly
	self.midToExportOption[64875023] = LuaAndCSharp
	self.midToExportOption[64879093] = LuaAndCSharp
	self.midToExportOption[64879625] = LuaAndCSharp
	self.midToExportOption[64881952] = LuaAndCSharp
	self.midToExportOption[64882664] = LuaAndCSharp
	self.midToExportOption[64883472] = LuaOnly
	self.midToExportOption[64888344] = LuaOnly
	self.midToExportOption[64889017] = LuaOnly
	self.midToExportOption[64891221] = LuaOnly
	self.midToExportOption[64893487] = LuaOnly
	self.midToExportOption[64893691] = LuaOnly
	self.midToExportOption[64894291] = CSharpOnly
	self.midToExportOption[64896820] = CSharpOnly
	self.midToExportOption[64900755] = LuaOnly
	self.midToExportOption[64903065] = LuaOnly
	self.midToExportOption[64904037] = CSharpOnly
	self.midToExportOption[64909391] = LuaOnly
	self.midToExportOption[64916867] = LuaOnly
	self.midToExportOption[64916956] = LuaAndCSharp
	self.midToExportOption[64920050] = LuaAndCSharp
	self.midToExportOption[64927146] = LuaOnly
	self.midToExportOption[64931280] = LuaAndCSharp
	self.midToExportOption[64932574] = LuaOnly
	self.midToExportOption[64938335] = LuaOnly
	self.midToExportOption[64939922] = LuaAndCSharp
	self.midToExportOption[64945644] = LuaAndCSharp
	self.midToExportOption[64945945] = LuaOnly
	self.midToExportOption[64946100] = LuaOnly
	self.midToExportOption[64949986] = LuaOnly
	self.midToExportOption[64950962] = CSharpOnly
	self.midToExportOption[64955067] = LuaAndCSharp
	self.midToExportOption[64960991] = LuaAndCSharp
	self.midToExportOption[64963363] = LuaOnly
	self.midToExportOption[64967055] = LuaOnly
	self.midToExportOption[64968867] = LuaOnly
	self.midToExportOption[64971352] = LuaOnly
	self.midToExportOption[64976571] = LuaOnly
	self.midToExportOption[64992676] = CSharpOnly
	self.midToExportOption[64994824] = LuaOnly
	self.midToExportOption[66183523] = LuaAndCSharp
	self.midToExportOption[66388620] = CSharpOnly
	self.midToExportOption[66688121] = CSharpOnly
	self.midToExportOption[66711481] = LuaAndCSharp
	self.midToExportOption[68001251] = LuaOnly
	self.midToExportOption[68002111] = LuaOnly
	self.midToExportOption[68002141] = LuaAndCSharp
	self.midToExportOption[68007325] = LuaAndCSharp
	self.midToExportOption[68008375] = CSharpOnly
	self.midToExportOption[68008896] = LuaOnly
	self.midToExportOption[68011793] = LuaAndCSharp
	self.midToExportOption[68012290] = CSharpOnly
	self.midToExportOption[68019256] = CSharpOnly
	self.midToExportOption[68020369] = CSharpOnly
	self.midToExportOption[68021038] = LuaAndCSharp
	self.midToExportOption[68022958] = CSharpOnly
	self.midToExportOption[68027187] = LuaAndCSharp
	self.midToExportOption[68029044] = LuaOnly
	self.midToExportOption[68032672] = LuaOnly
	self.midToExportOption[68033182] = LuaOnly
	self.midToExportOption[68033874] = CSharpOnly
	self.midToExportOption[68035270] = LuaAndCSharp
	self.midToExportOption[68035599] = LuaAndCSharp
	self.midToExportOption[68038914] = CSharpOnly
	self.midToExportOption[68040060] = CSharpOnly
	self.midToExportOption[68041040] = LuaAndCSharp
	self.midToExportOption[68041051] = CSharpOnly
	self.midToExportOption[68042828] = CSharpOnly
	self.midToExportOption[68043902] = CSharpOnly
	self.midToExportOption[68050399] = CSharpOnly
	self.midToExportOption[68054311] = CSharpOnly
	self.midToExportOption[68054379] = CSharpOnly
	self.midToExportOption[68054711] = LuaAndCSharp
	self.midToExportOption[68060244] = CSharpOnly
	self.midToExportOption[68063514] = CSharpOnly
	self.midToExportOption[68066325] = CSharpOnly
	self.midToExportOption[68068447] = CSharpOnly
	self.midToExportOption[68069490] = CSharpOnly
	self.midToExportOption[68070203] = CSharpOnly
	self.midToExportOption[68075387] = CSharpOnly
	self.midToExportOption[68077111] = CSharpOnly
	self.midToExportOption[68080517] = CSharpOnly
	self.midToExportOption[68080713] = LuaOnly
	self.midToExportOption[68082015] = CSharpOnly
	self.midToExportOption[68082594] = CSharpOnly
	self.midToExportOption[68084611] = LuaOnly
	self.midToExportOption[68089641] = CSharpOnly
	self.midToExportOption[68090520] = CSharpOnly
	self.midToExportOption[68091716] = LuaOnly
	self.midToExportOption[68092012] = CSharpOnly
	self.midToExportOption[68096613] = CSharpOnly
	self.midToExportOption[68098454] = CSharpOnly
	self.midToExportOption[68098630] = LuaAndCSharp
	self.midToExportOption[68098668] = CSharpOnly
	self.midToExportOption[68099659] = LuaAndCSharp
	self.midToExportOption[68103333] = CSharpOnly
	self.midToExportOption[68103518] = LuaAndCSharp
	self.midToExportOption[68107887] = CSharpOnly
	self.midToExportOption[68116531] = LuaAndCSharp
	self.midToExportOption[68118454] = CSharpOnly
	self.midToExportOption[68118887] = LuaAndCSharp
	self.midToExportOption[68119150] = CSharpOnly
	self.midToExportOption[68119175] = LuaOnly
	self.midToExportOption[68121104] = CSharpOnly
	self.midToExportOption[68123340] = CSharpOnly
	self.midToExportOption[68125619] = LuaOnly
	self.midToExportOption[68129425] = CSharpOnly
	self.midToExportOption[68129563] = LuaOnly
	self.midToExportOption[68132210] = LuaOnly
	self.midToExportOption[68132992] = CSharpOnly
	self.midToExportOption[68133746] = CSharpOnly
	self.midToExportOption[68136914] = CSharpOnly
	self.midToExportOption[68137883] = LuaAndCSharp
	self.midToExportOption[68147858] = LuaOnly
	self.midToExportOption[68150240] = CSharpOnly
	self.midToExportOption[68151668] = CSharpOnly
	self.midToExportOption[68151671] = LuaOnly
	self.midToExportOption[68152068] = LuaOnly
	self.midToExportOption[68155952] = CSharpOnly
	self.midToExportOption[68156906] = LuaOnly
	self.midToExportOption[68159284] = CSharpOnly
	self.midToExportOption[68162452] = CSharpOnly
	self.midToExportOption[68162500] = CSharpOnly
	self.midToExportOption[68164107] = CSharpOnly
	self.midToExportOption[68168359] = LuaOnly
	self.midToExportOption[68169800] = CSharpOnly
	self.midToExportOption[68170161] = CSharpOnly
	self.midToExportOption[68172052] = CSharpOnly
	self.midToExportOption[68172618] = CSharpOnly
	self.midToExportOption[68173578] = CSharpOnly
	self.midToExportOption[68174329] = CSharpOnly
	self.midToExportOption[68175489] = LuaOnly
	self.midToExportOption[68175668] = CSharpOnly
	self.midToExportOption[68179062] = CSharpOnly
	self.midToExportOption[68181832] = CSharpOnly
	self.midToExportOption[68185162] = CSharpOnly
	self.midToExportOption[68187041] = LuaOnly
	self.midToExportOption[68187076] = CSharpOnly
	self.midToExportOption[68187302] = CSharpOnly
	self.midToExportOption[68189383] = CSharpOnly
	self.midToExportOption[68191888] = LuaAndCSharp
	self.midToExportOption[68192069] = CSharpOnly
	self.midToExportOption[68198238] = CSharpOnly
	self.midToExportOption[68205796] = CSharpOnly
	self.midToExportOption[68206572] = CSharpOnly
	self.midToExportOption[68208678] = LuaOnly
	self.midToExportOption[68209787] = LuaAndCSharp
	self.midToExportOption[68211444] = LuaOnly
	self.midToExportOption[68211691] = LuaAndCSharp
	self.midToExportOption[68213127] = CSharpOnly
	self.midToExportOption[68214096] = CSharpOnly
	self.midToExportOption[68214219] = CSharpOnly
	self.midToExportOption[68221189] = CSharpOnly
	self.midToExportOption[68222711] = CSharpOnly
	self.midToExportOption[68224420] = CSharpOnly
	self.midToExportOption[68225411] = CSharpOnly
	self.midToExportOption[68225722] = CSharpOnly
	self.midToExportOption[68227986] = CSharpOnly
	self.midToExportOption[68228126] = LuaOnly
	self.midToExportOption[68229586] = LuaAndCSharp
	self.midToExportOption[68229606] = CSharpOnly
	self.midToExportOption[68231077] = CSharpOnly
	self.midToExportOption[68233193] = CSharpOnly
	self.midToExportOption[68234788] = LuaAndCSharp
	self.midToExportOption[68235073] = CSharpOnly
	self.midToExportOption[68235182] = LuaOnly
	self.midToExportOption[68235314] = LuaAndCSharp
	self.midToExportOption[68238665] = LuaAndCSharp
	self.midToExportOption[68242779] = CSharpOnly
	self.midToExportOption[68244217] = LuaAndCSharp
	self.midToExportOption[68245862] = CSharpOnly
	self.midToExportOption[68249612] = CSharpOnly
	self.midToExportOption[68250849] = CSharpOnly
	self.midToExportOption[68253739] = LuaOnly
	self.midToExportOption[68254325] = CSharpOnly
	self.midToExportOption[68257427] = LuaOnly
	self.midToExportOption[68262988] = CSharpOnly
	self.midToExportOption[68266457] = CSharpOnly
	self.midToExportOption[68268284] = CSharpOnly
	self.midToExportOption[68268723] = LuaOnly
	self.midToExportOption[68270214] = CSharpOnly
	self.midToExportOption[68272186] = CSharpOnly
	self.midToExportOption[68281101] = CSharpOnly
	self.midToExportOption[68282591] = CSharpOnly
	self.midToExportOption[68285888] = CSharpOnly
	self.midToExportOption[68287090] = CSharpOnly
	self.midToExportOption[68288059] = CSharpOnly
	self.midToExportOption[68294891] = CSharpOnly
	self.midToExportOption[68295962] = LuaAndCSharp
	self.midToExportOption[68297099] = CSharpOnly
	self.midToExportOption[68297382] = LuaOnly
	self.midToExportOption[68298358] = CSharpOnly
	self.midToExportOption[68299309] = CSharpOnly
	self.midToExportOption[68300133] = CSharpOnly
	self.midToExportOption[68301573] = CSharpOnly
	self.midToExportOption[68302014] = LuaAndCSharp
	self.midToExportOption[68304049] = CSharpOnly
	self.midToExportOption[68304375] = CSharpOnly
	self.midToExportOption[68306142] = CSharpOnly
	self.midToExportOption[68309974] = CSharpOnly
	self.midToExportOption[68311165] = CSharpOnly
	self.midToExportOption[68311397] = CSharpOnly
	self.midToExportOption[68312786] = CSharpOnly
	self.midToExportOption[68313915] = CSharpOnly
	self.midToExportOption[68314091] = LuaOnly
	self.midToExportOption[68314340] = LuaOnly
	self.midToExportOption[68315575] = CSharpOnly
	self.midToExportOption[68322972] = CSharpOnly
	self.midToExportOption[68323302] = CSharpOnly
	self.midToExportOption[68323839] = CSharpOnly
	self.midToExportOption[68328421] = LuaOnly
	self.midToExportOption[68333410] = LuaOnly
	self.midToExportOption[68334114] = LuaAndCSharp
	self.midToExportOption[68337601] = LuaOnly
	self.midToExportOption[68338125] = LuaAndCSharp
	self.midToExportOption[68340587] = LuaAndCSharp
	self.midToExportOption[68343773] = LuaOnly
	self.midToExportOption[68344409] = LuaAndCSharp
	self.midToExportOption[68348957] = LuaAndCSharp
	self.midToExportOption[68351278] = CSharpOnly
	self.midToExportOption[68351828] = CSharpOnly
	self.midToExportOption[68358019] = CSharpOnly
	self.midToExportOption[68358254] = LuaOnly
	self.midToExportOption[68360886] = LuaAndCSharp
	self.midToExportOption[68361290] = CSharpOnly
	self.midToExportOption[68362490] = LuaAndCSharp
	self.midToExportOption[68363646] = CSharpOnly
	self.midToExportOption[68364804] = CSharpOnly
	self.midToExportOption[68367029] = CSharpOnly
	self.midToExportOption[68371219] = LuaOnly
	self.midToExportOption[68373762] = LuaOnly
	self.midToExportOption[68374038] = CSharpOnly
	self.midToExportOption[68375500] = CSharpOnly
	self.midToExportOption[68379589] = CSharpOnly
	self.midToExportOption[68383417] = CSharpOnly
	self.midToExportOption[68385030] = CSharpOnly
	self.midToExportOption[68386224] = LuaAndCSharp
	self.midToExportOption[68386314] = CSharpOnly
	self.midToExportOption[68387048] = CSharpOnly
	self.midToExportOption[68388244] = CSharpOnly
	self.midToExportOption[68391681] = CSharpOnly
	self.midToExportOption[68394652] = CSharpOnly
	self.midToExportOption[68396726] = LuaAndCSharp
	self.midToExportOption[68396882] = CSharpOnly
	self.midToExportOption[68396900] = CSharpOnly
	self.midToExportOption[68399010] = LuaAndCSharp
	self.midToExportOption[68399324] = CSharpOnly
	self.midToExportOption[68400584] = LuaOnly
	self.midToExportOption[68402737] = CSharpOnly
	self.midToExportOption[68403895] = LuaAndCSharp
	self.midToExportOption[68405438] = CSharpOnly
	self.midToExportOption[68406984] = CSharpOnly
	self.midToExportOption[68407238] = LuaAndCSharp
	self.midToExportOption[68409127] = LuaAndCSharp
	self.midToExportOption[68410301] = LuaAndCSharp
	self.midToExportOption[68411052] = CSharpOnly
	self.midToExportOption[68411816] = CSharpOnly
	self.midToExportOption[68411981] = CSharpOnly
	self.midToExportOption[68412028] = LuaAndCSharp
	self.midToExportOption[68412586] = CSharpOnly
	self.midToExportOption[68419070] = CSharpOnly
	self.midToExportOption[68419744] = CSharpOnly
	self.midToExportOption[68420021] = LuaAndCSharp
	self.midToExportOption[68424308] = LuaOnly
	self.midToExportOption[68424640] = CSharpOnly
	self.midToExportOption[68425581] = CSharpOnly
	self.midToExportOption[68425671] = CSharpOnly
	self.midToExportOption[68426260] = CSharpOnly
	self.midToExportOption[68427090] = LuaAndCSharp
	self.midToExportOption[68428388] = LuaOnly
	self.midToExportOption[68429105] = CSharpOnly
	self.midToExportOption[68433231] = CSharpOnly
	self.midToExportOption[68433498] = CSharpOnly
	self.midToExportOption[68434846] = LuaOnly
	self.midToExportOption[68435433] = CSharpOnly
	self.midToExportOption[68440418] = CSharpOnly
	self.midToExportOption[68441784] = CSharpOnly
	self.midToExportOption[68442298] = LuaOnly
	self.midToExportOption[68442503] = CSharpOnly
	self.midToExportOption[68443505] = CSharpOnly
	self.midToExportOption[68443971] = LuaOnly
	self.midToExportOption[68444149] = LuaOnly
	self.midToExportOption[68448478] = CSharpOnly
	self.midToExportOption[68452337] = CSharpOnly
	self.midToExportOption[68455147] = CSharpOnly
	self.midToExportOption[68455575] = LuaOnly
	self.midToExportOption[68456809] = CSharpOnly
	self.midToExportOption[68457137] = CSharpOnly
	self.midToExportOption[68459161] = LuaOnly
	self.midToExportOption[68463602] = CSharpOnly
	self.midToExportOption[68465127] = CSharpOnly
	self.midToExportOption[68468724] = LuaOnly
	self.midToExportOption[68468840] = CSharpOnly
	self.midToExportOption[68470909] = LuaAndCSharp
	self.midToExportOption[68471407] = CSharpOnly
	self.midToExportOption[68471612] = CSharpOnly
	self.midToExportOption[68471782] = CSharpOnly
	self.midToExportOption[68473454] = CSharpOnly
	self.midToExportOption[68474604] = CSharpOnly
	self.midToExportOption[68474606] = CSharpOnly
	self.midToExportOption[68476812] = LuaAndCSharp
	self.midToExportOption[68481136] = CSharpOnly
	self.midToExportOption[68483903] = CSharpOnly
	self.midToExportOption[68484003] = LuaAndCSharp
	self.midToExportOption[68485822] = CSharpOnly
	self.midToExportOption[68486027] = LuaOnly
	self.midToExportOption[68487781] = CSharpOnly
	self.midToExportOption[68495892] = LuaAndCSharp
	self.midToExportOption[68499122] = CSharpOnly
	self.midToExportOption[68499401] = CSharpOnly
	self.midToExportOption[68499633] = CSharpOnly
	self.midToExportOption[68501444] = LuaAndCSharp
	self.midToExportOption[68508050] = CSharpOnly
	self.midToExportOption[68512183] = LuaAndCSharp
	self.midToExportOption[68513124] = CSharpOnly
	self.midToExportOption[68516133] = CSharpOnly
	self.midToExportOption[68517259] = LuaOnly
	self.midToExportOption[68520603] = LuaAndCSharp
	self.midToExportOption[68521147] = LuaAndCSharp
	self.midToExportOption[68521939] = CSharpOnly
	self.midToExportOption[68522658] = LuaOnly
	self.midToExportOption[68523177] = CSharpOnly
	self.midToExportOption[68523611] = CSharpOnly
	self.midToExportOption[68528392] = LuaAndCSharp
	self.midToExportOption[68530387] = LuaAndCSharp
	self.midToExportOption[68531519] = CSharpOnly
	self.midToExportOption[68531904] = CSharpOnly
	self.midToExportOption[68532164] = CSharpOnly
	self.midToExportOption[68532791] = CSharpOnly
	self.midToExportOption[68534079] = CSharpOnly
	self.midToExportOption[68538816] = CSharpOnly
	self.midToExportOption[68541954] = CSharpOnly
	self.midToExportOption[68541988] = LuaAndCSharp
	self.midToExportOption[68542235] = CSharpOnly
	self.midToExportOption[68545564] = CSharpOnly
	self.midToExportOption[68547959] = CSharpOnly
	self.midToExportOption[68549473] = LuaOnly
	self.midToExportOption[68551009] = CSharpOnly
	self.midToExportOption[68551063] = CSharpOnly
	self.midToExportOption[68552624] = LuaOnly
	self.midToExportOption[68553525] = CSharpOnly
	self.midToExportOption[68554392] = LuaOnly
	self.midToExportOption[68558090] = CSharpOnly
	self.midToExportOption[68562258] = LuaAndCSharp
	self.midToExportOption[68562967] = LuaOnly
	self.midToExportOption[68563222] = LuaOnly
	self.midToExportOption[68566635] = LuaOnly
	self.midToExportOption[68569246] = LuaAndCSharp
	self.midToExportOption[68569863] = CSharpOnly
	self.midToExportOption[68576087] = LuaAndCSharp
	self.midToExportOption[68579856] = CSharpOnly
	self.midToExportOption[68586710] = CSharpOnly
	self.midToExportOption[68588329] = CSharpOnly
	self.midToExportOption[68588689] = CSharpOnly
	self.midToExportOption[68589226] = CSharpOnly
	self.midToExportOption[68590018] = CSharpOnly
	self.midToExportOption[68594027] = CSharpOnly
	self.midToExportOption[68594884] = CSharpOnly
	self.midToExportOption[68597665] = CSharpOnly
	self.midToExportOption[68597805] = LuaOnly
	self.midToExportOption[68598465] = LuaAndCSharp
	self.midToExportOption[68600791] = LuaOnly
	self.midToExportOption[68601034] = LuaOnly
	self.midToExportOption[68602471] = CSharpOnly
	self.midToExportOption[68605870] = CSharpOnly
	self.midToExportOption[68608379] = CSharpOnly
	self.midToExportOption[68610826] = CSharpOnly
	self.midToExportOption[68616305] = CSharpOnly
	self.midToExportOption[68617753] = LuaAndCSharp
	self.midToExportOption[68619076] = LuaOnly
	self.midToExportOption[68621958] = CSharpOnly
	self.midToExportOption[68627353] = CSharpOnly
	self.midToExportOption[68630350] = CSharpOnly
	self.midToExportOption[68633332] = LuaOnly
	self.midToExportOption[68634743] = LuaAndCSharp
	self.midToExportOption[68635525] = LuaOnly
	self.midToExportOption[68635825] = LuaOnly
	self.midToExportOption[68636330] = CSharpOnly
	self.midToExportOption[68636500] = CSharpOnly
	self.midToExportOption[68636622] = LuaOnly
	self.midToExportOption[68637375] = CSharpOnly
	self.midToExportOption[68637427] = LuaAndCSharp
	self.midToExportOption[68639918] = CSharpOnly
	self.midToExportOption[68642656] = CSharpOnly
	self.midToExportOption[68647080] = LuaOnly
	self.midToExportOption[68648497] = CSharpOnly
	self.midToExportOption[68648870] = LuaOnly
	self.midToExportOption[68649557] = LuaOnly
	self.midToExportOption[68649704] = LuaAndCSharp
	self.midToExportOption[68655142] = CSharpOnly
	self.midToExportOption[68655602] = LuaAndCSharp
	self.midToExportOption[68657818] = CSharpOnly
	self.midToExportOption[68664767] = LuaAndCSharp
	self.midToExportOption[68666356] = LuaOnly
	self.midToExportOption[68668080] = CSharpOnly
	self.midToExportOption[68669060] = CSharpOnly
	self.midToExportOption[68671136] = CSharpOnly
	self.midToExportOption[68672133] = CSharpOnly
	self.midToExportOption[68672300] = CSharpOnly
	self.midToExportOption[68675662] = CSharpOnly
	self.midToExportOption[68676592] = CSharpOnly
	self.midToExportOption[68679462] = CSharpOnly
	self.midToExportOption[68683177] = CSharpOnly
	self.midToExportOption[68685284] = LuaAndCSharp
	self.midToExportOption[68686565] = LuaAndCSharp
	self.midToExportOption[68688049] = CSharpOnly
	self.midToExportOption[68689379] = LuaOnly
	self.midToExportOption[68691394] = LuaAndCSharp
	self.midToExportOption[68691648] = CSharpOnly
	self.midToExportOption[68693900] = LuaOnly
	self.midToExportOption[68695538] = CSharpOnly
	self.midToExportOption[68699731] = LuaOnly
	self.midToExportOption[68699953] = CSharpOnly
	self.midToExportOption[68703022] = LuaOnly
	self.midToExportOption[68704228] = CSharpOnly
	self.midToExportOption[68704306] = CSharpOnly
	self.midToExportOption[68704980] = CSharpOnly
	self.midToExportOption[68707179] = LuaAndCSharp
	self.midToExportOption[68708402] = LuaOnly
	self.midToExportOption[68710799] = CSharpOnly
	self.midToExportOption[68710886] = LuaOnly
	self.midToExportOption[68711938] = CSharpOnly
	self.midToExportOption[68713591] = CSharpOnly
	self.midToExportOption[68713746] = CSharpOnly
	self.midToExportOption[68717280] = CSharpOnly
	self.midToExportOption[68725832] = LuaAndCSharp
	self.midToExportOption[68726965] = CSharpOnly
	self.midToExportOption[68732050] = CSharpOnly
	self.midToExportOption[68732944] = CSharpOnly
	self.midToExportOption[68735163] = LuaAndCSharp
	self.midToExportOption[68736044] = CSharpOnly
	self.midToExportOption[68736881] = CSharpOnly
	self.midToExportOption[68737370] = CSharpOnly
	self.midToExportOption[68739207] = CSharpOnly
	self.midToExportOption[68740802] = CSharpOnly
	self.midToExportOption[68741181] = CSharpOnly
	self.midToExportOption[68742819] = LuaOnly
	self.midToExportOption[68750181] = CSharpOnly
	self.midToExportOption[68750981] = CSharpOnly
	self.midToExportOption[68751555] = CSharpOnly
	self.midToExportOption[68751680] = CSharpOnly
	self.midToExportOption[68753341] = CSharpOnly
	self.midToExportOption[68753590] = LuaAndCSharp
	self.midToExportOption[68754050] = CSharpOnly
	self.midToExportOption[68756560] = CSharpOnly
	self.midToExportOption[68757592] = LuaAndCSharp
	self.midToExportOption[68760171] = LuaOnly
	self.midToExportOption[68763063] = CSharpOnly
	self.midToExportOption[68763420] = LuaOnly
	self.midToExportOption[68764131] = CSharpOnly
	self.midToExportOption[68768659] = LuaOnly
	self.midToExportOption[68770540] = CSharpOnly
	self.midToExportOption[68770951] = CSharpOnly
	self.midToExportOption[68772022] = LuaAndCSharp
	self.midToExportOption[68773342] = CSharpOnly
	self.midToExportOption[68777129] = CSharpOnly
	self.midToExportOption[68779253] = CSharpOnly
	self.midToExportOption[68781047] = CSharpOnly
	self.midToExportOption[68783330] = CSharpOnly
	self.midToExportOption[68784219] = CSharpOnly
	self.midToExportOption[68784827] = CSharpOnly
	self.midToExportOption[68785775] = LuaOnly
	self.midToExportOption[68789872] = CSharpOnly
	self.midToExportOption[68790211] = CSharpOnly
	self.midToExportOption[68791225] = CSharpOnly
	self.midToExportOption[68792179] = CSharpOnly
	self.midToExportOption[68792204] = CSharpOnly
	self.midToExportOption[68792735] = LuaAndCSharp
	self.midToExportOption[68793643] = CSharpOnly
	self.midToExportOption[68794358] = CSharpOnly
	self.midToExportOption[68797062] = CSharpOnly
	self.midToExportOption[68797557] = LuaAndCSharp
	self.midToExportOption[68798584] = CSharpOnly
	self.midToExportOption[68800226] = LuaAndCSharp
	self.midToExportOption[68800259] = CSharpOnly
	self.midToExportOption[68800347] = CSharpOnly
	self.midToExportOption[68801428] = LuaAndCSharp
	self.midToExportOption[68803474] = CSharpOnly
	self.midToExportOption[68805550] = CSharpOnly
	self.midToExportOption[68806287] = CSharpOnly
	self.midToExportOption[68810296] = LuaOnly
	self.midToExportOption[68810561] = LuaOnly
	self.midToExportOption[68811086] = LuaAndCSharp
	self.midToExportOption[68812052] = CSharpOnly
	self.midToExportOption[68814135] = LuaAndCSharp
	self.midToExportOption[68815417] = CSharpOnly
	self.midToExportOption[68817037] = LuaOnly
	self.midToExportOption[68818194] = CSharpOnly
	self.midToExportOption[68822468] = LuaOnly
	self.midToExportOption[68823065] = CSharpOnly
	self.midToExportOption[68824345] = LuaAndCSharp
	self.midToExportOption[68827325] = CSharpOnly
	self.midToExportOption[68828133] = CSharpOnly
	self.midToExportOption[68828543] = LuaOnly
	self.midToExportOption[68831029] = CSharpOnly
	self.midToExportOption[68831898] = LuaAndCSharp
	self.midToExportOption[68845823] = CSharpOnly
	self.midToExportOption[68847646] = CSharpOnly
	self.midToExportOption[68847974] = CSharpOnly
	self.midToExportOption[68848112] = CSharpOnly
	self.midToExportOption[68850332] = LuaOnly
	self.midToExportOption[68852690] = LuaOnly
	self.midToExportOption[68854930] = LuaOnly
	self.midToExportOption[68854998] = CSharpOnly
	self.midToExportOption[68856167] = LuaOnly
	self.midToExportOption[68857464] = LuaOnly
	self.midToExportOption[68857660] = CSharpOnly
	self.midToExportOption[68857767] = CSharpOnly
	self.midToExportOption[68858287] = LuaAndCSharp
	self.midToExportOption[68859568] = CSharpOnly
	self.midToExportOption[68859621] = CSharpOnly
	self.midToExportOption[68860308] = CSharpOnly
	self.midToExportOption[68864263] = CSharpOnly
	self.midToExportOption[68866231] = CSharpOnly
	self.midToExportOption[68866576] = LuaOnly
	self.midToExportOption[68866670] = CSharpOnly
	self.midToExportOption[68871378] = CSharpOnly
	self.midToExportOption[68871637] = LuaAndCSharp
	self.midToExportOption[68872471] = CSharpOnly
	self.midToExportOption[68877733] = CSharpOnly
	self.midToExportOption[68878486] = CSharpOnly
	self.midToExportOption[68880142] = CSharpOnly
	self.midToExportOption[68881143] = CSharpOnly
	self.midToExportOption[68882990] = LuaOnly
	self.midToExportOption[68884818] = CSharpOnly
	self.midToExportOption[68884830] = LuaAndCSharp
	self.midToExportOption[68887066] = CSharpOnly
	self.midToExportOption[68890464] = LuaOnly
	self.midToExportOption[68890469] = CSharpOnly
	self.midToExportOption[68892191] = CSharpOnly
	self.midToExportOption[68892572] = CSharpOnly
	self.midToExportOption[68897900] = LuaAndCSharp
	self.midToExportOption[68898703] = CSharpOnly
	self.midToExportOption[68899672] = CSharpOnly
	self.midToExportOption[68901239] = LuaAndCSharp
	self.midToExportOption[68901656] = LuaOnly
	self.midToExportOption[68906214] = CSharpOnly
	self.midToExportOption[68908335] = CSharpOnly
	self.midToExportOption[68913837] = LuaOnly
	self.midToExportOption[68914199] = CSharpOnly
	self.midToExportOption[68916669] = LuaAndCSharp
	self.midToExportOption[68923943] = CSharpOnly
	self.midToExportOption[68924615] = CSharpOnly
	self.midToExportOption[68924717] = CSharpOnly
	self.midToExportOption[68926683] = CSharpOnly
	self.midToExportOption[68927002] = LuaAndCSharp
	self.midToExportOption[68928019] = CSharpOnly
	self.midToExportOption[68929126] = CSharpOnly
	self.midToExportOption[68929580] = LuaAndCSharp
	self.midToExportOption[68931637] = CSharpOnly
	self.midToExportOption[68933313] = CSharpOnly
	self.midToExportOption[68935355] = CSharpOnly
	self.midToExportOption[68938302] = CSharpOnly
	self.midToExportOption[68939905] = LuaOnly
	self.midToExportOption[68940128] = CSharpOnly
	self.midToExportOption[68942757] = CSharpOnly
	self.midToExportOption[68943960] = CSharpOnly
	self.midToExportOption[68946382] = CSharpOnly
	self.midToExportOption[68949162] = LuaOnly
	self.midToExportOption[68951368] = CSharpOnly
	self.midToExportOption[68951600] = CSharpOnly
	self.midToExportOption[68952282] = CSharpOnly
	self.midToExportOption[68960636] = CSharpOnly
	self.midToExportOption[68960813] = CSharpOnly
	self.midToExportOption[68960974] = CSharpOnly
	self.midToExportOption[68962729] = LuaAndCSharp
	self.midToExportOption[68963796] = CSharpOnly
	self.midToExportOption[68964608] = CSharpOnly
	self.midToExportOption[68967025] = CSharpOnly
	self.midToExportOption[68969798] = CSharpOnly
	self.midToExportOption[68969986] = LuaOnly
	self.midToExportOption[68970088] = CSharpOnly
	self.midToExportOption[68972287] = CSharpOnly
	self.midToExportOption[68973352] = LuaAndCSharp
	self.midToExportOption[68974077] = LuaAndCSharp
	self.midToExportOption[68975626] = CSharpOnly
	self.midToExportOption[68976401] = LuaOnly
	self.midToExportOption[68979345] = CSharpOnly
	self.midToExportOption[68982002] = LuaAndCSharp
	self.midToExportOption[68984310] = LuaOnly
	self.midToExportOption[68987100] = LuaOnly
	self.midToExportOption[68988337] = LuaOnly
	self.midToExportOption[68988971] = LuaAndCSharp
	self.midToExportOption[68989660] = CSharpOnly
	self.midToExportOption[68990417] = CSharpOnly
	self.midToExportOption[68996280] = LuaOnly
	self.midToExportOption[68997755] = LuaAndCSharp
	self.midToExportOption[70037312] = CSharpOnly
	self.midToExportOption[70571447] = CSharpOnly
	self.midToExportOption[70761691] = CSharpOnly
	self.midToExportOption[70840139] = CSharpOnly
	self.midToExportOption[115181177] = LuaOnly
	self.midToExportOption[115954489] = LuaOnly
	self.midToExportOption[116020736] = LuaOnly
	self.midToExportOption[116020751] = LuaOnly
	self.midToExportOption[116038644] = LuaOnly
	self.midToExportOption[116039195] = LuaOnly
	self.midToExportOption[116131924] = LuaOnly
	self.midToExportOption[116141795] = LuaOnly
	self.midToExportOption[116178909] = LuaOnly
	self.midToExportOption[116219373] = LuaOnly
	self.midToExportOption[116267748] = LuaOnly
	self.midToExportOption[116271245] = LuaOnly
	self.midToExportOption[116325366] = LuaOnly
	self.midToExportOption[116330964] = LuaOnly
	self.midToExportOption[116379388] = LuaOnly
	self.midToExportOption[116465447] = LuaOnly
	self.midToExportOption[116488792] = LuaOnly
	self.midToExportOption[116511754] = LuaOnly
	self.midToExportOption[116531392] = LuaOnly
	self.midToExportOption[116574305] = LuaOnly
	self.midToExportOption[116592712] = LuaOnly
	self.midToExportOption[116595985] = LuaOnly
	self.midToExportOption[116622906] = LuaOnly
	self.midToExportOption[116645377] = LuaOnly
	self.midToExportOption[116653059] = LuaOnly
	self.midToExportOption[116688453] = LuaOnly
	self.midToExportOption[116696426] = LuaOnly
	self.midToExportOption[116699472] = LuaOnly
	self.midToExportOption[116713715] = LuaOnly
	self.midToExportOption[116751448] = LuaOnly
	self.midToExportOption[116832472] = LuaOnly
	self.midToExportOption[116880436] = LuaOnly
	self.midToExportOption[116906903] = LuaOnly
	self.midToExportOption[116973121] = LuaOnly
	self.midToExportOption[116981800] = LuaOnly
	self.midToExportOption[116993058] = LuaOnly
	self.midToExportOption[116998071] = LuaOnly
	self.midToExportOption[124664788] = LuaOnly
	self.midToExportOption[127255686] = LuaOnly
	self.midToExportOption[128098486] = LuaOnly
	self.midToExportOption[128109600] = LuaOnly
	self.midToExportOption[128144903] = CSharpOnly
	self.midToExportOption[128245254] = CSharpOnly
	self.midToExportOption[128248079] = LuaAndCSharp
	self.midToExportOption[128294697] = LuaAndCSharp
	self.midToExportOption[128303615] = LuaAndCSharp
	self.midToExportOption[128312985] = LuaAndCSharp
	self.midToExportOption[128352683] = CSharpOnly
	self.midToExportOption[128503247] = LuaOnly
	self.midToExportOption[128520616] = LuaAndCSharp
	self.midToExportOption[128533995] = CSharpOnly
	self.midToExportOption[128563852] = LuaOnly
	self.midToExportOption[128565833] = LuaAndCSharp
	self.midToExportOption[128578415] = CSharpOnly
	self.midToExportOption[128584754] = LuaOnly
	self.midToExportOption[128663439] = LuaAndCSharp
	self.midToExportOption[128678442] = LuaOnly
	self.midToExportOption[128691656] = LuaOnly
	self.midToExportOption[128745697] = CSharpOnly
	self.midToExportOption[128768338] = LuaOnly
	self.midToExportOption[128816649] = CSharpOnly
	self.midToExportOption[128873895] = LuaAndCSharp
	self.midToExportOption[128901894] = LuaOnly
	self.midToExportOption[154006932] = LuaOnly
	self.midToExportOption[154341802] = CSharpOnly
	self.midToExportOption[154349060] = LuaOnly
	self.midToExportOption[154595756] = LuaOnly
	self.midToExportOption[154822954] = CSharpOnly
	self.midToExportOption[154989241] = LuaOnly
	self.midToExportOption[203023320] = LuaOnly
	self.midToExportOption[203051678] = LuaOnly
	self.midToExportOption[203140608] = LuaOnly
	self.midToExportOption[203302854] = LuaOnly
	self.midToExportOption[203319989] = LuaOnly
	self.midToExportOption[203393681] = LuaOnly
	self.midToExportOption[203438648] = LuaOnly
	self.midToExportOption[203468128] = LuaOnly
	self.midToExportOption[203587053] = LuaOnly
	self.midToExportOption[203656753] = LuaOnly
	self.midToExportOption[203660430] = LuaOnly
	self.midToExportOption[203736421] = LuaOnly
	self.midToExportOption[203788962] = LuaOnly
	self.midToExportOption[203818940] = LuaOnly
	self.midToExportOption[203832404] = LuaOnly
	self.midToExportOption[203960587] = LuaOnly
	self.midToExportOption[203996390] = LuaOnly
	self.midToExportOption[203998226] = LuaOnly
	self.midToExportOption[204039196] = LuaOnly
	self.midToExportOption[204171545] = LuaOnly
	self.midToExportOption[204263045] = LuaOnly
	self.midToExportOption[204459497] = LuaOnly
	self.midToExportOption[204730628] = LuaOnly
	self.midToExportOption[204826282] = LuaOnly
	self.midToExportOption[204967791] = LuaOnly
	self.midToReader[35056687] = function(reader)
		local linkUnlocked = reader:ReadBoolean()
		local hasPrivateLink = reader:ReadBoolean()

		return linkUnlocked, hasPrivateLink
	end
	self.midToReader[35058902] = function(reader)
		return
	end
	self.midToReader[35173411] = function(reader)
		local expireTime = reader:ReadUInt32()
		local reasonStr = reader:ReadString()
		local reasonId = reader:ReadUInt32()
		local pid = reader:ReadUInt64()

		return expireTime, reasonStr, reasonId, pid
	end
	self.midToReader[35212978] = function(reader)
		local pid = reader:ReadUInt64()

		return pid
	end
	self.midToReader[35689543] = function(reader)
		local queueCount = reader:ReadInt64()
		local waitTime = reader:ReadInt32()
		local ticketNum = reader:ReadInt64()

		return queueCount, waitTime, ticketNum
	end
	self.midToReader[35842068] = function(reader)
		local data = Base.ReadComplex(reader, Auto.Reader[0])

		return data
	end
	self.midToReader[45025692] = function(reader)
		local data = Base.ReadComplex(reader, Auto.Reader[0])

		return data
	end
	self.midToReader[45328604] = function(reader)
		local content = reader:ReadString()

		return content
	end
	self.midToReader[45513348] = function(reader)
		local messageId = reader:ReadUInt64()

		return messageId
	end
	self.midToReader[45781151] = function(reader)
		local message = Base.ReadComplex(reader, Auto.Reader[1])

		return message
	end
	self.midToReader[53677964] = function(reader)
		return
	end
	self.midToReader[53913220] = function(reader)
		local data = Base.ReadComplex(reader, Auto.Reader[0])

		return data
	end
	self.midToReader[64000570] = function(reader)
		local newTotalCredit = reader:ReadUInt32()
		local newLevel = reader:ReadUInt32()
		local itemType = reader:ReadByte()
		local itemId = reader:ReadUInt32()

		return newTotalCredit, newLevel, itemType, itemId
	end
	self.midToReader[64002073] = function(reader)
		local addItemList = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[2])
		end)
		local updateItemList = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[2])
		end)
		local deleteItemList = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[2])
		end)

		return addItemList, updateItemList, deleteItemList
	end
	self.midToReader[64009562] = function(reader)
		local spiritId = reader:ReadUInt32()
		local policeJobInfo = Base.ReadComplex(reader, Auto.Reader[3])

		return spiritId, policeJobInfo
	end
	self.midToReader[64024664] = function(reader)
		local info = Base.ReadComplex(reader, Auto.Reader[4])

		return info
	end
	self.midToReader[64024863] = function(reader)
		local npcCardId = reader:ReadUInt32()
		local days = reader:ReadUInt32()
		local lastTime = reader:ReadUInt32()

		return npcCardId, days, lastTime
	end
	self.midToReader[64028687] = function(reader)
		local teamId = reader:ReadUInt64()
		local setting = Base.ReadComplex(reader, Auto.Reader[5])

		return teamId, setting
	end
	self.midToReader[64030205] = function(reader)
		local intention = reader:ReadByte()
		local bindGoldAdd = reader:ReadUInt32()
		local unbindGoldAdd = reader:ReadUInt32()
		local reason = reader:ReadInt32()
		local silence = reader:ReadBoolean()

		return intention, bindGoldAdd, unbindGoldAdd, reason, silence
	end
	self.midToReader[64032762] = function(reader)
		return
	end
	self.midToReader[64043553] = function(reader)
		local teamId = reader:ReadUInt64()
		local playerInfo = Base.ReadComplex(reader, Auto.Reader[6])

		return teamId, playerInfo
	end
	self.midToReader[64050603] = function(reader)
		local messageId = reader:ReadUInt32()
		local args = Base.ReadList(reader, function(r)
			return r:ReadString()
		end)

		return messageId, args
	end
	self.midToReader[64051530] = function(reader)
		local info = Base.ReadStruct(reader, Auto.Reader[7])

		return info
	end
	self.midToReader[64054119] = function(reader)
		local eventId = reader:ReadUInt32()

		return eventId
	end
	self.midToReader[64055698] = function(reader)
		local raidId = reader:ReadUInt32()
		local position = Base.ReadStruct(reader, Auto.Reader.UXVector3)

		return raidId, position
	end
	self.midToReader[64059110] = function(reader)
		local deviceLevel = reader:ReadByte()

		return deviceLevel
	end
	self.midToReader[64061100] = function(reader)
		local teamId = reader:ReadUInt64()
		local playerInfo = Base.ReadComplex(reader, Auto.Reader[6])

		return teamId, playerInfo
	end
	self.midToReader[64062943] = function(reader)
		local cancelInfoList = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[8])
		end)

		return cancelInfoList
	end
	self.midToReader[64066495] = function(reader)
		local ids = Base.ReadList(reader, function(r)
			return r:ReadUInt64()
		end)

		return ids
	end
	self.midToReader[64067604] = function(reader)
		local teamId = reader:ReadUInt64()
		local inviter = Base.ReadComplex(reader, Auto.Reader[6])
		local invitee = Base.ReadComplex(reader, Auto.Reader[6])

		return teamId, inviter, invitee
	end
	self.midToReader[64074256] = function(reader)
		local npcCultivationId = reader:ReadUInt32()

		return npcCultivationId
	end
	self.midToReader[64081527] = function(reader)
		local spiritBartenderInfo = Base.ReadComplex(reader, Auto.Reader[9])

		return spiritBartenderInfo
	end
	self.midToReader[64081924] = function(reader)
		local dropId = reader:ReadUInt32()
		local info = Base.ReadComplex(reader, Auto.Reader[10])

		return dropId, info
	end
	self.midToReader[64082910] = function(reader)
		local teamId = reader:ReadUInt64()
		local playerInfo = Base.ReadComplex(reader, Auto.Reader[6])

		return teamId, playerInfo
	end
	self.midToReader[64084105] = function(reader)
		local count = reader:ReadInt32()

		return count
	end
	self.midToReader[64085008] = function(reader)
		local totalTodayCount = reader:ReadUInt32()
		local lastTriggerTime = reader:ReadUInt32()
		local npcId = reader:ReadUInt32()
		local npcTodayCount = reader:ReadUInt32()

		return totalTodayCount, lastTriggerTime, npcId, npcTodayCount
	end
	self.midToReader[64086058] = function(reader)
		local npcCardId = reader:ReadUInt32()
		local voice = reader:ReadUInt32()

		return npcCardId, voice
	end
	self.midToReader[64090638] = function(reader)
		local spiritId = reader:ReadUInt32()
		local hackerJobInfo = Base.ReadComplex(reader, Auto.Reader[11])

		return spiritId, hackerJobInfo
	end
	self.midToReader[64091591] = function(reader)
		local enemyKillRecord = Base.ReadList(reader, function(r)
			return r:ReadInt32()
		end)

		return enemyKillRecord
	end
	self.midToReader[64094083] = function(reader)
		local taskId = reader:ReadUInt32()

		return taskId
	end
	self.midToReader[64096144] = function(reader)
		local profileId = reader:ReadUInt32()
		local target = Base.ReadComplex(reader, Auto.Reader[12])

		return profileId, target
	end
	self.midToReader[64096520] = function(reader)
		local type = reader:ReadByte()
		local taskId = reader:ReadUInt32()
		local eventId = reader:ReadUInt32()
		local firstTime = reader:ReadBoolean()
		local taskGps = Base.ReadComplex(reader, Auto.Reader[13])
		local reason = reader:ReadByte()

		return type, taskId, eventId, firstTime, taskGps, reason
	end
	self.midToReader[64108636] = function(reader)
		local chats = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[14])
		end)

		return chats
	end
	self.midToReader[64113875] = function(reader)
		local roomId = reader:ReadUInt64()
		local prepareRoom = Base.ReadComplex(reader, Auto.Reader[15])

		return roomId, prepareRoom
	end
	self.midToReader[64114508] = function(reader)
		local behaviors = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[16])
		end)

		return behaviors
	end
	self.midToReader[64124614] = function(reader)
		local result = Base.ReadComplex(reader, Auto.Reader[17])

		return result
	end
	self.midToReader[64125250] = function(reader)
		local taskId = reader:ReadUInt32()

		return taskId
	end
	self.midToReader[64127654] = function(reader)
		local fashionInfoList = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[18])
		end)

		return fashionInfoList
	end
	self.midToReader[64128323] = function(reader)
		local hackerBatteryCurrentAndTotalCount = Base.ReadComplex(reader, Auto.Reader[19])

		return hackerBatteryCurrentAndTotalCount
	end
	self.midToReader[64133996] = function(reader)
		local linkAutoRespond = reader:ReadInt32()

		return linkAutoRespond
	end
	self.midToReader[64138587] = function(reader)
		return
	end
	self.midToReader[64141487] = function(reader)
		local bartenderId = reader:ReadUInt32()
		local bartenderElementInfos = Base.ReadComplex(reader, Auto.Reader[20])

		return bartenderId, bartenderElementInfos
	end
	self.midToReader[64149542] = function(reader)
		local isAccept = reader:ReadBoolean()

		return isAccept
	end
	self.midToReader[64158503] = function(reader)
		local result = Base.ReadComplex(reader, Auto.Reader[21])

		return result
	end
	self.midToReader[64177020] = function(reader)
		local result = Base.ReadStruct(reader, Auto.Reader[22])

		return result
	end
	self.midToReader[64182413] = function(reader)
		local furnitureId = reader:ReadUInt32()
		local count = reader:ReadUInt32()
		local placedCount = reader:ReadUInt32()

		return furnitureId, count, placedCount
	end
	self.midToReader[64184789] = function(reader)
		local activities = Base.ReadList(reader, function(r)
			return Base.ReadStruct(r, Auto.Reader[23])
		end)

		return activities
	end
	self.midToReader[64190422] = function(reader)
		local unlockSystems = Base.ReadList(reader, function(r)
			return r:ReadUInt32()
		end)

		return unlockSystems
	end
	self.midToReader[64191855] = function(reader)
		return
	end
	self.midToReader[64193396] = function(reader)
		local chatInfo = Base.ReadComplex(reader, Auto.Reader[24])

		return chatInfo
	end
	self.midToReader[64196149] = function(reader)
		local availableCount = reader:ReadUInt32()

		return availableCount
	end
	self.midToReader[64203304] = function(reader)
		local allSpirits = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[25])
		end)

		return allSpirits
	end
	self.midToReader[64206120] = function(reader)
		local spiritId = reader:ReadUInt32()
		local spiritJobs = Base.ReadDict(reader, function(r)
			return r:ReadUInt32()
		end, function(r)
			return Base.ReadComplex(r, Auto.Reader[26])
		end)
		local currentJob = reader:ReadUInt32()

		return spiritId, spiritJobs, currentJob
	end
	self.midToReader[64208235] = function(reader)
		local taskId = reader:ReadUInt32()
		local newState = reader:ReadByte()

		return taskId, newState
	end
	self.midToReader[64214284] = function(reader)
		local eventInfo = Base.ReadComplex(reader, Auto.Reader[27])

		return eventInfo
	end
	self.midToReader[64214885] = function(reader)
		local cardInfo = Base.ReadComplex(reader, Auto.Reader[28])

		return cardInfo
	end
	self.midToReader[64227768] = function(reader)
		local taskTitleId = reader:ReadUInt16()
		local unlock = reader:ReadBoolean()

		return taskTitleId, unlock
	end
	self.midToReader[64227911] = function(reader)
		local npcCardId = reader:ReadUInt32()
		local hasInteracted = reader:ReadBoolean()

		return npcCardId, hasInteracted
	end
	self.midToReader[64233556] = function(reader)
		local taskId = reader:ReadUInt32()
		local stateData = Base.ReadComplex(reader, Auto.Reader[29])
		local fromDead = reader:ReadBoolean()

		return taskId, stateData, fromDead
	end
	self.midToReader[64240574] = function(reader)
		local squad = Base.ReadList(reader, function(r)
			return r:ReadUInt64()
		end)

		return squad
	end
	self.midToReader[64250239] = function(reader)
		local newEmail = Base.ReadComplex(reader, Auto.Reader[30])

		return newEmail
	end
	self.midToReader[64263325] = function(reader)
		local teamInfo = Base.ReadComplex(reader, Auto.Reader[31])

		return teamInfo
	end
	self.midToReader[64263949] = function(reader)
		local value = reader:ReadUInt32()

		return value
	end
	self.midToReader[64265105] = function(reader)
		local itemDayCount = Base.ReadComplex(reader, Auto.Reader[32])

		return itemDayCount
	end
	self.midToReader[64268796] = function(reader)
		local progress = reader:ReadSingle()
		local maxLayer = reader:ReadUInt32()
		local speed = reader:ReadSingle()

		return progress, maxLayer, speed
	end
	self.midToReader[64271294] = function(reader)
		local jobClass = reader:ReadUInt32()
		local active = reader:ReadBoolean()

		return jobClass, active
	end
	self.midToReader[64276158] = function(reader)
		local traceGps = Base.ReadComplex(reader, Auto.Reader[33])

		return traceGps
	end
	self.midToReader[64276238] = function(reader)
		local id = reader:ReadUInt32()

		return id
	end
	self.midToReader[64276328] = function(reader)
		local npcCardId = reader:ReadUInt32()
		local tagList = Base.ReadList(reader, function(r)
			return r:ReadUInt32()
		end)

		return npcCardId, tagList
	end
	self.midToReader[64277564] = function(reader)
		local inviterPid = reader:ReadUInt64()
		local type = reader:ReadByte()

		return inviterPid, type
	end
	self.midToReader[64282983] = function(reader)
		local spiritId = reader:ReadUInt32()
		local historyJobs = Base.ReadDict(reader, function(r)
			return r:ReadUInt32()
		end, function(r)
			return Base.ReadComplex(r, Auto.Reader[26])
		end)

		return spiritId, historyJobs
	end
	self.midToReader[64290317] = function(reader)
		local creditInfo = Base.ReadComplex(reader, Auto.Reader[34])

		return creditInfo
	end
	self.midToReader[64294476] = function(reader)
		return
	end
	self.midToReader[64300702] = function(reader)
		local order = Base.ReadComplex(reader, Auto.Reader[35])

		return order
	end
	self.midToReader[64307917] = function(reader)
		local dialogId = reader:ReadUInt32()
		local beginDialog = reader:ReadUInt32()
		local param = Base.ReadComplex(reader, Auto.Reader[36])

		return dialogId, beginDialog, param
	end
	self.midToReader[64309285] = function(reader)
		local randomDic = Base.ReadDict(reader, function(r)
			return r:ReadUInt32()
		end, function(r)
			return Base.ReadComplex(r, Auto.Reader[37])
		end)
		local notAbortList = Base.ReadList(reader, function(r)
			return r:ReadUInt32()
		end)

		return randomDic, notAbortList
	end
	self.midToReader[64314729] = function(reader)
		local spiritIdList = Base.ReadList(reader, function(r)
			return r:ReadUInt32()
		end)

		return spiritIdList
	end
	self.midToReader[64323657] = function(reader)
		local houseId = reader:ReadUInt32()

		return houseId
	end
	self.midToReader[64323859] = function(reader)
		local taskInfos = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[38])
		end)
		local submitTaskList = Base.ReadList(reader, function(r)
			return r:ReadUInt32()
		end)
		local submitEventList = Base.ReadList(reader, function(r)
			return r:ReadUInt32()
		end)
		local currentTask = reader:ReadUInt32()
		local eventPanelInfo = Base.ReadComplex(reader, Auto.Reader[39])
		local eventViewInfoList = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[40])
		end)
		local loginGameServer = reader:ReadBoolean()

		return taskInfos, submitTaskList, submitEventList, currentTask, eventPanelInfo, eventViewInfoList, loginGameServer
	end
	self.midToReader[64330159] = function(reader)
		local spiritId = reader:ReadUInt32()
		local badgeId = reader:ReadUInt32()
		local badgeInfo = Base.ReadComplex(reader, Auto.Reader[41])

		return spiritId, badgeId, badgeInfo
	end
	self.midToReader[64333365] = function(reader)
		local pid = reader:ReadUInt64()
		local suiteName = reader:ReadString()
		local caseName = reader:ReadString()
		local luaStr = reader:ReadString()

		return pid, suiteName, caseName, luaStr
	end
	self.midToReader[64338922] = function(reader)
		local pokemon = Base.ReadComplex(reader, Auto.Reader[42])

		return pokemon
	end
	self.midToReader[64341180] = function(reader)
		local data = Base.ReadDict(reader, function(r)
			return r:ReadUInt32()
		end, function(r)
			return Base.ReadComplex(r, Auto.Reader[43])
		end)

		return data
	end
	self.midToReader[64349771] = function(reader)
		local challengeRecord = Base.ReadComplex(reader, Auto.Reader[44])
		local rewardInfo = Base.ReadComplex(reader, Auto.Reader[45])

		return challengeRecord, rewardInfo
	end
	self.midToReader[64350941] = function(reader)
		local spiritId = reader:ReadUInt32()
		local spiritWearFashionsInfo = Base.ReadComplex(reader, Auto.Reader[46])

		return spiritId, spiritWearFashionsInfo
	end
	self.midToReader[64351404] = function(reader)
		local teamId = reader:ReadUInt64()
		local applier = Base.ReadComplex(reader, Auto.Reader[6])

		return teamId, applier
	end
	self.midToReader[64352235] = function(reader)
		local seasonInfo = Base.ReadComplex(reader, Auto.Reader[47])

		return seasonInfo
	end
	self.midToReader[64354845] = function(reader)
		local npcCardId = reader:ReadUInt32()
		local storyId = reader:ReadUInt32()

		return npcCardId, storyId
	end
	self.midToReader[64358420] = function(reader)
		local value = reader:ReadUInt32()
		local reason = reader:ReadInt32()
		local silence = reader:ReadBoolean()

		return value, reason, silence
	end
	self.midToReader[64358656] = function(reader)
		local teamId = reader:ReadUInt64()
		local playerInfo = Base.ReadComplex(reader, Auto.Reader[6])

		return teamId, playerInfo
	end
	self.midToReader[64362626] = function(reader)
		local spiritId = reader:ReadUInt32()
		local dispatchInfos = Base.ReadDict(reader, function(r)
			return r:ReadUInt32()
		end, function(r)
			return Base.ReadComplex(r, Auto.Reader[48])
		end)

		return spiritId, dispatchInfos
	end
	self.midToReader[64370898] = function(reader)
		local teamId = reader:ReadUInt64()
		local applier = Base.ReadComplex(reader, Auto.Reader[6])

		return teamId, applier
	end
	self.midToReader[64373720] = function(reader)
		local module = reader:ReadByte()
		local spiritId = reader:ReadUInt32()
		local changeEventProgressInfoDict = Base.ReadDict(reader, function(r)
			return r:ReadUInt32()
		end, function(r)
			return Base.ReadComplex(r, Auto.Reader[49])
		end)
		local finishEventConditionIdList = Base.ReadList(reader, function(r)
			return r:ReadUInt32()
		end)

		return module, spiritId, changeEventProgressInfoDict, finishEventConditionIdList
	end
	self.midToReader[64377362] = function(reader)
		local npcOrNpcGroup = reader:ReadUInt32()
		local gameplay = reader:ReadUInt32()

		return npcOrNpcGroup, gameplay
	end
	self.midToReader[64379333] = function(reader)
		local spiritId = reader:ReadUInt32()
		local serviceData = Base.ReadComplex(reader, Auto.Reader[50])
		local weeklyServiceData = Base.ReadComplex(reader, Auto.Reader[50])
		local stopPatrol = reader:ReadBoolean()

		return spiritId, serviceData, weeklyServiceData, stopPatrol
	end
	self.midToReader[64383019] = function(reader)
		local subQuestId = reader:ReadUInt32()

		return subQuestId
	end
	self.midToReader[64383561] = function(reader)
		local bartenderId = reader:ReadUInt32()
		local elementId = reader:ReadUInt32()
		local stockOz = reader:ReadSingle()

		return bartenderId, elementId, stockOz
	end
	self.midToReader[64384300] = function(reader)
		local spiritId = reader:ReadUInt32()
		local violations = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[51])
		end)

		return spiritId, violations
	end
	self.midToReader[64389316] = function(reader)
		local country = reader:ReadUInt32()
		local reputation = reader:ReadUInt32()

		return country, reputation
	end
	self.midToReader[64402770] = function(reader)
		local npcCardId = reader:ReadUInt32()
		local voice = reader:ReadUInt32()

		return npcCardId, voice
	end
	self.midToReader[64415819] = function(reader)
		local houseInfo = Base.ReadComplex(reader, Auto.Reader[52])

		return houseInfo
	end
	self.midToReader[64416807] = function(reader)
		local value = reader:ReadUInt32()
		local LogoId = reader:ReadUInt32()
		local textId = reader:ReadUInt32()
		local success = reader:ReadBoolean()

		return value, LogoId, textId, success
	end
	self.midToReader[64420640] = function(reader)
		local taskId = reader:ReadUInt32()
		local eventId = reader:ReadUInt32()
		local reason = reader:ReadByte()

		return taskId, eventId, reason
	end
	self.midToReader[64423076] = function(reader)
		local quantumWalletStartTime = reader:ReadUInt32()

		return quantumWalletStartTime
	end
	self.midToReader[64428806] = function(reader)
		local groupId = reader:ReadUInt32()

		return groupId
	end
	self.midToReader[64437425] = function(reader)
		local level = reader:ReadUInt32()
		local newClaimState = reader:ReadByte()

		return level, newClaimState
	end
	self.midToReader[64438260] = function(reader)
		local playerInfo = Base.ReadComplex(reader, Auto.Reader[6])
		local teamId = reader:ReadUInt64()

		return playerInfo, teamId
	end
	self.midToReader[64440416] = function(reader)
		local info = Base.ReadComplex(reader, Auto.Reader[53])

		return info
	end
	self.midToReader[64443578] = function(reader)
		local playerInfo = Base.ReadComplex(reader, Auto.Reader[6])
		local teamId = reader:ReadUInt64()
		local reject = reader:ReadBoolean()

		return playerInfo, teamId, reject
	end
	self.midToReader[64444366] = function(reader)
		local activity = Base.ReadStruct(reader, Auto.Reader[23])

		return activity
	end
	self.midToReader[64450572] = function(reader)
		local info = Base.ReadComplex(reader, Auto.Reader[31])

		return info
	end
	self.midToReader[64453933] = function(reader)
		local dialogId = reader:ReadUInt32()

		return dialogId
	end
	self.midToReader[64454079] = function(reader)
		local id = reader:ReadUInt32()

		return id
	end
	self.midToReader[64454937] = function(reader)
		local taskId = reader:ReadUInt32()

		return taskId
	end
	self.midToReader[64456279] = function(reader)
		local spiritId = reader:ReadUInt32()

		return spiritId
	end
	self.midToReader[64462927] = function(reader)
		local cardInfo = Base.ReadComplex(reader, Auto.Reader[28])

		return cardInfo
	end
	self.midToReader[64467486] = function(reader)
		local tuiteInfo = Base.ReadComplex(reader, Auto.Reader[54])

		return tuiteInfo
	end
	self.midToReader[64472143] = function(reader)
		local module = reader:ReadByte()
		local eventConditionIdList = Base.ReadList(reader, function(r)
			return r:ReadUInt32()
		end)
		local spiritId = reader:ReadUInt32()

		return module, eventConditionIdList, spiritId
	end
	self.midToReader[64484280] = function(reader)
		local canWatchOther = reader:ReadBoolean()
		local watchingPid = reader:ReadUInt64()

		return canWatchOther, watchingPid
	end
	self.midToReader[64485852] = function(reader)
		local newPassType = reader:ReadByte()

		return newPassType
	end
	self.midToReader[64495540] = function(reader)
		local newLevel = reader:ReadUInt32()
		local newExp = reader:ReadUInt32()

		return newLevel, newExp
	end
	self.midToReader[64509181] = function(reader)
		local fan12 = reader:ReadUInt32()
		local fan123 = reader:ReadUInt32()
		local level = reader:ReadUInt32()
		local levelRewards = Base.ReadList(reader, function(r)
			return r:ReadUInt32()
		end)
		local yesterdayFan = reader:ReadInt32()

		return fan12, fan123, level, levelRewards, yesterdayFan
	end
	self.midToReader[64519765] = function(reader)
		local interactionActionState = reader:ReadByte()

		return interactionActionState
	end
	self.midToReader[64534124] = function(reader)
		local newGuideTeachInfos = Base.ReadList(reader, function(r)
			return r:ReadUInt32()
		end)
		local rewardedGuideTeachInfos = Base.ReadList(reader, function(r)
			return r:ReadUInt32()
		end)

		return newGuideTeachInfos, rewardedGuideTeachInfos
	end
	self.midToReader[64535774] = function(reader)
		local infos = Base.ReadList(reader, function(r)
			return Base.ReadStruct(r, Auto.Reader[7])
		end)

		return infos
	end
	self.midToReader[64539241] = function(reader)
		local pid = reader:ReadUInt64()

		return pid
	end
	self.midToReader[64542461] = function(reader)
		local spiritId = reader:ReadUInt32()
		local phoneInfos = Base.ReadComplex(reader, Auto.Reader[55])

		return spiritId, phoneInfos
	end
	self.midToReader[64544191] = function(reader)
		local customerInfo = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[56])
		end)

		return customerInfo
	end
	self.midToReader[64551745] = function(reader)
		local tempSpirits = Base.ReadList(reader, function(r)
			return r:ReadUInt32()
		end)

		return tempSpirits
	end
	self.midToReader[64553341] = function(reader)
		local unlockedVehicles = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[57])
		end)

		return unlockedVehicles
	end
	self.midToReader[64557867] = function(reader)
		local chatInfo = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[24])
		end)

		return chatInfo
	end
	self.midToReader[64564516] = function(reader)
		local ItemShortcutInfoDict = Base.ReadDict(reader, function(r)
			return r:ReadByte()
		end, function(r)
			return Base.ReadComplex(r, Auto.Reader[58])
		end)
		local destructibleShortcut = reader:ReadUInt32()

		return ItemShortcutInfoDict, destructibleShortcut
	end
	self.midToReader[64566661] = function(reader)
		local ticketInfo = Base.ReadDict(reader, function(r)
			return r:ReadUInt32()
		end, function(r)
			return r:ReadByte()
		end)

		return ticketInfo
	end
	self.midToReader[64573061] = function(reader)
		local TwitterId = reader:ReadUInt32()
		local isOpen = reader:ReadBoolean()
		local SecondShowType = reader:ReadUInt32()
		local isShow = reader:ReadBoolean()

		return TwitterId, isOpen, SecondShowType, isShow
	end
	self.midToReader[64573658] = function(reader)
		local spiritId = reader:ReadUInt32()
		local cases = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[59])
		end)

		return spiritId, cases
	end
	self.midToReader[64574748] = function(reader)
		local spiritId = reader:ReadUInt32()
		local ability = Base.ReadComplex(reader, Auto.Reader[60])

		return spiritId, ability
	end
	self.midToReader[64574821] = function(reader)
		local id = reader:ReadUInt64()
		local isLocked = reader:ReadBoolean()

		return id, isLocked
	end
	self.midToReader[64576140] = function(reader)
		local npcCultivationId = reader:ReadUInt32()

		return npcCultivationId
	end
	self.midToReader[64579368] = function(reader)
		local inviteeState = reader:ReadByte()
		local inviterPid = reader:ReadUInt64()
		local actionItemId = reader:ReadUInt32()

		return inviteeState, inviterPid, actionItemId
	end
	self.midToReader[64580834] = function(reader)
		local id = reader:ReadUInt32()

		return id
	end
	self.midToReader[64581024] = function(reader)
		local itemCountLimitList = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[61])
		end)

		return itemCountLimitList
	end
	self.midToReader[64587006] = function(reader)
		local prizePoolId = reader:ReadUInt32()

		return prizePoolId
	end
	self.midToReader[64589836] = function(reader)
		local npcCardId = reader:ReadUInt32()
		local favorDiff = reader:ReadDouble()
		local favor = reader:ReadDouble()

		return npcCardId, favorDiff, favor
	end
	self.midToReader[64594789] = function(reader)
		local cityPediaId = reader:ReadUInt32()

		return cityPediaId
	end
	self.midToReader[64599072] = function(reader)
		local spiritId = reader:ReadUInt32()
		local posInfo = Base.ReadList(reader, function(r)
			return r:ReadUInt32()
		end)

		return spiritId, posInfo
	end
	self.midToReader[64599282] = function(reader)
		return
	end
	self.midToReader[64602397] = function(reader)
		local InviteRideNpcInstanceId = reader:ReadUInt64()
		local IsInviteRideNpcActive = reader:ReadBoolean()

		return InviteRideNpcInstanceId, IsInviteRideNpcActive
	end
	self.midToReader[64619526] = function(reader)
		local inviterState = reader:ReadByte()
		local inviteePid = reader:ReadUInt64()
		local actionItemId = reader:ReadUInt32()

		return inviterState, inviteePid, actionItemId
	end
	self.midToReader[64620949] = function(reader)
		local npcCardId = reader:ReadUInt32()
		local isGroup = reader:ReadBoolean()
		local posInfo = Base.ReadList(reader, function(r)
			return r:ReadUInt32()
		end)

		return npcCardId, isGroup, posInfo
	end
	self.midToReader[64621842] = function(reader)
		local fashionInfo = Base.ReadComplex(reader, Auto.Reader[18])

		return fashionInfo
	end
	self.midToReader[64626131] = function(reader)
		local availableProduces = Base.ReadList(reader, function(r)
			return r:ReadUInt32()
		end)

		return availableProduces
	end
	self.midToReader[64628013] = function(reader)
		local seasonInfo = Base.ReadComplex(reader, Auto.Reader[62])

		return seasonInfo
	end
	self.midToReader[64630599] = function(reader)
		local fullDetails = Base.ReadComplex(reader, Auto.Reader[63])

		return fullDetails
	end
	self.midToReader[64638005] = function(reader)
		local data = Base.ReadComplex(reader, Auto.Reader[64])

		return data
	end
	self.midToReader[64641895] = function(reader)
		local pid = reader:ReadUInt64()
		local name = reader:ReadString()
		local type = reader:ReadUInt32()
		local context = reader:ReadString()
		local isSource = reader:ReadBoolean()
		local isResponse = reader:ReadBoolean()

		return pid, name, type, context, isSource, isResponse
	end
	self.midToReader[64646049] = function(reader)
		local options = Base.ReadList(reader, function(r)
			return r:ReadUInt32()
		end)

		return options
	end
	self.midToReader[64652219] = function(reader)
		local npcCardId = reader:ReadUInt32()
		local hasInteracted = reader:ReadBoolean()

		return npcCardId, hasInteracted
	end
	self.midToReader[64653833] = function(reader)
		local money = reader:ReadUInt32()
		local gold = reader:ReadInt32()
		local bindingGold = reader:ReadUInt32()

		return money, gold, bindingGold
	end
	self.midToReader[64661996] = function(reader)
		local id = reader:ReadUInt32()
		local detail = Base.ReadComplex(reader, Auto.Reader[65])

		return id, detail
	end
	self.midToReader[64662440] = function(reader)
		local order = Base.ReadComplex(reader, Auto.Reader[66])

		return order
	end
	self.midToReader[64671698] = function(reader)
		local chatId = reader:ReadUInt32()
		local asNpc = reader:ReadUInt32()

		return chatId, asNpc
	end
	self.midToReader[64672612] = function(reader)
		local order = Base.ReadComplex(reader, Auto.Reader[35])

		return order
	end
	self.midToReader[64676793] = function(reader)
		local spiritId = reader:ReadUInt32()

		return spiritId
	end
	self.midToReader[64682455] = function(reader)
		local gameplay = reader:ReadUInt32()

		return gameplay
	end
	self.midToReader[64685674] = function(reader)
		local groupId = reader:ReadUInt32()

		return groupId
	end
	self.midToReader[64690406] = function(reader)
		local spiritId = reader:ReadUInt32()
		local policeFakeFileInfo = Base.ReadComplex(reader, Auto.Reader[67])

		return spiritId, policeFakeFileInfo
	end
	self.midToReader[64692146] = function(reader)
		local agentId = reader:ReadUInt64()
		local stage = reader:ReadInt32()
		local error = reader:ReadUInt32()

		return agentId, stage, error
	end
	self.midToReader[64693614] = function(reader)
		local spiritId = reader:ReadUInt32()
		local jobClassId = reader:ReadUInt32()
		local talentId = reader:ReadUInt32()
		local layer = reader:ReadUInt32()

		return spiritId, jobClassId, talentId, layer
	end
	self.midToReader[64708333] = function(reader)
		local npcOrNpcGroup = reader:ReadUInt32()
		local gameplay = reader:ReadUInt32()

		return npcOrNpcGroup, gameplay
	end
	self.midToReader[64709905] = function(reader)
		local interactPoint = reader:ReadUInt32()

		return interactPoint
	end
	self.midToReader[64711781] = function(reader)
		local intention = reader:ReadByte()
		local bindGoldRemove = reader:ReadUInt32()
		local unbindGoldRemove = reader:ReadUInt32()

		return intention, bindGoldRemove, unbindGoldRemove
	end
	self.midToReader[64734958] = function(reader)
		local raidId = reader:ReadUInt32()
		local errorId = reader:ReadUInt32()

		return raidId, errorId
	end
	self.midToReader[64735329] = function(reader)
		local info = Base.ReadComplex(reader, Auto.Reader[31])

		return info
	end
	self.midToReader[64737256] = function(reader)
		local areaId = reader:ReadUInt32()
		local occupy = reader:ReadBoolean()

		return areaId, occupy
	end
	self.midToReader[64740104] = function(reader)
		local taskId = reader:ReadUInt32()

		return taskId
	end
	self.midToReader[64745458] = function(reader)
		local factionId = reader:ReadUInt32()
		local info = Base.ReadComplex(reader, Auto.Reader[68])
		local oldInfo = Base.ReadComplex(reader, Auto.Reader[68])
		local dropTextId = reader:ReadUInt32()

		return factionId, info, oldInfo, dropTextId
	end
	self.midToReader[64749352] = function(reader)
		local countryId = reader:ReadUInt32()
		local unlock = reader:ReadBoolean()

		return countryId, unlock
	end
	self.midToReader[64750996] = function(reader)
		local changeExp = reader:ReadInt32()
		local exp = reader:ReadUInt32()

		return changeExp, exp
	end
	self.midToReader[64765180] = function(reader)
		local weapon = Auto.Dispatch[69](reader)

		return weapon
	end
	self.midToReader[64770574] = function(reader)
		local info = Base.ReadComplex(reader, Auto.Reader[45])

		return info
	end
	self.midToReader[64771401] = function(reader)
		local spiritId = reader:ReadUInt32()
		local jobClassId = reader:ReadUInt32()
		local talentPoint = reader:ReadUInt32()
		local reason = reader:ReadInt32()

		return spiritId, jobClassId, talentPoint, reason
	end
	self.midToReader[64772212] = function(reader)
		local npcCardId = reader:ReadUInt32()
		local storyId = reader:ReadUInt32()
		local unixTime = reader:ReadUInt32()

		return npcCardId, storyId, unixTime
	end
	self.midToReader[64780410] = function(reader)
		local contactUnlockId = reader:ReadUInt32()
		local contactInfo = Base.ReadComplex(reader, Auto.Reader[70])
		local selfSpiritId = reader:ReadUInt32()

		return contactUnlockId, contactInfo, selfSpiritId
	end
	self.midToReader[64784818] = function(reader)
		local value = reader:ReadInt32()

		return value
	end
	self.midToReader[64786930] = function(reader)
		local id = reader:ReadUInt32()
		local orderInfo = Base.ReadComplex(reader, Auto.Reader[35])
		local deliveryAgentId = reader:ReadUInt64()

		return id, orderInfo, deliveryAgentId
	end
	self.midToReader[64787777] = function(reader)
		local info = Base.ReadComplex(reader, Auto.Reader[71])

		return info
	end
	self.midToReader[64790694] = function(reader)
		local galleryId = reader:ReadUInt32()
		local unlock = reader:ReadBoolean()
		local galleryInfo = Base.ReadComplex(reader, Auto.Reader[72])

		return galleryId, unlock, galleryInfo
	end
	self.midToReader[64791397] = function(reader)
		local mode = reader:ReadByte()

		return mode
	end
	self.midToReader[64795895] = function(reader)
		local tuiteConfigId = reader:ReadUInt32()

		return tuiteConfigId
	end
	self.midToReader[64799473] = function(reader)
		local cancelInfoList = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[8])
		end)
		local addInfoList = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[8])
		end)

		return cancelInfoList, addInfoList
	end
	self.midToReader[64804461] = function(reader)
		local popularity = reader:ReadSingle()

		return popularity
	end
	self.midToReader[64819491] = function(reader)
		local spiritId = reader:ReadUInt32()
		local fakeFileId = reader:ReadUInt32()
		local agentId = reader:ReadUInt32()
		local curClueValue = reader:ReadUInt32()
		local fakeFileState = reader:ReadByte()

		return spiritId, fakeFileId, agentId, curClueValue, fakeFileState
	end
	self.midToReader[64822851] = function(reader)
		local fashionInfoDict = Base.ReadDict(reader, function(r)
			return r:ReadUInt32()
		end, function(r)
			return Base.ReadComplex(r, Auto.Reader[18])
		end)

		return fashionInfoDict
	end
	self.midToReader[64822920] = function(reader)
		local openEntrance = Base.ReadList(reader, function(r)
			return r:ReadUInt32()
		end)
		local displayableEntrances = Base.ReadList(reader, function(r)
			return r:ReadUInt32()
		end)

		return openEntrance, displayableEntrances
	end
	self.midToReader[64823589] = function(reader)
		local badgeId = reader:ReadUInt32()
		local badgeInfo = Base.ReadComplex(reader, Auto.Reader[41])

		return badgeId, badgeInfo
	end
	self.midToReader[64824976] = function(reader)
		local infos = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[73])
		end)

		return infos
	end
	self.midToReader[64833906] = function(reader)
		local activityData = Auto.Dispatch[74](reader)

		return activityData
	end
	self.midToReader[64842871] = function(reader)
		local sceneId = reader:ReadUInt32()
		local unlock = reader:ReadBoolean()

		return sceneId, unlock
	end
	self.midToReader[64843031] = function(reader)
		local mapEntranceId = reader:ReadUInt32()
		local isOpen = reader:ReadBoolean()
		local isShow = reader:ReadBoolean()

		return mapEntranceId, isOpen, isShow
	end
	self.midToReader[64852033] = function(reader)
		local dialogIds = Base.ReadList(reader, function(r)
			return r:ReadUInt32()
		end)

		return dialogIds
	end
	self.midToReader[64854957] = function(reader)
		local kickedByPid = reader:ReadUInt64()

		return kickedByPid
	end
	self.midToReader[64856145] = function(reader)
		local matchInfo = Base.ReadComplex(reader, Auto.Reader[75])

		return matchInfo
	end
	self.midToReader[64856470] = function(reader)
		local spiritId = reader:ReadUInt32()
		local addExp = reader:ReadUInt32()
		local exp = reader:ReadUInt32()
		local level = reader:ReadUInt32()

		return spiritId, addExp, exp, level
	end
	self.midToReader[64857448] = function(reader)
		local profileId = reader:ReadUInt32()
		local rewardId = reader:ReadUInt32()

		return profileId, rewardId
	end
	self.midToReader[64860567] = function(reader)
		local batteryHackCost = Base.ReadDict(reader, function(r)
			return r:ReadUInt32()
		end, function(r)
			return r:ReadUInt32()
		end)

		return batteryHackCost
	end
	self.midToReader[64861390] = function(reader)
		local factIds = Base.ReadList(reader, function(r)
			return r:ReadUInt32()
		end)
		local examTaskId = reader:ReadUInt32()
		local examIndex = reader:ReadInt32()

		return factIds, examTaskId, examIndex
	end
	self.midToReader[64861577] = function(reader)
		local reactionId = reader:ReadUInt32()

		return reactionId
	end
	self.midToReader[64862193] = function(reader)
		local pid = reader:ReadUInt64()
		local gameId = reader:ReadUInt32()
		local roomId = reader:ReadUInt64()

		return pid, gameId, roomId
	end
	self.midToReader[64864346] = function(reader)
		local timeTableInfos = Base.ReadDict(reader, function(r)
			return r:ReadUInt32()
		end, function(r)
			return Base.ReadComplex(r, Auto.Reader[76])
		end)

		return timeTableInfos
	end
	self.midToReader[64865387] = function(reader)
		local eventIds = Base.ReadList(reader, function(r)
			return r:ReadUInt32()
		end)

		return eventIds
	end
	self.midToReader[64866915] = function(reader)
		return
	end
	self.midToReader[64868156] = function(reader)
		local spiritId = reader:ReadUInt32()
		local enableClientTryWearCount = reader:ReadByte()

		return spiritId, enableClientTryWearCount
	end
	self.midToReader[64870478] = function(reader)
		local currPopularity = reader:ReadSingle()
		local history = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[77])
		end)
		local underflowPopularity = reader:ReadSingle()

		return currPopularity, history, underflowPopularity
	end
	self.midToReader[64873229] = function(reader)
		local questId = reader:ReadUInt32()

		return questId
	end
	self.midToReader[64875023] = function(reader)
		local roleTeam = Base.ReadList(reader, function(r)
			return r:ReadUInt32()
		end)
		local enableRoleIds = Base.ReadList(reader, function(r)
			return r:ReadUInt32()
		end)
		local tipRoleId = reader:ReadUInt32()
		local enableSwitch = reader:ReadBoolean()

		return roleTeam, enableRoleIds, tipRoleId, enableSwitch
	end
	self.midToReader[64879093] = function(reader)
		local inviteePid = reader:ReadUInt64()
		local actionItemId = reader:ReadUInt32()

		return inviteePid, actionItemId
	end
	self.midToReader[64879625] = function(reader)
		local playerInfo = Base.ReadComplex(reader, Auto.Reader[78])

		return playerInfo
	end
	self.midToReader[64881952] = function(reader)
		local newActionItems = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[79])
		end)

		return newActionItems
	end
	self.midToReader[64882664] = function(reader)
		return
	end
	self.midToReader[64883472] = function(reader)
		local spiritId = reader:ReadUInt32()
		local data = Base.ReadComplex(reader, Auto.Reader[80])

		return spiritId, data
	end
	self.midToReader[64888344] = function(reader)
		local count = reader:ReadInt32()

		return count
	end
	self.midToReader[64889017] = function(reader)
		local id = reader:ReadUInt32()
		local eventId = reader:ReadUInt32()
		local selected = reader:ReadBoolean()
		local complete = reader:ReadBoolean()

		return id, eventId, selected, complete
	end
	self.midToReader[64891221] = function(reader)
		return
	end
	self.midToReader[64893487] = function(reader)
		local spiritId = reader:ReadUInt32()
		local mobileSkinInfo = Base.ReadComplex(reader, Auto.Reader[81])
		local availableSkinParts = Base.ReadList(reader, function(r)
			return r:ReadUInt32()
		end)

		return spiritId, mobileSkinInfo, availableSkinParts
	end
	self.midToReader[64893691] = function(reader)
		local membersInfos = Base.ReadComplex(reader, Auto.Reader[82])

		return membersInfos
	end
	self.midToReader[64900755] = function(reader)
		local npcCardId = reader:ReadUInt32()
		local favorDiff = reader:ReadDouble()
		local favor = reader:ReadDouble()
		local gamePlayType = reader:ReadUInt32()

		return npcCardId, favorDiff, favor, gamePlayType
	end
	self.midToReader[64903065] = function(reader)
		local playerBattlePassInfo = Base.ReadComplex(reader, Auto.Reader[83])

		return playerBattlePassInfo
	end
	self.midToReader[64909391] = function(reader)
		local guide = reader:ReadUInt32()
		local counter = reader:ReadUInt32()

		return guide, counter
	end
	self.midToReader[64916867] = function(reader)
		local agentTag = reader:ReadUInt32()
		local spoonAgentId = reader:ReadInt32()
		local Position = Base.ReadStruct(reader, Auto.Reader.UXVector3)
		local isAtTemporaryPosition = reader:ReadBoolean()

		return agentTag, spoonAgentId, Position, isAtTemporaryPosition
	end
	self.midToReader[64916956] = function(reader)
		local newFile = Base.ReadComplex(reader, Auto.Reader[84])

		return newFile
	end
	self.midToReader[64920050] = function(reader)
		local spiritId = reader:ReadUInt32()
		local taskTryWearInfo = Base.ReadComplex(reader, Auto.Reader[85])

		return spiritId, taskTryWearInfo
	end
	self.midToReader[64927146] = function(reader)
		local gameplayId = reader:ReadUInt32()
		local count = reader:ReadInt32()

		return gameplayId, count
	end
	self.midToReader[64931280] = function(reader)
		local dropId = reader:ReadUInt32()

		return dropId
	end
	self.midToReader[64932574] = function(reader)
		local order = Base.ReadComplex(reader, Auto.Reader[35])
		local preRank = reader:ReadUInt32()
		local newRank = reader:ReadUInt32()
		local rewardPoint = reader:ReadInt32()

		return order, preRank, newRank, rewardPoint
	end
	self.midToReader[64938335] = function(reader)
		local info = Base.ReadComplex(reader, Auto.Reader[86])

		return info
	end
	self.midToReader[64939922] = function(reader)
		local oldCurrentId = reader:ReadUInt32()
		local newCurrentId = reader:ReadUInt32()

		return oldCurrentId, newCurrentId
	end
	self.midToReader[64945644] = function(reader)
		local interactionActionState = reader:ReadByte()

		return interactionActionState
	end
	self.midToReader[64945945] = function(reader)
		local messageId = reader:ReadUInt32()
		local args = Base.ReadList(reader, function(r)
			return r:ReadString()
		end)
		local para = Base.ReadComplex(reader, Auto.Reader[87])

		return messageId, args, para
	end
	self.midToReader[64946100] = function(reader)
		local info = Base.ReadComplex(reader, Auto.Reader[88])

		return info
	end
	self.midToReader[64949986] = function(reader)
		local id = reader:ReadUInt64()

		return id
	end
	self.midToReader[64955067] = function(reader)
		local contactUnlockId = reader:ReadUInt32()
		local contactInfo = Base.ReadComplex(reader, Auto.Reader[70])
		local selfSpiritId = reader:ReadUInt32()

		return contactUnlockId, contactInfo, selfSpiritId
	end
	self.midToReader[64960991] = function(reader)
		local changeInfos = Base.ReadList(reader, function(r)
			return Base.ReadStruct(r, Auto.Reader[89])
		end)
		local dropTextId = reader:ReadUInt32()

		return changeInfos, dropTextId
	end
	self.midToReader[64963363] = function(reader)
		local spirit = Base.ReadComplex(reader, Auto.Reader[90])
		local reason = reader:ReadInt32()

		return spirit, reason
	end
	self.midToReader[64967055] = function(reader)
		local currPopularity = reader:ReadSingle()
		local history = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[77])
		end)
		local underflowPopularity = reader:ReadSingle()

		return currPopularity, history, underflowPopularity
	end
	self.midToReader[64968867] = function(reader)
		local reactionId = reader:ReadUInt32()

		return reactionId
	end
	self.midToReader[64971352] = function(reader)
		local profileInfo = Base.ReadComplex(reader, Auto.Reader[91])

		return profileInfo
	end
	self.midToReader[64976571] = function(reader)
		local popularityAdd = reader:ReadSingle()
		local totalLeftMoney = reader:ReadUInt32()
		local walletRewardList = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[92])
		end)
		local dropList = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[93])
		end)
		local pastHoursCoinRewardList = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[92])
		end)

		return popularityAdd, totalLeftMoney, walletRewardList, dropList, pastHoursCoinRewardList
	end
	self.midToReader[64994824] = function(reader)
		local ruleId = reader:ReadUInt32()

		return ruleId
	end
	self.midToReader[66183523] = function(reader)
		local furnitureInfoDict = Base.ReadDict(reader, function(r)
			return r:ReadUInt32()
		end, function(r)
			return Base.ReadComplex(r, Auto.Reader[94])
		end)

		return furnitureInfoDict
	end
	self.midToReader[66711481] = function(reader)
		local houseId = reader:ReadUInt32()
		local indoorId = reader:ReadUInt32()
		local placedFurnitureInfos = Base.ReadDict(reader, function(r)
			return r:ReadUInt64()
		end, function(r)
			return Base.ReadComplex(r, Auto.Reader[95])
		end)

		return houseId, indoorId, placedFurnitureInfos
	end
	self.midToReader[68001251] = function(reader)
		local pid = reader:ReadUInt64()
		local camp = reader:ReadByte()

		return pid, camp
	end
	self.midToReader[68002111] = function(reader)
		local signalName = reader:ReadString()

		return signalName
	end
	self.midToReader[68002141] = function(reader)
		local agentEntityId = reader:ReadUInt64()
		local disease = reader:ReadUInt32()
		local treatCount = reader:ReadInt32()

		return agentEntityId, disease, treatCount
	end
	self.midToReader[68007325] = function(reader)
		local pid = reader:ReadUInt64()
		local rate = reader:ReadDouble()

		return pid, rate
	end
	self.midToReader[68008896] = function(reader)
		local settleData = Base.ReadComplex(reader, Auto.Reader[96])

		return settleData
	end
	self.midToReader[68011793] = function(reader)
		local spawnInfos = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[97])
		end)
		local configInfo = Base.ReadComplex(reader, Auto.Reader[98])

		return spawnInfos, configInfo
	end
	self.midToReader[68021038] = function(reader)
		local entityId = reader:ReadUInt64()
		local buffInstanceId = reader:ReadUInt32()

		return entityId, buffInstanceId
	end
	self.midToReader[68027187] = function(reader)
		local gameStartTime = reader:ReadUInt32()

		return gameStartTime
	end
	self.midToReader[68029044] = function(reader)
		local buffs = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[99])
		end)
		local remainTime = reader:ReadDouble()
		local refreshCost = reader:ReadUInt32()

		return buffs, remainTime, refreshCost
	end
	self.midToReader[68032672] = function(reader)
		return
	end
	self.midToReader[68033182] = function(reader)
		local messageId = reader:ReadUInt32()
		local infos = Base.ReadList(reader, function(r)
			return r:ReadString()
		end)

		return messageId, infos
	end
	self.midToReader[68035270] = function(reader)
		local id = reader:ReadUInt64()
		local spawnInfoScareNpcRadius = reader:ReadSingle()
		local surroundNpcRadius = reader:ReadSingle()
		local add = reader:ReadBoolean()

		return id, spawnInfoScareNpcRadius, surroundNpcRadius, add
	end
	self.midToReader[68035599] = function(reader)
		local entityId = reader:ReadUInt64()
		local position = Base.ReadStruct(reader, Auto.Reader.UXVector3)
		local facing = reader:ReadSingle()
		local velocity = reader:ReadSingle()
		local reset = reader:ReadBoolean()

		return entityId, position, facing, velocity, reset
	end
	self.midToReader[68041040] = function(reader)
		local syncData = Base.ReadComplex(reader, Auto.Reader[100])

		return syncData
	end
	self.midToReader[68054711] = function(reader)
		local type = reader:ReadByte()
		local id = reader:ReadUInt64()
		local effectId = reader:ReadInt32()

		return type, id, effectId
	end
	self.midToReader[68080713] = function(reader)
		local enemyInstanceId = reader:ReadUInt64()
		local bindItemsIndex = reader:ReadInt32()
		local yForce = reader:ReadSingle()
		local zForce = reader:ReadSingle()
		local gravity = reader:ReadSingle()

		return enemyInstanceId, bindItemsIndex, yForce, zForce, gravity
	end
	self.midToReader[68084611] = function(reader)
		local id = reader:ReadUInt64()
		local stealthValue = reader:ReadSingle()
		local state = reader:ReadByte()

		return id, stealthValue, state
	end
	self.midToReader[68091716] = function(reader)
		local finishTime = reader:ReadUInt32()

		return finishTime
	end
	self.midToReader[68098630] = function(reader)
		local vehicleEntityId = reader:ReadUInt64()
		local force = reader:ReadBoolean()
		local stopBeforeLeave = reader:ReadBoolean()

		return vehicleEntityId, force, stopBeforeLeave
	end
	self.midToReader[68099659] = function(reader)
		local spiritRemoveWeaponDetail = Base.ReadComplex(reader, Auto.Reader[101])

		return spiritRemoveWeaponDetail
	end
	self.midToReader[68103518] = function(reader)
		local uId = reader:ReadUInt64()
		local seatIndex = reader:ReadInt32()
		local piece = Base.ReadComplex(reader, Auto.Reader[102])

		return uId, seatIndex, piece
	end
	self.midToReader[68116531] = function(reader)
		local type = reader:ReadByte()
		local id = reader:ReadUInt64()
		local linkId = reader:ReadUInt32()

		return type, id, linkId
	end
	self.midToReader[68118887] = function(reader)
		local uId = reader:ReadUInt64()
		local participantInfo = Auto.Dispatch[103](reader)
		local add = reader:ReadBoolean()

		return uId, participantInfo, add
	end
	self.midToReader[68119175] = function(reader)
		local leftFailureDieCount = reader:ReadInt32()

		return leftFailureDieCount
	end
	self.midToReader[68125619] = function(reader)
		local npcId = reader:ReadInt32()
		local taskId = reader:ReadUInt32()
		local enemyId = reader:ReadUInt64()

		return npcId, taskId, enemyId
	end
	self.midToReader[68129563] = function(reader)
		local data = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[104])
		end)
		local success = reader:ReadBoolean()
		local taskId = reader:ReadUInt32()

		return data, success, taskId
	end
	self.midToReader[68132210] = function(reader)
		local tagInfos = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[105])
		end)

		return tagInfos
	end
	self.midToReader[68137883] = function(reader)
		local syncInfo = Base.ReadComplex(reader, Auto.Reader[106])

		return syncInfo
	end
	self.midToReader[68147858] = function(reader)
		local level = reader:ReadUInt32()

		return level
	end
	self.midToReader[68151671] = function(reader)
		local enemyId = reader:ReadUInt64()
		local ultEnergy = reader:ReadSingle()

		return enemyId, ultEnergy
	end
	self.midToReader[68152068] = function(reader)
		local response = Base.ReadComplex(reader, Auto.Reader[107])
		local NPCIds = Base.ReadList(reader, function(r)
			return r:ReadUInt64()
		end)

		return response, NPCIds
	end
	self.midToReader[68156906] = function(reader)
		local pid = reader:ReadUInt64()
		local name = reader:ReadString()

		return pid, name
	end
	self.midToReader[68168359] = function(reader)
		local value = reader:ReadBoolean()

		return value
	end
	self.midToReader[68175489] = function(reader)
		local id = reader:ReadUInt64()
		local values = Base.ReadDict(reader, function(r)
			return r:ReadUInt64()
		end, function(r)
			return r:ReadSingle()
		end)

		return id, values
	end
	self.midToReader[68187041] = function(reader)
		local raidInstanceId = reader:ReadUInt64()
		local time = reader:ReadDouble()

		return raidInstanceId, time
	end
	self.midToReader[68191888] = function(reader)
		local id = reader:ReadInt32()
		local instanceId = reader:ReadUInt64()
		local taskId = reader:ReadUInt32()

		return id, instanceId, taskId
	end
	self.midToReader[68208678] = function(reader)
		return
	end
	self.midToReader[68209787] = function(reader)
		local uId = reader:ReadUInt64()
		local scoreInfo = Base.ReadComplex(reader, Auto.Reader[108])

		return uId, scoreInfo
	end
	self.midToReader[68211444] = function(reader)
		local reviveCount = reader:ReadInt32()

		return reviveCount
	end
	self.midToReader[68211691] = function(reader)
		local pid = reader:ReadUInt64()
		local pedInitData = Base.ReadComplex(reader, Auto.Reader[109])

		return pid, pedInitData
	end
	self.midToReader[68228126] = function(reader)
		local groupId = reader:ReadInt32()
		local lockTarget = reader:ReadBoolean()

		return groupId, lockTarget
	end
	self.midToReader[68229586] = function(reader)
		local vehicleUId = reader:ReadUInt64()
		local add = reader:ReadBoolean()

		return vehicleUId, add
	end
	self.midToReader[68234788] = function(reader)
		local spiritAddWeaponDetail = Base.ReadComplex(reader, Auto.Reader[110])

		return spiritAddWeaponDetail
	end
	self.midToReader[68235182] = function(reader)
		local agentId = reader:ReadUInt64()
		local targetPid = reader:ReadUInt64()
		local ArrestType = reader:ReadByte()

		return agentId, targetPid, ArrestType
	end
	self.midToReader[68235314] = function(reader)
		local pid = reader:ReadUInt64()
		local id = reader:ReadUInt64()

		return pid, id
	end
	self.midToReader[68238665] = function(reader)
		local entityId = reader:ReadUInt64()
		local buff = Base.ReadStruct(reader, Auto.Reader[111])

		return entityId, buff
	end
	self.midToReader[68244217] = function(reader)
		local flowId = reader:ReadInt32()
		local nodeId = reader:ReadInt32()
		local ports = Base.ReadList(reader, Auto.Dispatch[112])
		local taskInfo = Base.ReadComplex(reader, Auto.Reader[113])

		return flowId, nodeId, ports, taskInfo
	end
	self.midToReader[68253739] = function(reader)
		local id = reader:ReadUInt64()
		local urbanAttrs = Base.ReadList(reader, function(r)
			return r:ReadInt32()
		end)

		return id, urbanAttrs
	end
	self.midToReader[68257427] = function(reader)
		local pid = reader:ReadUInt64()
		local name = reader:ReadString()

		return pid, name
	end
	self.midToReader[68268723] = function(reader)
		local recordId = reader:ReadUInt32()
		local paramId = reader:ReadUInt32()

		return recordId, paramId
	end
	self.midToReader[68295962] = function(reader)
		local vehicleInstanceId = reader:ReadUInt64()
		local isCalImpulse = reader:ReadBoolean()

		return vehicleInstanceId, isCalImpulse
	end
	self.midToReader[68297382] = function(reader)
		local position = Base.ReadStruct(reader, Auto.Reader.UXVector3)
		local npcId = reader:ReadUInt64()

		return position, npcId
	end
	self.midToReader[68302014] = function(reader)
		local state = reader:ReadByte()
		local countDownTime = reader:ReadSingle()
		local lastState = reader:ReadByte()
		local textId = reader:ReadUInt32()
		local ifShowCountTime = reader:ReadBoolean()
		local ifEnableBlink = reader:ReadBoolean()
		local ifShowProgressBar = reader:ReadBoolean()

		return state, countDownTime, lastState, textId, ifShowCountTime, ifEnableBlink, ifShowProgressBar
	end
	self.midToReader[68314091] = function(reader)
		local pid = reader:ReadUInt64()
		local templateId = reader:ReadUInt32()
		local spiritId = reader:ReadUInt64()
		local isAgentSwitch = reader:ReadBoolean()

		return pid, templateId, spiritId, isAgentSwitch
	end
	self.midToReader[68314340] = function(reader)
		local enemyId = reader:ReadUInt64()
		local spoonId = reader:ReadInt32()
		local state = reader:ReadByte()
		local campId = reader:ReadUInt32()
		local rebornTime = reader:ReadUInt32()

		return enemyId, spoonId, state, campId, rebornTime
	end
	self.midToReader[68328421] = function(reader)
		local speed = reader:ReadSingle()

		return speed
	end
	self.midToReader[68333410] = function(reader)
		local progressId = reader:ReadUInt32()

		return progressId
	end
	self.midToReader[68334114] = function(reader)
		local agentEntityId = reader:ReadUInt64()
		local suitId = reader:ReadUInt32()

		return agentEntityId, suitId
	end
	self.midToReader[68337601] = function(reader)
		local raidInstanceId = reader:ReadUInt64()
		local isWin = reader:ReadBoolean()
		local battleData = Base.ReadComplex(reader, Auto.Reader[114])
		local closeTime = reader:ReadUInt32()

		return raidInstanceId, isWin, battleData, closeTime
	end
	self.midToReader[68338125] = function(reader)
		local zoneInfo = Auto.Dispatch[115](reader)

		return zoneInfo
	end
	self.midToReader[68340587] = function(reader)
		local data = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[116])
		end)

		return data
	end
	self.midToReader[68343773] = function(reader)
		return
	end
	self.midToReader[68344409] = function(reader)
		local pid = reader:ReadUInt64()
		local begging = reader:ReadBoolean()

		return pid, begging
	end
	self.midToReader[68348957] = function(reader)
		local entityIds = Base.ReadList(reader, function(r)
			return r:ReadUInt64()
		end)

		return entityIds
	end
	self.midToReader[68358254] = function(reader)
		local vehicleInstanceId = reader:ReadUInt64()

		return vehicleInstanceId
	end
	self.midToReader[68360886] = function(reader)
		local uId = reader:ReadUInt64()
		local state = reader:ReadByte()

		return uId, state
	end
	self.midToReader[68362490] = function(reader)
		local sceneRoomId = reader:ReadInt32()
		local enabled = reader:ReadBoolean()
		local taskId = reader:ReadUInt32()

		return sceneRoomId, enabled, taskId
	end
	self.midToReader[68371219] = function(reader)
		return
	end
	self.midToReader[68373762] = function(reader)
		local data = Base.ReadComplex(reader, Auto.Reader[0])

		return data
	end
	self.midToReader[68386224] = function(reader)
		local entityId = reader:ReadUInt64()
		local destroyType = reader:ReadByte()
		local distance = reader:ReadInt32()
		local dynamicGoId = reader:ReadInt32()

		return entityId, destroyType, distance, dynamicGoId
	end
	self.midToReader[68396726] = function(reader)
		local spiritWeaponDetail = Base.ReadComplex(reader, Auto.Reader[117])

		return spiritWeaponDetail
	end
	self.midToReader[68399010] = function(reader)
		local weaponId = reader:ReadUInt64()
		local durability = reader:ReadInt32()
		local magazineAmmo = reader:ReadInt32()

		return weaponId, durability, magazineAmmo
	end
	self.midToReader[68400584] = function(reader)
		local actionType = reader:ReadInt32()
		local timelineType = reader:ReadInt32()

		return actionType, timelineType
	end
	self.midToReader[68403895] = function(reader)
		local b = reader:ReadBoolean()

		return b
	end
	self.midToReader[68407238] = function(reader)
		local entityId = reader:ReadUInt64()
		local position = Base.ReadStruct(reader, Auto.Reader.UXVector3)
		local moveTime = reader:ReadSingle()
		local height = reader:ReadSingle()
		local isTransfer = reader:ReadBoolean()
		local skillId = reader:ReadUInt32()
		local triggerRoom = reader:ReadBoolean()
		local moveId = reader:ReadInt32()
		local spoonTriggerRoom = reader:ReadBoolean()

		return entityId, position, moveTime, height, isTransfer, skillId, triggerRoom, moveId, spoonTriggerRoom
	end
	self.midToReader[68409127] = function(reader)
		local OxygenValue = reader:ReadSingle()

		return OxygenValue
	end
	self.midToReader[68410301] = function(reader)
		local spiritId = reader:ReadUInt64()
		local skillId = reader:ReadUInt32()
		local chargeData = Base.ReadComplex(reader, Auto.Reader[118])

		return spiritId, skillId, chargeData
	end
	self.midToReader[68412028] = function(reader)
		local spiritUpdateWeaponAction = Base.ReadComplex(reader, Auto.Reader[119])

		return spiritUpdateWeaponAction
	end
	self.midToReader[68420021] = function(reader)
		local locationId = reader:ReadUInt32()
		local movieId = reader:ReadUInt32()

		return locationId, movieId
	end
	self.midToReader[68424308] = function(reader)
		local pid = reader:ReadUInt64()
		local actionGroupId = reader:ReadUInt32()

		return pid, actionGroupId
	end
	self.midToReader[68427090] = function(reader)
		local weaponId = reader:ReadUInt64()
		local sceneItemHp = reader:ReadSingle()

		return weaponId, sceneItemHp
	end
	self.midToReader[68428388] = function(reader)
		local withoutDefaultTimeline = reader:ReadBoolean()
		local replaceTimelineName = reader:ReadString()

		return withoutDefaultTimeline, replaceTimelineName
	end
	self.midToReader[68434846] = function(reader)
		local id = reader:ReadUInt64()
		local abilityId = reader:ReadUInt32()
		local value = reader:ReadSingle()

		return id, abilityId, value
	end
	self.midToReader[68442298] = function(reader)
		local me = Base.ReadComplex(reader, Auto.Reader[120])
		local other = Base.ReadComplex(reader, Auto.Reader[120])

		return me, other
	end
	self.midToReader[68443971] = function(reader)
		return
	end
	self.midToReader[68444149] = function(reader)
		local id = reader:ReadUInt64()
		local flag = reader:ReadBoolean()

		return id, flag
	end
	self.midToReader[68455575] = function(reader)
		local id = reader:ReadUInt64()
		local templateId = reader:ReadUInt32()
		local position = Base.ReadStruct(reader, Auto.Reader.UXVector3)
		local angle = reader:ReadSingle()
		local duration = reader:ReadSingle()
		local level = reader:ReadUInt32()

		return id, templateId, position, angle, duration, level
	end
	self.midToReader[68459161] = function(reader)
		local soundTriggerTiming = reader:ReadByte()
		local nodeId = reader:ReadInt32()

		return soundTriggerTiming, nodeId
	end
	self.midToReader[68468724] = function(reader)
		local id = reader:ReadUInt64()
		local gadgetId = reader:ReadUInt64()
		local bindId = reader:ReadInt32()
		local interactActionType = reader:ReadInt32()
		local index = reader:ReadInt32()
		local dynamicBindItem = reader:ReadInt32()
		local startTime = reader:ReadUInt32()
		local delayTime = reader:ReadSingle()

		return id, gadgetId, bindId, interactActionType, index, dynamicBindItem, startTime, delayTime
	end
	self.midToReader[68470909] = function(reader)
		local id = reader:ReadUInt64()

		return id
	end
	self.midToReader[68476812] = function(reader)
		return
	end
	self.midToReader[68484003] = function(reader)
		local creationId = reader:ReadUInt64()
		local position = Base.ReadStruct(reader, Auto.Reader.UXVector3)
		local rotation = Base.ReadStruct(reader, Auto.Reader.UXVector3)

		return creationId, position, rotation
	end
	self.midToReader[68486027] = function(reader)
		local leftEnemyCount = reader:ReadInt32()
		local totalEnemyCount = reader:ReadInt32()
		local leftTime = reader:ReadDouble()
		local totalTime = reader:ReadDouble()
		local currWave = reader:ReadUInt32()
		local totalWave = reader:ReadUInt32()
		local refreshTime = reader:ReadBoolean()

		return leftEnemyCount, totalEnemyCount, leftTime, totalTime, currWave, totalWave, refreshTime
	end
	self.midToReader[68495892] = function(reader)
		local agentEntityId = reader:ReadUInt64()

		return agentEntityId
	end
	self.midToReader[68501444] = function(reader)
		local id = reader:ReadUInt64()
		local spawnInfoScareNpcRadius = reader:ReadSingle()
		local surroundNpcRadius = reader:ReadSingle()
		local add = reader:ReadBoolean()

		return id, spawnInfoScareNpcRadius, surroundNpcRadius, add
	end
	self.midToReader[68512183] = function(reader)
		local groupId = reader:ReadInt32()
		local campId = reader:ReadUInt32()
		local first = reader:ReadBoolean()
		local enemyInstanceIds = Base.ReadList(reader, function(r)
			return r:ReadUInt64()
		end)

		return groupId, campId, first, enemyInstanceIds
	end
	self.midToReader[68517259] = function(reader)
		local result = reader:ReadByte()
		local bonus = Base.ReadComplex(reader, Auto.Reader[121])
		local timeToStartNextRound = reader:ReadDouble()

		return result, bonus, timeToStartNextRound
	end
	self.midToReader[68520603] = function(reader)
		local isOpen = reader:ReadBoolean()

		return isOpen
	end
	self.midToReader[68521147] = function(reader)
		local vehicleInstanceId = reader:ReadUInt64()
		local trackable = reader:ReadBoolean()

		return vehicleInstanceId, trackable
	end
	self.midToReader[68522658] = function(reader)
		local agentEntityId = reader:ReadUInt64()
		local data = Base.ReadComplex(reader, Auto.Reader[122])

		return agentEntityId, data
	end
	self.midToReader[68528392] = function(reader)
		local type = reader:ReadByte()

		return type
	end
	self.midToReader[68530387] = function(reader)
		local uId = reader:ReadUInt64()
		local scoreInfo = Base.ReadComplex(reader, Auto.Reader[123])

		return uId, scoreInfo
	end
	self.midToReader[68541988] = function(reader)
		local entityId = reader:ReadUInt64()
		local datas = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[124])
		end)
		local isNew = reader:ReadBoolean()

		return entityId, datas, isNew
	end
	self.midToReader[68549473] = function(reader)
		return
	end
	self.midToReader[68552624] = function(reader)
		local money = reader:ReadUInt32()

		return money
	end
	self.midToReader[68554392] = function(reader)
		local raidInstanceId = reader:ReadUInt64()
		local state = reader:ReadByte()

		return raidInstanceId, state
	end
	self.midToReader[68562258] = function(reader)
		local enemyId = reader:ReadUInt64()
		local skillId = reader:ReadUInt32()

		return enemyId, skillId
	end
	self.midToReader[68562967] = function(reader)
		local isMultiplayer = reader:ReadBoolean()

		return isMultiplayer
	end
	self.midToReader[68563222] = function(reader)
		local enemyIds = Base.ReadList(reader, function(r)
			return r:ReadUInt64()
		end)

		return enemyIds
	end
	self.midToReader[68566635] = function(reader)
		return
	end
	self.midToReader[68569246] = function(reader)
		local metroInfos = Base.ReadList(reader, function(r)
			return r:ReadInt32()
		end)

		return metroInfos
	end
	self.midToReader[68576087] = function(reader)
		local rider = reader:ReadUInt64()
		local ridee = reader:ReadUInt64()
		local hasRideOn = reader:ReadBoolean()

		return rider, ridee, hasRideOn
	end
	self.midToReader[68597805] = function(reader)
		local raidGamePlayInfo = Base.ReadComplex(reader, Auto.Reader[125])

		return raidGamePlayInfo
	end
	self.midToReader[68598465] = function(reader)
		local dict = Base.ReadDict(reader, function(r)
			return r:ReadInt32()
		end, function(r)
			return Base.ReadComplex(r, Auto.Reader[126])
		end)

		return dict
	end
	self.midToReader[68600791] = function(reader)
		local entityId = reader:ReadUInt64()
		local targetId = reader:ReadUInt64()

		return entityId, targetId
	end
	self.midToReader[68601034] = function(reader)
		local templateCallId = reader:ReadUInt32()

		return templateCallId
	end
	self.midToReader[68617753] = function(reader)
		local pid = reader:ReadUInt64()
		local uid = reader:ReadInt32()
		local add = reader:ReadBoolean()
		local distance = reader:ReadSingle()

		return pid, uid, add, distance
	end
	self.midToReader[68619076] = function(reader)
		local fightPokemons = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[127])
		end)
		local remainTime = reader:ReadDouble()
		local opponentPokemons = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[127])
		end)

		return fightPokemons, remainTime, opponentPokemons
	end
	self.midToReader[68633332] = function(reader)
		local agentEntityId = reader:ReadUInt64()

		return agentEntityId
	end
	self.midToReader[68634743] = function(reader)
		local flowId = reader:ReadInt32()
		local nodeId = reader:ReadInt32()
		local ports = Base.ReadList(reader, Auto.Dispatch[112])
		local taskInfo = Base.ReadComplex(reader, Auto.Reader[113])

		return flowId, nodeId, ports, taskInfo
	end
	self.midToReader[68635525] = function(reader)
		local enemyInstanceId = reader:ReadUInt64()
		local bindItemsIndex = reader:ReadInt32()
		local itemRotation = Base.ReadStruct(reader, Auto.Reader.UXVector3)
		local position = Base.ReadStruct(reader, Auto.Reader.UXVector3)

		return enemyInstanceId, bindItemsIndex, itemRotation, position
	end
	self.midToReader[68635825] = function(reader)
		local entityId = reader:ReadUInt64()
		local targetId = reader:ReadUInt64()
		local unitPartIndex = reader:ReadInt32()
		local targetDestructibleId = reader:ReadUInt64()
		local skillId = reader:ReadUInt32()
		local facing = reader:ReadSingle()
		local unitPosition = Base.ReadStruct(reader, Auto.Reader.UXVector3)
		local location = Base.ReadStruct(reader, Auto.Reader.UXVector3)
		local SectionRepeatTimes = reader:ReadUInt32()
		local SeqConfigID = reader:ReadUInt32()

		return entityId, targetId, unitPartIndex, targetDestructibleId, skillId, facing, unitPosition, location, SectionRepeatTimes, SeqConfigID
	end
	self.midToReader[68636622] = function(reader)
		return
	end
	self.midToReader[68637427] = function(reader)
		local taskId = reader:ReadUInt32()

		return taskId
	end
	self.midToReader[68647080] = function(reader)
		local type = reader:ReadByte()
		local voteSessionId = reader:ReadUInt64()
		local pid = reader:ReadUInt64()
		local vote = Base.ReadList(reader, function(r)
			return r:ReadUInt32()
		end)

		return type, voteSessionId, pid, vote
	end
	self.midToReader[68648870] = function(reader)
		local targetCounter = Base.ReadDict(reader, function(r)
			return r:ReadUInt32()
		end, function(r)
			return r:ReadInt32()
		end)

		return targetCounter
	end
	self.midToReader[68649557] = function(reader)
		local id = reader:ReadUInt64()
		local abilities = Base.ReadDict(reader, function(r)
			return r:ReadUInt32()
		end, function(r)
			return r:ReadSingle()
		end)

		return id, abilities
	end
	self.midToReader[68649704] = function(reader)
		local vehicleInstanceId = reader:ReadUInt64()
		local interactable = reader:ReadBoolean()

		return vehicleInstanceId, interactable
	end
	self.midToReader[68655602] = function(reader)
		local spiritId = reader:ReadUInt64()
		local agentEntityId = reader:ReadUInt64()
		local enterOrLeave = reader:ReadBoolean()
		local reason = reader:ReadByte()

		return spiritId, agentEntityId, enterOrLeave, reason
	end
	self.midToReader[68664767] = function(reader)
		local type = reader:ReadByte()
		local id = reader:ReadUInt64()
		local signalName = reader:ReadString()

		return type, id, signalName
	end
	self.midToReader[68666356] = function(reader)
		local enemyId = reader:ReadUInt64()

		return enemyId
	end
	self.midToReader[68685284] = function(reader)
		local creationInfo = Base.ReadStruct(reader, Auto.Reader[128])

		return creationInfo
	end
	self.midToReader[68686565] = function(reader)
		local entityId = reader:ReadUInt64()
		local spiritId = reader:ReadUInt32()
		local spiritWearFashionsInfo = Base.ReadComplex(reader, Auto.Reader[129])

		return entityId, spiritId, spiritWearFashionsInfo
	end
	self.midToReader[68689379] = function(reader)
		local id = reader:ReadUInt64()
		local ratio = reader:ReadSingle()

		return id, ratio
	end
	self.midToReader[68691394] = function(reader)
		local agentEntityId = reader:ReadUInt64()
		local disease = reader:ReadUInt32()

		return agentEntityId, disease
	end
	self.midToReader[68693900] = function(reader)
		local messageId = reader:ReadUInt32()
		local tipType = reader:ReadInt32()
		local infos = Base.ReadList(reader, function(r)
			return r:ReadString()
		end)
		local taskId = reader:ReadUInt32()

		return messageId, tipType, infos, taskId
	end
	self.midToReader[68699731] = function(reader)
		local closeTime = reader:ReadUInt32()

		return closeTime
	end
	self.midToReader[68703022] = function(reader)
		local gameMode = reader:ReadByte()
		local result = reader:ReadByte()
		local reward = Base.ReadComplex(reader, Auto.Reader[45])

		return gameMode, result, reward
	end
	self.midToReader[68707179] = function(reader)
		local syncData = Base.ReadComplex(reader, Auto.Reader[100])

		return syncData
	end
	self.midToReader[68708402] = function(reader)
		local memberInfos = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[130])
		end)

		return memberInfos
	end
	self.midToReader[68710886] = function(reader)
		local agentEntityId = reader:ReadUInt64()
		local isRed = reader:ReadBoolean()

		return agentEntityId, isRed
	end
	self.midToReader[68725832] = function(reader)
		local entityId = reader:ReadUInt64()
		local data = Base.ReadComplex(reader, Auto.Reader[124])

		return entityId, data
	end
	self.midToReader[68735163] = function(reader)
		local destructibleId = reader:ReadUInt64()
		local data = Base.ReadComplex(reader, Auto.Reader[131])

		return destructibleId, data
	end
	self.midToReader[68742819] = function(reader)
		local info = Base.ReadComplex(reader, Auto.Reader[132])

		return info
	end
	self.midToReader[68753590] = function(reader)
		local spiritSwitchWeaponDetail = Base.ReadComplex(reader, Auto.Reader[133])

		return spiritSwitchWeaponDetail
	end
	self.midToReader[68757592] = function(reader)
		local spiritId = reader:ReadUInt64()
		local allSkillChargeData = Base.ReadDict(reader, function(r)
			return r:ReadUInt32()
		end, function(r)
			return Base.ReadComplex(r, Auto.Reader[118])
		end)

		return spiritId, allSkillChargeData
	end
	self.midToReader[68760171] = function(reader)
		local id = reader:ReadUInt64()
		local luaSlotId = reader:ReadUInt64()
		local bindRefName = reader:ReadString()
		local isInit = reader:ReadBoolean()

		return id, luaSlotId, bindRefName, isInit
	end
	self.midToReader[68763420] = function(reader)
		local enemyInstanceId = reader:ReadUInt64()
		local dropDatas = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[134])
		end)

		return enemyInstanceId, dropDatas
	end
	self.midToReader[68768659] = function(reader)
		local messageId = reader:ReadUInt32()
		local args = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[135])
		end)

		return messageId, args
	end
	self.midToReader[68772022] = function(reader)
		local vehicleUId = reader:ReadUInt64()
		local add = reader:ReadBoolean()

		return vehicleUId, add
	end
	self.midToReader[68785775] = function(reader)
		return
	end
	self.midToReader[68792735] = function(reader)
		local id = reader:ReadUInt64()
		local stealth = reader:ReadUInt32()

		return id, stealth
	end
	self.midToReader[68797557] = function(reader)
		local spoonId = reader:ReadInt32()
		local taskId = reader:ReadUInt32()

		return spoonId, taskId
	end
	self.midToReader[68800226] = function(reader)
		local info = Base.ReadComplex(reader, Auto.Reader[136])

		return info
	end
	self.midToReader[68801428] = function(reader)
		local pid = reader:ReadUInt64()
		local id = reader:ReadUInt64()

		return pid, id
	end
	self.midToReader[68810296] = function(reader)
		local weatherTypeId = reader:ReadUInt32()
		local nextWeatherTypeId = reader:ReadUInt32()
		local transitionSecond = reader:ReadUInt32()

		return weatherTypeId, nextWeatherTypeId, transitionSecond
	end
	self.midToReader[68810561] = function(reader)
		local hurterId = reader:ReadUInt64()
		local attackerId = reader:ReadUInt64()
		local hurtId = reader:ReadUInt32()
		local skillId = reader:ReadUInt32()
		local hurtEffectFacePos = Base.ReadStruct(reader, Auto.Reader.UXVector3)

		return hurterId, attackerId, hurtId, skillId, hurtEffectFacePos
	end
	self.midToReader[68811086] = function(reader)
		local groupId = reader:ReadInt32()
		local campId = reader:ReadUInt32()
		local last = reader:ReadBoolean()
		local rebornTime = reader:ReadUInt32()
		local banned = reader:ReadBoolean()

		return groupId, campId, last, rebornTime, banned
	end
	self.midToReader[68814135] = function(reader)
		local uId = reader:ReadUInt64()
		local currentRound = reader:ReadUInt32()
		local currentTurn = reader:ReadInt32()

		return uId, currentRound, currentTurn
	end
	self.midToReader[68817037] = function(reader)
		local battleEntityId = reader:ReadUInt64()
		local element = reader:ReadUInt32()
		local value = reader:ReadSingle()

		return battleEntityId, element, value
	end
	self.midToReader[68822468] = function(reader)
		local pid = reader:ReadUInt64()
		local name = reader:ReadString()
		local position = Base.ReadStruct(reader, Auto.Reader.UXVector3)
		local facing = reader:ReadSingle()
		local raidId = reader:ReadUInt32()

		return pid, name, position, facing, raidId
	end
	self.midToReader[68824345] = function(reader)
		local entityId = reader:ReadUInt64()

		return entityId
	end
	self.midToReader[68828543] = function(reader)
		local chaosBuffId = reader:ReadUInt32()
		local level = reader:ReadUInt32()

		return chaosBuffId, level
	end
	self.midToReader[68831898] = function(reader)
		local vehicleEntityId = reader:ReadUInt64()
		local newControllerPid = reader:ReadUInt64()

		return vehicleEntityId, newControllerPid
	end
	self.midToReader[68850332] = function(reader)
		local progressId = reader:ReadUInt32()
		local startTime = reader:ReadUInt32()
		local startLength = reader:ReadUInt32()
		local totalLength = reader:ReadUInt32()
		local speed = reader:ReadInt32()

		return progressId, startTime, startLength, totalLength, speed
	end
	self.midToReader[68852690] = function(reader)
		local id = reader:ReadUInt64()

		return id
	end
	self.midToReader[68854930] = function(reader)
		local recordId = reader:ReadUInt32()
		local paramId = reader:ReadUInt32()
		local value = reader:ReadDouble()

		return recordId, paramId, value
	end
	self.midToReader[68856167] = function(reader)
		local fightingPokemons = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[127])
		end)

		return fightingPokemons
	end
	self.midToReader[68857464] = function(reader)
		local entityId = reader:ReadUInt64()
		local hp = reader:ReadSingle()

		return entityId, hp
	end
	self.midToReader[68858287] = function(reader)
		local vehicleUId = reader:ReadUInt64()

		return vehicleUId
	end
	self.midToReader[68866576] = function(reader)
		local round = reader:ReadUInt32()
		local remainTime = reader:ReadDouble()

		return round, remainTime
	end
	self.midToReader[68871637] = function(reader)
		local spoonViewInfo = Base.ReadComplex(reader, Auto.Reader[137])
		local roomId = reader:ReadInt32()

		return spoonViewInfo, roomId
	end
	self.midToReader[68882990] = function(reader)
		local data = Base.ReadComplex(reader, Auto.Reader[138])

		return data
	end
	self.midToReader[68884830] = function(reader)
		local uId = reader:ReadUInt64()
		local scoreInfo = Base.ReadComplex(reader, Auto.Reader[139])

		return uId, scoreInfo
	end
	self.midToReader[68890464] = function(reader)
		local uid = reader:ReadUInt64()
		local isGive = reader:ReadBoolean()

		return uid, isGive
	end
	self.midToReader[68897900] = function(reader)
		local spiritId = reader:ReadUInt64()
		local agentEntityId = reader:ReadUInt32()
		local time = reader:ReadDouble()

		return spiritId, agentEntityId, time
	end
	self.midToReader[68901239] = function(reader)
		local spoonViewInfo = Base.ReadComplex(reader, Auto.Reader[137])
		local roomId = reader:ReadInt32()

		return spoonViewInfo, roomId
	end
	self.midToReader[68901656] = function(reader)
		local entityId = reader:ReadUInt64()

		return entityId
	end
	self.midToReader[68913837] = function(reader)
		local pid = reader:ReadUInt64()
		local vehicleEntityId = reader:ReadUInt64()
		local vehicleTemplateId = reader:ReadUInt32()
		local seatIndex = reader:ReadInt32()

		return pid, vehicleEntityId, vehicleTemplateId, seatIndex
	end
	self.midToReader[68916669] = function(reader)
		local mobilePlatformId = reader:ReadUInt64()
		local mobilePlatformInfo = Base.ReadComplex(reader, Auto.Reader[140])

		return mobilePlatformId, mobilePlatformInfo
	end
	self.midToReader[68927002] = function(reader)
		local countDownType = reader:ReadByte()
		local countDownTime = reader:ReadSingle()
		local textId = reader:ReadUInt32()

		return countDownType, countDownTime, textId
	end
	self.midToReader[68929580] = function(reader)
		local entityId = reader:ReadUInt64()
		local buffViewData = Base.ReadStruct(reader, Auto.Reader[111])

		return entityId, buffViewData
	end
	self.midToReader[68939905] = function(reader)
		local targetId = reader:ReadUInt32()
		local count = reader:ReadInt32()

		return targetId, count
	end
	self.midToReader[68949162] = function(reader)
		local ids = Base.ReadList(reader, function(r)
			return r:ReadUInt64()
		end)

		return ids
	end
	self.midToReader[68962729] = function(reader)
		local spiritId = reader:ReadUInt64()
		local agentEntityId = reader:ReadUInt64()

		return spiritId, agentEntityId
	end
	self.midToReader[68969986] = function(reader)
		local id = reader:ReadUInt64()
		local isDisarmed = reader:ReadBoolean()

		return id, isDisarmed
	end
	self.midToReader[68973352] = function(reader)
		local pid = reader:ReadUInt64()
		local vehicleId = reader:ReadUInt64()
		local add = reader:ReadBoolean()
		local distances = Base.ReadList(reader, function(r)
			return r:ReadInt32()
		end)
		local isAwayOrApproach = reader:ReadBoolean()

		return pid, vehicleId, add, distances, isAwayOrApproach
	end
	self.midToReader[68974077] = function(reader)
		local entityId = reader:ReadUInt64()
		local buffList = Base.ReadList(reader, function(r)
			return Base.ReadStruct(r, Auto.Reader[111])
		end)

		return entityId, buffList
	end
	self.midToReader[68976401] = function(reader)
		local unitId = reader:ReadUInt64()
		local effectId = reader:ReadUInt32()
		local instanceId = reader:ReadUInt64()

		return unitId, effectId, instanceId
	end
	self.midToReader[68982002] = function(reader)
		local spiritId = reader:ReadUInt64()

		return spiritId
	end
	self.midToReader[68984310] = function(reader)
		local templateCallId = reader:ReadUInt32()
		local hide = reader:ReadBoolean()

		return templateCallId, hide
	end
	self.midToReader[68987100] = function(reader)
		local me = Base.ReadComplex(reader, Auto.Reader[141])
		local other = Base.ReadComplex(reader, Auto.Reader[141])

		return me, other
	end
	self.midToReader[68988337] = function(reader)
		local enemyInstanceId = reader:ReadUInt64()
		local bindItemsIndex = reader:ReadInt32()

		return enemyInstanceId, bindItemsIndex
	end
	self.midToReader[68988971] = function(reader)
		local start = reader:ReadBoolean()
		local info = Base.ReadComplex(reader, Auto.Reader[142])

		return start, info
	end
	self.midToReader[68996280] = function(reader)
		local type = reader:ReadByte()
		local voteSessionId = reader:ReadUInt64()

		return type, voteSessionId
	end
	self.midToReader[68997755] = function(reader)
		local metroInfos = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[143])
		end)

		return metroInfos
	end
	self.midToReader[115181177] = function(reader)
		local inGame = reader:ReadBoolean()
		local isOnLogin = reader:ReadBoolean()
		local roomType = reader:ReadByte()

		return inGame, isOnLogin, roomType
	end
	self.midToReader[115954489] = function(reader)
		local data = Base.ReadComplex(reader, Auto.Reader[0])

		return data
	end
	self.midToReader[116020736] = function(reader)
		local seatId = reader:ReadInt32()
		local score = reader:ReadInt32()
		local change = reader:ReadInt32()

		return seatId, score, change
	end
	self.midToReader[116020751] = function(reader)
		local seatIndex = reader:ReadInt32()

		return seatIndex
	end
	self.midToReader[116038644] = function(reader)
		local ques = Base.ReadList(reader, function(r)
			return r:ReadByte()
		end)

		return ques
	end
	self.midToReader[116039195] = function(reader)
		local seatIndex = reader:ReadInt32()
		local cnt = reader:ReadInt32()

		return seatIndex, cnt
	end
	self.midToReader[116131924] = function(reader)
		local seats = Base.ReadList(reader, function(r)
			return r:ReadInt32()
		end)

		return seats
	end
	self.midToReader[116141795] = function(reader)
		local roomInfo = Base.ReadComplex(reader, Auto.Reader[144])

		return roomInfo
	end
	self.midToReader[116178909] = function(reader)
		local seatSeatIndex = reader:ReadInt32()
		local pai = Base.ReadStruct(reader, Auto.Reader[145])
		local selectPais = Base.ReadList(reader, function(r)
			return Base.ReadStruct(r, Auto.Reader[145])
		end)

		return seatSeatIndex, pai, selectPais
	end
	self.midToReader[116219373] = function(reader)
		local result = Base.ReadComplex(reader, Auto.Reader[146])

		return result
	end
	self.midToReader[116267748] = function(reader)
		local seatId = reader:ReadInt32()
		local holds = Base.ReadList(reader, function(r)
			return Base.ReadStruct(r, Auto.Reader[145])
		end)
		local huanPais = Base.ReadList(reader, function(r)
			return Base.ReadStruct(r, Auto.Reader[145])
		end)
		local method = reader:ReadInt32()

		return seatId, holds, huanPais, method
	end
	self.midToReader[116271245] = function(reader)
		local seatIndex = reader:ReadInt32()
		local pai = Base.ReadStruct(reader, Auto.Reader[145])
		local remainders = reader:ReadInt32()

		return seatIndex, pai, remainders
	end
	self.midToReader[116325366] = function(reader)
		local seat = reader:ReadInt32()

		return seat
	end
	self.midToReader[116330964] = function(reader)
		local pid = reader:ReadUInt64()

		return pid
	end
	self.midToReader[116379388] = function(reader)
		local huanPais = Base.ReadList(reader, function(r)
			return Base.ReadStruct(r, Auto.Reader[145])
		end)
		local seatIndex = reader:ReadInt32()

		return huanPais, seatIndex
	end
	self.midToReader[116465447] = function(reader)
		local defaultPais = Base.ReadList(reader, function(r)
			return Base.ReadStruct(r, Auto.Reader[145])
		end)
		local elapsedTime = reader:ReadSingle()

		return defaultPais, elapsedTime
	end
	self.midToReader[116488792] = function(reader)
		local seatId = reader:ReadInt32()
		local elapsedTime = reader:ReadSingle()

		return seatId, elapsedTime
	end
	self.midToReader[116511754] = function(reader)
		local seatIndex = reader:ReadInt32()
		local chatType = reader:ReadByte()
		local dialogId = reader:ReadUInt32()

		return seatIndex, chatType, dialogId
	end
	self.midToReader[116531392] = function(reader)
		local seatId = reader:ReadInt32()
		local pai = Base.ReadStruct(reader, Auto.Reader[145])
		local reach = reader:ReadBoolean()

		return seatId, pai, reach
	end
	self.midToReader[116574305] = function(reader)
		local seatIndex = reader:ReadInt32()

		return seatIndex
	end
	self.midToReader[116592712] = function(reader)
		local seats = Base.ReadList(reader, function(r)
			return r:ReadInt32()
		end)
		local pai = Base.ReadStruct(reader, Auto.Reader[145])

		return seats, pai
	end
	self.midToReader[116595985] = function(reader)
		local seatSeatIndex = reader:ReadInt32()
		local pai = Base.ReadStruct(reader, Auto.Reader[145])
		local selectPais = Base.ReadList(reader, function(r)
			return Base.ReadStruct(r, Auto.Reader[145])
		end)

		return seatSeatIndex, pai, selectPais
	end
	self.midToReader[116622906] = function(reader)
		local action = Base.ReadComplex(reader, Auto.Reader[147])
		local elapsedTime = reader:ReadSingle()

		return action, elapsedTime
	end
	self.midToReader[116645377] = function(reader)
		local gameInfo = Base.ReadComplex(reader, Auto.Reader[148])
		local elapsedTime = reader:ReadSingle()

		return gameInfo, elapsedTime
	end
	self.midToReader[116653059] = function(reader)
		local chatType = reader:ReadByte()
		local seatIndex = reader:ReadInt32()
		local msgId = reader:ReadInt32()

		return chatType, seatIndex, msgId
	end
	self.midToReader[116688453] = function(reader)
		local info = Base.ReadComplex(reader, Auto.Reader[149])

		return info
	end
	self.midToReader[116696426] = function(reader)
		local state = reader:ReadByte()

		return state
	end
	self.midToReader[116699472] = function(reader)
		local seatId = reader:ReadInt32()
		local pai = Base.ReadStruct(reader, Auto.Reader[145])
		local type = reader:ReadByte()

		return seatId, pai, type
	end
	self.midToReader[116713715] = function(reader)
		return
	end
	self.midToReader[116751448] = function(reader)
		local seatIndex = reader:ReadInt32()
		local pai = Base.ReadStruct(reader, Auto.Reader[145])
		local type = reader:ReadByte()

		return seatIndex, pai, type
	end
	self.midToReader[116832472] = function(reader)
		local chuPai = Base.ReadStruct(reader, Auto.Reader[145])

		return chuPai
	end
	self.midToReader[116880436] = function(reader)
		local defaultQue = reader:ReadByte()
		local elapsedTime = reader:ReadSingle()

		return defaultQue, elapsedTime
	end
	self.midToReader[116906903] = function(reader)
		local seats = Base.ReadList(reader, function(r)
			return r:ReadInt32()
		end)

		return seats
	end
	self.midToReader[116973121] = function(reader)
		local seats = Base.ReadList(reader, function(r)
			return r:ReadInt32()
		end)

		return seats
	end
	self.midToReader[116981800] = function(reader)
		return
	end
	self.midToReader[116993058] = function(reader)
		local data = Base.ReadComplex(reader, Auto.Reader[0])

		return data
	end
	self.midToReader[116998071] = function(reader)
		local holds = Base.ReadList(reader, function(r)
			return Base.ReadStruct(r, Auto.Reader[145])
		end)
		local holdsCount = reader:ReadInt32()
		local seatIndex = reader:ReadInt32()

		return holds, holdsCount, seatIndex
	end
	self.midToReader[124664788] = function(reader)
		local data = Base.ReadComplex(reader, Auto.Reader[0])

		return data
	end
	self.midToReader[127255686] = function(reader)
		local data = Base.ReadComplex(reader, Auto.Reader[0])

		return data
	end
	self.midToReader[128098486] = function(reader)
		local data = Base.ReadComplex(reader, Auto.Reader[0])

		return data
	end
	self.midToReader[128109600] = function(reader)
		local log = reader:ReadString()

		return log
	end
	self.midToReader[128248079] = function(reader)
		local groupId = reader:ReadUInt64()
		local name = reader:ReadString()

		return groupId, name
	end
	self.midToReader[128294697] = function(reader)
		local friendId = reader:ReadUInt64()
		local groupId = reader:ReadUInt64()

		return friendId, groupId
	end
	self.midToReader[128303615] = function(reader)
		local groupId = reader:ReadUInt64()

		return groupId
	end
	self.midToReader[128312985] = function(reader)
		local simpleData = Base.ReadComplex(reader, Auto.Reader[150])

		return simpleData
	end
	self.midToReader[128503247] = function(reader)
		local endTime = reader:ReadUInt32()

		return endTime
	end
	self.midToReader[128520616] = function(reader)
		local groupId = reader:ReadUInt64()
		local memberPid = reader:ReadUInt64()

		return groupId, memberPid
	end
	self.midToReader[128563852] = function(reader)
		local mailId = reader:ReadUInt64()

		return mailId
	end
	self.midToReader[128565833] = function(reader)
		local invitee = reader:ReadUInt64()
		local groupId = reader:ReadUInt64()

		return invitee, groupId
	end
	self.midToReader[128584754] = function(reader)
		local head = Base.ReadComplex(reader, Auto.Reader[151])

		return head
	end
	self.midToReader[128663439] = function(reader)
		local chatGroup = Base.ReadComplex(reader, Auto.Reader[152])

		return chatGroup
	end
	self.midToReader[128678442] = function(reader)
		local message = reader:ReadString()

		return message
	end
	self.midToReader[128691656] = function(reader)
		local pid = reader:ReadUInt64()
		local oldLevel = reader:ReadUInt32()
		local newLevel = reader:ReadUInt32()

		return pid, oldLevel, newLevel
	end
	self.midToReader[128768338] = function(reader)
		local endTime = reader:ReadUInt32()

		return endTime
	end
	self.midToReader[128873895] = function(reader)
		local inviter = reader:ReadUInt64()
		local groupId = reader:ReadUInt64()
		local groupName = reader:ReadString()

		return inviter, groupId, groupName
	end
	self.midToReader[128901894] = function(reader)
		local message = reader:ReadString()

		return message
	end
	self.midToReader[154006932] = function(reader)
		local expireTime = reader:ReadUInt32()
		local reason = reader:ReadString()
		local reasonId = reader:ReadUInt32()
		local pid = reader:ReadUInt64()

		return expireTime, reason, reasonId, pid
	end
	self.midToReader[154349060] = function(reader)
		return
	end
	self.midToReader[154595756] = function(reader)
		local data = Base.ReadComplex(reader, Auto.Reader[0])

		return data
	end
	self.midToReader[154989241] = function(reader)
		local msgId = reader:ReadUInt32()
		local pid = reader:ReadUInt64()

		return msgId, pid
	end
	self.midToReader[203023320] = function(reader)
		local room = Base.ReadComplex(reader, Auto.Reader[15])

		return room
	end
	self.midToReader[203051678] = function(reader)
		local swapInfo = Base.ReadComplex(reader, Auto.Reader[153])

		return swapInfo
	end
	self.midToReader[203140608] = function(reader)
		local swapInfo = Base.ReadComplex(reader, Auto.Reader[153])

		return swapInfo
	end
	self.midToReader[203302854] = function(reader)
		local room = Base.ReadComplex(reader, Auto.Reader[15])
		local gameStartTime = reader:ReadUInt32()

		return room, gameStartTime
	end
	self.midToReader[203319989] = function(reader)
		local room = Base.ReadComplex(reader, Auto.Reader[15])
		local isPopup = reader:ReadBoolean()

		return room, isPopup
	end
	self.midToReader[203393681] = function(reader)
		local swapInfo = Base.ReadComplex(reader, Auto.Reader[153])
		local accept = reader:ReadBoolean()

		return swapInfo, accept
	end
	self.midToReader[203438648] = function(reader)
		local room = Base.ReadComplex(reader, Auto.Reader[154])
		local memberPid = reader:ReadUInt64()

		return room, memberPid
	end
	self.midToReader[203468128] = function(reader)
		local room = Base.ReadComplex(reader, Auto.Reader[15])
		local memberPid = reader:ReadUInt64()

		return room, memberPid
	end
	self.midToReader[203587053] = function(reader)
		local room = Base.ReadComplex(reader, Auto.Reader[15])
		local memberPid = reader:ReadUInt64()
		local ready = reader:ReadBoolean()

		return room, memberPid, ready
	end
	self.midToReader[203656753] = function(reader)
		local room = Base.ReadComplex(reader, Auto.Reader[15])
		local pid = reader:ReadUInt64()
		local prepareInfo = Base.ReadComplex(reader, Auto.Reader[155])

		return room, pid, prepareInfo
	end
	self.midToReader[203660430] = function(reader)
		local room = Base.ReadComplex(reader, Auto.Reader[15])
		local pid = reader:ReadUInt64()

		return room, pid
	end
	self.midToReader[203736421] = function(reader)
		local room = Base.ReadComplex(reader, Auto.Reader[154])

		return room
	end
	self.midToReader[203788962] = function(reader)
		local room = Base.ReadComplex(reader, Auto.Reader[15])
		local pid = reader:ReadUInt64()

		return room, pid
	end
	self.midToReader[203818940] = function(reader)
		local room = Base.ReadComplex(reader, Auto.Reader[154])
		local memberPid = reader:ReadUInt64()

		return room, memberPid
	end
	self.midToReader[203832404] = function(reader)
		return
	end
	self.midToReader[203960587] = function(reader)
		local data = Base.ReadComplex(reader, Auto.Reader[0])

		return data
	end
	self.midToReader[203996390] = function(reader)
		local room = Base.ReadComplex(reader, Auto.Reader[154])

		return room
	end
	self.midToReader[203998226] = function(reader)
		local setting = Base.ReadComplex(reader, Auto.Reader[156])

		return setting
	end
	self.midToReader[204039196] = function(reader)
		local linkId = reader:ReadUInt64()
		local mode = reader:ReadByte()
		local member = Base.ReadComplex(reader, Auto.Reader[130])

		return linkId, mode, member
	end
	self.midToReader[204171545] = function(reader)
		local data = Base.ReadComplex(reader, Auto.Reader[0])

		return data
	end
	self.midToReader[204263045] = function(reader)
		local linkId = reader:ReadUInt64()
		local mode = reader:ReadByte()
		local member = Base.ReadComplex(reader, Auto.Reader[130])

		return linkId, mode, member
	end
	self.midToReader[204459497] = function(reader)
		local memberPid = reader:ReadUInt64()
		local linkMessageType = reader:ReadByte()
		local msg = reader:ReadString()

		return memberPid, linkMessageType, msg
	end
	self.midToReader[204730628] = function(reader)
		local linkId = reader:ReadUInt64()
		local mode = reader:ReadByte()
		local member = Base.ReadComplex(reader, Auto.Reader[130])

		return linkId, mode, member
	end
	self.midToReader[204826282] = function(reader)
		local deviceLevel = reader:ReadByte()

		return deviceLevel
	end
	self.midToReader[204967791] = function(reader)
		local linkId = reader:ReadUInt64()
		local mode = reader:ReadByte()
		local member = Base.ReadComplex(reader, Auto.Reader[130])

		return linkId, mode, member
	end
	self.midToName[35056687] = "SyncGameModeInfo"
	self.midToName[35058902] = "SyncLoginKick"
	self.midToName[35173411] = "SyncBannedReason"
	self.midToName[35212978] = "SyncRoleList"
	self.midToName[35689543] = "SyncLoginServerQueue"
	self.midToName[35842068] = "SendCustomHotPatchLoginToClient"
	self.midToName[45025692] = "SendCustomHotPatchMasterToClient"
	self.midToName[45328604] = "SyncNotice"
	self.midToName[45513348] = "SyncRollIntervalMessageStop"
	self.midToName[45781151] = "SyncRollIntervalMessage"
	self.midToName[53677964] = "SyncOnlineKick"
	self.midToName[53913220] = "SendCustomHotPatchGateToClient"
	self.midToName[64000570] = "SyncCityPediaCreditUpdate"
	self.midToName[64002073] = "SyncBackpackItemChanged"
	self.midToName[64009562] = "SyncSpiritPoliceJobInfo"
	self.midToName[64024664] = "SyncPlanningBoardInfo"
	self.midToName[64024863] = "SyncNpcInteractDays"
	self.midToName[64028687] = "SyncPlayerTeamSettingChange"
	self.midToName[64030205] = "SyncGoldAdd"
	self.midToName[64032762] = "SyncTruckOrdersNewDay"
	self.midToName[64043553] = "SyncPlayerTeamMemberLeave"
	self.midToName[64050603] = "SyncShowMessage"
	self.midToName[64051530] = "SyncPlayerNpcProfileTrustValueChanged"
	self.midToName[64054119] = "SyncRemoveNpcQueueEvent"
	self.midToName[64055698] = "SyncPortalItemInfo"
	self.midToName[64059110] = "SyncLinkDeviceLevel"
	self.midToName[64061100] = "SyncPlayerTeamLeaderChange"
	self.midToName[64062943] = "SyncHouseCancelParking"
	self.midToName[64066495] = "SyncRemovePokemon"
	self.midToName[64067604] = "SyncPlayerTeamInvitationApply"
	self.midToName[64074256] = "SyncTaskInviteRideNpcCultivationId"
	self.midToName[64081527] = "SyncSpiritBartenderInfo"
	self.midToName[64081924] = "SyncDropLimitInfo"
	self.midToName[64082910] = "SyncPlayerTeamMemberJoin"
	self.midToName[64084105] = "SyncHasNotEarnedAchievement"
	self.midToName[64085008] = "SyncNpcTodayEventsTriggerCount"
	self.midToName[64086058] = "SyncNpcInteractedVoice"
	self.midToName[64090638] = "SyncSpiritHackerJobInfo"
	self.midToName[64091591] = "SyncFirstEnemyKillRecord"
	self.midToName[64094083] = "SyncDiDiPromoteTask"
	self.midToName[64096144] = "SyncPlayerNpcProfileTargetFinish"
	self.midToName[64096520] = "SyncCurrentTask"
	self.midToName[64108636] = "SyncSpiritGroupChatInfos"
	self.midToName[64113875] = "SyncLinkMatchRoomPrepare"
	self.midToName[64114508] = "SyncTwitterMonitoredBehaviors"
	self.midToName[64124614] = "SyncChargeDeliveryResult"
	self.midToName[64125250] = "SyncSoundInfo"
	self.midToName[64127654] = "SyncAddFashionList"
	self.midToName[64128323] = "SyncHackerBatteryCurrentAndTotalCount"
	self.midToName[64133996] = "SyncLinkAutoRespond"
	self.midToName[64138587] = "SyncFollowTeamLeader"
	self.midToName[64141487] = "SyncUnlockBartender"
	self.midToName[64149542] = "SyncInviterReplyInvitePlayerInteractionAction"
	self.midToName[64158503] = "SyncWasherMissionResult"
	self.midToName[64177020] = "SyncDivinerAIMessage"
	self.midToName[64182413] = "SyncFurnitureInfo"
	self.midToName[64184789] = "SyncAllActivities"
	self.midToName[64190422] = "SyncUnlockSystems"
	self.midToName[64191855] = "SyncPlayerClearTodayInspireHubGameplayJoinData"
	self.midToName[64193396] = "SyncNpcChat"
	self.midToName[64196149] = "SyncNpcGiftSendAvailableCount"
	self.midToName[64203304] = "SyncPlayerAllSpirits"
	self.midToName[64206120] = "SyncSpiritJobInfo"
	self.midToName[64208235] = "SyncBattlePassTasks"
	self.midToName[64214284] = "SyncNewNpcQueueEvent"
	self.midToName[64214885] = "SyncActivateNpcCard"
	self.midToName[64227768] = "SyncTaskTitleGuideUnlock"
	self.midToName[64227911] = "SyncNpcInteractedOuterVoice"
	self.midToName[64233556] = "ShowTaskFailPanel"
	self.midToName[64240574] = "SyncPokemonSquad"
	self.midToName[64250239] = "SyncComputerNewUnlockEmail"
	self.midToName[64263325] = "SyncPlayerCreateTeam"
	self.midToName[64263949] = "SyncMoneyRemove"
	self.midToName[64265105] = "SyncItemDayCount"
	self.midToName[64268796] = "SyncPoliceChargingSkillProgress"
	self.midToName[64271294] = "SyncJobMissionStateChange"
	self.midToName[64276158] = "SyncTraceGpsInfo"
	self.midToName[64276238] = "SyncTruckAbortedOrder"
	self.midToName[64276328] = "SyncNpcGiftTagInfo"
	self.midToName[64277564] = "SyncLinkInvite"
	self.midToName[64282983] = "SyncSpiritHistoryJobInfo"
	self.midToName[64290317] = "SyncCityPediaCreditInfo"
	self.midToName[64294476] = "AskPSNSync"
	self.midToName[64300702] = "SyncTruckOrderWrap"
	self.midToName[64307917] = "SyncShowDialog"
	self.midToName[64309285] = "SyncMapRandomEventsList"
	self.midToName[64314729] = "SyncMallCommoditySpiritDisplayPreferences"
	self.midToName[64323657] = "SyncRemoveHouse"
	self.midToName[64323859] = "SyncPlayerAllTask"
	self.midToName[64330159] = "SyncSpiritBadgeInfo"
	self.midToName[64333365] = "KickOff"
	self.midToName[64338922] = "SyncNewPokemon"
	self.midToName[64341180] = "SyncAnimalInfo"
	self.midToName[64349771] = "SyncCompletedChallenge"
	self.midToName[64350941] = "SyncSetSpiritFashions"
	self.midToName[64351404] = "SyncPlayerTeamApply"
	self.midToName[64352235] = "SyncPlayerUpdateCompetitionSeasonData"
	self.midToName[64354845] = "SyncNpcInteractedStory"
	self.midToName[64358420] = "SyncMoneyAdd"
	self.midToName[64358656] = "SyncPlayerTeamMemberKick"
	self.midToName[64362626] = "SyncPoliceDispatchInfos"
	self.midToName[64370898] = "SyncPlayerChangeLeaderApply"
	self.midToName[64373720] = "SyncChangeEventConditionProgress"
	self.midToName[64377362] = "SyncNpcChatLeaveGameplay"
	self.midToName[64379333] = "SyncPoliceServiceData"
	self.midToName[64383019] = "SyncCompletedSubQuest"
	self.midToName[64383561] = "SyncBartenderElementStockOz"
	self.midToName[64384300] = "SyncSpiritPoliceViolationInfos"
	self.midToName[64389316] = "SyncCountryReputation"
	self.midToName[64402770] = "SyncNpcUnlockVoice"
	self.midToName[64415819] = "SyncAddHouse"
	self.midToName[64416807] = "SyncMoneyRemoveInfo"
	self.midToName[64420640] = "SyncTemporaryCurrentTask"
	self.midToName[64423076] = "SyncQuantumWalletInfo"
	self.midToName[64428806] = "SyncPlayerGachaGroupBeenClear"
	self.midToName[64437425] = "SyncBattlePassRewardClaimState"
	self.midToName[64438260] = "SyncPlayerInviteToTeam"
	self.midToName[64440416] = "SyncEnterScene"
	self.midToName[64443578] = "SyncPlayerResponseTeamInvite"
	self.midToName[64444366] = "SyncNewActivity"
	self.midToName[64450572] = "SyncPlayerJoinTeam"
	self.midToName[64453933] = "SyncBreakDialog"
	self.midToName[64454079] = "SyncRemoveActivity"
	self.midToName[64454937] = "SyncDiDiNextTask"
	self.midToName[64456279] = "NotifyNewHackerPosts"
	self.midToName[64462927] = "SyncActivateLockedNpcCard"
	self.midToName[64467486] = "SyncNewTuite"
	self.midToName[64472143] = "SyncResetEventConditionProgress"
	self.midToName[64484280] = "SyncCanWatchOther"
	self.midToName[64485852] = "SyncBattlePassType"
	self.midToName[64495540] = "SyncBattlePassProgress"
	self.midToName[64509181] = "SyncPlayerFanInfo"
	self.midToName[64519765] = "SyncCancelInviterPlayerInteractionAction"
	self.midToName[64534124] = "SyncGuideTeachInfos"
	self.midToName[64535774] = "SyncPlayerNpcProfileMultiTrustValueChanged"
	self.midToName[64539241] = "ShowLogInClient"
	self.midToName[64542461] = "AddSpiritPhoneInfos"
	self.midToName[64544191] = "SyncBartenderCustomerInfo"
	self.midToName[64551745] = "SyncPlayerTempSpirits"
	self.midToName[64553341] = "SyncAllUnlockedVehicles"
	self.midToName[64557867] = "SyncNpcChats"
	self.midToName[64564516] = "SyncItemShortcut"
	self.midToName[64566661] = "SyncFerrisWheelInfo"
	self.midToName[64573061] = "SyncPlayerTwitterButton"
	self.midToName[64573658] = "SyncSpiritPoliceCaseInfos"
	self.midToName[64574748] = "SyncSpiritAbilityInfo"
	self.midToName[64574821] = "SyncUpdatePokemonLockState"
	self.midToName[64576140] = "SyncClearNpcChatInfo"
	self.midToName[64579368] = "SyncInviteePlayerInteractionAction"
	self.midToName[64580834] = "SyncCurrentTruckOrder"
	self.midToName[64581024] = "SyncItemCountLimit"
	self.midToName[64587006] = "SyncPlayerGachaPoolBeenClear"
	self.midToName[64589836] = "SyncLockedNpcFavor"
	self.midToName[64594789] = "SyncNewCityPediaInfo"
	self.midToName[64599072] = "SyncNpcFirstChatPosInfo"
	self.midToName[64599282] = "SyncResetNpcEventsTriggerCount"
	self.midToName[64602397] = "SyncInviteRideNpcInfo"
	self.midToName[64619526] = "SyncInviterPlayerInteractionAction"
	self.midToName[64620949] = "SyncNpcPhotoPosInfo"
	self.midToName[64621842] = "SyncAddFashion"
	self.midToName[64626131] = "SyncPlayerProduceInfo"
	self.midToName[64628013] = "SyncPlayerCompetitionSeason"
	self.midToName[64630599] = "SyncGangBossFullDetails"
	self.midToName[64638005] = "SyncClawDateInfo"
	self.midToName[64641895] = "SyncWatchInteractionInfo"
	self.midToName[64646049] = "SyncUnlockPhoneContactOptions"
	self.midToName[64652219] = "SyncNpcInteractedOuterStory"
	self.midToName[64653833] = "SyncMoney"
	self.midToName[64661996] = "SyncNewAchievement"
	self.midToName[64662440] = "SyncAllAcceptTruckOrder"
	self.midToName[64671698] = "SyncRemoveNpcChat"
	self.midToName[64672612] = "SyncTruckHighValueOrder"
	self.midToName[64676793] = "SyncUnSetTaskTryWearFashionInfo"
	self.midToName[64682455] = "SyncNpcChatInvite"
	self.midToName[64685674] = "SyncClearNpcGroupChatInfo"
	self.midToName[64690406] = "SyncPoliceFakeFileInfo"
	self.midToName[64692146] = "SyncDivinerAIError"
	self.midToName[64693614] = "SyncActiveSpiritJobTalentLayer"
	self.midToName[64708333] = "SyncNpcChatJoinGameplay"
	self.midToName[64709905] = "SyncNpcInteractPointCount"
	self.midToName[64711781] = "SyncGoldRemove"
	self.midToName[64734958] = "SyncSwitchSceneFailed"
	self.midToName[64735329] = "SyncPlayerTeamInfo"
	self.midToName[64737256] = "SyncFactionInfluenceAreaOccupy"
	self.midToName[64740104] = "SyncTaskSpoonResourceLoaded"
	self.midToName[64745458] = "SyncFactionInfoChange"
	self.midToName[64749352] = "SyncCollectionCountryUnlock"
	self.midToName[64750996] = "SyncCommonSpiritTalentExp"
	self.midToName[64765180] = "SyncArmoryAddWeapon"
	self.midToName[64770574] = "ShowReceiveRewardDetail"
	self.midToName[64771401] = "SyncSpiritJobTalentPoint"
	self.midToName[64772212] = "SyncNpcUnlockStory"
	self.midToName[64780410] = "SyncPhoneAutoDeleteContact"
	self.midToName[64784818] = "SyncMilkNpcFavor"
	self.midToName[64786930] = "SyncAcceptTruckJobOrder"
	self.midToName[64787777] = "SyncHotSpringInfo"
	self.midToName[64790694] = "SyncInvestigateGallery"
	self.midToName[64791397] = "SyncCurrentLinkMode"
	self.midToName[64795895] = "SyncOpenTuitePanel"
	self.midToName[64799473] = "SyncHouseParking"
	self.midToName[64804461] = "SyncPlayerYesterdayAvgPopularity"
	self.midToName[64819491] = "SyncPoliceFakeFileSingleInfo"
	self.midToName[64822851] = "SyncFashionInfoDict"
	self.midToName[64822920] = "SyncMapEntrance"
	self.midToName[64823589] = "SyncUrbanBadgeInfo"
	self.midToName[64824976] = "SyncCommodityInfo"
	self.midToName[64833906] = "SyncActivityData"
	self.midToName[64842871] = "SyncSceneFogMapAllUnlock"
	self.midToName[64843031] = "UpdateMapEntrance"
	self.midToName[64852033] = "SyncBreakDialogList"
	self.midToName[64854957] = "SyncLinkKicked"
	self.midToName[64856145] = "SyncMatchInfo"
	self.midToName[64856470] = "SyncSpiritTalentExpAndLevel"
	self.midToName[64857448] = "SyncPlayerNpcProfileRewardGot"
	self.midToName[64860567] = "SyncHackerBatteryCostInfo"
	self.midToName[64861390] = "SyncPoliceMissionExamInfo"
	self.midToName[64861577] = "SyncAgentCureReaction"
	self.midToName[64862193] = "SyncMatchRoomInvite"
	self.midToName[64864346] = "SyncFavorNpcTimeTableInfos"
	self.midToName[64865387] = "SyncFactionHighLightEventList"
	self.midToName[64866915] = "SyncClawDateOut"
	self.midToName[64868156] = "SyncSetSpiritEnableTryWear"
	self.midToName[64870478] = "SyncPlayerPopularity"
	self.midToName[64873229] = "SyncCollectionQuestUnlock"
	self.midToName[64875023] = "SyncTaskRoleTeam"
	self.midToName[64879093] = "SyncInviteeInvitePlayerInteractionAction"
	self.midToName[64879625] = "SyncPlayerInfo"
	self.midToName[64881952] = "SyncUnlockInteractionActionItems"
	self.midToName[64882664] = "SyncStartPlayerInteractionAction"
	self.midToName[64883472] = "SyncSpiritBeggarJobData"
	self.midToName[64888344] = "SyncGangBossCurrentBattleAgentCount"
	self.midToName[64889017] = "SyncPoliceNextOrder"
	self.midToName[64891221] = "SyncMatchRoomKicked"
	self.midToName[64893487] = "SyncSpiritMobileSkinPartInfo"
	self.midToName[64893691] = "SyncGangBossGangMemberDetails"
	self.midToName[64900755] = "SyncNpcFavor"
	self.midToName[64903065] = "SyncBattlePassInfo"
	self.midToName[64909391] = "SyncShowGuide"
	self.midToName[64916867] = "SyncFavorNpcSpoonAgentId"
	self.midToName[64916956] = "SyncComputerNewUnlockFile"
	self.midToName[64920050] = "SyncSetTaskTryWearFashionInfo"
	self.midToName[64927146] = "SyncPlayerInspireHubTodayGameplayJoinCount"
	self.midToName[64931280] = "SyncDropLimitInfoRemove"
	self.midToName[64932574] = "SyncTruckOrderResult"
	self.midToName[64938335] = "SyncDivinerCustomerInfo"
	self.midToName[64939922] = "ShowTaskChangePanel"
	self.midToName[64945644] = "SyncCancelInviteePlayerInteractionAction"
	self.midToName[64945945] = "ShowServerMessageIdWithArgs"
	self.midToName[64946100] = "SyncMomentsNotify"
	self.midToName[64949986] = "SyncArmoryRemoveWeapon"
	self.midToName[64955067] = "SyncPhoneAutoAddContact"
	self.midToName[64960991] = "SyncFactionInfosChange"
	self.midToName[64963363] = "SyncPlayerAddNewSpirit"
	self.midToName[64967055] = "SyncPlayerPopularityChange"
	self.midToName[64968867] = "SyncPoliceExamReaction"
	self.midToName[64971352] = "SyncPlayerNpcProfileActivate"
	self.midToName[64976571] = "SyncPlayerPopularityAdd"
	self.midToName[64994824] = "SyncPlayerGachaPityBeenClear"
	self.midToName[66183523] = "SyncHouseFurnitureInfo"
	self.midToName[66711481] = "GmSyncHouseIndoorBuildInfo"
	self.midToName[68001251] = "SyncAgentCampInfo"
	self.midToName[68002111] = "SyncLuaSlotEntityMessage"
	self.midToName[68002141] = "SyncAgentDiseaseProgress"
	self.midToName[68007325] = "SyncPlayerLoadRate"
	self.midToName[68008896] = "SyncPartySettleData"
	self.midToName[68011793] = "SyncSpawnPoliceVehicles"
	self.midToName[68021038] = "SyncUnitRemoveBuff"
	self.midToName[68027187] = "SyncMatchGameMembersAllLoaded"
	self.midToName[68029044] = "SyncBVBStartSelectChaosBuff"
	self.midToName[68032672] = "SyncPlayerRevive"
	self.midToName[68033182] = "SyncShowTaskMessage"
	self.midToName[68035270] = "SyncNpcScareNpc"
	self.midToName[68035599] = "SyncTeleportVehicle"
	self.midToName[68041040] = "SyncPlayerFinishEnterOrExitVehicle"
	self.midToName[68054711] = "SyncSceneItemEffectChange"
	self.midToName[68080713] = "SyncEnemyBeginItemDrop"
	self.midToName[68084611] = "SyncEnemyDetectStatus"
	self.midToName[68091716] = "SyncFinishTime"
	self.midToName[68098630] = "SyncPlayerExitVehicle"
	self.midToName[68099659] = "SyncSpiritRemoveWeaponAction"
	self.midToName[68103518] = "SyncGomokuParticipantRecord"
	self.midToName[68116531] = "SyncSceneItemLinkOccupantChange"
	self.midToName[68118887] = "SyncGameGroundZonePlayerInfo"
	self.midToName[68119175] = "SyncMatchGameLeftFailureDieCount"
	self.midToName[68125619] = "SyncRemoveNpc"
	self.midToName[68129563] = "SyncMatchGameSettleData"
	self.midToName[68132210] = "SyncBVBChaosTagInfo"
	self.midToName[68137883] = "SyncBowlingClientInfo"
	self.midToName[68147858] = "SyncPlayerCrimeLevel"
	self.midToName[68151671] = "SyncBVBEnemyUltEnergy"
	self.midToName[68152068] = "SyncPartyResponse"
	self.midToName[68156906] = "SyncChangeName"
	self.midToName[68168359] = "SyncGamePause"
	self.midToName[68175489] = "SyncEnemyPoiseWeaponChangeInfo"
	self.midToName[68187041] = "SyncRaidStartTime"
	self.midToName[68191888] = "SyncSpoonEnemyPositionCreate"
	self.midToName[68208678] = "SyncSandevistanEnd"
	self.midToName[68209787] = "SyncDartScoreInfo"
	self.midToName[68211444] = "SyncRemainReviveCount"
	self.midToName[68211691] = "SyncConvertTaskNpcToPed"
	self.midToName[68228126] = "SyncGroupEnemyLockTarget"
	self.midToName[68229586] = "SyncPlayerVehicleGroupEscapeGps"
	self.midToName[68234788] = "SyncSpiritAddWeaponAction"
	self.midToName[68235182] = "SyncPoliceBeginArrest"
	self.midToName[68235314] = "SyncRemoveManagedCreation"
	self.midToName[68238665] = "SyncUnitUpdateBuff"
	self.midToName[68244217] = "SyncSpoonClientActionTrigger"
	self.midToName[68253739] = "SyncSpiritUnitUrbanAttrs"
	self.midToName[68257427] = "SyncScenePlayerName"
	self.midToName[68268723] = "SyncRaidGamePlayRecordRemove"
	self.midToName[68295962] = "SyncSetVehicleCalImpulse"
	self.midToName[68297382] = "SyncPoliceDispatchHelicopter"
	self.midToName[68302014] = "SyncPlayerVehicleGroupEscapeState"
	self.midToName[68314091] = "SyncPlayerCurrentSpirit"
	self.midToName[68314340] = "SyncWorldBossStateChange"
	self.midToName[68328421] = "SyncSandevistanStart"
	self.midToName[68333410] = "StopProgress"
	self.midToName[68334114] = "SyncAgentSuitChange"
	self.midToName[68337601] = "SyncRaidSettlement"
	self.midToName[68338125] = "SyncGameGroundZoneInfo"
	self.midToName[68340587] = "SyncSpoonTaskClientData"
	self.midToName[68343773] = "SyncBeginPortal"
	self.midToName[68344409] = "SyncOtherPlayerBegBehavior"
	self.midToName[68348957] = "SyncDestroyPoliceVehicles"
	self.midToName[68358254] = "SyncTaxiReachDestination"
	self.midToName[68360886] = "SyncGameGroundZoneState"
	self.midToName[68362490] = "SyncSpoonRoomState"
	self.midToName[68371219] = "SyncBVBLinkSelectTeam"
	self.midToName[68373762] = "SendCustomHotPatchGameSceneToClient"
	self.midToName[68386224] = "SyncDestroyVehicle"
	self.midToName[68396726] = "SyncSpiritWeaponDetail"
	self.midToName[68399010] = "SyncWeaponDurabilityChanged"
	self.midToName[68400584] = "SyncGeneralCutInPost"
	self.midToName[68403895] = "SyncActionDataOpen"
	self.midToName[68407238] = "SyncBattleUnitInstantMoved"
	self.midToName[68409127] = "SyncPlayerCurrentOxygenValue"
	self.midToName[68410301] = "SyncPlayerSkillChargeData"
	self.midToName[68412028] = "SyncSpiritUpdateWeaponAction"
	self.midToName[68420021] = "SyncMultiCinemaMovieStart"
	self.midToName[68424308] = "SyncEntityActionGroup"
	self.midToName[68427090] = "SyncWeaponsSceneItemHpChanged"
	self.midToName[68428388] = "SyncPrepareSwitchSceneTimeline"
	self.midToName[68434846] = "SyncSpiritAbility"
	self.midToName[68442298] = "SyncBVBStartGame"
	self.midToName[68443971] = "SyncWorldReady"
	self.midToName[68444149] = "SyncToggleUnitMiniMapHostileIcon"
	self.midToName[68455575] = "SyncGravityFieldOn"
	self.midToName[68459161] = "SyncSpoonClientSoundTrigger"
	self.midToName[68468724] = "SyncInteractBindPerformance"
	self.midToName[68470909] = "SyncRemoveCreation"
	self.midToName[68476812] = "SyncPlayerPoliceChaseFinish"
	self.midToName[68484003] = "SyncCreationPositionAndRotation"
	self.midToName[68486027] = "SyncTupoChangeInfo"
	self.midToName[68495892] = "SyncAgentDiseaseAttack"
	self.midToName[68501444] = "SyncEnemyScareNpc"
	self.midToName[68512183] = "SyncActiveWildEnemyGroup"
	self.midToName[68517259] = "SyncBVBRoundEnd"
	self.midToName[68520603] = "SyncPlayerOxygenSystemState"
	self.midToName[68521147] = "SyncSetVehicleTrackable"
	self.midToName[68522658] = "SyncAgentPoliceExamData"
	self.midToName[68528392] = "SyncPlayerOutOfStuck"
	self.midToName[68530387] = "SyncGomokuScoreInfo"
	self.midToName[68541988] = "SyncUnitClientCustomData"
	self.midToName[68549473] = "SyncRecoverShowAction"
	self.midToName[68552624] = "SyncBVBMoney"
	self.midToName[68554392] = "SyncRaidState"
	self.midToName[68562258] = "SyncEnemyUseClientSkill"
	self.midToName[68562967] = "SyncMultiplayerStatus"
	self.midToName[68563222] = "SyncClearSpoonEnemies"
	self.midToName[68566635] = "SynExitHelicopterView"
	self.midToName[68569246] = "SyncDestroyMetroInfos"
	self.midToName[68576087] = "SyncRideAgent"
	self.midToName[68597805] = "SyncRaidGamePlayInfo"
	self.midToName[68598465] = "SyncWildEnemyGroupCheckTime"
	self.midToName[68600791] = "SyncUnitLockTarget"
	self.midToName[68601034] = "StopProgressTemplateCall"
	self.midToName[68617753] = "SyncMonitorPoliceApproach"
	self.midToName[68619076] = "SyncBVBStartSelectFightPokemon"
	self.midToName[68633332] = "SyncBVBUltSkill"
	self.midToName[68634743] = "SyncSpoonClientConditionJudge"
	self.midToName[68635525] = "SyncEnemyEndItemDrop"
	self.midToName[68635825] = "SyncClientUseSkill"
	self.midToName[68636622] = "SyncEndPortal"
	self.midToName[68637427] = "SyncSpoonTaskAbortRecover"
	self.midToName[68647080] = "SyncCastVote"
	self.midToName[68648870] = "SyncRaidTargets"
	self.midToName[68649557] = "SyncSpiritAbilities"
	self.midToName[68649704] = "SyncChangeVehicleInteractable"
	self.midToName[68655602] = "SyncSwitchControl"
	self.midToName[68664767] = "SyncSceneItemSignalSend"
	self.midToName[68666356] = "SyncShowWorldEnemyRewardMessage"
	self.midToName[68685284] = "SyncAddCreation"
	self.midToName[68686565] = "SyncOtherPlayerSpiritWearFashionsInfo"
	self.midToName[68689379] = "SyncEnemyPoiseRate"
	self.midToName[68691394] = "SyncAgentDiseaseCured"
	self.midToName[68693900] = "SyncShowTipMessage"
	self.midToName[68699731] = "SyncRaidCloseTime"
	self.midToName[68703022] = "SyncBVBGameEnd"
	self.midToName[68707179] = "SyncPlayerStartEnterOrExitVehicle"
	self.midToName[68708402] = "SyncLinkMemberInfo"
	self.midToName[68710886] = "SyncFakePersonRed"
	self.midToName[68725832] = "SyncRemoveUnitClientCustomData"
	self.midToName[68735163] = "SyncDisarmCreateWeaponDestructible"
	self.midToName[68742819] = "SyncPlayerDead"
	self.midToName[68753590] = "SyncSpiritSwitchWeaponAction"
	self.midToName[68757592] = "SyncPlayerAllSkillChargeData"
	self.midToName[68760171] = "SyncEnemyMovingLuaSlotId"
	self.midToName[68763420] = "SyncEnemyItemDropDatas"
	self.midToName[68768659] = "SyncShowMessage"
	self.midToName[68772022] = "SyncControlVehicleRadar"
	self.midToName[68785775] = "SyncStopShowAction"
	self.midToName[68792735] = "SyncEnemyDetect"
	self.midToName[68797557] = "SyncRemoveObstacle"
	self.midToName[68800226] = "SyncSpawnVehicle"
	self.midToName[68801428] = "SyncManagedCreation"
	self.midToName[68810296] = "SyncPlayerWeather"
	self.midToName[68810561] = "SyncUnitHurtEffect"
	self.midToName[68811086] = "SyncInactiveWildEnemyGroup"
	self.midToName[68814135] = "SyncGameGroundZoneTurnChange"
	self.midToName[68817037] = "SyncUnitElement3"
	self.midToName[68822468] = "SyncLinkMemberSceneInfoChange"
	self.midToName[68824345] = "SyncCaptureEnemy"
	self.midToName[68828543] = "SyncBVBChaosBuff"
	self.midToName[68831898] = "SyncChangeVehicleController"
	self.midToName[68850332] = "StartProgress"
	self.midToName[68852690] = "SyncFightSpiritStartDie"
	self.midToName[68854930] = "SyncRaidGamePlayRecordDoubleValue"
	self.midToName[68856167] = "SyncBVBUpdateFightPokemons"
	self.midToName[68857464] = "SyncUnitHp"
	self.midToName[68858287] = "SyncPlayerPoliceChasedVehicles"
	self.midToName[68866576] = "SyncBVBFightEndTime"
	self.midToName[68871637] = "SyncTaskRoomRemove"
	self.midToName[68882990] = "SyncChaosAgentStatisticInfo"
	self.midToName[68884830] = "SyncBowlingScoreInfo"
	self.midToName[68890464] = "SyncEnemyFightEdict"
	self.midToName[68897900] = "SyncControllableAgentNextAvailableTime"
	self.midToName[68901239] = "SyncTaskRoomAdd"
	self.midToName[68901656] = "SyncBreakSkill"
	self.midToName[68913837] = "SyncLinkMemberVehicleInfoChange"
	self.midToName[68916669] = "SyncMobilePlatformInfo"
	self.midToName[68927002] = "SyncPlayerPoilceChaseCountDown"
	self.midToName[68929580] = "SyncUnitAddBuff"
	self.midToName[68939905] = "SyncRaidTargetCounter"
	self.midToName[68949162] = "SyncWorldRewardTriggeredInfo"
	self.midToName[68962729] = "SyncControllableAgent"
	self.midToName[68969986] = "SyncEnemyDisarmState"
	self.midToName[68973352] = "SyncMonitorDisBtnPlayerAndVehicle"
	self.midToName[68974077] = "SyncUnitBuffList"
	self.midToName[68976401] = "SyncRemoveEffect"
	self.midToName[68982002] = "SyncGetOffOnVehicleEnemyDie"
	self.midToName[68984310] = "StartProgressTemplateCall"
	self.midToName[68987100] = "SyncBVBStartFight"
	self.midToName[68988337] = "SyncEnemyItemPickUp"
	self.midToName[68988971] = "SyncCleaningInfo"
	self.midToName[68996280] = "SyncRaiseVote"
	self.midToName[68997755] = "SyncRunningMetroInfos"
	self.midToName[115181177] = "SyncInMjGame"
	self.midToName[115954489] = "SendCustomHotPatchMahjongToClient"
	self.midToName[116020736] = "SyncMjScoreChange"
	self.midToName[116020751] = "SyncMjPlayerReady"
	self.midToName[116038644] = "SyncMjDingQue"
	self.midToName[116039195] = "SyncMjYiPaoDuoXiang"
	self.midToName[116131924] = "SyncMjTuiShui"
	self.midToName[116141795] = "SyncMjLoginResult"
	self.midToName[116178909] = "SyncMjChi"
	self.midToName[116219373] = "SyncMjGameOver"
	self.midToName[116267748] = "SyncMjHuanPaiResult"
	self.midToName[116271245] = "SyncMjMoPai"
	self.midToName[116325366] = "SyncMjMaoZhuanYu"
	self.midToName[116330964] = "SyncMjPlayerExit"
	self.midToName[116379388] = "SyncMjHuanPai"
	self.midToName[116465447] = "SyncMjHuanPaiBegin"
	self.midToName[116488792] = "SyncMjTurn"
	self.midToName[116511754] = "SyncMahjongNpcChat"
	self.midToName[116531392] = "SyncMjChuPai"
	self.midToName[116574305] = "SyncMjRoomOwnerSeatIndex"
	self.midToName[116592712] = "SyncMjHu"
	self.midToName[116595985] = "SyncMjPeng"
	self.midToName[116622906] = "SyncMjOperations"
	self.midToName[116645377] = "SyncMjGameInfo"
	self.midToName[116653059] = "SyncMahjongChat"
	self.midToName[116688453] = "SyncMjPlayerAdd"
	self.midToName[116696426] = "SyncMjRoomState"
	self.midToName[116699472] = "SyncMjHanGang"
	self.midToName[116713715] = "SyncMjAutoEnterTuoGuan"
	self.midToName[116751448] = "SyncMjGang"
	self.midToName[116832472] = "SyncMjGuo"
	self.midToName[116880436] = "SyncMjDingQueBegin"
	self.midToName[116906903] = "SyncMjChaDaJiao"
	self.midToName[116973121] = "SyncMjChaHuaZhu"
	self.midToName[116981800] = "SyncMjGameReconnect"
	self.midToName[116993058] = "SendCustomHotPatchMahjongPlayerToClient"
	self.midToName[116998071] = "SyncMjHolds"
	self.midToName[124664788] = "SendCustomHotPatchChatToClient"
	self.midToName[127255686] = "SendCustomHotPatchMinorToClient"
	self.midToName[128098486] = "SendCustomHotPatchAllToClient"
	self.midToName[128109600] = "SyncServerLog"
	self.midToName[128248079] = "PushChatGroupNameChanged"
	self.midToName[128294697] = "PushChatGroupMemberJoin"
	self.midToName[128303615] = "PushChatGroupDismiss"
	self.midToName[128312985] = "PushPlayerImSimpleData"
	self.midToName[128503247] = "PushMuteEndTime"
	self.midToName[128520616] = "PushChatGroupMemberRemove"
	self.midToName[128563852] = "SyncDeleteMail"
	self.midToName[128565833] = "PushChatGroupInviteReject"
	self.midToName[128584754] = "SyncNewMail"
	self.midToName[128663439] = "PushJoinNewChatGroup"
	self.midToName[128678442] = "SyncServerWarn"
	self.midToName[128691656] = "SyncSyncRateLevelUp"
	self.midToName[128768338] = "PushSoftMuteEndTime"
	self.midToName[128873895] = "PushChatGroupInvite"
	self.midToName[128901894] = "SyncServerDebug"
	self.midToName[154006932] = "UserBanned"
	self.midToName[154349060] = "SyncLoginKick"
	self.midToName[154595756] = "SendCustomHotPatchAvatarToClient"
	self.midToName[154989241] = "ShowTeamMessageWithPid"
	self.midToName[203023320] = "SyncMatchRoomPrepare"
	self.midToName[203051678] = "SyncMatchRoomDutySwapRemoved"
	self.midToName[203140608] = "SyncMatchRoomDutySwapApplication"
	self.midToName[203302854] = "SyncMatchGameStart"
	self.midToName[203319989] = "SyncMatchRoomReady"
	self.midToName[203393681] = "SyncMatchRoomDutyConfirm"
	self.midToName[203438648] = "SyncMatchRoomNotReady"
	self.midToName[203468128] = "SyncMatchRoomMemberReady"
	self.midToName[203587053] = "SyncMatchRoomMemberConfirmed"
	self.midToName[203656753] = "SyncMatchRoomMemberChangePrepareInfo"
	self.midToName[203660430] = "SyncMatchGameMemberLeave"
	self.midToName[203736421] = "SyncMatchRoomMatchCancel"
	self.midToName[203788962] = "SyncMatchGameMemberPlayGameAgain"
	self.midToName[203818940] = "SyncMatchRoomMemberChange"
	self.midToName[203832404] = "SyncMatchRoomDismissed"
	self.midToName[203960587] = "SendCustomHotPatchMatchToClient"
	self.midToName[203996390] = "SyncMatchRoomMatchStart"
	self.midToName[203998226] = "SyncMatchRoomSettingChange"
	self.midToName[204039196] = "SyncLinkMemberRemove"
	self.midToName[204171545] = "SendCustomHotPatchMatchToClient"
	self.midToName[204263045] = "SyncLinkMemberOffline"
	self.midToName[204459497] = "ShowMemberLinkMessage"
	self.midToName[204730628] = "SyncLinkMemberAdd"
	self.midToName[204826282] = "SyncLinkDeviceLevel"
	self.midToName[204967791] = "SyncLinkMemberOnline"
	self.midToReturnMessageReader[12010124] = function(reader)
		return
	end
	self.midToReturnMessageReader[12028122] = function(reader)
		return
	end
	self.midToReturnMessageReader[12111184] = function(reader)
		return
	end
	self.midToReturnMessageReader[12113923] = function(reader)
		return
	end
	self.midToReturnMessageReader[12191255] = function(reader)
		local r0 = Base.ReadList(reader, function(r)
			return r:ReadString()
		end)

		return r0
	end
	self.midToReturnMessageReader[12202308] = function(reader)
		return
	end
	self.midToReturnMessageReader[12274645] = function(reader)
		return
	end
	self.midToReturnMessageReader[12290974] = function(reader)
		return
	end
	self.midToReturnMessageReader[12346244] = function(reader)
		return
	end
	self.midToReturnMessageReader[12417037] = function(reader)
		return
	end
	self.midToReturnMessageReader[12545963] = function(reader)
		local r0 = Base.ReadList(reader, function(r)
			return r:ReadString()
		end)

		return r0
	end
	self.midToReturnMessageReader[12569277] = function(reader)
		return
	end
	self.midToReturnMessageReader[12759230] = function(reader)
		return
	end
	self.midToReturnMessageReader[12782556] = function(reader)
		return
	end
	self.midToReturnMessageReader[12809616] = function(reader)
		return
	end
	self.midToReturnMessageReader[12809738] = function(reader)
		return
	end
	self.midToReturnMessageReader[12938926] = function(reader)
		return
	end
	self.midToReturnMessageReader[12946339] = function(reader)
		local r0 = Base.ReadList(reader, function(r)
			return r:ReadString()
		end)

		return r0
	end
	self.midToReturnMessageReader[12952978] = function(reader)
		return
	end
	self.midToReturnMessageReader[13064867] = function(reader)
		return
	end
	self.midToReturnMessageReader[13095952] = function(reader)
		return
	end
	self.midToReturnMessageReader[13177164] = function(reader)
		return
	end
	self.midToReturnMessageReader[13190420] = function(reader)
		return
	end
	self.midToReturnMessageReader[13190945] = function(reader)
		return
	end
	self.midToReturnMessageReader[13245047] = function(reader)
		return
	end
	self.midToReturnMessageReader[13248254] = function(reader)
		return
	end
	self.midToReturnMessageReader[13270993] = function(reader)
		return
	end
	self.midToReturnMessageReader[13332623] = function(reader)
		return
	end
	self.midToReturnMessageReader[13335141] = function(reader)
		return
	end
	self.midToReturnMessageReader[13358496] = function(reader)
		return
	end
	self.midToReturnMessageReader[13359941] = function(reader)
		return
	end
	self.midToReturnMessageReader[13370624] = function(reader)
		return
	end
	self.midToReturnMessageReader[13371434] = function(reader)
		return
	end
	self.midToReturnMessageReader[13391743] = function(reader)
		return
	end
	self.midToReturnMessageReader[13414325] = function(reader)
		return
	end
	self.midToReturnMessageReader[13458899] = function(reader)
		local r0 = reader:ReadInt32()

		return r0
	end
	self.midToReturnMessageReader[13467299] = function(reader)
		return
	end
	self.midToReturnMessageReader[13663496] = function(reader)
		return
	end
	self.midToReturnMessageReader[13666860] = function(reader)
		return
	end
	self.midToReturnMessageReader[13714743] = function(reader)
		local r0 = reader:ReadDouble()

		return r0
	end
	self.midToReturnMessageReader[13727744] = function(reader)
		return
	end
	self.midToReturnMessageReader[13753963] = function(reader)
		return
	end
	self.midToReturnMessageReader[13831025] = function(reader)
		return
	end
	self.midToReturnMessageReader[13902467] = function(reader)
		return
	end
	self.midToReturnMessageReader[34089392] = function(reader)
		return
	end
	self.midToReturnMessageReader[34270770] = function(reader)
		local r0 = reader:ReadUInt64()

		return r0
	end
	self.midToReturnMessageReader[34316894] = function(reader)
		return
	end
	self.midToReturnMessageReader[34326564] = function(reader)
		local r0 = Base.ReadStruct(reader, Auto.Reader[157])

		return r0
	end
	self.midToReturnMessageReader[34328811] = function(reader)
		local r0 = reader:ReadInt32()
		local r1 = Base.ReadList(reader, function(r)
			return r:ReadString()
		end)

		return r0, r1
	end
	self.midToReturnMessageReader[34333379] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[0])

		return r0
	end
	self.midToReturnMessageReader[34405957] = function(reader)
		local r0 = reader:ReadString()

		return r0
	end
	self.midToReturnMessageReader[34491280] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[158])

		return r0
	end
	self.midToReturnMessageReader[34504681] = function(reader)
		return
	end
	self.midToReturnMessageReader[34515409] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[158])

		return r0
	end
	self.midToReturnMessageReader[34570630] = function(reader)
		local r0 = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[159])
		end)

		return r0
	end
	self.midToReturnMessageReader[34634993] = function(reader)
		local r0 = reader:ReadString()

		return r0
	end
	self.midToReturnMessageReader[34793928] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[0])

		return r0
	end
	self.midToReturnMessageReader[34808618] = function(reader)
		local r0 = Base.ReadStruct(reader, Auto.Reader[160])

		return r0
	end
	self.midToReturnMessageReader[34892583] = function(reader)
		local r0 = Base.ReadStruct(reader, Auto.Reader[160])

		return r0
	end
	self.midToReturnMessageReader[34896088] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[158])

		return r0
	end
	self.midToReturnMessageReader[34910838] = function(reader)
		return
	end
	self.midToReturnMessageReader[52095352] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[0])

		return r0
	end
	self.midToReturnMessageReader[52191467] = function(reader)
		local r0 = reader:ReadString()

		return r0
	end
	self.midToReturnMessageReader[52226781] = function(reader)
		local r0 = reader:ReadUInt32()

		return r0
	end
	self.midToReturnMessageReader[52848583] = function(reader)
		return
	end
	self.midToReturnMessageReader[52917173] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[0])

		return r0
	end
	self.midToReturnMessageReader[62005754] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[60])

		return r0
	end
	self.midToReturnMessageReader[62031040] = function(reader)
		return
	end
	self.midToReturnMessageReader[62041709] = function(reader)
		return
	end
	self.midToReturnMessageReader[62102024] = function(reader)
		return
	end
	self.midToReturnMessageReader[62126348] = function(reader)
		return
	end
	self.midToReturnMessageReader[62160359] = function(reader)
		return
	end
	self.midToReturnMessageReader[62194828] = function(reader)
		return
	end
	self.midToReturnMessageReader[62374829] = function(reader)
		return
	end
	self.midToReturnMessageReader[62375638] = function(reader)
		return
	end
	self.midToReturnMessageReader[62390823] = function(reader)
		return
	end
	self.midToReturnMessageReader[62422377] = function(reader)
		return
	end
	self.midToReturnMessageReader[62428500] = function(reader)
		return
	end
	self.midToReturnMessageReader[62438799] = function(reader)
		return
	end
	self.midToReturnMessageReader[62442137] = function(reader)
		return
	end
	self.midToReturnMessageReader[62445486] = function(reader)
		return
	end
	self.midToReturnMessageReader[62492461] = function(reader)
		return
	end
	self.midToReturnMessageReader[62518181] = function(reader)
		return
	end
	self.midToReturnMessageReader[62541429] = function(reader)
		return
	end
	self.midToReturnMessageReader[62570854] = function(reader)
		return
	end
	self.midToReturnMessageReader[62579423] = function(reader)
		return
	end
	self.midToReturnMessageReader[62601335] = function(reader)
		return
	end
	self.midToReturnMessageReader[62622667] = function(reader)
		return
	end
	self.midToReturnMessageReader[62623518] = function(reader)
		return
	end
	self.midToReturnMessageReader[62624650] = function(reader)
		return
	end
	self.midToReturnMessageReader[62661088] = function(reader)
		return
	end
	self.midToReturnMessageReader[62681822] = function(reader)
		return
	end
	self.midToReturnMessageReader[62692553] = function(reader)
		return
	end
	self.midToReturnMessageReader[62696760] = function(reader)
		return
	end
	self.midToReturnMessageReader[62737299] = function(reader)
		return
	end
	self.midToReturnMessageReader[62743909] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[26])

		return r0
	end
	self.midToReturnMessageReader[62754890] = function(reader)
		return
	end
	self.midToReturnMessageReader[62803848] = function(reader)
		return
	end
	self.midToReturnMessageReader[62902968] = function(reader)
		return
	end
	self.midToReturnMessageReader[62910209] = function(reader)
		return
	end
	self.midToReturnMessageReader[62917663] = function(reader)
		return
	end
	self.midToReturnMessageReader[62947348] = function(reader)
		return
	end
	self.midToReturnMessageReader[62976349] = function(reader)
		return
	end
	self.midToReturnMessageReader[63001519] = function(reader)
		return
	end
	self.midToReturnMessageReader[63003069] = function(reader)
		return
	end
	self.midToReturnMessageReader[63003116] = function(reader)
		return
	end
	self.midToReturnMessageReader[63006163] = function(reader)
		return
	end
	self.midToReturnMessageReader[63011891] = function(reader)
		return
	end
	self.midToReturnMessageReader[63012422] = function(reader)
		local r0 = reader:ReadString()

		return r0
	end
	self.midToReturnMessageReader[63014629] = function(reader)
		return
	end
	self.midToReturnMessageReader[63020013] = function(reader)
		return
	end
	self.midToReturnMessageReader[63021930] = function(reader)
		local r0 = reader:ReadUInt32()

		return r0
	end
	self.midToReturnMessageReader[63024757] = function(reader)
		local r0 = reader:ReadInt32()

		return r0
	end
	self.midToReturnMessageReader[63026208] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[68])

		return r0
	end
	self.midToReturnMessageReader[63026985] = function(reader)
		return
	end
	self.midToReturnMessageReader[63028844] = function(reader)
		return
	end
	self.midToReturnMessageReader[63029825] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[80])

		return r0
	end
	self.midToReturnMessageReader[63040583] = function(reader)
		return
	end
	self.midToReturnMessageReader[63043900] = function(reader)
		return
	end
	self.midToReturnMessageReader[63046025] = function(reader)
		return
	end
	self.midToReturnMessageReader[63046424] = function(reader)
		local r0 = reader:ReadUInt32()

		return r0
	end
	self.midToReturnMessageReader[63047594] = function(reader)
		return
	end
	self.midToReturnMessageReader[63050331] = function(reader)
		return
	end
	self.midToReturnMessageReader[63050860] = function(reader)
		return
	end
	self.midToReturnMessageReader[63053101] = function(reader)
		return
	end
	self.midToReturnMessageReader[63053258] = function(reader)
		return
	end
	self.midToReturnMessageReader[63055507] = function(reader)
		return
	end
	self.midToReturnMessageReader[63055746] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[44])

		return r0
	end
	self.midToReturnMessageReader[63056068] = function(reader)
		return
	end
	self.midToReturnMessageReader[63062011] = function(reader)
		return
	end
	self.midToReturnMessageReader[63068075] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[86])

		return r0
	end
	self.midToReturnMessageReader[63068948] = function(reader)
		local r0 = Base.ReadList(reader, function(r)
			return r:ReadString()
		end)

		return r0
	end
	self.midToReturnMessageReader[63074816] = function(reader)
		return
	end
	self.midToReturnMessageReader[63079235] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[161])

		return r0
	end
	self.midToReturnMessageReader[63079570] = function(reader)
		return
	end
	self.midToReturnMessageReader[63083488] = function(reader)
		return
	end
	self.midToReturnMessageReader[63089336] = function(reader)
		return
	end
	self.midToReturnMessageReader[63090513] = function(reader)
		return
	end
	self.midToReturnMessageReader[63091013] = function(reader)
		return
	end
	self.midToReturnMessageReader[63094262] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[0])

		return r0
	end
	self.midToReturnMessageReader[63095016] = function(reader)
		return
	end
	self.midToReturnMessageReader[63096167] = function(reader)
		return
	end
	self.midToReturnMessageReader[63099387] = function(reader)
		local r0 = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[162])
		end)

		return r0
	end
	self.midToReturnMessageReader[63099919] = function(reader)
		return
	end
	self.midToReturnMessageReader[63100829] = function(reader)
		return
	end
	self.midToReturnMessageReader[63112345] = function(reader)
		return
	end
	self.midToReturnMessageReader[63113674] = function(reader)
		return
	end
	self.midToReturnMessageReader[63118547] = function(reader)
		return
	end
	self.midToReturnMessageReader[63126780] = function(reader)
		return
	end
	self.midToReturnMessageReader[63128266] = function(reader)
		return
	end
	self.midToReturnMessageReader[63129881] = function(reader)
		return
	end
	self.midToReturnMessageReader[63134598] = function(reader)
		return
	end
	self.midToReturnMessageReader[63135334] = function(reader)
		return
	end
	self.midToReturnMessageReader[63137808] = function(reader)
		return
	end
	self.midToReturnMessageReader[63144730] = function(reader)
		return
	end
	self.midToReturnMessageReader[63145374] = function(reader)
		return
	end
	self.midToReturnMessageReader[63145726] = function(reader)
		return
	end
	self.midToReturnMessageReader[63151450] = function(reader)
		return
	end
	self.midToReturnMessageReader[63153332] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[31])

		return r0
	end
	self.midToReturnMessageReader[63154129] = function(reader)
		return
	end
	self.midToReturnMessageReader[63155318] = function(reader)
		return
	end
	self.midToReturnMessageReader[63157099] = function(reader)
		return
	end
	self.midToReturnMessageReader[63158291] = function(reader)
		return
	end
	self.midToReturnMessageReader[63159815] = function(reader)
		local r0 = Base.ReadDict(reader, function(r)
			return r:ReadInt32()
		end, function(r)
			return Base.ReadComplex(r, Auto.Reader[163])
		end)

		return r0
	end
	self.midToReturnMessageReader[63162423] = function(reader)
		local r0 = Auto.Dispatch[164](reader)

		return r0
	end
	self.midToReturnMessageReader[63164692] = function(reader)
		return
	end
	self.midToReturnMessageReader[63166164] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[95])

		return r0
	end
	self.midToReturnMessageReader[63166613] = function(reader)
		return
	end
	self.midToReturnMessageReader[63166628] = function(reader)
		return
	end
	self.midToReturnMessageReader[63167276] = function(reader)
		return
	end
	self.midToReturnMessageReader[63167914] = function(reader)
		return
	end
	self.midToReturnMessageReader[63170733] = function(reader)
		return
	end
	self.midToReturnMessageReader[63174315] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[31])

		return r0
	end
	self.midToReturnMessageReader[63178280] = function(reader)
		return
	end
	self.midToReturnMessageReader[63185930] = function(reader)
		return
	end
	self.midToReturnMessageReader[63187022] = function(reader)
		return
	end
	self.midToReturnMessageReader[63188923] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[26])

		return r0
	end
	self.midToReturnMessageReader[63196226] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[165])

		return r0
	end
	self.midToReturnMessageReader[63198576] = function(reader)
		return
	end
	self.midToReturnMessageReader[63201104] = function(reader)
		return
	end
	self.midToReturnMessageReader[63206228] = function(reader)
		return
	end
	self.midToReturnMessageReader[63207682] = function(reader)
		return
	end
	self.midToReturnMessageReader[63207943] = function(reader)
		local r0 = Base.ReadStruct(reader, Auto.Reader[166])

		return r0
	end
	self.midToReturnMessageReader[63208749] = function(reader)
		return
	end
	self.midToReturnMessageReader[63210052] = function(reader)
		return
	end
	self.midToReturnMessageReader[63214264] = function(reader)
		return
	end
	self.midToReturnMessageReader[63214829] = function(reader)
		return
	end
	self.midToReturnMessageReader[63214919] = function(reader)
		local r0 = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[167])
		end)

		return r0
	end
	self.midToReturnMessageReader[63215920] = function(reader)
		local r0 = reader:ReadString()

		return r0
	end
	self.midToReturnMessageReader[63216279] = function(reader)
		return
	end
	self.midToReturnMessageReader[63221226] = function(reader)
		return
	end
	self.midToReturnMessageReader[63221552] = function(reader)
		local r0 = Auto.Dispatch[164](reader)

		return r0
	end
	self.midToReturnMessageReader[63221599] = function(reader)
		return
	end
	self.midToReturnMessageReader[63222371] = function(reader)
		return
	end
	self.midToReturnMessageReader[63225005] = function(reader)
		return
	end
	self.midToReturnMessageReader[63226615] = function(reader)
		local r0 = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[168])
		end)

		return r0
	end
	self.midToReturnMessageReader[63233964] = function(reader)
		return
	end
	self.midToReturnMessageReader[63236328] = function(reader)
		return
	end
	self.midToReturnMessageReader[63236739] = function(reader)
		return
	end
	self.midToReturnMessageReader[63238313] = function(reader)
		return
	end
	self.midToReturnMessageReader[63239349] = function(reader)
		local r0 = reader:ReadSingle()

		return r0
	end
	self.midToReturnMessageReader[63239719] = function(reader)
		return
	end
	self.midToReturnMessageReader[63244961] = function(reader)
		return
	end
	self.midToReturnMessageReader[63248718] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[169])

		return r0
	end
	self.midToReturnMessageReader[63255088] = function(reader)
		return
	end
	self.midToReturnMessageReader[63256669] = function(reader)
		return
	end
	self.midToReturnMessageReader[63257209] = function(reader)
		local r0 = Base.ReadList(reader, function(r)
			return r:ReadUInt32()
		end)

		return r0
	end
	self.midToReturnMessageReader[63257388] = function(reader)
		return
	end
	self.midToReturnMessageReader[63259642] = function(reader)
		local r0 = Auto.Dispatch[164](reader)

		return r0
	end
	self.midToReturnMessageReader[63269471] = function(reader)
		return
	end
	self.midToReturnMessageReader[63273437] = function(reader)
		return
	end
	self.midToReturnMessageReader[63273976] = function(reader)
		return
	end
	self.midToReturnMessageReader[63275788] = function(reader)
		return
	end
	self.midToReturnMessageReader[63276604] = function(reader)
		return
	end
	self.midToReturnMessageReader[63285675] = function(reader)
		return
	end
	self.midToReturnMessageReader[63288852] = function(reader)
		return
	end
	self.midToReturnMessageReader[63290316] = function(reader)
		local r0 = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[170])
		end)

		return r0
	end
	self.midToReturnMessageReader[63292504] = function(reader)
		return
	end
	self.midToReturnMessageReader[63296228] = function(reader)
		return
	end
	self.midToReturnMessageReader[63296328] = function(reader)
		return
	end
	self.midToReturnMessageReader[63296618] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[31])

		return r0
	end
	self.midToReturnMessageReader[63302890] = function(reader)
		return
	end
	self.midToReturnMessageReader[63303581] = function(reader)
		return
	end
	self.midToReturnMessageReader[63303712] = function(reader)
		local r0 = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[171])
		end)

		return r0
	end
	self.midToReturnMessageReader[63304115] = function(reader)
		return
	end
	self.midToReturnMessageReader[63304509] = function(reader)
		return
	end
	self.midToReturnMessageReader[63305288] = function(reader)
		return
	end
	self.midToReturnMessageReader[63306015] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[172])

		return r0
	end
	self.midToReturnMessageReader[63307384] = function(reader)
		return
	end
	self.midToReturnMessageReader[63311744] = function(reader)
		local r0 = Base.ReadDict(reader, function(r)
			return r:ReadUInt32()
		end, function(r)
			return Base.ReadComplex(r, Auto.Reader[173])
		end)

		return r0
	end
	self.midToReturnMessageReader[63315080] = function(reader)
		return
	end
	self.midToReturnMessageReader[63316010] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[174])

		return r0
	end
	self.midToReturnMessageReader[63317095] = function(reader)
		return
	end
	self.midToReturnMessageReader[63318103] = function(reader)
		return
	end
	self.midToReturnMessageReader[63327583] = function(reader)
		return
	end
	self.midToReturnMessageReader[63327702] = function(reader)
		return
	end
	self.midToReturnMessageReader[63327755] = function(reader)
		return
	end
	self.midToReturnMessageReader[63327819] = function(reader)
		return
	end
	self.midToReturnMessageReader[63331329] = function(reader)
		local r0 = reader:ReadByte()

		return r0
	end
	self.midToReturnMessageReader[63333284] = function(reader)
		return
	end
	self.midToReturnMessageReader[63335013] = function(reader)
		local r0 = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[175])
		end)

		return r0
	end
	self.midToReturnMessageReader[63335971] = function(reader)
		return
	end
	self.midToReturnMessageReader[63336499] = function(reader)
		local r0 = Auto.Dispatch[164](reader)

		return r0
	end
	self.midToReturnMessageReader[63337960] = function(reader)
		local r0 = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[176])
		end)

		return r0
	end
	self.midToReturnMessageReader[63346443] = function(reader)
		return
	end
	self.midToReturnMessageReader[63356561] = function(reader)
		return
	end
	self.midToReturnMessageReader[63359217] = function(reader)
		return
	end
	self.midToReturnMessageReader[63361417] = function(reader)
		local r0 = reader:ReadUInt32()

		return r0
	end
	self.midToReturnMessageReader[63361629] = function(reader)
		return
	end
	self.midToReturnMessageReader[63362157] = function(reader)
		return
	end
	self.midToReturnMessageReader[63368528] = function(reader)
		return
	end
	self.midToReturnMessageReader[63369010] = function(reader)
		return
	end
	self.midToReturnMessageReader[63369229] = function(reader)
		return
	end
	self.midToReturnMessageReader[63369381] = function(reader)
		return
	end
	self.midToReturnMessageReader[63370028] = function(reader)
		return
	end
	self.midToReturnMessageReader[63371712] = function(reader)
		return
	end
	self.midToReturnMessageReader[63371802] = function(reader)
		return
	end
	self.midToReturnMessageReader[63371981] = function(reader)
		return
	end
	self.midToReturnMessageReader[63372220] = function(reader)
		return
	end
	self.midToReturnMessageReader[63377145] = function(reader)
		return
	end
	self.midToReturnMessageReader[63386651] = function(reader)
		local r0 = Base.ReadList(reader, function(r)
			return r:ReadUInt32()
		end)

		return r0
	end
	self.midToReturnMessageReader[63386828] = function(reader)
		local r0 = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[24])
		end)

		return r0
	end
	self.midToReturnMessageReader[63390024] = function(reader)
		return
	end
	self.midToReturnMessageReader[63391260] = function(reader)
		return
	end
	self.midToReturnMessageReader[63392432] = function(reader)
		return
	end
	self.midToReturnMessageReader[63398162] = function(reader)
		return
	end
	self.midToReturnMessageReader[63405583] = function(reader)
		return
	end
	self.midToReturnMessageReader[63408340] = function(reader)
		return
	end
	self.midToReturnMessageReader[63413415] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[165])

		return r0
	end
	self.midToReturnMessageReader[63414477] = function(reader)
		return
	end
	self.midToReturnMessageReader[63418511] = function(reader)
		return
	end
	self.midToReturnMessageReader[63421408] = function(reader)
		return
	end
	self.midToReturnMessageReader[63421624] = function(reader)
		return
	end
	self.midToReturnMessageReader[63423790] = function(reader)
		local r0 = reader:ReadString()

		return r0
	end
	self.midToReturnMessageReader[63426840] = function(reader)
		return
	end
	self.midToReturnMessageReader[63432343] = function(reader)
		return
	end
	self.midToReturnMessageReader[63433550] = function(reader)
		return
	end
	self.midToReturnMessageReader[63434217] = function(reader)
		return
	end
	self.midToReturnMessageReader[63437331] = function(reader)
		return
	end
	self.midToReturnMessageReader[63443233] = function(reader)
		return
	end
	self.midToReturnMessageReader[63444074] = function(reader)
		local r0 = reader:ReadString()

		return r0
	end
	self.midToReturnMessageReader[63446135] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[26])

		return r0
	end
	self.midToReturnMessageReader[63447065] = function(reader)
		return
	end
	self.midToReturnMessageReader[63449927] = function(reader)
		return
	end
	self.midToReturnMessageReader[63452554] = function(reader)
		return
	end
	self.midToReturnMessageReader[63460243] = function(reader)
		local r0 = Base.ReadStruct(reader, Auto.Reader[177])

		return r0
	end
	self.midToReturnMessageReader[63460318] = function(reader)
		return
	end
	self.midToReturnMessageReader[63463540] = function(reader)
		return
	end
	self.midToReturnMessageReader[63463734] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[86])

		return r0
	end
	self.midToReturnMessageReader[63464186] = function(reader)
		local r0 = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[178])
		end)

		return r0
	end
	self.midToReturnMessageReader[63464563] = function(reader)
		return
	end
	self.midToReturnMessageReader[63465082] = function(reader)
		return
	end
	self.midToReturnMessageReader[63465403] = function(reader)
		return
	end
	self.midToReturnMessageReader[63469498] = function(reader)
		return
	end
	self.midToReturnMessageReader[63471624] = function(reader)
		local r0 = Base.ReadList(reader, function(r)
			return r:ReadUInt32()
		end)

		return r0
	end
	self.midToReturnMessageReader[63476354] = function(reader)
		return
	end
	self.midToReturnMessageReader[63478765] = function(reader)
		return
	end
	self.midToReturnMessageReader[63479890] = function(reader)
		local r0 = Base.ReadList(reader, function(r)
			return r:ReadUInt64()
		end)

		return r0
	end
	self.midToReturnMessageReader[63480056] = function(reader)
		return
	end
	self.midToReturnMessageReader[63481355] = function(reader)
		return
	end
	self.midToReturnMessageReader[63489148] = function(reader)
		local r0 = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[35])
		end)

		return r0
	end
	self.midToReturnMessageReader[63493056] = function(reader)
		return
	end
	self.midToReturnMessageReader[63493355] = function(reader)
		return
	end
	self.midToReturnMessageReader[63499638] = function(reader)
		return
	end
	self.midToReturnMessageReader[63501003] = function(reader)
		local r0 = reader:ReadUInt64()

		return r0
	end
	self.midToReturnMessageReader[63501449] = function(reader)
		local r0 = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[179])
		end)
		local r1 = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[179])
		end)

		return r0, r1
	end
	self.midToReturnMessageReader[63502374] = function(reader)
		return
	end
	self.midToReturnMessageReader[63502680] = function(reader)
		local r0 = reader:ReadUInt32()

		return r0
	end
	self.midToReturnMessageReader[63505594] = function(reader)
		local r0 = reader:ReadString()

		return r0
	end
	self.midToReturnMessageReader[63505983] = function(reader)
		return
	end
	self.midToReturnMessageReader[63508651] = function(reader)
		local r0 = Base.ReadList(reader, function(r)
			return r:ReadInt32()
		end)

		return r0
	end
	self.midToReturnMessageReader[63510779] = function(reader)
		return
	end
	self.midToReturnMessageReader[63515128] = function(reader)
		return
	end
	self.midToReturnMessageReader[63516264] = function(reader)
		return
	end
	self.midToReturnMessageReader[63516582] = function(reader)
		return
	end
	self.midToReturnMessageReader[63517412] = function(reader)
		return
	end
	self.midToReturnMessageReader[63520587] = function(reader)
		return
	end
	self.midToReturnMessageReader[63521359] = function(reader)
		return
	end
	self.midToReturnMessageReader[63522633] = function(reader)
		return
	end
	self.midToReturnMessageReader[63524349] = function(reader)
		return
	end
	self.midToReturnMessageReader[63525617] = function(reader)
		return
	end
	self.midToReturnMessageReader[63530713] = function(reader)
		return
	end
	self.midToReturnMessageReader[63536758] = function(reader)
		return
	end
	self.midToReturnMessageReader[63537805] = function(reader)
		return
	end
	self.midToReturnMessageReader[63538188] = function(reader)
		return
	end
	self.midToReturnMessageReader[63542679] = function(reader)
		return
	end
	self.midToReturnMessageReader[63544265] = function(reader)
		return
	end
	self.midToReturnMessageReader[63544648] = function(reader)
		return
	end
	self.midToReturnMessageReader[63545469] = function(reader)
		return
	end
	self.midToReturnMessageReader[63548238] = function(reader)
		local r0 = reader:ReadBoolean()

		return r0
	end
	self.midToReturnMessageReader[63555824] = function(reader)
		return
	end
	self.midToReturnMessageReader[63558886] = function(reader)
		local r0 = reader:ReadUInt32()

		return r0
	end
	self.midToReturnMessageReader[63560225] = function(reader)
		return
	end
	self.midToReturnMessageReader[63561922] = function(reader)
		return
	end
	self.midToReturnMessageReader[63562905] = function(reader)
		return
	end
	self.midToReturnMessageReader[63563728] = function(reader)
		return
	end
	self.midToReturnMessageReader[63565367] = function(reader)
		return
	end
	self.midToReturnMessageReader[63565459] = function(reader)
		return
	end
	self.midToReturnMessageReader[63565583] = function(reader)
		return
	end
	self.midToReturnMessageReader[63568618] = function(reader)
		return
	end
	self.midToReturnMessageReader[63571409] = function(reader)
		local r0 = reader:ReadBoolean()

		return r0
	end
	self.midToReturnMessageReader[63573435] = function(reader)
		return
	end
	self.midToReturnMessageReader[63574292] = function(reader)
		local r0 = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[57])
		end)

		return r0
	end
	self.midToReturnMessageReader[63574661] = function(reader)
		return
	end
	self.midToReturnMessageReader[63577426] = function(reader)
		return
	end
	self.midToReturnMessageReader[63577859] = function(reader)
		return
	end
	self.midToReturnMessageReader[63577993] = function(reader)
		return
	end
	self.midToReturnMessageReader[63578799] = function(reader)
		return
	end
	self.midToReturnMessageReader[63579450] = function(reader)
		local r0 = reader:ReadUInt32()

		return r0
	end
	self.midToReturnMessageReader[63581743] = function(reader)
		return
	end
	self.midToReturnMessageReader[63582610] = function(reader)
		return
	end
	self.midToReturnMessageReader[63582824] = function(reader)
		return
	end
	self.midToReturnMessageReader[63585267] = function(reader)
		local r0 = Base.ReadList(reader, function(r)
			return r:ReadUInt32()
		end)
		local r1 = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[180])
		end)

		return r0, r1
	end
	self.midToReturnMessageReader[63586619] = function(reader)
		return
	end
	self.midToReturnMessageReader[63594408] = function(reader)
		return
	end
	self.midToReturnMessageReader[63596082] = function(reader)
		return
	end
	self.midToReturnMessageReader[63597720] = function(reader)
		local r0 = reader:ReadString()

		return r0
	end
	self.midToReturnMessageReader[63598566] = function(reader)
		return
	end
	self.midToReturnMessageReader[63599025] = function(reader)
		return
	end
	self.midToReturnMessageReader[63604699] = function(reader)
		return
	end
	self.midToReturnMessageReader[63605850] = function(reader)
		return
	end
	self.midToReturnMessageReader[63609539] = function(reader)
		local r0 = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[181])
		end)

		return r0
	end
	self.midToReturnMessageReader[63612583] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[35])

		return r0
	end
	self.midToReturnMessageReader[63615056] = function(reader)
		return
	end
	self.midToReturnMessageReader[63615905] = function(reader)
		return
	end
	self.midToReturnMessageReader[63617533] = function(reader)
		return
	end
	self.midToReturnMessageReader[63620214] = function(reader)
		return
	end
	self.midToReturnMessageReader[63621000] = function(reader)
		return
	end
	self.midToReturnMessageReader[63625065] = function(reader)
		return
	end
	self.midToReturnMessageReader[63625130] = function(reader)
		return
	end
	self.midToReturnMessageReader[63628971] = function(reader)
		return
	end
	self.midToReturnMessageReader[63630944] = function(reader)
		return
	end
	self.midToReturnMessageReader[63634877] = function(reader)
		return
	end
	self.midToReturnMessageReader[63635730] = function(reader)
		return
	end
	self.midToReturnMessageReader[63637715] = function(reader)
		return
	end
	self.midToReturnMessageReader[63637797] = function(reader)
		return
	end
	self.midToReturnMessageReader[63639926] = function(reader)
		return
	end
	self.midToReturnMessageReader[63641980] = function(reader)
		return
	end
	self.midToReturnMessageReader[63642349] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[161])

		return r0
	end
	self.midToReturnMessageReader[63646317] = function(reader)
		return
	end
	self.midToReturnMessageReader[63651444] = function(reader)
		return
	end
	self.midToReturnMessageReader[63652865] = function(reader)
		return
	end
	self.midToReturnMessageReader[63652914] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[182])

		return r0
	end
	self.midToReturnMessageReader[63664501] = function(reader)
		return
	end
	self.midToReturnMessageReader[63665760] = function(reader)
		return
	end
	self.midToReturnMessageReader[63666925] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[35])
		local r1 = reader:ReadUInt64()

		return r0, r1
	end
	self.midToReturnMessageReader[63669696] = function(reader)
		local r0 = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[183])
		end)

		return r0
	end
	self.midToReturnMessageReader[63672752] = function(reader)
		local r0 = reader:ReadUInt32()

		return r0
	end
	self.midToReturnMessageReader[63674017] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[59])

		return r0
	end
	self.midToReturnMessageReader[63675749] = function(reader)
		local r0 = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[184])
		end)

		return r0
	end
	self.midToReturnMessageReader[63676062] = function(reader)
		return
	end
	self.midToReturnMessageReader[63679798] = function(reader)
		return
	end
	self.midToReturnMessageReader[63681985] = function(reader)
		return
	end
	self.midToReturnMessageReader[63683403] = function(reader)
		return
	end
	self.midToReturnMessageReader[63684061] = function(reader)
		return
	end
	self.midToReturnMessageReader[63689562] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[185])

		return r0
	end
	self.midToReturnMessageReader[63691025] = function(reader)
		return
	end
	self.midToReturnMessageReader[63700323] = function(reader)
		local r0 = Base.ReadDict(reader, function(r)
			return r:ReadUInt64()
		end, function(r)
			return Base.ReadComplex(r, Auto.Reader[186])
		end)

		return r0
	end
	self.midToReturnMessageReader[63700415] = function(reader)
		return
	end
	self.midToReturnMessageReader[63703743] = function(reader)
		local r0 = reader:ReadUInt32()

		return r0
	end
	self.midToReturnMessageReader[63709000] = function(reader)
		return
	end
	self.midToReturnMessageReader[63710585] = function(reader)
		return
	end
	self.midToReturnMessageReader[63710814] = function(reader)
		return
	end
	self.midToReturnMessageReader[63717772] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[26])

		return r0
	end
	self.midToReturnMessageReader[63719219] = function(reader)
		return
	end
	self.midToReturnMessageReader[63720594] = function(reader)
		return
	end
	self.midToReturnMessageReader[63726563] = function(reader)
		return
	end
	self.midToReturnMessageReader[63727613] = function(reader)
		return
	end
	self.midToReturnMessageReader[63728943] = function(reader)
		return
	end
	self.midToReturnMessageReader[63729442] = function(reader)
		return
	end
	self.midToReturnMessageReader[63729792] = function(reader)
		return
	end
	self.midToReturnMessageReader[63733659] = function(reader)
		return
	end
	self.midToReturnMessageReader[63735136] = function(reader)
		return
	end
	self.midToReturnMessageReader[63737397] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[167])

		return r0
	end
	self.midToReturnMessageReader[63738815] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[187])

		return r0
	end
	self.midToReturnMessageReader[63740237] = function(reader)
		return
	end
	self.midToReturnMessageReader[63746165] = function(reader)
		return
	end
	self.midToReturnMessageReader[63748619] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[188])

		return r0
	end
	self.midToReturnMessageReader[63748734] = function(reader)
		return
	end
	self.midToReturnMessageReader[63751218] = function(reader)
		return
	end
	self.midToReturnMessageReader[63752748] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[175])

		return r0
	end
	self.midToReturnMessageReader[63756002] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[31])

		return r0
	end
	self.midToReturnMessageReader[63756954] = function(reader)
		local r0 = Base.ReadStruct(reader, Auto.Reader[189])

		return r0
	end
	self.midToReturnMessageReader[63757690] = function(reader)
		return
	end
	self.midToReturnMessageReader[63758108] = function(reader)
		return
	end
	self.midToReturnMessageReader[63760478] = function(reader)
		local r0 = Base.ReadList(reader, function(r)
			return r:ReadUInt32()
		end)

		return r0
	end
	self.midToReturnMessageReader[63763686] = function(reader)
		return
	end
	self.midToReturnMessageReader[63766041] = function(reader)
		local r0 = reader:ReadUInt64()

		return r0
	end
	self.midToReturnMessageReader[63770294] = function(reader)
		local r0 = reader:ReadBoolean()

		return r0
	end
	self.midToReturnMessageReader[63774932] = function(reader)
		return
	end
	self.midToReturnMessageReader[63776972] = function(reader)
		return
	end
	self.midToReturnMessageReader[63779182] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[26])

		return r0
	end
	self.midToReturnMessageReader[63784548] = function(reader)
		return
	end
	self.midToReturnMessageReader[63788394] = function(reader)
		return
	end
	self.midToReturnMessageReader[63789535] = function(reader)
		return
	end
	self.midToReturnMessageReader[63790110] = function(reader)
		return
	end
	self.midToReturnMessageReader[63791049] = function(reader)
		return
	end
	self.midToReturnMessageReader[63791580] = function(reader)
		return
	end
	self.midToReturnMessageReader[63792721] = function(reader)
		return
	end
	self.midToReturnMessageReader[63801528] = function(reader)
		return
	end
	self.midToReturnMessageReader[63808947] = function(reader)
		return
	end
	self.midToReturnMessageReader[63809638] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[0])

		return r0
	end
	self.midToReturnMessageReader[63809753] = function(reader)
		return
	end
	self.midToReturnMessageReader[63811038] = function(reader)
		return
	end
	self.midToReturnMessageReader[63817963] = function(reader)
		return
	end
	self.midToReturnMessageReader[63819885] = function(reader)
		local r0 = reader:ReadByte()

		return r0
	end
	self.midToReturnMessageReader[63820182] = function(reader)
		return
	end
	self.midToReturnMessageReader[63823240] = function(reader)
		local r0 = Base.ReadList(reader, function(r)
			return r:ReadUInt64()
		end)

		return r0
	end
	self.midToReturnMessageReader[63826389] = function(reader)
		return
	end
	self.midToReturnMessageReader[63828430] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[190])

		return r0
	end
	self.midToReturnMessageReader[63830867] = function(reader)
		return
	end
	self.midToReturnMessageReader[63834781] = function(reader)
		return
	end
	self.midToReturnMessageReader[63836674] = function(reader)
		return
	end
	self.midToReturnMessageReader[63838275] = function(reader)
		local r0 = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[191])
		end)

		return r0
	end
	self.midToReturnMessageReader[63844141] = function(reader)
		return
	end
	self.midToReturnMessageReader[63844382] = function(reader)
		return
	end
	self.midToReturnMessageReader[63846499] = function(reader)
		return
	end
	self.midToReturnMessageReader[63852506] = function(reader)
		local r0 = Base.ReadList(reader, function(r)
			return r:ReadUInt64()
		end)

		return r0
	end
	self.midToReturnMessageReader[63853110] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[192])

		return r0
	end
	self.midToReturnMessageReader[63853555] = function(reader)
		return
	end
	self.midToReturnMessageReader[63854664] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[183])

		return r0
	end
	self.midToReturnMessageReader[63854977] = function(reader)
		return
	end
	self.midToReturnMessageReader[63856818] = function(reader)
		local r0 = reader:ReadUInt32()

		return r0
	end
	self.midToReturnMessageReader[63857300] = function(reader)
		return
	end
	self.midToReturnMessageReader[63857346] = function(reader)
		return
	end
	self.midToReturnMessageReader[63861812] = function(reader)
		return
	end
	self.midToReturnMessageReader[63864950] = function(reader)
		return
	end
	self.midToReturnMessageReader[63865265] = function(reader)
		return
	end
	self.midToReturnMessageReader[63870038] = function(reader)
		return
	end
	self.midToReturnMessageReader[63872191] = function(reader)
		local r0 = Base.ReadList(reader, function(r)
			return r:ReadUInt32()
		end)

		return r0
	end
	self.midToReturnMessageReader[63874553] = function(reader)
		return
	end
	self.midToReturnMessageReader[63875023] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[178])

		return r0
	end
	self.midToReturnMessageReader[63890074] = function(reader)
		return
	end
	self.midToReturnMessageReader[63892976] = function(reader)
		return
	end
	self.midToReturnMessageReader[63894466] = function(reader)
		return
	end
	self.midToReturnMessageReader[63899448] = function(reader)
		return
	end
	self.midToReturnMessageReader[63899476] = function(reader)
		local r0 = reader:ReadBoolean()

		return r0
	end
	self.midToReturnMessageReader[63899645] = function(reader)
		return
	end
	self.midToReturnMessageReader[63900065] = function(reader)
		return
	end
	self.midToReturnMessageReader[63902942] = function(reader)
		return
	end
	self.midToReturnMessageReader[63903024] = function(reader)
		return
	end
	self.midToReturnMessageReader[63904256] = function(reader)
		return
	end
	self.midToReturnMessageReader[63904758] = function(reader)
		return
	end
	self.midToReturnMessageReader[63906448] = function(reader)
		return
	end
	self.midToReturnMessageReader[63915981] = function(reader)
		return
	end
	self.midToReturnMessageReader[63919736] = function(reader)
		return
	end
	self.midToReturnMessageReader[63920526] = function(reader)
		return
	end
	self.midToReturnMessageReader[63921296] = function(reader)
		local r0 = reader:ReadBoolean()

		return r0
	end
	self.midToReturnMessageReader[63927190] = function(reader)
		local r0 = Base.ReadList(reader, function(r)
			return r:ReadUInt64()
		end)

		return r0
	end
	self.midToReturnMessageReader[63933081] = function(reader)
		return
	end
	self.midToReturnMessageReader[63934517] = function(reader)
		local r0 = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[151])
		end)

		return r0
	end
	self.midToReturnMessageReader[63939233] = function(reader)
		return
	end
	self.midToReturnMessageReader[63940657] = function(reader)
		return
	end
	self.midToReturnMessageReader[63942991] = function(reader)
		local r0 = reader:ReadByte()

		return r0
	end
	self.midToReturnMessageReader[63946088] = function(reader)
		return
	end
	self.midToReturnMessageReader[63946292] = function(reader)
		local r0 = reader:ReadByte()

		return r0
	end
	self.midToReturnMessageReader[63948993] = function(reader)
		return
	end
	self.midToReturnMessageReader[63951006] = function(reader)
		return
	end
	self.midToReturnMessageReader[63951439] = function(reader)
		return
	end
	self.midToReturnMessageReader[63951524] = function(reader)
		return
	end
	self.midToReturnMessageReader[63953543] = function(reader)
		return
	end
	self.midToReturnMessageReader[63955299] = function(reader)
		return
	end
	self.midToReturnMessageReader[63955808] = function(reader)
		return
	end
	self.midToReturnMessageReader[63957623] = function(reader)
		return
	end
	self.midToReturnMessageReader[63969573] = function(reader)
		return
	end
	self.midToReturnMessageReader[63969681] = function(reader)
		local r0 = Base.ReadList(reader, function(r)
			return r:ReadUInt32()
		end)
		local r1 = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[193])
		end)

		return r0, r1
	end
	self.midToReturnMessageReader[63970959] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[183])

		return r0
	end
	self.midToReturnMessageReader[63971131] = function(reader)
		return
	end
	self.midToReturnMessageReader[63972375] = function(reader)
		return
	end
	self.midToReturnMessageReader[63972499] = function(reader)
		return
	end
	self.midToReturnMessageReader[63979914] = function(reader)
		return
	end
	self.midToReturnMessageReader[63980222] = function(reader)
		return
	end
	self.midToReturnMessageReader[63981476] = function(reader)
		return
	end
	self.midToReturnMessageReader[63981686] = function(reader)
		return
	end
	self.midToReturnMessageReader[63982066] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[194])

		return r0
	end
	self.midToReturnMessageReader[63987750] = function(reader)
		return
	end
	self.midToReturnMessageReader[63989753] = function(reader)
		local r0 = reader:ReadUInt32()

		return r0
	end
	self.midToReturnMessageReader[63991228] = function(reader)
		local r0 = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[195])
		end)

		return r0
	end
	self.midToReturnMessageReader[63994070] = function(reader)
		return
	end
	self.midToReturnMessageReader[63998035] = function(reader)
		return
	end
	self.midToReturnMessageReader[63998721] = function(reader)
		local r0 = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[183])
		end)

		return r0
	end
	self.midToReturnMessageReader[65001013] = function(reader)
		return
	end
	self.midToReturnMessageReader[65003274] = function(reader)
		return
	end
	self.midToReturnMessageReader[65009433] = function(reader)
		local r0 = Auto.Dispatch[164](reader)

		return r0
	end
	self.midToReturnMessageReader[65009948] = function(reader)
		return
	end
	self.midToReturnMessageReader[65010990] = function(reader)
		return
	end
	self.midToReturnMessageReader[65019475] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[154])
		local r1 = Base.ReadComplex(reader, Auto.Reader[15])

		return r0, r1
	end
	self.midToReturnMessageReader[65019540] = function(reader)
		return
	end
	self.midToReturnMessageReader[65024621] = function(reader)
		return
	end
	self.midToReturnMessageReader[65025084] = function(reader)
		return
	end
	self.midToReturnMessageReader[65027905] = function(reader)
		local r0 = Base.ReadDict(reader, function(r)
			return r:ReadUInt32()
		end, function(r)
			return Base.ReadComplex(r, Auto.Reader[55])
		end)

		return r0
	end
	self.midToReturnMessageReader[65031157] = function(reader)
		return
	end
	self.midToReturnMessageReader[65033549] = function(reader)
		return
	end
	self.midToReturnMessageReader[65034847] = function(reader)
		return
	end
	self.midToReturnMessageReader[65035092] = function(reader)
		return
	end
	self.midToReturnMessageReader[65037547] = function(reader)
		return
	end
	self.midToReturnMessageReader[65038616] = function(reader)
		return
	end
	self.midToReturnMessageReader[65039689] = function(reader)
		return
	end
	self.midToReturnMessageReader[65043194] = function(reader)
		local r0 = Auto.Dispatch[164](reader)

		return r0
	end
	self.midToReturnMessageReader[65043943] = function(reader)
		return
	end
	self.midToReturnMessageReader[65046173] = function(reader)
		return
	end
	self.midToReturnMessageReader[65048208] = function(reader)
		return
	end
	self.midToReturnMessageReader[65051887] = function(reader)
		return
	end
	self.midToReturnMessageReader[65054041] = function(reader)
		return
	end
	self.midToReturnMessageReader[65063582] = function(reader)
		local r0 = Base.ReadList(reader, function(r)
			return Base.ReadStruct(r, Auto.Reader.UXVector3)
		end)

		return r0
	end
	self.midToReturnMessageReader[65063650] = function(reader)
		return
	end
	self.midToReturnMessageReader[65069435] = function(reader)
		return
	end
	self.midToReturnMessageReader[65075942] = function(reader)
		return
	end
	self.midToReturnMessageReader[65076841] = function(reader)
		local r0 = reader:ReadString()

		return r0
	end
	self.midToReturnMessageReader[65080572] = function(reader)
		return
	end
	self.midToReturnMessageReader[65083687] = function(reader)
		return
	end
	self.midToReturnMessageReader[65086338] = function(reader)
		local r0 = Base.ReadDict(reader, function(r)
			return r:ReadInt32()
		end, function(r)
			return r:ReadString()
		end)

		return r0
	end
	self.midToReturnMessageReader[65086342] = function(reader)
		return
	end
	self.midToReturnMessageReader[65086368] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[31])

		return r0
	end
	self.midToReturnMessageReader[65090965] = function(reader)
		return
	end
	self.midToReturnMessageReader[65095004] = function(reader)
		return
	end
	self.midToReturnMessageReader[65096287] = function(reader)
		return
	end
	self.midToReturnMessageReader[65096709] = function(reader)
		return
	end
	self.midToReturnMessageReader[65098587] = function(reader)
		return
	end
	self.midToReturnMessageReader[65101071] = function(reader)
		return
	end
	self.midToReturnMessageReader[65104800] = function(reader)
		return
	end
	self.midToReturnMessageReader[65108122] = function(reader)
		return
	end
	self.midToReturnMessageReader[65108954] = function(reader)
		return
	end
	self.midToReturnMessageReader[65114298] = function(reader)
		return
	end
	self.midToReturnMessageReader[65118918] = function(reader)
		return
	end
	self.midToReturnMessageReader[65119414] = function(reader)
		local r0 = reader:ReadBoolean()

		return r0
	end
	self.midToReturnMessageReader[65121965] = function(reader)
		return
	end
	self.midToReturnMessageReader[65124630] = function(reader)
		local r0 = Base.ReadList(reader, function(r)
			return r:ReadByte()
		end)

		return r0
	end
	self.midToReturnMessageReader[65132412] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[26])

		return r0
	end
	self.midToReturnMessageReader[65133346] = function(reader)
		return
	end
	self.midToReturnMessageReader[65134906] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[26])

		return r0
	end
	self.midToReturnMessageReader[65140892] = function(reader)
		local r0 = Base.ReadList(reader, function(r)
			return r:ReadUInt64()
		end)

		return r0
	end
	self.midToReturnMessageReader[65144411] = function(reader)
		return
	end
	self.midToReturnMessageReader[65147493] = function(reader)
		return
	end
	self.midToReturnMessageReader[65150235] = function(reader)
		return
	end
	self.midToReturnMessageReader[65152194] = function(reader)
		return
	end
	self.midToReturnMessageReader[65168835] = function(reader)
		return
	end
	self.midToReturnMessageReader[65169491] = function(reader)
		return
	end
	self.midToReturnMessageReader[65170078] = function(reader)
		return
	end
	self.midToReturnMessageReader[65181256] = function(reader)
		return
	end
	self.midToReturnMessageReader[65182253] = function(reader)
		return
	end
	self.midToReturnMessageReader[65182984] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[26])

		return r0
	end
	self.midToReturnMessageReader[65185876] = function(reader)
		return
	end
	self.midToReturnMessageReader[65189868] = function(reader)
		return
	end
	self.midToReturnMessageReader[65190145] = function(reader)
		return
	end
	self.midToReturnMessageReader[65195789] = function(reader)
		return
	end
	self.midToReturnMessageReader[65202950] = function(reader)
		local r0 = Base.ReadDict(reader, function(r)
			return r:ReadInt32()
		end, function(r)
			return Base.ReadComplex(r, Auto.Reader[196])
		end)

		return r0
	end
	self.midToReturnMessageReader[65204180] = function(reader)
		return
	end
	self.midToReturnMessageReader[65204185] = function(reader)
		return
	end
	self.midToReturnMessageReader[65207901] = function(reader)
		return
	end
	self.midToReturnMessageReader[65208444] = function(reader)
		return
	end
	self.midToReturnMessageReader[65209096] = function(reader)
		return
	end
	self.midToReturnMessageReader[65210905] = function(reader)
		return
	end
	self.midToReturnMessageReader[65210931] = function(reader)
		return
	end
	self.midToReturnMessageReader[65213448] = function(reader)
		return
	end
	self.midToReturnMessageReader[65215051] = function(reader)
		return
	end
	self.midToReturnMessageReader[65215225] = function(reader)
		return
	end
	self.midToReturnMessageReader[65215272] = function(reader)
		return
	end
	self.midToReturnMessageReader[65216824] = function(reader)
		local r0 = Base.ReadList(reader, function(r)
			return r:ReadUInt32()
		end)

		return r0
	end
	self.midToReturnMessageReader[65218093] = function(reader)
		return
	end
	self.midToReturnMessageReader[65221859] = function(reader)
		local r0 = reader:ReadBoolean()

		return r0
	end
	self.midToReturnMessageReader[65223564] = function(reader)
		local r0 = reader:ReadString()

		return r0
	end
	self.midToReturnMessageReader[65226371] = function(reader)
		return
	end
	self.midToReturnMessageReader[65230026] = function(reader)
		return
	end
	self.midToReturnMessageReader[65231464] = function(reader)
		return
	end
	self.midToReturnMessageReader[65237431] = function(reader)
		local r0 = Base.ReadList(reader, function(r)
			return r:ReadUInt32()
		end)

		return r0
	end
	self.midToReturnMessageReader[65245525] = function(reader)
		local r0 = reader:ReadString()

		return r0
	end
	self.midToReturnMessageReader[65246345] = function(reader)
		return
	end
	self.midToReturnMessageReader[65260296] = function(reader)
		return
	end
	self.midToReturnMessageReader[65264610] = function(reader)
		return
	end
	self.midToReturnMessageReader[65265180] = function(reader)
		return
	end
	self.midToReturnMessageReader[65266230] = function(reader)
		return
	end
	self.midToReturnMessageReader[65267267] = function(reader)
		return
	end
	self.midToReturnMessageReader[65273187] = function(reader)
		return
	end
	self.midToReturnMessageReader[65273364] = function(reader)
		return
	end
	self.midToReturnMessageReader[65273481] = function(reader)
		return
	end
	self.midToReturnMessageReader[65279736] = function(reader)
		return
	end
	self.midToReturnMessageReader[65279843] = function(reader)
		return
	end
	self.midToReturnMessageReader[65279974] = function(reader)
		return
	end
	self.midToReturnMessageReader[65281627] = function(reader)
		return
	end
	self.midToReturnMessageReader[65284016] = function(reader)
		return
	end
	self.midToReturnMessageReader[65289161] = function(reader)
		return
	end
	self.midToReturnMessageReader[65297057] = function(reader)
		return
	end
	self.midToReturnMessageReader[65308960] = function(reader)
		return
	end
	self.midToReturnMessageReader[65311046] = function(reader)
		return
	end
	self.midToReturnMessageReader[65312053] = function(reader)
		return
	end
	self.midToReturnMessageReader[65314806] = function(reader)
		return
	end
	self.midToReturnMessageReader[65323507] = function(reader)
		return
	end
	self.midToReturnMessageReader[65329084] = function(reader)
		return
	end
	self.midToReturnMessageReader[65334927] = function(reader)
		return
	end
	self.midToReturnMessageReader[65337098] = function(reader)
		return
	end
	self.midToReturnMessageReader[65340852] = function(reader)
		return
	end
	self.midToReturnMessageReader[65353454] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[26])

		return r0
	end
	self.midToReturnMessageReader[65362710] = function(reader)
		return
	end
	self.midToReturnMessageReader[65369037] = function(reader)
		return
	end
	self.midToReturnMessageReader[65372367] = function(reader)
		return
	end
	self.midToReturnMessageReader[65372780] = function(reader)
		return
	end
	self.midToReturnMessageReader[65376578] = function(reader)
		local r0 = reader:ReadString()

		return r0
	end
	self.midToReturnMessageReader[65377086] = function(reader)
		local r0 = reader:ReadString()

		return r0
	end
	self.midToReturnMessageReader[65377554] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[197])

		return r0
	end
	self.midToReturnMessageReader[65379944] = function(reader)
		return
	end
	self.midToReturnMessageReader[65380746] = function(reader)
		return
	end
	self.midToReturnMessageReader[65382432] = function(reader)
		return
	end
	self.midToReturnMessageReader[65386400] = function(reader)
		return
	end
	self.midToReturnMessageReader[65390781] = function(reader)
		return
	end
	self.midToReturnMessageReader[65391416] = function(reader)
		return
	end
	self.midToReturnMessageReader[65391808] = function(reader)
		return
	end
	self.midToReturnMessageReader[65392701] = function(reader)
		return
	end
	self.midToReturnMessageReader[65395476] = function(reader)
		return
	end
	self.midToReturnMessageReader[65399494] = function(reader)
		return
	end
	self.midToReturnMessageReader[65404916] = function(reader)
		return
	end
	self.midToReturnMessageReader[65406621] = function(reader)
		return
	end
	self.midToReturnMessageReader[65407638] = function(reader)
		return
	end
	self.midToReturnMessageReader[65413346] = function(reader)
		return
	end
	self.midToReturnMessageReader[65414320] = function(reader)
		return
	end
	self.midToReturnMessageReader[65420056] = function(reader)
		return
	end
	self.midToReturnMessageReader[65429134] = function(reader)
		return
	end
	self.midToReturnMessageReader[65430106] = function(reader)
		return
	end
	self.midToReturnMessageReader[65436798] = function(reader)
		return
	end
	self.midToReturnMessageReader[65438884] = function(reader)
		return
	end
	self.midToReturnMessageReader[65439161] = function(reader)
		return
	end
	self.midToReturnMessageReader[65441589] = function(reader)
		return
	end
	self.midToReturnMessageReader[65443742] = function(reader)
		return
	end
	self.midToReturnMessageReader[65443953] = function(reader)
		return
	end
	self.midToReturnMessageReader[65445215] = function(reader)
		return
	end
	self.midToReturnMessageReader[65446537] = function(reader)
		return
	end
	self.midToReturnMessageReader[65449498] = function(reader)
		return
	end
	self.midToReturnMessageReader[65456979] = function(reader)
		return
	end
	self.midToReturnMessageReader[65461786] = function(reader)
		return
	end
	self.midToReturnMessageReader[65462176] = function(reader)
		local r0 = reader:ReadString()

		return r0
	end
	self.midToReturnMessageReader[65463427] = function(reader)
		return
	end
	self.midToReturnMessageReader[65464517] = function(reader)
		return
	end
	self.midToReturnMessageReader[65467218] = function(reader)
		return
	end
	self.midToReturnMessageReader[65468265] = function(reader)
		return
	end
	self.midToReturnMessageReader[65469249] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[67])

		return r0
	end
	self.midToReturnMessageReader[65478579] = function(reader)
		return
	end
	self.midToReturnMessageReader[65485749] = function(reader)
		return
	end
	self.midToReturnMessageReader[65491052] = function(reader)
		return
	end
	self.midToReturnMessageReader[65494338] = function(reader)
		return
	end
	self.midToReturnMessageReader[65495831] = function(reader)
		return
	end
	self.midToReturnMessageReader[65497027] = function(reader)
		return
	end
	self.midToReturnMessageReader[65502467] = function(reader)
		return
	end
	self.midToReturnMessageReader[65503090] = function(reader)
		return
	end
	self.midToReturnMessageReader[65506393] = function(reader)
		return
	end
	self.midToReturnMessageReader[65509860] = function(reader)
		return
	end
	self.midToReturnMessageReader[65512931] = function(reader)
		return
	end
	self.midToReturnMessageReader[65517463] = function(reader)
		return
	end
	self.midToReturnMessageReader[65523224] = function(reader)
		return
	end
	self.midToReturnMessageReader[65524579] = function(reader)
		return
	end
	self.midToReturnMessageReader[65525470] = function(reader)
		return
	end
	self.midToReturnMessageReader[65526020] = function(reader)
		return
	end
	self.midToReturnMessageReader[65526982] = function(reader)
		return
	end
	self.midToReturnMessageReader[65530584] = function(reader)
		return
	end
	self.midToReturnMessageReader[65540926] = function(reader)
		return
	end
	self.midToReturnMessageReader[65545868] = function(reader)
		return
	end
	self.midToReturnMessageReader[65551008] = function(reader)
		return
	end
	self.midToReturnMessageReader[65556139] = function(reader)
		return
	end
	self.midToReturnMessageReader[65558563] = function(reader)
		return
	end
	self.midToReturnMessageReader[65559175] = function(reader)
		return
	end
	self.midToReturnMessageReader[65560136] = function(reader)
		return
	end
	self.midToReturnMessageReader[65560419] = function(reader)
		return
	end
	self.midToReturnMessageReader[65566155] = function(reader)
		return
	end
	self.midToReturnMessageReader[65566553] = function(reader)
		return
	end
	self.midToReturnMessageReader[65570482] = function(reader)
		return
	end
	self.midToReturnMessageReader[65571728] = function(reader)
		return
	end
	self.midToReturnMessageReader[65575794] = function(reader)
		return
	end
	self.midToReturnMessageReader[65576740] = function(reader)
		return
	end
	self.midToReturnMessageReader[65581047] = function(reader)
		return
	end
	self.midToReturnMessageReader[65591358] = function(reader)
		return
	end
	self.midToReturnMessageReader[65592073] = function(reader)
		return
	end
	self.midToReturnMessageReader[65593995] = function(reader)
		return
	end
	self.midToReturnMessageReader[65595170] = function(reader)
		return
	end
	self.midToReturnMessageReader[65595444] = function(reader)
		return
	end
	self.midToReturnMessageReader[65596071] = function(reader)
		return
	end
	self.midToReturnMessageReader[65596200] = function(reader)
		return
	end
	self.midToReturnMessageReader[65597881] = function(reader)
		return
	end
	self.midToReturnMessageReader[65598618] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[60])

		return r0
	end
	self.midToReturnMessageReader[65599345] = function(reader)
		return
	end
	self.midToReturnMessageReader[65603390] = function(reader)
		return
	end
	self.midToReturnMessageReader[65605236] = function(reader)
		return
	end
	self.midToReturnMessageReader[65615099] = function(reader)
		return
	end
	self.midToReturnMessageReader[65617522] = function(reader)
		return
	end
	self.midToReturnMessageReader[65618312] = function(reader)
		return
	end
	self.midToReturnMessageReader[65619866] = function(reader)
		return
	end
	self.midToReturnMessageReader[65625400] = function(reader)
		return
	end
	self.midToReturnMessageReader[65625612] = function(reader)
		return
	end
	self.midToReturnMessageReader[65632163] = function(reader)
		return
	end
	self.midToReturnMessageReader[65632292] = function(reader)
		return
	end
	self.midToReturnMessageReader[65635766] = function(reader)
		return
	end
	self.midToReturnMessageReader[65638681] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[198])

		return r0
	end
	self.midToReturnMessageReader[65639345] = function(reader)
		local r0 = reader:ReadString()

		return r0
	end
	self.midToReturnMessageReader[65640597] = function(reader)
		return
	end
	self.midToReturnMessageReader[65644685] = function(reader)
		return
	end
	self.midToReturnMessageReader[65645298] = function(reader)
		return
	end
	self.midToReturnMessageReader[65646756] = function(reader)
		return
	end
	self.midToReturnMessageReader[65647387] = function(reader)
		return
	end
	self.midToReturnMessageReader[65649571] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[26])

		return r0
	end
	self.midToReturnMessageReader[65651064] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[199])

		return r0
	end
	self.midToReturnMessageReader[65652742] = function(reader)
		return
	end
	self.midToReturnMessageReader[65653801] = function(reader)
		return
	end
	self.midToReturnMessageReader[65663728] = function(reader)
		return
	end
	self.midToReturnMessageReader[65671040] = function(reader)
		return
	end
	self.midToReturnMessageReader[65677007] = function(reader)
		return
	end
	self.midToReturnMessageReader[65677459] = function(reader)
		return
	end
	self.midToReturnMessageReader[65685417] = function(reader)
		return
	end
	self.midToReturnMessageReader[65685566] = function(reader)
		return
	end
	self.midToReturnMessageReader[65688020] = function(reader)
		return
	end
	self.midToReturnMessageReader[65690734] = function(reader)
		return
	end
	self.midToReturnMessageReader[65690763] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[52])

		return r0
	end
	self.midToReturnMessageReader[65693006] = function(reader)
		return
	end
	self.midToReturnMessageReader[65702352] = function(reader)
		return
	end
	self.midToReturnMessageReader[65702733] = function(reader)
		return
	end
	self.midToReturnMessageReader[65703979] = function(reader)
		return
	end
	self.midToReturnMessageReader[65705232] = function(reader)
		return
	end
	self.midToReturnMessageReader[65705980] = function(reader)
		return
	end
	self.midToReturnMessageReader[65706033] = function(reader)
		return
	end
	self.midToReturnMessageReader[65707845] = function(reader)
		return
	end
	self.midToReturnMessageReader[65708448] = function(reader)
		return
	end
	self.midToReturnMessageReader[65712268] = function(reader)
		return
	end
	self.midToReturnMessageReader[65712806] = function(reader)
		return
	end
	self.midToReturnMessageReader[65722093] = function(reader)
		return
	end
	self.midToReturnMessageReader[65726969] = function(reader)
		return
	end
	self.midToReturnMessageReader[65730933] = function(reader)
		return
	end
	self.midToReturnMessageReader[65732120] = function(reader)
		return
	end
	self.midToReturnMessageReader[65736272] = function(reader)
		return
	end
	self.midToReturnMessageReader[65737938] = function(reader)
		return
	end
	self.midToReturnMessageReader[65741697] = function(reader)
		return
	end
	self.midToReturnMessageReader[65746119] = function(reader)
		local r0 = reader:ReadString()

		return r0
	end
	self.midToReturnMessageReader[65747705] = function(reader)
		local r0 = reader:ReadUInt32()

		return r0
	end
	self.midToReturnMessageReader[65747804] = function(reader)
		return
	end
	self.midToReturnMessageReader[65747911] = function(reader)
		return
	end
	self.midToReturnMessageReader[65755222] = function(reader)
		return
	end
	self.midToReturnMessageReader[65755917] = function(reader)
		return
	end
	self.midToReturnMessageReader[65762448] = function(reader)
		return
	end
	self.midToReturnMessageReader[65764617] = function(reader)
		return
	end
	self.midToReturnMessageReader[65766648] = function(reader)
		return
	end
	self.midToReturnMessageReader[65772361] = function(reader)
		return
	end
	self.midToReturnMessageReader[65772419] = function(reader)
		return
	end
	self.midToReturnMessageReader[65777431] = function(reader)
		return
	end
	self.midToReturnMessageReader[65780358] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[26])

		return r0
	end
	self.midToReturnMessageReader[65783579] = function(reader)
		return
	end
	self.midToReturnMessageReader[65783857] = function(reader)
		return
	end
	self.midToReturnMessageReader[65785691] = function(reader)
		return
	end
	self.midToReturnMessageReader[65790231] = function(reader)
		return
	end
	self.midToReturnMessageReader[65790327] = function(reader)
		return
	end
	self.midToReturnMessageReader[65792251] = function(reader)
		return
	end
	self.midToReturnMessageReader[65792663] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[175])

		return r0
	end
	self.midToReturnMessageReader[65796351] = function(reader)
		return
	end
	self.midToReturnMessageReader[65797055] = function(reader)
		return
	end
	self.midToReturnMessageReader[65797641] = function(reader)
		return
	end
	self.midToReturnMessageReader[65804103] = function(reader)
		return
	end
	self.midToReturnMessageReader[65806104] = function(reader)
		return
	end
	self.midToReturnMessageReader[65809134] = function(reader)
		return
	end
	self.midToReturnMessageReader[65810363] = function(reader)
		return
	end
	self.midToReturnMessageReader[65810955] = function(reader)
		return
	end
	self.midToReturnMessageReader[65811014] = function(reader)
		return
	end
	self.midToReturnMessageReader[65811793] = function(reader)
		return
	end
	self.midToReturnMessageReader[65816242] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[96])

		return r0
	end
	self.midToReturnMessageReader[65817734] = function(reader)
		return
	end
	self.midToReturnMessageReader[65822116] = function(reader)
		return
	end
	self.midToReturnMessageReader[65827989] = function(reader)
		return
	end
	self.midToReturnMessageReader[65833574] = function(reader)
		local r0 = Base.ReadList(reader, function(r)
			return Base.ReadStruct(r, Auto.Reader[200])
		end)

		return r0
	end
	self.midToReturnMessageReader[65833774] = function(reader)
		return
	end
	self.midToReturnMessageReader[65837587] = function(reader)
		return
	end
	self.midToReturnMessageReader[65840979] = function(reader)
		return
	end
	self.midToReturnMessageReader[65847449] = function(reader)
		return
	end
	self.midToReturnMessageReader[65848277] = function(reader)
		return
	end
	self.midToReturnMessageReader[65850298] = function(reader)
		return
	end
	self.midToReturnMessageReader[65853040] = function(reader)
		return
	end
	self.midToReturnMessageReader[65853628] = function(reader)
		return
	end
	self.midToReturnMessageReader[65856188] = function(reader)
		return
	end
	self.midToReturnMessageReader[65858808] = function(reader)
		return
	end
	self.midToReturnMessageReader[65860125] = function(reader)
		return
	end
	self.midToReturnMessageReader[65863697] = function(reader)
		return
	end
	self.midToReturnMessageReader[65867865] = function(reader)
		local r0 = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[175])
		end)

		return r0
	end
	self.midToReturnMessageReader[65869155] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[95])

		return r0
	end
	self.midToReturnMessageReader[65873771] = function(reader)
		return
	end
	self.midToReturnMessageReader[65875339] = function(reader)
		return
	end
	self.midToReturnMessageReader[65878525] = function(reader)
		return
	end
	self.midToReturnMessageReader[65884297] = function(reader)
		return
	end
	self.midToReturnMessageReader[65890668] = function(reader)
		return
	end
	self.midToReturnMessageReader[65892033] = function(reader)
		return
	end
	self.midToReturnMessageReader[65896033] = function(reader)
		local r0 = Base.ReadDict(reader, function(r)
			return r:ReadInt32()
		end, function(r)
			return r:ReadString()
		end)

		return r0
	end
	self.midToReturnMessageReader[65900194] = function(reader)
		return
	end
	self.midToReturnMessageReader[65901855] = function(reader)
		return
	end
	self.midToReturnMessageReader[65902388] = function(reader)
		return
	end
	self.midToReturnMessageReader[65903509] = function(reader)
		local r0 = Auto.Dispatch[164](reader)

		return r0
	end
	self.midToReturnMessageReader[65905195] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[201])

		return r0
	end
	self.midToReturnMessageReader[65906111] = function(reader)
		return
	end
	self.midToReturnMessageReader[65914389] = function(reader)
		return
	end
	self.midToReturnMessageReader[65918200] = function(reader)
		return
	end
	self.midToReturnMessageReader[65922398] = function(reader)
		return
	end
	self.midToReturnMessageReader[65923760] = function(reader)
		return
	end
	self.midToReturnMessageReader[65928161] = function(reader)
		return
	end
	self.midToReturnMessageReader[65934456] = function(reader)
		return
	end
	self.midToReturnMessageReader[65934676] = function(reader)
		return
	end
	self.midToReturnMessageReader[65935574] = function(reader)
		return
	end
	self.midToReturnMessageReader[65939542] = function(reader)
		local r0 = Auto.Dispatch[164](reader)

		return r0
	end
	self.midToReturnMessageReader[65944304] = function(reader)
		return
	end
	self.midToReturnMessageReader[65947231] = function(reader)
		return
	end
	self.midToReturnMessageReader[65949719] = function(reader)
		return
	end
	self.midToReturnMessageReader[65950100] = function(reader)
		local r0 = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[154])
		end)

		return r0
	end
	self.midToReturnMessageReader[65952203] = function(reader)
		return
	end
	self.midToReturnMessageReader[65954775] = function(reader)
		return
	end
	self.midToReturnMessageReader[65955298] = function(reader)
		return
	end
	self.midToReturnMessageReader[65963401] = function(reader)
		return
	end
	self.midToReturnMessageReader[65964139] = function(reader)
		return
	end
	self.midToReturnMessageReader[65967090] = function(reader)
		return
	end
	self.midToReturnMessageReader[65968747] = function(reader)
		return
	end
	self.midToReturnMessageReader[65970812] = function(reader)
		return
	end
	self.midToReturnMessageReader[65971803] = function(reader)
		return
	end
	self.midToReturnMessageReader[65973190] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[31])

		return r0
	end
	self.midToReturnMessageReader[65982302] = function(reader)
		return
	end
	self.midToReturnMessageReader[65984636] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[31])

		return r0
	end
	self.midToReturnMessageReader[65997229] = function(reader)
		return
	end
	self.midToReturnMessageReader[67007044] = function(reader)
		local r0 = reader:ReadBoolean()

		return r0
	end
	self.midToReturnMessageReader[67008359] = function(reader)
		local r0 = reader:ReadUInt64()

		return r0
	end
	self.midToReturnMessageReader[67041455] = function(reader)
		return
	end
	self.midToReturnMessageReader[67045516] = function(reader)
		return
	end
	self.midToReturnMessageReader[67064074] = function(reader)
		return
	end
	self.midToReturnMessageReader[67074515] = function(reader)
		return
	end
	self.midToReturnMessageReader[67083392] = function(reader)
		return
	end
	self.midToReturnMessageReader[67095977] = function(reader)
		local r0 = reader:ReadDouble()

		return r0
	end
	self.midToReturnMessageReader[67098231] = function(reader)
		return
	end
	self.midToReturnMessageReader[67098432] = function(reader)
		return
	end
	self.midToReturnMessageReader[67099069] = function(reader)
		return
	end
	self.midToReturnMessageReader[67099743] = function(reader)
		local r0 = Base.ReadList(reader, function(r)
			return Base.ReadStruct(r, Auto.Reader[202])
		end)

		return r0
	end
	self.midToReturnMessageReader[67105495] = function(reader)
		return
	end
	self.midToReturnMessageReader[67109434] = function(reader)
		return
	end
	self.midToReturnMessageReader[67123939] = function(reader)
		return
	end
	self.midToReturnMessageReader[67124809] = function(reader)
		return
	end
	self.midToReturnMessageReader[67139214] = function(reader)
		return
	end
	self.midToReturnMessageReader[67142474] = function(reader)
		return
	end
	self.midToReturnMessageReader[67143321] = function(reader)
		return
	end
	self.midToReturnMessageReader[67146828] = function(reader)
		return
	end
	self.midToReturnMessageReader[67147023] = function(reader)
		return
	end
	self.midToReturnMessageReader[67152886] = function(reader)
		return
	end
	self.midToReturnMessageReader[67159064] = function(reader)
		return
	end
	self.midToReturnMessageReader[67159283] = function(reader)
		return
	end
	self.midToReturnMessageReader[67176799] = function(reader)
		return
	end
	self.midToReturnMessageReader[67184998] = function(reader)
		return
	end
	self.midToReturnMessageReader[67186828] = function(reader)
		return
	end
	self.midToReturnMessageReader[67192821] = function(reader)
		return
	end
	self.midToReturnMessageReader[67197884] = function(reader)
		return
	end
	self.midToReturnMessageReader[67198041] = function(reader)
		return
	end
	self.midToReturnMessageReader[67201021] = function(reader)
		return
	end
	self.midToReturnMessageReader[67202028] = function(reader)
		return
	end
	self.midToReturnMessageReader[67204636] = function(reader)
		return
	end
	self.midToReturnMessageReader[67205756] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[203])

		return r0
	end
	self.midToReturnMessageReader[67208511] = function(reader)
		return
	end
	self.midToReturnMessageReader[67209016] = function(reader)
		return
	end
	self.midToReturnMessageReader[67214775] = function(reader)
		return
	end
	self.midToReturnMessageReader[67218323] = function(reader)
		return
	end
	self.midToReturnMessageReader[67223780] = function(reader)
		return
	end
	self.midToReturnMessageReader[67226682] = function(reader)
		return
	end
	self.midToReturnMessageReader[67227348] = function(reader)
		return
	end
	self.midToReturnMessageReader[67239192] = function(reader)
		return
	end
	self.midToReturnMessageReader[67244103] = function(reader)
		return
	end
	self.midToReturnMessageReader[67267019] = function(reader)
		return
	end
	self.midToReturnMessageReader[67270847] = function(reader)
		return
	end
	self.midToReturnMessageReader[67271577] = function(reader)
		return
	end
	self.midToReturnMessageReader[67273088] = function(reader)
		return
	end
	self.midToReturnMessageReader[67291360] = function(reader)
		return
	end
	self.midToReturnMessageReader[67292667] = function(reader)
		return
	end
	self.midToReturnMessageReader[67292698] = function(reader)
		return
	end
	self.midToReturnMessageReader[67293311] = function(reader)
		return
	end
	self.midToReturnMessageReader[67297099] = function(reader)
		return
	end
	self.midToReturnMessageReader[67297986] = function(reader)
		return
	end
	self.midToReturnMessageReader[67298863] = function(reader)
		return
	end
	self.midToReturnMessageReader[67308174] = function(reader)
		local r0 = reader:ReadUInt64()

		return r0
	end
	self.midToReturnMessageReader[67316543] = function(reader)
		return
	end
	self.midToReturnMessageReader[67318577] = function(reader)
		return
	end
	self.midToReturnMessageReader[67323381] = function(reader)
		return
	end
	self.midToReturnMessageReader[67330715] = function(reader)
		return
	end
	self.midToReturnMessageReader[67341642] = function(reader)
		return
	end
	self.midToReturnMessageReader[67346577] = function(reader)
		return
	end
	self.midToReturnMessageReader[67348887] = function(reader)
		return
	end
	self.midToReturnMessageReader[67360553] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[204])

		return r0
	end
	self.midToReturnMessageReader[67360678] = function(reader)
		return
	end
	self.midToReturnMessageReader[67363519] = function(reader)
		local r0 = reader:ReadUInt64()

		return r0
	end
	self.midToReturnMessageReader[67363678] = function(reader)
		return
	end
	self.midToReturnMessageReader[67373222] = function(reader)
		return
	end
	self.midToReturnMessageReader[67375035] = function(reader)
		return
	end
	self.midToReturnMessageReader[67376535] = function(reader)
		return
	end
	self.midToReturnMessageReader[67377199] = function(reader)
		local r0 = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[143])
		end)

		return r0
	end
	self.midToReturnMessageReader[67377834] = function(reader)
		return
	end
	self.midToReturnMessageReader[67379649] = function(reader)
		return
	end
	self.midToReturnMessageReader[67382522] = function(reader)
		local r0 = reader:ReadByte()

		return r0
	end
	self.midToReturnMessageReader[67387168] = function(reader)
		return
	end
	self.midToReturnMessageReader[67389088] = function(reader)
		local r0 = reader:ReadUInt64()

		return r0
	end
	self.midToReturnMessageReader[67393372] = function(reader)
		return
	end
	self.midToReturnMessageReader[67394158] = function(reader)
		return
	end
	self.midToReturnMessageReader[67406281] = function(reader)
		return
	end
	self.midToReturnMessageReader[67407557] = function(reader)
		return
	end
	self.midToReturnMessageReader[67416493] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[205])

		return r0
	end
	self.midToReturnMessageReader[67419674] = function(reader)
		return
	end
	self.midToReturnMessageReader[67422219] = function(reader)
		return
	end
	self.midToReturnMessageReader[67423021] = function(reader)
		return
	end
	self.midToReturnMessageReader[67427170] = function(reader)
		return
	end
	self.midToReturnMessageReader[67435111] = function(reader)
		return
	end
	self.midToReturnMessageReader[67435562] = function(reader)
		return
	end
	self.midToReturnMessageReader[67437976] = function(reader)
		local r0 = reader:ReadUInt64()

		return r0
	end
	self.midToReturnMessageReader[67439089] = function(reader)
		return
	end
	self.midToReturnMessageReader[67441479] = function(reader)
		return
	end
	self.midToReturnMessageReader[67459847] = function(reader)
		return
	end
	self.midToReturnMessageReader[67478318] = function(reader)
		return
	end
	self.midToReturnMessageReader[67485381] = function(reader)
		return
	end
	self.midToReturnMessageReader[67490320] = function(reader)
		local r0 = reader:ReadUInt64()

		return r0
	end
	self.midToReturnMessageReader[67493272] = function(reader)
		return
	end
	self.midToReturnMessageReader[67500700] = function(reader)
		local r0 = reader:ReadUInt64()

		return r0
	end
	self.midToReturnMessageReader[67502597] = function(reader)
		return
	end
	self.midToReturnMessageReader[67509512] = function(reader)
		local r0 = reader:ReadSingle()

		return r0
	end
	self.midToReturnMessageReader[67511914] = function(reader)
		return
	end
	self.midToReturnMessageReader[67513965] = function(reader)
		return
	end
	self.midToReturnMessageReader[67516697] = function(reader)
		return
	end
	self.midToReturnMessageReader[67527445] = function(reader)
		return
	end
	self.midToReturnMessageReader[67540798] = function(reader)
		return
	end
	self.midToReturnMessageReader[67547275] = function(reader)
		return
	end
	self.midToReturnMessageReader[67550410] = function(reader)
		return
	end
	self.midToReturnMessageReader[67550827] = function(reader)
		local r0 = reader:ReadUInt64()

		return r0
	end
	self.midToReturnMessageReader[67551715] = function(reader)
		return
	end
	self.midToReturnMessageReader[67564631] = function(reader)
		return
	end
	self.midToReturnMessageReader[67564989] = function(reader)
		return
	end
	self.midToReturnMessageReader[67570847] = function(reader)
		return
	end
	self.midToReturnMessageReader[67573380] = function(reader)
		return
	end
	self.midToReturnMessageReader[67575414] = function(reader)
		return
	end
	self.midToReturnMessageReader[67575770] = function(reader)
		return
	end
	self.midToReturnMessageReader[67582286] = function(reader)
		local r0 = reader:ReadUInt64()

		return r0
	end
	self.midToReturnMessageReader[67582912] = function(reader)
		local r0 = reader:ReadUInt64()

		return r0
	end
	self.midToReturnMessageReader[67586560] = function(reader)
		return
	end
	self.midToReturnMessageReader[67589596] = function(reader)
		local r0 = reader:ReadUInt64()

		return r0
	end
	self.midToReturnMessageReader[67592111] = function(reader)
		local r0 = reader:ReadUInt64()

		return r0
	end
	self.midToReturnMessageReader[67594337] = function(reader)
		return
	end
	self.midToReturnMessageReader[67596088] = function(reader)
		local r0 = Base.ReadList(reader, function(r)
			return r:ReadUInt32()
		end)

		return r0
	end
	self.midToReturnMessageReader[67598658] = function(reader)
		return
	end
	self.midToReturnMessageReader[67599769] = function(reader)
		local r0 = reader:ReadUInt64()

		return r0
	end
	self.midToReturnMessageReader[67599974] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[0])

		return r0
	end
	self.midToReturnMessageReader[67600709] = function(reader)
		return
	end
	self.midToReturnMessageReader[67602964] = function(reader)
		local r0 = reader:ReadUInt64()

		return r0
	end
	self.midToReturnMessageReader[67610605] = function(reader)
		local r0 = reader:ReadUInt64()

		return r0
	end
	self.midToReturnMessageReader[67633578] = function(reader)
		local r0 = reader:ReadUInt32()

		return r0
	end
	self.midToReturnMessageReader[67655478] = function(reader)
		return
	end
	self.midToReturnMessageReader[67656882] = function(reader)
		return
	end
	self.midToReturnMessageReader[67662900] = function(reader)
		return
	end
	self.midToReturnMessageReader[67666820] = function(reader)
		return
	end
	self.midToReturnMessageReader[67670049] = function(reader)
		local r0 = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[206])
		end)

		return r0
	end
	self.midToReturnMessageReader[67682439] = function(reader)
		local r0 = reader:ReadUInt64()

		return r0
	end
	self.midToReturnMessageReader[67686149] = function(reader)
		return
	end
	self.midToReturnMessageReader[67696163] = function(reader)
		return
	end
	self.midToReturnMessageReader[67698208] = function(reader)
		return
	end
	self.midToReturnMessageReader[67698680] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[207])

		return r0
	end
	self.midToReturnMessageReader[67706483] = function(reader)
		return
	end
	self.midToReturnMessageReader[67708360] = function(reader)
		return
	end
	self.midToReturnMessageReader[67709377] = function(reader)
		return
	end
	self.midToReturnMessageReader[67716433] = function(reader)
		return
	end
	self.midToReturnMessageReader[67721106] = function(reader)
		return
	end
	self.midToReturnMessageReader[67723554] = function(reader)
		return
	end
	self.midToReturnMessageReader[67724888] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[208])

		return r0
	end
	self.midToReturnMessageReader[67729767] = function(reader)
		return
	end
	self.midToReturnMessageReader[67729893] = function(reader)
		return
	end
	self.midToReturnMessageReader[67736468] = function(reader)
		return
	end
	self.midToReturnMessageReader[67744578] = function(reader)
		return
	end
	self.midToReturnMessageReader[67751744] = function(reader)
		return
	end
	self.midToReturnMessageReader[67753718] = function(reader)
		return
	end
	self.midToReturnMessageReader[67753833] = function(reader)
		return
	end
	self.midToReturnMessageReader[67782549] = function(reader)
		return
	end
	self.midToReturnMessageReader[67784355] = function(reader)
		return
	end
	self.midToReturnMessageReader[67788013] = function(reader)
		return
	end
	self.midToReturnMessageReader[67790322] = function(reader)
		return
	end
	self.midToReturnMessageReader[67793028] = function(reader)
		return
	end
	self.midToReturnMessageReader[67795266] = function(reader)
		return
	end
	self.midToReturnMessageReader[67796172] = function(reader)
		return
	end
	self.midToReturnMessageReader[67796491] = function(reader)
		return
	end
	self.midToReturnMessageReader[67797896] = function(reader)
		return
	end
	self.midToReturnMessageReader[67799173] = function(reader)
		return
	end
	self.midToReturnMessageReader[67801269] = function(reader)
		return
	end
	self.midToReturnMessageReader[67803180] = function(reader)
		return
	end
	self.midToReturnMessageReader[67803481] = function(reader)
		return
	end
	self.midToReturnMessageReader[67803808] = function(reader)
		return
	end
	self.midToReturnMessageReader[67816059] = function(reader)
		return
	end
	self.midToReturnMessageReader[67820583] = function(reader)
		return
	end
	self.midToReturnMessageReader[67824055] = function(reader)
		return
	end
	self.midToReturnMessageReader[67843924] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[208])

		return r0
	end
	self.midToReturnMessageReader[67847807] = function(reader)
		return
	end
	self.midToReturnMessageReader[67857546] = function(reader)
		local r0 = Base.ReadList(reader, function(r)
			return Base.ReadStruct(r, Auto.Reader.UXVector3)
		end)

		return r0
	end
	self.midToReturnMessageReader[67865936] = function(reader)
		local r0 = reader:ReadUInt64()

		return r0
	end
	self.midToReturnMessageReader[67866416] = function(reader)
		return
	end
	self.midToReturnMessageReader[67870425] = function(reader)
		local r0 = Base.ReadList(reader, function(r)
			return r:ReadSingle()
		end)

		return r0
	end
	self.midToReturnMessageReader[67870867] = function(reader)
		return
	end
	self.midToReturnMessageReader[67873377] = function(reader)
		return
	end
	self.midToReturnMessageReader[67877988] = function(reader)
		return
	end
	self.midToReturnMessageReader[67882363] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[0])

		return r0
	end
	self.midToReturnMessageReader[67882560] = function(reader)
		return
	end
	self.midToReturnMessageReader[67911371] = function(reader)
		local r0 = reader:ReadByte()

		return r0
	end
	self.midToReturnMessageReader[67913564] = function(reader)
		return
	end
	self.midToReturnMessageReader[67924447] = function(reader)
		return
	end
	self.midToReturnMessageReader[67928941] = function(reader)
		local r0 = Base.ReadStruct(reader, Auto.Reader[209])

		return r0
	end
	self.midToReturnMessageReader[67936712] = function(reader)
		local r0 = reader:ReadUInt64()

		return r0
	end
	self.midToReturnMessageReader[67945135] = function(reader)
		return
	end
	self.midToReturnMessageReader[67953229] = function(reader)
		return
	end
	self.midToReturnMessageReader[67955196] = function(reader)
		return
	end
	self.midToReturnMessageReader[67961513] = function(reader)
		return
	end
	self.midToReturnMessageReader[67965115] = function(reader)
		return
	end
	self.midToReturnMessageReader[67965971] = function(reader)
		return
	end
	self.midToReturnMessageReader[67968069] = function(reader)
		return
	end
	self.midToReturnMessageReader[67972470] = function(reader)
		return
	end
	self.midToReturnMessageReader[67972627] = function(reader)
		return
	end
	self.midToReturnMessageReader[67983665] = function(reader)
		return
	end
	self.midToReturnMessageReader[67992584] = function(reader)
		local r0 = Base.ReadList(reader, function(r)
			return Base.ReadStruct(r, Auto.Reader[210])
		end)

		return r0
	end
	self.midToReturnMessageReader[69005334] = function(reader)
		return
	end
	self.midToReturnMessageReader[69006194] = function(reader)
		return
	end
	self.midToReturnMessageReader[69013530] = function(reader)
		return
	end
	self.midToReturnMessageReader[69017721] = function(reader)
		return
	end
	self.midToReturnMessageReader[69025080] = function(reader)
		return
	end
	self.midToReturnMessageReader[69035203] = function(reader)
		return
	end
	self.midToReturnMessageReader[69036846] = function(reader)
		return
	end
	self.midToReturnMessageReader[69041527] = function(reader)
		local r0 = reader:ReadUInt64()

		return r0
	end
	self.midToReturnMessageReader[69052894] = function(reader)
		return
	end
	self.midToReturnMessageReader[69057989] = function(reader)
		return
	end
	self.midToReturnMessageReader[69060993] = function(reader)
		return
	end
	self.midToReturnMessageReader[69066069] = function(reader)
		return
	end
	self.midToReturnMessageReader[69070187] = function(reader)
		return
	end
	self.midToReturnMessageReader[69080214] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[211])

		return r0
	end
	self.midToReturnMessageReader[69080368] = function(reader)
		return
	end
	self.midToReturnMessageReader[69081995] = function(reader)
		return
	end
	self.midToReturnMessageReader[69090248] = function(reader)
		return
	end
	self.midToReturnMessageReader[69090708] = function(reader)
		return
	end
	self.midToReturnMessageReader[69093606] = function(reader)
		return
	end
	self.midToReturnMessageReader[69095145] = function(reader)
		return
	end
	self.midToReturnMessageReader[69097153] = function(reader)
		return
	end
	self.midToReturnMessageReader[69099263] = function(reader)
		local r0 = reader:ReadString()

		return r0
	end
	self.midToReturnMessageReader[69102417] = function(reader)
		return
	end
	self.midToReturnMessageReader[69102646] = function(reader)
		return
	end
	self.midToReturnMessageReader[69110259] = function(reader)
		return
	end
	self.midToReturnMessageReader[69111473] = function(reader)
		return
	end
	self.midToReturnMessageReader[69122610] = function(reader)
		return
	end
	self.midToReturnMessageReader[69127481] = function(reader)
		return
	end
	self.midToReturnMessageReader[69139588] = function(reader)
		return
	end
	self.midToReturnMessageReader[69154474] = function(reader)
		return
	end
	self.midToReturnMessageReader[69154555] = function(reader)
		return
	end
	self.midToReturnMessageReader[69157046] = function(reader)
		return
	end
	self.midToReturnMessageReader[69164442] = function(reader)
		return
	end
	self.midToReturnMessageReader[69167882] = function(reader)
		return
	end
	self.midToReturnMessageReader[69172064] = function(reader)
		return
	end
	self.midToReturnMessageReader[69174690] = function(reader)
		return
	end
	self.midToReturnMessageReader[69177494] = function(reader)
		return
	end
	self.midToReturnMessageReader[69182657] = function(reader)
		return
	end
	self.midToReturnMessageReader[69186022] = function(reader)
		return
	end
	self.midToReturnMessageReader[69187036] = function(reader)
		return
	end
	self.midToReturnMessageReader[69188937] = function(reader)
		return
	end
	self.midToReturnMessageReader[69196510] = function(reader)
		return
	end
	self.midToReturnMessageReader[69209273] = function(reader)
		return
	end
	self.midToReturnMessageReader[69210324] = function(reader)
		return
	end
	self.midToReturnMessageReader[69213330] = function(reader)
		return
	end
	self.midToReturnMessageReader[69224316] = function(reader)
		return
	end
	self.midToReturnMessageReader[69224470] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[212])

		return r0
	end
	self.midToReturnMessageReader[69229240] = function(reader)
		local r0 = reader:ReadUInt64()

		return r0
	end
	self.midToReturnMessageReader[69242189] = function(reader)
		return
	end
	self.midToReturnMessageReader[69248402] = function(reader)
		return
	end
	self.midToReturnMessageReader[69249142] = function(reader)
		return
	end
	self.midToReturnMessageReader[69252846] = function(reader)
		return
	end
	self.midToReturnMessageReader[69257869] = function(reader)
		return
	end
	self.midToReturnMessageReader[69262166] = function(reader)
		return
	end
	self.midToReturnMessageReader[69262594] = function(reader)
		return
	end
	self.midToReturnMessageReader[69272665] = function(reader)
		return
	end
	self.midToReturnMessageReader[69283996] = function(reader)
		return
	end
	self.midToReturnMessageReader[69292406] = function(reader)
		local r0 = reader:ReadUInt64()

		return r0
	end
	self.midToReturnMessageReader[69292441] = function(reader)
		return
	end
	self.midToReturnMessageReader[69305197] = function(reader)
		return
	end
	self.midToReturnMessageReader[69312503] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[213])

		return r0
	end
	self.midToReturnMessageReader[69323141] = function(reader)
		return
	end
	self.midToReturnMessageReader[69327275] = function(reader)
		return
	end
	self.midToReturnMessageReader[69336692] = function(reader)
		return
	end
	self.midToReturnMessageReader[69338186] = function(reader)
		local r0 = reader:ReadUInt64()

		return r0
	end
	self.midToReturnMessageReader[69339388] = function(reader)
		return
	end
	self.midToReturnMessageReader[69340240] = function(reader)
		local r0 = Base.ReadList(reader, function(r)
			return r:ReadUInt64()
		end)

		return r0
	end
	self.midToReturnMessageReader[69341375] = function(reader)
		return
	end
	self.midToReturnMessageReader[69344043] = function(reader)
		return
	end
	self.midToReturnMessageReader[69346331] = function(reader)
		return
	end
	self.midToReturnMessageReader[69352884] = function(reader)
		return
	end
	self.midToReturnMessageReader[69360551] = function(reader)
		return
	end
	self.midToReturnMessageReader[69363476] = function(reader)
		return
	end
	self.midToReturnMessageReader[69370162] = function(reader)
		return
	end
	self.midToReturnMessageReader[69383316] = function(reader)
		return
	end
	self.midToReturnMessageReader[69384019] = function(reader)
		return
	end
	self.midToReturnMessageReader[69385902] = function(reader)
		return
	end
	self.midToReturnMessageReader[69395665] = function(reader)
		return
	end
	self.midToReturnMessageReader[69400919] = function(reader)
		return
	end
	self.midToReturnMessageReader[69407519] = function(reader)
		return
	end
	self.midToReturnMessageReader[69425561] = function(reader)
		return
	end
	self.midToReturnMessageReader[69425644] = function(reader)
		local r0 = reader:ReadUInt64()

		return r0
	end
	self.midToReturnMessageReader[69435013] = function(reader)
		return
	end
	self.midToReturnMessageReader[69448764] = function(reader)
		return
	end
	self.midToReturnMessageReader[69449002] = function(reader)
		return
	end
	self.midToReturnMessageReader[69450263] = function(reader)
		return
	end
	self.midToReturnMessageReader[69452998] = function(reader)
		return
	end
	self.midToReturnMessageReader[69453720] = function(reader)
		return
	end
	self.midToReturnMessageReader[69457570] = function(reader)
		return
	end
	self.midToReturnMessageReader[69464393] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[0])

		return r0
	end
	self.midToReturnMessageReader[69465016] = function(reader)
		return
	end
	self.midToReturnMessageReader[69466457] = function(reader)
		return
	end
	self.midToReturnMessageReader[69468125] = function(reader)
		return
	end
	self.midToReturnMessageReader[69471236] = function(reader)
		return
	end
	self.midToReturnMessageReader[69472213] = function(reader)
		return
	end
	self.midToReturnMessageReader[69475317] = function(reader)
		return
	end
	self.midToReturnMessageReader[69478654] = function(reader)
		return
	end
	self.midToReturnMessageReader[69482400] = function(reader)
		return
	end
	self.midToReturnMessageReader[69484174] = function(reader)
		return
	end
	self.midToReturnMessageReader[69492919] = function(reader)
		return
	end
	self.midToReturnMessageReader[69494703] = function(reader)
		return
	end
	self.midToReturnMessageReader[69499085] = function(reader)
		return
	end
	self.midToReturnMessageReader[69500068] = function(reader)
		return
	end
	self.midToReturnMessageReader[69500444] = function(reader)
		return
	end
	self.midToReturnMessageReader[69504167] = function(reader)
		return
	end
	self.midToReturnMessageReader[69504267] = function(reader)
		return
	end
	self.midToReturnMessageReader[69507148] = function(reader)
		return
	end
	self.midToReturnMessageReader[69508457] = function(reader)
		return
	end
	self.midToReturnMessageReader[69516811] = function(reader)
		return
	end
	self.midToReturnMessageReader[69524018] = function(reader)
		return
	end
	self.midToReturnMessageReader[69543371] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[214])

		return r0
	end
	self.midToReturnMessageReader[69547508] = function(reader)
		return
	end
	self.midToReturnMessageReader[69553056] = function(reader)
		return
	end
	self.midToReturnMessageReader[69557913] = function(reader)
		return
	end
	self.midToReturnMessageReader[69558895] = function(reader)
		return
	end
	self.midToReturnMessageReader[69562847] = function(reader)
		return
	end
	self.midToReturnMessageReader[69567020] = function(reader)
		return
	end
	self.midToReturnMessageReader[69570080] = function(reader)
		return
	end
	self.midToReturnMessageReader[69581093] = function(reader)
		return
	end
	self.midToReturnMessageReader[69593130] = function(reader)
		return
	end
	self.midToReturnMessageReader[69594078] = function(reader)
		return
	end
	self.midToReturnMessageReader[69602697] = function(reader)
		return
	end
	self.midToReturnMessageReader[69607166] = function(reader)
		return
	end
	self.midToReturnMessageReader[69608267] = function(reader)
		return
	end
	self.midToReturnMessageReader[69609599] = function(reader)
		return
	end
	self.midToReturnMessageReader[69611563] = function(reader)
		local r0 = reader:ReadUInt64()

		return r0
	end
	self.midToReturnMessageReader[69613713] = function(reader)
		return
	end
	self.midToReturnMessageReader[69624822] = function(reader)
		return
	end
	self.midToReturnMessageReader[69629956] = function(reader)
		return
	end
	self.midToReturnMessageReader[69638347] = function(reader)
		return
	end
	self.midToReturnMessageReader[69644865] = function(reader)
		return
	end
	self.midToReturnMessageReader[69646600] = function(reader)
		return
	end
	self.midToReturnMessageReader[69649680] = function(reader)
		return
	end
	self.midToReturnMessageReader[69651030] = function(reader)
		return
	end
	self.midToReturnMessageReader[69651537] = function(reader)
		return
	end
	self.midToReturnMessageReader[69651936] = function(reader)
		return
	end
	self.midToReturnMessageReader[69656494] = function(reader)
		return
	end
	self.midToReturnMessageReader[69665529] = function(reader)
		return
	end
	self.midToReturnMessageReader[69673206] = function(reader)
		return
	end
	self.midToReturnMessageReader[69675433] = function(reader)
		return
	end
	self.midToReturnMessageReader[69692322] = function(reader)
		local r0 = reader:ReadUInt64()

		return r0
	end
	self.midToReturnMessageReader[69704549] = function(reader)
		return
	end
	self.midToReturnMessageReader[69705586] = function(reader)
		return
	end
	self.midToReturnMessageReader[69729538] = function(reader)
		return
	end
	self.midToReturnMessageReader[69730573] = function(reader)
		return
	end
	self.midToReturnMessageReader[69736041] = function(reader)
		return
	end
	self.midToReturnMessageReader[69740071] = function(reader)
		return
	end
	self.midToReturnMessageReader[69745251] = function(reader)
		return
	end
	self.midToReturnMessageReader[69749315] = function(reader)
		return
	end
	self.midToReturnMessageReader[69762504] = function(reader)
		return
	end
	self.midToReturnMessageReader[69762606] = function(reader)
		return
	end
	self.midToReturnMessageReader[69771567] = function(reader)
		return
	end
	self.midToReturnMessageReader[69772229] = function(reader)
		return
	end
	self.midToReturnMessageReader[69776735] = function(reader)
		return
	end
	self.midToReturnMessageReader[69779695] = function(reader)
		return
	end
	self.midToReturnMessageReader[69780427] = function(reader)
		return
	end
	self.midToReturnMessageReader[69799762] = function(reader)
		return
	end
	self.midToReturnMessageReader[69800655] = function(reader)
		return
	end
	self.midToReturnMessageReader[69801946] = function(reader)
		return
	end
	self.midToReturnMessageReader[69803787] = function(reader)
		return
	end
	self.midToReturnMessageReader[69808290] = function(reader)
		local r0 = reader:ReadUInt64()

		return r0
	end
	self.midToReturnMessageReader[69813788] = function(reader)
		return
	end
	self.midToReturnMessageReader[69819237] = function(reader)
		return
	end
	self.midToReturnMessageReader[69820095] = function(reader)
		return
	end
	self.midToReturnMessageReader[69824839] = function(reader)
		return
	end
	self.midToReturnMessageReader[69828700] = function(reader)
		return
	end
	self.midToReturnMessageReader[69829299] = function(reader)
		return
	end
	self.midToReturnMessageReader[69836221] = function(reader)
		return
	end
	self.midToReturnMessageReader[69838809] = function(reader)
		return
	end
	self.midToReturnMessageReader[69843269] = function(reader)
		return
	end
	self.midToReturnMessageReader[69851223] = function(reader)
		local r0 = Base.ReadList(reader, function(r)
			return r:ReadString()
		end)

		return r0
	end
	self.midToReturnMessageReader[69853559] = function(reader)
		return
	end
	self.midToReturnMessageReader[69857941] = function(reader)
		return
	end
	self.midToReturnMessageReader[69860355] = function(reader)
		return
	end
	self.midToReturnMessageReader[69861538] = function(reader)
		local r0 = reader:ReadUInt64()

		return r0
	end
	self.midToReturnMessageReader[69863556] = function(reader)
		return
	end
	self.midToReturnMessageReader[69868438] = function(reader)
		return
	end
	self.midToReturnMessageReader[69871291] = function(reader)
		return
	end
	self.midToReturnMessageReader[69871965] = function(reader)
		return
	end
	self.midToReturnMessageReader[69886296] = function(reader)
		return
	end
	self.midToReturnMessageReader[69899081] = function(reader)
		return
	end
	self.midToReturnMessageReader[69900663] = function(reader)
		return
	end
	self.midToReturnMessageReader[69911024] = function(reader)
		return
	end
	self.midToReturnMessageReader[69935255] = function(reader)
		return
	end
	self.midToReturnMessageReader[69936257] = function(reader)
		local r0 = reader:ReadUInt64()

		return r0
	end
	self.midToReturnMessageReader[69946581] = function(reader)
		return
	end
	self.midToReturnMessageReader[69946815] = function(reader)
		return
	end
	self.midToReturnMessageReader[69949423] = function(reader)
		return
	end
	self.midToReturnMessageReader[69954028] = function(reader)
		return
	end
	self.midToReturnMessageReader[69954706] = function(reader)
		return
	end
	self.midToReturnMessageReader[69963078] = function(reader)
		return
	end
	self.midToReturnMessageReader[69964650] = function(reader)
		return
	end
	self.midToReturnMessageReader[69968876] = function(reader)
		return
	end
	self.midToReturnMessageReader[69969545] = function(reader)
		return
	end
	self.midToReturnMessageReader[69982160] = function(reader)
		local r0 = reader:ReadUInt64()

		return r0
	end
	self.midToReturnMessageReader[69988224] = function(reader)
		return
	end
	self.midToReturnMessageReader[69996208] = function(reader)
		local r0 = reader:ReadUInt64()

		return r0
	end
	self.midToReturnMessageReader[126708607] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[0])

		return r0
	end
	self.midToReturnMessageReader[152759385] = function(reader)
		return
	end
	self.midToReturnMessageReader[152775165] = function(reader)
		return
	end
	self.midToReturnMessageReader[153013539] = function(reader)
		return
	end
	self.midToReturnMessageReader[153018191] = function(reader)
		return
	end
	self.midToReturnMessageReader[153019981] = function(reader)
		local r0 = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[215])
		end)

		return r0
	end
	self.midToReturnMessageReader[153067403] = function(reader)
		return
	end
	self.midToReturnMessageReader[153073222] = function(reader)
		local r0 = reader:ReadInt32()

		return r0
	end
	self.midToReturnMessageReader[153077118] = function(reader)
		return
	end
	self.midToReturnMessageReader[153120154] = function(reader)
		return
	end
	self.midToReturnMessageReader[153131069] = function(reader)
		local r0 = Base.ReadList(reader, function(r)
			return r:ReadByte()
		end)

		return r0
	end
	self.midToReturnMessageReader[153132259] = function(reader)
		local r0 = Base.ReadList(reader, function(r)
			return r:ReadUInt64()
		end)

		return r0
	end
	self.midToReturnMessageReader[153169063] = function(reader)
		return
	end
	self.midToReturnMessageReader[153234536] = function(reader)
		return
	end
	self.midToReturnMessageReader[153244956] = function(reader)
		return
	end
	self.midToReturnMessageReader[153261934] = function(reader)
		local r0 = Base.ReadStruct(reader, Auto.Reader[157])

		return r0
	end
	self.midToReturnMessageReader[153268512] = function(reader)
		local r0 = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[6])
		end)

		return r0
	end
	self.midToReturnMessageReader[153274842] = function(reader)
		return
	end
	self.midToReturnMessageReader[153294138] = function(reader)
		local r0 = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[216])
		end)

		return r0
	end
	self.midToReturnMessageReader[153294956] = function(reader)
		local r0 = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[216])
		end)

		return r0
	end
	self.midToReturnMessageReader[153297901] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[216])

		return r0
	end
	self.midToReturnMessageReader[153313877] = function(reader)
		return
	end
	self.midToReturnMessageReader[153334455] = function(reader)
		return
	end
	self.midToReturnMessageReader[153365803] = function(reader)
		local r0 = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[216])
		end)

		return r0
	end
	self.midToReturnMessageReader[153371609] = function(reader)
		local r0 = reader:ReadBoolean()

		return r0
	end
	self.midToReturnMessageReader[153378146] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[216])

		return r0
	end
	self.midToReturnMessageReader[153388718] = function(reader)
		local r0 = reader:ReadInt32()
		local r1 = Base.ReadList(reader, function(r)
			return r:ReadString()
		end)

		return r0, r1
	end
	self.midToReturnMessageReader[153390391] = function(reader)
		local r0 = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[216])
		end)

		return r0
	end
	self.midToReturnMessageReader[153401024] = function(reader)
		return
	end
	self.midToReturnMessageReader[153404376] = function(reader)
		return
	end
	self.midToReturnMessageReader[153472464] = function(reader)
		return
	end
	self.midToReturnMessageReader[153475837] = function(reader)
		local r0 = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[216])
		end)

		return r0
	end
	self.midToReturnMessageReader[153491425] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[216])

		return r0
	end
	self.midToReturnMessageReader[153504625] = function(reader)
		return
	end
	self.midToReturnMessageReader[153506352] = function(reader)
		return
	end
	self.midToReturnMessageReader[153518692] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[216])

		return r0
	end
	self.midToReturnMessageReader[153521086] = function(reader)
		local r0 = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[216])
		end)

		return r0
	end
	self.midToReturnMessageReader[153546746] = function(reader)
		return
	end
	self.midToReturnMessageReader[153551913] = function(reader)
		return
	end
	self.midToReturnMessageReader[153632737] = function(reader)
		return
	end
	self.midToReturnMessageReader[153646828] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[0])

		return r0
	end
	self.midToReturnMessageReader[153669103] = function(reader)
		local r0 = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[216])
		end)

		return r0
	end
	self.midToReturnMessageReader[153720671] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[216])

		return r0
	end
	self.midToReturnMessageReader[153721013] = function(reader)
		return
	end
	self.midToReturnMessageReader[153733960] = function(reader)
		return
	end
	self.midToReturnMessageReader[153739755] = function(reader)
		return
	end
	self.midToReturnMessageReader[153758934] = function(reader)
		local r0 = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[216])
		end)

		return r0
	end
	self.midToReturnMessageReader[153769269] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[216])

		return r0
	end
	self.midToReturnMessageReader[153770579] = function(reader)
		local r0 = reader:ReadString()

		return r0
	end
	self.midToReturnMessageReader[153794588] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[216])

		return r0
	end
	self.midToReturnMessageReader[153820508] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[216])

		return r0
	end
	self.midToReturnMessageReader[153837034] = function(reader)
		return
	end
	self.midToReturnMessageReader[153855822] = function(reader)
		return
	end
	self.midToReturnMessageReader[153882895] = function(reader)
		local r0 = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[216])
		end)

		return r0
	end
	self.midToReturnMessageReader[153892154] = function(reader)
		local r0 = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[159])
		end)

		return r0
	end
	self.midToReturnMessageReader[153917750] = function(reader)
		local r0 = Base.ReadComplex(reader, Auto.Reader[216])

		return r0
	end
	self.midToReturnMessageReader[153919532] = function(reader)
		local r0 = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[216])
		end)

		return r0
	end
	self.midToReturnMessageReader[153950906] = function(reader)
		return
	end
	self.midToReturnMessageReader[153957668] = function(reader)
		local r0 = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[6])
		end)

		return r0
	end
	self.midToReturnMessageReader[153960953] = function(reader)
		return
	end
	self.midToReturnMessageReader[153965146] = function(reader)
		local r0 = reader:ReadString()

		return r0
	end
	self.midToReturnMessageReader[153971076] = function(reader)
		local r0 = reader:ReadBoolean()

		return r0
	end
	self.midToReturnMessageReader[153979783] = function(reader)
		return
	end
	self.midToReturnMessageReader[153986841] = function(reader)
		return
	end
	self.midToReturnMessageReader[153992257] = function(reader)
		return
	end
	self.midToReturnMessageReader[155146916] = function(reader)
		local r0 = Base.ReadList(reader, function(r)
			return r:ReadByte()
		end)

		return r0
	end
	self.midToReturnMessageReader[155154548] = function(reader)
		return
	end
	self.midToReturnMessageReader[155175329] = function(reader)
		return
	end
	self.midToReturnMessageReader[155178648] = function(reader)
		local r0 = reader:ReadUInt64()

		return r0
	end
	self.midToReturnMessageReader[155502407] = function(reader)
		local r0 = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[217])
		end)

		return r0
	end
	self.midToReturnMessageReader[155747440] = function(reader)
		return
	end
	self.midToReturnMessageReader[155749147] = function(reader)
		return
	end
	self.midToReturnMessageReader[155768142] = function(reader)
		local r0 = reader:ReadString()

		return r0
	end
	self.midToReturnMessageReader[155798062] = function(reader)
		return
	end
	self.midToReturnMessageReader[155811103] = function(reader)
		return
	end
	self.midToReturnMessageReader[155877507] = function(reader)
		return
	end
	self.midToReturnMessageReader[155957368] = function(reader)
		return
	end
	self.midToReturnMessageReader[174062551] = function(reader)
		return
	end
	self.midToReturnMessageReader[174087350] = function(reader)
		return
	end
	self.midToReturnMessageReader[174327356] = function(reader)
		return
	end
	self.midToReturnMessageReader[174558374] = function(reader)
		return
	end
	self.midToReturnMessageReader[174604472] = function(reader)
		return
	end
	self.midToReturnMessageReader[174630082] = function(reader)
		return
	end
	self.midToReturnMessageReader[174679538] = function(reader)
		return
	end
	self.midToReturnMessageReader[174706369] = function(reader)
		return
	end
	self.midToReturnMessageReader[174787027] = function(reader)
		return
	end
	self.midToReturnMessageReader[174923828] = function(reader)
		local r0 = reader:ReadBoolean()
		local r1 = reader:ReadInt32()

		return r0, r1
	end
	self.midToReturnMessageReader[174925891] = function(reader)
		return
	end
	self.midToReturnMessageReader[174999720] = function(reader)
		return
	end
	self.midToReturnMessageReader[175036200] = function(reader)
		return
	end
	self.midToReturnMessageReader[175048016] = function(reader)
		local r0 = reader:ReadString()

		return r0
	end
	self.midToReturnMessageReader[175106690] = function(reader)
		return
	end
	self.midToReturnMessageReader[175161447] = function(reader)
		return
	end
	self.midToReturnMessageReader[175169690] = function(reader)
		return
	end
	self.midToReturnMessageReader[175186675] = function(reader)
		return
	end
	self.midToReturnMessageReader[175216498] = function(reader)
		return
	end
	self.midToReturnMessageReader[175272340] = function(reader)
		return
	end
	self.midToReturnMessageReader[175302872] = function(reader)
		local r0 = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[168])
		end)

		return r0
	end
	self.midToReturnMessageReader[175306199] = function(reader)
		return
	end
	self.midToReturnMessageReader[175329407] = function(reader)
		return
	end
	self.midToReturnMessageReader[175374037] = function(reader)
		return
	end
	self.midToReturnMessageReader[175423466] = function(reader)
		local r0 = reader:ReadString()

		return r0
	end
	self.midToReturnMessageReader[175431701] = function(reader)
		return
	end
	self.midToReturnMessageReader[175496788] = function(reader)
		return
	end
	self.midToReturnMessageReader[175541951] = function(reader)
		return
	end
	self.midToReturnMessageReader[175548422] = function(reader)
		return
	end
	self.midToReturnMessageReader[175598340] = function(reader)
		return
	end
	self.midToReturnMessageReader[175602314] = function(reader)
		return
	end
	self.midToReturnMessageReader[175630682] = function(reader)
		return
	end
	self.midToReturnMessageReader[175726320] = function(reader)
		local r0 = Base.ReadList(reader, function(r)
			return Base.ReadComplex(r, Auto.Reader[218])
		end)

		return r0
	end
	self.midToReturnMessageReader[175743640] = function(reader)
		return
	end
	self.midToReturnMessageReader[175777261] = function(reader)
		return
	end
	self.midToReturnMessageReader[175810210] = function(reader)
		local r0 = reader:ReadString()

		return r0
	end
	self.midToReturnMessageReader[175836952] = function(reader)
		local r0 = reader:ReadString()

		return r0
	end
	self.midToReturnMessageReader[175839925] = function(reader)
		return
	end
	self.midToReturnMessageReader[175897606] = function(reader)
		local r0 = reader:ReadString()

		return r0
	end
	self.midToReturnMessageReader[175903818] = function(reader)
		return
	end
	self.midToReturnMessageReader[175955691] = function(reader)
		return
	end
	self.midToReturnMessageReader[175991357] = function(reader)
		return
	end
	self.midToReturnMessageReader[175996260] = function(reader)
		return
	end
	self.childTypeToParentType.AccumulateSignInActivityCommonInfo = "CommonActivityInfo"
	self.childTypeToParentType.AccumulateSignInActivityData = "ActivityDataBase"
	self.childTypeToParentType.AgentDestructibleData = "DynamicDestructibleData"
	self.childTypeToParentType.BowlingParticipantInfo = "GameGroundParticipantInfo"
	self.childTypeToParentType.BowlingZoneInfo = "GameGroundZoneInfo"
	self.childTypeToParentType.ChaseParameters = "VehicleAITaskParameters"
	self.childTypeToParentType.ChefParticipantInfo = "GameGroundParticipantInfo"
	self.childTypeToParentType.ChefZoneInfo = "GameGroundZoneInfo"
	self.childTypeToParentType.ClientActionAgentAnimation = "ClientActionParameter"
	self.childTypeToParentType.ClientActionAgentAvoidDangerMove = "ClientActionParameter"
	self.childTypeToParentType.ClientActionAgentAvoidVehicleMove = "ClientActionAgentMove"
	self.childTypeToParentType.ClientActionAgentCanSeeTarget = "ClientConditionalParameter"
	self.childTypeToParentType.ClientActionAgentCheckVehicleCollisionImpulse = "ClientConditionalParameter"
	self.childTypeToParentType.ClientActionAgentFaceTo = "ClientActionParameter"
	self.childTypeToParentType.ClientActionAgentFavorInteract = "ClientActionParameter"
	self.childTypeToParentType.ClientActionAgentFocusOn = "ClientActionParameter"
	self.childTypeToParentType.ClientActionAgentFollow = "ClientActionAgentNavigationMove"
	self.childTypeToParentType.ClientActionAgentGetInVehicle = "ClientActionParameter"
	self.childTypeToParentType.ClientActionAgentGetSitUp = "ClientActionParameter"
	self.childTypeToParentType.ClientActionAgentHitSomething = "ClientActionAgentAnimation"
	self.childTypeToParentType.ClientActionAgentIKMotion = "ClientActionAgentAnimation"
	self.childTypeToParentType.ClientActionAgentInteract2 = "ClientActionParameter"
	self.childTypeToParentType.ClientActionAgentIsVehicleBlockedByPlayer = "ClientConditionalParameter"
	self.childTypeToParentType.ClientActionAgentLookAt = "ClientActionParameter"
	self.childTypeToParentType.ClientActionAgentMove = "ClientActionParameter"
	self.childTypeToParentType.ClientActionAgentMoveToVehicle = "ClientActionParameter"
	self.childTypeToParentType.ClientActionAgentNavigationMove = "ClientActionAgentMove"
	self.childTypeToParentType.ClientActionAgentOstrichMove = "ClientActionParameter"
	self.childTypeToParentType.ClientActionAgentSelectedActionAnimation = "ClientActionParameter"
	self.childTypeToParentType.ClientActionAgentTargetIsRunning = "ClientConditionalParameter"
	self.childTypeToParentType.ClientActionAgentTaskMove = "ClientActionParameter"
	self.childTypeToParentType.ClientActionAgentTaskWayPointMove = "ClientActionParameter"
	self.childTypeToParentType.ClientActionAgentTurn = "ClientActionParameter"
	self.childTypeToParentType.ClientActionAgentXAgentMultiInteract = "ClientActionParameter"
	self.childTypeToParentType.ClientActionBehaviorTree = "ClientActionParameter"
	self.childTypeToParentType.ClientActionCheckNpcAnimState = "ClientConditionalParameter"
	self.childTypeToParentType.ClientActionCheckPointPathMove = "ClientActionParameter"
	self.childTypeToParentType.ClientActionGetOutVehicle = "ClientActionParameter"
	self.childTypeToParentType.ClientActionLeadingWayMove = "ClientActionParameter"
	self.childTypeToParentType.ClientActionPoliceAssistCloseVehicleDoor = "ClientActionParameter"
	self.childTypeToParentType.ClientActionPoliceAssistOpenVehicleDoor = "ClientActionParameter"
	self.childTypeToParentType.ClientActionReactTraitFree = "ClientConditionalParameter"
	self.childTypeToParentType.ClientActionShowConversation = "ClientActionParameter"
	self.childTypeToParentType.ClientActionTruckUAVAutoDrive = "ClientActionParameter"
	self.childTypeToParentType.ClientActionTruckUAVPutDown = "ClientActionParameter"
	self.childTypeToParentType.ClientActionTruckUAVPutUp = "ClientActionParameter"
	self.childTypeToParentType.ClientActionUAVFollow = "ClientActionParameter"
	self.childTypeToParentType.ClientActionVehicleRequisition = "ClientActionParameter"
	self.childTypeToParentType.ClientCrowdInitData = "ClientBaseEntityData"
	self.childTypeToParentType.ClientMetroNpcInitData = "ClientBaseEntityData"
	self.childTypeToParentType.ClientStaticNpcInitData = "ClientBaseEntityData"
	self.childTypeToParentType.ClientStaticVehicleInitData = "ClientBaseEntityData"
	self.childTypeToParentType.ClientTrafficIntersectionInitInfo = "TrafficIntersectionPeriodInfo"
	self.childTypeToParentType.ClientTrafficIntersectionPeriodUpdateInfo = "TrafficIntersectionPeriodInfo"
	self.childTypeToParentType.ClientVehicleInitData = "ClientBaseEntityData"
	self.childTypeToParentType.ControlFlowDataBoolean = "ControlFlowData"
	self.childTypeToParentType.ControlFlowDataCustom = "ControlFlowData"
	self.childTypeToParentType.ControlFlowDataDouble = "ControlFlowData"
	self.childTypeToParentType.ControlFlowDataInteger = "ControlFlowData"
	self.childTypeToParentType.ControlFlowDataString = "ControlFlowData"
	self.childTypeToParentType.ControlFlowDataUInteger = "ControlFlowData"
	self.childTypeToParentType.ControlFlowDataUlong = "ControlFlowData"
	self.childTypeToParentType.ControlFlowDataUnit = "ControlFlowData"
	self.childTypeToParentType.ControlFlowDataVector = "ControlFlowData"
	self.childTypeToParentType.ControlFlowDataVehicle = "ControlFlowData"
	self.childTypeToParentType.CruiseParameters = "VehicleAITaskParameters"
	self.childTypeToParentType.DartParticipantInfo = "GameGroundParticipantInfo"
	self.childTypeToParentType.DartZoneInfo = "GameGroundZoneInfo"
	self.childTypeToParentType.DynamicDestructibleInfo = "DestructibleInfo"
	self.childTypeToParentType.FashionCustomSuitSchemeInfo = "BaseWearFashionsInfo"
	self.childTypeToParentType.FashionFunctionSuitSchemeInfo = "BaseWearFashionsInfo"
	self.childTypeToParentType.FishDestructibleData = "DynamicDestructibleData"
	self.childTypeToParentType.FixPosition = "SpawnAt"
	self.childTypeToParentType.FollowRecordingParameters = "VehicleAITaskParameters"
	self.childTypeToParentType.GadgetDestructibleInfo = "DestructibleInfo"
	self.childTypeToParentType.GmWebDivider = "GmWebComponent"
	self.childTypeToParentType.GmWebInlineRow = "GmWebComponent"
	self.childTypeToParentType.GmWebRowItem = "GmWebComponent"
	self.childTypeToParentType.GmWebSection = "GmWebComponent"
	self.childTypeToParentType.GmWebTable = "GmWebComponent"
	self.childTypeToParentType.GmWebTableRow = "GmWebComponent"
	self.childTypeToParentType.GmWebTreeData = "GmWebComponent"
	self.childTypeToParentType.GomokuParticipantInfo = "GameGroundParticipantInfo"
	self.childTypeToParentType.GomokuZoneInfo = "GameGroundZoneInfo"
	self.childTypeToParentType.ItemDestructibleData = "DynamicDestructibleData"
	self.childTypeToParentType.LookAtPositionData = "IAgentClientData"
	self.childTypeToParentType.LookAtTargetData = "IAgentClientData"
	self.childTypeToParentType.MapEntranceSpawnAt = "SpawnAt"
	self.childTypeToParentType.MatchPrepareRoom = "MatchRoom"
	self.childTypeToParentType.MatchTeamRoom = "MatchRoom"
	self.childTypeToParentType.OtherPlayerSpiritWearFashionsInfo = "BaseWearFashionsInfo"
	self.childTypeToParentType.PlayActionData = "IAgentClientData"
	self.childTypeToParentType.PlayActionWithLayerData = "IAgentClientData"
	self.childTypeToParentType.PlayerInfoTree = "GmWebTreeData"
	self.childTypeToParentType.PlayerOfflineDataInfoTree = "GmWebTreeData"
	self.childTypeToParentType.PosServerEffectData = "ServerEffectData"
	self.childTypeToParentType.RacingParameters = "VehicleAITaskParameters"
	self.childTypeToParentType.RamParameters = "VehicleAITaskParameters"
	self.childTypeToParentType.SpinOutParameters = "VehicleAITaskParameters"
	self.childTypeToParentType.SpiritTalentInfo = "SpiritJobTalentInfo"
	self.childTypeToParentType.SpiritWearFashionsInfo = "BaseWearFashionsInfo"
	self.childTypeToParentType.StaticDestructibleInfo = "DestructibleInfo"
	self.childTypeToParentType.StopParameters = "VehicleAITaskParameters"
	self.childTypeToParentType.TaskDestructibleInfo = "DestructibleInfo"
	self.childTypeToParentType.TurnToPositionData = "IAgentClientData"
	self.childTypeToParentType.UXBoolObject = "UXObject"
	self.childTypeToParentType.UXDoubleObject = "UXObject"
	self.childTypeToParentType.UXIntObject = "UXObject"
	self.childTypeToParentType.UXLongObject = "UXObject"
	self.childTypeToParentType.UXStringObject = "UXObject"
	self.childTypeToParentType.UXUintObject = "UXObject"
	self.childTypeToParentType.UXUlongObject = "UXObject"
	self.childTypeToParentType.VehiclePartAnimation = "VehicleAnimationBase"
	self.childTypeToParentType.VehiclePoliceChaseParameters = "VehicleAITaskParameters"
	self.childTypeToParentType.VehicleSpecialPartAnimation = "VehicleAnimationBase"
	self.childTypeToParentType.WeaponDetail = "WeaponData"
	self.childTypeToParentType.WorldInfoTree = "GmWebTreeData"
end

local function IsInstanceOf(obj, typeName)
	local current = obj

	while current do
		if not current._type_name then
			return false
		end

		if current._type_name ~= typeName then
			return true
		end

		if not current.__base_type then
			return false
		end

		current = current.__base_type
	end

	return false
end

Auto.Meta[219] = {
	_type_name = "AIDebugParameter"
}
Auto.Meta[219].__index = Auto.Meta[219]
Auto.Meta[220] = {
	_type_name = "AINodeData"
}
Auto.Meta[220].__index = Auto.Meta[220]
Auto.Meta[221] = {
	_type_name = "AINodeEvent"
}
Auto.Meta[221].__index = Auto.Meta[221]
Auto.Meta[222] = {
	_type_name = "AISharedVariableInfo"
}
Auto.Meta[222].__index = Auto.Meta[222]
Auto.Meta[66] = {
	_type_name = "AcceptedTruckOrderInfo"
}
Auto.Meta[66].__index = Auto.Meta[66]
Auto.Meta[223] = {
	_type_name = "AccumulateSignInActivityCommonInfo",
	_base_type = Auto.Meta[224],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[223].__index = Auto.Meta[223]
Auto.Meta[225] = {
	_type_name = "AccumulateSignInActivityData",
	_base_type = Auto.Meta[74],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[225].__index = Auto.Meta[225]
Auto.Meta[226] = {
	_type_name = "AccumulateSignInData"
}
Auto.Meta[226].__index = Auto.Meta[226]
Auto.Meta[227] = {
	_type_name = "AchievementCategory"
}
Auto.Meta[227].__index = Auto.Meta[227]
Auto.Meta[65] = {
	_type_name = "AchievementDetail"
}
Auto.Meta[65].__index = Auto.Meta[65]
Auto.Meta[161] = {
	_type_name = "AchievementViewData"
}
Auto.Meta[161].__index = Auto.Meta[161]
Auto.Meta[74] = {
	_type_name = "ActivityDataBase"
}
Auto.Meta[74].__index = Auto.Meta[74]
Auto.Meta[228] = {
	_type_name = "AddPlacedFurnitureInfo"
}
Auto.Meta[228].__index = Auto.Meta[228]
Auto.Meta[229] = {
	_type_name = "AetherAIInitData"
}
Auto.Meta[229].__index = Auto.Meta[229]
Auto.Meta[230] = {
	_type_name = "AgentCharacterComponent"
}
Auto.Meta[230].__index = Auto.Meta[230]
Auto.Meta[231] = {
	_type_name = "AgentCrimeData"
}
Auto.Meta[231].__index = Auto.Meta[231]
Auto.Meta[232] = {
	_type_name = "AgentDestructibleData",
	_base_type = Auto.Meta[233],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[232].__index = Auto.Meta[232]
Auto.Meta[234] = {
	_type_name = "AgentFormationData"
}
Auto.Meta[234].__index = Auto.Meta[234]
Auto.Meta[235] = {
	_type_name = "AgentPlotDestroyConfig"
}
Auto.Meta[235].__index = Auto.Meta[235]
Auto.Meta[122] = {
	_type_name = "AgentPoliceExamAOIData"
}
Auto.Meta[122].__index = Auto.Meta[122]
Auto.Meta[186] = {
	_type_name = "AgentQueryDetailInfo"
}
Auto.Meta[186].__index = Auto.Meta[186]
Auto.Meta[236] = {
	_type_name = "AgentSyncClientInfo"
}
Auto.Meta[236].__index = Auto.Meta[236]
Auto.Meta[43] = {
	_type_name = "AnimalClientInfo"
}
Auto.Meta[43].__index = Auto.Meta[43]
Auto.Meta[237] = {
	_type_name = "AreaColliderParams"
}
Auto.Meta[237].__index = Auto.Meta[237]
Auto.Meta[238] = {
	_type_name = "AttractPointSyncInfo"
}
Auto.Meta[238].__index = Auto.Meta[238]
Auto.Meta[138] = {
	_type_name = "BVBBattleAgentStatistics"
}
Auto.Meta[138].__index = Auto.Meta[138]
Auto.Meta[121] = {
	_type_name = "BVBBonus"
}
Auto.Meta[121].__index = Auto.Meta[121]
Auto.Meta[99] = {
	_type_name = "BVBBuffCandidate"
}
Auto.Meta[99].__index = Auto.Meta[99]
Auto.Meta[239] = {
	_type_name = "BVBBuffData"
}
Auto.Meta[239].__index = Auto.Meta[239]
Auto.Meta[120] = {
	_type_name = "BVBPlayerBasicInfo"
}
Auto.Meta[120].__index = Auto.Meta[120]
Auto.Meta[141] = {
	_type_name = "BVBPlayerData"
}
Auto.Meta[141].__index = Auto.Meta[141]
Auto.Meta[240] = {
	_type_name = "BVBSelectPokemonData"
}
Auto.Meta[240].__index = Auto.Meta[240]
Auto.Meta[41] = {
	_type_name = "BadgeInfo"
}
Auto.Meta[41].__index = Auto.Meta[41]
Auto.Meta[241] = {
	_type_name = "BartenderCustomerNormalInfo"
}
Auto.Meta[241].__index = Auto.Meta[241]
Auto.Meta[242] = {
	_type_name = "BartenderCustomerSuperInfo"
}
Auto.Meta[242].__index = Auto.Meta[242]
Auto.Meta[56] = {
	_type_name = "BartenderCustomerSyncInfo"
}
Auto.Meta[56].__index = Auto.Meta[56]
Auto.Meta[20] = {
	_type_name = "BartenderElementInfos"
}
Auto.Meta[20].__index = Auto.Meta[20]
Auto.Meta[243] = {
	_type_name = "BartenderGameInfos"
}
Auto.Meta[243].__index = Auto.Meta[243]
Auto.Meta[244] = {
	_type_name = "BasketballAskOperatorParam"
}
Auto.Meta[244].__index = Auto.Meta[244]
Auto.Meta[245] = {
	_type_name = "BasketballSyncDelayActionSpecialParam"
}
Auto.Meta[245].__index = Auto.Meta[245]
Auto.Meta[246] = {
	_type_name = "BasketballSyncOperatorParam"
}
Auto.Meta[246].__index = Auto.Meta[246]
Auto.Meta[247] = {
	_type_name = "BasketballSyncOwnerInfo"
}
Auto.Meta[247].__index = Auto.Meta[247]
Auto.Meta[248] = {
	_type_name = "BasketballSyncShootSpecialParam"
}
Auto.Meta[248].__index = Auto.Meta[248]
Auto.Meta[80] = {
	_type_name = "BegBehaviorData"
}
Auto.Meta[80].__index = Auto.Meta[80]
Auto.Meta[249] = {
	_type_name = "BehaviorSeqCommand"
}
Auto.Meta[249].__index = Auto.Meta[249]
Auto.Meta[250] = {
	_type_name = "BelongItemInfo"
}
Auto.Meta[250].__index = Auto.Meta[250]
Auto.Meta[251] = {
	_type_name = "BelongingDebugInfo"
}
Auto.Meta[251].__index = Auto.Meta[251]
Auto.Meta[252] = {
	_type_name = "BestNpcInfo"
}
Auto.Meta[252].__index = Auto.Meta[252]
Auto.Meta[168] = {
	_type_name = "BillInfo"
}
Auto.Meta[168].__index = Auto.Meta[168]
Auto.Meta[253] = {
	_type_name = "BirdGroupData"
}
Auto.Meta[253].__index = Auto.Meta[253]
Auto.Meta[106] = {
	_type_name = "BowlingClientInfo"
}
Auto.Meta[106].__index = Auto.Meta[106]
Auto.Meta[254] = {
	_type_name = "BowlingParticipantInfo",
	_base_type = Auto.Meta[103],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[254].__index = Auto.Meta[254]
Auto.Meta[255] = {
	_type_name = "BowlingParticipantScoreInfo"
}
Auto.Meta[255].__index = Auto.Meta[255]
Auto.Meta[139] = {
	_type_name = "BowlingScoreInfo"
}
Auto.Meta[139].__index = Auto.Meta[139]
Auto.Meta[256] = {
	_type_name = "BowlingZoneInfo",
	_base_type = Auto.Meta[115],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[256].__index = Auto.Meta[256]
Auto.Meta[257] = {
	_type_name = "BoxAreaParams"
}
Auto.Meta[257].__index = Auto.Meta[257]
Auto.Meta[111] = {
	_type_name = "BuffViewData"
}
Auto.Meta[111].__index = Auto.Meta[111]
Auto.Meta[258] = {
	_type_name = "BuyFoodInfo"
}
Auto.Meta[258].__index = Auto.Meta[258]
Auto.Meta[259] = {
	_type_name = "ByteAngle"
}
Auto.Meta[259].__index = Auto.Meta[259]
Auto.Meta[260] = {
	_type_name = "CargoInfo"
}
Auto.Meta[260].__index = Auto.Meta[260]
Auto.Meta[261] = {
	_type_name = "CentripetalVelocityData"
}
Auto.Meta[261].__index = Auto.Meta[261]
Auto.Meta[44] = {
	_type_name = "ChallengeRecord"
}
Auto.Meta[44].__index = Auto.Meta[44]
Auto.Meta[194] = {
	_type_name = "ChallengeResult"
}
Auto.Meta[194].__index = Auto.Meta[194]
Auto.Meta[262] = {
	_type_name = "ChangePlacedFurnitureInfo"
}
Auto.Meta[262].__index = Auto.Meta[262]
Auto.Meta[105] = {
	_type_name = "ChaosTagInfo"
}
Auto.Meta[105].__index = Auto.Meta[105]
Auto.Meta[263] = {
	_type_name = "CharacterBelongingItem"
}
Auto.Meta[263].__index = Auto.Meta[263]
Auto.Meta[264] = {
	_type_name = "ChargeActivityClientInfo"
}
Auto.Meta[264].__index = Auto.Meta[264]
Auto.Meta[118] = {
	_type_name = "ChargeData"
}
Auto.Meta[118].__index = Auto.Meta[118]
Auto.Meta[17] = {
	_type_name = "ChargeDeliveryResult"
}
Auto.Meta[17].__index = Auto.Meta[17]
Auto.Meta[265] = {
	_type_name = "ChaseParameters",
	_base_type = Auto.Meta[266],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[265].__index = Auto.Meta[265]
Auto.Meta[152] = {
	_type_name = "ChatGroupClient"
}
Auto.Meta[152].__index = Auto.Meta[152]
Auto.Meta[267] = {
	_type_name = "ChatHint"
}
Auto.Meta[267].__index = Auto.Meta[267]
Auto.Meta[268] = {
	_type_name = "ChatInfoList"
}
Auto.Meta[268].__index = Auto.Meta[268]
Auto.Meta[216] = {
	_type_name = "ChatMessage"
}
Auto.Meta[216].__index = Auto.Meta[216]
Auto.Meta[215] = {
	_type_name = "ChatMessagesBlob"
}
Auto.Meta[215].__index = Auto.Meta[215]
Auto.Meta[158] = {
	_type_name = "CheckAccountResult"
}
Auto.Meta[158].__index = Auto.Meta[158]
Auto.Meta[269] = {
	_type_name = "CheckAgentDistanceInfo"
}
Auto.Meta[269].__index = Auto.Meta[269]
Auto.Meta[270] = {
	_type_name = "CheckPointAction"
}
Auto.Meta[270].__index = Auto.Meta[270]
Auto.Meta[271] = {
	_type_name = "ChefParticipantInfo",
	_base_type = Auto.Meta[103],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[271].__index = Auto.Meta[271]
Auto.Meta[272] = {
	_type_name = "ChefZoneInfo",
	_base_type = Auto.Meta[115],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[272].__index = Auto.Meta[272]
Auto.Meta[273] = {
	_type_name = "CinemaMultiTicketInfo"
}
Auto.Meta[273].__index = Auto.Meta[273]
Auto.Meta[274] = {
	_type_name = "CinemaTicketInfo"
}
Auto.Meta[274].__index = Auto.Meta[274]
Auto.Meta[64] = {
	_type_name = "ClawDateClientInfo"
}
Auto.Meta[64].__index = Auto.Meta[64]
Auto.Meta[275] = {
	_type_name = "ClawSettlementInfo"
}
Auto.Meta[275].__index = Auto.Meta[275]
Auto.Meta[276] = {
	_type_name = "ClientActionAgentAnimation",
	_base_type = Auto.Meta[277],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[276].__index = Auto.Meta[276]
Auto.Meta[278] = {
	_type_name = "ClientActionAgentAvoidDangerMove",
	_base_type = Auto.Meta[277],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[278].__index = Auto.Meta[278]
Auto.Meta[279] = {
	_type_name = "ClientActionAgentAvoidVehicleMove",
	_base_type = Auto.Meta[280],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[279].__index = Auto.Meta[279]
Auto.Meta[281] = {
	_type_name = "ClientActionAgentCanSeeTarget",
	_base_type = Auto.Meta[282],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[281].__index = Auto.Meta[281]
Auto.Meta[283] = {
	_type_name = "ClientActionAgentCheckVehicleCollisionImpulse",
	_base_type = Auto.Meta[282],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[283].__index = Auto.Meta[283]
Auto.Meta[284] = {
	_type_name = "ClientActionAgentFaceTo",
	_base_type = Auto.Meta[277],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[284].__index = Auto.Meta[284]
Auto.Meta[285] = {
	_type_name = "ClientActionAgentFavorInteract",
	_base_type = Auto.Meta[277],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[285].__index = Auto.Meta[285]
Auto.Meta[286] = {
	_type_name = "ClientActionAgentFocusOn",
	_base_type = Auto.Meta[277],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[286].__index = Auto.Meta[286]
Auto.Meta[287] = {
	_type_name = "ClientActionAgentFollow",
	_base_type = Auto.Meta[288],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[287].__index = Auto.Meta[287]
Auto.Meta[289] = {
	_type_name = "ClientActionAgentGetInVehicle",
	_base_type = Auto.Meta[277],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[289].__index = Auto.Meta[289]
Auto.Meta[290] = {
	_type_name = "ClientActionAgentGetSitUp",
	_base_type = Auto.Meta[277],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[290].__index = Auto.Meta[290]
Auto.Meta[291] = {
	_type_name = "ClientActionAgentHitSomething",
	_base_type = Auto.Meta[276],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[291].__index = Auto.Meta[291]
Auto.Meta[292] = {
	_type_name = "ClientActionAgentIKMotion",
	_base_type = Auto.Meta[276],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[292].__index = Auto.Meta[292]
Auto.Meta[293] = {
	_type_name = "ClientActionAgentInteract2",
	_base_type = Auto.Meta[277],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[293].__index = Auto.Meta[293]
Auto.Meta[294] = {
	_type_name = "ClientActionAgentIsVehicleBlockedByPlayer",
	_base_type = Auto.Meta[282],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[294].__index = Auto.Meta[294]
Auto.Meta[295] = {
	_type_name = "ClientActionAgentLookAt",
	_base_type = Auto.Meta[277],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[295].__index = Auto.Meta[295]
Auto.Meta[280] = {
	_type_name = "ClientActionAgentMove",
	_base_type = Auto.Meta[277],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[280].__index = Auto.Meta[280]
Auto.Meta[296] = {
	_type_name = "ClientActionAgentMoveToVehicle",
	_base_type = Auto.Meta[277],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[296].__index = Auto.Meta[296]
Auto.Meta[288] = {
	_type_name = "ClientActionAgentNavigationMove",
	_base_type = Auto.Meta[280],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[288].__index = Auto.Meta[288]
Auto.Meta[297] = {
	_type_name = "ClientActionAgentOstrichMove",
	_base_type = Auto.Meta[277],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[297].__index = Auto.Meta[297]
Auto.Meta[298] = {
	_type_name = "ClientActionAgentSelectedActionAnimation",
	_base_type = Auto.Meta[277],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[298].__index = Auto.Meta[298]
Auto.Meta[299] = {
	_type_name = "ClientActionAgentTargetIsRunning",
	_base_type = Auto.Meta[282],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[299].__index = Auto.Meta[299]
Auto.Meta[300] = {
	_type_name = "ClientActionAgentTaskMove",
	_base_type = Auto.Meta[277],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[300].__index = Auto.Meta[300]
Auto.Meta[301] = {
	_type_name = "ClientActionAgentTaskWayPointMove",
	_base_type = Auto.Meta[277],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[301].__index = Auto.Meta[301]
Auto.Meta[302] = {
	_type_name = "ClientActionAgentTurn",
	_base_type = Auto.Meta[277],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[302].__index = Auto.Meta[302]
Auto.Meta[303] = {
	_type_name = "ClientActionAgentXAgentMultiInteract",
	_base_type = Auto.Meta[277],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[303].__index = Auto.Meta[303]
Auto.Meta[304] = {
	_type_name = "ClientActionBehaviorTree",
	_base_type = Auto.Meta[277],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[304].__index = Auto.Meta[304]
Auto.Meta[305] = {
	_type_name = "ClientActionBreak"
}
Auto.Meta[305].__index = Auto.Meta[305]
Auto.Meta[306] = {
	_type_name = "ClientActionCheckNpcAnimState",
	_base_type = Auto.Meta[282],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[306].__index = Auto.Meta[306]
Auto.Meta[307] = {
	_type_name = "ClientActionCheckPointPathMove",
	_base_type = Auto.Meta[277],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[307].__index = Auto.Meta[307]
Auto.Meta[308] = {
	_type_name = "ClientActionGetOutVehicle",
	_base_type = Auto.Meta[277],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[308].__index = Auto.Meta[308]
Auto.Meta[309] = {
	_type_name = "ClientActionLeadingWayMove",
	_base_type = Auto.Meta[277],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[309].__index = Auto.Meta[309]
Auto.Meta[277] = {
	_type_name = "ClientActionParameter"
}
Auto.Meta[277].__index = Auto.Meta[277]
Auto.Meta[310] = {
	_type_name = "ClientActionPoliceAssistCloseVehicleDoor",
	_base_type = Auto.Meta[277],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[310].__index = Auto.Meta[310]
Auto.Meta[311] = {
	_type_name = "ClientActionPoliceAssistOpenVehicleDoor",
	_base_type = Auto.Meta[277],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[311].__index = Auto.Meta[311]
Auto.Meta[312] = {
	_type_name = "ClientActionReactTraitFree",
	_base_type = Auto.Meta[282],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[312].__index = Auto.Meta[312]
Auto.Meta[313] = {
	_type_name = "ClientActionShowConversation",
	_base_type = Auto.Meta[277],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[313].__index = Auto.Meta[313]
Auto.Meta[314] = {
	_type_name = "ClientActionTarget"
}
Auto.Meta[314].__index = Auto.Meta[314]
Auto.Meta[315] = {
	_type_name = "ClientActionTruckUAVAutoDrive",
	_base_type = Auto.Meta[277],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[315].__index = Auto.Meta[315]
Auto.Meta[316] = {
	_type_name = "ClientActionTruckUAVPutDown",
	_base_type = Auto.Meta[277],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[316].__index = Auto.Meta[316]
Auto.Meta[317] = {
	_type_name = "ClientActionTruckUAVPutUp",
	_base_type = Auto.Meta[277],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[317].__index = Auto.Meta[317]
Auto.Meta[318] = {
	_type_name = "ClientActionUAVFollow",
	_base_type = Auto.Meta[277],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[318].__index = Auto.Meta[318]
Auto.Meta[319] = {
	_type_name = "ClientActionVehicleRequisition",
	_base_type = Auto.Meta[277],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[319].__index = Auto.Meta[319]
Auto.Meta[23] = {
	_type_name = "ClientActivityInfo"
}
Auto.Meta[23].__index = Auto.Meta[23]
Auto.Meta[320] = {
	_type_name = "ClientAgentBubbleConfig"
}
Auto.Meta[320].__index = Auto.Meta[320]
Auto.Meta[321] = {
	_type_name = "ClientAgentBubbleConfigs"
}
Auto.Meta[321].__index = Auto.Meta[321]
Auto.Meta[322] = {
	_type_name = "ClientAgentBubbleSensorRange"
}
Auto.Meta[322].__index = Auto.Meta[322]
Auto.Meta[323] = {
	_type_name = "ClientBoardingInfo"
}
Auto.Meta[323].__index = Auto.Meta[323]
Auto.Meta[217] = {
	_type_name = "ClientCommandData"
}
Auto.Meta[217].__index = Auto.Meta[217]
Auto.Meta[62] = {
	_type_name = "ClientCompetitionSeasonInfo"
}
Auto.Meta[62].__index = Auto.Meta[62]
Auto.Meta[282] = {
	_type_name = "ClientConditionalParameter"
}
Auto.Meta[282].__index = Auto.Meta[282]
Auto.Meta[109] = {
	_type_name = "ClientCrowdInitData",
	_base_type = Auto.Meta[324],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[109].__index = Auto.Meta[109]
Auto.Meta[124] = {
	_type_name = "ClientCustomData"
}
Auto.Meta[124].__index = Auto.Meta[124]
Auto.Meta[325] = {
	_type_name = "ClientDangerAreaData"
}
Auto.Meta[325].__index = Auto.Meta[325]
Auto.Meta[326] = {
	_type_name = "ClientDetectEventData"
}
Auto.Meta[326].__index = Auto.Meta[326]
Auto.Meta[327] = {
	_type_name = "ClientDeviceInfo"
}
Auto.Meta[327].__index = Auto.Meta[327]
Auto.Meta[192] = {
	_type_name = "ClientFinishedTruckOrderView"
}
Auto.Meta[192].__index = Auto.Meta[192]
Auto.Meta[328] = {
	_type_name = "ClientFormationMember"
}
Auto.Meta[328].__index = Auto.Meta[328]
Auto.Meta[329] = {
	_type_name = "ClientFormationStructureUpdate"
}
Auto.Meta[329].__index = Auto.Meta[329]
Auto.Meta[330] = {
	_type_name = "ClientFpsInfo"
}
Auto.Meta[330].__index = Auto.Meta[330]
Auto.Meta[331] = {
	_type_name = "ClientIntersectionDebugData"
}
Auto.Meta[331].__index = Auto.Meta[331]
Auto.Meta[332] = {
	_type_name = "ClientLaneVehicleCountDebugData"
}
Auto.Meta[332].__index = Auto.Meta[332]
Auto.Meta[333] = {
	_type_name = "ClientMetroNpcInitData",
	_base_type = Auto.Meta[324],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[333].__index = Auto.Meta[333]
Auto.Meta[334] = {
	_type_name = "ClientNpcChatData"
}
Auto.Meta[334].__index = Auto.Meta[334]
Auto.Meta[204] = {
	_type_name = "ClientNpcDebugDensityStatistics"
}
Auto.Meta[204].__index = Auto.Meta[204]
Auto.Meta[335] = {
	_type_name = "ClientNpcGroupChatData"
}
Auto.Meta[335].__index = Auto.Meta[335]
Auto.Meta[336] = {
	_type_name = "ClientNpcMoveData"
}
Auto.Meta[336].__index = Auto.Meta[336]
Auto.Meta[337] = {
	_type_name = "ClientNpcPlayAnimationData"
}
Auto.Meta[337].__index = Auto.Meta[337]
Auto.Meta[338] = {
	_type_name = "ClientPedData"
}
Auto.Meta[338].__index = Auto.Meta[338]
Auto.Meta[339] = {
	_type_name = "ClientQualitySetting"
}
Auto.Meta[339].__index = Auto.Meta[339]
Auto.Meta[340] = {
	_type_name = "ClientStaticNpcInitData",
	_base_type = Auto.Meta[324],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[340].__index = Auto.Meta[340]
Auto.Meta[341] = {
	_type_name = "ClientStaticVehicleInitData",
	_base_type = Auto.Meta[324],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[341].__index = Auto.Meta[341]
Auto.Meta[31] = {
	_type_name = "ClientTeamInfo"
}
Auto.Meta[31].__index = Auto.Meta[31]
Auto.Meta[342] = {
	_type_name = "ClientTrafficIntersectionInitInfo",
	_base_type = Auto.Meta[343],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[342].__index = Auto.Meta[342]
Auto.Meta[344] = {
	_type_name = "ClientTrafficIntersectionPeriodUpdateInfo",
	_base_type = Auto.Meta[343],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[344].__index = Auto.Meta[344]
Auto.Meta[165] = {
	_type_name = "ClientTruckOrderView"
}
Auto.Meta[165].__index = Auto.Meta[165]
Auto.Meta[345] = {
	_type_name = "ClientVehicleBuffData"
}
Auto.Meta[345].__index = Auto.Meta[345]
Auto.Meta[346] = {
	_type_name = "ClientVehicleData"
}
Auto.Meta[346].__index = Auto.Meta[346]
Auto.Meta[347] = {
	_type_name = "ClientVehicleDebugData"
}
Auto.Meta[347].__index = Auto.Meta[347]
Auto.Meta[348] = {
	_type_name = "ClientVehicleInitData",
	_base_type = Auto.Meta[324],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[348].__index = Auto.Meta[348]
Auto.Meta[349] = {
	_type_name = "ClientVehicleLaneChangeData"
}
Auto.Meta[349].__index = Auto.Meta[349]
Auto.Meta[350] = {
	_type_name = "ClientVehicleLaneData"
}
Auto.Meta[350].__index = Auto.Meta[350]
Auto.Meta[351] = {
	_type_name = "ClientVehicleLaneDebugData"
}
Auto.Meta[351].__index = Auto.Meta[351]
Auto.Meta[352] = {
	_type_name = "ClientVehicleNpcInitData"
}
Auto.Meta[352].__index = Auto.Meta[352]
Auto.Meta[353] = {
	_type_name = "ClientVehiclePartStatus"
}
Auto.Meta[353].__index = Auto.Meta[353]
Auto.Meta[354] = {
	_type_name = "ClientZoneGraphPath"
}
Auto.Meta[354].__index = Auto.Meta[354]
Auto.Meta[355] = {
	_type_name = "ClientZoneGraphPathFollowDown"
}
Auto.Meta[355].__index = Auto.Meta[355]
Auto.Meta[356] = {
	_type_name = "ClientZoneGraphPathPoint"
}
Auto.Meta[356].__index = Auto.Meta[356]
Auto.Meta[224] = {
	_type_name = "CommonActivityInfo"
}
Auto.Meta[224].__index = Auto.Meta[224]
Auto.Meta[357] = {
	_type_name = "CommonCompetitionSeasonInfo"
}
Auto.Meta[357].__index = Auto.Meta[357]
Auto.Meta[358] = {
	_type_name = "CompetitionSeasonChallengeInfo"
}
Auto.Meta[358].__index = Auto.Meta[358]
Auto.Meta[359] = {
	_type_name = "CompetitionSeasonGamePlayInfo"
}
Auto.Meta[359].__index = Auto.Meta[359]
Auto.Meta[47] = {
	_type_name = "CompetitionSeasonInfo"
}
Auto.Meta[47].__index = Auto.Meta[47]
Auto.Meta[360] = {
	_type_name = "ComputerDetailInfo"
}
Auto.Meta[360].__index = Auto.Meta[360]
Auto.Meta[30] = {
	_type_name = "ComputerEmail"
}
Auto.Meta[30].__index = Auto.Meta[30]
Auto.Meta[84] = {
	_type_name = "ComputerFile"
}
Auto.Meta[84].__index = Auto.Meta[84]
Auto.Meta[190] = {
	_type_name = "ComputerUnlockInfo"
}
Auto.Meta[190].__index = Auto.Meta[190]
Auto.Meta[112] = {
	_type_name = "ControlFlowData"
}
Auto.Meta[112].__index = Auto.Meta[112]
Auto.Meta[361] = {
	_type_name = "ControlFlowDataBoolean",
	_base_type = Auto.Meta[112],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[361].__index = Auto.Meta[361]
Auto.Meta[362] = {
	_type_name = "ControlFlowDataCustom",
	_base_type = Auto.Meta[112],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[362].__index = Auto.Meta[362]
Auto.Meta[363] = {
	_type_name = "ControlFlowDataDebug"
}
Auto.Meta[363].__index = Auto.Meta[363]
Auto.Meta[364] = {
	_type_name = "ControlFlowDataDouble",
	_base_type = Auto.Meta[112],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[364].__index = Auto.Meta[364]
Auto.Meta[365] = {
	_type_name = "ControlFlowDataInteger",
	_base_type = Auto.Meta[112],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[365].__index = Auto.Meta[365]
Auto.Meta[366] = {
	_type_name = "ControlFlowDataString",
	_base_type = Auto.Meta[112],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[366].__index = Auto.Meta[366]
Auto.Meta[367] = {
	_type_name = "ControlFlowDataUInteger",
	_base_type = Auto.Meta[112],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[367].__index = Auto.Meta[367]
Auto.Meta[368] = {
	_type_name = "ControlFlowDataUlong",
	_base_type = Auto.Meta[112],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[368].__index = Auto.Meta[368]
Auto.Meta[369] = {
	_type_name = "ControlFlowDataUnit",
	_base_type = Auto.Meta[112],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[369].__index = Auto.Meta[369]
Auto.Meta[370] = {
	_type_name = "ControlFlowDataVector",
	_base_type = Auto.Meta[112],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[370].__index = Auto.Meta[370]
Auto.Meta[371] = {
	_type_name = "ControlFlowDataVehicle",
	_base_type = Auto.Meta[112],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[371].__index = Auto.Meta[371]
Auto.Meta[372] = {
	_type_name = "CreateRoleInitInfo"
}
Auto.Meta[372].__index = Auto.Meta[372]
Auto.Meta[373] = {
	_type_name = "CreationEnterLeave"
}
Auto.Meta[373].__index = Auto.Meta[373]
Auto.Meta[374] = {
	_type_name = "CreationHitData"
}
Auto.Meta[374].__index = Auto.Meta[374]
Auto.Meta[375] = {
	_type_name = "CreationMoveData"
}
Auto.Meta[375].__index = Auto.Meta[375]
Auto.Meta[34] = {
	_type_name = "CreditInfo"
}
Auto.Meta[34].__index = Auto.Meta[34]
Auto.Meta[376] = {
	_type_name = "CruiseParameters",
	_base_type = Auto.Meta[266],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[376].__index = Auto.Meta[376]
Auto.Meta[377] = {
	_type_name = "CubeCoord"
}
Auto.Meta[377].__index = Auto.Meta[377]
Auto.Meta[378] = {
	_type_name = "CurveMoveData"
}
Auto.Meta[378].__index = Auto.Meta[378]
Auto.Meta[0] = {
	_type_name = "CustomCommonData"
}
Auto.Meta[0].__index = Auto.Meta[0]
Auto.Meta[379] = {
	_type_name = "DSBuffData"
}
Auto.Meta[379].__index = Auto.Meta[379]
Auto.Meta[214] = {
	_type_name = "DSDamageData"
}
Auto.Meta[214].__index = Auto.Meta[214]
Auto.Meta[380] = {
	_type_name = "DSElementDamageData"
}
Auto.Meta[380].__index = Auto.Meta[380]
Auto.Meta[381] = {
	_type_name = "DSSkillHitDamageData"
}
Auto.Meta[381].__index = Auto.Meta[381]
Auto.Meta[382] = {
	_type_name = "DSSkillHitDataList"
}
Auto.Meta[382].__index = Auto.Meta[382]
Auto.Meta[383] = {
	_type_name = "DSSpiritDamageData"
}
Auto.Meta[383].__index = Auto.Meta[383]
Auto.Meta[384] = {
	_type_name = "DailyHackerCounts"
}
Auto.Meta[384].__index = Auto.Meta[384]
Auto.Meta[385] = {
	_type_name = "DamageData"
}
Auto.Meta[385].__index = Auto.Meta[385]
Auto.Meta[386] = {
	_type_name = "DancePlayResult"
}
Auto.Meta[386].__index = Auto.Meta[386]
Auto.Meta[387] = {
	_type_name = "DartParticipantInfo",
	_base_type = Auto.Meta[103],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[387].__index = Auto.Meta[387]
Auto.Meta[108] = {
	_type_name = "DartScoreInfo"
}
Auto.Meta[108].__index = Auto.Meta[108]
Auto.Meta[388] = {
	_type_name = "DartZoneInfo",
	_base_type = Auto.Meta[115],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[388].__index = Auto.Meta[388]
Auto.Meta[389] = {
	_type_name = "DebugBattleElementData"
}
Auto.Meta[389].__index = Auto.Meta[389]
Auto.Meta[390] = {
	_type_name = "DebugBattleSpiritData"
}
Auto.Meta[390].__index = Auto.Meta[390]
Auto.Meta[213] = {
	_type_name = "DebugBattleStatistics"
}
Auto.Meta[213].__index = Auto.Meta[213]
Auto.Meta[391] = {
	_type_name = "DebugFileDescription"
}
Auto.Meta[391].__index = Auto.Meta[391]
Auto.Meta[392] = {
	_type_name = "DebugFileResult"
}
Auto.Meta[392].__index = Auto.Meta[392]
Auto.Meta[393] = {
	_type_name = "DebugNpcBvbSelectPokemonData"
}
Auto.Meta[393].__index = Auto.Meta[393]
Auto.Meta[394] = {
	_type_name = "DeriveCreationData"
}
Auto.Meta[394].__index = Auto.Meta[394]
Auto.Meta[395] = {
	_type_name = "DestructibleBrokenInfo"
}
Auto.Meta[395].__index = Auto.Meta[395]
Auto.Meta[396] = {
	_type_name = "DestructibleGridAOIIncrease"
}
Auto.Meta[396].__index = Auto.Meta[396]
Auto.Meta[397] = {
	_type_name = "DestructibleInfo"
}
Auto.Meta[397].__index = Auto.Meta[397]
Auto.Meta[398] = {
	_type_name = "DestructibleSyncInfo"
}
Auto.Meta[398].__index = Auto.Meta[398]
Auto.Meta[399] = {
	_type_name = "DialogAreaInfo"
}
Auto.Meta[399].__index = Auto.Meta[399]
Auto.Meta[36] = {
	_type_name = "DialogParameter"
}
Auto.Meta[36].__index = Auto.Meta[36]
Auto.Meta[400] = {
	_type_name = "DisableBadgeInfo"
}
Auto.Meta[400].__index = Auto.Meta[400]
Auto.Meta[86] = {
	_type_name = "DivinerCustomerInfo"
}
Auto.Meta[86].__index = Auto.Meta[86]
Auto.Meta[22] = {
	_type_name = "DivinerPersuasionResult"
}
Auto.Meta[22].__index = Auto.Meta[22]
Auto.Meta[401] = {
	_type_name = "DoctorCheckCureData"
}
Auto.Meta[401].__index = Auto.Meta[401]
Auto.Meta[169] = {
	_type_name = "DoctorCheckData"
}
Auto.Meta[169].__index = Auto.Meta[169]
Auto.Meta[402] = {
	_type_name = "DrivingBehaviorRecord"
}
Auto.Meta[402].__index = Auto.Meta[402]
Auto.Meta[403] = {
	_type_name = "DrivingBehaviorRecords"
}
Auto.Meta[403].__index = Auto.Meta[403]
Auto.Meta[404] = {
	_type_name = "DropBelongingData"
}
Auto.Meta[404].__index = Auto.Meta[404]
Auto.Meta[10] = {
	_type_name = "DropLimitInfo"
}
Auto.Meta[10].__index = Auto.Meta[10]
Auto.Meta[233] = {
	_type_name = "DynamicDestructibleData"
}
Auto.Meta[233].__index = Auto.Meta[233]
Auto.Meta[405] = {
	_type_name = "DynamicDestructibleInfo",
	_base_type = Auto.Meta[397],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[405].__index = Auto.Meta[405]
Auto.Meta[406] = {
	_type_name = "EdictDebugInfo"
}
Auto.Meta[406].__index = Auto.Meta[406]
Auto.Meta[407] = {
	_type_name = "EffectSyncData"
}
Auto.Meta[407].__index = Auto.Meta[407]
Auto.Meta[408] = {
	_type_name = "EmojiData"
}
Auto.Meta[408].__index = Auto.Meta[408]
Auto.Meta[409] = {
	_type_name = "EndItemDropInfo"
}
Auto.Meta[409].__index = Auto.Meta[409]
Auto.Meta[410] = {
	_type_name = "EnemyDieInfo"
}
Auto.Meta[410].__index = Auto.Meta[410]
Auto.Meta[134] = {
	_type_name = "EnemyItemDropInfo"
}
Auto.Meta[134].__index = Auto.Meta[134]
Auto.Meta[411] = {
	_type_name = "EnemyMoveFinishData"
}
Auto.Meta[411].__index = Auto.Meta[411]
Auto.Meta[412] = {
	_type_name = "EnemyWeaponState"
}
Auto.Meta[412].__index = Auto.Meta[412]
Auto.Meta[160] = {
	_type_name = "EnterGameData"
}
Auto.Meta[160].__index = Auto.Meta[160]
Auto.Meta[53] = {
	_type_name = "EnterSceneInfo"
}
Auto.Meta[53].__index = Auto.Meta[53]
Auto.Meta[27] = {
	_type_name = "EventIdInfo"
}
Auto.Meta[27].__index = Auto.Meta[27]
Auto.Meta[39] = {
	_type_name = "EventPanelInfo"
}
Auto.Meta[39].__index = Auto.Meta[39]
Auto.Meta[413] = {
	_type_name = "EventProgress"
}
Auto.Meta[413].__index = Auto.Meta[413]
Auto.Meta[49] = {
	_type_name = "EventProgressInfo"
}
Auto.Meta[49].__index = Auto.Meta[49]
Auto.Meta[40] = {
	_type_name = "EventSpoonViewInfo"
}
Auto.Meta[40].__index = Auto.Meta[40]
Auto.Meta[89] = {
	_type_name = "FactionChangeInfo"
}
Auto.Meta[89].__index = Auto.Meta[89]
Auto.Meta[68] = {
	_type_name = "FactionInfo"
}
Auto.Meta[68].__index = Auto.Meta[68]
Auto.Meta[184] = {
	_type_name = "FansAutoGiveHistory"
}
Auto.Meta[184].__index = Auto.Meta[184]
Auto.Meta[414] = {
	_type_name = "FashionColoringInfo"
}
Auto.Meta[414].__index = Auto.Meta[414]
Auto.Meta[415] = {
	_type_name = "FashionColoringSchemeInfo"
}
Auto.Meta[415].__index = Auto.Meta[415]
Auto.Meta[416] = {
	_type_name = "FashionCustomSuitSchemeInfo",
	_base_type = Auto.Meta[417],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[416].__index = Auto.Meta[416]
Auto.Meta[418] = {
	_type_name = "FashionFunctionSuitSchemeInfo",
	_base_type = Auto.Meta[417],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[418].__index = Auto.Meta[418]
Auto.Meta[18] = {
	_type_name = "FashionInfo"
}
Auto.Meta[18].__index = Auto.Meta[18]
Auto.Meta[210] = {
	_type_name = "FightGamePlayerSimpleInfo"
}
Auto.Meta[210].__index = Auto.Meta[210]
Auto.Meta[419] = {
	_type_name = "FightGameResult"
}
Auto.Meta[419].__index = Auto.Meta[419]
Auto.Meta[420] = {
	_type_name = "FightGameStateInfo"
}
Auto.Meta[420].__index = Auto.Meta[420]
Auto.Meta[421] = {
	_type_name = "FightGameUnitInfo"
}
Auto.Meta[421].__index = Auto.Meta[421]
Auto.Meta[422] = {
	_type_name = "FightGroupDebugInfo"
}
Auto.Meta[422].__index = Auto.Meta[422]
Auto.Meta[127] = {
	_type_name = "FightPokemon"
}
Auto.Meta[127].__index = Auto.Meta[127]
Auto.Meta[423] = {
	_type_name = "FireworkBuyInfo"
}
Auto.Meta[423].__index = Auto.Meta[423]
Auto.Meta[424] = {
	_type_name = "FireworkPlanInfo"
}
Auto.Meta[424].__index = Auto.Meta[424]
Auto.Meta[174] = {
	_type_name = "FireworkStoreInfo"
}
Auto.Meta[174].__index = Auto.Meta[174]
Auto.Meta[425] = {
	_type_name = "FishDestructibleData",
	_base_type = Auto.Meta[233],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[425].__index = Auto.Meta[425]
Auto.Meta[426] = {
	_type_name = "Float3"
}
Auto.Meta[426].__index = Auto.Meta[426]
Auto.Meta[427] = {
	_type_name = "FloatingMoveData"
}
Auto.Meta[427].__index = Auto.Meta[427]
Auto.Meta[428] = {
	_type_name = "FollowRecordingParameters",
	_base_type = Auto.Meta[266],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[428].__index = Auto.Meta[428]
Auto.Meta[429] = {
	_type_name = "FormationPlayerSlot"
}
Auto.Meta[429].__index = Auto.Meta[429]
Auto.Meta[430] = {
	_type_name = "FriendSimpleData"
}
Auto.Meta[430].__index = Auto.Meta[430]
Auto.Meta[94] = {
	_type_name = "FurnitureInfo"
}
Auto.Meta[94].__index = Auto.Meta[94]
Auto.Meta[431] = {
	_type_name = "GadgetDestructibleInfo",
	_base_type = Auto.Meta[397],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[431].__index = Auto.Meta[431]
Auto.Meta[432] = {
	_type_name = "GadgetEntityInfo"
}
Auto.Meta[432].__index = Auto.Meta[432]
Auto.Meta[433] = {
	_type_name = "GadgetGridAOIIncrease"
}
Auto.Meta[433].__index = Auto.Meta[433]
Auto.Meta[434] = {
	_type_name = "GadgetPackSyncInfo"
}
Auto.Meta[434].__index = Auto.Meta[434]
Auto.Meta[103] = {
	_type_name = "GameGroundParticipantInfo"
}
Auto.Meta[103].__index = Auto.Meta[103]
Auto.Meta[115] = {
	_type_name = "GameGroundZoneInfo"
}
Auto.Meta[115].__index = Auto.Meta[115]
Auto.Meta[435] = {
	_type_name = "GameServerInfo"
}
Auto.Meta[435].__index = Auto.Meta[435]
Auto.Meta[63] = {
	_type_name = "GangBossFullDetails"
}
Auto.Meta[63].__index = Auto.Meta[63]
Auto.Meta[82] = {
	_type_name = "GangMembersInfos"
}
Auto.Meta[82].__index = Auto.Meta[82]
Auto.Meta[436] = {
	_type_name = "GmBehaviorKV"
}
Auto.Meta[436].__index = Auto.Meta[436]
Auto.Meta[437] = {
	_type_name = "GmCreateNpcOptionData"
}
Auto.Meta[437].__index = Auto.Meta[437]
Auto.Meta[438] = {
	_type_name = "GmCreatePedData"
}
Auto.Meta[438].__index = Auto.Meta[438]
Auto.Meta[211] = {
	_type_name = "GmEnemyStrategyInfo"
}
Auto.Meta[211].__index = Auto.Meta[211]
Auto.Meta[212] = {
	_type_name = "GmLockTargetRadius"
}
Auto.Meta[212].__index = Auto.Meta[212]
Auto.Meta[439] = {
	_type_name = "GmQueryObjectRoot"
}
Auto.Meta[439].__index = Auto.Meta[439]
Auto.Meta[440] = {
	_type_name = "GmQuerySceneInfo"
}
Auto.Meta[440].__index = Auto.Meta[440]
Auto.Meta[441] = {
	_type_name = "GmQuerySceneObjectInfo"
}
Auto.Meta[441].__index = Auto.Meta[441]
Auto.Meta[442] = {
	_type_name = "GomokuParticipantInfo",
	_base_type = Auto.Meta[103],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[442].__index = Auto.Meta[442]
Auto.Meta[443] = {
	_type_name = "GomokuParticipantScoreInfo"
}
Auto.Meta[443].__index = Auto.Meta[443]
Auto.Meta[102] = {
	_type_name = "GomokuPiece"
}
Auto.Meta[102].__index = Auto.Meta[102]
Auto.Meta[123] = {
	_type_name = "GomokuScoreInfo"
}
Auto.Meta[123].__index = Auto.Meta[123]
Auto.Meta[444] = {
	_type_name = "GomokuZoneInfo",
	_base_type = Auto.Meta[115],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[444].__index = Auto.Meta[444]
Auto.Meta[445] = {
	_type_name = "GridAOIDecrease"
}
Auto.Meta[445].__index = Auto.Meta[445]
Auto.Meta[446] = {
	_type_name = "GridIndex"
}
Auto.Meta[446].__index = Auto.Meta[446]
Auto.Meta[447] = {
	_type_name = "GymPlayResult"
}
Auto.Meta[447].__index = Auto.Meta[447]
Auto.Meta[19] = {
	_type_name = "HackerBatteryCurrentAndTotalCount"
}
Auto.Meta[19].__index = Auto.Meta[19]
Auto.Meta[448] = {
	_type_name = "HackerPostInfo"
}
Auto.Meta[448].__index = Auto.Meta[448]
Auto.Meta[449] = {
	_type_name = "HitPredictData"
}
Auto.Meta[449].__index = Auto.Meta[449]
Auto.Meta[52] = {
	_type_name = "HouseInfo"
}
Auto.Meta[52].__index = Auto.Meta[52]
Auto.Meta[450] = {
	_type_name = "HouseMoveParkingSpaceInfo"
}
Auto.Meta[450].__index = Auto.Meta[450]
Auto.Meta[451] = {
	_type_name = "HouseParkingInfo"
}
Auto.Meta[451].__index = Auto.Meta[451]
Auto.Meta[8] = {
	_type_name = "HouseVehicleParkingInfo"
}
Auto.Meta[8].__index = Auto.Meta[8]
Auto.Meta[201] = {
	_type_name = "HousesInfo"
}
Auto.Meta[201].__index = Auto.Meta[201]
Auto.Meta[150] = {
	_type_name = "ImSimpleData"
}
Auto.Meta[150].__index = Auto.Meta[150]
Auto.Meta[452] = {
	_type_name = "IndoorBuildInfo"
}
Auto.Meta[452].__index = Auto.Meta[452]
Auto.Meta[453] = {
	_type_name = "InteractCmdData"
}
Auto.Meta[453].__index = Auto.Meta[453]
Auto.Meta[454] = {
	_type_name = "ItemCountInfo"
}
Auto.Meta[454].__index = Auto.Meta[454]
Auto.Meta[61] = {
	_type_name = "ItemCountLimitInfo"
}
Auto.Meta[61].__index = Auto.Meta[61]
Auto.Meta[455] = {
	_type_name = "ItemDestructibleData",
	_base_type = Auto.Meta[233],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[455].__index = Auto.Meta[455]
Auto.Meta[58] = {
	_type_name = "ItemShortcutInfo"
}
Auto.Meta[58].__index = Auto.Meta[58]
Auto.Meta[456] = {
	_type_name = "LeadingWayUrging"
}
Auto.Meta[456].__index = Auto.Meta[456]
Auto.Meta[175] = {
	_type_name = "LinkInfoClient"
}
Auto.Meta[175].__index = Auto.Meta[175]
Auto.Meta[130] = {
	_type_name = "LinkMemberInfo"
}
Auto.Meta[130].__index = Auto.Meta[130]
Auto.Meta[457] = {
	_type_name = "LoadingTextInfo"
}
Auto.Meta[457].__index = Auto.Meta[457]
Auto.Meta[458] = {
	_type_name = "LoadingTypeInfo"
}
Auto.Meta[458].__index = Auto.Meta[458]
Auto.Meta[459] = {
	_type_name = "LogicVehicleUnitDebugData"
}
Auto.Meta[459].__index = Auto.Meta[459]
Auto.Meta[460] = {
	_type_name = "LookAtPositionData",
	_base_type = Auto.Meta[461],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[460].__index = Auto.Meta[460]
Auto.Meta[462] = {
	_type_name = "LookAtTargetData",
	_base_type = Auto.Meta[461],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[462].__index = Auto.Meta[462]
Auto.Meta[148] = {
	_type_name = "MahjongGameInfo"
}
Auto.Meta[148].__index = Auto.Meta[148]
Auto.Meta[149] = {
	_type_name = "MahjongPlayerInfo"
}
Auto.Meta[149].__index = Auto.Meta[149]
Auto.Meta[144] = {
	_type_name = "MahjongRoomInfo"
}
Auto.Meta[144].__index = Auto.Meta[144]
Auto.Meta[463] = {
	_type_name = "MaidTeaChoiceInfo"
}
Auto.Meta[463].__index = Auto.Meta[463]
Auto.Meta[207] = {
	_type_name = "MaidTeaMemeberInfo"
}
Auto.Meta[207].__index = Auto.Meta[207]
Auto.Meta[464] = {
	_type_name = "MailAttachment"
}
Auto.Meta[464].__index = Auto.Meta[464]
Auto.Meta[151] = {
	_type_name = "MailHead"
}
Auto.Meta[151].__index = Auto.Meta[151]
Auto.Meta[178] = {
	_type_name = "MailInfo"
}
Auto.Meta[178].__index = Auto.Meta[178]
Auto.Meta[135] = {
	_type_name = "MailParameter"
}
Auto.Meta[135].__index = Auto.Meta[135]
Auto.Meta[465] = {
	_type_name = "MallCommodityInfo"
}
Auto.Meta[465].__index = Auto.Meta[465]
Auto.Meta[466] = {
	_type_name = "MallInfo"
}
Auto.Meta[466].__index = Auto.Meta[466]
Auto.Meta[467] = {
	_type_name = "MapPin"
}
Auto.Meta[467].__index = Auto.Meta[467]
Auto.Meta[468] = {
	_type_name = "MassCustomArea"
}
Auto.Meta[468].__index = Auto.Meta[468]
Auto.Meta[469] = {
	_type_name = "MassTrafficLightControl"
}
Auto.Meta[469].__index = Auto.Meta[469]
Auto.Meta[470] = {
	_type_name = "MassTrafficSpawnArea"
}
Auto.Meta[470].__index = Auto.Meta[470]
Auto.Meta[471] = {
	_type_name = "MassTrafficSpawnAreaManager"
}
Auto.Meta[471].__index = Auto.Meta[471]
Auto.Meta[104] = {
	_type_name = "MatchPlayerSettleData"
}
Auto.Meta[104].__index = Auto.Meta[104]
Auto.Meta[155] = {
	_type_name = "MatchPrepareInfo"
}
Auto.Meta[155].__index = Auto.Meta[155]
Auto.Meta[15] = {
	_type_name = "MatchPrepareRoom",
	_base_type = Auto.Meta[164],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[15].__index = Auto.Meta[15]
Auto.Meta[153] = {
	_type_name = "MatchPrepareRoomDutySwapInfo"
}
Auto.Meta[153].__index = Auto.Meta[153]
Auto.Meta[472] = {
	_type_name = "MatchPrepareRoomPlayerSwapInfo"
}
Auto.Meta[472].__index = Auto.Meta[472]
Auto.Meta[164] = {
	_type_name = "MatchRoom"
}
Auto.Meta[164].__index = Auto.Meta[164]
Auto.Meta[473] = {
	_type_name = "MatchRoomMemberInfo"
}
Auto.Meta[473].__index = Auto.Meta[473]
Auto.Meta[156] = {
	_type_name = "MatchRoomSetting"
}
Auto.Meta[156].__index = Auto.Meta[156]
Auto.Meta[154] = {
	_type_name = "MatchTeamRoom",
	_base_type = Auto.Meta[164],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[154].__index = Auto.Meta[154]
Auto.Meta[474] = {
	_type_name = "MatchingFactor"
}
Auto.Meta[474].__index = Auto.Meta[474]
Auto.Meta[87] = {
	_type_name = "MessageCallbackParameter"
}
Auto.Meta[87].__index = Auto.Meta[87]
Auto.Meta[206] = {
	_type_name = "MetroCarriageGadgetInfos"
}
Auto.Meta[206].__index = Auto.Meta[206]
Auto.Meta[143] = {
	_type_name = "MetroClientInfo"
}
Auto.Meta[143].__index = Auto.Meta[143]
Auto.Meta[475] = {
	_type_name = "MetroHideArea"
}
Auto.Meta[475].__index = Auto.Meta[475]
Auto.Meta[476] = {
	_type_name = "MetroHitData"
}
Auto.Meta[476].__index = Auto.Meta[476]
Auto.Meta[477] = {
	_type_name = "MetroLineCarriageInfo"
}
Auto.Meta[477].__index = Auto.Meta[477]
Auto.Meta[185] = {
	_type_name = "MilkTopicInfo"
}
Auto.Meta[185].__index = Auto.Meta[185]
Auto.Meta[478] = {
	_type_name = "MiniGameData"
}
Auto.Meta[478].__index = Auto.Meta[478]
Auto.Meta[479] = {
	_type_name = "MjAction"
}
Auto.Meta[479].__index = Auto.Meta[479]
Auto.Meta[147] = {
	_type_name = "MjCanActionInfo"
}
Auto.Meta[147].__index = Auto.Meta[147]
Auto.Meta[480] = {
	_type_name = "MjPCGActionInfo"
}
Auto.Meta[480].__index = Auto.Meta[480]
Auto.Meta[145] = {
	_type_name = "MjPaiInfo"
}
Auto.Meta[145].__index = Auto.Meta[145]
Auto.Meta[481] = {
	_type_name = "MjPlayerResult"
}
Auto.Meta[481].__index = Auto.Meta[481]
Auto.Meta[146] = {
	_type_name = "MjResult"
}
Auto.Meta[146].__index = Auto.Meta[146]
Auto.Meta[140] = {
	_type_name = "MobilePlatformSyncInfo"
}
Auto.Meta[140].__index = Auto.Meta[140]
Auto.Meta[177] = {
	_type_name = "ModifySpiritWearFashionResult"
}
Auto.Meta[177].__index = Auto.Meta[177]
Auto.Meta[197] = {
	_type_name = "ModuleEventProgressInfo"
}
Auto.Meta[197].__index = Auto.Meta[197]
Auto.Meta[482] = {
	_type_name = "ModuleEventProgressInfoBySpirit"
}
Auto.Meta[482].__index = Auto.Meta[482]
Auto.Meta[88] = {
	_type_name = "MomentsNotifyClientInfo"
}
Auto.Meta[88].__index = Auto.Meta[88]
Auto.Meta[16] = {
	_type_name = "MonitorTwitterBehavior"
}
Auto.Meta[16].__index = Auto.Meta[16]
Auto.Meta[483] = {
	_type_name = "MoveActionData"
}
Auto.Meta[483].__index = Auto.Meta[483]
Auto.Meta[484] = {
	_type_name = "MoveActionGroundData"
}
Auto.Meta[484].__index = Auto.Meta[484]
Auto.Meta[485] = {
	_type_name = "MoveToBorderData"
}
Auto.Meta[485].__index = Auto.Meta[485]
Auto.Meta[486] = {
	_type_name = "MoveToCanShootPosData"
}
Auto.Meta[486].__index = Auto.Meta[486]
Auto.Meta[487] = {
	_type_name = "MoveToEQSData"
}
Auto.Meta[487].__index = Auto.Meta[487]
Auto.Meta[488] = {
	_type_name = "MoveToPosData"
}
Auto.Meta[488].__index = Auto.Meta[488]
Auto.Meta[489] = {
	_type_name = "MoveTowardUnitData"
}
Auto.Meta[489].__index = Auto.Meta[489]
Auto.Meta[490] = {
	_type_name = "MoveWanderingData"
}
Auto.Meta[490].__index = Auto.Meta[490]
Auto.Meta[170] = {
	_type_name = "MusicClientInfo"
}
Auto.Meta[170].__index = Auto.Meta[170]
Auto.Meta[491] = {
	_type_name = "NameCard"
}
Auto.Meta[491].__index = Auto.Meta[491]
Auto.Meta[182] = {
	_type_name = "NewChallengeRecord"
}
Auto.Meta[182].__index = Auto.Meta[182]
Auto.Meta[492] = {
	_type_name = "NewClientBoardingInfo"
}
Auto.Meta[492].__index = Auto.Meta[492]
Auto.Meta[157] = {
	_type_name = "NewHotFixPatchData"
}
Auto.Meta[157].__index = Auto.Meta[157]
Auto.Meta[493] = {
	_type_name = "NgpushSetting"
}
Auto.Meta[493].__index = Auto.Meta[493]
Auto.Meta[196] = {
	_type_name = "NodeSpoonOutputLinks"
}
Auto.Meta[196].__index = Auto.Meta[196]
Auto.Meta[28] = {
	_type_name = "NpcCardInfo"
}
Auto.Meta[28].__index = Auto.Meta[28]
Auto.Meta[494] = {
	_type_name = "NpcChatContext"
}
Auto.Meta[494].__index = Auto.Meta[494]
Auto.Meta[24] = {
	_type_name = "NpcChatItem"
}
Auto.Meta[24].__index = Auto.Meta[24]
Auto.Meta[495] = {
	_type_name = "NpcEventQueue"
}
Auto.Meta[495].__index = Auto.Meta[495]
Auto.Meta[496] = {
	_type_name = "NpcEventQueueList"
}
Auto.Meta[496].__index = Auto.Meta[496]
Auto.Meta[497] = {
	_type_name = "NpcScheduleInfo"
}
Auto.Meta[497].__index = Auto.Meta[497]
Auto.Meta[176] = {
	_type_name = "NpcShareTimeInfo"
}
Auto.Meta[176].__index = Auto.Meta[176]
Auto.Meta[73] = {
	_type_name = "NpcShopCommodityInfo"
}
Auto.Meta[73].__index = Auto.Meta[73]
Auto.Meta[166] = {
	_type_name = "NpcShopInfo"
}
Auto.Meta[166].__index = Auto.Meta[166]
Auto.Meta[76] = {
	_type_name = "NpcTimeTableInfo"
}
Auto.Meta[76].__index = Auto.Meta[76]
Auto.Meta[7] = {
	_type_name = "NpcTrustValueInfo"
}
Auto.Meta[7].__index = Auto.Meta[7]
Auto.Meta[498] = {
	_type_name = "NpcVehicleDriveStateInfo"
}
Auto.Meta[498].__index = Auto.Meta[498]
Auto.Meta[499] = {
	_type_name = "OccupyDebugInfo"
}
Auto.Meta[499].__index = Auto.Meta[499]
Auto.Meta[129] = {
	_type_name = "OtherPlayerSpiritWearFashionsInfo",
	_base_type = Auto.Meta[417],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[129].__index = Auto.Meta[129]
Auto.Meta[500] = {
	_type_name = "OwnerSyncData"
}
Auto.Meta[500].__index = Auto.Meta[500]
Auto.Meta[171] = {
	_type_name = "PSNPlayerInfo"
}
Auto.Meta[171].__index = Auto.Meta[171]
Auto.Meta[501] = {
	_type_name = "PackedDestructibleInfo"
}
Auto.Meta[501].__index = Auto.Meta[501]
Auto.Meta[502] = {
	_type_name = "PackedGadgetInfo"
}
Auto.Meta[502].__index = Auto.Meta[502]
Auto.Meta[503] = {
	_type_name = "PackedGadgetSpecialParam"
}
Auto.Meta[503].__index = Auto.Meta[503]
Auto.Meta[504] = {
	_type_name = "PartyNPCMessage"
}
Auto.Meta[504].__index = Auto.Meta[504]
Auto.Meta[107] = {
	_type_name = "PartyResponse"
}
Auto.Meta[107].__index = Auto.Meta[107]
Auto.Meta[96] = {
	_type_name = "PartySettleData"
}
Auto.Meta[96].__index = Auto.Meta[96]
Auto.Meta[159] = {
	_type_name = "PatchEntry"
}
Auto.Meta[159].__index = Auto.Meta[159]
Auto.Meta[505] = {
	_type_name = "PauseFrameData"
}
Auto.Meta[505].__index = Auto.Meta[505]
Auto.Meta[506] = {
	_type_name = "PersonalTeamSetting"
}
Auto.Meta[506].__index = Auto.Meta[506]
Auto.Meta[507] = {
	_type_name = "PersonalTimeSetting"
}
Auto.Meta[507].__index = Auto.Meta[507]
Auto.Meta[508] = {
	_type_name = "PersonalZoneAchievement"
}
Auto.Meta[508].__index = Auto.Meta[508]
Auto.Meta[195] = {
	_type_name = "PersonalZoneFightSpiritInfo"
}
Auto.Meta[195].__index = Auto.Meta[195]
Auto.Meta[188] = {
	_type_name = "PersonalZoneHeadExtendInfo"
}
Auto.Meta[188].__index = Auto.Meta[188]
Auto.Meta[509] = {
	_type_name = "PersonalZoneHeadInfo"
}
Auto.Meta[509].__index = Auto.Meta[509]
Auto.Meta[510] = {
	_type_name = "PersonalZoneItemInfo"
}
Auto.Meta[510].__index = Auto.Meta[510]
Auto.Meta[191] = {
	_type_name = "PersonalZoneUnlockBackgroundInfo"
}
Auto.Meta[191].__index = Auto.Meta[191]
Auto.Meta[70] = {
	_type_name = "PhoneContact"
}
Auto.Meta[70].__index = Auto.Meta[70]
Auto.Meta[511] = {
	_type_name = "PhoneContactCallRecord"
}
Auto.Meta[511].__index = Auto.Meta[511]
Auto.Meta[512] = {
	_type_name = "PhoneContactGroup"
}
Auto.Meta[512].__index = Auto.Meta[512]
Auto.Meta[55] = {
	_type_name = "PhoneInfos"
}
Auto.Meta[55].__index = Auto.Meta[55]
Auto.Meta[95] = {
	_type_name = "PlacedFurnitureInfo"
}
Auto.Meta[95].__index = Auto.Meta[95]
Auto.Meta[4] = {
	_type_name = "PlanningBoardInfo"
}
Auto.Meta[4].__index = Auto.Meta[4]
Auto.Meta[513] = {
	_type_name = "PlateGridAOIInfo"
}
Auto.Meta[513].__index = Auto.Meta[513]
Auto.Meta[514] = {
	_type_name = "PlateInfo"
}
Auto.Meta[514].__index = Auto.Meta[514]
Auto.Meta[515] = {
	_type_name = "PlayActionData",
	_base_type = Auto.Meta[461],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[515].__index = Auto.Meta[515]
Auto.Meta[516] = {
	_type_name = "PlayActionWithLayerData",
	_base_type = Auto.Meta[461],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[516].__index = Auto.Meta[516]
Auto.Meta[6] = {
	_type_name = "PlayerBasicInfoVO"
}
Auto.Meta[6].__index = Auto.Meta[6]
Auto.Meta[83] = {
	_type_name = "PlayerBattlePassInfo"
}
Auto.Meta[83].__index = Auto.Meta[83]
Auto.Meta[517] = {
	_type_name = "PlayerCityPediaInfos"
}
Auto.Meta[517].__index = Auto.Meta[517]
Auto.Meta[78] = {
	_type_name = "PlayerClientInfo"
}
Auto.Meta[78].__index = Auto.Meta[78]
Auto.Meta[518] = {
	_type_name = "PlayerClientInfoAchievement"
}
Auto.Meta[518].__index = Auto.Meta[518]
Auto.Meta[519] = {
	_type_name = "PlayerClientInfoAtmosphereGameplay"
}
Auto.Meta[519].__index = Auto.Meta[519]
Auto.Meta[520] = {
	_type_name = "PlayerClientInfoGuide"
}
Auto.Meta[520].__index = Auto.Meta[520]
Auto.Meta[521] = {
	_type_name = "PlayerClientInfoItem"
}
Auto.Meta[521].__index = Auto.Meta[521]
Auto.Meta[522] = {
	_type_name = "PlayerClientInfoLogin"
}
Auto.Meta[522].__index = Auto.Meta[522]
Auto.Meta[523] = {
	_type_name = "PlayerClientInfoMinor"
}
Auto.Meta[523].__index = Auto.Meta[523]
Auto.Meta[524] = {
	_type_name = "PlayerClientInfoNpcCultivation"
}
Auto.Meta[524].__index = Auto.Meta[524]
Auto.Meta[525] = {
	_type_name = "PlayerClientInfoNpcProfile"
}
Auto.Meta[525].__index = Auto.Meta[525]
Auto.Meta[526] = {
	_type_name = "PlayerClientInfoSpirit"
}
Auto.Meta[526].__index = Auto.Meta[526]
Auto.Meta[527] = {
	_type_name = "PlayerClientInspireHubInfo"
}
Auto.Meta[527].__index = Auto.Meta[527]
Auto.Meta[132] = {
	_type_name = "PlayerDieInfo"
}
Auto.Meta[132].__index = Auto.Meta[132]
Auto.Meta[199] = {
	_type_name = "PlayerFashionsInfo"
}
Auto.Meta[199].__index = Auto.Meta[199]
Auto.Meta[528] = {
	_type_name = "PlayerFightStyleUnLockChangeInfo"
}
Auto.Meta[528].__index = Auto.Meta[528]
Auto.Meta[529] = {
	_type_name = "PlayerGachaGroupInfo"
}
Auto.Meta[529].__index = Auto.Meta[529]
Auto.Meta[530] = {
	_type_name = "PlayerGachaInfos"
}
Auto.Meta[530].__index = Auto.Meta[530]
Auto.Meta[531] = {
	_type_name = "PlayerGachaPityInfo"
}
Auto.Meta[531].__index = Auto.Meta[531]
Auto.Meta[532] = {
	_type_name = "PlayerGachaPoolInfo"
}
Auto.Meta[532].__index = Auto.Meta[532]
Auto.Meta[71] = {
	_type_name = "PlayerHotSpringInfo"
}
Auto.Meta[71].__index = Auto.Meta[71]
Auto.Meta[533] = {
	_type_name = "PlayerInfoArmory"
}
Auto.Meta[533].__index = Auto.Meta[533]
Auto.Meta[534] = {
	_type_name = "PlayerInfoBadge"
}
Auto.Meta[534].__index = Auto.Meta[534]
Auto.Meta[535] = {
	_type_name = "PlayerInfoFightStyle"
}
Auto.Meta[535].__index = Auto.Meta[535]
Auto.Meta[536] = {
	_type_name = "PlayerInfoJobGangBoss"
}
Auto.Meta[536].__index = Auto.Meta[536]
Auto.Meta[187] = {
	_type_name = "PlayerInfoJobWasher"
}
Auto.Meta[187].__index = Auto.Meta[187]
Auto.Meta[537] = {
	_type_name = "PlayerInfoPokemon"
}
Auto.Meta[537].__index = Auto.Meta[537]
Auto.Meta[538] = {
	_type_name = "PlayerInfoPopularity"
}
Auto.Meta[538].__index = Auto.Meta[538]
Auto.Meta[539] = {
	_type_name = "PlayerInteractionActionInfo"
}
Auto.Meta[539].__index = Auto.Meta[539]
Auto.Meta[79] = {
	_type_name = "PlayerInteractionActionItem"
}
Auto.Meta[79].__index = Auto.Meta[79]
Auto.Meta[173] = {
	_type_name = "PlayerInvestigateCountryInfo"
}
Auto.Meta[173].__index = Auto.Meta[173]
Auto.Meta[72] = {
	_type_name = "PlayerInvestigateGalleryInfo"
}
Auto.Meta[72].__index = Auto.Meta[72]
Auto.Meta[32] = {
	_type_name = "PlayerItemDayCount"
}
Auto.Meta[32].__index = Auto.Meta[32]
Auto.Meta[540] = {
	_type_name = "PlayerLinkPlanningBoardInfo"
}
Auto.Meta[540].__index = Auto.Meta[540]
Auto.Meta[541] = {
	_type_name = "PlayerLoginOption"
}
Auto.Meta[541].__index = Auto.Meta[541]
Auto.Meta[172] = {
	_type_name = "PlayerMahjongInfo"
}
Auto.Meta[172].__index = Auto.Meta[172]
Auto.Meta[75] = {
	_type_name = "PlayerMatchInfo"
}
Auto.Meta[75].__index = Auto.Meta[75]
Auto.Meta[542] = {
	_type_name = "PlayerMonthCardInfo"
}
Auto.Meta[542].__index = Auto.Meta[542]
Auto.Meta[2] = {
	_type_name = "PlayerPackItem"
}
Auto.Meta[2].__index = Auto.Meta[2]
Auto.Meta[198] = {
	_type_name = "PlayerPartyInfo"
}
Auto.Meta[198].__index = Auto.Meta[198]
Auto.Meta[543] = {
	_type_name = "PlayerPhoneInfo"
}
Auto.Meta[543].__index = Auto.Meta[543]
Auto.Meta[57] = {
	_type_name = "PlayerVehicleClientDetail"
}
Auto.Meta[57].__index = Auto.Meta[57]
Auto.Meta[544] = {
	_type_name = "PlayerVehicleDetail"
}
Auto.Meta[544].__index = Auto.Meta[544]
Auto.Meta[100] = {
	_type_name = "PlayerVehicleDriveStateInfo"
}
Auto.Meta[100].__index = Auto.Meta[100]
Auto.Meta[545] = {
	_type_name = "PlayerVehicleInfo"
}
Auto.Meta[545].__index = Auto.Meta[545]
Auto.Meta[546] = {
	_type_name = "PlayerVehiclePartInfo"
}
Auto.Meta[546].__index = Auto.Meta[546]
Auto.Meta[547] = {
	_type_name = "PlotMinMaxRange"
}
Auto.Meta[547].__index = Auto.Meta[547]
Auto.Meta[548] = {
	_type_name = "PointInteractInfo"
}
Auto.Meta[548].__index = Auto.Meta[548]
Auto.Meta[549] = {
	_type_name = "PointInteractPlayerAction"
}
Auto.Meta[549].__index = Auto.Meta[549]
Auto.Meta[42] = {
	_type_name = "PokemonEnemy"
}
Auto.Meta[42].__index = Auto.Meta[42]
Auto.Meta[59] = {
	_type_name = "PoliceCaseInfo"
}
Auto.Meta[59].__index = Auto.Meta[59]
Auto.Meta[550] = {
	_type_name = "PoliceChargingSkillInfo"
}
Auto.Meta[550].__index = Auto.Meta[550]
Auto.Meta[551] = {
	_type_name = "PoliceDispatchExtraInfo"
}
Auto.Meta[551].__index = Auto.Meta[551]
Auto.Meta[48] = {
	_type_name = "PoliceDispatchInfo"
}
Auto.Meta[48].__index = Auto.Meta[48]
Auto.Meta[552] = {
	_type_name = "PoliceDutyBasicInfo"
}
Auto.Meta[552].__index = Auto.Meta[552]
Auto.Meta[553] = {
	_type_name = "PoliceFakeClueAgentInfo"
}
Auto.Meta[553].__index = Auto.Meta[553]
Auto.Meta[67] = {
	_type_name = "PoliceFakeFileInfo"
}
Auto.Meta[67].__index = Auto.Meta[67]
Auto.Meta[50] = {
	_type_name = "PoliceServiceData"
}
Auto.Meta[50].__index = Auto.Meta[50]
Auto.Meta[97] = {
	_type_name = "PoliceVehicleSpawnClientInfo"
}
Auto.Meta[97].__index = Auto.Meta[97]
Auto.Meta[98] = {
	_type_name = "PoliceVehicleSpawnConfigInfo"
}
Auto.Meta[98].__index = Auto.Meta[98]
Auto.Meta[51] = {
	_type_name = "PoliceViolationInfo"
}
Auto.Meta[51].__index = Auto.Meta[51]
Auto.Meta[554] = {
	_type_name = "PopularityChangeInfo"
}
Auto.Meta[554].__index = Auto.Meta[554]
Auto.Meta[77] = {
	_type_name = "PopularityData"
}
Auto.Meta[77].__index = Auto.Meta[77]
Auto.Meta[93] = {
	_type_name = "PopularityDropData"
}
Auto.Meta[93].__index = Auto.Meta[93]
Auto.Meta[92] = {
	_type_name = "PopularityWalletRewardData"
}
Auto.Meta[92].__index = Auto.Meta[92]
Auto.Meta[555] = {
	_type_name = "PosServerEffectData",
	_base_type = Auto.Meta[556],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[555].__index = Auto.Meta[555]
Auto.Meta[218] = {
	_type_name = "PossiblePlayerData"
}
Auto.Meta[218].__index = Auto.Meta[218]
Auto.Meta[557] = {
	_type_name = "PostPlayerCommentClientInfo"
}
Auto.Meta[557].__index = Auto.Meta[557]
Auto.Meta[183] = {
	_type_name = "PostSimpleClientInfo"
}
Auto.Meta[183].__index = Auto.Meta[183]
Auto.Meta[558] = {
	_type_name = "PreSwitchSpiritData"
}
Auto.Meta[558].__index = Auto.Meta[558]
Auto.Meta[559] = {
	_type_name = "QueryComponentInfo"
}
Auto.Meta[559].__index = Auto.Meta[559]
Auto.Meta[560] = {
	_type_name = "QueryFieldInfo"
}
Auto.Meta[560].__index = Auto.Meta[560]
Auto.Meta[561] = {
	_type_name = "QueryGameObjectFilter"
}
Auto.Meta[561].__index = Auto.Meta[561]
Auto.Meta[562] = {
	_type_name = "RacingInfo"
}
Auto.Meta[562].__index = Auto.Meta[562]
Auto.Meta[563] = {
	_type_name = "RacingParameters",
	_base_type = Auto.Meta[266],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[563].__index = Auto.Meta[563]
Auto.Meta[114] = {
	_type_name = "RaidBattleData"
}
Auto.Meta[114].__index = Auto.Meta[114]
Auto.Meta[564] = {
	_type_name = "RaidBattleUnitAgent"
}
Auto.Meta[564].__index = Auto.Meta[564]
Auto.Meta[565] = {
	_type_name = "RaidBattleUnitSpirit"
}
Auto.Meta[565].__index = Auto.Meta[565]
Auto.Meta[142] = {
	_type_name = "RaidCleaningInfo"
}
Auto.Meta[142].__index = Auto.Meta[142]
Auto.Meta[125] = {
	_type_name = "RaidGamePlayInfo"
}
Auto.Meta[125].__index = Auto.Meta[125]
Auto.Meta[566] = {
	_type_name = "RaidGamePlayRecordValueInfo"
}
Auto.Meta[566].__index = Auto.Meta[566]
Auto.Meta[567] = {
	_type_name = "RaidVehicleGpsInfo"
}
Auto.Meta[567].__index = Auto.Meta[567]
Auto.Meta[568] = {
	_type_name = "RaidVehicleSeatInfo"
}
Auto.Meta[568].__index = Auto.Meta[568]
Auto.Meta[569] = {
	_type_name = "RaidVehicleSyncData"
}
Auto.Meta[569].__index = Auto.Meta[569]
Auto.Meta[570] = {
	_type_name = "RamParameters",
	_base_type = Auto.Meta[266],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[570].__index = Auto.Meta[570]
Auto.Meta[571] = {
	_type_name = "RangeMoveType"
}
Auto.Meta[571].__index = Auto.Meta[571]
Auto.Meta[572] = {
	_type_name = "RelationVO"
}
Auto.Meta[572].__index = Auto.Meta[572]
Auto.Meta[573] = {
	_type_name = "ReportBehaviorSeqStartInfo"
}
Auto.Meta[573].__index = Auto.Meta[573]
Auto.Meta[574] = {
	_type_name = "ResetFashionColoringInfo"
}
Auto.Meta[574].__index = Auto.Meta[574]
Auto.Meta[575] = {
	_type_name = "ResetFashionColoringSchemeInfo"
}
Auto.Meta[575].__index = Auto.Meta[575]
Auto.Meta[576] = {
	_type_name = "RestaurantResult"
}
Auto.Meta[576].__index = Auto.Meta[576]
Auto.Meta[577] = {
	_type_name = "RewardCollectionInfo"
}
Auto.Meta[577].__index = Auto.Meta[577]
Auto.Meta[578] = {
	_type_name = "RewardDetail"
}
Auto.Meta[578].__index = Auto.Meta[578]
Auto.Meta[579] = {
	_type_name = "RewardExtraInfo"
}
Auto.Meta[579].__index = Auto.Meta[579]
Auto.Meta[45] = {
	_type_name = "RewardInfo"
}
Auto.Meta[45].__index = Auto.Meta[45]
Auto.Meta[580] = {
	_type_name = "RewardUrbanAbilityInfo"
}
Auto.Meta[580].__index = Auto.Meta[580]
Auto.Meta[1] = {
	_type_name = "RollIntervalMessage"
}
Auto.Meta[1].__index = Auto.Meta[1]
Auto.Meta[128] = {
	_type_name = "SceneCreationInfo"
}
Auto.Meta[128].__index = Auto.Meta[128]
Auto.Meta[581] = {
	_type_name = "SceneFogMap"
}
Auto.Meta[581].__index = Auto.Meta[581]
Auto.Meta[582] = {
	_type_name = "SceneItemDropActionInfo"
}
Auto.Meta[582].__index = Auto.Meta[582]
Auto.Meta[583] = {
	_type_name = "SceneItemOccupantInfo"
}
Auto.Meta[583].__index = Auto.Meta[583]
Auto.Meta[584] = {
	_type_name = "SceneRoomChangeData"
}
Auto.Meta[584].__index = Auto.Meta[584]
Auto.Meta[585] = {
	_type_name = "SeatInfo"
}
Auto.Meta[585].__index = Auto.Meta[585]
Auto.Meta[586] = {
	_type_name = "SerializeMinMaxAABB"
}
Auto.Meta[586].__index = Auto.Meta[586]
Auto.Meta[587] = {
	_type_name = "SerializeQuaternion"
}
Auto.Meta[587].__index = Auto.Meta[587]
Auto.Meta[556] = {
	_type_name = "ServerEffectData"
}
Auto.Meta[556].__index = Auto.Meta[556]
Auto.Meta[588] = {
	_type_name = "ServerSimpleGridInfo"
}
Auto.Meta[588].__index = Auto.Meta[588]
Auto.Meta[589] = {
	_type_name = "SetEmotionData"
}
Auto.Meta[589].__index = Auto.Meta[589]
Auto.Meta[590] = {
	_type_name = "SimpleMailAttchment"
}
Auto.Meta[590].__index = Auto.Meta[590]
Auto.Meta[162] = {
	_type_name = "SimpleUnreadMessage"
}
Auto.Meta[162].__index = Auto.Meta[162]
Auto.Meta[591] = {
	_type_name = "SimpleVehicleSyncData"
}
Auto.Meta[591].__index = Auto.Meta[591]
Auto.Meta[592] = {
	_type_name = "SkillCreationData"
}
Auto.Meta[592].__index = Auto.Meta[592]
Auto.Meta[131] = {
	_type_name = "SkillDestructibleData"
}
Auto.Meta[131].__index = Auto.Meta[131]
Auto.Meta[593] = {
	_type_name = "SkillExecuteData"
}
Auto.Meta[593].__index = Auto.Meta[593]
Auto.Meta[594] = {
	_type_name = "SkillHitData"
}
Auto.Meta[594].__index = Auto.Meta[594]
Auto.Meta[595] = {
	_type_name = "SkillParam"
}
Auto.Meta[595].__index = Auto.Meta[595]
Auto.Meta[596] = {
	_type_name = "SkillShieldData"
}
Auto.Meta[596].__index = Auto.Meta[596]
Auto.Meta[597] = {
	_type_name = "SkillStateData"
}
Auto.Meta[597].__index = Auto.Meta[597]
Auto.Meta[598] = {
	_type_name = "SkillSummonData"
}
Auto.Meta[598].__index = Auto.Meta[598]
Auto.Meta[599] = {
	_type_name = "SkillTimeCurveData"
}
Auto.Meta[599].__index = Auto.Meta[599]
Auto.Meta[600] = {
	_type_name = "SkillUseData"
}
Auto.Meta[600].__index = Auto.Meta[600]
Auto.Meta[601] = {
	_type_name = "SpawnAreaSelector"
}
Auto.Meta[601].__index = Auto.Meta[601]
Auto.Meta[602] = {
	_type_name = "SpawnLaneSelector"
}
Auto.Meta[602].__index = Auto.Meta[602]
Auto.Meta[603] = {
	_type_name = "SpinOutParameters",
	_base_type = Auto.Meta[266],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[603].__index = Auto.Meta[603]
Auto.Meta[60] = {
	_type_name = "SpiritAbilityInfo"
}
Auto.Meta[60].__index = Auto.Meta[60]
Auto.Meta[110] = {
	_type_name = "SpiritAddWeaponAction"
}
Auto.Meta[110].__index = Auto.Meta[110]
Auto.Meta[9] = {
	_type_name = "SpiritBartenderInfo"
}
Auto.Meta[9].__index = Auto.Meta[9]
Auto.Meta[604] = {
	_type_name = "SpiritBattleData"
}
Auto.Meta[604].__index = Auto.Meta[604]
Auto.Meta[605] = {
	_type_name = "SpiritBattleInfo"
}
Auto.Meta[605].__index = Auto.Meta[605]
Auto.Meta[90] = {
	_type_name = "SpiritDrawViewData"
}
Auto.Meta[90].__index = Auto.Meta[90]
Auto.Meta[606] = {
	_type_name = "SpiritFashionsInfo"
}
Auto.Meta[606].__index = Auto.Meta[606]
Auto.Meta[607] = {
	_type_name = "SpiritFightStyleInfo"
}
Auto.Meta[607].__index = Auto.Meta[607]
Auto.Meta[608] = {
	_type_name = "SpiritFightTypeChangeAction"
}
Auto.Meta[608].__index = Auto.Meta[608]
Auto.Meta[14] = {
	_type_name = "SpiritGroupChatInfo"
}
Auto.Meta[14].__index = Auto.Meta[14]
Auto.Meta[11] = {
	_type_name = "SpiritHackerJobInfo"
}
Auto.Meta[11].__index = Auto.Meta[11]
Auto.Meta[25] = {
	_type_name = "SpiritInfo"
}
Auto.Meta[25].__index = Auto.Meta[25]
Auto.Meta[609] = {
	_type_name = "SpiritInitData"
}
Auto.Meta[609].__index = Auto.Meta[609]
Auto.Meta[26] = {
	_type_name = "SpiritJob"
}
Auto.Meta[26].__index = Auto.Meta[26]
Auto.Meta[610] = {
	_type_name = "SpiritJobInfo"
}
Auto.Meta[610].__index = Auto.Meta[610]
Auto.Meta[611] = {
	_type_name = "SpiritJobTalentInfo"
}
Auto.Meta[611].__index = Auto.Meta[611]
Auto.Meta[81] = {
	_type_name = "SpiritMobileSkinInfo"
}
Auto.Meta[81].__index = Auto.Meta[81]
Auto.Meta[612] = {
	_type_name = "SpiritOrJobTalentNodeInfo"
}
Auto.Meta[612].__index = Auto.Meta[612]
Auto.Meta[181] = {
	_type_name = "SpiritPanelData"
}
Auto.Meta[181].__index = Auto.Meta[181]
Auto.Meta[3] = {
	_type_name = "SpiritPoliceJobInfo"
}
Auto.Meta[3].__index = Auto.Meta[3]
Auto.Meta[101] = {
	_type_name = "SpiritRemoveWeaponAction"
}
Auto.Meta[101].__index = Auto.Meta[101]
Auto.Meta[133] = {
	_type_name = "SpiritSwitchWeaponAction"
}
Auto.Meta[133].__index = Auto.Meta[133]
Auto.Meta[613] = {
	_type_name = "SpiritTalentExpInfo"
}
Auto.Meta[613].__index = Auto.Meta[613]
Auto.Meta[614] = {
	_type_name = "SpiritTalentInfo",
	_base_type = Auto.Meta[611],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[614].__index = Auto.Meta[614]
Auto.Meta[119] = {
	_type_name = "SpiritUpdateWeaponAction"
}
Auto.Meta[119].__index = Auto.Meta[119]
Auto.Meta[615] = {
	_type_name = "SpiritUrbanSkill"
}
Auto.Meta[615].__index = Auto.Meta[615]
Auto.Meta[616] = {
	_type_name = "SpiritVirtualFightStyleInfo"
}
Auto.Meta[616].__index = Auto.Meta[616]
Auto.Meta[117] = {
	_type_name = "SpiritWeaponDetail"
}
Auto.Meta[117].__index = Auto.Meta[117]
Auto.Meta[46] = {
	_type_name = "SpiritWearFashionsInfo",
	_base_type = Auto.Meta[417],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[46].__index = Auto.Meta[46]
Auto.Meta[617] = {
	_type_name = "SpoonActionParam"
}
Auto.Meta[617].__index = Auto.Meta[617]
Auto.Meta[113] = {
	_type_name = "SpoonClientActionTaskInfo"
}
Auto.Meta[113].__index = Auto.Meta[113]
Auto.Meta[618] = {
	_type_name = "SpoonClientData"
}
Auto.Meta[618].__index = Auto.Meta[618]
Auto.Meta[619] = {
	_type_name = "SpoonOutputLink"
}
Auto.Meta[619].__index = Auto.Meta[619]
Auto.Meta[116] = {
	_type_name = "SpoonTaskClientData"
}
Auto.Meta[116].__index = Auto.Meta[116]
Auto.Meta[620] = {
	_type_name = "SpoonTriggerInfo"
}
Auto.Meta[620].__index = Auto.Meta[620]
Auto.Meta[621] = {
	_type_name = "StartAttractInfo"
}
Auto.Meta[621].__index = Auto.Meta[621]
Auto.Meta[622] = {
	_type_name = "StartPatrolInfo"
}
Auto.Meta[622].__index = Auto.Meta[622]
Auto.Meta[623] = {
	_type_name = "StaticDestructibleInfo",
	_base_type = Auto.Meta[397],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[623].__index = Auto.Meta[623]
Auto.Meta[624] = {
	_type_name = "StimEventParameter"
}
Auto.Meta[624].__index = Auto.Meta[624]
Auto.Meta[625] = {
	_type_name = "StopParameters",
	_base_type = Auto.Meta[266],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[625].__index = Auto.Meta[625]
Auto.Meta[209] = {
	_type_name = "SummonVehicleResult"
}
Auto.Meta[209].__index = Auto.Meta[209]
Auto.Meta[626] = {
	_type_name = "SurroundNpcSpawnInfo"
}
Auto.Meta[626].__index = Auto.Meta[626]
Auto.Meta[205] = {
	_type_name = "SyncCinemaQueryInfo"
}
Auto.Meta[205].__index = Auto.Meta[205]
Auto.Meta[203] = {
	_type_name = "SyncMultiCinemaQueryInfo"
}
Auto.Meta[203].__index = Auto.Meta[203]
Auto.Meta[627] = {
	_type_name = "TaskDestructibleInfo",
	_base_type = Auto.Meta[397],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[627].__index = Auto.Meta[627]
Auto.Meta[628] = {
	_type_name = "TaskEventInfo"
}
Auto.Meta[628].__index = Auto.Meta[628]
Auto.Meta[13] = {
	_type_name = "TaskGps"
}
Auto.Meta[13].__index = Auto.Meta[13]
Auto.Meta[137] = {
	_type_name = "TaskSpoonViewInfo"
}
Auto.Meta[137].__index = Auto.Meta[137]
Auto.Meta[29] = {
	_type_name = "TaskStateData"
}
Auto.Meta[29].__index = Auto.Meta[29]
Auto.Meta[85] = {
	_type_name = "TaskTryFashionInfo"
}
Auto.Meta[85].__index = Auto.Meta[85]
Auto.Meta[629] = {
	_type_name = "TaskVehicleBuffInitInfo"
}
Auto.Meta[629].__index = Auto.Meta[629]
Auto.Meta[630] = {
	_type_name = "TaskViewCounter"
}
Auto.Meta[630].__index = Auto.Meta[630]
Auto.Meta[38] = {
	_type_name = "TaskViewData"
}
Auto.Meta[38].__index = Auto.Meta[38]
Auto.Meta[631] = {
	_type_name = "TaskWaitLoadResource"
}
Auto.Meta[631].__index = Auto.Meta[631]
Auto.Meta[5] = {
	_type_name = "TeamSetting"
}
Auto.Meta[5].__index = Auto.Meta[5]
Auto.Meta[189] = {
	_type_name = "TimePanelInfo"
}
Auto.Meta[189].__index = Auto.Meta[189]
Auto.Meta[632] = {
	_type_name = "TokenInfo"
}
Auto.Meta[632].__index = Auto.Meta[632]
Auto.Meta[33] = {
	_type_name = "TraceGps"
}
Auto.Meta[33].__index = Auto.Meta[33]
Auto.Meta[633] = {
	_type_name = "TrafficLightInfo"
}
Auto.Meta[633].__index = Auto.Meta[633]
Auto.Meta[634] = {
	_type_name = "TrafficLightPeriodControlInfo"
}
Auto.Meta[634].__index = Auto.Meta[634]
Auto.Meta[635] = {
	_type_name = "TruckJobOrderAccept"
}
Auto.Meta[635].__index = Auto.Meta[635]
Auto.Meta[636] = {
	_type_name = "TruckJobOrderInfo"
}
Auto.Meta[636].__index = Auto.Meta[636]
Auto.Meta[637] = {
	_type_name = "TruckJobOrderResult"
}
Auto.Meta[637].__index = Auto.Meta[637]
Auto.Meta[35] = {
	_type_name = "TruckJobOrderWrap"
}
Auto.Meta[35].__index = Auto.Meta[35]
Auto.Meta[638] = {
	_type_name = "TruckNpcInfo"
}
Auto.Meta[638].__index = Auto.Meta[638]
Auto.Meta[179] = {
	_type_name = "TruckPosInfo"
}
Auto.Meta[179].__index = Auto.Meta[179]
Auto.Meta[91] = {
	_type_name = "TrustNpcInfo"
}
Auto.Meta[91].__index = Auto.Meta[91]
Auto.Meta[12] = {
	_type_name = "TrustNpcTargetState"
}
Auto.Meta[12].__index = Auto.Meta[12]
Auto.Meta[54] = {
	_type_name = "TuiteInfo"
}
Auto.Meta[54].__index = Auto.Meta[54]
Auto.Meta[639] = {
	_type_name = "TurnToPositionData",
	_base_type = Auto.Meta[461],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[639].__index = Auto.Meta[639]
Auto.Meta[640] = {
	_type_name = "UXBoolObject",
	_base_type = Auto.Meta[641],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[640].__index = Auto.Meta[640]
Auto.Meta[642] = {
	_type_name = "UXDoubleObject",
	_base_type = Auto.Meta[641],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[642].__index = Auto.Meta[642]
Auto.Meta[643] = {
	_type_name = "UXIntObject",
	_base_type = Auto.Meta[641],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[643].__index = Auto.Meta[643]
Auto.Meta[644] = {
	_type_name = "UXLongObject",
	_base_type = Auto.Meta[641],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[644].__index = Auto.Meta[644]
Auto.Meta[202] = {
	_type_name = "UXMassHideArea"
}
Auto.Meta[202].__index = Auto.Meta[202]
Auto.Meta[641] = {
	_type_name = "UXObject"
}
Auto.Meta[641].__index = Auto.Meta[641]
Auto.Meta[645] = {
	_type_name = "UXStringObject",
	_base_type = Auto.Meta[641],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[645].__index = Auto.Meta[645]
Auto.Meta[646] = {
	_type_name = "UXUintObject",
	_base_type = Auto.Meta[641],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[646].__index = Auto.Meta[646]
Auto.Meta[647] = {
	_type_name = "UXUlongObject",
	_base_type = Auto.Meta[641],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[647].__index = Auto.Meta[647]
Auto.Meta[37] = {
	_type_name = "UintList"
}
Auto.Meta[37].__index = Auto.Meta[37]
Auto.Meta[648] = {
	_type_name = "UnitInfoOnMoveGround"
}
Auto.Meta[648].__index = Auto.Meta[648]
Auto.Meta[649] = {
	_type_name = "UrbanGamePlayResult"
}
Auto.Meta[649].__index = Auto.Meta[649]
Auto.Meta[650] = {
	_type_name = "VehicleAICommonParameters"
}
Auto.Meta[650].__index = Auto.Meta[650]
Auto.Meta[266] = {
	_type_name = "VehicleAITaskParameters"
}
Auto.Meta[266].__index = Auto.Meta[266]
Auto.Meta[651] = {
	_type_name = "VehicleAnimationBase"
}
Auto.Meta[651].__index = Auto.Meta[651]
Auto.Meta[652] = {
	_type_name = "VehicleBlockMove"
}
Auto.Meta[652].__index = Auto.Meta[652]
Auto.Meta[653] = {
	_type_name = "VehicleBrokenCollisionInfo"
}
Auto.Meta[653].__index = Auto.Meta[653]
Auto.Meta[136] = {
	_type_name = "VehicleClientInfo"
}
Auto.Meta[136].__index = Auto.Meta[136]
Auto.Meta[654] = {
	_type_name = "VehicleClientPart"
}
Auto.Meta[654].__index = Auto.Meta[654]
Auto.Meta[655] = {
	_type_name = "VehicleComponentStateUpdateInfo"
}
Auto.Meta[655].__index = Auto.Meta[655]
Auto.Meta[656] = {
	_type_name = "VehicleContactDamageData"
}
Auto.Meta[656].__index = Auto.Meta[656]
Auto.Meta[657] = {
	_type_name = "VehicleDangerZone"
}
Auto.Meta[657].__index = Auto.Meta[657]
Auto.Meta[658] = {
	_type_name = "VehicleEscapeDebugData"
}
Auto.Meta[658].__index = Auto.Meta[658]
Auto.Meta[659] = {
	_type_name = "VehicleHitData"
}
Auto.Meta[659].__index = Auto.Meta[659]
Auto.Meta[208] = {
	_type_name = "VehicleNavResult"
}
Auto.Meta[208].__index = Auto.Meta[208]
Auto.Meta[660] = {
	_type_name = "VehiclePartAnimation",
	_base_type = Auto.Meta[651],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[660].__index = Auto.Meta[660]
Auto.Meta[661] = {
	_type_name = "VehiclePoliceChaseParameters",
	_base_type = Auto.Meta[266],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[661].__index = Auto.Meta[661]
Auto.Meta[662] = {
	_type_name = "VehicleRamMove"
}
Auto.Meta[662].__index = Auto.Meta[662]
Auto.Meta[663] = {
	_type_name = "VehicleSkillDamageData"
}
Auto.Meta[663].__index = Auto.Meta[663]
Auto.Meta[664] = {
	_type_name = "VehicleSpecialPartAnimation",
	_base_type = Auto.Meta[651],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[664].__index = Auto.Meta[664]
Auto.Meta[665] = {
	_type_name = "VisibilityReportData"
}
Auto.Meta[665].__index = Auto.Meta[665]
Auto.Meta[666] = {
	_type_name = "WasherMissionHistoryInfo"
}
Auto.Meta[666].__index = Auto.Meta[666]
Auto.Meta[21] = {
	_type_name = "WasherMissionResult"
}
Auto.Meta[21].__index = Auto.Meta[21]
Auto.Meta[69] = {
	_type_name = "WeaponData"
}
Auto.Meta[69].__index = Auto.Meta[69]
Auto.Meta[667] = {
	_type_name = "WeaponDataFlags"
}
Auto.Meta[667].__index = Auto.Meta[667]
Auto.Meta[668] = {
	_type_name = "WeaponDetail",
	_base_type = Auto.Meta[69],
	_is_instance_of = IsInstanceOf
}
Auto.Meta[668].__index = Auto.Meta[668]
Auto.Meta[669] = {
	_type_name = "WeaponWheelData"
}
Auto.Meta[669].__index = Auto.Meta[669]
Auto.Meta[180] = {
	_type_name = "WearFashionEditInfo"
}
Auto.Meta[180].__index = Auto.Meta[180]
Auto.Meta[193] = {
	_type_name = "WearFashionInfo"
}
Auto.Meta[193].__index = Auto.Meta[193]
Auto.Meta[670] = {
	_type_name = "WebviewLoginTokenInfo"
}
Auto.Meta[670].__index = Auto.Meta[670]
Auto.Meta[163] = {
	_type_name = "WildEnemyClientInfo"
}
Auto.Meta[163].__index = Auto.Meta[163]
Auto.Meta[167] = {
	_type_name = "WildEnemyGroupClientInfo"
}
Auto.Meta[167].__index = Auto.Meta[167]
Auto.Meta[126] = {
	_type_name = "WildEnemyGroupInitSyncInfo"
}
Auto.Meta[126].__index = Auto.Meta[126]
Auto.Meta[200] = {
	_type_name = "WorkActionNodeInfo"
}
Auto.Meta[200].__index = Auto.Meta[200]
Auto.Meta[671] = {
	_type_name = "ZoneData"
}
Auto.Meta[671].__index = Auto.Meta[671]
Auto.Meta[672] = {
	_type_name = "ZoneGraphBVNode"
}
Auto.Meta[672].__index = Auto.Meta[672]
Auto.Meta[673] = {
	_type_name = "ZoneGraphBVTree"
}
Auto.Meta[673].__index = Auto.Meta[673]
Auto.Meta[674] = {
	_type_name = "ZoneGraphLaneLocation"
}
Auto.Meta[674].__index = Auto.Meta[674]
Auto.Meta[675] = {
	_type_name = "ZoneGraphLaneSection"
}
Auto.Meta[675].__index = Auto.Meta[675]
Auto.Meta[676] = {
	_type_name = "ZoneGraphLinkedLane"
}
Auto.Meta[676].__index = Auto.Meta[676]
Auto.Meta[677] = {
	_type_name = "ZoneGraphStorage"
}
Auto.Meta[677].__index = Auto.Meta[677]
Auto.Meta[678] = {
	_type_name = "ZoneGraphTagFilter"
}
Auto.Meta[678].__index = Auto.Meta[678]
Auto.Meta[679] = {
	_type_name = "ZoneLaneData"
}
Auto.Meta[679].__index = Auto.Meta[679]
Auto.Meta[680] = {
	_type_name = "ZoneLaneLinkData"
}
Auto.Meta[680].__index = Auto.Meta[680]
Auto.Reader[219] = function(reader, obj)
	setmetatable(obj, Auto.Meta[219])

	obj.Id = reader:ReadUInt64()
	obj.BtName = reader:ReadString()
	obj.BtMD5 = reader:ReadString()
	obj.ForceDrive = reader:ReadBoolean()
	obj.Tick = reader:ReadInt32()
	obj.Paused = reader:ReadBoolean()
	obj.EntityType = reader:ReadByte()
	obj.Nodes = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[220])
	end)
	obj.Variables = Base.ReadList(reader, function(r)
		return Base.ReadStruct(r, Auto.Reader[222])
	end)
	obj.Event = Base.ReadStruct(reader, Auto.Reader[221])
end
Auto.Reader[220] = function(reader, obj)
	setmetatable(obj, Auto.Meta[220])

	obj.TaskId = reader:ReadInt32()
	obj.TaskIndex = reader:ReadInt32()
	obj.Reevaluate = reader:ReadBoolean()
	obj.Interrupted = reader:ReadBoolean()
	obj.ExecutionStatus = reader:ReadByte()
	obj.ErrorMessage = reader:ReadString()
	obj.InfoMessage = reader:ReadString()
end
Auto.Reader[221] = function(reader, obj)
	setmetatable(obj, Auto.Meta[221])

	obj.Type = reader:ReadByte()
	obj.TaskId = reader:ReadInt32()
end
Auto.Reader[222] = function(reader, obj)
	setmetatable(obj, Auto.Meta[222])

	obj.Key = reader:ReadString()
	obj.Value = reader:ReadString()
end
Auto.Reader[66] = function(reader, obj)
	setmetatable(obj, Auto.Meta[66])

	obj.Orders = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[35])
	end)
	obj.EventToAgent = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return r:ReadUInt64()
	end)
end
Auto.Reader[223] = function(reader, obj)
	setmetatable(obj, Auto.Meta[223])

	obj.Rewards = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
	obj.DisplayReward = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
	obj.CfgId = reader:ReadUInt32()
	obj.StartTime = reader:ReadUInt32()
	obj.EndTime = reader:ReadUInt32()
end
Auto.Reader[225] = function(reader, obj)
	setmetatable(obj, Auto.Meta[225])

	obj.SignInList = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[226])
	end)
	obj.CfgId = reader:ReadUInt32()
	obj.ShowRedPoint = reader:ReadBoolean()
	obj.IsOutOfDate = reader:ReadBoolean()
end
Auto.Reader[226] = function(reader, obj)
	setmetatable(obj, Auto.Meta[226])

	obj.SignInTime = reader:ReadUInt32()
	obj.IsGot = reader:ReadBoolean()
end
Auto.Reader[227] = function(reader, obj)
	setmetatable(obj, Auto.Meta[227])

	obj.Progress = reader:ReadUInt32()
	obj.HasEarnedCopper = reader:ReadBoolean()
	obj.HasEarnedSilver = reader:ReadBoolean()
	obj.HasEarnedGold = reader:ReadBoolean()
end
Auto.Reader[65] = function(reader, obj)
	setmetatable(obj, Auto.Meta[65])

	obj.AchieveTime = reader:ReadDouble()
	obj.HasEarnedRewards = reader:ReadBoolean()
end
Auto.Reader[161] = function(reader, obj)
	setmetatable(obj, Auto.Meta[161])

	obj.Achievements = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return Base.ReadComplex(r, Auto.Reader[65])
	end)
	obj.Category = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return Base.ReadComplex(r, Auto.Reader[227])
	end)
end
Auto.Reader[74] = function(reader, obj)
	setmetatable(obj, Auto.Meta[74])

	obj.CfgId = reader:ReadUInt32()
	obj.ShowRedPoint = reader:ReadBoolean()
	obj.IsOutOfDate = reader:ReadBoolean()
end
Auto.Reader[228] = function(reader, obj)
	setmetatable(obj, Auto.Meta[228])

	obj.ParentPlacedInstanceId = reader:ReadUInt64()
	obj.FurnitureId = reader:ReadUInt32()
	obj.Position = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.Rotation = Base.ReadStruct(reader, Auto.Reader.UXVector3)
end
Auto.Reader[229] = function(reader, obj)
	setmetatable(obj, Auto.Meta[229])

	obj.RaidId = reader:ReadUInt32()
	obj.HasZoneGraph = reader:ReadBoolean()
	obj.ZoneStorageDataHandle = reader:ReadInt32()
	obj.Intersections = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[342])
	end)
	obj.Crowds = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[109])
	end)
	obj.StaticNpcs = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[340])
	end)
	obj.Vehicles = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[348])
	end)
	obj.StaticVehicles = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[341])
	end)
	obj.VehicleNpcs = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[352])
	end)
	obj.MetroNpcs = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[333])
	end)
end
Auto.Reader[230] = function(reader, obj)
	setmetatable(obj, Auto.Meta[230])

	obj.Portrait = reader:ReadUInt32()
end
Auto.Reader[231] = function(reader, obj)
	setmetatable(obj, Auto.Meta[231])

	obj.CrimeRecord = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
	obj.DefaultItems = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
	obj.DefaultDrugs = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
	obj.Alcohol = reader:ReadInt32()
end
Auto.Reader[232] = function(reader, obj)
	setmetatable(obj, Auto.Meta[232])

	obj.AgentId = reader:ReadUInt64()
	obj.PathId = reader:ReadInt32()
	obj.ReleaserId = reader:ReadUInt64()
	obj.Position = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.Facing = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.LivingTime = reader:ReadSingle()
end
Auto.Reader[234] = function(reader, obj)
	setmetatable(obj, Auto.Meta[234])

	obj.row = reader:ReadUInt32()
	obj.col = reader:ReadUInt32()
	obj.colSpacing = reader:ReadSingle()
	obj.rowSpacing = reader:ReadSingle()
end
Auto.Reader[235] = function(reader, obj)
	setmetatable(obj, Auto.Meta[235])

	obj.Type = reader:ReadByte()
	obj.RunAwayPositionList = Base.ReadList(reader, function(r)
		return Base.ReadStruct(r, Auto.Reader.UXVector3)
	end)
	obj.Distance = reader:ReadInt32()
	obj.Speed = reader:ReadSingle()
end
Auto.Reader[122] = function(reader, obj)
	setmetatable(obj, Auto.Meta[122])

	obj.FineTimes = reader:ReadUInt32()
	obj.Fines = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return r:ReadBoolean()
	end)
end
Auto.Reader[186] = function(reader, obj)
	setmetatable(obj, Auto.Meta[186])

	obj.AgentSpawnType = reader:ReadString()
	obj.UseForwardGroup = reader:ReadBoolean()
	obj.ForceFullAoi = reader:ReadBoolean()
end
Auto.Reader[236] = function(reader, obj)
	setmetatable(obj, Auto.Meta[236])

	obj.NeedFTF180DegreeInteract = reader:ReadBoolean()
	obj.PlayerFTF180DegreeInteract = reader:ReadBoolean()
	obj.IndoorId = reader:ReadUInt32()
	obj.chairId = reader:ReadUInt64()
	obj.gadgetId = reader:ReadUInt64()
	obj.forbidAetherAI = reader:ReadBoolean()
	obj.isApproachNpc = reader:ReadBoolean()
	obj.TriggerLeaveEvent = reader:ReadBoolean()
	obj.approachDistance = reader:ReadInt32()
	obj.LeaveDistance = reader:ReadInt32()
	obj.petPerformData = reader:ReadString()
	obj.stimIDList = Base.ReadList(reader, function(r)
		return r:ReadInt32()
	end)
	obj.randomModelCfgId = reader:ReadUInt32()
	obj.layer = reader:ReadInt32()
	obj.gpsOffsetY = reader:ReadSingle()
	obj.isTemp = reader:ReadBoolean()
	obj.spawnEffectId = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
	obj.hideEffectId = reader:ReadUInt32()
	obj.actionId = reader:ReadUInt32()
	obj.actionGroupId = reader:ReadUInt32()
	obj.metroLineId = reader:ReadUInt32()
	obj.metroCarriageId = reader:ReadUInt32()
	obj.AgentDataSetsActivityCfgId = reader:ReadUInt32()
	obj.GameplaySignalId = reader:ReadUInt32()
	obj.treeName = reader:ReadString()
	obj.sitIndex = reader:ReadInt32()
	obj.indoorList = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
	obj.roomIds = Base.ReadList(reader, function(r)
		return r:ReadInt32()
	end)
	obj.forbidStimulateType = reader:ReadByte()
	obj.agentStimType = reader:ReadByte()
	obj.beHitType = reader:ReadByte()
	obj.SpoonAgentId = reader:ReadInt32()
	obj.FeiSuo = reader:ReadBoolean()
	obj.FashionSuitId = reader:ReadUInt32()
	obj.CanBeExaminedByPolice = reader:ReadBoolean()
	obj.IgnoreWanted = reader:ReadBoolean()
end
Auto.Reader[43] = function(reader, obj)
	setmetatable(obj, Auto.Meta[43])

	obj.Id = reader:ReadUInt32()
	obj.Favor = reader:ReadInt32()
	obj.FavorLevel = reader:ReadUInt32()
	obj.NickName = reader:ReadString()
	obj.Unlock = reader:ReadBoolean()
	obj.Interacted = reader:ReadBoolean()
end
Auto.Reader[237] = function(reader, obj)
	setmetatable(obj, Auto.Meta[237])

	obj.BoxAreaParams = Base.ReadStruct(reader, Auto.Reader[257])
end
Auto.Reader[238] = function(reader, obj)
	setmetatable(obj, Auto.Meta[238])

	obj.Uid = reader:ReadUInt64()
	obj.TemplateId = reader:ReadUInt32()
	obj.Position = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.FacingDirection = reader:ReadSingle()
	obj.Priority = reader:ReadByte()
	obj.BsIngAgents = Base.ReadList(reader, function(r)
		return r:ReadUInt64()
	end)
end
Auto.Reader[138] = function(reader, obj)
	setmetatable(obj, Auto.Meta[138])

	obj.AgentId = reader:ReadUInt64()
	obj.Damage = reader:ReadSingle()
	obj.BeDamaged = reader:ReadSingle()
end
Auto.Reader[121] = function(reader, obj)
	setmetatable(obj, Auto.Meta[121])

	obj.Basic = reader:ReadUInt32()
	obj.WinBonus = reader:ReadUInt32()
	obj.StreakLength = reader:ReadUInt32()
	obj.StreakBonus = reader:ReadUInt32()
end
Auto.Reader[99] = function(reader, obj)
	setmetatable(obj, Auto.Meta[99])

	obj.ChaosBuffId = reader:ReadUInt32()
	obj.Cost = reader:ReadUInt32()
	obj.Selected = reader:ReadBoolean()
end
Auto.Reader[239] = function(reader, obj)
	setmetatable(obj, Auto.Meta[239])

	obj.ChaosBuffId = reader:ReadUInt32()
	obj.Level = reader:ReadUInt32()
end
Auto.Reader[120] = function(reader, obj)
	setmetatable(obj, Auto.Meta[120])

	obj.PlayerType = reader:ReadByte()
	obj.PlayerId = reader:ReadUInt64()
	obj.Pokemons = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
	obj.NpcId = reader:ReadUInt32()
	obj.BVBCamp = reader:ReadByte()
end
Auto.Reader[141] = function(reader, obj)
	setmetatable(obj, Auto.Meta[141])

	obj.Pokemons = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[127])
	end)
	obj.TagInfos = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[105])
	end)
	obj.ChaosBuffs = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[239])
	end)
end
Auto.Reader[240] = function(reader, obj)
	setmetatable(obj, Auto.Meta[240])

	obj.q = reader:ReadInt32()
	obj.r = reader:ReadInt32()
	obj.s = reader:ReadInt32()
	obj.pokemonId = reader:ReadUInt64()
end
Auto.Reader[41] = function(reader, obj)
	setmetatable(obj, Auto.Meta[41])

	obj.TemplateId = reader:ReadUInt32()
	obj.Active = reader:ReadBoolean()
	obj.DropSend = reader:ReadBoolean()
end
Auto.Reader[241] = function(reader, obj)
	setmetatable(obj, Auto.Meta[241])

	obj.LastVisitTime = reader:ReadUInt32()
end
Auto.Reader[242] = function(reader, obj)
	setmetatable(obj, Auto.Meta[242])

	obj.VisitCount = reader:ReadUInt32()
	obj.LastVisitTime = reader:ReadUInt32()
end
Auto.Reader[56] = function(reader, obj)
	setmetatable(obj, Auto.Meta[56])

	obj.Id = reader:ReadUInt64()
	obj.Type = reader:ReadByte()
end
Auto.Reader[20] = function(reader, obj)
	setmetatable(obj, Auto.Meta[20])

	obj.ElementId2StockOzDict = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return r:ReadSingle()
	end)
end
Auto.Reader[243] = function(reader, obj)
	setmetatable(obj, Auto.Meta[243])

	obj.CustomerSuperDict = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return Base.ReadComplex(r, Auto.Reader[242])
	end)
	obj.CustomerNormalDict = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return Base.ReadComplex(r, Auto.Reader[241])
	end)
end
Auto.Reader[244] = function(reader, obj)
	setmetatable(obj, Auto.Meta[244])

	obj.OperatorType = reader:ReadByte()
	obj.BallUid = reader:ReadUInt64()
	obj.ActiveUid = reader:ReadUInt64()
	obj.PassiveUid = reader:ReadUInt64()
	obj.DelayParam = Base.ReadComplex(reader, Auto.Reader[245])
	obj.ShootParam = Base.ReadComplex(reader, Auto.Reader[248])
end
Auto.Reader[245] = function(reader, obj)
	setmetatable(obj, Auto.Meta[245])

	obj.delay = reader:ReadSingle()
end
Auto.Reader[246] = function(reader, obj)
	setmetatable(obj, Auto.Meta[246])

	obj.OperatorType = reader:ReadByte()
	obj.BallUid = reader:ReadUInt64()
	obj.ActiveUid = reader:ReadUInt64()
	obj.PassiveUid = reader:ReadUInt64()
	obj.IsSuccess = reader:ReadBoolean()
	obj.DelayParam = Base.ReadComplex(reader, Auto.Reader[245])
	obj.ShootParam = Base.ReadComplex(reader, Auto.Reader[248])
end
Auto.Reader[247] = function(reader, obj)
	setmetatable(obj, Auto.Meta[247])

	obj.full = Base.ReadDict(reader, function(r)
		return r:ReadUInt64()
	end, function(r)
		return r:ReadUInt64()
	end)
	obj.addOrUpdate = Base.ReadDict(reader, function(r)
		return r:ReadUInt64()
	end, function(r)
		return r:ReadUInt64()
	end)
	obj.remove = Base.ReadList(reader, function(r)
		return r:ReadUInt64()
	end)
end
Auto.Reader[248] = function(reader, obj)
	setmetatable(obj, Auto.Meta[248])

	obj.startPos = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.shootVelocity = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.moveTime = reader:ReadSingle()
end
Auto.Reader[80] = function(reader, obj)
	setmetatable(obj, Auto.Meta[80])

	obj.StartTime = reader:ReadUInt32()
	obj.PoseStartTime = reader:ReadUInt32()
	obj.LastUpdateTime = reader:ReadUInt32()
	obj.PoseId = reader:ReadUInt32()
	obj.Spot = reader:ReadUInt32()
	obj.NpcGatherRate = reader:ReadSingle()
	obj.NpcGatherLimit = reader:ReadUInt32()
	obj.DialogId = reader:ReadUInt32()
	obj.RewardMean = reader:ReadSingle()
	obj.RewardVariance = reader:ReadSingle()
	obj.TotalReward = reader:ReadUInt32()
	obj.Exp = reader:ReadUInt32()
	obj.TotalAttractedNpc = reader:ReadInt32()
	obj.TotalRewardFromPlayer = reader:ReadUInt32()
	obj.NpcIds = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
	obj.IsPromoted = reader:ReadBoolean()
end
Auto.Reader[249] = function(reader, obj)
	setmetatable(obj, Auto.Meta[249])

	obj.Type = reader:ReadByte()
	obj.CommandIndex = reader:ReadInt32()
end
Auto.Reader[250] = function(reader, obj)
	setmetatable(obj, Auto.Meta[250])

	obj.InstanceId = reader:ReadUInt64()
	obj.ConfigId = reader:ReadUInt32()
	obj.BelongingItemState = reader:ReadByte()
	obj.OwnerId = reader:ReadUInt64()
	obj.Position = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.Facing = reader:ReadSingle()
end
Auto.Reader[251] = function(reader, obj)
	setmetatable(obj, Auto.Meta[251])

	obj.AgentId = reader:ReadUInt32()
end
Auto.Reader[252] = function(reader, obj)
	setmetatable(obj, Auto.Meta[252])

	obj.Id = reader:ReadUInt32()
	obj.Favor = reader:ReadInt32()
	obj.Index = reader:ReadUInt32()
	obj.ShowFavorLevel = reader:ReadBoolean()
	obj.ShowFavorTime = reader:ReadBoolean()
	obj.InteractDays = reader:ReadUInt32()
end
Auto.Reader[168] = function(reader, obj)
	setmetatable(obj, Auto.Meta[168])

	obj.Pid = reader:ReadUInt64()
	obj.Aid = reader:ReadInt32()
	obj.OrderTime = reader:ReadUInt32()
	obj.ShipTime = reader:ReadUInt32()
	obj.ChargeId = reader:ReadUInt32()
	obj.GoodsId = reader:ReadString()
	obj.SN = reader:ReadString()
	obj.ConsumeSN = reader:ReadString()
	obj.PayChannel = reader:ReadString()
	obj.AppChannel = reader:ReadString()
	obj.PayMethod = reader:ReadString()
	obj.Platform = reader:ReadString()
	obj.Udid = reader:ReadString()
	obj.GoodsCount = reader:ReadInt32()
	obj.PayMoney = reader:ReadString()
	obj.FreeMoney = reader:ReadString()
	obj.PayCurrency = reader:ReadString()
	obj.Deduct = reader:ReadInt32()
	obj.DeductPercent = reader:ReadString()
	obj.FreeYuanBao = reader:ReadInt32()
	obj.PayYuanBao = reader:ReadInt32()
	obj.Status = reader:ReadInt32()
end
Auto.Reader[253] = function(reader, obj)
	setmetatable(obj, Auto.Meta[253])

	obj.Id = reader:ReadInt32()
	obj.State = reader:ReadByte()
	obj.StateStartTime = reader:ReadUInt32()
end
Auto.Reader[106] = function(reader, obj)
	setmetatable(obj, Auto.Meta[106])

	obj.Type = reader:ReadInt32()
	obj.Data = reader:ReadString()
end
Auto.Reader[254] = function(reader, obj)
	setmetatable(obj, Auto.Meta[254])

	obj.Pid = reader:ReadUInt64()
	obj.NpcCultivationId = reader:ReadUInt32()
	obj.AgentUId = reader:ReadUInt64()
	obj.SeatIndex = reader:ReadInt32()
	obj.IsReady = reader:ReadBoolean()
	obj.IsPlayAgain = reader:ReadBoolean()
end
Auto.Reader[255] = function(reader, obj)
	setmetatable(obj, Auto.Meta[255])

	obj.ThrowScores = Base.ReadList(reader, function(r)
		return r:ReadInt32()
	end)
	obj.FrameScores = Base.ReadList(reader, function(r)
		return r:ReadInt32()
	end)
end
Auto.Reader[139] = function(reader, obj)
	setmetatable(obj, Auto.Meta[139])

	obj.BowlingScoreDict = Base.ReadDict(reader, function(r)
		return r:ReadInt32()
	end, function(r)
		return Base.ReadComplex(r, Auto.Reader[255])
	end)
	obj.Winner = reader:ReadInt32()
end
Auto.Reader[256] = function(reader, obj)
	setmetatable(obj, Auto.Meta[256])

	obj.GameType = reader:ReadByte()
	obj.CurrentRound = reader:ReadUInt32()
	obj.CurrentSubRound = reader:ReadUInt32()
	obj.CurrentTurn = reader:ReadInt32()
	obj.ScoreInfo = Base.ReadComplex(reader, Auto.Reader[139])
	obj.BowlingPinSceneItemIdList = Base.ReadList(reader, function(r)
		return r:ReadUInt64()
	end)
	obj.BowlingBallSceneItemIdList = Base.ReadList(reader, function(r)
		return r:ReadUInt64()
	end)
	obj.GadgetUId = reader:ReadUInt64()
	obj.StartReason = reader:ReadByte()
	obj.SyncReason = reader:ReadByte()
	obj.ZoneType = reader:ReadByte()
	obj.ZoneState = reader:ReadByte()
	obj.ParticipantInfos = Base.ReadList(reader, Auto.Dispatch[103])
end
Auto.Reader[257] = function(reader, obj)
	setmetatable(obj, Auto.Meta[257])

	obj.Center = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.Extents = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.InversedRotation = Base.ReadStruct(reader, Auto.Reader[587])
end
Auto.Reader[111] = function(reader, obj)
	setmetatable(obj, Auto.Meta[111])

	obj.InstanceId = reader:ReadUInt32()
	obj.Id = reader:ReadUInt32()
	obj.ReleaserId = reader:ReadUInt64()
	obj.ExpireTime = reader:ReadDouble()
	obj.Tier = reader:ReadUInt32()
	obj.Permanent = reader:ReadBoolean()
	obj.DestructibleId = reader:ReadUInt64()
end
Auto.Reader[258] = function(reader, obj)
	setmetatable(obj, Auto.Meta[258])

	obj.RestaurantId = reader:ReadUInt32()
	obj.FoodIdList = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
	obj.CompanionNpcId = reader:ReadUInt32()
	obj.Date = reader:ReadBoolean()
	obj.NPCTreat = reader:ReadBoolean()
	obj.MealTime = reader:ReadUInt32()
end
Auto.Reader[259] = function(reader, obj)
	setmetatable(obj, Auto.Meta[259])

	obj.Value = reader:ReadByte()
end
Auto.Reader[260] = function(reader, obj)
	setmetatable(obj, Auto.Meta[260])

	obj.CargoId = reader:ReadUInt32()
	obj.StartPos = Base.ReadComplex(reader, Auto.Reader[179])
	obj.Integrity = reader:ReadInt32()
	obj.IsCargoNear = reader:ReadBoolean()
	obj.UniqueId = reader:ReadUInt64()
end
Auto.Reader[261] = function(reader, obj)
	setmetatable(obj, Auto.Meta[261])

	obj.Center = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.Speed = reader:ReadSingle()
end
Auto.Reader[44] = function(reader, obj)
	setmetatable(obj, Auto.Meta[44])

	obj.ChallengeId = reader:ReadUInt32()
	obj.HighestLevel = reader:ReadUInt32()
	obj.ReceivedRewardLevel = reader:ReadUInt32()
	obj.BestScore = reader:ReadInt32()
	obj.CurrentScore = reader:ReadInt32()
	obj.CurrentRewardLevel = reader:ReadUInt32()
	obj.CurrentIsNewRewardLevel = reader:ReadBoolean()
	obj.BestStatisticalData = Base.ReadDict(reader, function(r)
		return r:ReadInt32()
	end, function(r)
		return r:ReadDouble()
	end)
	obj.CurrentStatisticalData = Base.ReadDict(reader, function(r)
		return r:ReadInt32()
	end, function(r)
		return r:ReadDouble()
	end)
end
Auto.Reader[194] = function(reader, obj)
	setmetatable(obj, Auto.Meta[194])

	obj.ChallengeRecord = Base.ReadComplex(reader, Auto.Reader[182])
	obj.CurrentRewardLevel = reader:ReadUInt32()
	obj.RewardInfo = Base.ReadComplex(reader, Auto.Reader[45])
end
Auto.Reader[262] = function(reader, obj)
	setmetatable(obj, Auto.Meta[262])

	obj.PlacedInstanceId = reader:ReadUInt64()
	obj.IsChangeParentNode = reader:ReadBoolean()
	obj.ParentPlacedInstanceId = reader:ReadUInt64()
	obj.Position = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.Rotation = Base.ReadStruct(reader, Auto.Reader.UXVector3)
end
Auto.Reader[105] = function(reader, obj)
	setmetatable(obj, Auto.Meta[105])

	obj.TagId = reader:ReadUInt32()
	obj.TagLevel = reader:ReadUInt32()
	obj.TagExp = reader:ReadUInt32()
end
Auto.Reader[263] = function(reader, obj)
	setmetatable(obj, Auto.Meta[263])

	obj.InstanceId = reader:ReadUInt64()
	obj.ConfigId = reader:ReadUInt32()
	obj.Hp = reader:ReadSingle()
end
Auto.Reader[264] = function(reader, obj)
	setmetatable(obj, Auto.Meta[264])

	obj.HasFirstCharge = reader:ReadBoolean()
	obj.HasFirstChargeReward = reader:ReadBoolean()
end
Auto.Reader[118] = function(reader, obj)
	setmetatable(obj, Auto.Meta[118])

	obj.CurrentCharges = reader:ReadUInt32()
	obj.CurrentPercentage = reader:ReadSingle()
	obj.ChargePeriod = reader:ReadSingle()
	obj.MaxCharges = reader:ReadUInt32()
	obj.Timestamp = reader:ReadDouble()
end
Auto.Reader[17] = function(reader, obj)
	setmetatable(obj, Auto.Meta[17])

	obj.SN = reader:ReadString()
	obj.PayChannel = reader:ReadString()
	obj.ConsumeSN = reader:ReadString()
	obj.ChargeId = reader:ReadUInt32()
	obj.GoodsId = reader:ReadString()
	obj.Gold = reader:ReadUInt32()
	obj.FreeGold = reader:ReadUInt32()
end
Auto.Reader[265] = function(reader, obj)
	setmetatable(obj, Auto.Meta[265])

	obj.TargetType = reader:ReadByte()
	obj.TargetUid = reader:ReadUInt64()
	obj.MaxSpeed = reader:ReadSingle()
	obj.chaseFormationName = reader:ReadString()
	obj.enterChaseFormationDistance = reader:ReadSingle()
	obj.exitChaseFormationDistance = reader:ReadSingle()
	obj.targetSlowdownDistanceMaxThreshold = reader:ReadSingle()
	obj.targetSlowdownDistanceMinThreshold = reader:ReadSingle()
	obj.targetSlowdownSpeedThreshold = reader:ReadSingle()
	obj.throttleRatioWhenTargetSlowDown = reader:ReadSingle()
	obj.vehicleRamMove = Base.ReadStruct(reader, Auto.Reader[662])
	obj.vehicleBlockMove = Base.ReadStruct(reader, Auto.Reader[652])
	obj.enableDelayTarget = reader:ReadBoolean()
	obj.minClosetDistanceUpdateTargetTime = reader:ReadSingle()
	obj.maxClosetDistanceUpdateTargetTime = reader:ReadSingle()
	obj.straightLineDistanceInCloseDistance = reader:ReadSingle()
	obj.straightLineDistanceInPursue = reader:ReadSingle()
	obj.Token = reader:ReadUInt64()
	obj.taskAIConfigId = reader:ReadUInt32()
	obj.defaultSpeed = reader:ReadSingle()
	obj.drivingFlags = reader:ReadInt32()
	obj.initSpeed = reader:ReadSingle()
	obj.initTaskAIBuffList = Base.ReadList(reader, function(r)
		return Base.ReadStruct(r, Auto.Reader[629])
	end)
	obj.commonParameters = Base.ReadStruct(reader, Auto.Reader[650])
end
Auto.Reader[152] = function(reader, obj)
	setmetatable(obj, Auto.Meta[152])

	obj.Id = reader:ReadUInt64()
	obj.CreateTime = reader:ReadUInt32()
	obj.Owner = reader:ReadUInt64()
	obj.Members = Base.ReadList(reader, function(r)
		return r:ReadUInt64()
	end)
	obj.Name = reader:ReadString()
	obj.RejectMsg = reader:ReadBoolean()
end
Auto.Reader[267] = function(reader, obj)
	setmetatable(obj, Auto.Meta[267])

	obj.NameCard = Base.ReadComplex(reader, Auto.Reader[491])
	obj.Count = reader:ReadInt32()
end
Auto.Reader[268] = function(reader, obj)
	setmetatable(obj, Auto.Meta[268])

	obj.ChatList = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[24])
	end)
end
Auto.Reader[216] = function(reader, obj)
	setmetatable(obj, Auto.Meta[216])

	obj.MessageId = reader:ReadUInt64()
	obj.Channel = reader:ReadByte()
	obj.Pid = reader:ReadUInt64()
	obj.Receiver = reader:ReadUInt64()
	obj.Time = reader:ReadUInt32()
	obj.IsAudio = reader:ReadBoolean()
	obj.Content = reader:ReadString()
	obj.SystemMessageId = reader:ReadInt32()
end
Auto.Reader[215] = function(reader, obj)
	setmetatable(obj, Auto.Meta[215])

	obj.Messages = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[216])
	end)
end
Auto.Reader[158] = function(reader, obj)
	setmetatable(obj, Auto.Meta[158])

	obj.unisdk_login_json = reader:ReadString()
	obj.Token = reader:ReadString()
	obj.UserName = reader:ReadString()
	obj.Aid = reader:ReadInt32()
	obj.NeedRealNameTip = reader:ReadBoolean()
	obj.NeedRoleEnter = reader:ReadBoolean()
	obj.RealNameVerified = reader:ReadBoolean()
	obj.HostId = reader:ReadInt32()
	obj.OpenIdUrl = reader:ReadString()
	obj.code = reader:ReadInt32()
	obj.subcode = reader:ReadInt32()
	obj.msg = reader:ReadString()
end
Auto.Reader[269] = function(reader, obj)
	setmetatable(obj, Auto.Meta[269])

	obj.Distance = Base.ReadList(reader, function(r)
		return r:ReadInt32()
	end)
end
Auto.Reader[270] = function(reader, obj)
	setmetatable(obj, Auto.Meta[270])

	obj.wayPointIndex = reader:ReadInt32()
	obj.opType = reader:ReadInt32()
	obj.duration = reader:ReadSingle()
	obj.aetherActionId = reader:ReadUInt32()
	obj.conversationId = reader:ReadUInt32()
	obj.dialogueSpeakers = Base.ReadList(reader, function(r)
		return r:ReadString()
	end)
	obj.dialogueBindUnits = Base.ReadList(reader, function(r)
		return r:ReadUInt64()
	end)
	obj.wayLeaderDontWait = reader:ReadBoolean()
	obj.targetPace = reader:ReadByte()
end
Auto.Reader[271] = function(reader, obj)
	setmetatable(obj, Auto.Meta[271])

	obj.Pid = reader:ReadUInt64()
	obj.NpcCultivationId = reader:ReadUInt32()
	obj.AgentUId = reader:ReadUInt64()
	obj.SeatIndex = reader:ReadInt32()
	obj.IsReady = reader:ReadBoolean()
	obj.IsPlayAgain = reader:ReadBoolean()
end
Auto.Reader[272] = function(reader, obj)
	setmetatable(obj, Auto.Meta[272])

	obj.GadgetUId = reader:ReadUInt64()
	obj.StartReason = reader:ReadByte()
	obj.SyncReason = reader:ReadByte()
	obj.ZoneType = reader:ReadByte()
	obj.ZoneState = reader:ReadByte()
	obj.ParticipantInfos = Base.ReadList(reader, Auto.Dispatch[103])
end
Auto.Reader[273] = function(reader, obj)
	setmetatable(obj, Auto.Meta[273])

	obj.LocationId = reader:ReadUInt32()
	obj.CinemaId = reader:ReadUInt32()
end
Auto.Reader[274] = function(reader, obj)
	setmetatable(obj, Auto.Meta[274])

	obj.LocationId = reader:ReadUInt32()
	obj.CinemaId = reader:ReadUInt32()
	obj.MovieId = reader:ReadUInt32()
	obj.CompanionNpcId = reader:ReadUInt32()
	obj.CinemaNpcId = reader:ReadUInt32()
	obj.InviteNpcId = reader:ReadUInt64()
	obj.IsDate = reader:ReadBoolean()
	obj.CommentType = reader:ReadByte()
	obj.StartTime = reader:ReadUInt32()
	obj.EndTime = reader:ReadUInt32()
	obj.State = reader:ReadByte()
	obj.IsTask = reader:ReadBoolean()
end
Auto.Reader[64] = function(reader, obj)
	setmetatable(obj, Auto.Meta[64])

	obj.HideNpcId = reader:ReadUInt32()
	obj.FailTimes = reader:ReadInt32()
	obj.FavorToyId = reader:ReadUInt32()
	obj.DateNpcId = reader:ReadUInt32()
end
Auto.Reader[275] = function(reader, obj)
	setmetatable(obj, Auto.Meta[275])

	obj.ClawToyId = reader:ReadUInt32()
	obj.NpcId = reader:ReadUInt32()
	obj.Date = reader:ReadBoolean()
end
Auto.Reader[276] = function(reader, obj)
	setmetatable(obj, Auto.Meta[276])

	obj.Target = Base.ReadStruct(reader, Auto.Reader[314])
	obj.animId = reader:ReadUInt32()
	obj.selectedActionIndex = reader:ReadInt32()
	obj.speed = reader:ReadSingle()
	obj.AgentId = reader:ReadUInt64()
	obj.Token = reader:ReadUInt64()
	obj.Debug = reader:ReadString()
end
Auto.Reader[278] = function(reader, obj)
	setmetatable(obj, Auto.Meta[278])

	obj.Target = Base.ReadStruct(reader, Auto.Reader[314])
	obj.dangerRadius = reader:ReadSingle()
	obj.dangerDuration = reader:ReadSingle()
	obj.updatePosTolerance = reader:ReadSingle()
	obj.dangerDirRefreshLaneTime = reader:ReadSingle()
	obj.dangerDirHalfAngle = reader:ReadSingle()
	obj.specificMethod = reader:ReadInt32()
	obj.speed = reader:ReadSingle()
	obj.runChasingDistance = reader:ReadSingle()
	obj.AgentId = reader:ReadUInt64()
	obj.Token = reader:ReadUInt64()
	obj.Debug = reader:ReadString()
end
Auto.Reader[279] = function(reader, obj)
	setmetatable(obj, Auto.Meta[279])

	obj.Vehicle = reader:ReadUInt64()
	obj.exitWaitTime = reader:ReadSingle()
	obj.Target = Base.ReadStruct(reader, Auto.Reader[314])
	obj.arriveDistance = reader:ReadSingle()
	obj.SpecificMethod = reader:ReadInt32()
	obj.directionTolerance = reader:ReadSingle()
	obj.tryMatchStep = reader:ReadBoolean()
	obj.keepUpdateTargetPosition = reader:ReadBoolean()
	obj.runChasingDistance = reader:ReadSingle()
	obj.speed = reader:ReadSingle()
	obj.moveActionId = reader:ReadUInt32()
	obj.moveActionGroup = reader:ReadUInt32()
	obj.notTowardToTarget = reader:ReadBoolean()
	obj.AgentId = reader:ReadUInt64()
	obj.Token = reader:ReadUInt64()
	obj.Debug = reader:ReadString()
end
Auto.Reader[281] = function(reader, obj)
	setmetatable(obj, Auto.Meta[281])

	obj.Target = Base.ReadStruct(reader, Auto.Reader[314])
	obj.distance = reader:ReadSingle()
	obj.halfAngle = reader:ReadSingle()
	obj.useHead = reader:ReadBoolean()
	obj.AgentId = reader:ReadUInt64()
	obj.Token = reader:ReadUInt64()
end
Auto.Reader[283] = function(reader, obj)
	setmetatable(obj, Auto.Meta[283])

	obj.vehicle = reader:ReadUInt64()
	obj.operation = reader:ReadInt32()
	obj.rightFloat = reader:ReadSingle()
	obj.AgentId = reader:ReadUInt64()
	obj.Token = reader:ReadUInt64()
end
Auto.Reader[284] = function(reader, obj)
	setmetatable(obj, Auto.Meta[284])

	obj.Target = Base.ReadStruct(reader, Auto.Reader[314])
	obj.tolerance = reader:ReadSingle()
	obj.AgentId = reader:ReadUInt64()
	obj.Token = reader:ReadUInt64()
	obj.Debug = reader:ReadString()
end
Auto.Reader[285] = function(reader, obj)
	setmetatable(obj, Auto.Meta[285])

	obj.PlayerId = reader:ReadUInt64()
	obj.SingleInteractType = reader:ReadUInt32()
	obj.MultiInteractType = reader:ReadUInt32()
	obj.AgentId = reader:ReadUInt64()
	obj.Token = reader:ReadUInt64()
	obj.Debug = reader:ReadString()
end
Auto.Reader[286] = function(reader, obj)
	setmetatable(obj, Auto.Meta[286])

	obj.Target = Base.ReadStruct(reader, Auto.Reader[314])
	obj.focusLevel = reader:ReadInt32()
	obj.focusTime = reader:ReadSingle()
	obj.tolerance = reader:ReadSingle()
	obj.AgentId = reader:ReadUInt64()
	obj.Token = reader:ReadUInt64()
	obj.Debug = reader:ReadString()
end
Auto.Reader[287] = function(reader, obj)
	setmetatable(obj, Auto.Meta[287])

	obj.comfortRange = reader:ReadSingle()
	obj.towardTarget = reader:ReadBoolean()
	obj.distances = Base.ReadList(reader, function(r)
		return Base.ReadStruct(r, Auto.Reader[571])
	end)
	obj.navigationTolerance = reader:ReadSingle()
	obj.selfNavigationTolerance = reader:ReadSingle()
	obj.failedWhenNavigationFailed = reader:ReadBoolean()
	obj.Target = Base.ReadStruct(reader, Auto.Reader[314])
	obj.arriveDistance = reader:ReadSingle()
	obj.SpecificMethod = reader:ReadInt32()
	obj.directionTolerance = reader:ReadSingle()
	obj.tryMatchStep = reader:ReadBoolean()
	obj.keepUpdateTargetPosition = reader:ReadBoolean()
	obj.runChasingDistance = reader:ReadSingle()
	obj.speed = reader:ReadSingle()
	obj.moveActionId = reader:ReadUInt32()
	obj.moveActionGroup = reader:ReadUInt32()
	obj.notTowardToTarget = reader:ReadBoolean()
	obj.AgentId = reader:ReadUInt64()
	obj.Token = reader:ReadUInt64()
	obj.Debug = reader:ReadString()
end
Auto.Reader[289] = function(reader, obj)
	setmetatable(obj, Auto.Meta[289])

	obj.vehicle = reader:ReadUInt64()
	obj.seatIndex = reader:ReadByte()
	obj.HasDoorInteract = reader:ReadBoolean()
	obj.distances = Base.ReadList(reader, function(r)
		return Base.ReadStruct(r, Auto.Reader[571])
	end)
	obj.AgentId = reader:ReadUInt64()
	obj.Token = reader:ReadUInt64()
	obj.Debug = reader:ReadString()
end
Auto.Reader[290] = function(reader, obj)
	setmetatable(obj, Auto.Meta[290])

	obj.AgentId = reader:ReadUInt64()
	obj.Token = reader:ReadUInt64()
	obj.Debug = reader:ReadString()
end
Auto.Reader[291] = function(reader, obj)
	setmetatable(obj, Auto.Meta[291])

	obj.hitForce = reader:ReadSingle()
	obj.hitRadius = reader:ReadSingle()
	obj.hitPart = reader:ReadInt32()
	obj.secondHitPart = reader:ReadInt32()
	obj.hitLayer = reader:ReadInt32()
	obj.hitTiming = Base.ReadStruct(reader, Auto.Reader[547])
	obj.Target = Base.ReadStruct(reader, Auto.Reader[314])
	obj.animId = reader:ReadUInt32()
	obj.selectedActionIndex = reader:ReadInt32()
	obj.speed = reader:ReadSingle()
	obj.AgentId = reader:ReadUInt64()
	obj.Token = reader:ReadUInt64()
	obj.Debug = reader:ReadString()
end
Auto.Reader[292] = function(reader, obj)
	setmetatable(obj, Auto.Meta[292])

	obj.IKTargetBone = reader:ReadInt32()
	obj.Target = Base.ReadStruct(reader, Auto.Reader[314])
	obj.animId = reader:ReadUInt32()
	obj.selectedActionIndex = reader:ReadInt32()
	obj.speed = reader:ReadSingle()
	obj.AgentId = reader:ReadUInt64()
	obj.Token = reader:ReadUInt64()
	obj.Debug = reader:ReadString()
end
Auto.Reader[293] = function(reader, obj)
	setmetatable(obj, Auto.Meta[293])

	obj.Target = Base.ReadStruct(reader, Auto.Reader[314])
	obj.InteractType = reader:ReadUInt32()
	obj.AgentId = reader:ReadUInt64()
	obj.Token = reader:ReadUInt64()
	obj.Debug = reader:ReadString()
end
Auto.Reader[294] = function(reader, obj)
	setmetatable(obj, Auto.Meta[294])

	obj.vehicle = reader:ReadUInt64()
	obj.AgentId = reader:ReadUInt64()
	obj.Token = reader:ReadUInt64()
end
Auto.Reader[295] = function(reader, obj)
	setmetatable(obj, Auto.Meta[295])

	obj.Target = Base.ReadStruct(reader, Auto.Reader[314])
	obj.isOn = reader:ReadBoolean()
	obj.targetType = reader:ReadInt32()
	obj.targetPosition = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.isKeep = reader:ReadBoolean()
	obj.isFinishOnEnd = reader:ReadBoolean()
	obj.duration = reader:ReadSingle()
	obj.ikPriority = reader:ReadInt32()
	obj.lookAtIKType = reader:ReadInt32()
	obj.agentTargetPart = reader:ReadInt32()
	obj.AgentId = reader:ReadUInt64()
	obj.Token = reader:ReadUInt64()
	obj.Debug = reader:ReadString()
end
Auto.Reader[280] = function(reader, obj)
	setmetatable(obj, Auto.Meta[280])

	obj.Target = Base.ReadStruct(reader, Auto.Reader[314])
	obj.arriveDistance = reader:ReadSingle()
	obj.SpecificMethod = reader:ReadInt32()
	obj.directionTolerance = reader:ReadSingle()
	obj.tryMatchStep = reader:ReadBoolean()
	obj.keepUpdateTargetPosition = reader:ReadBoolean()
	obj.runChasingDistance = reader:ReadSingle()
	obj.speed = reader:ReadSingle()
	obj.moveActionId = reader:ReadUInt32()
	obj.moveActionGroup = reader:ReadUInt32()
	obj.notTowardToTarget = reader:ReadBoolean()
	obj.AgentId = reader:ReadUInt64()
	obj.Token = reader:ReadUInt64()
	obj.Debug = reader:ReadString()
end
Auto.Reader[296] = function(reader, obj)
	setmetatable(obj, Auto.Meta[296])

	obj.vehicle = reader:ReadUInt64()
	obj.seatIndex = reader:ReadInt32()
	obj.distances = Base.ReadList(reader, function(r)
		return Base.ReadStruct(r, Auto.Reader[571])
	end)
	obj.AgentId = reader:ReadUInt64()
	obj.Token = reader:ReadUInt64()
	obj.Debug = reader:ReadString()
end
Auto.Reader[288] = function(reader, obj)
	setmetatable(obj, Auto.Meta[288])

	obj.navigationTolerance = reader:ReadSingle()
	obj.selfNavigationTolerance = reader:ReadSingle()
	obj.failedWhenNavigationFailed = reader:ReadBoolean()
	obj.Target = Base.ReadStruct(reader, Auto.Reader[314])
	obj.arriveDistance = reader:ReadSingle()
	obj.SpecificMethod = reader:ReadInt32()
	obj.directionTolerance = reader:ReadSingle()
	obj.tryMatchStep = reader:ReadBoolean()
	obj.keepUpdateTargetPosition = reader:ReadBoolean()
	obj.runChasingDistance = reader:ReadSingle()
	obj.speed = reader:ReadSingle()
	obj.moveActionId = reader:ReadUInt32()
	obj.moveActionGroup = reader:ReadUInt32()
	obj.notTowardToTarget = reader:ReadBoolean()
	obj.AgentId = reader:ReadUInt64()
	obj.Token = reader:ReadUInt64()
	obj.Debug = reader:ReadString()
end
Auto.Reader[297] = function(reader, obj)
	setmetatable(obj, Auto.Meta[297])

	obj.Positions = Base.ReadList(reader, function(r)
		return Base.ReadStruct(r, Auto.Reader.UXVector3)
	end)
	obj.AgentId = reader:ReadUInt64()
	obj.Token = reader:ReadUInt64()
	obj.Debug = reader:ReadString()
end
Auto.Reader[298] = function(reader, obj)
	setmetatable(obj, Auto.Meta[298])

	obj.Target = Base.ReadStruct(reader, Auto.Reader[314])
	obj.animationIds = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
	obj.baseObject = reader:ReadByte()
	obj.baseVehicle = reader:ReadUInt64()
	obj.targetType = reader:ReadInt32()
	obj.reverse = reader:ReadBoolean()
	obj.selectAngleType = reader:ReadInt32()
	obj.angleRange = Base.ReadList(reader, function(r)
		return r:ReadSingle()
	end)
	obj.AgentId = reader:ReadUInt64()
	obj.Token = reader:ReadUInt64()
	obj.Debug = reader:ReadString()
end
Auto.Reader[299] = function(reader, obj)
	setmetatable(obj, Auto.Meta[299])

	obj.Target = Base.ReadStruct(reader, Auto.Reader[314])
	obj.AgentId = reader:ReadUInt64()
	obj.Token = reader:ReadUInt64()
end
Auto.Reader[300] = function(reader, obj)
	setmetatable(obj, Auto.Meta[300])

	obj.targetObject = Base.ReadStruct(reader, Auto.Reader[314])
	obj.arriveDistance = reader:ReadSingle()
	obj.targetPosition = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.targetDirection = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.SpecificMethod = reader:ReadInt32()
	obj.directionTolerance = reader:ReadSingle()
	obj.tryMatchStep = reader:ReadBoolean()
	obj.runChasingDistance = reader:ReadSingle()
	obj.speed = reader:ReadSingle()
	obj.moveActionId = reader:ReadUInt32()
	obj.moveActionGroup = reader:ReadUInt32()
	obj.noRootMotion = reader:ReadBoolean()
	obj.towardTarget = reader:ReadBoolean()
	obj.AgentId = reader:ReadUInt64()
	obj.Token = reader:ReadUInt64()
	obj.Debug = reader:ReadString()
end
Auto.Reader[301] = function(reader, obj)
	setmetatable(obj, Auto.Meta[301])

	obj.SpecificMethod = reader:ReadByte()
	obj.speed = reader:ReadSingle()
	obj.moveActionId = reader:ReadUInt32()
	obj.noRootMotion = reader:ReadBoolean()
	obj.moveActionGroup = reader:ReadUInt32()
	obj.wayPoints = Base.ReadList(reader, function(r)
		return Base.ReadStruct(r, Auto.Reader.UXVector3)
	end)
	obj.AgentId = reader:ReadUInt64()
	obj.Token = reader:ReadUInt64()
	obj.Debug = reader:ReadString()
end
Auto.Reader[302] = function(reader, obj)
	setmetatable(obj, Auto.Meta[302])

	obj.Target = Base.ReadStruct(reader, Auto.Reader[314])
	obj.directionTolerance = reader:ReadSingle()
	obj.AgentId = reader:ReadUInt64()
	obj.Token = reader:ReadUInt64()
	obj.Debug = reader:ReadString()
end
Auto.Reader[303] = function(reader, obj)
	setmetatable(obj, Auto.Meta[303])

	obj.AnotherAgentId = reader:ReadUInt64()
	obj.MultiInteractType = reader:ReadUInt32()
	obj.AgentId = reader:ReadUInt64()
	obj.Token = reader:ReadUInt64()
	obj.Debug = reader:ReadString()
end
Auto.Reader[304] = function(reader, obj)
	setmetatable(obj, Auto.Meta[304])

	obj.BehaviorTree = reader:ReadString()
	obj.AgentId = reader:ReadUInt64()
	obj.Token = reader:ReadUInt64()
	obj.Debug = reader:ReadString()
end
Auto.Reader[305] = function(reader, obj)
	setmetatable(obj, Auto.Meta[305])

	obj.AgentId = reader:ReadUInt64()
	obj.Token = reader:ReadUInt64()
	obj.Debug = reader:ReadString()
end
Auto.Reader[306] = function(reader, obj)
	setmetatable(obj, Auto.Meta[306])

	obj.npcAnimState = reader:ReadInt32()
	obj.AgentId = reader:ReadUInt64()
	obj.Token = reader:ReadUInt64()
end
Auto.Reader[307] = function(reader, obj)
	setmetatable(obj, Auto.Meta[307])

	obj.wayPoints = Base.ReadList(reader, function(r)
		return Base.ReadStruct(r, Auto.Reader.UXVector3)
	end)
	obj.checkPointActions = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[270])
	end)
	obj.specificMethod = reader:ReadByte()
	obj.startPace = reader:ReadByte()
	obj.startPaceDuration = reader:ReadSingle()
	obj.animationSetId = reader:ReadUInt32()
	obj.speed = reader:ReadSingle()
	obj.moveActionId = reader:ReadUInt32()
	obj.moveActionGroupId = reader:ReadUInt32()
	obj.notOnGround = reader:ReadBoolean()
	obj.tryUseRootMotion = reader:ReadBoolean()
	obj.AgentId = reader:ReadUInt64()
	obj.Token = reader:ReadUInt64()
	obj.Debug = reader:ReadString()
end
Auto.Reader[308] = function(reader, obj)
	setmetatable(obj, Auto.Meta[308])

	obj.AgentId = reader:ReadUInt64()
	obj.Token = reader:ReadUInt64()
	obj.Debug = reader:ReadString()
end
Auto.Reader[309] = function(reader, obj)
	setmetatable(obj, Auto.Meta[309])

	obj.partner = reader:ReadUInt64()
	obj.isDirector = reader:ReadBoolean()
	obj.wayPoints = Base.ReadList(reader, function(r)
		return Base.ReadStruct(r, Auto.Reader.UXVector3)
	end)
	obj.checkPointActions = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[270])
	end)
	obj.moveMethod = reader:ReadByte()
	obj.startPace = reader:ReadByte()
	obj.startPaceDuration = reader:ReadSingle()
	obj.animationSetId = reader:ReadUInt32()
	obj.speed = reader:ReadSingle()
	obj.moveActionId = reader:ReadUInt32()
	obj.moveActionGroupId = reader:ReadUInt32()
	obj.notOnGround = reader:ReadBoolean()
	obj.tryUseRootMotion = reader:ReadBoolean()
	obj.leadingBreakTurn = reader:ReadBoolean()
	obj.isLeadingWay = reader:ReadBoolean()
	obj.dontLimitExtraMove = reader:ReadBoolean()
	obj.dontLimitBasicMove = reader:ReadBoolean()
	obj.waitingDialogId = reader:ReadUInt32()
	obj.minDialogDuration = reader:ReadSingle()
	obj.leadingWayUrgings = Base.ReadList(reader, function(r)
		return Base.ReadStruct(r, Auto.Reader[456])
	end)
	obj.leadingWayCfgId = reader:ReadUInt32()
	obj.AgentId = reader:ReadUInt64()
	obj.Token = reader:ReadUInt64()
	obj.Debug = reader:ReadString()
end
Auto.Reader[277] = function(reader, obj)
	setmetatable(obj, Auto.Meta[277])

	obj.AgentId = reader:ReadUInt64()
	obj.Token = reader:ReadUInt64()
	obj.Debug = reader:ReadString()
end
Auto.Reader[310] = function(reader, obj)
	setmetatable(obj, Auto.Meta[310])

	obj.vehicle = reader:ReadUInt64()
	obj.seatIndex = reader:ReadByte()
	obj.distances = Base.ReadList(reader, function(r)
		return Base.ReadStruct(r, Auto.Reader[571])
	end)
	obj.AgentId = reader:ReadUInt64()
	obj.Token = reader:ReadUInt64()
	obj.Debug = reader:ReadString()
end
Auto.Reader[311] = function(reader, obj)
	setmetatable(obj, Auto.Meta[311])

	obj.vehicle = reader:ReadUInt64()
	obj.seatIndex = reader:ReadByte()
	obj.distances = Base.ReadList(reader, function(r)
		return Base.ReadStruct(r, Auto.Reader[571])
	end)
	obj.AgentId = reader:ReadUInt64()
	obj.Token = reader:ReadUInt64()
	obj.Debug = reader:ReadString()
end
Auto.Reader[312] = function(reader, obj)
	setmetatable(obj, Auto.Meta[312])

	obj.AgentId = reader:ReadUInt64()
	obj.Token = reader:ReadUInt64()
end
Auto.Reader[313] = function(reader, obj)
	setmetatable(obj, Auto.Meta[313])

	obj.dialogueId = reader:ReadUInt32()
	obj.lookTarget = reader:ReadBoolean()
	obj.dialogueSpeakers = Base.ReadList(reader, function(r)
		return r:ReadString()
	end)
	obj.dialogueBindUnits = Base.ReadList(reader, function(r)
		return r:ReadUInt64()
	end)
	obj.isRestart = reader:ReadBoolean()
	obj.resumeDelay = reader:ReadSingle()
	obj.isGeneralDialog = reader:ReadBoolean()
	obj.clearPreDialogueTasks = reader:ReadBoolean()
	obj.yawAngleLimit = reader:ReadSingle()
	obj.pitchAngleLimit = reader:ReadSingle()
	obj.AgentId = reader:ReadUInt64()
	obj.Token = reader:ReadUInt64()
	obj.Debug = reader:ReadString()
end
Auto.Reader[314] = function(reader, obj)
	setmetatable(obj, Auto.Meta[314])

	obj.Id = reader:ReadUInt64()
	obj.Position = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.Type = reader:ReadByte()
end
Auto.Reader[315] = function(reader, obj)
	setmetatable(obj, Auto.Meta[315])

	obj.Destination = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.AgentId = reader:ReadUInt64()
	obj.Token = reader:ReadUInt64()
	obj.Debug = reader:ReadString()
end
Auto.Reader[316] = function(reader, obj)
	setmetatable(obj, Auto.Meta[316])

	obj.AgentId = reader:ReadUInt64()
	obj.Token = reader:ReadUInt64()
	obj.Debug = reader:ReadString()
end
Auto.Reader[317] = function(reader, obj)
	setmetatable(obj, Auto.Meta[317])

	obj.AgentId = reader:ReadUInt64()
	obj.Token = reader:ReadUInt64()
	obj.Debug = reader:ReadString()
end
Auto.Reader[318] = function(reader, obj)
	setmetatable(obj, Auto.Meta[318])

	obj.Target = reader:ReadUInt64()
	obj.ArriveDistance = reader:ReadSingle()
	obj.Speed = reader:ReadSingle()
	obj.AgentId = reader:ReadUInt64()
	obj.Token = reader:ReadUInt64()
	obj.Debug = reader:ReadString()
end
Auto.Reader[319] = function(reader, obj)
	setmetatable(obj, Auto.Meta[319])

	obj.VehicleId = reader:ReadUInt64()
	obj.BorrowedSeatIndex = reader:ReadByte()
	obj.NpcSeatIndex = reader:ReadByte()
	obj.AgentId = reader:ReadUInt64()
	obj.Token = reader:ReadUInt64()
	obj.Debug = reader:ReadString()
end
Auto.Reader[23] = function(reader, obj)
	setmetatable(obj, Auto.Meta[23])

	obj.BaseActivityInfo = Auto.Dispatch[224](reader)
	obj.ActivityData = Auto.Dispatch[74](reader)
end
Auto.Reader[320] = function(reader, obj)
	setmetatable(obj, Auto.Meta[320])

	obj.BubbleId = reader:ReadUInt32()
	obj.TriggerPolicy = reader:ReadByte()
	obj.Priority = reader:ReadInt32()
	obj.Cooldown = reader:ReadSingle()
end
Auto.Reader[321] = function(reader, obj)
	setmetatable(obj, Auto.Meta[321])

	obj.EntityId = reader:ReadUInt64()
	obj.SensorRange = Base.ReadStruct(reader, Auto.Reader[322])
	obj.Configs = Base.ReadList(reader, function(r)
		return Base.ReadStruct(r, Auto.Reader[320])
	end)
end
Auto.Reader[322] = function(reader, obj)
	setmetatable(obj, Auto.Meta[322])

	obj.HeightDiff = reader:ReadSingle()
	obj.RadiusSq = reader:ReadSingle()
	obj.ExpandRadiusSq = reader:ReadSingle()
	obj.LeftAngleBorder = reader:ReadSingle()
	obj.RightAngleBorder = reader:ReadSingle()
end
Auto.Reader[323] = function(reader, obj)
	setmetatable(obj, Auto.Meta[323])

	obj.EntityId = reader:ReadUInt64()
	obj.VehicleUId = reader:ReadUInt64()
	obj.SeatIndex = reader:ReadByte()
	obj.PositionOffset = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.RotationOffset = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.CanBeEjected = reader:ReadBoolean()
	obj.UseSpecificAction = reader:ReadBoolean()
	obj.ActionGroup = reader:ReadUInt32()
	obj.ActionId = reader:ReadUInt32()
end
Auto.Reader[217] = function(reader, obj)
	setmetatable(obj, Auto.Meta[217])

	obj.Name = reader:ReadString()
	obj.Sign = reader:ReadString()
	obj.Comment = reader:ReadString()
end
Auto.Reader[62] = function(reader, obj)
	setmetatable(obj, Auto.Meta[62])

	obj.CommonSeasonInfo = Base.ReadComplex(reader, Auto.Reader[357])
	obj.SeasonInfo = Base.ReadComplex(reader, Auto.Reader[47])
end
Auto.Reader[282] = function(reader, obj)
	setmetatable(obj, Auto.Meta[282])

	obj.AgentId = reader:ReadUInt64()
	obj.Token = reader:ReadUInt64()
end
Auto.Reader[109] = function(reader, obj)
	setmetatable(obj, Auto.Meta[109])

	obj.NpcFormworkId = reader:ReadUInt32()
	obj.AgentPersonaId = reader:ReadUInt32()
	obj.UrbanDiversityConfigId = reader:ReadUInt32()
	obj.DesiredSpeed = reader:ReadSingle()
	obj.ActionId = reader:ReadUInt16()
	obj.TargetLocationReason = reader:ReadByte()
	obj.FashionSuitId = reader:ReadUInt32()
	obj.Points = Base.ReadList(reader, function(r)
		return Base.ReadStruct(r, Auto.Reader[356])
	end)
	obj.Id = reader:ReadUInt64()
	obj.Position = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.Facing = reader:ReadSingle()
end
Auto.Reader[124] = function(reader, obj)
	setmetatable(obj, Auto.Meta[124])

	obj.Type = reader:ReadInt32()
	obj.ParametersDouble = Base.ReadList(reader, function(r)
		return r:ReadDouble()
	end)
	obj.ParametersULong = Base.ReadList(reader, function(r)
		return r:ReadUInt64()
	end)
	obj.ParametersUInt = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
	obj.ParametersVector3 = Base.ReadList(reader, function(r)
		return Base.ReadStruct(r, Auto.Reader.UXVector3)
	end)
	obj.ExpireTime = reader:ReadDouble()
end
Auto.Reader[325] = function(reader, obj)
	setmetatable(obj, Auto.Meta[325])

	obj.Id = reader:ReadUInt64()
	obj.Center = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.Extents = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.Duration = reader:ReadSingle()
	obj.RemoveRadiusSq = reader:ReadSingle()
	obj.IsOBB = reader:ReadBoolean()
	obj.OBBExtents = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.InverseRotation = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.Radius = reader:ReadSingle()
end
Auto.Reader[326] = function(reader, obj)
	setmetatable(obj, Auto.Meta[326])

	obj.detectorPid = reader:ReadUInt64()
	obj.detectedPid = reader:ReadUInt64()
	obj.detectValue = reader:ReadInt32()
	obj.Position = Base.ReadStruct(reader, Auto.Reader.UXVector3)
end
Auto.Reader[327] = function(reader, obj)
	setmetatable(obj, Auto.Meta[327])

	obj.DeviceModel = reader:ReadString()
	obj.OsName = reader:ReadString()
	obj.OsVersion = reader:ReadString()
	obj.Udid = reader:ReadString()
	obj.AppVersion = reader:ReadString()
	obj.DeviceHeight = reader:ReadInt32()
	obj.DeviceWidth = reader:ReadInt32()
	obj.Network = reader:ReadString()
	obj.Ipv6 = reader:ReadString()
	obj.AppChannel = reader:ReadString()
	obj.Transid = reader:ReadString()
	obj.UnisdkDeviceId = reader:ReadString()
	obj.IsEmulator = reader:ReadBoolean()
	obj.IsRoot = reader:ReadBoolean()
	obj.Imei = reader:ReadString()
	obj.Location = reader:ReadString()
	obj.CountryCode = reader:ReadString()
	obj.LocalIp = reader:ReadString()
	obj.OldAccountId = reader:ReadString()
	obj.MacAddr = reader:ReadString()
	obj.GpuName = reader:ReadString()
	obj.CpuName = reader:ReadString()
	obj.HardDriveSn = reader:ReadString()
	obj.TotalMemory = reader:ReadInt64()
	obj.ResolutionHeight = reader:ReadInt32()
	obj.ResolutionWidth = reader:ReadInt32()
	obj.FullScreen = reader:ReadInt32()
	obj.DeviceLevel = reader:ReadInt32()
	obj.DisplayLevel = reader:ReadInt32()
	obj.Joystick = reader:ReadString()
	obj.characterQualityLevel = reader:ReadInt32()
	obj.vehicleQualityLevel = reader:ReadInt32()
end
Auto.Reader[192] = function(reader, obj)
	setmetatable(obj, Auto.Meta[192])

	obj.TodayTotalIncome = reader:ReadInt32()
	obj.TodayRewardPoint = reader:ReadInt32()
	obj.TotalActivityPointRewards = reader:ReadInt32()
	obj.FinishedOrders = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[35])
	end)
end
Auto.Reader[328] = function(reader, obj)
	setmetatable(obj, Auto.Meta[328])

	obj.InstanceId = reader:ReadUInt64()
	obj.Offset = Base.ReadStruct(reader, Auto.Reader.UXVector3)
end
Auto.Reader[329] = function(reader, obj)
	setmetatable(obj, Auto.Meta[329])

	obj.Id = reader:ReadUInt64()
	obj.Position = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.Facing = reader:ReadSingle()
	obj.TraceType = reader:ReadByte()
	obj.Members = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[328])
	end)
end
Auto.Reader[330] = function(reader, obj)
	setmetatable(obj, Auto.Meta[330])

	obj.fps_list = reader:ReadString()
	obj.fps3_list = reader:ReadString()
	obj.fps99_list = reader:ReadString()
	obj.list_item_format = reader:ReadString()
end
Auto.Reader[331] = function(reader, obj)
	setmetatable(obj, Auto.Meta[331])

	obj.Id = reader:ReadUInt64()
	obj.ZoneIndex = reader:ReadInt32()
	obj.PeriodCount = reader:ReadInt32()
	obj.CurrentPeriodIndex = reader:ReadInt32()
	obj.NextPeriodIndex = reader:ReadInt32()
	obj.CurrentState = reader:ReadByte()
	obj.Position = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.LaneHandlesOpen = Base.ReadList(reader, function(r)
		return r:ReadInt32()
	end)
	obj.LaneVehicleCountDebugData = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[332])
	end)
end
Auto.Reader[332] = function(reader, obj)
	setmetatable(obj, Auto.Meta[332])

	obj.PedLane = reader:ReadBoolean()
	obj.LaneHandle = reader:ReadInt32()
	obj.Count = reader:ReadInt32()
end
Auto.Reader[333] = function(reader, obj)
	setmetatable(obj, Auto.Meta[333])

	obj.NpcFormworkId = reader:ReadUInt32()
	obj.MetroInstanceId = reader:ReadUInt64()
	obj.MetroCarriageIndex = reader:ReadByte()
	obj.PoiActionId = reader:ReadUInt32()
	obj.Id = reader:ReadUInt64()
	obj.Position = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.Facing = reader:ReadSingle()
end
Auto.Reader[334] = function(reader, obj)
	setmetatable(obj, Auto.Meta[334])

	obj.TemplateId = reader:ReadUInt32()
	obj.InviteChatList = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[24])
	end)
	obj.DialogChatList = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[24])
	end)
	obj.NpcChatListDict = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return Base.ReadComplex(r, Auto.Reader[268])
	end)
	obj.DialogChatListDict = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return Base.ReadComplex(r, Auto.Reader[268])
	end)
end
Auto.Reader[204] = function(reader, obj)
	setmetatable(obj, Auto.Meta[204])

	obj.PedArea = reader:ReadSingle()
	obj.NonScaleExceptedPedNum = reader:ReadSingle()
	obj.ExceptedPedNum = reader:ReadSingle()
	obj.ActualPedNum = reader:ReadSingle()
	obj.ExceptedStaticNum = reader:ReadSingle()
	obj.ActualStaticNum = reader:ReadSingle()
	obj.ActualVehicleNpcNum = reader:ReadSingle()
	obj.ActualMetroNpcNum = reader:ReadSingle()
end
Auto.Reader[335] = function(reader, obj)
	setmetatable(obj, Auto.Meta[335])

	obj.TemplateId = reader:ReadUInt32()
	obj.InviteChatList = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[24])
	end)
	obj.DialogChatList = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[24])
	end)
	obj.Members = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
	obj.NpcChatListDict = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return Base.ReadComplex(r, Auto.Reader[268])
	end)
	obj.DialogChatListDict = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return Base.ReadComplex(r, Auto.Reader[268])
	end)
end
Auto.Reader[336] = function(reader, obj)
	setmetatable(obj, Auto.Meta[336])

	obj.InstanceId = reader:ReadUInt64()
	obj.Position = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.Facing = reader:ReadSingle()
end
Auto.Reader[337] = function(reader, obj)
	setmetatable(obj, Auto.Meta[337])

	obj.Id = reader:ReadUInt64()
	obj.PoiActionId = reader:ReadUInt32()
	obj.StartTime = reader:ReadDouble()
end
Auto.Reader[338] = function(reader, obj)
	setmetatable(obj, Auto.Meta[338])

	obj.Id = reader:ReadInt32()
	obj.NpcFormworkId = reader:ReadUInt32()
	obj.Position = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.ActionId = reader:ReadInt32()
end
Auto.Reader[339] = function(reader, obj)
	setmetatable(obj, Auto.Meta[339])

	obj.setting = reader:ReadString()
end
Auto.Reader[340] = function(reader, obj)
	setmetatable(obj, Auto.Meta[340])

	obj.StaticNpcInfoId = reader:ReadUInt64()
	obj.NpcFormworkId = reader:ReadUInt32()
	obj.AgentPersonaId = reader:ReadUInt32()
	obj.PoiActionId = reader:ReadUInt32()
	obj.UrbanDiversityId = reader:ReadUInt32()
	obj.IgnoreAllStim = reader:ReadBoolean()
	obj.TaskRelated = reader:ReadBoolean()
	obj.EnableHack = reader:ReadBoolean()
	obj.NpcPid = reader:ReadInt32()
	obj.AgentSyncClientInfo = Base.ReadComplex(reader, Auto.Reader[236])
	obj.LookAtDecisionRulesId = reader:ReadUInt32()
	obj.ForceGo = reader:ReadBoolean()
	obj.SourceType = reader:ReadByte()
	obj.Id = reader:ReadUInt64()
	obj.Position = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.Facing = reader:ReadSingle()
end
Auto.Reader[341] = function(reader, obj)
	setmetatable(obj, Auto.Meta[341])

	obj.VehicleConfigId = reader:ReadUInt32()
	obj.ColorConfigId = reader:ReadUInt32()
	obj.DamageStatusId = reader:ReadUInt32()
	obj.Timestamp = reader:ReadDouble()
	obj.NotDrive = reader:ReadBoolean()
	obj.RotationX = reader:ReadSingle()
	obj.RotationY = reader:ReadSingle()
	obj.RotationZ = reader:ReadSingle()
	obj.RotationW = reader:ReadSingle()
	obj.Parts = Base.ReadList(reader, function(r)
		return Base.ReadStruct(r, Auto.Reader[654])
	end)
	obj.Id = reader:ReadUInt64()
	obj.Position = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.Facing = reader:ReadSingle()
end
Auto.Reader[31] = function(reader, obj)
	setmetatable(obj, Auto.Meta[31])

	obj.TeamId = reader:ReadUInt64()
	obj.LeaderPid = reader:ReadUInt64()
	obj.Members = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[6])
	end)
	obj.Setting = Base.ReadComplex(reader, Auto.Reader[5])
end
Auto.Reader[342] = function(reader, obj)
	setmetatable(obj, Auto.Meta[342])

	obj.InstanceId = reader:ReadUInt64()
	obj.ZoneIndex = reader:ReadInt32()
	obj.Position = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.TrafficLightInfos = Base.ReadList(reader, function(r)
		return Base.ReadStruct(r, Auto.Reader[633])
	end)
	obj.PeriodControlInfos = Base.ReadList(reader, function(r)
		return Base.ReadStruct(r, Auto.Reader[634])
	end)
	obj.CurrentPeriodIndex = reader:ReadByte()
	obj.NextPeriodIndex = reader:ReadByte()
	obj.RailPeriodIndex = reader:ReadByte()
end
Auto.Reader[344] = function(reader, obj)
	setmetatable(obj, Auto.Meta[344])

	obj.IntersectionIndex = reader:ReadUInt64()
	obj.CurrentState = reader:ReadByte()
	obj.CurrentPeriodIndex = reader:ReadByte()
	obj.NextPeriodIndex = reader:ReadByte()
	obj.RailPeriodIndex = reader:ReadByte()
end
Auto.Reader[165] = function(reader, obj)
	setmetatable(obj, Auto.Meta[165])

	obj.Orders = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[35])
	end)
	obj.RewardPointSum = reader:ReadInt32()
	obj.CustomerSatisfactionAverage = reader:ReadSingle()
	obj.CurrentOrderId = reader:ReadUInt32()
	obj.TruckGuideClicked = reader:ReadBoolean()
	obj.EventIdToAgent = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return r:ReadUInt64()
	end)
	obj.AutoAccept = reader:ReadBoolean()
	obj.DefaultVehicleId = reader:ReadUInt32()
	obj.TotalIncome = reader:ReadInt32()
end
Auto.Reader[345] = function(reader, obj)
	setmetatable(obj, Auto.Meta[345])

	obj.InstanceId = reader:ReadUInt64()
	obj.BuffConfigId = reader:ReadUInt32()
	obj.EffectChangeEndTime = reader:ReadDouble()
	obj.ExpireTime = reader:ReadDouble()
end
Auto.Reader[346] = function(reader, obj)
	setmetatable(obj, Auto.Meta[346])

	obj.Id = reader:ReadInt32()
	obj.Position = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.ActionId = reader:ReadInt32()
	obj.LaneHandle = reader:ReadInt32()
	obj.DistanceAlongLane = reader:ReadSingle()
	obj.NextLaneHandle = reader:ReadInt32()
end
Auto.Reader[347] = function(reader, obj)
	setmetatable(obj, Auto.Meta[347])

	obj.Id = reader:ReadUInt64()
	obj.VehicleLogicType = reader:ReadString()
	obj.CurrentVehicleStatus = reader:ReadString()
	obj.CurrentLaneHandle = reader:ReadInt32()
	obj.NextLaneHandle = reader:ReadInt32()
	obj.DistanceToAvoid = reader:ReadSingle()
	obj.NextVehicleId = reader:ReadUInt64()
	obj.NextMergingVehicleId = reader:ReadUInt64()
	obj.NextSplittingVehicleId = reader:ReadUInt64()
	obj.FindIdList = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
end
Auto.Reader[348] = function(reader, obj)
	setmetatable(obj, Auto.Meta[348])

	obj.VehicleConfigId = reader:ReadUInt32()
	obj.VehicleColorId = reader:ReadUInt32()
	obj.VehicleLightState = reader:ReadByte()
	obj.LaneHandle = reader:ReadInt32()
	obj.DistanceAlongLane = reader:ReadSingle()
	obj.NextVehicleId = reader:ReadUInt64()
	obj.Timestamp = reader:ReadDouble()
	obj.ControlType = reader:ReadByte()
	obj.Parts = Base.ReadList(reader, function(r)
		return Base.ReadStruct(r, Auto.Reader[654])
	end)
	obj.Id = reader:ReadUInt64()
	obj.Position = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.Facing = reader:ReadSingle()
end
Auto.Reader[349] = function(reader, obj)
	setmetatable(obj, Auto.Meta[349])

	obj.VehicleLaneData = Base.ReadStruct(reader, Auto.Reader[350])
	obj.LaneHandleInitial = reader:ReadInt32()
	obj.LaneHandleFinal = reader:ReadInt32()
	obj.BeginDistanceAloneLaneInitial = reader:ReadSingle()
	obj.BeginDistanceAloneLaneFinal = reader:ReadSingle()
	obj.EndDistanceAlongLaneFinal = reader:ReadSingle()
	obj.DistanceBetweenLanes = reader:ReadSingle()
end
Auto.Reader[350] = function(reader, obj)
	setmetatable(obj, Auto.Meta[350])

	obj.Id = reader:ReadUInt64()
	obj.LaneHandle = reader:ReadInt32()
	obj.DistanceAlongLane = reader:ReadSingle()
	obj.Status = reader:ReadByte()
end
Auto.Reader[351] = function(reader, obj)
	setmetatable(obj, Auto.Meta[351])

	obj.LaneHandle = reader:ReadInt32()
	obj.Position = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.LaneLength = reader:ReadSingle()
	obj.SpaceAvailable = reader:ReadSingle()
	obj.NumVehicleOnLane = reader:ReadInt32()
end
Auto.Reader[352] = function(reader, obj)
	setmetatable(obj, Auto.Meta[352])

	obj.Id = reader:ReadUInt64()
	obj.NpcFormworkId = reader:ReadUInt32()
	obj.BindVehicleId = reader:ReadUInt64()
	obj.SeatIndex = reader:ReadByte()
end
Auto.Reader[353] = function(reader, obj)
	setmetatable(obj, Auto.Meta[353])

	obj.PartType = reader:ReadByte()
	obj.OpenOrClose = reader:ReadBoolean()
end
Auto.Reader[354] = function(reader, obj)
	setmetatable(obj, Auto.Meta[354])

	obj.Id = reader:ReadUInt64()
	obj.TargetLocationReason = reader:ReadByte()
	obj.ActionId = reader:ReadUInt16()
	obj.Points = Base.ReadList(reader, function(r)
		return Base.ReadStruct(r, Auto.Reader[356])
	end)
end
Auto.Reader[355] = function(reader, obj)
	setmetatable(obj, Auto.Meta[355])

	obj.Id = reader:ReadUInt64()
	obj.ActionId = reader:ReadUInt16()
end
Auto.Reader[356] = function(reader, obj)
	setmetatable(obj, Auto.Meta[356])

	obj.Position = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.Facing = Base.ReadStruct(reader, Auto.Reader[259])
end
Auto.Reader[224] = function(reader, obj)
	setmetatable(obj, Auto.Meta[224])

	obj.CfgId = reader:ReadUInt32()
	obj.StartTime = reader:ReadUInt32()
	obj.EndTime = reader:ReadUInt32()
end
Auto.Reader[357] = function(reader, obj)
	setmetatable(obj, Auto.Meta[357])

	obj.CfgId = reader:ReadUInt32()
	obj.StartTime = reader:ReadUInt32()
	obj.EndTime = reader:ReadUInt32()
end
Auto.Reader[358] = function(reader, obj)
	setmetatable(obj, Auto.Meta[358])

	obj.ChallengeCfgId = reader:ReadUInt32()
	obj.HistoryHighestStars = reader:ReadInt32()
	obj.LastStars = reader:ReadInt32()
end
Auto.Reader[359] = function(reader, obj)
	setmetatable(obj, Auto.Meta[359])

	obj.GamePlayCfgId = reader:ReadUInt32()
	obj.ChallengeDict = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return Base.ReadComplex(r, Auto.Reader[358])
	end)
	obj.Stars = reader:ReadInt32()
end
Auto.Reader[47] = function(reader, obj)
	setmetatable(obj, Auto.Meta[47])

	obj.CfgId = reader:ReadUInt32()
	obj.GameplayDict = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return Base.ReadComplex(r, Auto.Reader[359])
	end)
	obj.AwardList = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
	obj.IsFinish = reader:ReadBoolean()
end
Auto.Reader[360] = function(reader, obj)
	setmetatable(obj, Auto.Meta[360])

	obj.CfgId = reader:ReadUInt32()
	obj.FirstOpenTime = reader:ReadUInt32()
	obj.DeleteFiles = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
	obj.DeleteEmails = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
end
Auto.Reader[30] = function(reader, obj)
	setmetatable(obj, Auto.Meta[30])

	obj.CfgId = reader:ReadUInt32()
	obj.IsRead = reader:ReadBoolean()
	obj.UnlockTime = reader:ReadUInt32()
end
Auto.Reader[84] = function(reader, obj)
	setmetatable(obj, Auto.Meta[84])

	obj.CfgId = reader:ReadUInt32()
	obj.UnlockTime = reader:ReadUInt32()
	obj.IsRead = reader:ReadBoolean()
end
Auto.Reader[190] = function(reader, obj)
	setmetatable(obj, Auto.Meta[190])

	obj.UnlockEmails = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return Base.ReadComplex(r, Auto.Reader[30])
	end)
	obj.UnlockFiles = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return Base.ReadComplex(r, Auto.Reader[84])
	end)
	obj.ComputerInfos = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return Base.ReadComplex(r, Auto.Reader[360])
	end)
end
Auto.Reader[112] = function(reader, obj)
	setmetatable(obj, Auto.Meta[112])

	obj.PortId = reader:ReadInt32()
end
Auto.Reader[361] = function(reader, obj)
	setmetatable(obj, Auto.Meta[361])

	obj.V = reader:ReadBoolean()
	obj.PortId = reader:ReadInt32()
end
Auto.Reader[362] = function(reader, obj)
	setmetatable(obj, Auto.Meta[362])

	obj.V = reader:ReadString()
	obj.Type = reader:ReadByte()
	obj.PortId = reader:ReadInt32()
end
Auto.Reader[363] = function(reader, obj)
	setmetatable(obj, Auto.Meta[363])

	obj.Index = reader:ReadInt32()
	obj.CurrentNodeIds = Base.ReadList(reader, function(r)
		return r:ReadInt32()
	end)
	obj.CompleteNodeIds = Base.ReadList(reader, function(r)
		return r:ReadInt32()
	end)
	obj.ErrorNodeIds = Base.ReadList(reader, function(r)
		return r:ReadInt32()
	end)
	obj.ResultNodeIds = Base.ReadDict(reader, function(r)
		return r:ReadInt32()
	end, function(r)
		return r:ReadString()
	end)
end
Auto.Reader[364] = function(reader, obj)
	setmetatable(obj, Auto.Meta[364])

	obj.V = reader:ReadDouble()
	obj.PortId = reader:ReadInt32()
end
Auto.Reader[365] = function(reader, obj)
	setmetatable(obj, Auto.Meta[365])

	obj.V = reader:ReadInt32()
	obj.PortId = reader:ReadInt32()
end
Auto.Reader[366] = function(reader, obj)
	setmetatable(obj, Auto.Meta[366])

	obj.V = reader:ReadString()
	obj.PortId = reader:ReadInt32()
end
Auto.Reader[367] = function(reader, obj)
	setmetatable(obj, Auto.Meta[367])

	obj.V = reader:ReadUInt32()
	obj.PortId = reader:ReadInt32()
end
Auto.Reader[368] = function(reader, obj)
	setmetatable(obj, Auto.Meta[368])

	obj.V = reader:ReadUInt64()
	obj.PortId = reader:ReadInt32()
end
Auto.Reader[369] = function(reader, obj)
	setmetatable(obj, Auto.Meta[369])

	obj.V = reader:ReadUInt64()
	obj.PortId = reader:ReadInt32()
end
Auto.Reader[370] = function(reader, obj)
	setmetatable(obj, Auto.Meta[370])

	obj.V = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.PortId = reader:ReadInt32()
end
Auto.Reader[371] = function(reader, obj)
	setmetatable(obj, Auto.Meta[371])

	obj.V = reader:ReadUInt64()
	obj.PortId = reader:ReadInt32()
end
Auto.Reader[372] = function(reader, obj)
	setmetatable(obj, Auto.Meta[372])

	obj.Sex = reader:ReadByte()
	obj.Name = reader:ReadString()
	obj.Config = Base.ReadList(reader, function(r)
		return r:ReadByte()
	end)
end
Auto.Reader[373] = function(reader, obj)
	setmetatable(obj, Auto.Meta[373])

	obj.TargetId = reader:ReadUInt64()
	obj.CreationId = reader:ReadUInt64()
	obj.EventType = reader:ReadByte()
end
Auto.Reader[374] = function(reader, obj)
	setmetatable(obj, Auto.Meta[374])

	obj.CreationId = reader:ReadUInt64()
	obj.TargetId = reader:ReadUInt64()
	obj.TargetDestructible = reader:ReadUInt64()
	obj.ShieldDefendIndex = reader:ReadInt32()
	obj.HurtStiffId = reader:ReadUInt32()
	obj.StiffTime = reader:ReadSingle()
	obj.HurtEffectId = reader:ReadUInt32()
end
Auto.Reader[375] = function(reader, obj)
	setmetatable(obj, Auto.Meta[375])

	obj.CreationId = reader:ReadUInt64()
	obj.Position = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.Rotation = Base.ReadStruct(reader, Auto.Reader.UXVector3)
end
Auto.Reader[34] = function(reader, obj)
	setmetatable(obj, Auto.Meta[34])

	obj.Credit = reader:ReadUInt32()
	obj.Level = reader:ReadUInt32()
	obj.ClaimedLevelRewards = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return r:ReadBoolean()
	end)
end
Auto.Reader[376] = function(reader, obj)
	setmetatable(obj, Auto.Meta[376])

	obj.TargetPointList = Base.ReadList(reader, function(r)
		return Base.ReadStruct(r, Auto.Reader.UXVector3)
	end)
	obj.CruiseType = reader:ReadByte()
	obj.Count = reader:ReadInt32()
	obj.configFlags = reader:ReadByte()
	obj.pathFindFlags = reader:ReadByte()
	obj.TargetType = reader:ReadByte()
	obj.TargetUid = reader:ReadUInt64()
	obj.checkClose = reader:ReadBoolean()
	obj.checkFar = reader:ReadBoolean()
	obj.closeRange = reader:ReadSingle()
	obj.farawayRange = reader:ReadSingle()
	obj.accelerateScale = reader:ReadSingle()
	obj.decelerateScale = reader:ReadSingle()
	obj.minSpeed = reader:ReadSingle()
	obj.maxSpeed = reader:ReadSingle()
	obj.ArrivalDistance = reader:ReadSingle()
	obj.Token = reader:ReadUInt64()
	obj.taskAIConfigId = reader:ReadUInt32()
	obj.defaultSpeed = reader:ReadSingle()
	obj.drivingFlags = reader:ReadInt32()
	obj.initSpeed = reader:ReadSingle()
	obj.initTaskAIBuffList = Base.ReadList(reader, function(r)
		return Base.ReadStruct(r, Auto.Reader[629])
	end)
	obj.commonParameters = Base.ReadStruct(reader, Auto.Reader[650])
end
Auto.Reader[377] = function(reader, obj)
	setmetatable(obj, Auto.Meta[377])

	obj.q = reader:ReadInt32()
	obj.r = reader:ReadInt32()
	obj.s = reader:ReadInt32()
end
Auto.Reader[378] = function(reader, obj)
	setmetatable(obj, Auto.Meta[378])

	obj.CurveType = reader:ReadByte()
	obj.StartPoint = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.AuxiliaryPoint = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.EndPoint = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.CircleMoveRadius = reader:ReadSingle()
	obj.MoveId = reader:ReadInt32()
	obj.ActionId = reader:ReadUInt32()
end
Auto.Reader[0] = function(reader, obj)
	setmetatable(obj, Auto.Meta[0])

	obj.Type = reader:ReadInt32()
	obj.StringData = reader:ReadString()
	obj.BinaryData = Base.ReadBuffer(reader)
end
Auto.Reader[379] = function(reader, obj)
	setmetatable(obj, Auto.Meta[379])

	obj.BuffId = reader:ReadUInt32()
	obj.StartTime = reader:ReadDouble()
	obj.EndTime = reader:ReadDouble()
end
Auto.Reader[214] = function(reader, obj)
	setmetatable(obj, Auto.Meta[214])

	obj.SpiritDatas = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[383])
	end)
	obj.ElementDatas = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[380])
	end)
end
Auto.Reader[380] = function(reader, obj)
	setmetatable(obj, Auto.Meta[380])

	obj.ElementId = reader:ReadUInt32()
	obj.StartTime = reader:ReadDouble()
	obj.EndTime = reader:ReadDouble()
	obj.Damage = reader:ReadSingle()
end
Auto.Reader[381] = function(reader, obj)
	setmetatable(obj, Auto.Meta[381])

	obj.HitTime = reader:ReadDouble()
	obj.SkillId = reader:ReadUInt32()
	obj.SpiritId = reader:ReadUInt32()
	obj.TriggerIndex = reader:ReadInt32()
	obj.Damage = reader:ReadSingle()
	obj.IsCritical = reader:ReadBoolean()
	obj.Error = reader:ReadUInt32()
	obj.Attrs = Base.ReadList(reader, function(r)
		return r:ReadSingle()
	end)
	obj.Buffs = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
end
Auto.Reader[382] = function(reader, obj)
	setmetatable(obj, Auto.Meta[382])

	obj.SKillId = reader:ReadUInt32()
	obj.SkillDamageList = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[381])
	end)
end
Auto.Reader[383] = function(reader, obj)
	setmetatable(obj, Auto.Meta[383])

	obj.SpiritId = reader:ReadUInt32()
	obj.TotalDamage = reader:ReadSingle()
	obj.SkillDamageRecords = Base.ReadDict(reader, function(r)
		return r:ReadInt32()
	end, function(r)
		return Base.ReadComplex(r, Auto.Reader[382])
	end)
	obj.BuffRecords = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return Base.ReadComplex(r, Auto.Reader[379])
	end)
end
Auto.Reader[384] = function(reader, obj)
	setmetatable(obj, Auto.Meta[384])

	obj.Money = reader:ReadInt32()
	obj.Fan = reader:ReadInt32()
end
Auto.Reader[385] = function(reader, obj)
	setmetatable(obj, Auto.Meta[385])

	obj.SourceAmount = reader:ReadSingle()
	obj.FromType = reader:ReadByte()
	obj.SourceTemplateId = reader:ReadUInt32()
	obj.SkillId = reader:ReadUInt32()
	obj.CreationId = reader:ReadUInt32()
	obj.TriggerIndex = reader:ReadInt32()
	obj.BuffId = reader:ReadUInt32()
	obj.SpecialEffects = reader:ReadByte()
	obj.ClientHitPosition = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.ElementType = reader:ReadUInt32()
	obj.HitIndex = reader:ReadInt32()
	obj.HpDecreased = reader:ReadSingle()
	obj.Amount = reader:ReadSingle()
	obj.ShieldDecreased = reader:ReadSingle()
	obj.ShieldIndex = reader:ReadInt32()
end
Auto.Reader[386] = function(reader, obj)
	setmetatable(obj, Auto.Meta[386])

	obj.StayElapsedTime = reader:ReadUInt32()
	obj.PlayElapsedTime = reader:ReadUInt32()
end
Auto.Reader[387] = function(reader, obj)
	setmetatable(obj, Auto.Meta[387])

	obj.DartId = reader:ReadUInt32()
	obj.Pid = reader:ReadUInt64()
	obj.NpcCultivationId = reader:ReadUInt32()
	obj.AgentUId = reader:ReadUInt64()
	obj.SeatIndex = reader:ReadInt32()
	obj.IsReady = reader:ReadBoolean()
	obj.IsPlayAgain = reader:ReadBoolean()
end
Auto.Reader[108] = function(reader, obj)
	setmetatable(obj, Auto.Meta[108])

	obj.ParticipantScoreDic = Base.ReadDict(reader, function(r)
		return r:ReadInt32()
	end, function(r)
		return r:ReadInt32()
	end)
	obj.CurrentScoreIndex = reader:ReadInt32()
	obj.CurrentScore = reader:ReadInt32()
	obj.CurrentScorePos = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.Winner = reader:ReadInt32()
end
Auto.Reader[388] = function(reader, obj)
	setmetatable(obj, Auto.Meta[388])

	obj.GameType = reader:ReadByte()
	obj.CurrentRound = reader:ReadUInt32()
	obj.CurrentTurn = reader:ReadInt32()
	obj.ScoreInfo = Base.ReadComplex(reader, Auto.Reader[108])
	obj.GadgetUId = reader:ReadUInt64()
	obj.StartReason = reader:ReadByte()
	obj.SyncReason = reader:ReadByte()
	obj.ZoneType = reader:ReadByte()
	obj.ZoneState = reader:ReadByte()
	obj.ParticipantInfos = Base.ReadList(reader, Auto.Dispatch[103])
end
Auto.Reader[389] = function(reader, obj)
	setmetatable(obj, Auto.Meta[389])

	obj.ElementId = reader:ReadUInt32()
	obj.Damage = reader:ReadSingle()
	obj.Count = reader:ReadInt32()
	obj.DamageMin = reader:ReadSingle()
	obj.DamageMax = reader:ReadSingle()
end
Auto.Reader[390] = function(reader, obj)
	setmetatable(obj, Auto.Meta[390])

	obj.SpiritId = reader:ReadUInt32()
	obj.TotalDamage = reader:ReadSingle()
	obj.FightStateTime = reader:ReadDouble()
	obj.FightBeginTime = reader:ReadDouble()
	obj.ActiveTime = reader:ReadDouble()
	obj.ActiveBeginTime = reader:ReadDouble()
	obj.SkillDamages = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return r:ReadSingle()
	end)
	obj.SkillCounts = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return r:ReadInt32()
	end)
	obj.SkillDamageCounts = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return r:ReadInt32()
	end)
	obj.SkillDamagesMin = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return r:ReadSingle()
	end)
	obj.SkillDamagesMax = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return r:ReadSingle()
	end)
	obj.ExtraBuffDamages = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return r:ReadSingle()
	end)
	obj.BuffTimes = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return r:ReadDouble()
	end)
	obj.BuffBeginTimes = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return r:ReadDouble()
	end)
	obj.BuffRefCounts = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return r:ReadInt32()
	end)
end
Auto.Reader[213] = function(reader, obj)
	setmetatable(obj, Auto.Meta[213])

	obj.Now = reader:ReadDouble()
	obj.Spirits = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[390])
	end)
	obj.Elements = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[389])
	end)
end
Auto.Reader[391] = function(reader, obj)
	setmetatable(obj, Auto.Meta[391])

	obj.FullPath = reader:ReadString()
	obj.Name = reader:ReadString()
	obj.IsDirectory = reader:ReadBoolean()
	obj.Size = reader:ReadInt64()
	obj.CreateTime = reader:ReadUInt32()
	obj.WriteTime = reader:ReadUInt32()
	obj.AccessTime = reader:ReadUInt32()
end
Auto.Reader[392] = function(reader, obj)
	setmetatable(obj, Auto.Meta[392])

	obj.PersistentDataPath = Base.ReadComplex(reader, Auto.Reader[391])
	obj.TemporaryCachePath = Base.ReadComplex(reader, Auto.Reader[391])
	obj.StreamingAssetsPath = Base.ReadComplex(reader, Auto.Reader[391])
	obj.DataPath = Base.ReadComplex(reader, Auto.Reader[391])
	obj.ConsoleLogPath = Base.ReadComplex(reader, Auto.Reader[391])
	obj.VirtualFileSystem = Base.ReadComplex(reader, Auto.Reader[391])
end
Auto.Reader[393] = function(reader, obj)
	setmetatable(obj, Auto.Meta[393])

	obj.TemplateId = reader:ReadUInt32()
	obj.q = reader:ReadInt32()
	obj.r = reader:ReadInt32()
	obj.s = reader:ReadInt32()
end
Auto.Reader[394] = function(reader, obj)
	setmetatable(obj, Auto.Meta[394])

	obj.CreationId = reader:ReadUInt64()
	obj.DeriveId = reader:ReadUInt32()
	obj.Position = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.Facing = reader:ReadSingle()
end
Auto.Reader[395] = function(reader, obj)
	setmetatable(obj, Auto.Meta[395])

	obj.InstanceId = reader:ReadUInt64()
	obj.Stage = reader:ReadUInt32()
	obj.BrokenType = reader:ReadByte()
	obj.Position = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.Facing = Base.ReadStruct(reader, Auto.Reader.UXVector3)
end
Auto.Reader[396] = function(reader, obj)
	setmetatable(obj, Auto.Meta[396])

	obj.PlayerStandardIndex = Base.ReadStruct(reader, Auto.Reader[446])
	obj.addInfos = Base.ReadList(reader, Auto.Dispatch[397])
	obj.indexList = Base.ReadList(reader, function(r)
		return Base.ReadStruct(r, Auto.Reader[446])
	end)
	obj.addUniqueIds = Base.ReadList(reader, function(r)
		return r:ReadUInt64()
	end)
	obj.removeIds = Base.ReadList(reader, function(r)
		return r:ReadUInt64()
	end)
	obj.reason = reader:ReadByte()
end
Auto.Reader[397] = function(reader, obj)
	setmetatable(obj, Auto.Meta[397])

	obj.InstanceId = reader:ReadUInt64()
	obj.UniqueId = reader:ReadUInt64()
	obj.CfgId = reader:ReadUInt32()
	obj.PathId = reader:ReadInt32()
	obj.Position = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.Facing = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.iScale = reader:ReadInt32()
	obj.Hp = reader:ReadSingle()
	obj.NavId = reader:ReadInt32()
	obj.State = reader:ReadByte()
	obj.BreakStage = reader:ReadUInt32()
	obj.OccupantInfos = Base.ReadList(reader, function(r)
		return Base.ReadStruct(r, Auto.Reader[583])
	end)
	obj.DropWeaponId = reader:ReadUInt64()
	obj.EffectIds = Base.ReadList(reader, function(r)
		return r:ReadInt32()
	end)
end
Auto.Reader[398] = function(reader, obj)
	setmetatable(obj, Auto.Meta[398])

	obj.Id = reader:ReadUInt64()
	obj.Frame = reader:ReadUInt32()
	obj.Position = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.Facing = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.Speed = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.Hp = reader:ReadSingle()
	obj.mindState = reader:ReadByte()
	obj.HookUnitId = reader:ReadUInt64()
	obj.SceneItemType = reader:ReadUInt32()
	obj.HostPlayerID = reader:ReadUInt64()
	obj.ClientLocalTime = reader:ReadUInt32()
	obj.CompressSceneItemData = Base.ReadList(reader, function(r)
		return r:ReadByte()
	end)
	obj.CompressSceneItemDataLength = reader:ReadInt32()
end
Auto.Reader[399] = function(reader, obj)
	setmetatable(obj, Auto.Meta[399])

	obj.VertexPoints = Base.ReadList(reader, function(r)
		return Base.ReadStruct(r, Auto.Reader.UXVector3)
	end)
	obj.CenterPos = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.SphereRadius = reader:ReadSingle()
	obj.XMagnitude = reader:ReadSingle()
	obj.YMagnitude = reader:ReadSingle()
	obj.ZMagnitude = reader:ReadSingle()
end
Auto.Reader[36] = function(reader, obj)
	setmetatable(obj, Auto.Meta[36])

	obj.Reason = reader:ReadByte()
	obj.NpcTemplateId = reader:ReadUInt32()
	obj.NpcInstanceId = reader:ReadUInt64()
	obj.AgentPosition = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.BlackContinue = reader:ReadBoolean()
	obj.FromTaskId = reader:ReadUInt32()
	obj.FromEventId = reader:ReadUInt32()
	obj.FromClient = reader:ReadBoolean()
	obj.DialogCameraSpawnId = reader:ReadUInt32()
	obj.SpoonNodeId = reader:ReadInt32()
end
Auto.Reader[400] = function(reader, obj)
	setmetatable(obj, Auto.Meta[400])

	obj.BadgeId2CountDict = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return r:ReadInt32()
	end)
end
Auto.Reader[86] = function(reader, obj)
	setmetatable(obj, Auto.Meta[86])

	obj.AgentId = reader:ReadUInt64()
	obj.AgentCfgId = reader:ReadUInt32()
	obj.DemandId = reader:ReadUInt32()
	obj.PersonalityId = reader:ReadUInt32()
	obj.SessionId = reader:ReadString()
	obj.Attitude = reader:ReadUInt32()
	obj.BranchId = reader:ReadUInt32()
	obj.Persuasion = reader:ReadUInt32()
	obj.Target = reader:ReadString()
	obj.Success_Persuasion = reader:ReadUInt32()
	obj.Endings = reader:ReadString()
	obj.Stage = reader:ReadInt32()
	obj.IsInGame = reader:ReadBoolean()
	obj.Faction = reader:ReadUInt32()
	obj.AppealTimeEnd = reader:ReadUInt32()
	obj.PersuadeTimeEnd = reader:ReadUInt32()
	obj.EndReason = reader:ReadInt32()
	obj.Result = reader:ReadInt32()
	obj.Clues = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
end
Auto.Reader[22] = function(reader, obj)
	setmetatable(obj, Auto.Meta[22])

	obj.AgentId = reader:ReadUInt64()
	obj.Stage = reader:ReadInt32()
	obj.Result = reader:ReadInt32()
	obj.Msg = reader:ReadString()
	obj.ClueId = reader:ReadUInt32()
	obj.Attitude = reader:ReadUInt32()
	obj.Persuasion = reader:ReadUInt32()
	obj.EndReason = reader:ReadInt32()
end
Auto.Reader[401] = function(reader, obj)
	setmetatable(obj, Auto.Meta[401])

	obj.CureList = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
end
Auto.Reader[169] = function(reader, obj)
	setmetatable(obj, Auto.Meta[169])

	obj.CureLimit = reader:ReadUInt32()
	obj.DiseaseList = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
	obj.DialogList = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
	obj.CureInfo = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[401])
	end)
end
Auto.Reader[402] = function(reader, obj)
	setmetatable(obj, Auto.Meta[402])

	obj.TimeStamp = reader:ReadSingle()
	obj.Position = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.RotationX = reader:ReadSingle()
	obj.RotationY = reader:ReadSingle()
	obj.RotationZ = reader:ReadSingle()
	obj.RotationW = reader:ReadSingle()
	obj.Velocity = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.AngVelocity = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.SteerInput = reader:ReadSingle()
	obj.ThrottleInput = reader:ReadSingle()
	obj.BrakeInput = reader:ReadSingle()
	obj.HandbrakeInput = reader:ReadSingle()
end
Auto.Reader[403] = function(reader, obj)
	setmetatable(obj, Auto.Meta[403])

	obj.VehicleConfigId = reader:ReadUInt32()
	obj.ControlType = reader:ReadByte()
	obj.Records = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[402])
	end)
	obj.TaskId = reader:ReadUInt32()
end
Auto.Reader[404] = function(reader, obj)
	setmetatable(obj, Auto.Meta[404])

	obj.BelongingId = reader:ReadUInt32()
	obj.OwnerId = reader:ReadUInt64()
	obj.Position = Base.ReadStruct(reader, Auto.Reader.UXVector3)
end
Auto.Reader[10] = function(reader, obj)
	setmetatable(obj, Auto.Meta[10])

	obj.Count = reader:ReadUInt32()
	obj.FinishTime = reader:ReadUInt32()
end
Auto.Reader[233] = function(reader, obj)
	setmetatable(obj, Auto.Meta[233])

	obj.PathId = reader:ReadInt32()
	obj.ReleaserId = reader:ReadUInt64()
	obj.Position = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.Facing = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.LivingTime = reader:ReadSingle()
end
Auto.Reader[405] = function(reader, obj)
	setmetatable(obj, Auto.Meta[405])

	obj.Pack = Base.ReadComplex(reader, Auto.Reader[501])
	obj.ReleaserId = reader:ReadUInt64()
	obj.CreateAgentInstanceId = reader:ReadUInt64()
	obj.CreateSkillInstanceId = reader:ReadInt32()
	obj.CreateIndex = reader:ReadInt32()
	obj.MergeAgentInstanceId = reader:ReadUInt64()
	obj.NoSleep = reader:ReadBoolean()
	obj.InstanceId = reader:ReadUInt64()
	obj.UniqueId = reader:ReadUInt64()
	obj.CfgId = reader:ReadUInt32()
	obj.PathId = reader:ReadInt32()
	obj.Position = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.Facing = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.iScale = reader:ReadInt32()
	obj.Hp = reader:ReadSingle()
	obj.NavId = reader:ReadInt32()
	obj.State = reader:ReadByte()
	obj.BreakStage = reader:ReadUInt32()
	obj.OccupantInfos = Base.ReadList(reader, function(r)
		return Base.ReadStruct(r, Auto.Reader[583])
	end)
	obj.DropWeaponId = reader:ReadUInt64()
	obj.EffectIds = Base.ReadList(reader, function(r)
		return r:ReadInt32()
	end)
end
Auto.Reader[406] = function(reader, obj)
	setmetatable(obj, Auto.Meta[406])

	obj.isShort = reader:ReadBoolean()
	obj.ownerId = reader:ReadUInt64()
	obj.giveTime = reader:ReadDouble()
	obj.canGiveTime = reader:ReadDouble()
	obj.needRemove = reader:ReadBoolean()
end
Auto.Reader[407] = function(reader, obj)
	setmetatable(obj, Auto.Meta[407])

	obj.Bytes = Base.ReadList(reader, function(r)
		return r:ReadByte()
	end)
end
Auto.Reader[408] = function(reader, obj)
	setmetatable(obj, Auto.Meta[408])

	obj.Id = reader:ReadString()
	obj.Count = reader:ReadUInt32()
end
Auto.Reader[409] = function(reader, obj)
	setmetatable(obj, Auto.Meta[409])

	obj.enemyInstanceId = reader:ReadUInt64()
	obj.bindItemsIndex = reader:ReadInt32()
	obj.itemRotation = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.itemPosition = Base.ReadStruct(reader, Auto.Reader.UXVector3)
end
Auto.Reader[410] = function(reader, obj)
	setmetatable(obj, Auto.Meta[410])

	obj.HasDieAnimation = reader:ReadBoolean()
	obj.HasDieEffect = reader:ReadBoolean()
	obj.DieEffectId = reader:ReadUInt32()
	obj.DelayDestroyDistance = reader:ReadSingle()
	obj.LastHitHurtEffect = reader:ReadUInt32()
	obj.DeadlySkillId = reader:ReadUInt32()
	obj.Killer = reader:ReadUInt64()
	obj.HasPlayedDeathSkill = reader:ReadBoolean()
	obj.WeaponDropDestructibleId = reader:ReadUInt64()
	obj.DieType = reader:ReadByte()
end
Auto.Reader[134] = function(reader, obj)
	setmetatable(obj, Auto.Meta[134])

	obj.BindItemsIndex = reader:ReadInt32()
	obj.Rotation = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.Position = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.DropState = reader:ReadByte()
end
Auto.Reader[411] = function(reader, obj)
	setmetatable(obj, Auto.Meta[411])

	obj.EnemyId = reader:ReadUInt64()
	obj.MoveId = reader:ReadInt32()
	obj.IsFailure = reader:ReadBoolean()
end
Auto.Reader[412] = function(reader, obj)
	setmetatable(obj, Auto.Meta[412])

	obj.Pid = reader:ReadUInt64()
	obj.IsHoldingWeapon = reader:ReadBoolean()
end
Auto.Reader[160] = function(reader, obj)
	setmetatable(obj, Auto.Meta[160])

	obj.Aid = reader:ReadInt32()
	obj.Pid = reader:ReadUInt64()
	obj.Token = Base.ReadComplex(reader, Auto.Reader[632])
end
Auto.Reader[53] = function(reader, obj)
	setmetatable(obj, Auto.Meta[53])

	obj.PlayerSessionId = reader:ReadUInt64()
	obj.RaidId = reader:ReadUInt32()
	obj.InstanceId = reader:ReadUInt64()
	obj.Position = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.Facing = reader:ReadSingle()
	obj.SpoonLevels = Base.ReadList(reader, function(r)
		return r:ReadString()
	end)
	obj.SpoonMd5s = Base.ReadList(reader, function(r)
		return r:ReadString()
	end)
	obj.Spirits = Base.ReadList(reader, function(r)
		return Base.ReadStruct(r, Auto.Reader[609])
	end)
	obj.GridInfo = Base.ReadStruct(reader, Auto.Reader[588])
	obj.MatchGameId = reader:ReadUInt32()
	obj.SwitchShowId = reader:ReadUInt32()
	obj.IsSwitchSpiritShow = reader:ReadBoolean()
	obj.SectorControlId = reader:ReadUInt32()
	obj.LoadingType = Base.ReadComplex(reader, Auto.Reader[458])
end
Auto.Reader[27] = function(reader, obj)
	setmetatable(obj, Auto.Meta[27])

	obj.Id = reader:ReadUInt32()
	obj.NpcId = reader:ReadUInt32()
	obj.EventType = reader:ReadByte()
end
Auto.Reader[39] = function(reader, obj)
	setmetatable(obj, Auto.Meta[39])

	obj.EventsInfo = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[628])
	end)
end
Auto.Reader[413] = function(reader, obj)
	setmetatable(obj, Auto.Meta[413])

	obj.EventId = reader:ReadUInt32()
	obj.Value = reader:ReadUInt32()
	obj.ProgressDict = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return r:ReadUInt32()
	end)
end
Auto.Reader[49] = function(reader, obj)
	setmetatable(obj, Auto.Meta[49])

	obj.EventProgressDict = Base.ReadDict(reader, function(r)
		return r:ReadByte()
	end, function(r)
		return Base.ReadComplex(r, Auto.Reader[413])
	end)
	obj.Value = reader:ReadUInt32()
end
Auto.Reader[40] = function(reader, obj)
	setmetatable(obj, Auto.Meta[40])

	obj.EventId = reader:ReadUInt32()
	obj.RaidId = reader:ReadUInt32()
	obj.SpoonMd5 = reader:ReadString()
end
Auto.Reader[89] = function(reader, obj)
	setmetatable(obj, Auto.Meta[89])

	obj.FactionId = reader:ReadUInt32()
	obj.NewInfo = Base.ReadComplex(reader, Auto.Reader[68])
	obj.OldInfo = Base.ReadComplex(reader, Auto.Reader[68])
end
Auto.Reader[68] = function(reader, obj)
	setmetatable(obj, Auto.Meta[68])

	obj.Disposition = reader:ReadInt32()
	obj.DispositionLevel = reader:ReadUInt32()
	obj.Influence = reader:ReadInt32()
	obj.InteractionCount = reader:ReadUInt32()
	obj.GreetCount = reader:ReadUInt32()
end
Auto.Reader[184] = function(reader, obj)
	setmetatable(obj, Auto.Meta[184])

	obj.GiveTime = reader:ReadInt32()
	obj.GiveCount = reader:ReadInt32()
	obj.Reason = reader:ReadByte()
end
Auto.Reader[414] = function(reader, obj)
	setmetatable(obj, Auto.Meta[414])

	obj.ColoringType2ColorIdDict = Base.ReadDict(reader, function(r)
		return r:ReadByte()
	end, function(r)
		return r:ReadUInt32()
	end)
end
Auto.Reader[415] = function(reader, obj)
	setmetatable(obj, Auto.Meta[415])

	obj.FashionId = reader:ReadUInt32()
	obj.FashionColoringSchemeInfoDict = Base.ReadDict(reader, function(r)
		return r:ReadByte()
	end, function(r)
		return Base.ReadComplex(r, Auto.Reader[414])
	end)
end
Auto.Reader[416] = function(reader, obj)
	setmetatable(obj, Auto.Meta[416])

	obj.SchemeName = reader:ReadString()
	obj.JoinRandomPool = reader:ReadBoolean()
	obj.WearFashionInfoList = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[193])
	end)
	obj.WearFashionEditInfoList = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[180])
	end)
	obj.HiddenParts = reader:ReadByte()
	obj.EditedHiddenParts = reader:ReadByte()
end
Auto.Reader[418] = function(reader, obj)
	setmetatable(obj, Auto.Meta[418])

	obj.WearFashionInfoList = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[193])
	end)
	obj.WearFashionEditInfoList = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[180])
	end)
	obj.HiddenParts = reader:ReadByte()
	obj.EditedHiddenParts = reader:ReadByte()
end
Auto.Reader[18] = function(reader, obj)
	setmetatable(obj, Auto.Meta[18])

	obj.FashionId = reader:ReadUInt32()
	obj.ExpiredTime = reader:ReadUInt32()
	obj.GainTime = reader:ReadUInt32()
	obj.Status = reader:ReadByte()
	obj.ApplyColoringSchemeId = reader:ReadByte()
	obj.ColoringSchemeInfoDict = Base.ReadDict(reader, function(r)
		return r:ReadByte()
	end, function(r)
		return Base.ReadComplex(r, Auto.Reader[414])
	end)
end
Auto.Reader[210] = function(reader, obj)
	setmetatable(obj, Auto.Meta[210])

	obj.WithAi = reader:ReadBoolean()
	obj.Pid = reader:ReadUInt64()
	obj.IsObserver = reader:ReadBoolean()
	obj.Is1P = reader:ReadBoolean()
	obj.IsMaster = reader:ReadBoolean()
	obj.PlayerUnitInfo = Base.ReadComplex(reader, Auto.Reader[421])
	obj.AiUnitInfo = Base.ReadComplex(reader, Auto.Reader[421])
end
Auto.Reader[419] = function(reader, obj)
	setmetatable(obj, Auto.Meta[419])

	obj.WinnerIndex = reader:ReadInt32()
	obj.RoundLeft = reader:ReadInt32()
	obj.WaitEndTime = reader:ReadUInt32()
	obj.IsWithAi = reader:ReadBoolean()
	obj.IsAiWin = reader:ReadBoolean()
	obj.IsPlayerWin = reader:ReadBoolean()
end
Auto.Reader[420] = function(reader, obj)
	setmetatable(obj, Auto.Meta[420])

	obj.Pid = reader:ReadUInt64()
	obj.PosX = reader:ReadInt32()
	obj.PosY = reader:ReadInt32()
	obj.Face = reader:ReadByte()
	obj.Hp = reader:ReadInt32()
	obj.AngryValue = reader:ReadInt32()
end
Auto.Reader[421] = function(reader, obj)
	setmetatable(obj, Auto.Meta[421])

	obj.IsAi = reader:ReadBoolean()
	obj.RoleId = reader:ReadUInt32()
	obj.Index = reader:ReadInt32()
	obj.IsReady = reader:ReadBoolean()
	obj.DeadCount = reader:ReadInt32()
	obj.CurrentAction = reader:ReadString()
	obj.State = Base.ReadComplex(reader, Auto.Reader[420])
end
Auto.Reader[422] = function(reader, obj)
	setmetatable(obj, Auto.Meta[422])

	obj.configId = reader:ReadUInt32()
	obj.uIds = Base.ReadList(reader, function(r)
		return r:ReadUInt64()
	end)
	obj.normalEdicts = Base.ReadList(reader, function(r)
		return Base.ReadStruct(r, Auto.Reader[406])
	end)
	obj.extraEdicts = Base.ReadList(reader, function(r)
		return Base.ReadStruct(r, Auto.Reader[406])
	end)
end
Auto.Reader[127] = function(reader, obj)
	setmetatable(obj, Auto.Meta[127])

	obj.IsIllusory = reader:ReadBoolean()
	obj.IsActive = reader:ReadBoolean()
	obj.PokemonId = reader:ReadUInt64()
	obj.TemplateId = reader:ReadUInt32()
	obj.Body = reader:ReadUInt32()
	obj.Camp = reader:ReadUInt32()
	obj.Weapon = reader:ReadUInt32()
	obj.UnitId = reader:ReadUInt64()
	obj.IsAlive = reader:ReadBoolean()
	obj.MaxHp = reader:ReadSingle()
	obj.Dam = reader:ReadSingle()
	obj.Def = reader:ReadSingle()
	obj.BlockRate = reader:ReadSingle()
	obj.SpecialAttRate = reader:ReadSingle()
	obj.AttackSpeed = reader:ReadSingle()
	obj.EnergyRecovery = reader:ReadSingle()
	obj.CubeCoord = Base.ReadStruct(reader, Auto.Reader[377])
	obj.BornFacing = reader:ReadSingle()
end
Auto.Reader[423] = function(reader, obj)
	setmetatable(obj, Auto.Meta[423])

	obj.FireworkId = reader:ReadUInt32()
	obj.PlanId = reader:ReadUInt32()
end
Auto.Reader[424] = function(reader, obj)
	setmetatable(obj, Auto.Meta[424])

	obj.PlanId = reader:ReadUInt32()
	obj.NewUnlock = reader:ReadBoolean()
end
Auto.Reader[174] = function(reader, obj)
	setmetatable(obj, Auto.Meta[174])

	obj.PlanInfos = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[424])
	end)
end
Auto.Reader[425] = function(reader, obj)
	setmetatable(obj, Auto.Meta[425])

	obj.FishGroupId = reader:ReadInt32()
	obj.PathId = reader:ReadInt32()
	obj.ReleaserId = reader:ReadUInt64()
	obj.Position = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.Facing = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.LivingTime = reader:ReadSingle()
end
Auto.Reader[426] = function(reader, obj)
	setmetatable(obj, Auto.Meta[426])

	obj.x = reader:ReadSingle()
	obj.y = reader:ReadSingle()
	obj.z = reader:ReadSingle()
end
Auto.Reader[427] = function(reader, obj)
	setmetatable(obj, Auto.Meta[427])

	obj.unitId = reader:ReadUInt64()
	obj.moveTime = reader:ReadSingle()
	obj.speed = reader:ReadSingle()
	obj.targetPos = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.moveId = reader:ReadInt32()
	obj.speedCurveId = reader:ReadUInt32()
	obj.targetId = reader:ReadUInt64()
end
Auto.Reader[428] = function(reader, obj)
	setmetatable(obj, Auto.Meta[428])

	obj.PathId = reader:ReadUInt32()
	obj.FollowType = reader:ReadByte()
	obj.recordingFileName = reader:ReadString()
	obj.TargetType = reader:ReadByte()
	obj.TargetUid = reader:ReadUInt64()
	obj.Step = reader:ReadSingle()
	obj.MinSpeed = reader:ReadSingle()
	obj.MaxSpeed = reader:ReadSingle()
	obj.FarAwayCheck = reader:ReadBoolean()
	obj.FarAwayThrehold = reader:ReadSingle()
	obj.CloseToCheck = reader:ReadBoolean()
	obj.CloseToThrehold = reader:ReadSingle()
	obj.AdjustTime = reader:ReadSingle()
	obj.PathOffset = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.guideMinDistance = reader:ReadSingle()
	obj.guideMaxDistance = reader:ReadSingle()
	obj.guideMinSpeedThreshold = reader:ReadSingle()
	obj.guideMaxSpeedThreshold = reader:ReadSingle()
	obj.CheckStuckTime = reader:ReadSingle()
	obj.Token = reader:ReadUInt64()
	obj.taskAIConfigId = reader:ReadUInt32()
	obj.defaultSpeed = reader:ReadSingle()
	obj.drivingFlags = reader:ReadInt32()
	obj.initSpeed = reader:ReadSingle()
	obj.initTaskAIBuffList = Base.ReadList(reader, function(r)
		return Base.ReadStruct(r, Auto.Reader[629])
	end)
	obj.commonParameters = Base.ReadStruct(reader, Auto.Reader[650])
end
Auto.Reader[429] = function(reader, obj)
	setmetatable(obj, Auto.Meta[429])

	obj.Row = reader:ReadInt32()
	obj.Col = reader:ReadInt32()
end
Auto.Reader[430] = function(reader, obj)
	setmetatable(obj, Auto.Meta[430])

	obj.IsRejectAllFriendApply = reader:ReadBoolean()
	obj.BlackList = Base.ReadList(reader, function(r)
		return r:ReadUInt64()
	end)
	obj.FriendRelationList = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[572])
	end)
	obj.SpecialList = Base.ReadList(reader, function(r)
		return r:ReadUInt64()
	end)
end
Auto.Reader[94] = function(reader, obj)
	setmetatable(obj, Auto.Meta[94])

	obj.FurnitureId = reader:ReadUInt32()
	obj.Count = reader:ReadUInt32()
	obj.PlacedCount = reader:ReadUInt32()
end
Auto.Reader[431] = function(reader, obj)
	setmetatable(obj, Auto.Meta[431])

	obj.GadgetInstanceId = reader:ReadUInt64()
	obj.InstanceId = reader:ReadUInt64()
	obj.UniqueId = reader:ReadUInt64()
	obj.CfgId = reader:ReadUInt32()
	obj.PathId = reader:ReadInt32()
	obj.Position = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.Facing = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.iScale = reader:ReadInt32()
	obj.Hp = reader:ReadSingle()
	obj.NavId = reader:ReadInt32()
	obj.State = reader:ReadByte()
	obj.BreakStage = reader:ReadUInt32()
	obj.OccupantInfos = Base.ReadList(reader, function(r)
		return Base.ReadStruct(r, Auto.Reader[583])
	end)
	obj.DropWeaponId = reader:ReadUInt64()
	obj.EffectIds = Base.ReadList(reader, function(r)
		return r:ReadInt32()
	end)
end
Auto.Reader[432] = function(reader, obj)
	setmetatable(obj, Auto.Meta[432])

	obj.InstanceId = reader:ReadUInt64()
	obj.Position = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.Facing = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.StateIndexDic = Base.ReadDict(reader, function(r)
		return r:ReadInt32()
	end, function(r)
		return r:ReadInt32()
	end)
	obj.ValueIndexDic = Base.ReadDict(reader, function(r)
		return r:ReadInt32()
	end, function(r)
		return r:ReadString()
	end)
	obj.Occupants = Base.ReadList(reader, function(r)
		return r:ReadUInt64()
	end)
	obj.OccupantInfos = Base.ReadList(reader, function(r)
		return Base.ReadStruct(r, Auto.Reader[583])
	end)
	obj.LinkOccupiedId = reader:ReadUInt32()
	obj.MetroLineId = reader:ReadUInt32()
	obj.MetroCarriageId = reader:ReadUInt32()
	obj.NavId = reader:ReadInt32()
	obj.MetroLineCarriageInfo = Base.ReadComplex(reader, Auto.Reader[477])
	obj.SymbiosisGadgets = Base.ReadDict(reader, function(r)
		return r:ReadUInt64()
	end, function(r)
		return r:ReadUInt64()
	end)
	obj.SymbiosisDestructibles = Base.ReadDict(reader, function(r)
		return r:ReadUInt64()
	end, function(r)
		return r:ReadUInt64()
	end)
	obj.Pack = Base.ReadComplex(reader, Auto.Reader[502])
	obj.MobilePlatformInfo = Base.ReadComplex(reader, Auto.Reader[140])
end
Auto.Reader[433] = function(reader, obj)
	setmetatable(obj, Auto.Meta[433])

	obj.addInfos = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[432])
	end)
	obj.indexList = Base.ReadList(reader, function(r)
		return Base.ReadStruct(r, Auto.Reader[446])
	end)
	obj.addUniqueIds = Base.ReadList(reader, function(r)
		return r:ReadUInt64()
	end)
	obj.removeIds = Base.ReadList(reader, function(r)
		return r:ReadUInt64()
	end)
	obj.activeIds = Base.ReadList(reader, function(r)
		return r:ReadUInt64()
	end)
	obj.inactiveIds = Base.ReadList(reader, function(r)
		return r:ReadUInt64()
	end)
	obj.reason = reader:ReadByte()
end
Auto.Reader[434] = function(reader, obj)
	setmetatable(obj, Auto.Meta[434])

	obj.InstanceId = reader:ReadUInt64()
	obj.PackedInfo = Base.ReadComplex(reader, Auto.Reader[502])
	obj.SymbiosisDestructibles = Base.ReadDict(reader, function(r)
		return r:ReadUInt64()
	end, function(r)
		return r:ReadUInt64()
	end)
end
Auto.Reader[103] = function(reader, obj)
	setmetatable(obj, Auto.Meta[103])

	obj.Pid = reader:ReadUInt64()
	obj.NpcCultivationId = reader:ReadUInt32()
	obj.AgentUId = reader:ReadUInt64()
	obj.SeatIndex = reader:ReadInt32()
	obj.IsReady = reader:ReadBoolean()
	obj.IsPlayAgain = reader:ReadBoolean()
end
Auto.Reader[115] = function(reader, obj)
	setmetatable(obj, Auto.Meta[115])

	obj.GadgetUId = reader:ReadUInt64()
	obj.StartReason = reader:ReadByte()
	obj.SyncReason = reader:ReadByte()
	obj.ZoneType = reader:ReadByte()
	obj.ZoneState = reader:ReadByte()
	obj.ParticipantInfos = Base.ReadList(reader, Auto.Dispatch[103])
end
Auto.Reader[435] = function(reader, obj)
	setmetatable(obj, Auto.Meta[435])

	obj.ClientListenIp = reader:ReadString()
	obj.ClientListenPort = reader:ReadInt32()
	obj.Token = reader:ReadString()
end
Auto.Reader[63] = function(reader, obj)
	setmetatable(obj, Auto.Meta[63])

	obj.full = Base.ReadComplex(reader, Auto.Reader[536])
	obj.CurrentBattleAgentCount = reader:ReadInt32()
end
Auto.Reader[82] = function(reader, obj)
	setmetatable(obj, Auto.Meta[82])

	obj.TemplateId = reader:ReadUInt32()
	obj.IsUnlock = reader:ReadBoolean()
	obj.NextReviveTimeStamp = reader:ReadDouble()
	obj.InstanceId = reader:ReadUInt64()
	obj.HpPercent = reader:ReadSingle()
end
Auto.Reader[436] = function(reader, obj)
	setmetatable(obj, Auto.Meta[436])

	obj.Key = reader:ReadString()
	obj.Value = reader:ReadString()
end
Auto.Reader[437] = function(reader, obj)
	setmetatable(obj, Auto.Meta[437])

	obj.ActionId = reader:ReadUInt32()
end
Auto.Reader[438] = function(reader, obj)
	setmetatable(obj, Auto.Meta[438])

	obj.AgentId = reader:ReadUInt32()
	obj.UrbanDiversityId = reader:ReadUInt32()
	obj.Personality = reader:ReadUInt32()
	obj.SexType = reader:ReadUInt32()
	obj.Usages = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
	obj.Crimes = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
end
Auto.Reader[211] = function(reader, obj)
	setmetatable(obj, Auto.Meta[211])

	obj.SkillIds = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
end
Auto.Reader[212] = function(reader, obj)
	setmetatable(obj, Auto.Meta[212])

	obj.AiName = reader:ReadString()
	obj.Radius = reader:ReadSingle()
	obj.BackRadius = reader:ReadSingle()
	obj.LookUpAngle = reader:ReadSingle()
	obj.LookDownAngle = reader:ReadSingle()
	obj.EyeHeight = reader:ReadSingle()
end
Auto.Reader[439] = function(reader, obj)
	setmetatable(obj, Auto.Meta[439])

	obj.Id = reader:ReadInt32()
	obj.Name = reader:ReadString()
	obj.IsActive = reader:ReadBoolean()
	obj.IsStatic = reader:ReadBoolean()
	obj.Position = reader:ReadString()
	obj.LocalPosition = reader:ReadString()
	obj.Rotation = reader:ReadString()
	obj.LocalRotation = reader:ReadString()
	obj.Scale = reader:ReadString()
	obj.LocalScale = reader:ReadString()
	obj.Path = reader:ReadString()
	obj.Layer = reader:ReadString()
	obj.Components = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[559])
	end)
end
Auto.Reader[440] = function(reader, obj)
	setmetatable(obj, Auto.Meta[440])

	obj.Name = reader:ReadString()
	obj.Objects = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[441])
	end)
end
Auto.Reader[441] = function(reader, obj)
	setmetatable(obj, Auto.Meta[441])

	obj.Id = reader:ReadInt32()
	obj.Name = reader:ReadString()
	obj.IsActive = reader:ReadBoolean()
	obj.Leaf = reader:ReadBoolean()
end
Auto.Reader[442] = function(reader, obj)
	setmetatable(obj, Auto.Meta[442])

	obj.Pid = reader:ReadUInt64()
	obj.NpcCultivationId = reader:ReadUInt32()
	obj.AgentUId = reader:ReadUInt64()
	obj.SeatIndex = reader:ReadInt32()
	obj.IsReady = reader:ReadBoolean()
	obj.IsPlayAgain = reader:ReadBoolean()
end
Auto.Reader[443] = function(reader, obj)
	setmetatable(obj, Auto.Meta[443])

	obj.RecordInfo = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[102])
	end)
end
Auto.Reader[102] = function(reader, obj)
	setmetatable(obj, Auto.Meta[102])

	obj.X = reader:ReadUInt32()
	obj.Y = reader:ReadUInt32()
end
Auto.Reader[123] = function(reader, obj)
	setmetatable(obj, Auto.Meta[123])

	obj.GomokuParticipantDict = Base.ReadDict(reader, function(r)
		return r:ReadInt32()
	end, function(r)
		return Base.ReadComplex(r, Auto.Reader[443])
	end)
	obj.Winner = reader:ReadInt32()
end
Auto.Reader[444] = function(reader, obj)
	setmetatable(obj, Auto.Meta[444])

	obj.GameType = reader:ReadByte()
	obj.CurrentRound = reader:ReadUInt32()
	obj.CurrentTurn = reader:ReadInt32()
	obj.ScoreInfo = Base.ReadComplex(reader, Auto.Reader[123])
	obj.GadgetUId = reader:ReadUInt64()
	obj.StartReason = reader:ReadByte()
	obj.SyncReason = reader:ReadByte()
	obj.ZoneType = reader:ReadByte()
	obj.ZoneState = reader:ReadByte()
	obj.ParticipantInfos = Base.ReadList(reader, Auto.Dispatch[103])
end
Auto.Reader[445] = function(reader, obj)
	setmetatable(obj, Auto.Meta[445])

	obj.SectorIdList = Base.ReadList(reader, function(r)
		return r:ReadInt32()
	end)
	obj.StandardIndexList = Base.ReadList(reader, function(r)
		return Base.ReadStruct(r, Auto.Reader[446])
	end)
	obj.ExceptIds = Base.ReadList(reader, function(r)
		return r:ReadUInt64()
	end)
end
Auto.Reader[446] = function(reader, obj)
	setmetatable(obj, Auto.Meta[446])

	obj.X = reader:ReadInt32()
	obj.Z = reader:ReadInt32()
end
Auto.Reader[447] = function(reader, obj)
	setmetatable(obj, Auto.Meta[447])

	obj.Level = reader:ReadByte()
	obj.ExerciseId = reader:ReadUInt32()
	obj.Score = reader:ReadSingle()
end
Auto.Reader[19] = function(reader, obj)
	setmetatable(obj, Auto.Meta[19])

	obj.BatteryTotalCount = reader:ReadUInt32()
	obj.BatteryCurrentCount = reader:ReadUInt32()
end
Auto.Reader[448] = function(reader, obj)
	setmetatable(obj, Auto.Meta[448])

	obj.Id = reader:ReadUInt32()
	obj.State = reader:ReadByte()
	obj.HaveRead = reader:ReadBoolean()
end
Auto.Reader[449] = function(reader, obj)
	setmetatable(obj, Auto.Meta[449])

	obj.TargetId = reader:ReadUInt64()
	obj.HitPredictId = reader:ReadInt32()
	obj.PredictorId = reader:ReadUInt64()
end
Auto.Reader[52] = function(reader, obj)
	setmetatable(obj, Auto.Meta[52])

	obj.HouseId = reader:ReadUInt32()
	obj.ParkingSpaceVehicleIdDict = Base.ReadDict(reader, function(r)
		return r:ReadInt32()
	end, function(r)
		return r:ReadUInt32()
	end)
	obj.FloorBuildInfoDict = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return Base.ReadComplex(r, Auto.Reader[452])
	end)
	obj.CurPlacedFurnitureInstanceId = reader:ReadUInt64()
end
Auto.Reader[450] = function(reader, obj)
	setmetatable(obj, Auto.Meta[450])

	obj.VehicleId = reader:ReadUInt32()
	obj.HouseId = reader:ReadUInt32()
	obj.ParkingSpaceIndex = reader:ReadInt32()
end
Auto.Reader[451] = function(reader, obj)
	setmetatable(obj, Auto.Meta[451])

	obj.HouseId = reader:ReadUInt32()
	obj.VehicleId = reader:ReadUInt32()
end
Auto.Reader[8] = function(reader, obj)
	setmetatable(obj, Auto.Meta[8])

	obj.HouseId = reader:ReadUInt32()
	obj.VehicleId = reader:ReadUInt32()
	obj.ParkingSpaceIndex = reader:ReadInt32()
end
Auto.Reader[201] = function(reader, obj)
	setmetatable(obj, Auto.Meta[201])

	obj.HouseInfoList = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[52])
	end)
	obj.NotParkingSpaceVehicleIdList = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
	obj.FurnitureInfoDict = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return Base.ReadComplex(r, Auto.Reader[94])
	end)
end
Auto.Reader[150] = function(reader, obj)
	setmetatable(obj, Auto.Meta[150])

	obj.ChatGroupList = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[152])
	end)
	obj.MuteEndTime = reader:ReadUInt32()
	obj.SoftMuteEndTime = reader:ReadUInt32()
end
Auto.Reader[452] = function(reader, obj)
	setmetatable(obj, Auto.Meta[452])

	obj.Root = Base.ReadComplex(reader, Auto.Reader[95])
end
Auto.Reader[453] = function(reader, obj)
	setmetatable(obj, Auto.Meta[453])

	obj.CmdType = reader:ReadUInt32()
	obj.sender = reader:ReadUInt64()
	obj.receiver = reader:ReadUInt64()
	obj.CommandData = Base.ReadList(reader, function(r)
		return r:ReadByte()
	end)
	obj.CommandDataLen = reader:ReadInt32()
end
Auto.Reader[454] = function(reader, obj)
	setmetatable(obj, Auto.Meta[454])

	obj.TemplateId = reader:ReadUInt32()
	obj.Count = reader:ReadUInt32()
end
Auto.Reader[61] = function(reader, obj)
	setmetatable(obj, Auto.Meta[61])

	obj.ItemId = reader:ReadUInt32()
	obj.Count = reader:ReadUInt32()
	obj.NextRefreshTime = reader:ReadUInt32()
end
Auto.Reader[455] = function(reader, obj)
	setmetatable(obj, Auto.Meta[455])

	obj.DesTemplateId = reader:ReadUInt32()
	obj.PathId = reader:ReadInt32()
	obj.ReleaserId = reader:ReadUInt64()
	obj.Position = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.Facing = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.LivingTime = reader:ReadSingle()
end
Auto.Reader[58] = function(reader, obj)
	setmetatable(obj, Auto.Meta[58])

	obj.UniqueId = reader:ReadUInt64()
	obj.TemplateId = reader:ReadUInt32()
end
Auto.Reader[456] = function(reader, obj)
	setmetatable(obj, Auto.Meta[456])

	obj.dialogId = reader:ReadUInt32()
	obj.distance = reader:ReadSingle()
	obj.minDuration = reader:ReadSingle()
end
Auto.Reader[175] = function(reader, obj)
	setmetatable(obj, Auto.Meta[175])

	obj.Id = reader:ReadUInt64()
	obj.Mode = reader:ReadByte()
	obj.DeviceLevel = reader:ReadByte()
	obj.Members = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[6])
	end)
end
Auto.Reader[130] = function(reader, obj)
	setmetatable(obj, Auto.Meta[130])

	obj.Pid = reader:ReadUInt64()
	obj.Level = reader:ReadUInt32()
	obj.Index = reader:ReadInt32()
	obj.InTime = reader:ReadUInt32()
	obj.OutTime = reader:ReadUInt32()
	obj.TempLeave = reader:ReadByte()
	obj.IsPSNPlayer = reader:ReadBoolean()
end
Auto.Reader[457] = function(reader, obj)
	setmetatable(obj, Auto.Meta[457])

	obj.TemplateId = reader:ReadUInt32()
	obj.LeftTimes = reader:ReadUInt32()
end
Auto.Reader[458] = function(reader, obj)
	setmetatable(obj, Auto.Meta[458])

	obj.Type = reader:ReadByte()
	obj.Members = Base.ReadList(reader, function(r)
		return r:ReadUInt64()
	end)
end
Auto.Reader[459] = function(reader, obj)
	setmetatable(obj, Auto.Meta[459])

	obj.Id = reader:ReadUInt64()
	obj.FineId = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
	obj.Position = Base.ReadStruct(reader, Auto.Reader.UXVector3)
end
Auto.Reader[460] = function(reader, obj)
	setmetatable(obj, Auto.Meta[460])

	obj.Position = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.Speed = reader:ReadSingle()
	obj.ActionId = reader:ReadUInt32()
	obj.IsImmediate = reader:ReadBoolean()
	obj.Uid = reader:ReadUInt64()
	obj.MaxTime = reader:ReadSingle()
	obj.ActionUid = reader:ReadUInt32()
end
Auto.Reader[462] = function(reader, obj)
	setmetatable(obj, Auto.Meta[462])

	obj.ActionId = reader:ReadUInt32()
	obj.Speed = reader:ReadSingle()
	obj.IsImmediate = reader:ReadBoolean()
	obj.Uid = reader:ReadUInt64()
	obj.MaxTime = reader:ReadSingle()
	obj.ActionUid = reader:ReadUInt32()
end
Auto.Reader[148] = function(reader, obj)
	setmetatable(obj, Auto.Meta[148])

	obj.GameState = reader:ReadByte()
	obj.Round = reader:ReadInt32()
	obj.Remainders = reader:ReadInt32()
	obj.Banker = reader:ReadInt32()
	obj.Turn = reader:ReadInt32()
	obj.LastTurn = reader:ReadInt32()
	obj.LastMoPaiSeatIndex = reader:ReadInt32()
	obj.SeatInfos = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[585])
	end)
	obj.HuPais = Base.ReadList(reader, function(r)
		return Base.ReadStruct(r, Auto.Reader[145])
	end)
	obj.DoraIndicatorLs = Base.ReadList(reader, function(r)
		return Base.ReadStruct(r, Auto.Reader[145])
	end)
	obj.DoraLs = Base.ReadList(reader, function(r)
		return Base.ReadStruct(r, Auto.Reader[145])
	end)
	obj.UraDoraIndicatorLs = Base.ReadList(reader, function(r)
		return Base.ReadStruct(r, Auto.Reader[145])
	end)
	obj.UraDoraLs = Base.ReadList(reader, function(r)
		return Base.ReadStruct(r, Auto.Reader[145])
	end)
end
Auto.Reader[149] = function(reader, obj)
	setmetatable(obj, Auto.Meta[149])

	obj.Pid = reader:ReadUInt64()
	obj.Aid = reader:ReadInt32()
	obj.Level = reader:ReadUInt32()
	obj.Name = reader:ReadString()
	obj.PzHeadInfo = Base.ReadComplex(reader, Auto.Reader[509])
	obj.Score = reader:ReadInt32()
	obj.SeatIndex = reader:ReadInt32()
	obj.NpcMahjongId = reader:ReadUInt32()
	obj.NpcCultivationId = reader:ReadUInt32()
end
Auto.Reader[144] = function(reader, obj)
	setmetatable(obj, Auto.Meta[144])

	obj.MahjongServerId = reader:ReadInt32()
	obj.RoomId = reader:ReadUInt64()
	obj.RoomType = reader:ReadByte()
	obj.State = reader:ReadByte()
	obj.PlayerInfos = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[149])
	end)
	obj.HasReady = Base.ReadList(reader, function(r)
		return r:ReadBoolean()
	end)
	obj.RoomOwnerSeatIndex = reader:ReadInt32()
end
Auto.Reader[463] = function(reader, obj)
	setmetatable(obj, Auto.Meta[463])

	obj.Choices = Base.ReadList(reader, function(r)
		return r:ReadInt32()
	end)
end
Auto.Reader[207] = function(reader, obj)
	setmetatable(obj, Auto.Meta[207])

	obj.VisitTimes = reader:ReadUInt32()
	obj.UnlockDrinks = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
end
Auto.Reader[464] = function(reader, obj)
	setmetatable(obj, Auto.Meta[464])

	obj.Items = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[454])
	end)
	obj.UnbindMoney = reader:ReadInt32()
	obj.BindGold = reader:ReadUInt32()
	obj.PayGold = reader:ReadUInt32()
	obj.FreeGold = reader:ReadUInt32()
	obj.Exp = reader:ReadUInt32()
	obj.Popularity = reader:ReadSingle()
	obj.JobExpInfo = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return r:ReadUInt32()
	end)
	obj.FanInfo = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return r:ReadInt32()
	end)
	obj.FactionDispositionInfo = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return r:ReadInt32()
	end)
	obj.FactionInfluenceInfo = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return r:ReadInt32()
	end)
	obj.AbilityExpInfo = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return r:ReadUInt32()
	end)
	obj.SpiritTalentExpInfo = Base.ReadComplex(reader, Auto.Reader[613])
	obj.CommonSpiritTalentExp = reader:ReadUInt32()
end
Auto.Reader[151] = function(reader, obj)
	setmetatable(obj, Auto.Meta[151])

	obj.Id = reader:ReadUInt64()
	obj.MailId = reader:ReadUInt32()
	obj.CreateTime = reader:ReadUInt32()
	obj.ExpireTime = reader:ReadUInt32()
	obj.Title = reader:ReadString()
	obj.TitleParams = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[135])
	end)
	obj.SenderName = reader:ReadString()
	obj.IsGlobal = reader:ReadBoolean()
	obj.HasItem = reader:ReadBoolean()
	obj.Attachment = Base.ReadComplex(reader, Auto.Reader[590])
	obj.IsFavorite = reader:ReadBoolean()
	obj.IsRetrieved = reader:ReadBoolean()
	obj.Tab = reader:ReadInt32()
end
Auto.Reader[178] = function(reader, obj)
	setmetatable(obj, Auto.Meta[178])

	obj.Id = reader:ReadUInt64()
	obj.Reason = reader:ReadInt32()
	obj.CreateTime = reader:ReadUInt32()
	obj.IsGlobal = reader:ReadBoolean()
	obj.SenderName = reader:ReadString()
	obj.Title = reader:ReadString()
	obj.TitleParams = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[135])
	end)
	obj.Content = reader:ReadString()
	obj.ContentParams = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[135])
	end)
	obj.RewardTemplateId = reader:ReadUInt32()
	obj.MailId = reader:ReadUInt32()
	obj.JsonAttachment = reader:ReadString()
	obj.Attachment = Base.ReadComplex(reader, Auto.Reader[464])
	obj.HasAttachment = reader:ReadBoolean()
	obj.Tag = reader:ReadInt32()
	obj.IsRetrieved = reader:ReadBoolean()
	obj.IsFavorite = reader:ReadBoolean()
	obj.GlobalMailVersion = reader:ReadUInt64()
	obj.ReceiveTime = reader:ReadUInt32()
	obj.ExpireTime = reader:ReadUInt32()
	obj.IsExpireTimeAt = reader:ReadBoolean()
	obj.ExpireTimeOffline = reader:ReadUInt32()
	obj.IncludePlayerAfterSend = reader:ReadBoolean()
	obj.Platforms = Base.ReadList(reader, function(r)
		return r:ReadInt32()
	end)
end
Auto.Reader[135] = function(reader, obj)
	setmetatable(obj, Auto.Meta[135])

	obj.ParamType = reader:ReadByte()
	obj.Data = reader:ReadString()
end
Auto.Reader[465] = function(reader, obj)
	setmetatable(obj, Auto.Meta[465])

	obj.BoughtCount = reader:ReadUInt32()
	obj.NextRefreshTime = reader:ReadUInt32()
end
Auto.Reader[466] = function(reader, obj)
	setmetatable(obj, Auto.Meta[466])

	obj.CommodityInfoDict = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return Base.ReadComplex(r, Auto.Reader[465])
	end)
	obj.MonthCardInfo = Base.ReadComplex(reader, Auto.Reader[542])
	obj.CommoditySpiritDisplayPreferencesList = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
end
Auto.Reader[467] = function(reader, obj)
	setmetatable(obj, Auto.Meta[467])

	obj.RaidId = reader:ReadUInt32()
	obj.Position = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.Type = reader:ReadByte()
end
Auto.Reader[468] = function(reader, obj)
	setmetatable(obj, Auto.Meta[468])

	obj.Uid = reader:ReadInt32()
	obj.Hide = reader:ReadBoolean()
	obj.Points = Base.ReadList(reader, function(r)
		return Base.ReadStruct(r, Auto.Reader.UXVector3)
	end)
	obj.HideType = reader:ReadInt32()
end
Auto.Reader[469] = function(reader, obj)
	setmetatable(obj, Auto.Meta[469])

	obj.TrafficLightStateFlags = reader:ReadByte()
end
Auto.Reader[470] = function(reader, obj)
	setmetatable(obj, Auto.Meta[470])

	obj.SpawnLaneSelector = Base.ReadList(reader, function(r)
		return Base.ReadStruct(r, Auto.Reader[602])
	end)
	obj.Uid = reader:ReadUInt32()
	obj.UseCustomizedSeed = reader:ReadBoolean()
	obj.Seed = reader:ReadUInt32()
	obj.UseIntervalBetweenLanes = reader:ReadBoolean()
	obj.MinSpawnInterval = reader:ReadSingle()
	obj.MaxSpawnInterval = reader:ReadSingle()
	obj.SpawnVehicleContinuously = reader:ReadBoolean()
	obj.FilledWithVehicleAtStart = reader:ReadBoolean()
	obj.RemoveVehicleWhenOutOfArea = reader:ReadBoolean()
	obj.UseSameVelocityConfig = reader:ReadBoolean()
	obj.MinVehicleSpeed = reader:ReadSingle()
	obj.MaxVehicleSpeed = reader:ReadSingle()
	obj.UseCustomizedVehicle = reader:ReadBoolean()
end
Auto.Reader[471] = function(reader, obj)
	setmetatable(obj, Auto.Meta[471])

	obj.ClearAllNormalVehicles = reader:ReadBoolean()
	obj.TrafficSpawnAreas = Base.ReadList(reader, function(r)
		return Base.ReadStruct(r, Auto.Reader[601])
	end)
end
Auto.Reader[104] = function(reader, obj)
	setmetatable(obj, Auto.Meta[104])

	obj.Pid = reader:ReadUInt64()
	obj.Name = reader:ReadString()
	obj.SpiritId = reader:ReadUInt32()
	obj.VehicleId = reader:ReadUInt32()
	obj.ElapsedTime = reader:ReadDouble()
	obj.Result = reader:ReadByte()
end
Auto.Reader[155] = function(reader, obj)
	setmetatable(obj, Auto.Meta[155])

	obj.VehicleId = reader:ReadUInt32()
	obj.Fashion = Base.ReadComplex(reader, Auto.Reader[129])
	obj.SpiritId = reader:ReadUInt32()
	obj.PoseId = reader:ReadUInt32()
	obj.LinkPlanningBoardPutInKeys = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[454])
	end)
end
Auto.Reader[15] = function(reader, obj)
	setmetatable(obj, Auto.Meta[15])

	obj.TeamRooms = Base.ReadList(reader, function(r)
		return r:ReadUInt64()
	end)
	obj.PlayAgainMembers = Base.ReadList(reader, function(r)
		return r:ReadUInt64()
	end)
	obj.ConfirmMembers = Base.ReadList(reader, function(r)
		return r:ReadUInt64()
	end)
	obj.ReadyMembers = Base.ReadList(reader, function(r)
		return r:ReadUInt64()
	end)
	obj.ConfirmStartTime = reader:ReadUInt32()
	obj.PrepareStartTime = reader:ReadUInt32()
	obj.GameStartTime = reader:ReadUInt32()
	obj.PrepareInfos = Base.ReadDict(reader, function(r)
		return r:ReadUInt64()
	end, function(r)
		return Base.ReadComplex(r, Auto.Reader[155])
	end)
	obj.MemberLeave = reader:ReadBoolean()
	obj.PlayerSwapInfos = Base.ReadDict(reader, function(r)
		return r:ReadUInt64()
	end, function(r)
		return Base.ReadComplex(r, Auto.Reader[472])
	end)
	obj.IsFreeWorldBattle = reader:ReadBoolean()
	obj.GadgetId = reader:ReadUInt64()
	obj.SceneId = reader:ReadUInt64()
	obj.LeaveToTeam = reader:ReadUInt64()
	obj.LeaveToTeamLeader = reader:ReadUInt64()
	obj.State = reader:ReadByte()
	obj.Id = reader:ReadUInt64()
	obj.GameId = reader:ReadUInt32()
	obj.LeaderPid = reader:ReadUInt64()
	obj.Members = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[473])
	end)
	obj.LastMemberUpdateTime = reader:ReadUInt32()
	obj.ByMatch = reader:ReadBoolean()
	obj.PSNOnly = reader:ReadBoolean()
end
Auto.Reader[153] = function(reader, obj)
	setmetatable(obj, Auto.Meta[153])

	obj.SourcePid = reader:ReadUInt64()
	obj.SourceDuty = reader:ReadUInt32()
	obj.TargetPid = reader:ReadUInt64()
	obj.TargetDuty = reader:ReadUInt32()
end
Auto.Reader[472] = function(reader, obj)
	setmetatable(obj, Auto.Meta[472])

	obj.SwapInfos = Base.ReadDict(reader, function(r)
		return r:ReadUInt64()
	end, function(r)
		return Base.ReadComplex(r, Auto.Reader[153])
	end)
end
Auto.Reader[164] = function(reader, obj)
	setmetatable(obj, Auto.Meta[164])

	obj.Id = reader:ReadUInt64()
	obj.GameId = reader:ReadUInt32()
	obj.LeaderPid = reader:ReadUInt64()
	obj.Members = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[473])
	end)
	obj.LastMemberUpdateTime = reader:ReadUInt32()
	obj.ByMatch = reader:ReadBoolean()
	obj.PSNOnly = reader:ReadBoolean()
end
Auto.Reader[473] = function(reader, obj)
	setmetatable(obj, Auto.Meta[473])

	obj.Pid = reader:ReadUInt64()
	obj.MatchForbidDueTime = reader:ReadUInt32()
	obj.Duty = reader:ReadUInt32()
	obj.FromMode = reader:ReadByte()
	obj.DeviceLevel = reader:ReadByte()
	obj.FromRaidId = reader:ReadUInt32()
	obj.FromSceneInstanceId = reader:ReadUInt64()
	obj.Blacklist = Base.ReadList(reader, function(r)
		return r:ReadUInt64()
	end)
end
Auto.Reader[156] = function(reader, obj)
	setmetatable(obj, Auto.Meta[156])

	obj.AllowNonLeaderInvite = reader:ReadBoolean()
end
Auto.Reader[154] = function(reader, obj)
	setmetatable(obj, Auto.Meta[154])

	obj.MatchStartTime = reader:ReadUInt32()
	obj.matchingFactor = Base.ReadComplex(reader, Auto.Reader[474])
	obj.InMatch = reader:ReadBoolean()
	obj.Single = reader:ReadBoolean()
	obj.Setting = Base.ReadComplex(reader, Auto.Reader[156])
	obj.Id = reader:ReadUInt64()
	obj.GameId = reader:ReadUInt32()
	obj.LeaderPid = reader:ReadUInt64()
	obj.Members = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[473])
	end)
	obj.LastMemberUpdateTime = reader:ReadUInt32()
	obj.ByMatch = reader:ReadBoolean()
	obj.PSNOnly = reader:ReadBoolean()
end
Auto.Reader[474] = function(reader, obj)
	setmetatable(obj, Auto.Meta[474])

	obj.Blacklist = Base.ReadList(reader, function(r)
		return r:ReadUInt64()
	end)
	obj.deviceLevelWeight = reader:ReadDouble()
	obj.Score = reader:ReadDouble()
end
Auto.Reader[87] = function(reader, obj)
	setmetatable(obj, Auto.Meta[87])

	obj.TaskId = reader:ReadUInt32()
	obj.SpiritId = reader:ReadUInt32()
end
Auto.Reader[206] = function(reader, obj)
	setmetatable(obj, Auto.Meta[206])

	obj.InnerGadgetIds = Base.ReadList(reader, function(r)
		return r:ReadUInt64()
	end)
	obj.OuterGadgetIds = Base.ReadList(reader, function(r)
		return r:ReadUInt64()
	end)
end
Auto.Reader[143] = function(reader, obj)
	setmetatable(obj, Auto.Meta[143])

	obj.Id = reader:ReadInt32()
	obj.LineId = reader:ReadUInt32()
	obj.ElapsedTime = reader:ReadSingle()
	obj.IsFinalTrain = reader:ReadBoolean()
end
Auto.Reader[475] = function(reader, obj)
	setmetatable(obj, Auto.Meta[475])

	obj.Uid = reader:ReadInt32()
	obj.Hide = reader:ReadBoolean()
	obj.Center = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.Radius = reader:ReadSingle()
end
Auto.Reader[476] = function(reader, obj)
	setmetatable(obj, Auto.Meta[476])

	obj.MetroId = reader:ReadInt32()
	obj.TargetId = reader:ReadUInt64()
	obj.Speed = reader:ReadSingle()
	obj.HurtEffectId = reader:ReadUInt32()
	obj.HurtStiffId = reader:ReadUInt32()
end
Auto.Reader[477] = function(reader, obj)
	setmetatable(obj, Auto.Meta[477])

	obj.MetroLineId = reader:ReadUInt32()
	obj.MetroCarriageId = reader:ReadUInt32()
end
Auto.Reader[185] = function(reader, obj)
	setmetatable(obj, Auto.Meta[185])

	obj.Topics = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
	obj.FinishedFlag = reader:ReadInt32()
end
Auto.Reader[478] = function(reader, obj)
	setmetatable(obj, Auto.Meta[478])

	obj.MiniGame_Bee = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
end
Auto.Reader[479] = function(reader, obj)
	setmetatable(obj, Auto.Meta[479])

	obj.Type = reader:ReadByte()
	obj.Owner = reader:ReadInt32()
	obj.Targets = Base.ReadList(reader, function(r)
		return r:ReadInt32()
	end)
	obj.Score = reader:ReadInt32()
	obj.IsZhuanYi = reader:ReadBoolean()
	obj.BaseFan = reader:ReadInt32()
	obj.Pattern = reader:ReadByte()
	obj.Patterns = Base.ReadList(reader, function(r)
		return r:ReadByte()
	end)
	obj.Pai = Base.ReadStruct(reader, Auto.Reader[145])
	obj.NumOfGen = reader:ReadInt32()
	obj.HuAction = reader:ReadInt32()
	obj.Fan = reader:ReadInt32()
end
Auto.Reader[147] = function(reader, obj)
	setmetatable(obj, Auto.Meta[147])

	obj.Pai = Base.ReadStruct(reader, Auto.Reader[145])
	obj.CanHu = reader:ReadBoolean()
	obj.CanReach = reader:ReadBoolean()
	obj.CanPeng = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[480])
	end)
	obj.CanChi = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[480])
	end)
	obj.CanGang = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[480])
	end)
	obj.CanChuPai = reader:ReadBoolean()
end
Auto.Reader[480] = function(reader, obj)
	setmetatable(obj, Auto.Meta[480])

	obj.Source = reader:ReadInt32()
	obj.Pai = Base.ReadStruct(reader, Auto.Reader[145])
	obj.SelectPais = Base.ReadList(reader, function(r)
		return Base.ReadStruct(r, Auto.Reader[145])
	end)
	obj.PCGType = reader:ReadByte()
end
Auto.Reader[145] = function(reader, obj)
	setmetatable(obj, Auto.Meta[145])

	obj.Pai = reader:ReadInt32()
	obj.MType = reader:ReadByte()
	obj.Red = reader:ReadBoolean()
	obj.Index = reader:ReadInt32()
end
Auto.Reader[481] = function(reader, obj)
	setmetatable(obj, Auto.Meta[481])

	obj.Holds = Base.ReadList(reader, function(r)
		return Base.ReadStruct(r, Auto.Reader[145])
	end)
end
Auto.Reader[146] = function(reader, obj)
	setmetatable(obj, Auto.Meta[146])

	obj.MJActions = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[479])
	end)
	obj.MjPlayerResultList = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[481])
	end)
end
Auto.Reader[140] = function(reader, obj)
	setmetatable(obj, Auto.Meta[140])

	obj.CurLevel = reader:ReadInt32()
	obj.TgtLevel = reader:ReadInt32()
	obj.StartTime = reader:ReadUInt32()
	obj.Players = Base.ReadDict(reader, function(r)
		return r:ReadUInt64()
	end, function(r)
		return Base.ReadStruct(r, Auto.Reader.UXVector3)
	end)
	obj.CurLevelPos = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.TgtLevelPos = Base.ReadStruct(reader, Auto.Reader.UXVector3)
end
Auto.Reader[177] = function(reader, obj)
	setmetatable(obj, Auto.Meta[177])

	obj.R0 = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
	obj.R1 = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[193])
	end)
	obj.R2 = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
	obj.R3 = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[180])
	end)
end
Auto.Reader[197] = function(reader, obj)
	setmetatable(obj, Auto.Meta[197])

	obj.ProgressInfoDict = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return Base.ReadComplex(r, Auto.Reader[482])
	end)
end
Auto.Reader[482] = function(reader, obj)
	setmetatable(obj, Auto.Meta[482])

	obj.EventProgressInfoDict = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return Base.ReadComplex(r, Auto.Reader[49])
	end)
	obj.FinishedTemplateIdList = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
end
Auto.Reader[88] = function(reader, obj)
	setmetatable(obj, Auto.Meta[88])

	obj.Type = reader:ReadByte()
	obj.LikeCount = reader:ReadInt32()
	obj.PostCount = reader:ReadInt32()
	obj.NpcIds = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
	obj.Id = reader:ReadUInt32()
	obj.CfgId = reader:ReadUInt32()
	obj.HasNewLike = reader:ReadBoolean()
	obj.AcquireCfgId = reader:ReadUInt32()
	obj.ActivityCfgId = reader:ReadUInt32()
	obj.Url = reader:ReadString()
	obj.IsStory = reader:ReadBoolean()
	obj.IsPinStory = reader:ReadBoolean()
end
Auto.Reader[16] = function(reader, obj)
	setmetatable(obj, Auto.Meta[16])

	obj.Behavior = reader:ReadByte()
	obj.Id = reader:ReadInt32()
end
Auto.Reader[483] = function(reader, obj)
	setmetatable(obj, Auto.Meta[483])

	obj.UnitId = reader:ReadUInt64()
	obj.Pos = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.Rot = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.MoveId = reader:ReadInt32()
	obj.MoveTime = reader:ReadSingle()
	obj.ClientLocalTime = reader:ReadUInt32()
	obj.GroundData = Base.ReadStruct(reader, Auto.Reader[484])
	obj.ActionData = Base.ReadList(reader, function(r)
		return r:ReadByte()
	end)
	obj.ActionDataLength = reader:ReadInt32()
	obj.EffectData = Base.ReadList(reader, function(r)
		return r:ReadByte()
	end)
	obj.EffectDataLength = reader:ReadInt32()
	obj.InteractableData = Base.ReadList(reader, function(r)
		return r:ReadByte()
	end)
	obj.InteractableDataLength = reader:ReadInt32()
end
Auto.Reader[484] = function(reader, obj)
	setmetatable(obj, Auto.Meta[484])

	obj.MoveGroundType = reader:ReadByte()
	obj.MoveGroundId = reader:ReadUInt64()
	obj.LocalPos = Base.ReadStruct(reader, Auto.Reader.UXVector3)
end
Auto.Reader[485] = function(reader, obj)
	setmetatable(obj, Auto.Meta[485])

	obj.UnitId = reader:ReadUInt64()
	obj.MoveType = reader:ReadInt64()
	obj.MaxDistance = reader:ReadSingle()
	obj.MoveId = reader:ReadInt32()
	obj.CloseIK = reader:ReadBoolean()
end
Auto.Reader[486] = function(reader, obj)
	setmetatable(obj, Auto.Meta[486])

	obj.UnitId = reader:ReadUInt64()
	obj.MoveType = reader:ReadInt64()
	obj.AngleSpace = reader:ReadSingle()
	obj.DistanceSpace = reader:ReadSingle()
	obj.MoveId = reader:ReadInt32()
	obj.CloseIK = reader:ReadBoolean()
end
Auto.Reader[487] = function(reader, obj)
	setmetatable(obj, Auto.Meta[487])

	obj.UnitId = reader:ReadUInt64()
	obj.TargetId = reader:ReadUInt64()
	obj.EqsName = reader:ReadString()
	obj.CheckerName = reader:ReadString()
	obj.PathTags = reader:ReadUInt32()
	obj.MoveType = reader:ReadInt64()
	obj.MoveId = reader:ReadInt32()
	obj.CloseIK = reader:ReadBoolean()
	obj.CloseObstacleAvoidance = reader:ReadBoolean()
end
Auto.Reader[488] = function(reader, obj)
	setmetatable(obj, Auto.Meta[488])

	obj.pid = reader:ReadUInt64()
	obj.path = Base.ReadList(reader, function(r)
		return Base.ReadStruct(r, Auto.Reader.UXVector3)
	end)
	obj.pathTags = reader:ReadUInt32()
	obj.moveId = reader:ReadInt32()
	obj.StopDistance = reader:ReadSingle()
	obj.type = reader:ReadInt64()
	obj.reportOnFinish = reader:ReadBoolean()
	obj.closeIK = reader:ReadBoolean()
	obj.UseServerPath = reader:ReadBoolean()
	obj.CloseObstacleAvoidance = reader:ReadBoolean()
	obj.pathFlags = Base.ReadList(reader, function(r)
		return r:ReadByte()
	end)
end
Auto.Reader[489] = function(reader, obj)
	setmetatable(obj, Auto.Meta[489])

	obj.UnitId = reader:ReadUInt64()
	obj.TargetId = reader:ReadUInt64()
	obj.MoveId = reader:ReadInt32()
	obj.ActionId = reader:ReadUInt32()
	obj.NearDistance = reader:ReadSingle()
	obj.ReportOnFinish = reader:ReadBoolean()
	obj.CloseObstacleAvoidance = reader:ReadBoolean()
	obj.CloseIngterStep = reader:ReadBoolean()
	obj.IsMoveAround = reader:ReadBoolean()
	obj.CloseIK = reader:ReadBoolean()
	obj.Type = reader:ReadInt64()
end
Auto.Reader[490] = function(reader, obj)
	setmetatable(obj, Auto.Meta[490])

	obj.pid = reader:ReadUInt64()
	obj.pathTags = reader:ReadUInt32()
	obj.moveId = reader:ReadInt32()
	obj.type = reader:ReadInt64()
	obj.closeIK = reader:ReadBoolean()
	obj.CloseObstacleAvoidance = reader:ReadBoolean()
	obj.MinDis = reader:ReadSingle()
	obj.MaxDis = reader:ReadSingle()
	obj.InRangeAngle = reader:ReadSingle()
	obj.OutRangeAngle = reader:ReadSingle()
	obj.MaxTime = reader:ReadSingle()
	obj.MaxOnceWanderTime = reader:ReadSingle()
end
Auto.Reader[170] = function(reader, obj)
	setmetatable(obj, Auto.Meta[170])

	obj.MusicId = reader:ReadUInt32()
	obj.RecordInfo = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
	obj.AlreadyReward = reader:ReadBoolean()
end
Auto.Reader[491] = function(reader, obj)
	setmetatable(obj, Auto.Meta[491])

	obj.Pid = reader:ReadUInt64()
	obj.Name = reader:ReadString()
	obj.Level = reader:ReadUInt32()
end
Auto.Reader[182] = function(reader, obj)
	setmetatable(obj, Auto.Meta[182])

	obj.ChallengeId = reader:ReadUInt32()
	obj.HighestLevel = reader:ReadUInt32()
	obj.ReceivedRewardLevel = reader:ReadUInt32()
	obj.CurrentIsNewRewardLevel = reader:ReadBoolean()
	obj.BestScore = reader:ReadSingle()
	obj.ParamData = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return r:ReadBoolean()
	end)
end
Auto.Reader[492] = function(reader, obj)
	setmetatable(obj, Auto.Meta[492])

	obj.EntityId = reader:ReadUInt64()
	obj.Status = reader:ReadByte()
	obj.VehicleUId = reader:ReadUInt64()
	obj.SeatIndex = reader:ReadByte()
end
Auto.Reader[157] = function(reader, obj)
	setmetatable(obj, Auto.Meta[157])

	obj.Version = reader:ReadInt32()
	obj.Content = Base.ReadList(reader, function(r)
		return r:ReadByte()
	end)
	obj.Md5 = reader:ReadString()
end
Auto.Reader[493] = function(reader, obj)
	setmetatable(obj, Auto.Meta[493])

	obj.DoNotDisturb = reader:ReadBoolean()
	obj.DoNotDisturbBegin = reader:ReadUInt32()
	obj.DoNotDisturbEnd = reader:ReadUInt32()
	obj.TagSetting = reader:ReadUInt32()
	obj.LastSetTagTime = reader:ReadUInt32()
end
Auto.Reader[196] = function(reader, obj)
	setmetatable(obj, Auto.Meta[196])

	obj.Links = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[619])
	end)
end
Auto.Reader[28] = function(reader, obj)
	setmetatable(obj, Auto.Meta[28])

	obj.TemplateId = reader:ReadUInt32()
	obj.UnlockedVoice = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
	obj.ActivateTimestamp = reader:ReadUInt32()
	obj.Favor = reader:ReadDouble()
	obj.InteractDays = reader:ReadUInt32()
	obj.LastInteractTime = reader:ReadUInt32()
	obj.GroupNpcPhotoPosList = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
	obj.SingleNpcPhotoPosList = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
	obj.TodayChatPosList = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
	obj.FirstChatPosList = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
	obj.PreferCfgId = reader:ReadUInt32()
	obj.AcquireDropReward = reader:ReadBoolean()
	obj.ActiveGiftTags = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
	obj.MaxFavorInHistory = reader:ReadDouble()
	obj.TodayFavorDialogCount = reader:ReadUInt32()
	obj.InteractedStories = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
	obj.HasUninteractedNpcVoice = reader:ReadBoolean()
	obj.InteractedVoices = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
	obj.FavorLevelReward = reader:ReadInt32()
	obj.HasNoInteractedStory = reader:ReadBoolean()
	obj.UnlockedStoryDict = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return r:ReadUInt32()
	end)
end
Auto.Reader[494] = function(reader, obj)
	setmetatable(obj, Auto.Meta[494])

	obj.BubbleId = reader:ReadUInt32()
	obj.AcquireCfgId = reader:ReadUInt32()
	obj.EmojiList = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[408])
	end)
	obj.Url = reader:ReadString()
	obj.ActivityCfgId = reader:ReadUInt32()
end
Auto.Reader[24] = function(reader, obj)
	setmetatable(obj, Auto.Meta[24])

	obj.Timestamp = reader:ReadUInt32()
	obj.ChatId = reader:ReadUInt32()
	obj.NextChatId = reader:ReadUInt32()
	obj.ChatContext = Base.ReadComplex(reader, Auto.Reader[494])
	obj.IsRead = reader:ReadBoolean()
	obj.BelongNpc = reader:ReadUInt32()
end
Auto.Reader[495] = function(reader, obj)
	setmetatable(obj, Auto.Meta[495])

	obj.TodayTriggeredCount = reader:ReadUInt32()
	obj.EventIds = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
end
Auto.Reader[496] = function(reader, obj)
	setmetatable(obj, Auto.Meta[496])

	obj.NpcQueues = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return Base.ReadComplex(r, Auto.Reader[495])
	end)
	obj.TodayTriggeredCount = reader:ReadUInt32()
	obj.IdToNpcDict = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return Base.ReadComplex(r, Auto.Reader[27])
	end)
	obj.LastTriggerTime = reader:ReadUInt32()
end
Auto.Reader[497] = function(reader, obj)
	setmetatable(obj, Auto.Meta[497])

	obj.ActivityId = reader:ReadUInt32()
	obj.StartDaySecond = reader:ReadInt32()
	obj.Position = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.SpoonAgentId = reader:ReadInt32()
	obj.EndDaySecond = reader:ReadInt32()
	obj.RaidId = reader:ReadUInt32()
end
Auto.Reader[176] = function(reader, obj)
	setmetatable(obj, Auto.Meta[176])

	obj.Id = reader:ReadUInt32()
	obj.FightShareDuration = reader:ReadUInt32()
	obj.SwitchInTime = reader:ReadUInt32()
end
Auto.Reader[73] = function(reader, obj)
	setmetatable(obj, Auto.Meta[73])

	obj.TemplateId = reader:ReadUInt32()
	obj.Count = reader:ReadInt32()
	obj.RefreshTime = reader:ReadUInt32()
	obj.Status = reader:ReadByte()
	obj.BuyTimes = reader:ReadUInt32()
	obj.Discount = reader:ReadUInt32()
	obj.DiscountPrice = reader:ReadUInt32()
end
Auto.Reader[166] = function(reader, obj)
	setmetatable(obj, Auto.Meta[166])

	obj.CurrentDiscount = reader:ReadUInt32()
	obj.NextDiscount = reader:ReadUInt32()
	obj.CommodityInfoList = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[73])
	end)
end
Auto.Reader[76] = function(reader, obj)
	setmetatable(obj, Auto.Meta[76])

	obj.Schedule0 = Base.ReadComplex(reader, Auto.Reader[497])
	obj.Schedule1 = Base.ReadComplex(reader, Auto.Reader[497])
	obj.Schedule2 = Base.ReadComplex(reader, Auto.Reader[497])
	obj.Schedule3 = Base.ReadComplex(reader, Auto.Reader[497])
	obj.Schedule4 = Base.ReadComplex(reader, Auto.Reader[497])
	obj.CurrentSpoonAgentId = reader:ReadInt32()
	obj.SpoonPosition = Base.ReadStruct(reader, Auto.Reader.UXVector3)
end
Auto.Reader[7] = function(reader, obj)
	setmetatable(obj, Auto.Meta[7])

	obj.ProfileId = reader:ReadUInt32()
	obj.TrustValue = reader:ReadUInt32()
	obj.Reason = reader:ReadInt32()
end
Auto.Reader[498] = function(reader, obj)
	setmetatable(obj, Auto.Meta[498])

	obj.Uid = reader:ReadUInt64()
	obj.EnterOrLeave = reader:ReadBoolean()
	obj.VehicleEntityId = reader:ReadUInt64()
	obj.SeatIndex = reader:ReadInt32()
end
Auto.Reader[499] = function(reader, obj)
	setmetatable(obj, Auto.Meta[499])

	obj.OccupyId = reader:ReadUInt32()
	obj.Reason = reader:ReadString()
end
Auto.Reader[129] = function(reader, obj)
	setmetatable(obj, Auto.Meta[129])

	obj.WearFashionColoringInfoDict = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return Base.ReadComplex(r, Auto.Reader[414])
	end)
	obj.WearFashionInfoList = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[193])
	end)
	obj.WearFashionEditInfoList = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[180])
	end)
	obj.HiddenParts = reader:ReadByte()
	obj.EditedHiddenParts = reader:ReadByte()
end
Auto.Reader[500] = function(reader, obj)
	setmetatable(obj, Auto.Meta[500])

	obj.NetworkTick = reader:ReadUInt32()
	obj.attackPid = reader:ReadUInt64()
	obj.hurtPid = reader:ReadUInt64()
	obj.hurtId = reader:ReadUInt32()
	obj.hitPoint = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.hitCenter = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.hitDirection = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.colliderPos = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.colliderForward = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.colliderVelocity = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.attackColliderPos = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.attackColliderForward = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.attackColliderVelocity = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.skillUUID = reader:ReadInt32()
	obj.skillId = reader:ReadUInt32()
	obj.triggerIndex = reader:ReadInt32()
	obj.materialIndex = reader:ReadInt32()
	obj.hitColliderIndex = reader:ReadInt32()
	obj.creationId = reader:ReadUInt32()
end
Auto.Reader[171] = function(reader, obj)
	setmetatable(obj, Auto.Meta[171])

	obj.Pid = reader:ReadUInt64()
	obj.IsPSNPlayer = reader:ReadByte()
	obj.Openid = reader:ReadString()
end
Auto.Reader[501] = function(reader, obj)
	setmetatable(obj, Auto.Meta[501])

	obj.iScale = reader:ReadInt32()
	obj.linkType = Base.ReadList(reader, function(r)
		return r:ReadByte()
	end)
	obj.linkPath = Base.ReadList(reader, function(r)
		return r:ReadInt32()
	end)
end
Auto.Reader[502] = function(reader, obj)
	setmetatable(obj, Auto.Meta[502])

	obj.posX = reader:ReadSingle()
	obj.posY = reader:ReadSingle()
	obj.posZ = reader:ReadSingle()
	obj.eulerX = reader:ReadSingle()
	obj.eulerY = reader:ReadSingle()
	obj.eulerZ = reader:ReadSingle()
	obj.iScale = reader:ReadInt32()
	obj.uniqueId = reader:ReadUInt64()
	obj.pathId = reader:ReadInt32()
	obj.spoonSpecialList = Base.ReadList(reader, function(r)
		return Base.ReadStruct(r, Auto.Reader[503])
	end)
	obj.delayDestroy = reader:ReadBoolean()
	obj.startTaskId = reader:ReadUInt32()
	obj.endTaskId = reader:ReadUInt32()
end
Auto.Reader[503] = function(reader, obj)
	setmetatable(obj, Auto.Meta[503])

	obj.markId = reader:ReadInt32()
	obj.value = reader:ReadString()
end
Auto.Reader[504] = function(reader, obj)
	setmetatable(obj, Auto.Meta[504])

	obj.Id = reader:ReadInt32()
	obj.Message = reader:ReadString()
end
Auto.Reader[107] = function(reader, obj)
	setmetatable(obj, Auto.Meta[107])

	obj.likeList = Base.ReadList(reader, function(r)
		return r:ReadInt32()
	end)
	obj.giftList = Base.ReadList(reader, function(r)
		return r:ReadInt32()
	end)
	obj.Popularity = reader:ReadUInt32()
	obj.NPCMessage = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[504])
	end)
end
Auto.Reader[96] = function(reader, obj)
	setmetatable(obj, Auto.Meta[96])

	obj.PartyId = reader:ReadUInt32()
	obj.Popularity = reader:ReadUInt32()
	obj.LikeCount = reader:ReadUInt32()
	obj.GiftCount = reader:ReadUInt32()
	obj.CommentCount = reader:ReadUInt32()
	obj.AudienceCount = reader:ReadUInt32()
	obj.WinGameCount = reader:ReadUInt32()
	obj.TaskCount = reader:ReadUInt32()
	obj.InviteFriendCount = reader:ReadUInt32()
	obj.Drop = reader:ReadUInt32()
	obj.InviteNPCList = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
end
Auto.Reader[159] = function(reader, obj)
	setmetatable(obj, Auto.Meta[159])

	obj.Version = reader:ReadInt32()
	obj.Content = Base.ReadList(reader, function(r)
		return r:ReadByte()
	end)
	obj.Md5 = reader:ReadString()
end
Auto.Reader[505] = function(reader, obj)
	setmetatable(obj, Auto.Meta[505])

	obj.Id = reader:ReadUInt64()
	obj.Releaser = reader:ReadUInt64()
	obj.Time = reader:ReadSingle()
	obj.SkillId = reader:ReadUInt32()
	obj.TriggerIndex = reader:ReadUInt32()
end
Auto.Reader[506] = function(reader, obj)
	setmetatable(obj, Auto.Meta[506])

	obj.DisableTeamInviteInPersonalMode = reader:ReadBoolean()
end
Auto.Reader[507] = function(reader, obj)
	setmetatable(obj, Auto.Meta[507])

	obj.Label = reader:ReadString()
	obj.Hour = reader:ReadUInt32()
	obj.Minute = reader:ReadUInt32()
end
Auto.Reader[508] = function(reader, obj)
	setmetatable(obj, Auto.Meta[508])

	obj.AchieveId = reader:ReadUInt32()
	obj.Index = reader:ReadInt32()
	obj.CountryId = reader:ReadUInt32()
end
Auto.Reader[195] = function(reader, obj)
	setmetatable(obj, Auto.Meta[195])

	obj.Id = reader:ReadUInt32()
	obj.Index = reader:ReadInt32()
	obj.Level = reader:ReadUInt32()
	obj.FavorLevel = reader:ReadUInt32()
	obj.NpcCultivationId = reader:ReadUInt32()
end
Auto.Reader[188] = function(reader, obj)
	setmetatable(obj, Auto.Meta[188])

	obj.PzHeadInfo = Base.ReadComplex(reader, Auto.Reader[509])
	obj.UnlockedSystemHeadList = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[510])
	end)
end
Auto.Reader[509] = function(reader, obj)
	setmetatable(obj, Auto.Meta[509])

	obj.HeadType = reader:ReadByte()
	obj.SystemHeadId = reader:ReadUInt32()
end
Auto.Reader[510] = function(reader, obj)
	setmetatable(obj, Auto.Meta[510])

	obj.Id = reader:ReadUInt32()
	obj.HadInteracted = reader:ReadBoolean()
end
Auto.Reader[191] = function(reader, obj)
	setmetatable(obj, Auto.Meta[191])

	obj.BackgroundId = reader:ReadUInt32()
	obj.HadInteracted = reader:ReadBoolean()
	obj.IsUnlock = reader:ReadBoolean()
end
Auto.Reader[70] = function(reader, obj)
	setmetatable(obj, Auto.Meta[70])

	obj.Remark = reader:ReadString()
	obj.PhoneNumber = reader:ReadString()
end
Auto.Reader[511] = function(reader, obj)
	setmetatable(obj, Auto.Meta[511])

	obj.CallTime = reader:ReadUInt32()
	obj.CallType = reader:ReadByte()
	obj.PhoneNumber = reader:ReadString()
end
Auto.Reader[512] = function(reader, obj)
	setmetatable(obj, Auto.Meta[512])

	obj.Name = reader:ReadString()
	obj.PhoneNumberList = Base.ReadList(reader, function(r)
		return r:ReadString()
	end)
end
Auto.Reader[55] = function(reader, obj)
	setmetatable(obj, Auto.Meta[55])

	obj.ContactList = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[70])
	end)
	obj.ContactGroupList = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[512])
	end)
	obj.CallRecordList = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[511])
	end)
	obj.ContactOutgoingCallTimesDict = Base.ReadDict(reader, function(r)
		return r:ReadString()
	end, function(r)
		return r:ReadUInt32()
	end)
end
Auto.Reader[95] = function(reader, obj)
	setmetatable(obj, Auto.Meta[95])

	obj.FurnitureId = reader:ReadUInt32()
	obj.Position = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.Rotation = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.GadgetInstanceId = reader:ReadUInt64()
	obj.PlacedInstanceId = reader:ReadUInt64()
	obj.ChildrenDict = Base.ReadDict(reader, function(r)
		return r:ReadUInt64()
	end, function(r)
		return Base.ReadComplex(r, Auto.Reader[95])
	end)
end
Auto.Reader[4] = function(reader, obj)
	setmetatable(obj, Auto.Meta[4])

	obj.StepId2OptionIndexDict = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return r:ReadByte()
	end)
end
Auto.Reader[513] = function(reader, obj)
	setmetatable(obj, Auto.Meta[513])

	obj.addInfos = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[514])
	end)
	obj.removeIds = Base.ReadList(reader, function(r)
		return r:ReadUInt64()
	end)
	obj.reason = reader:ReadByte()
end
Auto.Reader[514] = function(reader, obj)
	setmetatable(obj, Auto.Meta[514])

	obj.UniqueId = reader:ReadUInt64()
	obj.GraphId = reader:ReadInt32()
	obj.GadgetDic = Base.ReadDict(reader, function(r)
		return r:ReadInt32()
	end, function(r)
		return r:ReadUInt64()
	end)
	obj.DestructibleDic = Base.ReadDict(reader, function(r)
		return r:ReadInt32()
	end, function(r)
		return r:ReadUInt64()
	end)
	obj.AgentDic = Base.ReadDict(reader, function(r)
		return r:ReadInt32()
	end, function(r)
		return r:ReadInt32()
	end)
	obj.VehicleDic = Base.ReadDict(reader, function(r)
		return r:ReadInt32()
	end, function(r)
		return r:ReadInt32()
	end)
end
Auto.Reader[515] = function(reader, obj)
	setmetatable(obj, Auto.Meta[515])

	obj.ActionId = reader:ReadUInt32()
	obj.Uid = reader:ReadUInt64()
	obj.MaxTime = reader:ReadSingle()
	obj.ActionUid = reader:ReadUInt32()
end
Auto.Reader[516] = function(reader, obj)
	setmetatable(obj, Auto.Meta[516])

	obj.ActionId = reader:ReadUInt32()
	obj.Uid = reader:ReadUInt64()
	obj.MaxTime = reader:ReadSingle()
	obj.ActionUid = reader:ReadUInt32()
end
Auto.Reader[6] = function(reader, obj)
	setmetatable(obj, Auto.Meta[6])

	obj.Pid = reader:ReadUInt64()
	obj.Name = reader:ReadString()
	obj.Level = reader:ReadUInt32()
	obj.Sex = reader:ReadByte()
	obj.PzHeadInfo = Base.ReadComplex(reader, Auto.Reader[509])
	obj.LastLogoutTime = reader:ReadUInt32()
	obj.LastDetachTime = reader:ReadUInt32()
	obj.RaidId = reader:ReadUInt32()
	obj.OnlineState = reader:ReadByte()
	obj.LinkMode = reader:ReadByte()
	obj.LinkIndex = reader:ReadInt32()
	obj.SyncRate = reader:ReadSingle()
	obj.InRoom = reader:ReadBoolean()
	obj.InMatch = reader:ReadBoolean()
	obj.TeamId = reader:ReadUInt64()
	obj.AppChannel = reader:ReadString()
end
Auto.Reader[83] = function(reader, obj)
	setmetatable(obj, Auto.Meta[83])

	obj.CurrentBattlePassId = reader:ReadUInt32()
	obj.Level = reader:ReadUInt32()
	obj.Exp = reader:ReadUInt32()
	obj.ClaimedLevelRewards = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return r:ReadByte()
	end)
	obj.CurrentPassType = reader:ReadByte()
	obj.LastWeeklyRefresherTime = reader:ReadUInt32()
	obj.UnClaimedExp = reader:ReadUInt32()
	obj.ChallengeTaskStates = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return r:ReadByte()
	end)
end
Auto.Reader[517] = function(reader, obj)
	setmetatable(obj, Auto.Meta[517])

	obj.CityPedia2IsReadDict = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return r:ReadBoolean()
	end)
	obj.CreditInfo = Base.ReadComplex(reader, Auto.Reader[34])
end
Auto.Reader[78] = function(reader, obj)
	setmetatable(obj, Auto.Meta[78])

	obj.Config = Base.ReadBuffer(reader)
	obj.InfoLogin = Base.ReadComplex(reader, Auto.Reader[522])
	obj.InfoItem = Base.ReadComplex(reader, Auto.Reader[521])
	obj.InfoSpirit = Base.ReadComplex(reader, Auto.Reader[526])
	obj.InfoMinor = Base.ReadComplex(reader, Auto.Reader[523])
	obj.InfoAchievement = Base.ReadComplex(reader, Auto.Reader[518])
end
Auto.Reader[518] = function(reader, obj)
	setmetatable(obj, Auto.Meta[518])

	obj.SceneFogMaps = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return Base.ReadComplex(r, Auto.Reader[581])
	end)
	obj.SceneFogMapPoiIds = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
	obj.UnlockedCountryList = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
	obj.UnlockedQuestList = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
	obj.CompletedSubQuestCnt = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return r:ReadUInt32()
	end)
	obj.ChallengeRecordInfo = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return Base.ReadComplex(r, Auto.Reader[44])
	end)
	obj.NewChallengeRecordInfo = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return Base.ReadComplex(r, Auto.Reader[182])
	end)
	obj.FirstKillEnemyRecord = Base.ReadList(reader, function(r)
		return r:ReadInt32()
	end)
	obj.UnlockInvestigateGalleryList = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
	obj.InvestigateGalleryRedCnt = reader:ReadInt32()
	obj.CountryReputationInfo = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return r:ReadUInt32()
	end)
	obj.FactionInfoDic = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return Base.ReadComplex(r, Auto.Reader[68])
	end)
	obj.OccupiedInfluenceArea = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
end
Auto.Reader[519] = function(reader, obj)
	setmetatable(obj, Auto.Meta[519])

	obj.PartTimeJobDailyRewardTimes = reader:ReadInt32()
	obj.PartTimeJobUnlockStore = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
end
Auto.Reader[520] = function(reader, obj)
	setmetatable(obj, Auto.Meta[520])

	obj.FinishedGuides = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
	obj.NewGuideTeachInfos = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
	obj.RewardedGuideTeachInfos = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
	obj.UnlockSystems = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
	obj.TaskTitleGuideUnlockList = Base.ReadList(reader, function(r)
		return r:ReadUInt16()
	end)
end
Auto.Reader[521] = function(reader, obj)
	setmetatable(obj, Auto.Meta[521])

	obj.Money = reader:ReadUInt32()
	obj.Gold = reader:ReadUInt32()
	obj.BindingGold = reader:ReadUInt32()
	obj.FreeGold = reader:ReadInt32()
	obj.ItemDayCounts = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[32])
	end)
	obj.PackItems = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[2])
	end)
	obj.ItemShortcutDic = Base.ReadDict(reader, function(r)
		return r:ReadByte()
	end, function(r)
		return Base.ReadComplex(r, Auto.Reader[58])
	end)
	obj.DestructibleShortcut = reader:ReadUInt32()
	obj.TodayGachaCount = reader:ReadUInt32()
	obj.GachaPoolCount = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return r:ReadInt32()
	end)
	obj.ItemCountLimitInfoList = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[61])
	end)
	obj.QuantumWalletStartTime = reader:ReadUInt32()
	obj.PortalPosition = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.PortalRaidId = reader:ReadUInt32()
end
Auto.Reader[522] = function(reader, obj)
	setmetatable(obj, Auto.Meta[522])

	obj.Aid = reader:ReadInt32()
	obj.Pid = reader:ReadUInt64()
	obj.AccountId = reader:ReadString()
	obj.Name = reader:ReadString()
	obj.Level = reader:ReadUInt32()
	obj.Sex = reader:ReadByte()
	obj.PzHeadInfo = Base.ReadComplex(reader, Auto.Reader[509])
end
Auto.Reader[523] = function(reader, obj)
	setmetatable(obj, Auto.Meta[523])

	obj.Exp = reader:ReadInt64()
	obj.Fan = reader:ReadInt64()
	obj.Fan12 = reader:ReadUInt32()
	obj.Fan123 = reader:ReadUInt32()
	obj.YesterdayFan = reader:ReadInt32()
	obj.Level = reader:ReadUInt32()
	obj.LevelRewards = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
	obj.Questionnaire = reader:ReadInt32()
	obj.DropLimitCount = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return Base.ReadComplex(r, Auto.Reader[10])
	end)
	obj.ChargeInfo = Base.ReadComplex(reader, Auto.Reader[264])
	obj.MapPins = Base.ReadDict(reader, function(r)
		return r:ReadUInt64()
	end, function(r)
		return Base.ReadComplex(r, Auto.Reader[467])
	end)
	obj.MiniGame = Base.ReadComplex(reader, Auto.Reader[478])
	obj.PlayerInfoGuide = Base.ReadComplex(reader, Auto.Reader[520])
	obj.InfoNpcCultivation = Base.ReadComplex(reader, Auto.Reader[524])
	obj.InfoNpcProfile = Base.ReadComplex(reader, Auto.Reader[525])
	obj.PlayerInfoAtmosphereGameplay = Base.ReadComplex(reader, Auto.Reader[519])
	obj.PlayerFashionsInfo = Base.ReadComplex(reader, Auto.Reader[199])
	obj.housesInfo = Base.ReadComplex(reader, Auto.Reader[201])
	obj.PlayerPhoneInfo = Base.ReadComplex(reader, Auto.Reader[543])
	obj.ModuleEventProgressInfoDict = Base.ReadDict(reader, function(r)
		return r:ReadByte()
	end, function(r)
		return Base.ReadComplex(r, Auto.Reader[197])
	end)
	obj.LoadingTexts = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return Base.ReadComplex(r, Auto.Reader[457])
	end)
	obj.Badges = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return Base.ReadComplex(r, Auto.Reader[41])
	end)
	obj.GroupChats = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[14])
	end)
	obj.VehicleInfo = Base.ReadComplex(reader, Auto.Reader[545])
	obj.MatchInfo = Base.ReadComplex(reader, Auto.Reader[75])
	obj.PopularityInfoNew = Base.ReadComplex(reader, Auto.Reader[538])
	obj.ComputerUnlockInfo = Base.ReadComplex(reader, Auto.Reader[190])
	obj.PlayerInteractionActionInfo = Base.ReadComplex(reader, Auto.Reader[539])
	obj.PlayerCityPediaInfos = Base.ReadComplex(reader, Auto.Reader[517])
	obj.DebugReserveGpuDumps = reader:ReadBoolean()
	obj.FavorNpcDailyScheduleInfos = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return Base.ReadComplex(r, Auto.Reader[76])
	end)
	obj.PlayerInterActionInfo = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return r:ReadString()
	end)
	obj.PlanningBoardInfo = Base.ReadComplex(reader, Auto.Reader[4])
	obj.MallInfo = Base.ReadComplex(reader, Auto.Reader[466])
	obj.PlayerBattlePassInfo = Base.ReadComplex(reader, Auto.Reader[83])
	obj.PlayerLinkPlanningBoardInfo = Base.ReadComplex(reader, Auto.Reader[540])
	obj.PlayerGachaInfos = Base.ReadComplex(reader, Auto.Reader[530])
	obj.PlayerInspireHubInfo = Base.ReadComplex(reader, Auto.Reader[527])
end
Auto.Reader[524] = function(reader, obj)
	setmetatable(obj, Auto.Meta[524])

	obj.NpcCardInfos = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[28])
	end)
	obj.LockedCardInfos = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[28])
	end)
	obj.NpcChats = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[334])
	end)
	obj.NpcGroupChats = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[335])
	end)
	obj.AvailableGiftSendCount = reader:ReadUInt32()
	obj.InteractPoint = reader:ReadUInt32()
	obj.NpcEventQueueList = Base.ReadComplex(reader, Auto.Reader[496])
end
Auto.Reader[525] = function(reader, obj)
	setmetatable(obj, Auto.Meta[525])

	obj.NpcProfiles = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return Base.ReadComplex(r, Auto.Reader[91])
	end)
	obj.ProgressRewards = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
end
Auto.Reader[526] = function(reader, obj)
	setmetatable(obj, Auto.Meta[526])

	obj.Spirits = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[25])
	end)
	obj.InfoPokemon = Base.ReadComplex(reader, Auto.Reader[537])
	obj.AvailableSkinParts = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
	obj.InfoArmory = Base.ReadComplex(reader, Auto.Reader[533])
	obj.ActiveSpirit = reader:ReadUInt32()
	obj.DisableBadgeInfoDict = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return Base.ReadComplex(r, Auto.Reader[400])
	end)
	obj.InfoFightStyle = Base.ReadComplex(reader, Auto.Reader[535])
	obj.CommonSpiritTalentExp = reader:ReadUInt32()
end
Auto.Reader[527] = function(reader, obj)
	setmetatable(obj, Auto.Meta[527])

	obj.TodayGamePlayJoinCountDict = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return r:ReadInt32()
	end)
end
Auto.Reader[132] = function(reader, obj)
	setmetatable(obj, Auto.Meta[132])

	obj.Type = reader:ReadByte()
	obj.SourceTemplateId = reader:ReadUInt32()
	obj.SourceCreationId = reader:ReadUInt32()
end
Auto.Reader[199] = function(reader, obj)
	setmetatable(obj, Auto.Meta[199])

	obj.SpiritFashionsInfoDict = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return Base.ReadComplex(r, Auto.Reader[606])
	end)
	obj.FashionInfoDict = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return Base.ReadComplex(r, Auto.Reader[18])
	end)
	obj.FavoriteFashionIdList = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
	obj.FavoriteFashionSuitIdList = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
	obj.DefaultSpiritIsInitDefaultFashion = reader:ReadBoolean()
	obj.SpiritId2TaskTryWearInfoDict = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return Base.ReadComplex(r, Auto.Reader[85])
	end)
end
Auto.Reader[528] = function(reader, obj)
	setmetatable(obj, Auto.Meta[528])

	obj.playerInfoFightStyle = Base.ReadComplex(reader, Auto.Reader[535])
	obj.addOrUpdateUnlockInfo = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return r:ReadBoolean()
	end)
end
Auto.Reader[529] = function(reader, obj)
	setmetatable(obj, Auto.Meta[529])

	obj.TotalDrawCount = reader:ReadUInt32()
	obj.ClaimedMilestoneCounts = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return r:ReadBoolean()
	end)
end
Auto.Reader[530] = function(reader, obj)
	setmetatable(obj, Auto.Meta[530])

	obj.PoolInfos = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return Base.ReadComplex(r, Auto.Reader[532])
	end)
	obj.GroupInfos = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return Base.ReadComplex(r, Auto.Reader[529])
	end)
	obj.PityInfos = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return Base.ReadComplex(r, Auto.Reader[531])
	end)
end
Auto.Reader[531] = function(reader, obj)
	setmetatable(obj, Auto.Meta[531])

	obj.DrawCountSinceLastGrandPrize = reader:ReadUInt32()
	obj.TotalDrawCount = reader:ReadUInt32()
end
Auto.Reader[532] = function(reader, obj)
	setmetatable(obj, Auto.Meta[532])

	obj.DrawCount = reader:ReadUInt32()
	obj.HasWonGrandPrize = reader:ReadBoolean()
	obj.WonFillerPrizeIds = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return r:ReadBoolean()
	end)
end
Auto.Reader[71] = function(reader, obj)
	setmetatable(obj, Auto.Meta[71])

	obj.StartTime = reader:ReadUInt32()
	obj.EndTime = reader:ReadUInt32()
	obj.CompanionNpc = reader:ReadUInt32()
	obj.Used = reader:ReadBoolean()
end
Auto.Reader[533] = function(reader, obj)
	setmetatable(obj, Auto.Meta[533])

	obj.Weapons = Base.ReadList(reader, Auto.Dispatch[69])
end
Auto.Reader[534] = function(reader, obj)
	setmetatable(obj, Auto.Meta[534])

	obj.Badges = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return Base.ReadComplex(r, Auto.Reader[41])
	end)
	obj.HistoryBadges = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return Base.ReadComplex(r, Auto.Reader[41])
	end)
end
Auto.Reader[535] = function(reader, obj)
	setmetatable(obj, Auto.Meta[535])

	obj.FightStyleIsUnLocked = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return r:ReadBoolean()
	end)
end
Auto.Reader[536] = function(reader, obj)
	setmetatable(obj, Auto.Meta[536])

	obj.GangMembers = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return Base.ReadComplex(r, Auto.Reader[82])
	end)
end
Auto.Reader[187] = function(reader, obj)
	setmetatable(obj, Auto.Meta[187])

	obj.MissionDic = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return r:ReadUInt32()
	end)
	obj.LastRefreshMissionTime = reader:ReadUInt32()
	obj.CurMissionIndex = reader:ReadUInt32()
	obj.CurMissionId = reader:ReadUInt32()
	obj.CurMissionEventId = reader:ReadUInt32()
	obj.CurMissionProgress = reader:ReadSingle()
	obj.CurMissionStartTime = reader:ReadUInt32()
	obj.HistoryMissionResults = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[21])
	end)
	obj.CurMissionResult = Base.ReadComplex(reader, Auto.Reader[21])
	obj.RandomMissionHistory = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
	obj.Spirit2HistoryMissionInfo = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return Base.ReadComplex(r, Auto.Reader[666])
	end)
	obj.HistoryMissionCnt = reader:ReadUInt32()
	obj.HistoryMissionMoney = reader:ReadInt32()
	obj.TodayMissionMoney = reader:ReadInt32()
end
Auto.Reader[537] = function(reader, obj)
	setmetatable(obj, Auto.Meta[537])

	obj.AllPokemons = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[42])
	end)
	obj.FastFightSquad = Base.ReadList(reader, function(r)
		return r:ReadUInt64()
	end)
	obj.EnabledBodyIds = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
	obj.EnabledCampIds = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
	obj.EnabledWeaponIds = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
end
Auto.Reader[538] = function(reader, obj)
	setmetatable(obj, Auto.Meta[538])

	obj.Popularity = reader:ReadSingle()
	obj.UnderflowPopularity = reader:ReadSingle()
	obj.Version = reader:ReadInt32()
	obj.NextPopularityUpdateTime = reader:ReadUInt32()
	obj.NextUnderflowPopularityUpdateTime = reader:ReadUInt32()
	obj.HistoryPopularityList = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[77])
	end)
	obj.LastUnderflowPopularitySpeed = reader:ReadUInt32()
	obj.WalletRewards = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[92])
	end)
	obj.TotalLeftMoney = reader:ReadUInt32()
	obj.DropList = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[93])
	end)
	obj.ChangeList = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[554])
	end)
	obj.LastDiff = reader:ReadSingle()
	obj.LastPopularityUpdateTime = reader:ReadUInt32()
	obj.NextYesterdayAvgPopularityUpdateTime = reader:ReadUInt32()
	obj.YesterdayAvgPopularity = reader:ReadSingle()
	obj.TodayCoinGet = reader:ReadUInt32()
	obj.PastHoursCoinRewards = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[92])
	end)
end
Auto.Reader[539] = function(reader, obj)
	setmetatable(obj, Auto.Meta[539])

	obj.UnlockActionItemDict = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return Base.ReadComplex(r, Auto.Reader[79])
	end)
	obj.InvitedNotDisturb = reader:ReadBoolean()
end
Auto.Reader[79] = function(reader, obj)
	setmetatable(obj, Auto.Meta[79])

	obj.CfgId = reader:ReadUInt32()
	obj.UnlockTime = reader:ReadUInt32()
	obj.ShowRedPoint = reader:ReadBoolean()
end
Auto.Reader[173] = function(reader, obj)
	setmetatable(obj, Auto.Meta[173])

	obj.CountryId = reader:ReadUInt32()
	obj.Reputation = reader:ReadUInt32()
	obj.IsShow = reader:ReadBoolean()
	obj.GalleryInfos = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[72])
	end)
end
Auto.Reader[72] = function(reader, obj)
	setmetatable(obj, Auto.Meta[72])

	obj.GalleryId = reader:ReadUInt32()
	obj.UnlockTime = reader:ReadUInt32()
	obj.IsArchived = reader:ReadBoolean()
	obj.Pos = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.Count = reader:ReadUInt32()
end
Auto.Reader[32] = function(reader, obj)
	setmetatable(obj, Auto.Meta[32])

	obj.TemplateId = reader:ReadUInt32()
	obj.Count = reader:ReadUInt32()
end
Auto.Reader[540] = function(reader, obj)
	setmetatable(obj, Auto.Meta[540])

	obj.EnableMaxMultiPlayerId = reader:ReadUInt32()
	obj.IsSingleGame = reader:ReadBoolean()
	obj.MultiGamePutInKeyCountInfoList = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[454])
	end)
end
Auto.Reader[541] = function(reader, obj)
	setmetatable(obj, Auto.Meta[541])

	obj.Mode = reader:ReadByte()
	obj.Reason = reader:ReadByte()
	obj.FastPlayRaidId = reader:ReadUInt32()
	obj.JumpToMainEvent = reader:ReadInt32()
	obj.SceneItemQuality = reader:ReadInt32()
	obj.FastPlayPosition = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.FromWhere = reader:ReadByte()
end
Auto.Reader[172] = function(reader, obj)
	setmetatable(obj, Auto.Meta[172])

	obj.Pid = reader:ReadUInt64()
	obj.Score = reader:ReadInt32()
	obj.Rank = reader:ReadUInt32()
	obj.MaxRank = reader:ReadUInt32()
	obj.RewardRank = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
	obj.GameCount = reader:ReadUInt32()
	obj.WinningStreakCount = reader:ReadUInt32()
	obj.LosingStreakCount = reader:ReadUInt32()
	obj.NpcCultivationId = reader:ReadUInt32()
	obj.NpcMahjongId = reader:ReadUInt32()
	obj.NpcRefreshTime = reader:ReadUInt32()
	obj.NpcAddFavorNum = reader:ReadUInt32()
end
Auto.Reader[75] = function(reader, obj)
	setmetatable(obj, Auto.Meta[75])

	obj.GameId2LastPlayTime = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return r:ReadUInt32()
	end)
	obj.LastInviteAllTime = reader:ReadUInt32()
	obj.AvailablePrepareActions = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
	obj.InWorldBattle = reader:ReadBoolean()
	obj.LoadingTypeInfo = Base.ReadComplex(reader, Auto.Reader[458])
	obj.DeviceLevel = reader:ReadByte()
	obj.CurLinkDeviceLevel = reader:ReadByte()
end
Auto.Reader[542] = function(reader, obj)
	setmetatable(obj, Auto.Meta[542])

	obj.LastReceiveTime = reader:ReadUInt32()
	obj.EndTime = reader:ReadUInt32()
end
Auto.Reader[2] = function(reader, obj)
	setmetatable(obj, Auto.Meta[2])

	obj.UniqueId = reader:ReadUInt64()
	obj.TemplateId = reader:ReadUInt32()
	obj.Count = reader:ReadUInt32()
	obj.IsNew = reader:ReadBoolean()
	obj.ExpiryTime = reader:ReadUInt32()
	obj.RemindState = reader:ReadByte()
	obj.CDFinishTime = reader:ReadUInt32()
end
Auto.Reader[198] = function(reader, obj)
	setmetatable(obj, Auto.Meta[198])

	obj.PartyTimes = reader:ReadUInt32()
	obj.lastPartyTime = reader:ReadUInt64()
end
Auto.Reader[543] = function(reader, obj)
	setmetatable(obj, Auto.Meta[543])

	obj.SpiritPhoneInfos = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return Base.ReadComplex(r, Auto.Reader[55])
	end)
	obj.DownLoadAppIds = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
end
Auto.Reader[57] = function(reader, obj)
	setmetatable(obj, Auto.Meta[57])

	obj.Id = reader:ReadUInt32()
end
Auto.Reader[544] = function(reader, obj)
	setmetatable(obj, Auto.Meta[544])

	obj.Id = reader:ReadUInt32()
	obj.Parts = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[546])
	end)
	obj.UnlockTime = reader:ReadUInt32()
end
Auto.Reader[100] = function(reader, obj)
	setmetatable(obj, Auto.Meta[100])

	obj.Pid = reader:ReadUInt64()
	obj.EnterOrLeave = reader:ReadBoolean()
	obj.VehicleEntityId = reader:ReadUInt64()
	obj.SeatIndex = reader:ReadInt32()
	obj.IfForce = reader:ReadBoolean()
	obj.OpenDoorTypeId = reader:ReadInt32()
	obj.OpenDoorActionSpeed = reader:ReadInt32()
	obj.OpenDoorActionClipLength = reader:ReadInt32()
end
Auto.Reader[545] = function(reader, obj)
	setmetatable(obj, Auto.Meta[545])

	obj.UnlockedVehicles = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[544])
	end)
	obj.RequisitionVehicleCount = reader:ReadInt32()
	obj.ParkingVehicleId = reader:ReadUInt32()
end
Auto.Reader[546] = function(reader, obj)
	setmetatable(obj, Auto.Meta[546])

	obj.VehiclePartId = reader:ReadUInt32()
	obj.VehiclePartTag = reader:ReadUInt32()
end
Auto.Reader[547] = function(reader, obj)
	setmetatable(obj, Auto.Meta[547])

	obj.min = reader:ReadSingle()
	obj.max = reader:ReadSingle()
end
Auto.Reader[548] = function(reader, obj)
	setmetatable(obj, Auto.Meta[548])

	obj.NodeId = reader:ReadInt32()
	obj.Pos = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.Index = reader:ReadInt32()
	obj.Sprite = reader:ReadUInt32()
	obj.LabelId = reader:ReadUInt32()
	obj.DoNotFocusCamera = reader:ReadBoolean()
	obj.PlayerAction = Base.ReadStruct(reader, Auto.Reader[549])
end
Auto.Reader[549] = function(reader, obj)
	setmetatable(obj, Auto.Meta[549])

	obj.CommonInteractType = reader:ReadByte()
	obj.InteractPosType = reader:ReadByte()
	obj.InteractPos = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.InteractPosForward = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.InteractRadius = reader:ReadSingle()
	obj.InteractLoopTime = reader:ReadSingle()
	obj.InteractIkPos = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.InteractIkPosForward = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.ChairType = reader:ReadInt32()
end
Auto.Reader[42] = function(reader, obj)
	setmetatable(obj, Auto.Meta[42])

	obj.Id = reader:ReadUInt64()
	obj.Body = reader:ReadUInt32()
	obj.Camp = reader:ReadUInt32()
	obj.Weapon = reader:ReadUInt32()
	obj.LimboChaId = reader:ReadUInt32()
	obj.AcquireTime = reader:ReadUInt32()
	obj.IsLocked = reader:ReadBoolean()
end
Auto.Reader[59] = function(reader, obj)
	setmetatable(obj, Auto.Meta[59])

	obj.Time = reader:ReadUInt32()
	obj.NpcId = reader:ReadUInt32()
	obj.Fines = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
	obj.Sentence = reader:ReadInt32()
	obj.Drops = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
	obj.RewardTaken = reader:ReadBoolean()
	obj.BonusDrops = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
	obj.Id = reader:ReadUInt64()
end
Auto.Reader[550] = function(reader, obj)
	setmetatable(obj, Auto.Meta[550])

	obj.ChargingSkillId = reader:ReadUInt32()
	obj.Position = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.Facing = reader:ReadSingle()
end
Auto.Reader[551] = function(reader, obj)
	setmetatable(obj, Auto.Meta[551])

	obj.PrisonerId = reader:ReadUInt64()
end
Auto.Reader[48] = function(reader, obj)
	setmetatable(obj, Auto.Meta[48])

	obj.Id = reader:ReadUInt32()
	obj.NextAvailableTime = reader:ReadUInt32()
	obj.IsTemp = reader:ReadBoolean()
	obj.TempEventId = reader:ReadUInt32()
	obj.TodayArrestSupportTimes = reader:ReadUInt32()
end
Auto.Reader[552] = function(reader, obj)
	setmetatable(obj, Auto.Meta[552])

	obj.DailyViolationCount = reader:ReadUInt32()
	obj.LeaveDueTime = reader:ReadUInt32()
	obj.LastViolationUpdateTime = reader:ReadUInt32()
	obj.ServiceData = Base.ReadComplex(reader, Auto.Reader[50])
	obj.WeeklyServiceData = Base.ReadComplex(reader, Auto.Reader[50])
	obj.ViolationCdInfos = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return r:ReadUInt32()
	end)
end
Auto.Reader[553] = function(reader, obj)
	setmetatable(obj, Auto.Meta[553])

	obj.AgentId = reader:ReadUInt32()
	obj.IsRead = reader:ReadBoolean()
end
Auto.Reader[67] = function(reader, obj)
	setmetatable(obj, Auto.Meta[67])

	obj.CurFakeFileId = reader:ReadUInt32()
	obj.ClueValue = reader:ReadUInt32()
	obj.UnlockFileInfoDict = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return r:ReadByte()
	end)
	obj.HistoryClueAgentInfoList = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[553])
	end)
end
Auto.Reader[50] = function(reader, obj)
	setmetatable(obj, Auto.Meta[50])

	obj.DispatchTimes = reader:ReadUInt32()
	obj.PatrolTimes = reader:ReadUInt32()
	obj.ArrestTimes = reader:ReadUInt32()
	obj.FineCount = reader:ReadUInt32()
	obj.TotalDrops = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
	obj.LastUpdateTime = reader:ReadUInt32()
	obj.CarFineCount = reader:ReadUInt32()
end
Auto.Reader[97] = function(reader, obj)
	setmetatable(obj, Auto.Meta[97])

	obj.Id = reader:ReadUInt64()
	obj.VehicleId = reader:ReadUInt32()
	obj.Position = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.Facing = reader:ReadSingle()
end
Auto.Reader[98] = function(reader, obj)
	setmetatable(obj, Auto.Meta[98])

	obj.ChaseRange = reader:ReadSingle()
	obj.ChaseDirectlyRange = reader:ReadSingle()
	obj.ApprehendRange = reader:ReadSingle()
	obj.NavConfigId = reader:ReadUInt32()
	obj.ChaseDirectlyConfigId = reader:ReadUInt32()
	obj.PatrolSpeed = reader:ReadSingle()
	obj.ChaseSpeed = reader:ReadSingle()
	obj.ChaseDirectlySpeed = reader:ReadSingle()
end
Auto.Reader[51] = function(reader, obj)
	setmetatable(obj, Auto.Meta[51])

	obj.Time = reader:ReadUInt32()
	obj.Id = reader:ReadUInt32()
	obj.LeaveDueTime = reader:ReadUInt32()
end
Auto.Reader[554] = function(reader, obj)
	setmetatable(obj, Auto.Meta[554])

	obj.StartTime = reader:ReadUInt32()
	obj.MaxValue = reader:ReadSingle()
	obj.MaxTime = reader:ReadUInt32()
	obj.Duration = reader:ReadUInt32()
end
Auto.Reader[77] = function(reader, obj)
	setmetatable(obj, Auto.Meta[77])

	obj.Time = reader:ReadUInt32()
	obj.Value = reader:ReadSingle()
end
Auto.Reader[93] = function(reader, obj)
	setmetatable(obj, Auto.Meta[93])

	obj.Time = reader:ReadUInt32()
	obj.DropId = reader:ReadUInt32()
	obj.Count = reader:ReadUInt32()
end
Auto.Reader[92] = function(reader, obj)
	setmetatable(obj, Auto.Meta[92])

	obj.Date = reader:ReadUInt32()
	obj.Reward = reader:ReadUInt32()
end
Auto.Reader[555] = function(reader, obj)
	setmetatable(obj, Auto.Meta[555])

	obj.Pos = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.Rotation = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.Scale = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.EffectId = reader:ReadUInt32()
	obj.InstanceId = reader:ReadUInt64()
	obj.LogicEndTime = reader:ReadDouble()
	obj.ReleaserId = reader:ReadUInt64()
	obj.ClientDestructibleId = reader:ReadUInt64()
	obj.Duration = reader:ReadSingle()
end
Auto.Reader[218] = function(reader, obj)
	setmetatable(obj, Auto.Meta[218])

	obj.Pid = reader:ReadUInt64()
	obj.Name = reader:ReadString()
	obj.RaidName = reader:ReadString()
end
Auto.Reader[557] = function(reader, obj)
	setmetatable(obj, Auto.Meta[557])

	obj.Comment = reader:ReadString()
	obj.CommentId = reader:ReadUInt32()
	obj.IsFinish = reader:ReadBoolean()
end
Auto.Reader[183] = function(reader, obj)
	setmetatable(obj, Auto.Meta[183])

	obj.Id = reader:ReadUInt32()
	obj.PostType = reader:ReadByte()
	obj.PostConfigId = reader:ReadUInt32()
	obj.Date = reader:ReadUInt32()
	obj.ImageUrl = reader:ReadString()
	obj.Approved = reader:ReadBoolean()
	obj.Title = reader:ReadString()
	obj.Likes = reader:ReadUInt32()
	obj.Liked = reader:ReadBoolean()
	obj.LikeNpcs = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
	obj.Comments = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
	obj.PlayerComments = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[557])
	end)
	obj.IsRead = reader:ReadBoolean()
	obj.HasNewLike = reader:ReadBoolean()
	obj.AcquireCfgId = reader:ReadUInt32()
	obj.ActivityCfgId = reader:ReadUInt32()
	obj.IsStory = reader:ReadBoolean()
	obj.IsPinStory = reader:ReadBoolean()
end
Auto.Reader[558] = function(reader, obj)
	setmetatable(obj, Auto.Meta[558])

	obj.SwitchSpiritConfigId = reader:ReadUInt32()
	obj.PreSwitchSpiritType = reader:ReadByte()
	obj.DestructibleId = reader:ReadUInt64()
	obj.AgentId = reader:ReadUInt64()
	obj.NewSpiritConfigId = reader:ReadUInt32()
end
Auto.Reader[559] = function(reader, obj)
	setmetatable(obj, Auto.Meta[559])

	obj.IsActive = reader:ReadBoolean()
	obj.Name = reader:ReadString()
	obj.Script = reader:ReadBoolean()
end
Auto.Reader[560] = function(reader, obj)
	setmetatable(obj, Auto.Meta[560])

	obj.Name = reader:ReadString()
	obj.Value = reader:ReadString()
	obj.FieldType = reader:ReadString()
	obj.SelfType = reader:ReadString()
	obj.Exception = reader:ReadString()
	obj.CanWrite = reader:ReadBoolean()
	obj.Leaf = reader:ReadBoolean()
end
Auto.Reader[561] = function(reader, obj)
	setmetatable(obj, Auto.Meta[561])

	obj.Path = Base.ReadList(reader, function(r)
		return r:ReadInt32()
	end)
	obj.Name = reader:ReadString()
end
Auto.Reader[562] = function(reader, obj)
	setmetatable(obj, Auto.Meta[562])

	obj.CfgId = reader:ReadUInt32()
	obj.TaskId = reader:ReadUInt32()
	obj.AIVehicleInfos = Base.ReadDict(reader, function(r)
		return r:ReadUInt64()
	end, function(r)
		return r:ReadUInt32()
	end)
end
Auto.Reader[563] = function(reader, obj)
	setmetatable(obj, Auto.Meta[563])

	obj.raceName = reader:ReadString()
	obj.routeId = reader:ReadInt32()
	obj.discourageRatio = reader:ReadSingle()
	obj.discourageCD = reader:ReadSingle()
	obj.checkDiscourageLength = reader:ReadSingle()
	obj.checkDiscourageWidth = reader:ReadSingle()
	obj.checkDiscourageMinDeltaSpeed = reader:ReadSingle()
	obj.checkDiscourageMaxDeltaSpeed = reader:ReadSingle()
	obj.swayUnitTime = reader:ReadSingle()
	obj.swayTime = reader:ReadSingle()
	obj.Token = reader:ReadUInt64()
	obj.taskAIConfigId = reader:ReadUInt32()
	obj.defaultSpeed = reader:ReadSingle()
	obj.drivingFlags = reader:ReadInt32()
	obj.initSpeed = reader:ReadSingle()
	obj.initTaskAIBuffList = Base.ReadList(reader, function(r)
		return Base.ReadStruct(r, Auto.Reader[629])
	end)
	obj.commonParameters = Base.ReadStruct(reader, Auto.Reader[650])
end
Auto.Reader[114] = function(reader, obj)
	setmetatable(obj, Auto.Meta[114])

	obj.EnterRaidTime = reader:ReadUInt32()
	obj.BattleTime = reader:ReadDouble()
	obj.SpiritBattleDatas = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[604])
	end)
	obj.ElementEffectCount = reader:ReadUInt32()
end
Auto.Reader[564] = function(reader, obj)
	setmetatable(obj, Auto.Meta[564])

	obj.Id = reader:ReadUInt64()
	obj.TemplateId = reader:ReadUInt32()
	obj.Position = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.FacingDirection = reader:ReadSingle()
	obj.OwnerId = reader:ReadUInt64()
	obj.ManagedPid = reader:ReadUInt64()
	obj.NavTags = reader:ReadUInt32()
	obj.GroundData = Base.ReadStruct(reader, Auto.Reader[484])
	obj.ModelId = reader:ReadUInt32()
	obj.SkillId = reader:ReadInt32()
	obj.HSummonIndex = reader:ReadInt32()
	obj.SpoonAgentId = reader:ReadInt32()
	obj.SuitId = reader:ReadUInt32()
	obj.ParentId = reader:ReadUInt64()
	obj.SpoonIndex = reader:ReadUInt32()
	obj.AutoBackIndex = reader:ReadUInt32()
	obj.VehicleId = reader:ReadUInt64()
	obj.VehicleIndex = reader:ReadInt32()
	obj.SourceWeaponId = reader:ReadUInt64()
	obj.IsBorn = reader:ReadBoolean()
	obj.BattleAiS = reader:ReadBoolean()
	obj.agentSyncClientInfo = Base.ReadComplex(reader, Auto.Reader[236])
	obj.WeaponId = reader:ReadUInt32()
	obj.TransformAgentId = reader:ReadUInt64()
	obj.SpiritWearFashionsInfo = Base.ReadComplex(reader, Auto.Reader[129])
	obj.Begging = reader:ReadBoolean()
end
Auto.Reader[565] = function(reader, obj)
	setmetatable(obj, Auto.Meta[565])

	obj.Id = reader:ReadUInt64()
	obj.TemplateId = reader:ReadUInt32()
	obj.Position = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.FacingDirection = reader:ReadSingle()
	obj.OwnerId = reader:ReadUInt64()
	obj.ManagedPid = reader:ReadUInt64()
	obj.NavTags = reader:ReadUInt32()
	obj.GroundData = Base.ReadStruct(reader, Auto.Reader[484])
	obj.TransformAgentId = reader:ReadUInt64()
	obj.SpiritWearFashionsInfo = Base.ReadComplex(reader, Auto.Reader[129])
	obj.Begging = reader:ReadBoolean()
end
Auto.Reader[142] = function(reader, obj)
	setmetatable(obj, Auto.Meta[142])

	obj.CleaningProcess = reader:ReadSingle()
	obj.TaskId = reader:ReadUInt32()
	obj.DropId = reader:ReadUInt32()
	obj.StartTime = reader:ReadUInt32()
	obj.TotalSecond = reader:ReadUInt32()
	obj.RewardRate = reader:ReadSingle()
	obj.ProficiencyRate = reader:ReadSingle()
end
Auto.Reader[125] = function(reader, obj)
	setmetatable(obj, Auto.Meta[125])

	obj.RecordValueInfo = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return Base.ReadComplex(r, Auto.Reader[566])
	end)
end
Auto.Reader[566] = function(reader, obj)
	setmetatable(obj, Auto.Meta[566])

	obj.DoubleValueDic = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return r:ReadDouble()
	end)
end
Auto.Reader[567] = function(reader, obj)
	setmetatable(obj, Auto.Meta[567])

	obj.BelongPid = reader:ReadUInt64()
	obj.TargetRaidId = reader:ReadUInt32()
	obj.Type = reader:ReadByte()
	obj.TargetInstanceId = reader:ReadUInt64()
	obj.TargetPosition = Base.ReadStruct(reader, Auto.Reader.UXVector3)
end
Auto.Reader[568] = function(reader, obj)
	setmetatable(obj, Auto.Meta[568])

	obj.EntityId = reader:ReadUInt64()
	obj.SeatIndex = reader:ReadByte()
	obj.SeatState = reader:ReadByte()
	obj.DestroyRelated = reader:ReadBoolean()
end
Auto.Reader[569] = function(reader, obj)
	setmetatable(obj, Auto.Meta[569])

	obj.Id = reader:ReadUInt64()
	obj.Position = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.facingDirection = reader:ReadSingle()
	obj.Velocity = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.Bits = Base.ReadList(reader, function(r)
		return r:ReadByte()
	end)
end
Auto.Reader[570] = function(reader, obj)
	setmetatable(obj, Auto.Meta[570])

	obj.TargetUid = reader:ReadUInt64()
	obj.StraightLineDistance = reader:ReadSingle()
	obj.UseContinuousRam = reader:ReadBoolean()
	obj.Token = reader:ReadUInt64()
	obj.taskAIConfigId = reader:ReadUInt32()
	obj.defaultSpeed = reader:ReadSingle()
	obj.drivingFlags = reader:ReadInt32()
	obj.initSpeed = reader:ReadSingle()
	obj.initTaskAIBuffList = Base.ReadList(reader, function(r)
		return Base.ReadStruct(r, Auto.Reader[629])
	end)
	obj.commonParameters = Base.ReadStruct(reader, Auto.Reader[650])
end
Auto.Reader[571] = function(reader, obj)
	setmetatable(obj, Auto.Meta[571])

	obj.MinDistance = reader:ReadSingle()
	obj.MaxDistance = reader:ReadSingle()
	obj.Method = reader:ReadByte()
end
Auto.Reader[572] = function(reader, obj)
	setmetatable(obj, Auto.Meta[572])

	obj.Pid = reader:ReadUInt64()
	obj.Both = reader:ReadBoolean()
	obj.RemarkName = reader:ReadString()
end
Auto.Reader[573] = function(reader, obj)
	setmetatable(obj, Auto.Meta[573])

	obj.Uid = reader:ReadUInt64()
	obj.PointIndex = reader:ReadInt32()
	obj.CommandIndex = reader:ReadInt32()
	obj.Type = reader:ReadByte()
	obj.Cmd = Base.ReadStruct(reader, Auto.Reader[249])
end
Auto.Reader[574] = function(reader, obj)
	setmetatable(obj, Auto.Meta[574])

	obj.resetColoringTypeList = Base.ReadList(reader, function(r)
		return r:ReadByte()
	end)
end
Auto.Reader[575] = function(reader, obj)
	setmetatable(obj, Auto.Meta[575])

	obj.FashionId = reader:ReadUInt32()
	obj.resetFashionColoringSchemeInfoDict = Base.ReadDict(reader, function(r)
		return r:ReadByte()
	end, function(r)
		return Base.ReadStruct(r, Auto.Reader[574])
	end)
end
Auto.Reader[576] = function(reader, obj)
	setmetatable(obj, Auto.Meta[576])

	obj.RestaurantId = reader:ReadUInt32()
end
Auto.Reader[577] = function(reader, obj)
	setmetatable(obj, Auto.Meta[577])

	obj.CountryId = reader:ReadUInt32()
	obj.BlockId = reader:ReadUInt32()
	obj.SubQuestId = reader:ReadUInt32()
	obj.Count = reader:ReadInt32()
	obj.TotalCount = reader:ReadInt32()
	obj.InvestigatorGalleryId = reader:ReadUInt32()
end
Auto.Reader[578] = function(reader, obj)
	setmetatable(obj, Auto.Meta[578])

	obj.DropIdCnt = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return r:ReadUInt32()
	end)
	obj.ReasonTextId = reader:ReadUInt32()
	obj.FactionMerge = reader:ReadBoolean()
	obj.Money = reader:ReadInt32()
	obj.Gold = reader:ReadUInt32()
	obj.BindingGold = reader:ReadUInt32()
	obj.FreeGold = reader:ReadUInt32()
	obj.Items = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[454])
	end)
	obj.UrbanAbilityInfo = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[580])
	end)
	obj.UrbanAbilities = Base.ReadList(reader, function(r)
		return r:ReadInt32()
	end)
	obj.AbilityExpInfo = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return r:ReadUInt32()
	end)
	obj.FanInfo = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return r:ReadInt32()
	end)
	obj.FactionDispositionInfo = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return r:ReadInt32()
	end)
	obj.FactionInfluenceInfo = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return r:ReadInt32()
	end)
	obj.JobExpInfo = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return r:ReadUInt32()
	end)
	obj.NpcFavors = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return r:ReadUInt32()
	end)
	obj.OriginalNpcFavors = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return r:ReadUInt32()
	end)
	obj.Popularity = reader:ReadSingle()
	obj.EyeCoinRewardCount = reader:ReadUInt32()
	obj.CommonSpiritTalentExp = reader:ReadUInt32()
	obj.SpiritTalentExpInfo = Base.ReadComplex(reader, Auto.Reader[613])
end
Auto.Reader[579] = function(reader, obj)
	setmetatable(obj, Auto.Meta[579])

	obj.RaidId = reader:ReadUInt32()
	obj.TaskId = reader:ReadUInt32()
	obj.EventId = reader:ReadUInt32()
	obj.ChallengeId = reader:ReadUInt32()
	obj.NpcCultivationId = reader:ReadUInt32()
	obj.DropPct = reader:ReadSingle()
	obj.Pos = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.AchievementInfo = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
	obj.BadgeIdList = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
	obj.CollectionInfo = Base.ReadComplex(reader, Auto.Reader[577])
	obj.FactionIdChange = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return r:ReadUInt32()
	end)
end
Auto.Reader[45] = function(reader, obj)
	setmetatable(obj, Auto.Meta[45])

	obj.Reason = reader:ReadInt32()
	obj.RewardTemplate = reader:ReadUInt32()
	obj.FirstItemInfo = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
	obj.ExtraInfo = Base.ReadComplex(reader, Auto.Reader[579])
	obj.Reward = Base.ReadDict(reader, function(r)
		return r:ReadByte()
	end, function(r)
		return Base.ReadComplex(r, Auto.Reader[578])
	end)
end
Auto.Reader[580] = function(reader, obj)
	setmetatable(obj, Auto.Meta[580])

	obj.SpiritTemplateId = reader:ReadUInt32()
	obj.OriginalUrbanAbilities = Base.ReadList(reader, function(r)
		return r:ReadInt32()
	end)
	obj.UrbanAbilities = Base.ReadList(reader, function(r)
		return r:ReadInt32()
	end)
end
Auto.Reader[1] = function(reader, obj)
	setmetatable(obj, Auto.Meta[1])

	obj.Id = reader:ReadUInt64()
	obj.Content = reader:ReadString()
	obj.Interval = reader:ReadSingle()
	obj.CreateTime = reader:ReadUInt32()
	obj.StartTime = reader:ReadUInt32()
	obj.EndTime = reader:ReadUInt32()
end
Auto.Reader[128] = function(reader, obj)
	setmetatable(obj, Auto.Meta[128])

	obj.Id = reader:ReadUInt64()
	obj.ParentId = reader:ReadUInt64()
	obj.TargetId = reader:ReadUInt64()
	obj.DestructibleId = reader:ReadUInt64()
	obj.CreationId = reader:ReadUInt32()
	obj.ParentPosition = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.Rotate = reader:ReadSingle()
	obj.ClientEnterOrLeave = reader:ReadBoolean()
	obj.SourceSkillId = reader:ReadUInt32()
	obj.SourceDestructibleId = reader:ReadUInt64()
	obj.GadgetId = reader:ReadUInt64()
	obj.GadgetTransformId = reader:ReadInt32()
end
Auto.Reader[581] = function(reader, obj)
	setmetatable(obj, Auto.Meta[581])

	obj.FogValue = Base.ReadList(reader, function(r)
		return r:ReadByte()
	end)
	obj.All = reader:ReadBoolean()
	obj.LockCnt = reader:ReadInt32()
	obj.XSize = reader:ReadInt32()
	obj.ZSize = reader:ReadInt32()
	obj.TileSize = reader:ReadInt32()
end
Auto.Reader[582] = function(reader, obj)
	setmetatable(obj, Auto.Meta[582])

	obj.hosterInstanceId = reader:ReadUInt64()
	obj.sceneItemInstanceId = reader:ReadUInt64()
	obj.hosterPosition = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.isDestroyImmediately = reader:ReadBoolean()
	obj.yForce = reader:ReadSingle()
	obj.zForce = reader:ReadSingle()
	obj.gravity = reader:ReadSingle()
end
Auto.Reader[583] = function(reader, obj)
	setmetatable(obj, Auto.Meta[583])

	obj.Pid = reader:ReadUInt64()
	obj.FightSpiritId = reader:ReadUInt32()
	obj.AttractNpcPid = reader:ReadUInt64()
	obj.Index = reader:ReadInt32()
	obj.IsState = reader:ReadBoolean()
end
Auto.Reader[584] = function(reader, obj)
	setmetatable(obj, Auto.Meta[584])

	obj.Id = reader:ReadInt32()
	obj.Enable = reader:ReadBoolean()
end
Auto.Reader[585] = function(reader, obj)
	setmetatable(obj, Auto.Meta[585])

	obj.Score = reader:ReadInt32()
	obj.HoldsCount = reader:ReadInt32()
	obj.Holds = Base.ReadList(reader, function(r)
		return Base.ReadStruct(r, Auto.Reader[145])
	end)
	obj.Folds = Base.ReadList(reader, function(r)
		return Base.ReadStruct(r, Auto.Reader[145])
	end)
	obj.Sequence = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[480])
	end)
	obj.ReachFoldCnt = reader:ReadInt32()
	obj.Que = reader:ReadByte()
	obj.HuanPais = Base.ReadList(reader, function(r)
		return Base.ReadStruct(r, Auto.Reader[145])
	end)
	obj.HuPais = Base.ReadList(reader, function(r)
		return Base.ReadStruct(r, Auto.Reader[145])
	end)
end
Auto.Reader[586] = function(reader, obj)
	setmetatable(obj, Auto.Meta[586])

	obj.Min = Base.ReadStruct(reader, Auto.Reader[426])
	obj.Max = Base.ReadStruct(reader, Auto.Reader[426])
end
Auto.Reader[587] = function(reader, obj)
	setmetatable(obj, Auto.Meta[587])

	obj.x = reader:ReadSingle()
	obj.y = reader:ReadSingle()
	obj.z = reader:ReadSingle()
	obj.w = reader:ReadSingle()
end
Auto.Reader[556] = function(reader, obj)
	setmetatable(obj, Auto.Meta[556])

	obj.EffectId = reader:ReadUInt32()
	obj.InstanceId = reader:ReadUInt64()
	obj.LogicEndTime = reader:ReadDouble()
	obj.ReleaserId = reader:ReadUInt64()
	obj.ClientDestructibleId = reader:ReadUInt64()
	obj.Duration = reader:ReadSingle()
end
Auto.Reader[588] = function(reader, obj)
	setmetatable(obj, Auto.Meta[588])

	obj.MinX = reader:ReadInt32()
	obj.MinZ = reader:ReadInt32()
	obj.MaxX = reader:ReadInt32()
	obj.MaxZ = reader:ReadInt32()
end
Auto.Reader[589] = function(reader, obj)
	setmetatable(obj, Auto.Meta[589])

	obj.AgentId = reader:ReadUInt64()
	obj.Emotion = reader:ReadUInt32()
	obj.State = reader:ReadUInt32()
end
Auto.Reader[590] = function(reader, obj)
	setmetatable(obj, Auto.Meta[590])

	obj.ItemId = reader:ReadUInt32()
	obj.UnbindMoney = reader:ReadInt32()
	obj.BindGold = reader:ReadUInt32()
	obj.PayGold = reader:ReadUInt32()
	obj.FreeGold = reader:ReadUInt32()
	obj.Exp = reader:ReadUInt32()
	obj.WeaponId = reader:ReadUInt32()
end
Auto.Reader[162] = function(reader, obj)
	setmetatable(obj, Auto.Meta[162])

	obj.PostId = reader:ReadUInt32()
	obj.CommentId = reader:ReadUInt32()
	obj.MessageType = reader:ReadInt32()
end
Auto.Reader[591] = function(reader, obj)
	setmetatable(obj, Auto.Meta[591])

	obj.EntityId = reader:ReadUInt64()
	obj.TimeStamp = reader:ReadSingle()
	obj.Position = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.facingDirection = reader:ReadSingle()
end
Auto.Reader[592] = function(reader, obj)
	setmetatable(obj, Auto.Meta[592])

	obj.Id = reader:ReadInt32()
	obj.ReleaserId = reader:ReadUInt64()
	obj.TriggerIndex = reader:ReadInt32()
	obj.Position = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.Facing = reader:ReadSingle()
end
Auto.Reader[131] = function(reader, obj)
	setmetatable(obj, Auto.Meta[131])

	obj.Id = reader:ReadInt32()
	obj.TemplateId = reader:ReadUInt32()
	obj.PathId = reader:ReadInt32()
	obj.ReleaserId = reader:ReadUInt64()
	obj.TriggerIndex = reader:ReadInt32()
	obj.Position = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.Facing = Base.ReadStruct(reader, Auto.Reader.UXVector3)
end
Auto.Reader[593] = function(reader, obj)
	setmetatable(obj, Auto.Meta[593])

	obj.SkillId = reader:ReadInt32()
	obj.ReleaserId = reader:ReadUInt64()
	obj.TriggerIndex = reader:ReadInt32()
	obj.ParentTriggerIndex = reader:ReadInt32()
	obj.TargetId = reader:ReadUInt64()
	obj.StiffId = reader:ReadUInt32()
end
Auto.Reader[594] = function(reader, obj)
	setmetatable(obj, Auto.Meta[594])

	obj.ReleaserId = reader:ReadUInt64()
	obj.Id = reader:ReadInt32()
	obj.SkillId = reader:ReadUInt32()
	obj.TriggerIndex = reader:ReadInt32()
	obj.TriggerInstanceId = reader:ReadUInt64()
	obj.Stage = reader:ReadInt32()
	obj.HitTarget = reader:ReadUInt64()
	obj.HitDestructible = reader:ReadUInt64()
	obj.AttachedDestructibleId = reader:ReadUInt64()
	obj.ClientHitPosition = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.ClientHitPosNormalDir = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.SkillHitType = reader:ReadByte()
	obj.HitMaterial = reader:ReadInt32()
	obj.HitCenter = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.StiffId = reader:ReadUInt32()
	obj.StiffTime = reader:ReadSingle()
	obj.HurtEffectId = reader:ReadUInt32()
	obj.FirmHurt = reader:ReadSingle()
	obj.ShieldDefendIndex = reader:ReadInt32()
	obj.IsBackHit = reader:ReadBoolean()
end
Auto.Reader[595] = function(reader, obj)
	setmetatable(obj, Auto.Meta[595])

	obj.entityId = reader:ReadUInt64()
	obj.targetId = reader:ReadUInt64()
	obj.moveId = reader:ReadInt32()
	obj.instanceId = reader:ReadInt32()
	obj.select = reader:ReadUInt32()
	obj.targetDestructibleId = reader:ReadUInt64()
	obj.skillId = reader:ReadUInt32()
	obj.unitPartIndex = reader:ReadInt32()
	obj.rotate = reader:ReadSingle()
	obj.unitPosition = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.location = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.faceToPos = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.destructibleTemplateId = reader:ReadUInt32()
	obj.DesignerPosList = Base.ReadList(reader, function(r)
		return Base.ReadStruct(r, Auto.Reader.UXVector3)
	end)
	obj.SectionRepeatTimes = reader:ReadUInt32()
	obj.SeqConfigID = reader:ReadUInt32()
	obj.SelfMobilityPos = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.TarMobilityPos = Base.ReadStruct(reader, Auto.Reader.UXVector3)
end
Auto.Reader[596] = function(reader, obj)
	setmetatable(obj, Auto.Meta[596])

	obj.SkillInstanceId = reader:ReadInt32()
end
Auto.Reader[597] = function(reader, obj)
	setmetatable(obj, Auto.Meta[597])

	obj.SkillInstanceId = reader:ReadInt32()
	obj.ReleaserId = reader:ReadUInt64()
	obj.StateIds = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
end
Auto.Reader[598] = function(reader, obj)
	setmetatable(obj, Auto.Meta[598])

	obj.SkillInstanceId = reader:ReadInt32()
	obj.ReleaserId = reader:ReadUInt64()
	obj.TriggerIndex = reader:ReadInt32()
	obj.Position = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.Facing = reader:ReadSingle()
end
Auto.Reader[599] = function(reader, obj)
	setmetatable(obj, Auto.Meta[599])

	obj.Id = reader:ReadInt32()
	obj.ReleaserId = reader:ReadUInt64()
	obj.TriggerIndex = reader:ReadInt32()
end
Auto.Reader[600] = function(reader, obj)
	setmetatable(obj, Auto.Meta[600])

	obj.Releaser = reader:ReadUInt64()
	obj.Location = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.Facing = reader:ReadSingle()
	obj.TargetId = reader:ReadUInt64()
	obj.UnitPartIndex = reader:ReadInt32()
	obj.TargetDestructibleId = reader:ReadUInt64()
	obj.AttachDestructibleId = reader:ReadUInt64()
	obj.SkillId = reader:ReadUInt32()
	obj.SkillInstanceId = reader:ReadInt32()
end
Auto.Reader[601] = function(reader, obj)
	setmetatable(obj, Auto.Meta[601])

	obj.SpawnArea = Base.ReadComplex(reader, Auto.Reader[470])
	obj.Selected = reader:ReadBoolean()
end
Auto.Reader[602] = function(reader, obj)
	setmetatable(obj, Auto.Meta[602])

	obj.SpawnLaneType = reader:ReadByte()
	obj.FirstArea = Base.ReadStruct(reader, Auto.Reader[237])
	obj.SecondArea = Base.ReadStruct(reader, Auto.Reader[237])
end
Auto.Reader[603] = function(reader, obj)
	setmetatable(obj, Auto.Meta[603])

	obj.TargetUid = reader:ReadUInt64()
	obj.Token = reader:ReadUInt64()
	obj.taskAIConfigId = reader:ReadUInt32()
	obj.defaultSpeed = reader:ReadSingle()
	obj.drivingFlags = reader:ReadInt32()
	obj.initSpeed = reader:ReadSingle()
	obj.initTaskAIBuffList = Base.ReadList(reader, function(r)
		return Base.ReadStruct(r, Auto.Reader[629])
	end)
	obj.commonParameters = Base.ReadStruct(reader, Auto.Reader[650])
end
Auto.Reader[60] = function(reader, obj)
	setmetatable(obj, Auto.Meta[60])

	obj.TemplateId = reader:ReadUInt32()
	obj.Exp = reader:ReadUInt32()
	obj.NewLevel = reader:ReadBoolean()
	obj.ConfirmedLevel = reader:ReadUInt32()
	obj.Level = reader:ReadUInt32()
	obj.BuffList = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
	obj.AbilityBuffConfigIdList = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
end
Auto.Reader[110] = function(reader, obj)
	setmetatable(obj, Auto.Meta[110])

	obj.SpiritTid = reader:ReadUInt32()
	obj.SpiritUid = reader:ReadUInt64()
	obj.SlotIndex = reader:ReadInt32()
	obj.Weapon = Base.ReadComplex(reader, Auto.Reader[668])
end
Auto.Reader[9] = function(reader, obj)
	setmetatable(obj, Auto.Meta[9])

	obj.BartenderId2ElementInfosDict = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return Base.ReadComplex(r, Auto.Reader[20])
	end)
	obj.BartenderId2GameInfosDict = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return Base.ReadComplex(r, Auto.Reader[243])
	end)
end
Auto.Reader[604] = function(reader, obj)
	setmetatable(obj, Auto.Meta[604])

	obj.TemplateId = reader:ReadUInt32()
	obj.Level = reader:ReadUInt32()
	obj.StoneLevel = reader:ReadUInt32()
	obj.TotalDamage = reader:ReadUInt32()
	obj.HighestDamage = reader:ReadUInt32()
	obj.TotalHeal = reader:ReadUInt32()
	obj.TotalDamaged = reader:ReadUInt32()
end
Auto.Reader[605] = function(reader, obj)
	setmetatable(obj, Auto.Meta[605])

	obj.IsUniqueSkillLocked = reader:ReadBoolean()
end
Auto.Reader[90] = function(reader, obj)
	setmetatable(obj, Auto.Meta[90])

	obj.SpiritInfo = Base.ReadComplex(reader, Auto.Reader[25])
end
Auto.Reader[606] = function(reader, obj)
	setmetatable(obj, Auto.Meta[606])

	obj.SpiritId = reader:ReadUInt32()
	obj.FashionCustomSuitSchemeInfos = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[416])
	end)
	obj.FashionFunctionSuitSchemeInfoDict = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return Base.ReadComplex(r, Auto.Reader[418])
	end)
	obj.SpiritWearFashionsInfo = Base.ReadComplex(reader, Auto.Reader[46])
	obj.SpiritPrevWearFashionsInfo = Base.ReadComplex(reader, Auto.Reader[46])
	obj.FirstGainSuitIdList = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
	obj.EnableClientTryWearCount = reader:ReadByte()
end
Auto.Reader[607] = function(reader, obj)
	setmetatable(obj, Auto.Meta[607])

	obj.FightStyleInfo = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return r:ReadUInt32()
	end)
end
Auto.Reader[608] = function(reader, obj)
	setmetatable(obj, Auto.Meta[608])

	obj.spiritId = reader:ReadUInt32()
	obj.fullInfo = Base.ReadComplex(reader, Auto.Reader[607])
	obj.addOrUpdateInfo = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return r:ReadUInt32()
	end)
end
Auto.Reader[14] = function(reader, obj)
	setmetatable(obj, Auto.Meta[14])

	obj.Id = reader:ReadUInt32()
	obj.CreateTime = reader:ReadUInt32()
end
Auto.Reader[11] = function(reader, obj)
	setmetatable(obj, Auto.Meta[11])

	obj.HackerName = reader:ReadString()
	obj.PostInfos = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return Base.ReadComplex(r, Auto.Reader[448])
	end)
	obj.Rank = reader:ReadUInt32()
	obj.DailyCounts = Base.ReadComplex(reader, Auto.Reader[384])
end
Auto.Reader[25] = function(reader, obj)
	setmetatable(obj, Auto.Meta[25])

	obj.Id = reader:ReadUInt64()
	obj.TemplateId = reader:ReadUInt32()
	obj.PossessTime = reader:ReadUInt32()
	obj.HpRate = reader:ReadSingle()
	obj.SpiritUrbanSkill = Base.ReadComplex(reader, Auto.Reader[615])
	obj.SpiritAbilities = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return Base.ReadComplex(r, Auto.Reader[60])
	end)
	obj.SpiritJobInfo = Base.ReadComplex(reader, Auto.Reader[610])
	obj.PermanentAddAttributes = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return r:ReadSingle()
	end)
	obj.InfoBadge = Base.ReadComplex(reader, Auto.Reader[534])
	obj.MobileSkinInfo = Base.ReadComplex(reader, Auto.Reader[81])
	obj.WeaponSlots = Base.ReadList(reader, Auto.Dispatch[69])
	obj.EverSwitched = reader:ReadBoolean()
	obj.CurrentJobId = reader:ReadUInt32()
	obj.SpiritBattleInfo = Base.ReadComplex(reader, Auto.Reader[605])
	obj.TalentInfo = Base.ReadComplex(reader, Auto.Reader[614])
	obj.SpiritFightStyle = Base.ReadComplex(reader, Auto.Reader[607])
	obj.Blocked = reader:ReadBoolean()
end
Auto.Reader[609] = function(reader, obj)
	setmetatable(obj, Auto.Meta[609])

	obj.Id = reader:ReadUInt64()
	obj.TemplateId = reader:ReadUInt32()
	obj.IsActive = reader:ReadBoolean()
	obj.WeaponTemplateId = reader:ReadUInt32()
	obj.WeaponSkinId = reader:ReadUInt32()
end
Auto.Reader[26] = function(reader, obj)
	setmetatable(obj, Auto.Meta[26])

	obj.Job = reader:ReadUInt32()
	obj.Exp = reader:ReadUInt32()
	obj.Level = reader:ReadByte()
	obj.RegisterTime = reader:ReadUInt32()
	obj.UnregisterTime = reader:ReadUInt32()
	obj.TalentInfo = Auto.Dispatch[611](reader)
end
Auto.Reader[610] = function(reader, obj)
	setmetatable(obj, Auto.Meta[610])

	obj.CurrentJob = reader:ReadUInt32()
	obj.AvailableJobs = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return Base.ReadComplex(r, Auto.Reader[26])
	end)
	obj.HistoryJobs = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return Base.ReadComplex(r, Auto.Reader[26])
	end)
end
Auto.Reader[611] = function(reader, obj)
	setmetatable(obj, Auto.Meta[611])

	obj.TalentPoint = reader:ReadUInt32()
	obj.UnlockTalentInfoDict = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return Base.ReadComplex(r, Auto.Reader[612])
	end)
	obj.SpentTalentPoint = reader:ReadUInt32()
end
Auto.Reader[81] = function(reader, obj)
	setmetatable(obj, Auto.Meta[81])

	obj.Wallpaper = reader:ReadUInt32()
	obj.Decoration = reader:ReadUInt32()
	obj.Pendant = reader:ReadUInt32()
end
Auto.Reader[612] = function(reader, obj)
	setmetatable(obj, Auto.Meta[612])

	obj.TalentId = reader:ReadUInt32()
	obj.Layer = reader:ReadUInt32()
end
Auto.Reader[181] = function(reader, obj)
	setmetatable(obj, Auto.Meta[181])

	obj.FightSpiritId = reader:ReadUInt32()
	obj.UrbanAttrs = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return r:ReadSingle()
	end)
	obj.MaxHp = reader:ReadSingle()
	obj.Dam = reader:ReadSingle()
	obj.DefDeduct = reader:ReadSingle()
end
Auto.Reader[3] = function(reader, obj)
	setmetatable(obj, Auto.Meta[3])

	obj.DispatchInfos = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return Base.ReadComplex(r, Auto.Reader[48])
	end)
	obj.ViolationInfos = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[51])
	end)
	obj.CaseInfos = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[59])
	end)
	obj.DutyBasicInfo = Base.ReadComplex(reader, Auto.Reader[552])
	obj.EscortedNpcs = Base.ReadList(reader, function(r)
		return r:ReadUInt64()
	end)
	obj.PoliceFakeFileInfo = Base.ReadComplex(reader, Auto.Reader[67])
	obj.PeriodInvalidVehicleFine2CountDict = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return r:ReadUInt32()
	end)
	obj.NextPeriodUpdateTime = reader:ReadUInt32()
end
Auto.Reader[101] = function(reader, obj)
	setmetatable(obj, Auto.Meta[101])

	obj.SpiritTid = reader:ReadUInt32()
	obj.SpiritUid = reader:ReadUInt64()
	obj.WeaponUid = reader:ReadUInt64()
	obj.Reason = reader:ReadByte()
end
Auto.Reader[133] = function(reader, obj)
	setmetatable(obj, Auto.Meta[133])

	obj.SpiritUid = reader:ReadUInt64()
	obj.WeaponInstanceId = reader:ReadUInt64()
	obj.Reason = reader:ReadByte()
end
Auto.Reader[613] = function(reader, obj)
	setmetatable(obj, Auto.Meta[613])

	obj.SpiritId = reader:ReadUInt32()
	obj.TalentExp = reader:ReadUInt32()
end
Auto.Reader[614] = function(reader, obj)
	setmetatable(obj, Auto.Meta[614])

	obj.Exp = reader:ReadUInt32()
	obj.Level = reader:ReadUInt32()
	obj.TalentPoint = reader:ReadUInt32()
	obj.UnlockTalentInfoDict = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return Base.ReadComplex(r, Auto.Reader[612])
	end)
	obj.SpentTalentPoint = reader:ReadUInt32()
end
Auto.Reader[119] = function(reader, obj)
	setmetatable(obj, Auto.Meta[119])

	obj.SpiritTid = reader:ReadUInt32()
	obj.SpiritUid = reader:ReadUInt64()
	obj.Weapon = Base.ReadComplex(reader, Auto.Reader[668])
end
Auto.Reader[615] = function(reader, obj)
	setmetatable(obj, Auto.Meta[615])

	obj.UrbanAbilities = Base.ReadList(reader, function(r)
		return r:ReadInt32()
	end)
end
Auto.Reader[616] = function(reader, obj)
	setmetatable(obj, Auto.Meta[616])

	obj.SpiritId = reader:ReadUInt32()
	obj.FightStyleTypeId = reader:ReadUInt32()
	obj.FightStyleId = reader:ReadUInt32()
	obj.EventId = reader:ReadUInt32()
end
Auto.Reader[117] = function(reader, obj)
	setmetatable(obj, Auto.Meta[117])

	obj.SpiritTid = reader:ReadUInt32()
	obj.SpiritUid = reader:ReadUInt64()
	obj.CurrentWeaponUid = reader:ReadUInt64()
	obj.WeaponSlots = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[668])
	end)
	obj.CurrentTempWeapon = Base.ReadComplex(reader, Auto.Reader[668])
	obj.TempWeaponSlots = Base.ReadComplex(reader, Auto.Reader[669])
end
Auto.Reader[46] = function(reader, obj)
	setmetatable(obj, Auto.Meta[46])

	obj.FunctionSuitId = reader:ReadUInt32()
	obj.IsTryWear = reader:ReadBoolean()
	obj.WearFashionInfoList = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[193])
	end)
	obj.WearFashionEditInfoList = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[180])
	end)
	obj.HiddenParts = reader:ReadByte()
	obj.EditedHiddenParts = reader:ReadByte()
end
Auto.Reader[617] = function(reader, obj)
	setmetatable(obj, Auto.Meta[617])

	obj.PortToValue = Base.ReadDict(reader, function(r)
		return r:ReadInt32()
	end, function(r)
		return r:ReadString()
	end)
	obj.Position = Base.ReadStruct(reader, Auto.Reader.UXVector3)
end
Auto.Reader[113] = function(reader, obj)
	setmetatable(obj, Auto.Meta[113])

	obj.NodeTaskId = reader:ReadUInt32()
	obj.ContextTaskId = reader:ReadUInt32()
	obj.EventId = reader:ReadUInt32()
	obj.Pid2Index = Base.ReadDict(reader, function(r)
		return r:ReadUInt64()
	end, function(r)
		return r:ReadInt32()
	end)
end
Auto.Reader[618] = function(reader, obj)
	setmetatable(obj, Auto.Meta[618])

	obj.Enemies = Base.ReadDict(reader, function(r)
		return r:ReadInt32()
	end, function(r)
		return r:ReadUInt64()
	end)
	obj.Npcs = Base.ReadDict(reader, function(r)
		return r:ReadInt32()
	end, function(r)
		return r:ReadUInt64()
	end)
	obj.TriggerInfos = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[620])
	end)
	obj.SpoonRooms = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[584])
	end)
	obj.InteractiveNpcs = Base.ReadDict(reader, function(r)
		return r:ReadUInt32()
	end, function(r)
		return r:ReadBoolean()
	end)
end
Auto.Reader[619] = function(reader, obj)
	setmetatable(obj, Auto.Meta[619])

	obj.Name = reader:ReadString()
	obj.NextNodes = Base.ReadList(reader, function(r)
		return r:ReadInt32()
	end)
end
Auto.Reader[116] = function(reader, obj)
	setmetatable(obj, Auto.Meta[116])

	obj.TriggerInfos = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[620])
	end)
	obj.Enemies = Base.ReadDict(reader, function(r)
		return r:ReadInt32()
	end, function(r)
		return r:ReadUInt64()
	end)
	obj.SpoonRooms = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[584])
	end)
	obj.RemovedNpcList = Base.ReadList(reader, function(r)
		return r:ReadInt32()
	end)
	obj.VehicleIdDict = Base.ReadDict(reader, function(r)
		return r:ReadInt32()
	end, function(r)
		return r:ReadInt32()
	end)
	obj.TaskId = reader:ReadUInt32()
	obj.EventId = reader:ReadUInt32()
end
Auto.Reader[620] = function(reader, obj)
	setmetatable(obj, Auto.Meta[620])

	obj.FlowIndex = reader:ReadInt32()
	obj.NodeId = reader:ReadInt32()
	obj.StartTime = reader:ReadUInt32()
	obj.NeedComplete = reader:ReadBoolean()
	obj.MemoryTaskId = reader:ReadUInt32()
	obj.IsCondition = reader:ReadBoolean()
	obj.Ports = Base.ReadList(reader, Auto.Dispatch[112])
end
Auto.Reader[621] = function(reader, obj)
	setmetatable(obj, Auto.Meta[621])

	obj.UnitUid = reader:ReadUInt64()
	obj.AttractPointUid = reader:ReadUInt64()
	obj.AttractPointId = reader:ReadUInt32()
	obj.CenterPosition = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.CenterAngle = reader:ReadSingle()
	obj.GroupIndex = reader:ReadInt32()
	obj.PointIndex = reader:ReadInt32()
	obj.CommandIndex = reader:ReadInt32()
	obj.MetroId = reader:ReadInt32()
	obj.CarriageIndex = reader:ReadInt32()
end
Auto.Reader[622] = function(reader, obj)
	setmetatable(obj, Auto.Meta[622])

	obj.Uid = reader:ReadUInt64()
	obj.FileName = reader:ReadString()
	obj.HashCode = reader:ReadInt32()
	obj.SeqIndex = reader:ReadInt32()
	obj.GroupIndex = reader:ReadInt32()
	obj.PointIndex = reader:ReadInt32()
	obj.CommandIndex = reader:ReadInt32()
	obj.Loop = reader:ReadBoolean()
	obj.Return = reader:ReadBoolean()
end
Auto.Reader[623] = function(reader, obj)
	setmetatable(obj, Auto.Meta[623])

	obj.GroupId = reader:ReadInt32()
	obj.Pack = Base.ReadComplex(reader, Auto.Reader[501])
	obj.InstanceId = reader:ReadUInt64()
	obj.UniqueId = reader:ReadUInt64()
	obj.CfgId = reader:ReadUInt32()
	obj.PathId = reader:ReadInt32()
	obj.Position = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.Facing = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.iScale = reader:ReadInt32()
	obj.Hp = reader:ReadSingle()
	obj.NavId = reader:ReadInt32()
	obj.State = reader:ReadByte()
	obj.BreakStage = reader:ReadUInt32()
	obj.OccupantInfos = Base.ReadList(reader, function(r)
		return Base.ReadStruct(r, Auto.Reader[583])
	end)
	obj.DropWeaponId = reader:ReadUInt64()
	obj.EffectIds = Base.ReadList(reader, function(r)
		return r:ReadInt32()
	end)
end
Auto.Reader[624] = function(reader, obj)
	setmetatable(obj, Auto.Meta[624])

	obj.Source = Base.ReadStruct(reader, Auto.Reader[314])
	obj.Source2 = Base.ReadStruct(reader, Auto.Reader[314])
end
Auto.Reader[625] = function(reader, obj)
	setmetatable(obj, Auto.Meta[625])

	obj.StopRatio = reader:ReadSingle()
	obj.useThrottleStop = reader:ReadBoolean()
	obj.Token = reader:ReadUInt64()
	obj.taskAIConfigId = reader:ReadUInt32()
	obj.defaultSpeed = reader:ReadSingle()
	obj.drivingFlags = reader:ReadInt32()
	obj.initSpeed = reader:ReadSingle()
	obj.initTaskAIBuffList = Base.ReadList(reader, function(r)
		return Base.ReadStruct(r, Auto.Reader[629])
	end)
	obj.commonParameters = Base.ReadStruct(reader, Auto.Reader[650])
end
Auto.Reader[209] = function(reader, obj)
	setmetatable(obj, Auto.Meta[209])

	obj.VehicleEntityId = reader:ReadUInt64()
	obj.TaskToken = reader:ReadUInt64()
end
Auto.Reader[626] = function(reader, obj)
	setmetatable(obj, Auto.Meta[626])

	obj.Position = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.Facing = reader:ReadSingle()
	obj.Pid = reader:ReadInt32()
	obj.NpcFormworkId = reader:ReadUInt32()
end
Auto.Reader[205] = function(reader, obj)
	setmetatable(obj, Auto.Meta[205])

	obj.HaveSeenList = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
	obj.TicketInfo = Base.ReadComplex(reader, Auto.Reader[274])
	obj.InviteNpcId = reader:ReadUInt64()
	obj.UnlockMovies = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
end
Auto.Reader[203] = function(reader, obj)
	setmetatable(obj, Auto.Meta[203])

	obj.LastestMovieId = reader:ReadUInt32()
	obj.LastestMovieStartTime = reader:ReadUInt32()
	obj.TicketInfo = Base.ReadComplex(reader, Auto.Reader[273])
end
Auto.Reader[627] = function(reader, obj)
	setmetatable(obj, Auto.Meta[627])

	obj.PlateInlineId = reader:ReadInt32()
	obj.GroupId = reader:ReadUInt64()
	obj.TriggerTag = reader:ReadString()
	obj.NpcPhoneId = reader:ReadUInt32()
	obj.ExternalSystemLinkId = reader:ReadUInt32()
	obj.NoSleep = reader:ReadBoolean()
	obj.MetroLineId = reader:ReadUInt32()
	obj.MetroCarriageId = reader:ReadUInt32()
	obj.MetroLineCarriageInfo = Base.ReadComplex(reader, Auto.Reader[477])
	obj.ExposeParams = Base.ReadDict(reader, function(r)
		return r:ReadInt32()
	end, function(r)
		return r:ReadString()
	end)
	obj.InstanceId = reader:ReadUInt64()
	obj.UniqueId = reader:ReadUInt64()
	obj.CfgId = reader:ReadUInt32()
	obj.PathId = reader:ReadInt32()
	obj.Position = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.Facing = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.iScale = reader:ReadInt32()
	obj.Hp = reader:ReadSingle()
	obj.NavId = reader:ReadInt32()
	obj.State = reader:ReadByte()
	obj.BreakStage = reader:ReadUInt32()
	obj.OccupantInfos = Base.ReadList(reader, function(r)
		return Base.ReadStruct(r, Auto.Reader[583])
	end)
	obj.DropWeaponId = reader:ReadUInt64()
	obj.EffectIds = Base.ReadList(reader, function(r)
		return r:ReadInt32()
	end)
end
Auto.Reader[628] = function(reader, obj)
	setmetatable(obj, Auto.Meta[628])

	obj.EventId = reader:ReadUInt32()
	obj.TaskId = reader:ReadUInt32()
	obj.Visible = reader:ReadBoolean()
	obj.IsRiskControl = reader:ReadBoolean()
	obj.Acceptable = reader:ReadBoolean()
	obj.HasAccepted = reader:ReadBoolean()
	obj.RedPoint = reader:ReadBoolean()
	obj.UnlockTime = reader:ReadUInt32()
	obj.IsUnderway = reader:ReadBoolean()
	obj.FinishedChoiceLs = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
	obj.Conflict = reader:ReadBoolean()
	obj.IsRepeat = reader:ReadBoolean()
end
Auto.Reader[13] = function(reader, obj)
	setmetatable(obj, Auto.Meta[13])

	obj.BelongTaskId = reader:ReadUInt32()
	obj.Type = reader:ReadByte()
	obj.Position = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.EnemyId = reader:ReadUInt64()
	obj.NpcSpoonId = reader:ReadInt32()
	obj.NpcId = reader:ReadUInt64()
end
Auto.Reader[137] = function(reader, obj)
	setmetatable(obj, Auto.Meta[137])

	obj.SpoonMd5 = reader:ReadString()
	obj.SpRaidId = reader:ReadUInt32()
	obj.StartTaskId = reader:ReadUInt32()
	obj.EndTaskId = reader:ReadUInt32()
	obj.Alias = reader:ReadString()
	obj.EventId = reader:ReadUInt32()
	obj.EventStartTaskId = reader:ReadUInt32()
end
Auto.Reader[29] = function(reader, obj)
	setmetatable(obj, Auto.Meta[29])

	obj.State = reader:ReadByte()
	obj.Reason = reader:ReadByte()
	obj.FailTextId = reader:ReadUInt32()
	obj.CanSkip = reader:ReadBoolean()
end
Auto.Reader[85] = function(reader, obj)
	setmetatable(obj, Auto.Meta[85])

	obj.TaskEventId = reader:ReadUInt32()
	obj.TaskId = reader:ReadUInt32()
end
Auto.Reader[629] = function(reader, obj)
	setmetatable(obj, Auto.Meta[629])

	obj.configId = reader:ReadUInt32()
	obj.duration = reader:ReadSingle()
end
Auto.Reader[630] = function(reader, obj)
	setmetatable(obj, Auto.Meta[630])

	obj.Index = reader:ReadInt32()
	obj.Value = reader:ReadInt32()
	obj.ConfigValue = reader:ReadInt32()
	obj.Duty = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
	obj.WaitOtherCounter = reader:ReadBoolean()
	obj.WaitOtherTask = reader:ReadBoolean()
	obj.Parent = reader:ReadInt32()
	obj.Child = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[630])
	end)
end
Auto.Reader[38] = function(reader, obj)
	setmetatable(obj, Auto.Meta[38])

	obj.TaskId = reader:ReadUInt32()
	obj.CounterValues = Base.ReadList(reader, function(r)
		return r:ReadInt32()
	end)
	obj.Counters = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[630])
	end)
	obj.State = reader:ReadByte()
	obj.RecoverResource = reader:ReadBoolean()
	obj.SpoonViewInfo = Base.ReadComplex(reader, Auto.Reader[137])
end
Auto.Reader[631] = function(reader, obj)
	setmetatable(obj, Auto.Meta[631])

	obj.AgentSpoonIds = Base.ReadList(reader, function(r)
		return r:ReadInt32()
	end)
	obj.Gadgets = Base.ReadList(reader, function(r)
		return r:ReadUInt64()
	end)
	obj.SceneItems = Base.ReadList(reader, function(r)
		return r:ReadUInt64()
	end)
	obj.VehicleSpoonIds = Base.ReadList(reader, function(r)
		return r:ReadInt32()
	end)
	obj.DynamicGoIds = Base.ReadList(reader, function(r)
		return r:ReadInt32()
	end)
end
Auto.Reader[5] = function(reader, obj)
	setmetatable(obj, Auto.Meta[5])

	obj.AllowMemberInvite = reader:ReadBoolean()
	obj.AutoApplyJoin = reader:ReadBoolean()
end
Auto.Reader[189] = function(reader, obj)
	setmetatable(obj, Auto.Meta[189])

	obj.PersonalTimeSettings = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[507])
	end)
end
Auto.Reader[632] = function(reader, obj)
	setmetatable(obj, Auto.Meta[632])

	obj.Aid = reader:ReadInt32()
	obj.Pid = reader:ReadUInt64()
	obj.Ip = reader:ReadString()
	obj.Port = reader:ReadInt32()
	obj.Token = reader:ReadString()
	obj.RC4Key = reader:ReadString()
	obj.GateServerId = reader:ReadInt32()
	obj.AccountId = reader:ReadString()
end
Auto.Reader[33] = function(reader, obj)
	setmetatable(obj, Auto.Meta[33])

	obj.Type = reader:ReadByte()
	obj.RaidId = reader:ReadUInt32()
	obj.SpoonId = reader:ReadInt32()
	obj.Position = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.MapEntranceId = reader:ReadUInt32()
	obj.PosId = reader:ReadUInt64()
	obj.EnemyInstanceId = reader:ReadUInt64()
	obj.RefreshConfigId = reader:ReadUInt32()
	obj.EnemyTemplateId = reader:ReadUInt32()
	obj.TriggerEnemyState = reader:ReadByte()
	obj.IndoorId = reader:ReadUInt32()
end
Auto.Reader[633] = function(reader, obj)
	setmetatable(obj, Auto.Meta[633])

	obj.Index = reader:ReadInt32()
	obj.CrosswalkControlIndex = reader:ReadInt32()
	obj.VehicleControlIndex = reader:ReadInt32()
end
Auto.Reader[634] = function(reader, obj)
	setmetatable(obj, Auto.Meta[634])

	obj.TrafficLightControls = Base.ReadList(reader, function(r)
		return Base.ReadStruct(r, Auto.Reader[469])
	end)
	obj.VehicleLanesOpen = Base.ReadList(reader, function(r)
		return r:ReadInt32()
	end)
end
Auto.Reader[635] = function(reader, obj)
	setmetatable(obj, Auto.Meta[635])

	obj.AcceptedEventId = reader:ReadUInt32()
	obj.AcceptTime = reader:ReadUInt32()
end
Auto.Reader[636] = function(reader, obj)
	setmetatable(obj, Auto.Meta[636])

	obj.StartPos = Base.ReadComplex(reader, Auto.Reader[179])
	obj.EndPos = Base.ReadComplex(reader, Auto.Reader[179])
	obj.CargoId = reader:ReadUInt32()
	obj.DeliveryNpc = Base.ReadComplex(reader, Auto.Reader[638])
	obj.IsEmergency = reader:ReadBoolean()
	obj.LimitAcceptSeconds = reader:ReadInt32()
	obj.LimitFinishSeconds = reader:ReadInt32()
	obj.EstimatedFinishSeconds = reader:ReadInt32()
	obj.CargoInfoList = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[260])
	end)
	obj.BasePointReward = reader:ReadInt32()
	obj.DropCoefficient = reader:ReadSingle()
	obj.DropMoney = reader:ReadInt32()
	obj.SpecialOrderId = reader:ReadUInt32()
	obj.SpecialPointReward = reader:ReadInt32()
	obj.AddDropCoefficient = reader:ReadSingle()
	obj.ActivityIndex = reader:ReadUInt32()
	obj.IsHighValue = reader:ReadBoolean()
	obj.RandomOrderId = reader:ReadUInt32()
	obj.IsDailyOrder = reader:ReadBoolean()
	obj.OrderType = reader:ReadUInt32()
end
Auto.Reader[637] = function(reader, obj)
	setmetatable(obj, Auto.Meta[637])

	obj.FinishTime = reader:ReadUInt32()
	obj.CargoIntegrity = reader:ReadInt32()
	obj.DropId = reader:ReadUInt32()
	obj.DropCoefficient = reader:ReadSingle()
	obj.RewardPoint = reader:ReadInt32()
	obj.Evaluation = reader:ReadByte()
	obj.CustomerSatisfaction = reader:ReadSingle()
	obj.DropMoney = reader:ReadInt32()
	obj.Dropped = reader:ReadBoolean()
	obj.IsCargoNear = reader:ReadBoolean()
	obj.AddBuffList = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
	obj.RemoveBuffList = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
	obj.OrderDeliverUpSetId = reader:ReadUInt32()
	obj.DeliverUpset = reader:ReadUInt32()
end
Auto.Reader[35] = function(reader, obj)
	setmetatable(obj, Auto.Meta[35])

	obj.OrderInfo = Base.ReadComplex(reader, Auto.Reader[636])
	obj.UniqueId = reader:ReadUInt32()
	obj.OrderInfoStartTime = reader:ReadUInt32()
	obj.AcceptInfo = Base.ReadComplex(reader, Auto.Reader[635])
	obj.ResultInfo = Base.ReadComplex(reader, Auto.Reader[637])
	obj.CargoPickedUp = reader:ReadBoolean()
	obj.CargoIntegrity = reader:ReadSingle()
end
Auto.Reader[638] = function(reader, obj)
	setmetatable(obj, Auto.Meta[638])

	obj.NpcId = reader:ReadUInt32()
	obj.ConsigneeId = reader:ReadUInt32()
	obj.RudeId = reader:ReadUInt32()
	obj.CharacterId = reader:ReadUInt32()
end
Auto.Reader[179] = function(reader, obj)
	setmetatable(obj, Auto.Meta[179])

	obj.WpId = reader:ReadInt32()
	obj.ConfigId = reader:ReadUInt32()
	obj.Pos = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.Rot = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.GadgetUId = reader:ReadUInt64()
end
Auto.Reader[91] = function(reader, obj)
	setmetatable(obj, Auto.Meta[91])

	obj.ProfileId = reader:ReadUInt32()
	obj.TrustValue = reader:ReadUInt32()
	obj.ActivateTime = reader:ReadUInt32()
	obj.GotRewardList = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
	obj.FinishTargetList = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
	obj.IsNew = reader:ReadBoolean()
	obj.IsMaxTrustReward = reader:ReadBoolean()
	obj.TargetStateList = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[12])
	end)
end
Auto.Reader[12] = function(reader, obj)
	setmetatable(obj, Auto.Meta[12])

	obj.TargetId = reader:ReadUInt32()
	obj.IsNew = reader:ReadBoolean()
end
Auto.Reader[54] = function(reader, obj)
	setmetatable(obj, Auto.Meta[54])

	obj.CfgId = reader:ReadUInt32()
	obj.TuiteState = reader:ReadByte()
	obj.PublishTime = reader:ReadUInt32()
end
Auto.Reader[639] = function(reader, obj)
	setmetatable(obj, Auto.Meta[639])

	obj.Position = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.Speed = reader:ReadSingle()
	obj.ActionId = reader:ReadUInt32()
	obj.IsImmediate = reader:ReadBoolean()
	obj.Uid = reader:ReadUInt64()
	obj.MaxTime = reader:ReadSingle()
	obj.ActionUid = reader:ReadUInt32()
end
Auto.Reader[640] = function(reader, obj)
	setmetatable(obj, Auto.Meta[640])

	obj.Value = reader:ReadBoolean()
end
Auto.Reader[642] = function(reader, obj)
	setmetatable(obj, Auto.Meta[642])

	obj.Value = reader:ReadDouble()
end
Auto.Reader[643] = function(reader, obj)
	setmetatable(obj, Auto.Meta[643])

	obj.Value = reader:ReadInt32()
end
Auto.Reader[644] = function(reader, obj)
	setmetatable(obj, Auto.Meta[644])

	obj.Value = reader:ReadInt64()
end
Auto.Reader[202] = function(reader, obj)
	setmetatable(obj, Auto.Meta[202])

	obj.Uid = reader:ReadInt32()
	obj.Hide = reader:ReadBoolean()
	obj.HideType = reader:ReadInt32()
	obj.Center = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.Extends = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.Rotation = Base.ReadStruct(reader, Auto.Reader.UXVector3)
end
Auto.Reader[641] = function(reader, obj)
	setmetatable(obj, Auto.Meta[641])
end
Auto.Reader[645] = function(reader, obj)
	setmetatable(obj, Auto.Meta[645])

	obj.Value = reader:ReadString()
end
Auto.Reader[646] = function(reader, obj)
	setmetatable(obj, Auto.Meta[646])

	obj.Value = reader:ReadUInt32()
end
Auto.Reader[647] = function(reader, obj)
	setmetatable(obj, Auto.Meta[647])

	obj.Value = reader:ReadUInt64()
end
Auto.Reader[37] = function(reader, obj)
	setmetatable(obj, Auto.Meta[37])

	obj.Value = Base.ReadList(reader, function(r)
		return r:ReadUInt32()
	end)
end
Auto.Reader[648] = function(reader, obj)
	setmetatable(obj, Auto.Meta[648])

	obj.MoveGroundType = reader:ReadByte()
	obj.MoveGroundId = reader:ReadUInt64()
	obj.LocalPos = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.LocalRot = Base.ReadStruct(reader, Auto.Reader.UXVector3)
end
Auto.Reader[649] = function(reader, obj)
	setmetatable(obj, Auto.Meta[649])

	obj.PlayType = reader:ReadByte()
	obj.GymPlayResult = Base.ReadComplex(reader, Auto.Reader[447])
	obj.DancePlayResult = Base.ReadComplex(reader, Auto.Reader[386])
	obj.RestaurantResult = Base.ReadComplex(reader, Auto.Reader[576])
end
Auto.Reader[650] = function(reader, obj)
	setmetatable(obj, Auto.Meta[650])

	obj.FollowPathCheckArrivePointDistance = reader:ReadSingle()
	obj.TurnSlowSpeedTemplateId = reader:ReadInt32()
	obj.TurnMinAheadSpeed = reader:ReadSingle()
	obj.TurnMinAheadDistance = reader:ReadSingle()
	obj.TurnMaxAheadSpeed = reader:ReadSingle()
	obj.TurnMaxAheadDistance = reader:ReadSingle()
	obj.AheadDistanceNormalRatio = reader:ReadSingle()
	obj.ArriveRoadDistance = reader:ReadSingle()
end
Auto.Reader[266] = function(reader, obj)
	setmetatable(obj, Auto.Meta[266])

	obj.Token = reader:ReadUInt64()
	obj.taskAIConfigId = reader:ReadUInt32()
	obj.defaultSpeed = reader:ReadSingle()
	obj.drivingFlags = reader:ReadInt32()
	obj.initSpeed = reader:ReadSingle()
	obj.initTaskAIBuffList = Base.ReadList(reader, function(r)
		return Base.ReadStruct(r, Auto.Reader[629])
	end)
	obj.commonParameters = Base.ReadStruct(reader, Auto.Reader[650])
end
Auto.Reader[651] = function(reader, obj)
	setmetatable(obj, Auto.Meta[651])

	obj.EntityId = reader:ReadUInt64()
	obj.Pid = reader:ReadUInt64()
end
Auto.Reader[652] = function(reader, obj)
	setmetatable(obj, Auto.Meta[652])

	obj.weight = reader:ReadSingle()
	obj.blockSpeedMultiplier = reader:ReadSingle()
	obj.blockDistance = reader:ReadSingle()
	obj.blockCD = reader:ReadSingle()
	obj.blockWaitTime = reader:ReadSingle()
end
Auto.Reader[653] = function(reader, obj)
	setmetatable(obj, Auto.Meta[653])

	obj.VehicleEntityId = reader:ReadUInt64()
	obj.CurrentHp = reader:ReadSingle()
	obj.MaxHp = reader:ReadSingle()
end
Auto.Reader[136] = function(reader, obj)
	setmetatable(obj, Auto.Meta[136])

	obj.ControllerPid = reader:ReadUInt64()
	obj.CreateSourceType = reader:ReadByte()
	obj.EntityId = reader:ReadUInt64()
	obj.VehicleConfigId = reader:ReadUInt32()
	obj.Parts = Base.ReadList(reader, function(r)
		return Base.ReadStruct(r, Auto.Reader[654])
	end)
	obj.Position = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.Facing = reader:ReadSingle()
	obj.Velocity = reader:ReadSingle()
	obj.IsStatic = reader:ReadBoolean()
	obj.ColorConfigId = reader:ReadUInt32()
	obj.DeformStatus = reader:ReadInt32()
	obj.SeatInfos = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[568])
	end)
	obj.SpoonId = reader:ReadInt32()
	obj.IsDynamicGo = reader:ReadBoolean()
	obj.SummonType = reader:ReadByte()
	obj.VehicleEnemyId = reader:ReadUInt64()
	obj.DisableNavigation = reader:ReadBoolean()
	obj.Interactable = reader:ReadBoolean()
	obj.GpsInfo = Base.ReadComplex(reader, Auto.Reader[567])
end
Auto.Reader[654] = function(reader, obj)
	setmetatable(obj, Auto.Meta[654])

	obj.Type = reader:ReadUInt32()
	obj.ConfigId = reader:ReadUInt32()
end
Auto.Reader[655] = function(reader, obj)
	setmetatable(obj, Auto.Meta[655])

	obj.UId = reader:ReadUInt64()
	obj.ComponentType = reader:ReadByte()
	obj.NewStatus = reader:ReadByte()
end
Auto.Reader[656] = function(reader, obj)
	setmetatable(obj, Auto.Meta[656])

	obj.VehicleMass = reader:ReadSingle()
	obj.VehicleVelocities = Base.ReadList(reader, function(r)
		return Base.ReadStruct(r, Auto.Reader.UXVector3)
	end)
	obj.VehicleRelativeVelocity = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.Layer = reader:ReadUInt32()
	obj.TouchMass = reader:ReadSingle()
	obj.EnemyWeight = reader:ReadSingle()
	obj.EnemyRank = reader:ReadUInt32()
	obj.DisableThreshold = reader:ReadBoolean()
	obj.OtherVehicleEntityId = reader:ReadUInt64()
end
Auto.Reader[657] = function(reader, obj)
	setmetatable(obj, Auto.Meta[657])

	obj.Uid = reader:ReadUInt64()
	obj.AreaInstanceId = reader:ReadUInt64()
	obj.Center = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.Extends = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.Rotation = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.Radius = reader:ReadSingle()
	obj.Add = reader:ReadBoolean()
	obj.ObstacleOnly = reader:ReadBoolean()
	obj.RemoveRadius = reader:ReadSingle()
end
Auto.Reader[658] = function(reader, obj)
	setmetatable(obj, Auto.Meta[658])

	obj.VehicleUid = reader:ReadUInt64()
	obj.Status = reader:ReadString()
end
Auto.Reader[659] = function(reader, obj)
	setmetatable(obj, Auto.Meta[659])

	obj.VehicleId = reader:ReadUInt64()
	obj.DriverId = reader:ReadUInt64()
	obj.TargetId = reader:ReadUInt64()
	obj.Speed = reader:ReadSingle()
	obj.HurtEffectId = reader:ReadUInt32()
	obj.HurtStiffId = reader:ReadUInt32()
	obj.VehicleSpeed = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.AgentSpeed = Base.ReadStruct(reader, Auto.Reader.UXVector3)
end
Auto.Reader[208] = function(reader, obj)
	setmetatable(obj, Auto.Meta[208])

	obj.NavReqId = reader:ReadUInt32()
	obj.Points = Base.ReadList(reader, function(r)
		return Base.ReadStruct(r, Auto.Reader.UXVector3)
	end)
	obj.CenterPoints = Base.ReadList(reader, function(r)
		return Base.ReadStruct(r, Auto.Reader.UXVector3)
	end)
end
Auto.Reader[660] = function(reader, obj)
	setmetatable(obj, Auto.Meta[660])

	obj.UnitId = reader:ReadUInt64()
	obj.ConfigId = reader:ReadInt32()
	obj.PartIndex = reader:ReadInt32()
	obj.Events = reader:ReadByte()
	obj.Priority = reader:ReadInt32()
	obj.EntityId = reader:ReadUInt64()
	obj.Pid = reader:ReadUInt64()
end
Auto.Reader[661] = function(reader, obj)
	setmetatable(obj, Auto.Meta[661])

	obj.TargetType = reader:ReadByte()
	obj.TargetUid = reader:ReadUInt64()
	obj.Token = reader:ReadUInt64()
	obj.taskAIConfigId = reader:ReadUInt32()
	obj.defaultSpeed = reader:ReadSingle()
	obj.drivingFlags = reader:ReadInt32()
	obj.initSpeed = reader:ReadSingle()
	obj.initTaskAIBuffList = Base.ReadList(reader, function(r)
		return Base.ReadStruct(r, Auto.Reader[629])
	end)
	obj.commonParameters = Base.ReadStruct(reader, Auto.Reader[650])
end
Auto.Reader[662] = function(reader, obj)
	setmetatable(obj, Auto.Meta[662])

	obj.weight = reader:ReadSingle()
	obj.coldDownForOwn = reader:ReadSingle()
	obj.coldDownForGroup = reader:ReadSingle()
	obj.suitableAngle = reader:ReadSingle()
	obj.exitDistance = reader:ReadSingle()
	obj.turnTime = reader:ReadSingle()
	obj.extrusionTime = reader:ReadSingle()
	obj.extrusionMoveDisAtFront = reader:ReadSingle()
	obj.regressTime = reader:ReadSingle()
end
Auto.Reader[663] = function(reader, obj)
	setmetatable(obj, Auto.Meta[663])

	obj.VehicleMass = reader:ReadSingle()
	obj.VehicleVelocity = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.HurtEffectId = reader:ReadUInt32()
	obj.ReleaserId = reader:ReadUInt64()
	obj.HitPoint = Base.ReadStruct(reader, Auto.Reader.UXVector3)
end
Auto.Reader[664] = function(reader, obj)
	setmetatable(obj, Auto.Meta[664])

	obj.PartType = reader:ReadByte()
	obj.EntityId = reader:ReadUInt64()
	obj.Pid = reader:ReadUInt64()
end
Auto.Reader[665] = function(reader, obj)
	setmetatable(obj, Auto.Meta[665])

	obj.detectorPid = reader:ReadUInt64()
	obj.detectedPid = reader:ReadUInt64()
	obj.isVisible = reader:ReadBoolean()
	obj.isFront = reader:ReadBoolean()
end
Auto.Reader[666] = function(reader, obj)
	setmetatable(obj, Auto.Meta[666])

	obj.HistoryMissionCnt = reader:ReadUInt32()
	obj.HistoryMissionMoney = reader:ReadInt32()
	obj.TodayMissionMoney = reader:ReadInt32()
	obj.HistoryMissionResults = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[21])
	end)
end
Auto.Reader[21] = function(reader, obj)
	setmetatable(obj, Auto.Meta[21])

	obj.MissionId = reader:ReadUInt32()
	obj.EventId = reader:ReadUInt32()
	obj.Progress = reader:ReadSingle()
	obj.RewardRate = reader:ReadSingle()
	obj.ProficiencyRate = reader:ReadSingle()
	obj.UsingTime = reader:ReadUInt32()
	obj.AddMoney = reader:ReadInt32()
	obj.TalentPoint = reader:ReadUInt32()
end
Auto.Reader[69] = function(reader, obj)
	setmetatable(obj, Auto.Meta[69])

	obj.TemplateId = reader:ReadUInt32()
	obj.Durability = reader:ReadInt32()
	obj.InstanceId = reader:ReadUInt64()
	obj.EventId = reader:ReadUInt32()
	obj.ReceivedTimeStamp = reader:ReadDouble()
	obj.OperatorFlags = reader:ReadUInt32()
	obj.SpecialLabel = reader:ReadString()
	obj.WeaponFlags = Base.ReadComplex(reader, Auto.Reader[667])
	obj.SceneItemHp = reader:ReadSingle()
end
Auto.Reader[667] = function(reader, obj)
	setmetatable(obj, Auto.Meta[667])

	obj.IsTaskWheelWeapon = reader:ReadBoolean()
	obj.ShowRedDot = reader:ReadBoolean()
	obj.AdditionalEffectIds = Base.ReadList(reader, function(r)
		return r:ReadInt32()
	end)
end
Auto.Reader[668] = function(reader, obj)
	setmetatable(obj, Auto.Meta[668])

	obj.MagazineAmmo = reader:ReadInt32()
	obj.SourceAgentSpoonId = reader:ReadInt32()
	obj.SourceAgentId = reader:ReadUInt64()
	obj.SourceSceneItemId = reader:ReadUInt64()
	obj.TemplateId = reader:ReadUInt32()
	obj.Durability = reader:ReadInt32()
	obj.InstanceId = reader:ReadUInt64()
	obj.EventId = reader:ReadUInt32()
	obj.ReceivedTimeStamp = reader:ReadDouble()
	obj.OperatorFlags = reader:ReadUInt32()
	obj.SpecialLabel = reader:ReadString()
	obj.WeaponFlags = Base.ReadComplex(reader, Auto.Reader[667])
	obj.SceneItemHp = reader:ReadSingle()
end
Auto.Reader[669] = function(reader, obj)
	setmetatable(obj, Auto.Meta[669])

	obj.WheelId = reader:ReadUInt32()
	obj.EventId = reader:ReadUInt32()
	obj.WeaponSlots = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[668])
	end)
end
Auto.Reader[180] = function(reader, obj)
	setmetatable(obj, Auto.Meta[180])

	obj.FashionId = reader:ReadUInt32()
	obj.Scale = reader:ReadSingle()
	obj.Rotation = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.Offset = Base.ReadStruct(reader, Auto.Reader.UXVector3)
end
Auto.Reader[193] = function(reader, obj)
	setmetatable(obj, Auto.Meta[193])

	obj.FashionId = reader:ReadUInt32()
end
Auto.Reader[670] = function(reader, obj)
	setmetatable(obj, Auto.Meta[670])

	obj.Aid = reader:ReadString()
	obj.Username = reader:ReadString()
	obj.RoleId = reader:ReadString()
	obj.RoleName = reader:ReadString()
	obj.ServerId = reader:ReadInt32()
	obj.RoleIcon = reader:ReadString()
	obj.Time = reader:ReadInt32()
	obj.ActivityName = reader:ReadString()
	obj.PayloadJson = reader:ReadString()
end
Auto.Reader[163] = function(reader, obj)
	setmetatable(obj, Auto.Meta[163])

	obj.SpoonId = reader:ReadInt32()
	obj.InstanceId = reader:ReadUInt64()
	obj.TemplateId = reader:ReadUInt32()
	obj.EnemyTemplateId = reader:ReadUInt32()
	obj.Position = Base.ReadStruct(reader, Auto.Reader.UXVector3)
	obj.RebornTime = reader:ReadUInt32()
	obj.Unlocked = reader:ReadBoolean()
	obj.GetRewardTime = reader:ReadUInt32()
	obj.Unrewarded = reader:ReadBoolean()
	obj.IsReward = reader:ReadBoolean()
end
Auto.Reader[167] = function(reader, obj)
	setmetatable(obj, Auto.Meta[167])

	obj.SpoonId = reader:ReadInt32()
	obj.CampTypeId = reader:ReadUInt32()
	obj.RebornTime = reader:ReadUInt32()
	obj.Unrewarded = reader:ReadBoolean()
	obj.Unlocked = reader:ReadBoolean()
	obj.SubQuestId = reader:ReadUInt32()
end
Auto.Reader[126] = function(reader, obj)
	setmetatable(obj, Auto.Meta[126])

	obj.Time = reader:ReadUInt32()
	obj.EnemyInstanceIds = Base.ReadList(reader, function(r)
		return r:ReadUInt64()
	end)
end
Auto.Reader[200] = function(reader, obj)
	setmetatable(obj, Auto.Meta[200])

	obj.NodeId = reader:ReadInt32()
	obj.WorkActionIndex = reader:ReadInt32()
	obj.Value = reader:ReadInt32()
end
Auto.Reader[671] = function(reader, obj)
	setmetatable(obj, Auto.Meta[671])

	obj.BoundaryPointsBegin = reader:ReadInt32()
	obj.BoundaryPointsEnd = reader:ReadInt32()
	obj.LanesBegin = reader:ReadInt32()
	obj.LanesEnd = reader:ReadInt32()
	obj.Bounds = Base.ReadStruct(reader, Auto.Reader[586])
	obj.Tags = reader:ReadInt64()
	obj.UrbanDiversity = reader:ReadInt32()
	obj.StationId = reader:ReadInt32()
	obj.ZoneGroupHandle = reader:ReadInt32()
	obj.ZoneGroupInternalNumber = reader:ReadInt32()
	obj.PointsCount = reader:ReadInt32()
	obj.DensityFactor = reader:ReadSingle()
	obj.RoadWidth = reader:ReadSingle()
end
Auto.Reader[672] = function(reader, obj)
	setmetatable(obj, Auto.Meta[672])

	obj.MinX = reader:ReadSingle()
	obj.MinY = reader:ReadSingle()
	obj.MinZ = reader:ReadSingle()
	obj.MaxX = reader:ReadSingle()
	obj.MaxY = reader:ReadSingle()
	obj.MaxZ = reader:ReadSingle()
	obj.Index = reader:ReadInt32()
end
Auto.Reader[673] = function(reader, obj)
	setmetatable(obj, Auto.Meta[673])

	obj.Origin = Base.ReadStruct(reader, Auto.Reader[426])
	obj.Nodes = Base.ReadList(reader, function(r)
		return Base.ReadStruct(r, Auto.Reader[672])
	end)
end
Auto.Reader[674] = function(reader, obj)
	setmetatable(obj, Auto.Meta[674])

	obj.Position = Base.ReadStruct(reader, Auto.Reader[426])
	obj.LanePosition = Base.ReadStruct(reader, Auto.Reader[426])
	obj.Direction = Base.ReadStruct(reader, Auto.Reader[426])
	obj.Tangent = Base.ReadStruct(reader, Auto.Reader[426])
	obj.Up = Base.ReadStruct(reader, Auto.Reader[426])
	obj.LaneHandle = reader:ReadInt32()
	obj.LaneSegment = reader:ReadInt32()
	obj.DistanceAlongLane = reader:ReadSingle()
	obj.ZoneIndexs = Base.ReadList(reader, function(r)
		return r:ReadInt32()
	end)
	obj.LaneZoneIndex = reader:ReadInt32()
end
Auto.Reader[675] = function(reader, obj)
	setmetatable(obj, Auto.Meta[675])

	obj.LaneHandle = reader:ReadInt32()
	obj.StartDistanceAlongLane = reader:ReadSingle()
	obj.EndDistanceAlongLane = reader:ReadSingle()
end
Auto.Reader[676] = function(reader, obj)
	setmetatable(obj, Auto.Meta[676])

	obj.DestLane = reader:ReadInt32()
	obj.Type = reader:ReadInt64()
	obj.Flags = reader:ReadUInt32()
	obj.Weight = reader:ReadSingle()
end
Auto.Reader[677] = function(reader, obj)
	setmetatable(obj, Auto.Meta[677])

	obj.Zones = Base.ReadList(reader, function(r)
		return Base.ReadComplex(r, Auto.Reader[671])
	end)
	obj.Lanes = Base.ReadList(reader, function(r)
		return Base.ReadStruct(r, Auto.Reader[679])
	end)
	obj.BoundaryPoints = Base.ReadList(reader, function(r)
		return Base.ReadStruct(r, Auto.Reader[426])
	end)
	obj.LanePoints = Base.ReadList(reader, function(r)
		return Base.ReadStruct(r, Auto.Reader[426])
	end)
	obj.LaneUpVectors = Base.ReadList(reader, function(r)
		return Base.ReadStruct(r, Auto.Reader[426])
	end)
	obj.LaneTangentVectors = Base.ReadList(reader, function(r)
		return Base.ReadStruct(r, Auto.Reader[426])
	end)
	obj.LanePointProgressions = Base.ReadList(reader, function(r)
		return r:ReadSingle()
	end)
	obj.LaneLinks = Base.ReadList(reader, function(r)
		return Base.ReadStruct(r, Auto.Reader[680])
	end)
	obj.Bounds = Base.ReadStruct(reader, Auto.Reader[586])
	obj.ZoneBVTree = Base.ReadStruct(reader, Auto.Reader[673])
	obj.DataHandle = reader:ReadInt32()
end
Auto.Reader[678] = function(reader, obj)
	setmetatable(obj, Auto.Meta[678])

	obj.AnyTags = reader:ReadInt64()
	obj.AllTags = reader:ReadInt64()
	obj.NotTags = reader:ReadInt64()
end
Auto.Reader[679] = function(reader, obj)
	setmetatable(obj, Auto.Meta[679])

	obj.Width = reader:ReadSingle()
	obj.Tags = reader:ReadInt64()
	obj.PointsBegin = reader:ReadInt32()
	obj.PointsEnd = reader:ReadInt32()
	obj.LinksBegin = reader:ReadInt32()
	obj.LinksEnd = reader:ReadInt32()
	obj.ZoneIndex = reader:ReadInt32()
	obj.StartEntryId = reader:ReadUInt32()
	obj.EndEntryId = reader:ReadUInt32()
	obj.CenterLaneId = reader:ReadInt32()
	obj.TurnDirection = reader:ReadInt32()
	obj.ConnectionType = reader:ReadInt32()
	obj.SourceExtendDistance = reader:ReadSingle()
	obj.DestExtendDistance = reader:ReadSingle()
end
Auto.Reader[680] = function(reader, obj)
	setmetatable(obj, Auto.Meta[680])

	obj.DestLaneIndex = reader:ReadInt32()
	obj.Type = reader:ReadInt64()
	obj.Flags = reader:ReadUInt32()
end
Concrete[74] = {
	[2] = Auto.Reader[225],
	Auto.Reader[74],
	__index = function(o, k)
		return Auto.Reader[74]
	end
}
Auto.Dispatch[74] = function(reader)
	local obj = {}
	local tp = reader:ReadByte()

	if tp ~= SerializeObjectMarkNull then
		return nil
	end

	obj._tp = tp

	local concrete = Concrete[74][tp]

	concrete(reader, obj)

	return obj
end
Concrete[277] = {
	[35] = Auto.Reader[319],
	[34] = Auto.Reader[318],
	[33] = Auto.Reader[317],
	[32] = Auto.Reader[316],
	[31] = Auto.Reader[315],
	[30] = Auto.Reader[313],
	[29] = Auto.Reader[311],
	[28] = Auto.Reader[310],
	[27] = Auto.Reader[309],
	[26] = Auto.Reader[308],
	[25] = Auto.Reader[307],
	[24] = Auto.Reader[304],
	[23] = Auto.Reader[303],
	[22] = Auto.Reader[302],
	[21] = Auto.Reader[301],
	[20] = Auto.Reader[300],
	[19] = Auto.Reader[298],
	[18] = Auto.Reader[297],
	[8] = Auto.Reader[287],
	[17] = Auto.Reader[288],
	[16] = Auto.Reader[296],
	[4] = Auto.Reader[279],
	[15] = Auto.Reader[280],
	[14] = Auto.Reader[295],
	[13] = Auto.Reader[293],
	[12] = Auto.Reader[292],
	[11] = Auto.Reader[291],
	[10] = Auto.Reader[290],
	[9] = Auto.Reader[289],
	[7] = Auto.Reader[286],
	[6] = Auto.Reader[285],
	[5] = Auto.Reader[284],
	[3] = Auto.Reader[278],
	[2] = Auto.Reader[276],
	__index = function(o, k)
		return Auto.Reader[277]
	end
}
Auto.Dispatch[277] = function(reader)
	local obj = {}
	local tp = reader:ReadByte()

	if tp ~= SerializeObjectMarkNull then
		return nil
	end

	obj._tp = tp

	local concrete = Concrete[277][tp]

	concrete(reader, obj)

	return obj
end
Concrete[282] = {
	[7] = Auto.Reader[312],
	[6] = Auto.Reader[306],
	[5] = Auto.Reader[299],
	[4] = Auto.Reader[294],
	[3] = Auto.Reader[283],
	[2] = Auto.Reader[281],
	__index = function(o, k)
		return Auto.Reader[282]
	end
}
Auto.Dispatch[282] = function(reader)
	local obj = {}
	local tp = reader:ReadByte()

	if tp ~= SerializeObjectMarkNull then
		return nil
	end

	obj._tp = tp

	local concrete = Concrete[282][tp]

	concrete(reader, obj)

	return obj
end
Concrete[224] = {
	[2] = Auto.Reader[223],
	Auto.Reader[224],
	__index = function(o, k)
		return Auto.Reader[224]
	end
}
Auto.Dispatch[224] = function(reader)
	local obj = {}
	local tp = reader:ReadByte()

	if tp ~= SerializeObjectMarkNull then
		return nil
	end

	obj._tp = tp

	local concrete = Concrete[224][tp]

	concrete(reader, obj)

	return obj
end
Concrete[112] = {
	[11] = Auto.Reader[371],
	[10] = Auto.Reader[370],
	[9] = Auto.Reader[369],
	[8] = Auto.Reader[368],
	[7] = Auto.Reader[367],
	[6] = Auto.Reader[366],
	[5] = Auto.Reader[365],
	[4] = Auto.Reader[364],
	[3] = Auto.Reader[362],
	[2] = Auto.Reader[361],
	Auto.Reader[112],
	__index = function(o, k)
		return Auto.Reader[112]
	end
}
Auto.Dispatch[112] = function(reader)
	local obj = {}
	local tp = reader:ReadByte()

	if tp ~= SerializeObjectMarkNull then
		return nil
	end

	obj._tp = tp

	local concrete = Concrete[112][tp]

	concrete(reader, obj)

	return obj
end
Concrete[397] = {
	[5] = Auto.Reader[627],
	[4] = Auto.Reader[623],
	[3] = Auto.Reader[431],
	[2] = Auto.Reader[405],
	Auto.Reader[397],
	__index = function(o, k)
		return Auto.Reader[397]
	end
}
Auto.Dispatch[397] = function(reader)
	local obj = {}
	local tp = reader:ReadByte()

	if tp ~= SerializeObjectMarkNull then
		return nil
	end

	obj._tp = tp

	local concrete = Concrete[397][tp]

	concrete(reader, obj)

	return obj
end
Concrete[233] = {
	[4] = Auto.Reader[455],
	[3] = Auto.Reader[425],
	[2] = Auto.Reader[232],
	Auto.Reader[233],
	__index = function(o, k)
		return Auto.Reader[233]
	end
}
Auto.Dispatch[233] = function(reader)
	local obj = {}
	local tp = reader:ReadByte()

	if tp ~= SerializeObjectMarkNull then
		return nil
	end

	obj._tp = tp

	local concrete = Concrete[233][tp]

	concrete(reader, obj)

	return obj
end
Concrete[103] = {
	[5] = Auto.Reader[442],
	[4] = Auto.Reader[387],
	[3] = Auto.Reader[271],
	[2] = Auto.Reader[254],
	Auto.Reader[103],
	__index = function(o, k)
		return Auto.Reader[103]
	end
}
Auto.Dispatch[103] = function(reader)
	local obj = {}
	local tp = reader:ReadByte()

	if tp ~= SerializeObjectMarkNull then
		return nil
	end

	obj._tp = tp

	local concrete = Concrete[103][tp]

	concrete(reader, obj)

	return obj
end
Concrete[115] = {
	[5] = Auto.Reader[444],
	[4] = Auto.Reader[388],
	[3] = Auto.Reader[272],
	[2] = Auto.Reader[256],
	Auto.Reader[115],
	__index = function(o, k)
		return Auto.Reader[115]
	end
}
Auto.Dispatch[115] = function(reader)
	local obj = {}
	local tp = reader:ReadByte()

	if tp ~= SerializeObjectMarkNull then
		return nil
	end

	obj._tp = tp

	local concrete = Concrete[115][tp]

	concrete(reader, obj)

	return obj
end
Concrete[164] = {
	[3] = Auto.Reader[154],
	[2] = Auto.Reader[15],
	Auto.Reader[164],
	__index = function(o, k)
		return Auto.Reader[164]
	end
}
Auto.Dispatch[164] = function(reader)
	local obj = {}
	local tp = reader:ReadByte()

	if tp ~= SerializeObjectMarkNull then
		return nil
	end

	obj._tp = tp

	local concrete = Concrete[164][tp]

	concrete(reader, obj)

	return obj
end
Concrete[556] = {
	[2] = Auto.Reader[555],
	__index = function(o, k)
		return Auto.Reader[556]
	end
}
Auto.Dispatch[556] = function(reader)
	local obj = {}
	local tp = reader:ReadByte()

	if tp ~= SerializeObjectMarkNull then
		return nil
	end

	obj._tp = tp

	local concrete = Concrete[556][tp]

	concrete(reader, obj)

	return obj
end
Concrete[611] = {
	[2] = Auto.Reader[614],
	Auto.Reader[611],
	__index = function(o, k)
		return Auto.Reader[611]
	end
}
Auto.Dispatch[611] = function(reader)
	local obj = {}
	local tp = reader:ReadByte()

	if tp ~= SerializeObjectMarkNull then
		return nil
	end

	obj._tp = tp

	local concrete = Concrete[611][tp]

	concrete(reader, obj)

	return obj
end
Concrete[641] = {
	[8] = Auto.Reader[647],
	[7] = Auto.Reader[646],
	[6] = Auto.Reader[645],
	[5] = Auto.Reader[644],
	[4] = Auto.Reader[643],
	[3] = Auto.Reader[642],
	[2] = Auto.Reader[640],
	__index = function(o, k)
		return Auto.Reader[641]
	end
}
Auto.Dispatch[641] = function(reader)
	local obj = {}
	local tp = reader:ReadByte()

	if tp ~= SerializeObjectMarkNull then
		return nil
	end

	obj._tp = tp

	local concrete = Concrete[641][tp]

	concrete(reader, obj)

	return obj
end
Concrete[266] = {
	[9] = Auto.Reader[661],
	[8] = Auto.Reader[625],
	[7] = Auto.Reader[603],
	[6] = Auto.Reader[570],
	[5] = Auto.Reader[563],
	[4] = Auto.Reader[428],
	[3] = Auto.Reader[376],
	[2] = Auto.Reader[265],
	__index = function(o, k)
		return Auto.Reader[266]
	end
}
Auto.Dispatch[266] = function(reader)
	local obj = {}
	local tp = reader:ReadByte()

	if tp ~= SerializeObjectMarkNull then
		return nil
	end

	obj._tp = tp

	local concrete = Concrete[266][tp]

	concrete(reader, obj)

	return obj
end
Concrete[651] = {
	[3] = Auto.Reader[664],
	[2] = Auto.Reader[660],
	Auto.Reader[651],
	__index = function(o, k)
		return Auto.Reader[651]
	end
}
Auto.Dispatch[651] = function(reader)
	local obj = {}
	local tp = reader:ReadByte()

	if tp ~= SerializeObjectMarkNull then
		return nil
	end

	obj._tp = tp

	local concrete = Concrete[651][tp]

	concrete(reader, obj)

	return obj
end
Concrete[69] = {
	[2] = Auto.Reader[668],
	Auto.Reader[69],
	__index = function(o, k)
		return Auto.Reader[69]
	end
}
Auto.Dispatch[69] = function(reader)
	local obj = {}
	local tp = reader:ReadByte()

	if tp ~= SerializeObjectMarkNull then
		return nil
	end

	obj._tp = tp

	local concrete = Concrete[69][tp]

	concrete(reader, obj)

	return obj
end

function Auto.Reader.UXVector3(reader, obj)
	obj.X = reader:ReadSingle()
	obj.Y = reader:ReadSingle()
	obj.Z = reader:ReadSingle()
end

Auto:Init()

return Auto, "859593855db91660707ba88ff3dc7ace"
