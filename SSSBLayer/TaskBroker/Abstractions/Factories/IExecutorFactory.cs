using TaskBroker.SSSB.Core;
using TaskBroker.SSSB.Executors;

namespace TaskBroker.SSSB.Factories
{
    public interface IExecutorFactory
    {
        IExecutor CreateInstance(ExecutorArgs executorArgs, ServiceMessageEventArgs args);
        void LoadExecutorInfo();
    }
}