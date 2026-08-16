using System;
using System.Buffers;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace AnantaTestGameServer.Utils;

public readonly struct PooledArray<T> : IDisposable
{
    internal readonly T[]? _array;

    public int Length { get; }
    public ref T this[int index] => ref _array[index];

    internal PooledArray(T[] array, int length)
    {
        _array = array;
        Length = length;
    }

    public Span<T> AsSpan() => new(_array, 0, Length);

    public Span<T> AsSpan(int offset, int length)
    {
        if (_array == null)
        {
            if (offset == 0 && length == 0)
                return Span<T>.Empty;

            throw new ArgumentOutOfRangeException();
        }

        return new Span<T>(_array, offset, length);
    }

    public static implicit operator Span<T>(PooledArray<T> self) => new(self._array, 0, self.Length);

    public static implicit operator ReadOnlySpan<T>(PooledArray<T> self)
    {
        if (self._array == null)
        {
            if (self.Length == 0)
                return ReadOnlySpan<T>.Empty;

            throw new ArgumentOutOfRangeException();
        }

        if (self.Length > self._array.Length)
            throw new ArgumentOutOfRangeException();

        return new ReadOnlySpan<T>(self._array, 0, self.Length);
    }

    public T[]? GetBuffer() => _array;

    public void Dispose()
    {
        if (_array == null) return;
        UXArrayPool<T>.Return(this);
    }
}
