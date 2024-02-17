using System;
using System.Collections.Generic;

namespace TaskBroker.Options
{
    public class SSSBOptions
    {
        public const string NAME = "SSSB";

        /// <summary>
        /// Уникальный для каждой службы ID подписчика
        /// </summary>
        public Guid SubscriberInstanceID { get; set; }

        /// <summary>
        /// Топики на которые подписыется службва
        /// </summary>
        public List<string> Topics { get; set; }

        /// <summary>
        /// Максимальное кол-во обрабатываающих сообщения потоков
        /// </summary>
        public Dictionary<string, int> MaxDOP { get; set; }
    }
}
