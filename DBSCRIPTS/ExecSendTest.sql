USE [testDB]
GO

DECLARE 
  @RC       int, 
  @BatchID  int, 
  @category nvarchar(100), 
  @infoType nvarchar(100), 
  @context  uniqueidentifier,
  @ch       uniqueidentifier;

SET @BatchID=1;
SET @category='category';
SET @infoType='test';
SET @context= NEWID();

BEGIN TRAN;

	WHILE(@BatchID <= 10)
	BEGIN
		EXECUTE @RC = [dbo].[sp_SendTest] 
		   @BatchID
		  ,@category
		  ,@infoType
		  ,@context, 
		   @ch OUTPUT;
    
		--SELECT @ch;
		SET @BatchID=@BatchID + 1;
	END;

COMMIT TRAN;

IF (@ch IS NOT NULL)
	END CONVERSATION @ch;
GO



