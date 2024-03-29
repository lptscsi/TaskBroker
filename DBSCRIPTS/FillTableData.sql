USE [testDB]
GO
INSERT [PPS].[Executor] ([ExecutorID], [Description], [FullTypeName], [Active], [IsMessageDecoder], [IsOnDemand], [ExecutorSettingsSchema], [CreateDate]) VALUES (1, N'Flush Settings Executor', N'FlushSettingsExecutor:1.0', 1, 0, 1, N'', CAST(N'2019-01-03T09:35:18.710' AS DateTime))
GO
INSERT [PPS].[Executor] ([ExecutorID], [Description], [FullTypeName], [Active], [IsMessageDecoder], [IsOnDemand], [ExecutorSettingsSchema], [CreateDate]) VALUES (2, N'Process Pending Executor', N'ProcessPendingExecutor:1.0', 1, 0, 1, N'', CAST(N'2019-01-04T06:24:41.040' AS DateTime))
GO
INSERT [PPS].[Executor] ([ExecutorID], [Description], [FullTypeName], [Active], [IsMessageDecoder], [IsOnDemand], [ExecutorSettingsSchema], [CreateDate]) VALUES (10, N'Test Executor', N'TestExecutor:1.0', 1, 0, 1, N'', CAST(N'2019-01-03T09:35:18.713' AS DateTime))
GO
INSERT [PPS].[Executor] ([ExecutorID], [Description], [FullTypeName], [Active], [IsMessageDecoder], [IsOnDemand], [ExecutorSettingsSchema], [CreateDate]) VALUES (11, N'MultyStep Executor', N'MultyStepExecutor:1.0', 1, 0, 1, N'', CAST(N'2019-01-04T17:48:35.720' AS DateTime))
GO
INSERT [PPS].[Shedule] ([SheduleID], [Name], [Interval], [Active], [CreateDate]) VALUES (1, N'One Minute Periodic', 60, 1, CAST(N'2018-12-23T16:15:05.070' AS DateTime))
GO
INSERT [PPS].[OnDemandTask] ([OnDemandTaskID], [Name], [Description], [Active], [ExecutorID], [SheduleID], [SettingID], [SSSBServiceName], [CreateDate]) VALUES (1, N'Flush Settings', N'Flushing Settings Cache', 1, 1, NULL, NULL, NULL, CAST(N'2019-01-03T09:35:18.720' AS DateTime))
GO
INSERT [PPS].[OnDemandTask] ([OnDemandTaskID], [Name], [Description], [Active], [ExecutorID], [SheduleID], [SettingID], [SSSBServiceName], [CreateDate]) VALUES (2, N'ProcessPending', N'Processes Pending Messages', 1, 2, 1, NULL, NULL, CAST(N'2019-01-04T06:25:01.350' AS DateTime))
GO
INSERT [PPS].[OnDemandTask] ([OnDemandTaskID], [Name], [Description], [Active], [ExecutorID], [SheduleID], [SettingID], [SSSBServiceName], [CreateDate]) VALUES (10, N'Test', N'Test OnDemandTask Execution', 1, 10, NULL, NULL, NULL, CAST(N'2019-01-03T09:35:18.723' AS DateTime))
GO
INSERT [PPS].[OnDemandTask] ([OnDemandTaskID], [Name], [Description], [Active], [ExecutorID], [SheduleID], [SettingID], [SSSBServiceName], [CreateDate]) VALUES (11, N'MultyStep', N'MultyStep Execution', 1, 11, NULL, NULL, NULL, CAST(N'2019-01-04T17:48:45.767' AS DateTime))
GO
