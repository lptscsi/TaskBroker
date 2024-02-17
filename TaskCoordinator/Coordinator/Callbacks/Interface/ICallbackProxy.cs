﻿using System.Threading.Tasks;

namespace Coordinator
{
    public interface ICallbackProxy<T>
    {
        BatchInfo BatchInfo { get; }
        Task TaskCompleted(T message, string error);
    }
}
