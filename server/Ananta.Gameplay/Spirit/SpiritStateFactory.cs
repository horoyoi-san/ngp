using System.Collections.Generic;
using System.Linq;
using AnantaTestGameServer.Messages;
using AnantaTestGameServer.Methods.Return;
using UX.RPC.Protocol;

namespace AnantaTestGameServer.Game.State

{
    public static class SpiritStateFactory
    {
        private static readonly uint[] JoinableFightSpiritIds =
        {
            15020967,
            15020968,
            15020989,
            15020991,
            15020992,
            15020997,
            15021016,
            15021017,
            15021020,
            15021021,
            15021022,
            15021023,
            15021024,
            15021025,
            15021029,
            15021038,
            15021039,
            15022030
        };

        public static List<SpiritInfo> BuildDefaultSpirits()
        {
            return JoinableFightSpiritIds
                .Select((templateId, index) => CreateSpirit(templateId, 100000000000UL + (ulong)index))
                .ToList();
        }

        private static SpiritInfo CreateSpirit(uint templateId, ulong instanceId)
        {
            return new SpiritInfo()
            {
                TemplateId = templateId,
                Id = instanceId,
                HpRate = 1,
                CurrentJobId = 100,
                SpiritUrbanSkill = new()
                {
                    UrbanAbilities = templateId == 15020968 ? new() { 92, 55, 70, 62, 81, 72 } : new()
                },
                SpiritAbilities = BuildDefaultSpiritAbilities(),
                SpiritJobInfo = new()
                {
                    CurrentJob = 100,
                    AvailableJobs = new(),
                    HistoryJobs = new(),
                },
                PermanentAddAttributes = new(),
                InfoBadge = new()
                {
                    Badges = new(),
                    HistoryBadges = new(),
                },
                MobileSkinInfo = new()
                {
                    Wallpaper = 12003000,
                    Decoration = 12003001,
                    Pendant = 12003002
                },
                WeaponSlots = new(),
                SpiritBattleInfo = new(),
                TalentInfo = new()
                {
                    Level = 1,
                    TalentPoint = 10,
                    UnlockTalentInfoDict = new()
                    {
                        { 601, new SpiritOrJobTalentNodeInfo() { TalentId = 601, Layer = 0 } },
                        { 608, new SpiritOrJobTalentNodeInfo() { TalentId = 608, Layer = 0 } }
                    }
                },
                SpiritFightStyle = new()
                {
                    FightStyleInfo = new()
                },
            };
        }

        private static Dictionary<uint, SpiritAbilityInfo> BuildDefaultSpiritAbilities()
        {
            return new()
            {
                { 1, CreateSpiritAbility(1, 5, 1000) },
                { 100, CreateSpiritAbility(100, 5, 0) },
                { 101, CreateSpiritAbility(101, 1, 0) },
                { 102, CreateSpiritAbility(102, 1, 0) },
                { 200, CreateSpiritAbility(200, 1, 0) },
                { 300, CreateSpiritAbility(300, 1, 0) },
            };
        }

        private static SpiritAbilityInfo CreateSpiritAbility(uint templateId, uint level, uint exp)
        {
            return new SpiritAbilityInfo()
            {
                TemplateId = templateId,
                Level = level,
                ConfirmedLevel = level,
                Exp = exp,
                AbilityBuffConfigIdList = new(),
                BuffList = new()
            };
        }
    }
}

