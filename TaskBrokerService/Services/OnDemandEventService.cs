using Microsoft.Extensions.Hosting;
using System.Threading;
using System.Threading.Tasks;
using TaskBroker.SSSB.Services;

namespace TaskBroker.Services
{
    public class OnDemandEventService : IHostedService
    {
        private readonly OnDemandEventSSSBService _sssbService;

        public OnDemandEventService(OnDemandEventSSSBService sssbService)
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
