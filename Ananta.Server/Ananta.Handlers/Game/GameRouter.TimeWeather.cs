using Ananta.SDK.Network;
using Ananta.SDK.Rpc;
using Ananta.SDK.Serialization;
using Ananta.Server.Protocol.Client4229938;
using GameMethods = Ananta.Server.RpcTypes.Client4229938.Methods.Game;

namespace Ananta.Server.Handlers.Game;

/// <summary>
/// Time + weather. The client runs its clock/atmosphere locally; these handlers make
/// the in-game time UI work (accept + remember) and the admin panel can force both:
/// time via SyncPlayerCurrentTime (proto-verified shape), weather via SyncPlayerWeather
/// (lua-reader-verified: 3× u32). Stored per session, re-pushed after every load.
/// </summary>
internal sealed partial class GameRouter
{
    private static void SetSessionTime(WorldEntryState state, uint hour, uint minute, bool fix, uint transition)
    {
        lock (state.SyncRoot)
        {
            state.TimeHour = Math.Min(hour, 23);
            state.TimeMinute = Math.Min(minute, 59);
            state.TimeFixed = fix;
            state.TimeTransitionSeconds = transition;
            state.HasExplicitTime = true;
        }
    }

    internal static async Task PushSessionTimeAsync(TcpSession session)
    {
        var state = GetStateIfExists(session);
        if (state is null)
            return;
        uint hour, minute, transition;
        bool fix;
        lock (state.SyncRoot)
        {
            if (!state.HasExplicitTime)
                return;
            hour = state.TimeHour;
            minute = state.TimeMinute;
            fix = state.TimeFixed;
            transition = state.TimeTransitionSeconds;
        }
        await session.NotifyAsync(MethodId.SyncPlayerCurrentTime, UxSerializer.Serialize(
            new GameMethods.SyncPlayerCurrentTime4229938
            {
                realTime = (uint)DateTimeOffset.UtcNow.ToUnixTimeSeconds(),
                raidDaySeconds = hour * 3600 + minute * 60,
                fix = fix,
                isPause = false,
                transitionSecond = transition,
                reason = 0, // RaidTimeAndWeatherChangeReason.Gm
                nodeId = 0,
            }), CancellationToken.None);
        session.Log.Info($"[TIME] push {hour:D2}:{minute:D2} fix={fix} transition={transition}s");
    }

    internal static async Task PushSessionWeatherAsync(TcpSession session)
    {
        var state = GetStateIfExists(session);
        if (state is null)
            return;
        uint weatherId, transition;
        lock (state.SyncRoot)
        {
            if (!state.HasExplicitWeather)
                return;
            weatherId = state.WeatherId;
            transition = state.WeatherTransitionSeconds;
        }
        await session.NotifyAsync(MethodId.SyncPlayerWeather, UxSerializer.Serialize(
            new GameMethods.SyncPlayerWeather4229938
            {
                weatherTypeId = weatherId,
                nextWeatherTypeId = weatherId,
                transitionSecond = transition,
            }), CancellationToken.None);
        session.Log.Info($"[WEATHER] push id={weatherId} transition={transition}s");
    }

    [Handler(MethodId.AskPassingTime)]
    private async Task AskPassingTime(Connection conn, UxRpcMessage msg)
    {
        if (msg.TryGetArgs<GameMethods.PassingTimeArgs4229938>(out var args) && args is not null)
        {
            SetSessionTime(GetWorldState(msg.Context), args.hour, args.minute, true, 5);
            conn.Log.Info($"[TIME] AskPassingTime {args.hour:D2}:{args.minute:D2}");
            await PushSessionTimeAsync(msg.Context.Session);
        }
        await conn.ReturnEmptyOkAsync(msg);
    }

