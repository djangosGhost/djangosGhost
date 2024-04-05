SET NOCOUNT ON

--------------------------------------------------
-- CREATE Main table to hold all hierarchy data
--------------------------------------------------
DROP TABLE IF EXISTS WorkArea.[NETID\jabbott3].AllHierarchies;
CREATE TABLE WorkArea.[NETID\jabbott3].AllHierarchies (
  AllHierarchiesID                        int identity 
, businessObject                          varchar(100)
, TopLevelNodeName                        varchar(500)
, TopLevelNodeWID                         char(32)
, hierarchyOrder                          int
, hierarchyNodeWID                        char(32)
, hierarchyNodeName                       varchar(500)
, hierarchyNodeRefID                      varchar(200)
, RecursionLevel                          int
, hierarchyOrganizationSubtypeName        varchar(500)
, ParentWID                               char(32)
, Parent_AllHierarchiesID                 int           NULL
, paddedHierarchyNames                    varchar(8000) NULL
, InLineColonDelim_Hierarchy	          varchar(8000) NULL
, InLineColonDelim_WID                    varchar(8000) NULL
, InLineColonDelim_hierarchyOrderNum      varchar(8000) NULL
, SelfRefBottomUpTrail_byName             varchar(8000) NULL
, SelfRefBottomUpTrail_byWID              varchar(8000) NULL
, SelfRefBottomUpTrail_byRefID            varchar(8000) NULL
, SelfRefBottomUpTrail_byAllHierarchiesID varchar(8000) NULL
, SelfRefTopDownTrail_byAllHierarchiesID  varchar(8000) NULL
, LeftBoundary                            int           NULL
, RightBoundary                           int           NULL
, BinarySortPath                          varbinary(8000) NULL
, BinarySortValue                         binary(4) null
, NodeCount                               int null
);

--------------------------------------------------
-- Temp table for the business objects
--------------------------------------------------
DROP TABLE IF EXISTS #BusinessObjects;
CREATE TABLE #BusinessObjects (BusinessObjectID int identity, BusinessObject nvarchar(100), StorageType int)
INSERT #BusinessObjects(BusinessObject,StorageType)
SELECT N'Activity', 2 
UNION
SELECT N'Appropriation', 3
UNION
SELECT N'Assignee', 2
UNION
SELECT N'BalancingUnit', 2
UNION
SELECT N'Company', 2
UNION
SELECT N'CostCenter', 2
UNION
SELECT N'Debt', 2
UNION
SELECT N'Function', 2
UNION
SELECT N'Fund', 4
UNION
SELECT N'Gift', 4
UNION
SELECT N'Grant', 1
UNION
SELECT N'InstitutionalInitiative', 2
UNION
SELECT N'Location', 2
UNION
SELECT N'Program', 1
UNION
SELECT N'Project', 4
UNION
SELECT N'Region', 3
UNION
SELECT N'Resource', 2
UNION
SELECT N'RevenueCategory', 5
UNION
SELECT N'SpendCategory', 5

--------------------------------------------------
-- declare variables
--------------------------------------------------
DECLARE @ListSeparator              char(1) = ':'
      , @businessObject             varchar(100) 
	  , @storageType                tinyint
	  , @CMD_buildHierarchies_Type1 nvarchar(max)
	  , @CMD_buildHierarchies_Type2 nvarchar(max)
	  , @CMD_buildHierarchies_Type3 nvarchar(max)
	  , @CMD_buildHierarchies_Type4 nvarchar(max)
	  , @CMD_buildHierarchies_Type5 nvarchar(max)
	  , @CMD                        nvarchar(max)
DECLARE @params                     nvarchar(255) = N'@ListSeparator char(1) = ' +''''+@ListSeparator+''''

