using System;
using System.Buffers;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace AnantaTestGameServer.Utils
{
    public static class UXArrayPool
    {
        private static Type? type;

        internal static ArrayPool<T> Create<T>()
        {
            if (type == null)
                return ArrayPool<T>.Shared;

            var genericType = type.MakeGenericType(typeof(T));

            var instance = Activator.CreateInstance(genericType);

            if (instance is ArrayPool<T> pool)
                return pool;

            return null!;
        }
    }

    public static class UXArrayPool<T>
    {
        private readonly static ArrayPool<T> pool;
        private readonly static bool needClear;

        static UXArrayPool()
        {
            pool = UXArrayPool.Create<T>();
            needClear = false;
        }

        public static PooledArray<T> Rent(int length)
        {
            var array = pool.Rent(length);
            return new PooledArray<T>(array, length);
        }

        public static void Return(PooledArray<T> array)
        {
            var buffer = array.GetBuffer();
            pool.Return(buffer, needClear);
        }
    }
}
