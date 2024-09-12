-- Create duplicate of original
CREATE TABLE IF NOT EXISTS housing_clean AS
SELECT * FROM housing;

-- Cleaning Housing data project 
ALTER TABLE housing_clean
ALTER COLUMN sale_date TYPE date USING CAST(sale_date AS date);

SELECT pg_typeof(sale_date)
FROM housing_clean
LIMIT 10;

 -- Populate property_address with ParcelID & self join
UPDATE housing_clean
SET property_address = COALESCE(h1.property_address, h2.property_address)
FROM housing_clean h1
JOIN housing_clean h2
    ON h1.parcel_id = h2.parcel_id
    AND h1.unique_id <> h2.unique_id
WHERE h1.property_address IS NULL;


-- Split property addres and city
ALTER TABLE housing_clean
ADD COLUMN property_city VARCHAR(255);

UPDATE housing_clean
SET property_city = INITCAP(SPLIT_PART(property_address, ',', 2)),
    property_address = INITCAP(SPLIT_PART(property_address,',', 1 ));

SELECT property_city, property_address
FROM housing_clean;


-- Split owner addres, city and state
ALTER TABLE housing_clean
ADD COLUMN owner_state VARCHAR(255),
ADD COLUMN owner_city VARCHAR(255);

UPDATE housing_clean
SET owner_state = SPLIT_PART(owner_address, ',', 3),
    owner_city = INITCAP(SPLIT_PART(owner_address, ',', 2)),
    owner_address = INITCAP(SPLIT_PART(owner_address, ',', 1));

-- Capitalize other columns
UPDATE housing_clean
SET owner_name = INITCAP(owner_name)
    landuse = INITCAP(landuse)

-- Clean sold as vacant column
SELECT DISTINCT(sold_vacant)
FROM housing_clean;

UPDATE housing_clean
SET sold_vacant = CASE WHEN sold_vacant = 'Y' THEN TRUE
    WHEN sold_vacant = 'Yes' THEN TRUE
    ELSE FALSE END;

ALTER TABLE housing_clean
ALTER COLUMN sold_vacant TYPE BOOLEAN USING sold_vacant::BOOLEAN;

-- Remove duplicates
WITH row_num_cte AS (
SELECT *, 
    ROW_NUMBER() OVER (PARTITION BY parcel_id,
                            property_address,
                            sale_price,
                            sale_date,
                            legal_reference ORDER BY parcel_id) AS row_num
FROM housing_clean
)
DELETE 
FROM housing_clean
USING row_num_cte
WHERE row_num_cte.unique_id = housing_clean.unique_id
AND row_num > 1;


-- Delete unused columns
ALTER TABLE housing_clean
DROP tax_district;

SELECT * FROM housing_clean
LIMIT 1000