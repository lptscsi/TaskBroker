using System;
using System.Threading;
using System.Threading.Tasks;

namespace Shared.Database
{
    public interface IConnectionErrorHandler
    {
        Task Handle(Exception ex, CancellationToken cancelation);
    }
}