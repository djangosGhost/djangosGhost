
use WorkArea
go
drop FUNCTION if exists [NETID\jabbott3].fn_getSelfRefBottomUpTrail_byName ;
go
CREATE FUNCTION [NETID\jabbott3].fn_getSelfRefBottomUpTrail_byName  (@businessObject varchar(100), @TopLevelNodeName varchar(500), @WID char(32))
RETURNS varchar(8000)
BEGIN
   DECLARE @output varchar(8000)

DECLARE @SelfReferenceTrail varchar(8000)=''
DECLARE @SelfReferenceTrail_WID varchar(8000)=''

;WITH CTE as 
( SELECT base.hierarchyNodeWID
     ,  base.hierarchyNodeName  as hierarchyNodeName
	 , base.businessObject
	 ,base.TopLevelNodeName
	 ,base.ParentWID
	 , 1 AS RecursionLevel 
  FROM WorkArea.[NETID\jabbott3].AllHierarchies base
  WHERE base.businessObject=@businessObject
  AND   base.TopLevelNodeName = @TopLevelNodeName
  AND   base.hierarchyNodeWID = @WID 
UNION ALL
  SELECT parent.hierarchyNodeWID
     , parent.hierarchyNodeName 
	 , parent.businessObject
	 , parent.TopLevelNodeName
	 , parent.ParentWID
	 , child.RecursionLevel + 1 AS RecursionLevel
  FROM WorkArea.[NETID\jabbott3].AllHierarchies parent
  INNER JOIN CTE child ON child.businessObject=parent.businessObject AND parent.TopLevelNodeName=child.TopLevelNodeName AND  parent.hierarchyNodeWID = child.ParentWID
  WHERE child.businessObject=@businessObject
  AND   child.TopLevelNodeName = @TopLevelNodeName
 
)
SELECT top 20 @SelfReferenceTrail = @SelfReferenceTrail + '[' + hierarchyNodeName +'] '
            , @SelfReferenceTrail_WID = @SelfReferenceTrail_WID + '[' + hierarchyNodeWID +'] '
from CTE
order by RecursionLevel

SELECT @output = @SelfReferenceTrail 

    RETURN @output
END;


GO


use WorkArea
go
drop FUNCTION if exists [NETID\jabbott3].fn_getSelfRefBottomUpTrail_byWID ;
go
CREATE FUNCTION [NETID\jabbott3].fn_getSelfRefBottomUpTrail_byWID  (@businessObject varchar(100), @TopLevelNodeName varchar(500), @WID char(32))
RETURNS varchar(8000)
BEGIN
   DECLARE @output varchar(8000)

DECLARE @SelfReferenceTrail varchar(8000)=''
DECLARE @SelfReferenceTrail_WID varchar(8000)=''

;WITH CTE as 
( SELECT base.hierarchyNodeWID
     ,  base.hierarchyNodeName  as hierarchyNodeName
	 , base.businessObject
	 ,base.TopLevelNodeName
	 ,base.ParentWID
	 , 1 AS RecursionLevel 
  FROM WorkArea.[NETID\jabbott3].AllHierarchies base
  WHERE base.businessObject=@businessObject
  AND   base.TopLevelNodeName = @TopLevelNodeName
  AND   base.hierarchyNodeWID = @WID 
UNION ALL
  SELECT parent.hierarchyNodeWID
     , parent.hierarchyNodeName 
	 , parent.businessObject
	 , parent.TopLevelNodeName
	 , parent.ParentWID
	 , child.RecursionLevel + 1 AS RecursionLevel
  FROM WorkArea.[NETID\jabbott3].AllHierarchies parent
  INNER JOIN CTE child ON child.businessObject=parent.businessObject AND parent.TopLevelNodeName=child.TopLevelNodeName AND  parent.hierarchyNodeWID = child.ParentWID
  WHERE child.businessObject=@businessObject
  AND   child.TopLevelNodeName = @TopLevelNodeName
  
)
SELECT top 20 @SelfReferenceTrail = @SelfReferenceTrail + '[' + hierarchyNodeName +'] '
            , @SelfReferenceTrail_WID = @SelfReferenceTrail_WID + '[' + hierarchyNodeWID +'] '
from CTE
order by RecursionLevel

SELECT @output = @SelfReferenceTrail_WID

    RETURN @output
END;

GO

