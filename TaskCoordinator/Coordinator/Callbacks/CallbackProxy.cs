﻿using Microsoft.Extensions.Logging;
using Shared.Errors;
using System;
using System.Threading;
using System.Threading.Tasks;

namespace Coordinator.Callbacks
{
    public class CallbackProxy<T> : ICallbackProxy<T>, IDisposable
    {
        public enum JobStatus : int
        {
            Running = 0,
            Success = 1,
            Error = 2,
            Cancelled = 3
        }

        private readonly ILogger _logger;
        private ICallback<T> _callback;
        private CancellationToken _token;
        private CancellationTokenRegistration _register;
        private volatile int _processedCount;
        private volatile int _status;

        public CallbackProxy(ILogger<CallbackProxy<T>> logger, ICallback<T> callback, CancellationToken token)
        {
            this._logger = logger;
            this._callback = callback;
            this._token = token;
            this._register = this._token.Register(() =>
            {
                try
                {
                    this.JobCancelled();
                }
                catch (Exception ex)
                {
                    this._logger.LogError(ErrorHelper.GetFullMessage(ex));
                }
            }, false);

            this._callback.CompleteAsync.ContinueWith((t) =>
            {
                int oldstatus = Interlocked.CompareExchange(ref this._status, 0, 0);
                if (oldstatus == 0)
                {
                    var batchInfo = this._callback.BatchInfo;
                    if (batchInfo.IsComplete && this._processedCount == batchInfo.BatchSize && !this._token.IsCancellationRequested)
                    {
                        this.JobCompleted(null);
                    }
                }
            });
            this._status = 0;
        }

        async Task ICallbackProxy<T>.TaskCompleted(T message, string error)
        {
            if (string.IsNullOrEmpty(error))
            {
                this.TaskSuccess(message);
                int count = Interlocked.Increment(ref this._processedCount);
                var batchInfo = this._callback.BatchInfo;
                if (batchInfo.IsComplete && count == batchInfo.BatchSize)
                {
                    this.JobCompleted(null);
                }
            }
            else if (error == "CANCELLED")
            {
                this.JobCancelled();
            }
            else
            {
                await this.TaskError(message, error);
            }
        }

        void TaskSuccess(T message)
        {
            var oldstatus = Interlocked.CompareExchange(ref this._status, 0, 0);
            if (oldstatus == 0)
            {
                this._callback.TaskSuccess(message);
            }
        }

        async Task TaskError(T message, string error)
        {
            var oldstatus = Interlocked.CompareExchange(ref this._status, 0, 0);
            if (oldstatus == 0)
            {
                bool res = await this._callback.TaskError(message, error);
                if (!res)
                {
                    this.JobCompleted(error);
                }
            }
        }

        void JobCancelled()
        {
            var oldstatus = Interlocked.CompareExchange(ref this._status, (int)JobStatus.Cancelled, 0);
            if (oldstatus == 0)
            {
                try
                {
                    var task = Task.Run(() =>
                    {
                        try
                        {
                            this._callback.JobCancelled();
                        }
                        catch (PPSException)
                        {
                            // Already Logged
                        }
                        catch (Exception ex)
                        {
                            if (!(ex is OperationCanceledException))
                            {
                                Logger.LogError(ErrorHelper.GetFullMessage(ex));
                            }
                        }
                    });
                }
                finally
                {
                    this._register.Dispose();
                }
            }
        }

        void JobCompleted(string error)
        {
            var oldstatus = 0;
            if (string.IsNullOrEmpty(error))
            {
                oldstatus = Interlocked.CompareExchange(ref this._status, (int)JobStatus.Success, 0);
            }
            else
            {
                oldstatus = Interlocked.CompareExchange(ref this._status, (int)JobStatus.Error, 0);
            }

            if (oldstatus == 0)
            {
                try
                {
                    var task = Task.Run(() =>
                    {
                        try
                        {
                            this._callback.JobCompleted(error);
                        }
                        catch (PPSException)
                        {
                            // Already Logged
                        }
                        catch (Exception ex)
                        {
                            if (!(ex is OperationCanceledException))
                            {
                                Logger.LogError(ErrorHelper.GetFullMessage(ex));
                            }
                        }
                    });
                }
                finally
                {
                    this._register.Dispose();
                }
            }
        }

        BatchInfo ICallbackProxy<T>.BatchInfo { get { return this._callback.BatchInfo; } }
        public JobStatus Status { get { return (JobStatus)_status; } }
        protected ILogger Logger
        {
            get { return _logger; }
        }

        #region IDisposable Support
        private bool disposedValue = false;

        protected virtual void Dispose(bool disposing)
        {
            if (!disposedValue)
            {
                if (disposing)
                {
                    this.JobCancelled();
                }

                disposedValue = true;
            }
        }

        public void Dispose()
        {
            Dispose(true);
        }
        #endregion
    }
}
