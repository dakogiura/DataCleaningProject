-- Table used to be called 'housingdata'

-- alter table nashvillehousing.housingdata
-- rename to nashvillehousing.nashville_housing_data;

SELECT
	*
FROM
	nashvillehousing.nashville_housing_data;

select
	count(*)
from
	nashville_housing_data;

update
	nashville_housing_data
set
	PropertyAddress = NULL
where
	PropertyAddress = '';

-- 1.) Populating the PropertyAddress where blank
select
	*
from
	nashville_housing_data
where
	PropertyAddress IS NULL
order by
	ParcelID;
	-- Here we figure out that ParcelID is an identifier. Same ParcelIDs will have same PropertyAddress
select
	a.ParcelID,
    a.PropertyAddress,
    b.ParcelID,
    b.PropertyAddress,
    IFNULL(a.PropertyAddress,b.PropertyAddress)
from
	nashville_housing_data a
join
	nashville_housing_data b
	on
		a.ParcelID = b.ParcelID
        and
        a.uniqueID <> b.uniqueID
where
	a.PropertyAddress IS NULL;
	-- Use update function with join function from earlier to replace any NULLs in PropertyAddress
    -- Use IFULL() replace a.PropertyAddress with b.PropertyAddress if a.PropertyAddress was a NULL value
update
	nashville_housing_data a
join
	nashville_housing_data b
	on
		a.ParcelID = b.ParcelID
        and
        a.uniqueID <> b.uniqueID
set
	a.PropertyAddress = IFNULL(a.PropertyAddress,b.PropertyAddress)
where
	a.PropertyAddress IS NULL;

-- 2.) Breaking out Addresses into Address, City, State (if any)
select
	PropertyAddress
from
	nashville_housing_data;
	-- Here we find out that the delimiter is a comma
    -- Use substring_index to separate the two out
select
	substring_index(PropertyAddress, ',', 1)  as Address,
    substring_index(PropertyAddress, ',', -1) as City
from
	nashville_housing_data;
	-- Creating two new columns in the Table
    -- Road Address:
alter table
	nashville_housing_data
add
	PropertyAddressRoad varchar(255);
update
	nashville_housing_data
set
	PropertyAddressRoad = substring_index(PropertyAddress, ',', 1);
    -- City Address:
alter table
	nashville_housing_data
add
	PropertyAddressCity varchar(255);
update
	nashville_housing_data
set
	PropertyAddressCity = substring_index(PropertyAddress, ',', -1);
	-- Check:
select
	*
from
	nashville_housing_data;
	-- I accidentally named one of the columns differently from the one I wanted to add values to.
-- alter table nashville_housing_data
-- drop column PropertyCity;

	-- Change OwnerAddress to Road, City, State
select
	OwnerAddress
from
	nashville_housing_data;

select
	substring_index(OwnerAddress, ',', 1) 							  as OwnerAddressRoad,
	(substring_index(substring_index(OwnerAddress, ',', 2), ',', -1)) as OwnerAddressCity,
	substring_index(OwnerAddress, ',', -1) 							  as OwnerAddressState
from
	nashville_housing_data;
    
    -- Road
alter table
	nashville_housing_data
add
	OwnerAddressRoad varchar(255);
update
	nashville_housing_data
set
	OwnerAddressRoad = substring_index(OwnerAddress, ',', 1);
    
	-- City
alter table
	nashville_housing_data
add
	OwnerAddressCity varchar(255);
update
	nashville_housing_data
set
	OwnerAddressCity = (substring_index(substring_index(OwnerAddress, ',', 2), ',', -1));
    
    -- State
alter table
	nashville_housing_data
add
	OwnerAddressState varchar(255);
update
	nashville_housing_data
set
	OwnerAddressState = substring_index(OwnerAddress, ',', -1);
    
-- 3.) Change Yes and No to 'Y' and 'N'
select
	distinct SoldAsVacant,
    count(SoldAsVacant)
from
	nashville_housing_data
group by
	SoldAsVacant
order by
	2
;
	-- Use CASE WHEN
SELECT
	SoldAsVacant,
	CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
		AS SoldAsVacantUpdated
FROM
	nashville_housing_data
;
UPDATE
	nashville_housing_data
SET
SoldAsVacant = 
(CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END)
;

-- 4.) Removing Duplicate Values
	-- Using ROWNUM and CTE
WITH RowNumCTE AS (
SELECT
	*,
    ROW_NUMBER() OVER (
    PARTITION BY ParcelID,
				 PropertyAddress,
                 SalePrice,
                 SaleDate,
                 LegalReference
                 ORDER BY
					UniqueID
				 ) AS row_num
FROM
	nashville_housing_data
)
DELETE FROM
	RowNumCTE
WHERE
	row_num > 1
;

-- 5.) Deleting Unused Columns
SELECT
	*
FROM
	nashville_housing_data
;
ALTER TABLE
	nashville_housing_data
DROP COLUMN
	OwnerAddress,
DROP COLUMN
	PropertyAddress,
DROP COLUMN
	TaxDistrict
;