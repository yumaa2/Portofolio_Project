/* 
Cleaning Data in SQL Queries (MySQL)
*/

SELECT *
FROM Nashville_Housing_Data;

--------------------------------------------------------------------------------------------------------------
-- Standarisasi Format Tanggal

SELECT SaleDate, STR_TO_DATE(SaleDate, '%M %d, %Y')
FROM Nashville_Housing_Data;

UPDATE Nashville_Housing_Data 
SET SaleDate = STR_TO_DATE(SaleDate, '%M %d, %Y')

--------------------------------------------------------------------------------------------------------------
-- Populasi Data Property Address

SELECT *
FROM Nashville_Housing_Data
WHERE PropertyAddress is null
ORDER BY ParcelID ;

SELECT ParcelID, PropertyAddress, COUNT(*) 
FROM Nashville_Housing_Data
GROUP BY ParcelID, PropertyAddress 
HAVING COUNT(*) > 1; -- kita mengetahui bahwa parcelID yang sama memiliki alamat yang sama

SELECT 
	a.ParcelID , 
	a.PropertyAddress,
	b.PropertyAddress,
	IFNULL(a.PropertyAddress, b.PropertyAddress) 
FROM Nashville_Housing_Data as a
JOIN Nashville_Housing_Data as b
ON a.ParcelID = b.ParcelID 
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

CREATE TABLE Nashville_Housing_Data_1 as 
SELECT 
	a.UniqueID, a.ParcelID, a.LandUse, 
	CASE WHEN a.PropertyAddress IS NULL THEN b.PropertyAddress ELSE a.PropertyAddress END PropertyAddress  , 
	a.SaleDate, a.SalePrice, a.LegalReference, a.SoldAsVacant, a.OwnerName, a.OwnerAddress, a.Acreage, a.TaxDistrict, 
	a.LandValue, a.BuildingValue, a.TotalValue, a.YearBuilt, a.Bedrooms, a.FullBath, a.HalfBath
FROM Nashville_Housing_Data as a
LEFT JOIN Nashville_Housing_Data as b
ON a.ParcelID = b.ParcelID 
AND a.UniqueID <> b.UniqueID;

--------------------------------------------------------------------------------------------------------------
-- Memecah Alamat menjadi kolom masing-masing (Address, City, State)

SELECT PropertyAddress 
FROM Nashville_Housing_Data_1;

SELECT 
	PropertyAddress , 
	SUBSTRING(PropertyAddress, 1, POSITION(',' IN PropertyAddress) - 1) as Address,
	SUBSTRING(PropertyAddress, POSITION(',' IN PropertyAddress) + 2) as City 
FROM Nashville_Housing_Data_1

ALTER TABLE Nashville_Housing_Data_1 
ADD PropertySplitAddress VARCHAR(255)

ALTER TABLE Nashville_Housing_Data_1 
ADD PropertySplitCity VARCHAR(255)

UPDATE Nashville_Housing_Data_1 
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, POSITION(',' IN PropertyAddress) - 1),
PropertySplitCity = SUBSTRING(PropertyAddress, POSITION(',' IN PropertyAddress) + 2)

SELECT 
	OwnerAddress,
	TRIM(SUBSTRING_INDEX(OwnerAddress, ',', 1)) as address,
	TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', -2), ',', 1)) as city,
	TRIM(SUBSTRING_INDEX(OwnerAddress, ',', -1)) as state
FROM Nashville_Housing_Data_1



ALTER TABLE Nashville_Housing_Data_1 
ADD OwnerSplitAddress VARCHAR(255);

ALTER TABLE Nashville_Housing_Data_1 
ADD OwnerSplitCity VARCHAR(255);

ALTER TABLE Nashville_Housing_Data_1 
ADD OwnerSplitState VARCHAR(255);

UPDATE Nashville_Housing_Data_1 
SET OwnerSplitAddress = TRIM(SUBSTRING_INDEX(OwnerAddress, ',', 1));

UPDATE Nashville_Housing_Data_1 
SET OwnerSplitCity = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', -2), ',', 1));

UPDATE Nashville_Housing_Data_1 
SET OwnerSplitState = TRIM(SUBSTRING_INDEX(OwnerAddress, ',', -1));

SELECT PropertySplitAddress, PropertySplitCity , OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
FROM Nashville_Housing_Data_1

SELECT *
from Nashville_Housing_Data_1 nhd 

--------------------------------------------------------------------------------------------------------------
-- Merubah Y dan N Menjadi No dan Yes dalam Kolom "SoldAsVacant"

SELECT DISTINCT (SoldAsVacant), COUNT(SoldAsVacant) 
FROM Nashville_Housing_Data_1 nhd 
group by SoldAsVacant 

SELECT 
	SoldAsVacant,
	CASE 
		WHEN SoldAsVacant = 'N' THEN 'No'
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		ELSE SoldAsVacant End Fixed
FROM Nashville_Housing_Data_1
WHERE SoldAsVacant = 'Y'

UPDATE Nashville_Housing_Data_1 
SET SoldAsVacant = CASE 
						WHEN SoldAsVacant = 'N' THEN 'No'
						WHEN SoldAsVacant = 'Y' THEN 'Yes'
						ELSE SoldAsVacant End
						
SELECT DISTINCT (SoldAsVacant)
FROM Nashville_Housing_Data_1 nhd 

--------------------------------------------------------------------------------------------------------------
-- Menghilangkan duplikat


CREATE TABLE Nashville_Housing_Data_2 AS

WITH RowNumCTE as (

SELECT 
	*,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID ,
				 PropertyAddress ,
				 SalePrice ,
				 SaleDate ,
				 LegalReference 
				 ORDER BY 
				 	UniqueID ) row_num
FROM Nashville_Housing_Data_1
ORDER BY ParcelID)

SELECT UniqueID, ParcelID, LandUse, PropertyAddress, SaleDate, SalePrice, LegalReference, SoldAsVacant, OwnerName, OwnerAddress, Acreage, TaxDistrict, LandValue, BuildingValue, TotalValue, YearBuilt, Bedrooms, FullBath, HalfBath, PropertySplitAddress, PropertySplitCity, OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
FROM RowNumCTE
WHERE row_num = 1

SELECT *
FROM Nashville_Housing_Data_2 nhd 

--------------------------------------------------------------------------------------------------------------
-- Menghapus Kolom Yang Tidak Digunakan

SELECT *
FROM Nashville_Housing_Data_2 nhd 

ALTER TABLE Nashville_Housing_Data_2 
DROP COLUMN OwnerAddress,
DROP COLUMN PropertyAddress, 
DROP COLUMN TaxDistrict


















