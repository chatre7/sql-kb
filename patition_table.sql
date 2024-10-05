--Adding File Groups to the database:
ALTER DATABASE mike
ADD FILEGROUP FG_01_2020
GO
ALTER DATABASE mike
ADD FILEGROUP FG_02_2020
GO
ALTER DATABASE mike
ADD FILEGROUP FG_03_2020
GO
ALTER DATABASE mike
ADD FILEGROUP FG_04_2020
GO
ALTER DATABASE mike
ADD FILEGROUP FG_05_2020
GO
ALTER DATABASE mike
ADD FILEGROUP FG_06_2020
GO
ALTER DATABASE mike
ADD FILEGROUP FG_07_2020
GO
ALTER DATABASE mike
ADD FILEGROUP FG_08_2020
GO
ALTER DATABASE mike
ADD FILEGROUP FG_09_2020
GO
ALTER DATABASE mike
ADD FILEGROUP FG_10_2020
GO
ALTER DATABASE mike
ADD FILEGROUP FG_11_2020
GO
ALTER DATABASE mike
ADD FILEGROUP FG_12_2020
GO


--Adding Files to each File Group
ALTER DATABASE mike
ADD FILE
(
  NAME = [File_012020],
  FILENAME = 'D:\DATA\mike\File_012020.ndf',
    SIZE = 5 MB,  
    MAXSIZE = UNLIMITED, 
    FILEGROWTH = 10 MB
) TO FILEGROUP FG_01_2020
GO
 
ALTER DATABASE mike
ADD FILE
(
  NAME = [File_022020],
  FILENAME = 'D:\DATA\mike\File_022020.ndf',
    SIZE = 5 MB,  
    MAXSIZE = UNLIMITED, 
    FILEGROWTH = 10 MB
) TO FILEGROUP FG_02_2020
GO
 
ALTER DATABASE mike
ADD FILE
(
  NAME = [File_032020],
  FILENAME = 'D:\DATA\mike\File_032020.ndf',
    SIZE = 5 MB,  
    MAXSIZE = UNLIMITED, 
    FILEGROWTH = 10 MB
) TO FILEGROUP FG_03_2020
GO
 
ALTER DATABASE mike
ADD FILE
(
  NAME = [File_042020],
  FILENAME = 'D:\DATA\mike\File_042020.ndf',
    SIZE = 5 MB,  
    MAXSIZE = UNLIMITED, 
    FILEGROWTH = 10 MB
) TO FILEGROUP FG_04_2020
GO
 
ALTER DATABASE mike
ADD FILE
(
  NAME = [File_052020],
  FILENAME = 'D:\DATA\mike\File_052020.ndf',
    SIZE = 5 MB,  
    MAXSIZE = UNLIMITED, 
    FILEGROWTH = 10 MB
) TO FILEGROUP FG_05_2020
GO
 
ALTER DATABASE mike
ADD FILE
(
  NAME = [File_062020],
  FILENAME = 'D:\DATA\mike\File_062020.ndf',
    SIZE = 5 MB,  
    MAXSIZE = UNLIMITED, 
    FILEGROWTH = 10 MB
) TO FILEGROUP FG_06_2020
GO
 
ALTER DATABASE mike
ADD FILE
(
  NAME = [File_072020],
  FILENAME = 'D:\DATA\mike\File_072020.ndf',
    SIZE = 5 MB,  
    MAXSIZE = UNLIMITED, 
    FILEGROWTH = 10 MB
) TO FILEGROUP FG_07_2020
GO
 
ALTER DATABASE mike
ADD FILE
(
  NAME = [File_082020],
  FILENAME = 'D:\DATA\mike\File_082020.ndf',
    SIZE = 5 MB,  
    MAXSIZE = UNLIMITED, 
    FILEGROWTH = 10 MB
) TO FILEGROUP FG_08_2020
GO
 
ALTER DATABASE mike
ADD FILE
(
  NAME = [File_092020],
  FILENAME = 'D:\DATA\mike\File_092020.ndf',
    SIZE = 5 MB,  
    MAXSIZE = UNLIMITED, 
    FILEGROWTH = 10 MB
) TO FILEGROUP FG_09_2020
GO
 
ALTER DATABASE mike
ADD FILE
(
  NAME = [File_102020],
  FILENAME = 'D:\DATA\mike\File_102020.ndf',
    SIZE = 5 MB,  
    MAXSIZE = UNLIMITED, 
    FILEGROWTH = 10 MB
) TO FILEGROUP FG_10_2020
GO
 
ALTER DATABASE mike
ADD FILE
(
  NAME = [File_112020],
  FILENAME = 'D:\DATA\mike\File_112020.ndf',
    SIZE = 5 MB,  
    MAXSIZE = UNLIMITED, 
    FILEGROWTH = 10 MB
) TO FILEGROUP FG_11_2020
GO
 
ALTER DATABASE mike
ADD FILE
(
  NAME = [File_122020],
  FILENAME = 'D:\DATA\mike\File_122020.ndf',
    SIZE = 5 MB,  
    MAXSIZE = UNLIMITED, 
    FILEGROWTH = 10 MB
) TO FILEGROUP FG_12_2020
GO


