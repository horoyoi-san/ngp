using Ananta.Server.ClientData.Client4229938;
using Ananta.Server.Configuration;
using Ananta.Server.RpcTypes.Client4229938;

namespace Ananta.Server.Protocol.Client4229938;

internal static class Profile
{
    private static PrivateServerConfig Config => PrivateServerConfigStore.Current;

    internal static int ClientVersion => Config.Client.Version;
    internal static int Aid => Config.Client.Aid;
    internal static ulong InitialUnitId => Config.Player.InitialUnitId;
    internal static uint InitialSpiritTemplateId => Config.Player.InitialSpiritTemplateId;
    internal static uint RaidId => Config.World.RaidId;
    internal static ulong SceneInstanceId => Config.World.SceneInstanceId;
    internal static uint UniverseId => Config.World.UniverseId;
    internal static int ServerId => Config.Client.ServerId;

    
    
    
    
    
    internal static string AccountId => ActiveAccount?.Uid ?? Config.Player.AccountId;
    internal static ulong PlayerPid => ActiveAccount?.Pid ?? Config.Player.Pid;
    internal static string UserName => ActiveAccount?.Username ?? Config.Player.UserName;
    internal static string DisplayName => ActiveAccount?.Nickname ?? Config.Player.DisplayName;

    private static Ananta.Server.State.AccountDatabase.Account? ActiveAccount
    {
        get
        {
            try
            {
                if (string.IsNullOrEmpty(Ananta.Server.State.AccountDatabase.Path))
                    return null;
                return Ananta.Server.State.AccountDatabase.Active();
            }
            catch
            {
                return null;
            }
        }
    }
    internal static string LoginToken => Config.Player.LoginToken;
    internal static string GameToken => Config.Player.GameToken;

    internal static bool WorldEntryOpeningEnabled => Config.World.EntryOpeningEnabled;

    
    
    
    
    
    
    
    
    internal static Vec3 WorldSpawn
    {
        get
        {
            var ball = Config.Gameplay.Basketball;
            if (ball.Enabled && ball.SpawnAtCourt)
            {
                var court = ball.SpawnCourtId > 0
                    ? BasketballCourtTable.TryGetPlayable(ball.SpawnCourtId)
                    : BasketballCourtTable.Nearest(Config.World.Spawn.X, Config.World.Spawn.Z, playableOnly: true);
                if (court is not null)
                    return new Vec3(court.X, court.Y, court.Z);
            }
            return Config.World.Spawn.ToVec3();
        }
    }

    internal static float WorldFacing
    {
        get
        {
            var ball = Config.Gameplay.Basketball;
            if (ball.Enabled && ball.SpawnAtCourt)
            {
                var court = ball.SpawnCourtId > 0
                    ? BasketballCourtTable.TryGetPlayable(ball.SpawnCourtId)
                    : BasketballCourtTable.Nearest(Config.World.Spawn.X, Config.World.Spawn.Z, playableOnly: true);
                if (court is not null)
                    return court.EulerY;
            }
            return Config.World.Facing;
        }
    }
}

