using System;

namespace TaskBroker.SSSB.Core
{
    /// <summary>
    ///  Аттрибут обработчика
    /// </summary>
    [AttributeUsage(System.AttributeTargets.Class, Inherited = false, AllowMultiple = false)]
    public sealed class ExecutorAttribute : System.Attribute, IExecutorAttribute
    {
        public ExecutorAttribute(string name, string version)
        {
            this.Name = name;
            this.Version = version;
        }

        /// <summary>
        /// Имя плагина
        /// </summary>
        public string Name
        {
            get;
        }

        /// <summary>
        /// Версия плагина
        /// </summary>
        public string Version
        {
            get;
        }
    }
}
