using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using TaskBroker.Options;
using TaskBroker.Services;
using TaskBroker.SSSB;

namespace TaskBroker
{
    public class Program
    {
        public static void Main(string[] args)
        {
            CreateHostBuilder(args).Build().Run();
        }

        public static IHostBuilder CreateHostBuilder(string[] args) =>
            Host.CreateDefaultBuilder(args)
                .ConfigureServices((context, services) =>
                {
                    if (context.HostingEnvironment.IsDevelopment())
                    {
                        // Development service configuration
                    }
                    else
                    {
                        // Non-development service configuration
                    }

                    var configuration = context.Configuration;

                    services.Configure<SSSBOptions>(configuration.GetSection(SSSBOptions.NAME));

                    services.AddOnDemandEventService(configuration);
                    services.AddOnDemandTaskService(configuration);
                    services.AddPubSubService(configuration);
                });
    }
}
