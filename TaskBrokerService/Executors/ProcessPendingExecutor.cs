using Microsoft.Extensions.DependencyInjection;
using Shared.Database;
using System;
using System.Threading;
using System.Threading.Tasks;
using System.Transactions;
using TaskBroker.SSSB.Core;
using TaskBroker.SSSB.MessageResults;
using TaskBroker.SSSB.Utils;

namespace TaskBroker.SSSB.Executors
{
    [ExecutorAttribute("ProcessPendingExecutor", "1.0")]
    public class ProcessPendingExecutor : BaseExecutor
    {
        private readonly IServiceBrokerHelper _issbHelper;
        private readonly bool _processAll;
        private readonly string _objectID;

        public ProcessPendingExecutor(ExecutorArgs args, IServiceBrokerHelper isssbHelper) :
            base(args)
        {
            _issbHelper = isssbHelper;
            _processAll = false;
            _objectID = null;
        }

        protected override async Task<HandleMessageResult> DoExecuteTask(CancellationToken token)
        {
            var connectionManager = this.Services.GetRequiredService<IConnectionManager>();
            using (TransactionScope transactionScope = new TransactionScope(TransactionScopeOption.RequiresNew, TimeSpan.FromSeconds(300), TransactionScopeAsyncFlowOption.Enabled))
            using (var connection = await connectionManager.CreateSSSBConnectionAsync(CancellationToken.None))
            {
                await _issbHelper.ProcessPendingMessages(connection, _processAll, _objectID);
                transactionScope.Complete();
            }

            return this.EndDialog();
        }
    }
}