SET @CMD_buildHierarchies_Type1=N' 
;WITH AllLevels_CTE AS (
      SELECT h.(BusinessObjectToken)Hierarchy_WID
           , h.(BusinessObjectToken)Hierarchy_Name
		   , CAST(h.(BusinessObjectToken)Hierarchy_Name as varchar(8000)) AS TopLevelNodeName
		   , h.(BusinessObjectToken)Hierarchy_WID AS TopLevelNodeWID
           , 1 AS RecursionLevel
           , h.[(BusinessObjectToken)Hierarchy_OrganizationSubtype_Name] 
		   , CAST(NULL as varchar(50)) as ParentWID
           , CAST('' '' as varchar(500)) AS paddingCrumbs
           , CAST(h.(BusinessObjectToken)Hierarchy_Name as varchar(4000)) AS padded(BusinessObjectToken)HierarchyNames
           , CAST(h.(BusinessObjectToken)Hierarchy_Name as varchar(8000)) AS InLineColonDelim_Hierarchy
		   , CAST(h.(BusinessObjectToken)Hierarchy_WID as varchar(8000)) AS InLineColonDelim_WID
		   , CAST(h.(BusinessObjectToken)Hierarchy_WID as varchar(8000)) AS InLineColonDelim_rowNumber
		   
   FROM  EWSStaging.fws.(BusinessObjectToken)Hierarchy h
   WHERE h.(BusinessObjectToken)Hierarchy_Parent_WID IS NULL
   AND [RecordEffEndDate] IS NULL
UNION ALL
      SELECT child.(BusinessObjectToken)Hierarchy_WID
           , child.(BusinessObjectToken)Hierarchy_Name
		   , TopLevelNodeName --CAST(CASE charindex(@ListSeparator,InLineColonDelim_Hierarchy,1) WHEN 0 THEN parent.(BusinessObjectToken)Hierarchy_Name ELSE REPLACE(substring(InLineColonDelim_Hierarchy,1,charindex(@ListSeparator,InLineColonDelim_Hierarchy,1)),@ListSeparator,'')  END as varchar(8000))
		   , TopLevelNodeWID
           , RecursionLevel + 1 AS RecursionLevel
           , child.[(BusinessObjectToken)Hierarchy_OrganizationSubtype_Name]
		   , CAST(child.(BusinessObjectToken)Hierarchy_Parent_WID as varchar(50))
           , CAST(''>> '' + paddingCrumbs as varchar(500)) AS paddingCrumbs
           , CAST(''>> '' + paddingCrumbs + child.(BusinessObjectToken)Hierarchy_Name as varchar(4000)) AS padded(BusinessObjectToken)HierarchyNames
           , CAST(InLineColonDelim_Hierarchy + @ListSeparator + child.(BusinessObjectToken)Hierarchy_Name as varchar(8000)) AS InLineColonDelim_Hierarchy
		   , CAST(InLineColonDelim_WID + @ListSeparator + child.(BusinessObjectToken)Hierarchy_WID as varchar(8000)) 
		   , CAST(InLineColonDelim_WID + @ListSeparator + child.(BusinessObjectToken)Hierarchy_WID as varchar(8000)) 
		   
   FROM EWSStaging.fws.(BusinessObjectToken)Hierarchy child
   INNER JOIN AllLevels_CTE parent ON parent.(BusinessObjectToken)Hierarchy_WID = child.(BusinessObjectToken)Hierarchy_Parent_WID
   WHERE [RecordEffEndDate] IS NULL
   )  
INSERT WorkArea.[NETID\jabbott3].AllHierarchies (
  businessObject                      
, TopLevelNodeName                   
, TopLevelNodeWID                    
, hierarchyOrder                     
, hierarchyNodeWID                                                
, hierarchyNodeName                  
, RecursionLevel                     
, hierarchyOrganizationSubtypeName   
, ParentWID                          
, paddedHierarchyNames               
, InLineColonDelim_Hierarchy	     
, InLineColonDelim_WID               
, InLineColonDelim_hierarchyOrderNum
, BinarySortValue
, NodeCount
)
   SELECT ''(BusinessObjectToken)''
        , a.TopLevelNodeName
		, a.TopLevelNodeWID
        , ROW_NUMBER() OVER (PARTITION BY a.TopLevelNodeName ORDER BY a.InLineColonDelim_Hierarchy,RecursionLevel  ) 
        , a.(BusinessObjectToken)Hierarchy_WID
	    , a.(BusinessObjectToken)Hierarchy_Name
        , a.RecursionLevel
        , a.(BusinessObjectToken)Hierarchy_OrganizationSubtype_Name
		, a.ParentWID
        , a.padded(BusinessObjectToken)HierarchyNames
        , a.InLineColonDelim_Hierarchy	
		, a.InLineColonDelim_WID
		, a.InLineColonDelim_rowNumber
		, BinarySortValue = CAST(CAST(ROW_NUMBER() OVER (PARTITION BY a.TopLevelNodeName ORDER BY a.InLineColonDelim_Hierarchy,RecursionLevel) AS BINARY(4))  AS VARBINARY(8000)) 
        , NodeCount  = ISNULL(CAST(0 AS INT),0)
   FROM   AllLevels_CTE a
   ORDER BY  a.TopLevelNodeName
           , a.InLineColonDelim_Hierarchy,RecursionLevel;'