use WorkArea
go
drop FUNCTION if exists [NETID\jabbott3].fn_getSelfRefBottomUpTrail_byRefID ;
go
CREATE FUNCTION [NETID\jabbott3].fn_getSelfRefBottomUpTrail_byRefID  (@businessObject varchar(100), @TopLevelNodeName varchar(500), @WID char(32))
RETURNS varchar(8000)
BEGIN
   DECLARE @SelfReferenceTrail varchar(8000)=''

;WITH CTE as 
( SELECT base.hierarchyNodeRefID
     ,  base.hierarchyNodeName  as hierarchyNodeName
	 , base.businessObject
	 ,base.TopLevelNodeName
	 ,base.ParentWID
	 , 1 AS RecursionLevel 
  FROM WorkArea.[NETID\jabbott3].AllHierarchies base
  WHERE base.businessObject=@businessObject
  AND   base.TopLevelNodeName = @TopLevelNodeName
  AND   base.hierarchyNodeWID = @WID 
UNION ALL
  SELECT parent.hierarchyNodeRefID
     , parent.hierarchyNodeName 
	 , parent.businessObject
	 , parent.TopLevelNodeName
	 , parent.ParentWID
	 , child.RecursionLevel + 1 AS RecursionLevel
  FROM WorkArea.[NETID\jabbott3].AllHierarchies parent
  INNER JOIN CTE child ON child.businessObject=parent.businessObject AND parent.TopLevelNodeName=child.TopLevelNodeName AND  parent.hierarchyNodeWID = child.ParentWID
  WHERE child.businessObject=@businessObject
  AND   child.TopLevelNodeName = @TopLevelNodeName
  
)
SELECT top 20 @SelfReferenceTrail = @SelfReferenceTrail + '[' + hierarchyNodeRefID +'] '
from CTE
order by RecursionLevel

    RETURN @SelfReferenceTrail
END;


GO


use WorkArea
go
drop FUNCTION if exists [NETID\jabbott3].fn_getSelfRefBottomUpTrail_byAllHierarchiesID ;
go
CREATE FUNCTION [NETID\jabbott3].fn_getSelfRefBottomUpTrail_byAllHierarchiesID  (@businessObject varchar(100), @TopLevelNodeName varchar(500), @WID char(32))
RETURNS varchar(8000)
BEGIN
   DECLARE @output varchar(8000)

DECLARE @SelfReferenceTrail varchar(8000)=''

;WITH CTE as 
( SELECT base.AllHierarchiesID
       , base.hierarchyNodeWID
     ,  base.hierarchyNodeName  as hierarchyNodeName
	 , base.businessObject
	 ,base.TopLevelNodeName
	 ,base.ParentWID
	 , 1 AS RecursionLevel 
  FROM WorkArea.[NETID\jabbott3].AllHierarchies base
  WHERE base.businessObject=@businessObject
  AND   base.TopLevelNodeName = @TopLevelNodeName
  AND   base.hierarchyNodeWID = @WID 
UNION ALL
  SELECT parent.AllHierarchiesID
     , parent.hierarchyNodeWID
     , parent.hierarchyNodeName 
	 , parent.businessObject
	 , parent.TopLevelNodeName
	 , parent.ParentWID
	 , child.RecursionLevel + 1 AS RecursionLevel
  FROM WorkArea.[NETID\jabbott3].AllHierarchies parent
  INNER JOIN CTE child ON child.businessObject=parent.businessObject AND parent.TopLevelNodeName=child.TopLevelNodeName AND  parent.hierarchyNodeWID = child.ParentWID
  WHERE child.businessObject=@businessObject
  AND   child.TopLevelNodeName = @TopLevelNodeName
  
  
)
SELECT top 20 @SelfReferenceTrail = @SelfReferenceTrail + '[' + CAST(AllHierarchiesID as varchar(10)) +'] '
from CTE
order by RecursionLevel

SELECT @output = @SelfReferenceTrail

    RETURN @output
END;

GO

use WorkArea
go
drop FUNCTION if exists [NETID\jabbott3].fn_getSelfRefTopDownTrail_byAllHierarchiesID ;
go
CREATE FUNCTION [NETID\jabbott3].fn_getSelfRefTopDownTrail_byAllHierarchiesID  (@businessObject varchar(100), @TopLevelNodeName varchar(500), @WID char(32))
RETURNS varchar(8000)
BEGIN
   DECLARE @output varchar(8000)

DECLARE @SelfReferenceTrail varchar(8000)=''

