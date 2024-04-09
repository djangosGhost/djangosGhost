


--------------------------------------------------------
-- FIND Hierarchical Ancestoral line to the top from any node
--------------------------------------------------------
SELECT h2.RecursionLevel
     , h2.hierarchyNodeWID
	 , h2.hierarchyNodeName
	 , h2.hierarchyNodeRefID
	 , h2.InLineColonDelim_Hierarchy
	 , h2.SelfRefBottomUpTrail_byRefID
FROM WorkArea.[NETID\jabbott3].AllHierarchies h1
INNER JOIN WorkArea.[NETID\jabbott3].AllHierarchies h2 ON h2.businessObject = h1.businessObject AND h2.TopLevelNodeName = h1.TopLevelNodeName
WHERE h1.LeftBoundary BETWEEN h2.LeftBoundary AND h2.RightBoundary 
AND   h1.hierarchyNodeRefID  = 'ACH101771'

--------------------------------------------------------
-- FIND ALL subordinate hierarchies from any node
--------------------------------------------------------
SELECT h1.RecursionLevel
     , h1.hierarchyNodeWID
	 , h1.hierarchyNodeName
	 , h1.hierarchyNodeRefID
	 , h1.InLineColonDelim_Hierarchy
	 , h1.SelfRefBottomUpTrail_byRefID
FROM WorkArea.[NETID\jabbott3].AllHierarchies h1
INNER JOIN WorkArea.[NETID\jabbott3].AllHierarchies h2 ON h2.businessObject = h1.businessObject AND h2.TopLevelNodeName = h1.TopLevelNodeName
WHERE h1.LeftBoundary BETWEEN h2.LeftBoundary AND h2.RightBoundary 
AND   h2.hierarchyNodeRefID  = 'ACH100018'


--------------------------------------------------------------------------------
-- FIND all Cost Centers within Foster School of Business Cost Center Hierarchy
--------------------------------------------------------------------------------
SELECT h1.RecursionLevel
     , h1.hierarchyNodeWID
	 , h1.hierarchyNodeName
	 , h1.hierarchyNodeRefID
	 , h1.SelfRefBottomUpTrail_byRefID
	 , c.CostCenterCode
	 , c.CostCenterName
	 , c.CostCenterReferenceID
FROM WorkArea.[NETID\jabbott3].AllHierarchies h1
INNER JOIN WorkArea.[NETID\jabbott3].AllHierarchies h2 ON h2.businessObject = h1.businessObject AND h2.TopLevelNodeName = h1.TopLevelNodeName
INNER JOIN UWODS.dbo.CostCenterHierarchyCostCenter chc ON chc.CostCenterHierarchyWID = h1.hierarchyNodeWID
INNER JOIN UWODS.dbo.CostCenter c ON c.CostCenterKey = chc.CostCenterKey
WHERE h1.LeftBoundary BETWEEN h2.LeftBoundary AND h2.RightBoundary 
--AND   h2.hierarchyNodeWID = '6495c52532ff1001f875d9c82b1e0002' 
AND h2.hierarchyNodeRefID = 'CCH100023'-- Foster School of Business Cost Center Hierarchy




--------------------------------------------------------------------------------
-- A View to FIND all Cost Centers within a CC Hierarchy
--------------------------------------------------------------------------------

GO
DROP  VIEW IF EXISTS [NETID\jabbott3].viewCostCentersByHierarchyRefID
GO
CREATE VIEW [NETID\jabbott3].viewCostCentersByHierarchyRefID
AS
SELECT h2.hierarchyNodeRefID           as parent_hierarchyReferenceID
     , h1.hierarchyNodeWID             as hierarchyWID
	 , h1.hierarchyNodeName            as hierarchyName
	 , h1.hierarchyNodeRefID           as hierarchyReferenceID
	 , h1.SelfRefBottomUpTrail_byRefID as BottomUpBreadCrumb
	 , c.CostCenterCode
	 , c.CostCenterName
	 , c.CostCenterReferenceID
FROM WorkArea.[NETID\jabbott3].AllHierarchies h1
INNER JOIN WorkArea.[NETID\jabbott3].AllHierarchies h2 ON h2.businessObject = h1.businessObject AND h2.TopLevelNodeName = h1.TopLevelNodeName
INNER JOIN UWODS.dbo.CostCenterHierarchyCostCenter chc ON chc.CostCenterHierarchyWID = h1.hierarchyNodeWID
INNER JOIN UWODS.dbo.CostCenter c ON c.CostCenterKey = chc.CostCenterKey
WHERE h1.LeftBoundary BETWEEN h2.LeftBoundary AND h2.RightBoundary 
GO

SELECT CostCenterCode
	 , CostCenterName
	 , CostCenterReferenceID 
from [NETID\jabbott3].viewCostCentersByHierarchyRefID 
WHERE parent_hierarchyReferenceID = 'CCH100023'