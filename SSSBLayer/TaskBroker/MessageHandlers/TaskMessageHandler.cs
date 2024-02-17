using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Shared.Errors;
using System;
using System.Threading.Tasks;
using System.Xml.Linq;
using TaskBroker.SSSB.Core;
using TaskBroker.SSSB.Executors;
using TaskBroker.SSSB.Factories;
using TaskBroker.SSSB.MessageResults;

namespace TaskBroker.SSSB.MessageHandlers
{
    public class TaskMessageHandler : BaseMessageHandler<ServiceMessageEventArgs>
    {
        protected ILogger Logger
        {
            get;
        }

        protected IServiceProvider RootServices
        {
            get;
        }

        protected Lazy<IExecutorFactory> ExecutorFactory
        {
            get;
        }

        public TaskMessageHandler(IServiceProvider rootServices)
        {
            RootServices = rootServices;
            Type loggerType = typeof(ILogger<>);
            this.Logger = (ILogger)RootServices.GetRequiredService(loggerType.MakeGenericType(this.GetType()));
            this.ExecutorFactory = new Lazy<IExecutorFactory>(() => { var res = new ExecutorFactory(); res.LoadExecutorInfo(); return res; }, true);
        }

        protected override string GetName()
        {
            return nameof(TaskMessageHandler);
        }

        public override async Task<ServiceMessageEventArgs> HandleMessage(ISSSBService sender, ServiceMessageEventArgs serviceMessageArgs)
        {
            MessageAtributes messageAtributes = null;

            try
            {
                serviceMessageArgs.Token.ThrowIfCancellationRequested();
                XElement xml = serviceMessageArgs.Message.GetMessageXML();
                messageAtributes = xml.GetMessageAttributes();
            }
            catch (OperationCanceledException)
            {
                serviceMessageArgs.TaskCompletionSource.TrySetCanceled(serviceMessageArgs.Token);
                return serviceMessageArgs;
            }
            catch (PPSException ex)
            {
                serviceMessageArgs.TaskCompletionSource.TrySetException(ex);
                return serviceMessageArgs;
            }
            catch (Exception ex)
            {
                this.Logger.LogError(ErrorHelper.GetFullMessage(ex));
                serviceMessageArgs.TaskCompletionSource.TrySetException(new PPSException(ex));
                return serviceMessageArgs;
            }

            var taskManager = serviceMessageArgs.Services.GetRequiredService<IOnDemandTaskManager>();
            try
            {
                serviceMessageArgs.Token.ThrowIfCancellationRequested();
                var task = await taskManager.GetTaskInfo(messageAtributes.TaskID.Value);
                serviceMessageArgs.TaskID = messageAtributes.TaskID.Value;
                var executorArgs = new ExecutorArgs(taskManager, task, serviceMessageArgs.Message, messageAtributes);
                await ExecuteTask(executorArgs, serviceMessageArgs);
            }
            catch (OperationCanceledException)
            {
                serviceMessageArgs.TaskCompletionSource.TrySetCanceled(serviceMessageArgs.Token);
            }
            catch (PPSException ex)
            {
                serviceMessageArgs.TaskCompletionSource.TrySetException(ex);
            }
            catch (Exception ex)
            {
                Logger.LogCritical(ErrorHelper.GetFullMessage(ex));
                serviceMessageArgs.TaskCompletionSource.TrySetException(new PPSException(ex));
            }

            return serviceMessageArgs;
        }

        protected virtual Task<HandleMessageResult> RunExecutor(IExecutor executor, ServiceMessageEventArgs args)
        {
            Task<HandleMessageResult> execResTask = executor.ExecuteTaskAsync(args.Token);
            return execResTask;
        }

        protected virtual async Task ExecuteTask(ExecutorArgs executorArgs, ServiceMessageEventArgs args)
        {
            try
            {
                var executor = this.ExecutorFactory.Value.CreateInstance(executorArgs, args);
                Task<HandleMessageResult> resultTask = RunExecutor(executor, args);

                if (executor.IsAsyncProcessing && !resultTask.IsCompleted)
                {
                    this.ExecuteAsync(resultTask, executorArgs, args);
                }
                else
                {
                    var res = await resultTask;
                    args.TaskCompletionSource.TrySetResult(res);
                }
            }
            catch (OperationCanceledException)
            {
                args.TaskCompletionSource.TrySetCanceled(args.Token);
            }
            catch (PPSException ex)
            {
                args.TaskCompletionSource.TrySetException(ex);
            }
            catch (Exception ex)
            {
                Logger.LogError(ErrorHelper.GetFullMessage(ex));
                args.TaskCompletionSource.TrySetException(new PPSException(ex));
            }
        }

        protected virtual void ExecuteAsync(Task<HandleMessageResult> execResTask, ExecutorArgs executorArgs, ServiceMessageEventArgs serviceArgs)
        {
            var continuationTask = execResTask.ContinueWith((antecedent) =>
            {
                try
                {
                    if (antecedent.IsFaulted)
                    {
                        antecedent.Exception.Flatten().Handle((err) =>
                        {
                            serviceArgs.TaskCompletionSource.TrySetException(err);
                            return true;
                        });
                    }
                    else if (antecedent.IsCanceled)
                    {
                        serviceArgs.TaskCompletionSource.TrySetCanceled(serviceArgs.Token);
                    }
                    else
                    {
                        serviceArgs.TaskCompletionSource.TrySetResult(antecedent.Result);
                    }
                }
                catch (OperationCanceledException)
                {
                    serviceArgs.TaskCompletionSource.TrySetCanceled(serviceArgs.Token);
                }
                catch (PPSException ex)
                {
                    serviceArgs.TaskCompletionSource.TrySetException(ex);
                }
                catch (Exception ex)
                {
                    Logger.LogError(ErrorHelper.GetFullMessage(ex));
                    serviceArgs.TaskCompletionSource.TrySetException(new PPSException(ex));
                }
            }, TaskContinuationOptions.ExecuteSynchronously);
        }
    }
}
