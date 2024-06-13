-- Creating new table: housingdata and populating from csv file
-- Loading data from csv file to SQL using LOAD DATA INFILE since the import wizard doesn't work properly, and it skips empty cells

use nashvillehousing;
drop table if exists housingdata;
CREATE TABLE housingdata
(
uniqueID int,
ParcelID varchar(255),
LandUse varchar(255),
PropertyAddress varchar(255),
SaleDate date,
SalePrice int,
LegalReference varchar(255),
SoldAsVacant varchar(255),
OwnerName varchar(255),
OwnerAddress varchar(255),
Acreage int,
TaxDistrict varchar(255),
LandValue int,
BuildingValue int,
TotalValue int,
YearBuilt int,
Bedrooms int,
FullBath int,
HalfBath int
);

LOAD DATA INFILE 'housing_data.csv' INTO TABLE housingdata
FIELDS TERMINATED BY ','
IGNORE 1 LINES;