;WITH CTE as 
( SELECT base.AllHierarchiesID
       , base.hierarchyNodeWID
     ,  base.hierarchyNodeName  as hierarchyNodeName
	 , base.businessObject
	 ,base.TopLevelNodeName
	 ,base.ParentWID
	 , 1 AS RecursionLevel 
  FROM WorkArea.[NETID\jabbott3].AllHierarchies base
  WHERE base.businessObject=@businessObject
  AND   base.TopLevelNodeName = @TopLevelNodeName
  AND   base.hierarchyNodeWID = @WID 
UNION ALL
  SELECT parent.AllHierarchiesID
     , parent.hierarchyNodeWID
     , parent.hierarchyNodeName 
	 , parent.businessObject
	 , parent.TopLevelNodeName
	 , parent.ParentWID
	 , child.RecursionLevel + 1 AS RecursionLevel
  FROM WorkArea.[NETID\jabbott3].AllHierarchies parent
  INNER JOIN CTE child ON child.businessObject=parent.businessObject AND parent.TopLevelNodeName=child.TopLevelNodeName AND  parent.hierarchyNodeWID = child.ParentWID
  WHERE child.businessObject=@businessObject
  AND   child.TopLevelNodeName = @TopLevelNodeName
  
  
)
SELECT top 20 @SelfReferenceTrail = @SelfReferenceTrail + '[' + CAST(AllHierarchiesID as varchar(10)) +'] '
from CTE
order by RecursionLevel DESC

SELECT @output = @SelfReferenceTrail

    RETURN @output
END;

GO


use WorkArea
go
drop FUNCTION if exists [NETID\jabbott3].fn_getSelfRefTopDownTrail_byBinarySortValue ;
go
CREATE FUNCTION [NETID\jabbott3].fn_getSelfRefTopDownTrail_byBinarySortValue  (@businessObject varchar(100), @TopLevelNodeName varchar(500), @WID char(32))
RETURNS varbinary(8000)
BEGIN
   DECLARE @output varbinary(8000)

DECLARE @SelfReferenceTrail varbinary(8000)=CAST('' as varbinary(8000))

;WITH CTE as 
(SELECT base.AllHierarchiesID
       , base.hierarchyNodeWID
     ,  base.hierarchyNodeName  as hierarchyNodeName
	 , base.businessObject
	 ,base.TopLevelNodeName
	 ,base.ParentWID
	  , base.BinarySortValue 
	 , 1 AS RecursionLevel 
  FROM WorkArea.[NETID\jabbott3].AllHierarchies base
  WHERE base.businessObject=@businessObject
  AND   base.TopLevelNodeName = @TopLevelNodeName
  AND   base.hierarchyNodeWID = @WID 
UNION ALL
  SELECT parent.AllHierarchiesID
     , parent.hierarchyNodeWID
     , parent.hierarchyNodeName 
	 , parent.businessObject
	 , parent.TopLevelNodeName
	 , parent.ParentWID
	 , parent.BinarySortValue 
	 , child.RecursionLevel + 1 AS RecursionLevel
  FROM WorkArea.[NETID\jabbott3].AllHierarchies parent
  INNER JOIN CTE child ON child.businessObject=parent.businessObject AND parent.TopLevelNodeName=child.TopLevelNodeName AND  parent.hierarchyNodeWID = child.ParentWID
  WHERE child.businessObject=@businessObject
  AND   child.TopLevelNodeName = @TopLevelNodeName 
)
SELECT top 20 @SelfReferenceTrail = CAST(@SelfReferenceTrail + BinarySortValue as VARBINARY(8000))
from CTE
order by RecursionLevel DESC

SELECT @output = @SelfReferenceTrail

    RETURN @output
END;

GO


DROP TABLE IF EXISTS WorkArea.[NETID\jabbott3].HTally;
SELECT TOP 10000 
        N = ISNULL(CAST(
                (ROW_NUMBER() OVER (ORDER BY (SELECT NULL))-1)*4+1
            AS INT),0)
INTO WorkArea.[NETID\jabbott3].HTally
FROM master.sys.all_columns ac1
CROSS JOIN master.sys.all_columns ac2;

ALTER TABLE WorkArea.[NETID\jabbott3].HTally
    ADD CONSTRAINT PK_HTally 
        PRIMARY KEY CLUSTERED (N) WITH FILLFACTOR = 100;