--Adding a Partition Function with Month wise range
USE mike
GO
CREATE PARTITION FUNCTION [PF_MonthlyPartition] (DATETIME)
AS RANGE LEFT FOR VALUES 
(
  '2020-01-31 00:00:00.000', '2020-02-29 00:00:00.000', '2020-03-31 00:00:00.000', 
  '2020-04-30 00:00:00.000', '2020-05-31 00:00:00.000', '2020-06-30 00:00:00.000', 
  '2020-07-31 00:00:00.000', '2020-08-31 00:00:00.000', '2020-09-30 00:00:00.000', 
  '2020-10-31 00:00:00.000', '2020-11-30 00:00:00.000', '2020-12-31 00:00:00.000'
);

--Adding a Partition Scheme with File Groups to the Partition Function
USE mike
GO
CREATE PARTITION SCHEME PS_Month
AS PARTITION PF_MonthlyPartition
TO 
( 
  'FG_01_2020', 'FG_02_2020', 'FG_03_2020',
  'FG_04_2020', 'FG_05_2020', 'FG_06_2020', 
  'FG_07_2020', 'FG_08_2020', 'FG_09_2020', 
  'FG_10_2020', 'FG_11_2020', 'FG_12_2020',
  'Primary'
);

USE mike
DROP TABLE IF EXISTS #temp
DROP TABLE IF EXISTS #generateScript

SELECT o.name as table_name, 
  pf.name as PartitionFunction, 
  ps.name as PartitionScheme, 
  MAX(rv.value) AS LastPartitionRange,
  CASE WHEN MAX(rv.value) <= DATEADD(MONTH, 2, GETDATE()) THEN 1 else 0 END AS isRequiredMaintenance
INTO #temp
FROM sys.partitions p
INNER JOIN sys.indexes i ON p.object_id = i.object_id AND p.index_id = i.index_id
INNER JOIN sys.objects o ON p.object_id = o.object_id
INNER JOIN sys.system_internals_allocation_units au ON p.partition_id = au.container_id
INNER JOIN sys.partition_schemes ps ON ps.data_space_id = i.data_space_id
INNER JOIN sys.partition_functions pf ON pf.function_id = ps.function_id
INNER JOIN sys.partition_range_values rv ON pf.function_id = rv.function_id AND p.partition_number = rv.boundary_id
GROUP BY o.name, pf.name, ps.name

SELECT table_name,
       PartitionFunction,
       PartitionScheme,
       LastPartitionRange,
       CONVERT(VARCHAR, DATEADD(MONTH, 1, CONVERT(DATETIME, LastPartitionRange)), 25) AS NewRange,
       'FG_' + CAST(FORMAT(DATEADD(MONTH, 1, CONVERT(DATETIME, LastPartitionRange)), 'MM') AS VARCHAR(2)) +
       '_' +
       CAST(YEAR(DATEADD(MONTH, 1, CONVERT(DATETIME, LastPartitionRange))) AS VARCHAR(4)) AS NewFileGroup,
       'File_' + CAST(FORMAT(DATEADD(MONTH, 1, CONVERT(DATETIME, LastPartitionRange)), 'MM') AS VARCHAR(2)) +
       CAST(YEAR(DATEADD(MONTH, 1, CONVERT(DATETIME, LastPartitionRange))) AS VARCHAR(4)) AS FileName,
       'D:\DATA\mike' AS file_path
INTO #generateScript
FROM #temp
WHERE isRequiredMaintenance = 1;

--SELECT * FROM #generateScript

DECLARE @filegroup NVARCHAR(MAX) = ''
DECLARE @file NVARCHAR(MAX) = ''
DECLARE @PScheme NVARCHAR(MAX) = ''
DECLARE @PFunction NVARCHAR(MAX) = ''
 
SELECT @filegroup = @filegroup + 
    CONCAT('IF NOT EXISTS(SELECT 1 FROM mike.sys.filegroups WHERE name = ''',NewFileGroup,''')
    BEGIN
      ALTER DATABASE mike ADD FileGroup ',NewFileGroup,' 
    END;'),
    @file = @file + CONCAT('IF NOT EXISTS(SELECT 1 FROM mike.sys.database_files WHERE name = ''',FileName,''')
    BEGIN
    ALTER DATABASE mike ADD FILE 
    (NAME = ''',FileName,''', 
    FILENAME = ''',File_Path,FileName,'.ndf'', 
    SIZE = 5MB, MAXSIZE = UNLIMITED, 
    FILEGROWTH = 10MB )
    TO FILEGROUP ',NewFileGroup, '
    END;'),
    @PScheme = @PScheme + CONCAT('ALTER PARTITION SCHEME ', PartitionScheme, ' NEXT USED ',NewFileGroup,';'),
    @PFunction = @PFunction + CONCAT('ALTER PARTITION FUNCTION ', PartitionFunction, '() SPLIT RANGE (''',NewRange,''');')
FROM #generateScript
 
EXEC (@filegroup)
EXEC (@file)
EXEC (@PScheme)
EXEC (@PFunction)
