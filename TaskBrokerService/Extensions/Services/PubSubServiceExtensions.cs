using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;
using Microsoft.Extensions.Options;
using System;
using System.Linq;
using TaskBroker.Options;
using TaskBroker.SSSB.Core;
using TaskBroker.SSSB.EF;
using TaskBroker.SSSB.PubSub;
using TaskBroker.SSSB.Scheduler;
using TaskBroker.SSSB.Services;

namespace TaskBroker.Services
{
    public static class PubSubServiceExtensions
    {
        public static void AddPubSubService(this IServiceCollection services, IConfiguration configuration)
        {
            services.AddDbContext<SSSBDbContext>((dbOptions) =>
            {
                string connectionString = configuration.GetConnectionString("DBConnectionStringSSSB");
                dbOptions.UseSqlServer(connectionString, (sqlOptions) =>
                {
                    // sqlOptions.UseRowNumberForPaging();
                });
            });

            services.AddSSSBService();
            services.TryAddSingleton<IPubSubHelper, PubSubHelper>();
            services.TryAddSingleton<IScheduleManager, ScheduleManager>();
            services.TryAddSingleton<PubSubSSSBService>((sp) =>
            {
                var sssbOptions = sp.GetRequiredService<IOptions<SSSBOptions>>().Value;
                Guid conversationGroup = sssbOptions.SubscriberInstanceID;
                return ActivatorUtilities.CreateInstance<PubSubSSSBService>(sp, new object[] { conversationGroup, sssbOptions.Topics?.AsEnumerable()?? Enumerable.Empty<string>() });
            });
            services.TryAddSingleton<HeartBeatTimer>((sp) =>
            {
                var sssbOptions = sp.GetRequiredService<IOptions<SSSBOptions>>().Value;
                Guid conversationGroup =  sssbOptions.SubscriberInstanceID;
                return ActivatorUtilities.CreateInstance<HeartBeatTimer>(sp, new object[] { conversationGroup });
            });
            services.TryAddScoped<IOnDemandTaskManager, OnDemandTaskManager>();
            services.TryAddScoped<ISettingsService, SettingsService>();
            services.AddHostedService<PubSubService>();
        }
    }
}