SET @CMD_buildHierarchies_Type2 = REPLACE(
                                      REPLACE(@CMD_buildHierarchies_Type1,'(BusinessObjectToken)Hierarchy_Parent_WID','(BusinessObjectToken)Hierarchy_HierarchyData_Parent_WID')
                                  , '(BusinessObjectToken)Hierarchy_OrganizationSubtype_Name', '(BusinessObjectToken)Hierarchy_Subtype_Name')
SET @CMD_buildHierarchies_Type3 = REPLACE(
                                      REPLACE(
									      REPLACE(@CMD_buildHierarchies_Type1,'(BusinessObjectToken)Hierarchy_Name','Name')
                                        , '(BusinessObjectToken)Hierarchy_OrganizationSubtype_Name','Subtype_Name')
								    , '(BusinessObjectToken)Hierarchy_Parent_WID','HierarchyData_Parent_WID')
SET @CMD_buildHierarchies_Type4 =  REPLACE(@CMD_buildHierarchies_Type1, '(BusinessObjectToken)Hierarchy_OrganizationSubtype_Name', '(BusinessObjectToken)Hierarchy_Subtype_Name')
SET @CMD_buildHierarchies_Type5 = REPLACE(REPLACE(REPLACE(@CMD_buildHierarchies_Type1, 'child.[(BusinessObjectToken)Hierarchy_OrganizationSubtype_Name]', 'NULL'),'a.(BusinessObjectToken)Hierarchy_OrganizationSubtype_Name','NULL'),'h.[(BusinessObjectToken)Hierarchy_OrganizationSubtype_Name]','NULL as col1')

