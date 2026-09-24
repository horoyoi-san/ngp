using Ananta.Server.Configuration;

namespace Ananta.Server.Gameplay;

internal static class WebTraversal
{
    private static WebTraversalSettings Settings => PrivateServerConfigStore.Current.Gameplay.WebTraversal;

    internal static uint MaleProtagonistId => Settings.MaleProtagonistId;
    internal static uint FemaleProtagonistId => Settings.FemaleProtagonistId;
    internal static uint FeiSuoBuff => Settings.PersistentGrappleBuffId;

    
    
    
    internal const uint SwingBuff4229938 = 52_853_761;
    internal const uint WallRushBuff4229938 = 52_853_762;
    internal const uint GrappleDiveDamageBuff4229938 = 52_959_114;
    private static readonly uint[] ClientLifecycleBuffs4229938 = [SwingBuff4229938, WallRushBuff4229938];
    private static readonly uint[] ResidentBuildWebBuffs4229938 = [GrappleDiveDamageBuff4229938];

    internal static int GrappleRearmDelayMs => Settings.GrappleRearmDelayMs;
    internal static IReadOnlyList<uint> ForbidStates => Settings.ForbidStateIds;

    internal static IReadOnlyList<uint> InitialCapabilityBuffIds
        => Combine(Settings.SharedBuffIds, new uint[] { Settings.PersistentGrappleBuffId }, Settings.MaleExtraBuffIds, ResidentBuildWebBuffs4229938);

    internal static IReadOnlyList<uint> FemaleCapabilityBuffIds
        => Combine(Settings.SharedBuffIds, new uint[] { Settings.PersistentGrappleBuffId }, Settings.FemaleExtraBuffIds, ResidentBuildWebBuffs4229938);

    internal static bool IsProtagonist(uint templateId)
        => templateId == Settings.MaleProtagonistId || templateId == Settings.FemaleProtagonistId;

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

    
    internal static uint HackerSpiritTemplateId
        => PrivateServerConfigStore.Current.Gameplay.SpiritContent.HackerSpiritTemplateId;

    internal static bool IsHacker(uint templateId)
        => templateId != 0 && templateId == HackerSpiritTemplateId;

    
    
    
    
    internal static IReadOnlyList<uint> HackerCapabilityBuffIds
        => PrivateServerConfigStore.Current.Gameplay.SpiritContent.GrantHackingAbilityBuff
            ? PrivateServerConfigStore.Current.Gameplay.SpiritContent.HackerAbilityBuffIds
            : [];

    
    
    
    
    internal static IReadOnlyList<uint> SharedCapabilityBuffIds
        => Combine(Settings.SharedBuffIds, new uint[] { Settings.PersistentGrappleBuffId }, ResidentBuildWebBuffs4229938);

    internal static IReadOnlyList<uint> CapabilityBuffIds(uint templateId)
    {
        if (templateId == Settings.MaleProtagonistId)
            return InitialCapabilityBuffIds;
        if (templateId == Settings.FemaleProtagonistId)
            return FemaleCapabilityBuffIds;

        
        
        
        
        
        
        
        
        
        
        
        
        
        var shared = SharedCapabilityBuffIds;
        return IsHacker(templateId) ? Combine(shared, HackerCapabilityBuffIds) : shared;
    }

    internal static bool IsClientLifecycleBuff(uint buffId)
        => ClientLifecycleBuffs4229938.Contains(buffId);

    internal static bool IsProtected(uint buffId)
        => Settings.SharedBuffIds.Contains(buffId)
           || Settings.MaleExtraBuffIds.Contains(buffId)
           || Settings.FemaleExtraBuffIds.Contains(buffId)
           || ResidentBuildWebBuffs4229938.Contains(buffId);

    internal static bool IsWebBuff(uint buffId)
        => buffId == Settings.PersistentGrappleBuffId || IsProtected(buffId) || IsClientLifecycleBuff(buffId);

    private static uint[] Combine(params IReadOnlyCollection<uint>[] groups)
        => groups.SelectMany(x => x).Distinct().ToArray();
}
