using Microsoft.Extensions.DependencyInjection;
using Shared.Errors;
using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using TaskBroker.SSSB.Core;
using TaskBroker.SSSB.Executors;

namespace TaskBroker.SSSB.Factories
{
    public class ExecutorFactory : IExecutorFactory
    {
        private readonly ConcurrentDictionary<string, ExecutorInfo> executorsDictionary = new ConcurrentDictionary<string, ExecutorInfo>();

        private static IEnumerable<(string Name, Type ExecutorType)> GetExecutorTypes(Assembly assembly)
        {
            var executorTypes = assembly
                             .GetTypes()
                             .Where(t => typeof(IExecutor).IsAssignableFrom(t) && !t.IsAbstract).ToList();

            var found = executorTypes.Where(p => p.GetCustomAttributes(false).OfType<IExecutorAttribute>().Any());

            var selected = found.Select(t => new { Name = t.GetCustomAttributes(false).OfType<IExecutorAttribute>().Select(a => $"{a.Name.Trim()}:{a.Version.Trim()}").First(), ExecutorType = t }).ToArray();

            return selected.Select(f => (f.Name, f.ExecutorType)).ToArray();
        }

        private static IEnumerable<Assembly> GetAssemblies()
        {
            var returnAssemblies = new List<Assembly>();
            var loadedAssemblies = new HashSet<string>();
            var assembliesToCheck = new Queue<Assembly>();

            var entry = Assembly.GetEntryAssembly();
            assembliesToCheck.Enqueue(entry);
            loadedAssemblies.Add(entry.FullName);
            returnAssemblies.Add(entry);

            while (assembliesToCheck.Any())
            {
                var assemblyToCheck = assembliesToCheck.Dequeue();

                foreach (var reference in assemblyToCheck.GetReferencedAssemblies())
                {
                    if (!loadedAssemblies.Contains(reference.FullName))
                    {
                        var assembly = Assembly.Load(reference);
                        assembliesToCheck.Enqueue(assembly);
                        loadedAssemblies.Add(reference.FullName);
                        returnAssemblies.Add(assembly);
                    }
                }
            }

            return returnAssemblies;
        }

        public sealed class ExecutorInfo
        {
            private readonly Type executorType;
            private readonly string name;

            public ExecutorInfo((string Name, System.Type ExecutorType) executor)
            {
                this.name = executor.Name;
                this.executorType = executor.ExecutorType;
            }

            public IExecutor CreateInstance(ExecutorArgs executorArgs, ServiceMessageEventArgs args)
            {
                var executor = (IExecutor)ActivatorUtilities.CreateInstance(args.Services, this.ExecutorType, new object[] { executorArgs });
                executorArgs.TasksManager.CurrentExecutor = executor;
                return executor;
            }

            public string Name => name;
            public Type ExecutorType => executorType;
        }

        public virtual IExecutor CreateInstance(ExecutorArgs executorArgs, ServiceMessageEventArgs args)
        {
            string name = executorArgs.TaskInfo.ExecutorTypeName;

            if (executorsDictionary.TryGetValue(name, out var executorInfo))
            {
                return executorInfo.CreateInstance(executorArgs, args);
            }
            else
            {
                throw new Exception($"Не найден Executor с именем {name}");
            }
        }

        public void LoadExecutorInfo()
        {
            var assemblies = GetAssemblies();

            foreach (var assembly in assemblies)
            {
                this.LoadExecutorInfo(assembly);
            }
        }

        public void LoadExecutorInfo(Assembly assembly)
        {
            var types = GetExecutorTypes(assembly);

            foreach (var type in types)
            {
                var executorInfo = new ExecutorInfo(type);

                var pluginInfo = executorsDictionary.AddOrUpdate(type.Name, executorInfo, (key, oldInfo) =>
                {
                    return executorInfo;
                });
            }
        }
    }
}
