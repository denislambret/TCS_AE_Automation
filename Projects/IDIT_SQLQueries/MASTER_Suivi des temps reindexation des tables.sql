SELECT TOP (1000) [ID]
 ,[StartTime]
      ,[DatabaseName]
      ,DATEDIFF(MINUTE,[StartTime] , [EndTime]) AS [Rebuild duration minutes]
      ,[SchemaName]      ,[ObjectName]      ,[ObjectType]
      ,[IndexName]      ,[IndexType]      ,[StatisticsName]
      ,[PartitionNumber]      ,[ExtendedInfo]      ,[Command]
      ,[CommandType]       ,[EndTime]      ,[ErrorNumber]
      ,[ErrorMessage]
  FROM [master].[dbo].[CommandLog] 
  where CommandType = 'ALTER_INDEX'
  order by [Rebuild duration minutes] desc
  --order by [StartTime] desc;