    [Handler(MethodId.GmPassingTime)]
    private async Task GmPassingTime(Connection conn, UxRpcMessage msg)
    {
        if (msg.TryGetArgs<GameMethods.PassingTimeArgs4229938>(out var args) && args is not null)
        {
            SetSessionTime(GetWorldState(msg.Context), args.hour, args.minute, true, 5);
            conn.Log.Info($"[TIME] GmPassingTime {args.hour:D2}:{args.minute:D2}");
            await PushSessionTimeAsync(msg.Context.Session);
        }
        await conn.ReturnEmptyOkAsync(msg);
    }

    [Handler(MethodId.GmSetTime)]
    private async Task GmSetTime(Connection conn, UxRpcMessage msg)
    {
        if (msg.TryGetArgs<GameMethods.GmSetTimeArgs4229938>(out var args) && args is not null)
        {
            SetSessionTime(GetWorldState(msg.Context), args.hour, args.minute, true, args.transition);
            conn.Log.Info($"[TIME] GmSetTime {args.hour:D2}:{args.minute:D2} transition={args.transition}s");
            await PushSessionTimeAsync(msg.Context.Session);
        }
        await conn.ReturnEmptyOkAsync(msg);
    }

    [Handler(MethodId.GmFixRaidTime)]
    private async Task GmFixRaidTime(Connection conn, UxRpcMessage msg)
    {
        if (msg.TryGetArgs<GameMethods.GmFixRaidTimeArgs4229938>(out var args) && args is not null)
        {
            var state = GetWorldState(msg.Context);
            if (args.clear)
            {
                lock (state.SyncRoot)
                    state.HasExplicitTime = false;
                conn.Log.Info("[TIME] GmFixRaidTime clear");
            }
            else
            {
                SetSessionTime(state, args.hour, args.minute, true, 5);
                conn.Log.Info($"[TIME] GmFixRaidTime {args.hour:D2}:{args.minute:D2}");
                await PushSessionTimeAsync(msg.Context.Session);
            }
        }
        await conn.ReturnEmptyOkAsync(msg);
    }

    [Handler(MethodId.ChangePersonalTimeSetting)]
    private async Task ChangePersonalTimeSetting(Connection conn, UxRpcMessage msg)
    {
        if (msg.TryGetArgs<GameMethods.ChangePersonalTimeSettingArgs4229938>(out var args) && args is not null)
            conn.Log.Info($"[TIME] personal slot={args.index} label={args.info?.Label} {args.info?.Hour:D2}:{args.info?.Minute:D2}");
        await conn.ReturnEmptyOkAsync(msg);
    }

    [Handler(MethodId.AddPersonalTimeSetting)]
    private async Task AddPersonalTimeSetting(Connection conn, UxRpcMessage msg)
    {
        if (msg.TryGetArgs<GameMethods.ChangePersonalTimeSettingArgs4229938>(out var args) && args is not null)
            conn.Log.Info($"[TIME] personal add slot={args.index} label={args.info?.Label}");
        await conn.ReturnEmptyOkAsync(msg);
    }

    [Handler(MethodId.GmSetWeather)]
    private async Task GmSetWeather(Connection conn, UxRpcMessage msg)
    {
        if (msg.TryGetArgs<GameMethods.GmSetWeatherArgs4229938>(out var args) && args is not null)
        {
            var state = GetWorldState(msg.Context);
            lock (state.SyncRoot)
            {
                state.WeatherId = args.weatherId;
                state.WeatherTransitionSeconds = 15;
                state.HasExplicitWeather = true;
            }
            conn.Log.Info($"[WEATHER] GmSetWeather id={args.weatherId}");
            await PushSessionWeatherAsync(msg.Context.Session);
        }
        await conn.ReturnEmptyOkAsync(msg);
    }

    [Handler(MethodId.GmSetWeatherParam)]
    private async Task GmSetWeatherParam(Connection conn, UxRpcMessage msg)
    {
        if (msg.TryGetArgs<GameMethods.GmSetWeatherParamArgs4229938>(out var args) && args is not null)
            conn.Log.Info($"[WEATHER] GmSetWeatherParam id={args.weatherParamId}");
        await conn.ReturnEmptyOkAsync(msg);
    }
}