DECLARE @counter int = 1
      , @max int = (SELECT max(BusinessObjectID) FROM #BusinessObjects)

WHILE @counter < @max+1
   BEGIN
      SELECT @BusinessObject = BusinessObject
	        , @StorageType   = StorageType 
	  FROM #BusinessObjects 
	  WHERE BusinessObjectID = @counter

      SELECT @CMD = 
          CASE @StorageType  
	          WHEN 1 THEN @CMD_buildHierarchies_Type1
		      WHEN 2 THEN @CMD_buildHierarchies_Type2
			  WHEN 3 THEN @CMD_buildHierarchies_Type3
			  WHEN 4 THEN @CMD_buildHierarchies_Type4
			  WHEN 5 THEN @CMD_buildHierarchies_Type5
		      ELSE ''
      	  END

	  SELECT @CMD = REPLACE(@CMD, '(BusinessObjectToken)', @BusinessObject)
	  
      IF @CMD = ''
         GOTO SKIP_ROW
		 
      EXEC sp_executesql @CMD, @params

      SKIP_ROW:
      SELECT @counter = @counter + 1
   END
GO

DELETE WorkArea.[NETID\jabbott3].AllHierarchies
where TopLevelNodeName like '%inactive%'
GO
DELETE WorkArea.[NETID\jabbott3].AllHierarchies
where RecursionLevel=1
and (hierarchyNodeName NOT LIKE '%01%'
and hierarchyNodeName NOT LIKE 'All %')
GO
delete from WorkArea.[NETID\jabbott3].AllHierarchies
where RecursionLevel<>1
and ParentWID NOT IN (SELECT hierarchyNodeWID from WorkArea.[NETID\jabbott3].AllHierarchies)
GO
CREATE INDEX IX_AllHierarchies_1 ON WorkArea.[NETID\jabbott3].AllHierarchies(businessObject)
CREATE INDEX IX_AllHierarchies_2 ON WorkArea.[NETID\jabbott3].AllHierarchies(businessObject, TopLevelNodeName)
CREATE INDEX IX_AllHierarchies_4 ON WorkArea.[NETID\jabbott3].AllHierarchies(businessObject, TopLevelNodeName, hierarchyNodeWID)
--CREATE INDEX IX_AllHierarchies_5 ON WorkArea.[NETID\jabbott3].AllHierarchies(businessObject, TopLevelNodeName, hierarchyNodeWID)
GO
update c
set Parent_AllHierarchiesID = p.AllHierarchiesID
from WorkArea.[NETID\jabbott3].AllHierarchies c
inner join WorkArea.[NETID\jabbott3].AllHierarchies p on p.hierarchyNodeWID=c.ParentWID and p.businessObject=c.businessObject and p.TopLevelNodeName=c.TopLevelNodeName
GO

update a
set SelfRefBottomUpTrail_byName = [NETID\jabbott3].fn_getSelfRefBottomUpTrail_byName(businessObject, TopLevelNodeName, hierarchyNodeWID)
from WorkArea.[NETID\jabbott3].AllHierarchies a

update a
set SelfRefBottomUpTrail_byWID = [NETID\jabbott3].fn_getSelfRefBottomUpTrail_byWID(businessObject, TopLevelNodeName, hierarchyNodeWID)
from WorkArea.[NETID\jabbott3].AllHierarchies a

update a
set SelfRefBottomUpTrail_byAllHierarchiesID = [NETID\jabbott3].fn_getSelfRefBottomUpTrail_byAllHierarchiesID(businessObject, TopLevelNodeName, hierarchyNodeWID)
from WorkArea.[NETID\jabbott3].AllHierarchies a

update a
set SelfRefTopDownTrail_byAllHierarchiesID = [NETID\jabbott3].fn_getSelfRefTopDownTrail_byAllHierarchiesID(businessObject, TopLevelNodeName, hierarchyNodeWID)
from WorkArea.[NETID\jabbott3].AllHierarchies a

update a
set BinarySortPath = [NETID\jabbott3].fn_getSelfRefTopDownTrail_byBinarySortValue(businessObject, TopLevelNodeName, hierarchyNodeWID)
from WorkArea.[NETID\jabbott3].AllHierarchies a
GO

UPDATE WorkArea.[NETID\jabbott3].AllHierarchies 
SET LeftBoundary = 2 * hierarchyOrder - RecursionLevel
GO
;WITH cteCountSubs AS (
   SELECT hierarchyOrder = CAST(SUBSTRING(h.BinarySortPath,t.N,4) AS INT)
        , NodeCount  = COUNT(*) --Includes current node
        , BusinessObject
        , TopLevelNodeName
FROM WorkArea.[NETID\jabbott3].AllHierarchies h
   , WorkArea.[NETID\jabbott3].HTally t
WHERE t.N BETWEEN 1 AND DATALENGTH(BinarySortPath)
GROUP BY SUBSTRING(h.BinarySortPath,t.N,4)
       , BusinessObject
       , TopLevelNodeName
) UPDATE h
     SET h.NodeCount  = downline.NodeCount
       , h.RightBoundary = (downline.NodeCount - 1) * 2 + LeftBoundary + 1
    FROM WorkArea.[NETID\jabbott3].AllHierarchies h
         INNER JOIN cteCountSubs downline ON h.hierarchyOrder = downline.hierarchyOrder
    WHERE h.BusinessObject = downline.BusinessObject
      AND h.TopLevelNodeName = downline.TopLevelNodeName


/*
DECLARE @counter int = 1
      , @max int 
      , @WID char(32)

select @counter = min(rowNumber)
     , @max= max(rowNumber) 
from #temp

while @counter<@max+1
begin

select @WID= ProgramHierarchy_WID
from #temp
WHERE rowNumber=@counter

update #temp
set InLineColonDelim_rowNumber = REPLACE(InLineColonDelim_rowNumber,@WID,CAST(@counter as varchar(10)))


select @counter = min(rowNumber) from #temp where rowNumber>@counter
end


*/
