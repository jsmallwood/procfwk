﻿CREATE PROCEDURE [procfwk].[BatchWrapper]
	(
	@BatchId UNIQUEIDENTIFIER,
	@LocalExecutionId UNIQUEIDENTIFIER OUTPUT
	)
AS
BEGIN
	SET NOCOUNT ON;

	--check for running batch execution
	IF EXISTS
		(
		SELECT 1 FROM [procfwk].[BatchExecution] WHERE [BatchId] = @BatchId AND ISNULL([BatchStatus],'') = 'Running'
		)
		BEGIN
			SELECT
				@LocalExecutionId = [ExecutionId]
			FROM
				[procfwk].[BatchExecution]
			WHERE
				[BatchId] = @BatchId;

			RAISERROR('There is already an batch execution run in progress. Stop the related parent pipeline via Data Factory first.',16,1);
			RETURN 0;
		END
	ELSE IF EXISTS
		(
		SELECT 1 FROM [procfwk].[BatchExecution] WHERE [BatchId] = @BatchId AND ISNULL([BatchStatus],'') = 'Stopped'
		)
		BEGIN
			SELECT
				@LocalExecutionId = [ExecutionId]
			FROM
				[procfwk].[BatchExecution]
			WHERE
				[BatchId] = @BatchId;
		END
	ELSE
		BEGIN
			SET @LocalExecutionId = NEWID();

			--create new batch run record
			INSERT INTO [procfwk].[BatchExecution]
				(
				[BatchId],
				[ExecutionId],
				[BatchStatus],
				[StartDateTime]
				)
			VALUES
				(
				@BatchId,
				@LocalExecutionId,
				'Running',
				GETDATE()
				)
		END;
END;