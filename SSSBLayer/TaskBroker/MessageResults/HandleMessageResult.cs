using System.Data.SqlClient;
using System.Threading;
using System.Threading.Tasks;
using TaskBroker.SSSB.Core;

namespace TaskBroker.SSSB.MessageResults
{
    public abstract class HandleMessageResult
    {
        public HandleMessageResult()
        {
        }

        public abstract Task Execute(SqlConnection dbconnection, SSSBMessage message, CancellationToken token);
    }
}
