-- Variables 
-- Load document types list 
DECLARE @DTList TABLE (Value INT)
INSERT INTO @DTList 
	SELECT DISTINCT id.itemtypenum	
	FROM hsi.itemdata AS id 
	GROUP BY id.itemtypenum;

-- Count total documents for document types included in documtent type group
SELECT COUNT(*) AS Total_docs
FROM hsi.itemdata AS id
WHERE id.itemtypenum IN (SELECT DISTINCT VALUE from @DTList);
