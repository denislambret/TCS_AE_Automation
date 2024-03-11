-- Variables 
-- Load document types list 
DECLARE @DTList TABLE (Value INT)
INSERT INTO @DTList 
	SELECT DISTINCT id.itemtypenum	
	FROM hsi.itemdata AS id 
	GROUP BY id.itemtypenum;

-- Count documents for document types included in a document group type, 
-- grouped by  doctypegroups, 
-- sort by dt groups then doc types
SELECT id.itemtypegroupnum, 
		dtg.itemtypegroupname,
		COUNT(id.itemnum) AS Total_Docs, 
		SUM(dp.filesize) AS Total_size
FROM hsi.itemdata AS id
	INNER JOIN hsi.doctype AS dt 
		ON dt.itemtypenum = id.itemtypenum
	INNER JOIN hsi.itemtypegroup AS dtg 
		ON dtg.itemtypegroupnum = id.itemtypegroupnum
	INNER JOIN hsi.itemdatapage AS dp 
		ON id.itemnum = dp.itemnum
WHERE id.itemtypenum IN (SELECT VALUE from @DTList)
GROUP BY  id.itemtypegroupnum, dtg.itemtypegroupname
ORDER BY  id.itemtypegroupnum;