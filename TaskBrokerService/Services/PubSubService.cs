using Microsoft.Extensions.Hosting;
using System.Threading;
using System.Threading.Tasks;
using TaskBroker.SSSB.Services;

namespace TaskBroker.Services
{
    public class PubSubService : IHostedService
    {
        private readonly PubSubSSSBService _sssbService;

        public PubSubService(PubSubSSSBService sssbService)
        {
            _sssbService = sssbService;
        }

        public Task StartAsync(CancellationToken cancellationToken)
        {
            return _sssbService.Start();
        }

        public Task StopAsync(CancellationToken cancellationToken)
        {
            return _sssbService.Stop();
        }
    }
}
