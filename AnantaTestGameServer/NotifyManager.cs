namespace AnantaTestGameServer;

using AnantaTestGameServer.Messages;
using Google.Protobuf.WellKnownTypes;
using System;
using System.Collections.Generic;
using System.Collections.Immutable;
using System.Drawing;
using System.Linq.Expressions;
using System.Net.Sockets;
using System.Numerics;
using System.Reflection;
using UX.RPC.Protocol;
using Type = Type;

public class HandlerAttribute : Attribute
{
    public int MethodId { get; set; }
    public HandlerAttribute(int ID)
    {
        this.MethodId = ID;
    }
    public HandlerAttribute(MethodId ID)
    {
        this.MethodId = (int)ID;
    }
    public delegate void HandlerDelegate(Connection conn, UxRpcMessage rpcMessage);
}
internal static class NotifyManager
{
    private static List<Type> s_handlerTypes = new List<Type>();
    private static ImmutableDictionary<int, (HandlerAttribute, HandlerAttribute.HandlerDelegate)> s_notifyReqGroup;

    public static void Init()
    {
        var handlers = ImmutableDictionary.CreateBuilder<int, (HandlerAttribute, HandlerAttribute.HandlerDelegate)>();

        foreach (var type in s_handlerTypes)
        {
            foreach (var method in type.GetMethods())
            {
                var attribute = method.GetCustomAttribute<HandlerAttribute>();
                if (attribute == null)
                    continue;

                var parameterInfo = method.GetParameters();

                var sessionParameter = Expression.Parameter(typeof(Connection));
                var rpcMessageParameter = Expression.Parameter(typeof(UxRpcMessage));

                var call = Expression.Call(method,
                    Expression.Convert(sessionParameter, parameterInfo[0].ParameterType),
                    Expression.Convert(rpcMessageParameter, parameterInfo[1].ParameterType));

                var lambda = Expression.Lambda<HandlerAttribute.HandlerDelegate>(call, sessionParameter, rpcMessageParameter);

                if (!handlers.TryGetKey(attribute.MethodId, out _))
                    handlers.Add(attribute.MethodId, (attribute, lambda.Compile()));
            }
        }
        s_notifyReqGroup = handlers.ToImmutable();
    }

    public static void AddReqGroupHandler(Type type)
    {
        s_handlerTypes.Add(type);
    }

    public static HandlerAttribute.HandlerDelegate GetHandler(int mtd)
    {
        if (s_notifyReqGroup.TryGetValue(mtd, out var handler))
        {
            return handler.Item2;
        }
        else
        {
            return null;
        }
    }
}
