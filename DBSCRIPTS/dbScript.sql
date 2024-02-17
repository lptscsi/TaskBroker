USE [testDB]
GO
CREATE SCHEMA [PPS]
GO
CREATE SCHEMA [SSSB]
GO
CREATE TYPE [PPS].[UT_Parameter] AS TABLE(
	[paramID] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](100) NOT NULL,
	[value] [nvarchar](max) NOT NULL,
	PRIMARY KEY CLUSTERED 
(
	[paramID] ASC
)WITH (IGNORE_DUP_KEY = OFF)
)
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
    CREATE   FUNCTION [PPS].[udfParameter](@task_id int, @param PPS.UT_Parameter READONLY)
    RETURNS XML
	AS
	BEGIN
	    DECLARE 
		  @res XML
		 ,@now NVARCHAR(20) = CONVERT(NVARCHAR(20),GetDate(),120);

		WITH CTE(res)
	    AS
	    ( 
			SELECT @task_id as task, @now as [date], 'true' as [multy-step],
			( SELECT [name] as [@name], [value] as [@value]
			  FROM @param
			  FOR XML PATH('param'), TYPE, ROOT('params')
			)
			FOR XML PATH ('timer'), ELEMENTS, TYPE
		 )
		 SELECT 
		      @res = res 
			FROM CTE;

		RETURN @res;
	END;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PPS].[Executor](
	[ExecutorID] [smallint] NOT NULL,
	[Description] [varchar](255) NULL,
	[FullTypeName] [varchar](255) NOT NULL,
	[Active] [bit] NOT NULL,
	[IsMessageDecoder] [bit] NOT NULL,
	[IsOnDemand] [bit] NOT NULL,
	[ExecutorSettingsSchema] [xml] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
	[RowTimeStamp] [timestamp] NOT NULL,
 CONSTRAINT [PK_EXECUTOR] PRIMARY KEY CLUSTERED 
(
	[ExecutorID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PPS].[MetaData](
	[MetaDataID] [int] IDENTITY(1,1) NOT NULL,
	[Context] [uniqueidentifier] NOT NULL,
	[IsContextConversationHandle] [bit] NOT NULL,
	[RequestCount] [int] NOT NULL,
	[RequestCompleted] [int] NOT NULL,
	[Error] [varchar](4000) NULL,
	[Result] [varchar](255) NULL,
	[CreateDate] [datetime] NOT NULL,
	[IsCanceled] [bit] NULL,
	[RowTimeStamp] [timestamp] NOT NULL,
 CONSTRAINT [PK_METADATA] PRIMARY KEY CLUSTERED 
(
	[MetaDataID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PPS].[OnDemandTask](
	[OnDemandTaskID] [int] NOT NULL,
	[Name] [varchar](100) NOT NULL,
	[Description] [varchar](500) NULL,
	[Active] [bit] NOT NULL,
	[ExecutorID] [smallint] NOT NULL,
	[SheduleID] [int] NULL,
	[SettingID] [int] NULL,
	[SSSBServiceName] [varchar](128) NULL,
	[CreateDate] [datetime] NOT NULL,
	[RowTimeStamp] [timestamp] NOT NULL,
 CONSTRAINT [PK_ONDEMANDTASK] PRIMARY KEY CLUSTERED 
(
	[OnDemandTaskID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PPS].[Setting](
	[SettingID] [int] NOT NULL,
	[Description] [varchar](255) NULL,
	[Settings] [xml] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
	[RowTimeStamp] [timestamp] NOT NULL,
 CONSTRAINT [PK_Setting] PRIMARY KEY CLUSTERED 
(
	[SettingID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PPS].[Shedule](
	[SheduleID] [int] NOT NULL,
	[Name] [varchar](100) NOT NULL,
	[Interval] [int] NOT NULL,
	[Active] [bit] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
	[RowTimeStamp] [timestamp] NOT NULL,
 CONSTRAINT [PK_SHEDULE] PRIMARY KEY CLUSTERED 
(
	[SheduleID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PPS].[Subscriber](
	[SubscriberID] [nvarchar](40) NOT NULL,
	[ConversationHandle] [uniqueidentifier] NOT NULL,
	[LastHeartBeat] [datetime] NULL,
	[LastError] [nvarchar](4000) NULL,
	[CreateDate] [datetime] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_Subscriber] PRIMARY KEY CLUSTERED 
(
	[SubscriberID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PPS].[Subscription](
	[SubscriptionID] [int] IDENTITY(1,1) NOT NULL,
	[SubscriberID] [nvarchar](40) NOT NULL,
	[Topic] [nvarchar](128) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_Subscription] PRIMARY KEY NONCLUSTERED 
(
	[SubscriptionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UK_Subscription] UNIQUE CLUSTERED 
(
	[SubscriberID] ASC,
	[Topic] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PPS].[SubscriptionError](
	[SubscriptionErrorID] [int] IDENTITY(1,1) NOT NULL,
	[ConversationHandle] [uniqueidentifier] NULL,
	[Error] [nvarchar](4000) NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_SubscriptionError] PRIMARY KEY NONCLUSTERED 
(
	[SubscriptionErrorID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SSSB].[PendingMessages](
	[PendingMessageID] [bigint] IDENTITY(1,1) NOT NULL,
	[ObjectID] [varchar](50) NULL,
	[ActivationDate] [datetime] NOT NULL,
	[FromService] [nvarchar](255) NOT NULL,
	[ToService] [nvarchar](255) NOT NULL,
	[ContractName] [nvarchar](255) NOT NULL,
	[LifeTime] [int] NULL,
	[IsWithEncryption] [bit] NOT NULL,
	[MessageBody] [varbinary](max) NOT NULL,
	[MessageType] [nvarchar](255) NOT NULL,
 CONSTRAINT [PK_PENDINGMESSAGES] PRIMARY KEY NONCLUSTERED 
(
	[PendingMessageID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [UK_Executor] ON [PPS].[Executor]
(
	[FullTypeName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Meta_Context] ON [PPS].[MetaData]
(
	[Context] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Meta_CreateDate] ON [PPS].[MetaData]
(
	[CreateDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [UK_Shedule_Name] ON [PPS].[Shedule]
(
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Subscriber_ConversationHandle] ON [PPS].[Subscriber]
(
	[ConversationHandle] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_Subscription_Topic] ON [PPS].[Subscription]
(
	[Topic] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [PPS].[Executor] ADD  CONSTRAINT [DF__Executor__Active__60882BD5]  DEFAULT ((1)) FOR [Active]
GO
ALTER TABLE [PPS].[Executor] ADD  CONSTRAINT [DF__Executor__IsMess__617C500E]  DEFAULT ((0)) FOR [IsMessageDecoder]
GO
ALTER TABLE [PPS].[Executor] ADD  CONSTRAINT [DF__Executor__IsOnDe__62707447]  DEFAULT ((0)) FOR [IsOnDemand]
GO
ALTER TABLE [PPS].[Executor] ADD  CONSTRAINT [DF__Executor__Create__63649880]  DEFAULT (getutcdate()) FOR [CreateDate]
GO
ALTER TABLE [PPS].[MetaData] ADD  CONSTRAINT [DF__MetaData__Contex__18CC84F8]  DEFAULT (newid()) FOR [Context]
GO
ALTER TABLE [PPS].[MetaData] ADD  CONSTRAINT [DF__MetaData__IsCont__19C0A931]  DEFAULT ((0)) FOR [IsContextConversationHandle]
GO
ALTER TABLE [PPS].[MetaData] ADD  CONSTRAINT [DF__MetaData__Reques__1AB4CD6A]  DEFAULT ((0)) FOR [RequestCount]
GO
ALTER TABLE [PPS].[MetaData] ADD  CONSTRAINT [DF__MetaData__Reques__1BA8F1A3]  DEFAULT ((0)) FOR [RequestCompleted]
GO
ALTER TABLE [PPS].[MetaData] ADD  CONSTRAINT [DF__MetaData__Create__1C9D15DC]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [PPS].[OnDemandTask] ADD  CONSTRAINT [DF__OnDemandT__Activ__589CF14A]  DEFAULT ((1)) FOR [Active]
GO
ALTER TABLE [PPS].[OnDemandTask] ADD  CONSTRAINT [DF__OnDemandT__Creat__59911583]  DEFAULT (getutcdate()) FOR [CreateDate]
GO
ALTER TABLE [PPS].[Setting] ADD  CONSTRAINT [DF__Setting__CreateD__51EFF3BB]  DEFAULT (getutcdate()) FOR [CreateDate]
GO
ALTER TABLE [PPS].[Shedule] ADD  CONSTRAINT [DF__Shedule__Interva__70BE939E]  DEFAULT ((0)) FOR [Interval]
GO
ALTER TABLE [PPS].[Shedule] ADD  CONSTRAINT [DF__Shedule__Active__71B2B7D7]  DEFAULT ((1)) FOR [Active]
GO
ALTER TABLE [PPS].[Shedule] ADD  CONSTRAINT [DF__Shedule__CreateD__72A6DC10]  DEFAULT (getutcdate()) FOR [CreateDate]
GO
ALTER TABLE [PPS].[Subscriber] ADD  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [PPS].[Subscriber] ADD  DEFAULT (getdate()) FOR [ModifiedDate]
GO
ALTER TABLE [PPS].[Subscription] ADD  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [PPS].[SubscriptionError] ADD  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [PPS].[OnDemandTask]  WITH CHECK ADD  CONSTRAINT [FK_OnDemandTask_Executor] FOREIGN KEY([ExecutorID])
REFERENCES [PPS].[Executor] ([ExecutorID])
GO
ALTER TABLE [PPS].[OnDemandTask] CHECK CONSTRAINT [FK_OnDemandTask_Executor]
GO
ALTER TABLE [PPS].[OnDemandTask]  WITH CHECK ADD  CONSTRAINT [FK_OnDemandTask_Setting] FOREIGN KEY([SettingID])
REFERENCES [PPS].[Setting] ([SettingID])
GO
ALTER TABLE [PPS].[OnDemandTask] CHECK CONSTRAINT [FK_OnDemandTask_Setting]
GO
ALTER TABLE [PPS].[OnDemandTask]  WITH CHECK ADD  CONSTRAINT [FK_OnDemandTask_Shedule] FOREIGN KEY([SheduleID])
REFERENCES [PPS].[Shedule] ([SheduleID])
GO
ALTER TABLE [PPS].[OnDemandTask] CHECK CONSTRAINT [FK_OnDemandTask_Shedule]
GO
ALTER TABLE [PPS].[Subscription]  WITH CHECK ADD  CONSTRAINT [FK_Subscription_Subscriber] FOREIGN KEY([SubscriberID])
REFERENCES [PPS].[Subscriber] ([SubscriberID])
ON DELETE CASCADE
GO
ALTER TABLE [PPS].[Subscription] CHECK CONSTRAINT [FK_Subscription_Subscriber]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SendMultyStep](@context uniqueidentifier, @metaID INT OUTPUT)
AS
BEGIN
SET XACT_ABORT ON;
SET NOCOUNT ON;

   DECLARE @i INT;
   SET @i=0;
   SET @metaID = NULL;

   BEGIN TRAN;
   WHILE(@i < 10)
   BEGIN
    EXEC PPS.GetMetaDataIDByContext @context, @metaID OUTPUT;
	EXEC [dbo].[sp_SendOneMultyStep] @context, @metaID;
	SET @i= @i + 1;
   END;
   COMMIT TRAN;
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_SendMultyStepAndWait]
as
BEGIN
 SET XACT_ABORT ON;
 SET NOCOUNT ON;
 SET DATEFORMAT ymd;
 
 DECLARE @metaID INT, @context UNIQUEIDENTIFIER;

 EXEC PPS.sp_DeleteOldData;

 SET @context= NewID();
 
 EXEC loopback.[testDB].dbo.SendMultyStep @context, @metaID OUTPUT;

 IF (@@ERROR != 0)
    RETURN;

 EXEC loopback.[testDB].[PPS].[sp_WaitForConversationGroupRequestCompletion] @context, 10;

 DELETE
 FROM [PPS].[MetaData] 
 WHERE [Context] = @context AND Error IS NULL;
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_SendOneMultyStep] (@context uniqueidentifier, @metaID INT)
AS
BEGIN
SET XACT_ABORT ON;
SET NOCOUNT ON;

  DECLARE @task_id INT, @SSSBServiceName NVarchar(128);
  DECLARE @msg XML;
  DECLARE @RC INT;
  DECLARE @now varchar(20);
  DECLARE @ch UNIQUEIDENTIFIER;
  DECLARE @mustCommit  BIT;
  SET @mustCommit =0;
  SET @task_id = 11;
  SET @now = CONVERT(Nvarchar(20),GetDate(),120);

 IF (@@TRANCOUNT = 0)
 BEGIN
  BEGIN TRANSACTION;
  SET @mustCommit = 1;
 END;
 
BEGIN TRY
  SELECT @SSSBServiceName = SSSBServiceName
  FROM PPS.OnDemandTask
  WHERE OnDemandTaskID = @task_id;
  
  SET @SSSBServiceName = Coalesce(@SSSBServiceName, 'PPS_OnDemandTaskService');
  
  DECLARE @param TABLE
  (
	[paramID] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [name] nVarchar(100)  NOT NULL,
    [value] nVarchar(max) NOT NULL
  );

  BEGIN DIALOG CONVERSATION @ch
  FROM SERVICE [PPS_MessageSendService]
  TO SERVICE @SSSBServiceName
  ON CONTRACT [PPS_OnDemandTaskContract]
  WITH RELATED_CONVERSATION_GROUP = @context, LIFETIME = 300, ENCRYPTION = OFF;

 
  INSERT INTO @param([name], [value])
  VALUES(N'MetaDataID', CAST(@metaID as Nvarchar(12)));

   WITH CTE(res)
   AS
   ( 
        SELECT @task_id as task, @now as [date], 'true' as [multy-step],
        ( SELECT [name] as [@name], [value] as [@value]
          FROM @param
          FOR XML PATH('param'), TYPE, ROOT('params')
        )
        FOR XML PATH ('timer'), ELEMENTS, TYPE
    )
      SELECT @msg = res FROM CTE;
   
  SEND ON CONVERSATION @ch MESSAGE TYPE [PPS_OnDemandTaskMessageType](@msg);
  
 IF (@mustCommit = 1)
    COMMIT;
END TRY
BEGIN CATCH
    -- ROLLBACK IF ERROR AND there's active transaction
    IF (XACT_STATE() <> 0)
    BEGIN
      ROLLBACK TRANSACTION;
    END;
    
    --rethrow handled error
    EXEC dbo.usp_RethrowError;
END CATCH;

SET NOCOUNT OFF;
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[sp_SendTest] (
  @BatchID int
 ,@category nvarchar(100)
 ,@infoType nvarchar(100)
 ,@context UNIQUEIDENTIFIER
 ,@ch UNIQUEIDENTIFIER OUTPUT)
AS
BEGIN
	SET XACT_ABORT ON;
	SET NOCOUNT ON;

	DECLARE 
		 @task_id          INT = 10
		,@SSSBServiceName  nvarchar(128)
		,@msg              XML
		,@RC               INT
		,@mustCommit       BIT = 0
		,@param            PPS.UT_Parameter;

	IF (@@TRANCOUNT = 0)
	 BEGIN
	  BEGIN TRANSACTION;
	  SET @mustCommit = 1;
	 END;
 
	BEGIN TRY
	  SELECT @SSSBServiceName = SSSBServiceName
	  FROM PPS.OnDemandTask
	  WHERE OnDemandTaskID = @task_id;
  
	  SET @SSSBServiceName = COALESCE(@SSSBServiceName, 'PPS_OnDemandTaskService');
  
	  INSERT INTO @param(
				   [name]
				  ,[value])
	  VALUES
		 (N'Category'      ,CAST(@category AS nvarchar(255)))
		,(N'InfoType'      ,CAST(@infoType AS nvarchar(255)))
		,(N'ClientContext' ,CAST(@context AS nvarchar(255)))
		,(N'UserId'        ,CAST('EprstUser' AS nvarchar(255)))
		,(N'BatchID'       ,CAST(@BatchID AS nvarchar(255)));
  
	  SELECT 
		 @msg = PPS.udfParameter(@task_id, @param);

      IF @ch IS NULL
	  BEGIN
		BEGIN DIALOG CONVERSATION @ch
		FROM SERVICE [PPS_OnDemandTaskService]
		TO SERVICE @SSSBServiceName
		ON CONTRACT [PPS_OnDemandTaskContract]
		WITH RELATED_CONVERSATION_GROUP = @context, LIFETIME = 3600,  ENCRYPTION = OFF;
      END;

	  SEND ON CONVERSATION @ch MESSAGE TYPE [PPS_OnDemandTaskMessageType](@msg);

	  --END CONVERSATION @ch;
 
	  IF (@mustCommit = 1)
		 COMMIT;
	END TRY
	BEGIN CATCH
		-- ROLLBACK IF ERROR AND there's active transaction
		IF (XACT_STATE() <> 0)
		BEGIN
		  ROLLBACK TRANSACTION;
		END;
    
		--rethrow handled error
		EXEC dbo.usp_RethrowError;
	END CATCH

	SET NOCOUNT OFF;
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_CleanUpClosedSSSB](@conversation_group uniqueidentifier = NULL)
AS
BEGIN
SET XACT_ABORT ON;
SET NOCOUNT ON;

DECLARE @cg UNIQUEIDENTIFIER, @now DATETIME;
SET @now= GETDATE();

DECLARE convCursor CURSOR FAST_FORWARD
FOR SELECT conversation_handle, [STATE]
FROM sys.conversation_endpoints
WHERE [STATE] in ('CD')
AND security_timestamp < DATEADD(minute, -30, @now)
AND (@conversation_group IS NULL OR conversation_group_id = @conversation_group);

OPEN convCursor;

DECLARE @convHandle uniqueidentifier, @state varchar(2);

FETCH NEXT FROM convCursor INTO @convHandle, @state;

WHILE (@@fetch_status = 0)
BEGIN
	BEGIN TRY
	END CONVERSATION @convHandle WITH cleanup;
	END TRY
	BEGIN CATCH
	END CATCH

	FETCH NEXT FROM convCursor INTO @convHandle, @state;
END;

 CLOSE convCursor;
 DEALLOCATE convCursor;
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_CleanUpSSSB](@conversation_group uniqueidentifier = NULL)
AS
BEGIN
SET XACT_ABORT ON;
SET NOCOUNT ON;

DECLARE @cg UNIQUEIDENTIFIER;

DECLARE convCursor CURSOR FAST_FORWARD
FOR SELECT conversation_handle, [STATE]
FROM sys.conversation_endpoints
WHERE [STATE] in ('ER', 'DI', 'OI')
AND (@conversation_group IS NULL OR conversation_group_id = @conversation_group);

OPEN convCursor;

DECLARE @convHandle uniqueidentifier, @state varchar(2);

FETCH NEXT FROM convCursor INTO @convHandle, @state;

WHILE (@@fetch_status = 0)
BEGIN
    BEGIN TRY
	END CONVERSATION @convHandle WITH cleanup;
	END TRY
	BEGIN CATCH
	END CATCH

	FETCH NEXT FROM convCursor INTO @convHandle, @state;
END;

CLOSE convCursor;
DEALLOCATE convCursor;

 EXEC [dbo].[usp_CleanUpClosedSSSB] @conversation_group;
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_RethrowError]
AS
BEGIN
    IF ERROR_NUMBER() IS NULL
        RETURN;

    DECLARE 
        @ErrorMessage    NVARCHAR(4000),
        @ErrorNumber     INT,
        @ErrorSeverity   INT,
        @ErrorState      INT,
        @ErrorLine       INT,
        @ErrorProcedure  NVARCHAR(200);

    -- Assign variables to error-handling functions that 
    -- capture information for RAISERROR.
    SELECT 
        @ErrorNumber = ERROR_NUMBER(),
        @ErrorSeverity = ERROR_SEVERITY(),
        @ErrorState = ERROR_STATE(),
        @ErrorLine = ERROR_LINE(),
        @ErrorProcedure = ISNULL(ERROR_PROCEDURE(), '-');

    -- Building the message string that will contain original
    -- error information.
    SELECT @ErrorMessage = 
        N'Error %d, Level %d, State %d, Procedure %s, Line %d, ' + 
            'Message: '+ ERROR_MESSAGE();

    -- Raise an error: msg_str parameter of RAISERROR will contain
    -- the original error information.
    RAISERROR 
        (
        @ErrorMessage, 
        @ErrorSeverity, 
        1,               
        @ErrorNumber,    -- parameter: original error number.
        @ErrorSeverity,  -- parameter: original error severity.
        @ErrorState,     -- parameter: original error state.
        @ErrorProcedure, -- parameter: original error procedure name.
        @ErrorLine       -- parameter: original error line number.
        );
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [PPS].[GetMetaDataIDByContext] (@context UNIQUEIDENTIFIER, @metaID INT OUTPUT)
AS
BEGIN
SET XACT_ABORT ON;
SET NOCOUNT ON;
DECLARE @RC INT,  @ctx Nvarchar(40), @mustCommit  BIT;
SET @metaID = NULL;
SET @ctx = Cast(@context as Nvarchar(40));
SET @mustCommit =0;

 IF (@@TRANCOUNT = 0)
 BEGIN
  BEGIN TRANSACTION;
  SET @mustCommit = 1;
 END;

BEGIN TRY
    EXEC @RC = sp_getapplock @Resource =  @ctx, @LockMode = 'Exclusive', @LockTimeout= 5000;

    IF (@RC < 0)
    BEGIN
      ROLLBACK TRAN;
      RAISERROR (N'Не удалось получить блокировку ресурса %s по причине %d', 16, 1, @ctx, @RC);
      RETURN;
    END;

  IF (EXISTS(SELECT * FROM [PPS].[MetaData] 
             WHERE [Context] = @context))
  BEGIN
   SELECT @metaID = MetaDataID
   FROM [PPS].[MetaData] 
   WHERE [Context] = @context;

   UPDATE [PPS].[MetaData] 
   SET RequestCount= RequestCount + 1
   WHERE MetaDataID = @metaID;
  END
  ELSE
  BEGIN
   INSERT INTO [PPS].[MetaData]([Context],[RequestCount],[RequestCompleted])
   VALUES(@context,1,0);
  
   SELECT @metaID = SCOPE_IDENTITY();
  END;

   EXEC @RC = sp_releaseapplock @Resource =  @ctx;

  IF (@mustCommit = 1)
    COMMIT;
END TRY
BEGIN CATCH
    -- ROLLBACK IF ERROR AND there's active transaction
    IF (XACT_STATE() <> 0)
    BEGIN
      ROLLBACK TRANSACTION;
    END;
    
    --rethrow handled error
    EXEC dbo.usp_RethrowError;
END CATCH;
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [PPS].[sp_CancelRequest] @context uniqueidentifier
AS
BEGIN
SET NOCOUNT ON;
SET XACT_ABORT ON;
DECLARE @RC INT,  @ctx Nvarchar(40);
SET @ctx = Cast(@context as Nvarchar(40));

  BEGIN TRAN
    EXEC @RC = sp_getapplock @Resource =  @ctx, @LockMode = 'Exclusive', @LockTimeout= 5000;

    IF (@RC < 0)
    BEGIN
      ROLLBACK TRAN;
      RAISERROR (N'Не удалось получить блокировку ресурса %s по причине %d', 16, 1, @ctx, @RC);
      RETURN;
    END;
    
	UPDATE PPS.MetaData
	SET IsCanceled=1
	WHERE Context= @context AND RequestCompleted < RequestCount;
 
  COMMIT TRAN;
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [PPS].[sp_DeleteOldData] 
AS
BEGIN
 SET NOCOUNT ON;
 DECLARE @deleteAfter  DATETIME;
 SET @deleteAfter = DATEADD (mi ,-180, GETDATE());

 DELETE FROM [PPS].MetaData
 WHERE [CreateDate] <  @deleteAfter; --older than 180 minutes
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [PPS].[sp_Publish] (@Topic NVARCHAR(128), @msg XML)
AS
BEGIN
SET XACT_ABORT ON;
SET NOCOUNT ON;
 DECLARE @noop BIT, @ch UNIQUEIDENTIFIER, @SubscriberID NVARCHAR(40), @result INT, @LastHeartBeat DateTime, @now DateTime;
 DECLARE @diff INT, @HeartBeatTimeOut INT;
 SET @HeartBeatTimeOut = 600; --Ten minutes

 SET @now= GETUTCDATE();

 DECLARE queuesCursor CURSOR FAST_FORWARD
 FOR SELECT [SubscriberID]
 FROM PPS.Subscription
 WHERE ISNULL(@Topic,N'') = N'' OR Topic= @Topic
 GROUP BY [SubscriberID];

  OPEN queuesCursor;

  FETCH NEXT FROM queuesCursor INTO @SubscriberID;

  WHILE (@@fetch_status = 0)
  BEGIN
	BEGIN TRY
      BEGIN TRANSACTION;
	   	EXEC @result = sp_getapplock @Resource = @SubscriberID, @LockMode = 'Exclusive';
		IF (@result < 0)
		BEGIN
		   RAISERROR (N'sp_getapplock failed to lock the resource: %s the reason: %d', 16, 1, @SubscriberID, @result);
		END;
		
		SET @ch = NULL;
		
		SELECT @ch = [ConversationHandle], @LastHeartBeat = [LastHeartBeat]
		FROM PPS.Subscriber
		WHERE SubscriberID= @SubscriberID AND LastError IS NULL;

		SET @now= GETUTCDATE();
		SET @diff= DATEDIFF(second,@LastHeartBeat, @now);

		IF (@ch IS NOT NULL AND @diff < @HeartBeatTimeOut)
		BEGIN
		  SET @noop = @noop;
          SEND ON CONVERSATION @ch MESSAGE TYPE [PPS_OnDemandTaskMessageType](@msg);
		END;

		EXEC @result = sp_releaseapplock @Resource = @SubscriberID;
	  COMMIT;
	END TRY
	BEGIN CATCH
      IF (XACT_STATE() <> 0)
      BEGIN
        ROLLBACK TRANSACTION;
      END;
      
	  UPDATE PPS.Subscriber 
	  SET [LastError]= ERROR_MESSAGE()
	  WHERE SubscriberID = @SubscriberID;
	 END CATCH

	 FETCH NEXT FROM queuesCursor INTO @SubscriberID;
  END;

 CLOSE queuesCursor;
 DEALLOCATE queuesCursor;

SET NOCOUNT OFF;
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [PPS].[sp_PublisherHandler]
AS
BEGIN
    SET NOCOUNT ON;
	DECLARE @cg UNIQUEIDENTIFIER, @ch UNIQUEIDENTIFIER, @messagetypename NVARCHAR(256), @messagebody varbinary(max), @result INT;
	DECLARE @msg XML, @SubscriberID NVARCHAR(40), @Topic NVARCHAR(128), @SubscriberCh UNIQUEIDENTIFIER;
	DECLARE @ErrorMessage NVARCHAR(4000), @ErrorNumber INT;

	BEGIN TRY
		BEGIN TRANSACTION;
		RECEIVE TOP(1)
		@cg = conversation_group_id,
		@ch = conversation_handle,
		@messagetypename = message_type_name,
		@messagebody = message_body
		FROM PPS_PublisherQueue;


		IF (@messagetypename = N'PPS_SubscribeMessageType' OR  @messagetypename = N'PPS_UnSubscribeMessageType' OR @messagetypename = N'PPS_HeartBeatMessageType')
		BEGIN
			SET @msg = CAST(@messagebody AS XML);
			SELECT @SubscriberID = @msg.value('(/message/@subscriberId)[1]', 'NVARCHAR(40)'),
			@Topic = @msg.value('(/message/topic)[1]', 'NVARCHAR(128)');

			EXEC @result = sp_getapplock @Resource = @SubscriberID, @LockMode = 'Exclusive';
			IF (@result < 0)
			BEGIN
			   RAISERROR (N'sp_getapplock failed to lock the resource: %s the reason: %d', 16, 1, @SubscriberID, @result);
			END
			ELSE
			BEGIN
			  SELECT @SubscriberCh = ConversationHandle
			  FROM PPS.Subscriber
			  WHERE SubscriberID = @SubscriberID;

			  IF (@messagetypename = N'PPS_SubscribeMessageType')
			  BEGIN
				IF (@SubscriberCh IS NULL)
				BEGIN
				   INSERT INTO PPS.Subscriber (SubscriberID, [ConversationHandle],[LastHeartBeat]) 
				   VALUES (@SubscriberID, @ch, GetUtcDate());
				END
				ELSE
				BEGIN
				   IF (@SubscriberCh != @ch)
				   BEGIN
				     UPDATE PPS.Subscriber
				     SET [ConversationHandle]= @ch, [ModifiedDate]= GetDate(), [LastHeartBeat]= GetUtcDate(), LastError = NULL
				     WHERE SubscriberID= @SubscriberID;
				   END;
			    END;

				SELECT @result = COUNT(*) FROM PPS.Subscription
			    WHERE SubscriberID= @SubscriberID AND Topic= @Topic;

				IF (@result = 0)
				BEGIN
				   INSERT INTO PPS.Subscription (SubscriberID, Topic) 
				   VALUES (@SubscriberID, @Topic);
				END;
			  END --@messagetypename = N'PPS_SubscribeMessageType'
			  ELSE IF (@messagetypename = N'PPS_UnSubscribeMessageType')
			  BEGIN
			     IF (@SubscriberCh IS NOT NULL AND @SubscriberCh != @ch)
				 BEGIN
				   UPDATE PPS.Subscriber
				   SET [ConversationHandle] = @ch, [ModifiedDate] = GetDate(), [LastHeartBeat]= GetUtcDate(), LastError = NULL
				   WHERE SubscriberID= @SubscriberID;
				 END;

			     DELETE PPS.Subscription
          	     WHERE SubscriberID= @SubscriberID AND Topic= @Topic;
			  END
			  ELSE IF (@messagetypename = N'PPS_HeartBeatMessageType')
			  BEGIN
   				 IF (@SubscriberCh IS NOT NULL AND @SubscriberCh != @ch)
				 BEGIN
				   UPDATE PPS.Subscriber
				   SET [ConversationHandle] = @ch, [ModifiedDate] = GetDate(), [LastHeartBeat]= GetUtcDate(), LastError = NULL
				   WHERE SubscriberID= @SubscriberID;
				 END
				 ELSE
				 BEGIN
			        UPDATE PPS.Subscriber
				    SET [LastHeartBeat]= GetUtcDate()
				    WHERE SubscriberID= @SubscriberID;
				 END;
			  END;

			  EXEC @result = sp_releaseapplock @Resource = @SubscriberID;
			END; 
		END
		ELSE IF (@messagetypename = 'http://schemas.microsoft.com/SQL/ServiceBroker/Error')
		BEGIN
	        SET @msg = CAST(@messagebody AS XML);
            SET @ErrorMessage = (SELECT @msg.value('declare namespace
     bns="http://schemas.microsoft.com/SQL/ServiceBroker/Error";
     (/bns:Error/bns:Description)[1]', 'nvarchar(3000)'));

		    UPDATE PPS.Subscriber 
			SET [LastError]= @ErrorMessage
            WHERE [ConversationHandle] = @ch;

			END CONVERSATION @ch;
	    END
		ELSE IF (@messagetypename = 'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog')
		BEGIN
		    DELETE PPS.Subscriber
            WHERE [ConversationHandle] = @ch;
			END CONVERSATION @ch;
	    END;

		COMMIT;
	END TRY
	BEGIN CATCH
        SELECT @ErrorNumber = ERROR_NUMBER(), @ErrorMessage = ERROR_MESSAGE();

		IF (XACT_STATE() < 0)
		BEGIN
			ROLLBACK TRANSACTION;
		END
		ELSE IF (XACT_STATE() > 0)
		BEGIN
			END CONVERSATION @ch WITH ERROR = @ErrorNumber DESCRIPTION = @ErrorMessage;
			COMMIT TRANSACTION;
		END;

		IF (@SubscriberID IS NOT NULL)
		BEGIN
		  UPDATE PPS.Subscriber 
		  SET [LastError]= @ErrorMessage
          WHERE SubscriberID = @SubscriberID AND [LastError] IS NULL;
		END
		ELSE
		BEGIN
		  UPDATE PPS.Subscriber 
		  SET [LastError]= @ErrorMessage
          WHERE [ConversationHandle] = @ch AND [LastError] IS NULL;
		END;
	END CATCH
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [PPS].[sp_SendFlushSettings] (@settingsType int, @settingsID int)
AS
BEGIN
SET NOCOUNT ON;
  DECLARE 
    @task_id INT = 1, 
	@msg     XML,
    @param   PPS.UT_Parameter;

  INSERT INTO @param([name], [value])
  VALUES
     ('settingsType', Cast(@settingsType as Nvarchar(40)))
    ,('settingsID'  , Cast(@settingsID as Nvarchar(40)));
 
  SELECT 
 	 @msg = PPS.udfParameter(@task_id, @param);


  EXEC [PPS].[sp_Publish] N'ADMIN', @msg;
 
SET NOCOUNT OFF;
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [PPS].[sp_SendSheduleEvent] (
   @task_id INT, 
   @relatedConversationGroup uniqueidentifier, 
   @endDialog BIT = 1)
AS
BEGIN
SET XACT_ABORT ON;
SET NOCOUNT ON;

  DECLARE 
    @ch               UNIQUEIDENTIFIER,
    @msg              XML,
	@SSSBServiceName  NVarchar(128),
    @mustCommit       BIT = 0,
	@param            PPS.UT_Parameter;

/*
 IF (@endDialog = 1 AND EXISTS(
 SELECT * FROM PPS.SheduleTask
 WHERE SheduleTaskID = @task_id AND SheduleID IS NOT NULL))
 BEGIN
 RAISERROR (N'Нельзя завершать диалог при отправке сообщения для задачи, которая имеет не внешний Sheduler',
           16, 1);
 RETURN;
 END 
*/

 IF (@relatedConversationGroup IS NULL)     
    SET @relatedConversationGroup = NewID();

 IF (@@TRANCOUNT = 0)
  BEGIN
   BEGIN TRANSACTION;
   SET @mustCommit = 1;
  END;

BEGIN TRY
  SELECT @SSSBServiceName = SSSBServiceName
  FROM PPS.OnDemandTask
  WHERE OnDemandTaskID = @task_id;
  
  SET @SSSBServiceName = Coalesce(@SSSBServiceName, 'PPS_OnDemandTaskService')
  
  --start dialog lifetime is a day
  BEGIN DIALOG CONVERSATION @ch
  FROM SERVICE [PPS_OnDemandEventService]
  TO SERVICE @SSSBServiceName
  ON CONTRACT [PPS_OnDemandTaskContract]
  WITH RELATED_CONVERSATION_GROUP = @relatedConversationGroup,  LIFETIME = 86400, ENCRYPTION = OFF;

  SELECT 
 	 @msg = PPS.udfParameter(@task_id, @param);

  SEND ON CONVERSATION @ch MESSAGE TYPE [PPS_OnDemandTaskMessageType](@msg);

  IF (@endDialog = 1)
     END CONVERSATION @ch;
  
  IF (@mustCommit = 1)
    COMMIT;
END TRY
BEGIN CATCH
    -- ROLLBACK IF ERROR AND there's active transaction
    IF (XACT_STATE() <> 0)
    BEGIN
      ROLLBACK TRANSACTION;
    END;
    
    --rethrow handled error
    EXEC dbo.usp_RethrowError;
END CATCH

SET NOCOUNT OFF;
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [PPS].[sp_SetCompleted] (@MetaDataID INT, @Result NVARCHAR(255) = NULL, @isCanceled BIT =0,  @ErrorMessage NVARCHAR(4000)= NULL)
AS
BEGIN
 SET NOCOUNT ON;
 DECLARE @RC INT, @mustCommit BIT, @ctx NVARCHAR(40);
 SET @mustCommit=0;
 
  IF (@@TRANCOUNT = 0)
   SET @mustCommit = 1;


 BEGIN TRY
  IF (@mustCommit = 1)
     BEGIN TRANSACTION;

   SELECT @ctx = Cast([Context] as NVARCHAR(40))
   FROM [PPS].[MetaData] WITH (nolock)
   WHERE MetaDataID= @MetaDataID;

   EXEC @RC = sp_getapplock @Resource =  @ctx, @LockMode = 'Exclusive', @LockTimeout= 30000;
   IF (@RC < 0)
   BEGIN
      RAISERROR (N'sp_getapplock failed to lock the resource: %s the reason: %d', 16, 1, @ctx, @RC);
   END;

   UPDATE [PPS].[MetaData]
   SET RequestCompleted= RequestCompleted + 1
   WHERE MetaDataID= @MetaDataID;
   
   IF (@isCanceled = 1)
   BEGIN
     UPDATE [PPS].[MetaData]
     SET IsCanceled= 1
     WHERE MetaDataID= @MetaDataID AND ISNULL(IsCanceled,0) = 0;
   END;

   IF (@Result IS NOT NULL)
   BEGIN
     UPDATE [PPS].[MetaData]
     SET Result = @Result
     WHERE MetaDataID= @MetaDataID AND Error IS NULL AND ISNULL(IsCanceled,0) = 0;
   END;

   IF (@ErrorMessage IS NOT NULL)
   BEGIN
     UPDATE [PPS].[MetaData]
     SET Error = @ErrorMessage, IsCanceled = 1
     WHERE MetaDataID= @MetaDataID AND Error IS NULL AND ISNULL(IsCanceled,0) = 0;
   END;

   EXEC sp_releaseapplock @Resource =  @ctx;
   IF (@mustCommit = 1)
     COMMIT TRANSACTION;
 END TRY
 BEGIN CATCH
    IF (XACT_STATE() <> 0 AND @mustCommit = 1)
     BEGIN
      ROLLBACK TRANSACTION;
     END;
    
    EXEC dbo.usp_RethrowError;
 END CATCH

SET NOCOUNT OFF;
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [PPS].[sp_WaitForCompletion](@conversatioHandle UNIQUEIDENTIFIER, @timeOut INT = 300)
AS
BEGIN
 SET XACT_ABORT ON;
 SET NOCOUNT ON;

 DECLARE @ctx Nvarchar(255), @RC INT, @isCanceled BIT;
 DECLARE @startTime DATETIME, @elapsedTime DATETIME;
 SET @ctx = Cast(@conversatioHandle as Nvarchar(255));
 SET @isCanceled=0;

 DECLARE @ErrorMessage NVARCHAR(4000), @ErrorNumber INT;

 SELECT @isCanceled = 0, @ErrorMessage = NULL;

DECLARE @cg UNIQUEIDENTIFIER;
DECLARE @ch UNIQUEIDENTIFIER;
DECLARE @msg VARBINARY(MAX);
DECLARE @messagetypename NVARCHAR(255);

DECLARE @exitWhile BIT;
SET @exitWhile = 0;
SET @startTime = GETDATE();
SET @elapsedTime =0;

WHILE(@exitWhile = 0)
BEGIN
 SET @cg = NULL;
 SET @ch = NULL;
 SET @messagetypename = NULL;
 SET @isCanceled = 0;
 SET @ErrorMessage = NULL;

 BEGIN TRY
   BEGIN TRANSACTION; 
     WAITFOR (
       RECEIVE TOP(1)
       @cg = conversation_group_id,
       @ch = conversation_handle,
       @messagetypename = message_type_name,
       @msg = message_body
       FROM PPS_MessageSendQueue
       WHERE conversation_handle = @conversatioHandle
      ), TIMEOUT 5000;
	COMMIT TRANSACTION;

	BEGIN TRANSACTION; 
	EXEC @RC = sp_getapplock @Resource =  @ctx, @LockMode = 'Exclusive', @LockTimeout= 5000;
    IF (@RC < 0)
    BEGIN
     RAISERROR (N'sp_getapplock failed to lock the resource: %s the reason: %d', 16, 1, @ctx, @RC);
    END

   SET @elapsedTime = DATEDIFF (ss, @startTime, GETDATE());

   IF (@ErrorMessage IS NOT NULL)
   BEGIN
     RAISERROR (@ErrorMessage, 16,1);
   END
   ELSE IF (@isCanceled = 1)
   BEGIN
     RAISERROR (N'The operation %s cancelled', 16,1, @ctx);
   END   
   ELSE IF (@ch IS NULL)
   BEGIN
	  -- NOOP CONTINUE
      SET @exitWhile = 0;
   END
   ELSE IF (@messagetypename = N'PPS_StepCompleteMessageType')
   BEGIN
      SET @exitWhile = 1;
   END
   ELSE IF (@messagetypename = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog')
   BEGIN
     SET @exitWhile = 1;
   END
   ELSE IF (@messagetypename = N'http://schemas.microsoft.com/SQL/ServiceBroker/Error')
   BEGIN
     DECLARE @errmsg XML;
     SELECT @errmsg = CAST(@msg as XML);
     SET @ErrorNumber = (SELECT @errmsg.value(N'declare namespace
     bns="http://schemas.microsoft.com/SQL/ServiceBroker/Error";
     (/bns:Error/bns:Code)[1]', 'int'));
     SET @ErrorMessage = (SELECT @errmsg.value('declare namespace
     bns="http://schemas.microsoft.com/SQL/ServiceBroker/Error";
     (/bns:Error/bns:Description)[1]', 'nvarchar(3000)'));
     
	 RAISERROR (N'Error: %s with the number: %d', 16, 1, @ErrorMessage, @ErrorNumber);
   END
   ELSE IF (@elapsedTime > @timeOut)      
   BEGIN
     RAISERROR (N'The operation %s ended with timeout', 16,1, @ctx);
   END;

  EXEC sp_releaseapplock @Resource =  @ctx;
  COMMIT TRANSACTION;

  IF (@exitWhile = 1)
  BEGIN
     BEGIN TRANSACTION
        END CONVERSATION @conversatioHandle;
     COMMIT TRANSACTION;
  END;
 END TRY
 BEGIN CATCH
     SET @exitWhile = 1;

     IF (XACT_STATE() <> 0)
     BEGIN
      ROLLBACK TRANSACTION;
     END;
    
	BEGIN TRY
	   BEGIN TRANSACTION
         END CONVERSATION @conversatioHandle;
       COMMIT TRANSACTION;
	END TRY
    BEGIN CATCH
     IF (XACT_STATE() <> 0)
     BEGIN
      ROLLBACK TRANSACTION;
     END;
	 SET @exitWhile = 1;
    END CATCH


    EXEC dbo.usp_RethrowError;
 END CATCH
END; --WHILE
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [PPS].[sp_WaitForConversationGroupRequestCompletion] (@context UNIQUEIDENTIFIER, @timeOut INT = 300)
AS
BEGIN
 SET XACT_ABORT ON;
 SET NOCOUNT ON;

 DECLARE @metaID INT, @ctx Nvarchar(255), @cnt INT, @IsContextConversationHandle BIT, @RC INT, @isCanceled BIT;
 SET @ctx = Cast(@context as Nvarchar(255));
 SET @isCanceled=0;

 DECLARE @ErrorMessage NVARCHAR(4000), @ErrorNumber INT;

 SELECT @metaID = MetaDataID, @cnt = RequestCount, @isCanceled = IsCanceled, @ErrorMessage = [Error],
   @IsContextConversationHandle=IsContextConversationHandle
   FROM [PPS].[MetaData] 
   WHERE [Context] = @context;

DECLARE @cg UNIQUEIDENTIFIER;
DECLARE @ch UNIQUEIDENTIFIER;
DECLARE @msg VARBINARY(MAX);
DECLARE @messagetypename NVARCHAR(255);
DECLARE @startTime DATETIME, @elapsedTime DATETIME;
DECLARE @tempTbl TABLE
(
   RequestCompleted INT NOT NULL
);
DECLARE @i int, @exitWhile BIT;
SET @i=0; 
SET @exitWhile =0;
SET @startTime = GETDATE();
SET @elapsedTime =0;


WHILE(@exitWhile = 0)
BEGIN
 SET @cg = NULL;
 SET @ch = NULL;
 SET @messagetypename = NULL;
 SET @isCanceled = 0;
 SET @ErrorMessage = NULL;

 BEGIN TRY
  IF (@isCanceled = 1 OR @ErrorMessage IS NOT NULL)
  BEGIN
    IF (@ErrorMessage IS NOT NULL)
	   RAISERROR (@ErrorMessage, 16,1);
	  ELSE
	   RAISERROR (N'The operation %s cancelled', 16,1, @ctx);
  END;

  BEGIN TRANSACTION;
    WAITFOR (
     RECEIVE TOP(1)
      @cg = conversation_group_id,
      @ch = conversation_handle,
      @messagetypename = message_type_name,
      @msg = message_body
     FROM PPS_MessageSendQueue
     WHERE conversation_group_id = @context
     ), TIMEOUT 5000;

     IF (@ch IS NOT NULL)
     BEGIN
      END CONVERSATION @ch;
     END;
   COMMIT TRANSACTION;
  
   BEGIN TRANSACTION; 
   EXEC @RC = sp_getapplock @Resource =  @ctx, @LockMode = 'Exclusive', @LockTimeout= 5000;
   IF (@RC < 0)
   BEGIN
   RAISERROR (N'sp_getapplock failed to lock the resource: %s the reason: %d', 16, 1, @ctx, @RC);
   END
       
   SET @elapsedTime = DATEDIFF (ss, @startTime, GETDATE());

   SELECT @cnt = RequestCount, @isCanceled = IsCanceled, @ErrorMessage = [Error], @i = RequestCompleted
   FROM [PPS].[MetaData] 
   WHERE [Context] = @context;

   IF (@ErrorMessage IS NOT NULL)
   BEGIN
      RAISERROR (@ErrorMessage, 16,1);
   END
   ELSE IF (@isCanceled = 1)
   BEGIN
      RAISERROR (N'The operation %s cancelled', 16,1, @ctx);
   END 
   ELSE IF (@i = @cnt)
   BEGIN
     SET @exitWhile=1;
   END     
   ELSE IF (@messagetypename = N'PPS_StepCompleteMessageType')
   BEGIN
     UPDATE a
     SET RequestCompleted= RequestCompleted + 1
     OUTPUT inserted.RequestCompleted INTO @tempTbl
     FROM PPS.MetaData as a
     WHERE Context= @context;
     
	 SELECT top(1) @i = RequestCompleted
     FROM @tempTbl;
     DELETE FROM @tempTbl;

     IF (@i = @cnt)
     BEGIN
       SET @exitWhile=1;
     END;
   END
   ELSE IF (@messagetypename = N'http://schemas.microsoft.com/SQL/ServiceBroker/Error')
   BEGIN
     DECLARE @errmsg XML;
     SELECT @errmsg = CAST(@msg as XML);
     SET @ErrorNumber = (SELECT @errmsg.value(N'declare namespace
     bns="http://schemas.microsoft.com/SQL/ServiceBroker/Error";
     (/bns:Error/bns:Code)[1]', 'int'));
     SET @ErrorMessage = (SELECT @errmsg.value('declare namespace
     bns="http://schemas.microsoft.com/SQL/ServiceBroker/Error";
     (/bns:Error/bns:Description)[1]', 'nvarchar(3000)'));

     RAISERROR (N'Error: %s with the number: %d', 16, 1, @ErrorMessage, @ErrorNumber);
   END
   ELSE IF (@elapsedTime > @timeOut)
   BEGIN
      RAISERROR (N'The operation %s ended with timeout', 16,1, @ctx);
   END;
   
   EXEC sp_releaseapplock @Resource =  @ctx;
   COMMIT TRANSACTION;
 END TRY
 BEGIN CATCH
     SET @exitWhile = 1;

     IF (XACT_STATE() <> 0)
     BEGIN
      ROLLBACK TRANSACTION;
     END;
    
	 UPDATE a
     SET Error = ERROR_MESSAGE(), IsCanceled = 1
     FROM PPS.MetaData as a
     WHERE Context= @context AND (Error IS NULL OR ISNULL(IsCanceled,0) = 0);

	EXEC [PPS].[usp_CleanUpConversationGroup] @context;

    EXEC dbo.usp_RethrowError;
 END CATCH
END; --WHILE
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [PPS].[sp_WaitForConversationHandleRequestCompletion](@context UNIQUEIDENTIFIER, @timeOut INT = 300)
AS
BEGIN
 SET XACT_ABORT ON;
 SET NOCOUNT ON;

 DECLARE @metaID INT, @ctx Nvarchar(255), @cnt INT, @IsContextConversationHandle BIT, @RC INT, @isCanceled BIT;
 DECLARE @startTime DATETIME, @elapsedTime DATETIME;

 SET @ctx = Cast(@context as Nvarchar(255));
 SET @isCanceled=0;

 DECLARE @ErrorMessage NVARCHAR(4000), @ErrorNumber INT;

 SELECT @metaID = MetaDataID, @cnt = RequestCount, @isCanceled = IsCanceled, @ErrorMessage = [Error],
   @IsContextConversationHandle=IsContextConversationHandle
   FROM [PPS].[MetaData] 
   WHERE [Context] = @context;

BEGIN TRY
	IF (@isCanceled = 1 OR @ErrorMessage IS NOT NULL)
    BEGIN
      BEGIN TRY
	   BEGIN TRANSACTION
         END CONVERSATION @context;
       COMMIT TRANSACTION;
	  END TRY
      BEGIN CATCH
	    IF (XACT_STATE() <> 0)
        BEGIN
           ROLLBACK TRANSACTION;
        END;
      END CATCH
	  
	  IF (@ErrorMessage IS NOT NULL)
	   RAISERROR (@ErrorMessage, 16,1);
	  ELSE
	   RAISERROR (N'The operation %s cancelled', 16,1, @ctx);
    END;
END TRY
BEGIN CATCH
     IF (XACT_STATE() <> 0)
     BEGIN
      ROLLBACK TRANSACTION;
     END;
  EXEC dbo.usp_RethrowError; 
  RETURN;
END CATCH
  
DECLARE @cg UNIQUEIDENTIFIER;
DECLARE @ch UNIQUEIDENTIFIER;
DECLARE @msg VARBINARY(MAX);
DECLARE @messagetypename NVARCHAR(255);
DECLARE @tempTbl TABLE
(
   RequestCompleted INT NOT NULL
);

DECLARE @i int, @exitWhile BIT;
SET @i=0;
SET @exitWhile = 0;
SET @startTime = GETDATE();
SET @elapsedTime =0;

WHILE(@exitWhile = 0)
BEGIN
 SET @cg = NULL;
 SET @ch = NULL;
 SET @messagetypename = NULL;
 SET @isCanceled = 0;
 SET @ErrorMessage = NULL;

 BEGIN TRY
   BEGIN TRANSACTION; 
     WAITFOR (
       RECEIVE TOP(1)
       @cg = conversation_group_id,
       @ch = conversation_handle,
       @messagetypename = message_type_name,
       @msg = message_body
       FROM PPS_MessageSendQueue
       WHERE conversation_handle = @context
      ), TIMEOUT 5000;
	COMMIT TRANSACTION;

	BEGIN TRANSACTION; 
	EXEC @RC = sp_getapplock @Resource =  @ctx, @LockMode = 'Exclusive', @LockTimeout= 5000;
    IF (@RC < 0)
    BEGIN
     RAISERROR (N'sp_getapplock failed to lock the resource: %s the reason: %d', 16, 1, @ctx, @RC);
    END

    SELECT @cnt = RequestCount, @isCanceled = IsCanceled, @ErrorMessage = [Error], @i = RequestCompleted
    FROM [PPS].[MetaData]
    WHERE [Context] = @context;

   SET @elapsedTime = DATEDIFF (ss, @startTime, GETDATE());

   IF (@ErrorMessage IS NOT NULL)
   BEGIN
     RAISERROR (@ErrorMessage, 16,1);
   END
   ELSE IF (@isCanceled = 1)
   BEGIN
     RAISERROR (N'The operation %s cancelled', 16,1, @ctx);
   END   
   ELSE IF (@i = @cnt)
   BEGIN
     SET @exitWhile=1;
   END 
   ELSE IF (@ch IS NULL)
   BEGIN
	  -- NOOP CONTINUE
      SET @exitWhile = 0;
   END
   ELSE IF (@messagetypename = N'PPS_StepCompleteMessageType')
   BEGIN
     UPDATE a
     SET RequestCompleted= RequestCompleted + 1
     OUTPUT inserted.RequestCompleted INTO @tempTbl
     FROM PPS.MetaData as a
     WHERE Context= @context;
  
     SELECT top(1) @i = RequestCompleted
     FROM @tempTbl;
  
     DELETE FROM @tempTbl;
  
     IF (@i = @cnt)
     BEGIN
        SET @exitWhile = 1;
     END;
   END
   ELSE IF (@messagetypename = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog')
   BEGIN
     SET @exitWhile = 1;
   END
   ELSE IF (@messagetypename = N'http://schemas.microsoft.com/SQL/ServiceBroker/Error')
   BEGIN
     DECLARE @errmsg XML;
     SELECT @errmsg = CAST(@msg as XML);
     SET @ErrorNumber = (SELECT @errmsg.value(N'declare namespace
     bns="http://schemas.microsoft.com/SQL/ServiceBroker/Error";
     (/bns:Error/bns:Code)[1]', 'int'));
     SET @ErrorMessage = (SELECT @errmsg.value('declare namespace
     bns="http://schemas.microsoft.com/SQL/ServiceBroker/Error";
     (/bns:Error/bns:Description)[1]', 'nvarchar(3000)'));
     
	 RAISERROR (N'Error: %s with the number: %d', 16, 1, @ErrorMessage, @ErrorNumber);
   END
   ELSE IF (@elapsedTime > @timeOut)      
   BEGIN
     RAISERROR (N'The operation %s ended with timeout', 16,1, @ctx);
   END;

  EXEC sp_releaseapplock @Resource =  @ctx;
  COMMIT TRANSACTION;

  IF (@exitWhile = 1)
  BEGIN
     BEGIN TRANSACTION
        END CONVERSATION @context;
     COMMIT TRANSACTION;
  END;
 END TRY
 BEGIN CATCH
     SET @exitWhile = 1;

     IF (XACT_STATE() <> 0)
     BEGIN
      ROLLBACK TRANSACTION;
     END;
    
	BEGIN TRY
	   BEGIN TRANSACTION
         END CONVERSATION @context;
       COMMIT TRANSACTION;
	END TRY
    BEGIN CATCH
     IF (XACT_STATE() <> 0)
     BEGIN
      ROLLBACK TRANSACTION;
     END;
	 SET @exitWhile = 1;
    END CATCH

	UPDATE a
    SET Error = ERROR_MESSAGE(), IsCanceled = 1
    FROM PPS.MetaData as a
    WHERE Context= @context AND (Error IS NULL OR ISNULL(IsCanceled,0) = 0);

    EXEC dbo.usp_RethrowError;
 END CATCH
END; --WHILE
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [PPS].[usp_CleanUpConversationGroup](@conversation_group uniqueidentifier)
AS
BEGIN
SET XACT_ABORT ON;
SET NOCOUNT ON;

DECLARE @cg UNIQUEIDENTIFIER
DECLARE convCursor CURSOR FAST_FORWARD
FOR SELECT conversation_handle, [STATE]
FROM sys.conversation_endpoints
WHERE conversation_group_id = @conversation_group;

OPEN convCursor;

DECLARE @convHandle uniqueidentifier, @state varchar(2);

FETCH NEXT FROM convCursor INTO @convHandle, @state;

WHILE (@@fetch_status = 0)
BEGIN
	BEGIN TRY
	END CONVERSATION @convHandle WITH cleanup;
	END TRY
	BEGIN CATCH
	END CATCH

	FETCH NEXT FROM convCursor INTO @convHandle, @state;
END;

CLOSE convCursor;
DEALLOCATE convCursor;
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create procedure [SSSB].[AutoEnableQueues] 
as
BEGIN
set nocount on;

declare queuesCursor cursor fast_forward
for select Name 
from sys.service_queues
where is_ms_shipped = 0
	and
	Name not like 'SqlQueryNotificationService%'
	and
	is_receive_enabled = 0;
	
declare @name nvarchar(128);
declare @query nvarchar(1000);

--set @query = 'alter queue @queue with status = on;'

open queuesCursor;

fetch next from queuesCursor into @name;

while (@@fetch_status = 0)
begin
	set @query = 'alter queue ' + @name + ' with status = on;';
	exec sp_executesql
		@stmt = @query;

	--exec sp_executesql
	--	@stmt = @query,
	--	@params = N'@queue nvarchar(128)',
	--	@queue = @name

	fetch next from queuesCursor into @name;
end;

close queuesCursor;
deallocate queuesCursor;

set nocount off;
return 0;
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create procedure [SSSB].[BeginDialogConversation] (
	@fromService nvarchar(255),
	@toService nvarchar(255),
	@contractName nvarchar(128),
	@lifetime int,
	@withEncryption bit,
	@relatedConversationID uniqueidentifier,
	@relatedConversationGroupID uniqueidentifier,
	@conversationHandle uniqueidentifier output	
)
WITH EXECUTE AS OWNER
AS
BEGIN
set nocount on;

declare @query nvarchar(4000);

set @query = 'begin dialog @ch from service @fs to service @ts, ''current database'' on contract @cn with encryption = '

if (@withEncryption = 1)
	set @query = @query + 'ON ';
else
	set @query = @query + 'OFF ';
	
if (@relatedConversationID is not null)
	set @query = @query + ', RELATED_CONVERSATION = @rch';
else if (@relatedConversationGroupID is not null)
	set @query = @query + ', RELATED_CONVERSATION_GROUP = @rcg';
	
if (@lifetime is not null and @lifetime > 0)
	set @query = @query + ', LIFETIME = @ltime ';
	
exec sp_executesql
	@stmt = @query,
	@params = N'@ch uniqueidentifier output, @fs nvarchar(255), @ts nvarchar(255), @cn nvarchar(128), @rch uniqueidentifier, @rcg uniqueidentifier, @ltime int',
	@ch = @conversationHandle output,
	@fs = @fromService,
	@ts = @toService,
	@cn = @contractName,
	@rch = @relatedConversationID,
	@rcg = @relatedConversationGroupID,
	@ltime = @lifetime;
        
set nocount off;
return 0;
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create procedure [SSSB].[EndConversation] (
	@conversationHandle uniqueidentifier,
	@withCleanup bit,
	@errorCode int,
	@errorDescription nvarchar(255)
)
AS
BEGIN
set nocount on;

if (@withCleanup = 1)
begin
	end conversation @conversationHandle with cleanup;
end
else if (@errorCode is not null)
begin
	end conversation @conversationHandle with error = @errorCode description = @errorDescription;
end
else
begin
	end conversation @conversationHandle;
end

set nocount off;
return 0;
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [SSSB].[GetActiveConversationByInitiatorGroupID]
(
	@initiatorConversationGroupID uniqueidentifier,
    @farService nvarchar(256),
	@conversationHandle uniqueidentifier output,
	@conversationID uniqueidentifier output,
	@lifetime datetime output,
	@state char(2) output,
	@dialogTimer datetime output
)
AS
BEGIN
set nocount on;

set	@conversationHandle = null;
set	@conversationID = null;
set	@lifetime = null;
set	@state = null;
set	@dialogTimer = null;

select
	@conversationHandle = conversation_handle,
	@conversationID = conversation_id,
	@lifetime = lifetime,
	@farService = far_service,
	@dialogTimer = dialog_timer
from sys.conversation_endpoints with (nolock)
where conversation_group_id = @initiatorConversationGroupID 
    and [far_service] = @farService
	and is_initiator = 1
	and [state] not in ('DI', 'DO', 'ER', 'CD');

set nocount off;
return 0;
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create procedure [SSSB].[GetServiceQueueName] 
(
	@serviceName nvarchar(128),
	@queueName nvarchar(128) output
)
AS
BEGIN
set nocount on;

set @queueName = (select q.name 
					from sys.service_queues q 
					inner join sys.services s
						on s.service_queue_id = q.object_id
					where s.name = @serviceName);

set nocount off;
return 0;
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [SSSB].[ImmediateReceiveMessagesFromQueue]
(
	@queueName nvarchar(128),
	@fetchSize int,
	@conversation_group uniqueidentifier = NULL
)
WITH EXECUTE AS OWNER
AS
BEGIN
set nocount on;

declare @query nvarchar(4000);

IF (@conversation_group IS NULL)
BEGIN
set @query = N'receive top(@fetchSize) 
			conversation_group_id, 
			conversation_handle,
			message_sequence_number,
			service_name, 
			service_contract_name, 
			message_type_name, 
			validation, 
			message_body 
        from ' + @queueName + N';';

	exec sp_executesql
	@stmt = @query,
	@params = N'@fetchSize int',
	@fetchSize = @fetchSize;
END
ELSE
BEGIN
set @query = N'receive top(@fetchSize) 
			conversation_group_id, 
			conversation_handle,
			message_sequence_number,
			service_name, 
			service_contract_name, 
			message_type_name, 
			validation, 
			message_body 
        from ' + @queueName + N' WHERE conversation_group_id = @conversation_group;';

    exec sp_executesql
	@stmt = @query,
	@params = N'@fetchSize int, @conversation_group uniqueidentifier',
	@fetchSize = @fetchSize,
	@conversation_group = @conversation_group;
END;

set nocount off;
return 0;
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [SSSB].[LockInitiatorConversationGroup] 
(
	@initiatorConversationGroupID uniqueidentifier
)
AS
BEGIN
 SET NOCOUNT ON;

 DECLARE @result INT, @context NVARCHAR(40);
 SET @context= Cast(@initiatorConversationGroupID as NVARCHAR(40));

 EXEC @result = sp_getapplock @Resource =  @context, @LockMode = 'Exclusive';
 IF (@result < 0)
  BEGIN
   RAISERROR (N'sp_getapplock failed to lock the resource: %s the reason: %d', 16, 1, @context, @result);
  END;

 SET NOCOUNT OFF;
 RETURN @result;
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [SSSB].[ProcessPendingMessages](@ProccessALL BIT = 0, @ObjectID Varchar(50) = N'')
AS
BEGIN
 SET XACT_ABORT ON;
 SET NOCOUNT ON;

DECLARE @selectedPendingMessages TABLE
(
	PendingMessageID bigint primary key,
	ObjectID varchar(50),
	ActivationDate datetime,
	FromService nvarchar(255),
	ToService nvarchar(255),
	ContractName nvarchar(255),
	[LifeTime] int,
	IsWithEncryption bit,
	MessageBody varbinary(MAX),
	MessageType nvarchar(255)
);

 DECLARE @date datetime;
 SET @date = GETDATE();

DECLARE @transactionCount int;
SET @transactionCount = @@trancount;
IF (@transactionCount = 0)
	BEGIN TRANSACTION;

DELETE FROM SSSB.PendingMessages
OUTPUT deleted.PendingMessageID, 
	deleted.ObjectID, 
	deleted.ActivationDate, 
	deleted.FromService, 
	deleted.ToService, 
	deleted.ContractName,
	deleted.[LifeTime], 
	deleted.IsWithEncryption, 
    deleted.MessageBody, 
	deleted.MessageType
INTO @selectedPendingMessages
WHERE 
(IsNull(@ProccessALL,0) = 1 OR ActivationDate <= @date)
AND
(IsNull(@ObjectID,'') = '' OR ObjectID = @ObjectID);


DECLARE
	@fromService nvarchar(255),
	@toService nvarchar(255),
	@contractName nvarchar(255),
	@lifeTime int,
	@isWithEncryption bit,
	@messageBody varbinary(max),
	@messageType nvarchar(255),
	@conversationHandle uniqueidentifier;

DECLARE pendingMessagesCursor CURSOR FAST_FORWARD
FOR SELECT FromService, 
	ToService, 
	ContractName, 
	[LifeTime], 
	IsWithEncryption, 
	MessageBody, 
	MessageType
FROM @selectedPendingMessages;

OPEN pendingMessagesCursor;

FETCH NEXT FROM pendingMessagesCursor
INTO
	@fromService,
	@toService,
	@contractName,
	@lifeTime,
	@isWithEncryption,
	@messageBody,
	@messageType;

WHILE (@@fetch_status = 0)
BEGIN
   EXEC SSSB.BeginDialogConversation
			@fromService,
			@toService,
			@contractName,
			@lifetime,
			@isWithEncryption,
			null,
			null,
			@conversationHandle output;
	
	EXEC SSSB.SendMessage
			@conversationHandle,
			@messageType,
			@messageBody;
		
	END CONVERSATION @conversationHandle;
	

   FETCH NEXT FROM pendingMessagesCursor
   INTO
	@fromService,
	@toService,
	@contractName,
	@lifeTime,
	@isWithEncryption,
	@messageBody,
	@messageType;
END;

CLOSE pendingMessagesCursor;
DEALLOCATE pendingMessagesCursor;

IF (@transactionCount = 0)
	COMMIT TRANSACTION;

SET NOCOUNT OFF;
RETURN 0;
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [SSSB].[ReceiveMessagesFromQueue]
(
	@queueName nvarchar(128),
	@fetchSize int,
	@waitTimeout int,
	@conversation_group uniqueidentifier = NULL
)
WITH EXECUTE AS OWNER
AS
BEGIN
set nocount on;

declare @query nvarchar(4000);

IF (@conversation_group IS NULL)
BEGIN
set @query = N'waitfor(receive top(@fetchSize) 
			conversation_group_id, 
			conversation_handle,
			message_sequence_number,
			service_name, 
			service_contract_name, 
			message_type_name, 
			validation, 
			message_body 
        from ' + @queueName +
        N'), timeout @waitTimeout;';

	exec sp_executesql
	@stmt = @query,
	@params = N'@fetchSize int, @waitTimeout int',
	@fetchSize = @fetchSize,
	@waitTimeout = @waitTimeout;
END
ELSE
BEGIN
set @query = N'waitfor(receive top(@fetchSize) 
			conversation_group_id, 
			conversation_handle,
			message_sequence_number,
			service_name, 
			service_contract_name, 
			message_type_name, 
			validation, 
			message_body 
        from ' + @queueName +
        N' WHERE conversation_group_id = @conversation_group), timeout @waitTimeout;';

    exec sp_executesql
	@stmt = @query,
	@params = N'@fetchSize int, @conversation_group uniqueidentifier, @waitTimeout int',
	@fetchSize = @fetchSize,
	@conversation_group = @conversation_group,
	@waitTimeout = @waitTimeout;
END;
 
set nocount off;
return 0;
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [SSSB].[ReleaseInitiatorConversationGroupLock] (
	@initiatorConversationGroupID uniqueidentifier
)
AS
BEGIN
 SET NOCOUNT ON;

 DECLARE @result INT, @context NVARCHAR(40);
 SET @context= Cast(@initiatorConversationGroupID as NVARCHAR(40));

 EXEC @result = sp_releaseapplock @Resource = @context; 

 SET NOCOUNT OFF;
 RETURN @result;
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [SSSB].[SendMessage] 
(
	@conversationHandle uniqueidentifier,
	@messageType nvarchar(255),
	@body varbinary(max)
)
AS
BEGIN
 DECLARE @noop BIT;
 SEND ON CONVERSATION @conversationHandle MESSAGE TYPE @messageType (@body);
 RETURN 0;
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE   PROCEDURE [SSSB].[SendMessageWithInitiatorConversationGroup] (
	@fromService nvarchar(255),
	@toService nvarchar(255),
	@contractName nvarchar(128),
	@lifeTime int,
	@withEncryption bit,
	@initiatorConversationGroupID uniqueidentifier,
	@messageType nvarchar(255),
	@body varbinary(max),
	@withEndDialog bit = 0
)
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	DECLARE 
	   @mustCommit BIT = 0
	  ,@result INT;

	IF (@@trancount = 0)
	BEGIN
		BEGIN TRANSACTION;
		SET @mustCommit = 1;
	END;

	DECLARE 
	    @conversationHandle uniqueidentifier = null,
		@conversationID uniqueidentifier,
		@lifetimeDate datetime,
		@state char(2),
		@farService nvarchar(256),
		@dialogTimer datetime;

	BEGIN TRY

		IF (@initiatorConversationGroupID is not null)
		BEGIN
			EXEC @result = SSSB.LockInitiatorConversationGroup @initiatorConversationGroupID;

			EXEC SSSB.GetActiveConversationByInitiatorGroupID
				@initiatorConversationGroupID = @initiatorConversationGroupID,
				@farService                   = @toService,
				@conversationHandle           = @conversationHandle output,
				@conversationID               = @conversationID output,
				@lifetime                     = @lifetimeDate output,
				@state                        = @state output,
				@dialogTimer                  = @dialogTimer output;
		END;

		IF (@conversationHandle is null)
		BEGIN
			EXEC SSSB.BeginDialogConversation @fromService,
				@toService,
				@contractName,
				@lifeTime,
				@withEncryption,
				null,
				@initiatorConversationGroupID,
				@conversationHandle output;
		END;

		IF (@messageType IS NOT NULL)
		BEGIN	
		  EXEC SSSB.SendMessage @conversationHandle, @messageType, @body;
		END;

		IF (@withEndDialog = 1)
		BEGIN
		  EXEC [SSSB].[EndConversation] @conversationHandle, 0, null, null;
		END;

		IF (@initiatorConversationGroupID is not null)
		BEGIN
			EXEC @result = SSSB.ReleaseInitiatorConversationGroupLock @initiatorConversationGroupID;

			IF (@result < 0)
			BEGIN
				IF (@mustCommit = 1)
					ROLLBACK TRANSACTION;
				RETURN @result;
			END;
		END;

		IF (@mustCommit = 1)
			COMMIT TRANSACTION;
		
		SET NOCOUNT OFF;
		RETURN 0;
   END TRY
   BEGIN CATCH
     IF (XACT_STATE() <> 0 AND @mustCommit = 1)
     BEGIN
      ROLLBACK TRANSACTION;
     END;
    
      EXEC dbo.usp_RethrowError;
   END CATCH;
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [SSSB].[SendPendingMessage] (
	@objectID varchar(50),
	@activationDate datetime,
	@fromService nvarchar(255),
	@toService nvarchar(255),
	@contractName nvarchar(255),
	@lifeTime int,
	@isWithEncryption bit,
	@messageBody varbinary(MAX),
	@messageType nvarchar(255),
	@pendingMessageID bigint output
)
AS
BEGIN
 SET NOCOUNT ON;

INSERT INTO SSSB.PendingMessages
(
	ObjectID,
	ActivationDate,
	FromService,
	ToService,
	ContractName,
	[LifeTime],
	IsWithEncryption,
	MessageBody,
	MessageType
)
VALUES
(
	@objectID,
	@activationDate,
	@fromService,
	@toService,
	@contractName,
	@lifeTime,
	@isWithEncryption,
	@messageBody,
	@messageType
)

 SET @pendingMessageID = scope_identity();

 SET NOCOUNT OFF;
 RETURN 0;
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE trigger [PPS].[tr_ud_OnDemandTask] on [PPS].[OnDemandTask] for update, delete as
begin
SET NOCOUNT ON

 DECLARE @cursor CURSOR, @ID Int, @SettingID INT

;SET @cursor = CURSOR LOCAL FAST_FORWARD FOR
 SELECT OnDemandTaskID FROM deleted

OPEN @cursor;

FETCH NEXT FROM @cursor
INTO @ID

WHILE (@@FETCH_STATUS <> -1)
BEGIN
  IF (UPDATE(SheduleID))
	EXEC [PPS].[sp_SendFlushSettings] 4, @ID
 
  FETCH NEXT FROM @cursor
  INTO @ID
END;

CLOSE @cursor;
DEALLOCATE @cursor;
end


GO
ALTER TABLE [PPS].[OnDemandTask] ENABLE TRIGGER [tr_ud_OnDemandTask]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



create trigger [PPS].[tr_ud_Setting] on [PPS].[Setting] 
for update, delete as
begin
SET NOCOUNT ON

 DECLARE @cursor CURSOR, @ID Int

;SET @cursor = CURSOR LOCAL FAST_FORWARD FOR
 SELECT SettingID FROM deleted

OPEN @cursor;

FETCH NEXT FROM @cursor
INTO @ID

WHILE (@@FETCH_STATUS <> -1)
BEGIN
  EXEC [PPS].[sp_SendFlushSettings] 3, @ID

  FETCH NEXT FROM @cursor
  INTO @ID
END;

CLOSE @cursor;
DEALLOCATE @cursor;
end

GO
ALTER TABLE [PPS].[Setting] ENABLE TRIGGER [tr_ud_Setting]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create trigger [PPS].[tr_ud_Shedule] on [PPS].[Shedule] for update, delete as
begin
SET NOCOUNT ON

 DECLARE @cursor CURSOR, @ID Int

;SET @cursor = CURSOR LOCAL FAST_FORWARD FOR
 SELECT distinct b.OnDemandTaskID
 FROM deleted as a JOIN PPS.OnDemandTask as b ON (a.SheduleID = b.SheduleID)

OPEN @cursor;

FETCH NEXT FROM @cursor
INTO @ID

WHILE (@@FETCH_STATUS <> -1)
BEGIN
  EXEC [PPS].[sp_SendFlushSettings] 4, @ID
 
  FETCH NEXT FROM @cursor
  INTO @ID
END;

CLOSE @cursor;
DEALLOCATE @cursor;
end
GO
ALTER TABLE [PPS].[Shedule] ENABLE TRIGGER [tr_ud_Shedule]
GO
USE [master]
GO
ALTER DATABASE [testDB] SET  READ_WRITE 
GO
