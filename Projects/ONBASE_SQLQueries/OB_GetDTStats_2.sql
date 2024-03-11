-- Variables 
-- Load document types list 
DECLARE @DTList TABLE (Value INT)
INSERT INTO @DTList 
	SELECT DISTINCT id.itemtypenum	
	FROM hsi.itemdata AS id 
	GROUP BY id.itemtypenum;

-- Count documents for document types included in document group type, ordered by dt groups then doc types
SELECT id.itemtypegroupnum, 
		dtg.itemtypegroupname,
		id.itemtypenum, 
		dt.itemtypename, 
		COUNT(id.itemnum) AS Total_Docs, 
		ROUND(SUM(dp.filesize),2) AS Total_size_MB
FROM hsi.itemdata AS id
	INNER JOIN hsi.doctype AS dt 
		ON dt.itemtypenum = id.itemtypenum
	INNER JOIN hsi.itemtypegroup AS dtg 
		ON dtg.itemtypegroupnum = id.itemtypegroupnum
	INNER JOIN hsi.itemdatapage AS dp 
		ON id.itemnum = dp.itemnum
WHERE id.itemtypenum IN (SELECT VALUE from @DTList)
GROUP BY  id.itemtypegroupnum, dtg.itemtypegroupname, id.itemtypenum, dt.itemtypename
ORDER BY  id.itemtypegroupnum, id.itemtypenum;
