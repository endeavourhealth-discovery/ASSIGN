DECLARE @tResidential TABLE (id int, code varchar(20))
INSERT INTO @tResidential
VALUES(1,'R'),(2,'RD'),(3,'RD01'),(4,'RD02'),(5,'RD03'),(6,'RD04'),(7,'RD06'),(8,'RD07'),(9,'RD10'),(10,'RH02'),(11,'U'),(12,'UC'),(13,'UP'),(14,'X')

declare @gms varchar

DROP TABLE IF EXISTS #tUPRN
SELECT
	x.patient_id,
	x.dom,
	address.id,
	uprn.uprn_ralf00,
	address.start_date,
	address.end_date,
	uprn.uprn_property_classification,
	address.use_concept_id,
	uprn.match_date,
	uprn.qualifier,
	[test01].[dbo].GMS_V3(x.patient_id, x.dom) as gms
INTO #tUPRN
FROM [test01].[dbo].[patient_address] address
JOIN [test01].[dbo].[patient_address_match] uprn ON uprn.patient_address_id= address.id
JOIN [db_lookup].[gpp].[ncmp_gms_data] x ON x.patient_id = address.patient_id
WHERE 1=1
AND (address.start_date <= x.dom OR address.start_date is null)
AND (address.end_date >= x.dom OR address.end_date is null)
AND uprn_property_classification IN (select code from @tResidential) OR (qualifier = 'Best (residential) match')
AND use_concept_id <> '1335360' -- Temps
-- AND ([test01].[dbo].GMS_V3(x.patient_id, x.dom) = 1)
AND gms = 1

CREATE CLUSTERED INDEX cx_tUPRN
ON #tUPRN (id, start_date);

SELECT *
FROM (
   SELECT
		*,
        ROW_NUMBER() OVER (PARTITION BY patient_id ORDER BY id DESC, start_date DESC) AS rn
   FROM #tUPRN
   ) as t
WHERE rn = 1